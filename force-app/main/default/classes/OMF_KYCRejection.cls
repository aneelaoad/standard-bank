/**
* @description  RestResource Class for Handling Managed Fund KYC Rejection
* @author Manisha
* @company Absyz
* @test Class OMF_KYCRejection_Test
* @JIRA Tickets    SFP-18381
*/
// this class will be deleted 
@RestResource(urlMapping='/omf/kyc-reject-todelete')
@SuppressWarnings('PMD.NcssMethodCount,CyclomaticComplexity')
global with sharing class OMF_KYCRejection{
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('OMF_KYCRejection');
    
    @HttpPatch
    /**
* @description Update the rejection details
*/
    global static void updateStatusOfManagedFund(){

        RestRequest req = RestContext.request;
        //***Deserialize the JSON Request into name-value pairs***
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(req.requestbody.tostring());
        String fundId = String.valueOf(params.get('SalesforceId'));
        String rejectionReason = String.valueOf(params.get('RejectionReason'));
        String rejectionDetails = String.valueOf(params.get('RejectionDetails'));
        String kycAnalyst = String.valueOf(params.get('KYCAnalyst'));
        Map<String, String> jsonResponse = new Map<String, String>();
        String onboardingStatus = 'KYC';
        
        //***Validate parameters of JSON request body***
        if (String.isEmpty(fundId) || String.isBlank(rejectionReason) || String.isBlank(rejectionDetails)) {
            jsonResponse.put('SalesforceId', fundId);
            jsonResponse.put('Notes', '');
            jsonResponse.put('ERROR', 'INVALID REQUEST');
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(jsonResponse));
            RestContext.response.statusCode = 401;
            return;
        }
        
        //*** Validate whether value salesforeceId(AccountId) passed in JSON request exists in Salesforce or not***
        List<Account> accList = new SEL_Accounts().selectAccountDetail(fundId);
        if (accList.isEmpty()) {
            jsonResponse.put('SalesforceId', fundId);
            jsonResponse.put('Notes', '');
            jsonResponse.put('ERROR', 'Fund record does not exist');
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(JSON.serialize(jsonResponse));
            RestContext.response.statusCode = 400;
            return;
        }
        try {
            List<OMF_ManagedFund__c> rejectedManagedFundList = new SEL_OMF_ManagedFunds().selectManagedFundRecordByStatus(fundId,onboardingStatus);
                
            if (rejectedManagedFundList.isEmpty()) {
                jsonResponse.put('SalesforceId', fundId);
                jsonResponse.put('Notes', '');
                jsonResponse.put('FAILURE', 'No Records Found for Managed Fund');
                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(jsonResponse));
                RestContext.response.statusCode = 400;
                return;
            }
            else if (rejectedManagedFundList.size() > 1) {
                LOGGER.error('Records for OMF_ManagedFund__c greater than 1 '+rejectedManagedFundList.size());
            } else {
                OMF_ManagedFund__c managedFund = rejectedManagedFundList[0];
                managedFund.RejectionReason__c = rejectionReason ;
                managedFund.RejectionDetails__c = rejectionDetails + ' - ' +kycAnalyst;
                managedFund.Onboarding_Status__c = 'Document Upload'; 
                    
                EmailTemplate[] listEmailTemplate = new SEL_EmailTemplate().selectByDeveloperName('OMF_KYC_Rejected');
                EmailTemplate emailTemp;
                if(listEmailTemplate.size()>0){
                    emailTemp = listEmailTemplate[0];
                }
                List<OMF_ManagedFund__c>  listManagedFund = new SEL_OMF_ManagedFunds().selectedByRecordId(managedFund.Id); 
                    
                String strUserId= (string)listManagedFund[0].CreatedById;
                    
                Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(emailTemp.Id, strUserId, managedFund.Id);
                List<String> listuser=new List<String>();
                         
                User reciepientAddress  = new SEL_Users().selectWithContactSyncFieldById(strUserId);
                        
                listuser.add(reciepientAddress.email);
                mail.setTargetObjectId(reciepientAddress.id);        
                mail.setSaveAsActivity(false);
                mail.setToAddresses(listuser);
                String emailSubject = mail.getSubject();
                String emailTextBody = mail.getPlainTextBody();
                mail.setSubject(emailSubject);
                mail.setPlainTextBody(emailTextBody);     
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                        
                jsonResponse.put('SalesforceId', fundId);
                jsonResponse.put('Notes', managedFund.OMF_Notes__c);
                jsonResponse.put('SUCCESS', 'Record Updated');
                RestContext.response.addHeader('Content-Type', 'application/json');
                        
                RestContext.response.responseBody = Blob.valueOf(JSON.serialize(jsonResponse));
                RestContext.response.statusCode = 200;
                    
                try{
                    update managedFund;
                }
                catch(System.Exception e){
                    LOGGER.error('An exception occured:',e);
                }
                return;
            }
        }
        catch(System.Exception e){  
            LOGGER.error('An exception occured:',e);
            return;
        }
    }
}