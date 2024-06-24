/*****************************************************************************************************\
    @ Author        : Rudolf Niehaus 
    @ Date          : 11/2010
    @ Test File     : None - Test Method in this class
    @ Description   : Trigger helper class that makes sure that triggers updating objects
                    visa versa do not run into an endless loop 
    @ Last Modified By  : Nitish Kumar
    @ Last Modified On  : March 2013
    @ Modification Description : Made static variables Public to access them in test class
                                 API version moved to 20 from 27
                                 
    @ Last Modified By  : Charles Mutsu
    @ Last Modified On  : 05/04/2013
    @ Modified Reason   : EN-0102 - Implemented Topics Functionality    
    
    @ Last Modified By  : Vishnu Teja Vundavalli
    @ Last Modified On  : 26 April 2015
    @ Last Modified Reason  : EN 707 : To create Event object record on create of Event Report record
    
    @ Last Modified By  : Vishnu Teja Vundavalli
    @ Last Modified On  : 23 June 2015
    @ Last Modified Reason  : EN 742 : To handle ERA's on Confidential activity checkbox update on Insert/Update
    
    @ Last Modified By  : Abhishek V
    @ Last Modified On  : 20 May 2016
    @ Last Modified Reason  : DEF-001864: Removing hyphen (-) if Client Name is null from the Event report Name
    
    @ Last Modified By:     Manoj Gupta
    @ Last Modified On:     May 2016
    @ Last Modified Reason: EN 1352: Removed Client_Name__c,Client__c field references and replaced with Related_to_Client__C
    
    @ Last Modified By  : Abhishek V
    @ Last Modified On  : 13 Oct 2016
    @ Last Modified Reason  : US - 1434: Defining the name of Event report for cases based on RT
                                                        
******************************************************************************************************/
public class SA_EventTriggerHelperClass {
    
    public static boolean alreadyCreatedEventReport = false;
    public static boolean alreadyCreatedEvent = false;
    
    public static boolean hasAlreadyCreatedEventReport(){ 
        return alreadyCreatedEventReport;
    }
    public static boolean hasAlreadyCreatedEvent(){
        return alreadyCreatedEvent;
    }
    
    public static void setAlreadyCreatedEventReport(){
        alreadyCreatedEventReport = true;
    }
    public static void setAlreadyCreatedEvent(){
        alreadyCreatedEvent = true;
    }
    
    public static boolean reportErrorInERUpdate = false;
    public static string errorMsgInErUpdate = '' ;
     /**
             * @author :- Charles Mutsu
             * @date  :-  01-04-13
             * @description :- Public void method which creates the Topic record when a Topic is selected in Event Report
             * @param :- Set<Id> and List<Call_Report_Attendees__c>
     */
    
    public static void createTopic(Set<Id> erIds, List<Call_Report_Attendees__c> eraList){
        List<Topic__c> listTopics = new List<Topic__c>();
        
        for(Call_Report__c er:[Select Id,Topics__c,(Select Id from Call_Report_Attendeess__r) from Call_Report__c where Id IN:erIds]){
            if(er.Topics__c != null){
                String s = er.Topics__c+';';
                List<String> topicName = s.split(';',0);
                System.debug('>>>String>>>'+topicName+'>>>'+topicName.size());
                if(eraList.size()>0){
                    for(Call_Report_Attendees__c era: eraList){
                        if(era.Call_Report__c == er.Id){
                            for(Integer i=0; i<topicName.size(); i++){
                                Topic__c tpcs = new Topic__c(Topic_Name__c = topicName[i], Event_Report_Attendees__c = era.Id);
                                listTopics.add(tpcs);
                            }
                        }
                    }
                }
            }
            
         }
           if(listTopics.size() >0){
            Database.saveresult[] sr = Database.insert(listTopics, False);
            }
            listTopics.clear();
    }
    
     /**
             * @author :- Charles Mutsu
             * @date  :-  01-04-13
             * @description :- Public void method which deletes the Topic record when a Topic is deselected in Event Report
             * @param :- Map<Id,String> mapTopicsOld And Map<Id,String> mapTopicsNew
     */
    
    public static void syncTopicRecords(Map<Id,String> mapTopicsOld , Map<Id,String> mapTopicsNew){
        
        Map<Id,list<String>> mapTopicsToDelete = new Map<Id,list<String>>();
        List<String> topicsToDelete = new list<String>();
        Set<String> newTopicsNameSet = new Set<String>();
        Set<String> oldTopicsNameSet = new Set<String>();
        Map<Id , list<Call_Report_Attendees__c>> mapEventAtten = new Map<Id , List<Call_Report_Attendees__c>>() ;
        List<Topic__c> listTopics = new List<Topic__c>();
        list<String> newTopicName = new list<String>();
        
        list<Call_Report_Attendees__c> eventReportAttenList = [select id , Call_Report__c from Call_Report_Attendees__c Where Call_Report__c =: mapTopicsNew.KeySet()];
        
        if(eventReportAttenList.size()>0){
            for(Call_Report_Attendees__c erAtt : eventReportAttenList){
                mapEventAtten.put(erAtt.Call_Report__c , eventReportAttenList);
            }
        }

        for (Id EventId : mapTopicsOld.keySet()){
            
            if(mapTopicsNew.ContainsKey(EventId)){
            
                String s = mapTopicsOld.get(EventId)+';';
                list<String> oldTopicName = s.split(';',0);
                oldTopicsNameSet.addAll(oldTopicName);
                oldTopicsNameSet.remove('null');
                
                if(mapTopicsNew.get(EventId) != null){
                String s1 = mapTopicsNew.get(EventId)+';';
                newTopicName = s1.split(';',0);
                newTopicsNameSet.addAll(newTopicName);
                }
                
                if(oldTopicName.size()>0){  
                   for (String findTopic : oldTopicName){
                       if (!newTopicsNameSet.Contains(findTopic))
                         topicsToDelete.Add(findTopic);
                   }
                }

                if(newTopicName.size()>0 && newTopicName != null){
                    for (String findTopic2 : newTopicName){
                       if (!(oldTopicsNameSet.Contains(findTopic2)) && findTopic2 != null){
                           if(mapEventAtten.containsKey(EventId)){
                               if(!mapEventAtten.get(EventId).isEmpty()){
                                   for (Call_Report_Attendees__c erAtten : mapEventAtten.get(EventId)){
                                       Topic__c tpcs = new Topic__c(Topic_Name__c = findTopic2, Event_Report_Attendees__c = erAtten.Id);
                                       listTopics.add(tpcs);
                                   }
                               }
                           }
                       }
                    }
                 }
                 mapTopicsToDelete.put(EventId,topicsToDelete );
             }   
         }
        
        
        list<Topic__c> topicsToDeleteList = [select id from Topic__c where Topic_Name__c =: topicsToDelete 
                                                    AND Event_Report_Attendees__r.Call_Report__c In : mapTopicsToDelete.KeySet()];
        
        if(topicsToDeleteList.size() > 0){
        Database.DeleteResult[] sr = Database.delete(topicsToDeleteList, false);
       }
       
       if(listTopics.size() >0){
        Database.saveresult[] s = Database.insert(listTopics, False);
        }
       listTopics.clear();
       
    }
    
    //######################## TEST METODS #############################
    static testMethod void testHelper(){
        
        SA_EventTriggerHelperClass.setAlreadyCreatedEventReport();
        System.assertEquals(SA_EventTriggerHelperClass.hasAlreadyCreatedEventReport(),true);
        SA_EventTriggerHelperClass.setAlreadyCreatedEvent();
        System.assertEquals(SA_EventTriggerHelperClass.hasAlreadyCreatedEvent(),true);
    }
    
    /**
             * @author :- Vishnu Vundavalli
             * @date  :-  19/03/2015
             * @description :- Public void method gets called from SA_EventReportAttendeeUpdate which checks if the bank contact added has a corresponding CST member 
                               in the client and then assign its role to a field in the Event Report Attendees object
             * @param :- Map<Id,String> mapTopicsOld And Map<Id,String> mapTopicsNew
     */
    
    public static void updateCorrespondingCSTRole(List<Call_Report_Attendees__c> lstNewERA){
        
        /******* New logic to satisfy Defect 1157 *****/
        set<Id> setEventReports = new set<Id>();
        set<Id> setConIds = new set<Id>();
        set<Id> setClientIds = new set<Id>();
        map<Id,map<Id,Custom_Client_Team__c>> mapAccIdmapUserConSyncIdCST = new map<Id,map<Id,Custom_Client_Team__c>>();
        map<Id,Call_Report__c> mapERIdER = new map<Id,Call_Report__c>();

        for(Call_Report_Attendees__c newERA : lstNewERA){
            setEventReports.add(newERA.Call_Report__c);
            setConIds.add(newERA.Contact_id__c);
        }
        
        map<Id,Contact> mapConIdContact = new map<Id,Contact>([select id,Contact_Category__c,AccountID from Contact where id in:setConIds]); 
        
        for(Call_Report__c ER : [select id, Relate_to_Client__c from Call_Report__c where ID IN: setEventReports]){
            setClientIds.add(ER.Relate_to_Client__c);
            mapERIdER.put(ER.id,ER);
        }
        
        for(Account client : [select id,
                              (select id,Team_Member__c,Team_Member__r.Contact_Sync_ID__c,Client_Role__c from Custom_Client_Teams__r) 
                              from Account 
                              where id IN: setClientIds])
        {
            for(Custom_Client_Team__c cst : client.Custom_Client_Teams__r){
                if(mapAccIdmapUserConSyncIdCST.containskey(client.id)){
                    mapAccIdmapUserConSyncIdCST.get(client.id).put((Id)cst.Team_Member__r.Contact_Sync_ID__c,cst);
                }else{
                    map<Id,Custom_Client_Team__c> mapUserConSyncIdCST = new map<Id,Custom_Client_Team__c>();
                    mapUserConSyncIdCST.put((Id)cst.Team_Member__r.Contact_Sync_ID__c,cst);
                    
                    mapAccIdmapUserConSyncIdCST.put(client.id,mapUserConSyncIdCST);
                }
            }
        }
        
        for(Call_Report_Attendees__c newERA : lstNewERA){
            if(mapConIdContact.containskey(newERA.Contact_id__c) && mapERIdER.containsKey(newERA.Call_Report__c)){
                if(mapConIdContact.get(newERA.Contact_id__c).AccountId != mapERIdER.get(newERA.Call_Report__c).Relate_to_Client__c){
                    newERA.Contact_Category__c = '';
                }else{
                    newERA.Contact_Category__c = mapConIdContact.get(newERA.Contact_id__c).Contact_Category__c;
                }
            }
            
            if(mapAccIdmapUserConSyncIdCST.containsKey(mapERIdER.get(newERA.Call_Report__c).Relate_to_Client__c)){
                if(mapAccIdmapUserConSyncIdCST.get(mapERIdER.get(newERA.Call_Report__c).Relate_to_Client__c).containsKey(newERA.Contact_id__c)){
                    newERA.Client_Team_Role__c = mapAccIdmapUserConSyncIdCST.get(mapERIdER.get(newERA.Call_Report__c).Relate_to_Client__c).get(newERA.Contact_id__c).Client_Role__c ;
                }else{
                    newERA.Client_Team_Role__c = '';
                }
            }
        }
    }
    
    /**
             * @author :- Vishnu Vundavalli
             * @date  :-  25/03/2015
             * @description :- Public void method gets called from SA_EventReportUpdate which updates the Contact_Category__C and Client_Team_Role
                               according to the CSTs' and contacts' on new client
             * @param :- list<Id> : which contain the changed Client Ids
     */
    
    public static void updateERAsOnClientChange(set<Id> changedClientIds,list<Id> ClientChangeSatisfiedERs){

        //@vishnu (10/4/2015): Changed logic in the method according to incorporate Defect 1157
        map<Id,Call_Report_Attendees__c> mapERAIdERAToUpdate = new map<Id,Call_Report_Attendees__c>();
        map<Id,map<Id,Custom_Client_Team__c>> mapAccIdmapUserConSyncIdCST = new map<Id,map<Id,Custom_Client_Team__c>>();
        
        for(Account client : [select id,
                              (select id,Team_Member__c,Team_Member__r.Contact_Sync_ID__c,Client_Role__c from Custom_Client_Teams__r) 
                              from Account 
                              where id IN: changedClientIds])
        {
            for(Custom_Client_Team__c cst : client.Custom_Client_Teams__r){
                if(mapAccIdmapUserConSyncIdCST.containskey(client.id)){
                    mapAccIdmapUserConSyncIdCST.get(client.id).put((Id)cst.Team_Member__r.Contact_Sync_ID__c,cst);
                }else{
                    map<Id,Custom_Client_Team__c> mapUserConSyncIdCST = new map<Id,Custom_Client_Team__c>();
                    mapUserConSyncIdCST.put((Id)cst.Team_Member__r.Contact_Sync_ID__c,cst);
                    
                    mapAccIdmapUserConSyncIdCST.put(client.id,mapUserConSyncIdCST);
                }
            }
        }
        
        for(Call_Report__c ER : [select id,Relate_to_Client__c, 
                                 (select id,Client_Team_Role__c,Contact_Category__c,
                                         Contact_id__c,Contact_id__r.AccountID,Contact_id__r.Contact_Category__c 
                                         from Call_Report_Attendeess__r 
                                 ) 
                                 from Call_Report__c where Relate_to_Client__c IN: changedClientIds AND id IN: ClientChangeSatisfiedERs]){
                                    
            for(Call_Report_Attendees__c ERA : er.Call_Report_Attendeess__r){
                if(mapAccIdmapUserConSyncIdCST.containsKey(ER.Relate_to_Client__c)){
                    if(mapAccIdmapUserConSyncIdCST.get(ER.Relate_to_Client__c).containsKey(ERA.Contact_id__c)){
                        ERA.Client_Team_Role__c = mapAccIdmapUserConSyncIdCST.get(ER.Relate_to_Client__c).get(ERA.Contact_id__c).Client_Role__c ;
                    }else{
                        ERA.Client_Team_Role__c = '';
                    }
                }
                
                if(ERA.Contact_id__r.AccountID != ER.Relate_to_Client__c){
                    ERA.Contact_Category__c = '';
                }else{
                    if(ERA.Contact_id__r.Contact_Category__c != '' && ERA.Contact_id__r.Contact_Category__c != null){
                        ERA.Contact_Category__c = ERA.Contact_id__r.Contact_Category__c;
                    }
                }
                mapERAIdERAToUpdate.put(ERA.id,ERA);
            }        
        }
        if(!mapERAIdERAToUpdate.values().isEmpty()){
            try{
                update mapERAIdERAToUpdate.values() ;
            }catch(Exception e){
                system.debug('>>> Error while updating ERA on account change : ' + e.getMessage());
            }
        }
    }
    
    /**
             * @author :- Vishnu Vundavalli
             * @date  :-  26/05/2015
             * @description :- Public void method gets called from SA_EventReportUpdate which 
                               creates or updates event record on event report insert or update
             * @param :- list<Call_Report__c> : which contains the trigger.new of inserted ER's
     */

    public static void handleEventOnERInsertOrUpdate(list<Call_Report__c> listInsertedERs,map<Id,Call_Report__c> oldMap){
        
        // Process Updates and Inserted of custom event report records
        Set<Id> reportIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> relate2Ids = new Set<Id>();
        List<Id> changedOwnerIds = new List<Id>();
        List<Id> changedOwnerCallReportIds = new List<Id>();
        List<Id> changedClientContactIds = new List<Id>();
        List<Id> changedClientContactCallReportIds = new List<Id>();
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Call_Report__c;
        Map<String, Schema.RecordTypeInfo> EventRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id nbacrtId = EventRecordTypeInfo.get('NBAC Meeting').getRecordTypeId();
        
        //US - 1434: CIB Client Case RT
        Schema.DescribeSObjectResult cfrSchema1 = Schema.SObjectType.Case;
        Map<String, Schema.RecordTypeInfo> ClientCaseRTinfo = cfrSchema1.getRecordTypeInfosByName();
        Id cibclientcasertid = ClientCaseRTinfo.get('CIB Client Case').getRecordTypeId();
        Id commbclientcasertid = ClientCaseRTinfo.get('CommB Client Case').getRecordTypeId();
        
        //added

        Set<Id> allAccIds = new Set<Id>();
        
        set<Id> setUserIds = new set<Id>();
        for (Call_Report__c s : listInsertedERs){
            setUserIds.add(s.Assigned_To__c);
            
            if(s.EventId__c != null){
                reportIds.add(s.EventId__c);
            }
            if(s.Report_Client_Lead__c != null){
                contactIds.add(s.Report_Client_Lead__c);
            }
            if(s.Report_Client_Contact__c != null){
                contactIds.add(s.Report_Client_Contact__c);
            }
            if(s.Relate_to_Client__c != null){
                relate2Ids.add(s.Relate_to_Client__c);
                allAccIds.add(s.Relate_to_Client__c) ;
            }
            if(s.Relate_to_Opp__c != null){
                relate2Ids.add(s.Relate_to_Opp__c);
            }
            if(s.Related_to_Case__c != null){
                relate2Ids.add(s.Related_to_Case__c);
             }
            if(s.Related_to_Campaign__c != null){
                 relate2Ids.add(s.Related_to_Campaign__c);
            }
        }
        
        // Get role to users mapping in a map with key as role id
        map<Id, UserRole> roleUsersMap = new Map<Id, UserRole>([select Id, Name, parentRoleId, (select id, name, Business_Unit__c, User_Division__c from users where isActive=true) from UserRole order by parentRoleId]);
    
        Map<Id, User> mapUserIdToUser ;
        if (!setUserIds.isEmpty()) {
            // Populate map of user id -> user based on previous id's
            mapUserIdToUser = new Map<Id, User>([select Id, Name, UserRole.Name,UserRoleID, UserRole.Id
                                    from User
                                    where Id in :setUserIds]);
        }
        
        // Loop through list and check if user's role is DCM or Advisory
        List<Id> eventOwnerRoleIds = new List<Id>();
        
        for (Call_Report__c cr : listInsertedERs) {
            if(mapUserIdToUser.get(cr.Assigned_To__c) != null){
                eventOwnerRoleIds.add(mapUserIdToUser.get(cr.Assigned_To__c).UserRole.Id);
            }
        }
        
        // Build hashtable of standard event records that are associated to the changed custom event reports
        Map<Id,Event> eventMap = new Map<Id,Event>([Select Id, OwnerId, Location, Subject, StartDateTime, EndDateTime, Meeting_Audience__c, Meeting_Purpose__c,
                 IsAllDayEvent, WhoId, ShowAs, SA_Related_to_Non_CIB_Client__c, call_report_created__c,
                 SA_Priority__c,WhatId,Description from Event where Id IN : reportIds]);
        
        Map<Id,Contact> contactMap = new Map<Id,Contact>([Select Id,Inactive__c,RecordTypeId, Name, AccountId from Contact Where Id IN : contactIds]);
        Map<Id,Lead> leadMap = new Map<Id,Lead>([Select Id, Name from Lead Where Id IN : contactIds]);
        
        //Related To - The WhatId
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([Select Id, Name,Account.Name from Opportunity Where Id IN : relate2Ids]);
        //Map<Id,Account> accMap = new Map<Id,Account>([Select Id, Name from Account Where Id IN : relate2Ids]);
        Map<Id,Account> accMap = new Map<Id,Account>();
        Map<Id,Campaign> campMap = new Map<Id,Campaign>([Select Id, Name from Campaign Where Id IN : relate2Ids]);
        Map<Id,Case> caseMap = new Map<Id,Case>([Select Id, Subject,CaseNumber, AccountId, Account.Name, RecordTypeId from Case Where Id IN : relate2Ids]);
        
        for(Contact c : contactMap.values()){
            if(c.AccountId != null){
                accountIds.add(c.AccountId);
                allAccIds.add(c.AccountId);
            }
        }
        
        //@vishnu(26/05/2015) : commented to merge the query with other accounts and then segregate into seperate maps
        //Map<Id,Account> accountMap = new Map<Id,Account>([Select Id, Name from Account Where Id IN : accountIds]);
        Map<Id,Account> accountMap = new Map<Id,Account>();
        
        for(Account acc : [select id,name, Primary_Relationship_Holder__c from account where id IN : allAccIds ]){
            if(relate2Ids.contains(acc.id)){
                accMap.put(acc.id,acc);
            }
            if(accountIds.contains(acc.id)){
                accountMap.put(acc.id,acc);
            }
        }
        
        String strClientName; 
        String strContactId; 
        String strOppRelatedName; 
        String strClientRelatedName;
        String strCampRelatedName;
        String strCaseRelatedName;  
        String strClientContact; 
        String repName; 
        String ID; 
        String thelink; 
        
        Environment_Variable__c env = Environment_Variable__c.getInstance();
        String adminProfileIds = env.Admin_Profile_IDs__c;
        Id currentUserProfileId = Userinfo.getProfileId();
        Id currentUserRoleId  = UserInfo.getUserRoleId();
        Id currentUserId = UserInfo.getUserId(); 
        String BankContactRecordTypeID = env.Bank_Contact_Record_Id__c.subString(0,15);
        Boolean isAdminUser = false;
        
        if(adminProfileIds!=null){
            if(adminProfileIds.contains(currentUserProfileId)){
                isAdminUser = true;
            }
        }
        
        if(trigger.IsUpdate) {
            for (Call_Report__c cr : listInsertedERs){
                
                if(eventMap.containsKey(cr.EventId__c)){
                    // US-1661 this part will never be true
                    // if(Trigger.isInsert){
                    //    eventMap.get(cr.EventId__c).Call_Report_Created__c = True;
                    //}else 
                    //if(Trigger.isUpdate){
                        
                        // Get reference to original record before the update.
                        Call_Report__c originalEventReport = oldMap.get(cr.Id);
                        // Check if the Assigned to Changed?
                        if (cr.Assigned_To__c == null || cr.Assigned_To__c != originalEventReport.Assigned_To__c){
                            Id currentEventOwnerId = cr.OwnerId;
                            //@vishnu(29/6/2015) : replacing the isManagerOfUser method with isManagerOfUserByProvidingRoles to avoid acting like query in loop
                            //if (isAdminUser || (RoleUtility.isManagerOfUser(currentUserRoleId,currentEventOwnerId)) || (currentUserId == currentEventOwnerId) )
                            if (isAdminUser || (RoleUtility.isManagerOfUserByProvidingRoles(roleUsersMap,currentUserRoleId,currentEventOwnerId)) || (currentUserId == currentEventOwnerId) ){
                            
                                cr.OwnerId = cr.Assigned_To__c;
                            } else {
                                cr.addError('You do not have sufficient privileges to modify the assigned to value. Please request the record owner to update this record.');
                            }
                        }
                        
                        if (cr.OwnerId != originalEventReport.OwnerId  && cr.RecordTypeId != nbacrtId){
                            
                            cr.Assigned_To__c = cr.OwnerId;
                            changedOwnerIds.add(cr.OwnerId);
                            changedOwnerCallReportIds.add(cr.Id);
                        }
                        //check if the Client Contact changed
                        if (cr.Report_Client_Contact__c != originalEventReport.Report_Client_Contact__c && cr.Report_Client_Contact__c != null){
                            changedClientContactIds.add(cr.Report_Client_Contact__c);
                            changedClientContactCallReportIds.add(cr.Id);
                        } 
    
                        eventMap.get(cr.EventId__c).Description = cr.Description__c;       
                        eventMap.get(cr.EventId__c).Subject = cr.Subject__c;
                        eventMap.get(cr.EventId__c).Location = cr.Location__c; 
                        eventMap.get(cr.EventId__c).OwnerId = cr.Assigned_To__c;
            
                        eventMap.get(cr.EventId__c).StartDateTime = cr.Start__c; 
                        eventMap.get(cr.EventId__c).EndDateTime = cr.End__c; 
                        eventMap.get(cr.EventId__c).Meeting_Audience__c = cr.Meeting_Audience__c;
                        eventMap.get(cr.EventId__c).Meeting_Purpose__c = cr.Meeting_Purpose__c;
                        eventMap.get(cr.EventId__c).IsAllDayEvent = cr.AllDayEvent__c;
                        eventMap.get(cr.EventId__c).ShowAs = cr.Report_Show_Time_As__c;
                        eventMap.get(cr.EventId__c).SA_Related_to_Non_CIB_Client__c = cr.Related_To_Non_CIB_Client__c;                 
                        eventMap.get(cr.EventId__c).Visible_to_Internal_Attendees_only__c = cr.Visible_to_Internal_Attendees_only__c;
                        eventMap.get(cr.EventId__c).SA_Priority__c = cr.Event_Priority__c;
                        
                        if(contactMap.containsKey(cr.Report_Client_Contact__c)){
                            strClientName = contactMap.get(cr.Report_Client_Contact__c).Name;
                            
                            if(accountMap.containsKey(contactMap.get(cr.Report_Client_Contact__c).AccountId)){
                              //  cr.Client__c = accountMap.get(contactMap.get(cr.Report_Client_Contact__c).AccountId).Id;   //commented as a part of EN:1352
                                strClientName = accountMap.get(contactMap.get(cr.Report_Client_Contact__c).AccountId).Name;
                            }
                        }else{
                            if(leadMap.containsKey(cr.Report_Client_Lead__c)){
                                strClientName = leadMap.get(cr.Report_Client_Lead__c).Name;
                            }
                        }
                        
                        ///////// ADD WhoId Link
                        if(cr.Report_Client_Contact__c == null){
                            //link lead
                            eventMap.get(cr.EventId__c).WhoId = cr.Report_Client_Lead__c;
                        }else{
                            //link contact
                            eventMap.get(cr.EventId__c).WhoId = cr.Report_Client_Contact__c;
                            eventMap.get(cr.EventId__c).Report_Client_Contact__c = cr.Report_Client_Contact__c;
                            //@En-662 - Populating Related to client if contact is not blank
                            if(cr.Relate_to_Client__c == null && cr.Relate_to_Opp__c == null && 
                                cr.Related_to_Campaign__c == null && cr.Related_To_Case__c == null){
                                cr.Relate_to_Client__c = contactMap.get(cr.Report_Client_Contact__c).AccountId;
                            }
                        }
                        
                        ////////// ADD WhatId Link
                        if(cr.Relate_to_Opp__c != null){
                            eventMap.get(cr.EventId__c).WhatId = cr.Relate_to_Opp__c;
                            strOppRelatedName = oppMap.get(cr.Relate_to_Opp__c).Account.Name;
                        }else if(cr.Relate_to_Client__c != null){
                            eventMap.get(cr.EventId__c).WhatId = cr.Relate_to_Client__c;
                            //@En-662 - Populating Related to client if contact is not blank
                            if(accMap.get(cr.Relate_to_Client__c) != null)
                                strClientRelatedName = accMap.get(cr.Relate_to_Client__c).Name;
                            else if (accountMap.get(cr.Relate_to_Client__c) != null)
                                strClientRelatedName = accountMap.get(cr.Relate_to_Client__c).Name;                          
                        }else if(cr.Related_to_Campaign__c != null){
                            eventMap.get(cr.EventId__c).WhatId = cr.Related_to_Campaign__c;
                            strCampRelatedName = campMap.get(cr.Related_to_Campaign__c).Name;
                        }else if(cr.Related_to_Case__c != null){
                            eventMap.get(cr.EventId__c).WhatId = cr.Related_to_Case__c;
                            if((caseMap.get(cr.Related_to_Case__c).RecordTypeId == cibclientcasertid || caseMap.get(cr.Related_to_Case__c).RecordTypeId == commbclientcasertid) && caseMap.get(cr.Related_to_Case__c).AccountId != null){
                                strCaseRelatedName = caseMap.get(cr.Related_to_Case__c).Account.Name;
                            }else{
                                strCaseRelatedName = caseMap.get(cr.Related_to_Case__c).CaseNumber;
                            }
                        }else {
                            eventMap.get(cr.EventId__c).WhatId = null;
                        }   
                        
                        
                        eventMap.get(cr.EventId__c).SA_Activity_Instigated__c = cr.Instigated_By__c;
                                                
                        if(strClientRelatedName != null ){
                            thelink = strClientRelatedName;
                        }else{
                            if(strClientName  != null){
                                thelink = strClientName;
                            }else if(strOppRelatedName != null){
                                thelink = strOppRelatedName;
                            }else if(strCaseRelatedName != null){
                                thelink = strCaseRelatedName;
                            }else if(strCampRelatedName != null){
                                thelink = strCampRelatedName;
                            }else {
                                thelink = null;
                            }
                        }
                        
                        if(thelink == null){
                            repName = cr.Subject__c;
                        }else{
                            repName = cr.Subject__c + '-' + thelink;
                        }
                        cr.Name = (repName.length() > 79)?repName.Substring(0,79):repName;
                    
                        strClientName = ''; 
                        strContactId = ''; 
                        strOppRelatedName = ''; 
                        strClientRelatedName = ''; 
                        strClientContact = '';
                        strCampRelatedName = ''; 
                        strCaseRelatedName = '';
                        repName = ''; 
                        ID = ''; 
                        thelink = '';                                                                                 
                    //}
                }                              
            }
            SA_EventTriggerHelperClass.setAlreadyCreatedEventReport();
             
            Database.SaveResult[] lsr = Database.update(eventMap.values(),false);
            for(Database.SaveResult sr : lsr){
                
                if(!sr.isSuccess()){
                    reportErrorInERUpdate = true; 
                    // Get the first save result error
                    Database.Error err = sr.getErrors()[0];
                     errorMsgInErUpdate =  err.getMessage();
                    break;
                }
            }
            
            // Add the new owner as attendee
            if (changedOwnerCallReportIds.size()>0) {
                List<Id> ownerContactIds = new List<Id>();
                Map<Id,User> userMap = new Map<Id,User>([Select Id, Contact_Sync_ID__c from User Where Id IN : changedOwnerIds]);
                for (Id ownerId : changedOwnerIds) {
                    ownerContactIds.add(userMap.get(ownerId).Contact_Sync_ID__c);
                }
                SA_EventReportAttendeeFutureUpdate.addEventReportAttendees(ownerContactIds, changedOwnerCallReportIds);
            }
            
            // Add the changed client contact as attendee
            if (changedClientContactIds.size()>0) {
                SA_EventReportAttendeeFutureUpdate.addEventReportAttendees(changedClientContactIds, changedClientContactCallReportIds);
            }
        }
        else if(trigger.isInsert){
            map<Integer,Event> mapUniqueIDNewEvent = new map<Integer,Event>();
            map<Integer,Call_Report__c> mapUniqueIDNewER = new map<Integer,Call_Report__c>();
            Integer i = 1;
                               
            for (Call_Report__c cr : listInsertedERs){
                
                Event newEvent = new Event();
                
                newEvent.Description = cr.Description__c;       
                newEvent.Subject = cr.Subject__c;
                newEvent.Location = cr.Location__c; 
                newEvent.OwnerId = cr.Assigned_To__c;
                newEvent.StartDateTime = cr.Start__c; 
                newEvent.EndDateTime = cr.End__c; 
                newEvent.Meeting_Audience__c = cr.Meeting_Audience__c;
                newEvent.Meeting_Purpose__c = cr.Meeting_Purpose__c;
                newEvent.IsAllDayEvent = cr.AllDayEvent__c;
                newEvent.ShowAs = cr.Report_Show_Time_As__c;
                newEvent.SA_Related_to_Non_CIB_Client__c = cr.Related_To_Non_CIB_Client__c;                 
                newEvent.Visible_to_Internal_Attendees_only__c = cr.Visible_to_Internal_Attendees_only__c;
                newEvent.SA_Priority__c = cr.Event_Priority__c;
                newEvent.call_report_created__c = true;

                if(contactMap.containsKey(cr.Report_Client_Contact__c)){
                    strClientName = contactMap.get(cr.Report_Client_Contact__c).Name;
                    
                    if(accountMap.containsKey(contactMap.get(cr.Report_Client_Contact__c).AccountId)){
                        strClientName = accountMap.get(contactMap.get(cr.Report_Client_Contact__c).AccountId).Name;
                    }
                }else{
                    if(leadMap.containsKey(cr.Report_Client_Lead__c)){
                        strClientName = leadMap.get(cr.Report_Client_Lead__c).Name;
                    }
                }

                // ADD WhoId Link
                if(cr.Report_Client_Contact__c == null){
                    //link lead
                    newEvent.WhoId = cr.Report_Client_Lead__c;
                }else{
                    //link contact
                    newEvent.WhoId = cr.Report_Client_Contact__c;
                    newEvent.Report_Client_Contact__c = cr.Report_Client_Contact__c;
                    if(cr.Relate_to_Client__c == null && cr.Relate_to_Opp__c == null &&
                        cr.Related_to_Campaign__c == null && cr.Related_To_Case__c == null){
                        cr.Relate_to_Client__c = contactMap.get(cr.Report_Client_Contact__c).AccountId;
                    }
                }
                
                if(cr.Relate_to_Opp__c != null){
                    newEvent.WhatId = cr.Relate_to_Opp__c;
                    strOppRelatedName = oppMap.get(cr.Relate_to_Opp__c).Account.Name;
                }else if(cr.Relate_to_Client__c != null){
                    newEvent.WhatId = cr.Relate_to_Client__c;
                    //@En-662 - Populating Related to client if contact is not blank
                    if(accMap.get(cr.Relate_to_Client__c) != null){
                        strClientRelatedName = accMap.get(cr.Relate_to_Client__c).Name;
                    }else if (accountMap.get(cr.Relate_to_Client__c) != null){
                        strClientRelatedName = accountMap.get(cr.Relate_to_Client__c).Name;     
                    }                     
                }else if(cr.Related_to_Campaign__c != null){
                    newEvent.WhatId = cr.Related_to_Campaign__c;
                    strCampRelatedName = campMap.get(cr.Related_to_Campaign__c).Name;
                }else if(cr.Related_to_Case__c != null){
                    newEvent.WhatId = cr.Related_to_Case__c;
                    //strCaseRelatedName = caseMap.get(cr.Related_to_Case__c).Subject; //Commented as part of US - 1434
                    if((caseMap.get(cr.Related_to_Case__c).RecordTypeId == cibclientcasertid || caseMap.get(cr.Related_to_Case__c).RecordTypeId == commbclientcasertid) && caseMap.get(cr.Related_to_Case__c).AccountId != null){
                        strCaseRelatedName = caseMap.get(cr.Related_to_Case__c).Account.Name;
                    }else{
                        strCaseRelatedName = caseMap.get(cr.Related_to_Case__c).CaseNumber;
                    }
                }else {
                    newEvent.WhatId = null;
                }   

                newEvent.SA_Activity_Instigated__c = cr.Instigated_By__c;
                                        
                if(strClientRelatedName != null ){
                    thelink = strClientRelatedName;
                }else{
                    if(strClientName  != null){
                        thelink = strClientName;
                    }
                    else if(strOppRelatedName != null){
                        thelink = strOppRelatedName;
                    }else if(strCaseRelatedName != null){
                        thelink = strCaseRelatedName;
                    }else if(strCampRelatedName != null){
                        thelink = strCampRelatedName;
                    }else {
                        thelink = null;
                    }
                }
                if(thelink == null){
                    repName = cr.Subject__c;
                }else{
                    repName = cr.Subject__c + '-' + thelink;
                }
                cr.Name = (repName.length() > 79)?repName.Substring(0,79):repName;
                
                strClientName = ''; 
                strContactId = ''; 
                strOppRelatedName = ''; 
                strClientRelatedName = ''; 
                strClientContact = '';
                strCampRelatedName = ''; 
                strCaseRelatedName = '';
                repName = ''; 
                ID = ''; 
                thelink = '';   
                
                mapUniqueIDNewEvent.put(i,newEvent);    
                mapUniqueIDNewER.put(i,cr);
                i++;      
            } 
            
            SA_EventTriggerHelperClass.setAlreadyCreatedEvent();
            try{
                insert mapUniqueIDNewEvent.values() ;
                
                for(Integer uniqueID : mapUniqueIDNewER.keyset()){
                    if(mapUniqueIDNewEvent.containsKey(uniqueID)){
                        mapUniqueIDNewER.get(uniqueID).EventId__c = mapUniqueIDNewEvent.get(uniqueID).id;
                    }
                }
                
            }catch(Exception e){
                system.debug('>>>> exception while creating event report : ' +  e.getMessage());
            }
            
            
        }     
    }

     /**
             * @author :- Vishnu Vundavalli
             * @date  :-  26/05/2015
             * @description :- Public void method gets called from SA_EventReportUpdate which 
                               creates event report attendees on create of event report
             * @param :- list<Call_Report__c> : which contains the trigger.new of inserted ER's
     */
    
    public static void createERAsOnERInsert(list<Call_Report__c> listInsertedERs){
        set<Id> setAssignedToUserIds = new set<Id>();
        list<ID> bankContactIds = new list<ID>();
        list<ID> eventReportIds = new list<ID>();
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Call_Report__c;
        Map<String, Schema.RecordTypeInfo> EventRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id nbacrtId = EventRecordTypeInfo.get('NBAC Meeting').getRecordTypeId();
         
        for(Call_Report__c newER : listInsertedERs){
            setAssignedToUserIds.add(newER.Assigned_To__c) ;
        }
        
        Map<Id,User> userMap = new Map<Id,User>([Select Id, Name, Contact_Sync_ID__c from User Where Id IN : setAssignedToUserIds]);
        
        for(Call_Report__c newER : listInsertedERs){
            if(newER.Report_Client_Contact__c != null){
                bankContactIds.add(newER.Report_Client_Contact__c);
                eventReportIds.add(newER.id);
            }
            if(userMap.containsKey(newER.Assigned_To__c) && newER.RecordTypeId != nbacrtId){
                bankContactIds.add(userMap.get(newER.Assigned_To__c).Contact_Sync_ID__c);
                eventReportIds.add(newER.id);
            }
        }
        
        if(!bankContactIds.isEmpty()){
            SA_EventReportAttendeeFutureUpdate.addEventReportAttendees(bankContactIds, eventReportIds);
        }
    }
}