public class ANSA_AvailabilityToReserve {
    
    @InvocableMethod(label='Compare Quantities to Reserve' description='Compares quantities in order vs quantities from OCI')
	public static List<Results> compareQuantities(List<InputVariables> inputVariables) {
        system.debug(inputVariables);
        
        Double quantity;
        List<String> unavailableSKUs = new List<String>();
        
        List<String> passedSKUs = inputVariables.get(0).SKUList;
        List<Double> passedQuantities = inputVariables.get(0).QuantiiesList;
        List<String> passedOciSKUs = inputVariables.get(0).OCISKUList;
        List<Double> passedOciQuantities = inputVariables.get(0).OCIQuantitiesList;
        String passedOrderId = inputvariables.get(0).orderId;
        String passedPriorityWarehouse = inputvariables.get(0).priorityWarehouse;
        
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
                String unavailableSKU = skuu;
                unavailableSKUs.add(unavailableSKU);  
            }
            system.debug(unavailableSKUs);
        }
        for (String outOfStockSKU : unavailableSKUs){
            purchaseSkuQty.remove(outOfStockSKU);
        }
        system.debug(purchaseSkuQty);
        
        List<String> availableSKUs = new List<String>(purchaseSkuQty.keySet());
        system.debug(availableSKUs);
        List<Double> availableQuantities = new List<Double>();
        for(String inStockSKUs : availableSKUs){
            availableQuantities.add(purchaseSkuQty.get(inStockSKUs));
        }
        system.debug(availableQuantities);
        
        // Update Order Product records.
        List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
        List<OrderItem> orderItems = [SELECT Id, ANSA_Warehouse__c FROM OrderItem WHERE OrderId =: passedOrderId AND SKU__c IN : availableSKUs];
        for(OrderItem orderItem : orderItems){
            orderItem.ANSA_Warehouse__c = passedPriorityWarehouse;
            orderItemsToUpdate.add(orderItem);
        }
        system.debug(orderItemsToUpdate);
        if(!orderItemsToUpdate.isEmpty()){
            try{
                update orderItemsToUpdate;
            }catch(exception e){
                system.debug('***Error when updating order items:' + e);
            }
        }
        
        
        
        //Create a Results object to hold the return values
        Results response = new Results();
    
        //Add the return values to the Results object
        response.availableQties = availableQuantities;
        response.availableSKUs = availableSKUs;
    
        //Wrap the Results object in a List container 
        //(an extra step added to allow this interface to also support bulkification)
        List<Results> responseWrapper= new List<Results>();
        responseWrapper.add(response);
        return responseWrapper;    
      }
    
    public class InputVariables{
        @InvocableVariable
        public List<String> SKUList;
        
        @InvocableVariable
        public List<Double> QuantiiesList;
        
        @InvocableVariable
        public List<String> OCISKUList;
        
        @InvocableVariable
        public List<Double> OCIQuantitiesList;
        
        @InvocableVariable
        public String orderId;
        
        @InvocableVariable
        public String priorityWarehouse;
    }
    
    public class Results{
        @InvocableVariable
        public List<Double> availableQties;
        
        @InvocableVariable
        public List<String> availableSKUs;
    }

}