public class ANSA_OauthTokenRequest {
    
    public static Response sendRequest(){
        
        String baseInstanceUrl = URL.getSalesforceBaseUrl().toExternalForm();
        system.debug(baseInstanceUrl);
        
        String responseString;
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setEndpoint(''+baseInstanceUrl+'/services/oauth2/token');
        
        Boolean runningInASandbox = [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
        String CLIENT_ID;
        String CLIENT_SECRET;
        String USERNAME;
        String PASSWORD;
        if(runningInASandbox){
            CLIENT_ID = '3MVG9oZtFCVWuSwNFkWkf364QDgi.Mr1xhBgQBpqa3w58dqbbbmqeA6dPtsOpehcljmoNLnKACaZc9IwIGMlp';
            CLIENT_SECRET = 'C6F18F8324F5B73816C946A3A44DFE6A7B286D78FBECF04DC8825D6831006A0C';
            USERNAME = 'integration@ansa.dev';
            PASSWORD = 'ANSA_2023!#';
        }else{
            CLIENT_ID = '3MVG9FMtW0XJDLd2twdFeCxo9RS9YMj30QB_N2kNib7Y.SYyde2yjiqA6t7oXZXkpbapDPuUxveqtnQpzf0By';
            CLIENT_SECRET = 'E10F699C71E44B2FB3164C1915AE9605261B5C2D33EFBFE43CD79D06DC63DEA9';
            USERNAME = 'integration@ansa.prod';
            PASSWORD = 'ANSA_2023!jhJdj9HEDNQmLVFeklsFulpo';
        }
        
        
        req.setBody('grant_type=password' + '&client_id='+CLIENT_ID + 
                    '&client_secret='+CLIENT_SECRET + '&username='+USERNAME + '&password='+PASSWORD);
        
        Http http = new Http();
        HttpResponse response;
        
        if(!system.test.isRunningTest()) {
            response = http.send(req);
        }else{
            response = new HttpResponse();
            response.setHeader('Content-Type','application/x-www-form-urlencoded');
            response.setBody('{"access_token": "00D6u0000008k7N!ARsAQBKQNEaNtyRiSbNbI3FVrqFqNEmwAjQ0yfdQg34UlvLmA9wUsBvY55PHtuy9EckY44aaadhHGNFF.d3d2wMizkFYrYZ7"}');
            response.setStatusCode(200);
        }
        
        
        if(response.getStatusCode() == 200 || response.getStatusCode() == 201) {
                    responseString = String.valueOf(response.getBody());
                    system.debug(responseString);
                }
        
        System.debug('Body ' + response.getBody());
        System.debug('Status ' + response.getStatus());
        System.debug('Status code ' + response.getStatusCode());
        
        return (Response) System.JSON.deserialize(responseString, Response.class);
    }
    
    public class Response {
    	public String access_token;
    	public String instance_url;
    	public String id;
    	public String token_type;
    	public String issued_at;
    	public String signature;
    
    }

}