public class ANSA_OCIReservationCancellationRequest {
    
    @InvocableMethod(label='Reservations Cancellation' description='Processes Order Items to cancel reservations')
    public static void compareQuantities(List<InputVariables> inputVariables) {
        system.debug(inputVariables);
        
        String orderId = inputvariables.get(0).orderId;
        
        ANSA_OCIReservationCancellationRequest.sendRequest(orderId);
        
    }
    
    @future(callout=true)
    public static void sendRequest(String orderId){
        
        String baseInstanceUrl = URL.getSalesforceBaseUrl().toExternalForm();
        system.debug(baseInstanceUrl);
        String actionRequestUuid = new Uuid().getValue();
        
        String accesToken = ANSA_OauthTokenRequest.sendRequest().access_token;
        system.debug('Token de acceso es:' + accesToken);
        
        // Query OrderItem to find all items with the field "ANSA_Warehouse__c" populated.
        List<OrderItem> orderItems = [SELECT SKU__c, Quantity, ANSA_Warehouse__c, Product2.Family FROM OrderItem WHERE OrderId =: orderId AND ANSA_Warehouse__c != null];
        
        // Instantiate Object to be serialized into Json.
        if(!orderItems.isEmpty()){
            reservationCancellationObject rObj = new reservationCancellationObject();
            List<ReleaseRecords> releaseRecordsList = new List<ReleaseRecords>();
            for(OrderItem orderItem : orderItems){
                ReleaseRecords releaseRecords = new ReleaseRecords();
                releaseRecords.actionRequestId = actionRequestUuid;
                releaseRecords.locationIdentifier = orderItem.ANSA_Warehouse__c;
                releaseRecords.quantity = orderItem.Quantity;
                releaseRecords.stockKeepingUnit = orderItem.SKU__c;
                
                releaseRecordsList.add(releaseRecords);
            }
            rObj.releaseRecords = releaseRecordsList;
            system.debug(rObj);
    
            String jsonBody = JSON.serialize(rObj);
            system.debug(jsonBody);
            httpRequest httpRequest = new httpRequest();
            Http httpObject = new Http();
            HttpResponse httpResponse;
            httpRequest.setHeader('Content-type', 'application/json;charset=UTF-8');
            httpRequest.setHeader('Authorization', 'Bearer'+ ' ' + accesToken+'');
            httpRequest.setEndpoint(''+baseInstanceUrl+'/services/data/v51.0/commerce/oci/reservation/actions/releases');
            httpRequest.setMethod('POST');
            httpRequest.setTimeout(120000);
            httpRequest.setBody(jsonBody);
            if(!system.test.isRunningTest()) {
                try{
                    httpResponse = httpObject.send(httpRequest);
                    if(httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 201) {
                        String responseString = String.valueOf(httpResponse.getBody());
                        system.debug(responseString);
                        
                    }else{
                        String responseString = String.valueOf(httpResponse.getBody());
                        system.debug(responseString);
                    }
                }catch(exception e){
                    
                }
            }
            
        }
        
    }
    
    // Input Variables
    public class InputVariables{
        @InvocableVariable
        public String orderId;
    }
    
    // Wrapper class to create Request Body Object.    
    public class reservationCancellationObject {
        public List<ReleaseRecords> releaseRecords;
    }
    
    public class ReleaseRecords {
        public String actionRequestId;
        public String locationIdentifier;
        public Double quantity;
        public String stockKeepingUnit;
    }

}