/********************************************
* @author  	: Chandrasekhar Mokkala
* @date    	: 15 August 2022
* @description : Batch class to Send email notifications to CST members
*
* ModifiedDate  modifiedby     		Story    	Description
* 2023-05-12    Chandrasekhar  		SFP-25324	SmartNudge: Update Email notification criteria	
* 2023-09-05    Chandrasekhar  		SFP-28741	SmartNudge External Pilot 1a	 
*/
global class SmartNudge_BatchInsightsInMyPortfolio implements Database.Batchable<sObject>,Schedulable{
    public Set<Id> userIds;
    public Set<Id> userIdSet;
    public Id emailTemplateId;
    public String oweaId;
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('SmartNudge_BatchInsightsInMyPortfolio');
    
    /*******
    * @description custom exception class
    ******/ 
    private class CustomException extends Exception {}
    
    /******
     * @description : Preparing list of CST members from the last 90 days insights. 
     * *****/
    global SmartNudge_BatchInsightsInMyPortfolio(){
        LOGGER.info('SmartNudge_BatchInsightsInMyPortfolio Weekely internal user Notifications initiated at :'+System.now());
        try{      
            userIds = new Set<Id>();
            userIdSet = new Set<Id>();
            List<EmailTemplate> templateList = new SEL_EmailTemplate().selectByName('SmartNudge_NotificationsToCSTmembers');
            List<OrgWideEmailAddress> oweaList = new SEL_OrgWideEmailAddress().selectByAddress('SmartNudge@standardbank.co.za');
            if(!templateList.isEmpty()){
                emailTemplateId = templateList[0].Id;
            }
            if(!oweaList.isEmpty()){
                oweaId = oweaList[0].Id;
            }
            getProductSpecialistUserIds();
            LOGGER.debug('SmartNudge_BatchInsightsInMyPortfolio List of product specialist ids :'+userIds); 
        }
        catch(Exception exp){
            LOGGER.error('SmartNudge_BatchInsightsInMyPortfolio constructor Exception logged : ', exp);
            throw new CustomException(exp.getMessage());
        }
    }
    /******
    * @description : Preparing prodduct specialst user ids set to whom we are sending mails. 
    * *****/
    private void getProductSpecialistUserIds(){
        LOGGER.info('SmartNudge_BatchInsightsInMyPortfolio:getProductSpecialistUserIds initiated :');
        try{  
            List<Insight__c> activeCustomerInsights = new SEL_Insights().selectAcitveInsightsByDateAndPersona(90,'',40000);
            LOGGER.debug('SmartNudge_BatchInsightsInMyPortfolio Nudges size :'+activeCustomerInsights.size()); 
            if(!activeCustomerInsights.isEmpty()){
                Set<String> insightIds = new Set<String>();
                for(Insight__c insight : activeCustomerInsights){
                    userIdSet.add(insight.OwnerId);
                    insightIds.add(insight.Id);
                }
                List<Insight__Share> insightShareList = new SEL_InsightShares().getInsightSharesByInsightPersonaAndInsightIds(insightIds,'');
                for(Insight__Share insightShare : insightShareList){
                    userIdSet.add(insightShare.UserOrGroupId);
                }
                if(!userIdSet.isEmpty()){
                    for(PermissionSetAssignment ps : new SEL_PermissionSetAssignments().selectByPermissionSetNameAndAssigneeIds('Akili_Insights_Access',userIdSet)){
                        userIds.add(ps.AssigneeId);
                    }
                }
            }
        }
        catch(Exception exp){
            LOGGER.error('SmartNudge_BatchInsightsInMyPortfolio:getProductSpecialistUserIds Exception logged : ', exp);
			throw new CustomException(exp.getMessage());
        }
    }
    /******
     * @description : start method to fetch CST members
     * @return user records
     * @param bc
     * *****/
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([Select id,Name,Email from User where Id IN : userIds and isActive=true]);
                                                                      
    }
    /******
     * @description execute method to send email notifications to CST members
     * @param bc
     * @param userList
     * *****/
    global void execute(Database.BatchableContext bc, List<User> userList){
        LOGGER.debug('SmartNudge_BatchInsightsInMyPortfolio:execute initiated with :' +userList.size()+' records');
        try {
            List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
            if(!userList.isEmpty()){
                for(User userRecord : userList){
                    Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(emailTemplateId, null, userRecord.Id);
                    message.setTemplateID(emailTemplateId);
                    message.setWhatId(userInfo.getUserId());
                    message.setTreatTargetObjectAsRecipient(false);
                    message.setTargetObjectId(userRecord.Id);
                    message.setSaveAsActivity(false);
                    if(String.isNotBlank(oweaId)){
                        message.setOrgWideEmailAddressId(oweaId);         
                    }
                    message.setToAddresses(new String[] {userRecord.Email});
                    messages.add(message);
                }
                Messaging.sendEmail(messages);  
            }
        }
        catch (Exception ex) {
            LOGGER.error('SmartNudge_BatchInsightsInMyPortfolio:execute Exception logged : ', ex);
        }
    } 
    /******
     * @description schedule method to call batch class with batchsize 90
     * @param sc 
     * *****/
    global void execute(SchedulableContext sc){
        SmartNudge_BatchInsightsInMyPortfolio clientsInMyPortfolio = new SmartNudge_BatchInsightsInMyPortfolio();
        Database.executeBatch(clientsInMyPortfolio, 90);
    }
    /******
     * @description finish method
     * @param bc
     * *****/
    global void finish(Database.BatchableContext bc){
        LOGGER.info('SmartNudge_BatchInsightsInMyPortfolio:finish Weekely internal user Notifications Completed at :'+System.now());
    }    
}