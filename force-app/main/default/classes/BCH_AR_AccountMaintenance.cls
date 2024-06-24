/**
 * @description       : Batch process for performing maintenance tasks on BCC AR Account records
 *                      REcalculation of record completeness score
 * @author            : Derek Hughes
 * @group             : 
 * @last modified on  : 09-01-2024
 * @last modified by  : Derek Hughes
 * 
 * CHANGE LOG
 * 
 * 2023-03-15   Derek Hughes    Fixed bug that left accounts stuck with the default owner
 * 2023-04-09   Derek Hughes    Added logic to add users to Account Team as RM Assistant role
 * 2023-05-12   Derek Hughes    Made the made query very simple and then did the comlex query in each execute batch
 * 2023-07-02   Derek Hughes    SFP-27096 Split this into two classes - moved owner and team updates to BCH_AccountTeamMaintenance
 * 2023-07-25   Derek Hughes    SFP-27096 Added Africa Regions Prospects to the calculation
 * 2023-09-21   Derek Hughes    Converted to be managed by Batch Job Scheduler framework
**/

@SuppressWarnings('PMD.AvoidGlobalModifier, PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity, PMD.CognitiveComplexity') 
// global is required for this class, and further simplication is not feasible
global without sharing class BCH_AR_AccountMaintenance extends sbgbase.BatchJobBase implements Database.Batchable<sObject>, Schedulable, Database.Stateful {

	private static final String CRON_DAILY_6AM = '0 0 06 * * ?';
    private static final Integer DEFAULT_BATCH_SIZE = 500;
    
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('BCH_AR_AccountMaintenance');

    global static Boolean isRunning = false;

    @TestVisible
    private Boolean testMode = false;
    // private Integer totalRecords = 0;
    private Integer totalBatches = 0;
    private Integer updatedScores = 0;
    // private Integer updateErrors = 0;

    private Map<String, Set<Id>> userIdsByPortfolioCode;

    private List<Account> accountsToUpdate;
   
    /**
    * @description Requied method for schedulable classes that is called when the scheduled job is run
    * @author Derek Hughes | 19-09-2022 
    * @param sc SchedulableContext 
    **/
    global void execute(SchedulableContext sc) {
        database.executebatch(new BCH_AR_AccountMaintenance(), DEFAULT_BATCH_SIZE);
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
        Database.executeBatch(new BCH_AR_AccountMaintenance(), batchSize); 
    }

    /**
    * @description Runs the batch job immediately in test mode that only processes a limited number of record with a 100 batch size
    * @author Derek Hughes | 19-09-2022 
    **/
    public static void test() {
        Database.executeBatch(new BCH_AR_AccountMaintenance(true), 100); 
    }

    /**
    * @description Schedules a new job with a default cron schedule
    * @author Derek Hughes | 19-09-2022 
    **/
    public static void schedule() {
        schedule('BCC AR Client Maintenance', CRON_DAILY_6AM);
    }

    /**
    * @description Schedules a new job with a specific cron schedule
    * @author Derek Hughes | 19-09-2022 
    * @param cron String - formatted cron string defining the job schedule  
    **/
    public static void schedule(String name, String cron) {
        System.schedule(name, cron, new BCH_AR_AccountMaintenance()); 
    }

    /**
    * @description Default contructor
    * @author Derek Hughes | 19-09-2022 
    **/
    global BCH_AR_AccountMaintenance () {
        this.testMode = false;
    }
    
    /**
    * @description Constructore for running in test mode
    * @author Derek Hughes | 19-09-2022 
    * @param testMode Boolean - true to run in test mode with limited records 
    **/
    global BCH_AR_AccountMaintenance (Boolean testMode) {
        this.testMode = testMode;
    }

    /**
    * @description Selects all the BCC AR clients 
    * @author Derek Hughes | 31-08-2022 
    * @param bc Database.BatchableContext  
    * @return Database.QueryLocator 
    **/
    global Database.QueryLocator start(Database.BatchableContext bc) {

        super.startJob(bc);

        String query = 'SELECT Id, Name ';
        query += ' FROM Account WHERE (RecordType.Name = \'' + DMN_Account.COMMERCIAL_AFRICA_TYPE + '\' OR RecordType.Name = \'' + DMN_Account.ENTERPRISE_AFRICA_TYPE + '\' )' +
            ' OR (RecordType.Name = \'' + DMN_Account.RT_PROSPECT + '\' AND Owner.UserRole.Name LIKE \'BCC AR%\')' ;  
    
        // For testing purposes to keep data small and make the execution quick
        if (this.testMode) {
            query += ' ORDER BY Name LIMIT 200'; 
            LOGGER.warn('Batch process running in TEST MODE.  Only 200 records will be processed');
        }

        LOGGER.info('Batch process started:  query: '+query);

        return Database.getQueryLocator(query);
    }
    
    /**
    * @description Execute method of the batch class to process a block of records
    * @author Derek Hughes | 31-08-2022 
    * @param bc Database.BatchableContext 
    * @param scope List<Account> - the accounts to process in this batch 
    **/
    global void execute(Database.BatchableContext bc, List<Account>scope) {
        LOGGER.debug('execute: batch: '+(totalBatches+1)+': ' +scope.size()+' records');
        
        List<Account> accounts = (List<Account>) scope;
        Integer errors = 0;
        String errorMessages = '';

        Set<Id> accountIds = new Set<Id>();
        try {

            for (Account acc : accounts) {
                accountIds.add(acc.Id);
            }

            //TODO:  Reduce the number of fields selected to improve performance and reduce heap size
            String query = 'SELECT RecordType.Name ';
            for(Schema.SObjectField fld: Schema.getGlobalDescribe().get('Account').getDescribe().fields.getMap().values()){
                query += ', ' + fld.getDescribe().getName();
            }
            query += ' FROM Account WHERE Id IN :accountIds';  
        
            accounts = Database.query(query);

            processAccounts(accounts);

            // totalRecords += scope.size();
            totalBatches++;

            LOGGER.debug('execute: Updating: '+accountsToUpdate.size()+' Account records');

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
                        errorMessages += errorMessage+'\n';
                        LOGGER.warn('execute: Error updating account: '+accountsToUpdate[i].Name+': '+errorMessage);
                    }
                }
            }

            if (errors==0) {
                LOGGER.debug('execute: Update succesful');
            }
            else {
                // updateErrors += errors;
                LOGGER.error('execute: Errors updating accounts: '+errors+' Account record(s) not updated');
            }
        }
        catch (Exception ex) {
            LOGGER.fatal('execute: Unhandled exception', ex);
            finishBatch(bc, scope.size(), scope.size(),  'Unhandled exception:' + ex.getMessage());
            throw ex;
        }

        finishBatch(bc, scope.size(), errors, errorMessages);

    }

    /**
    * @description Processes the accounts in the execute step
    * @author Derek Hughes | 18-09-2022 
    * @param accounts List<Account> - to be processed 
    * @return List<Account> 
    **/
    private void processAccounts (List<Account> accounts) {

        Map<Id, Account> accountsToBeScored = new Map<Id, Account>();
        Map<Id, Decimal> oldScores = new Map<Id, Decimal>();
    
        for (Account acc: accounts) {
            accountsToBeScored.put(acc.Id, acc);   
            oldScores.put(acc.Id, acc.Completeness_Score__c);
        }

        accountsToUpdate = new List<Account>();

        if (accountsToBeScored.size() > 0) {
            Map<Account,Map<String,Integer>> recordCompletenessRelatedData = Record_Completeness_RR_Helper.getRelatedRecord(accountsToBeScored.keySet(), accountsToBeScored);
            List<Account> scoredAccounts = CalculateRecordCompleteness.updateRecordCompletenessScore(recordCompletenessRelatedData);
            
            for (Account acc: scoredAccounts) {
                // Has the score changed?
                if (acc.Completeness_Score__c.setScale(2) <> oldScores.get(acc.Id)?.setScale(2)) {
                    accountsToUpdate.add(acc);
                    updatedScores++;
                }
            }
        }
    }
    
    /**
    * @description Finish the process
    * @author Derek Hughes | 31-08-2022 
    * @param bc Database.BatchableContext 
    **/
    global void finish(Database.BatchableContext bc) {

        super.finishJob(bc, 'Updated '+updatedScores+' scores(s)');
        
    }

    private class MyException extends Exception {}
}