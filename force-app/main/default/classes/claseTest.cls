public class claseTest {
	@Future(callout=true)
    public static void futuroMetodo(){
		HttpRequest request = new HttpRequest();
        request.setEndpoint('https://staging.ptranz.com/Api/spi/' + 'Conductor'); //+ 'SpiToken=' + EncodingUtil.urlEncode('2xomtt5eu2yqte9cfykmjrbb6b8ci958njnospobxb0go2jgvd-3plyg9wt7wz','utf-8'));
        request.setMethod('POST'); 
		request.setHeader('Content-Type', vNHttpFormBuilder.GetContentType2());  
        //request.setTimeout(12000);
                
        String payload = 'SpiToken='+EncodingUtil.urlEncode('5n3x8x1uuflf2m4u8699sgrim1ttu5gp6a5bosixd4k727bfm-3plyg9wt7wz','UTF-8');
    	System.debug(payload);
        
        
        String form64 = '';

		form64 += vNHttpFormBuilder.WriteBoundary();
        form64 += vNHttpFormBuilder.WriteBodyParameter('SpiToken', '2m6vlvzmum7sfveaqp7mcxf92qxzxpopl9uqxp1i4xw8ydcg2h-3plyg9wt7wz');
        form64 += vNHttpFormBuilder.WriteBoundary(vNHttpFormBuilder.EndingType.CrLf);

        blob formBlob = EncodingUtil.base64Decode(form64);
        //request.setBodyAsBlob(formBlob);
        request.setBody(payload);
        request.setHeader('Content-Length', '70');
		System.debug(request.toString());      
        HTTP http = new HTTP();
        HttpResponse responsePayment = http.send(request);
		System.debug(request.getBody());
        //System.debug(String.valueOf(formBlob.size()));
		System.debug(responsePayment);
            System.debug(responsePayment.getBody());
            for(String hKey : responsePayment.getHeaderKeys()){
                System.debug(hKey + ': ' + responsePayment.getHeader(hKey));
            }
            System.debug(responsePayment.getStatus());
    }
}