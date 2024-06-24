/**
*@description Service  Class for Handling inbound request for Managed Fund from CIF System
*@author Raja Kumar
*@test Class OMF_CIFRRStatusUpdate_Test
*@JIRA Tickets SFP-32673
*@date Feb 2024
*/
@SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')
public inherited sharing class SRV_OMF_CIFStatusUpdate {
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SRV_OMF_CIFStatusUpdate');
    private static OMF_API_CIFRRStatusUpdate.DTO_Response baseResponseDTO=new OMF_API_CIFRRStatusUpdate.DTO_Response();
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
        List<OMFSetting__mdt> omfSetting = OMFSetting__mdt.getAll().values();
        Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(objEmailTemplate.Id, managedFundRecord.CreatedById, managedFundRecord.Id);
        
        String emailSubject = message.getSubject();
        String emailTextBody = message.getPlainTextBody();
        String emailHtmlBody =message.getHtmlBody();
        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
        singleEmail.setToAddresses(omfSetting.size() > 0 ? new String[] {omfSetting[0].GlobalCIFEmailAddress__c} : new String[] {});
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
        
        //create chatter Feed
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
* @description method to build the response for the request received
* @param responseType
*/
    private static void createDToResponse(String responseType){
        if(responseType=='ERROR'){
            baseResponseDTO.ERROR='BAD REQUEST';
        }else if(responseType=='SUCCESS'){
            baseResponseDTO.SUCCESS='Record Updated';
        }
        baseResponseDTO.relationshipShortName=null;
        baseResponseDTO.requestStatusCode=null;
        baseResponseDTO.authUser=null;
        baseResponseDTO.relationshipCIFId=null;
        baseResponseDTO.relationshipOSDId=null;
    }
    /**
* @description  method to get the relationship record id from the request and process
* @param dtoRequest Dto request type (the inbound request)
* @return baseResponseDTO
*/
    public static OMF_API_CIFRRStatusUpdate.DTO_Response processInboundRequest(OMF_API_CIFRRStatusUpdate.DTO_Response dtoRequest){
        try{
            baseResponseDTO=dtoRequest;
            If(baseResponseDTO.requestStatusCode == 'Relationship Record Created' || baseResponseDTO.requestStatusCode == 'Auth Rejected'){
                List<OMF_ManagedFund__c> lstManagedFunds=new SEL_OMF_ManagedFunds().selectByFundCIFAndAssetManagerCIF(baseResponseDTO.parentCIFId,baseResponseDTO.childCIFId);
                if(lstManagedFunds != null && !lstManagedFunds.isEmpty()){
                    if(baseResponseDTO.requestStatusCode == 'Relationship Record Created'){
                        if(String.isBlank(baseResponseDTO.relationshipCIFId) || String.isBlank(baseResponseDTO.relationshipOSDId)){
                            createDToResponse('ERROR');
                            return baseResponseDTO;
                        }
                        OMF_ManagedFund__c fundToUpdate = new OMF_ManagedFund__c
                            (Id = lstManagedFunds[0].Id, 
                             Onboarding_Status__c= 'Legal+Credit',
                             OSD_ID__c = baseResponseDTO.relationshipOSDId, 
                             GlobalCIFNumber__c = baseResponseDTO.relationshipCIFId,
                             RejectionReason__c='',
                             RejectionDetails__c='',
                             CreatedById=lstManagedFunds[0].CreatedById);
                        Database.update(fundToUpdate);
                        //send sucess email and create post.
                        sendEmailAndCreateChatterPost('OMF_CIFApprovalNotification2',fundToUpdate);
                        createDToResponse('SUCCESS');
                        return baseResponseDTO;
                    }else if(baseResponseDTO.requestStatusCode == 'Auth Rejected'){
                        OMF_ManagedFund__c fundToUpdate = new OMF_ManagedFund__c
                            (Id = lstManagedFunds[0].Id, 
                             Onboarding_Status__c= 'Global CIF',
                             RejectionReason__c = baseResponseDTO.RequestStatusCode,
                             RejectionDetails__c=baseResponseDTO.authUser,
                             CreatedById=lstManagedFunds[0].CreatedById);
                        Database.update(fundToUpdate);
                        //send email and chatter post for failure and create task
                        createTask(fundToUpdate,baseResponseDTO.authUser);
                        sendEmailAndCreateChatterPost('OMF_CIFRejectionNotification2',fundToUpdate);
                        createDToResponse('SUCCESS');
                        return baseResponseDTO;
                    }
                }else{
                    baseResponseDTO.ERROR='Managed Fund record does not exist';
                    createDToResponse('RECORD NOT EXIST');
                    return baseResponseDTO;
                }
            }else{
                createDToResponse('ERROR');
                return baseResponseDTO;
            }
            return baseResponseDTO;
        }catch(Exception e){ 
            LOGGER.ERROR('An exception an occured: ',e);
            createDToResponse('ERROR');
            return baseResponseDTO;
        }
    }
    
}