/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 07-08-2022
 * @last modified by  : TCK
**/
public with sharing class DMN_EAP_Meeting {
    public static final String GROUP_PREFIX = 'MT_';

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param id2NewRecords 
    * @param id2OldRecords 
    **/
    public static void createMeetingGroup(Map<Id, EAP_Meeting__c> id2NewRecords, Map<Id,EAP_Meeting__c> id2OldRecords){
        new WithoutSharing().createMeetingGroup(id2NewRecords, id2OldRecords);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param id2NewRecords 
    * @param id2OldRecords 
    **/
    public static void populateEventData(Map<Id, EAP_Meeting__c> id2NewRecords, Map<Id, EAP_Meeting__c> id2OldRecords){
        List<EAP_Meeting__c> meetingList = new List<EAP_Meeting__c>();
        Set<Id> meetingIds = new Set<Id>();
        List<Id> eventIds = new List<Id>();

        for(EAP_Meeting__c meeting : id2NewRecords.values()) {
            if (meeting.EAP_AppEvent__c != null) {
                eventIds.add(meeting.EAP_AppEvent__c);
                meetingIds.add(meeting.Id);
            }
        }

        meetingList = SEL_EAP_Meeting.newInstance().selectById(meetingIds);

        if (eventIds.size() > 0) {
            autopopulateMeetings(meetingList, eventIds);
        }
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param meetingList 
    * @param eventIds 
    **/
    public static void autopopulateMeetings(List<EAP_Meeting__c> meetingList, List<Id> eventIds) {
        Map<Id, EAP_AppEvent__c> eventMap = new Map<Id, EAP_AppEvent__c>(SEL_EAP_AppEvent.newInstance().selectById(new Set<Id>(eventIds)));

        for(EAP_Meeting__c meeting : meetingList) {
            meeting.EAP_Location__c = eventMap.get(meeting.EAP_AppEvent__c).EAP_Location__c;
            meeting.EAP_Format__c = eventMap.get(meeting.EAP_AppEvent__c).EAP_Format__c;
            meeting.EAP_Type__c = eventMap.get(meeting.EAP_AppEvent__c).EAP_Type__c;
        }

        try{
            update meetingList;
        }catch(DMLException ex){
            SRV_Logger.newInstance().log(ex, DMN_Log.AREA_EVENTSAPP, DMN_EAP_Meeting.class.getName());
        }
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param id2NewRecords 
    * @param id2OldRecords 
    **/
    public static void deleteMeetingGroup(Map<Id, EAP_Meeting__c> id2NewRecords, Map<Id, EAP_Meeting__c> id2OldRecords){
        List<Id> meetingIds = new List<Id>();
        for(EAP_Meeting__c meeting : id2OldRecords.values()) {
            meetingIds.add(meeting.Id);
        }
        deleteGroup(meetingIds);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param meetingIds 
    **/
    @future
    public static void deleteGroup(List<Id> meetingIds) {
        new WithoutSharing().deleteGroup(meetingIds);
    }

    private without sharing class WithoutSharing{

        /**
        * @description 
        * @author TCK | 06-14-2022 
        * @param id2NewRecords 
        * @param id2OldRecords 
        **/
        private void createMeetingGroup(Map<Id, EAP_Meeting__c> id2NewRecords,Map<Id, EAP_Meeting__c> id2OldRecords){
            List<Group> groups = new List<Group>();
    
            for(EAP_Meeting__c meeting : id2NewRecords.values()){
                Group grp = new Group(); 
                grp.Name = GROUP_PREFIX + meeting.Id; 
                grp.Type = 'Regular'; 
                groups.add(grp);
            }
    
            if(groups.size() > 0){
                try{
                    insert groups;
                }catch(DMLException ex){
                    SRV_Logger.newInstance().log(ex, DMN_Log.AREA_EVENTSAPP, DMN_EAP_Meeting.class.getName());
                }
            }
        }
    
        /**
        * @description 
        * @author TCK | 06-14-2022 
        * @param meetingIds 
        **/
        private void deleteGroup(List<Id> meetingIds) {
            List<Id> groupIds = new List<Id>();
            List<String> groupName = new List<String>();
            for(Id meetingId : meetingIds) {
                groupName.add(GROUP_PREFIX+meetingId);
            }
            List<Group> meetingGroup = SEL_Group.newInstance().selectByName(groupName);
    
            for(Group gr : meetingGroup) {
                groupIds.add(gr.Id);
            }
            List<GroupMember> groupMembers = SEL_GroupMember.newInstance().selectByUserOrGroupId(groupIds);
            if (groupMembers.size() > 0) {
                try{
                    delete groupMembers;
                }catch(DMLException ex){
                    SRV_Logger.newInstance().log(ex, DMN_Log.AREA_EVENTSAPP, DMN_EAP_Meeting.class.getName());
                }
            }
    
            if (meetingGroup.size() >  0) {
                try{
                    delete meetingGroup;
                }catch(DMLException ex){
                    SRV_Logger.newInstance().log(ex, DMN_Log.AREA_EVENTSAPP, DMN_EAP_Meeting.class.getName());
                }
            }
        }
    }
}