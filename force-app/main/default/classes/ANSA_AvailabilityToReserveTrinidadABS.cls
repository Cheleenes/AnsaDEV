public class ANSA_AvailabilityToReserveTrinidadABS {
    
    
    
    @InvocableMethod(label='Compare Quantities to Reserve Trinidad ABS' description='Compares quantities in order vs quantities from OCI')
    public static void compareQuantities(List<InputVariables> inputVariables) {
        system.debug(inputVariables);
        
        String passedOrderId = inputvariables.get(0).orderId;
        
        List<String> locationIdentifiers = new List<String>{'YARDC', 'YARDBC', 'AFGS', 'SPSTR', 'COL1600PLT', 'COL16PLT', 'VFGS', 'SFGS', 'MAINAC'};
        List<String> skus= new List<String>();
        
        List<OrderItem> orderItems = [SELECT SKU__c, Quantity, ANSA_Warehouse__c,Product2.Id, Product2.Family, Product2.Name FROM OrderItem WHERE OrderId =: passedOrderId];
        List<String> orderProductsIds = new List<String>();
        
        for(OrderItem orderItem : orderItems){
            system.debug(orderItem.Product2.Id);
            system.debug(orderItem.Product2.Family);
            system.debug(orderItem.Product2.Name);
            if(orderItem.SKU__c != null){
                skus.add(orderItem.SKU__c);
            	orderProductsIds.add(orderItem.Product2.Id);
            }
        }
        system.debug(orderProductsIds);
        
        // Call OCI's "Get Availability" endpoint.
        ANSA_CheckInventoryRequest getAvailability = new ANSA_CheckInventoryRequest();
        String availabilityResponse = getAvailability.sendRequest(locationIdentifiers, skus);
        
        //Parse "Get Availability" response Json.
        availabilityObject availabilityResponseObject = (availabilityObject)JSON.deserialize(availabilityResponse, availabilityObject.class);
        
        //Process "Get Availability" response Object.
        if(availabilityResponseObject.success == true){
            
            Map<String, Double> YARDCmap = new Map<String, Double>();
            Map<String, Double> YARDBCmap = new Map<String, Double>();
            Map<String, Double> AFGSmap = new Map<String, Double>();
            Map<String, Double> SPSTRmap = new Map<String, Double>();
            Map<String, Double> COL1600PLTmap = new Map<String, Double>();
            Map<String, Double> COL16PLTmap = new Map<String, Double>();
            Map<String, Double> VFGSmap = new Map<String, Double>();
            Map<String, Double> SFGSmap = new Map<String, Double>();
            Map<String, Double> MAINACmap = new Map<String, Double>();
            
            for(Locations location : availabilityResponseObject.locations){
                if(location.locationIdentifier == 'YARDC'){
                    for(InventoryRecords inventoryRecord : location.inventoryRecords){
                        YARDCmap.put(inventoryRecord.stockKeepingUnit, inventoryRecord.availableToFulfill);
                        system.debug(inventoryRecord.stockKeepingUnit);
                        system.debug(inventoryRecord.availableToFulfill);
                        
                    }
                system.debug(YARDCmap);   
                }else if(location.locationIdentifier == 'YARDBC'){
                    for(InventoryRecords inventoryRecord : location.inventoryRecords){
                        YARDBCmap.put(inventoryRecord.stockKeepingUnit, inventoryRecord.availableToFulfill);
                        system.debug(inventoryRecord.stockKeepingUnit);
                        system.debug(inventoryRecord.availableToFulfill);
                    }
                }else if(location.locationIdentifier == 'AFGS'){
                    for(InventoryRecords inventoryRecord : location.inventoryRecords){
                        AFGSmap.put(inventoryRecord.stockKeepingUnit, inventoryRecord.availableToFulfill);
                        system.debug(inventoryRecord.stockKeepingUnit);
                        system.debug(inventoryRecord.availableToFulfill);
                    }
                }else if(location.locationIdentifier == 'SPSTR'){
                    for(InventoryRecords inventoryRecord : location.inventoryRecords){
                        SPSTRmap.put(inventoryRecord.stockKeepingUnit, inventoryRecord.availableToFulfill);
                        system.debug(inventoryRecord.stockKeepingUnit);
                        system.debug(inventoryRecord.availableToFulfill);
                    }
                }else if(location.locationIdentifier == 'COL1600PLT'){
                    for(InventoryRecords inventoryRecord : location.inventoryRecords){
                        COL1600PLTmap.put(inventoryRecord.stockKeepingUnit, inventoryRecord.availableToFulfill);
                        system.debug(inventoryRecord.stockKeepingUnit);
                        system.debug(inventoryRecord.availableToFulfill);
                    }
                }else if(location.locationIdentifier == 'COL16PLT'){
                    for(InventoryRecords inventoryRecord : location.inventoryRecords){
                        COL16PLTmap.put(inventoryRecord.stockKeepingUnit, inventoryRecord.availableToFulfill);
                        system.debug(inventoryRecord.stockKeepingUnit);
                        system.debug(inventoryRecord.availableToFulfill);
                    }
                }else if(location.locationIdentifier == 'VFGS'){
                    for(InventoryRecords inventoryRecord : location.inventoryRecords){
                        VFGSmap.put(inventoryRecord.stockKeepingUnit, inventoryRecord.availableToFulfill);
                        system.debug(inventoryRecord.stockKeepingUnit);
                        system.debug(inventoryRecord.availableToFulfill);
                    }
                }else if(location.locationIdentifier == 'SFGS'){
                    for(InventoryRecords inventoryRecord : location.inventoryRecords){
                        SFGSmap.put(inventoryRecord.stockKeepingUnit, inventoryRecord.availableToFulfill);
                        system.debug(inventoryRecord.stockKeepingUnit);
                        system.debug(inventoryRecord.availableToFulfill);
                    }
                }else if(location.locationIdentifier == 'MAINAC'){
                    for(InventoryRecords inventoryRecord : location.inventoryRecords){
                        MAINACmap.put(inventoryRecord.stockKeepingUnit, inventoryRecord.availableToFulfill);
                        system.debug(inventoryRecord.stockKeepingUnit);
                        system.debug(inventoryRecord.availableToFulfill);
                    }
                }
                
            }
            
			List<OrderItem> oiToUpdate = new List<OrderItem>();
            List<Product2> orderProducts = [SELECT Id, (SELECT ProductCategory.Name  FROM ProductCategoryProducts) FROM Product2 WHERE Id IN : orderProductsIds];
            system.debug(orderProducts[0].ProductCategoryProducts);
            Map<Id, List<String>> productCategoriesMap = new Map<Id, List<String>>();
            for(Product2 orderProduct : orderProducts){
                List<String> categoryNames = new List<String>();
                for(ProductCategoryProduct categoryProducts : orderProduct.ProductCategoryProducts){
                    system.debug(categoryProducts);
                    categoryNames.add(categoryProducts.ProductCategory.Name);
                }
                productCategoriesMap.put(orderProduct.Id, categoryNames);
            }
            system.debug(orderItems);
            for(OrderItem orderItem : orderItems){
                system.debug(orderItem);
                if(orderItem.SKU__c != null){
                    if(orderItem.Product2.Family == 'Clay' && orderItem.Quantity <= YARDCmap.get(orderItem.SKU__c)){
                    orderItem.ANSA_Warehouse__c = 'YARDC';
                    oiToUpdate.add(orderItem);
                    
                    }else if(orderItem.Product2.Family == 'Air Conditioning' && orderItem.Quantity <= MAINACmap.get(orderItem.SKU__c)){
                        orderItem.ANSA_Warehouse__c = 'MAINAC';
                        oiToUpdate.add(orderItem);
                    
                    }else if(orderItem.Product2.Family == 'Bescrete' || orderItem.Product2.Family == 'Bestcrete'){
                        
                        // Obtain Categories for all Order Products.
                        List<String> categories = productCategoriesMap.get(orderItem.Product2.Id);
                                
                        if(categories.contains('Structural Blocks 140mm (6")')
                           && orderItem.Quantity <= SPSTRmap.get(orderItem.SKU__c)){
                               orderItem.ANSA_Warehouse__c = 'SPSTR';
                               oiToUpdate.add(orderItem);
						}else if(categories.contains('Structural Blocks 190mm (8")')
							|| categories.contains('Structural Blocks 90mm (4")')
                            && orderItem.Quantity <= COL1600PLTmap.get(orderItem.SKU__c)){
                            	orderItem.ANSA_Warehouse__c = 'COL1600PLT';
                                oiToUpdate.add(orderItem);
                        }else if(categories.contains('Landscaping - Paving Solutions')
                        	&& orderItem.Product2.Name.contains('Contemporary Paver')
                            && orderItem.Quantity <= COL1600PLTmap.get(orderItem.SKU__c)){
                            	orderItem.ANSA_Warehouse__c = 'COL1600PLT';
                                oiToUpdate.add(orderItem);
                        }else if(categories.contains('Decorative Blocks')
                        	&& orderItem.Quantity <= COL16PLTmap.get(orderItem.SKU__c)){
                             	orderItem.ANSA_Warehouse__c = 'COL16PLT';
                                oiToUpdate.add(orderItem);
                        }else if(categories.contains('Landscaping - Paving Solutions')
                        	&& !orderItem.Product2.Name.contains('Contemporary Paver')
                        	&& orderItem.Quantity <= COL16PLTmap.get(orderItem.SKU__c)){
                             	orderItem.ANSA_Warehouse__c = 'COL16PLT';
                                oiToUpdate.add(orderItem);
                        }else if(orderItem.Quantity <= YARDBCmap.get(orderItem.SKU__c)){
                             	orderItem.ANSA_Warehouse__c = 'YARDBC';
                                oiToUpdate.add(orderItem);
                            }
                    }
                    
                }
                  
        	}
            system.debug(oiToUpdate);
            if(!oiToUpdate.isEmpty()){
                update oiToUpdate;
            }
            
            ANSA_OCIReservationRequest.sendRequest(passedOrderId);
            
            
        }
         
    }
    
    // Input Variables
    public class InputVariables{
        @InvocableVariable
        public String orderId;
    }
   
    // Object to deserialize Json.
	public class availabilityObject {
	public List<Errors> errors;
	public List<Errors> locationGroups;
	public List<Locations> locations;
	public Boolean success;
    }
    
    public class Errors {
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

	public class Locations {
		public List<InventoryRecords> inventoryRecords;
		public String locationIdentifier;
	}


}