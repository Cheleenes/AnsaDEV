@isTest
public class ANSA_AvailabilityToReserveExportTest {
    @isTest static void compareQuantities_Test(){
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'FAC Account' LIMIT 1];
        Account FACacct = new Account();
        FACacct.RecordTypeId = rt.Id;
        FACacct.Name = 'Test FAC Account';
        FACacct.CurrencyIsoCode = 'TTD';
        insert FACacct;
        
        Product2 prod = new Product2();
        prod.Name = 'Test Class Product';
        prod.Family = 'Clay';
        prod.StockKeepingUnit = 'P567823412313';
        insert prod;
        system.debug(prod);
        
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
        
        List<String> SKUList = new List<String>{'P567823412313'};
        List<Double> QuantiiesList = new List<Double>{1};
        List<String> OCISKUList = new List<String>{'P567823412313'};
        List<String> OCISKUList2 = new List<String>{'P567823412313'};
        List<Double> OCIQuantitiesList = new List<Double>(10);
        List<Double> OCIQuantitiesList2 = new List<Double>(10);
        String priorityWarehouse = 'Jamaica';
        String priorityWarehouse2 = 'Jamaica2';
        
        List<ANSA_AvailabilityToReserveExport.InputVariables> inputVariables = new List<ANSA_AvailabilityToReserveExport.InputVariables>();
        ANSA_AvailabilityToReserveExport.InputVariables input = new ANSA_AvailabilityToReserveExport.InputVariables();
        input.SKUList = SKUList;
        input.QuantiiesList = QuantiiesList;
        input.OCISKUList = OCISKUList;
        input.OCISKUList2 = OCISKUList2;
        input.OCIQuantitiesList =OCIQuantitiesList;
        input.OCIQuantitiesList2 =OCIQuantitiesList2;
        input.orderId = order.Id;
        input.priorityWarehouse = priorityWarehouse;
        input.priorityWarehouse2 = priorityWarehouse2;
        inputVariables.add(input);
        
        ANSA_AvailabilityToReserveExport.compareQuantities(inputVariables);
    }

}