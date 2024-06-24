/**
* @description  Class for Calling Set Digital API 
* @author Dayakar
* @date  11-12-2022 
* @Last Modified By  : Dayakar 
* @Last Modified On  : 19 APRIL 2024
* @Modification Description : SFP-37349
*/
public class AOB_API_SetDigital extends AOB_API_RestBaseOutboundPing {
    
    private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
   /**
    * @description constructor used to make sure a token will be provided to authenticate to the API call
    * @param applicationId
    */
    public string offeridset;
    public AOB_API_SetDigital(String applicationId)
    {
        List<AOB_Application__c> app= [select Id,AOB_SalesObjectId__c from AOB_Application__c where Id=:applicationId];
        offeridset=app[0].AOB_SalesObjectId__c; 
        this.accessToken = AOB_Utils.getAccessToken();
        this.jsonBody = JSON.serialize(AOB_DTO_CreateSetDigital.SetDigitalResponseBody(applicationId));
    }
    public static final String SERVICE_NAME = AOB_API_SetDigital.class.getName();
    
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
    
    private class DTO_Request extends CMN_DTO_JsonBase
    {
       /**
        * @description populates triggering object
        */
        @TestVisible
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
    */
    @TestVisible
    protected override virtual String getVerb()
    {
        return HTTP_VERB_PUT;
    }
    
    @TestVisible
    protected virtual override void setHeaders() 
    {
        
        setServiceSettings();
        request.setMethod(getVerb());
        request.setHeader(HTTP_CONTENT_TYPE, HTTP_ENCODING_JSON);
        request.setHeader(HTTP_HEADER_ACCEPT, HTTP_ENCODING_JSON);
		request.setHeader(HTTP_HEADER_CLIENT_ID, '{!$Credential.BCB_SA_API_SBGGatewayExternal.ClientId}');
        request.setHeader(HTTP_HEADER_CLIENT_SECRET, '{!$Credential.BCB_SA_API_SBGGatewayExternal.ClientSecret}');
		if(String.isNotBlank(settings.AOB_ClientCertificate__c)){
            request.setHeader(HTTP_HEADER_CERTIFICATE,settings.AOB_ClientCertificate__c);
			
        }
        request.setHeader(HTTP_HEADER_INTERACTIONID,AOB_Utils.generateGUID());
        request.setHeader(AOB_Constants.XSBGCHANNEL,settings.AOB_Channel__c);
        request.setHeader(HTTP_HEADER_AUTHORIZATION,AOB_Constants.BEARER+this.accessToken); 
        request.setTimeout(120000);
    }
    
    
    /**
    * @description Method is use to return the endpoint URL using in HTTP response.
    *
    * @return endpoint
    */
    @TestVisible
    protected override String getWebServiceEndPoint()
    {
        String endPoint;
        
        string path = String.isNotBlank(this.offeridset) ? '/' + this.offeridset : CMN_UTIL_String.EMPTY;
        if (settings != null && String.isNotBlank(settings.CMN_NamedCredential__c)) {
            path = String.isNotBlank(settings.CMN_Path__c) ? settings.CMN_Path__c + path : CMN_UTIL_String.EMPTY;
            endPoint = String.format(
                NAMED_CREDENTIAL_URL_FORMAT,
                new List<String>{
                    settings.CMN_NamedCredential__c,
                        String.isNotBlank(path) ? path : CMN_UTIL_String.EMPTY
                            }
            );
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
		return new SETDIGTALMock();
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
    
    
    public override String getResponseBody()
    {
        return response.getBody();
    }
    
    
    /**
    * @description Mock class for Test classes
    */
    public class SETDIGTALMock extends CMN_API_HttpBaseOutboundMock
    {
        public final String validResponse ='{'+
		'    "applicationID": "0045375115",'+
		'    "appStatus": ['+
		'        {'+
		'            "mainStatus": true,'+
		'            "statusCode": "E0041",'+
		'            "statusDesc": "Draft"'+
		'        }'+
		'    ],'+
		'    "initiatorUUID": "A142403",'+
		'    "channel": "Z009",'+
		'    "maintOfferId": "0600045723",'+
		'    "productItems": ['+
		'        {'+
		'            "expiryDate": "2022-11-08",'+
		'            "itemID": 100,'+
		'            "productID": "4648",'+
		'            "mainProduct": "R",'+
		'            "itemStatus": ['+
		'                {'+
		'                    "mainStatus": false,'+
		'                    "statusCode": "E0006",'+
		'                    "statusDesc": "Accepted"'+
		'                },'+
		'                {'+
		'                    "mainStatus": false,'+
		'                    "statusCode": "E0008",'+
		'                    "statusDesc": "Conditions Outstanding"'+
		'                },'+
		'                {'+
		'                    "mainStatus": true,'+
		'                    "statusCode": "E0071",'+
		'                    "statusDesc": "Draft"'+
		'                }'+
		'            ],'+
		'            "tnxDetails": {'+
		'                "priceOption": "ZMMB",'+
		'                "myUpdates": {'+
		'                    "recipientName": "KARABO MODISE",'+
		'                    "cellphone": null,'+
		'                    "email": "karabo.modise@standardbank.co.za",'+
		'                    "msgType": "E"'+
		'                }'+
		'            },'+
		'            "chequeCardDetails": null,'+
		'            "merchantDeviceDetails": null,'+
		'            "snapScanDetails": null'+
		'        },'+
		'        {'+
		'            "expiryDate": "2022-11-08",'+
		'            "itemID": 400,'+
		'            "productID": "ZBCH",'+
		'            "mainProduct": "X",'+
		'            "itemStatus": ['+
		'                {'+
		'                    "mainStatus": false,'+
		'                    "statusCode": "E0006",'+
		'                    "statusDesc": "Accepted"'+
		'                },'+
		'                {'+
		'                    "mainStatus": false,'+
		'                    "statusCode": "E0008",'+
		'                    "statusDesc": "Conditions Outstanding"'+
		'                },'+
		'                {'+
		'                    "mainStatus": false,'+
		'                    "statusCode": "E0033",'+
		'                    "statusDesc": "Txn acnt details not Active"'+
		'                },'+
		'                {'+
		'                    "mainStatus": true,'+
		'                    "statusCode": "E0071",'+
		'                    "statusDesc": "Draft"'+
		'                }'+
		'            ],'+
		'            "tnxDetails": null,'+
		'            "chequeCardDetails": {'+
		'                "cardOption": "4108",'+
		'                "deliveryDetail": {'+
		'                    "deliveryMethod": "F",'+
		'                    "deliveryBranch": null,'+
		'                    "deliveryBranchName": null,'+
		'                    "city": "JOHANNESBURG",'+
		'                    "streetNumber": null,'+
		'                    "streetName": null,'+
		'                    "province": "GP",'+
		'                    "postalCode": "2001"'+
		'                },'+
		'                "cardHolderUUID": null'+
		'            },'+
		'            "merchantDeviceDetails": null,'+
		'            "snapScanDetails": null'+
		'        },'+
		'        {'+
		'            "expiryDate": "2022-11-08",'+
		'            "itemID": 500,'+
		'            "productID": "4488",'+
		'            "mainProduct": "X",'+
		'            "itemStatus": ['+
		'                {'+
		'                    "mainStatus": false,'+
		'                    "statusCode": "E0006",'+
		'                    "statusDesc": "Accepted"'+
		'                },'+
		'                {'+
		'                    "mainStatus": false,'+
		'                    "statusCode": "E0008",'+
		'                    "statusDesc": "Conditions Outstanding"'+
		'                },'+
		'                {'+
		'                    "mainStatus": true,'+
		'                    "statusCode": "E0071",'+
		'                    "statusDesc": "Draft"'+
		'                }'+
		'            ],'+
		'            "tnxDetails": null,'+
		'            "chequeCardDetails": null,'+
		'            "merchantDeviceDetails": null,'+
		'            "snapScanDetails": null'+
		'        },'+
		'        {'+
		'            "expiryDate": "2022-11-08",'+
		'            "itemID": 600,'+
		'            "productID": "ZPOB",'+
		'            "mainProduct": "X",'+
		'            "itemStatus": ['+
		'                {'+
		'                    "mainStatus": false,'+
		'                    "statusCode": "E0006",'+
		'                    "statusDesc": "Accepted"'+
		'                },'+
		'                {'+
		'                    "mainStatus": false,'+
		'                    "statusCode": "E0008",'+
		'                    "statusDesc": "Conditions Outstanding"'+
		'                },'+
		'                {'+
		'                    "mainStatus": false,'+
		'                    "statusCode": "E0033",'+
		'                    "statusDesc": "Txn acnt details not Active"'+
		'                },'+
		'                {'+
		'                    "mainStatus": true,'+
		'                    "statusCode": "E0071",'+
		'                    "statusDesc": "Draft"'+
		'                }'+
		'            ],'+
		'            "tnxDetails": null,'+
		'            "chequeCardDetails": null,'+
		'            "merchantDeviceDetails": {'+
		'                "pricingOption": "ZPBP",'+
		'                "prodDetails": {'+
		'                    "merchantCategoryCode": "7996",'+
		'                    "businessEmailAddr": "tktrading@webmail.com",'+
		'                    "businessMobileNbr": "0839876543",'+
		'                    "businessTelephoneNbr": "0784585896",'+
		'                    "registrationEmailAddr": "karabo.modise@standardbank.co.za",'+
		'                    "accountNbr": "0000010006844276",'+
		'                    "merchantCategoryDesc": "AMUSEMENT PARKS, CARNIVALS, CIRCUSES",'+
		'                    "consents": null,'+
		'                    "numberOfDevices": 1,'+
		'                    "serviceDescription": "TRADING IN ENTERTAINMENT COMMODITIES",'+
		'                    "acceptAmExpressNum": null,'+
		'                    "acceptDinersNum": null,'+
		'                    "acceptRCSNum": null'+
		'                }'+
		'            },'+
		'            "snapScanDetails": null'+
		'        },'+
		'        {'+
		'            "expiryDate": "2022-11-08",'+
		'            "itemID": 700,'+
		'            "productID": "ZPSS",'+
		'            "mainProduct": "X",'+
		'            "itemStatus": ['+
		'                {'+
		'                    "mainStatus": false,'+
		'                    "statusCode": "E0006",'+
		'                    "statusDesc": "Accepted"'+
		'                },'+
		'                {'+
		'                    "mainStatus": false,'+
		'                    "statusCode": "E0008",'+
		'                    "statusDesc": "Conditions Outstanding"'+
		'                },'+
		'                {'+
		'                    "mainStatus": false,'+
		'                    "statusCode": "E0033",'+
		'                    "statusDesc": "Txn acnt details not Active"'+
		'                },'+
		'                {'+
		'                    "mainStatus": true,'+
		'                    "statusCode": "E0071",'+
		'                    "statusDesc": "Draft"'+
		'                }'+
		'            ],'+
		'            "tnxDetails": null,'+
		'            "chequeCardDetails": null,'+
		'            "merchantDeviceDetails": null,'+
		'            "snapScanDetails": {'+
		'                "pricingOption": "ZPSP",'+
		'                "snapscanDetails": {'+
		'                    "authPartner": null,'+
		'                    "businessName": "MAFIA INC",'+
		'                    "storeType": "O",'+
		'                    "accountNbr": "0000010006844276",'+
		'                    "authPersonIdNum": "6711205246099",'+
		'                    "authPersonName": "GAMBINO LUCCHESE",'+
		'                    "authPersonEmail": "gambino@standardbank.co.za",'+
		'                    "authPersonCell": "0834167890",'+
		'                    "businessEmail": "mafia@testemail.com",'+
		'                    "businessServiceDesc": "ANTIQUES",'+
		'                    "merchantCategoryCode": "5937",'+
		'                    "merchantCategoryDesc": "ANTIQUE REPRODUCTION STORES"'+
		'                }'+
		'            }'+
		'        }'+
		'    ]'+
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