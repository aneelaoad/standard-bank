/**
 * Logic used in the Matchmaking matrix
 * <br/>SFP-10310
 *
 * @author The Cocktail
 * @date November 2021
 * @description Matrix logic
 */
public without sharing class EAP_CTRL_MatrixLogic {

    /**
    * @description Search attendees availability
    * <br/>US-XXXX
    *
    * @author TCK
    * @param searchParam
    * @return res
    * 
    **/
    @AuraEnabled
    public static ResponseAvailabilityWr searchAvailabilityNotice(String searchParam){

        Integer offset = UserInfo.getTimezone().getOffset(Datetime.now())/(1000*60*60);
        MatrixActionsParameterWr paramsWr = (MatrixActionsParameterWr)JSON.deserialize(searchParam, MatrixActionsParameterWr.class);
        
        Datetime startDate = Datetime.valueOfGMT(paramsWr.startDate).addHours(-offset);
        Datetime endDate = Datetime.valueOfGMT(paramsWr.endDate).addHours(-offset);

        Set<Id> idsAttendance = new Set<Id>();
        String coorporateId = paramsWr.coorporateId;
        idsAttendance.add(coorporateId);
        if(!paramsWr.investorIds.isEmpty()){
            for(String idAux:paramsWr.investorIds){
                idsAttendance.add(Id.valueOf(idAux));
            }
        }

        List<EAP_Attendee__c> atteendeList = SEL_EAP_Attendee.newInstance().selectById(idsAttendance);
        Map<String,String> mapAttName = new Map<String,String>();                                          
        for(EAP_Attendee__c att:atteendeList){
            mapAttName.put(att.Id, att.EAP_ContactName__c);
        }

        List<EAP_MeetingAvailability__c> availabilityList = SEL_EAP_MeetingAvailability.newInstance().selectByAttendeeAndStartEndDate(idsAttendance, startDate, endDate);
        Map<Id,EAP_MeetingAvailability__c> mapAttMeAv = new Map<Id,EAP_MeetingAvailability__c>();
        for(EAP_MeetingAvailability__c ma  :availabilityList){
            mapAttMeAv.put(ma.EAP_Attendee__c,ma);
        }

        List<EAP_Attendance__c> attendanceList = SEL_EAP_Attendance.newInstance().selectByAttendeeAndStartEndDate(idsAttendance, startDate, endDate);
        Map<Id,EAP_Attendance__c> mapAttMeet = new Map<Id,EAP_Attendance__c>();
        for(EAP_Attendance__c atten  :attendanceList){
            mapAttMeet.put(atten.EAP_Attendee__c,atten);
        }

        ResponseAvailabilityWr res = new ResponseAvailabilityWr();
        List<IndividualMeet_Wr> investorsMatch = new List<IndividualMeet_Wr>();
        Boolean allAvailable = true;
        for(Id idAtt: idsAttendance){
            IndividualMeet_Wr imWr = new IndividualMeet_Wr();
            imWr.attId = idAtt;
            EAP_MeetingAvailability__c avaMeet = mapAttMeAv.get(idAtt);
            imWr.name = mapAttName.get(idAtt);
            if(avaMeet != null){
                imWr.available = !avaMeet.EAP_Booked__c;
                if(avaMeet.EAP_Booked__c){
                    EAP_Attendance__c attend = mapAttMeet.get(idAtt);
                    imWr.meeting = (attend != null)?attend.EAP_Meeting__c:null;
                    allAvailable = false;
                }
            }else{
                imWr.available = false;
                allAvailable = false;
            }

            if(idAtt == coorporateId){
                res.coorporateMatch = imWr;
            }else{
                investorsMatch.add(imWr);
            }
        }
        res.investorsMatch = investorsMatch;
        res.allAvailable = allAvailable;

        return res;
    }

    /**
    * @description Edit meeting Mathcmaking
    * <br/>US-XXXX 
    * @author TCK
    * @param editMeetParams 
    **/
    @AuraEnabled
    public static void editMeetingAttendance(String editMeetParams){

        List<EAP_Attendance__c> listAttToUpdate = new List<EAP_Attendance__c>();
        List<EAP_Attendance__c> listAttToDelete = new List<EAP_Attendance__c>();

        Integer offset = UserInfo.getTimezone().getOffset(Datetime.now())/(1000*60*60);
        MatrixActionsParameterWr editParams = (MatrixActionsParameterWr)JSON.deserialize(editMeetParams, MatrixActionsParameterWr.class);
        
        Datetime pastStartDate = Datetime.valueOfGMT(editParams.pastStartDate).addHours(-offset);
        Datetime pastEndDate = Datetime.valueOfGMT(editParams.pastEndDate).addHours(-offset);

        Datetime newStartDate = Datetime.valueOfGMT(editParams.startDate).addHours(-offset);
        Datetime newEndDate = Datetime.valueOfGMT(editParams.endDate).addHours(-offset);

        Set<Id> idsAttendance = new Set<Id>();
        String coorporateId = editParams.coorporateId;
        idsAttendance.add(coorporateId);
        if(!editParams.investorIds.isEmpty()){
            for(String idAux:editParams.investorIds){
                idsAttendance.add(Id.valueOF(idAux));
            }
        }

        Set<Datetime> startSet = new Set<Datetime>{pastStartDate,newStartDate};
        Set<Datetime> endtSet = new Set<Datetime>{pastEndDate,newEndDate};

        //Lista de disponibilidades tanto en las fechas pasadas como nuevas para el investor y corporate
        List<EAP_MeetingAvailability__c> availabilityList = SEL_EAP_MeetingAvailability.newInstance().selectByAttendeeAndStartEndDate(idsAttendance, startSet, endtSet);

        Map<String,EAP_MeetingAvailability__c> mapCodeMeetAvai = new Map<String,EAP_MeetingAvailability__c>();
        for(EAP_MeetingAvailability__c ma: availabilityList){
            mapCodeMeetAvai.put(ma.EAP_StartDate__c+'-'+ma.EAP_EndDate__c+':'+ma.EAP_Attendee__c,ma);
        }

        //Lista de attendance tanto en las fechas pasadas como nuevas para el corporate
        List<EAP_Attendance__c> attendanceListCorp = new List<EAP_Attendance__c>();

        List<EAP_Attendance__c> attendanceListCorpPast = new List<EAP_Attendance__c>();
        if(editParams.pastCoorporateId != coorporateId){
            attendanceListCorpPast = SEL_EAP_Attendance.newInstance().selectByAttendeeAndStartEndDate(new Set<Id>{Id.valueOf(editParams.pastCoorporateId)}, pastStartDate, pastEndDate);

            List<EAP_MeetingAvailability__c> availabilityListPast = SEL_EAP_MeetingAvailability.newInstance().selectByAttendeeAndStartEndDate(new Set<Id>{Id.valueOf(editParams.pastCoorporateId)}, pastStartDate, pastEndDate);
            for(EAP_MeetingAvailability__c ma: availabilityListPast){
                mapCodeMeetAvai.put(ma.EAP_StartDate__c+'-'+ma.EAP_EndDate__c+':'+ma.EAP_Attendee__c,ma);
            }
            
            attendanceListCorp = SEL_EAP_Attendance.newInstance().selectByAttendeeAndStartEndDate(new Set<Id>{Id.valueOf(coorporateId)}, newStartDate, newEndDate);

        }else{
            attendanceListCorp = SEL_EAP_Attendance.newInstance().selectByAttendeeAndStartEndDate(new Set<Id>{Id.valueOf(coorporateId)}, startSet, endtSet);

        }

        //Lista de attendance tanto en las fechas pasadas como nuevas para el investor
        Set<Id> investorsIdSet = new Set<Id>();
        for (String inv : editParams.investorIds) {
            investorsIdSet.add(Id.valueOf(inv));
        }
        List<EAP_Attendance__c> attendanceListIn = SEL_EAP_Attendance.newInstance().selectByAttendeeAndStartEndDate(investorsIdSet, startSet, endtSet);

        Set<Id> meetingIds = new Set<Id>();
        for(EAP_Attendance__c att: attendanceListIn){
            meetingIds.add(att.EAP_Meeting__c);
        }
        for(EAP_Attendance__c att: attendanceListCorp){
            meetingIds.add(att.EAP_Meeting__c);
        }

        List<EAP_Meeting__c> meetingList = SEL_EAP_Meeting.newInstance().selectByIdWithStartEndDate(meetingIds, startSet, endtSet);

        Map<String,EAP_Meeting__c> mapIdMeet = new Map<String,EAP_Meeting__c>();
        Map<String,Integer> mapIdMeetNumAtten = new Map<String,Integer>();
        for(EAP_Meeting__c meet: meetingList){
            mapIdMeet.put(meet.Id,meet);
            mapIdMeetNumAtten.put(meet.Id,meet.EAP_Attendance_Meeting__r.size());
        }

        EAP_Meeting__c meetMove;
        Id idMeetNew;
        Boolean moveToNewCor = false;
        Boolean moveOnlyAtten = false;
        Boolean deletePastMeeting = false;
        List<EAP_Attendance__c> listAttMove = new List<EAP_Attendance__c>();
        Set<Id> listExistInNew = new Set<Id>();

        Map<Id,EAP_MeetingAvailability__c> mapIdMeetAvaiToUpdate = new Map<Id,EAP_MeetingAvailability__c>();
        
        EAP_Meeting__c pastMeeting = mapIdMeet.get(editParams.pastMeetingId);
        for(EAP_Attendance__c att: attendanceListIn){

            if(att.EAP_Meeting__r.EAP_StartDate__c == pastStartDate && att.EAP_Meeting__r.EAP_EndDate__c == pastEndDate && att.EAP_Meeting__r.EAP_CorporateID__c == editParams.pastCoorporateId && att.EAP_Meeting__c == editParams.pastMeetingId){
                EAP_MeetingAvailability__c maBefore = mapCodeMeetAvai.get(pastStartDate+'-'+pastEndDate+':'+att.EAP_Attendee__c);
                if(pastMeeting.EAP_CorporateID__c != coorporateId){
                    moveToNewCor = true;
                    //Update MeetAva
                    if(maBefore != null){
                        maBefore.EAP_Booked__c = false;
                        mapIdMeetAvaiToUpdate.put(maBefore.Id,maBefore);
                    }
                }else{
                    //Update MeetAva
                    if(maBefore != null){
                        maBefore.EAP_Booked__c = false;
                        mapIdMeetAvaiToUpdate.put(maBefore.Id,maBefore);
                    }
                    EAP_MeetingAvailability__c maAfter = mapCodeMeetAvai.get(newStartDate+'-'+newEndDate+':'+att.EAP_Attendee__c);
                    if(maAfter != null){
                        maAfter.EAP_Booked__c = true;
                        mapIdMeetAvaiToUpdate.put(maAfter.Id,maAfter);
                    }
                }

                listAttMove.add(att);
                
            }

            if(att.EAP_Meeting__r.EAP_StartDate__c == newStartDate && att.EAP_Meeting__r.EAP_EndDate__c == newEndDate && att.EAP_Meeting__r.EAP_CorporateID__c == coorporateId){
                EAP_Meeting__c newMeeting = mapIdMeet.get(att.EAP_Meeting__c);
                if(newMeeting != null){
                    listExistInNew.add(att.EAP_Attendee__c);
                }
            }
        }

        for(EAP_Attendance__c att: attendanceListCorp){
            if(att.EAP_Meeting__r.EAP_StartDate__c == pastStartDate && att.EAP_Meeting__r.EAP_EndDate__c == pastEndDate 
                                    && pastMeeting.EAP_CorporateID__c == coorporateId && att.EAP_Meeting__c == editParams.pastMeetingId){
                Integer numAttendanceMeet = mapIdMeetNumAtten.get(att.EAP_Meeting__c);
                if(numAttendanceMeet <= 2){
                    meetMove = pastMeeting;
                    listAttMove.add(att);
                }else{
                    moveOnlyAtten = true;
                    EAP_Attendance__c attNew = new EAP_Attendance__c();
                    attNew.Name = att.Name;
                    attNew.EAP_Attendee__c = att.EAP_Attendee__c;
                    listAttMove.add(attNew);
                }

                //Update MeetAva
                EAP_MeetingAvailability__c maBefore = mapCodeMeetAvai.get(pastStartDate+'-'+pastEndDate+':'+att.EAP_Attendee__c);
                if(maBefore != null){
                    maBefore.EAP_Booked__c = false;
                    mapIdMeetAvaiToUpdate.put(maBefore.Id,maBefore);
                }
                EAP_MeetingAvailability__c maAfter = mapCodeMeetAvai.get(newStartDate+'-'+newEndDate+':'+att.EAP_Attendee__c);
                if(maAfter != null){
                    maAfter.EAP_Booked__c = true;
                    mapIdMeetAvaiToUpdate.put(maAfter.Id,maAfter);
                }
            }

            if(att.EAP_Meeting__r.EAP_StartDate__c == newStartDate && att.EAP_Meeting__r.EAP_EndDate__c == newEndDate){
                EAP_Meeting__c newMeeting = mapIdMeet.get(att.EAP_Meeting__c);

                if(pastMeeting.EAP_CorporateID__c == coorporateId){
                    Integer numAttendanceMeet = mapIdMeetNumAtten.get(att.EAP_Meeting__c);
                    Integer numAttendanceMeetPast = mapIdMeetNumAtten.get(pastMeeting.Id);

                    if(numAttendanceMeetPast <= 2 && numAttendanceMeet > 0){
                        deletePastMeeting = true;
                    }
                    if(numAttendanceMeet != null && numAttendanceMeet >= 2){
                        moveOnlyAtten = true;
                    }
                    
                }

                if(newMeeting != null){
                    idMeetNew = newMeeting.Id;
                    listExistInNew.add(att.EAP_Attendee__c);
                }
                
            }
            
        }

        for(EAP_Attendance__c att: attendanceListCorpPast){

            //Update MeetAva
            EAP_MeetingAvailability__c maBefore = mapCodeMeetAvai.get(pastStartDate+'-'+pastEndDate+':'+att.EAP_Attendee__c);
            if(maBefore != null){
                maBefore.EAP_Booked__c = false;
                mapIdMeetAvaiToUpdate.put(maBefore.Id,maBefore);
            }
            EAP_MeetingAvailability__c maAfter = mapCodeMeetAvai.get(newStartDate+'-'+newEndDate+':'+coorporateId);
            if(maAfter != null){
                maAfter.EAP_Booked__c = true;
                mapIdMeetAvaiToUpdate.put(maAfter.Id,maAfter);
            }
            
            Integer numAttendanceMeet = 0;
            EAP_Meeting__c newMeeting = mapIdMeet.get(idMeetNew);
            if(idMeetNew != null){
                numAttendanceMeet = mapIdMeetNumAtten.get(newMeeting.Id);
            }
            Integer numAttendanceMeetPast = mapIdMeetNumAtten.get(pastMeeting.Id);

            if(numAttendanceMeetPast <= 2 && numAttendanceMeet > 0){
                deletePastMeeting = true;
                listAttToDelete.add(att);
            }
            if(numAttendanceMeet != null && numAttendanceMeet > 2){
                moveOnlyAtten = true;
            }else{
                if(numAttendanceMeetPast <= 2){
                    meetMove = pastMeeting;
                    //att.Name = att.Name;
                    att.EAP_Attendee__c = coorporateId;
                    listAttMove.add(att);
                }else{
                    moveOnlyAtten = true;
                    EAP_Attendance__c attNew = new EAP_Attendance__c();
                    attNew.Name = att.Name;
                    attNew.EAP_Attendee__c = coorporateId;
                    listAttMove.add(attNew);
                }
            }
        }

        if(moveOnlyAtten){
            if(idMeetNew == null){
                meetMove = new EAP_Meeting__c();
                meetMove.Name = 'Meeting Matrix';
                meetMove.EAP_AppEvent__c = editParams.eventId;
                meetMove.EAP_StartDate__c = newStartDate;
                meetMove.EAP_EndDate__c = newEndDate;
                meetMove.EAP_Format__c = 'Onsite';
                meetMove.EAP_Status__c = 'Active';
                meetMove.EAP_CorporateID__c = coorporateId;

                try{
                    insert meetMove;
                } catch(DMLException ex) { ApexPages.addMessages(ex); }

                idMeetNew = meetMove.Id;
            }
            for(EAP_Attendance__c att: listAttMove){
                if(!listExistInNew.contains(att.EAP_Attendee__c)){
                    att.EAP_Meeting__c = idMeetNew;
                    listAttToUpdate.add(att);
                }else{
                    if(att.Id != null){
                        listAttToDelete.add(att);
                    }
                }
            }
        }else{
            if(meetMove != null){
                meetMove.EAP_StartDate__c = newStartDate;
                meetMove.EAP_EndDate__c = newEndDate;
                if(moveToNewCor){
                    meetMove.EAP_CorporateID__c = coorporateId;
                }
                try{
                    update meetMove;
                } catch(DMLException ex) { ApexPages.addMessages(ex); }
            }

            if(moveToNewCor){
                for(EAP_Attendance__c att: listAttMove){
                    if(!listExistInNew.contains(att.EAP_Attendee__c)){
                        listAttToUpdate.add(att);

                    }else if(att.Id != null){
                        listAttToDelete.add(att);
                    }
                }
            }
        }

        try{
            if(!listAttToUpdate.isEmpty()){
                Database.upsert(listAttToUpdate);
            }
            if(!listAttToDelete.isEmpty()){
                Database.delete(listAttToDelete);
            }
            if(!mapIdMeetAvaiToUpdate.values().isEmpty()){
                Database.update(mapIdMeetAvaiToUpdate.values());
            }
    
            if(deletePastMeeting){
                delete pastMeeting;
            }
        } catch(DMLException ex) { ApexPages.addMessages(ex); }
        
    }
    
    /**
    * @description Create a new meeting from the Matchmaking Matix with a coorporate and investors selected
    * <br/>US-XXXX
    *
    * @author TCK
    * @param forceMeetParams 
    * @param isNew 
    **/
    @AuraEnabled
    public static void forceMeeting(String forceMeetParams,Boolean isNew){
        List<EAP_Attendance__c> listAttToUpdate = new List<EAP_Attendance__c>();

        Integer offset = UserInfo.getTimezone().getOffset(Datetime.now())/(1000*60*60);
        MatrixActionsParameterWr editParams = (MatrixActionsParameterWr)JSON.deserialize(forceMeetParams, MatrixActionsParameterWr.class);
        
        Datetime newStartDate = Datetime.valueOfGMT(editParams.startDate).addHours(-offset);
        Datetime newEndDate = Datetime.valueOfGMT(editParams.endDate).addHours(-offset);

        Set<Id> idsAttendance = new Set<Id>();
        String coorporateId = editParams.coorporateId;
        if(!editParams.investorIds.isEmpty()){
            for(String idAux:editParams.investorIds){
                idsAttendance.add(Id.valueOf(idAux));
            }
        }
        Set<Id> attsIdAndCorpId = new Set<Id>(idsAttendance);
        attsIdAndCorpId.add(coorporateId);

        List<EAP_MeetingAvailability__c> availabilityList = SEL_EAP_MeetingAvailability.newInstance().selectByAttendeeAndStartEndDate(attsIdAndCorpId, newStartDate, newEndDate);
        Map<String,EAP_MeetingAvailability__c> mapCodeMeetAvai = new Map<String,EAP_MeetingAvailability__c>();
        for(EAP_MeetingAvailability__c ma: availabilityList){
            mapCodeMeetAvai.put(ma.EAP_Attendee__c, ma);
        }

        List<EAP_Attendance__c> attendanceMeetingList = SEL_EAP_Attendance.newInstance().selectByAttendeeCorporateAndStartEndDate(idsAttendance, coorporateId, newStartDate, newEndDate);
        List<String> attListExist = new List<String>();
        for(EAP_Attendance__c att: attendanceMeetingList){
            attListExist.add(att.EAP_Attendee__c);
        }

        listAttToUpdate = SEL_EAP_Attendance.newInstance().selectByAttendeeAndTargetAttendee(idsAttendance, coorporateId);
        List<String> attListToUpdate = new List<String>();
        for(EAP_Attendance__c att: listAttToUpdate){
            attListToUpdate.add(att.EAP_Attendee__c);
        }

        List<EAP_Attendance__c> attendanceCoorList = SEL_EAP_Attendance.newInstance().selectByAttendeeCorporateAndStartEndDate(new Set<Id>{coorporateId}, coorporateId, newStartDate, newEndDate);

        Map<Id,EAP_Attendee__c> mapIdAtten = new Map<Id,EAP_Attendee__c>();
        List<EAP_Attendee__c> attendeList = SEL_EAP_Attendee.newInstance().selectById(attsIdAndCorpId);
        for(EAP_Attendee__c att: attendeList){
            mapIdAtten.put(att.Id,att);
        }

        String meetingId;
        List<EAP_Attendance__c> attToInsert = new List<EAP_Attendance__c>();
        List<EAP_MeetingAvailability__c> maToUpdate = new List<EAP_MeetingAvailability__c>();
        if(attendanceCoorList.isEmpty()){
            EAP_Meeting__c meetNew = new EAP_Meeting__c();
            meetNew.Name = 'Meeting Force';
            meetNew.EAP_AppEvent__c = editParams.eventId;
            meetNew.EAP_StartDate__c = newStartDate;
            meetNew.EAP_EndDate__c = newEndDate;
            meetNew.EAP_Format__c = 'Onsite';
            meetNew.EAP_Status__c = 'Active';
            meetNew.EAP_CorporateID__c = coorporateId;
            try{
                insert meetNew;
            } catch(DMLException ex) { ApexPages.addMessages(ex); }
            meetingId = meetNew.Id;

            EAP_Attendee__c attende = mapIdAtten.get(coorporateId);
            EAP_Attendance__c attNew = new EAP_Attendance__c();
            attNew.Name = attende.EAP_ContactName__c;
            attNew.EAP_Attendee__c = coorporateId;
            attNew.EAP_Meeting__c = meetingId;
            attToInsert.add(attNew);

            if (mapCodeMeetAvai.get(coorporateId) != null) {
                EAP_MeetingAvailability__c meetingAv = mapCodeMeetAvai.get(coorporateId);
                meetingAv.EAP_Booked__c = true;
                maToUpdate.add(meetingAv);
            }
        }else{
            meetingId = attendanceCoorList.get(0).EAP_Meeting__c;
        }

        for(String idAtt: idsAttendance){
            if(!attListExist.contains(idAtt) && !attListToUpdate.contains(idAtt)){
                EAP_Attendee__c attende = mapIdAtten.get(idAtt);
                EAP_Attendee__c coorporate = mapIdAtten.get(coorporateId);
                EAP_Attendance__c attNew = new EAP_Attendance__c();
                attNew.Name = attende.EAP_ContactName__c+' - '+coorporate.EAP_ContactName__c;
                attNew.EAP_Attendee__c = idAtt;
                attNew.EAP_Meeting__c = meetingId;
                attToInsert.add(attNew);
            }

            if (mapCodeMeetAvai.get(idAtt) != null) {
                EAP_MeetingAvailability__c meetingAv = mapCodeMeetAvai.get(idAtt);
                meetingAv.EAP_Booked__c = true;
                maToUpdate.add(meetingAv);
            }
        }

        for(EAP_Attendance__c attendance: listAttToUpdate){
            attendance.EAP_Meeting__c = meetingId;
        }

        try{
            if(!attToInsert.isEmpty()){
                Database.upsert(attToInsert);
            }
    
            if (!listAttToUpdate.isEmpty()) {
                update listAttToUpdate;
            }
    
            if (!maToUpdate.isEmpty()) {
                update maToUpdate;
            }
        } catch(DMLException ex) { ApexPages.addMessages(ex); }
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param eventId 
    **/
    
    @AuraEnabled
    public static void generateAgenda(String eventId){
        List<EAP_Attendee__c> attendees = SEL_EAP_Attendee.newInstance().selectInvestorsByEventId(eventId);
        if(attendees.size() > 0){
            Database.executeBatch(new EAP_GenerateAttendeeAgenda(eventId));
        }
    }

    
    /**
     * @author TCK
     * @description MatrixActionsParameterWr class
     */ 
    public class MatrixActionsParameterWr{
        /**
         * @author TCK
         * @description eventId getter and setter
         */ 
        public String eventId {get;set;}
        /**
         * @author TCK
         * @description corporateId getter and setter
         */ 
        public String coorporateId {get;set;}
        /**
         * @author TCK
         * @description investorIds getter and setter
         */ 
        public List<String> investorIds {get;set;}
        /**
         * @author TCK
         * @description startDate getter and setter
         */ 
        public String startDate {get;set;}
        /**
         * @author TCK
         * @description endDate getter and setter
         */ 
        public String endDate {get;set;}
        /**
         * @author TCK
         * @description  pastStartDate getter and setter
         */ 
        public String pastStartDate {get;set;}
        /**
         * @author TCK
         * @description  pastEndDate getter and setter
         */ 
        public String pastEndDate {get;set;}
        /**
         * @author TCK
         * @description pastCoorporateId getter and setter
         */ 
        public String pastCoorporateId {get;set;}
        /**
         * @author TCK
         * @description  pastMeetingId getter and setter
         */ 
        public String pastMeetingId {get;set;}
    }

    /**
     * @author TCK
     * @description ResponseAvailabilityWrapper
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
     * @description IndividualMeetingWrapper
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
         */  public String name {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description getter and setter
         */  public Boolean available {get;set;}
        @AuraEnabled
        /**
         * @author TCK
         * @description getter and setter
         */  public String meeting {get;set;}
    }
}