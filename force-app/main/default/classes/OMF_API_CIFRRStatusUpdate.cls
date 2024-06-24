/**
* @description RestResource Class for Handling Managed Fund Global CIF Approval
* @author Raja Kumar
* @company Absyz
* @test Class OMF_CIFRRStatusUpdate_Test
* @JIRA Tickets SFP-32673
*/
@RestResource(urlMapping='/omf/cif-rr-status-update')
global with sharing class OMF_API_CIFRRStatusUpdate extends CMN_API_HttpBase{
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
    /**
* @description HttpPatch method to get the relationship record id from CIF system number
*/
    @HttpPatch
    global static void updateStatusOfManagedFund(){
        RestRequest request = RestContext.request;
        String jsonResponse=request.requestbody.tostring();
        baseResponseDTO=SRV_OMF_CIFStatusUpdate.processInboundRequest((DTO_Response)baseResponseDTO.deserialize(jsonResponse));
        if(baseResponseDTO.SUCCESS!=null){
            createJsonResponse(CMN_API_HttpBase.HTTP_OK);
            return;
        }else if(baseResponseDTO.ERROR!=null){
            createJsonResponse(CMN_API_HttpBase.HTTP_BAD_REQUEST);
            return;
        }
        
    }
    /**
* @description class for handling the response payload
*/
    public class DTO_Response extends CMN_DTO_JsonBase
    {
        Public String parentCifId;
        Public String childCifId;
        Public String relationshipTypeId;
        Public String relationshipShortName;
        Public String requestStatusCode;
        Public String authUser;
        Public String relationshipCIFId;
        Public String relationshipOSDId;
        //suppressed this PMD because the payload expects the variable in capital letters
        @SuppressWarnings('PMD.FieldNamingConventions')
        Public String ERROR;
        //suppressed this PMD because the payload expects the variable in capital letters
        @SuppressWarnings('PMD.FieldNamingConventions')
        Public String SUCCESS;
        /**
* @description The Type of the DTO used when deserializing the class
*
* @return Class of the DTO
*/
        protected override Type getObjectType()
        {
            Return OMF_API_CIFRRStatusUpdate.DTO_Response.class;
        }
    }
}