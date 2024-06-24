/**
 * @author          Maksim Dzianisik
 * @date            Dec. 2022
 * @description     SFP-19087 Controller class for the callReportAttendeeModal LWC
 */
public with sharing class CallReportAttendeeModalController {

    /**
     * @param idEventReport String
     * @param isInternal Boolean
     * @description the method returns data to show in the component
     * @return DataWrapper
     */
    @AuraEnabled
    public static DataWrapper getAttendeeData(String idEventReport, Boolean isInternal) {
        idEventReport = String.escapeSingleQuotes(idEventReport);
        DataWrapper response = new DataWrapper();
        response.statusValues = getStatusValues();

        List<AttendeeWrapper> attendeeList = new List<AttendeeWrapper>();
        Set<Id> attendeesIds = new Set<Id>();
        Call_Report__c eventReport = getEventReport(idEventReport);
        User eventOwner;
        Map<String, CSTTeamRoleRanking__c> coreTeamRoles;
        Integer coreAttendees = 0;
        String contactRt;

        if (isInternal) {
            eventOwner = [SELECT Id, Contact_Sync_ID__c FROM User WHERE Id = :eventReport.OwnerId];
            coreTeamRoles = CSTTeamRoleRanking__c.getAll();
            contactRt = DMN_Contact.RTD_BANK;
        } else {
            contactRt = DMN_Contact.RTD_CLIENT;
        }

        for (Call_Report_Attendees__c attendee : getAttendees(idEventReport, contactRt)) {
            
            attendeesIds.add(attendee.Contact_id__c);
            Boolean isOwner;
            if (isInternal) {
                isOwner = attendee.Contact_id__c == eventOwner.Contact_Sync_ID__c;
                if (coreTeamRoles.containsKey(attendee.Client_Team_Role__c)) {
                     
                    coreAttendees++;
                }
            } else {
                isOwner = eventReport.Report_Client_Contact__c == attendee.Contact_id__c;
            }
            attendeeList.add(new AttendeeWrapper(true, isOwner, isInternal, attendee));
        }

        if (isInternal) {
            response.isCoreClientMeeting = eventReport.Enforce_Core_Attendee_Validation__c && coreAttendees < 2;
            Map<Id, String> contactId2memberRole = new Map<Id, String>();
            for (AccountTeamMember teamMember : [
                    SELECT Id, User.Contact_Sync_ID__c, TeamMemberRole
                    FROM AccountTeamMember
                    WHERE AccountId = :eventReport.Relate_to_Client__c AND User.IsActive = TRUE AND User.Contact_Sync_ID__c NOT IN :attendeesIds
            ]) {
                contactId2memberRole.put(teamMember.User.Contact_Sync_ID__c, teamMember.TeamMemberRole);
            }
            for (Contact tempContact : [
                    SELECT Id, Name, Account.Name
                    FROM Contact
                    WHERE Id IN :contactId2memberRole.keySet()
                    ORDER BY Name
            ]) {
                attendeeList.add(new AttendeeWrapper(isInternal, contactId2memberRole.get(tempContact.Id), tempContact));
            }
            
            response.attendeeWrappers = attendeeList;


        } else {
            List<Contact> potentialAttendees = [
                    SELECT Id, Name, Title, Account.Name
                    FROM Contact
                    WHERE AccountId = :eventReport.Relate_to_Client__c AND RecordType.DeveloperName = :DMN_Contact.RTD_CLIENT AND Inactive__c = FALSE AND Id NOT IN :attendeesIds
                    ORDER BY SystemModstamp DESC
                    LIMIT 100
            ];

            for (Contact tempContact : potentialAttendees) {
                attendeeList.add(new AttendeeWrapper(isInternal, '', tempContact));
                
            }
        }
        response.attendeeWrappers = attendeeList;
       
        return response;
    }

    /**
     * @param searchValue String
     * @param isInternal Boolean
     * @description prepare and return suggestions according to the user input
     * @return Map<String, List<String>> - key = Contact Id, value = Contact name and Account Name
     */
    @AuraEnabled
    public static Map<String, List<String>> getContactSuggestions(String searchValue, Boolean isInternal) {
        searchValue = '%' + String.escapeSingleQuotes(searchValue) + '%';
        Map<String, List<String>> result = new Map<String, List<String>>();
        if (isInternal) {
            List<Contact> contacts = [
                    SELECT Id, Name
                    FROM Contact
                    WHERE Active_User__c = TRUE AND RecordType.DeveloperName = :DMN_Contact.RTD_BANK AND Name LIKE :searchValue
                    ORDER BY Name ASC
                    LIMIT 10
            ];
            for (Contact tempContact : contacts) {
                result.put(tempContact.Id, new List<String>{tempContact.Name, ''});
            }
        } else {
            List<Contact> contacts = [
                    SELECT Id, Name, Account.Name
                    FROM Contact
                    WHERE Inactive__c = FALSE AND RecordType.DeveloperName != :DMN_Contact.RTD_BANK AND Name LIKE :searchValue
                    ORDER BY Name ASC
                    LIMIT 10
            ];
            for (Contact tempContact : contacts) {
                result.put(tempContact.Id, new List<String>{tempContact.Name, tempContact.Account.Name});
            }
        }
        return result;
    }

    /**
     * @param recordId String
     * @param updatedData String
     * @param isInternal Boolean
     * @description convert wrapper to the records and save changes
     * @return String
     */
    @AuraEnabled
    public static String saveAttendees(String recordId, String updatedData, Boolean isInternal) {
       
        String response = 'Something wrong! Please review the Attendees list!';
        recordId = String.escapeSingleQuotes(recordId);
        Map<Id, Call_Report_Attendees__c> contId2ReportAttendees = new Map<Id, Call_Report_Attendees__c>();
        Map<String, CSTTeamRoleRanking__c> coreTeamRoles = CSTTeamRoleRanking__c.getAll();
        Integer coreAttendees = 0;

        for (Call_Report_Attendees__c tempRecord : [
                SELECT Id, Call_Report__c, Client_Team_Role__c, Send_Email__c, Status__c, Contact_id__c, CompositeKey__c,Distance__c
                FROM Call_Report_Attendees__c
                WHERE Call_Report__c = :recordId
        ]) {
            contId2ReportAttendees.put(tempRecord.Contact_id__c, tempRecord);
        }
        List<AttendeeWrapper> updatedAttendees = (List<AttendeeWrapper>) JSON.deserialize(updatedData, List<AttendeeWrapper>.class);

        Map<Id, Call_Report_Attendees__c> contId2AttendForUpsert = new Map<Id, Call_Report_Attendees__c>();
        Map<Id, Call_Report_Attendees__c> contId2AttendForDelete = new Map<Id, Call_Report_Attendees__c>();
        for (AttendeeWrapper tempRecord : updatedAttendees) {
            if (tempRecord.addRemove) {
                if (contId2ReportAttendees.containsKey(tempRecord.contactId)) {
                    Call_Report_Attendees__c tempAttendees = contId2ReportAttendees.get(tempRecord.contactId);

                    if (tempAttendees.Status__c != tempRecord.status || tempAttendees.Distance__c != tempRecord.distance ) {
                        tempAttendees.Status__c = tempRecord.status;
                        tempAttendees.Distance__c = tempRecord.distance;
                        contId2AttendForUpsert.put(tempRecord.contactId, tempAttendees);
                    }

                    if (isInternal && coreTeamRoles.containsKey(tempRecord.roleName)) {
                        coreAttendees++;
                    }

                } else {
                    String sendEmail = isInternal ? 'Yes' : 'No';
                    Call_Report_Attendees__c tempAttendee = new Call_Report_Attendees__c();
                    tempAttendee.Send_Email__c = sendEmail;
                    tempAttendee.Contact_id__c = tempRecord.contactId;
                    tempAttendee.Call_Report__c = recordId;
                    tempAttendee.Status__c = tempRecord.status;
                    tempAttendee.Distance__c = tempRecord.distance;
                    tempAttendee.Client_Team_Role__c = tempRecord.roleName;
                    tempAttendee.CompositeKey__c = String.valueOf(tempRecord.contactId).left(15) + String.valueOf(recordId).left(15);
                    contId2AttendForUpsert.put(tempRecord.contactId, tempAttendee);

                    if (isInternal && coreTeamRoles.containsKey(tempRecord.roleName)) {
                        coreAttendees++;
                    }
                }
            } else {
                if (contId2ReportAttendees.containsKey(tempRecord.contactId) && !tempRecord.isOwner) {
                    contId2AttendForDelete.put(tempRecord.contactId, contId2ReportAttendees.get(tempRecord.contactId));
                }
            }

        }

        if (contId2AttendForUpsert.size() > 0 || contId2AttendForDelete.size() > 0) {
            try {
                if (contId2AttendForUpsert.size() > 0) {
                    List<Call_Report_Attendees__c> forUpsert = contId2AttendForUpsert.values();
                    upsert forUpsert CompositeKey__c;
                }
                if (contId2AttendForDelete.size() > 0) {
                    List<Call_Report_Attendees__c> forDelete = contId2AttendForDelete.values();
                    delete forDelete;
                }
                if (!isInternal) {
                    response = updateCallReport(recordId, contId2AttendForUpsert.keySet(), contId2AttendForDelete.keySet());
                } else if (coreAttendees < 2) {
                    response = 'Internal core warning';
                } else {
                    response = 'SUCCESS';
                }
            } catch (DmlException ex) {
                response = 'An Error occurred: ' + ex.getMessage();
            }
        } else {
            response = 'SUCCESS';
        }

        return response;
    }

    /**
     * @description the method update call report
     * @param recordId
     * @param contactIdsForUpsert
     * @param contactIdsForDelete
     * @return DataWrapper
     */
    private static String updateCallReport(String recordId, Set<Id> contactIdsForUpsert, Set<Id> contactIdsForDelete) {
        String response = 'Something wrong! I could not update the Event Report';
        Boolean hasChanged = false;

        Call_Report__c callReport = getEventReport(recordId);
        Boolean isCSuiete = isCSuiteReport(contactIdsForUpsert, contactIdsForDelete);
        if (isCSuiete != null && isCSuiete != callReport.C_Suite_Attendance__c) {
            callReport.C_Suite_Attendance__c = isCSuiete;
            hasChanged = true;
        }

        if (callReport.Attendee_Reminder_Required__c == 'NEED_REMINDER' || callReport.Attendee_Reminder_Required__c == 'HAS_REMINDER_NEED') {
            callReport.Attendee_Reminder_Required__c = 'HAS_REMINDER_NO_NEED';
            hasChanged = true;
        }

        if (hasChanged) {
            try {
                update callReport;
                response = 'SUCCESS';
            } catch (DmlException ex) {
                response = 'An Error occurred: ' + ex.getMessage();
            }
        }else {
            response = 'SUCCESS';
        }
        return response;
    }
    
        /**
     * @description the method for isCSuiteReport
     * @param contactIdsForUpsert
     * @param contactIdsForDelete
     * @return Boolean
     */
    private static Boolean isCSuiteReport(Set<Id> contactIdsForUpsert, Set<Id> contactIdsForDelete) {
        Boolean result = null;

        Map<Id, Contact> id2Contact = new Map<Id, Contact>([
                SELECT Id, Contact_Category__c
                FROM Contact
                WHERE Id IN: contactIdsForUpsert OR Id IN: contactIdsForDelete
        ]);

        for (Id contactId : contactIdsForUpsert) {
            Contact tempContact = id2Contact.get(contactId);
            if (tempContact.Contact_Category__c != null && DMN_Contact.CONTACT_CATEGORIES.contains(tempContact.Contact_Category__c)) {
                return true;
            }
        }

        for (Id contactId : contactIdsForDelete) {
            Contact tempContact = id2Contact.get(contactId);
            if (tempContact.Contact_Category__c != null && DMN_Contact.CONTACT_CATEGORIES.contains(tempContact.Contact_Category__c)) {
                return false;
            }
        }

        return result;
    }
    
     /**
     * @description the method for getStatusValues
     * @return List<String>
     */
    private static List<String> getStatusValues() {
        List<String> options = new List<String>();
        List<Schema.PicklistEntry> fieldResult = Call_Report_Attendees__c.Status__c.getDescribe().getPicklistValues();
        for (Schema.PicklistEntry entry : fieldResult) {
            options.add(entry.getValue() + '%%%' + entry.getLabel());
        }
        return options;
    }
     /**
     * @description the method for getEventReport
     * @param eventReportId
     * @return List<String>
     */
    private static Call_Report__c getEventReport(Id eventReportId) {
        return [
                SELECT OwnerId, Relate_to_Client__c, Enforce_Core_Attendee_Validation__c, Report_Client_Contact__c, Attendee_Reminder_Required__c, C_Suite_Attendance__c
                FROM Call_Report__c
                WHERE Id = :eventReportId
        ];
    }
	 /**
     * @description the method for getEventReport
     * @param eventReportId
     * @param contactRt
     * @return List<Call_Report_Attendees__c>
     */
    private static List<Call_Report_Attendees__c> getAttendees(Id eventReportId, String contactRt) {
        return [
                SELECT Id, Contact_id__c, Contact_id__r.Name, Contact_id__r.Title, Contact_id__r.Account.Name, Status__c, Client_Team_Role__c, CompositeKey__c,Distance__c
                FROM Call_Report_Attendees__c
                WHERE Call_Report__c = :eventReportId AND Contact_id__r.RecordType.DeveloperName = :contactRt
                ORDER BY Contact_id__r.Name
        ];
    }
    
   /**
    * @description Checks if User Profile is Commercial Banking
    * @return Boolean result of Profile check
    **/
    @AuraEnabled
    public static Boolean isBCBUser(){     
        return DMN_Profile.isCommBUser() ||
            DMN_Profile.isBusinessUser() ||
            DMN_Profile.isEnterpriseUser();           
    }

    /**
    * @description data transformation object 
    */
    public class DataWrapper {
    	/**
    	* @description get attendeeWrappers
	    */
        @AuraEnabled
        public List<AttendeeWrapper> attendeeWrappers { get; set; }
       /**
    	* @description get isCoreClientMeeting
	    */
        @AuraEnabled
        public Boolean isCoreClientMeeting { get; set; }
       /**
    	* @description get statusValues
	    */
        @AuraEnabled
        public List<String> statusValues { get; set; }
    }

    /**
    * @description data transformation object
    **/
    public class AttendeeWrapper {
        /**
    	* @description to add addRemove
    	**/
        @AuraEnabled
        public Boolean addRemove { get; set; }
       /**
    	* @description get isOwner
    	**/
        @AuraEnabled
        public Boolean isOwner { get; set; }
       /**
    	* @description get contactName
    	**/
        @AuraEnabled
        public String contactName { get; set; }
        /**
    	* @description get roleName
    	**/
        @AuraEnabled
        public String roleName { get; set; }
       /**
    	* @description get contactTitle
    	**/
        @AuraEnabled
        public String contactTitle { get; set; }
       /**
    	* @description get status
    	**/
        @AuraEnabled
        public String status { get; set; }
       /**
    	* @description get accountName
    	**/
        @AuraEnabled
        public String accountName { get; set; }
       /**
    	* @description get contactId
    	**/
        @AuraEnabled
        public Id contactId { get; set; }
       /**
    	* @description get distance
    	**/
        @AuraEnabled
        public Double distance { get; set; }
       /**
    	* @description get disabledDistance
    	**/
        @AuraEnabled 
        public Boolean disabledDistance { get; set; }

        /**
        * @description constructor
        * @param addRemove 
        * @param isOwner 
        * @param isInternal 
        * @param attendee 
        **/
        public AttendeeWrapper(Boolean addRemove, Boolean isOwner, Boolean isInternal, Call_Report_Attendees__c attendee) {
            this.addRemove = addRemove;
            this.isOwner = isOwner;
            this.contactName = attendee.Contact_id__r.Name;
            this.roleName = isInternal ? attendee.Client_Team_Role__c : '';
            this.contactTitle = isInternal ? '' : attendee.Contact_id__r.Title;
            this.status = isBCBUser() ? attendee.Status__c : DMN_CallReportAttendee.STATUS_ATTENDED;
            this.accountName = attendee.Contact_id__r.Account.Name;
            this.contactId = attendee.Contact_id__c;
            this.distance = attendee.Status__c == 'Attended' ? attendee.Distance__c : null;
            this.disabledDistance = attendee.Status__c == 'Attended' ? false : true;
        }

        /**
        * @description constructor
        * @param isInternal 
        * @param roleName 
        * @param tempContact 
        **/
        public AttendeeWrapper(Boolean isInternal, String roleName, Contact tempContact) {
            this.addRemove = false;
            this.isOwner = false;
            this.contactName = tempContact.Name;

            if (isInternal) {
                this.roleName = String.isNotBlank(roleName) ? roleName : '';
                this.contactTitle = '';
            } else {
                this.roleName = '';
                this.contactTitle = String.isNotBlank(tempContact.Title) ? tempContact.Title : '';
            }

            this.status = DMN_CallReportAttendee.STATUS_ATTENDED;
            this.accountName = tempContact.Account.Name;
            this.contactId = tempContact.Id;
        }

    }
}