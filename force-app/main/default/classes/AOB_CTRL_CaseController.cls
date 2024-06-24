/**
* @description  : Technical cases for any technical issue faced during AO in CORE
* User Story : SFP-8797
* @author Nomcebo Nzimande (nomcebo.nzimande@standardbank.co.za)
* @date January 2023 
*/
public without sharing class AOB_CTRL_CaseController {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_CTRL_CaseController');
    
    private static final String 
    USER_CONTACT_MAP_EMAIL      = AOB_Constants.EMAILFIELD,
    USER_CONTACT_MAP_NAME       = AOB_Constants.CONTACTNAME,
    USER_CONTACT_CONTACT_ID     = AOB_Constants.CONTACTID,
    CASE_OBJ_NAME               = AOB_Constants.OOBJECTCASE,
    RT_CROSS_BORDER             = AOB_Constants.CROSSBORDERTYPE ,
    PRIORITY_HIGH               = AOB_Constants.CONTACTMAPHIGH,
    TPS_QUEUE					= AOB_Constants.AOBSOUTHAFRICADFCT,
    STATUS_NEW                  = AOB_Constants.CONTACTNEWMAP,
    SUBJECT                     = AOB_Constants.ONLINEOFFERCREATION;

    @AuraEnabled
    /**
    * Method creates a case when error message is returned from API call
    * @param subject description
    * @param description description of the case
    * @return string which is the caseNumber of newly created case
    */   
    public static String createCase(String description, String applicationID ) {
        
        try{ 
            Contact con;
            List<Contact> contactList = new List<Contact>();
            Map<String, Id> userContactMap = new Map<String, String>();
            SEL_Users selUsers = new SEL_Users();
            List<User> users = selUsers.selectWithContactFieldsById(new Set<Id>{UserInfo.getUserId()});
            list<QueueSobject> defaultQueue = [SELECT QueueId FROM QueueSobject WHERE queue.name =:TPS_QUEUE];
                userContactMap.put(USER_CONTACT_MAP_EMAIL, users[0].Email);
                userContactMap.put(USER_CONTACT_MAP_NAME, users[0].Name);
                if(users[0].ContactId != null){
                    userContactMap.put(USER_CONTACT_CONTACT_ID, (Id) users[0].ContactId);
                }else{
                    userContactMap.put(USER_CONTACT_CONTACT_ID, (Id) users[0].Contact_Sync_ID__c);    
                }
                contactList = new SEL_Contacts().selectById(new Set<Id> {userContactMap.get(USER_CONTACT_CONTACT_ID)});
                con = contactList[0];        
            Case newCase;
            List<Case> results = [SELECT ID, CaseNumber, Status , Description, Account.Name, Account.Industry from CASE WHERE AccountId = :con.AccountId];
            Boolean isDescription = false;

            if (results.isEmpty()) {
                newCase = new Case(
                    ContactId = con.Id ,
                    AccountId = con.AccountId,
                    Status = STATUS_NEW,
                    Origin = AOB_Constants.CSORIGIN,
                    Priority = PRIORITY_HIGH,
                    Subject = SUBJECT,
                    Description = description,
                    RecordTypeId = UTL_RecordType.getRecordTypeId(CASE_OBJ_NAME, RT_CROSS_BORDER),
                    OwnerId = defaultQueue[0].queueId); 
                    insert newCase; 
                    
            } else  {
                for(Integer i = 0; i<results.size(); i++) {
                    if(results[i].Description == description) {
                        isDescription = true;
                        newCase = results[i];
                        break;
                    }
                }
                if  (isDescription) {
                    DateTime dt = DateTime.now();
                    String dateTimeStr = dt.format(AOB_Constants.DATEFORM);

                    String updatedDescription = description + ' '+AOB_Constants.SAMEERROR+' ' + dateTimeStr;
                    description = updatedDescription;
                    newCase.Description = updatedDescription;
                    update newCase;

                } else {
                    newCase = new Case(
                        ContactId = con.Id ,
                        AccountId = con.AccountId,
                        Status = STATUS_NEW,
                        Origin = AOB_Constants.CSORIGIN,
                        Priority = PRIORITY_HIGH,
                        Subject = SUBJECT,
                        Description = description,
                        RecordTypeId = UTL_RecordType.getRecordTypeId(CASE_OBJ_NAME, RT_CROSS_BORDER),
                        OwnerId = defaultQueue[0].queueId); 
                
                    insert newCase;  
                }
            }
            sendingEmail(description, applicationID);     
            newCase = [select id, casenumber from case where id = : newCase.id];
            return string.valueOf(newCase.CaseNumber);
        
        } catch(Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'AOB_CTRL_CaseController',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        }
    }

    private static void sendingEmail(String description, String applicationID) {

         Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
         String[] toAddresses = new String[] {System.Label.Aob_SentEmail}; 
         mail.setToAddresses(toAddresses);
         mail.setReplyTo(AOB_Constants.sentReplyTo);
         mail.setSenderDisplayName(AOB_Constants.SALESFORCEBCCAO_PRODUCTION);
         mail.setSubject(AOB_Constants.DONOTREPLY);
         mail.setBccSender(false);
         mail.setUseSignature(false);
         mail.setPlainTextBody(AOB_Constants.CASECREATED);
         mail.setHtmlBody(AOB_Constants.HELLOHTMLTAG+ applicationID +AOB_Constants.HASFAILEDONLINE+ description+AOB_Constants.GENERATEDEMAIL);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
     }
}