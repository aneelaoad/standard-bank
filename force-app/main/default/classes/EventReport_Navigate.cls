/***************************************
Created By: Abhishek V
Created on: 06/07/2016
Description: US - 1379: Class to redirect Event report based on Record type

Last Modified By: Manoj Gupta
Description: DEF-002349,Prepopulation of Event Report fields not populating when creating from Event Report tab
Last Modified Date: 19 Jan 2017

Last Modified By : Upender Nath Sharma
Description : US-1823
Last Modified Date : 09 Feb 2017

Last Modified By : Upender Nath Sharma
Description : US-1864
Last Modified Date : 20 Feb 2017

Last Modified By : Maciej Jaźnicki
Description : US-3650
Last Modified Date : 05 Apr 2019

********************************************/

public without sharing class EventReport_Navigate{

    public String reportId = '';
    public String eventId = '';
    public String newURLedit{get;set;}
    public ID newURLRTID{get; set;}
    public boolean isNBAC{get; set;}
    public boolean isMeeting{get;set;}
    public String newURLnew{get;set;}
    private final Boolean isLightning;
    public boolean lightningEnv{get;set;}
    public String selectedRT {get;set;}
    
    public List<RecordType> rtlstdetails{
        get{
            List<RecordType> rtlst = new List<RecordType>();
            List<String> namesRt = new List<String>();
            List<RecordTypeInfo> rtlsttemp = Schema.Call_Report__c.SObjectType.getDescribe().getRecordTypeInfos();
            for(RecordTypeInfo rti : rtlsttemp){
                if(rti.isAvailable()){
                    namesRt.add(rti.getName());
                }
            }
            rtlst = [Select ID, Name, Description from RecordType where SobjectType = 'Call_Report__c' and Name IN :namesRt];
            return rtlst ;
        } set;
    }
    
    public Boolean getIsLightning() {
        return this.isLightning;
    }

    public Boolean getIsClassic() {
        return !this.isLightning;
    }
    
    public List<SelectOption> getrecordtypevalues() {
        List<SelectOption> options = new List<SelectOption>();
        for(RecordType rt: rtlstdetails){
            options.add(new SelectOption(rt.Name,rt.Name));
        }
        return options;
    }

    
    private Boolean isPageOriginLightning(Map<String, Object> params) {
        if (params.get('sfdcIFrameHost') != null ||
            params.get('sfdcIFrameOrigin') != null ||
            params.get('isdtp') == 'p1') {      
                return true;
            } else {      
                return false;
            }
    }
    
    public EventReport_Navigate(ApexPages.StandardController stdController){
        this.isLightning = isPageOriginLightning(ApexPages.currentPage().getParameters());
        if(rtlstdetails.size() == 1) {
            selectedRT = rtlstdetails[0].Name;
            continuemethod();
        }
    }
    
    public void continuemethod(){
        if(isLightning){
            lightningEnv = true;
        }
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Call_Report__c;
        Map<String, Schema.RecordTypeInfo> EventRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id nbacMeetingRtId = EventRecordTypeInfo.get('NBAC Meeting').getRecordTypeId();
        Id emrtId = EventRecordTypeInfo.get('Meeting').getRecordTypeId();
        if(selectedRT == 'Meeting') {
            ApexPages.currentPage().getParameters().put('RecordType',emrtId);
        }else {
            ApexPages.currentPage().getParameters().put('RecordType', nbacMeetingRtId);
        }
        navigateNew();
    }
    
    public void navigateNew(){

            Boolean boolentered = false;
            Map<String,String> paramMap = ApexPages.currentPage().getParameters();
            Schema.DescribeSObjectResult d = Schema.SObjectType.Call_Report__c;
            String keyPrefix = d.getKeyPrefix();
            String newURL =  '/';
            
            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Call_Report__c;
            Map<String, Schema.RecordTypeInfo> EventRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
            Id nbacrtId = EventRecordTypeInfo.get('NBAC Meeting').getRecordTypeId();
            Id emrtId = EventRecordTypeInfo.get('Meeting').getRecordTypeId();
        String loggedInUserName = userInfo.getName() ;
            DateTime startDateTime = system.now();
            DateTime endDateTime = startDateTime.addHours(1);
            String startDateStr = startDateTime.format() ;
            String endDateStr = endDateTime.format();
            
            if(paramMap.containsKey('RecordType')){
                if((ApexPages.currentPage().getParameters().get('RecordType') == nbacrtId)){
                    newURL = newURL + 'apex/MeetingConsole';
                    newURLRTID = nbacrtId;
                    isNBAC = True;
                    isMeeting = false;
                }else{
                    newURL +=  keyPrefix +'/e?';
                    newURLRTID = emrtId;
                    isNBAC = false;
                    isMeeting = True;
                    for(String pars: paramMap.keyset()){
                        if(pars != 'save_new' && pars != 'sfdc.override'){
                            newURL += pars + '=' +  paramMap.get(pars);
                            newURL += '&';
                        }
                    }
                    
                    if(!newURL.contains('RecordType')){
                        boolentered = true;
                        newURL = newURL  + 'RecordType=' + emrtId;
                    }
                    
                    if(boolentered == True){
                        newURL += '&nooverride=1';
                    }else{
                        newURL += '&CF00N200000024QsA='+ loggedInUserName + '&00N200000024RDK=' + startDateStr  + '&00N200000024RD7=' + endDateStr  + '&Name=' + label.EventReportDefaultName +'&nooverride=1';
                        newURL = newURL + '&saveURL=/apex/RedirectToAddAttendees';
                    }
                }
            }else{
                newURLRTID = null;
            }
            newURLnew = newURL;

    }
        
    public void navigateEdit(){
        
            ID EventReportID = ApexPages.currentPage().getParameters().get('id');
            Map<String,String> paramMapedit = ApexPages.currentPage().getParameters();
            newURLedit =  '/';
            String ERRecTypeName = getEventReportRT(EventReportID);
            
            
            if(ERRecTypeName == 'NBAC Meeting'){
                newURLedit = newURLedit + 'apex/MeetingConsole?id='+EventReportID;
                isMeeting = false;
            }else{
                newURLedit +=  EventReportID +'/e?';
                
                for(String pars: paramMapedit.keyset()){
                    if(pars != 'save_new' && pars != 'sfdc.override' && pars != 'id'){
                        newURLedit += pars + '=' +  paramMapedit.get(pars);
                        newURLedit += '&';
                    }
                }
                
               newURLedit += 'nooverride=1';
               isMeeting = true;
               
            }
    }
    
    public String navigateViewURL{
        get{


            Map<String,String> paramMap = ApexPages.currentPage().getParameters();

            String newURL = buildURL();

            if (!(newUrl.length() < 15)) {
                if(paramMap.containsKey('retURL')){
                    if(!newURL.containsAny('?')){
                        newURL = newURL + '?retURL=' + EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('retURL'),'UTF-8');
                    }else{
                        newURL = newURL + '&retURL=' + EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('retURL'),'UTF-8');
                    }
                }
                
            }
            
            return newURL; 
        }
        set; 
    }
    
    public String buildURL(){
        
        String URL = '/';
        reportId = ApexPages.currentPage().getParameters().get('id');
        Call_Report__c cr = [SELECT Meeting_Purpose__c, Date__c FROM Call_Report__c WHERE Id = :reportId];


        String RECtypeName = getEventReportRT(reportId);

        if(RECtypeName != '' && RECtypeName == 'NBAC Meeting'){
            URL = URL + 'apex/MeetingConsole?id='+reportId;
        } else {
            URL = URL + reportId+'?nooverride=1';
        }
        return URL;
        
    }
    
    public String getEventReportRT(String eventID){
        
        String rectypename = '';

        List<Call_Report__c> eventReportList = new List<Call_Report__c>([select id,Eventid__c, RecordType.Name from Call_Report__c where ID =:eventID]);
        
        if(eventReportList.size() > 0){
            rectypename = eventReportList[0].RecordType.Name;

        }
        if(rectypename != null && rectypename != ''){
            return rectypename;
        }else{
            return '';
        }
    } 

}