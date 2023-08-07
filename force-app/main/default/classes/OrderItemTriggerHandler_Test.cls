@isTest
public class OrderItemTriggerHandler_Test {
	@isTest static void testHandler1(){
    	Promotion prom = new Promotion();
        prom.Name = 'Test';
        prom.IsActive = true;
        prom.IsCommercePromotion = true;
        insert prom;
        
        Promotion prom2 = new Promotion();
        prom2.Name = 'Test';
        prom2.IsActive = true;
        prom2.IsCommercePromotion = true;
        insert prom2;
        
        Account buacc = new Account();
        buacc.AMC_Tax__c = 10.00;
        buacc.Name = 'Abel Building Solutions';
        buacc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FAC Account').getRecordTypeId();
        buacc.CurrencyIsoCode = 'USD';
        insert buacc;
        
        Account acc = new Account();
        acc.Name = 'test';
        acc.CurrencyIsoCode = 'USD';
        acc.FAC_Account__c = buacc.Id;
        acc.ANSA_Markup__c = 'Dealer';
        acc.ANSA_isExport__c = true;
        acc.AMC_Channel__c = 'Export';
        insert acc;

		Contact cont = new Contact();
        cont.LastName = 'test';
        cont.FirstName = 'test';
        cont.Salutation = 'Mr.';
        cont.Email = 'test@test.com';
        cont.Phone = '12345678901';
        cont.CurrencyIsoCode = 'USD';
        cont.Fax = '12345678901';
        insert cont;
        
        BuyerAccount ba = new BuyerAccount();
        ba.BuyerId = acc.Id;
        ba.Name = 'Test';
        ba.IsActive = true;
        insert ba;
        
        BuyerGroup bg = new BuyerGroup();
        bg.Name = 'test';
        insert bg;
        
        BuyerGroupMember bgm = new BuyerGroupMember();
        bgm.BuyerGroupId = bg.Id;
        bgm.BuyerId = acc.Id;
        insert bgm;
        
        PromotionSegment ps = new PromotionSegment();
        ps.Name = 'test';
        insert ps;
        
        PromotionMarketSegment pms = new PromotionMarketSegment();
        pms.PromotionId = prom.Id;
        pms.PromotionSegmentId = ps.Id;
        insert pms;
        
        PromotionMarketSegment pms2 = new PromotionMarketSegment();
        pms2.PromotionId = prom2.Id;
        pms2.PromotionSegmentId = ps.Id;
        insert pms2;
        
        PromotionSegmentBuyerGroup psbg = new PromotionSegmentBuyerGroup();
        psbg.BuyerGroupId = bg.Id;
        psbg.PromotionSegmentId = ps.Id;
        insert psbg;
        
        Product2 prod = new Product2();
        prod.name = 'test';
		insert prod;
        
        Product2 prod2 = new Product2();
        prod2.name = 'Shipping cost';
		insert prod2;
        
        ProductCatalog pCatalog = new ProductCatalog();
        pCatalog.Name = 'test';
        insert pCatalog;
        
		ProductCategory pc = new ProductCategory();
		pc.Name = 'Clay Blocks';
        pc.CatalogId = pCatalog.Id;
		insert pc;

        ProductCategoryProduct pcp = new ProductCategoryProduct();
        pcp.ProductId = prod.Id;
        pcp.ProductCategoryId = pc.Id;
        insert pcp;
        
        ProductCategoryProduct pcp2 = new ProductCategoryProduct();
        pcp2.ProductId = prod2.Id;
        pcp2.ProductCategoryId = pc.Id;
        insert pcp2;
        
        PromotionTarget pt = new PromotionTarget();
        pt.PromotionId = prom.Id;
        pt.TargetId = pc.Id;
        pt.TargetType = 'ProductCategory';
        pt.AdjustmentType = 'PercentageDiscount';
        pt.AdjustmentPercent = 10.00;
        insert pt;
        
        PromotionTarget pt2 = new PromotionTarget();
        pt2.PromotionId = prom2.Id;
        pt2.TargetId = prod.Id;
        pt2.TargetType = 'Product';
        pt2.AdjustmentType = 'FixedPrice';
        pt2.AdjustmentAmount = 1;
        insert pt2;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.CloseDate = System.today();
        opp.StageName = 'Qualification';
        opp.CurrencyIsoCode = 'USD';
        opp.AccountId = acc.Id;
        insert opp;
        
        Order ord = new Order();
        //ord.OpportunityId = opp.Id;
        ord.AccountId = acc.Id;
        ord.Name = 'Test';
        ord.CurrencyIsoCode = 'USD';
        ord.Pricebook2Id = Test.getStandardPricebookId();
        ord.EffectiveDate = System.today();
        ord.Status = 'Draft';
        insert ord;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.CurrencyIsoCode = 'USD';
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.Product2Id = prod.Id;
        pbe.UnitPrice = 100;
        pbe.IsActive = true;
        insert pbe;
        
        PricebookEntry pbe2 = new PricebookEntry();
        pbe2.CurrencyIsoCode = 'USD';
        pbe2.Pricebook2Id = Test.getStandardPricebookId();
        pbe2.Product2Id = prod2.Id;
        pbe2.UnitPrice = 100;
        pbe2.IsActive = true;
        insert pbe2;
        
        OrderItem oli = new OrderItem();
        oli.Product2Id = prod.Id;
        oli.OrderId = ord.Id;
        oli.PricebookEntryId = pbe.Id;
        oli.Quantity = 1;
        oli.UnitPrice = 100;  
        insert oli;
        
        OrderItem oli2 = new OrderItem();
        oli2.Product2Id = prod2.Id;
        oli2.OrderId = ord.Id;
        oli2.PricebookEntryId = pbe2.Id;
        oli2.Quantity = 1;
        oli2.UnitPrice = 100;  
        insert oli2;
        
        buacc.Name = 'ANSA Coatings Ltd';
        update buacc;
        
         OrderItem oli3 = new OrderItem();
        oli3.Product2Id = prod2.Id;
        oli3.OrderId = ord.Id;
        oli3.PricebookEntryId = pbe2.Id;
        oli3.Quantity = 1;
        oli3.UnitPrice = 100;  
        insert oli3;
        
        /*buacc.Name = 'Berger Paints Barbados Ltd';
        update buacc;
        
         OrderItem oli4 = new OrderItem();
        oli4.Product2Id = prod2.Id;
        oli4.OrderId = ord.Id;
        oli4.PricebookEntryId = pbe2.Id;
        oli4.Quantity = 1;
        oli4.UnitPrice = 100;  
        insert oli4;
        
        buacc.Name = 'Berger Paints Jamaica Ltd';
        update buacc;
        
         OrderItem oli5 = new OrderItem();
        oli5.Product2Id = prod2.Id;
        oli5.OrderId = ord.Id;
        oli5.PricebookEntryId = pbe2.Id;
        oli5.Quantity = 1;
        oli5.UnitPrice = 100;  
        insert oli5;
        
        buacc.Name = 'Sissons Paints Grenada Ltd';
        update buacc;
        
         OrderItem oli6 = new OrderItem();
        oli6.Product2Id = prod2.Id;
        oli6.OrderId = ord.Id;
        oli6.PricebookEntryId = pbe2.Id;
        oli6.Quantity = 1;
        oli6.UnitPrice = 100;  
        insert oli6;*/
    }
    
    @isTest static void testHandler2(){
    	Promotion prom = new Promotion();
        prom.Name = 'Test';
        prom.IsActive = true;
        prom.IsCommercePromotion = true;
        insert prom;
        
        Account buacc = new Account();
        buacc.AMC_Tax__c = 10.00;
        buacc.Name = 'Abel Building Solutions';
        buacc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FAC Account').getRecordTypeId();
        buacc.CurrencyIsoCode = 'USD';
        insert buacc;
        
        Account acc = new Account();
        acc.Name = 'test';
        acc.CurrencyIsoCode = 'USD';
        acc.FAC_Account__c = buacc.Id;
        insert acc;

		Contact cont = new Contact();
        cont.LastName = 'test';
        cont.FirstName = 'test';
        cont.Salutation = 'Mr.';
        cont.Email = 'test@test.com';
        cont.Phone = '12345678901';
        cont.CurrencyIsoCode = 'USD';
        cont.Fax = '12345678901';
        insert cont;
        
        BuyerAccount ba = new BuyerAccount();
        ba.BuyerId = acc.Id;
        ba.Name = 'Test';
        ba.IsActive = true;
        insert ba;
        
        BuyerGroup bg = new BuyerGroup();
        bg.Name = 'test';
        insert bg;
        
        BuyerGroupMember bgm = new BuyerGroupMember();
        bgm.BuyerGroupId = bg.Id;
        bgm.BuyerId = acc.Id;
        insert bgm;
        
        PromotionSegment ps = new PromotionSegment();
        ps.Name = 'test';
        insert ps;
        
        PromotionMarketSegment pms = new PromotionMarketSegment();
        pms.PromotionId = prom.Id;
        pms.PromotionSegmentId = ps.Id;
        insert pms;
        
        PromotionSegmentBuyerGroup psbg = new PromotionSegmentBuyerGroup();
        psbg.BuyerGroupId = bg.Id;
        psbg.PromotionSegmentId = ps.Id;
        insert psbg;
        
        Product2 prod = new Product2();
        prod.name = 'test';
		insert prod;
        
        Product2 prod2 = new Product2();
        prod2.name = 'Shipping cost';
		insert prod2;
        System.debug(prod2);
        
        ProductCatalog pCatalog = new ProductCatalog();
        pCatalog.Name = 'test';
        insert pCatalog;
        
		ProductCategory pc = new ProductCategory();
		pc.Name = 'Clay Blocks';
        pc.CatalogId = pCatalog.Id;
		insert pc;

        ProductCategoryProduct pcp = new ProductCategoryProduct();
        pcp.ProductId = prod.Id;
        pcp.ProductCategoryId = pc.Id;
        insert pcp;
        
        ProductCategoryProduct pcp2 = new ProductCategoryProduct();
        pcp2.ProductId = prod2.Id;
        pcp2.ProductCategoryId = pc.Id;
        insert pcp2;
        
        PromotionTarget pt = new PromotionTarget();
        pt.PromotionId = prom.Id;
        pt.TargetId = pc.Id;
        pt.TargetType = 'ProductCategory';
        pt.AdjustmentType = 'PercentageDiscount';
        pt.AdjustmentPercent = 10.00;
        insert pt;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.CloseDate = System.today();
        opp.StageName = 'Qualification';
        opp.CurrencyIsoCode = 'USD';
        opp.AccountId = acc.Id;
        insert opp;
        
        Order ord = new Order();
        //ord.OpportunityId = opp.Id;
        ord.AccountId = acc.Id;
        ord.Name = 'Test';
        ord.CurrencyIsoCode = 'USD';
        ord.Pricebook2Id = Test.getStandardPricebookId();
        ord.EffectiveDate = System.today();
        ord.Status = 'Draft';
        insert ord;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.CurrencyIsoCode = 'USD';
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.Product2Id = prod.Id;
        pbe.UnitPrice = 100;
        pbe.IsActive = true;
        insert pbe;
        
        PricebookEntry pbe2 = new PricebookEntry();
        pbe2.CurrencyIsoCode = 'USD';
        pbe2.Pricebook2Id = Test.getStandardPricebookId();
        pbe2.Product2Id = prod2.Id;
        pbe2.UnitPrice = 100;
        pbe2.IsActive = true;
        insert pbe2;
        
        OrderItem oli = new OrderItem();
        oli.Product2Id = prod.Id;
        oli.OrderId = ord.Id;
        oli.PricebookEntryId = pbe.Id;
        oli.Quantity = 1;
        oli.UnitPrice = 100;  
        insert oli;
        
        OrderItem oli2 = new OrderItem();
        oli2.Product2Id = prod2.Id;
        oli2.OrderId = ord.Id;
        oli2.PricebookEntryId = pbe2.Id;
        oli2.Quantity = 1;
        oli2.UnitPrice = 100;  
        insert oli2;
        
        /*buacc.Name = 'ANSA Coatings Ltd';
        update buacc;
        
         OrderItem oli3 = new OrderItem();
        oli3.Product2Id = prod2.Id;
        oli3.OrderId = ord.Id;
        oli3.PricebookEntryId = pbe2.Id;
        oli3.Quantity = 1;
        oli3.UnitPrice = 100;  
        insert oli3;*/
        
        buacc.Name = 'Berger Paints Barbados Ltd';
        update buacc;
        
         OrderItem oli4 = new OrderItem();
        oli4.Product2Id = prod2.Id;
        oli4.OrderId = ord.Id;
        oli4.PricebookEntryId = pbe2.Id;
        oli4.Quantity = 1;
        oli4.UnitPrice = 100;  
        insert oli4;
        
        /*buacc.Name = 'Berger Paints Jamaica Ltd';
        update buacc;
        
         OrderItem oli5 = new OrderItem();
        oli5.Product2Id = prod2.Id;
        oli5.OrderId = ord.Id;
        oli5.PricebookEntryId = pbe2.Id;
        oli5.Quantity = 1;
        oli5.UnitPrice = 100;  
        insert oli5;
        
        buacc.Name = 'Sissons Paints Grenada Ltd';
        update buacc;
        
         OrderItem oli6 = new OrderItem();
        oli6.Product2Id = prod2.Id;
        oli6.OrderId = ord.Id;
        oli6.PricebookEntryId = pbe2.Id;
        oli6.Quantity = 1;
        oli6.UnitPrice = 100;  
        insert oli6;*/
    }
    
    @isTest static void testHandler3(){
    	Promotion prom = new Promotion();
        prom.Name = 'Test';
        prom.IsActive = true;
        prom.IsCommercePromotion = true;
        insert prom;
        
        Account buacc = new Account();
        buacc.AMC_Tax__c = 10.00;
        buacc.Name = 'Abel Building Solutions';
        buacc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FAC Account').getRecordTypeId();
        buacc.CurrencyIsoCode = 'USD';
        insert buacc;
        
        Account acc = new Account();
        acc.Name = 'test';
        acc.CurrencyIsoCode = 'USD';
        acc.FAC_Account__c = buacc.Id;
        insert acc;

		Contact cont = new Contact();
        cont.LastName = 'test';
        cont.FirstName = 'test';
        cont.Salutation = 'Mr.';
        cont.Email = 'test@test.com';
        cont.Phone = '12345678901';
        cont.CurrencyIsoCode = 'USD';
        cont.Fax = '12345678901';
        insert cont;
        
        BuyerAccount ba = new BuyerAccount();
        ba.BuyerId = acc.Id;
        ba.Name = 'Test';
        ba.IsActive = true;
        insert ba;
        
        BuyerGroup bg = new BuyerGroup();
        bg.Name = 'test';
        insert bg;
        
        BuyerGroupMember bgm = new BuyerGroupMember();
        bgm.BuyerGroupId = bg.Id;
        bgm.BuyerId = acc.Id;
        insert bgm;
        
        PromotionSegment ps = new PromotionSegment();
        ps.Name = 'test';
        insert ps;
        
        PromotionMarketSegment pms = new PromotionMarketSegment();
        pms.PromotionId = prom.Id;
        pms.PromotionSegmentId = ps.Id;
        insert pms;
        
        PromotionSegmentBuyerGroup psbg = new PromotionSegmentBuyerGroup();
        psbg.BuyerGroupId = bg.Id;
        psbg.PromotionSegmentId = ps.Id;
        insert psbg;
        
        Product2 prod = new Product2();
        prod.name = 'test';
		insert prod;
        
        Product2 prod2 = new Product2();
        prod2.name = 'Shipping cost';
		insert prod2;
        System.debug(prod2);
        
        ProductCatalog pCatalog = new ProductCatalog();
        pCatalog.Name = 'test';
        insert pCatalog;
        
		ProductCategory pc = new ProductCategory();
		pc.Name = 'Clay Blocks';
        pc.CatalogId = pCatalog.Id;
		insert pc;

        ProductCategoryProduct pcp = new ProductCategoryProduct();
        pcp.ProductId = prod.Id;
        pcp.ProductCategoryId = pc.Id;
        insert pcp;
        
        ProductCategoryProduct pcp2 = new ProductCategoryProduct();
        pcp2.ProductId = prod2.Id;
        pcp2.ProductCategoryId = pc.Id;
        insert pcp2;
        
        PromotionTarget pt = new PromotionTarget();
        pt.PromotionId = prom.Id;
        pt.TargetId = pc.Id;
        pt.TargetType = 'ProductCategory';
        pt.AdjustmentType = 'PercentageDiscount';
        pt.AdjustmentPercent = 10.00;
        insert pt;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.CloseDate = System.today();
        opp.StageName = 'Qualification';
        opp.CurrencyIsoCode = 'USD';
        opp.AccountId = acc.Id;
        insert opp;
        
        Order ord = new Order();
        //ord.OpportunityId = opp.Id;
        ord.AccountId = acc.Id;
        ord.Name = 'Test';
        ord.CurrencyIsoCode = 'USD';
        ord.Pricebook2Id = Test.getStandardPricebookId();
        ord.EffectiveDate = System.today();
        ord.Status = 'Draft';
        insert ord;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.CurrencyIsoCode = 'USD';
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.Product2Id = prod.Id;
        pbe.UnitPrice = 100;
        pbe.IsActive = true;
        insert pbe;
        
        PricebookEntry pbe2 = new PricebookEntry();
        pbe2.CurrencyIsoCode = 'USD';
        pbe2.Pricebook2Id = Test.getStandardPricebookId();
        pbe2.Product2Id = prod2.Id;
        pbe2.UnitPrice = 100;
        pbe2.IsActive = true;
        insert pbe2;
        
        OrderItem oli = new OrderItem();
        oli.Product2Id = prod.Id;
        oli.OrderId = ord.Id;
        oli.PricebookEntryId = pbe.Id;
        oli.Quantity = 1;
        oli.UnitPrice = 100;  
        insert oli;
        
        OrderItem oli2 = new OrderItem();
        oli2.Product2Id = prod2.Id;
        oli2.OrderId = ord.Id;
        oli2.PricebookEntryId = pbe2.Id;
        oli2.Quantity = 1;
        oli2.UnitPrice = 100;  
        insert oli2;
        
        /*buacc.Name = 'ANSA Coatings Ltd';
        update buacc;
        
         OrderItem oli3 = new OrderItem();
        oli3.Product2Id = prod2.Id;
        oli3.OrderId = ord.Id;
        oli3.PricebookEntryId = pbe2.Id;
        oli3.Quantity = 1;
        oli3.UnitPrice = 100;  
        insert oli3;
        
        buacc.Name = 'Berger Paints Barbados Ltd';
        update buacc;
        
         OrderItem oli4 = new OrderItem();
        oli4.Product2Id = prod2.Id;
        oli4.OrderId = ord.Id;
        oli4.PricebookEntryId = pbe2.Id;
        oli4.Quantity = 1;
        oli4.UnitPrice = 100;  
        insert oli4;*/
        
        buacc.Name = 'Berger Paints Jamaica Ltd';
        update buacc;
        
         OrderItem oli5 = new OrderItem();
        oli5.Product2Id = prod2.Id;
        oli5.OrderId = ord.Id;
        oli5.PricebookEntryId = pbe2.Id;
        oli5.Quantity = 1;
        oli5.UnitPrice = 100;  
        insert oli5;
        
        /*buacc.Name = 'Sissons Paints Grenada Ltd';
        update buacc;
        
         OrderItem oli6 = new OrderItem();
        oli6.Product2Id = prod2.Id;
        oli6.OrderId = ord.Id;
        oli6.PricebookEntryId = pbe2.Id;
        oli6.Quantity = 1;
        oli6.UnitPrice = 100;  
        insert oli6;*/
    }
    
    @isTest static void testHandler4(){
    	Promotion prom = new Promotion();
        prom.Name = 'Test';
        prom.IsActive = true;
        prom.IsCommercePromotion = true;
        insert prom;
        
        Account buacc = new Account();
        buacc.AMC_Tax__c = 10.00;
        buacc.Name = 'Abel Building Solutions';
        buacc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FAC Account').getRecordTypeId();
        buacc.CurrencyIsoCode = 'USD';
        insert buacc;
        
        Account acc = new Account();
        acc.Name = 'test';
        acc.CurrencyIsoCode = 'USD';
        acc.FAC_Account__c = buacc.Id;
        insert acc;

		Contact cont = new Contact();
        cont.LastName = 'test';
        cont.FirstName = 'test';
        cont.Salutation = 'Mr.';
        cont.Email = 'test@test.com';
        cont.Phone = '12345678901';
        cont.CurrencyIsoCode = 'USD';
        cont.Fax = '12345678901';
        insert cont;
        
        BuyerAccount ba = new BuyerAccount();
        ba.BuyerId = acc.Id;
        ba.Name = 'Test';
        ba.IsActive = true;
        insert ba;
        
        BuyerGroup bg = new BuyerGroup();
        bg.Name = 'test';
        insert bg;
        
        BuyerGroupMember bgm = new BuyerGroupMember();
        bgm.BuyerGroupId = bg.Id;
        bgm.BuyerId = acc.Id;
        insert bgm;
        
        PromotionSegment ps = new PromotionSegment();
        ps.Name = 'test';
        insert ps;
        
        PromotionMarketSegment pms = new PromotionMarketSegment();
        pms.PromotionId = prom.Id;
        pms.PromotionSegmentId = ps.Id;
        insert pms;
        
        PromotionSegmentBuyerGroup psbg = new PromotionSegmentBuyerGroup();
        psbg.BuyerGroupId = bg.Id;
        psbg.PromotionSegmentId = ps.Id;
        insert psbg;
        
        Product2 prod = new Product2();
        prod.name = 'test';
		insert prod;
        
        Product2 prod2 = new Product2();
        prod2.name = 'Shipping cost';
		insert prod2;
        System.debug(prod2);
        
        ProductCatalog pCatalog = new ProductCatalog();
        pCatalog.Name = 'test';
        insert pCatalog;
        
		ProductCategory pc = new ProductCategory();
		pc.Name = 'Clay Blocks';
        pc.CatalogId = pCatalog.Id;
		insert pc;

        ProductCategoryProduct pcp = new ProductCategoryProduct();
        pcp.ProductId = prod.Id;
        pcp.ProductCategoryId = pc.Id;
        insert pcp;
        
        ProductCategoryProduct pcp2 = new ProductCategoryProduct();
        pcp2.ProductId = prod2.Id;
        pcp2.ProductCategoryId = pc.Id;
        insert pcp2;
        
        PromotionTarget pt = new PromotionTarget();
        pt.PromotionId = prom.Id;
        pt.TargetId = pc.Id;
        pt.TargetType = 'ProductCategory';
        pt.AdjustmentType = 'PercentageDiscount';
        pt.AdjustmentPercent = 10.00;
        insert pt;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.CloseDate = System.today();
        opp.StageName = 'Qualification';
        opp.CurrencyIsoCode = 'USD';
        opp.AccountId = acc.Id;
        insert opp;
        
        Order ord = new Order();
        //ord.OpportunityId = opp.Id;
        ord.AccountId = acc.Id;
        ord.Name = 'Test';
        ord.CurrencyIsoCode = 'USD';
        ord.Pricebook2Id = Test.getStandardPricebookId();
        ord.EffectiveDate = System.today();
        ord.Status = 'Draft';
        insert ord;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.CurrencyIsoCode = 'USD';
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.Product2Id = prod.Id;
        pbe.UnitPrice = 100;
        pbe.IsActive = true;
        insert pbe;
        
        PricebookEntry pbe2 = new PricebookEntry();
        pbe2.CurrencyIsoCode = 'USD';
        pbe2.Pricebook2Id = Test.getStandardPricebookId();
        pbe2.Product2Id = prod2.Id;
        pbe2.UnitPrice = 100;
        pbe2.IsActive = true;
        insert pbe2;
        
        OrderItem oli = new OrderItem();
        oli.Product2Id = prod.Id;
        oli.OrderId = ord.Id;
        oli.PricebookEntryId = pbe.Id;
        oli.Quantity = 1;
        oli.UnitPrice = 100;  
        insert oli;
        
        OrderItem oli2 = new OrderItem();
        oli2.Product2Id = prod2.Id;
        oli2.OrderId = ord.Id;
        oli2.PricebookEntryId = pbe2.Id;
        oli2.Quantity = 1;
        oli2.UnitPrice = 100;  
        insert oli2;
        
        /*buacc.Name = 'ANSA Coatings Ltd';
        update buacc;
        
         OrderItem oli3 = new OrderItem();
        oli3.Product2Id = prod2.Id;
        oli3.OrderId = ord.Id;
        oli3.PricebookEntryId = pbe2.Id;
        oli3.Quantity = 1;
        oli3.UnitPrice = 100;  
        insert oli3;
        
        buacc.Name = 'Berger Paints Barbados Ltd';
        update buacc;
        
         OrderItem oli4 = new OrderItem();
        oli4.Product2Id = prod2.Id;
        oli4.OrderId = ord.Id;
        oli4.PricebookEntryId = pbe2.Id;
        oli4.Quantity = 1;
        oli4.UnitPrice = 100;  
        insert oli4;
        
        buacc.Name = 'Berger Paints Jamaica Ltd';
        update buacc;
        
         OrderItem oli5 = new OrderItem();
        oli5.Product2Id = prod2.Id;
        oli5.OrderId = ord.Id;
        oli5.PricebookEntryId = pbe2.Id;
        oli5.Quantity = 1;
        oli5.UnitPrice = 100;  
        insert oli5;*/
        
        buacc.Name = 'Sissons Paints Grenada Ltd';
        update buacc;
        
         OrderItem oli6 = new OrderItem();
        oli6.Product2Id = prod2.Id;
        oli6.OrderId = ord.Id;
        oli6.PricebookEntryId = pbe2.Id;
        oli6.Quantity = 1;
        oli6.UnitPrice = 100;  
        insert oli6;
    }
}