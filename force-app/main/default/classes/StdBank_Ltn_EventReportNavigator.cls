public class StdBank_Ltn_EventReportNavigator {
    @AuraEnabled
    public static Boolean showConsole(Id recordId) {
        try {
            Call_Report__c report = [SELECT Id, RecordType.Name FROM Call_Report__c WHERE Id = :recordId];

            return (report.RecordType.Name != '' && report.RecordType.Name == 'NBAC Meeting') ? true : false;
        } catch (QueryException ex) {
            return false;
        }
    }

    @AuraEnabled
    public static Boolean showExternalAttendees(Id recordId){
        try {
            List<Call_Report__c> report = [SELECT Attendee_Reminder_Required__c, Meeting_Purpose__c, OwnerId FROM Call_Report__c WHERE Id = :recordId AND Meeting_Purpose__c = 'Client Entertainment'
            AND (Attendee_Reminder_Required__c = 'NEED_REMINDER' OR Attendee_Reminder_Required__c = 'HAS_REMINDER_NEED') AND Total_Event_Costs__c = null];

            if(report.isEmpty()){
                return false;
            }

            WRP_User wrpUser = new WRP_User(UTL_User.getCachedUser(report[0].OwnerId));
            if(wrpUser.isCommB()) {
                return false;
            }

            return true;
        } catch (QueryException ex) {
            return false;
        }
    }
    
    @AuraEnabled
    public static Boolean corecheck(Id recordId){
        Map<String, CSTTeamRoleRanking__c> coreTeamRoles = CSTTeamRoleRanking__c.getAll();
        Integer coreAttendeesCnt = 0; 
        boolean corebool;
        List<Call_Report__c> ers = [SELECT id, enforce_core_attendee_validation__c,(Select Id, Contact_Id__c,Contact_Id__r.Name, Contact_Id__r.RecordType.DeveloperName, Client_Team_Role__c FROM Call_Report_Attendeess__r where Contact_Id__r.RecordType.DeveloperName = 'SA_Bank_Contact_Record_Type') FROM Call_Report__c WHERE id = :recordId];
        if(ers.size() > 0){
            if (ers[0] != null && ers[0].enforce_core_attendee_validation__c == true && ButtonAccess.checkInternalAttendeeButton(UserInfo.getUserId(), ers[0].id)) {
                for(Call_Report_Attendees__c cra: ers[0].Call_Report_Attendeess__r){
                     if (coreTeamRoles.keySet().contains(cra.Client_Team_Role__c)) {
                         coreAttendeesCnt++;
                     }
                }
                
                if(coreAttendeesCnt < 2){
                    corebool = true;
                }else{
                    corebool = false;
                }
                
            } else if (ers[0] != null) {
                corebool = false;
            }
        }else{
            corebool = false;
        }
        return corebool;
    }
}