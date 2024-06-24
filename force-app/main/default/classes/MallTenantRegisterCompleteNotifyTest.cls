@IsTest
private class MallTenantRegisterCompleteNotifyTest {

    @IsTest
    public static void sendEmailInviteForTenantRegistrationTest(){

        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName = 'Contact';
        contact.Email = 'test@gmail.com';
        insert contact;

        String templateName = 'Store Manager Registration Completion';
        MallTenantRegisterCompleteNotification.MallTenantRegistrationEmailRequest req = new MallTenantRegisterCompleteNotification.MallTenantRegistrationEmailRequest();
        req.contactId = contact.Id;
        req.emailTemplateName = templateName;
        MallTenantRegisterCompleteNotification.sendEmailForTenantRegistrationCompletion(new List<MallTenantRegisterCompleteNotification.MallTenantRegistrationEmailRequest> {req});
        try{
            req.contactId = '0001';
        	MallTenantRegisterCompleteNotification.sendEmailForTenantRegistrationCompletion(new List<MallTenantRegisterCompleteNotification.MallTenantRegistrationEmailRequest> {req});
        }catch(Exception e) {
            AuraHandledException aueaEx = MallTenantRegistrationInviteNotification.throwAuraException('sendEmailForTenantRegistrationCompletion',e);
            Assert.areEqual(true, aueaEx.getMessage().contains('0001'), 'exception');
        }
    }
}