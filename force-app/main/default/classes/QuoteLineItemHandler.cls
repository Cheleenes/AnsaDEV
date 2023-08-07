public class QuoteLineItemHandler {
    public void handleBeforeInsert(List<QuoteLineItem> newList){
		Quote theQuote = [Select Id, Opportunity.AccountId, GrandTotal From Quote Where Id =: newList[0].QuoteId LIMIT 1];
        Account buyer = [Select Id, FAC_Account__r.Name From Account Where Id = :theQuote.Opportunity.AccountId Limit 1];        
        Set<Id> productIds = new Set<Id>();
        for(QuoteLineItem qLI : newList){
            productIds.add(qLI.Product2Id);
        }
        Map<Id, Product2> mapProds = new Map<Id, Product2>([Select Id, Name, StockKeepingUnit, AMC_ProductType__c From Product2 Where Id in: productIds]);
        for(QuoteLineItem qLI : newList){
            if(mapProds.get(qLI.Product2Id).Name == 'Shipping cost'){
                CalculateShippingCost(qLI, buyer.FAC_Account__r.Name, theQuote);
            }  
        }  
    }    
    
    public void handleAfterInsert(List<QuoteLineItem> newList){
        map<Id, QuoteLineItem> needsPromotion = new map<Id, QuoteLineItem>([Select Id, Discount From QuoteLineItem Where Id in: newList]);
        map<Id, List<Decimal>> mapQLIDiscounts = new map<Id, List<Decimal>>();
        
		Quote theQuote = [Select Id, Opportunity.AccountId, GrandTotal, AccountId From Quote Where Id =: newList[0].QuoteId LIMIT 1];
        Account buyer = [Select Id, FAC_Account__r.Name, ANSA_Markup__c, ANSA_isExport__c, AMC_Channel__c From Account Where Id = :theQuote.AccountId Limit 1];
        System.debug('Buyer: ' + buyer);
        System.debug('Buyer BU: ' + buyer.FAC_Account__r.Name);
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
        for(QuoteLineItem qLI : newList){
            productIds.add(qLI.Product2Id);
        }
        List<ProductCategoryProduct> listProductCategoryProduct = [Select Id, ProductId, ProductCategoryId, ProductCategory.Name From ProductCategoryProduct Where ProductId in: productIds];
        System.debug('listProductCategoryProduct: ' + listProductCategoryProduct);
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
        List<QuoteLineItem> qItemsToUpdate = new List<QuoteLineItem>();
        
        //Boolean set to true if related account is export and needs markup calculation
        Boolean needsMarkup = false;
        if((buyer.ANSA_Markup__c == 'Dealer' || buyer.ANSA_Markup__c == 'Other') && (buyer.ANSA_isExport__c && buyer.AMC_Channel__c == 'Export'))
            needsMarkup = true;
        
        for(QuoteLineItem qLI : newList){
            System.debug('qli.ListPrice: ' + qli.ListPrice);
            System.debug('qli.UnitPrice: ' + qli.UnitPrice);
			QuoteLineItem qLIupdate = new QuoteLineItem(Id = qli.Id, Description = String.valueOf(qli.UnitPrice), UnitPrice = qli.UnitPrice);
            //Markup calcultation if neccesary
            if(needsMarkup){
                CalculateMarkup(qLIupdate, buyer.FAC_Account__r.Name, buyer.ANSA_Markup__c); 
                qItemsToUpdate.add(qLIupdate);
            }
                
            
            
            for(Promotion promo : mapPromotions.values()){
                List<PromotionTarget> currentPromotionTargets = mapPromotionTarget.get(promo.Id);
                System.debug('promotion targets: ' + currentPromotionTargets);
                if(currentPromotionTargets != null){
                    for(PromotionTarget pt : currentPromotionTargets){
                        if(mapProductCategoryProduct.get(qLI.Product2Id) == null){
                            if(qli.Product2Id == pt.TargetId){
                                if(pt.AdjustmentType == 'PercentageDiscount'){
                                    if(qli.Discount == null || pt.AdjustmentPercent > qli.Discount ){
                                        
                                        qLIupdate.Discount = pt.AdjustmentPercent;
                                        if(!qItemsToUpdate.contains(qLIupdate))
                                            qItemsToUpdate.add(qLIupdate);
                                    }
                                }else{
                                    if(qli.AMC_Promotion_applied_c__c == null || pt.AdjustmentAmount > Decimal.valueOf(qli.AMC_Promotion_applied_c__c) ){
                                        //QuoteLineItem qLIupdate = new QuoteLineItem(Id = qli.Id);
                                        if(qLIupdate.Description == null)
                                            qLIupdate.Description = String.valueOf(qLIupdate.UnitPrice);
                                        qLIupdate.AMC_Promotion_applied_c__c = String.valueOf(pt.AdjustmentAmount);
                                        qLIupdate.UnitPrice = Decimal.valueOf(qLIupdate.Description) - pt.AdjustmentAmount;//qli.UnitPrice - pt.AdjustmentAmount;
                                        if(!qItemsToUpdate.contains(qLIupdate))
                                            qItemsToUpdate.add(qLIupdate);
                                    }
                                }                          
                            }
                            
                        }else{
                            for(ProductCategoryProduct pcp : mapProductCategoryProduct.get(qLI.Product2Id)){
                                if(pcp.ProductCategoryId == pt.TargetId || qli.Product2Id == pt.TargetId){
                                    if(pt.AdjustmentType == 'PercentageDiscount'){
                                        if(qli.Discount == null || pt.AdjustmentPercent > qli.Discount ){
                                            
                                            qLIupdate.Discount = pt.AdjustmentPercent;
                                            if(!qItemsToUpdate.contains(qLIupdate))
                                                qItemsToUpdate.add(qLIupdate);
                                        }
                                    }else{
                                        if(qli.AMC_Promotion_applied_c__c == null || pt.AdjustmentAmount > Decimal.valueOf(qli.AMC_Promotion_applied_c__c) ){
                                            //QuoteLineItem qLIupdate = new QuoteLineItem(Id = qli.Id);
                                            if(qLIupdate.Description == null)
                                                qLIupdate.Description = String.valueOf(qLIupdate.UnitPrice);
                                            qLIupdate.AMC_Promotion_applied_c__c = String.valueOf(pt.AdjustmentAmount);
                                            qLIupdate.UnitPrice = Decimal.valueOf(qLIupdate.Description) - pt.AdjustmentAmount;//qli.UnitPrice - pt.AdjustmentAmount;
                                            if(!qItemsToUpdate.contains(qLIupdate))
                                                qItemsToUpdate.add(qLIupdate);
                                        }
                                    }                          
                                }
                            }
                    	}
                    }
                }
            }    
        }  
        update qItemsToUpdate;
    }    
    
    public static void CalculateShippingCost(QuoteLineItem qLI, String BU, Quote theQuote){
        System.debug('Procesing shipping cost...');
        System.debug('BU: ' + BU);
        List<Id> quoteProdIds = new List<Id>();
        List<QuoteLineItem> allQLI = [Select Id, Product2Id, Quantity From QuoteLineItem Where QuoteId =: theQuote.Id];
        for(QuoteLineItem theQLI : allQLI){
            quoteProdIds.add(theQLI.Product2Id);
        }
        List<ProductCategoryProduct> listProductCategoryProduct = [Select Id, ProductId, ProductCategoryId, ProductCategory.Name From ProductCategoryProduct Where ProductId in: quoteProdIds];
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
                for(QuoteLineItem currentQLI : allQLI){
                    System.debug('current category: ' + mapProdIdCatName.get(currentQLI.Product2Id));
                    List<String> categoryList = mapProdIdCatName.get(currentQLI.Product2Id);
                    for(String cat : categoryList){
                        System.debug('current category: ' + cat);
                        if(cat.contains(clayConcept)){
                            intClay += (Integer)currentQLI.Quantity;
                            break;
                        }if(concreteConcept.contains(cat)){
                            intConcrete += (Integer)currentQLI.Quantity;
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
                    qLI.UnitPrice = 0;
                }else{
                    qLI.UnitPrice = totalShippingCost;
                }
            }
            when 'ANSA Coatings Ltd'{
                System.debug('Shipping cost for ANSA Coatings Ltd...');
                if(theQuote.GrandTotal >= 250.00){
                    qLI.UnitPrice = 0;
                }else{
                    qLI.UnitPrice = 30.00;
                }
            }          
            when 'Berger Paints Barbados Ltd'{
                System.debug('Shipping cost for Berger Paints Barbados Ltd...');
                if(theQuote.GrandTotal >= 100.00){
                    qLI.UnitPrice = 0;
                }else{
                    qLI.UnitPrice = 18.00;
                }
            }
            when 'Berger Paints Jamaica Ltd'{
                System.debug('Shipping cost for Berger Paints Jamaica Ltd...');
                if(theQuote.GrandTotal >= 9000.00){
					qLI.UnitPrice = 0;
                }else{
                    qLI.UnitPrice = 900.00;
                }
            }
            when 'Sissons Paints Grenada Ltd'{
                System.debug('Shipping cost for Sissons Paints Grenada Ltd...');
                if(theQuote.GrandTotal >= 200.00){
                    qLI.UnitPrice = 0;
                }else{
                    qLI.UnitPrice = 30.00;
                }
            }
        }
    }
    
    public static void CalculateMarkup(QuoteLineItem qLI, String BU, String markupType){
        Decimal listPrice = Decimal.valueOf(qLI.Description);
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
            
        qLI.UnitPrice = listPrice + (listPrice * markupPercent);
    }
}