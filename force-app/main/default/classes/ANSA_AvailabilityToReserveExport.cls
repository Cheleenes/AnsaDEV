public class ANSA_AvailabilityToReserveExport {
    
    @InvocableMethod(label='Compare Quantities to Reserve Export' description='Compares quantities in order vs quantities from OCI')
	public static List<Results> compareQuantities(List<InputVariables> inputVariables) {
        system.debug(inputVariables);
        
        Double quantity;
        
        List<String> passedSKUs = inputVariables.get(0).SKUList;
        List<Double> passedQuantities = inputVariables.get(0).QuantiiesList;
        List<String> passedOciSKUs = inputVariables.get(0).OCISKUList;
        List<Double> passedOciQuantities = inputVariables.get(0).OCIQuantitiesList;
        List<String> passedOciSKUs2 = inputVariables.get(0).OCISKUList2;
        List<Double> passedOciQuantities2 = inputVariables.get(0).OCIQuantitiesList2;
        String passedOrderId = inputvariables.get(0).orderId;
        String passedPriorityWarehouse = inputvariables.get(0).priorityWarehouse;
        String passedPriorityWarehouse2 = inputvariables.get(0).priorityWarehouse2;
        // Map for ordered SKUs-Quantities
        Map<String, Double> purchaseSkuQty = new Map<String, Double>();
        for (Integer i = 0; i < passedSKUs.size(); i++) {
           purchaseSkuQty.put(passedSKUs[i], passedQuantities[i]);
        }
        system.debug(purchaseSkuQty);
        
        // Map for SKUs-Quantities availability at priorityLocation1
        Map<String, Double> OciSkuQty = new Map<String, Double>();
        for (Integer i = 0; i < passedOciSKUs.size(); i++) {
           OciSkuQty.put(passedOciSKUs[i], passedOciQuantities[i]);
        }
        system.debug(OciSkuQty);
        
        // Map for SKUs-Quantities availability at priorityLocation2
        Map<String, Double> OciSkuQty2 = new Map<String, Double>();
        for (Integer i = 0; i < passedOciSKUs2.size(); i++) {
           OciSkuQty2.put(passedOciSKUs2[i], passedOciQuantities2[i]);
        }
        system.debug(OciSkuQty2);
        
        //Loop throug PurchaseSkus and compare quantities with those of purchase.
        List<String> availableSKUs = new List<String>();
        List<String> availableSKUs2 = new List<String>();
        List<Double> availableQuantities = new List<Double>();
        List<Double> availableQuantities2 = new List<Double>();
        for (String skuu : purchaseSkuQty.keySet()) {
            Double quantityFromPurchase = purchaseSkuQty.get(skuu);
            Double quantityFromOCI = (Double)OciSkuQty.get(skuu);
            Double quantityFromOCI2 = (Double)OciSkuQty2.get(skuu);
            if (quantityFromOCI >= quantityFromPurchase){
                availableSKUs.add(skuu);
                availableQuantities.add(quantityFromPurchase);
                 
            }else if(quantityFromOCI2 >= quantityFromPurchase){
                availableSKUs2.add(skuu);
                availableQuantities2.add(quantityFromPurchase);
            }
            
        }
        
        system.debug(availableSKUs);
        system.debug(availableQuantities);
        
        // Update Order Product records.
        List<OrderItem> orderItemsToUpdate = new List<OrderItem>();
        List<OrderItem> orderItems = [SELECT Id, ANSA_Warehouse__c FROM OrderItem WHERE OrderId =: passedOrderId AND SKU__c IN : availableSKUs];
        for(OrderItem orderItem : orderItems){
            orderItem.ANSA_Warehouse__c = passedPriorityWarehouse;
            orderItemsToUpdate.add(orderItem);
        }
        
        List<OrderItem> orderItems2 = [SELECT Id, ANSA_Warehouse__c FROM OrderItem WHERE OrderId =: passedOrderId AND SKU__c IN : availableSKUs2];
        for(OrderItem orderItem : orderItems2){
            orderItem.ANSA_Warehouse__c = passedPriorityWarehouse2;
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
        response.availableQties2 = availableQuantities2;
        response.availableSKUs2 = availableSKUs2;
    
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
        public List<String> OCISKUList2;
        
        @InvocableVariable
        public List<Double> OCIQuantitiesList2;
        
        @InvocableVariable
        public String orderId;
        
        @InvocableVariable
        public String priorityWarehouse;
        
        @InvocableVariable
        public String priorityWarehouse2;
    }
    
    public class Results{
        @InvocableVariable
        public List<Double> availableQties;
        
        @InvocableVariable
        public List<String> availableSKUs;
        
        @InvocableVariable
        public List<Double> availableQties2;
        
        @InvocableVariable
        public List<String> availableSKUs2;
    }

}