/*************************************************************************
    @ Author:       Abhishek V
    @ Date:         31 August 2016
    @ Test File:    NewOppLookupsSupportTest.cls
    @ Description:  US-1425: Provide search facilities for look-ups
    
    @ Author:       Abhishek V
    @ Date:         29 September 2016
    @ Test File:    NewOppLookupsSupportTest.cls
    @ Description:  US-1543: Provide search facilities for look-ups on Users
    
    @ Author:       Abhishek V
    @ Date:         04 October 2016
    @ Test File:    NewOppLookupsSupportTest.cls
    @ Description:  US-1553: Provide search facilities for look-ups on Contacts

    @author:        Dzianisik Maksim
    @date:          April 2023
    @description:   SFP-9010 Deleted constructor for "OpportunityCloseRedirect_SF1_Ext controller" as part of decommissioning story
*************************************************************************/
/**
* @description retrieves data based on search-string criteria
*
*/
global without sharing class NewOppLookupsSupport {

    public NewOppLookupsSupport(ApexPages.StandardController controller) {
    // empty
    }
    
    public NewOppLookupsSupport(Opprtunity_New_LDS_ctrl controller) {
    // empty
    }
    
    public NewOppLookupsSupport(oppTeamCreationController controller) {
    // empty
    }
    
    public NewOppLookupsSupport(AddInternalAttendeesCtrl controller) {
    // empty
    }
    
    public NewOppLookupsSupport(AddExternalAttendeesController controller) {
    // empty
    }

    
    public NewOppLookupsSupport(LDS_TaskCtrl controller) {
    // empty
    }

    /*
     *  @description Method to retrieve ACCOUNT records based on search string value
     * 
     *  @param keyword
     * 
     *  @return foundAccounts
     */
    @RemoteAction
    global static List<Account> queryAccounts(String keyword) {
        List<Account> foundAccounts = new List<Account>();
        
        if (String.isEmpty(keyword)) {
            return foundAccounts;
        }
        
        String escapedKeyword = '%' + String.escapeSingleQuotes(keyword) + '%';
        
        foundAccounts = [SELECT id, Name 
                        FROM Account
                       WHERE name LIKE :escapedKeyword LIMIT 5];
        
        return foundAccounts ;
    }
    
    /*
     *  @description Method to retrieve Opportunity records based on search string value
     * 
     *  @param keyword
     * 
     *  @return foundOpps
     */
    @RemoteAction
    global static List<Opportunity> queryOpps(String keyword) {
        List<Opportunity> foundOpps = new List<Opportunity>();
        
        if (String.isEmpty(keyword)) {
            return foundOpps;
        }
        
        String escapedKeyword = '%' + String.escapeSingleQuotes(keyword) + '%';
        
        foundOpps = [SELECT id, Name 
                        FROM Opportunity
                       WHERE name LIKE :escapedKeyword LIMIT 5];
        
        return foundOpps ;
    }
    
    /*
     *  @description Method to retrieve User records based on search string value
     * 
     *  @param keyword
     * 
     *  @return foundusers
     */
    @RemoteAction
    global static List<User> queryUsers(String keyword) {
        List<User> foundusers = new List<User>();
        
        if (String.isEmpty(keyword)) {
            return foundusers;
        }
        
        String escapedKeyword = '%' + String.escapeSingleQuotes(keyword) + '%';
        
        foundusers = [SELECT id, Name 
                      FROM User
                      WHERE name LIKE :escapedKeyword 
                      AND isActive = TRUE LIMIT 5];
        
        return foundusers;
    }
    
    /*
     *  @description: Method to retrieve CONTACT records based on search string value and SA Bank Contact record type
     * 
     *  @param keyword
     * 
     *  @return foundcons
     */
    @RemoteAction
    global static List<Contact> queryintcontact(String keyword) {
        List<Contact> foundcons = new List<Contact>();
        
        if (String.isEmpty(keyword)) {
            return foundcons;
        }
        
        String escapedKeyword = '%' + String.escapeSingleQuotes(keyword) + '%';
        
        foundcons =  [SELECT id, Name, firstName, lastName 
                           FROM Contact 
                          WHERE inactive__c = FALSE
                            AND recordType.developerName = 'SA_Bank_Contact_Record_Type'
                            AND name LIKE :escapedKeyword LIMIT 5];
        
        return foundcons;
    }
    
    /*
     * @description: Method to retrieve CONTACT records based on search string value and SA Client Contact record type
     * 
     *  @param keyword
     * 
     *  @return foundcons
     */
    @RemoteAction
    global static List<Contact> queryextcontact(String keyword) {
        List<Contact> foundcons = new List<Contact>();
        
        if (String.isEmpty(keyword)) {
            return foundcons;
        }
        
        String escapedKeyword = '%' + String.escapeSingleQuotes(keyword) + '%';
        
        foundcons =  [SELECT id, Name, firstName, lastName 
                           FROM Contact 
                          WHERE inactive__c = FALSE
                            AND recordType.developerName = 'SA_Client_Contact_Record_Type'
                            AND name LIKE :escapedKeyword LIMIT 5];
        
        return foundcons;
    }
    
    /*
     *  @description Method to retrieve Campaign records based on search string value
     * 
     *  @param keyword
     * 
     *  @return foundcamps
     */
    @RemoteAction
    global static List<Campaign> querycamp(String keyword) {
        List<Campaign> foundcamps = new List<Campaign>();
        
        if (String.isEmpty(keyword)) {
            return foundcamps;
        }
        
        String escapedKeyword = '%' + String.escapeSingleQuotes(keyword) + '%';
        
        foundcamps =  [SELECT id, Name
                           FROM Campaign 
                          WHERE IsActive = true and name LIKE :escapedKeyword LIMIT 5];
        
        return foundcamps;
    }
}