/*************************************************************************\
    @ Author        :     Vaishali Singh
    @ Date          :     24 Mar 2013
    @ Test File     :     
    @ Description   :      Controller to add and update internal attendees

    @ Last Modified By  : Petr Roubal
    @ Last Modified On  : 5/5/2015
    @ Last Modified Reason  : Def-001219 Core Client Team members are NOT listed at the top according to ranking
    
    @ Last Modified By  : Abhishek V
    @ Last Modified On  : 5/16/2016
    @ Last Modified Reason  : US - 1234 - Modified condition to add event report attendees to allow duplicate attendees for submission attendees

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : June 15, 2016
    @ Last Modified Reason  : US-1355 - Ensuring at least 2 Core Team Members exist on Internal Core Meetings

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : July 7, 2016
    @ Last Modified Reason  : US-1414 - changing the condition when the check on 2 core team members happens
    
    @ Last Modified By  : Abhishek V
    @ Last Modified On  : November 22, 2016
    @ Last Modified Reason  : US-1670 - Check if 2 Core Team Members exists on Internal Core Meetings initially before save to show error message on Lightning
    
    @ Last Modified By  :   Abhishek V
    @ Last Modified On  :   Nov 25, 2016
    @ Last Modified Reason  : US-1699 : Introduced active filter while fetching CST members
****************************************************************************/ 
public class AddInternalAttendeesCtrl {
    
    public String strReportCurrency {get;set;}
    public Id idEventReport = ApexPages.currentPage().getParameters().get('reportid');
    public List<InternalAttendeeWrapper> lstAttendees {get;set;}
    public Call_Report__c sobjEventReport {get;set;}
    public User sObjEventOwner {get;set;}
    private Set<Id> setCheckContactId;
    public boolean checkcoreinit{get;set;}
    
    private Boolean checkCoreCSTInvitees;
    private Map<String, CSTTeamRoleRanking__c> coreTeamRoles = CSTTeamRoleRanking__c.getAll();
    
    public AddInternalAttendeesCtrl(){
        
        sobjEventReport = [Select Id, OwnerId, CurrencyIsoCode, Name,Report_Client_Contact__r.AccountId, Relate_to_Client__c, Enforce_Core_Attendee_Validation__c from Call_Report__c where Id =:idEventReport];
        checkCoreCSTInvitees = sobjEventReport.Enforce_Core_Attendee_Validation__c;
        sObjEventOwner = [Select Id, Contact_Sync_ID__c from User where Id =:sobjEventReport.OwnerId];
        strReportCurrency = sobjEventReport.CurrencyIsoCode;
        lstAttendees = new List<InternalAttendeeWrapper>();
        getEventReportAttendee();
        getClientTeamMembers();
        addRow();
        lstAttendees.sort();
        system.debug(lstAttendees);
    }
    // method to get already existing event report attendees
    public void getEventReportAttendee(){
        Integer corecnt = 0;
        setCheckContactId = new Set<Id>();
        
        for(Call_Report_Attendees__c sObjReportAttendees : [Select Id, Contact_Id__c, Contact_Id__r.Id, Contact_Id__r.Name, Contact_Id__r.RecordType.DeveloperName, Send_Email__c, Status__c,Client_Team_Role__c,  Type_of_Attendee__c, Related_Agenda__c, CompositeKey__c
                                                                    FROM Call_Report_Attendees__c where Call_Report__c=:idEventReport and Contact_Id__r.RecordType.DeveloperName='SA_Bank_Contact_Record_Type']){
            InternalAttendeeWrapper objAttendees = new InternalAttendeeWrapper(sObjReportAttendees);
            if(sObjEventOwner.Contact_Sync_ID__c == sObjReportAttendees.Contact_Id__c){
                objAttendees.bReportOwner = true;
                objAttendees.intOrder = '0';
            }
            if(coreTeamRoles.keySet().contains(sObjReportAttendees.Client_Team_Role__c)){
                corecnt++;
            }
            
            lstAttendees.add(objAttendees);
            setCheckContactId.add(sObjReportAttendees.Contact_Id__c);
        }
        
        if(checkCoreCSTInvitees && (corecnt < 2)){
            checkcoreinit = true;
        }else{
            checkcoreinit = false;
        }
    }
    // method to get the list of Client Team members
    public void getClientTeamMembers(){
        
        Map<Id, AccountTeamMember> mapContactId = new Map<Id, AccountTeamMember>();
        for(AccountTeamMember sObjAccTeamMember : [Select Id, User.Contact_Sync_ID__c, TeamMemberRole, AccountId 
                                                    from AccountTeamMember where AccountId =:sobjEventReport.Relate_to_Client__c and User.IsActive = true]){
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
                InternalAttendeeWrapper objAttendee = new InternalAttendeeWrapper(false, sObjContact, idEventReport, strReportCurrency, teamRole, rank);
                // to disable checkbox if ERA has not yet been created (future method) when this runs
                if(sObjEventOwner.Contact_Sync_ID__c == objAttendee.sobjAttendee.Contact_Id__c){
                    objAttendee.bReportOwner = true;
                    objAttendee.intOrder = '0';
                    objAttendee.bChecked = true;
                }                
                lstAttendees.add(objAttendee);
            }
        }
        system.debug('@@lstAttendees@@'+lstAttendees.size() +'####'+lstAttendees);
    }
    
    
    public void addRow(){
        for(Integer i=0;i<4;i++){
            lstAttendees.add(new InternalAttendeeWrapper(false, null, idEventReport, strReportCurrency, null ,'50'));
        }
    }
    
    public PageReference save(){
        List<Call_Report_Attendees__c> lstUpsertAttendee = new List<Call_Report_Attendees__c>();
        List<Call_Report_Attendees__c> lstRemoveAttendee = new List<Call_Report_Attendees__c>();
        setCheckContactId = new Set<Id>();
        Set<Id> setCheck = new Set<Id>();
        //logic based on setsubmissionCheck was added to allow submission attendee duplication - US - 1234
        Set<String> setsubmissionCheck = new Set<String>();
        Integer coreAttendeesCnt = 0;
        
        for(InternalAttendeeWrapper objAttendee: lstAttendees){
                if(objAttendee.bChecked){
                    setCheckContactId.add(objAttendee.sobjAttendee.Contact_Id__c);
                    if(objAttendee.sobjAttendee.Contact_Id__c==null){
                        objAttendee.sobjAttendee.Contact_Id__c.addError('Please enter a value');
                    }
                    else if(setsubmissionCheck.add(objAttendee.sobjAttendee.Contact_Id__c +''+ objAttendee.sobjAttendee.Related_Agenda__c)) {
                                setCheck.add(objAttendee.sobjAttendee.Contact_Id__c);
                                lstUpsertAttendee.add(objAttendee.sobjAttendee);
                                if (coreTeamRoles.keySet().contains(objAttendee.teamRole)) {
                                    coreAttendeesCnt++;
                                }
                    } else {
                        objAttendee.bChecked = false;
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Error, 'You cannot select same Contact more than once, duplicate contact is unchecked.'));
              return null;
                    }
                } else {
                    //if(setCheckContactId.add(objAttendee.sobjAttendee.Contact_Id__c) && objAttendee.sobjAttendee.Id != null) {
                    if(objAttendee.sobjAttendee.Id != null) {
                        lstRemoveAttendee.add(objAttendee.sobjAttendee);
                    }
                }
        }
        List<Contact> lstCon = [Select Name From Contact where Id IN :setCheck and Inactive__c = true];
        if(!lstCon.isEmpty()){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Error, 'You cannot add an Inactive contact.'));
            for(Contact sObjContact : lstCon){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Error, sObjContact.Name));
            }
        return null;
        }
        List<Contact> lstExternalCon = [Select Name, Inactive__c From Contact where Id IN :setCheck and RecordType.DeveloperName = 'SA_Client_Contact_Record_Type'];
        if(!lstExternalCon.isEmpty()){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Error, 'You cannot add an external contact.'));
            for(Contact sObjContact : lstExternalCon){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Error, sObjContact.Name));
            }
        return null;
        }
        if (checkCoreCSTInvitees && coreAttendeesCnt < 2) {
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Error, 'Internal core client team meetings require at least 2 core client team members in the Attendees section.'));
            return null;
        }
        try{
            Delete lstRemoveAttendee;
            
            // synthesize compositeKey__c for added rows
            for (Call_Report_Attendees__c cra: lstUpsertAttendee) {
                if (String.isEmpty(cra.compositeKey__c) && !String.isEmpty(cra.contact_id__c) && !String.isEmpty(cra.call_report__c)) {
                    cra.compositeKey__c = String.valueOf(cra.contact_id__c).left(15) + String.valueOf(cra.call_report__c).left(15); // make it compatible with the value constructed in WR
                }
            }
            Upsert lstUpsertAttendee CompositeKey__c;
            return new PageReference('/'+idEventReport);
        } catch (Exception e){
            ApexPages.getMessages().clear();
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Error, 'An error occured. '+ e.getMessage()));
        }
        return null;
    }
    
    public PageReference cancel(){
        return new PageReference('/'+idEventReport);
    }
    
    public class InternalAttendeeWrapper implements Comparable {
        
        public String intOrder {get;set;}
        public Boolean bChecked  {get;set;}
        public Call_Report_Attendees__c sobjAttendee {get;set;}
      public Boolean bReportOwner {get;set;}
      public String teamRole {get;set;}
      
      public InternalAttendeeWrapper(Boolean bChecked, Contact sObjContact, Id idEventReport, String strReportCurrency, String teamRole, String intOrder){
          this.bChecked = bChecked;
          this.intOrder = intOrder;
          this.teamRole = teamRole;
          sobjAttendee = new Call_Report_Attendees__c();
          if(sObjContact!=null)
              sobjAttendee.Contact_Id__c = sObjContact.Id;
          sobjAttendee.Status__c = 'Invited';
          sobjAttendee.CurrencyIsoCode = strReportCurrency;
          sobjAttendee.Call_Report__c = idEventReport;
          sobjAttendee.Send_Email__c = 'Yes';
          if (sObjContact != null && !String.isEmpty(sObjContact.id) && !String.isEmpty(idEventReport)) {
            sobjAttendee.CompositeKey__c = String.valueOf(sObjContact.Id).left(15) + String.valueOf(idEventReport).left(15); // make it compatible with the value constructed in WR
          }
      }
      
      public InternalAttendeeWrapper(Call_Report_Attendees__c sobjAttendee){
          bChecked = true;
          intOrder = '00';
          this.sobjAttendee = sobjAttendee;
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
}