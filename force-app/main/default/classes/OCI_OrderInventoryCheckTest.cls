@isTest
public class OCI_OrderInventoryCheckTest {
    @isTest static void inventoryCheck_Test(){
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'FAC Account' LIMIT 1];
        Account FACacct = new Account();
        FACacct.RecordTypeId = rt.Id;
        FACacct.Name = 'Test FAC Account';
        FACacct.CurrencyIsoCode = 'TTD';
        insert FACacct;
        
        ProductCatalog catalog = new ProductCatalog();
        catalog.Name = 'Test Class Catalog';
        insert catalog;
        
        ProductCategory category = new ProductCategory();
        category.Name = 'Structural Blocks 140mm (6")';
        category.CatalogId = catalog.Id;
        insert category;
        
        Product2 prod = new Product2();
        prod.Name = 'Test Class Product';
        prod.Family = 'Clay';
        prod.StockKeepingUnit = 'P567823412313';
        prod.ANC_Show_Store__c = true;
        insert prod;
        system.debug(prod);
        
        ProductCategoryProduct categoryProduct = new ProductCategoryProduct();
        categoryProduct.ProductCategoryId = category.Id;
        categoryProduct.ProductId = prod.Id;
        categoryProduct.IsPrimaryCategory = false;
        insert categoryProduct;
        
        Order order = new Order();
        order.AccountId = FACacct.Id;
        order.EffectiveDate = date.valueOf('2023-04-23');
        order.Status = 'Draft';
        order.AMC_Manual_order_creation__c = 'Yes';
        insert order;
        
        OrderItem oItem = new OrderItem();
        oItem.OrderId = order.Id;
        oItem.Product2Id = prod.Id;
        oItem.Quantity = 1;
        oItem.ListPrice = 200.00;
        oItem.UnitPrice = 200.00;
        insert oItem;
        
        List<ANSA_AvailabilityToReserveTrinidadABS.InputVariables> inputVariables = new List<ANSA_AvailabilityToReserveTrinidadABS.InputVariables>();
        ANSA_AvailabilityToReserveTrinidadABS.InputVariables ordId = new ANSA_AvailabilityToReserveTrinidadABS.InputVariables();
        ordId.orderId = order.Id;
        inputVariables.add(ordId);
        
        OCI_OrderInventoryCheck.inventoryCheck(order);
    }

}