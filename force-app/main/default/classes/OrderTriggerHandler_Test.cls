@isTest
public class OrderTriggerHandler_Test {
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
        Integration_Data__mdt cfsWSOrder = Integration_Data__mdt.getInstance('Sales_Order');
        String sEndpointOrder = WS_D365Callout.isOrgSandbox() ? cfsWSOrder.Endpoint_Test__c : cfsWSOrder.Endpoint__c;
        String sResponseOrder = '{ "dmrDataAreaID": "e035", "dmrRecId": 5639036077, "dmrSalesOrderNumber": "E035SO0085566", "dmrCRM_QuoteNumber": "CRM_QN_00001", "dmrSuccess": true, "dmrActionResultText": "Sales Order Header record update success", "dmrErrorText": "" }';
        Single_CalloutMock sCMOrder = new Single_CalloutMock(200,
                                                          'Complete',
                                                          sResponseOrder,
                                                          null);
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put(sEndpointOrder, sCMOrder);
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
        acc.CurrencyIsoCode = 'TTD';
        insert acc;
        
        Contact cont = new Contact();
        cont.FirstName = 'Test';
        cont.Salutation = 'Mr.';
        cont.LastName = 'Test';
        cont.Email = 'Test@test.test';
        cont.Phone = '12345678901';
        cont.AccountId = acc.Id;
        insert cont;
        
        Order ord = new Order();
        ord.ANSA_Ready_for_D365__c = true;
        ord.AccountId = acc.Id;
        //ord.FACAccount__c = parentAcc.Id;
        ord.CurrencyIsoCode = 'TTD';
        ord.Status = 'Draft';
        ord.EffectiveDate = Date.valueOf('2023-04-21');
        ord.Pricebook2Id = Test.getStandardPricebookId();
        insert ord;
        
        Product2 prod = new Product2();
        prod.Name = 'Test prod';
        prod.CurrencyIsoCode = 'TTD';
        insert prod;
        
        PriceBookEntry pbe = new PriceBookEntry();
        pbe.Product2Id = prod.Id;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.UnitPrice = 1000;
        pbe.CurrencyIsoCode = 'TTD';
        insert pbe;
        
        OrderItem oI = new OrderItem();
        oI.OrderId = ord.Id;
        oI.PricebookEntryId = pbe.Id;
        oI.Product2Id = prod.Id;
        oI.UnitPrice = 1000;
        oI.Quantity = 1;
        insert oI;
        
        Order ord2 = new Order();
        ord2.ANSA_Ready_for_D365__c = true;
        ord2.AccountId = acc.Id;
        //ord2.FACAccount__c = parentAcc.Id;
        ord2.CurrencyIsoCode = 'TTD';
        ord2.Status = 'Draft';
        ord2.EffectiveDate = Date.valueOf('2023-04-21');
        ord2.Pricebook2Id = Test.getStandardPricebookId();
        insert ord2;
        
        
        List<OrderItem> oIs = new List<OrderItem>();
        oIs.add(oI);
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
        Integration_Data__mdt cfsWSc = Integration_Data__mdt.getInstance('Customer_Get');
        String sEndpointc = WS_D365Callout.isOrgSandbox() ? cfsWSc.Endpoint_Test__c : cfsWSc.Endpoint__c;
        String sResponsec = '{"dmDataAreaID":"e001","dmrRecId":5638025076,"dmCustomerAccount":"E001_0013C00000oxZOJ","dmInvoiceAccount":"E001_0013C00000oxZOJ","dmPartyType":"Organization","dmOrganizationName":"Test TTD","dmNameAlias":"integration test","dmPersonFirstName":"","dmPersonLastName":"","dmPrimaryContactEmail":"isifuentes@yopmail.com","dmPrimaryContactPhone":"871971708","dmDeliveryAddressDescription":"","dmDeliveryAddressCity":"","dmInvoiceAddressStreet":"","dmCustomerGroupId":"LGRP","dmSalesSegmentId":"AUTOMOTIVE","dmPaymentMethod":"CHEQUE","dmSalesCurrencyCode":"TTD","dmLanguageId":"en-US","dmDefaultDimensionDisplayValue":"-----CC001-DP261-DV001-IC001--RC001--","dmrSuccess":true,"dmrActionResultText":"Customer record find success","dmrMessageText":"Successfully found Customer, DataAreaId: e001, Customer:E001_0013C00000oxZOJ, PaymentTermsDueDate: 6/8/2023, PaymentTermsDueDateDays:0, PaymTermId: ","dmrCreditBalanceMST":0.0,"dmrCreditBalanceCur":0.0,"dmrCreditLimitMST":0.0,"dmrCreditLimitCur":0.0,"dmrIsMandatoryCreditLimit":true,"dmrTermsOfPayment":"","dmrCRM_SalesforceId":"","dmrIsWithInCreditTerms":false,"dmrOldestPendingInvoiceDate":"1900-01-01T12:00:00","dmrAvailableCreditBalanceMST":0.0,"dmrOpenSalesOrdersAmountMST":0.0}';
        Single_CalloutMock sCMc = new Single_CalloutMock(200,
                                                          'Complete',
                                                          sResponsec,
                                                          null);
        Map<String, HttpCalloutMock> endpoint2TestResp = new Map<String,HttpCalloutMock>();
        endpoint2TestResp.put(sEndpoint, sCM);
        endpoint2TestResp.put(sEndpointtoken, sCMToken);
        endpoint2TestResp.put(sEndpointc, sCMc);
        Test.setMock(HttpCalloutMock.class, new CalloutMock(endpoint2TestResp));
        Test.startTest();
        Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('FAC Account').getRecordTypeId();
        Account FACAccount = [Select Id From Account Where RecordtypeId =: rtId LIMIT 1];
        Account acc = [Select Id From Account Where RecordtypeId !=: rtId LIMIT 1];
        Order ord = [Select Id, Account.FAC_Account__r.DataAreaId__c, Account.FAC_Account__r.Name, Account.FAC_Account__r.DeliveryAddressDescription__c, AccountId, Account.DefaultDimensionDisplayValue__c,
                     Account.FAC_Account__r.DefaultDimensionDisplayValue__c,Name, CurrencyIsoCode, Account.FAC_Account__r.CurrencyIsoCode, ShippingAddress, Account.Name,
                     Account.D365Id__c, OrderNumber, Status, AMC_Payment_method__c, ANSA_Ready_for_D365__c, AMC_Ignore_Credit_Check__c, D365Id__c
                      From Order 
                      Limit 1];
        List<OrderItem> lstOrdItem = [Select Id, OrderId, OrderItemNumber, Product2.ProductCode, Product2.Description, ANSA_Warehouse__c,
                                      Quantity, Product2.StockKeepingUnit, Product2.ShippingSiteId__c, Product2.ShippingWarehouseId__c, ListPrice
                                      From OrderItem 
                                      Where OrderId =: ord.Id];
        //WS_D365Callout.updateOrders(ord, lstOrdItem);
        ord.Status = 'Processing';
        ord.D365Id__c = null;
        ord.ANSA_Ready_for_D365__c = false;
        update ord;
        
        ord.Status = 'Activated';
        ord.AMC_Payment_method__c = 'Credit Store';
        update ord; 
        
        ord.Status = 'Approved';
        ord.ANSA_Ready_for_D365__c = true;
        ord.AMC_Ignore_Credit_Check__c = false;
        ord.D365Id__c = null;
        update ord;
        
        Test.stopTest();
    }
}