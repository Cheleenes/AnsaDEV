@isTest
public class AccountTriggerHandler_Test {
	@isTest 
    static void testUpdateCustomer() {
		Integration_Data__mdt cfsWSToken = Integration_Data__mdt.getInstance('Token');
        String sEndpointToken = WS_D365Callout.isOrgSandbox() ? cfsWSToken.Endpoint_Test__c : cfsWSToken.Endpoint__c;
        sEndpointToken = sEndpointToken.replace('{tenantId}', cfsWSToken.Tenant_Id__c);
        String sResponseToken = '{"token_type":"Bearer","expires_in":"3599","ext_expires_in":"3599","expires_on":"1683146550","not_before":"1683142650","resource":"https://aml-consmfg1.sandbox.operations.dynamics.com/","access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyIsImtpZCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyJ9.eyJhdWQiOiJodHRwczovL2FtbC1jb25zbWZnMS5zYW5kYm94Lm9wZXJhdGlvbnMuZHluYW1pY3MuY29tLyIsImlzcyI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0LzQ0OTljZmExLTFhMWQtNDdjOC1hNzJmLWY2YWUzOTY1MTk1MS8iLCJpYXQiOjE2ODMxNDI2NTAsIm5iZiI6MTY4MzE0MjY1MCwiZXhwIjoxNjgzMTQ2NTUwLCJhaW8iOiJFMlpnWU9Cd1R0V1kvTkkydDhDMFVXYTZSWGM4QUE9PSIsImFwcGlkIjoiMmZhZDc0N2EtNjEwMi00OTkzLTk4ODgtMjRlYjRlOTIwN2JmIiwiYXBwaWRhY3IiOiIxIiwiaWRwIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvNDQ5OWNmYTEtMWExZC00N2M4LWE3MmYtZjZhZTM5NjUxOTUxLyIsIm9pZCI6IjI1YTUyZjFkLWM1MzAtNGU4Ny1iNTBlLTE3YTdiZjc4NDI1ZiIsInJoIjoiMC5BUWNBb2MtWlJCMGF5RWVuTF9hdU9XVVpVUlVBQUFBQUFBQUF3QUFBQUFBQUFBQUhBQUEuIiwicm9sZXMiOlsiQ29ubmVjdG9yLkZ1bGxBY2Nlc3MiXSwic3ViIjoiMjVhNTJmMWQtYzUzMC00ZTg3LWI1MGUtMTdhN2JmNzg0MjVmIiwidGlkIjoiNDQ5OWNmYTEtMWExZC00N2M4LWE3MmYtZjZhZTM5NjUxOTUxIiwidXRpIjoieGkzbVlCcUJVa2EyQk5JRTdNUjdBQSIsInZlciI6IjEuMCJ9.fYbKvheQKPM9YfQZ_BG_TWpd3RdjOhpP7qUM0Q9wzYbX3PCpNc8qSAn4F2e1s1HLo8rT8ugouX_YBC0oCQhH0BpBo_nwv9LoFjmLIGHDmIv4LWqylZlaxXOtWoZrr6U74l-jF_iiDOADI-QU1OVJpDMTiZEdp0GKsYvXMwqfeGA6M-9pvrJ8NOJSM2r_P9LMeKTsD1AtjuUA5x5mI7fsyluA976QWGxeve6hGwMxilhpERosqH-b8zj13cuDw1xeZbqNccffn5r7UnDbYZLNI5xuZreAHhr_9g1_WLBe8UHV-wqWCGgTtRbAqGC9Nm1kM5TajdWIN-pTtnZDtEzYrQ"}';
		Single_CalloutMock sCMToken = new Single_CalloutMock(200,
                                                          'Complete',
                                                          sResponseToken,
                                                          null);        
        Integration_Data__mdt cfsWS = Integration_Data__mdt.getInstance('Update_Customer');
        String sEndpoint = WS_D365Callout.isOrgSandbox() ? cfsWS.Endpoint_Test__c : cfsWS.Endpoint__c;
        String sResponse = '{"dmrDataAreaID": "e035", "dmrRecId": 5637148510, "dmrCustomerAccount": "E035_C000002", "dmrSuccess": true, "dmrActionResultText": "Customer record update success", "dmrErrorText": ""}';
        Single_CalloutMock sCM = new Single_CalloutMock(200,
                                                          'Complete',
                                                          sResponse,
                                                          null);
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put(sEndpoint, sCM);
        endpoint2TestResp.put(sEndpointtoken, sCMToken);
        Test.setMock(HttpCalloutMock.class, new CalloutMock(endpoint2TestResp));
        
        Account parentAcc = new Account();
        parentAcc.Name = 'Parent Acc';
        parentAcc.DataAreaId__c = 'E001';
        parentAcc.CurrencyIsoCode = 'TTD';
        parentAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FAC Account').getRecordTypeId();
        insert parentAcc;
        
        Account acc  = new Account();
        acc.Name = 'Test';
        acc.FAC_Account__c = parentAcc.Id;
        acc.NameAlias__c = 'test';
        acc.ShippingStreet = '';
        acc.ShippingCity = '';
        acc.BillingStreet = '';
        acc.ItemCustomerGroupId__c = '';
        acc.SalesSegmentId__c = '';
        acc.PaymentMethod__c = '';
        insert acc;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test';
        cont.Salutation = 'Mr.';
        cont.LastName = 'Test';
        cont.Email = 'Test@test.test';
        cont.Phone = '12345678901';
        cont.AccountId = acc.Id;
        insert cont;
        
        Account accPAC  = new Account();
        accPAC.FirstName = 'Test';
        accPAC.LastName = 'TestPAC';
        accPAC.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        accPAC.FAC_Account__c = parentAcc.Id;
        accPAC.NameAlias__c = 'test';
        accPAC.ShippingStreet = '';
        accPAC.ShippingCity = '';
        accPAC.BillingStreet = 'test';
        accPAC.BillingCity = 'test';
        accPAC.BillingCountry = 'test';
        accPAC.BillingPostalCode = '123345';
        accPAC.BillingState = 'test';
        accPAC.ItemCustomerGroupId__c = '';
        accPAC.SalesSegmentId__c = '';
        accPAC.PaymentMethod__c = '';
        insert accPAC;
         
        cont.FirstName = 'Test2';
        update cont;
    }
}