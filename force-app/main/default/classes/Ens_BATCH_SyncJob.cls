/**
 * @description Ens_BATCH_SyncJob Schedulable and batchable class to sync new Business_Assessments records with ENS tool
 * jira: SFP-15261
 *
 * @author Atul Sharma
 * @date 3rd Jan, 2023
 */
public class Ens_BATCH_SyncJob implements Database.Batchable<sObject>,Database.AllowsCallouts, Database.Stateful {
    public  Datetime lastJobTimeStamp; //value will be passed from last job finish method
    private  Datetime currentJobTimeStamp; //Current job start time stamp
    private static final string JOB_NAME = Test.isRunningTest() ? 'Ens_BATCH_SyncJob_Test' : 'Ens_BATCH_SyncJob';
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('Ens_BATCH_SyncJob');

    private static final Set<Id> CIB_NBAC_IDS = new Set<Id> {
        UTL_RecordType.getRecordTypeId(DMN_BusinessAssessment.OBJ_NAME, DMN_BusinessAssessment.RT_NBAC),
        UTL_RecordType.getRecordTypeId(DMN_BusinessAssessment.OBJ_NAME, DMN_BusinessAssessment.RT_NBAC_READONLY),
        UTL_RecordType.getRecordTypeId(DMN_BusinessAssessment.OBJ_NAME, DMN_BusinessAssessment.RT_BUSINESS_ASSESSMENT)
    };

    /**
     * @param constructor
     * @param ts: last job timestamp, to be used as where clause for querying the latest scope
     * */
    public Ens_BATCH_SyncJob(Datetime ts){
        System.debug('Last timestamp:'+ts);
        this.lastJobTimeStamp = ts; 
    }
    
    /**
     * @description Schedule the job for the first time     
     * */
    public void scheduleFirstJob() {
        try{
            Datetime yestTimeStamp = System.now().addDays(-1);
            System.scheduleBatch(new Ens_BATCH_SyncJob(yestTimeStamp), JOB_NAME, Integer.valueOf(0));                            
        }catch(Exception e){ LOGGER.fatal('Failed to schedule class Ens_BATCH_SyncJob.\n StackTraceString:'+e.getStackTraceString() +'\n getMessage:'+string.valueOf(e.getMessage()) ); }
    }
    
     /**
     * @description: Batch Start Method
     * */
    public Database.QueryLocator start(Database.BatchableContext BC){
        this.currentJobTimeStamp = system.now();  //Current job time stamp for next run
        Set<Id> recordTypeIds = CIB_NBAC_IDS;
        LOGGER.info('Ens_BATCH_SyncJob.lastJobTimeStamp:'+lastJobTimeStamp);
        return Database.getQueryLocator(SEL_BusinessAssessments.newInstance().getQueryToSelectByCreatedDateAndRecordTypeIds(lastJobTimeStamp, CIB_NBAC_IDS));
    }
    
     /**
     * @description: Batch Execute Method
     * Action: post the Business_Assessment__c record created since last job run to ENS system
     * */
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        try{            
            new SRV_GatewayAPI_Ens().postAssessmentData((List<Business_Assessment__c>)scope);
        }catch (Exception e){ LOGGER.fatal('Failed Ens_BATCH_SyncJob.execute(),\n StackTraceString:'+e.getStackTraceString() +'\n getMessage:'+e.getMessage()+'\n scope :'+ scope ); }
    }
    /**
     * @description: Batch Finish Method
     * */
    public void finish(Database.BatchableContext BC){
        try{
            System.scheduleBatch(new Ens_BATCH_SyncJob(currentJobTimeStamp), JOB_NAME , Integer.valueOf(Label.ENS_SyncJobFrequency_Min)); //recursive scheduling	        		                    
        }catch (Exception e){ LOGGER.fatal('Failed Ens_BATCH_SyncJob.finish(),\n StackTraceString:'+e.getStackTraceString() +'\n getMessage:'+e.getMessage()); }
    }	
}