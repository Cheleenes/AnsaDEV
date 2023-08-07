public class OrderTriggerHandler {
    public void handleBeforeInsert(List<Order> newList){
    }
    
    public void handleBeforeUpdate(List<Order> newList, Map<Id,Order> oldMap){
        /*for(Order ord : newList){
            if(ord.Status == 'Processing' && oldMap.get(ord.Id).Status == 'Rejected' && ord.D365Id__c == null){
                //Check Inventory OCI callout. Si terms = true && limit - blance >= ord.ammount -> ord.Status = Appoved, else ord.Status = Rejected
				OCI_OrderInventoryCheck.inventoryCheck(ord);
            }
        }*/
    }
    
    public void handleAfterUpdate(List<Order> newList, Map<Id,Order> oldMap){
        for(Order ord : newList){
            if(ord.Status == 'Activated'){ //&& ord.AMC_Payment_method__c == 'Credit Store'){
                //credit callout. Si terms = true && limit - blance >= ord.ammount -> ord.Status = Appoved, else ord.Status = Rejected
				updateAccountCredit(ord.AccountId, ord.Id, ord.TotalAmount);                
				
            }
            if(((ord.Status == 'Approved' && ord.ANSA_Ready_for_D365__c == true && ord.AMC_Ignore_Credit_Check__c == false) || (ord.Status == 'Processing' && ord.ANSA_Ready_for_D365__c == true && ord.AMC_Ignore_Credit_Check__c == true)) && ord.D365Id__c == null){// && ord.FACAccount__c != null){
                doCallout(ord.Id);
            }
            /*if(ord.Status == 'Processing' && oldMap.get(ord.Id).Status == 'Rejected' && ord.D365Id__c == null){
                //Check Inventory OCI callout. Si terms = true && limit - blance >= ord.ammount -> ord.Status = Appoved, else ord.Status = Rejected
				OCI_OrderInventoryCheck.inventoryCheck(ord);
            }*/
        }
    }
    
    /*@future(callout=true)
    public static void ociCheckInventory(Id OrderId){
        Order ord = [SELECT Id, Status FROM Order WHERE Id =: OrderId Limit 1];
        String endpointResult = OCI_OrderInventoryCheck.inventoryCheck(ord);
    }*/
    
    @future(callout=true)
    public static void doCallout(Id OrderId){
        Order ord = [Select Id, Account.FAC_Account__r.DataAreaId__c, Account.FAC_Account__r.Name, Account.FAC_Account__r.DeliveryAddressDescription__c, AccountId, Account.DefaultDimensionDisplayValue__c,
                     Account.FAC_Account__r.DefaultDimensionDisplayValue__c,Name, CurrencyIsoCode, Account.FAC_Account__r.CurrencyIsoCode, ShippingAddress, Account.Name,
                     Account.D365Id__c, OrderNumber
                      From Order 
                      Where Id =: OrderId
                      Limit 1];
        List<OrderItem> lstOrdItem = [Select Id, OrderId, OrderItemNumber, Product2.ProductCode, Description, Product2.Description, ANSA_Warehouse__c, UnitPrice,
                                      Quantity, Product2.StockKeepingUnit, Product2.ShippingSiteId__c, Product2.ShippingWarehouseId__c, ListPrice, Product2.Name
                                      From OrderItem 
                                      Where OrderId =: OrderId AND (Product2.ANC_Show_Store__c = true OR (Product2.ANC_Show_Store__c = false AND Product2.Family = 'Pallet'))];
        String endpointResult = WS_D365Callout.updateOrders(ord, lstOrdItem);
        List<String> parsedResponse = WS_D365Parser.updateSalesOrderParser(endpointResult);
        if(parsedResponse != null){
            ord.D365Id__c = parsedResponse[0];
            ord.ANSA_Picking_List__c = parsedResponse[1];
            update ord;
        }
    }
    
    @future(callout=true)
    public static void updateStatus(String OrderId, String statusName){
        Order ord = [Select Id, Status From Order Where Id =: OrderId LIMIT 1];
        ord.Status = statusName;
        update ord;
    }
    
    @future(callout=true)
    public static void updateAccountCredit(String accountId, String orderId, Decimal ordTotalAmmount){
        Account acc = [Select Id, FAC_Account__r.DataAreaId__c, D365Id__c, AMC_Credit_limit__c, Credit_Balance__c From Account Where Id = :accountId LIMIT 1];
        WS_D365Parser.cutomerGetResponse responseCredit = WS_D365Parser.customerGetParser(WS_D365Callout.customerGet(acc, ordTotalAmmount));
        acc.AMC_Credit_limit__c = responseCredit.dmrCreditLimitCur;
        acc.Credit_Balance__c = responseCredit.dmrCreditBalanceCur;
        acc.Need_credit__c = responseCredit.dmrTermsOfPayment;
        acc.ANSA_Available_Credit_Balance__c = responseCredit.dmrAvailableCreditBalanceMST;
        acc.ANSA_Open_Sales_Order_Amount__c = responseCredit.dmrOpenSalesOrdersAmountMST;
        String oldestPendingInvoiceDate = responseCredit.dmrOldestPendingInvoiceDate;
        oldestPendingInvoiceDate = oldestPendingInvoiceDate.replace('T', ' ');
        acc.ANSA_Last_Open_Invoice_Date__c = dateTime.valueOf(oldestPendingInvoiceDate+'Z');
        
        update acc;
        
        System.debug(responseCredit);
        Order ord = [Select Id, Status, AMC_Reason_for_rejection__c From Order Where Id =: OrderId LIMIT 1];
        if(responseCredit.dmrTermsOfPayment == 'EOFM'){
            if(responseCredit.dmrIsWithInCreditTerms == true){// && responseCredit.dmrCreditLimitCur - responseCredit.dmrCreditBalanceCur >= ordTotalAmmount){
                ord.Status = 'Approved';
            }else{
                ord.Status = 'Rejected';
                ord.AMC_Reason_for_rejection__c = 'Failed automatic Credit Management check';
            }
        }else if(responseCredit.dmrTermsOfPayment == 'Cash' || responseCredit.dmrTermsOfPayment == 'COD'){
            if(responseCredit.dmrAvailableCreditBalanceMST < 0){
                ord.Status = 'Rejected';
                ord.AMC_Reason_for_rejection__c = 'Failed automatic Credit Management check';
            }else{
                ord.Status = 'Approved';
            }
        }else{
            ord.Status = 'Rejected';
            ord.AMC_Reason_for_rejection__c = 'Failed automatic Credit Management check';
        }
        update ord;
    }
}