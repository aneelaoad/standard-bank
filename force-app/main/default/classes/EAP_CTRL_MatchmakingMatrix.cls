/**
 * Logic used in the Matchmaking matrix
 * SFP-10310
 *
 * @author The Cocktail
 * @date November 2021
 * @description Matchmaking matrix logic
 */
public without sharing class EAP_CTRL_MatchmakingMatrix {

    /**
    * @description Return all the relevant information of the meeting
    *
    * @author TCK | 06-14-2022 
    * @param eventId 
    * @return EAP_Meeting__c 
    **/
    @AuraEnabled
    public static Boolean hasMatchmakingRan(String eventId){

        if(eventId != null && eventId != '') {
            EAP_AppEvent__c event = SEL_EAP_AppEvent.newInstance().selectById(eventId);
            return event.EAP_MatchmakingExecuted__c;
        }

        return false;
    }
    
    /**
    * @description Return all the relevant information of the meeting
    *
    * @author TCK | 06-14-2022 
    * @param eventId 
    * @return EAP_Meeting__c 
    **/
    @AuraEnabled
    public static List<Matrix_Wrapper> getMatrixData(String eventId){
        List<Matrix_Wrapper> matrixWrList = new List<Matrix_Wrapper>();

        if(eventId != null && eventId != '')
        {
            //User timezone
            Integer offset = UserInfo.getTimezone().getOffset(Datetime.now())/(1000*60*60);
            
            //Event Data
            List<EAP_AppEvent__c> eventList = SEL_EAP_AppEvent.newInstance().selectByIdWithCoorporates(eventId);
            EAP_AppEvent__c event = eventList.get(0);
            
            List<Campaign> campaignList = SEL_Campaign.newInstance().selectById(event.EAP_Campaign__c);
            Campaign campaign = campaignList.get(0);

            List<Datetime> listSlots = new List<Datetime>();

            DateTime slotStart = DateTime.newInstance(campaign.EAP_Event_Start_Date__c, event.EAP_Start_Meetings_Time__c);
            DateTime eventEnd = DateTime.newInstance(campaign.EAP_Event_End_Date__c, event.EAP_End_Meetings_Time__c);

            //Slots Time Data 
            do{
                listSlots.add(slotStart);
                slotStart = slotStart.addMinutes(Integer.valueOf(event.EAP_MeetingDuration__c));
                if(event.EAP_BreakBetweenMeetings__c != null){
                    slotStart = slotStart.addMinutes(Integer.valueOf(event.EAP_BreakBetweenMeetings__c));
                }

                if(slotStart.time() > event.EAP_End_Meetings_Time__c){
                    slotStart = DateTime.newInstance(slotStart.date().addDays(1), event.EAP_Start_Meetings_Time__c);
                }

            }while(slotStart <= eventEnd);

            //Coorporate Availability
            Set<Id> idsAttendes = new Set<Id>();
            for(EAP_Attendee__c att:event.EAP_Attendee_Event__r){
                idsAttendes.add(att.Id);
            }
            List<EAP_MeetingAvailability__c> meetingAvailabilityList = SEL_EAP_MeetingAvailability.newInstance().selectByAttendee(idsAttendes);


            Map<String,Map<Datetime,Boolean>> mapCoorMeetingAvailabily = new Map<String,Map<Datetime,Boolean>>();
            for(EAP_MeetingAvailability__c ma:meetingAvailabilityList){
                if(mapCoorMeetingAvailabily.get(ma.EAP_Attendee__c) != null){
                    Map<Datetime,Boolean> mapDatetimeMeetingAvai = mapCoorMeetingAvailabily.get(ma.EAP_Attendee__c);
                    mapDatetimeMeetingAvai.put(ma.EAP_StartDate__c,ma.EAP_Booked__c);
                    mapCoorMeetingAvailabily.put(ma.EAP_Attendee__c,mapDatetimeMeetingAvai);
                }else{
                    Map<Datetime,Boolean> mapDatetimeMeetingAvai = new Map<Datetime,Boolean>();
                    mapDatetimeMeetingAvai.put(ma.EAP_StartDate__c,ma.EAP_Booked__c);
                    mapCoorMeetingAvailabily.put(ma.EAP_Attendee__c,mapDatetimeMeetingAvai);
                }
            }

            //Coorporate Meetings       
            List<EAP_Meeting__c> meetingList = SEL_EAP_Meeting.newInstance().selectMeetingsCorporateByEvent(eventId);

            Map<String,Map<Datetime,Meeting_Wrapper>> mapCoorMeeting = new Map<String,Map<Datetime,Meeting_Wrapper>>();
            for(EAP_Meeting__c metting:meetingList)
            {
                if(mapCoorMeeting.get(metting.EAP_CorporateID__c) != null)
                {
                    Map<Datetime,Meeting_Wrapper> mapDatetimeMeeting = mapCoorMeeting.get(metting.EAP_CorporateID__c);

                    Meeting_Wrapper mwr = new Meeting_Wrapper(metting,metting.EAP_Attendance_Meeting__r);

                    mapDatetimeMeeting.put(metting.EAP_StartDate__c,mwr);
                    mapCoorMeeting.put(metting.EAP_CorporateID__c,mapDatetimeMeeting);
                }else
                {
                    Map<Datetime,Meeting_Wrapper> mapDatetimeMeeting = new Map<Datetime,Meeting_Wrapper>();

                    Meeting_Wrapper mwr = new Meeting_Wrapper(metting,metting.EAP_Attendance_Meeting__r);

                    mapDatetimeMeeting.put(metting.EAP_StartDate__c,mwr);
                    mapCoorMeeting.put(metting.EAP_CorporateID__c,mapDatetimeMeeting);
                }
            }

            //Attendance no meeting
            List<EAP_Attendance__c> attNoMeetingList = SEL_EAP_Attendance.newInstance().selectByEventNoMeeting(eventId);

            Map<Id,List<EAP_Attendance__c>> mapCoorpListAtt = new Map<Id,List<EAP_Attendance__c>>();
            for(EAP_Attendance__c att:attNoMeetingList){
                if(mapCoorpListAtt.get(att.EAP_TargetAttendee__c) != null)
                {
                    List<EAP_Attendance__c> attList = mapCoorpListAtt.get(att.EAP_TargetAttendee__c);
                    attList.add(att);
                    mapCoorpListAtt.put(att.EAP_TargetAttendee__c,attList);
                }else{
                    List<EAP_Attendance__c> attList = new List<EAP_Attendance__c>();
                    attList.add(att);
                    mapCoorpListAtt.put(att.EAP_TargetAttendee__c,attList);
                }
            }

            for(EAP_Attendee__c att: event.EAP_Attendee_Event__r){
                Map<Datetime,Boolean> mapDatetimeMeetingAvai = mapCoorMeetingAvailabily.get(att.Id);
                Map<Datetime,Meeting_Wrapper> mapDatetimeMeeting = mapCoorMeeting.get(att.Id);

                Matrix_Wrapper mr = new Matrix_Wrapper(att);
                
                Integer numDay = 1;
                Integer numSlot = 1;
                Integer actualDay = listSlots.get(0).day();
                for(Datetime slot:listSlots){
                    if(actualDay < slot.day()){
                        numDay++;
                        actualDay = slot.day();
                    }
                    Slot_Wrapper sWr = new Slot_Wrapper(slot.addHours(offset),slot.addMinutes(Integer.valueOf(event.EAP_MeetingDuration__c)).addHours(offset));
                    sWr.numDay = numDay;
                    sWr.numSlot = numSlot;
                    numSlot++;

                    //Tiene disponibilidad en hueco
                    if(mapDatetimeMeetingAvai != null && mapDatetimeMeetingAvai.get(slot) != null){
                        sWr.available = true;
                        //Tiene Meeting programado
                        if(mapDatetimeMeeting != null && mapDatetimeMeeting.get(slot) != null){
                            sWr.meeting = mapDatetimeMeeting.get(slot);
                        }
                    }
                    if(mapDatetimeMeeting != null && mapDatetimeMeeting.get(slot) != null){
                        sWr.meeting = mapDatetimeMeeting.get(slot);
                    }
                    mr.addSlot(sWr);
                }

                //Add Attendance no meeting
                if(mapCoorpListAtt.get(att.Id) != null)
                {
                    mr.listInvestorNoMeeting = mapCoorpListAtt.get(att.Id);
                }
                matrixWrList.add(mr);
            }
        }
        return matrixWrList;
    }

    /**
    * @description Delete investor from Meeting
    *
    * @author TCK | 06-14-2022 
    * @param attendeeId 
    * @param meetingId 
    **/
    @AuraEnabled
    public static void deleteAttendance(Id attendeeId, Id meetingId){
        Set<id> setAttendeeId = new Set<Id>();
        setAttendeeId.add(attendeeId);
        EAP_Attendance__c attendanceToDelete = SEL_EAP_Attendance.newInstance().selectByAttendeeAndMeeting(setAttendeeId, meetingId).get(0);
        List<EAP_Attendance__c> attendance = SEL_EAP_Attendance.newInstance().selectByMeetingId(meetingId);

        Set<id> setMeetingId = new Set<Id>();
        setMeetingId.add(meetingId);
        EAP_Meeting__c meeting = SEL_EAP_Meeting.newInstance().selectById(setMeetingId).get(0);

        if (attendance.size() > 2) {
            List<EAP_MeetingAvailability__c> availabilityToUpdate = SEL_EAP_MeetingAvailability.newInstance().selectByAttendeeAndStartDate(setAttendeeId, meeting.EAP_StartDate__c);
            if (availabilityToUpdate.size() > 0) {
                availabilityToUpdate.get(0).EAP_Booked__c = false;
                try{
                    update availabilityToUpdate;
                } catch(DMLException ex) {
                    ApexPages.addMessages(ex);
                }
            }

        } else {
            Integer indexOfInvestor = 0;
            setAttendeeId.clear();
            for (EAP_Attendance__c att :  attendance) {
                setAttendeeId.add(att.EAP_Attendee__c);

                if (att.EAP_Attendee__c == attendeeId) {
                    indexOfInvestor = attendance.indexOf(att);
                }
            }
            attendance.remove(indexOfInvestor);
            List<EAP_MeetingAvailability__c> availabilityToUpdate = SEL_EAP_MeetingAvailability.newInstance().selectByAttendeeAndStartDate(setAttendeeId, meeting.EAP_StartDate__c);
            
            for (EAP_MeetingAvailability__c av :  availabilityToUpdate) {
                av.EAP_Booked__c = false;
            }

            try{
                update availabilityToUpdate;
                delete attendance;
                delete meeting;
            } catch(DMLException ex) {
                ApexPages.addMessages(ex);
            }
        }

        try{
            if (attendanceToDelete.EAP_TargetAttendee__c != null) {
                attendanceToDelete.EAP_Meeting__c = null;
                update attendanceToDelete;
    
            } else {
                delete attendanceToDelete;
            }
        } catch(DMLException ex) {
            ApexPages.addMessages(ex);
        }
    }

    /**
    * @description Set all event meetings status to Active
    *
    * @author TCK | 06-14-2022 
    * @param eventId 
    **/
    @AuraEnabled
    public static void publishMeetings(String eventId) {
        List<EAP_Meeting__c> eventMeetings = SEL_EAP_Meeting.newInstance().selectByEventId(eventId);
        for (EAP_Meeting__c meeting : eventMeetings) {
            meeting.EAP_VisibleOnMobileApp__c = true;
        }

        try{
            update eventMeetings;
        } catch(DMLException ex) {
            ApexPages.addMessages(ex);
        }
    }

    /**
    * @description Set all event meetings from a selected corporate to Active
    *
    * @author TCK | 06-14-2022 
    * @param eventId 
    * @param corporateIds
    * @param meetingIds
    **/
    @AuraEnabled
    public static void publishCorporateMeetings(String eventId, List<Id> corporateIds, List<Id> meetingIds) {
        List<EAP_Meeting__c> eventMeetings = new List<EAP_Meeting__c>();
        if (corporateIds.size() > 0) {
            List<EAP_Meeting__c> tempList = [SELECT Id, EAP_VisibleOnMobileApp__c FROM EAP_Meeting__c WHERE EAP_CorporateID__c = :corporateIds];
            eventMeetings.addAll(tempList);
        }
        if (meetingIds.size() > 0) {
            List<EAP_Meeting__c> tempList2 = [SELECT EAP_VisibleOnMobileApp__c FROM EAP_Meeting__c WHERE Id = :meetingIds];
            eventMeetings.addAll(tempList2);
        }
        for (EAP_Meeting__c meeting : eventMeetings) {
            meeting.EAP_VisibleOnMobileApp__c = true;
        }

        try{
            update eventMeetings;
        } catch(DMLException ex) {
            ApexPages.addMessages(ex);
        }
    }

    /**
    * @description Get event investors
    *
    * @author TCK | 06-14-2022 
    * @param eventId 
    * @return List<EAP_Attendee__c> 
    **/
    @AuraEnabled
    public static List<Attendee_Wrapper> getInvestors(String eventId){
        List<EAP_Attendee__c> investors = SEL_EAP_Attendee.newInstance().selectInvestorsByEventId(eventId);
        Set<Id> invContactId = new Set<Id>();
        for (EAP_Attendee__c inv : investors) {
            invContactId.add(inv.EAP_Contact__c);
        }
        List<Relationship_Manager__c> rlsmList = [SELECT Id, EAP_User__r.Name, EAP_Contact__r.Id FROM Relationship_Manager__c WHERE EAP_Contact__r.Id IN :invContactId];
        //SEL_Relationship_Manager.newInstance().selectByContactId(invContactId);
        Map<Id, String> rlsmUserName = new Map<Id, String>();
        for (Relationship_Manager__c rlsm: rlsmList) {
            rlsmUserName.put(rlsm.EAP_Contact__r.Id, rlsm.EAP_User__r.Name);
        }

        List<Attendee_Wrapper> invWr = new List<Attendee_Wrapper>();
        for (EAP_Attendee__c inv : investors) {
            Attendee_Wrapper wr = new Attendee_Wrapper(inv, rlsmUserName.get(Id.valueOf(inv.EAP_Contact__c)));
            invWr.add(wr);
        }

        return invWr;
    }

    /**
     * @author TCK
     * @description MatrixWrapper class
     */ 
    public class Matrix_Wrapper {
        @AuraEnabled
        /**
         * @author TCK
         * @description getter and setter
         */
        public EAP_Attendee__c coorporate {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description getter and setter
         */
        public List<Slot_Wrapper> listSlots {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description getter and setter
         */
        public List<EAP_Attendance__c> listInvestorNoMeeting {get;set;}

        /**
        * @description 
        * @author TCK | 06-14-2022 
        * @param coorporate
        **/
        public Matrix_Wrapper(EAP_Attendee__c coorporate){
            this.coorporate = coorporate;
            this.listSlots = new List<Slot_Wrapper>();
        }

        /**
        * @description 
        * @author TCK | 06-14-2022 
        * @param slotWr
        **/
        public void addSlot(Slot_Wrapper slotWr){
            this.listSlots.add(slotWr);
        }
    }

    /**
     * @author TCK
     * @description SlotWrapper class
     */ 
    public class Slot_Wrapper {
        @AuraEnabled
        /**
         * @author TCK
         * @description getter and setter
         */
        public Datetime startDate {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description getter and setter
         */
        public Datetime endDate {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description getter and setter
         */
        public Datetime name {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description getter and setter
         */
        public Boolean available {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description getter and setter
         */
        public Meeting_Wrapper meeting {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description getter and setter
         */
        public Integer numDay {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description getter and setter
         */
        public Integer numSlot {get;set;}

        /**
         * @author TCK
         * @description SlotWrapper method
         * @param startDate
         * @param endDate
         */ 
        public Slot_Wrapper(Datetime startDate, Datetime endDate){
            this.startDate = startDate;
            this.endDate = endDate;
            this.available = false;
        }
    }

    /**
     * @author TCK
     * @description MeetingWrapper class
     */ 
    public class Meeting_Wrapper {
        @AuraEnabled
        /**
         * @author TCK
         * @description meeting getter and setter
         */ 
        public EAP_Meeting__c meeting {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description listInvestor getter and setter
         */ 
        public List<EAP_Attendance__c> listInvestor {get;set;}

        /**
        * @description 
        * @author TCK | 06-14-2022 
        * @param meeting 
        * @param listInvestor 
        **/
        public Meeting_Wrapper(EAP_Meeting__c meeting, List<EAP_Attendance__c> listInvestor){
            this.meeting = meeting;
            this.listInvestor = listInvestor;
        }
    }


    /**
     * @author TCK
     * @description NewMeetingWrapper class
     */     
    public class New_Meeting_Wrapper {
        @AuraEnabled
        public List<String> investorsId;
        @AuraEnabled
        public String corporateId;
        @AuraEnabled
        public Long startMeeting;
        @AuraEnabled
        public Long endMeeting;
    }

    /**
     * @author TCK
     * @description AttendeeWrapper class
     */ 
    public class Attendee_Wrapper {
        @AuraEnabled
        public EAP_Attendee__c investor;
        @AuraEnabled
        public String relationshipManager;

        /**
        * @description 
        * @author TCK | 06-14-2022 
        * @param investor 
        * @param relationshipManager 
        **/
        public Attendee_Wrapper(EAP_Attendee__c investor, String relationshipManager){
            this.investor = investor;
            this.relationshipManager = relationshipManager;
        }
    }

    /**
     * @author TCK
     * @description ResponseAvailabilityWrapper class
     */     
    public class ResponseAvailabilityWr{
        @AuraEnabled
        public List<IndividualMeet_Wr> investorsMatch;
        @AuraEnabled
        public IndividualMeet_Wr coorporateMatch;
        @AuraEnabled
        /**
         * @author TCK
         * @description getter and setter
         */
        public Boolean allAvailable {get;set;}
    }

    /**
     * @author TCK
     * @description IndividualMeetWrapper class
     */     
    public class IndividualMeet_Wr{
        @AuraEnabled 
        /**
         * @author TCK
         * @description getter and setter
         */  
        public String attId {get;set;}
        @AuraEnabled 
        /**
         * @author TCK
         * @description getter and setter
         */  
        public String name {get;set;}
        @AuraEnabled 
        /**
         * @author TCK
         * @description getter and setter
         */  
        public Boolean available {get;set;}
        @AuraEnabled 
        /**
         * @author TCK
         * @description getter and setter
         */  
        public String meeting {get;set;}
    }
}