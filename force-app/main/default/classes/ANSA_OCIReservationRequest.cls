public class ANSA_OCIReservationRequest {
    
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
            reservationObject rObj = new reservationObject();
            rObj.actionRequestId = actionRequestUuid;
            List<CreateRecords> createRecordsList = new List<CreateRecords>();
            for(OrderItem orderItem : orderItems){
                CreateRecords createRecords = new CreateRecords();
                createRecords.locationIdentifier = orderItem.ANSA_Warehouse__c;
                createRecords.quantity = orderItem.Quantity;
                createRecords.stockKeepingUnit = orderItem.SKU__c;
                
                createRecordsList.add(createRecords);
            }
            rObj.createRecords = createRecordsList;
            system.debug(rObj);
    
            String jsonBody = JSON.serialize(rObj);
            system.debug(jsonBody);
            httpRequest httpRequest = new httpRequest();
            Http httpObject = new Http();
            HttpResponse httpResponse;
            httpRequest.setHeader('Content-type', 'application/json;charset=UTF-8');
            httpRequest.setHeader('Authorization', 'Bearer'+ ' ' + accesToken+'');
            httpRequest.setEndpoint(''+baseInstanceUrl+'/services/data/v51.0/commerce/oci/reservation/actions/reservations');
            httpRequest.setMethod('POST');
            httpRequest.setTimeout(120000);
            httpRequest.setBody(jsonBody);
            if(!system.test.isRunningTest()) {
                httpResponse = httpObject.send(httpRequest);
            }else{
                httpResponse = new HttpResponse();
                httpResponse.setHeader('Content-type', 'application/json;charset=UTF-8');
                httpResponse.setBody('Test response');
                httpResponse.setStatusCode(200);
            }
                try{
                    
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
    
	// Wrapper class to create Request Body Object.    
    public class reservationObject {
        public String actionRequestId;
        public List<CreateRecords> createRecords;
    }
    
    public class CreateRecords {
        public String locationIdentifier;
        public Double quantity;
        public String stockKeepingUnit;
    }

}