public class WS_IntegrationLogs implements Queueable {
    HttpRequest req;
    String reqBody;
    String reqEndpoint;
    String resBody;
    Decimal resStatusCode;
    String sResponse;
    Boolean WSError;
    public WS_IntegrationLogs(String vReqBody, String vReqEndpoint, String vResBody, Decimal vResStatusCode, String vSResponse, Boolean vWSError){
        reqBody = vReqBody;
        reqEndpoint = vReqEndpoint;
        resBody = vResBody;
        resStatusCode = vResStatusCode;
        sResponse = vSResponse;
        WSError = vWSError;
    }
    public void execute(QueueableContext context) {
    	List<Integration_Log__c> lstiLogs = new List<Integration_Log__c>();
        Integration_Log__c iLog = new Integration_Log__c();
        iLog.Request__c = reqBody;
        iLog.Endpoint__c = reqEndpoint;
        iLog.Response__c = resBody.abbreviate(131072);
        iLog.Status_Code__c = resStatusCode;
        iLog.Date__c = date.today();
        iLog.Web_Service_Error__c = WSError;

        lstiLogs.add(iLog);
        
        Database.SaveResult[] sr = Database.insert(lstiLogs, false);
        for(Database.SaveResult result : sr){
            if(!result.isSuccess()){
                for(Database.Error err : result.getErrors()){
                    System.debug('Error: ' + err.getStatusCode() + ' : ' + err.getMessage());
                    System.debug('Fields that affected this error: ' + err.getFields());
                }
            }
        }
    }
}