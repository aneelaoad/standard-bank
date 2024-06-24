/**
 * Created by tsobota on 06.12.2018.
 */

public without sharing class SRV_CallReportSharing extends ABS_SharingService {
    public SRV_CallReportSharing() {
        teamType = Call_Report_Attendees__c.SObjectType;
        sObj2Type = new Map<SobjectType, Type>{
                Call_Report__c.SObjectType => SHR_CallReport.class
        };
    }

    protected override Map<Id, SObject[]> fetchTeam(Set<Id> parentIds) {
        Map<Id, List<SObject>> usersOrObjectShare2EventReportIds = new Map<Id, List<SObject>>();
        for (Call_Report_Attendees__c callReportAttendee : [
                SELECT Contact_id__r.OwnerId, Call_Report__c, Contact_Type__c
                FROM Call_Report_Attendees__c
                WHERE Call_Report__c IN :parentIds
        ]) {
            if (!usersOrObjectShare2EventReportIds.containsKey(callReportAttendee.Call_Report__c)) {
                usersOrObjectShare2EventReportIds.put(callReportAttendee.Call_Report__c, new List<SObject>());
            }
            usersOrObjectShare2EventReportIds.get(callReportAttendee.Call_Report__c).add(callReportAttendee);
        }

        return usersOrObjectShare2EventReportIds;
    }
}