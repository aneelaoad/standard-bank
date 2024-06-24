/**
* 
* @description API_MallCustomerAccountList
* @author Ankit Kumar 
* @since 03 Dec 2023
*/
 
public with sharing class API_MallCustomerAccountList extends AOB_API_RestBaseOutboundPing
{
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}{2}';
    private static final String SERVICE_NAME = API_MallCustomerAccountList.class.getName();
    private final static Integer PAGE_SIZE = 10;
    private final static Integer START_RECORD_NUMBER = 1; 
    private final static Integer MAX_API_TIMEOUT_LIMIT = 12000; 
    public String customerBPGUID;

    /**
	 * @description API_MallCustomerAccountList 
	 *
	 */    
    public API_MallCustomerAccountList(String customerBPGUID){
        this.customerBPGUID = customerBPGUID;
    }
    
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
        request.setMethod(HTTP_VERB_GET);
        request.setTimeout(MAX_API_TIMEOUT_LIMIT);
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
        
        endPoint += '/accounts?startRecordNo=' + START_RECORD_NUMBER + '&pageSize=' + PAGE_SIZE;
        return endPoint;
    }

    /**
	 * @description Call the parent objects' method to ensure we get code coverage
	 *
	 * @return
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {
		super.getEndpointMock();
		return new API_MallCustomerAccountListMock();
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
    public static MallCustomerAccountListResponse getCustomerAccountList(String customerBPGUID) {
        try {
            API_MallCustomerAccountList stub = new API_MallCustomerAccountList(customerBPGUID);
            CMN_WebserviceCallQueue__c queueRecord = CMN_DAL_DataFactory.newOutboundWebserviceQueue(API_MallCustomerAccountList.SERVICE_NAME);
            stub.process(queueRecord); 
            MallCustomerAccountListResponse customerAccountListResponse = MallCustomerAccountListResponse.parse(stub.getResponseBody());
            return customerAccountListResponse;
        } catch(Exception e) { 
            throw MallExceptionUtil.throwAuraException('API_MallCustomerAccountList.getCustomerAccountList', e); 
        }
    }
    
    /**
    * @description Mock class for Test classes
    */
    public class API_MallCustomerAccountListMock extends CMN_API_HttpBaseOutboundMock
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
}