/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 05-31-2022
 * @last modified by  : TCK
**/
public with sharing class TRH_EAP_Attendance extends ABS_TriggerHandlerBase{
    private EAP_Attendance__c[] records {
        get { return (EAP_Attendance__c[])Trigger.new; }
    }

    private Map<Id, EAP_Attendance__c> id2OldRecords{
        get{
            if(Trigger.old == null){
                return null;
            }
            return new Map<Id, EAP_Attendance__c>((EAP_Attendance__c[])Trigger.old);
        }
    }

    private Map<Id, EAP_Attendance__c> id2NewRecords {
        get {
            if (Trigger.newMap == null) {
                return null;
            }
            return (Map<Id, EAP_Attendance__c>) Trigger.newMap;
        }
    }

    public override void handleAfterInsert() {
        DMN_EAP_Attendance.lockSlotsForMeeting(id2NewRecords,id2OldRecords);
        DMN_EAP_Attendance.addToMeetingGroup(id2NewRecords,id2OldRecords);
    }

    public override void handleBeforeDelete() {
        DMN_EAP_Attendance.deleteAsMember(id2NewRecords,id2OldRecords);
    }
}