/**
 * @description Send email attachted with the document.
 * @Author Khushmeet Kaur
 * @Company Absyz
 * @Test Class OMF_SendEmailWtihAttactments_Test
 */
@SuppressWarnings('PMD.CognitiveComplexity,PMD.AvoidDeeplyNestedIfStmts,PMD.NcssMethodCount,PMD.ApexDoc,PMD.LocalVariableNamingConventions,PMD.FormalParameterNamingConventions')
public with sharing class OMF_SendEmailWithAttactments {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('OMF_SendEmailWithAttactments');
    /**
     * @description Send the email with document
     * @param emailDataWrapper Wrapper of list_emailData
     */

    @InvocableMethod
    public static void sendEmailWithDocuments(List<EmailData> list_emailData){
        
        EmailData objEmailData = list_emailData.get( 0 );
        String strKYCRecordId = objEmailData.strKYCRecordId;
        String strManagedFundRecordId;
        //Get KYC Required Documents 
        Set<Id>setKycRequiredDocumentId = new set<Id>();
        for(KYC_Required_Documents__c objKYCRequiredDocument :new SEL_KYCRequiredDocuments().selectByKYCRequiredDocumentsByKYCTeamDocument(strKYCRecordId)){
            setKycRequiredDocumentId.add(objKYCRequiredDocument.Id);
            strManagedFundRecordId = objKYCRequiredDocument.KYC_Review_Status__r.ManagedFundID__c;
        }
        
        //Get content document links
        Set<Id>setContentDocumentId = new set<Id>();
        for(ContentDocumentLink objContentDocumentLink : new SEL_ContentDocumentLink().selectByLinkedEntityIdAllFields(setKycRequiredDocumentId)){
               setContentDocumentId.add(objContentDocumentLink.ContentDocumentId);
        }
        
        List<Id>setContentVersionId = new list<Id>();
        for(ContentVersion objContentVersion :new SEL_ContentVersion().selectByContentDocumentId(setContentDocumentId)){
             setContentVersionId.add(objContentVersion.Id);
       }
        
        if(setContentDocumentId.size()>0){
            EmailTemplate[] objEmailTemplate = new SEL_EmailTemplate().selectByDeveloperName('OMF_SendLegalDocuments');
            
            Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
            singleEmail.setToAddresses(new List<String>{objEmailData.strToAddress}); 
            
            if(objEmailTemplate.size()>0){
            	singleEmail.setTemplateId(objEmailTemplate[0].Id);
            }
            singleEmail.setTargetObjectId(UserInfo.getUserId());
            singleEmail.setWhatId(strManagedFundRecordId);
            singleEmail.setSaveAsActivity(false); // Optional: Set to true if you want to save the email as an activity in Salesforce
            singleEmail.setEntityAttachments(setContentVersionId);
            
            Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ singleEmail });

            // Check the results if needed
            for (Messaging.SendEmailResult result : sendResults) {
                if (result.isSuccess()) {
                    LOGGER.DEBUG('Email sent successfully.');
                } else {
                    LOGGER.ERROR('Failed to send the email: ', result.getErrors());
                }
            }
        }
    }
    
    /**
     * @description EmailData wrapper classs to store the details
     */
    public class EmailData{
        
        @InvocableVariable public String strToAddress;
        
        @InvocableVariable public String strSubject;
        
        @InvocableVariable public String strHtmlBody;
        
        @InvocableVariable public String strKYCRecordId;
        
    }
}