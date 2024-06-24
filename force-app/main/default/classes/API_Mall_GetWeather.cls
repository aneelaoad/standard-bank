/**
* 
* @description API_Mall_GetWeather
* @author Ankit Kumar 
* @since 03 Dec 2023
*/
 
public with sharing class API_Mall_GetWeather extends AOB_API_RestBaseOutboundPing
{
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
    public static final String SERVICE_NAME = API_Mall_GetWeather.class.getName();   
    private static final String QUERY_PARAM_LOCATION = 'location';
    private static final String QUERY_PARAM_APIKEY = 'key';
    private String location;
    
    /**
    * @description constructor used to make sure a token will be provided to authenticate to the API call
    * @param location String
    */
    public API_Mall_GetWeather(String location)
    {
        this.location = location;
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
        request.setHeader(CMN_API_HttpBase.HTTP_HEADER_ACCEPT, CMN_API_HttpBase.HTTP_ENCODING_JSON);
        request.setHeader(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_URL);
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
                new List<String>{
                    settings.CMN_NamedCredential__c,
                        String.isNotBlank(path) ? path : CMN_UTIL_String.EMPTY
                            }
            );
        }
        if(String.isNotBlank(settings.CMN_ApiKey__c)) {
            endPoint += '?' + QUERY_PARAM_APIKEY + '=' + settings.CMN_ApiKey__c;
        }
        if(String.isNotBlank(location)) {
            endPoint += '&aqi=yes&q=' + location;
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
		return new API_Mall_GetWeatherMock();
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
    public class API_Mall_GetWeatherMock extends CMN_API_HttpBaseOutboundMock
    {
        public final String validResponse =	'{'+
		'  "location": {'+
		'    "name": "London",'+
		'    "region": "City of London, Greater London",'+
		'    "country": "United Kingdom",'+
		'    "lat": 51.52,'+
		'    "lon": -0.11,'+
		'    "tz_id": "Europe/London",'+
		'    "localtime_epoch": 1572750327,'+
		'    "localtime": "2019-11-03 3:05"'+
		'  },'+
		'  "current": {'+
		'    "temp_c": 9,'+
		'    "temp_f": 48.2,'+
		'    "is_day": 0,'+
		'    "condition": {'+
		'      "text": "Clear",'+
		'      "icon": "//cdn.weatherapi.com/weather/64x64/night/113.png",'+
		'      "code": 1000'+
		'    },'+
		'    "wind_mph": 6.9,'+
		'    "wind_kph": 11.2,'+
		'    "wind_degree": 220,'+
		'    "wind_dir": "SW",'+
		'    "pressure_mb": 979,'+
		'    "pressure_in": 29.4,'+
		'    "precip_mm": 0,'+
		'    "precip_in": 0,'+
		'    "humidity": 81,'+
		'    "cloud": 0,'+
		'    "feelslike_c": 7.2,'+
		'    "feelslike_f": 45,'+
		'    "vis_km": 10,'+
		'    "vis_miles": 6,'+
		'    "uv": 0,'+
		'    "gust_mph": 16.3,'+
		'    "gust_kph": 26.3'+
		'  },'+
		'  "forecast": {'+
		'    "forecastday": ['+
		'      {'+
		'        "date": "2019-11-03",'+
		'        "date_epoch": 1572739200'+
		'      }'+
		'    ]'+
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