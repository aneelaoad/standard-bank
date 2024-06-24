/**
 * 
 * @description MallTenantRegisterCompleteNotification
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallTenantRegisterCompleteNotification {
    
    //global instance of rf lib logger
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('MallTenantRegisterCompleteNotification');
   
    /**
     * @description ApexType wrapper for MallTenantRegistrationEmailRequest
     */
    public class MallTenantRegistrationEmailRequest {
        @InvocableVariable
        public String emailTemplateName;

        @InvocableVariable
        public String contactId;
    }

    /**
    * 
    * @description sendEmailForTenantRegistrationCompletion : Mall Tenant Registration Completion Notification
    * @param requests List of MallTenantRegistrationEmailRequest
    * @exception AuraHandledException
    */
    @InvocableMethod(label='Mall Tenant Registration Completion Notification')
    public static void sendEmailForTenantRegistrationCompletion(List<MallTenantRegistrationEmailRequest> requests) { 
        try{
            List<String> contactIds = new List<String>();
            String emailTemplateName = requests[0].emailTemplateName;
            for(MallTenantRegistrationEmailRequest request: requests) {
                contactIds.add(request.contactId);
            }
            MallSendEmailService.createEmailsForContactsBasedOnEmailTemplate(contactIds, emailTemplateName);
        } catch (Exception e) {
            throw throwAuraException('sendEmailForTenantRegistrationCompletion', e);
        }
    }

    /**
     * 
     * @description Method to return Exception for each catch block
     * @param message String 
     * @param e Exception
     * @return  AuraHandledException
     */
    private static AuraHandledException throwAuraException(String message, Exception e) {
        LOGGER.error(message, e);
        AuraHandledException auraException = new AuraHandledException(e.getMessage());
        auraException.setMessage(e.getMessage());
        return auraException;
    }
}