/**
 * @description       : Batch process for performing maintenance task account records
 *                      Updates to owners based on employee number and portfolio code changes
 * @author            : Derek Hughes
 * @group             : Batch
 * @last modified on  : 09-01-2024
 * @last modified by  : Derek Hughes
 * 
 * CHANGE LOG
 * 
 * 2023-07-02   Derek Hughes    Split this from BCH_AR_AccountMaintenance that will only do AR record completeness from now
 * 2023-09-21   Derek Hughes    Converted to be managed by Batch Job Scheduler framework
 * 09-20-2023   Tukelo Moseamo  Added logic to cater for BCC Business Center Manager custom client Team members
 * 2023-10-04   Derek Hughes    Added portfolio role logic to better handle RMs with multiple portfolios
 *                              NB: This will be replaced with a more robust solution based on the Sales Code design from the Universal Org
 *2023-10-23    Tukelo Moseamo  Added a fix for checking for inactive users and sbgplatform error


*/


// global is required for this class, and further simplication is not feasible
global without sharing class BCH_AccountTeamMaintenance extends sbgbase.BatchJobBase implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

	private static final String CRON_DAILY_3AM = '0 0 06 * * ?';
    private static final Integer DEFAULT_BATCH_SIZE = 500;
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('BCH_AccountTeamMaintenance');

    public static Boolean isRunning = false;

    @TestVisible
    private Boolean testMode = false;
    private Integer totalRecords = 0;
    private Integer totalBatches = 0;
    private Integer updatedOwners = 0;
    private Integer updatedScores = 0;
    private Integer updateErrors = 0;
    private Integer atmsAdded = 0;
    private Integer atmsDeleted = 0;
    private Integer clientTeamsDeleted = 0;
    private Integer clientTeamsAdded = 0;

    private Map<String, Set<Id>> rmUserIdsByPortfolioCode;
    private Map<String, Set<Id>> rmAssistantUserIdsByPortfolioCode;
    private Map<String, Id> userIdsByEmployeeNumber;
    private Map<String, Id> duplicateUserIdsByEmployeeNumber;
    private Map<String, Id> userIdByAeNumber;
    private List<UserSortable> sortedUsers; // these will be sorted by the lenght of the portfolio code to controll matching order

    private List<Account> accountsToUpdate;
    private List<String> listOfRecordTypeNames = new List<String>{
        DMN_Account.COMMERCIAL_AFRICA_TYPE,
        DMN_Account.ENTERPRISE_AFRICA_TYPE,
        DMN_Account.RT_COMMB,
        DMN_Account.RT_PERSONAL_BUSINESS_BANKING_CLIENT
    };
    private List<String> listOfProfiles = new List<String>{
        DMN_Profile.BCC_CUSTOM_STD_USER_MOBILE,
        DMN_Profile.BCC_AR_CUSTOM_STD_USER_MOBILE,
        DMN_Profile.PERSONAL_BUSINESS_BANKING_CUSTOM_STD_USER_MOBILE
    };
    
    private List<AccountTeamMember> atmsToAdd;
    private List<AccountTeamMember> atmsToDelete;   
    private List<Custom_Client_Team__c> clientTeamsToAdd;
    private List<Custom_Client_Team__c> clientTeamsToDelete;
    
    private static String bccRole = 'BCC Business Center Manager';

    /**
    * @description Requied method for schedulable classes that is called when the scheduled job is run
    * @author Derek Hughes | 19-09-2022 
    * @param sc SchedulableContext 
    **/
    public void execute(SchedulableContext sc) {
        database.executebatch(new BCH_AccountTeamMaintenance(), DEFAULT_BATCH_SIZE);
    }

    /**
    * @description Runs the batch job immediately with the default batch size
    * @author Derek Hughes | 19-09-2022 
    **/
    public static void run() {
        run(DEFAULT_BATCH_SIZE);
    }

    /**
    * @description Runs the batch job immediately with a specified batch size
    * @author Derek Hughes | 19-09-2022 
    * @param batchSize Integer - number or records to process per batch 
    **/
    public static void run(Integer batchSize) {
        Database.executeBatch(new BCH_AccountTeamMaintenance(), batchSize); 
    }

    /**
    * @description Runs the batch job immediately in test mode that only processes a limited number of record with a 100 batch size
    * @author Derek Hughes | 19-09-2022 
    **/
    public static void test() {
        Database.executeBatch(new BCH_AccountTeamMaintenance(true), 200); 
    }

    /**
    * @description Schedules a new job with a default cron schedule
    * @author Derek Hughes | 19-09-2022 
    **/
    public static void schedule() {
        schedule(CRON_DAILY_3AM);
    }

    /**
    * @description Schedules a new job with a specific cron schedule
    * @author Derek Hughes | 19-09-2022 
    * @param cron String - formatted cron string defining the job schedule  
    **/
    public static void schedule(String cron) {
        System.schedule('BCC AR Client Maintenance', cron, new BCH_AccountTeamMaintenance()); 
    }

    /**
    * @description Default contructor
    * @author Derek Hughes | 19-09-2022 
    **/
    global BCH_AccountTeamMaintenance () {
        this.testMode = false;
    }
    
    /**
    * @description Constructore for running in test mode
    * @author Derek Hughes | 19-09-2022 
    * @param testMode Boolean - true to run in test mode with limited records 
    **/
    public BCH_AccountTeamMaintenance (Boolean testMode) {
        this.testMode = testMode;
    }
    
    /**
    * @description Selects all the BCC AR clients 
    * @author Derek Hughes | 31-08-2022 
    * @param bc Database.BatchableContext  
    * @return Database.QueryLocator 
    **/
    public Database.QueryLocator start(Database.BatchableContext bc) {

        super.startJob(bc);

        loadUsers();

        //TODO:  Reduce the number of fields selected to improve performance and reduce heap size
        String query = 'SELECT RecordType.Name, Owner.ManagerId ';
        query += ' FROM Account WHERE RecordType.Name IN: listOfRecordTypeNames OR RecordType.DeveloperName IN:listOfRecordTypeNames';  
    
        // For testing purposes to keep data small and make the execution quick
        //Tukelo - added else statement to decrease the number of LOGGER events we fire
        if (this.testMode) {
            query += ' ORDER BY LastModifiedDate DESC LIMIT 200'; 
            LOGGER.warn('Batch process running in TEST MODE.  Only 200 records will be processed');
        }
        LOGGER.info('Batch process started: '+this.sortedUsers.size()+' default users loaded');        
        
        return Database.getQueryLocator(query);
    }
    
    /**
    * @description Execute method of the batch class to process a block of records
    * @author Derek Hughes | 31-08-2022 
    * @param bc Database.BatchableContext 
    * @param scope List<Account> - the accounts to process in this batch 
    **/
    public void execute(Database.BatchableContext bc, List<Account>scope) {
        
        LOGGER.debug('execute: batch: '+(totalBatches+1)+': ' +scope.size()+' records');
        
        List<Account> accounts = (List<Account>) scope;
        Integer errors = 0;
        String errorMessages = '';

        Set<Id> accountIds = new Set<Id>();
        Set<Id> managerIds = new Set<Id>();
        for (Account acc : accounts) {
            accountIds.add(acc.Id);
            managerIds.add(acc.Owner.ManagerId);
        }

        
        Map<String, SObjectField> fieldsMap = Schema.SObjectType.Account.fields.getMap();
        List<String> fieldNames = new List<String>();
        for (String fieldName : fieldsMap.keySet()) {
            fieldNames.add(fieldName);
        }
        String query = 'SELECT RecordType.Name, ';
        query += String.join(fieldNames, ', ');

        query += ', Owner.EmployeeNumber, Owner.AE_Number__c, Owner.Portfolio_Codes__c, Owner.ManagerId, Owner.Manager.isActive, ';
        query += ' (SELECT Id, AccountId, UserId, TeamMemberRole, AccountAccessLevel, OpportunityAccessLevel, CaseAccessLevel, ContactAccessLevel FROM AccountTeamMembers WHERE TeamMemberRole=\'RM Assistant\'), ';
        query += ' (SELECT Id, Client_Role__c, Team_Member__c FROM Custom_Client_Teams__r  WHERE Client_Role__c = \'BCC Business Center Manager\' OR Team_Member__c IN :managerIds) ';
        query += ' FROM Account WHERE Id IN :accountIds';  
      
        accounts = Database.query(query);

        try {
            processAccounts(accounts); 

            totalRecords += scope.size();
            totalBatches++;
            // delete any ATM records before updating the owners
            delete atmsToDelete;
            atmsDeleted += atmsToDelete.size();
    
            LOGGER.debug('execute: Updating: '+accountsToUpdate.size()+' Account records');
            String upsertFailureMessages = ''; 

            // Update any accounts with changed scores and let the trigger know not to re-calculate
            if (!accountsToUpdate.isEmpty()) {

                isRunning = true;
                Database.SaveResult[] results = Database.update(accountsToUpdate, false);
                isRunning = false;

                for (integer i = 0; i < results.size(); i++) {
                    Database.SaveResult sr = results[i];
        
                    if (!sr.isSuccess()) {
                        String errorMessage = 'Unknown error';
                        if (!sr.getErrors().isEmpty()) {
                            errorMessage = sr.getErrors()[0].getMessage();
                        }
                        errors++;
                        errorMessages += accountsToUpdate[i].Name+': Owner Update Failed: '+errorMessage +'\r\n';
                        upsertFailureMessages += 'execute: Error updating account: '+accountsToUpdate[i].Name+': '+errorMessage + '\r\n';
                        
                    }
                }
                if (String.isNotBlank(upsertFailureMessages)) {
                    LOGGER.warn(upsertFailureMessages);
                    upsertFailureMessages = '';
                }               
        
            }

            // add any new atm records
            if (!atmsToAdd.isEmpty()) {
                insert atmsToAdd;
                atmsAdded += atmsToAdd.size();
            }

            //delete old custom client teams
            if (!clientTeamsToDelete.isEmpty()) {
                delete clientTeamsToDelete;
                clientTeamsDeleted += clientTeamsToDelete.size();
            }

            if(!clientTeamsToAdd.isEmpty()) {
                Integer tempSize = clientTeamsToAdd.size();
                Database.SaveResult[] results = Database.insert(clientTeamsToAdd, false);


                for (integer i = 0; i < results.size(); i++) {
                    Database.SaveResult sr = results[i];
        
                    if (!sr.isSuccess()) {
                        String errorMessage = 'Unknown error';
                        if (!sr.getErrors().isEmpty()) {
                            errorMessage = sr.getErrors()[0].getMessage();
                        }
                        errors++;
                        upsertFailureMessages += 'execute: Error creating: '+ clientTeamsToAdd[i].Team_Member__r.Name + ' on Account: ' + clientTeamsToAdd[i].Account__c + ': ' + errorMessage + '.\r\n ';
                        tempSize--;
                    }
                }
                //Moved this out of the above loop
                if (String.isNotBlank(upsertFailureMessages)) {
                    LOGGER.warn(upsertFailureMessages);
                }                
                clientTeamsAdded += tempSize;
            }
            

            if (errors==0) {
                LOGGER.debug('execute: Update succesful');
            }
            else {
                updateErrors += errors;
                LOGGER.error('execute: Errors updating accounts: '+errors+' Account record(s) not updated');
            }
        }
        catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'BCH_AccountTeamMaintenance.execute',ex.getMessage()}, ex);
            finishBatch(bc, scope.size(), scope.size(),  'Unhandled exception:' + ex.getMessage());
            throw ex;
        }

        finishBatch(bc, scope.size(), errors, errorMessages);

    }

    /**
    * @description Processes the accounts in the execute step
    * @author Derek Hughes | 18-09-2022 
    * @param accountsToProcess List<Account> - to be processed 
    **/
    private void processAccounts (List<Account> accountsToProcess) {

        accountsToUpdate = new List<Account>();
        atmsToAdd = new List<AccountTeamMember>();
        atmsToDelete = new List<AccountTeamMember>();
        clientTeamsToAdd = new List<Custom_Client_Team__c>();
        clientTeamsToDelete = new List<Custom_Client_Team__c>();
        Map<String,List<String>> countryCode2Userfields = new Map<String,List<String>>();
        Map<String,Relationship_Management__mdt> relManageMap = new Map<String,Relationship_Management__mdt>();

        for(Relationship_Management__mdt relManager :[SELECT Id,DeveloperName,User_Fields__c,Automate_Account_Team_Updates__c,Use_Custom_Client_Team__c, Client_Team_Roles__c FROM Relationship_Management__mdt WHERE Status__c='Active']){
           String countryCode = relManager.DeveloperName;
            List<String> listOfUserFields = new List<String>();
            for (String field : relManager.User_Fields__c.split(',')) {
                
                listOfUserFields.add(field);

            }
            relManageMap.put(countryCode,relManager);
            countryCode2Userfields.put(countryCode,listOfUserFields);
        }
       
        for (Account acc: accountsToProcess) {

            Boolean updateAccount = false;
            Id newOwnerId = null;

            String portfolioCode = acc.Portfolio_Code__c?.trim().toUpperCase();
            String rmCode = acc.RelationshipMgrCode__c?.trim().toUpperCase();
            
            Id userIdForAeNumber = userIdByAeNumber.get(portfolioCode);
            Id userIdForEmployeeNumber = userIdsByEmployeeNumber.get(rmCode);

            Set<Id> rmAssistantIdsForCode = rmAssistantUserIdsByPortfolioCode.get(portfolioCode);
            if (rmAssistantIdsForCode ==null) {
                rmAssistantIdsForCode = new Set<Id>();
            }

            Set<Id> rmIdsForCode = rmUserIdsByPortfolioCode.get(portfolioCode);
            if (rmIdsForCode==null) {
                rmIdsForCode = new Set<Id>();
            }
            
            if(relManageMap.get(acc.ExternalCIFCountry__c)!=null){
                Relationship_Management__mdt relManager = relManageMap.get(acc.ExternalCIFCountry__c);
                List<String> listOfUserFields = relManager.User_Fields__c.split(',');
                for (String field :listOfUserFields){

                    // First check if there is a user with a matching Employee Number
                    if (userIdForEmployeeNumber != null && field.toUpperCase() == 'EMPLOYEENUMBER') {
                        newOwnerId = userIdForEmployeeNumber;
                        break;
                    }
                    // Second check if there is a user with a matching AE Number (primary portfolio code) 
                    else if (userIdForAeNumber != null && field.toUpperCase() == 'AE_NUMBER__C') {
                        newOwnerId = userIdForAeNumber;
                        break;
                    }
                    // Third check if there are user(s) assigned to this portfolio code and if the current owner is one of them
                    else if (rmIdsForCode.size()>0 && rmIdsForCode.contains(acc.OwnerId) && field.toUpperCase() == 'PORTFOLIO_CODES__C') {
                        newOwnerId = acc.OwnerId;
                        break;
                    } 
                    // Fourth check if there are user(s) assigned to this portfolio code and if the current owner is NOT one of them
                    else if (rmIdsForCode.size()>0 && !rmIdsForCode.contains(acc.OwnerId) && field.toUpperCase() == 'PORTFOLIO_CODES__C') {
        
                        //Allocate a random owner from the list for this code
                        Integer randomNumber = Integer.valueof((Math.random() * rmIdsForCode.size()));
                        newOwnerId = new List<Id>(rmIdsForCode).get(randomNumber);
                        break;
                    }
                    
                    // Fourth - use a default owner if there is a portfolio code - if no code then leave current owner as is.
                    else if (String.isNotBlank(portfolioCode)) {
                        
                        for (UserSortable us : sortedUsers) {
                            if (Pattern.matches(us.user.AE_Number__c.toUpperCase(), portfolioCode.toUpperCase())) {
                                newOwnerId = us.user.Id;
                                break;
                            }
                        }

                    }
                }

                if(relManager.Automate_Account_Team_Updates__c=='Yes' && !relManager.Use_Custom_Client_Team__c){
                    processAccountTeam(acc,rmAssistantIdsForCode);
                }

                List<String> availableRoles = relManager.Client_Team_Roles__c?.split(',');
                if(relManager.Use_Custom_Client_Team__c && availableRoles != null && availableRoles.contains(bccRole)) {
                    processBcmClientTeam(acc);
                }
            }

            //Has the owner changed?
            if (newOwnerId != null && acc.OwnerId != newOwnerId ) {
                acc.OwnerId = newOwnerId;
                updateAccount=true;
                updatedOwners++;
            }
            
            if (updateAccount) {
                accountsToUpdate.add(acc);
            }
        }
    }

    
    /**
    * @description logic to create custom teams member with BCC BCM roles
    * @author Tukelo Moseamo | 09-07-2023 
    * @param List<Account> accounts 
    **/
    @TestVisible
    private void processBcmClientTeam(Account acc) {

        boolean createManager = true;
        
        if (String.isNotBlank(acc.ExternalCIFCountry__c) && acc.ExternalCIFCountry__c.equalsIgnoreCase('ZA') == true) {
            try {
                List<Custom_client_Team__c> clientTeams = acc.Custom_Client_Teams__r;

                if (String.isNotBlank(acc.owner.ManagerId)) {
                    createManager = true;
                    for (Custom_client_Team__c cTeam : clientTeams) {
                        
                        if (cTeam.Client_Role__c?.equalsIgnoreCase(bccRole) == true) {
        
                            if (cTeam.Team_Member__c == acc.owner.ManagerId) {
                                createManager = false;
                            } 
                            else {
                                createManager = true;
                                clientTeamsToDelete.add(cTeam);
                            }
                        }              
                    }
        
                    if (createManager && acc.Owner.Manager.isActive) {
                        clientTeamsToAdd.add(createBCMClientTeam(acc));
                    }
                }
                else {
                    for (Custom_client_Team__c cTeam : clientTeams) {
                        if (cTeam.Client_Role__c?.equalsIgnoreCase(bccRole) == true) {
                            createManager = false;
                            clientTeamsToDelete.add(cTeam);
                        }
                    }
                }
            }
            catch (Exception ex) {
                LOGGER.error(ex.getMessage(), new String[] {'BCH_AccountTeamMaintenance.execute',ex.getMessage()}, ex);
                throw ex;
            }      
        }       
        
    }

    /**
    * @description creates custom client team member with BCC BCM roles
    * @author Tukelo Moseamo | 09-07-2023 
    * @param List<Account> accounts 
    **/
    public static Custom_Client_Team__c createBCMClientTeam(Account acc) {
        Custom_Client_Team__c cTeam = new Custom_Client_Team__c();
        cTeam.Team_Member__c = acc.Owner.ManagerId;
        cTeam.Account__c = acc.Id;
        cTeam.Client_Role__c = bccRole;
        cTeam.Opportunity_Access__c = 'Read Only';
        cTeam.Client_Access__c = 'Read Only';
        cTeam.Contact_Access__c = 'Read Only';
        cTeam.Case_Access__c = 'Read Only';
        
        return cTeam;
    }

    /**
    * @description process Account team
    * @param acc Account
    * @param rmAssistantIdsForCode Set<Id> 
    * Modification
    * 2023-10-23 - Tukelo - removed the logger line as it is in a loop
    **/    
    private void processAccountTeam (Account acc, Set<Id> rmAssistantIdsForCode) {

        rmAssistantIdsForCode = rmAssistantIdsForCode==null? new Set<Id>():rmAssistantIdsForCode;

        // CHECK IF THE ACCOUNT TEAM MEMBERS ARE CORRECT
        Set<Id> atmUserIds = new Set<Id>();
        for (AccountTeamMember atm : acc.AccountTeamMembers) {

            // if an ATM is no longer valid it will be deleted
            if (!rmAssistantIdsForCode.contains(atm.userId)) {
                atmsToDelete.add(new AccountTeamMember(Id = atm.Id));
            }
            else {
                // create a set of the remaining ATM user id for the next step
                atmUserIds.add(atm.userId);
            }

        }

        for (Id uId : rmAssistantIdsForCode) {

            if (!atmUserIds.contains(uId)) {
                AccountTeamMember newAtm = new AccountTeamMember(
                    AccountId = acc.Id,
                    UserId = uId,
                    TeamMemberRole = 'RM Assistant', 
                    AccountAccessLevel = 'Edit', 
                    OpportunityAccessLevel = 'Edit', 
                    CaseAccessLevel = 'Edit',
                    ContactAccessLevel = 'Edit' 
                );
                atmsToAdd.add(newAtm);
            }
        }
       
    }
    /**
    * @description Finish the process
    * @author Derek Hughes | 31-08-2022 
    * @param bc Database.BatchableContext 
    **/
    public void finish(Database.BatchableContext bc) {
        LOGGER.info('finish: process '+totalRecords+' in '+totalBatches+' batches with '+updateErrors+' error(s)');
             
        String finalMessage = 'Updated '+updatedOwners+' owner(s) with '+updateErrors+' error(s)\r\n';
        finalMessage += 'Account Team Member(s): added '+atmsAdded+' and deleted '+atmsDeleted+'\r\n';
        finalMessage += 'Custom Client Team member(s) added ' + clientTeamsAdded + ' and deleted ' + clientTeamsDeleted;
        
        LOGGER.info('finish: '+finalMessage);
        
        super.finishJob(bc, finalMessage);

    }

    /**
    * @description Loads the BCC AR users and create various lists and maps for use in the execute method
    * @author Derek Hughes | 18-09-2022 
    * Modification
    *2023-10-23    Tukelo Moseamo  refactoring of LOGGER lines within a loop. Added logic to allow continuation when duplicates are found and remove the dups in the list
    **/
    private void loadUsers() {

        List<User> users = [
            SELECT Id, Name, AE_Number__c, Portfolio_Role_Name__c, Portfolio_Codes__c, EmployeeNumber, IsActive, ManagerId 
            FROM User 
            WHERE IsActive = true AND Profile.Name IN:listOfProfiles
        ];

        rmUserIdsByPortfolioCode = new Map<String, Set<Id>>();
        rmAssistantUserIdsByPortfolioCode = new Map<String, Set<Id>>();
        userIdsByEmployeeNumber = new Map<String, Id>();
        duplicateUserIdsByEmployeeNumber = new Map<String, Id>();
        userIdByAeNumber = new Map<String, Id>();
        sortedUsers = new List<UserSortable>();
        String employeeMessages = '';

        for (User u : users) {
        
            // for any user that has a primary portfolio code (stored in the AE_Number field)
            if (String.isNotBlank(u.AE_Number__c)) {
                if (u.AE_Number__c.contains('*')) {
                    // Create a sortable list of users with wildcards for AE_Numbers
                    sortedUsers.add(new UserSortable(u));
                }
                else {
                    // Create map of user Id by AE Number
                    userIdByAeNumber.put(u.AE_Number__c.toUpperCase().trim(), u.Id);
                }
            }            
            
            // Create map of user Id by Employee Number
            if (String.isNotBlank(u.EmployeeNumber)) {
                String employeeNumber = u.EmployeeNumber.toUpperCase().trim();
                
                if (userIdsByEmployeeNumber.containsKey(employeeNumber)) {
                    
                    employeeMessages += 'duplicate Employee Number ('+employeeNumber+') detected on user '+u.Name + '\r\n';
                    duplicateUserIdsByEmployeeNumber.put(employeeNumber, u.Id);
                    userIdsByEmployeeNumber.remove(employeeNumber);
            
                }
                else if (!duplicateUserIdsByEmployeeNumber.containsKey(employeeNumber)) {
                    userIdsByEmployeeNumber.put(employeeNumber, u.Id);
                }                
            }            

            // Create map of user Ids by Portfolio Code and Employee NUmber
            if (String.isNotBlank(u.Portfolio_Codes__c)) {

                for (String code : u.Portfolio_Codes__c.split(',')) {
                                       
                    if (u.Portfolio_Role_Name__c == 'Relationship Manager') {
                        addCodeToMasterSet(u.Id, code, rmUserIdsByPortfolioCode);
                    }
                    else {
                        addCodeToMasterSet(u.Id, code, rmAssistantUserIdsByPortfolioCode);
                    }
                }            
            }
        
        }

        if (String.isNotBlank(employeeMessages)) {
            LOGGER.warn(employeeMessages);
        }
        

        sortedUsers.sort();

    }
   
    /** 
    * @description Adds a portfolio code to a master set
    * @author Derek Hughes | 04-10-2023 
    * @param code 
    * @param userIdsByPortfolioCode 
    **/
    private void addCodeToMasterSet (Id userId, String code, Map<String, Set<Id>> userIdsByPortfolioCode) {
        code = code.toUpperCase().trim();
        Set<Id> usersIdsForCode = userIdsByPortfolioCode.get(code);
        if (usersIdsForCode == null) {
            usersIdsForCode = new Set<Id>();
        }
        usersIdsForCode.add(userId); 
        userIdsByPortfolioCode.put(code.toUpperCase(), usersIdsForCode);
    }

    /** 
     * @description A sortable list that wraps user and can be sorted on lenght of AE_Number__c
     **/
    public class UserSortable implements Comparable {

        public User user;
        
        /**
        * @description Constructor
        * @author Derek Hughes | 19-09-2022 
        * @param u User record
        **/
        public UserSortable(User u) {
            this.user = u;
        }
        
        /**
        * @description Compare opportunities based on the opportunity amount.
        * @author Derek Hughes | 19-09-2022 
        * @param compareTo Object - the object to be comoared to  
        * @return Integer 
        **/
        public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            UserSortable compareToUser = (UserSortable)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;

            String thisCode = this.user.AE_Number__c;
            String compareCode = compareToUser.user.AE_Number__c;

            if (thisCode.length() > compareCode.length()) {
                returnValue = -1;
            } 
            else if (thisCode.length() < compareCode.length()) {
                returnValue = 1;
            } 
            return returnValue;       
        }
    }

    private class MyException extends Exception {}
}