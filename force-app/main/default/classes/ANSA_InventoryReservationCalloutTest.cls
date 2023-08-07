@isTest
public class ANSA_InventoryReservationCalloutTest {
    @isTest static void makeCallout_Test(){
        
        String locationIdentifier = 'Jamaica';
        List<Double> quantities = new List<Double>{1};
        List<String> skuList = new List<String>{'P567823412313'};
        
        List<ANSA_InventoryReservationCallout.InputVariables> inputVariables = new List<ANSA_InventoryReservationCallout.InputVariables>();
        ANSA_InventoryReservationCallout.InputVariables inputVariable = new ANSA_InventoryReservationCallout.InputVariables();
        inputVariable.locationIdentifier = locationIdentifier;
        inputVariable.quantities = quantities;
        inputVariable.skuList = skuList;
        inputVariables.add(inputVariable);
        
        ANSA_InventoryReservationCallout.makeCallout(inputVariables);
        
    }

}