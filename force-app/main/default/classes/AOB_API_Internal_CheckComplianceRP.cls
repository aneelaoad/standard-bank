/**
 * @description       : SFP-25088 : API class for checkComplaince
 * @author            : Tukelo Moseamo
 * @group             : 
 * @last modified on  : 07-03-2023
 * @last modified by  : Tukelo Moseamo
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-07-2023   Tukelo Moseamo   Initial Version
 * 
**/
public with sharing class AOB_API_Internal_CheckComplianceRP extends AOB_API_StaffAssistedOnboarding {
   
    public static final String SERVICE_NAME = AOB_API_Internal_CheckComplianceRP.class.getName();
	
    /**
	 * @description ApI Constructor
	 *
	 * @param applicationId 
	 */
    public AOB_API_Internal_CheckComplianceRP(String applicationId)	{
		application = new SEL_AOBApplication().selectAppsById(applicationId).iterator().next();
	}

    /**
	 * @description Override to set your request and response DTO types and any other globals you may have
	 */
	protected override void initialise() {
		super.initialise();
		baseResponseDTO = new DTO_Response();
		hasUserIdHeader = true;
	}
    /**
	 * @description The name of your service to be used when looking up custom settings for you service
	 *
	 * @return The name of the service
	 */
	protected override String getServiceName() {
		return SERVICE_NAME;
	}
    /**
	 * @description Will serialize requestDTO after its been populated.
	 *
	 * @return result
	 */
	protected override String getBody()	{
		super.getBody();
		return getRequestBody();
	}
    /**
	 * @description Method generates the request body
	 *
	 * @return request body json string
	 */
	private String getRequestBody()	{

		AOB_API_InternalPreApplication.DTO_PreApplicationResponse preApplicationResponse = (AOB_API_InternalPreApplication.DTO_PreApplicationResponse)JSON.deserialize(
				JSON.serialize(inflightDataMap.get(AOB_DTO_StaffAssistedOnboarding.PRE_APPLICATION_RESPONSE)),
				AOB_API_InternalPreApplication.DTO_PreApplicationResponse.class);
        
        AOB_DTO_Internal_CheckComplianceRP.DTO_CheckComplainceRPRequest checkComplaince = new AOB_DTO_Internal_CheckComplianceRP.DTO_CheckComplainceRPRequest();


        checkComplaince.businessBPID = preApplicationResponse?.cipcRegisteredDetails.businessDetails.businessBPID;
        checkComplaince.user = user;

        AOB_DTO_Internal_CheckComplianceRP.DTO_Request dtoRequest = new AOB_DTO_Internal_CheckComplianceRP.DTO_Request();
        dtoRequest.checkComplianceRPandShareholderRequest = checkComplaince;

        return JSON.serialize(dtoRequest);
    }
    
    public override String getResponseBody() {
        return response.getBody();
    }

	/**
	 * @description To get the endpoint from mock request
	 *
	 * @return CMN_API_HttpBaseOutboundMock
	 */
	protected override CMN_API_HttpBaseOutboundMock getEndpointMock()
	{
		return new AOB_API_Internal_CheckComplianceRPMock();
	}

	/**
	 * @description This is a Mock Response object used both in unit tests and when running service in mock mode
	 */
	public class AOB_API_Internal_CheckComplianceRPMock extends CMN_API_HttpBaseOutboundMock
	{
		@SuppressWarnings('PMD.FieldNamingConventions')
		private final String VALID_RESPONSE = '{"checkComplianceRPandShareholderResponse":{"orchestrationHeaderResponse":' + 
		'{"requestTimeStamp":"2023-06-06","responseTimeStamp":"2023-06-06","responseStatus":{"severity":"Info","serverStatusCode":' + 
		'"3","statusDescription":"Successful","statusCode":"200"}},"complianceData":[{"complianceStatus":"Fulfilled",' + 
		'"complianceTypeCode":"001","complianceTypeDescription":"KYC Requirements"},{"complianceStatus":"Yes","complianceTypeCode":' + 
		'"002","complianceTypeDescription":"Customer Role Exist"},{"complianceStatus":"No","complianceTypeCode":"003",' + 
		'"complianceTypeDescription":"Undesirable Status"},{"complianceStatus":"Fulfilled","complianceTypeCode":"005",' + 
		'"complianceTypeDescription":"CDPC - Customer Data Clean-up Status"},{"complianceStatus":"Fulfilled","complianceTypeCode":' + 
		'"004","complianceTypeDescription":"SARB Business Partner Status"},{"complianceStatus":"Fulfilled","complianceTypeCode":"012"' + 
		',"complianceTypeDescription":"SARB Related Party Status"},{"complianceStatus":"Approved","complianceTypeCode":"006",' + 
		'"complianceTypeDescription":"Sanction Status"},{"complianceStatus":"No","complianceTypeCode":"018","complianceTypeDescription"' + 
		':"Prominent Influential Persons (PIP)"},{"complianceStatus":"Continue Business","complianceTypeCode":"020",' + 
		'"complianceTypeDescription":"Customer Risk Assessment Status"},{"complianceStatus":"Approved","complianceTypeCode":"008",' + 
		'"complianceTypeDescription":"Fraud Status"},{"complianceStatus":"Yes","complianceTypeCode":"009","complianceTypeDescription"' + 
		':"Fraud Consent Given"},{"complianceStatus":"Fulfilled","complianceTypeCode":"013","complianceTypeDescription":"Pending ' + 
		'Relationship Compliance"},{"complianceStatus":"Fulfilled","complianceTypeCode":"014","complianceTypeDescription":"Pending ' + 
		'Account Role Compliance"},{"complianceStatus":"Fulfilled","complianceTypeCode":"015","complianceTypeDescription":"Existing ' + 
		'Relationship Compliance"},{"complianceStatus":"Fulfilled","complianceTypeCode":"016","complianceTypeDescription":"Existing ' + 
		'Account Role Compliance"},{"complianceStatus":null,"complianceTypeCode":null,"complianceTypeDescription":null},' + 
		'{"complianceStatus":null,"complianceTypeCode":null,"complianceTypeDescription":null}],"complianceIndicator":true}}';
		protected override void setResponse(HttpRequest request, HttpResponse response)
		{
			super.setResponse(request, response);
			response.setBody(VALID_RESPONSE);
		}
	}

    /**
	 * @description DTO class for http response
	 */
	public class DTO_Response extends CMN_DTO_JsonBase	{
		/**
		* @description checkComplianceRPandShareholderResponse
		*/
        @AuraEnabled
		public DTO_CheckComplianceRPResponse checkComplianceRPandShareholderResponse;

		/**
		 * @description The Type of the DTO used when deserializing the class
		 *
		 * @return Class of the DTO
		 */
		public override Type getObjectType()
		{
			return DTO_Response.class;
		}
	}

    /**
	 * @description checkComplaince response data transformation object
	 */
	public class DTO_CheckComplianceRPResponse	{
		/**
		* @description orchestrationHeaderResponse
		*/
        @AuraEnabled
        public DTO_OrchestrationHeaderResponse orchestrationHeaderResponse;
		/**
		* @description complianceData
		*/
		@AuraEnabled
        public List<DTO_ComplianceData> complianceData;
		/**
		* @description complianceIndicator
		*/
		@AuraEnabled
        public Boolean complianceIndicator;
		/**
		* @description sysError
		*/
        @AuraEnabled
        public String sysError;
		/**
		* @description customerFirstURL
		*/
		@AuraEnabled
		public String customerFirstURL;
	}

    /**
	 * @description checkComplaince response data transformation object
	 */
	public class DTO_OrchestrationHeaderResponse {
		/**
		* @description requestTimeStamp
		*/
		@AuraEnabled
		public String requestTimeStamp;
		/**
		* @description responseTimeStamp
		*/
		@AuraEnabled
		public String responseTimeStamp;
		/**
		* @description errorResponse
		*/
        @AuraEnabled
		public List<DTO_ErrorResponse> errorResponse;
	}

    /**
	 * @description checkComplaince response data transformation object
	 */
    public class DTO_ComplianceData {
		/**
		* @description complianceStatus
		*/
		@AuraEnabled
        public String complianceStatus;
		/**
		* @description complianceTypeCode
		*/
		@AuraEnabled
        public String complianceTypeCode;
		/**
		* @description complianceTypeDescription
		*/
        @AuraEnabled
		public String complianceTypeDescription;
	}

    /**
	 * @description checkComplaince response data transformation object
	 */
    public class DTO_ErrorResponse {
		public String stepStatus;
		/**
		* @description step
		*/
		public String step {get; set;}
		/**
		* @description responseMessage
		*/
		@AuraEnabled
		public String responseMessage{get; set;}
		
	}

}