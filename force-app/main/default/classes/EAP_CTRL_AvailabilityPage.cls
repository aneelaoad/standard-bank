/**
 * Retrieving data used in the availability detail page
 * <br/>SFP-7976
 *
 * @author The Cocktail
 * @date October 2021
 * @description Retrieving data used in the availability detail page
**/
public without sharing class EAP_CTRL_AvailabilityPage {
    /**
    * @description Function to insert EAP_MeetingAvailability__c and EAP_Attendance__c
    * @author TCK | 11-10-2021 
    * @param eventId 
    * @param meetingAvailability 
    * @param corporatesToMeet 
    **/
    @AuraEnabled
    public static void saveAvailability(String eventId, String meetingAvailability, String corporatesToMeet){
        EAP_AppEvent__c thisEvent = SEL_EAP_AppEvent.newInstance().selectByIdWithMeetingInfo(eventId);
        User eventUserModifier = SEL_Users.newInstance().selectWithContactSyncFieldById(thisEvent.LastModifiedById);
        TimeZone eventUserModifierTimeZone = TimeZone.getTimezone(eventUserModifier.TimeZoneSidKey);
        Integer offsetEvent = eventUserModifierTimeZone.getOffset(thisEvent.EAP_StartMeetingTime__c)/(1000*60*60);
        Integer noon = 12 - offsetEvent;

        User user = SEL_Users.newInstance().selectWithContactSyncFieldById(UserInfo.getUserId());
        List<EAP_Attendee__c> thisAttendee = SEL_EAP_Attendee.newInstance().selectByEventIdAndContactSync(thisEvent.Id, user.Contact_Sync_ID__c);
        
        List<String> availabilityList = meetingAvailability.substring(1, meetingAvailability.length()-1).split('},');
        List<EAP_MeetingAvailability__c> maList = new List<EAP_MeetingAvailability__c>(); //maList stands for Meeting Availability List
        List<String> corporatesList = corporatesToMeet.substring(1, corporatesToMeet.length()-1).split('},');
        List<EAP_Attendance__c> caList = new List<EAP_Attendance__c>(); //caList stands for Corporates Attendance List


        if (availabilityList.get(0) != '') {
            Integer slotNumber = 1;
            for (String avItem : availabilityList) {
                MeetingAvailabilityWrapper maWrapperItem = (MeetingAvailabilityWrapper)JSON.deserialize((avItem+'}'), MeetingAvailabilityWrapper.class);
                Datetime maOriginalDate = Datetime.newInstance(long.valueOf(maWrapperItem.dateToInsert));
                Datetime maStartDate = maOriginalDate.addHours(-maOriginalDate.hourGMT()); //Get date with time 00:00
                Datetime maEndDate = maOriginalDate.addHours(-maOriginalDate.hourGMT());
                Datetime endMATime = maOriginalDate.addHours(-maOriginalDate.hourGMT());
                String maName = '';
    
                if (maWrapperItem.availability == 'allDay') {
                    maStartDate = maStartDate.addHours(thisEvent.EAP_StartMeetingTime__c.hourGMT());
                    endMATime = endMATime.addHours(thisEvent.EAP_EndMeetingTime__c.hourGMT());
                
                } else if (maWrapperItem.availability == 'morning') {
                    maStartDate = maStartDate.addHours(thisEvent.EAP_StartMeetingTime__c.hourGMT());
                    endMATime = endMATime.addHours(noon);

                } else if (maWrapperItem.availability == 'afternoon') {
                    maStartDate = maStartDate.addHours(noon);
                    endMATime = endMATime.addHours(thisEvent.EAP_EndMeetingTime__c.hourGMT());
                    
                }

                maEndDate = maStartDate.addMinutes(Integer.valueOf(thisEvent.EAP_MeetingDuration__c));
    
                do {
                    maName = 'Slot ' + slotNumber;
                    EAP_MeetingAvailability__c ma = new EAP_MeetingAvailability__c(EAP_Attendee__c = thisAttendee[0].Id,
                                                                                    EAP_EndDate__c = maEndDate,
                                                                                    EAP_StartDate__c = maStartDate, 
                                                                                    Name = maName);
                    maList.add(ma);
                    maStartDate = maEndDate.addMinutes(Integer.valueOf(thisEvent.EAP_BreakBetweenMeetings__c));
                    maEndDate = maStartDate.addMinutes(Integer.valueOf(thisEvent.EAP_MeetingDuration__c));
                    slotNumber++;
                } while (maStartDate.hourGMT() < endMATime.hourGMT());
            }
        }
        

        if (corporatesList.get(0) != '') {
            String attendanceName = '';
            for (String corp : corporatesList) {
                CorporatesWrapper corpWrapperItem = (CorporatesWrapper)JSON.deserialize((corp+'}'), CorporatesWrapper.class);
                attendanceName = thisAttendee[0].Name + ' + ' + corpWrapperItem.name;
                EAP_Attendance__c attendanceToInsert = new EAP_Attendance__c(EAP_Attendee__c = thisAttendee[0].Id,
                                                                            EAP_RequestFrom__c = thisAttendee[0].Id,
                                                                            EAP_TargetAttendee__c = corpWrapperItem.id,
                                                                            Name = attendanceName,
                                                                            EAP_PreferenceSelection__c = corpWrapperItem.preference);
                caList.add(attendanceToInsert);
            }
        }

        //Delete all Availability
        Set<Id> attIds = new Set<Id>();
        attIds.add(thisAttendee[0].Id);
        List<EAP_MeetingAvailability__c> maToDelete = SEL_EAP_MeetingAvailability.newInstance().selectByAttendee(attIds);
        delete maToDelete;

        //Delete all attendance
        List<EAP_Attendance__c> caToDelete = SEL_EAP_Attendance.newInstance().selectCorporatesByAttendee(thisAttendee);
        delete caToDelete;

        //Insert new Availability and Attendance
        insert maList;
        insert caList;

        //Update FormCompleted from attendee
        thisAttendee[0].EAP_FormCompleted__c = true;
        update thisAttendee;
    }

    /**
    * @description Function to get selected EAP_MeetingAvailability__c and EAP_Attendance__c
    * @author TCK | 11-10-2021 
    * @param eventId 
    * @return Map<Datetime, AvailabilityWrapper> 
    **/
    @AuraEnabled
    public static Map<Datetime, AvailabilityWrapper> getAvailability(String eventId){
        EAP_AppEvent__c thisEvent = SEL_EAP_AppEvent.newInstance().selectByIdWithMeetingInfo(eventId);
        User eventUserModifier = SEL_Users.newInstance().selectWithContactSyncFieldById(thisEvent.LastModifiedById);
        TimeZone eventUserModifierTimeZone = TimeZone.getTimezone(eventUserModifier.TimeZoneSidKey);
        Integer offsetEvent = eventUserModifierTimeZone.getOffset(thisEvent.EAP_StartMeetingTime__c)/(1000*60*60);
        Integer offset = UserInfo.getTimezone().getOffset(thisEvent.EAP_StartMeetingTime__c) / (1000*60*60);

        User user = SEL_Users.newInstance().selectWithContactSyncFieldById(UserInfo.getUserId());
        List<EAP_Attendee__c> att = SEL_EAP_Attendee.newInstance().selectByEventIdAndContactSync(thisEvent.Id, user.Contact_Sync_ID__c);
        Set<Id> attIds = new Set<Id>();
        attIds.add(att[0].Id);

        List<EAP_MeetingAvailability__c> availabilityList = SEL_EAP_MeetingAvailability.newInstance().selectByAttendee(attIds);
        Map<Datetime, AvailabilityWrapper> result = new Map<Datetime, AvailabilityWrapper>();
        Integer noon = 12 - offsetEvent + offset;

        for (EAP_MeetingAvailability__c ma : availabilityList) {
            Datetime startDate = ma.EAP_StartDate__c.date();
            Integer startTime = ma.EAP_StartDate__c.hour();
            AvailabilityWrapper aw = new AvailabilityWrapper();

            if (result.get(startDate) != null) {
                aw = result.get(startDate);
            }

            if (!aw.onMorning) {
                aw.onMorning = (startTime < noon) ? true : false;
            }

            if (!aw.onAfternoon) {
                aw.onAfternoon = (startTime < noon) ? false : true;
            }

            aw.timeMorningStart = thisEvent.EAP_StartMeetingTime__c.hourGMT() + offset;
            aw.timeNoon = noon;
            aw.timeAfternoonEnd = thisEvent.EAP_EndMeetingTime__c.hourGMT() + offset;
            result.put(startDate, aw);
        }

        if (result.size() == 0) {
            AvailabilityWrapper aw = new AvailabilityWrapper();
            aw.timeMorningStart = thisEvent.EAP_StartMeetingTime__c.hourGMT() + offset;
            aw.timeNoon = noon;
            aw.timeAfternoonEnd = thisEvent.EAP_EndMeetingTime__c.hourGMT() + offset;
            result.put(null, aw);
        }

        return result;
    }

    /**
    * @description Function to get if the matchmaking was executed
    * @author TCK | 11-10-2021 
    * @param eventId 
    * @return Boolean 
    **/
    @AuraEnabled(cacheable=true)
    public static Boolean getMatchmakingExecuted(String eventId){
        EAP_AppEvent__c thisEvent = SEL_EAP_AppEvent.newInstance().selectById(eventId);
        return thisEvent.EAP_MatchmakingExecuted__c;
    }

    /**
    * @description Function to get the role of the current attendee in the event
    * @author TCK | 11-10-2021 
    * @param eventId 
    * @return role 
    **/
    @AuraEnabled(cacheable=true)
    public static String getRoleEvent(String eventId){
        Id eventIdT = Id.valueOf(eventId);
        User user = SEL_Users.newInstance().selectWithContactSyncFieldById(UserInfo.getUserId());
        List<EAP_Attendee__c> att = SEL_EAP_Attendee.newInstance().selectByEventIdAndContactSync(eventIdT, user.Contact_Sync_ID__c);
        String role = att.get(0).EAP_RoleEvent__c;

        return role;
    }

    /**
    * @description Function to get the available corporates
    * @author TCK | 11-10-2021 
    * @param eventId 
    * @return cwList 
    **/
    @AuraEnabled(cacheable=true)
    public static List<CorporatesWrapper> getCorporates(String eventId){
        Id eventIdT = Id.valueOf(eventId);
        User user = SEL_Users.newInstance().selectWithContactSyncFieldById(UserInfo.getUserId());
        List<EAP_Attendee__c> thisAttendee = SEL_EAP_Attendee.newInstance().selectByEventIdAndContactSync(eventIdT, user.Contact_Sync_ID__c);
        List<EAP_Attendance__c> selectedAttendance = SEL_EAP_Attendance.newInstance().selectCorporatesByAttendee(thisAttendee);
        List<EAP_Attendee__c> corporatesList = SEL_EAP_Attendee.newInstance().selectCorporatesByEventId(eventIdT);

        Map<Id, Integer> selectedCorporates = new Map<Id, Integer>();
        for (EAP_Attendance__c attendance : selectedAttendance){
            selectedCorporates.put(attendance.EAP_TargetAttendee__c, Integer.valueOf(attendance.EAP_PreferenceSelection__c));
        }

        Set<Id> contactsIdList = new Set<Id>();
        for (EAP_Attendee__c attendee : corporatesList){
            contactsIdList.add(attendee.EAP_Contact__c);
        }
        Map<ID, Contact> contactsList = new Map<ID, Contact>(SEL_Contacts.newInstance().selectById(contactsIdList));
        
        List<User> userInfoList = SEL_Users.newInstance().selectByContactSyncId(contactsIdList);
        Map<String,String> mapContactPhoto = new Map<String,String>();
        for(User us : userInfoList){
            if(us.Contact_Sync_ID__c != null){
                mapContactPhoto.put(us.Contact_Sync_ID__c, us.SmallPhotoUrl);
            }
        }

        Set<Id> clientsIdList = new Set<Id>();
        for (ID idContact : contactsList.keyset()){
            clientsIdList.add(contactsList.get(idContact).AccountId);
        }
        Map<ID, Account> clientList = new Map<ID, Account>(SEL_Accounts.newInstance().selectById(clientsIdList));
        
        List<CorporatesWrapper> cwList = new List<CorporatesWrapper>();
        for (EAP_Attendee__c attendee : corporatesList){
            Contact contact = contactsList.get(attendee.EAP_Contact__c);
            String contactPhoto = mapContactPhoto.get(attendee.EAP_Contact__c);
            Account client = clientList.get(contact.AccountId);

            CorporatesWrapper cw;
            if (selectedCorporates.containsKey(attendee.Id)) {
                cw = new CorporatesWrapper(attendee, contact, client);
                cw.contactPhoto = contactPhoto;
                cw.isSelected = true;
                cw.preference = selectedCorporates.get(attendee.Id);
            
            } else {
                cw = new CorporatesWrapper(attendee, contact, client);
                cw.contactPhoto = contactPhoto;
                cw.isSelected = false;
            }
            cwList.add(cw);

        }

        return cwList;
    }
    /**
     * @author TCK
     * @description Availability Wrapper class
     */    
    public class AvailabilityWrapper{
        @AuraEnabled
        public Boolean onMorning = false;
        @AuraEnabled
        public Boolean onAfternoon = false;

        @AuraEnabled
        public Integer timeMorningStart;
        @AuraEnabled
        public Integer timeNoon;
        @AuraEnabled
        public Integer timeAfternoonEnd;
    }
    /**
     * @author TCK
     * @description Meeting availability Wrapper class
     */ 
    public class MeetingAvailabilityWrapper{
        @AuraEnabled
        public String dateToInsert;
        @AuraEnabled
        public String availability;
    }
    /**
     * @author TCK
     * @description Coporates Wrapper class
     */ 
    public class CorporatesWrapper{
        @AuraEnabled
        /**
         * @author TCK
         * @description id setter y getter
         */         
        public Id id {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description name setter y getter
         */
        public String name {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description clientName setter y getter
         */
        public String clientName {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description contactPhoto setter y getter
         */
        public String contactPhoto {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description isSelected setter y getter
         */
        public Boolean isSelected {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description preference setter y getter
         */
        public Integer preference {get;set;}

        /**
         * @author TCK
         * @description Corporates Wrapper method
         * @param attendee
         * @param contact
         * @param client
         */ 
        public CorporatesWrapper(EAP_Attendee__c attendee, Contact contact, Account client){
            this.id = attendee.Id;
            this.name = contact.Name;
            this.clientName = client.Name;
        }
    }
}