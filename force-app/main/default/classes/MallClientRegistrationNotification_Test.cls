/**
 * @description MallClientRegistrationNotification_Test
 * @author Ankit Kumar
 * @since 
 */
@IsTest
private class MallClientRegistrationNotification_Test {

    @testSetup static void setup() {
        EmailTemplate emailTemplate =new EmailTemplate();
        emailTemplate.Name = MallClientRegistrationNotification.BCB_PLATFORM_EXPERIENCE_MEMBER_ROLE_TEST_TEMPLATE;
        emailTemplate.TemplateType= 'Text';
        emailTemplate.DeveloperName = MallClientRegistrationNotification.BCB_PLATFORM_EXPERIENCE_MEMBER_ROLE_TEST_TEMPLATE;
        emailTemplate.IsActive = true;
        emailTemplate.FolderId = [select Type from Folder where Type = 'Email' LIMIT 1].id;
        insert emailTemplate;
    }
    
    @IsTest
    public static void sendEmailInviteForTenantRegistrationTest() {
        Test.startTest();
        String memberRole = 'BCB Platform Experience User';
        MallClientRegistrationNotification.sendClientRegistrationNotification(UserInfo.getUserId(), memberRole);
        MallClientRegistrationNotification.sendClientRegistrationNotification(UserInfo.getUserId(), '');
        Assert.areEqual(true, Limits.getEmailInvocations() > 0, 'Expected result');

        try{
        	MallClientRegistrationNotification.sendClientRegistrationNotification('0001', memberRole);
        }catch(Exception e) {
            AuraHandledException aueaEx = MallExceptionUtil.throwAuraException('sendClientRegistrationNotification',e);
            Assert.areEqual(true, aueaEx.getMessage().contains('0001'), 'exception');
        }
        Test.StopTest();
    }
}