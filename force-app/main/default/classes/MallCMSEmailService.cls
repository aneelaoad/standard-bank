/**  
 * @description It will send emails to user with template   
 * @className MallCMSEmailService   
 * @Author - Ankit Kumar    
 */

public with sharing class MallCMSEmailService {
    /**    
     * @description - global instance of rf lib logger     
     */
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('MallCMSEmailService');
    
    /**
     * 
     * @description Method to send email to users
     * @param List<InputParameters> inputParamsList 
     */
    @InvocableMethod(label='MallCMSEmailService')
    public static void sendEmailToUser(List<InputParameters> inputParamsList) {
        if (!inputParamsList.isEmpty()) {
            List <Messaging.SingleEmailMessage> emailList = new List <Messaging.SingleEmailMessage> ();
            for (InputParameters inputParams: inputParamsList) {
                if (inputParams.emailTemplateId != null && inputParams.userId != null && inputParams.whatId != null) {
                    Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(inputParams.emailTemplateId,
                        inputParams.userId, inputParams.whatId);
                    email.setSubject(email.getSubject());
                    email.setHtmlBody(email.getHtmlBody());
                    email.setSaveAsActivity(false);
                    if (inputParams.orgWideEmailAddressId != null) {
                        email.setOrgWideEmailAddressId(inputParams.orgWideEmailAddressId);
                    }
                    email.setTargetObjectId(inputParams.userId);
                    emailList.add(email);
                }
            }
            if (!emailList.isEmpty()) {
                try {
                    if (Limits.getEmailInvocations() <= Limits.getLimitEmailInvocations()) {
                        Messaging.sendEmail(emailList);
                    } else {
                        LOGGER.error('You have made ' + Limits.getEmailInvocations() + ' email calls out of ' + Limits.getLimitEmailInvocations() + ' allowed');
                    }
                } catch (Exception e) { throw throwAuraException('sendEmailToUser', e); }
            }
        }
    }

    /**
     * 
     * @description Method to return Exception for each catch block
     * @param message String 
     * @param e Exception
     * @return  Aura Handled Exception
     */
    private static AuraHandledException throwAuraException(String message, Exception e) {
        LOGGER.error(message, e);
        AuraHandledException auraException = new AuraHandledException(e.getMessage());
        auraException.setMessage(e.getMessage());
        return auraException;
    }

    /**    
     * @description - input params emailTemplateId , userId, whatId and orgWideEmailAddressId    
     */
    public class InputParameters {
        @InvocableVariable
        public Id emailTemplateId;
        @InvocableVariable
        public Id userId;
        @InvocableVariable
        public Id whatId;
        @InvocableVariable
        public Id orgWideEmailAddressId;
    }
}