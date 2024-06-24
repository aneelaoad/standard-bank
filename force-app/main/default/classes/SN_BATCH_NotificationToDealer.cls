/********************************************
* @author  		: Chandrasekhar Mokkala(chandrasekhar.mokkala@standardbank.co.za)
* @date    		: 25 August 2023
* @description 	: SFP-28741 - Batch class to Send email notifications twice a week to Client Dealer  	 
*/
global class SN_BATCH_NotificationToDealer implements Database.Batchable<sObject>,Schedulable,Database.Stateful {
    public Set<Id> userIds;
    public Id emailTemplateId;
    public String oweaId;
    public List<ResultWrapper> mailsResult;
    public Map<String,User> userMap;
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SN_BATCH_NotificationToDealer');
    /*******
    * @description custom exception class
    ******/ 
    private class CustomException extends Exception {}
    
    /******
    * @description : Preparing list of Client Dealers and Clients from the last 90 days insights. 
    * *****/
    global SN_BATCH_NotificationToDealer(){
        LOGGER.info('SN_BATCH_NotificationToDealer Client Notifications initiated at :'+System.now()); 
        try{        
            mailsResult =  new List<ResultWrapper>();
            userMap = new Map<String,User>();
            userIds = new Set<Id>();
            List<EmailTemplate> templateList = new SEL_EmailTemplate().selectByName('SmartNudge_NotificationsToClient');
            List<OrgWideEmailAddress> oweaList = new SEL_OrgWideEmailAddress().selectByAddress('SmartNudge@standardbank.co.za');
            if(!templateList.isEmpty()){
                emailTemplateId = templateList[0].Id;
            }
            if(!oweaList.isEmpty()){
                oweaId = oweaList[0].Id;
            }
            prepareDealerUserIds();
        }
        catch(Exception exp){
            LOGGER.error('SN_BATCH_NotificationToDealer constructor Exception logged :', exp);
            throw new CustomException(exp.getMessage());
        }
    }
    /******
    * @description : Preparing dealer user ids set . 
    * *****/
    private void prepareDealerUserIds(){
        try{        
            List<Insight__c> activeCustomerInsights = new SEL_Insights().selectAcitveInsightsByDateAndPersona(90,'Client',40000);
            LOGGER.debug('SN_BATCH_NotificationToDealer:prepareDealerUserIds Nudges size :'+activeCustomerInsights.size()); 
            if(!activeCustomerInsights.isEmpty()){
                Set<String> insightIds = new Set<String>();
                for(Insight__c insight : activeCustomerInsights){
                    userIds.add(insight.OwnerId);
                    insightIds.add(insight.Id);
                }
                List<Insight__Share> insightShareList = new SEL_InsightShares().getInsightSharesByInsightPersonaAndInsightIds(insightIds,'Client');
                LOGGER.debug('SN_BATCH_NotificationToDealer:prepareDealerUserIds Insight share size :'+insightShareList.size()); 
                for(Insight__Share insightShare : insightShareList){
                    userIds.add(insightShare.UserOrGroupId);
                }
                LOGGER.debug('SN_BATCH_NotificationToDealer:prepareDealerUserIds set of dealer ids :'+userIds); 
            }
        }
        catch(Exception exp){
            LOGGER.error('SN_BATCH_NotificationToDealer:prepareClientUserIds Exception logged : ', exp);
            throw new CustomException(exp.getMessage());
        }
    }
    /******
    * @description : start method to fetch Clients and Client Dealers
    * @return user records
    * @param bc
    * *****/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([Select id,Name,Email from User where Id IN : userIds and isActive=true]);
        
    }
    /******
    * @description execute method to send email notifications to Client and Client Dealer
    * @param bc
    * @param userList
    * *****/
    global void execute(Database.BatchableContext bc, List<User> userList){
        LOGGER.debug('SmartNudge_BatchNotificationToClient:execute batch :' +userList.size()+' records');
        
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        try {
            if(!userList.isEmpty()){
                LOGGER.debug('SN_BATCH_NotificationToDealer:execute Users size :'+userList.size());
                for(User userRecord : userList){
                    userMap.put(userRecord.Id,userRecord);
                    Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(emailTemplateId, null, userRecord.Id);
                    message.setTemplateID(emailTemplateId);
                    message.setWhatId(userInfo.getUserId());
                    message.setTreatTargetObjectAsRecipient(false);
                    message.setTargetObjectId(userRecord.Id);
                    message.setSaveAsActivity(false);
                    message.setUseSignature(false);
                    if(String.isNotBlank(oweaId)){
                        message.setOrgWideEmailAddressId(oweaId);         
                    }
                    message.setToAddresses(new String[] {userRecord.Email});
                    messages.add(message);
                }
                sendEmails(messages);
            }
        }
        catch (Exception ex) {
            LOGGER.error('SN_BATCH_NotificationToDealer:execute Exception logged :', ex);
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
                LOGGER.error('SN_BATCH_NotificationToDealer:sendEmails Send mail each client notification result :'+mailResult);
                for(Messaging.SendEmailError err : mailResult.getErrors()) {
                    errorMessage = err.getMessage(); 
                }
                LOGGER.error('SN_BATCH_NotificationToDealer:sendEmails Error Message While sending client notification :'+errorMessage);
            }
            
            prepareEmailResult(messages.get(i).getTargetObjectId(),mailResult.isSuccess(),errorMessage);
            i++;
        }
    }
    
    /******
    * @description  preparing email result wrapper
    * @param userId
    * @param isSuccess
    * @param errorMessage
    * *****/
    private void prepareEmailResult(String userId , Boolean isSuccess, String errorMessage){
        ResultWrapper emailResult = new ResultWrapper();
        emailResult.userId = userId;
        emailResult.isSuccess = isSuccess;
        emailResult.errorMessage = errorMessage;
        LOGGER.debug('SN_BATCH_NotificationToDealer:prepareEmailResult Each Email Result :'+emailResult);
        mailsResult.add(emailResult);  
    }
    /******
    * @description wrapper to hold each email result 
    * *****/
    public class ResultWrapper{
        public string userId;
        public string emailId;
        public Boolean isSuccess;
        public String errorMessage;
    }
    
    /******
    * @description finish method
    * @param bc
    * *****/
    global void finish(Database.BatchableContext bc){
        LOGGER.info('SN_BATCH_NotificationToDealer:finish Client Notifications finsh method started at :'+System.now());
        
        try{
            String csvFile = prepareCSVFile();
            Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
            Blob csvBlob = blob.valueOf(csvFile);
            
            String csvName = 'Pilot Client Dealer Emails - Salesforce Receipt Notifications'+System.now()+'.csv';
            csvAttachment.setFileName(csvName);
            csvAttachment.setBody(csvBlob);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[]{'SmartNudge@standardbank.co.za'};
            String subject = 'Client Dealer Emails - Salesforce Sent Notifications '+System.now();
            email.setSubject(subject);
            email.setToAddresses(toAddresses);
            email.setOrgWideEmailAddressId(oweaId);
            email.setUseSignature(false);
            email.setPlainTextBody('Please find attached delivery report showing which emails were sent out of Salesforce');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttachment});
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            LOGGER.info('SN_BATCH_NotificationToDealer:finish Client Notifications finished at :'+System.now());
        }
        catch (Exception ex) {
            LOGGER.error('SN_BATCH_NotificationToDealer:finish Exception logged :', ex);
        }
    } 
    
    /******
    * @description schedule method to call batch class with batchsize 90
    * @param sc 
    * *****/
    global void execute(SchedulableContext sc){
        SN_BATCH_NotificationToDealer dealerNotification = new SN_BATCH_NotificationToDealer();
        Database.executeBatch(dealerNotification, 90);
    }
    
    /******
    * @description preparing csv file with emails result
    * @return string
    * *****/
    private string prepareCSVFile(){
        String csv = 'User Id,Email Id,IsSuccess,Error Message\n';
        for (ResultWrapper emailResult : mailsResult ) {
                csv += emailResult.userId + ','+userMap.get(emailResult.userId).Email+','+emailResult.isSuccess+','+ emailResult.errorMessage + '\n';
        }
        return csv;
    }
}