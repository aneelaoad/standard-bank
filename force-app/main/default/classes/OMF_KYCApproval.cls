/**
* @description RestResource Class for Handling Managed Fund KYC Approval
* @author Manisha
* @company Absyz
* @test Class OMF_KYCApproval_Test
* @JIRA Tickets     SFP-18538
*/
@RestResource(urlMapping='/omf/cif-status-update-todelete')
@SuppressWarnings('PMD.NcssMethodCount,PMD.AvoidDeeplyNestedIfStmts,PMD.StdCyclomaticComplexity,PMD.CyclomaticComplexity')
global with sharing class OMF_KYCApproval {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('OMF_KYCApproval');
    
    @HttpPatch
    /**
@description RestResource Class for Handling Managed Fund KYC ApprovalUpdates the status of a managed fund via HTTP PATCH request.
This is a global static method that can be accessed from any part of the program.
Note that the request is sent asynchronously, so the method does not block the calling thread.
*/
    global static void updateStatusOfManagedFund(){
        // Get the REST request and deserialize the JSON request body
        try{
            RestRequest request = RestContext.request;
            Map<String, Object> requestBody=(Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
            
            // Get the Salesforce ID and CIF ID from the request body
            
            String fundId = string.valueOf(requestBody.get('SalesforceId'));
            String cifId = string.valueOf(requestBody.get('CIFID')); 
            
            // Initialize the JSON response map and the list of managed fund records to update
            Map<String, String> jsonResponse = new Map<String, String>();
            List<OMF_ManagedFund__c> managedFundRecordsToUpdate = new List<OMF_ManagedFund__c>();
            
            // Get the list of relationships from the request body
            List<Object> relationships = (List<Object>)requestBody.get('relationships');                      
            
            // Loop through the relationships and create a map of CIF IDs and active statuses
            Map<String, String> cifIdByActiveStatus = new Map<String, String>();
            for (Object relationship : relationships) {
                Map<String, Object> relationshipMap = (Map<String, Object>)relationship;
                cifIdByActiveStatus.put(String.valueOf(relationshipMap.get('CifRelationshipID')), String.valueOf(relationshipMap.get('active')));
            }
            
            // Validate the parameters in the request body
            if (String.isBlank(fundId) || String.isBlank(cifId) || fundId.length() != 18) {
                jsonResponse.put('SalesforceId', fundId);
                jsonResponse.put('CIFID', cifId);
                jsonResponse.put('ERROR', 'INVALID REQUEST');
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(jsonResponse));
                RestContext.response.statusCode = 401;
                return;
            } 
            
            //*** Validate whether value salesforeceId(AccountId) passed in JSON request exists in Salesforce or not***
            List<Account> fundRecords = new SEL_Accounts().selectAccountDetail(fundId);
            if (fundRecords.isEmpty()) {
                jsonResponse.put('SalesforceId', fundId);
                jsonResponse.put('CIFID', cifId);
                jsonResponse.put('ERROR', 'Fund record does not exist');
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(jsonResponse));
                RestContext.response.statusCode = 400;
                return;
            }
            
            String onboardingStatus = 'KYC';
            List<OMF_ManagedFund__c> managedFundRecords = new SEL_OMF_ManagedFunds().selectManagedFundRecordByStatus(fundId,onboardingStatus);
            String strManagedFundRecordId;
            
            if (managedFundRecords.isEmpty()) {
                jsonResponse.put('SalesforceId', fundId);
                jsonResponse.put('CIFID', cifId);
                jsonResponse.put('FAILURE','No Records Found for Managed Fund');                 
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(jsonResponse));
                RestContext.response.statusCode = 400;
                return;
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
            
            EmailTemplate[] listEmailTemplate = new SEL_EmailTemplate().selectByDeveloperName('OMF_EmailToGenerateRelationshipRecord');
            EmailTemplate objEmailTemplate;
            if(listEmailTemplate.size()>0){
                objEmailTemplate = listEmailTemplate[0];
            }
            //Get email address from custom metadata
             List<OMFSetting__mdt> omfSetting = OMFSetting__mdt.getAll().values();
            
            Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
            singleEmail.setToAddresses(omfSetting.size() > 0 ? new String[] {omfSetting[0].CreditEmailAddress__c} : new String[] {});
            
            singleEmail.setTemplateId(objEmailTemplate.Id);
            singleEmail.setTargetObjectId(UserInfo.getUserId());
            singleEmail.setWhatId(strManagedFundRecordId);
            singleEmail.setSaveAsActivity(false); // Optional: Set to true if you want to save the email as an activity in Salesforce
            if (Limits.getEmailInvocations() < Limits.getLimitEmailInvocations()) {
                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ singleEmail });
            }else {
                LOGGER.INFO('Email limit exceeded, cannot send email at this time.');
            }
            
            callGlobalCIF(managedFundRecordsToUpdate[0].Id);
            
            RestContext.response.addHeader('Content-Type', 'application/json');
            jsonResponse.put('SalesforceId', fundId);	
            jsonResponse.put('CIFID',cifId);
            jsonResponse.put('SUCCESS','Record Updated');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(jsonResponse));                   
            RestContext.response.statusCode = 200;
            return;
        }
        catch(Exception e){ 
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.statusCode = 500;
            LOGGER.ERROR('An exception an occured: ',e);
            return;
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