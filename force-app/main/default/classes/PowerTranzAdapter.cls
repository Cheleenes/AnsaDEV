global without sharing class PowerTranzAdapter implements commercepayments.PaymentGatewayAdapter {
    global PowerTranzAdapter() {}
    
    global commercepayments.GatewayResponse processRequest(commercepayments.paymentGatewayContext gatewayContext) {
        commercepayments.RequestType requestType = gatewayContext.getPaymentRequestType();
        commercepayments.PaymentGatewayRequest paymentRequest = gatewayContext.getPaymentRequest();
        commercepayments.GatewayResponse response;
        
        Map<String, Object> mapCardPaymentMethod = (Map<String, Object>)JSON.deserializeUntyped(JSON.serializePretty(paymentRequest));
        Map<String, Object> mapPaymentMethod = (Map<String, Object>)mapCardPaymentMethod.get('paymentMethod');
        Map<String, Object> mapInternalAddress = (Map<String, Object>)mapPaymentMethod.get('internalAddress');
        System.debug(JSON.serializePretty(mapInternalAddress));
        
        System.debug('requestType: ' + requestType);
        if (requestType == CommercePayments.RequestType.Authorize) {
           response = createAuthResponse((commercepayments.AuthorizationRequest) paymentRequest, gatewayContext, mapInternalAddress);
           System.debug(response);
        } else if (requestType == CommercePayments.RequestType.Sale) {
           // Handle capture
        } else {
           // Other request types
        }
        return response;    
    }
    public commercepayments.GatewayResponse createAuthResponse(commercepayments.AuthorizationRequest authRequest, commercepayments.paymentGatewayContext gatewayContext, Map<String, Object> mapInternalAddress) {
               
        CommercePayments.AuthorizationRequest commerceAuthRequest = (CommercePayments.AuthorizationRequest)gatewayContext.getPaymentRequest();
        
        System.debug(commerceAuthRequest);
        //System.debug(JSON.serializePretty(commerceAuthRequest));
        
    	CommercePayments.AuthApiPaymentMethodRequest authPaymentMethod = commerceAuthRequest.paymentMethod;
        System.debug(authPaymentMethod);
    	String paymentMethodId = authPaymentMethod.Id;
        System.debug(paymentMethodId);
        // get the cardPaymentMethod object with the token
        CommercePayments.CardPaymentMethodRequest cardPaymentMethod = (CommercePayments.CardPaymentMethodRequest)authPaymentMethod.cardPaymentMethod;
        //commercepayments.AddressRequest billingAddress = tokenizeRequest.address;
        
        String currencyIsoCodeLC = authRequest.currencyIsoCode.toLowercase();
        System.debug('authRequest currency iso code: ' + currencyIsoCodeLC);
        Account userAcc = [Select Id, FAC_Account__c From Account Where Id =: commerceAuthRequest.accountId];
        Contact userCont = [Select Id, Email, Phone From Contact Where AccountId =: userAcc.Id LIMIT 1];
        Account FACAccount = [Select Id, CurrencyIsoCode, Name From Account Where Id =: userAcc.FAC_Account__c];
        Integration_Data__mdt accountData = [Select Id, User__c, Password__c, CurrencyIsoCode__c, ISO_4217_Texto__c From Integration_Data__mdt Where MasterLabel =: FACAccount.Name Limit 1];
        Order lastOrder = [Select Id, OrderNumber From Order Order by CreatedDate DESC Limit 1];
        System.debug(String.valueOf(Integer.valueOf(lastOrder.OrderNumber) + 1));
        //System.debug(accountData.CurrencyIsoCode__c);
        //System.debug(accountData.ISO_4217_Texto__c);
        Map<String, Object> params = new Map<String, Object>();
        
        Blob b = Crypto.GenerateAESKey(128);
		String h = EncodingUtil.ConvertTohex(b);
		String guid = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
        

        
        params.put('CurrencyCode', currencyIsoCodeLC);
        //params.put('source', urlEncode(cardPaymentMethod.GatewayToken));        
        params.put('TransactionIdentifier', guid);
        params.put('TotalAmount', Decimal.valueOf(commerceAuthRequest.amount).setScale(2, RoundingMode.HALF_UP));
        params.put('CurrencyCode', accountData.ISO_4217_Texto__c);
        params.put('ThreeDSecure', true);
        Map<String, Object> sourceP = new Map<String, Object>();
        sourceP.put('CardPan', cardPaymentMethod.cardNumber);
        sourceP.put('CardCvv', cardPaymentMethod.cvv);
        sourceP.put('CardExpiration', String.valueOf(cardPaymentMethod.expiryYear).right(2) + cardPaymentMethod.expiryMonth);
        sourceP.put('CardholderName', cardPaymentMethod.cardHolderName);
        params.put('Source', sourceP);
        params.put('OrderIdentifier', 'SF-' + guid);
        Map<String, Object> BillingAddressP = new Map<String, Object>();
        BillingAddressP.put('FirstName', 'John');
        BillingAddressP.put('LastName', 'Smith');
        BillingAddressP.put('Line1', (String)mapInternalAddress.get('street'));
        BillingAddressP.put('Line2', '');
        BillingAddressP.put('City', (String)mapInternalAddress.get('city'));
        BillingAddressP.put('State', (String)mapInternalAddress.get('state'));
        BillingAddressP.put('PostalCode', (String)mapInternalAddress.get('postalCode'));
        BillingAddressP.put('CountryCode', mapCountries.get((String)mapInternalAddress.get('country')));
        BillingAddressP.put('EmailAddress', userCont.email);
        BillingAddressP.put('PhoneNumber', userCont.Phone);
        params.put('BillingAddress', BillingAddressP);
        params.put('AddressMatch', 'false');
        Map<String, Object> ExtendedDataP = new Map<String, Object>();
        Map<String, Object> ThreeDSecureP = new Map<String, Object>();
        ThreeDSecureP.put('ChallengeWindowSize', '4');
        ThreeDSecureP.put('ChallengeWindowSize', '02');
        ExtendedDataP.put('ThreeDSecure', ThreeDSecureP);
        ExtendedDataP.put('MerchantResponseUrl', 'https://webhook.site/');
        params.put('ExtendedData', ExtendedDataP);  
		//System.debug(JSON.serializePretty(params));
		System.debug('AccountId: ' + commerceAuthRequest.accountId);
		
        System.debug('FAC_Account__c : ' + userAcc.FAC_Account__c);
        
        System.debug('Account: ' + userAcc);
        System.debug('FAC_Account__c isocode: ' + FACAccount.currencyIsoCode);
        HttpResponse response = doPostSale('auth', accountData, params);
        System.debug(response);
        System.debug(response.getHeaderKeys());
        for(String strkey : response.getHeaderKeys() ){
            System.debug(strkey + ': ' + response.getHeader(strkey));
        }
        String body = response.getBody();
        System.debug(body);
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(body);
        Boolean approved = (Boolean)results.get('Approved');
        Integer sc = response.getStatusCode();
        commercepayments.AuthorizationResponse authResponse = new commercepayments.AuthorizationResponse();
        
        authResponse.setGatewayDate(system.now());
        
        // map: https://stripe.com/docs/api/errors
        // to: https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_enum_commercepayments_SalesforceResultCode.htm
        
        if (sc >= 200 && sc < 300) {
            
            String spiToken = (String)results.get('SpiToken');
            System.debug(spiToken);
            if(spiToken == ''){
				Throw new TestException();                
            }
            HttpResponse responsePayment = doPostConductor('Conductor', spiToken);
            
            System.debug(responsePayment);
            System.debug(responsePayment.getBody());
            for(String hKey : responsePayment.getHeaderKeys()){
                System.debug(hKey + ': ' + responsePayment.getHeader(hKey));
            }
            System.debug(responsePayment.getStatus());
            String conductorSPIToken = responsePayment.getBody();
            Integer scConductor = responsePayment.getStatusCode();
            if (scConductor >= 200 && scConductor < 300) {
                conductorSPIToken = conductorSPIToken.right(204);
                conductorSPIToken = conductorSPIToken.left(62);
                System.debug(conductorSPIToken);
                
                HttpResponse responsePaymentFinal = doPostPayment('payment', conductorSPIToken, accountData);
                Integer scPayment = responsePaymentFinal.getStatusCode();
                if (scPayment >= 200 && scPayment < 300) {
                    System.debug(responsePaymentFinal);
                    System.debug(responsePaymentFinal.getBody());
                    System.debug(responsePaymentFinal.getStatus());
                    if(responsePayment.getBody() == ''){
                        Throw new TestException();
                    }
                    
                    authResponse.setGatewayResultCode('200');//(String) results.get('status'));
                    authResponse.setGatewayResultCodeDescription((String) results.get('ResponseMessage'));
                    authResponse.setGatewayAuthCode((String) results.get('SpiToken'));
                    authResponse.setSalesforceResultCodeInfo(new commercepayments.SalesforceResultCodeInfo(commercepayments.SalesforceResultCode.Success));
                    authResponse.setGatewayDate(system.now());
                    
                    authResponse.setAmount(double.valueOf(1));//((Long) results.get('amount'))/100.00)); // TODO: use reverse of toStripeCurrencyUnits
                    
                  //If payment failed  
                } else {
                    // TODO: lots of error mapping/handling
                    Map<String, Object> error = (Map<String, Object>) results.get('error');
                    String errorType = (String) error.get('type');
                    String errorCode = (String) error.get('code');
                    
                    if (errorType.equals('card_error') ) {
                        authResponse.setGatewayResultCode(errorCode);
                        authResponse.setGatewayResultCodeDescription((String) error.get('decline_code'));
                        authResponse.setGatewayMessage((String) error.get('message'));
                        authResponse.setSalesforceResultCodeInfo(new commercepayments.SalesforceResultCodeInfo(commercepayments.SalesforceResultCode.Decline));
                    } else {
                        return new commercepayments.GatewayErrorResponse(String.valueOf(sc), 'ERROR: ' + body);
                    }                    
                }
              //If conductor failed  
            } else {
                // TODO: lots of error mapping/handling
                Map<String, Object> error = (Map<String, Object>) results.get('error');
                String errorType = (String) error.get('type');
                String errorCode = (String) error.get('code');
                
                if (errorType.equals('card_error') ) {
                    authResponse.setGatewayResultCode(errorCode);
                    authResponse.setGatewayResultCodeDescription((String) error.get('decline_code'));
                    authResponse.setGatewayMessage((String) error.get('message'));
                    authResponse.setSalesforceResultCodeInfo(new commercepayments.SalesforceResultCodeInfo(commercepayments.SalesforceResultCode.Decline));
                } else {
                    return new commercepayments.GatewayErrorResponse(String.valueOf(sc), 'ERROR: ' + body);
                }
            }
            
          //If auth failed  
        } else {
            // TODO: lots of error mapping/handling
            Map<String, Object> error = (Map<String, Object>) results.get('error');
            String errorType = (String) error.get('type');
            String errorCode = (String) error.get('code');
            
            if (errorType.equals('card_error') ) {
                authResponse.setGatewayResultCode(errorCode);
                authResponse.setGatewayResultCodeDescription((String) error.get('decline_code'));
                authResponse.setGatewayMessage((String) error.get('message'));
                authResponse.setSalesforceResultCodeInfo(new commercepayments.SalesforceResultCodeInfo(commercepayments.SalesforceResultCode.Decline));
            } else {
                return new commercepayments.GatewayErrorResponse(String.valueOf(sc), 'ERROR: ' + body);
            }
        }
       
        return authResponse;
    }
    
    class TestException extends Exception{
        
    }
    
    private static HttpResponse doPostSale(String path, Integration_Data__mdt accountData, Map<String, Object> params) {
        
        System.debug('isocode: ' + accountData.CurrencyIsoCode__c);
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint('/spi/' + path);
        request.setMethod('POST');
		request.setHeader('Content-Type', 'application/json');
        request.setHeader('PowerTranz-PowerTranzId', accountData.User__c);
        request.setHeader('PowerTranz-PowerTranzPassword', accountData.Password__c);
        request.setHeader('Host', 'staging.ptranz.com');        
        request.setBody(JSON.serialize(params));
		System.debug(request.toString());      
        commercepayments.PaymentsHttp http = new commercepayments.PaymentsHttp();
        return http.send(request);
    }
    
    private static HttpResponse doPostConductor(String path, String spiToken) {   
        HttpRequest request = new HttpRequest();
        request.setEndpoint('/spi/' + path);
        request.setMethod('POST'); 
		request.setHeader('Content-Type', 'application/x-www-form-urlencoded'); 
                
        //tring payload = 'client_id='+EncodingUtil.urlEncode(clientId,'UTF-8')+'&client_secret='+EncodingUtil.urlEncode(clientSecret,'UTF-8')+'&refresh_token='+EncodingUtil.urlEncode(refreshToken,'UTF-8')+'&grant_type=refresh_token';
        
        String payload = 'SpiToken='+EncodingUtil.urlEncode(spiToken,'UTF-8')+'&browserLanguage='+EncodingUtil.urlEncode('en-US','UTF-8')+'&browserWidth='+EncodingUtil.urlEncode('1920','UTF-8')+'&browserHeight='+EncodingUtil.urlEncode('1080','UTF-8')+'&browserTimeZone='+EncodingUtil.urlEncode('360','UTF-8')+'&browserJavaEnabled='+EncodingUtil.urlEncode('false','UTF-8')+'&browserJavascriptEnabled='+EncodingUtil.urlEncode('true','UTF-8')+'&browserColorDepth='+EncodingUtil.urlEncode('24','UTF-8');
        request.setBody(payload);
        request.setHeader('Content-Length', '70');
		System.debug(request.toString());      
        commercepayments.PaymentsHttp http = new commercepayments.PaymentsHttp();
        System.debug(request.getBody());
        //System.debug(String.valueOf(formBlob.size()));
        return http.send(request);
    }
    
    private static HttpResponse doPostPayment(String path, String spiToken, Integration_Data__mdt accountData) {   
        System.debug('isocode: ' + accountData.CurrencyIsoCode__c);
        HttpRequest request = new HttpRequest();
        request.setEndpoint('/spi/' + path);
        request.setMethod('POST'); 
		request.setHeader('Content-Type', 'application/json'); 
        request.setHeader('PowerTranz-PowerTranzId', accountData.User__c);
        request.setHeader('PowerTranz-PowerTranzPassword', accountData.Password__c);
                
        String payload = '\"' + spiToken + '\"';
        System.debug('payload: ' + payload);
        request.setBody(payload);
		System.debug(request.toString());      
        commercepayments.PaymentsHttp http = new commercepayments.PaymentsHttp();
        System.debug(request.getBody());
        return http.send(request);
    }
    
    public static Map<String, String> mapCountries = new Map<String, String>{
        	'Afghanistan' => '004',
            'Aland Islands' => '248',
            'Albania' => '008',
            'Algeria' => '012',
            'Andorra' => '020',
            'Angola' => '024',
            'Anguilla' => '660',
            'Antarctica' => '010',
            'Antigua and Barbuda' => '028',
            'Argentina' => '032',
            'Armenia' => '051',
            'Aruba' => '533',
            'Australia' => '036',
            'Austria' => '040',
            'Azerbaijan' => '031',
            'Bahamas' => '044',
            'Bahrain' => '048',
            'Bangladesh' => '050',
            'Barbados' => '052',
            'Belarus' => '112',
            'Belgium' => '056',
            'Belize' => '084',
            'Benin' => '204',
            'Bermuda' => '060',
            'Bhutan' => '064',
            'Bolivia, Plurinational State of' => '068',
            'Bonaire, Sint Eustatius and Saba' => '535',
            'Bosnia and Herzegovina' => '070',
            'Botswana' => '072',
            'Bouvet Island' => '074',
            'Brazil' => '076',
            'British Indian Ocean Territory' => '086',
            'Brunei Darussalam' => '096',
            'Bulgaria' => '100',
            'Burkina Faso' => '854',
            'Burundi' => '108',
            'Cambodia' => '132',
            'Cameroon' => '116',
            'Canada' => '120',
            'Cape Verde' => '124',
            'Cayman Islands' => '136',
            'Central African Republic' => '140',
            'Chad' => '148',
            'Chile' => '152',
            'China' => '156',
            'Christmas Island' => '162',
            'Cocos (Keeling) Islands' => '166',
            'Colombia' => '170',
            'Comoros' => '174',
            'Congo' => '178',
            'Congo, the Democratic Republic of the' => '180',
            'Cook Islands' => '184',
            'Costa Rica' => '188',
            'Cote d’Ivoire' => '384',
            'Croatia' => '191',
            'Cuba' => '192',
            'Curaçao' => '531',
            'Cyprus' => '196',
            'Czech Republic' => '203',
            'Denmark' => '208',
            'Djibouti' => '262',
            'Dominica' => '212',
            'Dominican Republic' => '214',
            'Ecuador' => '218',
            'Egypt' => '818',
            'El Salvador' => '222',
            'Equatorial Guinea' => '226',
            'Eritrea' => '232',
            'Estonia' => '233',
            'Ethiopia' => '231',
            'Falkland Islands (Malvinas)' => '238',
            'Faroe Islands' => '234',
            'Fiji' => '242',
            'Finland' => '246',
            'France' => '250',
            'French Guiana' => '254',
            'French Polynesia' => '258',
            'French Southern Territories' => '260',
            'Gabon' => '266',
            'Gambia' => '270',
            'Georgia' => '268',
            'Germany' => '276',
            'Ghana' => '288',
            'Gibraltar' => '292',
            'Greece' => '300',
            'Greenland' => '304',
            'Grenada' => '308',
            'Guadeloupe' => '312',
            'Guatemala' => '320',
            'Guernsey' => '831',
            'Guinea' => '324',
            'Guinea-Bissau' => '624',
            'Guyana' => '328',
            'Haiti' => '332',
            'Heard Island and McDonald Islands' => '334',
            'Holy See (Vatican City State)' => '336',
            'Honduras' => '340',
            'Hungary' => '348',
            'Iceland' => '352',
            'India' => '356',
            'Indonesia' => '360',
            'Iran, Islamic Republic of' => '364',
            'Iraq' => '368',
            'Ireland' => '372',
            'Isle of Man' => '833',
            'Israel' => '376',
            'Italy' => '380',
            'Jamaica' => '388',
            'Japan' => '392',
            'Jersey' => '832',
            'Jordan' => '400',
            'Kazakhstan' => '398',
            'Kenya' => '404',
            'Kiribati' => '296',
            'Korea, Democratic People’s Republic of"' => '408',
            'Korea, Republic of' => '410',
            'Kuwait' => '414',
            'Kyrgyzstan' => '417',
            'Lao People’s Democratic Republic' => '418',
            'Latvia' => '428',
            'Lebanon' => '422',
            'Lesotho' => '426',
            'Liberia' => '430',
            'Libya' => '434',
            'Liechtenstein' => '438',
            'Lithuania' => '440',
            'Luxembourg' => '442',
            'Macao' => '446',
            'Madagascar' => '450',
            'Malawi' => '454',
            'Malaysia' => '458',
            'Maldives' => '462',
            'Mali' => '466',
            'Malta' => '470',
            'Martinique' => '474',
            'Mauritania' => '478',
            'Mauritius' => '480',
            'Mayotte' => '175',
            'Mexico' => '484',
            'Moldova, Republic of' => '498',
            'Monaco' => '492',
            'Mongolia' => '496',
            'Montenegro' => '499',
            'Montserrat' => '500',
            'Morocco' => '504',
            'Mozambique' => '508',
            'Myanmar' => '104',
            'Namibia' => '516',
            'Nauru' => '520',
            'Nepal' => '524',
            'Netherlands' => '528',
            'New Caledonia' => '540',
            'New Zealand' => '554',
            'Nicaragua' => '558',
            'Niger' => '562',
            'Nigeria' => '566',
            'Niue' => '570',
            'Norfolk Island' => '574',
            'Norway' => '578',
            'Oman' => '512',
            'Pakistan' => '586',
            'Palestine' => '275',
            'Panama' => '591',
            'Papua New Guinea' => '598',
            'Paraguay' => '600',
            'Peru' => '604',
            'Philippines' => '608',
            'Pitcairn' => '612',
            'Poland' => '616',
            'Portugal' => '620',
            'Qatar' => '634',
            'Reunion' => '638',
            'Romania' => '642',
            'Russian Federation' => '643',
            'Rwanda' => '646',
            'Saint Barthélemy' => '652',
            'Saint Helena, Ascension and Tristan da Cunha' => '654',
            'Saint Kitts and Nevis' => '659',
            'Saint Lucia' => '662',
            'Saint Martin (French part)' => '663',
            'Saint Pierre and Miquelon' => '666',
            'Saint Vincent and the Grenadines' => '670',
            'Samoa' => '882',
            'San Marino' => '674',
            'Sao Tome and Principe' => '678',
            'Saudi Arabia' => '682',
            'Senegal' => '686',
            'Serbia' => '688',
            'Seychelles' => '690',
            'Sierra Leone' => '694',
            'Singapore' => '702',
            'Sint Maarten (Dutch part)' => '534',
            'Slovakia' => '703',
            'Slovenia' => '705',
            'Solomon Islands' => '090',
            'Somalia' => '706',
            'South Africa' => '710',
            'South Georgia and the South Sandwich Islands' => '239',
            'South Sudan' => '728',
            'Spain' => '724',
            'Sri Lanka' => '144',
            'Sudan' => '729',
            'Suriname' => '740',
            'Svalbard and Jan Mayen' => '744',
            'Sweden' => '752',
            'Switzerland' => '756',
            'Syrian Arab Republic' => '760',
            'Taiwan' => '158',
            'Tajikistan' => '762',
            'Tanzania, United Republic of' => '834',
            'Thailand' => '764',
            'Timor-Leste' => '626',
            'Togo' => '768',
            'Tokelau' => '772',
            'Tonga' => '776',
            'Trinidad and Tobago' => '780',
            'Tunisia' => '788',
            'Turkey' => '792',
            'Turkmenistan' => '795',
            'Turks and Caicos Islands' => '796',
            'Tuvalu' => '798',
            'Uganda' => '800',
            'Ukraine' => '804',
            'United Arab Emirates' => '784',
            'United Kingdom' => '826',
            'United States' => '840',
            'Uruguay' => '858',
            'Uzbekistan' => '860',
            'Vanuatu' => '548',
            'Venezuela, Bolivarian Republic of' => '862',
            'Vietnam' => '704',
            'Virgin Islands, British' => '092',
            'Wallis and Futuna' => '876',
            'Western Sahara' => '732',
            'Yemen' => '887',
            'Zambia' => '894',
            'Zimbabwe' => '716'    
    };
}