/**
*@description Service  Class for Handling inbound request for Managed Fund from KYC System
*@author Raja Kumar
*@test Class OMF_API_KYCRejection_TEST and OMF_API_KYCApproval_Test
*@JIRA Tickets SFP-36557
*@date March 2024
*/
public inherited sharing class SRV_OMF_KYCStatusUpdate {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SRV_OMF_KYCStatusUpdate');
    private static OMF_API_KYCApproval.DTO_Response baseResponseDTO=new OMF_API_KYCApproval.DTO_Response();
    private static OMF_API_KYCRejection.DTO_Response rejectionResponseDTO=new OMF_API_KYCRejection.DTO_Response();
    
    /**
* @description method to build the response for the request received
* @param errorMessage
* @param successMessage
* @param notes
* @param failureMessage
*/
    @SuppressWarnings('PMD.ExcessiveParameterList')//need all this parameter to generlize the function so suppressed this PMD warning
    private static void createDToResponse(String errorMessage,String successMessage,String notes,String failureMessage){
        rejectionResponseDTO.ERROR=errorMessage;
        rejectionResponseDTO.SUCCESS=successMessage;
        rejectionResponseDTO.Notes=notes;
        rejectionResponseDTO.FAILURE=failureMessage;
        rejectionResponseDTO.RejectionReason=null;
        rejectionResponseDTO.RejectionDetails=null;
        rejectionResponseDTO.KYCAnalyst=null;
    }
     /**
* @description sends email and create a chatter post for the ManagedFund Record 
* @param emailTemplateDeveloperName
* @param managedFundRecord
*/
    private static void sendEmail(String emailTemplateDeveloperName,OMF_ManagedFund__c managedFundRecord){
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
        if(emailTemplateDeveloperName=='OMF_KYC_Rejected'){
            User reciepientAddress  = new SEL_Users().selectWithContactSyncFieldById(managedFundRecord.CreatedById);
            singleEmail.setToAddresses(new List<String>{reciepientAddress.email});
        }else if(emailTemplateDeveloperName=='OMF_EmailToGenerateRelationshipRecord'){
            singleEmail.setToAddresses(omfSetting.size() > 0 ? new String[] {omfSetting[0].GlobalCIFEmailAddress__c} : new String[] {});
        }
        singleEmail.setWhatId(managedFundRecord.Id);
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
    }
    
    /**
* @description  method to get the relationship record id from the request and process
* @param dtoRequest Dto request type (the inbound request)
* @return rejectionResponseDTO
*/
    public static OMF_API_KYCRejection.DTO_Response processInboundRequestFromKYCRejection(OMF_API_KYCRejection.DTO_Response dtoRequest){
        rejectionResponseDTO=dtoRequest;
        String onboardingStatus = 'KYC';
        //***Validate parameters of JSON request body***
        if (String.isEmpty(rejectionResponseDTO.SalesforceId) || String.isBlank(rejectionResponseDTO.RejectionReason) || String.isBlank(rejectionResponseDTO.RejectionDetails)) {
            createDToResponse('INVALID REQUEST',null,'',null);
            return rejectionResponseDTO;
        }
        //*** Validate whether value salesforeceId(AccountId) passed in JSON request exists in Salesforce or not***
        List<Account> accList = new SEL_Accounts().selectAccountDetail(rejectionResponseDTO.SalesforceId);
        if (accList.isEmpty()) {
            createDToResponse('Fund record does not exist',null,'',null);
            return rejectionResponseDTO;
        }
        try {
            List<OMF_ManagedFund__c> rejectedManagedFundList = new SEL_OMF_ManagedFunds().selectManagedFundRecordByStatus(rejectionResponseDTO.SalesforceId,onboardingStatus);
            
            if (rejectedManagedFundList.isEmpty()) {
                createDToResponse(null,null,'','No Records Found for Managed Fund');
                return rejectionResponseDTO;
            }
            else if (rejectedManagedFundList.size() > 1) {
                LOGGER.error('Records for OMF_ManagedFund__c greater than 1 '+rejectedManagedFundList.size());
            } else {
                OMF_ManagedFund__c managedFund = rejectedManagedFundList[0];
                managedFund.RejectionReason__c = rejectionResponseDTO.RejectionReason;
                managedFund.RejectionDetails__c = rejectionResponseDTO.RejectionDetails + ' - ' +rejectionResponseDTO.KYCAnalyst;
                managedFund.Onboarding_Status__c = 'Document Upload'; 
                sendEmail('OMF_KYC_Rejected',managedFund);
                createDToResponse(null,'Record Updated',managedFund.OMF_Notes__c,null);
                Database.update(managedFund);
                return rejectionResponseDTO;
            }
            return rejectionResponseDTO;
        }
        catch(System.Exception e){  
            LOGGER.error('An exception occured:',e);
            createDToResponse('Server Error',null,null,null);
            return rejectionResponseDTO;
        }
    }
    
    /**
* @description  method to get the relationship record id from the request and process
* @param requestBody 
* @return baseResponseDTO
*/
    @SuppressWarnings('PMD.AvoidDeeplyNestedIfStmts')//suppressed this as we can't avoid having nested ifs for this logic.
    public static OMF_API_KYCApproval.DTO_Response processInboundRequestFromKYC(Map<String, Object> requestBody){
        try{
            baseResponseDTO.SalesforceId=string.valueOf(requestBody.get('SalesforceId'));
            baseResponseDTO.CIFID=string.valueOf(requestBody.get('CIFID'));
            List<OMF_ManagedFund__c> managedFundRecordsToUpdate = new List<OMF_ManagedFund__c>();
            // Loop through the relationships and create a map of CIF IDs and active statuses
            Map<String, String> cifIdByActiveStatus = new Map<String, String>();
            List<Object> relationships = (List<Object>)requestBody.get('relationships'); 
            for (Object relationship : relationships) {
                Map<String, Object> relationshipMap = (Map<String, Object>)relationship;
                cifIdByActiveStatus.put(String.valueOf(relationshipMap.get('CifRelationshipID')), String.valueOf(relationshipMap.get('active')));
            }
            // Validate the parameters in the request body
            if (String.isBlank(baseResponseDTO.SalesforceId) || String.isBlank(baseResponseDTO.CIFID) || baseResponseDTO.SalesforceId.length() != 18) {
                baseResponseDTO.ERROR='INVALID REQUEST';
                return baseResponseDTO;
            } 
            // Validate whether value salesforeceId(AccountId) passed in JSON request exists in Salesforce or not***
            List<Account> fundRecords = new SEL_Accounts().selectAccountDetail(baseResponseDTO.SalesforceId);
            if (fundRecords.isEmpty()) {
                baseResponseDTO.ERROR='Fund record does not exist';
                return baseResponseDTO;
            }
            
            String onboardingStatus = 'KYC';
            List<OMF_ManagedFund__c> managedFundRecords = new SEL_OMF_ManagedFunds().selectManagedFundRecordByStatus(baseResponseDTO.SalesforceId,onboardingStatus);
            String strManagedFundRecordId;
            
            if (managedFundRecords.isEmpty()) {
                baseResponseDTO.FAILURE='No Records Found for Managed Fund';
                return baseResponseDTO;
            }
            
            else if (managedFundRecords.size()==1){
                if(!cifIdByActiveStatus.isEmpty()){
                    for(OMF_ManagedFund__c objManagedFund : managedFundRecords){
                        strManagedFundRecordId = objManagedFund.Id;
                        if(cifIdByActiveStatus.containsKey(objManagedFund.AssetManager__r.CIF__c)){
                            objManagedFund.Relationship_Record_State__c = 'Active';
                            objmanagedFund.KYC_Approved__c= true;
                        }
                        else{
                            objManagedFund.Relationship_Record_State__c = 'InActive';
                            objmanagedFund.KYC_Approved__c= true;
                        }
                        managedFundRecordsToUpdate.add(objManagedFund) ;
                    }
                }
                else{
                    for(OMF_ManagedFund__c objManagedFund : managedFundRecords){
                        strManagedFundRecordId = objManagedFund.Id;
                        objManagedFund.Relationship_Record_State__c = 'Active';
                        objmanagedFund.KYC_Approved__c= true;
                        managedFundRecordsToUpdate.add(objManagedFund) ;
                    }
                }
            }
            Database.update(managedFundRecordsToUpdate);
            sendEmail('OMF_EmailToGenerateRelationshipRecord',managedFundRecords[0]);
            callGlobalCIF(managedFundRecordsToUpdate[0].Id);
            
            baseResponseDTO.SUCCESS='Record Updated';
            return baseResponseDTO;
        }
        catch(Exception e){
            LOGGER.ERROR('An exception an occured: ',e);
            baseResponseDTO.ERROR='Server Error';
            return baseResponseDTO;
        }
    }
    /**
* @description future method to send request to global CIF system
* @param recordId
*/
    @future(callout=true)
    public static void callGlobalCIF(String recordId){
        if(String.isNotBlank(recordId)){
            OMF_API_CIFController service = new OMF_API_CIFController(recordId);
            service.sendRequest();
        }    
    }
    
    
}