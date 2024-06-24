/***
@ Func Area     	:  NBAC
@ Author        	:  Emmanuel Nocks Mulea
@ Date          	:  01.16.2020
@User Story    	    :  US-4260
@ Description 	    :  pulling all submission Attendees and creating them if not exist
***/
public without sharing class SubmissionAttendee_ctrl{
    public ID currentAgendaIdsub {get;  set;}
    public ID currentERIdsub {get;  set;}
    public boolean showintattpanelsub{get;  set;}  
    public boolean showerrormsgsub{get;  set;}
    public String strReportCurrencysub {get;set;}
    public List<InternalAttendeeWrappersub> lstAttendeessub {get;set;}
    public Call_Report__c sobjEventReportsub {get;set;}
    public User sObjEventOwnersub {get;set;}
    private Set<Id> setCheckContactIdsub;  
    private Set<Id> setCheckcommattId; 
    public boolean hasAccesssub{get;  set;}
    public boolean iscommattinsub{get;  set;}
    public boolean issubattinsub{get;  set;}
    public String errorMsginaddsubatt{get;set;}
    
    public SubmissionAttendee_ctrl(){
        showintattpanelsub = false;
        showerrormsgsub = false;
        errorMsginaddsubatt = '';
    }
    
    public List<Call_report_attendees__c> eralstsub{
        get{
            eralstsub = new List<Call_report_attendees__c>();
            if(currentAgendaIdsub != null){
                eralstsub = [Select Id, Contact_Id__c, Contact_Id__r.Id, Contact_Id__r.Name, Contact_Id__r.RecordType.DeveloperName, Send_Email__c, Status__c,Client_Team_Role__c
                                                                    FROM Call_Report_Attendees__c where Related_Agenda__c=:currentAgendaIdsub];
            }
            return eralstsub;
        } set;
        
    }
    /***
Use
@param  	    :  String agendaId
@return   	    :  List of Call_report_attendees__c
@ Description 	:  get a list of Call_report_attendees__c by agendaId
***/
    @AuraEnabled
    public Static List<Call_report_attendees__c> getListOfAttendees(String agendaId){

        List<Call_report_attendees__c> AttendeeList = new List<Call_report_attendees__c>();

        AttendeeList = [Select Id,Type_of_Attendee__c, Contact_Id__c, Contact_Id__r.Id, Contact_Id__r.Name, Contact_Id__r.RecordType.DeveloperName, Send_Email__c, Status__c,Client_Team_Role__c
        FROM Call_Report_Attendees__c where Related_Agenda__c=:agendaId];

        return AttendeeList;


    }
    public PageReference showinternalattendeesub(){
        NBACMeetingController.errorMsginssub ='';
        if(currentAgendaIdsub != null){
            sobjEventReportsub = [Select Id, OwnerId, CurrencyIsoCode, Name,Report_Client_Contact__r.AccountId, Relate_to_Client__c from Call_Report__c where Id =: currentERIdsub ];
            sObjEventOwnersub = [Select Id, Contact_Sync_ID__c from User where Id =:sobjEventReportsub.OwnerId];
            strReportCurrencysub = sobjEventReportsub.CurrencyIsoCode;
            lstAttendeessub = new List<InternalAttendeeWrappersub>();
            getEventReportAttendeesub();
            getClientTeamMemberssub();
            addRowsub();
            lstAttendeessub.sort();
            showintattpanelsub = true;
        }else{
            showerrormsgsub = True;
        }
        return null;
    }
    /***
Use
@param  	    :  String currentERIdsub,String currentAgendaIdsub
@return   	    :  String
@ Description 	:  get a list of InternalAttendeeWrappersub using EventReportID and that has been Agenda selected
***/
    @AuraEnabled
    public Static String showinternalattendeesub(String currentERIdsub,String currentAgendaIdsub){

        Call_Report__c sobjEventReportsub = [Select Id, OwnerId, CurrencyIsoCode, Name,Report_Client_Contact__r.AccountId, Relate_to_Client__c from Call_Report__c where Id =: currentERIdsub ];
        User sObjEventOwnersub = [Select Id, Contact_Sync_ID__c from User where Id =:sobjEventReportsub.OwnerId];
        String strReportCurrencysub = sobjEventReportsub.CurrencyIsoCode;

        List<InternalAttendeeWrappersub>   lstAttendees = SubmissionAttendee_ctrl.getEventReportAttendeeSubAura(currentAgendaIdsub,currentERIdsub,sObjEventOwnersub,strReportCurrencysub,sobjEventReportsub);


        return JSON.serialize(lstAttendees);
    }

    /***
Use
@param  	    :  String currentAgendaIdsub,String currentERId,User sObjEventOwnersub,String strReportCurrency,Call_Report__c sobjEventReport
@return   	    :  List of InternalAttendeeWrappersub
@ Description 	:  method to get already existing event report attendees
***/
    public Static List<InternalAttendeeWrappersub> getEventReportAttendeeSubAura(String currentAgendaIdsub,String currentERId,User sObjEventOwnersub,String strReportCurrency,Call_Report__c sobjEventReport){

        List<InternalAttendeeWrappersub>   lstAttendeessub = new List<InternalAttendeeWrappersub>();
        for(Call_Report_Attendees__c sObjReportAttendees : [Select Id, Contact_Id__c, Contact_Id__r.Id, Contact_Id__r.Name, Contact_Id__r.RecordType.DeveloperName, Send_Email__c, Status__c,Client_Team_Role__c
        FROM Call_Report_Attendees__c where Related_Agenda__c =:currentAgendaIdsub]){

            InternalAttendeeWrappersub objAttendees = new InternalAttendeeWrappersub(sObjReportAttendees);
            if(sObjEventOwnersub.Contact_Sync_ID__c == sObjReportAttendees.Contact_Id__c){
                objAttendees.intOrder = '0';
            }
            lstAttendeessub.add(objAttendees);
        }
        lstAttendeessub.addAll(SubmissionAttendee_ctrl.getClientTeamMemberSubAura(strReportCurrency,currentAgendaIdsub,currentERId,sobjEventReport));
        return lstAttendeessub;
    }

    // method to get the list of Client Team members
    public Static List<InternalAttendeeWrappersub>  getClientTeamMemberSubAura(String strReportCurrencysub,String currentAgendaIdsub,String currentERIdsub,Call_Report__c sobjEventReportsub){
        Set<Id> setCheckContactIdsub = SubmissionAttendee_ctrl.getCheckContactId(currentERIdsub);
        List<InternalAttendeeWrappersub>   lstAttendeessub = new List<InternalAttendeeWrappersub>();
        Map<Id, AccountTeamMember> mapContactId = new Map<Id, AccountTeamMember>();
        for(AccountTeamMember sObjAccTeamMember : [Select Id, User.Contact_Sync_ID__c, TeamMemberRole, AccountId
        from AccountTeamMember where AccountId =:sobjEventReportsub.Relate_to_Client__c]){
            if(setCheckContactIdsub.add(sObjAccTeamMember.User.Contact_Sync_ID__c))
                mapContactId.put(sObjAccTeamMember.User.Contact_Sync_ID__c, sObjAccTeamMember);
        }

        if(!mapContactId.isEmpty()){

            Custom_Client_Team__c[] lstClientTeam= [Select Team_Member__r.Contact_Sync_ID__c, TeamRoleSortValue__c From Custom_Client_Team__c  where Account__c =: sobjEventReportsub.Relate_to_Client__c and Team_Member__r.Contact_Sync_ID__c IN :mapContactId.keyset()];
            map<Id, String> mapClientTeam = new map<Id, String>();
            for(Custom_Client_Team__c cct : lstClientTeam)
                mapClientTeam.put(cct.Team_Member__r.Contact_Sync_ID__c, cct.TeamRoleSortValue__c);

            for(Contact sObjContact: [Select Id, Name, Inactive__c From Contact where Id IN :mapContactId.keyset()]){
                CSTTeamRoleRanking__c sObjRanking = CSTTeamRoleRanking__c.getValues(mapContactId.get(sObjContact.Id).TeamMemberRole);
                String teamRole = mapContactId.get(sObjContact.Id).TeamMemberRole;
                String rank = '49';
                rank = mapClientTeam.containsKey(sObjContact.Id) ?  mapClientTeam.get(sObjContact.Id) : '49';
                rank = rank.contains('_') ? '49' : rank;
                lstAttendeessub.add(new InternalAttendeeWrappersub(false, sObjContact, currentERIdsub, currentAgendaIdsub, strReportCurrencysub, teamRole, rank));
            }
        }

        return lstAttendeessub;
    }
    public static Set<Id> getChecksubattId(String currentERId){

        Set<Id> setChecksubattId = new Set<Id>();
        for(Call_Report_Attendees__c subattendees :[Select Id, Contact_Id__c, Contact_Id__r.Id, Contact_Id__r.Name, Contact_Id__r.RecordType.DeveloperName, Send_Email__c, Status__c,Client_Team_Role__c
        FROM Call_Report_Attendees__c where Call_Report__c=:currentERId and Contact_Id__r.RecordType.DeveloperName='SA_Bank_Contact_Record_Type' and Type_of_Attendee__c = 'Submission Attendee']){
            setChecksubattId.add(subattendees.Contact_Id__c);
        }

        return setChecksubattId;
    }

    public static Set<Id> getCheckcommattId(String currentERIdsub){

        Set<Id> setCheckcommattId = new Set<Id>();
        for(Call_Report_Attendees__c committeeattendees :[Select Id, Contact_Id__c, Contact_Id__r.Id, Contact_Id__r.Name, Contact_Id__r.RecordType.DeveloperName, Send_Email__c, Status__c,Client_Team_Role__c
        FROM Call_Report_Attendees__c where Call_Report__c=:currentERIdsub and Contact_Id__r.RecordType.DeveloperName='SA_Bank_Contact_Record_Type' and Type_of_Attendee__c = 'Committee Attendee']){
        setCheckcommattId.add(committeeattendees.Contact_Id__c);
        }

        return setCheckcommattId;
    }

    public static Set<Id> getCheckContactId(String currentERId){

        Set<Id> setCheckContactId = new Set<Id>();
        for(Call_Report_Attendees__c sObjReportAttendees : [Select Id, Contact_Id__c, Contact_Id__r.Id, Contact_Id__r.Name, Contact_Id__r.RecordType.DeveloperName, Send_Email__c, Status__c,Client_Team_Role__c
        FROM Call_Report_Attendees__c where Call_Report__c=:currentERId and Contact_Id__r.RecordType.DeveloperName='SA_Bank_Contact_Record_Type' and Type_of_Attendee__c = 'Committee Attendee']){

            setCheckContactId.add(sObjReportAttendees.Contact_Id__c);
        }

        return setCheckContactId;
    }
    // method to get already existing event report attendees
    public void getEventReportAttendeesub(){
        
        setCheckContactIdsub = new Set<Id>();
        setCheckcommattId = new Set<Id>();
        for(Call_Report_Attendees__c committeeattendees :[Select Id, Contact_Id__c, Contact_Id__r.Id, Contact_Id__r.Name, Contact_Id__r.RecordType.DeveloperName, Send_Email__c, Status__c,Client_Team_Role__c
                                                                    FROM Call_Report_Attendees__c where Call_Report__c=:currentERIdsub and Contact_Id__r.RecordType.DeveloperName='SA_Bank_Contact_Record_Type' and Type_of_Attendee__c = 'Committee Attendee']){
               setCheckcommattId.add(committeeattendees.Contact_Id__c);                                    
        }
        
        for(Call_Report_Attendees__c sObjReportAttendees : [Select Id, Contact_Id__c, Contact_Id__r.Id, Contact_Id__r.Name, Contact_Id__r.RecordType.DeveloperName, Send_Email__c, Status__c,Client_Team_Role__c
                                                                    FROM Call_Report_Attendees__c where Related_Agenda__c =:currentAgendaIdsub]){
            
            InternalAttendeeWrappersub objAttendees = new InternalAttendeeWrappersub(sObjReportAttendees);
            if(sObjEventOwnersub.Contact_Sync_ID__c == sObjReportAttendees.Contact_Id__c){
                objAttendees.intOrder = '0';
            }
            lstAttendeessub.add(objAttendees);
            setCheckContactIdsub.add(sObjReportAttendees.Contact_Id__c);
        }
    }
    // method to get the list of Client Team members
    public void getClientTeamMemberssub(){
        
        Map<Id, AccountTeamMember> mapContactId = new Map<Id, AccountTeamMember>();
        for(AccountTeamMember sObjAccTeamMember : [Select Id, User.Contact_Sync_ID__c, TeamMemberRole, AccountId 
                                                    from AccountTeamMember where AccountId =:sobjEventReportsub.Relate_to_Client__c]){
            if(setCheckContactIdsub.add(sObjAccTeamMember.User.Contact_Sync_ID__c))
                mapContactId.put(sObjAccTeamMember.User.Contact_Sync_ID__c, sObjAccTeamMember);
        }
        
        if(!mapContactId.isEmpty()){

          Custom_Client_Team__c[] lstClientTeam= [Select Team_Member__r.Contact_Sync_ID__c, TeamRoleSortValue__c From Custom_Client_Team__c  where Account__c =: sobjEventReportsub.Relate_to_Client__c and Team_Member__r.Contact_Sync_ID__c IN :mapContactId.keyset()];
          map<Id, String> mapClientTeam = new map<Id, String>();
          for(Custom_Client_Team__c cct : lstClientTeam)
            mapClientTeam.put(cct.Team_Member__r.Contact_Sync_ID__c, cct.TeamRoleSortValue__c);

            for(Contact sObjContact: [Select Id, Name, Inactive__c From Contact where Id IN :mapContactId.keyset()]){
                CSTTeamRoleRanking__c sObjRanking = CSTTeamRoleRanking__c.getValues(mapContactId.get(sObjContact.Id).TeamMemberRole);
                String teamRole = mapContactId.get(sObjContact.Id).TeamMemberRole;
                String rank = '49';
                rank = mapClientTeam.containsKey(sObjContact.Id) ?  mapClientTeam.get(sObjContact.Id) : '49';
                rank = rank.contains('_') ? '49' : rank;
                lstAttendeessub.add(new InternalAttendeeWrappersub(false, sObjContact, currentERIdsub, currentAgendaIdsub, strReportCurrencysub, teamRole, rank));
            }
        }
    }
    
    
    public Pagereference addRowsub(){
        for(Integer i=0;i<4;i++){
            lstAttendeessub.add(new InternalAttendeeWrappersub(false, null, currentERIdsub, currentAgendaIdsub, strReportCurrencysub, null ,'50'));
        }
        return null;
    }
    /***
Use
@param  	    :  string currentERIdsub,string currentAgendaIdsub
@return   	    :  JSON List of InternalAttendeeWrappersub as a string
@ Description 	:  create virtual object of InternalAttendeeWrappersub for cmp to use it as a new row
***/
    @AuraEnabled
    public Static String addRowAura(string currentERIdsub,string currentAgendaIdsub){
        Call_Report__c eventReport= [Select Id, OwnerId, CurrencyIsoCode, Name,Report_Client_Contact__r.AccountId, Relate_to_Client__c from Call_Report__c where Id =: currentERIdsub ];
        InternalAttendeeWrappersub newSub= new InternalAttendeeWrappersub(false, null, currentERIdsub, currentAgendaIdsub, eventReport.CurrencyIsoCode, null ,'50');

        return JSON.serialize(newSub);
    }
    /***
Use
@param  	    :  string currentERIdsub,string currentAgendaIdsub
@return   	    :  JSON List of InternalAttendeeWrappersub as a string
@ Description 	:  create virtual object of InternalAttendeeWrappersub for cmp to use it as a new 4 rows
***/
    @AuraEnabled
    public Static String add_4_RowAura(string currentERIdsub,string currentAgendaIdsub){
        Call_Report__c eventReport= [Select Id, OwnerId, CurrencyIsoCode, Name,Report_Client_Contact__r.AccountId, Relate_to_Client__c from Call_Report__c where Id =: currentERIdsub ];
        List<InternalAttendeeWrappersub> newSubList = new List<InternalAttendeeWrappersub>();
        for(integer x=0;x<4;x++) {

        InternalAttendeeWrappersub newSub = new InternalAttendeeWrappersub(false, null, currentERIdsub, currentAgendaIdsub, eventReport.CurrencyIsoCode, null, '50');
            newSubList.add(newSub);
        }
        return JSON.serialize(newSubList);
    }
    public Pagereference addRowsubonlink(){
        for(Integer i=0;i<4;i++){
            lstAttendeessub.add(new InternalAttendeeWrappersub(false, null, currentERIdsub, currentAgendaIdsub, strReportCurrencysub, null ,'50'));
        }
        showintattpanelsub = true;
        errorMsginaddsubatt = '';
        return null;
    }
    /***
Use
@param  	    :  string currentERIdsub,string submissionList
@return   	    :  JSON as a string
@ Description 	:  Create or edit Submission Attendees
***/
    @AuraEnabled
    public Static String saveSubmissionAttendee(string currentERIdsub,string submissionList){
        JSONGenerator jsonGen = JSON.createGenerator(true);
        try{
            List<Call_Report_Attendees__c> lstUpsertAttendee = new List<Call_Report_Attendees__c>();
            List<Call_Report_Attendees__c> lstRemoveAttendee = new List<Call_Report_Attendees__c>();
            Set<Id> setCheckContactIdsub = SubmissionAttendee_ctrl.getCheckContactId(currentERIdsub);
            Set<Id> setCheckcommattId = SubmissionAttendee_ctrl.getCheckcommattId(currentERIdsub);
            Set<Id> setCheck = new Set<Id>();
            Boolean isErrors = false;
            List<InternalAttendeeWrappersub> lstAttendeessub = (List<InternalAttendeeWrappersub>)JSON.deserialize(submissionList, List<InternalAttendeeWrappersub>.class);
            for(InternalAttendeeWrappersub objAttendee: lstAttendeessub){
            if(objAttendee.bChecked){
                if(objAttendee.sobjAttendee.Contact_Id__c==null){
                    objAttendee.isError=true;
                    objAttendee.errorMessage= 'Attendee Name cannot be blank';
                    isErrors =true;
                }
                else if(setCheckcommattId.contains(objAttendee.sobjAttendee.Contact_Id__c)){

                    objAttendee.isError=true;
                    objAttendee.errorMessage= Label.Submission_already_a_Committee;
                    isErrors =true;
                }
                else if(setCheckContactIdsub.add(objAttendee.sobjAttendee.Contact_Id__c)) {
                    setCheck.add(objAttendee.sobjAttendee.Contact_Id__c);
                    lstUpsertAttendee.add(objAttendee.sobjAttendee);
                }
                else if(!setCheckContactIdsub.add(objAttendee.sobjAttendee.Contact_Id__c)){
                    objAttendee.bChecked = false;
                    objAttendee.isError=true;
                    objAttendee.errorMessage= 'You cannot select same Contact more than once, duplicate contact is unchecked.';
                    isErrors =true;
                }


            } else {
                if(setCheckContactIdsub.add(objAttendee.sobjAttendee.Contact_Id__c) && objAttendee.sobjAttendee.Id != null) {
                    lstRemoveAttendee.add(objAttendee.sobjAttendee);
                }
            }
            }
            if(isErrors){

            return System.JSON.serialize(lstAttendeessub);
            }
            List<Contact> lstCon = [Select Name From Contact where Id IN :setCheck and Inactive__c = true];
            if(!lstCon.isEmpty()){

            for(InternalAttendeeWrappersub objAttendee: lstAttendeessub) {

                for (Contact sObjContact : lstCon) {

                    if (objAttendee.sobjAttendee.Contact_Id__c == sObjContact.Id) {
                        objAttendee.isError=true;
                        objAttendee.errorMessage= 'You cannot add an Inactive contact.';
                    }
                }
            }

            return System.JSON.serialize(lstAttendeessub);
            }
            List<Contact> lstExternalCon = [Select Name, Inactive__c From Contact where Id IN :setCheck and RecordType.DeveloperName = 'SA_Client_Contact_Record_Type'];
            if(!lstExternalCon.isEmpty()){
            for(InternalAttendeeWrappersub objAttendee: lstAttendeessub) {

                for (Contact sObjContact : lstExternalCon) {

                    if (objAttendee.sobjAttendee.Contact_Id__c == sObjContact.Id) {
                        objAttendee.isError=true;
                        objAttendee.errorMessage= 'You cannot add an external contact.';
                    }
                }
            }
            return System.JSON.serialize(lstAttendeessub);
            }


            Delete lstRemoveAttendee;
            Upsert lstUpsertAttendee;
            jsonGen.writeStartObject();
            jsonGen.writeBooleanField('isError',false);
            jsonGen.writeStringField('msg','');
            jsonGen.writeEndObject();
            return jsonGen.getAsString();
        } catch (Exception e){
            jsonGen.writeStartObject();
            jsonGen.writeBooleanField('isError',true);
            jsonGen.writeStringField('msg', e.getMessage());
            jsonGen.writeEndObject();
            return jsonGen.getAsString();
        }

    }

    public PageReference savesub(){
        errorMsginaddsubatt = '';
        List<Call_Report_Attendees__c> lstUpsertAttendee = new List<Call_Report_Attendees__c>();
        List<Call_Report_Attendees__c> lstRemoveAttendee = new List<Call_Report_Attendees__c>();
        setCheckContactIdsub = new Set<Id>();
        Set<Id> setCheck = new Set<Id>();
        
        for(InternalAttendeeWrappersub objAttendee: lstAttendeessub){
                if(objAttendee.bChecked){
                    if(objAttendee.sobjAttendee.Contact_Id__c==null){
                         errorMsginaddsubatt = '';
                         errorMsginaddsubatt = 'Attendee Name cannot be blank';
                         return null;
                    }
                    else if(setCheckcommattId.contains(objAttendee.sobjAttendee.Contact_Id__c)){
                        objAttendee.bChecked = false;
                        errorMsginaddsubatt = '';
                        errorMsginaddsubatt = Label.Submission_already_a_Committee;
                        return null;
                    }
                    else if(setCheckContactIdsub.add(objAttendee.sobjAttendee.Contact_Id__c)) {
                                setCheck.add(objAttendee.sobjAttendee.Contact_Id__c);
                                lstUpsertAttendee.add(objAttendee.sobjAttendee);
                    } 
                    else if(!setCheckContactIdsub.add(objAttendee.sobjAttendee.Contact_Id__c)){
                        objAttendee.bChecked = false;
                        errorMsginaddsubatt = '';
                        errorMsginaddsubatt = 'You cannot select same Contact more than once, duplicate contact is unchecked.';
                        return null;
                    }
                    
                   
                } else {
                    if(setCheckContactIdsub.add(objAttendee.sobjAttendee.Contact_Id__c) && objAttendee.sobjAttendee.Id != null) {
                        lstRemoveAttendee.add(objAttendee.sobjAttendee);
                    }
                }
        }
        List<Contact> lstCon = [Select Name From Contact where Id IN :setCheck and Inactive__c = true];
        if(!lstCon.isEmpty()){
            errorMsginaddsubatt = '';
            errorMsginaddsubatt = 'You cannot add an Inactive contact.';
            for(Contact sObjContact : lstCon){
                errorMsginaddsubatt +=  '<br/>'+ sObjContact.Name;
            }
        return null;
        }
        List<Contact> lstExternalCon = [Select Name, Inactive__c From Contact where Id IN :setCheck and RecordType.DeveloperName = 'SA_Client_Contact_Record_Type'];
        if(!lstExternalCon.isEmpty()){
            errorMsginaddsubatt = '';
            errorMsginaddsubatt = 'You cannot add an external contact.';
            for(Contact sObjContact : lstExternalCon){
                errorMsginaddsubatt +=  '<br/>'+ sObjContact.Name;
            }
        return null;
        }
        try{
            Delete lstRemoveAttendee;
            Upsert lstUpsertAttendee;
            showintattpanelsub = false;
            errorMsginaddsubatt = '';
            return null;
        } catch (Exception e){
            ApexPages.getMessages().clear();
            errorMsginaddsubatt = '';
            errorMsginaddsubatt = 'An error occured. '+ e.getMessage();
        }
        return null;
    }
    
   
    public class InternalAttendeeWrappersub implements Comparable {
        
      public String intOrder {get;set;}
      public Boolean bChecked  {get;set;}
      public Call_Report_Attendees__c sobjAttendee {get;set;}
      public String teamRole {get;set;}
        public Boolean isError {get;set;}
        public String errorMessage {get;set;}
      public InternalAttendeeWrappersub(Boolean bChecked, Contact sObjContact, Id idEventReport, Id idAgenda, String strReportCurrencysub, String teamRole, String intOrder){
          this.bChecked = bChecked;
          this.intOrder = intOrder;
          this.teamRole = teamRole;
          this.isError = false;
          this.errorMessage = '';
          sobjAttendee = new Call_Report_Attendees__c();
          if(sObjContact!=null)
              sobjAttendee.Contact_Id__c = sObjContact.Id;
          sobjAttendee.Status__c = 'Invited';
          sobjAttendee.CurrencyIsoCode = strReportCurrencysub;
          sobjAttendee.Call_Report__c = idEventReport;
          sobjAttendee.Related_Agenda__c = idAgenda;
          sobjAttendee.Send_Email__c = 'Yes';
          sobjAttendee.Type_of_Attendee__c = 'Submission Attendee';
      }
      
      public InternalAttendeeWrappersub(Call_Report_Attendees__c sobjAttendee){
          bChecked = true;
          intOrder = '00';
          this.sobjAttendee = sobjAttendee;
          teamRole = sobjAttendee.Client_Team_Role__c;
      }
      
      public Integer compareTo(Object obj){
          InternalAttendeeWrappersub compareToAttendee = (InternalAttendeeWrappersub)obj;
          if(this.intOrder == compareToAttendee.intOrder)
              return 0;
          else
              if(this.intOrder > compareToAttendee.intOrder)
                  return 1;
              else
                    return -1;
      }
    }
    
    public Pagereference intattclosesub(){
        showintattpanelsub = false;
        errorMsginaddsubatt = '';
        return null;
    }
    
    public Pagereference errclosesub(){
        showerrormsgsub = false;
        errorMsginaddsubatt = '';
        return null;
    }
    /***
Use
@param  	    :  none
@return   	    :  JSON as a string
@ Description 	:  get pickList values of the status
***/
    @AuraEnabled
    public static String getSubmissionAttendeesStatusOptions() {
        Schema.DescribeFieldResult f = Call_Report_Attendees__c.Status__c.getDescribe();
        return system.JSON.serialize(prepareSubmissionAttendeesStatusFromDescribeFieldResult(f));
    }
    /***
Use
@param  	    :  Schema.DescribeFieldResult f
@return   	    :  List of Mapped strings
@ Description 	:  get pickList values of the status
***/
    private Static List<Map<string,string>> prepareSubmissionAttendeesStatusFromDescribeFieldResult(Schema.DescribeFieldResult f) {

        List<Schema.PicklistEntry> p = f.getPicklistValues();
        Map<string,string> options = new Map<string,string>();
        List<Map<string,string>> optionList = new List<Map<string,string>>();
        options.put('--None--', '--None--');
        optionList.add(options);
        for (Schema.PicklistEntry e: p) {

            options = new Map<string,string>();
            options.put(String.ValueOf(e.getLabel()),String.ValueOf(e.getValue()));
            optionList.add(options);
        }
        return optionList;
    }
    /***
Use
@param  	    :  string nbacID,string agendaId,string ERID,boolean hasAccess
@return   	    :  String
@ Description 	:  create Submission Attendees
***/
    @AuraEnabled
    public Static String insertsubattendees(string nbacID,string agendaId,string ERID,boolean hasAccess) {
        JSONGenerator jsonGen = JSON.createGenerator(true);
try{
        List<Call_Report_Attendees__c> subattfinal = new List<Call_Report_Attendees__c>();
        Map<ID, String> checkdupera = new Map<ID, String>();
        Map<ID, String> checkduperainit = new Map<ID, String>();
        List<ID> consyncIds = new List<ID>();
        Map<ID, Call_Report_Attendees__c> existingagenda = new Map<ID, Call_Report_Attendees__c>();
        Map<ID, String> consyncpropermap = new Map<ID, String>();
        List<User> otmlst = new List<User>();
        String existsascomatt = '';
        String invalidconsync = '';
        List<UserRecordAccess> lstura = new List<UserRecordAccess>();
        Set<ID> manageset = new Set<ID>();
        lstura = [Select RecordId,HasReadAccess, HasEditAccess, MaxAccessLevel from UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :nbacID];


        if (hasAccess || (lstura.size() > 0 && lstura[0].HasReadAccess == True)) {
            if (agendaId != null) {
                for (Call_Report_Attendees__c agendarec : [Select ID, Contact_id__c from Call_Report_Attendees__c where Related_Agenda__c = :agendaId]) {
                    existingagenda.put(agendarec.Contact_id__c, agendarec);
                }
            }

            if (manageset.add(agendaId) && existingagenda.size() < 1) {

                    for (Call_Report_Attendees__c cra : [Select ID, Contact_id__c, Contact_id__r.Name, Type_of_Attendee__c from Call_Report_Attendees__c where Call_Report__c = :ERID and Type_of_Attendee__c = 'Committee Attendee']) {
                        checkdupera.put(cra.Contact_id__c, cra.Contact_id__r.Name);
                        checkduperainit.put(cra.Contact_id__c, cra.Contact_id__r.Name);
                    }

                    if (nbacID != null) {
                        otmlst = [Select Id, Contact_Sync_ID__c, Name From User Where Id IN (Select UserOrGroupId From Business_Assessment__Share Where ParentId = :nbacID)];
                        for (User otm : otmlst) {
                            if (otm.Contact_Sync_ID__c != null) {
                                consyncIds.add(otm.Contact_Sync_ID__c);
                            }
                        }
                        for (Contact con : [Select ID, name from Contact where Id in :consyncIds]) {
                            consyncpropermap.put(con.ID, con.Name);
                        }
                    }

                    for (User otm : otmlst) {
                        if (otm.Contact_Sync_ID__c != null && consyncpropermap.containskey(otm.Contact_Sync_ID__c)) {
                            if (!checkduperainit.containskey(otm.Contact_Sync_ID__c)) {
                                if (!checkdupera.containskey(otm.Contact_Sync_ID__c) && (!existingagenda.containskey(otm.Contact_Sync_ID__c))) {
                                    checkdupera.put(otm.Contact_Sync_ID__c, consyncpropermap.get(otm.Contact_Sync_ID__c));
                                    Call_Report_Attendees__c crarec = new Call_Report_Attendees__c();
                                    crarec.Contact_Id__c = otm.Contact_Sync_ID__c;
                                    crarec.Status__c = 'Invited';
                                    crarec.Call_Report__c = ERID;
                                    crarec.Related_Agenda__c = agendaId;
                                    crarec.Send_Email__c = 'Yes';
                                    crarec.Type_of_Attendee__c = 'Submission Attendee';
                                    subattfinal.add(crarec);
                                }
                            } else {
                                if (!existsascomatt.contains(consyncpropermap.get(otm.Contact_Sync_ID__c))) {
                                    existsascomatt += ', ' + consyncpropermap.get(otm.Contact_Sync_ID__c);
                                }
                            }
                        } else {
                            invalidconsync += ', ' + otm.Name ;
                        }
                    }
                    if (existsascomatt != '') {

                        jsonGen.writeStartObject();
                        jsonGen.writeBooleanField('isError', true);
                        jsonGen.writeStringField('msg', Label.OppTeam_Committee + existsascomatt);
                        jsonGen.writeEndObject();
                        return jsonGen.getAsString();
                    }
                    if (invalidconsync != '') {
                        jsonGen.writeStartObject();
                        jsonGen.writeBooleanField('isError', true);
                        jsonGen.writeStringField('msg', Label.OppTeam_noBankContact + invalidconsync);
                        jsonGen.writeEndObject();
                        return jsonGen.getAsString();
                    }


            }
            else {

                jsonGen.writeStartObject();
                jsonGen.writeBooleanField('isError', true);
                jsonGen.writeStringField('msg', 'we have existing agenda ');
                jsonGen.writeEndObject();
                return jsonGen.getAsString();
            }

            if (subattfinal.size() > 0) {
                try {
                    insert subattfinal;
                    jsonGen.writeStartObject();
                    jsonGen.writeBooleanField('isError', true);
                    jsonGen.writeStringField('msg', 'success');
                    jsonGen.writeEndObject();
                    return jsonGen.getAsString();
                } catch (DmlException e) {
                    system.debug('An exception during saving Agenda data ...' + e.getdmlMessage(0));
                    //errorMsg = e.getdmlMessage(0);
                    jsonGen.writeStartObject();
                    jsonGen.writeBooleanField('isError', true);
                    jsonGen.writeStringField('msg', e.getdmlMessage(0));
                    jsonGen.writeEndObject();
                    return jsonGen.getAsString();
                }
            }
            else {
                jsonGen.writeStartObject();
                jsonGen.writeBooleanField('isError', true);
                jsonGen.writeStringField('msg', 'No Submission attendees');
                jsonGen.writeEndObject();
                return jsonGen.getAsString();
            }

            //}
        } else {

            jsonGen.writeStartObject();
            jsonGen.writeBooleanField('isError', true);
            jsonGen.writeStringField('msg', Label.Console_Manage_No_Access);
            jsonGen.writeEndObject();
            return jsonGen.getAsString();

        }
    }
        catch(Exception e){
        jsonGen.writeStartObject();
        jsonGen.writeBooleanField('isError', true);
        jsonGen.writeStringField('msg', e.getMessage());
        jsonGen.writeEndObject();
        return jsonGen.getAsString();
    }
    }
}