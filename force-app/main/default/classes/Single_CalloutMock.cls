@isTest
public class Single_CalloutMock implements HttpCalloutMock {
	public Integer code;
    public String status;
    public String bodyAsString;
    public Blob bodyAsBlob;
    public Map<String, String> responseHeaders;
    
    public Single_CalloutMock(Integer code, String status, String body,
                                         Map<String, String> responseHeaders) {
			this.code = code;
			this.status = status;
			this.bodyAsString = body;
			this.bodyAsBlob = null;
			this.responseHeaders = responseHeaders;
	}

	public Single_CalloutMock(Integer code, String status, Blob body,
                                         Map<String, String> responseHeaders) {
			this.code = code;
			this.status = status;
			this.bodyAsBlob = body;
			this.bodyAsString = null;
			this.responseHeaders = responseHeaders;
	}
    
    public HTTPResponse respond(HTTPRequest req) {
	        HttpResponse resp = new HttpResponse();
			resp.setStatusCode(code);
			resp.setStatus(status);
			if (bodyAsBlob != null) {
				resp.setBodyAsBlob(bodyAsBlob);
			} else {
				resp.setBody(bodyAsString);
			}

			if (responseHeaders != null) {
			     for (String key : responseHeaders.keySet()) {
				 	resp.setHeader(key, responseHeaders.get(key));
			     }
			}
			return resp;
	    }
}