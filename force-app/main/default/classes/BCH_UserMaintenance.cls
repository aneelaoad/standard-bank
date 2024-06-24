/**
 * @description       : 'User bacth maintenance for updating AE numbers from Referenced Data to User object'
 * @author            : Emmanuel Mulea
 * @group             : SBG
 * @Date              : July 2023
**/

public without sharing class BCH_UserMaintenance implements Database.Batchable<sObject>, Schedulable, Database.Stateful {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('BCH_UserMaintenance');
    private static final String  CRON_EXPRESSION = '0 0 03 * * ?';
    private static final Integer DEFAULT_BATCH_SIZE = 500;
    private static  String orgName = Label.ORG_NAME;
    @TestVisible
    private Boolean testMode = false;
    /**
     * @description       : run batch on default size
    **/    
    public static void run(){
       run(DEFAULT_BATCH_SIZE); 
    }
    /**
     * @description       : method to run a batch
     * @param             batchSize 
    **/     
    public static void run(Integer batchSize){
       Database.executeBatch(new BCH_UserMaintenance(), batchSize); 
    }
    /**
     * @description       : method for test run
    **/    
    public static void runTest(){
       Database.executeBatch(new BCH_UserMaintenance(true), 100); 
    }
    /**
     * @description       : overloaded constructor
     * @param             isTestMode 
    **/   
    public BCH_UserMaintenance(Boolean isTestMode){
        this.testMode = isTestMode;
        LOGGER.info('Batch process started at :: '+DateTime.now());
            
    }
    /**
     * @description       : constructor
    **/    
    public BCH_UserMaintenance(){
        this.testMode = false;
        LOGGER.info('Batch process started at :: '+DateTime.now());
        
    }
    /**
     * @description       : scheduler execute method
     * @param             sc 
    **/   
    public void execute(SchedulableContext sc) {
        database.executebatch(new BCH_UserMaintenance(), DEFAULT_BATCH_SIZE);
    }
    /**
     * @description       : scheduler method
    **/
    public static void schedule() {

        schedule(CRON_EXPRESSION);   
    }
    /**
     * @description       : scheduler method with param
     * @param             cron 
    **/    
    public static void schedule(String cron) {

        System.schedule('User Maintenance', cron, new BCH_UserMaintenance());   
    }
    /**
     * @description       : batch start
     * @param             bc 
     * @return Database.QueryLocator 
    **/    
    public Database.QueryLocator start(Database.BatchableContext bc) {
       
        //AOB_Value__c mapped to Email Address in MRI
        //AOB_Code__c mapped to AE Number in MRI
        String mriTableName = 'ACNT_EXCTV';
        String query = 'SELECT AOB_Code__c,AOB_Value__c FROM AOB_ReferencedData__c WHERE AOB_SAPField__c=:mriTableName AND AOB_Value__c!=null AND AOB_Code__c!=null'; 
        if (this.testMode) {
            query += ' LIMIT 200'; 
            LOGGER.warn('Batch process running in TEST MODE.  Only 200 records will be processed');
        }


        
        return Database.getQueryLocator(query);
    }
    /**
     * @description       : batch execute 
     * @param             bc
     * @param             scope 
    **/
    public void execute(Database.BatchableContext bc, List<AOB_ReferencedData__c>scope) {
    
        try{
            List<AOB_ReferencedData__c> accountExecutives = (List<AOB_ReferencedData__c>) scope;
         
            LOGGER.info('accountExecutives Count :: '+accountExecutives.size());
            List<User> listOfUsers = new List<User>();
            List<User> listOfOldUsers = new List<User>();
            Map<String ,String> userName2AEnumber = new Map<String ,String>();
            Map<String ,Integer> email2Count = new Map<String ,Integer>();

            Map<String ,String> aeNumber2UserName = new Map<String ,String>();
            Map<String ,User> mapOldUser = new Map<String ,User>();
            Set<String> emails = new Set<String>();
            Set<String> aeNumList = new Set<String>();
            for (AOB_ReferencedData__c ae : accountExecutives) {
                emails.add(ae.AOB_Value__c.toLowercase()+orgName);
                aeNumList.add(ae.AOB_Code__c);
                userName2AEnumber.put(ae.AOB_Value__c.toLowercase()+orgName,ae.AOB_Code__c);

                if(email2Count.get(ae.AOB_Value__c.toLowercase()+orgName)==null){
                    email2Count.put(ae.AOB_Value__c.toLowercase()+orgName,1);
                }
                else {
                    Integer emailcount = email2Count.get(ae.AOB_Value__c.toLowercase()+orgName)+1;
                    email2Count.put(ae.AOB_Value__c.toLowercase()+orgName,emailcount);
                }
            }
            String query = 'SELECT Id,AE_Number__c,Username FROM User WHERE Username IN: emails';
            String queryByAENumber = 'SELECT Id,AE_Number__c,Username FROM User WHERE AE_Number__c IN: aeNumList';
            
            listOfUsers = Database.query(query);
            listOfOldUsers = Database.query(queryByAENumber);
            for(User ur :listOfOldUsers){
                aeNumber2UserName.put(ur.AE_Number__c,ur.Username.toLowercase());
                mapOldUser.put(ur.Username.toLowercase(),ur);
            }
            processUsers(listOfUsers,userName2AEnumber,aeNumber2UserName,mapOldUser,email2Count);
        }
        catch(Exception ex){
            LOGGER.fatal('BCH_UserMaintenance execute: Unhandled exception', ex);
            LOGGER.error(ex.getMessage(), new String[] {'BCH_UserMaintenance.execute',ex.getMessage()}, ex);
            throw ex;
        }

    }
    /**
     * @description       : update user records
     * @param             listOfUsers
     * @param             userName2AEnumber 
     * @param             aEnumber2UserName 
     * @param             mapOldUser 
    **/
    private void processUsers (List<User> listOfUsers,  Map<String ,String> userName2AEnumber ,Map<String ,String> aEnumber2UserName,Map<String ,user> mapOldUser,Map<String ,Integer> email2Count) {

        List<User> oldUserList = new List<User>();
        for(User usr: listOfUsers){

            if(userName2AEnumber.get(usr.Username.toLowercase()) != null && email2Count.get(usr.Username.toLowercase())==1){
                usr.AE_Number__c = userName2AEnumber.get(usr.Username).toUpperCase();
                if(aEnumber2UserName.get(usr.AE_Number__c)!=usr.Username.toLowercase() && aEnumber2UserName.get(usr.AE_Number__c)!=null){
                    user oldUser = mapOldUser.get(aEnumber2UserName.get(usr.AE_Number__c).toLowercase());
                    oldUser.AE_Number__c ='';
                    oldUserList.add(oldUser);
                }
            }
        }

        update oldUserList;
        update listOfUsers;
    }

    /**
     * @description       : batch finishes
     * @param             bc 
    **/    
    public void finish(Database.BatchableContext bc) {
    
        LOGGER.info('Batch process ended at :: '+DateTime.now());
    }
}