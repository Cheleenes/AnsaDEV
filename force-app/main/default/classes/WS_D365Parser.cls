public class WS_D365Parser {
    public static String tokenParser(String sResponse) {
        Map<String, Object> mapParams = (Map<String, Object>)JSON.deserializeUntyped(sResponse);
        return (String)mapParams.get('access_token');
    }
    
	public static String updateCustomerParser(String sResponse) {
        String externalId = '';
        Map<String, Object> mapParams = (Map<String, Object>)JSON.deserializeUntyped(sResponse);
        externalId = (String)mapParams.get('dmrCustomerAccount');
        Boolean isSuccess = (Boolean)mapParams.get('dmrSuccess');
        if(isSuccess)
            return externalId;
        return '';
    }
    
    public static List<String> updateSalesOrderParser(String sResponse) {
        System.debug(sResponse);
        String externalId = '';
        String pickingListId = '';
        List<String> returnList = new List<String>();
        Map<String, Object> mapParams = (Map<String, Object>)JSON.deserializeUntyped(sResponse);
        externalId = (String)mapParams.get('dmrSalesOrderNumber');
        pickingListId = (String)mapParams.get('dmrAutoGeneratedPickingListNumber');
        Boolean isSuccess = (Boolean)mapParams.get('dmrSuccess');
        returnList.add(externalId);
        returnList.add(pickingListId);
        if(isSuccess)
            return returnList;
        return null;
    }
    
    public static cutomerGetResponse customerGetParser(String sResponse){
        system.debug(sResponse);
        cutomerGetResponse response = (cutomerGetResponse)JSON.deserialize(sResponse, cutomerGetResponse.class);
        return response;
    }
    
    public class cutomerGetResponse{
        public String dmDataAreaID;
        public String dmrRecId;
        public String dmCustomerAccount;
        public String dmInvoiceAccount;
        public String dmPartyType;
        public String dmOrganizationName;
        public String dmNameAlias;
        public String dmPersonFirstName;
        public String dmPersonLastName;
        public String dmPrimaryContactEmail;
        public String dmPrimaryContactPhone;
        public String dmDeliveryAddressDescription;
        public String dmDeliveryAddressCity;
        public String dmInvoiceAddressStreet;
        public String dmCustomerGroupId;
        public String dmSalesSegmentId;
        public String dmPaymentMethod;
        public String dmSalesCurrencyCode;
        public String dmLanguageId;
        public String dmDefaultDimensionDisplayValue;
        public Boolean dmrSuccess;
        public String dmrActionResultText;
        public String dmrMessageText;
        public Double dmrCreditBalanceMST;
        public Double dmrCreditBalanceCur;
        public Double dmrCreditLimitMST;
        public Double dmrCreditLimitCur;
        public Boolean dmrIsMandatoryCreditLimit;
        public String dmrTermsOfPayment;
        public String dmrCRM_SalesforceId;
        public Boolean dmrIsWithInCreditTerms;
        public String dmrOldestPendingInvoiceDate;
        public Double dmrAvailableCreditBalanceMST;
        public Double dmrOpenSalesOrdersAmountMST;
    }
}