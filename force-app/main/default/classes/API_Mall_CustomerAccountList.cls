/**
* 
* @description API_Mall_CustomerAccountList
* @author Ankit Kumar 
* @since 03 Dec 2023
*/
 
public with sharing class API_Mall_CustomerAccountList extends AOB_API_RestBaseOutboundPing
{
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}{2}';
    private static final String SERVICE_NAME = API_MallCustomerAccountList.class.getName();
    private final static Integer PAGE_SIZE = 10;
    private final static Integer START_RECORD_NUMBER = 1; 
    public String customerBPGUID;
    
    /**
    * @description The name of your service to be used when looking up custom settings for you service
    *
    * @return SERVICE_NAME
    */
    protected virtual override String getServiceName()
    {
        return SERVICE_NAME;
    }
    
    /**
    * @description Override to set your request and response DTO types and any other globals you may have
    */
    protected override void initialise()
    {
        super.initialise();
        baseRequestDTO = new DTO_Request();
        baseResponseDTO = new DTO_Response();
    }
    
    /**
    * @description DTO_Request
    */
    private class DTO_Request extends CMN_DTO_JsonBase
    {
    /**
    * @description populates triggering object
    * @param triggeringObjectId
    */
        public override void populate(Id triggeringObjectId)
        {
            super.populate(triggeringObjectId);
        }
    }
    
    /**
    * @description Will serialize requestDTO after its been populated.
    *
    * @return result
    */
    @TestVisible
    public virtual override String getBody()
    {
        super.getBody();
        populateRequestDTO();
        return jsonBody;
    }
    
    /**
    * @description Overriding parent class method to use the right API Method
    * @return String
    */
    @TestVisible
    protected override virtual String getVerb()
    {
        return HTTP_VERB_GET;
    }
    
    /**
    * @description OsetHeaders
    */
    public virtual override void setHeaders() 
    {
        request.setHeader(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_JSON);
		request.setHeader(CMN_API_HttpBase.HTTP_HEADER_ACCEPT, CMN_API_HttpBase.HTTP_ENCODING_JSON);
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_CLIENTID, '{!$Credential.API_MALL_SB_API_GATEWAY.ClientId}');
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_CLIENTSECRET, '{!$Credential.API_MALL_SB_API_GATEWAY.ClientSecret}');
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_INTERACTIONID, MALL_OAuth_Util.generateGUID());
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_AUTHORIZATION, MALL_AUTH_PingCustomer.getAccessToken());
    }

    /**
    * @description Method is use to return the endpoint URL using in HTTP response.
    *
    * @return endpoint
    */
    @TestVisible
    protected override String getWebServiceEndPoint() {
        String endPoint;
        String path;
        if (settings != NULL && String.isNotBlank(settings.CMN_NamedCredential__c)) {
            path = String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c : CMN_UTIL_String.EMPTY;
            endPoint = String.format(
                NAMED_CREDENTIAL_URL_FORMAT,
                new List<String>{settings.CMN_NamedCredential__c, String.isNotBlank(path) ? path : CMN_UTIL_String.EMPTY, customerBPGUID}
            );
        }
        if(String.isNotBlank(customerBPGUID)) {
            endPoint += '/accounts?startRecordNo=' + START_RECORD_NUMBER + '&pageSize=' + PAGE_SIZE;
        }
        
        return endPoint;
    }

    /**
	 * @description Call the parent objects' method to ensure we get code coverage
	 *
	 * @return
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {
		super.getEndpointMock();
		return new API_Mall_CustomerAccountListMock();
	}
    
    /**
    * @description Overriding parent class method to indicate that triggering object is not needed
    * @return Boolean
    */
    @TestVisible
    protected override virtual Boolean triggeringObjectRequired()
    {
        return false;
    }
    
    /**
    * @description Wrapper class for http response
    */
    public class DTO_Response extends CMN_DTO_JsonBase
    {
        /**
        * @description response
        * @return String
        */
        @AuraEnabled
        public string response { get; set; }
        
    /**
    * @description The Type of the DTO used when deserializing the class
    *
    * @return Class of the DTO
    */
        @TestVisible
        public override Type getObjectType()
        {
            return DTO_Response.class;
        }
    }
    
    /**
    * @description getResponseBody
    * @return String
    */
    public override String getResponseBody()
    {
        return response.getBody();
    }

    /**
     * 
     * @description getCustomerAccountList
     * @param customerBPGUID String
     * @return  `MallCustomerAccountListResponse`
     */
    public MallCustomerAccountListResponse getCustomerAccountList(String customerBPGUID) {
        try {
            this.customerBPGUID = customerBPGUID;
            API_Mall_CustomerAccountList stub = new API_Mall_CustomerAccountList();
            CMN_WebserviceCallQueue__c queueRecord = CMN_DAL_DataFactory.newOutboundWebserviceQueue(API_Mall_CustomerAccountList.SERVICE_NAME);
            stub.process(queueRecord); 
            System.debug(stub.getResponseBody());
            MallCustomerAccountListResponse customerAccountListResponse = (MallCustomerAccountListResponse) System.JSON.deserialize(stub.getResponseBody(), MallCustomerAccountListResponse.class);
            return customerAccountListResponse;
        } catch(Exception e) { 
            throw MallExceptionUtil.throwAuraException('API_MallCustomerAccountList.getCustomerAccountList', e); 
        }
    }
    
    /**
    * @description Mock class for Test classes
    */
    public class API_Mall_CustomerAccountListMock extends CMN_API_HttpBaseOutboundMock
    {
        public final String validResponse = '{'+
        '  "customerAccountListDetails": ['+
		'    {'+
		'      "accountCloseDate": "4323783007298592",'+
		'      "accountClosedDate": "5018093557268608",'+
		'      "productId": "3846548846804992",'+
		'      "sourceSystemId": "4256401935302656",'+
		'      "accountActivityStatusDescription": "30030714597193",'+
		'      "accountOpenDate": "6011748645529247",'+
		'      "accountNumber": "6304817166377058",'+
		'      "productName": "Victor Alvarado",'+
		'      "accountStatusName": "4026695868634543",'+
		'      "accountActivityStatusCode": "30092537502271",'+
		'      "accountStatusCode": "5163679260655538",'+
		'      "productTypeDescription": "Putfag re sekdugma badtib eto gazduzzi bivdomvo sowu jillovhok neh laro ad oc misojupe.",'+
		'      "productType": "feukewedie"'+
		'    },'+
		'    {'+
		'      "accountCloseDate": "6256797567796353",'+
		'      "accountClosedDate": "4903020901492387",'+
		'      "productId": "3620443758002176",'+
		'      "sourceSystemId": "7319475252625408",'+
		'      "accountActivityStatusDescription": "6011891037993694",'+
		'      "accountOpenDate": "4026423473706568",'+
		'      "accountNumber": "6378000716278339",'+
		'      "productName": "Jon Price",'+
		'      "accountStatusName": "6011831078443472",'+
		'      "accountActivityStatusCode": "6011525537523722",'+
		'      "accountStatusCode": "5610163085072988",'+
		'      "productTypeDescription": "Iji ge aghoci warnad has we nohum eda dihijto sihgiw famzuzho tac cowger.",'+
		'      "productType": "ferupot"'+
		'    },'+
		'    {'+
		'      "accountCloseDate": "4802253856436933",'+
		'      "accountClosedDate": "4903918504188106",'+
		'      "productId": "927539063160832",'+
		'      "sourceSystemId": "8851694829961216",'+
		'      "accountActivityStatusDescription": "4903842217877369",'+
		'      "accountOpenDate": "5610255214405483",'+
		'      "accountNumber": "6304970760917272",'+
		'      "productName": "Leona Drake",'+
		'      "accountStatusName": "341845678599867",'+
		'      "accountActivityStatusCode": "4903374655452729",'+
		'      "accountStatusCode": "5148228154310188",'+
		'      "productTypeDescription": "Pibuk nevepuc cij izadejjig ro hibi de na asnika sibu odu si kemfu bizij.",'+
		'      "productType": "cazkawikzoiru"'+
		'    }'+
		'  ],'+
		'  "pageCtrlOut": {'+
		'    "remainRecordsCount": 86013899,'+
		'    "pageSize": 19936154,'+
		'    "remainPageInd": true,'+
		'    "totalRecordsCount": -80932589'+
		'  }'+
		'}';
    /*
    * @description creates a mock response for http calls
    * @param  request
    * @param response
    */
        protected override void setResponse(
            HttpRequest request,
            HttpResponse response
        )
        { 
            super.setResponse(request, response);
            response.setBody(validResponse);
        }
    }

    /**
    * 
    * @description Mock class for Test classes
    */
    public class MALL_AUTH_PingCustomerMock extends CMN_API_HttpBaseOutboundMock
    {
        public final String validResponse ='{'+
        '    "access_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6ImRpZC0yIiwicGkuYXRtIjoiOGlraSJ9.eyJzY3AiOlsib3BlbmlkIiwicHJvZmlsZSIsImVtYWlsIl0sImNsaWVudF9pZCI6ImZhYWQ5YWNjLTU4NGEtNDkzZC04YzhhLWQ0YjNkNjhmMjY5YyIsImlzcyI6Imh0dHBzOi8vZW50ZXJwcmlzZXN0c3NpdC5zdGFuZGFyZGJhbmsuY28uemEiLCJqdGkiOiJpNzhvU25ENlhZandSU2hHZ2pWSzU1Iiwic3ViIjoiZGF5YWthckAxMjMiLCJkaWdpbWUiOmZhbHNlLCJuYmYiOjE2Njg5NDY4MTEsImFtciI6InB3ZCIsImlkIjoiM2UzNzJjYjctYmVhNC00YzFiLWFkYjMtMTQ5ZmE3ZjY3ZGE0IiwiaWF0IjoxNjY4OTQ2ODExLCJleHAiOjE2Njg5NDcxMTF9.LrHYLaXf6Gi8eVLPA2AEhTWwrQm7DJ8o-PE7i6FQH9dgOUUPjGWUGZnYhruRkR9RzKJpu9K2D6fvLf854XIgFK6yDT6Cg8XBh_mJuwyPd5egUWt6jWM9bVDLQwsnJ8dmWDqTd0NvTvFZPS2yxT898Wd_7u0lctL5bDnZNcnWmmic_t5l-SsMC5g8-KqghyFpmfXPKw-qnuBlFlBScNgp66_dQpwFWa5JEoWm3xksQyd749Y3BzGQE0iq00chZUNWli1uLeHMxw9ZjVgdBTDT87CHE0CfbO-pf-RJWluFkQje3XWqyeZdcC6Joma3sALUZDbaA-gFs7-fxWyWGm97OA",'+
        '    "refresh_token": "rePpfHwqAfJ6VU57941Erxg2U2KqiobBJRCpCCgifI",'+
        '    "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IlJROUV5cXBueGtEbGd0VEtqUGJZWUJVQjd1WSJ9.eyJzdWIiOiJkYXlha2FyQDEyMyIsImF1ZCI6ImZhYWQ5YWNjLTU4NGEtNDkzZC04YzhhLWQ0YjNkNjhmMjY5YyIsImp0aSI6InNIT0NaZDZXcmo2bkFvQWdMa2cwYXkiLCJpc3MiOiJodHRwczovL2VudGVycHJpc2VzdHNzaXQuc3RhbmRhcmRiYW5rLmNvLnphIiwiaWF0IjoxNjY4OTQ2NTI2LCJleHAiOjE2Njg5NDc0MjYsImFtciI6WyJwd2QiXSwiYXV0aF90aW1lIjoxNjY4OTQ2NTI2LCJlbWFpbHZlcmlmaWNhdGlvbnN0YXR1cyI6IlRSVUUiLCJpZCI6IjNlMzcyY2I3LWJlYTQtNGMxYi1hZGIzLTE0OWZhN2Y2N2RhNCIsImZpcnN0X25hbWUiOiJkYXlha2FyIiwiZW1haWwiOiJEYXlha2FyLkRlZWtvbmRhQHN0YW5kYXJkYmFuay5jby56YSIsInBpLnNyaSI6InBneFY2ekZlcUFaZ0h6T1FkUHZqRHBFT2diOC4uZWhwZS5TRGxvUWhZalY3ZnRUSHJPckM1MjRuaFFWIiwibm9uY2UiOiJhZDhjN2RlYS03ZDNkLTQ5ZGMtOGYwYS01ZTBjZWM3MGMzODkiLCJzX2hhc2giOiIxZWFGR2JjSkFBa1MwRTIwejZuUjFRIn0.oXoDuUycBKsPv-lYZInJbIwAaOgHpNcyxfx5QZwoBvs9v8vihhAfyttdOyi7jbo9awEcbU3Hqcr7ZLNOhQ4ChkB75lT3UZ_ufqVQeqg0xwsvQ76hOrAVa31ObW1vr2YussdqeXPsVEAu38vaNIXaImOV6V5xG8UgVkLqdCpMPIoQWFPqITVswjbhfvd5VX2PUQQdChn15_OCiYLTkvnSS4FeW00TXHzPOpxkCc-G52oEuczKrPJ93js2ZzM0E4oqk8ZEyaBaNV2iaPP2t_QkGiAnwmrTDMugUvLfmpTg0glbvi3cXVQSEZMJ-vEJukYMv-ADTUYTHbR1Ezj_B8zvkQ",'+
        '    "token_type": "Bearer",'+
        '    "expires_in": 299'+
        '}';
		
        
    /*
    * @description creates a mock response for http calls
    * @param  request
    * @param response
    */
        protected override void setResponse(
            HttpRequest request,
            HttpResponse response
        )
        {
            super.setResponse(request, response);
            response.setBody(validResponse);
        }
    }  
}