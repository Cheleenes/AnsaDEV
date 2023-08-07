public class OrderItemTriggerHandler {
    public void handleBeforeUpdate(List<OrderItem> newList, List<OrderItem> oldList, Map<Id,OrderItem> newMap, Map<Id,OrderItem> oldMap){
        for(OrderItem oItem : newList){
            if(oItem.ANSA_Order_Status__c != 'Draft' && oItem.Quantity != oldMap.get(oItem.Id).Quantity){
                oItem.addError('Sorry, quantities can not be modified on Activated orders', true);
            }
        }
        
    }
    
    public void handleAfterInsert(List<OrderItem> newList){
        
        map<Id, OrderItem> needsPromotion = new map<Id, OrderItem>([Select Id, TotalAdjustmentAmount, Discount__c From OrderItem Where Id in: newList]);
        map<Id, List<Decimal>> mapQLIDiscounts = new map<Id, List<Decimal>>();
        
        Order theOrder = [Select Id, AccountId, OpportunityID, TotalAmount From Order Where Id =: newList[0].OrderId LIMIT 1];
        IF(theOrder.OpportunityId != null)
            return;
        Account buyer = [Select Id, FAC_Account__r.Name, ANSA_Markup__c, ANSA_isExport__c, AMC_Channel__c From Account Where Id = :theOrder.AccountId Limit 1];
        Map<Id, BuyerGroupMember> mapBuyerGroupMember = new Map<Id, BuyerGroupMember>([Select Id, BuyerGroupId From BuyerGroupMember Where BuyerId = :buyer.Id]);
        Set<Id> BuyerGroupIds = new Set<Id>();
        For(BuyerGroupMember bgm : mapBuyerGroupMember.values()){
            BuyerGroupIds.add(bgm.BuyerGroupId);
        }
        
        List<PromotionSegmentBuyerGroup> listPromotionSegmentBuyerGroup = [Select Id, BuyerGroupId, PromotionSegmentId From PromotionSegmentBuyerGroup Where BuyerGroupId in: BuyerGroupIds];
        Set<Id> promotionSegmentIds = new Set<Id>();
        for(PromotionSegmentBuyerGroup psbg : listPromotionSegmentBuyerGroup){
            promotionSegmentIds.add(psbg.PromotionSegmentId);            
        }
        
        List<PromotionMarketSegment> listPromotionMarketSegment = [Select Id, PromotionId, PromotionSegmentId From PromotionMarketSegment Where PromotionSegmentId in: promotionSegmentIds];
        Set<Id> promotionIds = new Set<Id>();
        for(PromotionMarketSegment pms : listPromotionMarketSegment){
            promotionIds.add(pms.PromotionId);            
        }
        
        DateTime now = System.now();
        Map<Id,Promotion> mapPromotions = new Map<Id, Promotion>([Select Id From Promotion Where Id in: promotionIds AND IsCommercePromotion = true]);
        
        List<PromotionTarget> listPromotionTarget = [Select Id, PromotionId, TargetId, AdjustmentPercent, AdjustmentType, AdjustmentAmount From PromotionTarget Where PromotionId in:promotionIds];
        map<Id, List<PromotionTarget>> mapPromotionTarget = new map<Id, List<PromotionTarget>>();
        for(PromotionTarget pt : listPromotionTarget){
            if(mapPromotionTarget.get(pt.PromotionId) == null){
                List<PromotionTarget> aux = new List<PromotionTarget>();
                aux.add(pt);
                mapPromotionTarget.put(pt.PromotionId, aux);
            }else{
                List<PromotionTarget> aux = mapPromotionTarget.get(pt.PromotionId);
                aux.add(pt);
                mapPromotionTarget.put(pt.PromotionId, aux);
            }
            
        }
        
        
        Set<Id> productIds = new Set<Id>();
        for(OrderItem oLI : newList){
            productIds.add(oLI.Product2Id);
        }
        List<ProductCategoryProduct> listProductCategoryProduct = [Select Id, ProductId, ProductCategoryId, ProductCategory.Name From ProductCategoryProduct Where ProductId in: productIds];
        map<Id, List<ProductCategoryProduct>> mapProductCategoryProduct = new map<Id, List<ProductCategoryProduct>>();
        for(ProductCategoryProduct pcp : listProductCategoryProduct){
            if(mapProductCategoryProduct.get(pcp.ProductId) == null){
                List<ProductCategoryProduct> aux = new List<ProductCategoryProduct>();
                aux.add(pcp);
                mapProductCategoryProduct.put(pcp.ProductId, aux);
            }else{
                List<ProductCategoryProduct> aux = mapProductCategoryProduct.get(pcp.ProductId);
                aux.add(pcp);
                mapProductCategoryProduct.put(pcp.ProductId, aux);
            }
        }
        
        Map<Id, Product2> mapProds = new Map<Id, Product2>([Select Id, Name, StockKeepingUnit, AMC_ProductType__c From Product2 Where Id in: productIds]);
        List<OrderItem> oItemsToUpdate = new List<OrderItem>();
        
        //Boolean set to true if related account is export and needs markup calculation
        Boolean needsMarkup = false;
        if((buyer.ANSA_Markup__c == 'Dealer' || buyer.ANSA_Markup__c == 'Other') && (buyer.ANSA_isExport__c && buyer.AMC_Channel__c == 'Export')){
            needsMarkup = true;
            System.debug('Account marked as markup needed');
        }
            
        
        for(OrderItem oLI : newList){
            OrderItem oLIupdate = new OrderItem(Id = oLI.Id, ListPrice = oLI.ListPrice, UnitPrice = oLI.UnitPrice);
            if(needsMarkup){
                System.debug('executing markup method');
                CalculateMarkup(oLIupdate, buyer.FAC_Account__r.Name, buyer.ANSA_Markup__c);
                oItemsToUpdate.add(oLIupdate);
            }
            
            System.debug('prod name: ' + mapProds.get(oLI.Product2Id).Name + ', id: ' + mapProds.get(oLI.Product2Id).Id);
            for(Promotion promo : mapPromotions.values()){
                List<PromotionTarget> currentPromotionTargets = mapPromotionTarget.get(promo.Id);
                System.debug('promotion targets: ' + currentPromotionTargets);
                if(currentPromotionTargets != null){
                    for(PromotionTarget pt : currentPromotionTargets){
                        if(mapProductCategoryProduct.get(oLI.Product2Id) == null){
                            if(oLI.Product2Id == pt.TargetId){
                                if(pt.AdjustmentType == 'PercentageDiscount'){
                                    if(oLI.Discount__c == null || pt.AdjustmentPercent > oLI.Discount__c ){
                                        if(oLIupdate.Description == null){
                                            oLIupdate.Description = String.valueOf(oLIupdate.UnitPrice);
                                        }                                        
                                        oLIupdate.Discount__c = pt.AdjustmentPercent;
                                        System.debug('oLIupdate.Discount__c:' + oLIupdate.Discount__c); System.debug('oLIupdate.UnitPrice:' + oLIupdate.UnitPrice); System.debug('oLIupdate.Description:' + oLIupdate.Description);
                                        oLIupdate.UnitPrice = Decimal.valueOf(oLIupdate.Description) - (Decimal.valueOf(oLIupdate.Description) * (oLIupdate.Discount__c / 100) );
                                        if(!oItemsToUpdate.contains(oLIupdate))
                                            oItemsToUpdate.add(oLIupdate);
                                    }
                                }else{
                                    if(oLI.AMC_Promotion_applied__c == null || pt.AdjustmentAmount > Decimal.valueOf(oLI.AMC_Promotion_applied__c) ){
                                        //OrderItem oLIupdate = new OrderItem(Id = oLI.Id);
                                        if(oLIupdate.Description == null)
                                            oLIupdate.Description = String.valueOf(oLIupdate.UnitPrice);
                                        oLIupdate.AMC_Promotion_applied__c = String.valueOf(pt.AdjustmentAmount);
                                        oLIupdate.UnitPrice = Decimal.valueOf(oLIupdate.Description) - pt.AdjustmentAmount;
                                        if(!oItemsToUpdate.contains(oLIupdate))
                                            oItemsToUpdate.add(oLIupdate);
                                    }
                                }
                            }
                        }else{
                            for(ProductCategoryProduct pcp : mapProductCategoryProduct.get(oLI.Product2Id)){
                                if(pcp.ProductCategoryId == pt.TargetId || oLI.Product2Id == pt.TargetId){
                                    if(pt.AdjustmentType == 'PercentageDiscount'){
                                        if(oLI.Discount__c == null || pt.AdjustmentPercent > oLI.Discount__c ){
                                            if(oLIupdate.Description == null){
                                                oLIupdate.Description = String.valueOf(oLIupdate.UnitPrice);
                                            }                                        
                                            oLIupdate.Discount__c = pt.AdjustmentPercent;
                                            System.debug('oLIupdate.Discount__c:' + oLIupdate.Discount__c); System.debug('oLIupdate.UnitPrice:' + oLIupdate.UnitPrice); System.debug('oLIupdate.Description:' + oLIupdate.Description);
                                            oLIupdate.UnitPrice = Decimal.valueOf(oLIupdate.Description) - (Decimal.valueOf(oLIupdate.Description) * (oLIupdate.Discount__c / 100) );
                                            if(!oItemsToUpdate.contains(oLIupdate))
                                                oItemsToUpdate.add(oLIupdate);
                                        }
                                    }else{
                                        if(oLI.AMC_Promotion_applied__c == null || pt.AdjustmentAmount > Decimal.valueOf(oLI.AMC_Promotion_applied__c) ){
                                            //OrderItem oLIupdate = new OrderItem(Id = oLI.Id);
                                            if(oLIupdate.Description == null)
                                                oLIupdate.Description = String.valueOf(oLIupdate.UnitPrice);
                                            oLIupdate.AMC_Promotion_applied__c = String.valueOf(pt.AdjustmentAmount);
                                            oLIupdate.UnitPrice = Decimal.valueOf(oLIupdate.Description) - pt.AdjustmentAmount;
                                            if(!oItemsToUpdate.contains(oLIupdate))
                                                oItemsToUpdate.add(oLIupdate);
                                        }
                                    }
                                }
                            }
                        }
                    }
            	}
            }
            
        }
        update oItemsToUpdate;
        /*
        for(OrderItem oLI : newList){
            if(oLI.Discount__c != null){
                oLI.UnitPrice = oLI.UnitPrice - (oLI.UnitPrice * (oLI.Discount__c / 100) );
                oItemsToUpdate.add(oLI);
            }
        }
        update oItemsToUpdate;
*/
    }
    
    public void handleBeforeInsert(List<OrderItem> newList){
        Order theOrder = [Select Id, AccountId, OpportunityID, TotalAmount From Order Where Id =: newList[0].OrderId LIMIT 1];
        Account buyer = [Select Id, FAC_Account__r.Name From Account Where Id = :theOrder.AccountId Limit 1];
        Set<Id> productIds = new Set<Id>();
        for(OrderItem oLI : newList){
            productIds.add(oLI.Product2Id);
        }
        Map<Id, Product2> mapProds = new Map<Id, Product2>([Select Id, Name, StockKeepingUnit, AMC_ProductType__c From Product2 Where Id in: productIds]);
        for(OrderItem oLI : newList){
            if(mapProds.get(oLI.Product2Id).Name == 'Shipping cost'){
                CalculateShippingCost(oLI, buyer.FAC_Account__r.Name, theOrder);
            }
        }
    }
    
    public static void CalculateShippingCost(OrderItem oLI, String BU, Order theOrder){
        System.debug('Procesing shipping cost...');
        System.debug('BU: ' + BU);
        List<Id> orderProdIds = new List<Id>();
        List<OrderItem> allOLI = [Select Id, Product2Id, Quantity From OrderItem Where ORderId =: theOrder.Id];
        for(OrderItem theOLI : allOLI){
            orderProdIds.add(theOLI.Product2Id);
        }
        List<ProductCategoryProduct> listProductCategoryProduct = [Select Id, ProductId, ProductCategoryId, ProductCategory.Name From ProductCategoryProduct Where ProductId in: orderProdIds];
        System.debug('listProductCategoryProduct: ' + listProductCategoryProduct);
        Map<Id, List<String>> mapProdIdCatName = new Map<Id, List<String>>();
        for(ProductCategoryProduct pcp : listProductCategoryProduct){
            if(mapProdIdCatName.get(pcp.ProductId) == null){
                List<String> aux  = new List<String>();
                aux.add(pcp.ProductCategory.Name);
                mapProdIdCatName.put(pcp.ProductId, aux);
            }else{
                List<String> aux = mapProdIdCatName.get(pcp.ProductId);
                aux.add(pcp.ProductCategory.Name);
                mapProdIdCatName.put(pcp.ProductId, aux);
            }            
        }
        switch on BU{
            when 'Abel Building Solutions'{
                System.debug('Shipping cost for ABS...');
                Map<String, String> mapCategoryProductId = new Map<String, String>();
                for(ProductCategoryProduct PCP : listProductCategoryProduct){
                    System.debug('PCP: ' + PCP);
                    mapCategoryProductId.put(PCP.ProductCategory.Name, PCP.ProductId);
                }
                Set<Id> countClay = new Set<Id>();
                Set<Id> countConcrete = new Set<Id>();
                Integer intClay = 0;
                Integer intConcrete = 0;
                String clayConcept = 'Clay Blocks';
                String concreteConcept = 'Building Blocks, Decorative Blocks, Landscaping';
                for(OrderItem currentOLI : allOLI){
                    System.debug('current category: ' + mapProdIdCatName.get(currentOLI.Product2Id));
                    List<String> categoryList = mapProdIdCatName.get(currentOLI.Product2Id);
                    for(String cat : categoryList){
                        System.debug('current category: ' + cat);
                        if(cat.contains(clayConcept)){
                            intClay += (Integer)currentOLI.Quantity;
                            break;
                        }if(concreteConcept.contains(cat)){
                            intConcrete += (Integer)currentOLI.Quantity;
                            break;
                        }
                    }
                }
                Integer clayShippingCost = 0;
                Integer concreteShippingCost = 0;
                if(intClay > 0 && intClay < 5)
                    clayShippingCost = 700;
                if(intConcrete > 0 && intConcrete < 4)
                    concreteShippingCost = 700;
                Integer totalShippingCost = clayShippingCost + concreteShippingCost;
                System.debug('countClay: ' + countClay);
                System.debug('countConcrete: ' + countConcrete);
                System.debug('intClay: ' + intClay);
                System.debug('intConcrete: ' + intConcrete);
                System.debug('clayShippingCost: ' + clayShippingCost);
                System.debug('concreteShippingCost: ' + concreteShippingCost);
                
                if(totalShippingCost <= 0){
                    oLI.UnitPrice = 0;
                }else{
                    oLI.UnitPrice = totalShippingCost;
                }
            }
            when 'ANSA Coatings Ltd'{
                System.debug('Shipping cost for ANSA Coatings Ltd...');
                if(theOrder.TotalAmount >= 250.00){
                    oLI.UnitPrice = 0;
                }else{
                    oLI.UnitPrice = 30.00;
                }
            }          
            when 'Berger Paints Barbados Ltd'{
                System.debug('Shipping cost for Berger Paints Barbados Ltd...');
                if(theOrder.TotalAmount >= 100.00){
                    oLI.UnitPrice = 0;
                }else{
                    oLI.UnitPrice = 18.00;
                }
            }
            when 'Berger Paints Jamaica Ltd'{
                System.debug('Shipping cost for Berger Paints Jamaica Ltd...');
                if(theOrder.TotalAmount >= 9000.00){
					oLI.UnitPrice = 0;
                }else{
                    oLI.UnitPrice = 900.00;
                }
            }
            when 'Sissons Paints Grenada Ltd'{
                System.debug('Shipping cost for Sissons Paints Grenada Ltd...');
                if(theOrder.TotalAmount >= 200.00){
                    oLI.UnitPrice = 0;
                }else{
                    oLI.UnitPrice = 30.00;
                }
            }
        }
    }
    
    public static void CalculateMarkup(OrderItem oLI, String BU, String markupType){
        System.debug('entered markup method');
        if(BU == 'Abel Building Solutions')
            return;
        Decimal markupPercent = 0;
        if(BU == 'ANSA Coatings Ltd')
            if(markupType == 'Other')
				markupPercent = 0.3;
        	else
                markupPercent = 0.15;
        else
            if(markupType == 'Other')
				markupPercent = 0.2;
        	else
                markupPercent = 0.10;
        System.debug('markupPercent: ' + markupPercent);
        System.debug('oLI.UnitPrice: ' + oLI.UnitPrice); 
        oLI.UnitPrice = oLI.ListPrice + (oLI.ListPrice * markupPercent);
        System.debug('oLI.UnitPrice: ' + oLI.UnitPrice);        
    }
}