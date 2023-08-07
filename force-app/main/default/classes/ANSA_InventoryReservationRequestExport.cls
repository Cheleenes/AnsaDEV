public class ANSA_InventoryReservationRequestExport {
    
    @future(callout=true)
    public static void sendRequest(String locationIdentifier, String locationIdentifier2, List<Double> quantities, List<String> skuList, List<Double> quantities2, List<String> skuList2){
        
        String baseInstanceUrl = URL.getSalesforceBaseUrl().toExternalForm();
        system.debug(baseInstanceUrl);
        String actionRequestUuid = new Uuid().getValue();
        
        String accesToken = ANSA_OauthTokenRequest.sendRequest().access_token;
        system.debug('Token de acceso es:' + accesToken);
        
        Map<String, Double> availableSkuQty = new Map<String, Double>();
        for (Integer i = 0; i < skuList.size(); i++) {
           availableSkuQty.put(skuList[i], quantities[i]);
        }
        system.debug(availableSkuQty);
        
        Map<String, Double> availableSkuQty2 = new Map<String, Double>();
        for (Integer i = 0; i < skuList2.size(); i++) {
           availableSkuQty2.put(skuList2[i], quantities2[i]);
        }
        system.debug(availableSkuQty2);
        
        // Instantiate Object to be serialized into Json.
        reservationObject rObj = new reservationObject();
        rObj.actionRequestId = actionRequestUuid;
        List<CreateRecords> createRecordsList = new List<CreateRecords>();
        for(String skuu : availableSkuQty.keySet()){
            Double SKUquantity = availableSkuQty.get(skuu);
            CreateRecords createRecords = new CreateRecords();
            createRecords.locationIdentifier = locationIdentifier;
            createRecords.quantity = SKUquantity;
            createRecords.stockKeepingUnit = skuu;
            
            createRecordsList.add(createRecords);
        }
        
        for(String skuu : availableSkuQty2.keySet()){
            Double SKUquantity2 = availableSkuQty2.get(skuu);
            CreateRecords createRecords = new CreateRecords();
            createRecords.locationIdentifier = locationIdentifier2;
            createRecords.quantity = SKUquantity2;
            createRecords.stockKeepingUnit = skuu;
            
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