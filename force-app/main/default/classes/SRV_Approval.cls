/**
* @author Artur Kepczynski
* @date   May 2018
* @description Service class for Approval functionality, allows easy operations on ProcessInstance and ProcessInstanceWorkitem
* @US US-2958
* @usage    SRV_Approval srv = new SRV_Approval();
*           srv.apply(<some ProcessInstance>);
*           srv.approve();
*/
public without sharing class SRV_Approval {


    public static final String
    APPROVE = 'Approve',
    REJECT  = 'Reject',
    RECALL  = 'Removed',
    COMMENT = 'Automatic action',
	PENDING = 'Pending',
        COMMENT_APPROVE = 'Automatic approve comment',
        COMMENT_RECALL = 'Automatic cancellation due to no response',
        COMMENT_REJECTION = 'Automatic cancellation due to no response',
        COMMENT_REJECTION_CLEAN_UP  = 'Automation cancellation due to system clean up';
        

    @TestVisible
    private static Map<String, Approval_Configuration__mdt> approvalName2Config{
        get{
            if(approvalName2Config == null){
                approvalName2Config = new Map<String, Approval_Configuration__mdt>();
                for(Approval_Configuration__mdt ac : [  SELECT DeveloperName, Auto_Reject__c, Reminder_Template_Name__c,
                                                            Send_Reminder_After__c, Rejection_Template_Name__c
                                                        FROM Approval_Configuration__mdt]){
                    approvalName2Config.put(ac.DeveloperName, ac);
                }
            }
            return approvalName2Config;
        }
        set;
    }
    

    private Map<Id, ProcessInstance> id2ProcessInstance{
        get{
            if(id2ProcessInstance == null){
                id2ProcessInstance = new Map<Id, ProcessInstance>();
            }
            return id2ProcessInstance;
        }
        set;
    }

    private Map<String, String> item2Comment{
        get{
            if(item2Comment == null){
                item2Comment = new Map<String, String>{ APPROVE => COMMENT_APPROVE,
                REJECT  => COMMENT_REJECTION,
                RECALL  => COMMENT_RECALL};
            }
            return item2Comment;
        }
        set;
    }
    
    private ProcessInstanceWorkitem[] workitems{
        get{
            if(workitems == null){
                workitems = new ProcessInstanceWorkitem[]{};
            }
            return workitems;
        }
        set;
    }

    private void cacheActors(){
        Set<Id> usrId = new Set<Id>();

        for(ProcessInstanceWorkitem wi : workitems){
            usrId.add(wi.ActorId);
        }

        UTL_User.cacheUsers(usrId);
    }

    /**
     * Return set of names for processes that was included in configuration
     * @return Type: Set<String>
     */
    public static Set<String> getProcessesWithConfig(){
        return approvalName2Config.keySet();
    }
    
    /**
     * Check if particular ProcessInstance actors should receive reminder
     * @param pi Type: ProcessInstance
     * @return Type: Boolean
     */
    public static Boolean isReminderRequired(ProcessInstance pi){
        Integer elapsedTimeInDays = getElapsedTimeInDays(pi);
        Approval_Configuration__mdt config;
        
        try {
            config = getConfig(pi.ProcessDefinition.DeveloperName);
        }
        catch(SRV_ApprovalException ex){
            return false;
        }
        catch (Exception ex){
            throw new SRV_ApprovalException(ex);
        }

        return config != null && elapsedTimeInDays == (Integer)config.Send_Reminder_After__c;
    }

    /**
     * Check if particular ProcessInstance should be rejected
     * @param pi Type: ProcessInstance
     * @return Type: Boolean
     */
    public static Boolean isAutoRejectRequired(ProcessInstance pi){

        Integer elapsedTimeInDays = getElapsedTimeInDays(pi);
        Approval_Configuration__mdt config;
    
        try {
            config = getConfig(pi.ProcessDefinition.DeveloperName);
        }
        catch(SRV_ApprovalException ex){
            return false;
        }
        catch (Exception ex){
            throw new SRV_ApprovalException(ex);
        }
        return config != null && elapsedTimeInDays >= (Integer)config.Auto_Reject__c;
    }

    private static integer getElapsedTimeInDays(ProcessInstance pi){
        if(pi.ElapsedTimeInDays == null){
            throw new SRV_ApprovalException('ElapsedTimeInDays not populated');
        }
        return (Integer)pi.ElapsedTimeInDays;
    }
    
    private static Approval_Configuration__mdt getConfig(String processName){
        if(!approvalName2Config.containsKey(processName)){
            throw new SRV_ApprovalException('No Matching Configuration');
        }
        return approvalName2Config.get(processName);
    }

    /**
     * Allow to add new ProcessInstance to instance context
     * @param pi Type: ProcessInstance
     */
    public void apply(ProcessInstance pi){
        apply(new ProcessInstance[]{pi});
    }
    
    /**
     * Allow to add new ProcessInstances to instance context
     * @param pis Type: ProcessInstance[]
     */
    public void apply(ProcessInstance[] pis){
        for(ProcessInstance pi : pis){
            id2ProcessInstance.put(pi.Id, pi);
        }
    }

    /**
     * Allow to add new ProcessInstanceWorkitem to instance context
     * @param piw Type: ProcessInstanceWorkitem
     */
    public void apply(ProcessInstanceWorkitem piw){
        apply(new ProcessInstanceWorkitem[]{piw});
    }
    
    /**
     * Allow to add new ProcessInstanceWorkitems to instance context
     * @param piws Type: ProcessInstanceWorkitem[]
     */
    public void apply(ProcessInstanceWorkitem[] piws){
        for(ProcessInstanceWorkitem piw : piws){
            if(!workitems.contains(piw)){
                workitems.add(piw);
            }
        }
    }
    
    /**
     * Allow to add new ProcessInstance to instance context
     * @param pi Type: ProcessInstance
     */
    public void apply(ProcessInstance pi, String comment){
        apply(new ProcessInstance[]{pi});
    }
    
    /**
     * Allow to add new ProcessInstances to instance context
     * @param pis Type: ProcessInstance[]
     */
    public void apply(ProcessInstance[] pis, String[] comments){
        for(ProcessInstance pi : pis){
            id2ProcessInstance.put(pi.Id, pi);
        }
    }
    
    /**
     * Allow to add new ProcessInstanceWorkitem to instance context and comment
     * @param piw Type: ProcessInstanceWorkitem
     * @param comment Type: String
     */
    public void apply(ProcessInstanceWorkitem piw, String comment){
        apply(new ProcessInstanceWorkitem[]{piw}, new String[]{comment});
    }
    
    /**
     * Allow to add new ProcessInstanceWorkitem to instance context and comments
     * @param piws Type: ProcessInstanceWorkitem[]
     * @param comments Type: String[]
     */
    public void apply(ProcessInstanceWorkitem[] piws, String[] comments){
        
        if(comments.size() != comments.size() && !comments.isEmpty()){
            throw new SRV_ApprovalException('List of comments must match list of ProcessInstanceWorkitems');
        }
        
        for(Integer i = 0; i < piws.size(); i++ ){
            ProcessInstanceWorkitem piw = piws[i];
            String comment = comments[i];
            if(!workitems.contains(piw)){
                workitems.add(piw);
            }
            if(String.isNotBlank(comment)) {
                item2Comment.put(piw.Id, comment);
            }
        }
    }
    
    /**
     * clear current instance context data
     */
    public void clearData(){
        id2ProcessInstance = null;
        workitems = null;
        item2Comment = null;
    }

    /**
     * Approve instance context ProcessInstances
     */
    public Approval.ProcessResult[] approve(){
        return process(APPROVE);
    }

    /**
     * Reject instance context ProcessInstances
     */
    public Approval.ProcessResult[] reject(){
        return process(REJECT);
    }

    public Approval.ProcessResult[] recall(){
        return process(RECALL);
    }

    public Approval.ProcessResult[] rejectCleanUp(){
        return process(REJECT);
    }

    
    private Approval.ProcessResult[] process(String actionName){
    
        if(id2ProcessInstance.isEmpty() && workitems.isEmpty() ){
            throw new SRV_ApprovalException('You have to set at leats one Approval to be processed!');
        }
        workitems = fetchWorkitems();
        ProcessInstanceWorkitem[] currentWorkitems = workitems;
        cacheActors();
        
        Approval.ProcessWorkitemRequest[] requests = new Approval.ProcessWorkitemRequest[]{};
    
        for(ProcessInstanceWorkitem pi : currentWorkitems){
      
            Approval.ProcessWorkitemRequest newRequest = new Approval.ProcessWorkitemRequest();
            newRequest.setAction(actionName);
            
            String comment;

            if(item2Comment.containsKey(pi.Id)){
                comment = item2Comment.get(pi.Id);
            }
            else if (item2Comment.containsKey(pi.ProcessInstanceId)){
                comment = item2Comment.get(pi.ProcessInstanceId);
            }
            else{
                comment = item2Comment.get(actionName);
            }
            newRequest.setComments(comment);
            
            newRequest.setWorkitemId(pi.Id);
            requests.add(newRequest);
            }
        
        if(requests.isEmpty()){
            return new Approval.ProcessResult[]{};
        }
        
        return Approval.process(requests);
    }

    private ProcessInstanceWorkitem[] fetchWorkitems(){
        return [SELECT Id, ProcessInstance.TargetObjectId, ProcessInstance.ProcessDefinition.DeveloperName, Actor.Email,
                    ProcessInstance.Status, ActorId, Actor.Name
                FROM ProcessInstanceWorkitem
                WHERE (ProcessInstanceId IN:  id2ProcessInstance.values()
                    OR Id IN: workitems )
                    AND IsDeleted = false
                    AND ProcessInstance.Status =: PENDING
                    ORDER BY ProcessInstanceId ];
    }

    /**
     * Send Reminders to Actors related to context ProcessInstances
     */
    public Messaging.SendEmailResult[] sendReminderEmails(){
        Messaging.SingleEmailMessage[] messages = new Messaging.SingleEmailMessage[]{};
        User sfAdministration = UTL_User.getSfAdministrationUser();

        for(ProcessInstanceWorkitem piw : fetchWorkitems()){
            if(piw.ActorId != sfAdministration.Id) {
            messages.add(createApprovalReminder(piw));
        }
        }
        
        if(messages.isEmpty()){
            return new Messaging.SendEmailResult[]{};
        }

        return Messaging.sendEmail(messages, false);
    }

    /**
     * Send Rejction emails to Actors related to context ProcessInstances
     */
    public Messaging.SendEmailResult[] sendRejectionEmails(){
        Messaging.SingleEmailMessage[] messages = new Messaging.SingleEmailMessage[]{};
    
        for(ProcessInstanceWorkitem piw : fetchWorkitems()){
            messages.add(createApprovalRejection(piw));
        }
        return Messaging.sendEmail(messages, false);
    }

    private static Messaging.SingleEmailMessage createApprovalRejection(ProcessInstanceWorkitem piw){
        Approval_Configuration__mdt config = getConfig(piw.ProcessInstance.ProcessDefinition.DeveloperName);
        EmailTemplate et = UTL_EmailTemplate.getTemplate(config.Rejection_Template_Name__c);

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setWhatId(piw.ProcessInstance.TargetObjectId);
        email.setTargetObjectId(UTL_User.getCachedUser(piw.ActorId).Contact_Sync_ID__c);
        email.setTreatTargetObjectAsRecipient(false);
        email.setTemplateId(et.Id);
        email.setSaveAsActivity(false);
        email.setToAddresses(new String[]{piw.Actor.Email});

        return email;
    }

    private static Messaging.SingleEmailMessage createApprovalReminder(ProcessInstanceWorkitem piw){
    
        Approval_Configuration__mdt config = getConfig(piw.ProcessInstance.ProcessDefinition.DeveloperName);
        
        EmailTemplate et = UTL_EmailTemplate.getTemplate(config.Reminder_Template_Name__c);
    
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    
        String body = et.HtmlValue.replace('{!ApprovalRequest.External_URL}',
            Url.getSalesforceBaseUrl().toExternalForm() + '/p/process/ProcessInstanceWorkitemWizardStageManager?id=' + piw.Id);

        email.setWhatId(piw.ProcessInstance.TargetObjectId);
        email.setTargetObjectId(UTL_User.getCachedUser(piw.ActorId).Contact_Sync_ID__c);
        email.setTreatTargetObjectAsRecipient(false);
        email.setHtmlBody(body);
        email.setSubject(et.Subject);
        email.setTreatBodiesAsTemplate(true);
        email.setSaveAsActivity(false);
        email.setToAddresses(new String[]{piw.Actor.Email});
        
        return email;
    }
    
    public class SRV_ApprovalException extends Exception{}
}