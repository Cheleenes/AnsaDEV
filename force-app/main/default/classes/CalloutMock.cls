@isTest
global class CalloutMock implements HttpCalloutMock {
    Map<String, HttpCalloutMock> requests;

    public CalloutMock(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
    }

    public HTTPResponse respond(HTTPRequest req) {
        System.debug(req.getEndpoint());
        System.debug(requests.keySet());
		HttpCalloutMock mock = requests.get(req.getEndpoint());
        HTTPResponse res;
	    try {
            System.debug(mock);
	        res = mock.respond(req);
        } catch (Exception e) {
            System.debug('HTTP callout not supported for test methods');
            System.debug('Message: ' + e.getMessage());
	    }
        return res;
    }

    public void addRequestMock(String url, HttpCalloutMock mock) {
        requests.put(url, mock);
    }
    
    public static Boolean isOrgSandbox(){
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        return runningInASandbox;
    }
}