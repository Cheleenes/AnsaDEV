public class ANSA_GetAvailabilityResponseJsonParser {
    
    public class Errors {
	}

	public List<Errors> errors;
	public List<LocationGroups> locationGroups;
	public List<Errors> locations;
	public Boolean success;

	public class LocationGroups {
		public List<InventoryRecords> inventoryRecords;
		public String locationGroupIdentifier;
	}

	public class InventoryRecords {
		public Double availableToFulfill;
		public Double availableToOrder;
		public String effectiveDate;
		public List<Errors> futures;
		public Double onHand;
		public Double reserved;
		public Double safetyStockCount;
		public String stockKeepingUnit;
	}

//	@InvocableMethod(label='Json parser' description='Parses the response given by Get Availability Flow Action')
	public static void parse(List<String> purchaseSkus, List<Double> purchaseQuantities, String jsonString) {
         
        String sku;
        Double quantity;
        List<String> statusList = new List<String>();
        String status;

        Object inventoryResponse = JSON.deserializeUntyped(jsonString);
        
        Map<String, Object> obMap = (Map<String, Object>)inventoryResponse;
        system.debug(obMap);
        for (Object ob : (List<Object>)obMap.get('locationGroups')) {
            Map<String, Object> ob2Map = (Map<String, Object>)ob;
            system.debug(ob2Map);
            
            List<String> skuList = new List<String>();
            List<Double> quantityList = new List<Double>();
            for (Object ob2 : (List<Object>)ob2Map.get('inventoryRecords')) {
                Map<String, Object> ob3Map = (Map<String, Object>)ob2;
                system.debug(ob3Map);
                
                sku = string.valueOf(ob3Map.get('stockKeepingUnit'));
                skuList.add(sku);
                
                quantity = double.valueOf(ob3Map.get('availableToFulfill'));
                quantityList.add(quantity);

        	}
            system.debug(skuList);
            system.debug(quantityList);
            
            Map<String, Double> OCIskuQuantities = new Map<String, Double>();
            for (Integer i = 0; i < skuList.size(); i++) {
               OCIskuQuantities.put(skuList[i], quantityList[i]);
            }
            system.debug(OCIskuQuantities);
            
            Map<String, Double> PurchaseSkuQuantities = new Map<String, Double>();
            for (Integer i = 0; i < purchaseSkus.size(); i++) {
               PurchaseSkuQuantities.put(purchaseSkus[i], purchaseQuantities[i]);
            }
            system.debug(PurchaseSkuQuantities);
            
            //Loop throug PurchaseSkus and compare quantities with those of purchase.
            for (String skuu : PurchaseSkuQuantities.keySet()) {
                Double quantityFromPurchase = PurchaseSkuQuantities.get(sku);
                Double quantityFromOCI = (Double)OCIskuQuantities.get(sku);
                if (quantityFromOCI < quantityFromPurchase){
                   String errorMessage = 'Insufficient quantity for the product with sku ' + skuu + ': ' 
                               + quantityFromPurchase + ' needed, but only '
                               + quantityFromOCI + ' available.';
                    status = 'Failure';
                   
                }
                else {
                    // If the product exists and the available quantity is enough, set status as SUCCESS
                    status = 'Success';
                    statusList.add(status);
                    
                }
                system.debug(status);
            }

        }
        
	}
    
  	@InvocableMethod(label='Compare Quantities' description='Compares quantities in cart vs quantities from OCI')
	public static List<Results> compareQuantities(List<InputVariables> inputVariables) {
        system.debug(inputVariables);
        
        Double quantity;
        List<String> statusList = new List<String>();
        List<String> errorList = new List<String>();
        String status;
        
        List<String> passedSKUs = inputVariables.get(0).SKUList2;
        List<Double> passedQuantities = inputVariables.get(0).QuantiiesList;
        List<String> passedOciSKUs = inputVariables.get(0).OCISKUList;
        List<Double> passedOciQuantities = inputVariables.get(0).OCIQuantitiesList;
        
        Map<String, Double> purchaseSkuQty = new Map<String, Double>();
        for (Integer i = 0; i < passedSKUs.size(); i++) {
           purchaseSkuQty.put(passedSKUs[i], passedQuantities[i]);
        }
        system.debug(purchaseSkuQty);
        
        Map<String, Double> OciSkuQty = new Map<String, Double>();
        for (Integer i = 0; i < passedOciSKUs.size(); i++) {
           OciSkuQty.put(passedOciSKUs[i], passedOciQuantities[i]);
        }
        system.debug(OciSkuQty);
        
        //Loop throug PurchaseSkus and compare quantities with those of purchase.
        for (String skuu : purchaseSkuQty.keySet()) {
            Double quantityFromPurchase = purchaseSkuQty.get(skuu);
            Double quantityFromOCI = (Double)OciSkuQty.get(skuu);
            if (quantityFromOCI < quantityFromPurchase){
                String errorMessage = 'Insufficient quantity for the product with sku ' + skuu + ': ' 
                    + quantityFromPurchase + ' needed, but only '
                    + quantityFromOCI + ' available.';
                errorList.add(errorMessage);  
            }
            
            system.debug(status);
            system.debug(errorList);
            if(errorList.isEmpty()){
                status = 'Success';
            }else{
                status = 'Failure';
            }
            
        }
        
        //Create a Results object to hold the return values
        Results response = new Results();
    
        //Add the return values to the Results object
        response.status = status;
        response.errorMessages = errorList;
    
        //Wrap the Results object in a List container 
        //(an extra step added to allow this interface to also support bulkification)
        List<Results> responseWrapper= new List<Results>();
        responseWrapper.add(response);
        return responseWrapper;    
      }
    
    public class InputVariables{
        @InvocableVariable
        public List<String> SKUList2;
        
        @InvocableVariable
        public List<Double> QuantiiesList;
        
        @InvocableVariable
        public List<String> OCISKUList;
        
        @InvocableVariable
        public List<Double> OCIQuantitiesList;
    }
    
    public class Results{
        @InvocableVariable
        public String status;
        
        @InvocableVariable
        public List<String> errorMessages;
    }

}