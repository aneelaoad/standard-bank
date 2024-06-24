/**
* @author  		: Chandrasekhar Mokkala(chandrasekhar.mokkala@standardbank.co.za)
* @date    		: 23 August 2023
* @description 	: SFP-28741 - Batch class to Send email notifications twice a week to the Clients 	 
*/
global class SmartNudge_BatchNotificationToClient implements Database.Batchable<sObject>,Schedulable,Database.Stateful {
    public Set<Id> contactIds;
    public Id emailTemplateId;
    public String oweaId;
    public List<ResultWrapper> mailsResult;
    public Map<String,Contact> contactMap;
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SmartNudge_BatchNotificationToClient');
    /*******
    * @description custom exception class
    ******/ 
    private class CustomException extends Exception {}
    
    /******
    * @description : Preparing list of Client Dealers from the last 90 days insights. 
    * *****/
    global SmartNudge_BatchNotificationToClient(){
        LOGGER.info('SmartNudge_BatchNotificationToClient Notifications initiated at :'+System.now()); 
        try{        
            mailsResult =  new List<ResultWrapper>();
            contactMap = new Map<String,Contact>();
            contactIds = new Set<Id>();
            List<EmailTemplate> templateList = new SEL_EmailTemplate().selectByName('SmartNudge_NotificationsToClientDealer');
            List<OrgWideEmailAddress> oweaList = new SEL_OrgWideEmailAddress().selectByAddress('SmartNudge@standardbank.co.za');
            if(!templateList.isEmpty()){
                emailTemplateId = templateList[0].Id;
            }
            if(!oweaList.isEmpty()){
                oweaId = oweaList[0].Id;
            }
            prepareClientIds();
        }
        catch(Exception exp){
            LOGGER.error('SmartNudge_BatchNotificationToClient constructor Exception logged :', exp);
            throw new CustomException(exp.getMessage());
        }
    }
    /******
    * @description : Preparing client ids set . 
    * *****/
    private void prepareClientIds(){
        try{        
            List<Insight_Client_Relationship__c> activeClientInsights = new SEL_InsightClientRelationships().selectActiveInsightClientRelationships(new Set<Id>(),90,40000);
            LOGGER.debug('SmartNudge_BatchNotificationToClient:prepareClientIds Nudges size :'+activeClientInsights.size()); 
            if(!activeClientInsights.isEmpty()){
                for(Insight_Client_Relationship__c insightClientRelationship : activeClientInsights){
                    contactIds.add(insightClientRelationship.Contact__c);
                }
            }
            LOGGER.debug('SmartNudge_BatchNotificationToClient:prepareClientIds client ids to which sending mails :'+contactIds.size()); 
        }
        catch(Exception exp){
            LOGGER.error('SmartNudge_BatchNotificationToClient:prepareDealerIds Exception logged : ', exp);
            throw new CustomException(exp.getMessage());
        }
    }
    /******
    * @description : start method to fetch Clients and Client Dealers
    * @return user records
    * @param bc
    * *****/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([Select id,Name,Email from Contact where Id IN : contactIds]);
        
    }
    /******
    * @description execute method to send email notifications to Client and Client Dealer
    * @param bc
    * @param contactList
    * *****/
    global void execute(Database.BatchableContext bc, List<Contact> contactList){
        LOGGER.debug('SmartNudge_BatchNotificationToClient:execute initiated with :' +contactList.size()+' records');
        
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        try {
            if(!contactList.isEmpty()){
                LOGGER.debug('SmartNudge_BatchNotificationToClient:execute Users size :'+contactList.size());
                for(Contact contactRecord : contactList){
                    contactMap.put(contactRecord.Id,contactRecord);
                    Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(emailTemplateId, null, contactRecord.Id);
                    message.setTemplateID(emailTemplateId);
                    message.setWhatId(userInfo.getUserId());
                    message.setTreatTargetObjectAsRecipient(false);
                    message.setTargetObjectId(contactRecord.Id);
                    message.setSaveAsActivity(false);
                    message.setUseSignature(false);
                    if(String.isNotBlank(oweaId)){
                        message.setOrgWideEmailAddressId(oweaId);         
                    }
                    message.setToAddresses(new String[] {contactRecord.Email});
                    messages.add(message);
                }
                sendEmails(messages);
            }
        }
        catch (Exception ex) {
            LOGGER.error('SmartNudge_BatchNotificationToClient:execute Exception logged :', ex);
            LOGGER.error(ex.getMessage(), new String[] {'SmartNudge_BatchNotificationToClient:execute',ex.getMessage()}, ex);
        }
    }
    
    
    /******
    * @description  send email notifications to Client and Client Dealer
    * @param messages
    * *****/
    private void sendEmails(List<Messaging.SingleEmailMessage> messages){
        Messaging.SendEmailResult [] sendMailResult = Messaging.sendEmail(messages,false);  
        Integer i=0; 
        for(Messaging.SendEmailResult mailResult: sendMailResult){
            String errorMessage = '';
            if(!mailResult.isSuccess()){
                LOGGER.error('SmartNudge_BatchNotificationToClient:sendEmails Send mail each client notification result :'+mailResult);
                for(Messaging.SendEmailError err : mailResult.getErrors()) {
                    errorMessage = err.getMessage(); 
                }
                LOGGER.error('SmartNudge_BatchNotificationToClient:sendEmails Error Message While sending client notification :'+errorMessage);
            }
            
            prepareEmailResult(messages.get(i).getTargetObjectId(),mailResult.isSuccess(),errorMessage);
            i++;
        }
    }
    
    /******
    * @description  preparing email result wrapper
    * @param contactId
    * @param isSuccess
    * @param errorMessage
    * *****/
    private void prepareEmailResult(String contactId , Boolean isSuccess, String errorMessage){
        ResultWrapper emailResult = new ResultWrapper();
        emailResult.contactId = contactId;
        emailResult.isSuccess = isSuccess;
        emailResult.errorMessage = errorMessage;
        LOGGER.debug('SmartNudge_BatchNotificationToClient:prepareEmailResult Each Email Result :'+emailResult);
        mailsResult.add(emailResult);  
    }
    /******
    * @description wrapper to hold each email result 
    * *****/
    public class ResultWrapper{
        public string contactId;
        public string emailId;
        public Boolean isSuccess;
        public String errorMessage;
    }
    
    /******
    * @description schedule method to call batch class with batchsize 90
    * @param sc 
    * *****/
    global void execute(SchedulableContext sc){
        SmartNudge_BatchNotificationToClient clientNotification = new SmartNudge_BatchNotificationToClient();
        Database.executeBatch(clientNotification, 90);
    }
    /******
    * @description finish method
    * @param bc
    * *****/
    global void finish(Database.BatchableContext bc){
        LOGGER.info('SmartNudge_BatchNotificationToClient:finish Client Notifications finsh method started at :'+System.now());
        
        try{
            String csvFile = prepareCSVFile();
            Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
            Blob csvBlob = blob.valueOf(csvFile);
            
            String csvName = 'Pilot Client Emails - Salesforce Receipt Notifications'+System.now()+'.csv';
            csvAttachment.setFileName(csvName);
            csvAttachment.setBody(csvBlob);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{'SmartNudge@standardbank.co.za'};
            String subject = 'Client Emails - Salesforce Sent Notifications '+System.now();
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            email.setOrgWideEmailAddressId(oweaId);
            email.setUseSignature(false);
            email.setPlainTextBody('Please find attached delivery report showing which emails were sent out of Salesforce');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            LOGGER.info('SmartNudge_BatchNotificationToClient:finish Client Notifications finished at :'+System.now());
        }
        catch (Exception ex) {
            LOGGER.error('SmartNudge_BatchNotificationToClient:finish Exception logged :', ex);
        }
    } 
    /******
    * @description preparing csv file with emails result
    * @return string
    * *****/
    private string prepareCSVFile(){
        String csv = 'Contact Id,Email Id,IsSuccess,Error Message\n';
        for (ResultWrapper emailResult : mailsResult ) {
                csv += emailResult.contactId + ','+contactMap.get(emailResult.contactId).Email+','+emailResult.isSuccess+','+ emailResult.errorMessage + '\n';
        }
        return csv;
    }
}