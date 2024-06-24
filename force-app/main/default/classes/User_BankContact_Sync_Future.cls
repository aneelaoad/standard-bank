/*************************************************************************
    @ Author        : Shaveen Bageloo
    @ Date          : 06 December 2010
    @ Test File     : Test_User_BankContact_SyncTrigger
    @description   : This is a @future class that will update/create the CONTACT record.
                      Reason for @future class was that there is a DML Error thrown when
                      update/creating the CONTACT record (non-setup object) from the
                      USER object (setup object)
    @ Last Modified By  : Rudolf Niehaus
    @ Last Modified On  : 10 December 2010
    @ Modification Description : Completing Coding.
    
    @ Last Modified By  :   Balabramham Yadamakanti
    @ Last Modified On  :   17th Aug 2011
    @ Modified Reason   :   Code comments, formatting, code modification to replace SAM Account Name with SID/Email as Unique field.
                            Case C-00000178
                            
    @ Last Modified By  :   Rambabu Tummagunta
    @ Last Modified On  :   07 October 2011
    @ Modified Reason   :   [C-00001844] Added code to delete Non-User Client Team records when inactive user becomes acitve user.     

     @ Last Modified By  :   Anand Nancharla
    @ Last Modified On  :   08 November 2011
    @ Modified Reason   :   [C-00003160] Added additional two fields: Employee Number & Cost Center to update from User to Contact.               
    
    @ Last Modified By  : Wayne Gray
    @ Last Modified On  : June 2012
    @ Last Modified Reason  :  Case #6521- Change contact to use TestFatcory    
                               API Version moved from 22 to 25 
                               
    @ Last Modified By  : Tracy Roberts
    @ Last Modified On  : 28 August 2012
    @ Last Modified Reason  :  Case #7820- Change Email Opt Out to be unticked on a Bank Contact when a User 
                               are created and Sync with a Bank Contact.
                               
    @ Last Modified By  : Jorel Naidoo
    @ Last Modified On  : 27 November 2012
    @ Last Modified Reason  :  Case #8165- Added User Franco Field to Contact Sync
    
    @ Last Modified By  : Nitish Kumar
    @ Last Modified On  : March 2013
    @ Modification Description : EN-31- Change contact to use TestDataUtility   
                                 API Version moved from 25 to 27    
                                 
                                
    @ Last Modified By  :   Tracy de Bruin
    @ Last Modified On  :   27 August 2014
    @ Modified Reason   :   Add a User_Country_Sync__c field that will populate for Bank Contacts.
                            Get value from User Country field on User Object 
                               
****************************************************************************/
public without sharing class User_BankContact_Sync_Future {

    /**
     * @description Future method to update contacts based on User data
     * @param lUserIds
     **/
    @Future
    public static void main(List<Id> lUserIds){
        Environment_Variable__c env = Environment_Variable__c.getInstance();
        String bankContactRecordTypeID = env.Bank_Contact_Record_Id__c;
        String bankContactAccountID = env.Bank_Contact_Account_Id__c;
        CreateContacts(lUserIds, bankContactRecordTypeID, bankContactAccountID);
     }


    /**
    * @description Method to update contacts based on User data
    * @param lcContactIds
    * @param bankContactRecordTypeID
    * @param bankContactAccountID
    **/
    public static void createContacts(List<Id> lcContactIds, String bankContactRecordTypeID, String bankContactAccountID) {
        List<User> userList = new List<User>(
                    [Select 
                    Id,
                    Department,
                    Email,
                    Fax,
                    FirstName, 
                    LastName,
                    Street,
                    State,
                    PostalCode,
                    Country,
                    City,
                    MobilePhone,
                    Phone,
                    Title,
                    Birth_Day_Month__c,
                    Business_Unit__c,
                    User_CIB_Global_Area__c,
                    User_Division__c,
                    User_Team__c,
                    User_Franco__c,
                    User_Country__c,
                    LanguageLocaleKey,
                    isActive,
                    Contact_Sync_ID__c,
                    ReceivesInfoEmails,
                    EmployeeNumber,
                    SA_Cost_Centre__c,
                    Outlook_Exchange_System_ID__c,
                    Non_SBG_User__c
                    From User Where Id IN : lcContactIds]);
        Contact[] newContacts = new Contact[]{};
        Set<String>unicIDnames = new Set<String>();
        Set<Id> activeUserIds = new Set<Id>();
        
        For (Integer x=0;x<userList.size();x++) {
        

            //populate set with domain acc names
            
            if(userList[x]. Outlook_Exchange_System_ID__c!=null && userList[x]. Outlook_Exchange_System_ID__c!=''){
                unicIDnames.add(userList[x].Outlook_Exchange_System_ID__c);
            }
            //geting list of active user id for Non-User client team
            if(userList[x].IsActive == true){
                    activeUserIds.add(userList[x].Contact_Sync_ID__c);
                 }
            Contact tempContact= buildDefaultContact();
            tempContact.Department = userList[x].Department;
            tempContact.Email = userList[x].Email;
            tempContact.Fax = userList[x].Fax;
            tempContact.FirstName = userList[x].FirstName;
            tempContact.LastName = userList[x].LastName;
            tempContact.MailingStreet = userList[x].Street;
            tempContact.MailingState = userList[x].State;
            tempContact.MailingPostalCode = userList[x].PostalCode;
            tempContact.MailingCountry = userList[x].Country;
            tempContact.MailingCity = userList[x].City;
            tempContact.MobilePhone = userList[x].MobilePhone;
            tempContact.Phone = userList[x].Phone;
            tempContact.Title = userList[x].Title;
            tempContact.Birth_Day_Month__c = userList[x].Birth_Day_Month__c;
            tempContact.User_Division_Sync__c = userList[x].User_Division__c;
            tempContact.User_Team_Sync__c = userList[x].User_Team__c;
            tempContact.User_Franco_Sync__c = userList[x].User_Franco__c;
            tempContact.User_CIB_Global_Area_Sync__c = userList[x].User_CIB_Global_Area__c;
            tempContact.User_Business_Unit_Sync__c = userList[x].Business_Unit__c;
            tempContact.User_Country_Sync__c = userList[x].User_Country__c;
            tempContact.RecordTypeId =BankContactRecordTypeID;
            tempContact.Outlook_Exchange_System_ID__c = userList[x].Outlook_Exchange_System_ID__c;
            tempContact.AccountId =BankContactAccountID;
            tempContact.OwnerId = userList[x].Id;
            tempContact.HasOptedOutOfEmail = false;
            tempContact.Active_User__c=userList[x].isActive;
            tempContact.Employee_Number__c=userList[x].EmployeeNumber;
            tempContact.Cost_Centre__c=userList[x].SA_Cost_Centre__c;
            tempContact.Non_SBG_Contact__c=userList[x].Non_SBG_User__c;
            newContacts.add(tempContact);
        }
        
        //Code to delete non user client teams when user made active.
        try{
            if(activeUserIds!=null && activeUserIds.size()>0){
                
                 List<Non_User_Client_Team__c> nonUsercontactList = new List<Non_User_Client_Team__c>();
                 
                 nonUsercontactList =[select id ,Contact_Name__c from Non_User_Client_Team__c where  Contact_Name__c IN :activeUserIds ]; 
                
                delete nonUsercontactList;
            }
        }catch(exception excep){
            SRV_Logger.newInstance().log(excep, DMN_Log.TYPE_ERROR, User_BankContact_Sync_Future.class.getName());
        }
        
        //Write the CONTACT list to Database
        try {
            User_BankContact_Sync_HelperClass.setAlreadySyncUser();
            
            upsert newContacts Outlook_Exchange_System_ID__c;
            
            List<Contact> conList = new List<Contact>();
            conList = [Select Id,Outlook_Exchange_System_ID__c From Contact Where Outlook_Exchange_System_ID__c IN : unicIDnames];
           
            Map<String,Id> conMap = new Map<String,Id>();
            //build map between domain name and contact id
            for(Integer r=0;r<conList.size();r++){
                conMap.put((conList[r].Outlook_Exchange_System_ID__c),conList[r].Id);
            }
            //loop through new trigger body and contact sync id with the related contact id
            for(Integer i=0;i<userList.size();i++){
                userList[i].Contact_Sync_ID__c = conMap.get((userList[i].Outlook_Exchange_System_ID__c)); 
                   
                }
            
            try{
                User_BankContact_Sync_HelperClass.setAlreadySyncContact();
                update userList;
            }catch(Exception ex){
                SRV_Logger.newInstance().log(ex, DMN_Log.TYPE_ERROR, User_BankContact_Sync_Future.class.getName());
            }

        }catch (exception e){
            SRV_Logger.newInstance().log(e, DMN_Log.TYPE_ERROR, User_BankContact_Sync_Future.class.getName());
        }
    }

    /**
    * Method moved from TestDataUtilityClass while refactoring test factories.
    * It has to be discussed with business which fields should be chosen
    *
    * @return Base contact record
    */
    private static Contact buildDefaultContact(){

        Contact newContact = new Contact();
        Date birthDate = Date.newInstance(1990, 2, 17);
        newContact.AssistantName = 'Asssis First1 Last Name1';
        newContact.AssistantPhone = '1111111111';
        newContact.Birthdate = birthDate;
        newContact.Description = 'Description Test';
        newContact.DoNotCall = true;
        newContact.Fax = '1231231231';
        newContact.HasOptedOutOfFax = true;
        newContact.HomePhone = '1478963214';
        newContact.OtherPhone = '5411452511';
        newContact.Allergies__c = 'Allergies Test';
        newContact.Assistant_Email__c = 'assistant@email.co.za';
        newContact.Birth_Day_Month__c = '01/01';
        newContact.Contact_Category__c = 'Staff';
        return newContact;
    }

}