/**
 * @description Class to test the send email functionality in CMN_FLOW_SendEmail
 *
 * @see CMN_FLOW_SendEmail.sendEmail
 *
 * @author Accenture
 *
 * @date March 2021
 */
@IsTest(SeeAllData=false IsParallel=true)
private class CMN_FLOW_SendEmail_TEST
{
    private static final String SEARCH_TERM = Case.SObjectType.getDescribe().getLocalName();

    /**
     * @description Create required data for the unit test
     */
    @TestSetup
    private static void setup()
    {
        Contact newContact = newContact();
        insert newContact;

        Case newCase = newCase();
        insert newCase;
        
        
    }
 
    /**
     * @description Create a new case
     * @return the case created
     */  
    private static Contact newContact() {
      Contact newContact = new Contact();

      newContact.LastName = 'test';
      newContact.MobilePhone = '123455';
      newContact.Phone = '22222222';
      newContact.HomePhone = '23423';
      newContact.Email = 'test@test.com';
      return newContact;
    }
    
    /**
     * @description Create a new case
     * @return the case created
     */  
    private static Case newCase()
    {
        Case newCase = new Case();
    
        newCase.Subject = 'test';
        newCase.Description = 'test';
        newCase.suppliedemail = 'test@test.pt';    
        return newCase;
      }
    /**
     * @description Contains the base code required to run each test with variants in parameter list
     *
     * @param toAddress The address to send email to
     * @param whatId The Id to which email should be related
     *
     * @note There is an issue that the common search methods generate a APEX CPU timeout issue, the code
     *       below now utilizes a query to get a random template rather than CMN_SEARCH. Further resolution
     *       will be tracked on VCCC-10858
     *
     *       The offending line is :
     *       CMN_DAL_EmailTemplate.getRandomItem(searchTerm)?.DeveloperName;
     *
     * @return A list of email send responses
     */
    private static List<CMN_FLOW_SendEmail.DTO_SendEmailResponse> runTest(String toAddress, Id whatId)
    {
        CMN_FLOW_SendEmail.DTO_SendEmailRequest dtoEmail = new CMN_FLOW_SendEmail.DTO_SendEmailRequest();

        dtoEmail.toAddress = toAddress;
        dtoEmail.whatId = whatId;
        dtoEmail.orgWideEmailAddress = CMN_DAL_OrgWideEmailAddress.getRandomItem()?.Address;
        dtoEmail.templateUniqueName = [
                SELECT Id,
                        DeveloperName
                FROM EmailTemplate
                LIMIT 1
        ].DeveloperName;



        EmailTemplate emailTemplate = CMN_DAL_EmailTemplate.getRandomItem('ccc');


        Set<String> templateNames = new Set<String>();
        templateNames.add('test');
            
        List<EmailTemplate> emailTemplates = CMN_DAL_EmailTemplate.findByName(templateNames);
       
        string devname = CMN_DAL_EmailTemplate.FIELD_DEVELOPER_NAME;

        Test.startTest();

        List<CMN_FLOW_SendEmail.DTO_SendEmailResponse> dtoResponses = CMN_FLOW_SendEmail.sendEmail(new List<CMN_FLOW_SendEmail.DTO_SendEmailRequest> {dtoEmail});

        Test.stopTest();

        System.assertNotEquals(true, dtoResponses.isEmpty(), 'No responses received');

        return dtoResponses;
    }

    /**
     * @description Check to see an email would have successfully been sent using contactId in the toAddress field
     */
    @IsTest
    private static void sendMailSuccessfullyUsingContactId()
    {
        Contact newContact = [select id from contact];
        Case newCase = [select id from case];

        List<CMN_FLOW_SendEmail.DTO_SendEmailResponse> dtoResponses = runTest(newContact.Id, newCase.Id);

        System.assertEquals(true, dtoResponses.iterator().next().success, 'Send Email Failed: ' + dtoResponses.iterator().next().errors);
    }

    /**
     * @description Check to see an email would have successfully been sent using an email in the toAddress field
     */
    @IsTest
    private static void sendMailSuccessfullyUsingEmailAddress()
    {
        Contact newContact = [select id, Email from contact];
        Case newCase = [select id from case];

        List<CMN_FLOW_SendEmail.DTO_SendEmailResponse> dtoResponses = runTest(newContact.Email, newCase.Id);

        System.assertEquals(true, dtoResponses.iterator().next().success, 'Send Email Failed: ' + dtoResponses.iterator().next().errors);
    }

    /**
     * @description Will Test that an error is reported for putting invalid Id into targetObjectId
     */
    @IsTest
    private static void failedSendMailInvalidTargetObjectId()
    {
        Case newCase = [select id from case];

        List<CMN_FLOW_SendEmail.DTO_SendEmailResponse> dtoResponses = runTest(newCase.Id, newCase.Id);

        System.assertEquals(false, dtoResponses.iterator().next().success, 'Send did not fail as expected');
    }
}