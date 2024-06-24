/**
 * Test Class for SendServiceCaseEmail class
 * <br/>SGPRT-1497
 *
 * @author Suveer Mohunlal (suveer.mohunlal@standardbank.co.za)
 * @date August 2020
 */

@IsTest
global class SendServiceCaseEmail_Test {
    
    @TestSetup
    static void makeData(){
		User thisUser = new User(Id = UserInfo.getUserId());
        System.runAs (thisUser) {

            EmailTemplate template = new EmailTemplate(
                IsActive = true,
                Name = 'name',
                DeveloperName = 'unique_name_testclasstest',
                TemplateType = 'text',
                FolderId = UserInfo.getUserId()
            );
            insert template;
            
            // Create test data
            Account acc = new Account(
                Name='Test Name',
                Phone = '1234',
                FAX = '123',
                Billingstreet = 'test'
            );
            insert acc;      
    
            Contact con = new Contact(
                FirstName='Test Name',
                LastName = 'test',
                AccountId = acc.Id,
                MobilePhone = '1234',
                email='fake@test.com'
            );
            insert con;
            
        }
       
    }
    
    @IsTest
    static void testSendEmailSuccess() {
        Contact theContact = [SELECT Id, AccountId FROM Contact LIMIT 1];

        SendServiceCaseEmail.InvokeSendEmail request = new SendServiceCaseEmail.InvokeSendEmail();
        request.EmailTemplateName = 'unique_name_testclasstest';
		request.ContactId = theContact.id;
        request.RelatedToId = theContact.AccountId;
        request.OrgWideEmailAddress = 'helpme@standardbank.co.za';
        
        Test.startTest();

        SendServiceCaseEmail.sendEmail( new List<SendServiceCaseEmail.InvokeSendEmail>{ request } );
        Integer invocations = Limits.getEmailInvocations();

        Test.stopTest();
		
        System.assertEquals(1, invocations, 'We expect an email to be sent');
        
    }
}