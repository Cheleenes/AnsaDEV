public with sharing class WS_D365Callout {
    public static String ABS_Werehouses = 'MAIN,SPARESAC,SPARESACLG,PDCTG,PDCTG SITE,YARDBC,CRTCLCON,PDCLV,PDCSF,QUARANTBC,TRANSITBC,ABS,PDCPOS,AC PRO,MAINAC,MAINACRES,PDCB,UPRW/HOUSE,CBS,QuarantYC,YARDC,TRANSITC,C3RDPTYFGW,AC DAM FG,MAINACCOM,SDLGB,WP W/HOUSE,OMNIAPLT,WH4,AFGS,WH6,WH1,WH3,WH2,WH7,PDCMH,ADFFGS,SFGS,QUARANTAC,WH5,MT3RDPRTY,MSTR,CMS,GFGS,ANSTAC,VFGS,FGQW,VFGS2,WHDR 4,TRANSITM,HWS,';
    public static String Grenada_Werehouses = 'FG,';
    public static String S01_Werehouses = 'MARABELLA,P-MAIN,P-CSARIMA,P-LONG,P-MARAB,CSSISARIMA,CSSTJAMES,DAMAGES,INDUSTMCS,P-EXPORT,PNONCONFM,FGCENT,FGCENT-KIN,FGPENTA-W2,RMG-KINGST,TOYOTA,EXPORT,QC LAB,Builders H,GPL HW,Real Tuff,P-TRANSIT,CSSISMARAB,MOBAY-DECO,CS MT.HOPE,MANDEVILLE,CSHOP-TP,TOBCL,P-BERGER,PSALEMARAB,PSMLBATCH,P-CSSALE,PPROD,P-SALE,P-QUARANT,TS&D,PCSMTROSE,INB.FGPENT,TEST,NCP-KINGST,PSALECOCOR,P-ADMIN,DIRECT,FGOSW-ALEX,INDPROJ01,SPT,CSAROUCA,CLT,HW E&P,PSALEARIMA,P-RMW,CSCUNUPIA,RMG,CSHOP-DH,PROD,NCP-ALEX,SUN,INT.KINGST,INT.MAND,INT.MOBAY,TRAN,CSHOP-MAND,NCP,';
    public static String SVC_Werehouses = '';
    public static String getToken(){
        System.debug('Token callout...');
        Integration_Data__mdt cfsWS = Integration_Data__mdt.getInstance('Token');
        
        String form64 = '';
        
        form64 += vNHttpFormBuilder.WriteBoundary();
        form64 += vNHttpFormBuilder.WriteBodyParameter('client_id', cfsWS.User__c);
        form64 += vNHttpFormBuilder.WriteBoundary();
        form64 += vNHttpFormBuilder.WriteBodyParameter('client_secret', cfsWS.Password__c);
        form64 += vNHttpFormBuilder.WriteBoundary();
        form64 += vNHttpFormBuilder.WriteBodyParameter('resource', cfsWS.Resource__c);
        form64 += vNHttpFormBuilder.WriteBoundary();
        form64 += vNHttpFormBuilder.WriteBodyParameter('grant_type', 'client_credentials');
        form64 += vNHttpFormBuilder.WriteBoundary();
        
        blob formBlob = EncodingUtil.base64Decode(form64);
        
        String sResponse;

        HttpRequest req = new HttpRequest();
        String sEndpoint = isOrgSandbox() ? cfsWS.Endpoint_Test__c : cfsWS.Endpoint__c;
        sEndpoint = sEndpoint.replace('{tenantId}', cfsWS.Tenant_Id__c);
        req.setEndpoint(sEndpoint);
        req.setTimeout(120000);
        req.setMethod(cfsWS.Method__c);
        req.setBodyAsBlob(formBlob);
        req.setHeader('Content-Type', vNHttpFormBuilder.GetContentType());
		System.debug(req.getBody());
        Http http = new Http();
        HTTPResponse res = http.send(req);
		System.debug(res);
        System.debug(res.getBody());
        if(res.getStatusCode() != 200 && res.getStatusCode() != 201){
            sResponse = 'Error: ' + res.getBody();
            //WS_IntegrationLogs.CreateIntegrationLogs(req, res, sResponse, true);
        }else{
            sResponse = res.getBody();
            //WS_IntegrationLogs.CreateIntegrationLogs(req, res, null, false);
        }

        return sResponse;
    }
	public static String updateCustomers(Account oAccount, Contact oContact){
        
        System.debug('Update customer callout...');
        Integration_Data__mdt cfsWS = Integration_Data__mdt.getInstance('Update_Customer');

        String sToken = getToken();
        String sResponse;

        HttpRequest req = new HttpRequest();
        String sEndpoint = isOrgSandbox() ? cfsWS.Endpoint_Test__c : cfsWS.Endpoint__c;
        req.setEndpoint(sEndpoint);
        req.setTimeout(120000);
        req.setMethod(cfsWS.Method__c);
        req.setHeader('Authorization', 'Bearer ' + WS_D365Parser.tokenParser(sToken));

        customerCreateUpdateContract ccuc = new customerCreateUpdateContract();
        ccuc.dmDataAreaID = oAccount.FAC_Account__r.DataAreaId__c;
        if(oAccount.ANSA_DataLoader__c){
            ccuc.dmCustomerAccount = oAccount.D365Id__c;
        }else{
            ccuc.dmCustomerAccount = oAccount.FAC_Account__r.DataAreaId__c+'_'+oAccount.Id;
        }
        ccuc.dmInvoiceAccount = oAccount.InvoiceAccount__c;
        ccuc.dmPartyType = 'Organization'; //oAccount.PartyType__c;
        ccuc.dmOrganizationName = oAccount.Name;  
        ccuc.dmNameAlias = oAccount.NameAlias__c;
        ccuc.dmPersonFirstName = oContact.FirstName;
        ccuc.dmPersonLastName = oContact.LastName;
        ccuc.dmPrimaryContactEmail = oContact.Email;
        ccuc.dmPrimaryContactPhone = oContact.Phone;
        ccuc.dmDeliveryAddressDescription = oAccount.ShippingStreet;
        ccuc.dmDeliveryAddressCity = oAccount.ShippingCity;
        ccuc.dmInvoiceAddressStreet = oAccount.BillingStreet;
        ccuc.dmCustomerGroupId = oAccount.ItemCustomerGroupId__c;
        ccuc.dmSalesSegmentId = oAccount.SalesSegmentId__c;
        ccuc.dmPaymentMethod = oAccount.PaymentMethod__c;
        ccuc.dmSalesCurrencyCode = oAccount.ANSA_IsExport__c ? 'USD' : oAccount.FAC_Account__r.CurrencyIsoCode;
        ccuc.dmLanguageId = 'en-US'; //oAccount.LanguageId__c;
        ccuc.dmDefaultDimensionDisplayValue = oAccount.Financial_Dimensions__c;
        ccuc.dmCRM_SalesforceId = oAccount.Id;
        customerCreateUpdatePayload ccp = new customerCreateUpdatePayload();
        ccp.customerCreateUpdateContract = ccuc;
        String body = JSON.serialize(ccp);
        System.debug(JSON.serializePretty(ccp));
        System.debug(body.replace('customerCreateUpdateContract', '_customerCreateUpdateContract'));
        req.setBody(body.replace('customerCreateUpdateContract', '_customerCreateUpdateContract'));

        Http http = new Http();
        HTTPResponse res = http.send(req);
		System.debug(res);
        System.debug(JSON.serializePretty(res.getBody()));
        if(res.getStatusCode() != 200 && res.getStatusCode() != 201){
            sResponse = 'Error: ' + res.getBody();
            if(!Test.isRunningTest()){
                WS_IntegrationLogs iL = new WS_IntegrationLogs(req.getBody(), req.getEndpoint(), res.getBody(), res.getStatusCode(), sResponse, true);
                System.enqueueJob(iL);
            }
        }else{
            sResponse = res.getBody();
            if(!Test.isRunningTest()){
                WS_IntegrationLogs iL = new WS_IntegrationLogs(req.getBody(), req.getEndpoint(), res.getBody(), res.getStatusCode(), sResponse, false);
                System.enqueueJob(iL);
            }
        }

        return sResponse;
    }
    
    public static String updateCustomers(Account oAccount){
        
        System.debug('Update customer callout...');
        Integration_Data__mdt cfsWS = Integration_Data__mdt.getInstance('Update_Customer');

        String sToken = getToken();
        String sResponse;

        HttpRequest req = new HttpRequest();
        String sEndpoint = isOrgSandbox() ? cfsWS.Endpoint_Test__c : cfsWS.Endpoint__c;
        req.setEndpoint(sEndpoint);
        req.setTimeout(120000);
        req.setMethod(cfsWS.Method__c);
        req.setHeader('Authorization', 'Bearer ' + WS_D365Parser.tokenParser(sToken));

        customerCreateUpdateContract ccuc = new customerCreateUpdateContract();
        ccuc.dmDataAreaID = oAccount.FAC_Account__r.DataAreaId__c;
        if(oAccount.ANSA_DataLoader__c){
            ccuc.dmCustomerAccount = oAccount.D365Id__c;
        }else{
            ccuc.dmCustomerAccount = oAccount.FAC_Account__r.DataAreaId__c+'_'+oAccount.Id;
        }
        ccuc.dmInvoiceAccount = oAccount.InvoiceAccount__c;
        ccuc.dmPartyType = 'Organization'; //oAccount.PartyType__c;
        ccuc.dmOrganizationName = oAccount.FirstName + ' ' + oAccount.LastName;//oAccount.Name;  
        ccuc.dmNameAlias = oAccount.NameAlias__c;
        ccuc.dmPersonFirstName = oAccount.FirstName;
        ccuc.dmPersonLastName = oAccount.LastName;
        ccuc.dmPrimaryContactEmail = oAccount.PersonEmail;
        ccuc.dmPrimaryContactPhone = oAccount.Phone;
        ccuc.dmDeliveryAddressDescription = oAccount.ShippingStreet;
        ccuc.dmDeliveryAddressCity = oAccount.ShippingCity;
        ccuc.dmInvoiceAddressStreet = oAccount.BillingStreet;
        ccuc.dmCustomerGroupId = oAccount.ItemCustomerGroupId__c;
        ccuc.dmSalesSegmentId = oAccount.SalesSegmentId__c;
        ccuc.dmPaymentMethod = oAccount.PaymentMethod__c;
        ccuc.dmSalesCurrencyCode = oAccount.ANSA_IsExport__c ? 'USD' : oAccount.FAC_Account__r.CurrencyIsoCode;
        ccuc.dmLanguageId = 'en-US'; //oAccount.LanguageId__c;
        ccuc.dmDefaultDimensionDisplayValue = oAccount.Financial_Dimensions__c;
        ccuc.dmCRM_SalesforceId = oAccount.Id;
        customerCreateUpdatePayload ccp = new customerCreateUpdatePayload();
        ccp.customerCreateUpdateContract = ccuc;
        String body = JSON.serialize(ccp);
        System.debug(JSON.serializePretty(ccp));
        System.debug(body.replace('customerCreateUpdateContract', '_customerCreateUpdateContract'));
        req.setBody(body.replace('customerCreateUpdateContract', '_customerCreateUpdateContract'));

        Http http = new Http();
        HTTPResponse res = http.send(req);
		System.debug(res);
        System.debug(JSON.serializePretty(res.getBody()));
        if(res.getStatusCode() != 200 && res.getStatusCode() != 201){
            sResponse = 'Error: ' + res.getBody();
            if(!Test.isRunningTest()){
                WS_IntegrationLogs iL = new WS_IntegrationLogs(req.getBody(), req.getEndpoint(), res.getBody(), res.getStatusCode(), sResponse, true);
                System.enqueueJob(iL);
            }
        }else{
            sResponse = res.getBody();
            if(!Test.isRunningTest()){
                WS_IntegrationLogs iL = new WS_IntegrationLogs(req.getBody(), req.getEndpoint(), res.getBody(), res.getStatusCode(), sResponse, false);
                System.enqueueJob(iL);
            }
        }

        return sResponse;
    }
    
    public static String updateOrders(Order oOrder, List<OrderItem> lstItems){
        System.debug('Update order callout...');
        Integration_Data__mdt cfsWS = Integration_Data__mdt.getInstance('Sales_Order');

        String sToken = getToken();
        String sResponse;

        HttpRequest req = new HttpRequest();
        String sEndpoint = isOrgSandbox() ? cfsWS.Endpoint_Test__c : cfsWS.Endpoint__c;
        req.setEndpoint(sEndpoint);
        System.debug('Endpoint: ' + sEndpoint);
        req.setTimeout(120000);
        req.setMethod(cfsWS.Method__c);
        req.setHeader('Authorization', 'Bearer ' + WS_D365Parser.tokenParser(sToken));
        
        salesOrderCreateUpdateContract socu = new salesOrderCreateUpdateContract();
        socu.dmDataAreaID = oOrder.Account.FAC_Account__r.DataAreaId__c;
        dmSalesOrderHeaderContract sohc = new dmSalesOrderHeaderContract();
        sohc.dmDataAreaID = oOrder.Account.FAC_Account__r.DataAreaId__c;
        sohc.dmOrderingCustomerAccountNumber = oOrder.Account.D365Id__c;
        sohc.dmInvoiceCustomerAccountNumber = oOrder.Account.D365Id__c;
        sohc.dmSalesOrderName = oOrder.Account.Name;
        sohc.dmDefaultLedgerDimensionDisplayValue = '';//oOrder.Account.DefaultDimensionDisplayValue__c == null ? '-BB0001-BL002-BT003-TTO-CC072-DP243-DV082-IC001-SL035-RC002- INNCARIBPREM-ASSOCIATED' : oOrder.Account.DefaultDimensionDisplayValue__c;
        sohc.dmCRM_OpportunityName = 'test';
        sohc.dmCRM_QuoteNumber = 'CRM_QN_' + oOrder.OrderNumber;
        sohc.dmCRM_SalesforceId = oOrder.Id;
        sohc.dmCurrencyCode = oOrder.CurrencyIsoCode == 'USD' ? oOrder.CurrencyIsoCode : oOrder.Account.FAC_Account__r.CurrencyIsoCode;
        sohc.dmEmail = 'Fore@ffff.com';//oOrder.AccountId.email;
        sohc.dmContactPersonId = '';
        sohc.dmDeliveryAddressName = String.valueOf(oOrder.ShippingAddress);
        socu.dmSalesOrderHeaderContract = sohc;
        List<dmSalesOrderLineContractArray> dmSalesOrderLineContractArray = new List<dmSalesOrderLineContractArray>();
        System.debug('lstItems.size(): ' + lstItems.size());
        Boolean allHaveWarehouseId = true;
        for(OrderItem oI : lstItems){
            if(oI.ANSA_Warehouse__c == null || oI.ANSA_Warehouse__c == ''){
                allHaveWarehouseId = false;
            }
            String shippingSiteId = '';
            if(ABS_Werehouses.contains(oI.ANSA_Warehouse__c+',')){
                shippingSiteId = 'ABS';
            }
            if(Grenada_Werehouses.contains(oI.ANSA_Warehouse__c+',')){
                shippingSiteId = 'Grenada';
            }
            if(S01_Werehouses.contains(oI.ANSA_Warehouse__c+',')){
                shippingSiteId = 'S01';
            }
            if(SVC_Werehouses.contains(oI.ANSA_Warehouse__c+',')){
                shippingSiteId = 'SVC';
            }
            dmSalesOrderLineContractArray solc = new dmSalesOrderLineContractArray();
            solc.dmDataAreaID = oOrder.Account.FAC_Account__r.DataAreaId__c;
        	//solc.dmSalesOrderNumber = oI.OrderId;
        	solc.dmSalesPrice = oI.UnitPrice;
        	solc.dmCustomersLineNumber = oI.OrderItemNumber;
        	solc.dmItemNumber = oI.Product2.StockKeepingUnit;
        	solc.dmLineDescription = oI.Description;	
        	solc.dmOrderedSalesQuantity = oI.Quantity;
        	solc.dmDefaultLedgerDimensionDisplayValue = '';//oOrder.Account.DefaultDimensionDisplayValue__c == null ? '-BB0001-BL002-BT003-TTO-CC072-DP243-DV082-IC001-SL035-RC002- INNCARIBPREM-ASSOCIATED' : oOrder.Account.DefaultDimensionDisplayValue__c;
        	solc.dmShippingSiteId = shippingSiteId;//'S01'; //oI.ShippingSiteId__c;
        	solc.dmShippingWarehouseId = oI.ANSA_Warehouse__c; //oI.Product2.ShippingWarehouseId__c;
            if(solc.dmShippingWarehouseId == ''){
                solc.dmIsReservationRequiredInCRM = true;
            }else{
                solc.dmIsReservationRequiredInCRM = false;
            }
            solc.dmLineDiscountPercentage = 0;
            solc.dmSalesOrderNumber = oOrder.OrderNumber;
            dmSalesOrderLineContractArray.add(solc);
        }
        socu.dmSalesOrderLineContractArray = dmSalesOrderLineContractArray;
        socu.dmAutoGeneratePickingList = allHaveWarehouseId? 1 : 0;
        
        salesOrderCreateUpdatePayload payload = new salesOrderCreateUpdatePayload();
        payload.salesOrderCreateUpdateContract = socu;
        String body = JSON.serialize(payload, false);
        body = body.replace('salesOrderCreateUpdateContract', '_salesOrderCreateUpdateContract');
        System.debug(body);
        System.debug(JSON.serializePretty(payload));
        System.debug(body);
        req.setBody(body);

        Http http = new Http();
        HTTPResponse res = http.send(req);

        if(res.getStatusCode() != 200 && res.getStatusCode() != 201){
            sResponse = 'Error: ' + res.getBody();
            if(!Test.isRunningTest()){
                WS_IntegrationLogs iL = new WS_IntegrationLogs(req.getBody(), req.getEndpoint(), res.getBody(), res.getStatusCode(), sResponse, true);
                System.enqueueJob(iL);
            }
        }else{
            sResponse = res.getBody();
            if(!Test.isRunningTest()){
                WS_IntegrationLogs iL = new WS_IntegrationLogs(req.getBody(), req.getEndpoint(), res.getBody(), res.getStatusCode(), sResponse, false);
                System.enqueueJob(iL);
            }
        }

        return sResponse;
    }
    
    public static String customerGet(Account oAccount, Decimal orderAmmount){
        System.debug('Customer get callout...');
        Integration_Data__mdt cfsWS = Integration_Data__mdt.getInstance('Customer_Get');

        String sToken = getToken();
        String sResponse;

        HttpRequest req = new HttpRequest();
        String sEndpoint = isOrgSandbox() ? cfsWS.Endpoint_Test__c : cfsWS.Endpoint__c;
        req.setEndpoint(sEndpoint);
        req.setTimeout(120000);
        req.setMethod(cfsWS.Method__c);
        req.setHeader('Authorization', 'Bearer ' + WS_D365Parser.tokenParser(sToken));
        customerGetContractPayload payload = new customerGetContractPayload();
        customerGetContract CGC = new customerGetContract();
        CGC.dmDataAreaId = oAccount.FAC_Account__r.DataAreaId__c;
        CGC.dmCustomerAccount = oAccount.D365Id__c;
        CGC.dmCRM_SalesforceId = oAccount.Id;
        CGC.dmCRM_SalesOrderTotalValue = orderAmmount;
        payload.customerGetContract = CGC;
        String body = JSON.serialize(payload);
        System.debug(JSON.serializePretty(payload));
        System.debug(body.replace('customerGetContract', '_customerGetContract'));
        req.setBody(body.replace('customerGetContract', '_customerGetContract'));
		
        Http http = new Http();
        HTTPResponse res = http.send(req);
		System.debug(res);
        System.debug(JSON.serializePretty(res.getBody()));
        if(res.getStatusCode() != 200 && res.getStatusCode() != 201){
            sResponse = 'Error: ' + res.getBody();
            if(!Test.isRunningTest()){
                WS_IntegrationLogs iL = new WS_IntegrationLogs(req.getBody(), req.getEndpoint(), res.getBody(), res.getStatusCode(), sResponse, true);
                System.enqueueJob(iL);
            }
        }else{
            sResponse = res.getBody();
            if(!Test.isRunningTest()){
                WS_IntegrationLogs iL = new WS_IntegrationLogs(req.getBody(), req.getEndpoint(), res.getBody(), res.getStatusCode(), sResponse, false);
                System.enqueueJob(iL);
            }
        }

        return sResponse;
    }
    
    public static Boolean isOrgSandbox(){
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        return runningInASandbox;
    }
    
    public class customerCreateUpdateContract{
        String dmDataAreaID;
        String dmCustomerAccount;
        String dmInvoiceAccount;
        String dmPartyType;
        String dmOrganizationName;
        String dmNameAlias;
        String dmPersonFirstName;
        String dmPersonLastName;
        String dmPrimaryContactEmail;
        String dmPrimaryContactPhone;
        String dmDeliveryAddressDescription;
        String dmDeliveryAddressCity;
        String dmInvoiceAddressStreet;
        String dmCustomerGroupId;
        String dmSalesSegmentId;
        String dmPaymentMethod;
        String dmSalesCurrencyCode;
        String dmLanguageId;
        String dmDefaultDimensionDisplayValue;
        String dmCRM_SalesforceId;
    }
    
    public class customerCreateUpdatePayload{
        customerCreateUpdateContract customerCreateUpdateContract;
    }
    
    public class salesOrderCreateUpdateContract{
        String dmDataAreaID;
        dmSalesOrderHeaderContract dmSalesOrderHeaderContract;
        List<dmSalesOrderLineContractArray> dmSalesOrderLineContractArray;
        Integer dmAutoGeneratePickingList;
    }
    
    public class dmSalesOrderHeaderContract {
        String dmDataAreaID;
        String dmOrderingCustomerAccountNumber;
        String dmInvoiceCustomerAccountNumber;
        String dmSalesOrderName;
        String dmDefaultLedgerDimensionDisplayValue;
        String dmCRM_OpportunityName;
        String dmCRM_QuoteNumber;
        String dmCRM_SalesforceId;
        String dmCurrencyCode;
        String dmEmail;
        String dmContactPersonId;
        String dmDeliveryAddressName;
        
    }
    
    public class dmSalesOrderLineContractArray{
        String dmDataAreaID;
        String dmSalesOrderNumber;
        Decimal dmSalesPrice;
        String dmCustomersLineNumber;
        String dmItemNumber;
        String dmLineDescription;
        Decimal dmOrderedSalesQuantity;
        Integer dmLineDiscountPercentage;
        String dmDefaultLedgerDimensionDisplayValue;
        String dmShippingSiteId;
        String dmShippingWarehouseId;
        Boolean dmIsReservationRequiredInCRM;
    }
    
    public class salesOrderCreateUpdatePayload{
        salesOrderCreateUpdateContract salesOrderCreateUpdateContract;
    }
    
    public class customerGetContract{
        String dmDataAreaId;
        String dmCustomerAccount;
        String dmCRM_SalesforceId;
        Decimal dmCRM_SalesOrderTotalValue;
    }
    public class customerGetContractPayload{
        customerGetContract customerGetContract;
    }
}