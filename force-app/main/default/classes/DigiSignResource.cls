/**
*
* @author Emmanuel Mulea Nocks(BlueSky)
* @date June 2020
* @description an API resource class
*/
@SuppressWarnings('PMD.ExcessivePublicCount')
@RestResource(urlMapping='/bpm/v1/digisignfeedback')
global with sharing class DigiSignResource {
    private static final String SUCCESS_STATUS = 'Successfully updated';
    private static final Integer OK_CODE = 200;
    private static final Integer SERVER_ERROR_CODE = 500;

    /**
    * an Exposed post endpoint to be consumed by other systems
    *
    */
    @HttpPOST
    global static void doPost(){
        RestResponse res = RestContext.response;
        string reqBody = RestContext.request.requestBody.toString();
        ResponseWrapper resWrapper = new ResponseWrapper();
        resWrapper.notifyChannelRs =new NotifyChannelRs();
        resWrapper.notifyChannelRs.statusDetails = new StatusDetails();
        RequestWrapper objResponseBody;
        res.addHeader('Content-Type', 'application/json');

        try {

            objResponseBody = (RequestWrapper) JSON.deserialize(reqBody, RequestWrapper.class);
            DigiSignService.updateOnboardRecords(objResponseBody);
            resWrapper.notifyChannelRs.statusDetails.statusCode = String.valueOf(OK_CODE);
            resWrapper.notifyChannelRs.statusDetails.processState = SUCCESS_STATUS;
            resWrapper.notifyChannelRs.statusDetails.statusDescription = SUCCESS_STATUS;
            res.responseBody = Blob.valueOf(JSON.serialize(resWrapper));
            res.statusCode = OK_CODE;
        }
        catch (Exception ex){
            List<Onboarding_Application__c> onboardRecord = new SEL_OnboardingApplications().selectById(
                new Set<Id>{objResponseBody.callBackRequest.headerDetails.requestCorrelation});
            String clientId = onboardRecord.isEmpty()? null:onboardRecord[0].Client__c;
            String statusDescription = onboardRecord.isEmpty()? DigiSignService.NO_ONBOARD_RECORD_ERROR:ex.getMessage();
            resWrapper.notifyChannelRs.statusDetails.statusCode = String.valueOf(SERVER_ERROR_CODE);
            resWrapper.notifyChannelRs.statusDetails.statusDescription = statusDescription;
            resWrapper.notifyChannelRs.statusDetails.errorDetails = String.valueOf(ex);
            res.responseBody = Blob.valueOf(JSON.serialize(resWrapper));
            res.statusCode = SERVER_ERROR_CODE;
            SRV_Logger.newInstance().log(ex, DMN_Log.AREA_COMMB, DigiSignResource.class.getName());
            DigiSignConsent.sendCalloutExceptionEmail(clientId, ex.getMessage());
        }
        
    }

    /**
    * @description Inner class to handle exceptions
    */
    public class DigiSignResourceException extends Exception{}

    /**
    * @description Inner class to wrap Response Object
    */
    public class Response {
        public String status;
        public String statusDescription;
    }

    /**
    * @description Inner class to wrap SystemDetails Object
    */
    public class SystemDetails {
        public String productId;
        public String additionalInfo;
        public String productName;
    }

    /**
    * @description Inner class to wrap SignatoryApprovalDetails Object
    */
    public class SignatoryApprovalDetails {
        
        public String bpid;
        public String approvalStatus;
        public String firstName;
        public String lastName;
        public String emailAddress;
        public String mobileNumber;
        public String approvalTimeStamp;
        public String declineReason;
    }

    /**
    * @description Inner class to wrap HeaderDetails Object
    */
    public class HeaderDetails {
        public String requestCorrelation;
        public String callBackUrl;
        public String applicationContent;
        public String digitalId;
        public String sourceSystemId;
        public String businessFunction;
        public SystemDetails systemDetails;
        public String accessToken;
        public String channelId;
        public AuthenticationDetails authenticationDetails;
        public String requestTraceId;
    }

    /**
    * @description Inner class to wrap RequestWrapper Object
    */
    public class RequestWrapper{
        public CallBackRequest callBackRequest;
    }

    /**
    * @description Inner class to wrap DocumentDetails Object
    */
    public class DocumentDetails {
        public String documentType;
        public String documentLink;
        public String documentName;
        public String documentGUID;
    }

    /**
    * @description Inner class to wrap DigiSignStatus Object
    */
    public class DigiSignStatus {
        public String statusDescription;
        public String statusCode;
    }

    /**
    * @description Inner class to wrap CallBackRequest Object
    */
    public class CallBackRequest {
        public List<DocumentDetails> documentDetails;
        public HeaderDetails headerDetails;
        public List<SignatoryApprovalDetails> signatoryApprovalDetails;
        public DigiSignStatus digiSignStatus;
    }

    /**
    * @description Inner class to wrap AuthenticationDetails Object
    */
    public class AuthenticationDetails {
        public String acceptContentType;
        public String authenticationType;
        public String tokenType;
        public String userName;
        public String contentType;
        public String authenticationToken;
    }

    /**
    * @description Inner class to wrap ResponseWrapper Object
    */
    public class ResponseWrapper{
        public NotifyChannelRs notifyChannelRs;
    }

    /**
    * @description Inner class to wrap NotifyChannelRs Object
    */
    public class NotifyChannelRs {
        public StatusDetails statusDetails;
    }

    /**
    * @description Inner class to wrap StatusDetails Object
    */
    public class StatusDetails {
        public String statusDescription;
        public String processState;
        public String statusReasonDescription;
        public String statusReasonCode;
        public String statusCode;
        public String errorDetails;
    }
}