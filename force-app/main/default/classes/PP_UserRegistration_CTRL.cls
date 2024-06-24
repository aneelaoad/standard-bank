/**
 * @description       : SFP-19834  Controller to handle the LWC calls
 * @author            : Peter Guest
 * @group             : CloudSmiths
 * @last modified on  : 02-08-2024
 * @last modified by  : Jaco de Lange
 */
public with sharing class PP_UserRegistration_CTRL {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('PP_UserRegistration_CTRL');
    private static final String ERROR_MSG_FAILED_INVITE = 'Failed to send an invite due to technical issue.';
    private static final String ERROR_MSG_INVALID_LINK = 'User registration link not valid, expired or there was a technical issue.';
    private static final String ERROR_MSG_INVALID_EMAIL = 'Provided email address does not match invitation or there was a technical issue.';
    private static final String ERROR_MSG_INVALID_REGISTER = 'User registration failed or there was a technical issue.';

    /**
     * @description Called from the "Send Registration Invite" button and launched in a flow.
     * @author Peter Guest | 05-05-2023
     * @param contactId
     * @return Boolean
     */
    @AuraEnabled
    public static Boolean sendRegistrationInvitation(String contactId) {
        try {
            SRV_Encryption encryptionService = (SRV_Encryption) SRV_Encryption.newInstance().initialise('Partner_Connect_User_Registration');
            Partner_Connect_Setting__mdt setting = Partner_Connect_Setting__mdt.getInstance('Default');
            List<EmailTemplate> emailTemplates = SEL_EmailTemplate.newInstance().selectByDeveloperName(setting.Registration_Email_Template__c);
            List<Contact> contacts = SEL_Contacts.newInstance().selectById(new Set<Id>{ contactId });

            //Construct invite to be encrypted.
            Invitation invite = new Invitation(
                contactId,
                contacts.get(0).Email,
                contacts.get(0).FirstName,
                contacts.get(0).LastName,
                contacts.get(0).MobilePhone,
                System.now().addHours(Integer.valueOf(setting.Registration_Validity_Period_Hours__c))
            );

            String encryptedInvite = encryptionService.encryptWithManagedIV(JSON.serialize(invite));
            String registrationUrl = setting.Registration_URL__c + '?id=' + encryptedInvite;

            //Send email.
            Messaging.reserveSingleEmailCapacity(1);
            Messaging.SingleEmailMessage theEmail = Messaging.renderStoredEmailTemplate(emailTemplates.get(0).Id, contactId, null);
            theEmail.setSaveAsActivity(true);
            String emailBody = theEmail.getHtmlBody();
            emailBody = emailBody.replaceFirst('##registration_url##', registrationUrl);
            theEmail.setHtmlBody(emailBody);
            Messaging.SendEmailResult[] result = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ theEmail });
            return result.get(0).isSuccess();
        }
        catch(Exception e) {
            LOGGER.error('Exception while sending an invite. ', e);
            throw new CustomException(ERROR_MSG_FAILED_INVITE);
        }
        
    }

    /**
     * @description check if the link is expired or not
     * @author Peter Guest | 05-05-2023
     * @param linkIdParameter
     * @return Invitation class
     */
    @AuraEnabled
    public static Invitation validateLink(String linkIdParameter) {
        
        try {
            if (String.isBlank(linkIdParameter)) {
                throw new IllegalArgumentException('Invalid parameter provided for linkIdParameter.');
            }

            SRV_Encryption encryptionService = (SRV_Encryption) SRV_Encryption.newInstance().initialise('Partner_Connect_User_Registration');
            String decryptedInvite = encryptionService.decryptWithManagedIV(linkIdParameter);
            Invitation invite = (Invitation) JSON.deserialize(decryptedInvite, Invitation.class);

            if (System.now() > invite.expiresAt) {
                throw new CustomException('User registration link expired.');
            }

            return invite;
        } 
        catch (Exception e) {
            LOGGER.error('Exception while validating link. ', e);
            throw new CustomException(ERROR_MSG_INVALID_LINK);
        }
    }

    /**
     * @description validate email address upon entering to the text field
     * @author Peter Guest | 05-05-2023
     * @param linkIdParameter
     * @param emailAddress
     * @return Boolean
     */
    @AuraEnabled
    public static Boolean validateEmailAddress(String linkIdParameter, String emailAddress) {

        Boolean isExisting = false;

        if (String.isBlank(linkIdParameter)) {
            throw new IllegalArgumentException('Invalid parameter provided for linkIdParameter.');
        }

        try {
            SRV_Encryption encryptionService = (SRV_Encryption) SRV_Encryption.newInstance().initialise('Partner_Connect_User_Registration');
            String decryptedInvite = encryptionService.decryptWithManagedIV(linkIdParameter);
            Invitation invite = (Invitation) JSON.deserialize(decryptedInvite, Invitation.class);

            if (invite.emailAddress != emailAddress) {
                throw new CustomException('Provided email address does not match invitation.');
            }
            
            PP_SRV_PING api = (PP_SRV_PING) PP_SRV_PING.newInstance();
            PP_IntegrationResult result = api.searchCustomer(emailAddress);

            if (result.isSuccess()) {

                PP_SRV_PING.PingResult searchResult = (PP_SRV_PING.PingResult)result;

                if (searchResult.size >= 1) {
                    isExisting = true;
                }
            } 
            else {
                throw new CustomException(ERROR_MSG_INVALID_EMAIL);
            }

            return isExisting;
        } 
        catch (Exception e) {
            LOGGER.error('Exception while validating email address. ', e);
            throw new CustomException(ERROR_MSG_INVALID_EMAIL);
        }
    }

    /**
     * @description Register new user to the Ping system
     * @author Areeba Khan
     * @param registrationFormData
     * @return PP_IntegrationResult
     */
    @AuraEnabled
    public static PP_IntegrationResult registerUser(Map<String, String> registrationFormData) {

        try {
            PP_SRV_PING api = (PP_SRV_PING) PP_SRV_PING.newInstance();
            PP_IntegrationResult result = api.registerUser(registrationFormData);
            
            if (result.resultStatus == PP_IntegrationResult.FAILED) {
                throw new CustomException(ERROR_MSG_INVALID_REGISTER);
            } 
            return result;
        }
        catch (Exception e) {
            LOGGER.error('Exception while registering user. ', e);
            throw new CustomException(e.getMessage());
        }
    }

    /**
     * @description Register new user to the Ping system
     * @author            : Peter Guest
     * @group             : CloudSmiths
     */
    public class Invitation {
        @AuraEnabled
        public String contactId;
        @AuraEnabled
        public String emailAddress;
        @AuraEnabled
        public String firstName;
        @AuraEnabled
        public String lastName;
        @AuraEnabled
        public String mobile;
        @AuraEnabled
        public DateTime expiresAt;

        /**
         * @description       : Register new user to the Ping system
         * @param             : contactId
         * @param             : emailAddress
         * @param             : firstName
         * @param             : lastName
         * @param             : mobile
         * @param             : expiresAt
         * @author            : Peter Guest
         * @group             : CloudSmiths
         */
        public Invitation(String contactId, String emailAddress, String firstName, String lastName, String mobile, DateTime expiresAt) {
            this.contactId = contactId;
            this.emailAddress = emailAddress;
            this.firstName = firstName;
            this.lastName = lastName;
            this.mobile = mobile;
            this.expiresAt = expiresAt;
        }
    }

    /**
     * @description Returns the outcome
     * @author            : Peter Guest
     * @group             : CloudSmiths
     */
    public class RegisterOutcome {
        public String status;
        public String message;
    }

    private class CustomException extends Exception {
    }
}