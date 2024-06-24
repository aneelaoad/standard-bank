/***
@ Func Area     	:  NBAC
@ Author        	:  Emmanuel Nocks Mulea
@ Date          	:  01.16.2020
@User Story    	    :  US-4260
@ Description 	    :  pulling all Committee Attendees and creating them if not exist
***/
public without sharing class CommitteeAttendee_ctrl{
    public ID currentERId {get;  set;}
    public boolean showintattpanel{get;  set;}  
    public boolean showerrormsg{get;  set;}
    public String strReportCurrency {get;set;}
    public List<InternalAttendeeWrapper> lstAttendees {get;set;}
    public Call_Report__c sobjEventReport {get;set;}
    public User sObjEventOwner {get;set;}
    private Set<Id> setCheckContactId;
    private Set<Id> setChecksubattId;  
    public boolean issubatt{get;  set;}
    public boolean iscommatt{get;  set;}
    public boolean hasallAcc{get;  set;}
    public String errorMsginaddcommatt{get;set;}
    
    public CommitteeAttendee_ctrl(){
        showintattpanel = false;
        showerrormsg = false;
        errorMsginaddcommatt = '';
    }
    /***
Use
@param  	    :  string currentERId
@return   	    :  List of Call_report_attendees__c
@ Description 	:  get a list of Call_report_attendees__c
***/
    @AuraEnabled
    public static  List<Call_report_attendees__c> getCallReportAttendees(string currentERId){

        List<Call_report_attendees__c> callReportAttendeesList = [Select Id, Contact_Id__c, Contact_Id__r.Id, Contact_Id__r.Name, Contact_Id__r.RecordType.DeveloperName, Send_Email__c, Status__c,Client_Team_Role__c
        FROM Call_Report_Attendees__c where Call_Report__c=:currentERId and Contact_Id__r.RecordType.DeveloperName='SA_Bank_Contact_Record_Type' and Type_of_Attendee__c = 'Committee Attendee'];
        return callReportAttendeesList;

    }

    public List<Call_report_attendees__c> eralst{
        get{
            eralst = new List<Call_report_attendees__c>();
            if(currentERId != null){
                eralst = [Select Id, Contact_Id__c, Contact_Id__r.Id, Contact_Id__r.Name, Contact_Id__r.RecordType.DeveloperName, Send_Email__c, Status__c,Client_Team_Role__c
                                                                    FROM Call_Report_Attendees__c where Call_Report__c=:currentERId and Contact_Id__r.RecordType.DeveloperName='SA_Bank_Contact_Record_Type' and Type_of_Attendee__c = 'Committee Attendee'];
            }
            return eralst;
        } set;
        
    }
    
    public PageReference showinternalattendee(){
        NBACMeetingController.errorMsginssub ='';
        if(currentERId != null){
            sobjEventReport = [Select Id, OwnerId, CurrencyIsoCode, Name,Report_Client_Contact__r.AccountId, Relate_to_Client__c from Call_Report__c where Id =: currentERId ];
            sObjEventOwner = [Select Id, Contact_Sync_ID__c from User where Id =:sobjEventReport.OwnerId];
            strReportCurrency = sobjEventReport.CurrencyIsoCode;
            lstAttendees = new List<InternalAttendeeWrapper>();
            getEventReportAttendee();
            getClientTeamMembers();
            addRow();
            lstAttendees.sort();
            showintattpanel = true;
            System.debug('++++showintattpanel'+showintattpanel);
            /*PageReference pf = new PageReference('/apex/Opportunity_Visibility');
            pf.setRedirect(True);
            return pf;*/
        }else{
            showerrormsg = True;
        }
        return null;
    }
    /***
Use
@param  	    :  String currentERId
@return   	    :  String
@ Description 	:  get a list of InternalAttendeeWrapper using currentERId
***/
    @AuraEnabled
    public Static String showinternalattendeeAura(String currentERId){
        NBACMeetingController.errorMsginssub ='';

        Call_Report__c sobjEventReport = [Select Id, OwnerId, CurrencyIsoCode, Name,Report_Client_Contact__r.AccountId, Relate_to_Client__c from Call_Report__c where Id =: currentERId ];
        User sObjEventOwner = [Select Id, Contact_Sync_ID__c from User where Id =:sobjEventReport.OwnerId];
        String strReportCurrency = sobjEventReport.CurrencyIsoCode;
        List<InternalAttendeeWrapper>   lstAttendees = CommitteeAttendee_ctrl.getEventReportAttendeeAura(currentERId,sObjEventOwner,strReportCurrency,sobjEventReport);
        lstAttendees.sort();

        return JSON.serialize(lstAttendees);
    }

    /***
Use
@param  	    :  String currentERId,User sObjEventOwner,String strReportCurrency,Call_Report__c sobjEventReport
@return   	    :  list of InternalAttendeeWrapper
@ Description 	:  method to get already existing event report attendees
***/
    public Static List<InternalAttendeeWrapper> getEventReportAttendeeAura(String currentERId,User sObjEventOwner,String strReportCurrency,Call_Report__c sobjEventReport){


        List<InternalAttendeeWrapper>   lstAttendees = new List<InternalAttendeeWrapper>();


        for(Call_Report_Attendees__c sObjReportAttendees : [Select Id, Contact_Id__c, Contact_Id__r.Id, Contact_Id__r.Name, Contact_Id__r.RecordType.DeveloperName, Send_Email__c, Status__c,Client_Team_Role__c
        FROM Call_Report_Attendees__c where Call_Report__c=:currentERId and Contact_Id__r.RecordType.DeveloperName='SA_Bank_Contact_Record_Type' and Type_of_Attendee__c = 'Committee Attendee']){

            InternalAttendeeWrapper objAttendees = new InternalAttendeeWrapper(sObjReportAttendees);
            if(sObjEventOwner.Contact_Sync_ID__c == sObjReportAttendees.Contact_Id__c){
                objAttendees.intOrder = '0';
            }
            lstAttendees.add(objAttendees);
        }
        lstAttendees.addAll(CommitteeAttendee_ctrl.getClientTeamMembersAura(strReportCurrency,currentERId,sobjEventReport));
        return lstAttendees;
    }
    /***
Use
@param  	    :  String currentERId
@return   	    :  Set of ID
@ Description 	:  method to get check Contacts that are already in the Call_Report_Attendees__c as Submission Attendee
***/
    public static Set<Id> getChecksubattId(String currentERId){

        Set<Id> setChecksubattId = new Set<Id>();
        for(Call_Report_Attendees__c subattendees :[Select Id, Contact_Id__c, Contact_Id__r.Id, Contact_Id__r.Name, Contact_Id__r.RecordType.DeveloperName, Send_Email__c, Status__c,Client_Team_Role__c
        FROM Call_Report_Attendees__c where Call_Report__c=:currentERId and Contact_Id__r.RecordType.DeveloperName='SA_Bank_Contact_Record_Type' and Type_of_Attendee__c = 'Submission Attendee']){
            setChecksubattId.add(subattendees.Contact_Id__c);
        }

        return setChecksubattId;
    }
    /***
Use
@param  	    :  String currentERId
@return   	    :  Set of ID
@ Description 	:  method to get check Contacts that are already in the Call_Report_Attendees__c as Committee Attendee
***/
    public static Set<Id> getCheckContactId(String currentERId){

        Set<Id> setCheckContactId = new Set<Id>();
        for(Call_Report_Attendees__c sObjReportAttendees : [Select Id, Contact_Id__c, Contact_Id__r.Id, Contact_Id__r.Name, Contact_Id__r.RecordType.DeveloperName, Send_Email__c, Status__c,Client_Team_Role__c
        FROM Call_Report_Attendees__c where Call_Report__c=:currentERId and Contact_Id__r.RecordType.DeveloperName='SA_Bank_Contact_Record_Type' and Type_of_Attendee__c = 'Committee Attendee']){

            setCheckContactId.add(sObjReportAttendees.Contact_Id__c);
        }

        return setCheckContactId;
    }
    /***
Use
@param  	    :  String strReportCurrency,String currentERId,Call_Report__c sobjEventReport
@return   	    :  list of InternalAttendeeWrapper
@ Description 	:  method to get the list of Client Team members
***/
    public Static List<InternalAttendeeWrapper> getClientTeamMembersAura(String strReportCurrency,String currentERId,Call_Report__c sobjEventReport){
        Set<Id> setCheckContactId = CommitteeAttendee_ctrl.getCheckContactId(currentERId);
        List<InternalAttendeeWrapper>   lstAttendees = new List<InternalAttendeeWrapper>();
        Map<Id, AccountTeamMember> mapContactId = new Map<Id, AccountTeamMember>();
        for(AccountTeamMember sObjAccTeamMember : [Select Id, User.Contact_Sync_ID__c, TeamMemberRole, AccountId
        from AccountTeamMember where AccountId =:sobjEventReport.Relate_to_Client__c]){
            if(setCheckContactId.add(sObjAccTeamMember.User.Contact_Sync_ID__c))
                mapContactId.put(sObjAccTeamMember.User.Contact_Sync_ID__c, sObjAccTeamMember);
        }

        if(!mapContactId.isEmpty()){

            Custom_Client_Team__c[] lstClientTeam= [Select Team_Member__r.Contact_Sync_ID__c, TeamRoleSortValue__c From Custom_Client_Team__c  where Account__c =: sobjEventReport.Relate_to_Client__c and Team_Member__r.Contact_Sync_ID__c IN :mapContactId.keyset()];
            map<Id, String> mapClientTeam = new map<Id, String>();
            for(Custom_Client_Team__c cct : lstClientTeam)
                mapClientTeam.put(cct.Team_Member__r.Contact_Sync_ID__c, cct.TeamRoleSortValue__c);

            for(Contact sObjContact: [Select Id, Name, Inactive__c From Contact where Id IN :mapContactId.keyset()]){
                CSTTeamRoleRanking__c sObjRanking = CSTTeamRoleRanking__c.getValues(mapContactId.get(sObjContact.Id).TeamMemberRole);
                String teamRole = mapContactId.get(sObjContact.Id).TeamMemberRole;
                String rank = '49';
                //if(sObjRanking != null)
                //rank = Integer.valueOf(sObjRanking.CSTTeamRoleRanking__c);
                rank = mapClientTeam.containsKey(sObjContact.Id) ?  mapClientTeam.get(sObjContact.Id) : '49';
                rank = rank.contains('_') ? '49' : rank;
                system.debug('##### rank is ' + rank);
                lstAttendees.add(new InternalAttendeeWrapper(false, sObjContact, currentERId, strReportCurrency, teamRole, rank));
            }
        }
        system.debug('@@lstAttendees@@'+lstAttendees.size() +'####'+lstAttendees);

        return lstAttendees;
    }


    // method to get already existing event report attendees
    public void getEventReportAttendee(){

        setCheckContactId = new Set<Id>();
        setChecksubattId = new Set<Id>();
        
        for(Call_Report_Attendees__c subattendees :[Select Id, Contact_Id__c, Contact_Id__r.Id, Contact_Id__r.Name, Contact_Id__r.RecordType.DeveloperName, Send_Email__c, Status__c,Client_Team_Role__c
                                                                    FROM Call_Report_Attendees__c where Call_Report__c=:currentERId and Contact_Id__r.RecordType.DeveloperName='SA_Bank_Contact_Record_Type' and Type_of_Attendee__c = 'Submission Attendee']){
               setChecksubattId.add(subattendees.Contact_Id__c);                                    
        }
        
        for(Call_Report_Attendees__c sObjReportAttendees : [Select Id, Contact_Id__c, Contact_Id__r.Id, Contact_Id__r.Name, Contact_Id__r.RecordType.DeveloperName, Send_Email__c, Status__c,Client_Team_Role__c
                                                                    FROM Call_Report_Attendees__c where Call_Report__c=:currentERId and Contact_Id__r.RecordType.DeveloperName='SA_Bank_Contact_Record_Type' and Type_of_Attendee__c = 'Committee Attendee']){
            
            InternalAttendeeWrapper objAttendees = new InternalAttendeeWrapper(sObjReportAttendees);
            if(sObjEventOwner.Contact_Sync_ID__c == sObjReportAttendees.Contact_Id__c){
                objAttendees.intOrder = '0';
            }
            lstAttendees.add(objAttendees);
            setCheckContactId.add(sObjReportAttendees.Contact_Id__c);
        }
    }
    // method to get the list of Client Team members
    public void getClientTeamMembers(){
        
        Map<Id, AccountTeamMember> mapContactId = new Map<Id, AccountTeamMember>();
        for(AccountTeamMember sObjAccTeamMember : [Select Id, User.Contact_Sync_ID__c, TeamMemberRole, AccountId 
                                                    from AccountTeamMember where AccountId =:sobjEventReport.Relate_to_Client__c]){
            if(setCheckContactId.add(sObjAccTeamMember.User.Contact_Sync_ID__c))
                mapContactId.put(sObjAccTeamMember.User.Contact_Sync_ID__c, sObjAccTeamMember);
        }
        
        if(!mapContactId.isEmpty()){

          Custom_Client_Team__c[] lstClientTeam= [Select Team_Member__r.Contact_Sync_ID__c, TeamRoleSortValue__c From Custom_Client_Team__c  where Account__c =: sobjEventReport.Relate_to_Client__c and Team_Member__r.Contact_Sync_ID__c IN :mapContactId.keyset()];
          map<Id, String> mapClientTeam = new map<Id, String>();
          for(Custom_Client_Team__c cct : lstClientTeam)
            mapClientTeam.put(cct.Team_Member__r.Contact_Sync_ID__c, cct.TeamRoleSortValue__c);

            for(Contact sObjContact: [Select Id, Name, Inactive__c From Contact where Id IN :mapContactId.keyset()]){
                CSTTeamRoleRanking__c sObjRanking = CSTTeamRoleRanking__c.getValues(mapContactId.get(sObjContact.Id).TeamMemberRole);
                String teamRole = mapContactId.get(sObjContact.Id).TeamMemberRole;
                String rank = '49';
                //if(sObjRanking != null)
                    //rank = Integer.valueOf(sObjRanking.CSTTeamRoleRanking__c);
                rank = mapClientTeam.containsKey(sObjContact.Id) ?  mapClientTeam.get(sObjContact.Id) : '49';
                rank = rank.contains('_') ? '49' : rank;
                system.debug('##### rank is ' + rank); 
                lstAttendees.add(new InternalAttendeeWrapper(false, sObjContact, currentERId, strReportCurrency, teamRole, rank));
            }
        }
        system.debug('@@lstAttendees@@'+lstAttendees.size() +'####'+lstAttendees);
    }


    public Pagereference addRow(){
        for(Integer i=0;i<4;i++){
            lstAttendees.add(new InternalAttendeeWrapper(false, null, currentERId, strReportCurrency, null ,'50'));
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
    public Static String addRowAura(string currentERId){
        Call_Report__c eventReport= [Select Id, OwnerId, CurrencyIsoCode, Name,Report_Client_Contact__r.AccountId, Relate_to_Client__c from Call_Report__c where Id =: currentERId ];
        InternalAttendeeWrapper newComm = new InternalAttendeeWrapper(false, null, currentERId, eventReport.CurrencyIsoCode, null ,'50');

        return JSON.serialize(newComm);
    }
    /***
Use
@param  	    :  string currentERIdsub,string currentAgendaIdsub
@return   	    :  JSON List of InternalAttendeeWrappersub as a string
@ Description 	:  create virtual object of InternalAttendeeWrappersub for cmp to use it as a new 4 row
***/
    @AuraEnabled
    public Static String add_4_RowAura(string currentERId){
        Call_Report__c eventReport= [Select Id, OwnerId, CurrencyIsoCode, Name,Report_Client_Contact__r.AccountId, Relate_to_Client__c from Call_Report__c where Id =: currentERId ];
        List<InternalAttendeeWrapper> newComList = new List<InternalAttendeeWrapper>();
        for(integer x=0;x<4;x++) {

            InternalAttendeeWrapper newComm = new InternalAttendeeWrapper(false, null, currentERId, eventReport.CurrencyIsoCode, null ,'50');
            newComList.add(newComm);
        }
        return JSON.serialize(newComList);
    }
    
    public Pagereference addRowonlink(){
        for(Integer i=0;i<4;i++){
            lstAttendees.add(new InternalAttendeeWrapper(false, null, currentERId, strReportCurrency, null ,'50'));
        }
        showintattpanel = true;
        errorMsginaddcommatt = '';
        return null;
    }
    
    public PageReference save(){
        errorMsginaddcommatt = '';
        List<Call_Report_Attendees__c> lstUpsertAttendee = new List<Call_Report_Attendees__c>();
        List<Call_Report_Attendees__c> lstRemoveAttendee = new List<Call_Report_Attendees__c>();
        setCheckContactId = new Set<Id>();
        Set<Id> setCheck = new Set<Id>();
        
        for(InternalAttendeeWrapper objAttendee: lstAttendees){
                if(objAttendee.bChecked){
                    if(objAttendee.sobjAttendee.Contact_Id__c==null){
                         errorMsginaddcommatt = '';
                         errorMsginaddcommatt = 'Attendee Name cannot be blank';
                         return null;
                    }
                    else if(setChecksubattId.contains(objAttendee.sobjAttendee.Contact_Id__c)){
                        objAttendee.bChecked = false;
                        errorMsginaddcommatt = '';
                        errorMsginaddcommatt = Label.Committee_already_a_Submission;
                        return null;
                    }
                   else if(setCheckContactId.add(objAttendee.sobjAttendee.Contact_Id__c)) {
                                setCheck.add(objAttendee.sobjAttendee.Contact_Id__c);
                                lstUpsertAttendee.add(objAttendee.sobjAttendee);
                    } else {
                        objAttendee.bChecked = false;
                        errorMsginaddcommatt = '';
                        errorMsginaddcommatt = 'You cannot select same Contact more than once, duplicate contact is unchecked.';
                        return null;
                    }
                } else {
                    if(setCheckContactId.add(objAttendee.sobjAttendee.Contact_Id__c) && objAttendee.sobjAttendee.Id != null) {
                        lstRemoveAttendee.add(objAttendee.sobjAttendee);
                    }
                }
        }
        List<Contact> lstCon = [Select Name From Contact where Id IN :setCheck and Inactive__c = true];
        if(!lstCon.isEmpty()){
            errorMsginaddcommatt = '';
            errorMsginaddcommatt = 'You cannot add an Inactive contact.';
            for(Contact sObjContact : lstCon){
                errorMsginaddcommatt +=  '<br/>'+ sObjContact.Name;
            }
        return null;
        }
        List<Contact> lstExternalCon = [Select Name, Inactive__c From Contact where Id IN :setCheck and RecordType.DeveloperName = 'SA_Client_Contact_Record_Type'];
        if(!lstExternalCon.isEmpty()){
            errorMsginaddcommatt = '';
            errorMsginaddcommatt = 'You cannot add an external contact.';
            for(Contact sObjContact : lstExternalCon){
                errorMsginaddcommatt +=  '<br/>'+ sObjContact.Name;
            }
        return null;
        }
        try{
            Delete lstRemoveAttendee;
            Upsert lstUpsertAttendee;
            showintattpanel = false;
            errorMsginaddcommatt = '';
            return null;
        } catch (Exception e){
            ApexPages.getMessages().clear();
            errorMsginaddcommatt = '';
            errorMsginaddcommatt = 'An error occured. '+ e.getMessage();
        }
        return null;
    }

    /***
Use
@param  	    :  string commAttendeeList,String currentERId
@return   	    :  JSON as a string
@ Description 	:  create or edit Commitee Attendees
***/
    @AuraEnabled
    public Static String saveCommitteAttendee(string commAttendeeList,String currentERId){
        JSONGenerator jsonGen = JSON.createGenerator(true);
        try{
        List<Call_Report_Attendees__c> lstUpsertAttendee = new List<Call_Report_Attendees__c>();
        List<Call_Report_Attendees__c> lstRemoveAttendee = new List<Call_Report_Attendees__c>();
        Set<Id> setCheckContactId =  new Set<Id>();
        Set<Id> setChecksubattId = CommitteeAttendee_ctrl.getChecksubattId(currentERId);
        Set<Id> setCheck = new Set<Id>();
        Boolean isErrors = false;

        List<InternalAttendeeWrapper> lstAttendees = (List<InternalAttendeeWrapper>)JSON.deserialize(commAttendeeList, List<InternalAttendeeWrapper>.class);
        for(InternalAttendeeWrapper objAttendee: lstAttendees){
            if(objAttendee.bChecked){
                if(objAttendee.sobjAttendee.Contact_Id__c==null){

                    objAttendee.isError=true;
                    objAttendee.errorMessage= 'Attendee Name cannot be blank';
                    isErrors =true;
                }
                else if(setChecksubattId.contains(objAttendee.sobjAttendee.Contact_Id__c)){
                    objAttendee.bChecked = false;
                    objAttendee.isError=true;
                    objAttendee.errorMessage= Label.Committee_already_a_Submission;
                    isErrors =true;
                }
                else if(setCheckContactId.add(objAttendee.sobjAttendee.Contact_Id__c)) {
                    setCheck.add(objAttendee.sobjAttendee.Contact_Id__c);
                    lstUpsertAttendee.add(objAttendee.sobjAttendee);
                } else {
                    objAttendee.bChecked = false;
                    objAttendee.isError=true;
                    objAttendee.errorMessage= 'You cannot select same Contact more than once, duplicate contact is unchecked.';
                    isErrors =true;
                }
            } else {
                if(setCheckContactId.add(objAttendee.sobjAttendee.Contact_Id__c) && objAttendee.sobjAttendee.Id != null) {
                    lstRemoveAttendee.add(objAttendee.sobjAttendee);
                }
            }
        }
        if(isErrors){

            return System.JSON.serialize(lstAttendees);
        }
        List<Contact> lstCon = [Select Name,Id From Contact where Id IN :setCheck and Inactive__c = true];
        if(!lstCon.isEmpty()){

            for(InternalAttendeeWrapper objAttendee: lstAttendees) {

                for (Contact sObjContact : lstCon) {

                    if (objAttendee.sobjAttendee.Contact_Id__c == sObjContact.Id) {
                        objAttendee.isError=true;
                        objAttendee.errorMessage= 'You cannot add an Inactive contact.';
                    }
                }
            }

            return System.JSON.serialize(lstAttendees);
        }
        List<Contact> lstExternalCon = [Select Name, Inactive__c,Id From Contact where Id IN :setCheck and RecordType.DeveloperName = 'SA_Client_Contact_Record_Type'];
        if(!lstExternalCon.isEmpty()){

            for(InternalAttendeeWrapper objAttendee: lstAttendees) {

                for (Contact sObjContact : lstExternalCon) {

                    if (objAttendee.sobjAttendee.Contact_Id__c == sObjContact.Id) {
                        objAttendee.isError=true;
                        objAttendee.errorMessage= 'You cannot add an external contact.';
                    }
                }
            }
            return System.JSON.serialize(lstAttendees);
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

    /***
Use
@param  	    :  none
@return   	    :  JSON as a string
@ Description 	:  get pickList values of the status
***/
    @AuraEnabled
    public static String getCommitteeAttendeesStatusOptions() {
        Schema.DescribeFieldResult f = Call_Report_Attendees__c.Status__c.getDescribe();
        return system.JSON.serialize(prepareCommitteeAttendeesStatusFromDescribeFieldResult(f));
    }
    /***
Use
@param  	    :  Schema.DescribeFieldResult f
@return   	    :  List of Mapped strings
@ Description 	:  get pickList values of the status
***/
    private Static List<Map<string,string>> prepareCommitteeAttendeesStatusFromDescribeFieldResult(Schema.DescribeFieldResult f) {

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
    
    public class InternalAttendeeWrapper implements Comparable {
        
      public String intOrder {get;set;}
      public Boolean bChecked  {get;set;}
      public Call_Report_Attendees__c sobjAttendee {get;set;}
      public String teamRole {get;set;}
        public Boolean isError {get;set;}
        public String errorMessage {get;set;}
      
      public InternalAttendeeWrapper(Boolean bChecked, Contact sObjContact, Id idEventReport, String strReportCurrency, String teamRole, String intOrder){
          this.bChecked = bChecked;
          this.intOrder = intOrder;
          this.teamRole = teamRole;
          this.isError = false;
          this.errorMessage = '';
          sobjAttendee = new Call_Report_Attendees__c();
          if(sObjContact!=null)
              sobjAttendee.Contact_Id__c = sObjContact.Id;
          sobjAttendee.Status__c = 'Invited';
          sobjAttendee.CurrencyIsoCode = strReportCurrency;
          sobjAttendee.Call_Report__c = idEventReport;
          sobjAttendee.Send_Email__c = 'Yes';
          sobjAttendee.Type_of_Attendee__c = 'Committee Attendee';
      }
      
      public InternalAttendeeWrapper(Call_Report_Attendees__c sobjAttendee){
          bChecked = true;
          intOrder = '00';
          this.sobjAttendee = sobjAttendee;
          this.isError = false;
          this.errorMessage = '';
          teamRole = sobjAttendee.Client_Team_Role__c;
      }
      
      public Integer compareTo(Object obj){
          InternalAttendeeWrapper compareToAttendee = (InternalAttendeeWrapper)obj;
          if(this.intOrder == compareToAttendee.intOrder)
              return 0;
          else
              if(this.intOrder > compareToAttendee.intOrder)
                  return 1;
              else
                    return -1;
      }
    }
    
    public Pagereference intattclose(){
        showintattpanel = false;
        errorMsginaddcommatt = '';
        return null;
    }
    
    public Pagereference errclose(){
        showerrormsg = false;
        errorMsginaddcommatt = '';
        return null;
    }
    
}