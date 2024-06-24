/**
 * @description Test Class for the MallTenantRegistrationController
 * @author Maham Hasan
 * @since 
*/
@isTest
public class MallTenantRegistrationControllerTest {
    @testSetup static void setup() {
        EmailTemplate emailTemplate =new EmailTemplate();
        emailTemplate.Name = MallTenantRegistrationController.TENANT_INVITATION_EMAIL_TEMPLATE;
        emailTemplate.TemplateType= 'Text';
        emailTemplate.DeveloperName = 'BCB_Platform_Tenant_Registration_Invitation_Notifications';
        emailTemplate.IsActive = true;
        emailTemplate.FolderId = [select Type from Folder where Type = 'Email' LIMIT 1].id;
        insert emailTemplate;
    }
    
    /**
     * 
     * @description Test Method to get Contact List based on Account Id
     */
    @IsTest
    static void getContactsByAccountIdTest() {
       
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        Provider__c provider = new Provider__c();
        provider.Name = 'Test Provider';
        provider.Related_Client__c = acc.Id;
        insert provider;

        Contact contact = new Contact();
        contact.LastName = 'Test Contact 1';
        contact.Email = 'test1@gmail.com';
        contact.AccountId = acc.Id;
        insert contact;

        Test.startTest();
        List<Contact> contactsList = MallTenantRegistrationController.getContactsByProviderId(provider.Id);
        Assert.areEqual(1, contactsList.size(), 'Expected contacts list');

        for(Contact currentContact: contactsList){
            currentContact.Register_Mall_Tenant__c = true;
        }

        List<Contact> contacts = MallTenantRegistrationController.updateTenantRegistrationEmailFlag(contactsList);
        Assert.areEqual(true, contacts[0].Register_Mall_Tenant__c, 'Expected tenant list');

        contactsList = MallTenantRegistrationController.getContactsByProviderId(provider.Id);
        Assert.areEqual(1, contactsList.size(), 'Expected contacts list');

        Test.stopTest();        
    }

    /**
     * 
     * @description Test Method to send emails to Contact's Email
     */
    @IsTest
    static void sendEmailTest(){          
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        Provider__c provider = new Provider__c();
        provider.Name = 'Test Provider';
        provider.Related_Client__c = acc.Id;
        insert provider;

        Contact contact = new Contact();
        contact.LastName = 'Test Contact 1';
        contact.AccountId = acc.Id;
        contact.Email = 'test1@gmail.com';
        insert contact;
        
        List<String> contactIds = new List<String>();
        contactIds.add(contact.id);

        Test.startTest();
        Assert.areEqual(0, Limits.getEmailInvocations(), 'Expected result');
        MallTenantRegistrationController.sendEmail(contactIds);
        Test.stopTest();
    }
}