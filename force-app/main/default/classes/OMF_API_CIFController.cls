/**
* @description Rest Callout to send Json payload to CIF system and get syncronous response back
* @author Raja Kumar
* @company Absyz
* @test Class OMF_API_CIFController_TEST
* @date 12 Jan 2024
*/
public without sharing class OMF_API_CIFController extends CMN_API_HttpBase{
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('OMF_API_CIFController');
    private static DTO_Request baseRequestDTO;
    private static DTO_Response baseResponseDTO;
    private String requestBody;
    private Id strManagedFundId;
    private static String updatedShortName=null;
    /**
* @description constructor for the class OMF_API_CIFController
* @param strManagedFundId
*/
    public OMF_API_CIFController(Id strManagedFundId){
        this.strManagedFundId = strManagedFundId; 
    }
    /**
* @description Method call from screenflow to resume the process
* @param managedFundDataList
*/
    @InvocableMethod(label='Send Relationship Short Name To CIF' description='Method is used to send request to CIF and needs managed fund id and/or shortname as input' category= 'Managed Fund Onboarding')
    public static void sendShortNameToCIF(List<ManagedFundDataFromFlow> managedFundDataList){
        ManagedFundDataFromFlow objManagedFundDataFromFlow = managedFundDataList.get( 0 );
        updatedShortName = objManagedFundDataFromFlow.updatedShortName;
        if((objManagedFundDataFromFlow.mangedFundId.getSObjectType().getDescribe().getName())=='OMF_ManagedFund__c'){
            OMF_API_CIFController service = new OMF_API_CIFController(objManagedFundDataFromFlow.mangedFundId);
            service.sendRequest();
        }
        
    }
    
    
/**
* @description inner class used to throw exceptions
* @author Raja Kumar
* @test Class OMF_API_CIFController_TEST
* @date 12 Jan 2024
*/
    public class OMF_API_CIFControllerException extends Exception{}
    
    /**
* @description function to send the Http request
*/
    public void sendRequest(){
        HttpRequest req = getWebServiceRequest();
        
        if(req!=null){
            Http http = new Http();
            try{
                HTTPResponse res = http.send(req);
                processCIFResponse(res);
            }
            catch(CalloutException ex){
                callPlatformEventForUpdateCIF();
                throw new OMF_API_CIFControllerException(Label.Onboarding_Callout_Failure);
            }
            catch(Exception ex){
                callPlatformEventForUpdateCIF();
                throw new OMF_API_CIFControllerException(Label.Onboarding_Callout_Failure);
            }
        }
    }
    /*@description create request for the webservice*/
    private HttpRequest getWebServiceRequest(){
        String requestBody = getBody();
        HttpRequest req;
        if(!String.isEmpty(requestBody)){
            String endpoint='callout:OMF_GlobalCIF';
            req =  (new HTTP_RequestBuilder(CMN_API_HttpBase.HTTP_VERB_POST,endpoint, requestBody)).getHttpRequest();
            req.setHeader(CMN_API_HttpBase.HTTP_CONTENT_TYPE,CMN_API_HttpBase.HTTP_ENCODING_JSON);
        }
        return req;
    }
    /**
* @description This method will be called to get HTTP request Body
*
* @return string
*/
    protected override String getBody()
    {
        list<OMF_ManagedFund__c> objFundList=new SEL_OMF_ManagedFunds().selectManagedFundRecordWithAssetManagerAndFundDetails(strManagedFundId);
        baseRequestDTO.parentCifId=objFundList[0].Fund__r.CIF__c;
        baseRequestDTO.childCifId=objFundList[0].AssetManager__r.CIF__c;
        baseRequestDTO.relationshipShortName = (updatedShortName!=null) ? updatedShortName : objFundList[0].ShortName__c;
        baseRequestDTO.relationshipTypeId='OBO';
        return baseRequestDTO.serialize();
    }
    
    /* @description process the response received*/    
    private void processCIFResponse(HttpResponse res){
        if(res!=null){
            String responseJson = res.getBody();
            baseResponseDTO=(DTO_Response)baseResponseDTO.deserialize(responseJson);
            if(res.getStatusCode()<200 || res.getStatusCode()>299) {
                updateErrorRecord(strManagedFundId,baseResponseDTO.requestStatusCode);
            }
            else{
                updateSuccessRecord(strManagedFundId);
            }
        }
    }
    /*@description call this platform event on error to update field on Managed Fund Rec*/
    private void callPlatformEventForUpdateCIF(){
        OMF_ManagedFundRecordUpdate__e asyncDmlForOMF = new OMF_ManagedFundRecordUpdate__e();
        asyncDmlForOMF.ManagedFundRecordId__c = strManagedFundId;
        asyncDmlForOMF.NewOnboardingStatus__c = 'CIF Submission Failed';
        EventBus.publish(asyncDmlForOMF);
    }
    
    /**
* @description function that is called from platform event to update status when there is exception
* @param managedFundRecId
*/
    public static void handleCIFAPIFailureNotification(String managedFundRecId){
        OMF_ManagedFund__c[] listManagedFundRecord = new SEL_OMF_ManagedFunds().selectedByRecordId(managedFundRecId);
        if(listManagedFundRecord != null && !listManagedFundRecord.isEmpty()){
            OMF_ManagedFund__c fundToUpdate = new OMF_ManagedFund__c
                (Id = listManagedFundRecord[0].Id, 
                 Onboarding_Status__c= 'CIF Submission Failed');
            Database.update(fundToUpdate);
            sendEmailAndCreateChatterPost('OMF_CIFAPISubmissionFailureNotification',listManagedFundRecord[0]);
            
        }
    }
    /**
* @description sends email and create a chatter post for the ManagedFund Record
* @param emailTemplateDeveloperName
* @param managedFundRecord
*/
    private static void sendEmailAndCreateChatterPost(String emailTemplateDeveloperName,OMF_ManagedFund__c managedFundRecord){
        EmailTemplate[] listEmailTemplate = new SEL_EmailTemplate().selectByDeveloperName(emailTemplateDeveloperName);
        EmailTemplate objEmailTemplate;
        if(listEmailTemplate.size()>0){
            objEmailTemplate = listEmailTemplate[0];
        }
        
        //send email
        Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(objEmailTemplate.Id, managedFundRecord.CreatedById, managedFundRecord.Id);
        String emailSubject = message.getSubject();
        String emailTextBody = message.getPlainTextBody();
        String emailHtmlBody =message.getHtmlBody();
        
        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
        If(emailTemplateDeveloperName == 'OMF_RejectionOfTheFundShortName2' || emailTemplateDeveloperName == 'OMF_CIFRejectionNotification2'){
            List<OMFSetting__mdt> omfSetting = OMFSetting__mdt.getAll().values();
            singleEmail.setToAddresses(omfSetting.size() > 0 ? new String[] {omfSetting[0].GlobalCIFEmailAddress__c} : new String[] {});
        }
        singleEmail.setTargetObjectId(managedFundRecord.CreatedById);
        singleEmail.setSaveAsActivity(false); // Optional: Set to true if you want to save the email as an activity in Salesforce
        singleEmail.setSubject(emailSubject);
        singleEmail.setPlainTextBody(emailTextBody);
        singleEmail.setHtmlBody(emailHtmlBody);
        if (Limits.getEmailInvocations() < Limits.getLimitEmailInvocations()) {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ singleEmail });
        }else {
            LOGGER.INFO('Email limit exceeded, cannot send email at this time.');
        }
        //create Chatter Post
        FeedItem objFeedItem = new FeedItem();
        objFeedItem.ParentId = managedFundRecord.Id;
        objFeedItem.Body = emailTextBody;
        try {
            Database.insert(objFeedItem);
        } catch (DmlException e) {
            LOGGER.error('An error occured while inserting the FeedItem record:',e);
        }
        
    }
    /**
* @description creates the task for owner of ManagedFund Record 
* @param managedFundRecord
* @param authUser
*/
    private static void createTask(OMF_ManagedFund__c managedFundRecord,String authUser){
        Task taskForOM = new Task();
        taskForOM.OwnerId = managedFundRecord.CreatedById;
        taskForOM.Subject = 'Contact CIF Team';
        taskForOM.Status = 'Open';
        taskForOM.WhatId = managedFundRecord.Id;
        taskForOM.Description=authUser;
        try {
            Database.insert(taskForOM);
        } catch (DmlException e) {
            LOGGER.error('An error occured while inserting the task record:',e);
        }
        
    }
    /**
* @description perform the error flow when we get error back in response
* @param salesforceId
* @param errorMessage
*/
    private void updateErrorRecord(String salesforceId,String errorMessage){
        OMF_ManagedFund__c[] listManagedFundRecord = new SEL_OMF_ManagedFunds().selectedByRecordId(salesforceId);
        OMF_ManagedFund__c objManagedFundRecord = new OMF_ManagedFund__c();
        if(errorMessage.containsIgnoreCase('Short Name') && !listManagedFundRecord.isEmpty()){
            objManagedFundRecord.Id = listManagedFundRecord[0].Id;
            objManagedFundRecord.Onboarding_Status__c = 'Fund Details';
            objManagedFundRecord.RejectionReason__c = errorMessage;
            if(updatedShortName!=null){
                objManagedFundRecord.ShortName__c=updatedShortName;
            }
            
            try {
                Database.update(objManagedFundRecord);
            } catch (DmlException e) {
                LOGGER.error('An error occured while updating the record:',e);
            } 
            sendEmailAndCreateChatterPost('OMF_RejectionOfTheFundShortName2',listManagedFundRecord[0]);
        }
        if(!errorMessage.containsIgnoreCase('Short Name') && !listManagedFundRecord.isEmpty()){
            objManagedFundRecord.Id = listManagedFundRecord[0].Id;
            objManagedFundRecord.Onboarding_Status__c = 'Global CIF';
            objManagedFundRecord.RejectionReason__c = errorMessage;
            try {
                Database.update(objManagedFundRecord);
            } catch (DmlException e) {
                LOGGER.error('An error occured while updating the record:',e);
            } 
            sendEmailAndCreateChatterPost('OMF_CIFRejectionNotification2',listManagedFundRecord[0]);
            createTask(listManagedFundRecord[0],errorMessage);
        }
        
    }
    /**
* @description perform the success flow
* @param salesforceId
*/
    private void updateSuccessRecord(String salesforceId){
        OMF_ManagedFund__c[] listManagedFundRecord = new SEL_OMF_ManagedFunds().selectedByRecordId(salesforceId);
        OMF_ManagedFund__c objManagedFundRecord = new OMF_ManagedFund__c();
        if (!listManagedFundRecord.isEmpty()) {
            objManagedFundRecord.Id = listManagedFundRecord[0].Id;
            objManagedFundRecord.Onboarding_Status__c = 'Global CIF';
            objManagedFundRecord.RejectionReason__c='';
            objManagedFundRecord.RejectionDetails__c='';
            if(updatedShortName!=null){
                objManagedFundRecord.ShortName__c=updatedShortName;
            }
            try {
                Database.update(objManagedFundRecord);
            } catch (DmlException e) {
                LOGGER.error('An error occured while updating the record:',e);
            }
        }
    }
    /**
* @description intialise the variables
*/
    protected override void initialise()
    {
        super.initialise();
        baseRequestDTO = new DTO_Request();
        baseResponseDTO = new DTO_Response();
    }
    /**
* @description Class used for request payload
*/
    private class DTO_Request extends CMN_DTO_JsonBase
    {
        public String parentCifId;
        public String childCifId;
        public String relationshipTypeId;
        public String relationshipShortName;
        
        
    }
    /**
* @description class for handling the response payload
*/
    @TestVisible
    private class DTO_Response extends CMN_DTO_JsonBase
    {
        public String parentCifId;
        public String childCifId;
        public String relationshipTypeId;
        public String relationshipShortName;
        public String requestStatusCode;
        /**
* @description The Type of the DTO used when deserializing the class
*
* @return Class of the DTO
*/
        protected override Type getObjectType()
        {
            return OMF_API_CIFController.DTO_Response.class;
        }
    }
    /**
* @description Data wrapper classs to store the details from flow
*/
    public class ManagedFundDataFromFlow{
        
        @InvocableVariable public Id mangedFundId;
        
        @InvocableVariable public String updatedShortName;
        
    }
    
}