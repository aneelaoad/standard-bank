/*************************************************************************\
    @ Author        :     Prabhanshu Agrawal
    @ Date          :     Apr 2015
    @ Test File     :     AddExternalAttendeesController_Test
    @ Description   :     Controller to add and update external attendees

    @ Last Modified By  	: 
    @ Last Modified On  	: 
    @ Last Modified Reason  : 
****************************************************************************/ 
public class AddExternalAttendeesController {
    
    public Id idEventReport {get;set;}
    public List<externalAttendeeWrapper> lstAttendees {get;set;}
    public Call_Report__c sobjEventReport {get;set;}
    private Set<Id> setCheckContactId;
    
    
    public AddExternalAttendeesController(){
        
		idEventReport = ApexPages.currentPage().getParameters().get('reportid');
        sobjEventReport = [Select Id, OwnerId, Name, Report_Client_Contact__c, Report_Client_Contact__r.AccountId, 
        							Relate_to_Client__c from Call_Report__c where Id =: idEventReport];
        lstAttendees = new List<externalAttendeeWrapper>();
        getEventReportAttendee();
        getClientContacts();
        addRow();
    }
    // method to get already existing event report attendees
    public void getEventReportAttendee(){
        
        setCheckContactId = new Set<Id>();
        
        for(Call_Report_Attendees__c sObjReportAttendees : [Select Id, Contact_Id__c, Contact_Id__r.Id, Contact_Id__r.Name, Contact_Id__r.Title, 
        															Contact_Id__r.RecordType.DeveloperName, Status__c
        															FROM Call_Report_Attendees__c 
        															where Call_Report__c =: idEventReport 
        															and Contact_Id__r.RecordType.DeveloperName='SA_Client_Contact_Record_Type']){
            
            externalAttendeeWrapper objAttendees = new externalAttendeeWrapper(sObjReportAttendees);
            if(sobjEventReport.Report_Client_Contact__c == sObjReportAttendees.Contact_Id__c)
                objAttendees.bReportOwner = true;
            lstAttendees.add(objAttendees);
            setCheckContactId.add(sObjReportAttendees.Contact_Id__c);
        }
    }
    // method to get the list of Client Contact
    public void getClientContacts(){
        
		for(Contact sObjContact: [Select Id, Name, Inactive__c, Title From Contact 
									where AccountId =: sobjEventReport.Relate_to_Client__c 
									and RecordType.DeveloperName='SA_Client_Contact_Record_Type'
									and Inactive__c != true
									and Id Not IN : setCheckContactId
									order by SystemModstamp Desc limit 100]){
        	lstAttendees.add(new externalAttendeeWrapper(false, sObjContact, idEventReport, sObjContact.Title));
        }
    }
        
    public void addRow(){
        for(Integer i=0;i<4;i++){
            lstAttendees.add(new externalAttendeeWrapper(false, null, idEventReport, ''));
        }
    }
    
    public PageReference save(){
        List<Call_Report_Attendees__c> lstUpsertAttendee = new List<Call_Report_Attendees__c>();
        List<Call_Report_Attendees__c> lstRemoveAttendee = new List<Call_Report_Attendees__c>();
        setCheckContactId = new Set<Id>();
        Set<Id> setCheck = new Set<Id>();
        
        for(externalAttendeeWrapper objAttendee: lstAttendees){
                if(objAttendee.bChecked){
                    if(objAttendee.sobjAttendee.Contact_Id__c == null){
                        objAttendee.sobjAttendee.Contact_Id__c.addError('Please enter a value');
                    }
                    else if(setCheckContactId.add(objAttendee.sobjAttendee.Contact_Id__c)) {
                    	setCheck.add(objAttendee.sobjAttendee.Contact_Id__c);
                        lstUpsertAttendee.add(objAttendee.sobjAttendee);
                    } else {
                        objAttendee.bChecked = false;
                        ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Error, 'You cannot select same Contact more than once, duplicate contact is unchecked.'));
    					return null;
                    }
                } else {
                    if(setCheckContactId.add(objAttendee.sobjAttendee.Contact_Id__c) && objAttendee.sobjAttendee.Id != null) {
                        lstRemoveAttendee.add(objAttendee.sobjAttendee);
                    }
                }
        }
        List<Contact> lstCon = [Select Name From Contact where Id IN : setCheck and Inactive__c = true];
        if(!lstCon.isEmpty()){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Error, 'You cannot add an Inactive contact.'));
            for(Contact sObjContact : lstCon){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Error, sObjContact.Name));
            }
    		return null;
        }
        List<Contact> lstInternalCon = [Select Name, Inactive__c From Contact where Id IN :setCheck and RecordType.DeveloperName = 'SA_Bank_Contact_Record_Type'];
        if(!lstInternalCon.isEmpty()){
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Error, 'You cannot add an internal contact.'));
            for(Contact sObjContact : lstInternalCon){
                ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Error, sObjContact.Name));
            }
    		return null;
        }
        try{
            Delete lstRemoveAttendee;
            Upsert lstUpsertAttendee;
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
    
    public class externalAttendeeWrapper{
        
        public Boolean bChecked	{get;set;}
        public Call_Report_Attendees__c sobjAttendee {get;set;}
    	public Boolean bReportOwner {get;set;}
    	public String Title {get;set;}
    	
    	public externalAttendeeWrapper(Boolean bChecked, Contact sObjContact, Id idEventReport, String Title){
	    	
            this.bChecked = bChecked;
    	    this.sobjAttendee = new Call_Report_Attendees__c();
    	    this.Title = Title;
    	    if(sObjContact!=null)
    	        this.sobjAttendee.Contact_Id__c = sObjContact.Id;
	        this.sobjAttendee.Status__c = 'Invited';
    	    this.sobjAttendee.Call_Report__c = idEventReport;
    	}
    	
    	public externalAttendeeWrapper(Call_Report_Attendees__c sobjAttendee){
    	    bChecked = true;
    	    this.sobjAttendee = sobjAttendee;
    	    this.Title = sobjAttendee.Contact_id__r.Title;
    	}
    }
}