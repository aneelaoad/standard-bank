/*************************************************************************
    @ Author:       Petr Svestka
    @ Date:         18 Julu 2016
    @ Test File:    MeetingConsoleLookupsSupportTest.cls
    @ Description:  US-1247: Provide search facilities for look-ups
*************************************************************************/
global without sharing class MeetingConsoleLookupsSupport {

    public MeetingConsoleLookupsSupport(ApexPages.StandardController controller) {
		// empty
    }
    
    public MeetingConsoleLookupsSupport(MeetingConsole_TasksController controller) {
		// empty
    }
    
    public MeetingConsoleLookupsSupport(CommitteeAttendee_ctrl controller) {
		// empty
    }
    
    public MeetingConsoleLookupsSupport(SubmissionAttendee_ctrl controller) {
		// empty
    }

    @RemoteAction
    global static List<User> queryUsers(String keyword) {
        List<User> foundUsers = new List<User>();
        
        if (String.isEmpty(keyword)) {
            return foundUsers;
        }
        
        String escapedKeyword = '%' + String.escapeSingleQuotes(keyword) + '%';
        
        foundUsers = [SELECT id, firstName, lastName 
                      	FROM User 
                       WHERE isActive = TRUE 
                         AND name LIKE :escapedKeyword LIMIT 5];
        
        return foundUsers;
    }
    
    @RemoteAction
    global static List<Contact> queryContacts(String keyword) {
        List<Contact> foundContacts = new List<Contact>();
        
        if (String.isEmpty(keyword)) {
            return foundContacts;
        }
        
        String escapedKeyword = '%' + String.escapeSingleQuotes(keyword) + '%';
        
        foundContacts = [SELECT id, firstName, lastName 
                      	   FROM Contact 
                          WHERE inactive__c = FALSE
                            AND recordType.developerName = 'SA_Bank_Contact_Record_Type'
                            AND name LIKE :escapedKeyword LIMIT 5];
        
        return foundContacts;
    }
}