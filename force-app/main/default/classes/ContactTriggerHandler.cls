public class ContactTriggerHandler {
    public void handleAfterInsert(List<Contact> newList){
        for(Contact cont : newList){
            if(cont.AccountId != null && cont.LastName != null && cont.Email != null && cont.Phone != null){
				doCallout(cont.AccountId, cont.Id);                
            }
        }
    }
    
    public void handleAfterUpdate(List<Contact> newList, Map<Id, Contact> oldMap){
        for(Contact cont : newList){
            if((cont.AccountId != null && cont.LastName != null && cont.Email != null && cont.Phone != null) && 
               (cont.AccountId != oldMap.get(cont.Id).AccountId || cont.LastName != oldMap.get(cont.Id).LastName || cont.FirstName != oldMap.get(cont.Id).FirstName ||
                cont.Email != oldMap.get(cont.Id).Email || cont.Phone != oldMap.get(cont.Id).Phone)){
                doCallout(cont.AccountId, cont.Id);
            }
        }
    }
    
    @future(callout=true)
    public static void doCallout(Id AccountId, Id ContactId){
        Account acc = [Select Id, D365Id__c, InvoiceAccount__c, PartyType__c, OrganizationName__c, NameAlias__c, FirstName, DataAreaId__c, CustomerAccount__c, Financial_Dimensions__c,
                      Name, PersonEmail, Phone, DeliveryAddressDescription__c, ShippingCity, BillingStreet, FAC_Account__c, CurrencyIsoCode, FAC_Account__r.DataAreaId__c, ShippingStreet,
                      FAC_Account__r.CurrencyIsoCode, SalesSegmentId__c, PaymentMethod__c, SalesCurrencyCode__c, LanguageId__c, DefaultDimensionDisplayValue__c, ItemCustomerGroupId__c,
                      FAC_Account__r.Country_Code__c, ANSA_DataLoader__c, ANSA_IsExport__c
                      From Account 
                      Where Id =: AccountId
                      Limit 1];
        Contact cont = [Select Id, FirstName, LastName, Phone, Email From Contact Where Id =: ContactId Limit 1];
        String externalId = '';
        externalId = WS_D365Parser.updateCustomerParser(WS_D365Callout.updateCustomers(acc, cont));
        if(externalId != ''){
            acc.D365Id__c = externalId;
            update acc;
        }
    }
}