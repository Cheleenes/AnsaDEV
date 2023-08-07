public class AccountTriggerHandler {
    public void handleAfterInsert(List<Account> newList){
        
        Id RTID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FAC Account').getRecordTypeId();
        for(Account ac : newList){
            if(ac.RecordTypeId != RTID && !ac.ANSA_DataLoader__c){
                doCallout(ac.Id, ac.RecordTypeId);
                //AMC_AccountUpdate_Queueable calloutJob = new AMC_AccountUpdate_Queueable(ac.Id, ac.RecordTypeId);
                //System.enqueueJob(calloutJob);
            }
        }
    }
    public void handleAfterUpdate(List<Account> newList, List<Account> oldList, Map<Id,Account> newMap, Map<Id,Account> oldMap){
        
       Id RTID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FAC Account').getRecordTypeId();
        for(Account ac : newList){
            if(ac.RecordTypeId != RTID){
                if(ac.NameAlias__c != oldMap.get(ac.Id).NameAlias__c || ac.ItemCustomerGroupId__c != oldMap.get(ac.Id).ItemCustomerGroupId__c || ac.PaymentMethod__c != oldMap.get(ac.Id).PaymentMethod__c || ac.Name != oldMap.get(ac.Id).Name ||
                   ac.LanguageId__c != oldMap.get(ac.Id).LanguageId__c || ac.PartyType__c != oldMap.get(ac.Id).PartyType__c || ac.DeliveryAddressDescription__c != oldMap.get(ac.Id).DeliveryAddressDescription__c || ac.InvoiceAccount__c != oldMap.get(ac.Id).InvoiceAccount__c ||
                   ac.SalesSegmentId__c != oldMap.get(ac.Id).SalesSegmentId__c || ac.ShippingCity != oldMap.get(ac.Id).ShippingCity || ac.BillingStreet != oldMap.get(ac.Id).BillingStreet || ac.Customer_classification__c != oldMap.get(ac.Id).Customer_classification__c ||
                   ac.Department__c != oldMap.get(ac.Id).Department__c || ac.Division__c != oldMap.get(ac.Id).Division__c || ac.ICDESC__c != oldMap.get(ac.Id).ICDESC__c || ac.Report_Code__c != oldMap.get(ac.Id).Report_Code__c ){
                       doCallout(ac.Id, ac.RecordTypeId);
                       //AMC_AccountUpdate_Queueable calloutJob = new AMC_AccountUpdate_Queueable(ac.Id, ac.RecordTypeId);
                       //System.enqueueJob(calloutJob);
            	}
            }

        }
    }
    
    @future(callout=true)
    public static void doCallout(Id AccountId, Id RTID){
        Id RTIDpAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        if(RTID != RTIDpAcc){
            Account acc = [Select Id, InvoiceAccount__c, PartyType__c, OrganizationName__c, NameAlias__c, FirstName, DataAreaId__c, CustomerAccount__c, Financial_Dimensions__c,
                           Name, PersonEmail, Phone, DeliveryAddressDescription__c, ShippingCity, BillingStreet, FAC_Account__c, CurrencyIsoCode, FAC_Account__r.DataAreaId__c, ShippingStreet,
                           FAC_Account__r.CurrencyIsoCode, SalesSegmentId__c, PaymentMethod__c, SalesCurrencyCode__c, LanguageId__c, DefaultDimensionDisplayValue__c, ItemCustomerGroupId__c,
                           FAC_Account__r.Country_Code__c, D365Id__c, ANSA_DataLoader__c, ANSA_IsExport__c, RecordtypeId
                           From Account 
                           Where Id =: AccountId
                           Limit 1];
            Contact cont;
            try{
                 cont = [Select Id, FirstName, LastName, Phone, Email From Contact Where AccountId =: AccountId Order By CreatedDate DESC Limit 1];
            }catch(Exception e){
                return;
            }

            String externalId = '';
            externalId = WS_D365Parser.updateCustomerParser(WS_D365Callout.updateCustomers(acc, cont));
            if(externalId != ''){
                acc.D365Id__c = externalId;
                //acc.InvoiceAccount__c = externalId;
                update acc;
            }
        }else{
            Account acc = [Select Id, InvoiceAccount__c, PartyType__c, OrganizationName__c, NameAlias__c, DataAreaId__c, CustomerAccount__c, Financial_Dimensions__c,
                           FirstName, LastName, PersonEmail, Phone, DeliveryAddressDescription__c, ShippingCity, BillingStreet, FAC_Account__c, CurrencyIsoCode, FAC_Account__r.DataAreaId__c, ShippingStreet,
                           FAC_Account__r.CurrencyIsoCode, SalesSegmentId__c, PaymentMethod__c, SalesCurrencyCode__c, LanguageId__c, DefaultDimensionDisplayValue__c, ItemCustomerGroupId__c,
                           FAC_Account__r.Country_Code__c, D365Id__c, ANSA_DataLoader__c, ANSA_IsExport__c, RecordtypeId
                           From Account 
                           Where Id =: AccountId
                           Limit 1];
            String externalId = '';
            externalId = WS_D365Parser.updateCustomerParser(WS_D365Callout.updateCustomers(acc));
            if(externalId != ''){
                acc.D365Id__c = externalId;
                //acc.InvoiceAccount__c = externalId;
                update acc;
            }
        }
        
    }
}