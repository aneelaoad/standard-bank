public class StdBank_Ltn_EventReportCP {
    public class EmailAttributes {
        @AuraEnabled
        public String templateId;
        @AuraEnabled
        public String objectId;
        @AuraEnabled
        public String to;
        @AuraEnabled
        public String cc;
        @AuraEnabled
        public String bcc;

        public EmailAttributes(
                String templateId, 
                String objectId,
                String to,
                String cc,
                String bcc) {
            this.templateId = templateId;
            this.objectId = objectId;
            this.to = to;
            this.cc = cc;
            this.bcc = bcc;
        }
    }

    @AuraEnabled
    public static Call_Report__c getRecord(Id recordId) {
        return [SELECT Id, EventId__c, Relate_to_Client__c, Owner.Name, RecordType.Name FROM Call_Report__c WHERE Id = :recordId];
    }

    @AuraEnabled
    public static EmailAttributes getEmailAttributes(Id recordId, Id clientId, Boolean withTeamMembers) {
        String emailCarbonCopy = '';
        String emailRecepients = '';

        Id templateId;
        List<EmailTemplate> templateIds = [SELECT Id, Name FROM EmailTemplate WHERE Name LIKE 'EventReport'];

        if (!templateIds.isEmpty()) {
            templateId = templateIds.get(0).Id;
        } else {
            templateId = '00X200000013kCZ';
        }

        List<User> teamMembers = [SELECT u.Id, u.Email FROM User u WHERE u.Id IN (SELECT a.UserId FROM AccountTeamMember a WHERE a.Account.Id = :clientId)];
        List<Call_Report_Attendees__c> attendees = [SELECT Id, Email__c, Contact_Type__c, Status__c FROM Call_report_Attendees__c WHERE  Contact_Type__c = 'Internal' AND Send_Email__c = 'Yes' AND ((Status__c = 'Attended') OR (Status__c = 'Invited') OR (Status__c = 'Distribute Only')) AND Call_report__c = :recordId];

        if (withTeamMembers) {
            for (User item : teamMembers) {
                emailCarbonCopy += item.Email + ';';
            }
        }

        for (Call_Report_Attendees__c item : attendees) {
            emailRecepients += item.Email__c + ';';
        }

        return new EmailAttributes(templateId, recordId, emailRecepients, emailCarbonCopy, '');
    }

    @AuraEnabled
    public static Boolean buttonsEnabled(Id recordId) {
        List<Call_Report__Share> sharedRecords = [
                SELECT ParentId, UserOrGroupId, AccessLevel
                FROM Call_Report__Share
                WHERE ParentId = :recordId
                AND UserOrGroupId = :UserInfo.getUserId()
                AND (AccessLevel = 'All' OR AccessLevel = 'Edit')
        ];

        if (!sharedRecords.isEmpty()) return true;

        Call_Report__c eventReport = [SELECT Id, Relate_to_Client__c FROM Call_Report__c WHERE Id = :recordId];

        List<Id> userIds = new List<Id>(
            getListOfIds(
                [SELECT Team_Member__c FROM Custom_Client_Team__c WHERE Account__c = :eventReport.Relate_to_Client__c],
                'Team_Member__c'
            )
        );

        List<Id> setConId = new List<Id>(
            getListOfIds(
                [SELECT Contact_id__c FROM Call_Report_Attendees__c WHERE Call_Report__c = :recordId],
                'Contact_id__c'
            )
        );

        userIds.addAll(
            getListOfIds(
                [SELECT Id FROM User WHERE Contact_Sync_ID__c IN :setConId],
                'Id'
            )
        );

        if (new Set<Id>(userIds).contains(UserInfo.getUserId())) return true;

        Profile userProfile = [SELECT PermissionsModifyAllData FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];

        if (userProfile.PermissionsModifyAllData) return true;

        if (!userIds.isEmpty()) {
            return RoleUtility.isManagerOfUsers(userIds, UserInfo.getUserId());
        } else {
            return false;
        }
    }

    @AuraEnabled
    public static Boolean hasClientTeam(Id recordId) {
        AggregateResult[] ar = [SELECT COUNT(Id) FROM Custom_Client_Team__c WHERE Account__c = :recordId];
        if ((Integer)ar[0].get('expr0') > 0) {
            return true;
        }
        else {
            return false;
        }

    }

    private static List<Id> getListOfIds(List<sObject> records, String fieldName) {
        List<Id> result = new List<Id>();

        for (sObject item : records) {
            result.add((Id) item.get(fieldName));
        }

        return result;
    }
}