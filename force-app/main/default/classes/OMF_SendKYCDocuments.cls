/**
* @description send email to the kyc/credit team with documents
* @Author Khushmeet Kaur
* @Company Absyz
* @Test Class OMF_SendKYCDocuments_Test
*/
public with sharing class OMF_SendKYCDocuments {
     private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('OMF_SendKYCDocuments');
    /**
     * @description Send an email to the KYC/Credit team with documents.
     * @param contentDocumentIds List of content Document IDs.
     * @param strManagedFundRecordId String of managed fund ID.
     * @param strTeamName String of team name.
     */

    public static void sendEmailWithAttachments(List<Id> contentDocumentIds,String strManagedFundRecordId,String strTeamName) {
       
        List<ContentVersion> contentVersionsToAttach  = new SEL_ContentVersion().selectByListContentDocumentId(contentDocumentIds);
        List<Id>listContentVersionId = new List<Id>();
        for(ContentVersion contentVersion : contentVersionsToAttach){
            listContentVersionId.add(contentVersion.Id);
        }
        EmailTemplate objEmailTemplate;
        String toAddress;
        List<OMFSetting__mdt> omfSetting = OMFSetting__mdt.getAll().values();
        
        if(strTeamName == 'Credit'){
            EmailTemplate[] listEmailTemplate = new SEL_EmailTemplate().selectByDeveloperName('OMF_SendCreditTeamDocuments');
            if(listEmailTemplate.size()>0){
                objEmailTemplate = listEmailTemplate[0];
            }
           
            toAddress = omfSetting.isEmpty() ? '' : omfSetting[0].CreditEmailAddress__c;
        }
        else if(strTeamName == 'KYC'){
        	//Get Email template id.
         	EmailTemplate[] listEmailTemplate = new SEL_EmailTemplate().selectByDeveloperName('OMF_SendKYCDocuments');
            if(listEmailTemplate.size()>0){
                objEmailTemplate = listEmailTemplate[0];
            }
            
			toAddress = omfSetting.isEmpty() ? '' : omfSetting[0].KYCEmailAddress__c;

            
        }
        
        
        // Step 5: Send the email using SingleEmailMessage class
        Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage(); 
        singleEmail.setToAddresses(new list<string> {toAddress}); 
        singleEmail.setTemplateId(objEmailTemplate.Id);
        singleEmail.setTargetObjectId(UserInfo.getUserId());
        singleEmail.setWhatId(strManagedFundRecordId);
        singleEmail.setSaveAsActivity(false); // Optional: Set to true if you want to save the email as an activity in Salesforce
		singleEmail.setEntityAttachments(listContentVersionId);
        // Send the email
        if (Limits.getEmailInvocations() < Limits.getLimitEmailInvocations()) {
            Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ singleEmail });
            } else {
            LOGGER.INFO('Email limit exceeded, cannot send email at this time.');
        }
    }
}