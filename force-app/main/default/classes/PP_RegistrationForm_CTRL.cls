/**
 * @description  : Partner Portal Registration From Controller
 * User Story :
 *
 * @author Syed Ovais Ali (syed.ali@standardbank.co.za)
 * @date July 2021
 *  @last modified by  : Peter Guest
 */
public without sharing class PP_RegistrationForm_CTRL {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('PP_RegistrationForm_CTRL');

    /**
     * @description Used to Register a Partner
     * User Story : SFP-4874
     * @param registrationDetails
     * @return Partner Application record id
     **/
    @AuraEnabled
    public static String partnershipRegistration(PP_PartnerApplication__c registrationDetails) {

        String partnerApplicationId;

        try {
            UTL_Security.xssSanitize(
                registrationDetails, 
                new List<String>{ 'PP_Website__c', 'PP_LinkedInProfile__c', 'PP_FirstName__c', 'PP_LastName__c', 'Name' }
            );

            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType>{ PP_PartnerApplication__c.SObjectType });

            partnerApplicationId = PP_SRV_PartnerApplication.newInstance().savePartnerApplication(
                new List<PP_PartnerApplication__c>{ registrationDetails }, 
                uow
            );

            return partnerApplicationId;
        }
        catch(Exception e) {
            LOGGER.error('Exception while saving Partner Application record. ', e);
            throw new AuraHandledException(e.getMessage());
        }        
    }
    /**
     * @description Used to Update the Partner record on Contact detail back button
     * User Story : SFP-4874
     * @param registrationDetails
     * @return string of success
     *
     **/
    @AuraEnabled
    public static String partnershipRegistrationUpdate(PP_PartnerApplication__c registrationDetails) {

        try {
            UTL_Security.xssSanitize(
                registrationDetails, 
                new List<String>{ 'PP_Website__c', 'PP_LinkedInProfile__c', 'PP_FirstName__c', 'PP_LastName__c', 'Name' }
            );
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType>{ PP_PartnerApplication__c.SObjectType });

            uow.registerDirty(registrationDetails);
            uow.commitWork();
            return 'Success';
        }
        catch(Exception e) {
            LOGGER.error('Exception while saving Partner Application record. ', e);
            throw new AuraHandledException(e.getMessage());
        } 
    }

    /**
     * @description Used to Update a Partner
     * User Story : SFP-4874
     * @param registrationDetails
     * @param base64
     * @param filename
     * @return String
     **/
    @AuraEnabled
    public static String partnershipUpdate(PP_PartnerApplication__c registrationDetails, String base64, String filename) {

        String fileExtension;
        Boolean isValid = false;

        try {

            UTL_Security.xssSanitize(
                registrationDetails,
                new List<String>{ 'PP_Website__c', 'PP_LinkedInProfile__c', 'PP_FirstName__c', 'PP_LastName__c', 'Name', 'PP_PartnershipGoalOther__c', 'PP_RegistrationNumber__c', 'PP_SolutionDetails__c' }
            );

            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<SObjectType>{ PP_PartnerApplication__c.SObjectType });

            if (filename != null) {
                fileExtension = filename.substring(filename.lastIndexOf('.') + 1);
                isValid = UTL_Security.isValidFile(fileExtension, EncodingUtil.base64Decode(base64));
                if (isValid) {
                    filename = 'Solution Details.' + fileExtension;
                    ContentVersion cv = createContentVersion(base64, filename);
                    createContentLink(cv.Id, registrationDetails.Id);
                }
            }
            uow.registerDirty(registrationDetails);
            uow.commitWork();
            return 'Success';
        }
        catch(Exception e) {
            LOGGER.error('Exception while saving Partner Application record. ', e);
            throw new AuraHandledException(e.getMessage());
        }    
    }

    /**
     * @description Initialise OTP method from SRV_OTP class
     * @author : Areeba Khan
     * @param Id relatedRecordId
     * @return returns Response class
     **/
    @AuraEnabled
    public static SRV_OTP.Response initialiseOTPCode(Id relatedRecordId) {
        SRV_OTP.Response response = PP_SRV_PartnerApplication.newInstance().initialiseOTP(relatedRecordId);
        return response;
    }

    /**
     * @description Validate an OTP code
     * @author : Areeba Khan
     * @param string inputCode, string relatedRecordId
     * @return returns Response class
     **/
    @AuraEnabled
    public static SRV_OTP.Response validateOTPCode(string inputCode, string relatedRecordId) {
        SRV_OTP.Response response = PP_SRV_PartnerApplication.newInstance().validateOTPCode(inputCode, relatedRecordId);
        return response;
    }

    /**
     * @description Used to Create Content Version
     *
     * @param base64
     * @param filename
     * @return ContentVersion
     **/
    private static ContentVersion createContentVersion(String base64, String filename) {
        ContentVersion cv = new ContentVersion();
        cv.VersionData = EncodingUtil.base64Decode(base64);
        cv.Title = filename;
        cv.PathOnClient = filename;
        insert cv;
        return cv;
    }

    /**
     * @description Used to Create Content Link
     *
     * @param contentVersionId
     * @param recordId
     * @return ContentDocumentLink
     **/
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) {
            return null;
        }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :contentVersionId
        ]
        .ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        cdl.ShareType = 'V';
        insert cdl;
        return cdl;
    }

    /**
     * @description Used to Get Partner Details
     * User Story : SFP-4874
     * @return PP_PartnerApplication__c
     **/
    @AuraEnabled
    public static PP_PartnerApplication__c getPartnerDetails() {
        PP_PartnerApplication__c partner = new PP_PartnerApplication__c();
        Id userId = UserInfo.getUserId();
        List<Contact> contacts = SEL_Contacts.newInstance().selectByUserId(new Set<Id>{ userId });
        if (!contacts.isEmpty()) {
            partner = SEL_PartnerApplication.newInstance().selectByPrimaryContactId(new Set<Id>{ contacts[0].id })[0];
        }

        return partner;
    }
}