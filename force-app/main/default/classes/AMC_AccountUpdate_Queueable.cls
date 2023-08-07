public class AMC_AccountUpdate_Queueable implements Queueable{
	public Account acc;
    public Contact cont;
    public Id RTID;
    
    public AMC_AccountUpdate_Queueable(String accId, Id accRT){
        RTID = accRT;
        Id RTIDpAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        if(RTID != RTIDpAcc){
            acc = [Select Id, InvoiceAccount__c, PartyType__c, OrganizationName__c, NameAlias__c, FirstName, DataAreaId__c, CustomerAccount__c, Financial_Dimensions__c,
                           Name, PersonEmail, Phone, DeliveryAddressDescription__c, ShippingCity, BillingStreet, FAC_Account__c, CurrencyIsoCode, FAC_Account__r.DataAreaId__c, ShippingStreet,
                           FAC_Account__r.CurrencyIsoCode, SalesSegmentId__c, PaymentMethod__c, SalesCurrencyCode__c, LanguageId__c, DefaultDimensionDisplayValue__c, ItemCustomerGroupId__c,
                           FAC_Account__r.Country_Code__c, D365Id__c, ANSA_DataLoader__c, ANSA_IsExport__c, RecordtypeId
                           From Account 
                           Where Id =: accId
                           Limit 1];
            try{
                cont = [Select Id, FirstName, LastName, Phone, Email From Contact Where AccountId =: accId Order By CreatedDate DESC Limit 1];
            }catch(Exception e){
                cont = null;
            }
                        
        }else{
            acc = [Select Id, InvoiceAccount__c, PartyType__c, OrganizationName__c, NameAlias__c, DataAreaId__c, CustomerAccount__c, Financial_Dimensions__c,
                           FirstName, LastName, PersonEmail, Phone, DeliveryAddressDescription__c, ShippingCity, BillingStreet, FAC_Account__c, CurrencyIsoCode, FAC_Account__r.DataAreaId__c, ShippingStreet,
                           FAC_Account__r.CurrencyIsoCode, SalesSegmentId__c, PaymentMethod__c, SalesCurrencyCode__c, LanguageId__c, DefaultDimensionDisplayValue__c, ItemCustomerGroupId__c,
                           FAC_Account__r.Country_Code__c, D365Id__c, ANSA_DataLoader__c, ANSA_IsExport__c, RecordtypeId
                           From Account 
                           Where Id =: accId
                           Limit 1];
        }
    }
    
    public void execute(QueueableContext context) {
        String externalId = '';
        Id RTIDpAcc = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        if(RTID == RTIDpAcc)
        	externalId = WS_D365Parser.updateCustomerParser(WS_D365Callout.updateCustomers(acc));
        else{
            if(cont == null)
                return;
        	externalId = WS_D365Parser.updateCustomerParser(WS_D365Callout.updateCustomers(acc, cont));
        }
        if(externalId != ''){
            acc.D365Id__c = externalId;
            acc.InvoiceAccount__c = externalId;
            update acc;
        }             
    }
}