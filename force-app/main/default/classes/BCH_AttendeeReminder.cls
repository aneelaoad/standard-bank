public with sharing class BCH_AttendeeReminder implements Database.Batchable<SObject>, Schedulable{
    private static String HAS_REMINDER_NEED		= 'HAS_REMINDER_NEED';
    private static String HAS_REMINDER_NO_NEED	= 'HAS_REMINDER_NO_NEED';
    private static String NO_NEED			    = 'NO_NEED';
    private static String NEED_REMINDER		    = 'NEED_REMINDER';


    public void execute(Database.BatchableContext param1, List<Call_Report_Attendees__c> attendees) {
        Set<Id> reportIds = new Set<Id>();
        for(Call_Report_Attendees__c cra: attendees) {
            reportIds.add(cra.Call_Report__c);
        }
        List<Call_Report__c> events = [SELECT Attendee_Reminder_Required__c, OwnerId FROM Call_Report__c WHERE Id IN: reportIds AND Total_Event_Costs__c = NULL];
        for(Call_Report__c cr: events){
            WRP_User wrpUser = new WRP_User(UTL_User.getCachedUser(cr.OwnerId));
            if(!wrpUser.isCommB()){
                cr.Attendee_Reminder_Required__c = changeReminderStatus(cr);
            }
        }
        update events;
    }

    public void finish(Database.BatchableContext param1) {
    }

    public Iterable<SObject> start(Database.BatchableContext param1) {
        return Database.query('SELECT Id, Costs_Per_Attendee__c, Call_Report__c FROM Call_Report_Attendees__c ' +
                'WHERE Call_Report__r.Date__c < TODAY AND  Call_Report__r.Meeting_Format__c = \'Entertainment\' AND Call_Report__r.Total_Event_Costs__c = NULL AND Status__c = \'Attended\' ' +
                'AND (Call_Report__r.Attendee_Reminder_Required__c = \'NO_NEED\' OR Call_Report__r.Attendee_Reminder_Required__c = null OR Call_Report__r.Attendee_Reminder_Required__c = \'HAS_REMINDER_NO_NEED\')');
    }

    public void execute(SchedulableContext param1) {
        BCH_AttendeeReminder batchJob = new BCH_AttendeeReminder();
        Database.executeBatch(batchJob);
    }

    private String changeReminderStatus(Call_Report__c event){
        return event.Attendee_Reminder_Required__c == NO_NEED ? NEED_REMINDER : event.Attendee_Reminder_Required__c == null ?
                NO_NEED : event.Attendee_Reminder_Required__c == HAS_REMINDER_NO_NEED ? HAS_REMINDER_NEED : NEED_REMINDER;
    }
}