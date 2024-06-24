@isTest
public with sharing class MallTenantRegistrationInviteNotifyTest {
   
    @IsTest
    public static void sendEmailInviteForTenantRegistrationTest(){

        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName = 'Contact';
        contact.Email = 'test@gmail.com';
        insert contact;

        String templateName = 'Tenant Registration Invitation Email Notification';
        MallTenantRegistrationInviteNotification.MallTenantRegistrationEmailRequest req = new MallTenantRegistrationInviteNotification.MallTenantRegistrationEmailRequest();
        req.contactId = contact.Id;
        req.emailTemplateName = templateName;
        MallTenantRegistrationInviteNotification.sendEmailInviteForTenantRegistration(new List<MallTenantRegistrationInviteNotification.MallTenantRegistrationEmailRequest> {req});
        try{
            req.contactId = '0001';
        	MallTenantRegistrationInviteNotification.sendEmailInviteForTenantRegistration(new List<MallTenantRegistrationInviteNotification.MallTenantRegistrationEmailRequest> {req});
             Assert.areEqual(Limits.getEmailInvocations(),1, 'one invocation expected');
        }catch(Exception e) {
            AuraHandledException aueaEx = MallTenantRegistrationInviteNotification.throwAuraException('sendEmailInviteForTenantRegistration',e);
            Assert.areNotEqual(aueaEx, NULL, 'error expected');
        }
    }
}