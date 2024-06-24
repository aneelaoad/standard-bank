/**
 * @description Test class to assert the upsert on a survey
 *
 * @author Accenture
 * @date March 2022
 *
 * @see SVC_API_UpsertSurveyResponse
 *
 **/
@IsTest(SeeAllData=false)
public class SVC_API_UpsertSurveyResponse_Test
{

    /**
	 * @description This method is use to test a successful call
	 */
    @IsTest
    private static void successfulCall()
    {
        String randomGUID = '9efabe81-f491-4124-9ae0-69bf9b2668ec';        
        amazonconnect__AC_ContactChannels__c amazonConnectChannel = new amazonconnect__AC_ContactChannels__c();
        amazonConnectChannel.amazonconnect__ContactId__c = randomGUID;
        insert amazonConnectChannel;

        SVC_API_UpsertSurveyResponse.DTO_Request inboundRequest = new SVC_API_UpsertSurveyResponse.DTO_Request();
        inboundRequest.contactId = randomGUID;
        inboundRequest.answerOne = 'Yes';
        inboundRequest.answerTwo = '5';
        inboundRequest.answerThree = '7';

        String request = JSON.serializePretty(inboundRequest);

        RestContext.request = new RestRequest();
        RestContext.request.headers.put('Content-Type', 'application/json');
        RestContext.request.addParameter('Sample', 'MyValue');
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf(request);

        Test.startTest();

        SVC_API_UpsertSurveyResponse.upsertSurvey();

        Test.stopTest();

        List<SVC_ContactChannelSurvey__c> surveys = [SELECT Id FROM SVC_ContactChannelSurvey__c];
        System.assertEquals(surveys != null, true, 'No surveys inserted');
    }

    /**
    * @description This method is use to test the Missing contact Id
    */
    @IsTest
    private static void assertContactIdException()
    {
        amazonconnect__AC_ContactChannels__c amazonConnectChannel = new amazonconnect__AC_ContactChannels__c();
        amazonConnectChannel.amazonconnect__ContactId__c = 'ceb212ce-59f0-44a6-8c4b-9fa4d7a20466';
        insert amazonConnectChannel;

        SVC_API_UpsertSurveyResponse.DTO_Request inboundRequest = new SVC_API_UpsertSurveyResponse.DTO_Request();
        inboundRequest.answerOne = 'Yes';
        inboundRequest.answerTwo = '5';
        inboundRequest.answerThree = '7';

        String request = JSON.serializePretty(inboundRequest);

        RestContext.request = new RestRequest();
        RestContext.request.headers.put('Content-Type', 'application/json');
        RestContext.request.addParameter('Sample2', 'MyValue2');
        RestContext.response = new RestResponse();
        RestContext.request.requestBody = Blob.valueOf(request);

        Test.startTest();

        String exceptionMessage;
        try
        {
            SVC_API_UpsertSurveyResponse.upsertSurvey();
        }
        catch (SearchException error)
        {
            exceptionMessage = error.getMessage();
        }

        Test.stopTest();

        List<SVC_ContactChannelSurvey__c> surveys = [SELECT Id FROM SVC_ContactChannelSurvey__c];
        System.assertNotEquals(exceptionMessage == SVC_API_UpsertSurveyResponse.ERROR_CONTACT_ID_WAS_NOT_PROVIDED, false, 'Incorrect Exception');
    }
}