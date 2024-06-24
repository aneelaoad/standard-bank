/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 07-08-2022
 * @last modified by  : TCK
**/
public with sharing class DMN_EAP_AppEvent {

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param id2NewRecords 
    * @param id2OldRecords 
    **/
    public static void updateMeeting(Map<Id, EAP_AppEvent__c> id2NewRecords,Map<Id, EAP_AppEvent__c> id2OldRecords){
        List<Id> eventIds = new List<Id>();
        List<EAP_Meeting__c> meetingList = new List<EAP_Meeting__c>();

        for(EAP_AppEvent__c event : id2OldRecords.values()){
            if ((event.EAP_Location__c != id2NewRecords.get(event.Id).EAP_Location__c) || 
                (event.EAP_Format__c != id2NewRecords.get(event.Id).EAP_Format__c) || 
                (event.EAP_Type__c != id2NewRecords.get(event.Id).EAP_Type__c)){
                eventIds.add(event.Id);
            }
        }

        meetingList = SEL_EAP_Meeting.newInstance().selectByEventIds(eventIds);
        DMN_EAP_Meeting.autopopulateMeetings(meetingList, eventIds);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param id2NewRecords 
    * @param id2OldRecords 
    **/
    public static void createEventGroup(Map<Id, EAP_AppEvent__c> id2NewRecords,Map<Id, EAP_AppEvent__c> id2OldRecords){
        new WithoutSharing().createEventGroup(id2NewRecords, id2OldRecords);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param id2NewRecords 
    * @param id2OldRecords 
    **/
    public static void deleteEventGroup(Map<Id, EAP_AppEvent__c> id2NewRecords,Map<Id, EAP_AppEvent__c> id2OldRecords){
        List<Id> eventIds = new List<Id>();
        for(EAP_AppEvent__c event : id2OldRecords.values()) {
            eventIds.add(event.Id);
        }
        deleteGroup(eventIds);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventIds 
    **/
    @future
    public static void deleteGroup(List<Id> eventIds) {
        new WithoutSharing().deleteGroup(eventIds);
    }

    private without sharing class WithoutSharing{

        /**
        * @description 
        * @author TCK | 06-14-2022 
        * @param id2NewRecords 
        * @param id2OldRecords 
        **/
        private void createEventGroup(Map<Id, EAP_AppEvent__c> id2NewRecords,Map<Id, EAP_AppEvent__c> id2OldRecords){
            List<Group> groups = new List<Group>();
    
            for(EAP_AppEvent__c event : id2NewRecords.values()){
                Group grp = new Group(); 
                grp.Name = event.Id; 
                grp.Type = 'Regular'; 
                groups.add(grp);
            }
    
            if(groups.size() > 0){
                try{
                    insert groups;  
                }catch(DMLException e){
                    SRV_Logger.newInstance().log(e, DMN_Log.AREA_EVENTSAPP, DMN_EAP_AppEvent.class.getName());
                }
            }
        }

        /**
        * @description 
        * @author TCK | 06-14-2022 
        * @param eventIds 
        **/
        private void deleteGroup(List<Id> eventIds) {
            List<Id> groupIds = new List<Id>();
            List<Group> eventGroup = SEL_Group.newInstance().selectByName(eventIds);
    
            for(Group gr : eventGroup) {
                groupIds.add(gr.Id);
            }
            List<GroupMember> groupMembers = SEL_GroupMember.newInstance().selectByUserOrGroupId(groupIds);
    
            if (groupMembers.size() > 0) {
                try{
                    delete groupMembers;
                }catch(DMLException e){
                    SRV_Logger.newInstance().log(e, DMN_Log.AREA_EVENTSAPP, DMN_EAP_AppEvent.class.getName());
                }
            }
    
            if (eventGroup.size() >  0) {
                try{
                    delete eventGroup;
                }catch(DMLException e){
                    SRV_Logger.newInstance().log(e, DMN_Log.AREA_EVENTSAPP, DMN_EAP_AppEvent.class.getName());
                }
            }
        }
    }
}