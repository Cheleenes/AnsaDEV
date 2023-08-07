// This must implement the sfdc_checkout.CartInventoryValidation interface
// in order to be processed by the checkout flow and used for your Check Inventory integration.

global without sharing class B2BCheckInventorySample implements sfdc_checkout.CartInventoryValidation {
    
    global sfdc_checkout.IntegrationStatus startCartProcessAsync(sfdc_checkout.IntegrationInfo jobInfo, ID cartId) {
        sfdc_checkout.IntegrationStatus integStatus = new sfdc_checkout.IntegrationStatus();
        try {
            // Get all SKUs and their quantities from cart items.
            Map<String, Decimal> quantitiesFromSalesforce = new Map<String, Decimal>();
            for (CartItem cartItem : [SELECT Sku, Quantity FROM CartItem WHERE CartId = :cartId AND Type = 'Product' WITH SECURITY_ENFORCED]) {
                // Pending: filter out pallets, shipping costs, and all items that are not products.
                quantitiesFromSalesforce.put(cartItem.Sku, cartItem.Quantity);
            }

            // Stop checkout if there are no items in the cart
            if (quantitiesFromSalesforce.isEmpty()) {
                String errorMessage = 'Looks like your cart is empty.';
                return integrationStatusFailedWithCartValidationOutputError(
                    integStatus,
                    errorMessage,
                    jobInfo,
                    cartId
                );
            }
            
            // Build list of locationGroupIdentifiers
            List<WebCart> cart = [SELECT AccountId FROM WebCart WHERE Id =: cartId];
            String accId = cart[0].AccountId;
            Account acc = [SELECT AMC_Assigned_Location_Group__c FROM Account WHERE Id =: accId LIMIT 1];
            List<String> locationGroups = new List<String>();
        	locationGroups.add(acc.AMC_Assigned_Location_Group__c);
            
            // Get all available quantities for products in the cart (cart items) from an external service.
            List<String> cartItemsSkus = new List<String>(quantitiesFromSalesforce.keySet());
            system.debug(cartItemsSkus);
			List<Product2> cartProducts = [SELECT StockKeepingUnit FROM Product2 WHERE StockKeepingUnit IN : cartItemsSkus AND ANC_Show_Store__c = true];
            system.debug(cartProducts);
            List<String> cartProductsSkus = new List<String>();
            for(Product2 cartProduct : cartProducts){
                cartProductsSkus.add(cartProduct.StockKeepingUnit);
            }
            system.debug(cartProductsSkus);
            
            String availabilityResponse = getQuantitiesFromExternalService(locationGroups, cartProductsSkus);  
            
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
                String errorMessageFinal = 'Insufficient quantity for the products with the following skus ';
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
                        // If the product exists and the available quantity is enough, set status as SUCCESS
                        integStatus.status = sfdc_checkout.IntegrationStatus.Status.SUCCESS;
                    }
                }
                if(errorMessage != ''){
                    errorMessageFinal = errorMessageFinal + '<br/>' + errorMessage;
                    return integrationStatusFailedWithCartValidationOutputError(
                               integStatus,
                               errorMessageFinal,
                               jobInfo,
                               cartId
                           );
                }
                
            }
            
/*
            // For each cart item SKU, check that the quantity from the external service
            // is greater or equal to the quantity in the cart.
            // If that is not true, set the integration status to "Failed".
            for (String sku : quantitiesFromSalesforce.keySet()) {
                Decimal quantityFromSalesforce = quantitiesFromSalesforce.get(sku);
                Decimal quantityFromExternalService = (Decimal)quantitiesFromExternalService.get(sku);
                if (quantityFromExternalService == null){
                    String errorMessage = 'The product with sku ' + sku + ' could not be found in the external system';
                    return integrationStatusFailedWithCartValidationOutputError(
                       integStatus,
                       errorMessage,
                       jobInfo,
                       cartId
                   );
                } 
                else if (quantityFromExternalService < quantityFromSalesforce){
                   String errorMessage = 'Insufficient quantity for the product with sku ' + sku + ': ' 
                               + quantityFromSalesforce + ' needed, but only '
                               + quantityFromExternalService + ' available.';
                   return integrationStatusFailedWithCartValidationOutputError(
                       integStatus,
                       errorMessage,
                       jobInfo,
                       cartId
                   );
                }
                else {
                    // If the product exists and the available quantity is enough, set status as SUCCESS
                    integStatus.status = sfdc_checkout.IntegrationStatus.Status.SUCCESS;
                }
            }
*/
            
        } catch(Exception e) {
            // For testing purposes, this example treats exceptions as user errors, which means they are displayed to the buyer user.
            // In production you probably want this to be an admin-type error. In that case, throw the exception here
            // and make sure that a notification system is in place to let the admin know that the error occurred.
            // See the readme section about error handling for details about how to create that notification.
            return integrationStatusFailedWithCartValidationOutputError(
                integStatus,
                'An exception of type ' + e.getTypeName() + ' has occurred: ' + e.getMessage(),
                jobInfo,
                cartId
            );
        }
        return integStatus;
    }

/*    
    private Map<String, Object> getQuantitiesFromExternalService (Set<String> skus) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        Integer SuccessfulHttpRequest = 200;

        // Encode the product SKUs to avoid any invalid characters in the request URL.
        Set<String> encodedSkus = new Set<String>();
        for (String sku : skus) {
            encodedSkus.add(EncodingUtil.urlEncode(sku, 'UTF-8'));
        }

        // To access the service below, add endpoint = https://b2b-commerce-test.herokuapp.com in Setup | Security | Remote site settings.
        request.setEndpoint('https://b2b-commerce-test.herokuapp.com/get-inventory?skus=' + JSON.serialize(encodedSkus));
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        // The response includes the available quantity for each SKU and uses the following format:
        // {"SKU-25-10028":9999.00, "SKU-25-10030":9999.00}
        // Because this is a sample, and we want this integration to return success.
        // The external service returns the exact list of SKUs it receives
        // and an available quantity of 9999 for each SKU.
        // If the cart has an item with a quantity higher than 9999, the integration returns an error.
        if (response.getStatusCode() == SuccessfulHttpRequest) {
            Map<String, Object> quantitiesFromExternalService = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            return quantitiesFromExternalService;
        }
        else {
            throw new CalloutException ('There was a problem with the request. Error: ' + response.getStatusCode());
        }
    }  
*/
    
     public String getQuantitiesFromExternalService(List<String> locationGroupIdentifiers, List<String> skus){
        
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
            try{
                httpResponse = httpObject.send(httpRequest);
                if(httpResponse.getStatusCode() == 200 || httpResponse.getStatusCode() == 201) {
                    responseString = String.valueOf(httpResponse.getBody());
                    system.debug(responseString);
                    
                    
                }else{
                    responseString = String.valueOf(httpResponse.getBody());
                    system.debug(responseString);
                }
            }catch(exception e){
                
            }
        }
        return responseString;

    }
    
    private sfdc_checkout.IntegrationStatus integrationStatusFailedWithCartValidationOutputError(
        sfdc_checkout.IntegrationStatus integrationStatus, String errorMessage, sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
            integrationStatus.status = sfdc_checkout.IntegrationStatus.Status.FAILED;
            // To propagate the error to the user, we need to add a new CartValidationOutput record.
            // The following fields must be populated:
            // BackgroundOperationId: Foreign Key to the BackgroundOperation
            // CartId: Foreign key to the WebCart that this validation line is for
            // Level (required): One of the following - Info, Error, or Warning
            // Message (optional): Message displyed to the user
            // Name (required): The name of this CartValidationOutput record. For example CartId:BackgroundOperationId
            // RelatedEntityId (required): Foreign key to WebCart, CartItem, CartDeliveryGroup
            // Type (required): One of the following - SystemError, Inventory, Taxes, Pricing, Shipping, Entitlement, Other
            CartValidationOutput cartValidationError = new CartValidationOutput(
                BackgroundOperationId = jobInfo.jobId,
                CartId = cartId,
                Level = 'Error',
                Message = errorMessage.left(255),
                Name = (String)cartId + ':' + jobInfo.jobId,
                RelatedEntityId = cartId,
                Type = 'Inventory'
            );
            insert(cartValidationError);
            return integrationStatus;
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