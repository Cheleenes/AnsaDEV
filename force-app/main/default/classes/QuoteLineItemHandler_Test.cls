@isTest
public class QuoteLineItemHandler_Test {
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
		pc.Name = 'test';
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
        
        Quote qt = new Quote();
        qt.OpportunityId = opp.Id;
        qt.Name = 'Test';
        qt.ExpirationDate = System.today() + 30;
        qt.CurrencyIsoCode = 'USD';
        qt.Pricebook2Id = Test.getStandardPricebookId();
        insert qt;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.CurrencyIsoCode = 'USD';
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.Product2Id = prod.Id;
        pbe.UnitPrice = 100;
        pbe.IsActive = true;
        insert pbe;
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.Product2Id = prod.Id;
        qli.QuoteId = qt.Id;
        qli.PricebookEntryId = pbe.Id;
        qli.Quantity = 1;
        qli.UnitPrice = 100;  
        insert qli;
        
        QuoteLineItem qli2 = new QuoteLineItem();
        qli2.Product2Id = prod2.Id;
        qli2.QuoteId = qt.Id;
        qli2.PricebookEntryId = pbe.Id;
        qli2.Quantity = 1;
        qli2.UnitPrice = 100;  
        insert qli2;
        
        buacc.Name = 'Sissons Paints Grenada Ltd';
        update buacc;
        
        QuoteLineItem qli6 = new QuoteLineItem();
        qli6.Product2Id = prod2.Id;
        qli6.QuoteId = qt.Id;
        qli6.PricebookEntryId = pbe.Id;
        qli6.Quantity = 1;
        qli6.UnitPrice = 100;  
        insert qli6;
        
        
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
        
        ProductCatalog pCatalog = new ProductCatalog();
        pCatalog.Name = 'test';
        insert pCatalog;
        
		ProductCategory pc = new ProductCategory();
		pc.Name = 'test';
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
        
        Quote qt = new Quote();
        qt.OpportunityId = opp.Id;
        qt.Name = 'Test';
        qt.ExpirationDate = System.today() + 30;
        qt.CurrencyIsoCode = 'USD';
        qt.Pricebook2Id = Test.getStandardPricebookId();
        insert qt;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.CurrencyIsoCode = 'USD';
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.Product2Id = prod.Id;
        pbe.UnitPrice = 100;
        pbe.IsActive = true;
        insert pbe;
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.Product2Id = prod.Id;
        qli.QuoteId = qt.Id;
        qli.PricebookEntryId = pbe.Id;
        qli.Quantity = 1;
        qli.UnitPrice = 100;  
        insert qli;
        
        QuoteLineItem qli2 = new QuoteLineItem();
        qli2.Product2Id = prod2.Id;
        qli2.QuoteId = qt.Id;
        qli2.PricebookEntryId = pbe.Id;
        qli2.Quantity = 1;
        qli2.UnitPrice = 100;  
        insert qli2;
        
        buacc.Name = 'ANSA Coatings Ltd';
        update buacc;
        
        QuoteLineItem qli3 = new QuoteLineItem();
        qli3.Product2Id = prod2.Id;
        qli3.QuoteId = qt.Id;
        qli3.PricebookEntryId = pbe.Id;
        qli3.Quantity = 1;
        qli3.UnitPrice = 100;  
        insert qli3;
        
        /*buacc.Name = 'Berger Paints Barbados Ltd';
        update buacc;
        
        QuoteLineItem qli4 = new QuoteLineItem();
        qli4.Product2Id = prod2.Id;
        qli4.QuoteId = qt.Id;
        qli4.PricebookEntryId = pbe.Id;
        qli4.Quantity = 1;
        qli4.UnitPrice = 100;  
        insert qli4;
        
        buacc.Name = 'Berger Paints Jamaica Ltd';
        update buacc;
        
        QuoteLineItem qli5 = new QuoteLineItem();
        qli5.Product2Id = prod2.Id;
        qli5.QuoteId = qt.Id;
        qli5.PricebookEntryId = pbe.Id;
        qli5.Quantity = 1;
        qli5.UnitPrice = 100;  
        insert qli5;
        
        buacc.Name = 'Sissons Paints Grenada Ltd';
        update buacc;
        
        QuoteLineItem qli6 = new QuoteLineItem();
        qli6.Product2Id = prod2.Id;
        qli6.QuoteId = qt.Id;
        qli6.PricebookEntryId = pbe.Id;
        qli6.Quantity = 1;
        qli6.UnitPrice = 100;  
        insert qli6;*/
        
        
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
        
        ProductCatalog pCatalog = new ProductCatalog();
        pCatalog.Name = 'test';
        insert pCatalog;
        
		ProductCategory pc = new ProductCategory();
		pc.Name = 'test';
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
        
        Quote qt = new Quote();
        qt.OpportunityId = opp.Id;
        qt.Name = 'Test';
        qt.ExpirationDate = System.today() + 30;
        qt.CurrencyIsoCode = 'USD';
        qt.Pricebook2Id = Test.getStandardPricebookId();
        insert qt;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.CurrencyIsoCode = 'USD';
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.Product2Id = prod.Id;
        pbe.UnitPrice = 100;
        pbe.IsActive = true;
        insert pbe;
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.Product2Id = prod.Id;
        qli.QuoteId = qt.Id;
        qli.PricebookEntryId = pbe.Id;
        qli.Quantity = 1;
        qli.UnitPrice = 100;  
        insert qli;
        
        QuoteLineItem qli2 = new QuoteLineItem();
        qli2.Product2Id = prod2.Id;
        qli2.QuoteId = qt.Id;
        qli2.PricebookEntryId = pbe.Id;
        qli2.Quantity = 1;
        qli2.UnitPrice = 100;  
        insert qli2;
        
        /*buacc.Name = 'ANSA Coatings Ltd';
        update buacc;
        
        QuoteLineItem qli3 = new QuoteLineItem();
        qli3.Product2Id = prod2.Id;
        qli3.QuoteId = qt.Id;
        qli3.PricebookEntryId = pbe.Id;
        qli3.Quantity = 1;
        qli3.UnitPrice = 100;  
        insert qli3;*/
        
        buacc.Name = 'Berger Paints Barbados Ltd';
        update buacc;
        
        QuoteLineItem qli4 = new QuoteLineItem();
        qli4.Product2Id = prod2.Id;
        qli4.QuoteId = qt.Id;
        qli4.PricebookEntryId = pbe.Id;
        qli4.Quantity = 1;
        qli4.UnitPrice = 100;  
        insert qli4;
        
        /*buacc.Name = 'Berger Paints Jamaica Ltd';
        update buacc;
        
        QuoteLineItem qli5 = new QuoteLineItem();
        qli5.Product2Id = prod2.Id;
        qli5.QuoteId = qt.Id;
        qli5.PricebookEntryId = pbe.Id;
        qli5.Quantity = 1;
        qli5.UnitPrice = 100;  
        insert qli5;
        
        buacc.Name = 'Sissons Paints Grenada Ltd';
        update buacc;
        
        QuoteLineItem qli6 = new QuoteLineItem();
        qli6.Product2Id = prod2.Id;
        qli6.QuoteId = qt.Id;
        qli6.PricebookEntryId = pbe.Id;
        qli6.Quantity = 1;
        qli6.UnitPrice = 100;  
        insert qli6;*/
        
        
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
        
        ProductCatalog pCatalog = new ProductCatalog();
        pCatalog.Name = 'test';
        insert pCatalog;
        
		ProductCategory pc = new ProductCategory();
		pc.Name = 'test';
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
        
        Quote qt = new Quote();
        qt.OpportunityId = opp.Id;
        qt.Name = 'Test';
        qt.ExpirationDate = System.today() + 30;
        qt.CurrencyIsoCode = 'USD';
        qt.Pricebook2Id = Test.getStandardPricebookId();
        insert qt;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.CurrencyIsoCode = 'USD';
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.Product2Id = prod.Id;
        pbe.UnitPrice = 100;
        pbe.IsActive = true;
        insert pbe;
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.Product2Id = prod.Id;
        qli.QuoteId = qt.Id;
        qli.PricebookEntryId = pbe.Id;
        qli.Quantity = 1;
        qli.UnitPrice = 100;  
        insert qli;
        
        QuoteLineItem qli2 = new QuoteLineItem();
        qli2.Product2Id = prod2.Id;
        qli2.QuoteId = qt.Id;
        qli2.PricebookEntryId = pbe.Id;
        qli2.Quantity = 1;
        qli2.UnitPrice = 100;  
        insert qli2;
        
        /*buacc.Name = 'ANSA Coatings Ltd';
        update buacc;
        
        QuoteLineItem qli3 = new QuoteLineItem();
        qli3.Product2Id = prod2.Id;
        qli3.QuoteId = qt.Id;
        qli3.PricebookEntryId = pbe.Id;
        qli3.Quantity = 1;
        qli3.UnitPrice = 100;  
        insert qli3;
        
        buacc.Name = 'Berger Paints Barbados Ltd';
        update buacc;
        
        QuoteLineItem qli4 = new QuoteLineItem();
        qli4.Product2Id = prod2.Id;
        qli4.QuoteId = qt.Id;
        qli4.PricebookEntryId = pbe.Id;
        qli4.Quantity = 1;
        qli4.UnitPrice = 100;  
        insert qli4;*/
        
        buacc.Name = 'Berger Paints Jamaica Ltd';
        update buacc;
        
        QuoteLineItem qli5 = new QuoteLineItem();
        qli5.Product2Id = prod2.Id;
        qli5.QuoteId = qt.Id;
        qli5.PricebookEntryId = pbe.Id;
        qli5.Quantity = 1;
        qli5.UnitPrice = 100;  
        insert qli5;
        
        /*buacc.Name = 'Sissons Paints Grenada Ltd';
        update buacc;
        
        QuoteLineItem qli6 = new QuoteLineItem();
        qli6.Product2Id = prod2.Id;
        qli6.QuoteId = qt.Id;
        qli6.PricebookEntryId = pbe.Id;
        qli6.Quantity = 1;
        qli6.UnitPrice = 100;  
        insert qli6;*/
        
        
    }
}