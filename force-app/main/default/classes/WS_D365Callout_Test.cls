@isTest
public class WS_D365Callout_Test {
    @TestSetup static void testUpdateCustomerSetup() {
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
        cont.Phone = '12345678902';
        update cont;
        
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
    }
	@isTest static void testUpdateCustomer(){
		System.debug('testUpdatecustomer---------------------------------------------------------------------------------------------------');
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
        Test.startTest();
        Account acc = [Select Id, InvoiceAccount__c, PartyType__c, OrganizationName__c, NameAlias__c, FirstName, DataAreaId__c, CustomerAccount__c, Financial_Dimensions__c,
                           Name, PersonEmail, Phone, DeliveryAddressDescription__c, ShippingCity, BillingStreet, FAC_Account__c, CurrencyIsoCode, FAC_Account__r.DataAreaId__c, ShippingStreet,
                           FAC_Account__r.CurrencyIsoCode, SalesSegmentId__c, PaymentMethod__c, SalesCurrencyCode__c, LanguageId__c, DefaultDimensionDisplayValue__c, ItemCustomerGroupId__c,
                           FAC_Account__r.Country_Code__c, D365Id__c, ANSA_DataLoader__c, ANSA_IsExport__c, RecordtypeId
                      From Account 
                      Where Name = 'Test'
                      Limit 1];
        Contact cont = [Select Id, FirstName, LastName, Phone, Email From Contact Where AccountId =: acc.Id Order By CreatedDate DESC Limit 1];
        WS_D365Callout.updateCustomers(acc,cont);
        Test.stopTest();
    }
    
    	@isTest static void testUpdatePersonCustomer(){
		System.debug('testUpdatecustomer---------------------------------------------------------------------------------------------------');
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
        Test.startTest();
        Account acc = [Select Id, InvoiceAccount__c, PartyType__c, OrganizationName__c, NameAlias__c, DataAreaId__c, CustomerAccount__c, Financial_Dimensions__c,
                           FirstName, LastName, PersonEmail, Phone, DeliveryAddressDescription__c, ShippingCity, BillingStreet, FAC_Account__c, CurrencyIsoCode, FAC_Account__r.DataAreaId__c, ShippingStreet,
                           FAC_Account__r.CurrencyIsoCode, SalesSegmentId__c, PaymentMethod__c, SalesCurrencyCode__c, LanguageId__c, DefaultDimensionDisplayValue__c, ItemCustomerGroupId__c,
                           FAC_Account__r.Country_Code__c, D365Id__c, ANSA_DataLoader__c, ANSA_IsExport__c, RecordtypeId
                           From Account 
                      	   Where LastName = 'TestPAC'
                      	   Limit 1];
        WS_D365Callout.updateCustomers(acc);
        Test.stopTest();
    }
    
    @isTest static void testUpdateOrders(){
		System.debug('testUpdateOrders---------------------------------------------------------------------------------------------------');
		Integration_Data__mdt cfsWSToken = Integration_Data__mdt.getInstance('Token');
        String sEndpointToken = WS_D365Callout.isOrgSandbox() ? cfsWSToken.Endpoint_Test__c : cfsWSToken.Endpoint__c;
        sEndpointToken = sEndpointToken.replace('{tenantId}', cfsWSToken.Tenant_Id__c);
        String sResponseToken = '{"token_type":"Bearer","expires_in":"3599","ext_expires_in":"3599","expires_on":"1683146550","not_before":"1683142650","resource":"https://aml-consmfg1.sandbox.operations.dynamics.com/","access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyIsImtpZCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyJ9.eyJhdWQiOiJodHRwczovL2FtbC1jb25zbWZnMS5zYW5kYm94Lm9wZXJhdGlvbnMuZHluYW1pY3MuY29tLyIsImlzcyI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0LzQ0OTljZmExLTFhMWQtNDdjOC1hNzJmLWY2YWUzOTY1MTk1MS8iLCJpYXQiOjE2ODMxNDI2NTAsIm5iZiI6MTY4MzE0MjY1MCwiZXhwIjoxNjgzMTQ2NTUwLCJhaW8iOiJFMlpnWU9Cd1R0V1kvTkkydDhDMFVXYTZSWGM4QUE9PSIsImFwcGlkIjoiMmZhZDc0N2EtNjEwMi00OTkzLTk4ODgtMjRlYjRlOTIwN2JmIiwiYXBwaWRhY3IiOiIxIiwiaWRwIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvNDQ5OWNmYTEtMWExZC00N2M4LWE3MmYtZjZhZTM5NjUxOTUxLyIsIm9pZCI6IjI1YTUyZjFkLWM1MzAtNGU4Ny1iNTBlLTE3YTdiZjc4NDI1ZiIsInJoIjoiMC5BUWNBb2MtWlJCMGF5RWVuTF9hdU9XVVpVUlVBQUFBQUFBQUF3QUFBQUFBQUFBQUhBQUEuIiwicm9sZXMiOlsiQ29ubmVjdG9yLkZ1bGxBY2Nlc3MiXSwic3ViIjoiMjVhNTJmMWQtYzUzMC00ZTg3LWI1MGUtMTdhN2JmNzg0MjVmIiwidGlkIjoiNDQ5OWNmYTEtMWExZC00N2M4LWE3MmYtZjZhZTM5NjUxOTUxIiwidXRpIjoieGkzbVlCcUJVa2EyQk5JRTdNUjdBQSIsInZlciI6IjEuMCJ9.fYbKvheQKPM9YfQZ_BG_TWpd3RdjOhpP7qUM0Q9wzYbX3PCpNc8qSAn4F2e1s1HLo8rT8ugouX_YBC0oCQhH0BpBo_nwv9LoFjmLIGHDmIv4LWqylZlaxXOtWoZrr6U74l-jF_iiDOADI-QU1OVJpDMTiZEdp0GKsYvXMwqfeGA6M-9pvrJ8NOJSM2r_P9LMeKTsD1AtjuUA5x5mI7fsyluA976QWGxeve6hGwMxilhpERosqH-b8zj13cuDw1xeZbqNccffn5r7UnDbYZLNI5xuZreAHhr_9g1_WLBe8UHV-wqWCGgTtRbAqGC9Nm1kM5TajdWIN-pTtnZDtEzYrQ"}';
		Single_CalloutMock sCMToken = new Single_CalloutMock(200,
                                                          'Complete',
                                                          sResponseToken,
                                                          null);        
        Integration_Data__mdt cfsWS = Integration_Data__mdt.getInstance('Sales_Order');
        String sEndpoint = WS_D365Callout.isOrgSandbox() ? cfsWS.Endpoint_Test__c : cfsWS.Endpoint__c;
        String sResponse = '{ "dmrDataAreaID": "e035", "dmrRecId": 5639036077, "dmrSalesOrderNumber": "E035SO0085566", "dmrCRM_QuoteNumber": "CRM_QN_00001", "dmrSuccess": true, "dmrActionResultText": "Sales Order Header record update success", "dmrErrorText": "" }';
        Single_CalloutMock sCM = new Single_CalloutMock(200,
                                                          'Complete',
                                                          sResponse,
                                                          null);
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put(sEndpoint, sCM);
        endpoint2TestResp.put(sEndpointtoken, sCMToken);
        Test.setMock(HttpCalloutMock.class, new CalloutMock(endpoint2TestResp));
        Test.startTest();
        
        WS_D365Callout.updateOrders(new Order(), new List<OrderItem>{new OrderItem()});
        Test.stopTest();
    }
    
    @isTest static void testUpdateCredit(){
		System.debug('testCustomer_Get---------------------------------------------------------------------------------------------------');
		Integration_Data__mdt cfsWSToken = Integration_Data__mdt.getInstance('Token');
        String sEndpointToken = WS_D365Callout.isOrgSandbox() ? cfsWSToken.Endpoint_Test__c : cfsWSToken.Endpoint__c;
        sEndpointToken = sEndpointToken.replace('{tenantId}', cfsWSToken.Tenant_Id__c);
        String sResponseToken = '{"token_type":"Bearer","expires_in":"3599","ext_expires_in":"3599","expires_on":"1683146550","not_before":"1683142650","resource":"https://aml-consmfg1.sandbox.operations.dynamics.com/","access_token":"eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyIsImtpZCI6Ii1LSTNROW5OUjdiUm9meG1lWm9YcWJIWkdldyJ9.eyJhdWQiOiJodHRwczovL2FtbC1jb25zbWZnMS5zYW5kYm94Lm9wZXJhdGlvbnMuZHluYW1pY3MuY29tLyIsImlzcyI6Imh0dHBzOi8vc3RzLndpbmRvd3MubmV0LzQ0OTljZmExLTFhMWQtNDdjOC1hNzJmLWY2YWUzOTY1MTk1MS8iLCJpYXQiOjE2ODMxNDI2NTAsIm5iZiI6MTY4MzE0MjY1MCwiZXhwIjoxNjgzMTQ2NTUwLCJhaW8iOiJFMlpnWU9Cd1R0V1kvTkkydDhDMFVXYTZSWGM4QUE9PSIsImFwcGlkIjoiMmZhZDc0N2EtNjEwMi00OTkzLTk4ODgtMjRlYjRlOTIwN2JmIiwiYXBwaWRhY3IiOiIxIiwiaWRwIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvNDQ5OWNmYTEtMWExZC00N2M4LWE3MmYtZjZhZTM5NjUxOTUxLyIsIm9pZCI6IjI1YTUyZjFkLWM1MzAtNGU4Ny1iNTBlLTE3YTdiZjc4NDI1ZiIsInJoIjoiMC5BUWNBb2MtWlJCMGF5RWVuTF9hdU9XVVpVUlVBQUFBQUFBQUF3QUFBQUFBQUFBQUhBQUEuIiwicm9sZXMiOlsiQ29ubmVjdG9yLkZ1bGxBY2Nlc3MiXSwic3ViIjoiMjVhNTJmMWQtYzUzMC00ZTg3LWI1MGUtMTdhN2JmNzg0MjVmIiwidGlkIjoiNDQ5OWNmYTEtMWExZC00N2M4LWE3MmYtZjZhZTM5NjUxOTUxIiwidXRpIjoieGkzbVlCcUJVa2EyQk5JRTdNUjdBQSIsInZlciI6IjEuMCJ9.fYbKvheQKPM9YfQZ_BG_TWpd3RdjOhpP7qUM0Q9wzYbX3PCpNc8qSAn4F2e1s1HLo8rT8ugouX_YBC0oCQhH0BpBo_nwv9LoFjmLIGHDmIv4LWqylZlaxXOtWoZrr6U74l-jF_iiDOADI-QU1OVJpDMTiZEdp0GKsYvXMwqfeGA6M-9pvrJ8NOJSM2r_P9LMeKTsD1AtjuUA5x5mI7fsyluA976QWGxeve6hGwMxilhpERosqH-b8zj13cuDw1xeZbqNccffn5r7UnDbYZLNI5xuZreAHhr_9g1_WLBe8UHV-wqWCGgTtRbAqGC9Nm1kM5TajdWIN-pTtnZDtEzYrQ"}';
		Single_CalloutMock sCMToken = new Single_CalloutMock(200,
                                                          'Complete',
                                                          sResponseToken,
                                                          null);        
        Integration_Data__mdt cfsWS = Integration_Data__mdt.getInstance('Customer_Get');
        String sEndpoint = WS_D365Callout.isOrgSandbox() ? cfsWS.Endpoint_Test__c : cfsWS.Endpoint__c;
        String sResponse = '{"dmDataAreaID":"e001","dmrRecId":5638025076,"dmCustomerAccount":"E001_0013C00000oxZOJ","dmInvoiceAccount":"E001_0013C00000oxZOJ","dmPartyType":"Organization","dmOrganizationName":"Test TTD","dmNameAlias":"integration test","dmPersonFirstName":"","dmPersonLastName":"","dmPrimaryContactEmail":"isifuentes@yopmail.com","dmPrimaryContactPhone":"871971708","dmDeliveryAddressDescription":"","dmDeliveryAddressCity":"","dmInvoiceAddressStreet":"","dmCustomerGroupId":"LGRP","dmSalesSegmentId":"AUTOMOTIVE","dmPaymentMethod":"CHEQUE","dmSalesCurrencyCode":"TTD","dmLanguageId":"en-US","dmDefaultDimensionDisplayValue":"-----CC001-DP261-DV001-IC001--RC001--","dmrSuccess":true,"dmrActionResultText":"Customer record find success","dmrMessageText":"Successfully found Customer, DataAreaId: e001, Customer:E001_0013C00000oxZOJ, PaymentTermsDueDate: 6/8/2023, PaymentTermsDueDateDays:0, PaymTermId: ","dmrCreditBalanceMST":0.0,"dmrCreditBalanceCur":0.0,"dmrCreditLimitMST":0.0,"dmrCreditLimitCur":0.0,"dmrIsMandatoryCreditLimit":true,"dmrTermsOfPayment":"","dmrCRM_SalesforceId":"","dmrIsWithInCreditTerms":false,"dmrOldestPendingInvoiceDate":"1900-01-01T12:00:00","dmrAvailableCreditBalanceMST":0.0,"dmrOpenSalesOrdersAmountMST":0.0}';
        Single_CalloutMock sCM = new Single_CalloutMock(200,
                                                          'Complete',
                                                          sResponse,
                                                          null);
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put(sEndpoint, sCM);
        endpoint2TestResp.put(sEndpointtoken, sCMToken);
        Test.setMock(HttpCalloutMock.class, new CalloutMock(endpoint2TestResp));
        Test.startTest();
        
        Account acc = [Select Id, InvoiceAccount__c, PartyType__c, OrganizationName__c, NameAlias__c, FirstName, DataAreaId__c, CustomerAccount__c, Financial_Dimensions__c,
                           Name, PersonEmail, Phone, DeliveryAddressDescription__c, ShippingCity, BillingStreet, FAC_Account__c, CurrencyIsoCode, FAC_Account__r.DataAreaId__c, ShippingStreet,
                           FAC_Account__r.CurrencyIsoCode, SalesSegmentId__c, PaymentMethod__c, SalesCurrencyCode__c, LanguageId__c, DefaultDimensionDisplayValue__c, ItemCustomerGroupId__c,
                           FAC_Account__r.Country_Code__c, D365Id__c, ANSA_DataLoader__c, ANSA_IsExport__c, RecordtypeId
                      From Account 
                      Where Name = 'Test'
                      Limit 1];
        
        WS_D365Callout.customerGet(acc, 10.00);
        Test.stopTest();
    }
}