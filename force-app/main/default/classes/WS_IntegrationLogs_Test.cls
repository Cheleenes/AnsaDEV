@isTest
public class WS_IntegrationLogs_Test {
    @isTest static void testLogs(){
    	WS_IntegrationLogs iL = new WS_IntegrationLogs('req.getBody()', 'req.getEndpoint()', 'res.getBody()', 200, 'sResponse', true);
        System.enqueueJob(iL);
    }
}