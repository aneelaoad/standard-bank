/**
 * Test class for PocketRSVP_REST_API class
 *
 * @author Mykhailo Reznyk (mreznyk@deloittece.com)
 * @date October 2019
*/
@IsTest
private class PocketRSVP_REST_API_Test {

    private static CampaignMember campaignMember {
        get {
            if (campaignMember == null) {
                campaignMember = [SELECT ContactId FROM CampaignMember];
            }
            return campaignMember;
        }
        set;
    }

    private static final String CONTACT_LNAME = 'lastNameTest';

    @TestSetup
    private static void setupData() {

        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getEmailAddress()
        });

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Contact conBld = new BLD_Contact(uow)
            .name('fName', CONTACT_LNAME)
            .contactCategory(DMN_Contact.CATEGORY_CEO)
            .email('testEmail@test.com')
            .fax('567898765467')
            .account(
                new BLD_Account(uow)
            );

        new BLD_Campaign(uow)
            .addMember(
                new BLD_CampaignMember(uow)
                    .contact(conBld)
                    .status(DMN_CampaignMember.STATUS_SENT)
            );

        uow.commitWork();

    }

    @IsTest
    static void testUpdateCampaign() {
        RestRequest request = createRestRequest();
        request.requestBody = Blob.valueOf('{"Contact":{"Allergies__c":"Nuts;Other","AssistantName":"Rozy API","Attendance_Status__c":"WALKIN","Dates":{"Birthdate":"2000/12/07"}},"Campaign":{"Dates":{"EndDate":"2015/01/08"}}}');
        RestContext.request = request;

        PocketRSVP_REST_API.ResponseWrapper response = PocketRSVP_REST_API.updateCampaign();
        System.assertEquals('Success', response.status);
    }

    @IsTest
    static void shouldSendEmailToHosts() {

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_CampaignHost(uow)
            .bankContact(
                new BLD_Contact(uow).useBankContact()
                    .email('testemail@standardbank.co.za')
                    .account(
                        new BLD_Account(uow)
                            .name(DMN_Account.STANDARD_BANK_EMPLOYEES)
                    )
            )
            .memberHostId([SELECT Id FROM Campaign_Member_Host__c].Id);
        uow.commitWork();

        RestRequest request = createRestRequest();
        request.requestBody = Blob.valueOf('{"Contact":{"Allergies__c":"Nuts;Other","AssistantName":"Rozy API","Attendance_Status__c":"WALKIN","Dates":{"Birthdate":"2000/12/07"}}}');
        RestContext.request = request;

        Integer emailsSent = Limits.getEmailInvocations();
        PocketRSVP_REST_API.ResponseWrapper response = PocketRSVP_REST_API.updateCampaign();
        System.assertEquals('Success', response.status);
        System.assertEquals(emailsSent + 1, Limits.getEmailInvocations());
    }

    @IsTest
    static void testUpdateCampaignNoFieldWasUpdated() {

        RestRequest request = createRestRequest();
        request.requestBody = Blob.valueOf('{"Contact":{"Fax":"123456789"}}');
        RestContext.request = request;

        PocketRSVP_REST_API.ResponseWrapper response = PocketRSVP_REST_API.updateCampaign();
        System.assertEquals('Success', response.status);
        System.assertEquals('No field was updated', response.message);
    }

    @IsTest
    static void testUpdateCampaignCampaignMemberIdError() {

        RestRequest request = createRestRequest();
        request.requestBody = Blob.valueOf('{"Contact":{"Allergies__c":"Nuts;Other","AssistantName":"Rozy API","Attendance_Status__c":"WALKIN","Dates":{"Birthdate":"2000/12/07"}},"Campaign":{"Dates":{"EndDate":"2015/01/08"}}}');

        request.requestURI = '/services/apexrest/Events/' + 'incorrectId';

        RestContext.request = request;

        PocketRSVP_REST_API.ResponseWrapper response = PocketRSVP_REST_API.updateCampaign();
        System.assertEquals('Error', response.status);
        System.assertEquals('Didn\'t find Campaign Member with such Id', response.message);
    }

    @IsTest
    static void testUpdateCampaignDateConversionError() {

        RestRequest request = createRestRequest();
        request.requestBody = Blob.valueOf('{"Contact":{"Allergies__c":"Nuts;Other","AssistantName":"Rozy API","Attendance_Status__c":"WALKIN","Dates":{"Birthdate":"20s00/12/07"}},"Campaign":{"Dates":{"EndDate":"2015/01/08"}}}');
        RestContext.request = request;

        PocketRSVP_REST_API.ResponseWrapper response = PocketRSVP_REST_API.updateCampaign();
        System.assertEquals('Error', response.status);
        System.assert(response.message.contains('Error during String to Date conversion;'));
    }

    @IsTest
    static void testUpdateCampaignFieldNameError() {

        RestRequest request = createRestRequest();
        request.requestBody = Blob.valueOf('{"Contact":{"AAllergies__c":"Nuts;Other","AssistantName":"Rozy API","Attendance_Status__c":"WALKIN","Dates":{"Birthdate":"2000/12/07"}},"Campaign":{"Dates":{"EndDate":"2015/01/08"}}}');
        RestContext.request = request;

        PocketRSVP_REST_API.ResponseWrapper response = PocketRSVP_REST_API.updateCampaign();
        System.assertEquals('Error', response.status);
        System.assertEquals('Invalid field AAllergies__c for Contact', response.message);
    }

    static RestRequest createRestRequest() {
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/Events/' + campaignMember.Id;
        request.httpMethod = 'PATCH';
        request.addHeader('Content-Type', 'application/json');
        return request;
    }
}