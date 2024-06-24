/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 11-02-2022
 * @last modified by  : TCK
**/
public without sharing class EAP_BATCH_MatchmakingAlgorithm implements Database.Batchable<sObject>, Database.Stateful{
    
    Map<String, AttendeesMeeting_Wrapper> mapAttMeeting; 
    String eventId; //App Event that fires de Matchmaking 

    Map<Id, Map<DateTime, EAP_MeetingAvailability__c>> mapInvestors;
    Map<Id, Map<DateTime, EAP_MeetingAvailability__c>> mapCorporates;
    Map<Id, List<EAP_Attendee__c>> mapCorpWithAssociated;
    List<Id> attendanceList = new List<Id>();

    Integer numGoldMeetings;
    Integer numSilverMeetings;
    Integer numBronzeMeetings;

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param idEvent 
    **/
    public EAP_BATCH_MatchmakingAlgorithm(String idEvent){
        this.eventId = idEvent;
        this.mapAttMeeting = new Map<String, AttendeesMeeting_Wrapper>();
        this.mapInvestors = new Map<Id, Map<DateTime, EAP_MeetingAvailability__c>>();
        this.mapCorporates = new Map<Id, Map<DateTime, EAP_MeetingAvailability__c>>();
        this.mapCorpWithAssociated = new  Map<Id, List<EAP_Attendee__c>>();
        this.numGoldMeetings = 0;
        this.numSilverMeetings = 0;
        this.numBronzeMeetings = 0;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param bc 
    * @return Database.QueryLocator 
    **/
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(
            'SELECT Id, CreatedDate, EAP_Meeting__c, EAP_Attendee__c,'
                    + ' EAP_RequestFrom__r.Id, EAP_RequestFrom__r.EAP_TierLevel__c,'
                    + ' EAP_TargetAttendee__r.Id,EAP_TargetAttendee__r.Name,EAP_RequestFrom__r.Name ' +
            'FROM EAP_Attendance__c ' +
            'WHERE EAP_Meeting__c = NULL ' +
            'AND EAP_Attendee__r.EAP_AppEvent__c = :eventId '+
            'ORDER BY EAP_RequestFrom__r.EAP_TierLevel__c ASC, EAP_RequestFrom__r.EAP_SlotAssociated__c ASC,EAP_RequestFrom__r.Name ASC,EAP_PreferenceSelection__c ASC, CreatedDate ASC');
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param bc 
    * @param listAttendance 
    **/
    public void execute(Database.BatchableContext bc, List<EAP_Attendance__c> listAttendance) {
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        EAP_AppEvent__c eventInfo = SEL_EAP_AppEvent.newInstance().selectByIdWithTierLevelInfo(this.eventId);

        Set<Id> listInvestor =  new Set<Id>();
        Set<Id> listCorporates =  new Set<Id>();
        Map<Id, List<Id>>  mapInvestorCorporate = new Map<Id, List<Id>>();

        for (EAP_Attendance__c attendance : listAttendance) {
            if (!listInvestor.contains(attendance.EAP_RequestFrom__r.Id)) {
                listInvestor.add(attendance.EAP_RequestFrom__r.Id);
            }

            if (!listCorporates.contains(attendance.EAP_TargetAttendee__r.Id)) {
                listCorporates.add(attendance.EAP_TargetAttendee__r.Id);
            }

            if (!mapInvestorCorporate.containsKey(attendance.EAP_RequestFrom__r.Id)) {
                mapInvestorCorporate.put(attendance.EAP_RequestFrom__r.Id, new List<Id>());
            }

            List<Id> listCorporatesInMap = mapInvestorCorporate.get(attendance.EAP_RequestFrom__r.Id);
            listCorporatesInMap.add(attendance.EAP_TargetAttendee__r.Id);
            mapInvestorCorporate.put(attendance.EAP_RequestFrom__r.Id, listCorporatesInMap);
        }

        getAttendanceMeetingAvailability(listInvestor, listCorporates);
        getAssociatedCorporates(listCorporates);

        for (EAP_Attendance__c attendance : listAttendance) {
            Datetime startEventMeetingTime = eventInfo.EAP_StartMeetingTime__c;

            Map<DateTime, EAP_MeetingAvailability__c> investorAvailability = mapInvestors.get(attendance.EAP_RequestFrom__c);
            Map<DateTime, EAP_MeetingAvailability__c> coorporateAvailability = mapCorporates.get(attendance.EAP_TargetAttendee__c);

            List<EAP_MeetingAvailability__c> listMeetAvaiInvestor = (investorAvailability != null)?investorAvailability.values():new List<EAP_MeetingAvailability__c>();
            Integer iteratorValue = 0;

            Boolean booked = false;
            Boolean failMatch = false;
            if(investorAvailability != null && coorporateAvailability != null){
                do{ 

                    if(!listMeetAvaiInvestor.isEmpty() && iteratorValue < listMeetAvaiInvestor.size()){
                        startEventMeetingTime = listMeetAvaiInvestor.get(iteratorValue).EAP_StartDate__c;
                    }else{
                        failMatch = true;
                    }
                    
                    EAP_MeetingAvailability__c meetAvailableInvestor = investorAvailability.get(startEventMeetingTime);
                    EAP_MeetingAvailability__c meetAvailableCoorporate = coorporateAvailability.get(startEventMeetingTime);

                    if(meetAvailableInvestor != null && !meetAvailableInvestor.EAP_Booked__c
                        && meetAvailableCoorporate != null &&  !meetAvailableCoorporate.EAP_Booked__c){

                        EAP_Meeting__c meeting = createMeeting(startEventMeetingTime,eventInfo,attendance.EAP_RequestFrom__r.EAP_TierLevel__c,attendance.EAP_TargetAttendee__r.Id);
                        uow.registerNew(meeting);

                        EAP_Attendance__c attTarget = createAttendance(attendance);
                        uow.registerRelationship(attTarget, EAP_Attendance__c.EAP_Meeting__c, meeting);
                        uow.registerNew(attTarget);


                        for (EAP_Attendee__c associatedCorporate : mapCorpWithAssociated.get(attendance.EAP_TargetAttendee__r.Id)) {
                            EAP_Attendance__c attAssociated = createAttendance(attendance, associatedCorporate);
                            uow.registerRelationship(attAssociated, EAP_Attendance__c.EAP_Meeting__c, meeting);
                            uow.registerNew(attAssociated);
                        }
                        
                        uow.registerDirty(attendance,EAP_Attendance__c.EAP_Meeting__c,meeting);

                        meetAvailableInvestor.EAP_Booked__c = true;
                        meetAvailableCoorporate.EAP_Booked__c = true;
                        uow.registerDirty(meetAvailableInvestor);
                        uow.registerDirty(meetAvailableCoorporate);

                        AttendeesMeeting_Wrapper attWr = new AttendeesMeeting_Wrapper(meeting,attendance.EAP_RequestFrom__r.EAP_TierLevel__c);
                        mapAttMeeting.put(attendance.EAP_TargetAttendee__c+'-'+startEventMeetingTime,attWr);

                        booked = true;

                    }else if(meetAvailableInvestor != null && !meetAvailableInvestor.EAP_Booked__c && meetAvailableCoorporate != null && meetAvailableCoorporate.EAP_Booked__c){
                        AttendeesMeeting_Wrapper att = mapAttMeeting.get(attendance.EAP_TargetAttendee__c+'-'+startEventMeetingTime);
                        Boolean canJoinMeeting = false;
                        if(att != null && att.meeting != null && att.tierLevelMeeting == attendance.EAP_RequestFrom__r.EAP_TierLevel__c){
                            if(att.numGoldAttendees != null && att.numGoldAttendees < eventInfo.EAP_GoldPerMeeting__c){
                                canJoinMeeting = true;
                                att.numGoldAttendees++;
                            }
                            if( att.numSilverAttendees != null && att.numSilverAttendees < eventInfo.EAP_SilverPerMeeting__c){
                                canJoinMeeting = true;
                                att.numSilverAttendees++;
                            }
                            if(att.numBronzeAttendees != null && att.numBronzeAttendees < eventInfo.EAP_BronzePerMeeting__c){
                                canJoinMeeting = true;
                                att.numBronzeAttendees++;
                            }
                        }

                        if(canJoinMeeting){    
                            uow.registerDirty(attendance,EAP_Attendance__c.EAP_Meeting__c, att.meeting);

                            meetAvailableInvestor.EAP_Booked__c = true;
                            uow.registerDirty(meetAvailableInvestor);

                            booked = true;
                        }
                        
                    }
                    iteratorValue++;

                }while(!booked && !failMatch);

                attendanceList.add(attendance.Id);
            }
        }

        uow.commitWork();
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param bc 
    **/
    public void finish(Database.BatchableContext bc){
        List<EAP_Attendance__c> attendanceListObject = SEL_EAP_Attendance.newInstance().selectById(attendanceList);
        Map<String, List<Id>> attendanceMap = new Map<String, List<Id>>();
        for (EAP_Attendance__c att: attendanceListObject) {
            if (attendanceMap.keySet().contains(DMN_EAP_Meeting.GROUP_PREFIX+att.EAP_Meeting__c)) {
                List<Id> tempAttendees = attendanceMap.get(DMN_EAP_Meeting.GROUP_PREFIX+att.EAP_Meeting__c);
                tempAttendees.add(att.EAP_Attendee__c);
                attendanceMap.put(DMN_EAP_Meeting.GROUP_PREFIX+att.EAP_Meeting__c, tempAttendees);
                
            } else {
                List<Id> tempAttendees = new List<Id>();
                tempAttendees.add(att.EAP_Attendee__c);
                attendanceMap.put(DMN_EAP_Meeting.GROUP_PREFIX+att.EAP_Meeting__c, tempAttendees);
            }
        }

        Map<String, Id> meetingGroupMap = new Map<String,Id>();
        Map<Id, Id> attendeeContactMap = new Map<Id,Id>();
        Map<Id, Id> contactUserMap = new Map<Id,Id>();
        Map<Id, List<Id>> groupUserMap = new Map<Id,List<Id>>();
        List<Group> groupList = new List<Group>();
        List<Id> attendeeIdList = new List<Id>();
        List<EAP_Attendee__c> attendeeList = new List<EAP_Attendee__c>();
        List<User> userList = new List<User>();
        List<GroupMember> gpList = new List<GroupMember>();

        attendeeIdList.addAll(new List<Id>(mapInvestors.keySet()));
        attendeeIdList.addAll(new List<Id>(mapCorporates.keySet()));

        groupList = [SELECT Id, Name FROM Group WHERE Name IN: attendanceMap.keySet()];
        // groupList = SEL_Group.newInstance().selectByName(attendanceMap.keySet());
        for (Group gr : groupList) {
            meetingGroupMap.put(gr.Name,gr.Id);
        }

        attendeeList = SEL_EAP_Attendee.newInstance().selectByIds(attendeeIdList);
        for (EAP_Attendee__c att : attendeeList) {
            attendeeContactMap.put(att.Id, att.EAP_Contact__c);
        }

        userList = SEL_Users.newInstance().selectByContactIds(attendeeContactMap.values());
        for (User user : userList) {
            contactUserMap.put(user.Contact_Sync_ID__c, user.Id);
        }

        for(String groupName : attendanceMap.keySet()) {
            for (Id attendeeId :attendanceMap.get(groupName)) {
                if (groupUserMap.keySet().contains(meetingGroupMap.get(groupName))) {
                    List<Id> tempUserList = groupUserMap.get(meetingGroupMap.get(groupName));
                    tempUserList.add(contactUserMap.get(attendeeContactMap.get(attendeeId)));
                    groupUserMap.put(meetingGroupMap.get(groupName), tempUserList);
                } else {
                    List<Id> tempUserList = new List<Id>();
                    tempUserList.add(contactUserMap.get(attendeeContactMap.get(attendeeId)));
                    groupUserMap.put(meetingGroupMap.get(groupName), tempUserList);
                }
            }
        }

        for(Id groupId : groupUserMap.keySet()) {
            for (Id userId: groupUserMap.get(groupId)) {
                GroupMember grpMem = new GroupMember();
                grpMem.GroupId = groupId;
                grpMem.UserOrGroupId = userId;
                if (grpMem.GroupId != null) {
                    gpList.add(grpMem);
                }
            }
        }

        if(!gpList.isEmpty()) {
            insert gpList;
        }
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param ids 
    **/
    @InvocableMethod(label='Run Matchmaking Algorithm' description='Execute de Matchmaking Algorithm for the App Event passed as parameter.' category='AppEvent')
    public static void runMatchmakingAlgorithm(List<String> ids) {
        Database.executeBatch(new EAP_BATCH_MatchmakingAlgorithm(ids[0]), 100);
    }

    /**
    * @description Init the maps with the Meeting Availabity for each Attendee needed for the Matchmaking
    * 
    * @param listInvestor  Id List of Inverstor
    * @param listCorporates Id List of Coorporates
    **/
    private void getAttendanceMeetingAvailability(Set<Id> listInvestor,Set<Id> listCorporates){

        List<EAP_MeetingAvailability__c> listAvailabilityInvestors = SEL_EAP_MeetingAvailability.newInstance().selectByAttendee(new Set<Id>(listInvestor));
        List<EAP_MeetingAvailability__c> listAvailabilityCorporates =  SEL_EAP_MeetingAvailability.newInstance().selectByAttendee(new Set<Id>(listCorporates));

        for (EAP_MeetingAvailability__c mAv : listAvailabilityInvestors) {
            DateTime startTime = mAv.EAP_StartDate__c;
            EAP_MeetingAvailability__c av = mAv;
            Id att = mAv.EAP_Attendee__c;
            Map<DateTime, EAP_MeetingAvailability__c> mapT = new Map<DateTime, EAP_MeetingAvailability__c>();

            if (mapInvestors.containsKey(att)) {
                mapT = mapInvestors.get(att);
            }
            if(!mapT.containsKey(startTime)){
                mapT.put(startTime, av);
                mapInvestors.put(att, mapT);
            }
        }

        for (EAP_MeetingAvailability__c mAv : listAvailabilityCorporates) {
            DateTime startTime = mAv.EAP_StartDate__c;
            EAP_MeetingAvailability__c av = mAv;
            Id att = mAv.EAP_Attendee__c;
            Map<DateTime, EAP_MeetingAvailability__c> mapT = new Map<DateTime, EAP_MeetingAvailability__c>();

            if (mapCorporates.containsKey(att)) {
                mapT = mapCorporates.get(att);
            }
            if(!mapT.containsKey(startTime)){
                mapT.put(startTime, av);
                mapCorporates.put(att, mapT);
            }
        }
    }

    /**
    * @description Init mapCorpWithAssociated
    * 
    * @param listCorporates 
    **/
    private void getAssociatedCorporates(Set<Id> listCorporates) {
        List<EAP_Attendee__c> associatedCorporates = SEL_EAP_Attendee.newInstance().selectByAssociatedCorporate(listCorporates);

        for (EAP_Attendee__c att : associatedCorporates) {
            if (mapCorpWithAssociated.get(att.EAP_CorporateAssociated__c) != null) {
                mapCorpWithAssociated.get(att.EAP_CorporateAssociated__c).add(att);
            
            } else {
                mapCorpWithAssociated.put(att.EAP_CorporateAssociated__c, new List<EAP_Attendee__c>{att});
            }
        }
    }


    /**
    * @description Return a new meetting with required fields values
    *
    * @param startEventMeetingTime Date and time the meeting start
    * @param eventInfo EAP_AppEvent__c event info 
    * @param tierLevel String meeting tier level
    * @param coorporateId String Id coorporate
    * @return EAP_Meeting__c 
    **/
    private EAP_Meeting__c createMeeting(Datetime startEventMeetingTime,EAP_AppEvent__c eventInfo,String tierLevel,String coorporateId){
        EAP_Meeting__c meeting = new EAP_Meeting__c();
        meeting.EAP_AppEvent__c = this.eventId;
        meeting.EAP_StartDate__c = startEventMeetingTime;
        meeting.EAP_EndDate__c = startEventMeetingTime.addMinutes(Integer.valueOf(eventInfo.EAP_MeetingDuration__c));
        meeting.EAP_Format__c = 'Onsite';
        meeting.EAP_Status__c = 'Active';
        meeting.EAP_CorporateID__c = coorporateId;

        switch on  tierLevel{
            when  '1'{
                this.numGoldMeetings += 1;
                meeting.Name = 'Meeting Gold '+this.numGoldMeetings;
            }
            when  '2'{
                this.numSilverMeetings += 1;
                meeting.Name = 'Meeting Silver '+this.numSilverMeetings;
            }
            when  '3'{
                this.numBronzeMeetings += 1;
                meeting.Name = 'Meeting Bronze '+this.numBronzeMeetings;
            }
        }

        return meeting;
    }

    /**
    * @description Return a new Attendace with required fields values
    *
    * @param attParent parent Attendace info
    * @return EAP_Attendance__c 
    **/
    private EAP_Attendance__c createAttendance(EAP_Attendance__c attParent){
        EAP_Attendance__c attTarget = new EAP_Attendance__c();
        attTarget.Name = attParent.EAP_TargetAttendee__r.Name;
        attTarget.EAP_Attendee__c = attParent.EAP_TargetAttendee__c;
        attTarget.Created_From_Batch__c = true;

        return attTarget;
    }

    /**
    * @description Return a new Attendace with required fields values
    *
    * @param attParent parent Attendace info
    * @param corpAssociated corporate Associated info
    * @return EAP_Attendance__c 
    **/
    private EAP_Attendance__c createAttendance(EAP_Attendance__c attParent, EAP_Attendee__c corpAssociated){
        EAP_Attendance__c attAssociated = new EAP_Attendance__c();
        attAssociated.Name = corpAssociated.Name;
        attAssociated.EAP_Attendee__c = corpAssociated.Id;
        attAssociated.Created_From_Batch__c = true;

        return attAssociated;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    public class AttendeesMeeting_Wrapper{
        @AuraEnabled 
        public String tierLevelMeeting; 
        @AuraEnabled
        public Integer numGoldAttendees;
        @AuraEnabled
        public Integer numSilverAttendees;
        @AuraEnabled
        public Integer numBronzeAttendees;

        @AuraEnabled
        public EAP_Meeting__c meeting;

        /**
        * @description 
        * @author TCK | 06-14-2022 
        * @param meeting
        * @param tierLevel
        **/
        public AttendeesMeeting_Wrapper(EAP_Meeting__c meeting,String tierLevel){
            this.meeting = meeting;
            this.tierLevelMeeting = tierLevel;
            switch on  tierLevel{
                when  '1'{
                    this.numGoldAttendees = 1;
                }
                when  '2'{
                    this.numSilverAttendees = 1;
                }
                when  '3'{
                    this.numBronzeAttendees = 1;
                }
            }
        }
    }
}