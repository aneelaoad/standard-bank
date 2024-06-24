/**
 * 
 * @description MallClientRegistrationNotification
 * @author Ankit Kumar
 * @since 
 */

 public with sharing class MallClientRegistrationNotification {
    //constant map of user role in bcb platform and email template developer name
    private static final String BCB_PLATFORM_STORE_MANAGER_ROLE = 'Store Manager';
    private static final String BCB_PLATFORM_STORE_REPRESENTATIVE_ROLE = 'Store Representative';
    private static final String BCB_PLATFORM_STORE_PUBLISHER_ROLE = 'Store Publisher';
    private static final String BCB_PLATFORM_EXPERIENCE_MEMBER_ROLE = 'BCB Platform Experience User';

    private static final Map<String, String> MAPUSERBCBPLATFORMROLEVSEMAILTEMPLATE = new Map<String, String> {
        BCB_PLATFORM_STORE_MANAGER_ROLE => 'BCB_Platform_Store_Manager_Registration_Completion',
        BCB_PLATFORM_STORE_REPRESENTATIVE_ROLE => 'BCB_Platform_Store_Representative_Registration_Completion',
        BCB_PLATFORM_STORE_PUBLISHER_ROLE => 'BCB_Platform_Store_Representative_Registration_Completion',
        BCB_PLATFORM_EXPERIENCE_MEMBER_ROLE => 'BCB_Platform_Client_Registration_Notification'
    };

    @TestVisible
    private static final String BCB_PLATFORM_EXPERIENCE_MEMBER_ROLE_TEST_TEMPLATE = 'BCB_Platform_Client_Registration_Notification_Test';

    /**
    * 
    * @description Send Email Notifification to the client for BCB Platform
    * @param userId : String
    * @param userBcbPlatformRole : String
    * @exception AuraHandledException
    */
    public static void sendClientRegistrationNotification(String userId, String userBcbPlatformRole) { 
        try{
            String emailtemplateDeveloperName;
            if(String.IsNotBlank(userBcbPlatformRole)) {
                emailtemplateDeveloperName = MAPUSERBCBPLATFORMROLEVSEMAILTEMPLATE.get(userBcbPlatformRole);
            } else {
                emailtemplateDeveloperName = MAPUSERBCBPLATFORMROLEVSEMAILTEMPLATE.get(BCB_PLATFORM_EXPERIENCE_MEMBER_ROLE);
            }
            emailtemplateDeveloperName = !Test.isRunningTest() ? emailtemplateDeveloperName : BCB_PLATFORM_EXPERIENCE_MEMBER_ROLE_TEST_TEMPLATE;
            MallSendEmailService.createEmailsForUsersBasedOnEmailTemplate(new List<String>{userId}, emailtemplateDeveloperName);
        } catch (Exception e) {  
            throw MallExceptionUtil.throwAuraException('MallClientRegistrationNotification.sendClientRegistrationNotification', e); }
    }
}