/* 
* This class is template for all triggerHandlers    
* This class provide logic and methods to automate trigger handling process
*/
public abstract class ABS_TriggerHandlerBase{ 

    private static Integer eventId = 0;
    private static Map<Integer, ExecutionContext> id2Event {
                                                            get{
                                                                if(id2Event == null){
                                                                    id2Event = new Map<Integer, ExecutionContext>();
                                                                }
                                                                return id2Event;
                                                            }
                                                            set;
                                                        }
    private static Map<Id, Execution__c> Id2Execution;
    private static Map<String, Integer> unitName2Invocations{
                                                            get{
                                                                if(unitName2Invocations == null){
                                                                    unitName2Invocations = new Map<String, Integer>();
                                                                }
                                                                return unitName2Invocations;
                                                            }
                                                            set;
                                                        }
    private static String[] invocationOrder{
                                            get{
                                                if(invocationOrder == null){
                                                    invocationOrder = new String[]{};
                                                }
                                                return invocationOrder;
                                            }
                                            private set;
                                        }
    private String className{
                                get{
                                    if(className == null){
                                        className = String.valueOf(this).substringBefore(':');
                                    } 
                                    return className;
                                }
                                private set;
                            }

    private Integer execut = 0;

    public void handleTrigger() {

        alwaysRunMethods();

        if(skipTriggers()){
            return;
        }

        runMethods(); 
        
        if(Id2Execution.get(UserInfo.getUserId()) != null 
            && Id2Execution.get(UserInfo.getUserId()).Display_TriggerHandler_Details__c){
            System.debug('invocationOrder ' + invocationOrder );
            System.debug('unitName2Invocations ' + unitName2Invocations);
            System.debug('Invocation ' + id2Event.get(eventId - 1));
        }
    } 

    @TestVisible private void runMethods(){
        
        ExecutionContext exeCon = new ExecutionContext(true, generateEventName(false), eventId);
        Integer evId = eventId;
        id2Event.put(evId, exeCon);
        eventId++; 

        if (Trigger.isBefore && Trigger.isInsert) {
            handleBeforeInsert();
        }
        else if (Trigger.isAfter && Trigger.isInsert) {
            handleAfterInsert();
        }
        else if (Trigger.isBefore && Trigger.isUpdate) {
            handleBeforeUpdate();
        }
        else if (Trigger.isAfter && Trigger.isUpdate) {
            handleAfterUpdate();
        }
        else if (Trigger.isBefore && Trigger.isDelete) {
            handleBeforeDelete();
        }
        else if (Trigger.isAfter && Trigger.isDelete) {
            handleAfterDelete();
        }
        else if (Trigger.isAfter && Trigger.isUndelete) {
            handleAfterUndelete();
        }

        if(id2Event.get(evId).isOverriden){
            record(exeCon);
        }
    }
  
    // This is for overriding Trigger turn Off
    @TestVisible private void alwaysRunMethods() {
        
        ExecutionContext exeCon = new ExecutionContext(true, generateEventName(true), eventId);
        Integer evId = eventId;
        id2Event.put(evId, exeCon);
        eventId++;

        if (Trigger.isBefore && Trigger.isInsert) {
            alwaysBeforeInsert();
        }
        else if (Trigger.isAfter && Trigger.isInsert) {
            alwaysAfterInsert();
        }
        else if (Trigger.isBefore && Trigger.isUpdate) {
            alwaysBeforeUpdate();
        }
        else if (Trigger.isAfter && Trigger.isUpdate) {
            alwaysAfterUpdate();
        }
        else if (Trigger.isBefore && Trigger.isDelete) {
            alwaysBeforeDelete();
        }
        else if (Trigger.isAfter && Trigger.isDelete) {
            alwaysAfterDelete();
        }
        else if (Trigger.isAfter && Trigger.isUndelete) {
            alwaysAfterUndelete();
        }

        if(id2Event.get(evId).isOverriden){
            record(exeCon);
        }
    }
    
    @TestVisible protected virtual void handleBeforeInsert()  {useDefaultMethod();}
    @TestVisible protected virtual void handleAfterInsert()   {useDefaultMethod();}
    @TestVisible protected virtual void handleBeforeUpdate()  {useDefaultMethod();}
    @TestVisible protected virtual void handleAfterUpdate()   {useDefaultMethod();}
    @TestVisible protected virtual void handleBeforeDelete()  {useDefaultMethod();}
    @TestVisible protected virtual void handleAfterDelete()   {useDefaultMethod();}
    @TestVisible protected virtual void handleAfterUndelete() {useDefaultMethod();}

    @TestVisible protected virtual void alwaysBeforeInsert()  {useDefaultMethod();}
    @TestVisible protected virtual void alwaysAfterInsert()   {useDefaultMethod();}
    @TestVisible protected virtual void alwaysBeforeUpdate()  {useDefaultMethod();}
    @TestVisible protected virtual void alwaysAfterUpdate()   {useDefaultMethod();}
    @TestVisible protected virtual void alwaysBeforeDelete()  {useDefaultMethod();}
    @TestVisible protected virtual void alwaysAfterDelete()   {useDefaultMethod();}
    @TestVisible protected virtual void alwaysAfterUndelete() {useDefaultMethod();}

    @TestVisible protected virtual List<Sobject> triggerNew(){return null;}

    @TestVisible protected virtual void handleBeforeInsert2(Sobject[] sobj)  {useDefaultMethod();}

    private void useDefaultMethod(){ 
        ExecutionContext ec = id2Event.get(eventId - 1);
        ec.isOverriden = false;  
        id2Event.put(eventId - 1, ec);
    } 

    @TestVisible private Boolean skipTriggers() {  
        if(Id2Execution == null){
            buildExecutionMap();  
        }
        
        String userId = UserInfo.getUserId();

        if(!Id2Execution.containsKey(userId)){
            return false;
        }

        Execution__c exec = Execution__c.getInstance(userId);

        if(exec.Skip_Triggers__c){
            return true;
        }

        if(String.isNotBlank(exec.Skip_Object_Triggers__c)){
            Sobject sObj = Trigger.new != null ? Trigger.new[0] : Trigger.old[0];
            SobjectType st = sObj.getSobjectType();
            String currentObject = String.valueOf(st).toLowerCase();

            String[] objNames = exec.Skip_Object_Triggers__c.split(';');
            Set<String> objects = new Set<String>();
            for(String obj : objNames){
                if(String.isNotBlank(obj)){
                    objects.add(obj.toLowerCase());
                }
            }

            return objects.contains(currentObject);
        }
        return false;
    }


    @TestVisible private void buildExecutionMap(){
        Id2Execution = new Map<Id, Execution__c>{
                    UserInfo.getUserId() => Execution__c.getInstance(UserInfo.getUserId())
        };
    }

    public String generateEventName(Boolean hasSuffix){
        return  className + '_'  +
                 (Trigger.isBefore ? 'Before' : 'After') + '_'
                + (hasSuffix ? 'AlwawysRun_' : '')
                + (Trigger.isInsert ? 'Insert' : '')
                + (Trigger.isUpdate ? 'Update' : '')
                + (Trigger.isDelete ? 'Delete' : '')
                + (Trigger.isUndelete ? 'Undelete' : '');  
    } 

    @TestVisible private void record(ExecutionContext exeCon){
        invocationOrder.add(exeCon.eventName);
        Integer invocations =  unitName2Invocations.containsKey(exeCon.eventName) ? 
                                            unitName2Invocations.get(exeCon.eventName) : 0;
        exeCon.logLimits();
        unitName2Invocations.put(exeCon.eventName, invocations + 1);
    }

    

    public class ExecutionContext{

        public Boolean isOverriden;
        public String  eventName;
        public String  limitStart;
        public String  limitStop;
        public Integer idx;

        public ExecutionContext(Boolean isOverriden, String eventName, Integer idx){
            this.isOverriden = isOverriden;
            this.eventName   = eventName;
            this.idx         = idx; 
            this.limitStart  = buildLimitString();
        }

        public void logLimits(){
            this.limitStop = buildLimitString(); 
        }

        private String buildLimitString(){
            return 
                'Callout Limit: ' + Limits.getCallouts() + '/' + Limits.getLimitCallouts() + '\n' +
                'Future Call Limit: ' + Limits.getFutureCalls() + '/' + Limits.getLimitFutureCalls() + '\n' +
                'SOQL Queries Limit: ' + Limits.getQueries() + '/' + Limits.getLimitQueries() + '\n' +
                'Query Rows Limit: ' + Limits.getQueryRows() + '/' + Limits.getLimitQueryRows() + '\n' +
                'DML Rows Limit: ' + Limits.getDMLRows() + '/' + Limits.getLimitDMLRows() + '\n' +
                'DML Statements Limit: ' + Limits.getDMLStatements() + '/' + Limits.getLimitDMLStatements() + '\n' +
                'CPU Time Limit: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime();
        }
    }
}