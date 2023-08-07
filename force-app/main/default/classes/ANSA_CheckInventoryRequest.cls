public class ANSA_CheckInventoryRequest {
    
    public String sendRequest(List<String> locationIdentifiers, List<String> skus){
        
        String responseString;
        String baseInstanceUrl = URL.getSalesforceBaseUrl().toExternalForm();
        system.debug(baseInstanceUrl);
        
        String accesToken = ANSA_OauthTokenRequest.sendRequest().access_token;
        system.debug('Token de acceso es:' + accesToken);
        
        // Instantiate Object to be serialized into Json.
        reservationObject rObj = new reservationObject();
        rObj.locationIdentifiers = locationIdentifiers;
        rObj.stockKeepingUnits = skus;
        

        String jsonBody = JSON.serialize(rObj);
        system.debug(jsonBody);
        httpRequest httpRequest = new httpRequest();
        Http httpObject = new Http();
        HttpResponse httpResponse;
        httpRequest.setHeader('Content-type', 'application/json;charset=UTF-8');
        httpRequest.setHeader('Authorization', 'Bearer'+ ' ' + accesToken+'');
        httpRequest.setEndpoint(''+baseInstanceUrl+'/services/data/v51.0/commerce/oci/availability/availability-records/actions/get-availability');
        httpRequest.setMethod('POST');
        httpRequest.setTimeout(120000);
        httpRequest.setBody(jsonBody);
        if(!system.test.isRunningTest()) {
            httpResponse = httpObject.send(httpRequest);
        }else{
            httpResponse = new HttpResponse();
            httpResponse.setHeader('Content-type', 'application/json;charset=UTF-8');
            httpResponse.setBody('{'+
                                '"errors": [],'+
                                '"locationGroups": [],'+
                                '"locations": ['+
                                    '{'+
                                        '"inventoryRecords": ['+
                                            '{'+
                                                '"availableToFulfill": 10.0,'+
                                                '"availableToOrder": 0.0,'+
                                                '"futures": [],'+
                                                '"onHand": 0.0,'+
                                                '"reserved": 0.0,'+
                                                '"safetyStockCount": 0.0,'+
                                                '"stockKeepingUnit": "P567823412313"'+
                                            '}'+
                                        '],'+
                                        '"locationIdentifier": "YARDBC"'+
                                    '},'+
                                    '{'+
                                        '"inventoryRecords": ['+
                                            '{'+
                                                '"availableToFulfill": 10.0,'+
                                                '"availableToOrder": 0.0,'+
                                                '"futures": [],'+
                                                '"onHand": 0.0,'+
                                                '"reserved": 0.0,'+
                                                '"safetyStockCount": 0.0,'+
                                                '"stockKeepingUnit": "P567823412313"'+
                                            '}'+
                                        '],'+
                                        '"locationIdentifier": "COL16PLT"'+
                                    '},'+
                                    '{'+
                                        '"inventoryRecords": ['+
                                            '{'+
                                                '"availableToFulfill": 10.0,'+
                                                '"availableToOrder": 0.0,'+
                                                '"futures": [],'+
                                                '"onHand": 0.0,'+
                                                '"reserved": 0.0,'+
                                                '"safetyStockCount": 0.0,'+
                                                '"stockKeepingUnit": "P567823412313"'+
                                            '}'+
                                        '],'+
                                        '"locationIdentifier": "YARDC"'+
                                    '},'+
                                    '{'+
                                        '"inventoryRecords": ['+
                                            '{'+
                                                '"availableToFulfill": 10.0,'+
                                                '"availableToOrder": 0.0,'+
                                                '"futures": [],'+
                                                '"onHand": 0.0,'+
                                                '"reserved": 0.0,'+
                                                '"safetyStockCount": 0.0,'+
                                                '"stockKeepingUnit": "P567823412313"'+
                                            '}'+
                                        '],'+
                                        '"locationIdentifier": "COL1600PLT"'+
                                    '},'+
                                    '{'+
                                        '"inventoryRecords": ['+
                                            '{'+
                                                '"availableToFulfill": 10.0,'+
                                                '"availableToOrder": 0.0,'+
                                                '"futures": [],'+
                                                '"onHand": 0.0,'+
                                                '"reserved": 0.0,'+
                                                '"safetyStockCount": 0.0,'+
                                                '"stockKeepingUnit": "P567823412313"'+
                                            '}'+
                                        '],'+
                                        '"locationIdentifier": "SPSTR"'+
                                    '},'+
                                    '{'+
                                        '"inventoryRecords": ['+
                                            '{'+
                                                '"availableToFulfill": 10.0,'+
                                                '"availableToOrder": 0.0,'+
                                                '"futures": [],'+
                                                '"onHand": 0.0,'+
                                                '"reserved": 0.0,'+
                                                '"safetyStockCount": 0.0,'+
                                                '"stockKeepingUnit": "P567823412313"'+
                                            '}'+
                                        '],'+
                                        '"locationIdentifier": "AFGS"'+
                                    '},'+
                                    '{'+
                                        '"inventoryRecords": ['+
                                            '{'+
                                                '"availableToFulfill": 10.0,'+
                                                '"availableToOrder": 0.0,'+
                                                '"futures": [],'+
                                                '"onHand": 0.0,'+
                                                '"reserved": 0.0,'+
                                                '"safetyStockCount": 0.0,'+
                                                '"stockKeepingUnit": "P567823412313"'+
                                            '}'+
                                        '],'+
                                        '"locationIdentifier": "MAINAC"'+
                                    '},'+
                                    '{'+
                                        '"inventoryRecords": ['+
                                            '{'+
                                                '"availableToFulfill": 10.0,'+
                                                '"availableToOrder": 0.0,'+
                                                '"futures": [],'+
                                                '"onHand": 0.0,'+
                                                '"reserved": 0.0,'+
                                                '"safetyStockCount": 0.0,'+
                                                '"stockKeepingUnit": "P567823412313"'+
                                            '}'+
                                        '],'+
                                        '"locationIdentifier": "VFGS"'+
                                    '},'+
                                    '{'+
                                        '"inventoryRecords": ['+
                                            '{'+
                                                '"availableToFulfill": 10.0,'+
                                                '"availableToOrder": 0.0,'+
                                                '"futures": [],'+
                                                '"onHand": 0.0,'+
                                                '"reserved": 0.0,'+
                                                '"safetyStockCount": 0.0,'+
                                                '"stockKeepingUnit": "P567823412313"'+
                                            '}'+
                                        '],'+
                                        '"locationIdentifier": "SFGS"'+
                                    '}'+
                                '],'+
                                '"success": true'+
                            '}');
            httpResponse.setStatusCode(200);
        }
            try{
                
                if(httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 201) {
                    responseString = String.valueOf(httpResponse.getBody());
                    system.debug(responseString);
                    
                    
                }else{
                    responseString = String.valueOf(httpResponse.getBody());
                    system.debug(responseString);
                }
            }catch(exception e){
                
            }
        return responseString;
    }
    
    // Wrapper class to create Request Body Object.    
    public class reservationObject {
        public List<String> locationIdentifiers;
        public List<String> stockKeepingUnits;
    }

}