/**
* 
* @description API_Mall_GetForeignExchangeRate
* @author Ankit Kumar 
* @since 03 Dec 2023
*/
 
public with sharing class API_Mall_GetForeignExchangeRate extends AOB_API_RestBaseOutboundPing
{
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}{2}{3}';
    public static final String SERVICE_NAME = API_Mall_GetForeignExchangeRate.class.getName();   
    public static final String PRICE_SEGMENT_KEY = 'priceSegment';   
    public static final String PRICE_SEGMENT_VALUE = 'retail';   
    private List<String> currencyPairs;
    private String accessToken;
    private static final String API_CALLOUT_SCOPE = 'forex';
    private static final String HTTP_HEADER_REQUEST_ID = 'x-req-id';
    private static final String HTTP_HEADER_COUNTRY_CODE = 'x-country-code';
    private static final String HTTP_HEADER_TIMESTAMP = 'x-req-timestamp';
    private static final String HTTP_DEFAULT_COUNTRY_CODE = 'ZA';
    private static final String HTTP_INDICATIVE_RATE_TYPE_ENCODING = 'application/x.indicative-rates+json;version=1';
    private static final String DEFAULT_CHANNEL = 'BCB0';

    /**
     * @description constructor used to make sure a token will be provided to authenticate to the API call
    * @param location String
    */
    public API_Mall_GetForeignExchangeRate(List<String> currencyPairs)
    {
        accessToken = Mall_API_SystemGatewayToken.getGatewayAccessToken(API_CALLOUT_SCOPE);
        this.currencyPairs = currencyPairs;
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
    * 
    * @description Override to set your request and response DTO types and any other globals you may have
    */
    protected override void initialise()
    {
        super.initialise();
        baseRequestDTO = new DTO_Request();
        baseResponseDTO = new DTO_Response();
    }
    
    /**
    * 
    * @description DTO_Request
    */
    private class DTO_Request extends CMN_DTO_JsonBase
    {
    /**
    * 
    * @description populates triggering object
    * @param triggeringObjectId Id
    */
        public override void populate(Id triggeringObjectId)
        {
            super.populate(triggeringObjectId);
        }
    }
    
    /**
    * @description Will serialize requestDTO after its been populated.
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
    * 
    * @description setHeaders
    */
    public virtual override void setHeaders() 
    {
        setServiceSettings();
        request.setMethod(getVerb());
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_ACCEPT, HTTP_INDICATIVE_RATE_TYPE_ENCODING);
        request.setHeader(HTTP_HEADER_REQUEST_ID, Mall_OAuth_Util.generateGUID());
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_CHANNELID, DEFAULT_CHANNEL);
        request.setHeader(HTTP_HEADER_COUNTRY_CODE, HTTP_DEFAULT_COUNTRY_CODE);
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_AUTHORIZATION, 'Bearer ' + this.accessToken);
        request.setHeader(HTTP_HEADER_TIMESTAMP, getFormattedTimestamp());
    }

    private String getFormattedTimestamp() {
        DateTime currentUtcDateTime = DateTime.now().addHours(-DateTime.now().hour()).addMinutes(-DateTime.now().minute()).addSeconds(-DateTime.now().second());
        return currentUtcDateTime.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
    }

    /**
    * @description Method is use to return the endpoint URL using in HTTP response.
    *
    * @return endpoint
    */
    @TestVisible
    protected override String getWebServiceEndPoint() {
        String endPoint;
        if (settings != null && String.isNotBlank(settings.CMN_NamedCredential__c)) {
            String path = String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c : CMN_UTIL_String.EMPTY;
            endPoint = String.format(
                NAMED_CREDENTIAL_URL_FORMAT,
                new List<String> {
                    settings.CMN_NamedCredential__c,
                    String.isNotBlank(path) ? path : CMN_UTIL_String.EMPTY,
                    ('?' + PRICE_SEGMENT_KEY + '=' + PRICE_SEGMENT_VALUE),
                    ('&' + formatCurrencyPairUrlSegment(this.currencyPairs))
                }
            );
        }
        return endPoint;
    }

    private String formatCurrencyPairUrlSegment(List<String> currencyPairs) {
        List<String> pairsFormatted = new List<String>();
            for(String pair : currencyPairs) {
                pair = 'currencyPairs='+ pair;
                pairsFormatted.add(pair);
            }
        return String.join(pairsFormatted, '&');
    }

    /**
	 * @description Call the parent objects' method to ensure we get code coverage
	 *
	 * @return
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock() {
		super.getEndpointMock();
		return new API_Mall_GetForeignExchangeRateMock();
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
    *
    * @return String
    */
    public override String getResponseBody()
    {
        return response.getBody();
    }

    /**
    * @description getStatusCode
    *
    * @return Integer
    */
    public Integer getStatusCode()
    {
        return response.getStatusCode();
    }

    /**
    * 
    * @description Mock class for Test classes
    */
    public class API_Mall_GetForeignExchangeRateMock extends CMN_API_HttpBaseOutboundMock
    {
        public final String validResponse = 	'{'+
		'  "instrumentation": ['+
		'    {'+
		'      "name": "GM-IR-REQ-REC",'+
		'      "timestamp": 1720085828425'+
		'    },'+
		'    {'+
		'      "name": "RS_RECEIVED_REQUEST",'+
		'      "timestamp": 1720085828438'+
		'    },'+
		'    {'+
		'      "name": "TIER_CACHE_REQUEST_RECEIVED",'+
		'      "timestamp": 1720085828439'+
		'    },'+
		'    {'+
		'      "name": "TIER_CACHE_RESPONSE_SENT",'+
		'      "timestamp": 1720085828439'+
		'    },'+
		'    {'+
		'      "name": "RS_PUBLISHING_RESPONSE",'+
		'      "timestamp": 1720085828440'+
		'    },'+
		'    {'+
		'      "name": "GM-IR-RESP-PUB",'+
		'      "timestamp": 1720085828442'+
		'    }'+
		'  ],'+
		'  "indicativeRates": ['+
		'    {'+
		'      "currencyPair": "USD/ZAR",'+
		'      "bidRate": 17.5038,'+
		'      "midRate": 18.202,'+
		'      "askRate": 18.9002,'+
		'      "lastUpdatedTimestamp": "2024-07-04T09:19:41.715Z"'+
		'    },'+
		'    {'+
		'      "currencyPair": "EUR/USD",'+
		'      "bidRate": 1.07255,'+
		'      "midRate": 1.0796,'+
		'      "askRate": 1.08665,'+
		'      "lastUpdatedTimestamp": "2024-07-04T09:36:51.379Z"'+
		'    },'+
		'    {'+
		'      "currencyPair": "GBP/INR",'+
		'      "bidRate": 103.0511,'+
		'      "midRate": 106.4606,'+
		'      "askRate": 109.87,'+
		'      "lastUpdatedTimestamp": "2024-07-04T09:37:01.573Z"'+
		'    }'+
		'  ]'+
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

    public class DTO_IndicativeRatesResponse {
        public DTO_Instrumentation[] instrumentation;
        public DTO_IndicativeRate[] indicativeRates;
    }

	public class DTO_Instrumentation {
		public String name;
		public Integer timestamp;
	}

	public class DTO_IndicativeRate {
		public String currencyPair;	
		public Double bidRate;	
		public Double midRate;	
		public Double askRate;	
		public String lastUpdatedTimestamp;
	}
}