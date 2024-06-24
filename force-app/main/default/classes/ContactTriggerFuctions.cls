/*****************************************************************************************************\
    @ Func Area     : Contacts
    @ Author        : Rudolf Niehaus
    @ Date          : 15/05/2011
    @ Test File     : Test Method TestContactTrigger.cls
    @ Description   : General Contact functions class invoked by the Contact trigger
    -------------------------------------------------------------------------------------
    @ Func Area         : Campaign, Campaign Members, Campaign Member Hosts, Contacts
    @ Last Modified By  : Rudolf Niehaus
    @ Last Modified On  : 15/05/2012 
    @ Modification Description : Case#6246
                                Add the methods: 
                                - mergeCampaignMembers()
                                The method will merge campaign members in the custom Campiagn_Members_Host__c 
                                object when Contacts are merge using standard sf functionality.  
                                
                                The Below two methods are cleanup methods implemented to keep the data
                                between campaigns, members and hosts consistant and have clean objects all the time:
                                - deleteOrphanHosts()
                                The method deletes all orphan host records i.e. host records not linked to a member or
                                a bank contact
                                - deleteOrphanMembers()
                                The method deletes all orphan member records i.e. member records not linked to a campaign
                                or a Contact
                                - syncJunctionObject()
                                This method sync the standard member object with the junction object if there is an ID miss match. The reason for this is
                                that the contact merge issue made the data in these two objects inconsistent. so this method fixes previous data issue
---------------------------------------------------------------------------------------------------------------------------
   @ Func Area     : Contacts, Contact Team Members
   @ Last Modified By  : Jorel Naidoo
   @ Last Modified On  : 26/02/2013
   @ Modification Description : EN#0099.
                                Added Method to update Contact Team Members when a Contact is Merged.
---------------------------------------------------------------------------------------------------------------------------   
   @ Func Area     :Contacts, Accounts
   @ Last Modified By  : Vishnu Vundavalli
   @ Last Modified On  :  25/03/2015
   @ Modification Description : EN-661 : To update the ERABatchUpdatedRequired field on account on contact category change on Contact
---------------------------------------------------------------------------------------------------------------------------   

@ Last Modified By  :   Manoj Gupta        
@ Last Modified On  :   Oct 2015
@ Last Modified Reason  : Added Salesforce to Salesforce sharing method   (Including Jorel Naidu changes from ServCloud org)   

@ Last Modified By  :   Manoj Gupta        
@ Last Modified On  :   Jan 2016
@ Last Modified Reason  : EN:1015 Added Connectionstatus = 'Accepted' in connection record SOQL query.This is to refer Active connection only 

***********************************************************************************************/

public class ContactTriggerFuctions {
    
    //Class declarations
    private List<Contact> oldList = new List<Contact>();
    private Set<Id> mergedWinnerIds = new Set<Id>();
    private Set<Id> mergeLoserIds = new Set<Id>();
    private Set<Id> delContactSet = new Set<Id>();
    private Map<String,Contact> contactMap = new Map<String,Contact>();
    private Set<Id> fullnames = new Set<Id>();
    public static Boolean isAutomatedUpdate = false;

    //Class constructor. Takes as parameters the trigger OLD Maps
    public ContactTriggerFuctions(List<Contact> oldList){
        this.oldList = oldList;
        //Loop through the old trigger list containing contact records that was deleted, populate collection
        //methods seperating merge contacts from normal deleted records 
        for(Contact c : oldList){
            //if the field MasterRecordId is not populated it means that the contact was deleted from a normal delete
            //process. If not null it was deleted as a result from a contact merger and the value in the field would be
            //the record Id of the winning contact record after a merger.
            if(c.MasterRecordId == null){
                //add ids of contacts that was only deleted and not merged
                delContactSet.add(c.Id);
            }else{
                if(c.MasterRecordId != c.Id){
                mergeLoserIds.add(c.Id);
                }
                //add only the winning ids
                mergedWinnerIds.add(c.MasterRecordId);
                //add all email addresses of winner contacts so we can sync std member object with the member junction object
                contactMap.put(c.Name,c);
                fullnames.add(c.Name);
            }
        }
    }
    //The method will merge campaign members in the custom Campaign_Members_Host__c 
    //object when Contacts are merge using standard sf functionality.  
    public void mergeCampaignMembers(){
        
        if(mergedWinnerIds.size() > 0){
            
            Id campId = null;
            Id holdId = null;
            Integer x = 1;
            
            List<Campaign_Member_Host__c> memberDelList = new List<Campaign_Member_Host__c>();
            List<Campaign_Member_Host__c> campaignMemberList = new List<Campaign_Member_Host__c>();
            List<Campaign_Hosts__c> hostDelList = new List<Campaign_Hosts__c>();
            List<Campaign_Hosts__c> hostUpdateList = new List<Campaign_Hosts__c>();
            
            Set<Id> campMemIds = new Set<Id>();
            Id winningHost = null;
            Set<Id> losingHosts = new Set<Id>();
            Set<Id> notDuplicateHost = new Set<Id>();
            
            //get all member ids so that we can populate a host Lst containing all the hosts for all the members that won the merge
            Set<Id> allMemIds = new Set<Id>();
            for(Campaign_Member_Host__c m : [SELECT c.Id, c.Member__c, c.Campaign__c FROM Campaign_Member_Host__c c WHERE c.Member__c IN : mergedWinnerIds]){
                allMemIds.add(m.Id);
            }
            //Get all the hosts and populate a Map between member Id and Host object
            List<Campaign_Hosts__c> hostList = [SELECT Id, Host_Id__c, Campaign_Member_Host__c, Bank_Contact__c FROM Campaign_Hosts__c WHERE Campaign_Member_Host__c IN : allMemIds];
            
        
            for(Campaign_Member_Host__c m : [SELECT c.Id, c.Member__c, c.Campaign__c, c.LastModifiedDate FROM Campaign_Member_Host__c c WHERE c.Member__c IN : mergedWinnerIds ORDER BY c.Campaign__c, c.LastModifiedDate DESC]){
            
                campId = m.Campaign__c;
                if((campId == holdId) || (holdId == null)){
                    //add member ids, make a bucket of member ids per campaign
                    campMemIds.add(m.Member__c);
                    //make bucket list of members per campaign
                    campaignMemberList.add(m);

                }else{
                    
                    if(campaignMemberList.size() > 1){
                        
                        for(Campaign_Member_Host__c cm : campaignMemberList){
                                //do not delete the first member only the rest
                                if(x>1){
                                    memberDelList.add(cm);
                                    losingHosts.add(cm.Id);
                                }else{
                                    winningHost = cm.Id;
                                }
                                x++;    
                        }
                    }
                    
                    if(hostList.size() > 0){
                        //get all the winning member hosts contact ids
                        for(Campaign_Hosts__c h : hostList){
                            if(h.Campaign_Member_Host__c == winningHost){
                                notDuplicateHost.add(h.Bank_Contact__c);
                            }
                        }
                        //now update all losing hosts and make sure we do not add duplicates
                        for(Campaign_Hosts__c h : hostList){
                            
                            if(losingHosts.contains(h.Campaign_Member_Host__c)){
                                if(notDuplicateHost.add(h.Bank_Contact__c)){
                                    h.Campaign_Member_Host__c = winningHost;
                                    hostUpdateList.add(h);
                                }else{
                                    hostDelList.add(h);
                                }
                            }
                        }
                    }
                    
                    //reset buckets
                    x=1;
                    campMemIds.clear();
                    campaignMemberList.clear();
                    losingHosts.clear();
                    winningHost = null;
                    notDuplicateHost.clear();
                    
                    //update this current record
                    //add member ids, make a bucket of member ids per campaign
                    campMemIds.add(m.Member__c);
                    //make bucket list of members per campaign
                    campaignMemberList.add(m);
                }   
                
                holdId = m.Campaign__c;
                
            }
            
            //Process last member list for the last campaign
            //------------------------------------------------------------------------
            
            if(campaignMemberList.size() > 1){
                        
                for(Campaign_Member_Host__c cm : campaignMemberList){
                        //do not delete the first member only the rest
                        if(x>1){
                            memberDelList.add(cm);
                            
                            losingHosts.add(cm.Id);
                        }else{
                            
                            winningHost = cm.Id;
                        }
                        x++;    
                }
            }
            
            if(hostList.size() > 0){
                
                //get all the winning member hosts contact ids
                for(Campaign_Hosts__c h : hostList){
                    if(h.Campaign_Member_Host__c == winningHost){
                        
                        notDuplicateHost.add(h.Bank_Contact__c);
                    }
                }
                //now update all losing hosts and make sure we do not add duplicates
                for(Campaign_Hosts__c h : hostList){
                    
                    if(losingHosts.contains(h.Campaign_Member_Host__c)){
                        
                        if(notDuplicateHost.add(h.Bank_Contact__c)){
                            h.Campaign_Member_Host__c = winningHost;
                            hostUpdateList.add(h);
                        }else{
                            
                            hostDelList.add(h);
                        }
                    }
                }
            }
            //------------------------------------------------------------------------------
            
            //Update and delete members and hosts
            try{
                
                if(hostUpdateList.size() > 0){update hostUpdateList;}
                if(hostDelList.size() > 0){delete hostDelList;}
                if(memberDelList.size() > 0){delete memberDelList;}
            
            }catch(System.DMLException e){
                System.debug('Campaign Member DELETE or UPDATE failed ' + e.getMessage());
            }
        }
    }

    //this method sync the standard member object with the junction object if there is an ID miss match. The reason for this is
    //that the contact merge issue made the data in these two objects inconsistent. so this method fixes previous data issue
    public void syncJunctionObject(){
        
        Map<String,CampaignMember> memberMap = new Map<String,CampaignMember>();
        Integer q = 0;
        String mapKey = '';
        if(mergedWinnerIds.isEmpty()){
            return;
        }
            
        for(CampaignMember cm : [   SELECT Id, ContactId,Campaign_Wave__c,Status,HasResponded, CampaignId,Attendance_Status__c,Contact_Record_Type__c,Date_Responded__c
                                    FROM CampaignMember
                                    WHERE ContactId IN : mergedWinnerIds
                                    ORDER BY CampaignId ASC]){
                //fullname.add(cm.Contact.Name);
            mapKey = cm.ContactId + '' + cm.CampaignId;
            memberMap.put(mapKey,cm);
            q++;
        }
        
        List<Campaign_Member_Host__c> mem = [ SELECT Responded__c,Date_Responded__c,Contact_Record_Type__c,Attendance_Status__c,Campaign_Wave__c,Member__r.Name, Campaign__c, Member__c, Member_Id__c
                                                FROM Campaign_Member_Host__c
                                                WHERE Member__c IN : mergedWinnerIds
                                                ORDER BY Campaign__c ASC];

        String key = '';

        for(Integer x=0;x<mem.size();x++){
            
            key = mem[x].Member__c + '' + mem[x].Campaign__c;
            

            if(memberMap.containsKey(key)){
                if(mem[x].Member_Id__c != memberMap.get(key).Id){
                    //update the member host record with the ID of the campaignmember record and all other related info that needs to be in sync.
                    mem[x].Member_Id__c = memberMap.get(key).Id;
                    mem[x].Campaign_Wave__c = memberMap.get(key).Campaign_Wave__c;
                    mem[x].Member_Status__c = memberMap.get(key).Status;
                    mem[x].Attendance_Status__c = memberMap.get(key).Attendance_Status__c;
                    mem[x].Contact_Record_Type__c = memberMap.get(key).Contact_Record_Type__c;
                    mem[x].Date_Responded__c = memberMap.get(key).Date_Responded__c;
                    mem[x].Responded__c = memberMap.get(key).HasResponded;
                }
            }
        }
        
        System.debug('Do Complete update');
        try{
            update mem;
        }catch(DMLException ex){
            
        }
    }
    
    //Case#7064 - This method determines which Event Report Attendees must be deleted.
     public void mergeEventReportAttendees(){
        
        //Create 2 temp ID holders
        Id eventReportID = null;
        Id tempEventReportID = null;

        if(mergedWinnerIds.isEmpty()){
            return;
        }
        
        //Create a List of Event Report Attendees that must be Deleted
        List<Call_Report_Attendees__c> eventReportAttDeleteList = new List<Call_Report_Attendees__c>();
        
        //Loop through all the Event Report Attendees, sort(desc) List by Event Report and then Last Modified Date
        for (Call_Report_Attendees__c eventReportAttendees : [SELECT c.LastModifiedDate, c.Id, c.Contact_id__c, c.CompositeKey__c, c.Call_Report__c FROM Call_Report_Attendees__c c WHERE Contact_id__c IN : mergedWinnerIds ORDER BY c.Call_Report__c,c.LastModifiedDate DESC])
        {
            //The Last Modified Event Report Attendee's Event Report ID
            eventReportID = eventReportAttendees.Call_Report__c;
            
            //If the current Event Report ID is not the Last Modified Event Report ID, then add the Event Report Attenddee Record to the list
            if(eventReportID == tempEventReportID)
            {
                //Add the Event Report Attendee to the List
                eventReportAttDeleteList.add(eventReportAttendees);
            }
            //If the current Event Report ID is the Last Modified Event Report ID
            else
            {
                //Store the last Modified Event Report ID
                tempEventReportID = eventReportAttendees.Call_Report__c;
            }
        }
        
        try
        {
            //Delete all the Event Report Attendees that was not the Last Modified on.
            delete eventReportAttDeleteList;
        }
        catch(System.DMLException e)
        {
            System.debug('Event Report Attendee Delete Failed ' + e.getMessage());
        }
     }
     
     //Delete duplicate Non-User Client Teams
     public void mergeNonUserClientTeam(){

        if(mergedWinnerIds.isEmpty()){
            return;
        }
        
        //Create 2 temp ID holders
        Id clientID = null;
        Id tempClientID = null;
        
        //Create a List of Non-User Client Teams that must be Deleted
        List<Non_User_Client_Team__c> NonUserClientTeamDeleteList = new List<Non_User_Client_Team__c>();
        
        //Loop through all the Non-User Client Teams, sort(desc) List by Client and then Last Modified Date
        for (Non_User_Client_Team__c NonUserClientTeam : [SELECT n.LastModifiedDate, n.Id, n.Contact_Name__c, n.Client_Name__c FROM Non_User_Client_Team__c n WHERE Contact_Name__c IN : mergedWinnerIds ORDER BY n.Client_Name__c, n.LastModifiedDate DESC])
        {
            //The Last Modified Non-User Client Teams Client ID
            clientID = NonUserClientTeam.Client_Name__c;
            
            //If the current Client ID is not the Last Modified Client ID, then add the Non-User Client Teams Record to the list
            if(clientID == tempClientID)
            {
                //Add the Non-User Client Team to the List
                NonUserClientTeamDeleteList.add(NonUserClientTeam);
            }
            //If the current Client ID is the Last Modified Client ID
            else
            {
                //Store the last Modified Client ID
                tempClientID = NonUserClientTeam.Client_Name__c;
            }
        }
        
        try
        {
            //Delete all the Non-User Client Team that was not the Last Modified one.
            delete NonUserClientTeamDeleteList;
        }
        catch(System.DMLException e)
        {
            System.debug('Non-User Client Team Delete Failed ' + e.getMessage());
        }
     }
     
    //EN-0099 This method determines which Contact Team Members must be deleted.
     public void mergeContactTeamMembers(){  
       isAutomatedUpdate = true;
        //Create 2 temp ID holders
        Id UserID = null;
        Set <Id> tempUserID = new Set<Id>();

        if(mergedWinnerIds.isEmpty()){
            return;
        }
        
        //Get The Owner for the Winning Record
        List<Contact> winnerOwner = [SELECT OwnerId FROM Contact WHERE Id IN : mergedWinnerIds LIMIT 1];
        //Create a List of Contact Team Members that must be Deleted
        List<SA_Contact_Team_Member__c> contactTMDeleteList = new List<SA_Contact_Team_Member__c>();
        //Create a List of Contact Team Members that must be Updated
        List<SA_Contact_Team_Member__c> contactTMUpdateList = new List<SA_Contact_Team_Member__c>();
        
        //Loop through all the Contact Team Members
        for (SA_Contact_Team_Member__c contactTeamMembers : [   SELECT c.LastModifiedDate, c.Id, c.SA_Contact__c, c.CompositeKey__c, c.SA_User__c, c.Primary_Contact_Person__c
                                                                FROM SA_Contact_Team_Member__c c
                                                                WHERE (SA_Contact__c IN : mergedWinnerIds
                                                                        OR SA_Contact__c IN : mergeLoserIds )
                                                                ORDER BY c.SA_User__c,c.Primary_Contact_Person__c DESC])
        {
            //Contact Team Member's User
            userID = contactTeamMembers.SA_User__c;
            //If the current User ID is in the Set
            if(tempUserID.contains(userID))
            {
                //Add the Contact Team Member to the List
                contactTeamMembers.Primary_Contact_Person__c = false;
                contactTMDeleteList.add(contactTeamMembers);
                contactTMUpdateList.add(contactTeamMembers);
            }
            //If the current User ID is not in the Set
            else
            {            
                if(winnerOwner[0].OwnerId == contactTeamMembers.SA_User__c){
                    contactTeamMembers.Primary_Contact_Person__c = true;
                }else{
                    contactTeamMembers.Primary_Contact_Person__c = false;
                    contactTMUpdateList.add(contactTeamMembers);
                }
                //Store the last User ID
                tempUserID.add(contactTeamMembers.SA_User__c);
            }
        }
        
        Database.SaveResult[] s2 = Database.update (contactTMUpdateList,false);

        
        Database.DeleteResult[] d = Database.delete (contactTMDeleteList,false);
        
        //JN Update Contact Composite Keys
         List<SA_Contact_Team_Member__c> contactTMCompKeyUpdateList = new List <SA_Contact_Team_Member__c>();
         
            for(SA_Contact_Team_Member__c compKeyUpdate : [SELECT Id,CompositeKey__c,SA_User__c,SA_Contact__c FROM SA_Contact_Team_Member__c WHERE SA_Contact__c IN :mergedWinnerIds] ){
                 compKeyUpdate.CompositeKey__c = String.valueOf(compKeyUpdate.SA_User__c)+ String.valueOf(compKeyUpdate.SA_Contact__c);
                 contactTMCompKeyUpdateList.add(compKeyUpdate);
            }

            //Update all the Contact Team Members CompositeKey in the Update list
            Database.SaveResult[] s3 = Database.update (contactTMCompKeyUpdateList ,false);
     }   
     /**
             * @author :- Vishnu Vundavalli
             * @date  :-  26/03/2015
             * @description :- EN:661 - Public void method gets called from Contact trigger which updates the contact category on ERA's that are
                                        associated to the Event Report of the client 
             * @param :- list<Id> : which contain the changed Client Ids
     */  
     public static void updateERAsOnContactChange(Set<Id> changedClientIds, Map<Id,Contact> mapUpdatedConIdContact,Map<Id,boolean> mapAccIdisNew){

        if(changedClientIds.isEmpty()){
            return;
        }

         List<Call_Report_Attendees__c> callReportAttendees =
         [SELECT id, Call_Report__r.Relate_to_Client__c, Contact_Category__c, Contact_id__c
            FROM Call_Report_Attendees__c
            WHERE
                Contact_id__c IN :mapUpdatedConIdContact.keySet()
                AND Call_Report__r.Relate_to_Client__c IN :changedClientIds
                AND Call_Report__r.End__c >= TODAY
                AND IsDeleted = FALSE
         ];

         List<Call_Report_Attendees__c> listERAToUpdate = new List<Call_Report_Attendees__c>();

         for(Call_Report_Attendees__c attendee : callReportAttendees){
             String oldValue = attendee.Contact_Category__c;
             String newValue = mapAccIdisNew.get(attendee.Call_Report__r.Relate_to_Client__c) ? mapUpdatedConIdContact.get(attendee.Contact_id__c).Contact_Category__c : '';

             if(oldValue != newValue){
                 attendee.Contact_Category__c = newValue;
                 listERAToUpdate.add(attendee);
             }

         }

         if(!listERAToUpdate.isEmpty()){
             try{
                 update listERAToUpdate;
             }catch(Exception e){
             }
         }
    }    
    
    
    //JN: Method to share clients with Standard Bank CCC environment
    public static void createCCCShare(List<Contact> contacts){
        //JN: List to Insert Shared Records
        List <PartnerNetworkRecordConnection> newConnections = new List <PartnerNetworkRecordConnection>();
        
        //JN: Get CCC Connection Record
        List <PartnerNetworkConnection> cccCIBConntection = [SELECT Id, ConnectionStatus, ConnectionName FROM PartnerNetworkConnection WHERE ConnectionName = 'Standard Bank CCC' AND Connectionstatus = 'Accepted'];
        
        //JN: Share clients that have a CIF Number
        if(contacts.size()>0){
            for(Contact contact : contacts){
                if(contact.AccountId != null){
                    PartnerNetworkRecordConnection newConnection =
                        new PartnerNetworkRecordConnection(
                            ConnectionId = cccCIBConntection[0].id,
                            LocalRecordId = contact.Id,
                            SendClosedTasks = false,
                            SendOpenTasks = false,
                            SendEmails = false,
                            ParentRecordID = contact.AccountId
                          );
                    newConnections.add(newConnection);
                }
            }
            //JN: DML for share records
            if(newConnections.size()>0){
                Database.SaveResult[] ncSR = Database.insert(newConnections,false);
            }
        } 
    }
}