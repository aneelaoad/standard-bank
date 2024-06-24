/*************************************************************************\
    @ Test Class        :    EventReportAttendee_test
    @ Last Modified By  :   Anand Nancharla
    @ Last Modified On  :   17th Aug 2011
    @ Modified Reason   :   Code comments whereever Domain_UserName__c is no longer used.
                            Case C-00000178
                            
    @ Last Modified By  : Caro Reinecke
    @ Last Modified On  : 06/01/2012
    @ Modification Description : Case#548 Regression Remove redundant fields
    
    @ Last Modified By  : Caro Reinecke
    @ Last Modified On  : 31/05/2012
    @ Modification Description : Case#4296 When the event report owner changes, salesforce removes the manual shares. 
                                Added method refreshEventReportAttendeeShares 
                                This method will recreate the maual shares for attendees with an attended status.
                                Removed test methods as these were already covered in the test class
                                
    @Last Modified By   : Vaishali Singh
    @ Last Modified On  : 31/03/2015
    @ Modification Description : Modified to default the distribution value set to 'yes' for the event report attendee added as an owner.
                                 Removed the attended clause from method refreshEventReportAttendeeShares so irrespective of status the sharing is created.
                                 Removed the @future method for EN -0658 which was delaying the addition of event report attendee

    @ Last Modified By  : Marko Dvečko
    @ Last Modified On  : 03/04/2017
    @ Modification Description : Current owner is not added to manual sharing and class is without sharing so that it can be used by previous owner.

****************************************************************************/

global without sharing class SA_EventReportAttendeeFutureUpdate {

    private class AddEventAttendees implements Queueable {

        private List<ID> contactId;
        private List<ID> eventReportId;

        public AddEventAttendees(List<ID> contactId, List<ID> eventReportId){
            this.contactId = contactId;
            this.eventReportId = eventReportId;
        }

        public void execute(QueueableContext context) {
            System.debug('### contact IDs ' + contactId);
            System.debug('### event report IDs ' + eventReportId);

            Call_Report_Attendees__c repAtt;
            Call_Report_Attendees__c[] repAttendeesInsert = new Call_Report_Attendees__c[]{};
            Map<ID,Contact> mapContactId = new Map<ID,Contact>([Select id, RecordType.DeveloperName from Contact where id in:contactId]);

            for (Integer x = 0; x < contactId.size(); x++) {
                repAtt = new Call_Report_Attendees__c();

                repAtt.Call_Report__c = eventReportId[x];
                repAtt.Contact_id__c = contactId[x];
                if (mapContactId.containsKey(contactId[x])) {
                    if (mapContactId.get(contactId[x]).RecordType.DeveloperName == 'SA_Bank_Contact_Record_Type') {
                        repAtt.Send_Email__c = 'Yes';
                    }
                    else {
                        repAtt.Send_Email__c = 'No';
                    }
                }
                repAttendeesInsert.add(repAtt);
            }

            try {
                Database.insert(repAttendeesInsert, false);
            }
            catch(System.DMLException ex) {
                System.debug('Error adding event report attendess ' + ex);
            }
        }
    }
    

    public static void addEventReportAttendees(List<ID> contactId, List<ID> eventReportId) {
        addEventAttendees addJob = new addEventAttendees(contactId, eventReportId);
        System.enqueueJob(addJob);
    }
    
    @future
    public static void refreshEventReportAttendeeShares(List<ID> eventReportIds) {
        
        List<Call_Report__Share> sharesToRefresh = new List<Call_Report__Share>();
        Call_Report__Share shareToRefresh;
        for (Call_Report_Attendees__c existingAttendee : [select id,Call_Report__c,Call_Report__r.OwnerId, Contact_id__c,Contact_id__r.OwnerId from Call_Report_Attendees__c where Call_Report__c in :eventReportIds and Contact_Type__c = 'Internal']){
            if (existingAttendee.Contact_id__r.OwnerId != existingAttendee.Call_Report__r.OwnerId) {
                shareToRefresh = new Call_Report__Share();
                shareToRefresh.UserOrGroupId = existingAttendee.Contact_id__r.OwnerId;
                shareToRefresh.ParentId = existingAttendee.Call_Report__c;
                shareToRefresh.RowCause = 'Manual';
                shareToRefresh.AccessLevel = 'Edit';
                sharesToRefresh.add(shareToRefresh);
            }
        }
                
        try {
            system.debug ('sharesToRefresh' + sharesToRefresh);
            insert sharesToRefresh;
        } 
        catch(System.DMLException ex) {
            system.debug ('sharesToRefreshError' + ex);
            System.debug('Error refreshing event report attendee share records ' + ex);
        }
    }

}