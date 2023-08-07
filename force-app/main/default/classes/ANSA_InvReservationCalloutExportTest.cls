@isTest
public class ANSA_InvReservationCalloutExportTest {
    @isTest static void makeCallout_Test(){
        String locationIdentifier = 'Jamaica';
        List<Double> quantities = new List<Double>{1};
        List<String> skuList = new List<String>{'P567823412313'};
        String locationIdentifier2 = 'Barbados';
        List<Double> quantities2 = new List<Double>{1};
        List<String> skuList2 = new List<String>{'P567823412314'};
        
        List<ANSA_InventoryReservationCalloutExport.InputVariables> inputVariables = new List<ANSA_InventoryReservationCalloutExport.InputVariables>();
        ANSA_InventoryReservationCalloutExport.InputVariables inputVariable = new ANSA_InventoryReservationCalloutExport.InputVariables();
        inputVariable.locationIdentifier = locationIdentifier;
        inputVariable.quantities = quantities;
        inputVariable.skuList = skuList;
        inputVariable.locationIdentifier2 = locationIdentifier2;
        inputVariable.quantities2 = quantities2;
        inputVariable.skuList2 = skuList2;
        inputVariables.add(inputVariable);
        
        ANSA_InventoryReservationCalloutExport.makeCallout(inputVariables);
        
    }

}