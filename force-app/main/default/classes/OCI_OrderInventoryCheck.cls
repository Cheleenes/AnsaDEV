public class OCI_OrderInventoryCheck {
    public static String inventoryCheck(Order ord) {
        String errorMessageFinal = 'Inventory Check failed. Some of the products in this order are no longer available to fulfill';
        try {
            // Get all SKUs and their quantities from cart items.
            Map<String, Decimal> quantitiesFromSalesforce = new Map<String, Decimal>();
            for (OrderItem orderItem : [SELECT SKU__c, Quantity FROM OrderItem WHERE OrderId = :ord.Id AND Product2.ANC_Show_Store__c = true]) {
                quantitiesFromSalesforce.put(orderItem.SKU__c, orderItem.Quantity);
            }

            
            // Build list of locationGroupIdentifiers
            List<Order> order = [SELECT AccountId FROM Order WHERE Id =: ord.Id];
            String accId = order[0].AccountId;
            Account acc = [SELECT AMC_Assigned_Location_Group__c FROM Account WHERE Id =: accId LIMIT 1];
            List<String> locationGroups = new List<String>();
        	locationGroups.add(acc.AMC_Assigned_Location_Group__c);
            
            // Get all available quantities for products in the order (order items) from an external service.
            List<String> orderItemsSkus = new List<String>(quantitiesFromSalesforce.keySet());
            system.debug(orderItemsSkus);
			List<Product2> orderProducts = [SELECT StockKeepingUnit FROM Product2 WHERE StockKeepingUnit IN : orderItemsSkus AND ANC_Show_Store__c = true];
            system.debug(orderProducts);
            List<String> orderProductsSkus = new List<String>();
            for(Product2 cartProduct : orderProducts){
                orderProductsSkus.add(cartProduct.StockKeepingUnit);
            }
            system.debug(orderProductsSkus);
            
            String availabilityResponse = getQuantitiesFromExternalService(locationGroups, orderProductsSkus);  
            
            //Parse "Get Availability" response Json.
        	availabilityObject availabilityResponseObject = (availabilityObject)JSON.deserialize(availabilityResponse, availabilityObject.class);
            
            //Process "Get Availability" response Object.
            
        	if(availabilityResponseObject.success == true){
                
                Map<String, Double> availableSkuQtyMap = new Map<String, Double>();
                for(LocationGroups locationGroup : availabilityResponseObject.locationGroups){
                    for(InventoryRecords inventoryRecord : locationGroup.inventoryRecords){
                        availableSkuQtyMap.put(inventoryRecord.stockKeepingUnit, inventoryRecord.availableToFulfill);
                        system.debug(inventoryRecord.stockKeepingUnit);
                        system.debug(inventoryRecord.availableToFulfill);
                        
                    }
                }
                
                String errorMessage = '';
                for(String availableSku : availableSkuQtyMap.keySet()){
                    Decimal quantityFromSalesforce = quantitiesFromSalesforce.get(availableSku);
                    system.debug(quantityFromSalesforce);
                	Decimal quantityFromExternalService = availableSkuQtyMap.get(availableSku);
                    system.debug(quantityFromExternalService);
                    if (quantityFromExternalService < quantityFromSalesforce){
                       errorMessage = errorMessage + '<br/>'
									+ availableSku + ': ' 
									+ quantityFromSalesforce + ' needed, but only '
									+ quantityFromExternalService + ' available.';
                       
                    }
                    else {
                        // If the product exists and the available quantity is enough, errorMessageFinal as SUCCESS
                        errorMessageFinal = 'SUCCESS';
                    }
                }
                if(errorMessage != ''){
                    errorMessageFinal = errorMessageFinal + '<br/>' + errorMessage;
                    
                }
                
            }
        	    
        } catch(Exception e) {
            // For testing purposes, this example treats exceptions as user errors, which means they are displayed to the buyer user.
            // In production you probably want this to be an admin-type error. In that case, throw the exception here
            // and make sure that a notification system is in place to let the admin know that the error occurred.
            // See the readme section about error handling for details about how to create that notification.
        }
        system.debug(errorMessageFinal);
        return errorMessageFinal;
    }

    
     public static String getQuantitiesFromExternalService(List<String> locationGroupIdentifiers, List<String> skus){
        
        String responseString;
        String baseInstanceUrl = URL.getSalesforceBaseUrl().toExternalForm();
        system.debug(baseInstanceUrl);
        
        String accesToken = ANSA_OauthTokenRequest.sendRequest().access_token;
        system.debug('Token de acceso es:' + accesToken);
        
        // Instantiate Object to be serialized into Json.
        reservationObject rObj = new reservationObject();
        rObj.locationGroupIdentifiers = locationGroupIdentifiers;
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
                                '"locations": [],'+
                                '"locationGroups": ['+
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
    
    // Object to deserialize Json.
	public class availabilityObject {
	public List<Errors> errors;
	public List<LocationGroups> locationGroups;
	public List<Errors> locations;
	public Boolean success;
    }
    
    public class Errors {
	}

	public class InventoryRecords {
		public Double availableToFulfill;
		public Double availableToOrder;
		public List<Errors> futures;
		public Double onHand;
		public Double reserved;
		public Double safetyStockCount;
		public String stockKeepingUnit;
	}

	public class LocationGroups {
		public List<InventoryRecords> inventoryRecords;
		public String locationGroupIdentifier;
	}
    
    // Wrapper class to create Request Body Object.    
    public class reservationObject {
        public List<String> locationGroupIdentifiers;
        public List<String> stockKeepingUnits;
    }  


}