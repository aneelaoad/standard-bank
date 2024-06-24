/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 10-31-2022
 * @last modified by  : TCK
**/
public with sharing class DMN_EAP_Attendee {
    public static final String ROL_CORPORATE = 'Corporate';
    public static final String ROL_CORPORATE_ASSOCIATED = 'Corporate Associated';
    public static final String ROL_INVESTOR = 'Investor';
    public static final String ROL_POLICY_MAKER = 'Policy Maker';

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param id2NewRecords 
    * @param id2OldRecords 
    **/
    public static void addToEventGroup(Map<Id, EAP_Attendee__c> id2NewRecords,Map<Id, EAP_Attendee__c> id2OldRecords){ 
        Map<String,Id> contactUserMap = new Map<String,Id>();
        Map<String,Id> eventGroupMap = new Map<String,Id>();

        List<EAP_Attendee__c> attendeeList = new List<EAP_Attendee__c>();
        List<Id> contactList = new List<Id>();
        List<Id> eventList = new List<Id>();
        List<Group> groupList = new List<Group>();
        List<User> userList = new List<User>();

        for(EAP_Attendee__c attendee:id2NewRecords.values()){
            contactList.add(attendee.EAP_Contact__c);
            eventList.add(attendee.EAP_AppEvent__c);
            attendeeList.add(attendee);
        }

        if (attendeeList.size() > 0) {
            userList = SEL_Users.newInstance().selectByContactIds(contactList);
            for (User user : userList) {
                contactUserMap.put(user.Contact_Sync_ID__c,user.Id);
            }
    
            groupList = SEL_Group.newInstance().selectByName(eventList);
            for (Group gr : groupList) {
                eventGroupMap.put(gr.Name,gr.Id);
            }
    
            List<Id> attendeeListId = new List<Id>();
            Map<Id, Id> attendeeGroupMap = new Map<Id, Id>();
            Map<Id, Id> attendeeUserMap = new Map<Id, Id>();
    
            for(EAP_Attendee__c attendee : attendeeList){
                attendeeListId.add(attendee.Id);
                attendeeGroupMap.put(attendee.Id, eventGroupMap.get(attendee.EAP_AppEvent__c));
                attendeeUserMap.put(attendee.Id, contactUserMap.get(attendee.EAP_Contact__c));
            }
    
            addToGroup(attendeeListId, attendeeGroupMap, attendeeUserMap);
        }
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param attendeeList 
    * @param attendeeGroupMap 
    * @param attendeeUserMap 
    **/
    @future
    public static void addToGroup(List<Id> attendeeList, Map<Id, Id> attendeeGroupMap, Map<Id, Id> attendeeUserMap) {  
        new WithoutSharing().addToGroup(attendeeList, attendeeGroupMap, attendeeUserMap);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param id2NewRecords 
    * @param id2OldRecords 
    **/
    public static void deleteAsMember(Map<Id, EAP_Attendee__c> id2NewRecords,Map<Id, EAP_Attendee__c> id2OldRecords){
        List<Id> contactList = new List<Id>();
        List<User> userList = new List<User>();
        List<Id> userIds = new List<Id>();

        for(EAP_Attendee__c attendee:id2OldRecords.values()){
            contactList.add(attendee.EAP_Contact__c);
        }

        userList = SEL_Users.newInstance().selectByContactIds(contactList);
        for (User user : userList) {
            userIds.add(user.Id);
        }

        deleteMember(userIds);
        
    }
    
    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param userIds 
    **/
    @future
    public static void deleteMember(List<Id> userIds) {
        new WithoutSharing().deleteMember(userIds);
    }

    private without sharing class WithoutSharing{

        /**
        * @description 
        * @author TCK | 06-14-2022 
        * @param attendeeList 
        * @param attendeeGroupMap 
        * @param attendeeUserMap 
        **/
        private void addToGroup(List<Id> attendeeList, Map<Id, Id> attendeeGroupMap, Map<Id, Id> attendeeUserMap){
            List<GroupMember> gpList = new List<GroupMember>();
    
            for(Id attendee : attendeeList) {
                if (attendeeUserMap.get(attendee) != null) {
                    GroupMember grpMem = new GroupMember();
                    grpMem.GroupId = attendeeGroupMap.get(attendee);
                    grpMem.UserOrGroupId = attendeeUserMap.get(attendee);

                    if (grpMem.GroupId != null && grpMem.UserOrGroupId != null) {
                        gpList.add(grpMem);
                    }
                }
            }
    
            if(!gpList.isEmpty()) {
                try{
                    insert gpList;
                }catch(DMLException ex){
                    SRV_Logger.newInstance().log(ex, DMN_Log.AREA_EVENTSAPP, DMN_EAP_Attendee.class.getName());
                }
            }
        }
    
        /**
        * @description 
        * @author TCK | 06-14-2022 
        * @param userIds 
        **/
        private void deleteMember(List<Id> userIds) {
            List<GroupMember> gpList = SEL_GroupMember.newInstance().selectByUserOrGroupId(userIds);
            if (gpList.size() > 0) {
                try{
                    delete gpList;
                }catch(DMLException ex){
                    SRV_Logger.newInstance().log(ex, DMN_Log.AREA_EVENTSAPP, DMN_EAP_Attendee.class.getName());
                }
            }
        }
    }
}