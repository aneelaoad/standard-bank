/**
* @description  : OneHub - MySupport Tab related component
* User Story : SFP-4835
*
* @author Sharath Chandra (sharath.chintalapati@standardbank.co.za)
* @date October 2021
*/
public with sharing class CB_GM_CaseController {
    
    private static final String 
        USER_CONTACT_MAP_EMAIL      = 'Email',
        USER_CONTACT_MAP_NAME       = 'Name',
        USER_CONTACT_CONTACT_ID     = 'ContactID',
        CASE_OBJ_NAME               = 'Case',
        RT_CROSS_BORDER             = 'Cross_Border_CoE_Record_Type',
        PRIORITY_HIGH               = 'High',
        TPS_QUEUE					= 'Cross Border CoE Queue',
        STATUS_NEW                  = 'New';
    
    @AuraEnabled
/**
* Method creates a case from the one Hub MySupport page
* @param subject description
* @param description description of the case
* @return string which is the caseNumber of newly created case
*/   
    public static String createCase( String subject, String description ){
        Contact con;
    	List<Contact> contactList = new List<Contact>();
        Map<String, Id> userContactMap = new Map<String, String>();
        list<QueueSobject> defaultQueue = [SELECT QueueId FROM QueueSobject WHERE queue.name =:TPS_QUEUE];
        try {
            SEL_Users selUsers = new SEL_Users();
            List<User> users = selUsers.selectWithContactFieldsById(new Set<Id>{UserInfo.getUserId()});
            if (users[0] != null) {
                userContactMap.put(USER_CONTACT_MAP_EMAIL, users[0].Email);
                userContactMap.put(USER_CONTACT_MAP_NAME, users[0].Name);
                
                if(users[0].ContactId != null){
                    userContactMap.put(USER_CONTACT_CONTACT_ID, (Id) users[0].ContactId);
                }else{
                    userContactMap.put(USER_CONTACT_CONTACT_ID, (Id) users[0].Contact_Sync_ID__c);    
                }
                contactList = new SEL_Contacts().selectById(new Set<Id> {userContactMap.get(USER_CONTACT_CONTACT_ID)});
                con = contactList[0];
            }
            
            //Creating a new Case with values
            Case newCase = new Case();
            newCase.Origin = 'Web';
            newCase.Status = STATUS_NEW;
            newCase.Priority = PRIORITY_HIGH;
            newCase.Subject = subject;
            newCase.Description = description;
            newCase.ContactId = con.Id ;
            newCase.accountId = con.AccountId;
            newCase.RecordTypeId = UTL_RecordType.getRecordTypeId(CASE_OBJ_NAME, RT_CROSS_BORDER);
            newCase.OwnerId = defaultQueue[0].queueId;            
            try{
                database.insert(newCase);
            }catch (Exception e){
                throw new AuraHandledException(e.getMessage());
            }        
            
            list<Case> returnCaseList = SEL_Cases.newInstance().selectBySubject(new Set<String>{subject});
            Case c = returnCaseList.get(0);
            return string.valueOf(c.CaseNumber);
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}