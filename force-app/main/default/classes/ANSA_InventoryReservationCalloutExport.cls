public class ANSA_InventoryReservationCalloutExport {
    
     @InvocableMethod(label='OCI Reservations Callout Export' description='Callout to OCI Reservation endpoint')
    public static void makeCallout(List<InputVariables> inputVariables){
        system.debug(inputVariables);
        
        String locationIdentifier = inputVariables.get(0).locationIdentifier;
        String locationIdentifier2 = inputVariables.get(0).locationIdentifier2;
        List<Double> quantities = inputVariables.get(0).quantities;
        List<String> skuList = inputVariables.get(0).skuList;
        List<Double> quantities2 = inputVariables.get(0).quantities2;
        List<String> skuList2 = inputVariables.get(0).skuList2;
        
        ANSA_InventoryReservationRequestExport.sendRequest(locationIdentifier, locationIdentifier2, quantities, skuList, quantities2, skuList2);
      
        
    }
    
    //Invocable Variables
    public class InputVariables{
        @InvocableVariable
        public String locationIdentifier;
        
        @InvocableVariable
        public String locationIdentifier2;
        
        @InvocableVariable
        public List<Double> quantities;
        
        @InvocableVariable
        public List<String> skuList;
        
        @InvocableVariable
        public List<Double> quantities2;
        
        @InvocableVariable
        public List<String> skuList2;
    }

}