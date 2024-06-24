/**
 * @description       : Salesforce OTP Request class.
 *                      Refer to the "OTP Request Settings" Custom Metadata Type for setup.
 * @author            : Peter Guest
 * @group             : CloudSmiths
 * @last modified on  : 13-03-2023
 * @last modified by  : Peter Guest
 **/
public without sharing class SRV_OTP implements IService {
    
    private SEL_OTPRequest otpSelector;
    private Boolean isInitialised = false;
    private Id relatedRecordId;
    private OTP_Request_Setting__mdt setting;
    private String recipientEmailAddress;
    private String relatedRecordCustomField1;
    private String relatedRecordCustomField2;
    private String relatedRecordCustomField3;
    private final String charSETNUM = 'Numeric';
    private final String charSETALPHA = 'Alphanumeric';
    private OTPRequest__c otpRequest;
    private Response response;

    private final String msgEXCEEDATTEMPT = 'Number of attempts exceeded, please try again later.';
    private final String msgEXCEEDREQUEST = 'Number of requests exceeded, please try again later.';
    private final String msgCODEINVALID = 'Invalid code, please try again.';
    private final String msgCODEEXPIRED = 'Invalid code, request a new code.';
    private final String msgLocked = 'Access locked temporarily, please try again later.';

    /**
     * @description Class singleton approach to call it.
     * @author Peter Guest | 13-02-2023
     * @return IService
     **/
    public static IService newInstance() {
        return (IService) ORG_Application.service.newInstance(IService.class);
    }

    /**
     * @description Class interface to expose callable methods.
     * @author Peter Guest | 03-03-2023
     * @param settingName
     * @param relatedRecordId
     * @param ;
     * @return interface
     **/
    public interface IService {
        /**
         * @description Sets up the service class and handles input parameters checks and validations.
         * @author Peter Guest | 10-02-2023
         * @param String settingName
         * @param String relatedRecordId
         * @return IService
         **/
        IService initialise(String settingName, Id relatedRecordId);

        /**
         * @description Used to the request or resend an OTP code.  Does at relevant checks to make sure we can fulfil it.
         * @author Peter Guest | 10-02-2023
         * @return Response
         **/
        Response requestCode();

        /**
         * @description Validates if the provided code matches the one specified on the OTP Request.
         * @author Peter Guest | 10-02-2023
         * @param String inputCode
         * @return Response
         **/
        Response validateCode(String inputCode);
    }

    /**
     * @description Sets up the service class and handles input parameters checks and validations.
     * @author Peter Guest | 10-02-2023
     * @param String settingName
     * @param String relatedRecordId
     * @return IService
     **/
    public IService initialise(String settingName, Id relatedRecordId) {
        this.otpSelector = SEL_OTPRequest.newInstance();
        this.response = new Response();

        //Paramater checks to make sure we have everything we need, and control usage of the service.
        if (String.isEmpty(settingName) || String.isEmpty(relatedRecordId)) {
            throw new SRV_OTPException('Invalid parameters, you must specify a "settingName", "relatedRecordId".');
        }

        this.setting = OTP_Request_Setting__mdt.getInstance(settingName);
        this.relatedRecordId = relatedRecordId;

        populateMergeFields();

        this.isInitialised = true;

        return this;
    }

    /**
     * @description Used to the request or resend an OTP code.  Does at relevant checks to make sure we can fulfil it.
     * @author Peter Guest | 10-02-2023
     * @return Response
     **/
    public Response requestCode() {
        Boolean isValid = true;

        checkInitialised();
        loadRequest();

        if (this.otpRequest == null) {
            generateNewRequest();
        }

        //Handle Locked
        if (isLocked()) {
            markResponseFailed(msgLocked);
            return this.response;
        }

        //Handle Request Limits
        if (requestLimitExceeded()) {
            isValid = false;
            this.otpRequest.Locked__c = true;
            this.otpRequest.LockExpiresAt__c = System.now().addMinutes(Integer.valueOf(this.setting.LockDurationMinutes__c));
            this.otpRequest.Requests__c = 0;
            this.otpRequest.Attempts__c = 0;
            this.otpRequest.Validated__c = false;
            this.otpRequest.ValidatedAt__c = null;
            markResponseFailed(msgEXCEEDREQUEST);
        }

        //Handle code expiry and refresh code.
        if (isValid) {
            this.otpRequest.Requests__c = this.otpRequest.Requests__c + 1;
            this.otpRequest.Send__c = true;
            this.otpRequest.Locked__c = false;
            this.otpRequest.LockExpiresAt__c = null;

            if (isCodeExpired()) {
                refreshCode();
            }
        }
        upsert this.otpRequest;
        return this.response;
    }

    /**
     * @description Validates if the provided code matches the one specified on the OTP Request.
     * @author Peter Guest | 10-02-2023
     * @param String inputCode
     * @return Response
     **/
    public Response validateCode(String inputCode) {
        Boolean withinLimits = true;

        checkInitialised();
        loadRequest();

        if (this.otpRequest == null) {
            markResponseFailed(msgCODEEXPIRED);
            return this.response;
        }

        if (isLocked()) {
            markResponseFailed(msgLocked);
            return this.response;
        }

        if (attemptLimitExceeded()) {
            withinLimits = false;
            this.otpRequest.Locked__c = true;
            this.otpRequest.LockExpiresAt__c = System.now().addMinutes(Integer.valueOf(this.setting.LockDurationMinutes__c));
            this.otpRequest.Requests__c = 0;
            this.otpRequest.Attempts__c = 0;
            this.otpRequest.Validated__c = false;
            this.otpRequest.ValidatedAt__c = null;
            markResponseFailed(msgEXCEEDATTEMPT);
        }

        if (withinLimits) {
            this.otpRequest.Attempts__c = this.otpRequest.Attempts__c + 1;

            if (isCodeExpired()) {
                markResponseFailed(msgCODEEXPIRED);
            } else if (this.otpRequest.Code__c != inputCode.deleteWhiteSpace()) {
                markResponseFailed(msgCODEINVALID);
            } else {
                this.otpRequest.Validated__c = true;
                this.otpRequest.ValidatedAt__c = System.now();
            }
        }

        upsert this.otpRequest;

        return this.response;
    }

    /**
     * @description Queries and copies down values from related records to custom fields defined in metadata.
     * @author Peter Guest | 02-03-2023
     **/
    private void populateMergeFields() {
        //Build dynamic query based in setting fields defined to retrieve data.
        fflib_QueryFactory factory = new fflib_QueryFactory(this.relatedRecordId.getSobjectType());
        factory.setCondition('Id = :relatedRecordId');

        if (!String.isBlank(this.setting.RecipientEmailAddressField__c)) {
            factory.selectField(this.setting.RecipientEmailAddressField__c);
        }

        if (!String.isBlank(this.setting.Custom1Field__c)) {
            factory.selectField(this.setting.Custom1Field__c);
        }

        if (!String.isBlank(this.setting.Custom2Field__c)) {
            factory.selectField(this.setting.Custom2Field__c);
        }

        if (!String.isBlank(this.setting.Custom3Field__c)) {
            factory.selectField(this.setting.Custom3Field__c);
        }

        List<sObject> results = Database.query(factory.toSOQL());

        if (results.size() == 0) {
            throw new SRV_OTPException('Specified "relatedRecordId" record was not found.');
        } else {
            sObject result = results.get(0);
            this.recipientEmailAddress = (String) result.get(this.setting.RecipientEmailAddressField__c);
            this.relatedRecordCustomField1 = !String.isBlank(this.setting.Custom1Field__c) ? (String) result.get(this.setting.Custom1Field__c) : null;
            this.relatedRecordCustomField2 = !String.isBlank(this.setting.Custom2Field__c) ? (String) result.get(this.setting.Custom2Field__c) : null;
            this.relatedRecordCustomField3 = !String.isBlank(this.setting.Custom3Field__c) ? (String) result.get(this.setting.Custom3Field__c) : null;
        }
    }

    /**
     * @description Ensure the initialise method is called, so that we can setup the correct parameters.
     * @author Peter Guest | 10-02-2023
     **/
    private void checkInitialised() {
        if (!isInitialised) {
            throw new SRV_OTPException('Service not initialised. Please call the "initialise" method first.');
        }
    }

    /**
     * @description Retrieved existing an OTP Request or creates a new one for a related record ID.
     * @author Peter Guest | 02-03-2023
     **/
    private void loadRequest() {
        List<OTPRequest__c> otpRequests = this.otpSelector.selectByRelatedRecordId(this.relatedRecordId);
        this.otpRequest = !otpRequests.isEmpty() ? otpRequests.get(0) : null;
    }

    /**
     * @description Generates a new OTP Request record with the respective settings and related defaulting.
     * @author Peter Guest | 06-03-2023
     **/
    private void generateNewRequest() {
        OTPRequest__c newRequest = new OTPRequest__c(
            RelatedRecordID__c = this.relatedRecordId,
            RecipientEmailAddress__c = this.recipientEmailAddress,
            CustomField1__c = this.relatedRecordCustomField1,
            CustomField2__c = this.relatedRecordCustomField2,
            CustomField3__c = this.relatedRecordCustomField3,
            CodeExpiresAt__c = System.now().addSeconds(Integer.valueOf(this.setting.CodeDurationSeconds__c)),
            Code__c = generateCode(),
            Attempts__c = 0,
            Requests__c = 0,
            Validated__c = false,
            ValidatedAt__c = null,
            Locked__c = false,
            LockExpiresAt__c = null
        );

        this.otpRequest = newRequest;
    }

    /**
     * @description Resets the code and code expiration on the record.
     * @author Peter Guest | 02-03-2023
     **/
    private void refreshCode() {
        this.otpRequest.Code__c = generateCode();
        this.otpRequest.CodeExpiresAt__c = System.now().addSeconds(Integer.valueOf(this.setting.CodeDurationSeconds__c));
        this.otpRequest.Attempts__c = 0;
        this.otpRequest.Validated__c = false;
        this.otpRequest.ValidatedAt__c = null;
    }

    /**
     * @description Checks if an OTP Request has exceeded request limit.
     * @author Peter Guest | 02-03-2023
     * @return Boolean
     **/
    private Boolean requestLimitExceeded() {
        if (this.otpRequest.Requests__c < this.setting.RequestLimit__c) {
            return false;
        }

        return true;
    }

    /**
     * @description Checks if an OTP Request has exceeded attempt limit.
     * @author Peter Guest | 02-03-2023
     * @return Boolean
     **/
    private Boolean attemptLimitExceeded() {
        if (this.otpRequest.Attempts__c < this.setting.AttemptLimit__c) {
            return false;
        }

        return true;
    }

    /**
     * @description Checks if an OTP Request is locked.
     * @author Peter Guest | 10-02-2023
     * @return Boolean
     **/
    private Boolean isLocked() {
        Boolean isLocked = false;

        if (this.otpRequest.LockExpiresAt__c != null && this.otpRequest.LockExpiresAt__c >= System.now()) {
            isLocked = true;
        }

        return isLocked;
    }

    /**
     * @description Checks if an OTP Request code has expired.
     * @author Peter Guest | 02-03-2023
     * @return Boolean
     **/
    private Boolean isCodeExpired() {
        if (System.now() >= this.otpRequest.CodeExpiresAt__c) {
            return true;
        }

        return false;
    }

    /**
     * @description Generates a new OTP Request code.
     * @author Peter Guest | 02-03-2023
     * @return String
     **/
    private String generateCode() {
        if (this.setting.CodeCharacterSet__c == charSETALPHA) {
            return CMN_UTIL_Random.randomAlphanumeric(Integer.valueOf(this.setting.CodeCharacterLength__c)).toUpperCase();
        } else {
            return CMN_UTIL_Random.randomNumeric(Integer.valueOf(this.setting.CodeCharacterLength__c));
        }
    }

    /**
     * @description Marks the reponse to failed with a status message.
     * @author Peter Guest | 03-03-2023
     * @param message
     **/
    private void markResponseFailed(String message) {
        this.response.isSuccess = false;
        this.response.message = message;
    }

    /**
     * @description Response wrapper class for response handling
     * @author Peter Guest | 03-03-2023
     **/
    public class Response {        

        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String message;
        @AuraEnabled public String token;

        /**
         * @description Response wrapper class constructor
         * @author Peter Guest | 03-03-2023
         **/
        public Response() {
            this.isSuccess = true;
        }
    }

    /**
     * @description Custom Exception class
     * @author Peter Guest | 03-03-2023
     **/
    public class SRV_OTPException extends Exception {
    }
}