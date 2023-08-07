public class ANSA_InventoryReservationCallout {
    @InvocableMethod(label='OCI Reservations Callout' description='Callout to OCI Reservation endpoint')
    public static void makeCallout(List<InputVariables> inputVariables){
        system.debug(inputVariables);
        
        String locationIdentifier = inputVariables.get(0).locationIdentifier;
        List<Double> quantities = inputVariables.get(0).quantities;
        List<String> skuList = inputVariables.get(0).skuList;
        
        ANSA_InventoryReservationRequest.sendRequest(locationIdentifier, quantities, skuList);
      
        
    }
    
    //Invocable Variables
    public class InputVariables{
        @InvocableVariable
        public String locationIdentifier;
        
        @InvocableVariable
        public List<Double> quantities;
        
        @InvocableVariable
        public List<String> skuList;
    }

}