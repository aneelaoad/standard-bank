/**
* @description  RestResource Class for Handling Managed Fund KYC Rejection
* @author Manisha
* @company Absyz
* @test Class OMF_KYCRejection_Test
* @JIRA Tickets    SFP-18381
*************************************************************************
* @description updated the class as per integration framwork
* @author Raja
* @company Absyz
* @test Class OMF_API_KYCApproval_Test
* @JIRA Tickets     SFP-32673
*/
@RestResource(urlMapping='/omf/kyc-reject')
global with sharing class OMF_API_KYCRejection extends CMN_API_HttpBase{
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('OMF_API_KYCRejection');
    private static DTO_Response baseResponseDTO=new DTO_Response();
    /**
* @description method to build the response for the request received
* @param responseCode
*/
    private static void createJsonResponse(Integer responseCode){
        RestContext.response.responseBody = Blob.valueOf(baseResponseDTO.serialize());
        RestContext.response.addHeader(CMN_API_HttpBase.HTTP_CONTENT_TYPE,CMN_API_HttpBase.HTTP_ENCODING_JSON);
        RestContext.response.statusCode = responseCode;
    }
    @HttpPatch
    /**
* @description Update the rejection details
*/
    global static void updateStatusOfManagedFund(){
        
        RestRequest req = RestContext.request;
        baseResponseDTO=SRV_OMF_KYCStatusUpdate.processInboundRequestFromKYCRejection((DTO_Response)baseResponseDTO.deserialize(req.requestbody.tostring()));
        if(baseResponseDTO.SUCCESS!=null){
            createJsonResponse(CMN_API_HttpBase.HTTP_OK);
            return;
        }else if(baseResponseDTO.ERROR=='Server Error'){
            createJsonResponse(CMN_API_HttpBase.HTTP_INTERNAL_SERVER_ERROR);
        }
        else if(baseResponseDTO.ERROR!=null || baseResponseDTO.FAILURE!=null){
            createJsonResponse(CMN_API_HttpBase.HTTP_BAD_REQUEST);
            return;
        }
    }
    /**
* @description class for handling the response payload
*/
    //suppressed this PMD because the payload expects the variable in capital letters
    @SuppressWarnings('PMD.FieldNamingConventions')
    public class DTO_Response extends CMN_DTO_JsonBase
    {
        public String SalesforceId;
        public String CIFID;
        public String FAILURE;
        public String ERROR;
        public String SUCCESS;
        public String RejectionReason;
        public String RejectionDetails;
        public String KYCAnalyst;
        public String Notes;
        /**
* @description The Type of the DTO used when deserializing the class
* @return Class of the DTO
*/
        protected override Type getObjectType()
        {
            Return OMF_API_KYCRejection.DTO_Response.class;
        }
    }
}