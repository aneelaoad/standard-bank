/**
 * @description Trigger handler class for the Call_Report__c object
 */
public class TRH_CallReport extends ABS_TriggerHandlerBase {

    private Call_Report__c[] records{
                                        get{
                                                return (Call_Report__c[])Trigger.new;
                                        }
                                    }

    private Call_Report__c[] oldRecords{
                                        get{
                                            return (Call_Report__c[])Trigger.old;
                                        }
                                    }

    private Map<Id, Call_Report__c> id2OldRecords{
                                                    get{
                                                        if(Trigger.old == null){
                                                            return null;
                                                        }
                                                        return new Map<Id, Call_Report__c>(oldRecords);
                                                    }
                                                }

    /**
     * @description Trigger handler for Before Insert
     */
    public override void handleBeforeInsert(){
        handleEventReportChange(records, oldRecords);
        DMN_CallReport.syncDivsionInfo(records, id2OldRecords); 
    } 

    /**
     * @description Trigger handler for After Insert
     */    
    public override void handleAfterInsert(){
        DMN_CallReport.sendEmailToRelatedClients(records); 
        SA_EventTriggerHelperClass.createERAsOnERInsert(records);
        DMN_Event.synchWithEvenReports(records);
        SHR_CallReport.manageSharing(records, id2OldRecords);
    }

    /**
     * @description Trigger handler for Before Update
     */    
    public override void handleBeforeUpdate(){
        handleEventReportChange(records, oldRecords);
        DMN_CallReport.syncDivsionInfo(records, id2OldRecords);
    }

    /**
     * @description Trigger handler for After update 
     */    
    public override void handleAfterUpdate() {
         afterUpdate(records, new Map<Id, Call_Report__c>(oldRecords));
    }

    /**
     * @description Trigger handler for After delete 
     */
    public override void handleAfterDelete(){
        deleteRelatedEvents();
    }

    /**
     * @description handler for event report change 
     * @param callReports
     * @param oldCallReports
     */
    private void handleEventReportChange(Call_Report__c[] callReports, Call_Report__c[] oldCallReports){

        
        if( SA_EventTriggerHelperClass.hasAlreadyCreatedEvent()){
            return; 
        } 

        Map<Id,Call_Report__c> id2OldCllReport =  oldCallReports == null ? 
                        new Map<Id,Call_Report__c>() : new Map<Id,Call_Report__c>(oldCallReports);
        SA_EventTriggerHelperClass.handleEventOnERInsertOrUpdate(callReports, id2OldCllReport);
        
        if(SA_EventTriggerHelperClass.reportErrorInERUpdate){ sendErrorNotification(SA_EventTriggerHelperClass.errorMsgInErUpdate); }    
    }

    private void deleteRelatedEvents(){

        SA_EventTriggerHelperClass.setAlreadyCreatedEventReport();
        Database.DeleteResult[] deleteResults = DMN_Event.deleteEvents(oldRecords);

        String[] errors = new String[]{};

        for(Database.DeleteResult dr : deleteResults){ 
            if(dr.isSuccess()){
                continue;
            }
            for(Database.Error err : dr.getErrors()){
                errors.add(err.getMessage());
            }
        }

        if(!errors.isEmpty()){  sendErrorNotification(String.join(errors, ' \n ') ); }
    }

    @TestVisible
    private void sendErrorNotification(String errorMsg){
        Environment_Variable__c settings = Environment_Variable__c.getInstance();
        String SupportEmailAddress = settings.CRM_Production_Support__c;
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {SupportEmailAddress};
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Apex Error in : ' + UserInfo.getOrganizationName());
        mail.setSubject('Apex Error related to Event Report Update'); 
        mail.setPlainTextBody('Error in Trigger: SA_EventReportUpdate\n' + errorMsg );
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    private void afterUpdate(Call_Report__c[] callReports, Map<Id, Call_Report__c> Id2oldCr){

        Map<Id,String> mapTopicsNew = new Map<Id,String>();
        Map<Id,String> mapTopicsOld = new Map<Id,String>();
        Set<Id> setAttendeeId = new Set<Id>();
        Set<Id> changedClientIds = new set<Id>();
        Id[] ClientChangeSatisfiedERs = new Id[]{};
        Call_Report__c[] lstNewCR = new Call_Report__c[]{};
        Call_Report__c[] lstOldCR = new Call_Report__c[]{};

        for(Call_Report__c er: callReports){    
            if((er.Topics__c != Id2oldCr.get(er.Id).Topics__c)){
                mapTopicsOld.put(er.id, Id2oldCr.get(er.Id).Topics__c);
                mapTopicsNew.put(er.Id ,er.Topics__c );
            }
                
            if(er.CurrencyIsoCode != Id2oldCr.get(er.Id).CurrencyIsoCode){ setAttendeeId.add(er.id);  }
                
            if(er.Relate_to_Client__c != Id2oldCr.get(er.Id).Relate_to_Client__c 
                && er.Relate_to_Client__c != null){
                changedClientIds.add(er.Relate_to_Client__c);
                ClientChangeSatisfiedERs .add(er.id);
            }
                
            if(er.Relate_to_Client__c != Id2oldCr.get(er.id).Relate_to_Client__c ){
                lstNewCR.add(er);
                lstOldCR.add(Id2oldCr.get(er.Id));
            } 
        } 

        if(!changedClientIds.isEmpty()){ SA_EventTriggerHelperClass.updateERAsOnClientChange(changedClientIds,ClientChangeSatisfiedERs); }

        if(mapTopicsNew.Values().Size() > 0 && mapTopicsOld.Values().Size() >0){SA_EventTriggerHelperClass.syncTopicRecords(mapTopicsOld, mapTopicsNew);}

        DMN_CallReport.updateChairpersonOnNBACs(records, id2OldRecords);
        SHR_CallReport.manageSharing(records, id2OldRecords);
    }
}