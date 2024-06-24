/**
 * @description Rest resource to perform an upsert on a survey completed after a voice call.
 * 
 * @author Accenture
 * @date March 2022
 * 
 **/
@RestResource(UrlMapping='/v1/ContactChannelSurvey/*')
global class SVC_API_UpsertSurveyResponse
{
    @TestVisible
    private static final String ERROR_CONTACT_ID_WAS_NOT_PROVIDED = 'The required contact channel external Id was not provided.';
    @TestVisible
    private static final String SUCCESS_MESSAGE = 'Contact Channel Survey Updated';
    @TestVisible
    private static final String ERROR_NO_RECORD_FOUND = 'Unable to retrieve Contact Channel for the contact Id provided';
    private static final Integer HTTP_CODE_OK = 200;
    public static final String SERVICE_NAME = SVC_API_UpsertSurveyResponse.class.getName();
    private static final Integer HTTP_CODE_BAD_REQUEST = 400;

    @HttpPost
    global static DTO_Response upsertSurvey()
    {
        SVC_ContactChannelSurvey__c upsertSurveyResponse;
        DTO_Response responseJSON = new DTO_Response();

        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();
        
        DTO_Request dtoRequest = (DTO_Request)JSON.deserialize(requestBody, DTO_Request.class);
        
        if (String.isBlank(dtoRequest.contactId))
        {
            throw new SearchException(ERROR_CONTACT_ID_WAS_NOT_PROVIDED);
        }
        
        String amazonConnectContactId = dtoRequest.contactId;
        String answerOne = dtoRequest.answerOne;
        String answerTwo = dtoRequest.answerTwo;
        String answerThree = dtoRequest.answerThree;
        
        amazonconnect__AC_ContactChannels__c contactChannel = SVC_DAL_AcContactChannel.findByContactId(amazonConnectContactId);
        
        if (contactChannel == null)
        {
            throw new SearchException(ERROR_NO_RECORD_FOUND);
        }
        
        upsertSurveyResponse = SVC_DAL_ContactChannelSurvey.findSurveyResponseByContactChannelId(contactChannel.Id);
        upsertSurveyResponse = upsertSurveyResponse == null ? new SVC_ContactChannelSurvey__c() : upsertSurveyResponse;
        
        upsertSurveyResponse.SVC_ACContactChannel__c = contactChannel.Id;
        upsertSurveyResponse.SVC_AchievedPurpose__c = answerOne;
        upsertSurveyResponse.SVC_NetPromoterScoreRating__c = Integer.valueOf(answerTwo);
        upsertSurveyResponse.SVC_AgentRating__c = Integer.valueOf(answerThree);
        upsertSurveyResponse.OwnerId = contactChannel.OwnerId;
        
        try
        {
            upsert upsertSurveyResponse;
            responseJSON.success = SUCCESS_MESSAGE;
            responseJSON.id = upsertSurveyResponse.Id;
            responseJSON.code = HTTP_CODE_OK;
        }
        catch (Exception e)
        {
            responseJSON.success = e.getMessage();
            responseJSON.id = null;
            responseJSON.code = HTTP_CODE_BAD_REQUEST;
            SRV_Logger.newInstance().log(e, 'Voice', SVC_API_UpsertSurveyResponse.Class.getName());
        }
        
        return responseJSON;

    }

    @TestVisible
    private class DTO_Request
    {
        public String contactId;
        public String answerOne;
        public String answerTwo;
        public String answerThree;
    }

    //wrapper class for the response to an API request
    global class DTO_Response
    {
        global String id { get; set; }
        global String success { get; set; }
        global integer code { get; set; }
    }

}