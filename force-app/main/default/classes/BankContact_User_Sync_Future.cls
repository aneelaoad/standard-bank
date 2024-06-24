/*****************************************************************************************************\
    @ Func Area     : Bank contacts, Contacts, Users
    @ Author        : Rudolf Niehaus
    @ Date          : 12/2010
    @ Test File     : Have a look at the trigger ContactAfterUpdateInsert 
    @ Description   : This class sync's the new / update bank contact with the related User record
    
    @ Last Modified By  : Rudolf Niehaus
    @ Last Modified On  : 18/02/2011
    @ Modification Description :     
    
  
    Disable syncing of the following User fields:
    
    - Country
    - City 
    - Business_Unit__c 
    - User_Division__c
    - User_CIB_Global_Area__c
    - User_Team__c
    - FirstName
    - LastName
    
    Business wants the User object to be the source for Reporting purposes.
    They would like users only to be able to edit the User object which will in 
    turn sync changes across to the Contact object. Users must not be able to edit
    any of the above fields on the Contact object and NO syncing of these fields
    must take place from Contact object to the User object
    
    Contact Fields removed:
    
    - User_Team_Sync__c
    - User_Division_Sync__c
    - User_CIB_Global_Area_Sync__c
    - User_Business_Unit_Sync__c
    - MailingCountry 
    - MailingCity
    - FirstName
    - LastName
    
    @ Last Modified By  :   Balabramham Yadamakanti
    @ Last Modified On  :   17th Aug 2011
    @ Modified Reason   :   Code comments, formatting, code modification to replace SAM Account Name with SID/Email as Unique field.
                            Case C-00000178  
        
    @ Last Modified By  :   Rambabu Tummagunta
    @ Last Modified On  :   12th Sept 2011
    @ Modified Reason   :   Code to delete non user client teams when bank conatct made inactive or active user.
                            Case C-00001844
    
    @ Last Modified By  :   Anand Nancharla
    @ Last Modified On  :   21th Oct 2011
    @ Modified Reason   :   Modified the code to not to update Address field from Contact to User Object
                            Case C-00000530  as part of PROD fix. 
                            
    @ Last Modified By  :   Stephen Moore
    @ Last Modified On  :   25/04/2012
    @ Modification Description : remove preferred_language__c and replace it with sa_preferred_language__c
                             C-00003926 Delete Preferred Language 
                                                                                                                                               
    @ Last Modified By  :   Wayne Gray
    @ Last Modified On  :   April 2012
    @ Modified Reason   :   Added in a check to see user editing Bank Contact belongs to the correct profile, profile ID's 
                            are stored in the Admin_Profile_IDs__c environmental variable.
                            Case C-0000497   
                            
    @ Last Modified By  :   Tracy Roberts
    @ Last Modified On  :   24 October 2012
    @ Modified Reason   :   Add a check to the Update of Users to exclude Users with a blank SID (Which means Inactive Users), 
                            becausethat means that the Bank Contact does not have a corresponding User. Case#6547                                                                                                                                                                                            
******************************************************************************************************/

global class BankContact_User_Sync_Future {
@future

    public static void futureUpdateUsers(List<Id> conId){
        boolean IsUnicSID = false; 
        Set<String> contactIds = new Set<String>();
        Set<Id> inactiveContactIds = new Set<Id>();
        Map<String,Contact> conMap = new Map<String,Contact>();
        List<Contact> conList = new List<Contact>([Select Department,
                                                    Email,
                                                    Fax,
                                                    MailingStreet,
                                                    MailingState,
                                                    MailingPostalCode, 
                                                    MobilePhone, 
                                                    Phone, 
                                                    Title,
                                                    Active_User__c,
                                                    Birth_Day_Month__c,
                                                    sa_Preferred_Language__c, 
                                                    Inactive__c,
                                                    HasOptedOutOfEmail,
                                                    Id ,
                                                    Outlook_Exchange_System_ID__c                                                
                                                    From Contact Where Id IN : conId]);
                                                    
        system.debug('#### contact user list '+conList);                                  
    
        for(Integer c=0;c<conList.size();c++){
            
                 contactIds.add(conList[c].Outlook_Exchange_System_ID__c);
                 conMap.put(conList[c].Outlook_Exchange_System_ID__c,conList[c]);
                 
                 if(conList[c].Inactive__c == true || conList[c].Active_User__c == true){
                    inactiveContactIds.add(conList[c].Id);
                 }
        }  
         
        //Code to delete non user client teams when bank conatct made inactive or active user.
         
        if(inactiveContactIds!=null && inactiveContactIds.size()>0){
            
             List<Non_User_Client_Team__c> nonUsercontactList = new List<Non_User_Client_Team__c>();
             
             nonUsercontactList =[select id ,Contact_Name__c from Non_User_Client_Team__c where  Contact_Name__c IN :inactiveContactIds ]; 
            
            delete nonUsercontactList;
        }
         
          
         
         
        system.debug('#### ContactIds '+contactIds);
        system.debug('#### ContactIds size '+contactIds.size());
        system.debug('#### ContactIds conMap '+conMap);
         
        List<User> userList = new List<User>();
        
       userList = [Select u.Id,u.Department,u.Email,u.Fax,u.Street,u.State,u.PostalCode,u.MobilePhone,u.Phone,u.Title,u.Birth_Day_Month__c,u.LanguageLocaleKey,u.isActive,u.Contact_Sync_ID__c,u.ReceivesInfoEmails,u.Outlook_Exchange_System_ID__c from User u Where u.Outlook_Exchange_System_ID__c  IN : contactIds And u.Outlook_Exchange_System_ID__c != null];
         
                                                                                     
                 
        system.debug('#### userList user list '+userList);  
        system.debug('#### userList user list size : '+userList.size());  
            
        String strUniqueValue='';
                                                
        for(Integer x=0;x<userList.size();x++){
                
            strUniqueValue=userList[x].Outlook_Exchange_System_ID__c;
                
                        
            System.debug('#### Reding Rec ' + x);
            System.debug('#### Check if Domain Name as key exists in Contact MAP'+strUniqueValue);
                
                            
            if(conMap.containsKey(strUniqueValue)){
                System.debug('#### Key exists SET user list values for Index ' + x);

                userList[x].Department = conMap.get(strUniqueValue).Department; 
                userList[x].Fax = conMap.get(strUniqueValue).Fax;
                userList[x].MobilePhone = conMap.get(strUniqueValue).MobilePhone; 
                userList[x].Phone = conMap.get(strUniqueValue).Phone; 
                userList[x].Title = conMap.get(strUniqueValue).Title;
                userList[x].Birth_Day_Month__c = conMap.get(strUniqueValue).Birth_Day_Month__c;
                userList[x].Contact_Sync_ID__c = conMap.get(strUniqueValue).Id;
                userList[x].ReceivesInfoEmails = (!conMap.get(strUniqueValue).HasOptedOutOfEmail);
                userList[x].Outlook_Exchange_System_ID__c = conMap.get(strUniqueValue).Outlook_Exchange_System_ID__c;
            }
                
        }
            
        try{
            System.debug('#### Attempt User UPDATE now...'+userList);
            //set var
            User_BankContact_Sync_HelperClass.setAlreadySyncContact();
            Environment_Variable__c env = Environment_Variable__c.getInstance();
            String AdminProfileIds = env.Admin_Profile_IDs__c;
            String  UserProfileId = Userinfo.getProfileId();
            
            System.debug('#### AdminProfileIds: ' + AdminProfileIds);
            System.debug('#### UserProfileId: ' + UserProfileId);
            //Check to see if Sync back to User should occur
            //These must be 18-digit ID's     
            if((AdminProfileIds!=null)&&(UserProfileId!=null))
            {
                if(AdminProfileIds.contains(UserProfileId)){
                    Database.SaveResult[] MySaveResult = database.update(userList ,false);
                    System.debug('#### DONE'+MySaveResult);               
                 }
             }
            System.debug('#### DONE');
            
        }catch(DMLException ex){
            System.debug('#### There was an Error when Syncronizing the Contact records with the related User record');
        }   
    
    }

    public  static boolean bReverseBoolean(Boolean bValueIn) {
        if (bValueIn) {return False;} else {return True;}
    }    


}