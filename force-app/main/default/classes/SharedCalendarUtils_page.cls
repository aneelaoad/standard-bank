global with sharing class SharedCalendarUtils_page extends PageControllerBase {

// Constructor
    public SharedCalendarUtils_page () { 
        hasHierarchy = false;
        singleClientView = false;
        isCustomView = false;
        pref = new SharedCalPrefs();
        String filterId = recentFilterViewId;
        if (filterId != null && filterId != '') {
         currentView = filterId;
         if (recentFilter.View_Type__c == 'Custom') { isCustomView = true;} else {isCustomView = false;}
        }
    }
    
        //JN Added to Update Custom setting for recent record on page load 
    public PageReference updateRecentViewed(){
        String calledFrom = qstr('calledFrom');
        if ( ( calledFrom == null ) || ( calledFrom == 'homePage') ) {
        // called from Home Page button - fetch recent calendar type and filter view from custom settings
            if ( pref.RecentFilter == null ) {
            // user has not viewed anything before - set view to default
                saveRecentRecord('Single Client',null,null);
            }
            String tabName = qstr('sfdc.tabName'); // Called from shared cal visualforce tab
            if ( ( pref.RecentRecord != null ) && ( ( qstr( 'recordId' ) == 'None' ) || ( tabName != null ) ) ) {
                //********************HomePage with previously viewed calendar
                PageReference reloadPage = Page.SharedCalendar;
                reloadPage.getParameters().put('recordId',pref.RecentRecord);
                reloadPage.getParameters().put('calType','Client');
                reloadPage.getParameters().put('callFrom','homePage');
                reloadPage.setRedirect(true);
                return reloadPage;            
            }
        } else if ( calledFrom == 'detailPage') {
        // called from record detail page button - update custom settings with 'Single Client' view and record Id
                saveRecentRecord('Single Client',null,qstr('recordId'));
                singleClientView = true;
        } else if ( calledFrom == 'hierarchyPage' ) {
        // called from shared calendar page crt Hierarchy click - update custom settings with 'Single Client' view
            if (recentChildren == 'true') {
                saveRecentRecord('CRT Client Hierarchy',null,qstr('recordId'));
                singleClientView = true;
            } else {
                saveRecentRecord('Single Client',null,qstr('recordId'));
                singleClientView = true;
            }
        } 
        pref = new SharedCalPrefs();
        if (pref.RecentFilter != null) {
            currentView = pref.RecentFilter;
            if (recentFilter.View_Type__c == 'Custom') { isCustomView = true;} else {isCustomView = false;}
        }
        String currentFilterName = pref.RecentFilterName;
        renderLegend = false;
        if (currentFilterName != null) {
                if ( currentFilterName == 'Single Client' || currentFilterName == 'CRT Client Hierarchy' ) { 
                    if ( pref.RecentRecord != null && pref.RecentRecord != ''){
                        String currentRecord = pref.RecentRecord;
                        try{
                            Calendar_Content__c calendarContentObject = [Select Hierarchy_Object_Name__c,Hierarchy_Relation_Field__c from Calendar_Content__c where Calendar_Type__r.Name = 'Client' and Name = 'Client Events'];     
                            selectedRecord = Database.query('select id,name,' +calendarContentObject.Hierarchy_Relation_Field__c +' from '+calendarContentObject.Hierarchy_Object_Name__c +' where id = :currentRecord limit 1');
                            setHierarchy(currentRecord,'Client');
                       }catch (Exception e) {
                            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()+' *** Shared Calendar Should NOT be used for All Client View ***'));
                       }
                       renderLegend = true;
                    } else {
                    // No current record for single client / hierarchy view add message if no previous message was added.
                        if ( !ApexPages.hasMessages() ) {
                            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, 'Please search for a Client in the Select Client input box or select an alternative view'));
                        }
                    }
                } else {
                    renderLegend = true;
                // CR: TODO Handle other views here if neccessary
                }
        }
        return null;   
    }
    
    Public boolean isCustomView { get; private set;}
    
  /******************Used in setting the date format for a new event based on the users locale */ 
    Public Static String newDateFormat { get; private set; } {
          String userLocaleSid = UserInfo.getLocale(); 
          if (userLocaleSid == 'zh_CN') newDateFormat = 'yyyy-M-d';
          if (userLocaleSid == 'zh_HK') newDateFormat = 'yyyy年M月d日';
          if (userLocaleSid == 'en_AU' || userLocaleSid == 'en_GH' || userLocaleSid == 'en_NG' || userLocaleSid == 'en_GB' || userLocaleSid == 'pt_BR' || userLocaleSid == 'es_AR' ) newDateFormat = 'dd/MM/yyyy';
          if (userLocaleSid == 'tr') newDateFormat = 'dd.MM.yyyy';
          if (userLocaleSid == 'en_US') newDateFormat = 'M/d/yyyy';
          if (userLocaleSid == 'en_ZA') newDateFormat = 'yyyy/MM/dd';
          if (newDateFormat == null) newDateFormat = 'dd/MM/yyyy';       
        }
/**********************************************************************************************/ 
    public void saveRecentRecord(String filterName, String filterId, String recordId ) {
        try {
            Shared_Calendar_Prefs__c setting = SharedCalPrefs.getSettings( UserInfo.getUserId());
            if ( null != filterName && null != filterId ){
                setting.Recent_Filter_Name__c = filterName;
                setting.Recent_Filter__c = filterId;
            }
            if (null == filterId && null != filterName) {
                setting.Recent_Filter_Name__c = filterName;
                Calendar_Filter_View__c theFilterView = [Select Id from Calendar_Filter_View__c where Name = :filterName and Calendar_Type__r.Name = 'Client'];
                setting.Recent_Filter__c = theFilterView.Id;
            }
            if (null != filterId && null == filterName) {
                setting.Recent_Filter_Name__c = [Select Id,Name from Calendar_Filter_View__c where Id = :filterId].Name;
                setting.Recent_Filter__c = filterId;
            }
            if (null != recordId) setting.Recent_Record__c = recordId ;
            Database.upsert(setting);
        } catch (system.exception e) {
            ApexPages.addMessages(e);
        }   
    }
  
  public HierarchyStructure_page myComponentController { get; set; }
  
    public List<SelectOption> viewNames { 
        get {
            List<SelectOption> options = new List<SelectOption>();            
            for (Calendar_Filter_View__c calendarFilter : [select Id,name from Calendar_Filter_View__c where Calendar_Type__r.Name = 'Client' and (CreatedById = :UserInfo.getUserId() or View_Type__c = 'Standard')]){
                options.add(new SelectOption(calendarFilter.Id,calendarFilter.Name));
            }
            return options;
            } 
        set;
     }
    
    public String currentView { 
        get ;
        set {
            currentView = value;
            String currentViewName = [Select Name from Calendar_Filter_View__c where id = :currentView].Name;
            if (currentViewName == 'Single Client') {singleClientView = true; } 
        }
    }
    
    public Boolean showClientContactEvents { get { return (recentContacts == 'true'); }set;}
    
    public Boolean showClientOppyEvents { 
        get { return (recentOpportunities == 'true');}
        set;}
    
    public Boolean renderLegend { 
        get { 
            if (renderLegend == null) {
                return (( recentView != null && !singleClientView ) || ( recentRecord != null && singleClientView ));
            } else return renderLegend;
        }   
        set;}
 
    public String currentRecordId{get;set;}
    public String objectName{get;set;}
    public String eventObjectName{get;set;}
    public String calendarType{get;set;}
    public List <Calendar_Legend__c> newCalLegItem = new List<Calendar_Legend__c>();
    public Boolean hasHierarchy {get; set;}
    public String recentRecord { get { return pref.recentRecord; }}
    public String recentView { get { return pref.recentView; }}
    public String recentFilterViewId { get { return pref.recentFilter; }}
    public Calendar_Filter_View__c recentFilter { get { return [Select Id,View_Type__c from Calendar_Filter_View__c where Id = :recentFilterViewId];}}
    public String recentChildren { get { return pref.recentChildren; }}
    public String recentContacts { get { return pref.recentContacts; }}
    public String recentOpportunities { get { return pref.recentOppys; }}
    public Boolean singleClientView { get; set; }
    public sObject selectedRecord {get; private set;}
    public Event editEvent { get; set; } { editEvent = new Event(); }
    public String calledFrom { get; set;} { calledFrom = System.currentPageReference().getUrl();}
    
    String qstr(string s) { 
        String ret = Apexpages.currentPage().getParameters().get(s) ;
        if (ret != null ) 
            ret = String.escapeSingleQuotes( ret );
        return ret; 
    }
     
// data loading
    public List<fullcalendarEvent> allEvents { set;  
        get {
            if ( allEvents == null ) {
                allEvents = new List<fullcalendarevent>();
                String typeSelParam = qstr('Type');
                String clientId = pref.RecentRecord;
                String currentViewName = pref.RecentFilterName;
                String objectSelParam = qstr('object'); //JN added for additional objects
                objectName = qstr('legendFor');
                
                // if id is a list of IDS, allow that
                List<string> typeSel = new List<string>();
                
                if ( typeSelParam != null ) {
                    typeSel = typeSelParam.split(',');
                }                
                //JN Added for additional objects
                List<string> objectSel = new List<string>();
                Set<string> uniqueObjectSel = new Set<string>();
                
                if ( objectSelParam != null ) {
                    objectSel = objectSelParam.split(',');
                 uniqueObjectSel.addAll(objectSel);   
                }
                
                String st = qstr('start'); 
                if ( st != null ) 
                    startDate = (Datetime.newInstance( Long.valueof( st )*1000 )).addMonths(-1);  
                    
                string en = qstr('end');
                if ( en != null ) 
                    endDate = (Datetime.newInstance( Long.valueof( en )*1000 )).addDays(7);
                
/****Single and Hierarchy Views*****************************************************************************/                
                if ( currentViewName == 'Single Client' || currentViewName == 'CRT Client Hierarchy') {
                    if ( (clientId != '') && (clientId != null) ){ // CR: Fetch events for a specific Client
                        String includeChildren = recentChildren;
                        List<Id> clientIds = new List<Id>();       
                        if (includeChildren=='true'){
                            if (myComponentController == null) {
                                myComponentController = new HierarchyStructure_page();
                                myComponentController.currentId = clientId;
                                myComponentController.objectName = 'Account';
                                myComponentController.hierarchyField = 'ParentId';
                                myComponentController.hierarchyClassifyField ='CRT_Client_Types__c';
                                myComponentController.getObjectStructure();
                            }
                            clientIds = myComponentController.getHierarchyChildren(clientId);
                        } else {
                            clientIds.add(clientId);
                        }
                        try {
                            if(uniqueObjectSel.contains('Event')){
                                if (objectName == 'Account'){
                                    for( Event e: [Select e.Subject, e.StartDateTime, e.Id, e.OwnerId, e.Location, 
                                            e.IsRecurrence, e.IsPrivate, e.IsGroupEvent, e.Owner.Name,
                                            e.IsChild, e.IsArchived, e.IsAllDayEvent,  e.GroupEventType, 
                                            e.EndDateTime, e.DurationInMinutes, e.Description, e.who.name, e.what.name,
                                            e.ActivityDateTime, e.ActivityDate,e.Meeting_Purpose__c
                                            From Event e
                                            where e.Meeting_Purpose__c in :typeSel
                                            and e.whatId in :clientIds
                                            and (e.activitydatetime >= :startDate or (e.IsAllDayEvent = true AND e.activitydate >=:startDate.date() ))
                                            and e.endDateTime <= :endDate 
                                            and e.isRecurrence = false
                                            ]) {
                                        fullcalendarEvent v = new fullcalendarEvent();
                                        v.id = e.id;
                                        v.title= e.subject;
                                        v.description = e.Description;
                                        v.url = ('/'+e.id);
                                        v.whoName = e.who.name!=null?e.who.name:'';
                                        v.whatName = e.what.name!=null?e.what.name:'';
                                        v.classname = 'fc-'+e.Meeting_Purpose__c;
                                        v.classname = v.classname.replaceAll('\\s+','');
                                        v.ownerid = e.OwnerId;
                                        v.ownername = e.Owner.Name;
                                        v.eventType = e.Meeting_Purpose__c;
                                     
                                        if ( e.IsAllDayEvent ) {
                                            v.allDayDate = e.activityDate;
                                            v.endDateTime = e.EndDateTime;
                                            v.allDayEvent = e.IsAllDayEvent;    
                                        } else {
                                            v.startDateTime = e.activityDatetime;
                                            v.endDateTime = e.endDateTime;
                                        }
                                        allEvents.add( v);
                                    }
                                } else if (objectName == 'Contact') {
                                    Map<Id,Contact> clientContacts = new Map<Id,Contact>([Select Id from Contact where AccountId in :clientIds and LastActivityDate != null]);
                                    Set<Id> clientContactIds = clientContacts.keySet();
                                    for( Event e: [Select e.Subject, e.StartDateTime, e.Id, e.OwnerId, e.Location, 
                                            e.IsRecurrence, e.IsPrivate, e.IsGroupEvent, e.Owner.Name,
                                            e.IsChild, e.IsArchived, e.IsAllDayEvent,  e.GroupEventType, 
                                            e.EndDateTime, e.DurationInMinutes, e.Description, e.who.name, e.what.name,
                                            e.ActivityDateTime, e.ActivityDate,e.Meeting_Purpose__c
                                            From Event e
                                            where e.Meeting_Purpose__c in :typeSel
                                            and e.whatId = null
                                            and e.whoId in :clientContactIds
                                            and (e.activitydatetime >= :startDate or (e.IsAllDayEvent = true AND e.activitydate >=:startDate.date() ))
                                            and e.endDateTime <= :endDate 
                                            and e.isRecurrence = false
                                            ]) {
                                        fullcalendarEvent v = new fullcalendarEvent();
                                        v.id = e.id;
                                        v.title= e.subject;
                                        v.description = e.Description;
                                        v.url = ('/'+e.id);
                                        v.whoName = e.who.name!=null?e.who.name:'';
                                        v.whatName = e.what.name!=null?e.what.name:'';
                                        v.classname = 'fc-'+e.Meeting_Purpose__c;
                                        v.classname = v.classname.replaceAll('\\s+','');
                                        v.ownerid = e.OwnerId;
                                        v.ownername = e.Owner.Name;
                                        v.eventType = e.Meeting_Purpose__c;
                                     
                                        if ( e.IsAllDayEvent ) {
                                            v.allDayDate = e.activityDate;
                                            v.endDateTime = e.EndDateTime;
                                            v.allDayEvent = e.IsAllDayEvent;    
                                        } else {
                                            v.startDateTime = e.activityDatetime;
                                            v.endDateTime = e.endDateTime;
                                        }
                                        allEvents.add( v);
                                    }
                                }else if (objectName == 'Opportunity') {
                                    Map<Id,Opportunity> clientOppys = new Map<Id,Opportunity>([Select Id from Opportunity where AccountId in :clientIds and LastActivityDate != null]);
                                    Set<Id> clientOpyIds = clientOppys.keySet();
                                    for( Event e: [Select e.Subject, e.StartDateTime, e.Id, e.OwnerId, e.Location, 
                                            e.IsRecurrence, e.IsPrivate, e.IsGroupEvent, e.Owner.Name,
                                            e.IsChild, e.IsArchived, e.IsAllDayEvent,  e.GroupEventType, 
                                            e.EndDateTime, e.DurationInMinutes, e.Description, e.who.name, e.what.name,
                                            e.ActivityDateTime, e.ActivityDate,e.Meeting_Purpose__c
                                            From Event e
                                            where e.Meeting_Purpose__c in :typeSel
                                            and e.whatId in :clientOpyIds
                                            and (e.activitydatetime >= :startDate or (e.IsAllDayEvent = true AND e.activitydate >=:startDate.date() ))
                                            and e.endDateTime <= :endDate 
                                            and e.isRecurrence = false
                                            ]) {
                                        fullcalendarEvent v = new fullcalendarEvent();
                                        v.id = e.id;
                                        v.title= e.subject;
                                        v.description = e.Description;
                                        v.url = ('/'+e.id);
                                        v.whoName = e.who.name!=null?e.who.name:'';
                                        v.whatName = e.what.name!=null?e.what.name:'';
                                        v.classname = 'fc-'+e.Meeting_Purpose__c;
                                        v.classname = v.classname.replaceAll('\\s+','');
                                        v.ownerid = e.OwnerId;
                                        v.ownername = e.Owner.Name;
                                        v.eventType = e.Meeting_Purpose__c;
                                     
                                        if ( e.IsAllDayEvent ) {
                                            v.allDayDate = e.activityDate;
                                            v.endDateTime = e.EndDateTime;
                                            v.allDayEvent = e.IsAllDayEvent;    
                                        } else {
                                            v.startDateTime = e.activityDatetime;
                                            v.endDateTime = e.endDateTime;
                                        }
                                        allEvents.add( v);
                                    }
                                }
                            }
       
                        } catch (Exception e) {
                            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                        }
                    }
/****My Client Team’s Clients View*********************************************************************************/                     
                } else if(currentViewName == 'My Client Team\'s Clients') { 
                    try {
                        if(uniqueObjectSel.contains('Event')){
                         Set<Id> clientServiceTeamMemberClientIds = new Set<Id>();
                         For ( AccountTeamMember clientServiceTeamRecord : [Select AccountId from AccountTeamMember where UserId = :UserInfo.getUserId()]){
                             clientServiceTeamMemberClientIds.Add(clientServiceTeamRecord.AccountId);
                         }
                         Map<Id,Account> clientServiceTeamMemberClients = new Map<Id,Account>();
                            clientServiceTeamMemberClients  = new Map<Id,Account>([select Id from Account where id in :clientServiceTeamMemberClientIds and LastActivityDate != null]);
                            if (objectName == 'Account'){
                                for( Event e: [Select e.Subject, e.StartDateTime, e.Id, e.OwnerId, e.Location, 
                                        e.IsRecurrence, e.IsPrivate, e.IsGroupEvent, e.Owner.Name,
                                        e.IsChild, e.IsArchived, e.IsAllDayEvent,  e.GroupEventType, 
                                        e.EndDateTime, e.DurationInMinutes, e.Description, e.who.name, e.what.name,
                                        e.ActivityDateTime, e.ActivityDate,e.Meeting_Purpose__c
                                        From Event e
                                        where e.Meeting_Purpose__c in :typeSel
                                        and e.WhatId in :clientServiceTeamMemberClients.keySet()
                                        and (e.activitydatetime >= :startDate or (e.IsAllDayEvent = true AND e.activitydate >=:startDate.date() ))
                                        and e.endDateTime <= :endDate 
                                        and e.isRecurrence = false
                                        ]) {
                                    fullcalendarEvent v = new fullcalendarEvent();
                                    v.id = e.id;
                                    v.title= e.subject;
                                    v.description = e.Description;
                                    v.url = ('/'+e.id);
                                    v.whoName = e.who.name!=null?e.who.name:'';
                                    v.whatName = e.what.name!=null?e.what.name:'';
                                    v.classname = 'fc-'+e.Meeting_Purpose__c;
                                    v.classname = v.classname.replaceAll('\\s+','');
                                    
                                    v.ownerid = e.OwnerId;
                                    v.ownername = e.Owner.Name;
                                    v.eventType = e.Meeting_Purpose__c;
                                 
                                    if ( e.IsAllDayEvent ) {
                                        v.allDayDate = e.activityDate;
                                        v.endDateTime = e.EndDateTime;
                                        v.allDayEvent = e.IsAllDayEvent;    
                                    } else {
                                        v.startDateTime = e.activityDatetime;
                                        v.endDateTime = e.endDateTime;
                                    }
                                    allEvents.add( v);
                                }
                            } else if (objectName == 'Contact') {
                                Map<Id,Contact> clientContacts = new Map<Id,Contact>([Select Id from Contact where AccountId in :clientServiceTeamMemberClients.keySet() and LastActivityDate != null]);
                                Set<Id> clientContactIds = clientContacts.keySet();
                                for( Event e: [Select e.Subject, e.StartDateTime, e.Id, e.OwnerId, e.Location, 
                                        e.IsRecurrence, e.IsPrivate, e.IsGroupEvent, e.Owner.Name,
                                        e.IsChild, e.IsArchived, e.IsAllDayEvent,  e.GroupEventType, 
                                        e.EndDateTime, e.DurationInMinutes, e.Description, e.who.name, e.what.name,
                                        e.ActivityDateTime, e.ActivityDate,e.Meeting_Purpose__c
                                        From Event e
                                        where e.Meeting_Purpose__c in :typeSel
                                        and e.whatId = null
                                        and e.whoId in :clientContactIds
                                        and (e.activitydatetime >= :startDate or (e.IsAllDayEvent = true AND e.activitydate >=:startDate.date() ))
                                        and e.endDateTime <= :endDate 
                                        and e.isRecurrence = false
                                        ]) {
                                    fullcalendarEvent v = new fullcalendarEvent();
                                    v.id = e.id;
                                    v.title= e.subject;
                                    v.description = e.Description;
                                    v.url = ('/'+e.id);
                                    v.whoName = e.who.name!=null?e.who.name:'';
                                    v.whatName = e.what.name!=null?e.what.name:'';
                                    v.classname = 'fc-'+e.Meeting_Purpose__c;
                                    v.classname = v.classname.replaceAll('\\s+','');
                                    
                                    v.ownerid = e.OwnerId;
                                    v.ownername = e.Owner.Name;
                                    v.eventType = e.Meeting_Purpose__c;
                                 
                                    if ( e.IsAllDayEvent ) {
                                        v.allDayDate = e.activityDate;
                                        v.endDateTime = e.EndDateTime;
                                        v.allDayEvent = e.IsAllDayEvent;    
                                    } else {
                                        v.startDateTime = e.activityDatetime;
                                        v.endDateTime = e.endDateTime;
                                    }
                                    allEvents.add( v);
                                }
                            } else if (objectName == 'Opportunity') {
                                Map<Id,Opportunity> clientOppys = new Map<Id,Opportunity>([Select Id from Opportunity where AccountId in :clientServiceTeamMemberClients.keySet() and LastActivityDate != null]);
                                Set<Id> clientOppyIds = clientOppys.keySet();
                                for( Event e: [Select e.Subject, e.StartDateTime, e.Id, e.OwnerId, e.Location, 
                                        e.IsRecurrence, e.IsPrivate, e.IsGroupEvent, e.Owner.Name,
                                        e.IsChild, e.IsArchived, e.IsAllDayEvent,  e.GroupEventType, 
                                        e.EndDateTime, e.DurationInMinutes, e.Description, e.who.name, e.what.name,
                                        e.ActivityDateTime, e.ActivityDate,e.Meeting_Purpose__c
                                        From Event e
                                        where e.Meeting_Purpose__c in :typeSel
                                        and e.whatId in :clientOppyIds
                                        and (e.activitydatetime >= :startDate or (e.IsAllDayEvent = true AND e.activitydate >=:startDate.date() ))
                                        and e.endDateTime <= :endDate 
                                        and e.isRecurrence = false
                                        ]) {
                                    fullcalendarEvent v = new fullcalendarEvent();
                                    v.id = e.id;
                                    v.title= e.subject;
                                    v.description = e.Description;
                                    v.url = ('/'+e.id);
                                    v.whoName = e.who.name!=null?e.who.name:'';
                                    v.whatName = e.what.name!=null?e.what.name:'';
                                    v.classname = 'fc-'+e.Meeting_Purpose__c;
                                    v.classname = v.classname.replaceAll('\\s+','');
                                    v.ownerid = e.OwnerId;
                                    v.ownername = e.Owner.Name;
                                    v.eventType = e.Meeting_Purpose__c;
                                 
                                    if ( e.IsAllDayEvent ) {
                                        v.allDayDate = e.activityDate;
                                        v.endDateTime = e.EndDateTime;
                                        v.allDayEvent = e.IsAllDayEvent;    
                                    } else {
                                        v.startDateTime = e.activityDatetime;
                                        v.endDateTime = e.endDateTime;
                                    }
                                    allEvents.add( v);
                                }
                            } 
                        }
                        //CR:TODO handle non event type calendar items here
                    } catch (System.LimitException le) {
                        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, 'Your view has returned more than 50 000 records. Please create a custom filter to reduced the number of records.'));
                    } catch (Exception e) {
                        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                    }
/****My Team's Client Team Clients View*********************************************************************************/                     
                } else if(currentViewName == 'My Team\'s Client Team Clients') { 
                    try {
                        if(uniqueObjectSel.contains('Event')){
                         Set<Id> clientServiceTeamMemberClientIds = new Set<Id>();
                         For ( AccountTeamMember clientServiceTeamRecord : [Select AccountId from AccountTeamMember where UserId in :teamMemberIds]){
                             clientServiceTeamMemberClientIds.Add(clientServiceTeamRecord.AccountId);
                         }
                         Map<Id,Account> clientServiceTeamMemberClients = new Map<Id,Account>();
                            clientServiceTeamMemberClients  = new Map<Id,Account>([select Id from Account where id in :clientServiceTeamMemberClientIds and LastActivityDate != null]);
                            if (objectName == 'Account'){
                                for( Event e: [Select e.Subject, e.StartDateTime, e.Id, e.OwnerId, e.Location, 
                                        e.IsRecurrence, e.IsPrivate, e.IsGroupEvent, e.Owner.Name,
                                        e.IsChild, e.IsArchived, e.IsAllDayEvent,  e.GroupEventType, 
                                        e.EndDateTime, e.DurationInMinutes, e.Description, e.who.name, e.what.name,
                                        e.ActivityDateTime, e.ActivityDate,e.Meeting_Purpose__c
                                        From Event e
                                        where e.Meeting_Purpose__c in :typeSel
                                        and e.WhatId in :clientServiceTeamMemberClients.keySet()
                                        and (e.activitydatetime >= :startDate or (e.IsAllDayEvent = true AND e.activitydate >=:startDate.date() ))
                                        and e.endDateTime <= :endDate 
                                        and e.isRecurrence = false
                                        ]) {
                                    fullcalendarEvent v = new fullcalendarEvent();
                                    v.id = e.id;
                                    v.title= e.subject;
                                    v.description = e.Description;
                                    v.url = ('/'+e.id);
                                    v.whoName = e.who.name!=null?e.who.name:'';
                                    v.whatName = e.what.name!=null?e.what.name:'';
                                    v.classname = 'fc-'+e.Meeting_Purpose__c;
                                    v.classname = v.classname.replaceAll('\\s+','');
                                    
                                    v.ownerid = e.OwnerId;
                                    v.ownername = e.Owner.Name;
                                    v.eventType = e.Meeting_Purpose__c;
                                 
                                    if ( e.IsAllDayEvent ) {
                                        v.allDayDate = e.activityDate;
                                        v.endDateTime = e.EndDateTime;
                                        v.allDayEvent = e.IsAllDayEvent;    
                                    } else {
                                        v.startDateTime = e.activityDatetime;
                                        v.endDateTime = e.endDateTime;
                                    }
                                    allEvents.add( v);
                                }
                            } else if (objectName == 'Contact') {
                                Map<Id,Contact> clientContacts = new Map<Id,Contact>([Select Id from Contact where AccountId in :clientServiceTeamMemberClients.keySet() and LastActivityDate != null]);
                                Set<Id> clientContactIds = clientContacts.keySet();
                                for( Event e: [Select e.Subject, e.StartDateTime, e.Id, e.OwnerId, e.Location, 
                                        e.IsRecurrence, e.IsPrivate, e.IsGroupEvent, e.Owner.Name,
                                        e.IsChild, e.IsArchived, e.IsAllDayEvent,  e.GroupEventType, 
                                        e.EndDateTime, e.DurationInMinutes, e.Description, e.who.name, e.what.name,
                                        e.ActivityDateTime, e.ActivityDate,e.Meeting_Purpose__c
                                        From Event e
                                        where e.Meeting_Purpose__c in :typeSel
                                        and e.whatId = null
                                        and e.whoId in :clientContactIds
                                        and (e.activitydatetime >= :startDate or (e.IsAllDayEvent = true AND e.activitydate >=:startDate.date() ))
                                        and e.endDateTime <= :endDate 
                                        and e.isRecurrence = false
                                        ]) {
                                    fullcalendarEvent v = new fullcalendarEvent();
                                    v.id = e.id;
                                    v.title= e.subject;
                                    v.description = e.Description;
                                    v.url = ('/'+e.id);
                                    v.whoName = e.who.name!=null?e.who.name:'';
                                    v.whatName = e.what.name!=null?e.what.name:'';
                                    v.classname = 'fc-'+e.Meeting_Purpose__c;
                                    v.classname = v.classname.replaceAll('\\s+','');
                                    
                                    v.ownerid = e.OwnerId;
                                    v.ownername = e.Owner.Name;
                                    v.eventType = e.Meeting_Purpose__c;
                                 
                                    if ( e.IsAllDayEvent ) {
                                        v.allDayDate = e.activityDate;
                                        v.endDateTime = e.EndDateTime;
                                        v.allDayEvent = e.IsAllDayEvent;    
                                    } else {
                                        v.startDateTime = e.activityDatetime;
                                        v.endDateTime = e.endDateTime;
                                    }
                                    allEvents.add( v);
                                }
                            } else if (objectName == 'Opportunity') {
                                Map<Id,Opportunity> clientOppys = new Map<Id,Opportunity>([Select Id from Opportunity where AccountId in :clientServiceTeamMemberClients.keySet() and LastActivityDate != null]);
                                Set<Id> clientOppyIds = clientOppys.keySet();
                                for( Event e: [Select e.Subject, e.StartDateTime, e.Id, e.OwnerId, e.Location, 
                                        e.IsRecurrence, e.IsPrivate, e.IsGroupEvent, e.Owner.Name,
                                        e.IsChild, e.IsArchived, e.IsAllDayEvent,  e.GroupEventType, 
                                        e.EndDateTime, e.DurationInMinutes, e.Description, e.who.name, e.what.name,
                                        e.ActivityDateTime, e.ActivityDate,e.Meeting_Purpose__c
                                        From Event e
                                        where e.Meeting_Purpose__c in :typeSel
                                        and e.whatId in :clientOppyIds
                                        and (e.activitydatetime >= :startDate or (e.IsAllDayEvent = true AND e.activitydate >=:startDate.date() ))
                                        and e.endDateTime <= :endDate 
                                        and e.isRecurrence = false
                                        ]) {
                                    fullcalendarEvent v = new fullcalendarEvent();
                                    v.id = e.id;
                                    v.title= e.subject;
                                    v.description = e.Description;
                                    v.url = ('/'+e.id);
                                    v.whoName = e.who.name!=null?e.who.name:'';
                                    v.whatName = e.what.name!=null?e.what.name:'';
                                    v.classname = 'fc-'+e.Meeting_Purpose__c;
                                    v.classname = v.classname.replaceAll('\\s+','');
                                    v.ownerid = e.OwnerId;
                                    v.ownername = e.Owner.Name;
                                    v.eventType = e.Meeting_Purpose__c;
                                 
                                    if ( e.IsAllDayEvent ) {
                                        v.allDayDate = e.activityDate;
                                        v.endDateTime = e.EndDateTime;
                                        v.allDayEvent = e.IsAllDayEvent;    
                                    } else {
                                        v.startDateTime = e.activityDatetime;
                                        v.endDateTime = e.endDateTime;
                                    }
                                    allEvents.add( v);
                                }
                            } 
                        }
                        //CR:TODO handle non event type calendar items here
                    } catch (System.LimitException le) {
                        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, 'Your view has returned more than 50 000 records. Please create a custom filter to reduced the number of records.'));
                    } catch (Exception e) {
                        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                    }
/****My Team's Clients View*********************************************************************************/                            
                } else if(currentViewName == 'My Team\'s Clients') { 
                    try {
                        if(uniqueObjectSel.contains('Event')){
                         Map<Id,Account> teamMemberClients = new Map<Id,Account>();
                         teamMemberClients = new Map<Id,Account>([select Id from Account where ownerId in :teamMemberIds and LastActivityDate != null]);
                         if (objectName == 'Account'){
                            for( Event e: [Select e.Subject, e.StartDateTime, e.Id, e.OwnerId, e.Location, 
                                    e.IsRecurrence, e.IsPrivate, e.IsGroupEvent, e.Owner.Name,
                                    e.IsChild, e.IsArchived, e.IsAllDayEvent,  e.GroupEventType, 
                                    e.EndDateTime, e.DurationInMinutes, e.Description, e.who.name, e.what.name,
                                    e.ActivityDateTime, e.ActivityDate,e.Meeting_Purpose__c
                                    From Event e
                                    where e.Meeting_Purpose__c in :typeSel
                                    and e.WhatId in :teamMemberClients.keySet()
                                    and (e.activitydatetime >= :startDate or (e.IsAllDayEvent = true AND e.activitydate >=:startDate.date() ))
                                    and e.endDateTime <= :endDate 
                                    and e.isRecurrence = false
                                    ]) {
                                fullcalendarEvent v = new fullcalendarEvent();
                                v.id = e.id;
                                v.title= e.subject;
                                v.description = e.Description;
                                v.url = ('/'+e.id);
                                v.whoName = e.who.name!=null?e.who.name:'';
                                v.whatName = e.what.name!=null?e.what.name:'';
                                v.classname = 'fc-'+e.Meeting_Purpose__c;
                                v.classname = v.classname.replaceAll('\\s+','');                               
                                v.ownerid = e.OwnerId;
                                v.ownername = e.Owner.Name;
                                v.eventType = e.Meeting_Purpose__c;
                             
                                if ( e.IsAllDayEvent ) {
                                    v.allDayDate = e.activityDate;
                                    v.endDateTime = e.EndDateTime;
                                    v.allDayEvent = e.IsAllDayEvent;    
                                } else {
                                    v.startDateTime = e.activityDatetime;
                                    v.endDateTime = e.endDateTime;
                                }
                                allEvents.add( v);
                            }
                        } else if (objectName == 'Contact') {
                            Map<Id,Contact> clientContacts = new Map<Id,Contact>([Select Id from Contact where AccountId in :teamMemberClients.keySet() and LastActivityDate != null]);
                            Set<Id> clientContactIds = clientContacts.keySet();
                            for( Event e: [Select e.Subject, e.StartDateTime, e.Id, e.OwnerId, e.Location, 
                                    e.IsRecurrence, e.IsPrivate, e.IsGroupEvent, e.Owner.Name,
                                    e.IsChild, e.IsArchived, e.IsAllDayEvent,  e.GroupEventType, 
                                    e.EndDateTime, e.DurationInMinutes, e.Description, e.who.name, e.what.name,
                                    e.ActivityDateTime, e.ActivityDate,e.Meeting_Purpose__c
                                    From Event e
                                    where e.Meeting_Purpose__c in :typeSel
                                    and e.whatId = null
                                    and e.whoId in :clientContactIds
                                    and (e.activitydatetime >= :startDate or (e.IsAllDayEvent = true AND e.activitydate >=:startDate.date() ))
                                    and e.endDateTime <= :endDate 
                                    and e.isRecurrence = false
                                    ]) {
                                fullcalendarEvent v = new fullcalendarEvent();
                                v.id = e.id;
                                v.title= e.subject;
                                v.description = e.Description;
                                v.url = ('/'+e.id);
                                v.whoName = e.who.name!=null?e.who.name:'';
                                v.whatName = e.what.name!=null?e.what.name:'';
                                v.classname = 'fc-'+e.Meeting_Purpose__c;
                                v.classname = v.classname.replaceAll('\\s+','');                               
                                v.ownerid = e.OwnerId;
                                v.ownername = e.Owner.Name;
                                v.eventType = e.Meeting_Purpose__c;
                             
                                if ( e.IsAllDayEvent ) {
                                    v.allDayDate = e.activityDate;
                                    v.endDateTime = e.EndDateTime;
                                    v.allDayEvent = e.IsAllDayEvent;    
                                } else {
                                    v.startDateTime = e.activityDatetime;
                                    v.endDateTime = e.endDateTime;
                                }
                                allEvents.add( v);
                            }
                        } else if (objectName == 'Opportunity') {
                            System.Debug('Rows: '+Limits.getQueryRows());                               
                            Map<Id,Opportunity> clientOppys = new Map<Id,Opportunity>([Select Id from Opportunity where AccountId in :teamMemberClients.keySet() and LastActivityDate != null]);
                            Set<Id> clientOppyIds = clientOppys.keySet();
                            for( Event e: [Select e.Subject, e.StartDateTime, e.Id, e.OwnerId, e.Location, 
                                    e.IsRecurrence, e.IsPrivate, e.IsGroupEvent, e.Owner.Name,
                                    e.IsChild, e.IsArchived, e.IsAllDayEvent,  e.GroupEventType, 
                                    e.EndDateTime, e.DurationInMinutes, e.Description, e.who.name, e.what.name,
                                    e.ActivityDateTime, e.ActivityDate,e.Meeting_Purpose__c
                                    From Event e
                                    where e.Meeting_Purpose__c in :typeSel
                                    and e.whatId in :clientOppyIds
                                    and (e.activitydatetime >= :startDate or (e.IsAllDayEvent = true AND e.activitydate >=:startDate.date() ))
                                    and e.endDateTime <= :endDate 
                                    and e.isRecurrence = false
                                    ]) {
                                fullcalendarEvent v = new fullcalendarEvent();
                                v.id = e.id;
                                v.title= e.subject;
                                v.description = e.Description;
                                v.url = ('/'+e.id);
                                v.whoName = e.who.name!=null?e.who.name:'';
                                v.whatName = e.what.name!=null?e.what.name:'';
                                v.classname = 'fc-'+e.Meeting_Purpose__c;
                                v.classname = v.classname.replaceAll('\\s+','');
                                v.ownerid = e.OwnerId;
                                v.ownername = e.Owner.Name;
                                v.eventType = e.Meeting_Purpose__c;
                             
                                if ( e.IsAllDayEvent ) {
                                    v.allDayDate = e.activityDate;
                                    v.endDateTime = e.EndDateTime;
                                    v.allDayEvent = e.IsAllDayEvent;    
                                } else {
                                    v.startDateTime = e.activityDatetime;
                                    v.endDateTime = e.endDateTime;
                                }
                                allEvents.add( v);
                            }
                        } 
                    }
                        //CR:TODO handle non event type calendar items here
                    } catch (System.LimitException le) {
                        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, 'Your view has returned more than 50 000 records. Please create a custom filter to reduced the number of records.'));
                    } catch (Exception e) {
                        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                    }
/****My Clients View*************************************************************************************/                            
                } else if(currentViewName == 'My Clients') { 
                    try {
                        if(uniqueObjectSel.contains('Event')){
                         Map<Id,Account> myClients = new Map<Id,Account>();
                            myClients = new Map<Id,Account>([select Id from Account where ownerId = :userInfo.getUserId() and LastActivityDate != null]);
                            if (objectName == 'Account'){
                                for( Event e: [Select e.Subject, e.StartDateTime, e.Id, e.OwnerId, e.Location, 
                                        e.IsRecurrence, e.IsPrivate, e.IsGroupEvent, e.Owner.Name,
                                        e.IsChild, e.IsArchived, e.IsAllDayEvent,  e.GroupEventType, 
                                        e.EndDateTime, e.DurationInMinutes, e.Description, e.who.name, e.what.name,
                                        e.ActivityDateTime, e.ActivityDate,e.Meeting_Purpose__c
                                        From Event e
                                        where e.Meeting_Purpose__c in :typeSel
                                        and e.whatId in :myClients.keySet()
                                        and (e.activitydatetime >= :startDate or (e.IsAllDayEvent = true AND e.activitydate >=:startDate.date() ))
                                        and e.endDateTime <= :endDate 
                                        and e.isRecurrence = false
                                        ]) {
                                    fullcalendarEvent v = new fullcalendarEvent();
                                    v.id = e.id;
                                    v.title= e.subject;
                                    v.description = e.Description;
                                    v.url = ('/'+e.id);
                                    v.whoName = e.who.name!=null?e.who.name:'';
                                    v.whatName = e.what.name!=null?e.what.name:'';
                                    v.classname = 'fc-'+e.Meeting_Purpose__c;
                                    v.classname = v.classname.replaceAll('\\s+','');
                                    v.ownerid = e.OwnerId;
                                    v.ownername = e.Owner.Name;
                                    v.eventType = e.Meeting_Purpose__c;
                                 
                                    if ( e.IsAllDayEvent ) {
                                        v.allDayDate = e.activityDate;
                                        v.endDateTime = e.EndDateTime;
                                        v.allDayEvent = e.IsAllDayEvent;    
                                    } else {
                                        v.startDateTime = e.activityDatetime;
                                        v.endDateTime = e.endDateTime;
                                    }
                                    allEvents.add( v);
                                }
                            } else if (objectName == 'Contact') {
                                Map<Id,Contact> clientContacts = new Map<Id,Contact>([Select Id from Contact where AccountId in :myClients.keySet() and LastActivityDate != null]);
                                Set<Id> clientContactIds = clientContacts.keySet();
                                for( Event e: [Select e.Subject, e.StartDateTime, e.Id, e.OwnerId, e.Location, 
                                        e.IsRecurrence, e.IsPrivate, e.IsGroupEvent, e.Owner.Name,
                                        e.IsChild, e.IsArchived, e.IsAllDayEvent,  e.GroupEventType, 
                                        e.EndDateTime, e.DurationInMinutes, e.Description, e.who.name, e.what.name,
                                        e.ActivityDateTime, e.ActivityDate,e.Meeting_Purpose__c
                                        From Event e
                                        where e.Meeting_Purpose__c in :typeSel
                                        and e.whatId = null
                                        and e.whoId in :clientContactIds
                                        and (e.activitydatetime >= :startDate or (e.IsAllDayEvent = true AND e.activitydate >=:startDate.date() ))
                                        and e.endDateTime <= :endDate 
                                        and e.isRecurrence = false
                                        ]) {
                                    fullcalendarEvent v = new fullcalendarEvent();
                                    v.id = e.id;
                                    v.title= e.subject;
                                    v.description = e.Description;
                                    v.url = ('/'+e.id);
                                    v.whoName = e.who.name!=null?e.who.name:'';
                                    v.whatName = e.what.name!=null?e.what.name:'';
                                    v.classname = 'fc-'+e.Meeting_Purpose__c;
                                    v.classname = v.classname.replaceAll('\\s+','');
                                    v.ownerid = e.OwnerId;
                                    v.ownername = e.Owner.Name;
                                    v.eventType = e.Meeting_Purpose__c;
                                 
                                    if ( e.IsAllDayEvent ) {
                                        v.allDayDate = e.activityDate;
                                        v.endDateTime = e.EndDateTime;
                                        v.allDayEvent = e.IsAllDayEvent;    
                                    } else {
                                        v.startDateTime = e.activityDatetime;
                                        v.endDateTime = e.endDateTime;
                                    }
                                    allEvents.add( v);
                                }
                            } else if (objectName == 'Opportunity') {
                                Map<Id,Opportunity> clientOppys = new Map<Id,Opportunity>([Select Id from Opportunity where AccountId in :myClients.keySet() and LastActivityDate != null]);
                                Set<Id> clientOppyIds = clientOppys.keySet();
                                for( Event e: [Select e.Subject, e.StartDateTime, e.Id, e.OwnerId, e.Location, 
                                        e.IsRecurrence, e.IsPrivate, e.IsGroupEvent, e.Owner.Name,
                                        e.IsChild, e.IsArchived, e.IsAllDayEvent,  e.GroupEventType, 
                                        e.EndDateTime, e.DurationInMinutes, e.Description, e.who.name, e.what.name,
                                        e.ActivityDateTime, e.ActivityDate,e.Meeting_Purpose__c
                                        From Event e
                                        where e.Meeting_Purpose__c in :typeSel
                                        and e.whatId in :clientOppyIds
                                        and (e.activitydatetime >= :startDate or (e.IsAllDayEvent = true AND e.activitydate >=:startDate.date() ))
                                        and e.endDateTime <= :endDate 
                                        and e.isRecurrence = false
                                        ]) {
                                    fullcalendarEvent v = new fullcalendarEvent();
                                    v.id = e.id;
                                    v.title= e.subject;
                                    v.description = e.Description;
                                    v.url = ('/'+e.id);
                                    v.whoName = e.who.name!=null?e.who.name:'';
                                    v.whatName = e.what.name!=null?e.what.name:'';
                                    v.classname = 'fc-'+e.Meeting_Purpose__c;
                                    v.classname = v.classname.replaceAll('\\s+','');
                                    v.ownerid = e.OwnerId;
                                    v.ownername = e.Owner.Name;
                                    v.eventType = e.Meeting_Purpose__c;
                                 
                                    if ( e.IsAllDayEvent ) {
                                        v.allDayDate = e.activityDate;
                                        v.endDateTime = e.EndDateTime;
                                        v.allDayEvent = e.IsAllDayEvent;    
                                    } else {
                                        v.startDateTime = e.activityDatetime;
                                        v.endDateTime = e.endDateTime;
                                    }
                                    allEvents.add( v);
                                }
                            } 
                        }
                        //CR:TODO handle non event type calendar items here
                    } catch (System.LimitException le) {
                        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO, 'Your view has returned more than 50 000 records. Please create a custom filter to reduced the number of records.'));
                    } catch (Exception e) {
                        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
                    }
                }
            }
            return allEvents;
        }
    }   
 
 
// called from Calendar For type-ahead support
     public List<sObject> allDynamicRecords { 
         get { 
            if ( allDynamicRecordValues == null ) {
                String term = qstr('term');
                term = '%'+term.trim()+'%';
                String calType = qstr('calType');
                if (null == calType || calType == '') { 
                    calType = 'Client';
                    ApexPages.currentPage().getParameters().put('calType','Client');
                } //CR: Default the calendar type to client if it is not set 
                String recordSearchObject = [Select Hierarchy_Object_Name__c,Hierarchy_Object_External_Id_Field__c from Calendar_Content__c where Calendar_Type__r.Name = :calType and Name = 'Client Events'].Hierarchy_Object_Name__c;
                System.assert( recordSearchObject != null,'The data object for the '+calType+' calendar is not defined. Please specify the object name in the Hierarchy Object Name field on the Calendar Content object');
                allDynamicRecordValues = Database.query('select Id, Name, CIF__c, RecordType.Name from ' + recordSearchObject +' where name like :term order by Name limit 50');
            }
            return allDynamicRecordValues;
         } 
         private set; 
     }
     
     private transient List<sObject> allDynamicRecordValues;
    
// interactions on the page
    
    @RemoteAction
    global static Boolean deleteEventById(String eventId) {
        Boolean deleted  = false;
        try {
            Event eventToUpdate = [select Id from Event where Id = :eventId limit 1];
            delete eventToUpdate;
            deleted = true;
        }
        catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            throw new System.NoAccessException();
        }
        return deleted;  
    }
 
 /*   public void changeEventOwner() {
        Id eventId = qstr('eventId');
        Id newOwner = qstr('ownerId');
        try {
            Event eventToUpdate = [select Id, ownerId from Event   where Id = :eventId limit 1];
            eventToUpdate.ownerId = newOwner;
            update eventToUpdate;
        }
        catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
         
    } */
    
    
    @RemoteAction
    global static void updateEventMove(Id theEventId, String theDayDelta, String theMinuteDelta) {
    
        try {
            Event eventToUpdate = [select Id, activityDateTime,activityDate ,IsAllDayEvent 
                                    from Event where Id = :theEventId limit 1];
            
            if ( eventToUpdate.IsAllDayEvent ) {                                // day event
                if (theDayDelta != '0' && theDayDelta != '') {
                    Integer days = Double.valueOf(theDayDelta).intValue();
                    eventToUpdate.activityDate = eventToUpdate.activityDate.addDays(days);
                }
            } else {                                                            // time event              
                if(theMinuteDelta != '0' && theMinuteDelta != '' ){
                    Integer minutes = Double.valueOf(theMinuteDelta).intValue();
                    eventToUpdate.activityDateTime = eventToUpdate.activityDateTime.addMinutes(minutes);
                }
                if (theDayDelta!= '0' && theDayDelta != '') {
                    Integer days = Double.valueOf(theDayDelta).intValue();
                    eventToUpdate.activityDateTime = eventToUpdate.activityDateTime.addDays(days);
                }
            }
               
            update eventToUpdate;
        }
        catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            throw new System.NoAccessException();
        }
    }       
    
    @RemoteAction
    global static void viewDisplay(String theView) {
        SharedCalPrefs pref = new SharedCalPrefs();
        pref.saveView(theView);
    }
    
    @RemoteAction
    global static void updateDateChanged(String theDay, String theMonth, String theYear) {
        SharedCalPrefs pref = new SharedCalPrefs();
        pref.saveDate( theDay,theMonth,theYear );
    }
    
    public PageReference includeBoth() {
        pref.saveContacts( qstr('includeBoth') );
        pref.saveOppys( qstr('includeBoth') );
        String param1 = qstr('recordId');
        String param2 = qstr('filterName');
        PageReference reloadPage = Page.SharedCalendar;
        reloadPage.getParameters().put('recordId',param1);
        reloadPage.getParameters().put('calType','Client');
        reloadPage.getParameters().put('filterName',param2);
        reloadPage.setRedirect(true);
        return reloadPage;            
    }
    
    public PageReference includeContacts() {
        pref.saveContacts( qstr('includeContacts') );
        String param1 = qstr('recordId');
        String param2 = qstr('filterName');
        PageReference reloadPage = Page.SharedCalendar;
        reloadPage.getParameters().put('recordId',param1);
        reloadPage.getParameters().put('calType','Client');
        reloadPage.getParameters().put('filterName',param2);
        reloadPage.setRedirect(true);
        return reloadPage;            
    }
    
    public PageReference includeOppys() {
        pref.saveOppys( qstr('includeOppys') );
        String param1 = qstr('recordId');
        String param2 = qstr('filterName');
        PageReference reloadPage = Page.SharedCalendar;
        reloadPage.getParameters().put('recordId',param1);
        reloadPage.getParameters().put('calType','Client');
        reloadPage.getParameters().put('filterName',param2);
        reloadPage.setRedirect(true);
        return reloadPage;            
    }
    
    public PageReference changeFilterView() { 
        String param1 = qstr( 'filterName' );
        String param2 = qstr( 'filterId' );
        pref.saveFilter( param2 );
        pref.saveFilterName( param1 );
        pref = new SharedCalPrefs();
        singleClientView = false;
        PageReference reloadPage = Page.SharedCalendar;
        reloadPage.getParameters().put('calType','Client');
        if ( pref.recentFilterName == 'Single Client') {
            reloadPage.getParameters().put('calledFrom','detailPage');
            pref.saveChildren('false');
            pref.saveContacts('');
            pref.saveOppys('');
            singleClientView = true; 
        } else if (pref.recentFilterName == 'My Team\'s Clients')  {
            pref.saveRecord('');
            reloadPage.getParameters().put('calledFrom','homePage');
        } else if (pref.recentFilterName == 'My Team\'s Client Team Clients')  {
            pref.saveRecord('');
            reloadPage.getParameters().put('calledFrom','homePage');
        } else if (pref.recentFilterName == 'My Client Team\'s Clients')  {
            pref.saveRecord('');
            reloadPage.getParameters().put('calledFrom','homePage');
        } else if (pref.recentFilterName == 'My Clients')  {
            pref.saveRecord('');
            reloadPage.getParameters().put('calledFrom','homePage');
        } else if (pref.recentFilterName == 'CRT Client Hierarchy')  {
            pref.saveChildren('true');
            pref.saveContacts('');
            pref.saveOppys('');
            pref.saveRecord('');
            reloadPage.getParameters().put('calledFrom','hierarchyPage');
        } else {
            // Custom View called
        }
        reloadPage.setRedirect(true);
        return reloadPage;         
    }
    
    public PageReference includeChildren() {
        pref.saveChildren( qstr('includeChildren') );
        String param1 = qstr('recordId');
        String param2 = qstr('filterName');
        PageReference reloadPage = Page.SharedCalendar;
        reloadPage.getParameters().put('recordId',param1);
        reloadPage.getParameters().put('calType','Client');
        if (qstr('includeChildren')=='false'){
            reloadPage.getParameters().put('calledFrom','detailPage');
        } else {
            reloadPage.getParameters().put('calledFrom','hierarchyPage');        }
        reloadPage.setRedirect(true);
        return reloadPage;            
    }
     
     public pageReference selectSearchedRecord() { 
        Id param1 = qstr('seletedRecordId');
        String param2 = qstr('filterId');
        pref.saveRecord(param1);
        pref.saveFilter(param2);
        PageReference reloadPage = new PageReference('/apex/SharedCalendar');
        reloadPage.getParameters().put('recordId',param1);
        reloadPage.getParameters().put('calType','Client');
        if (pref.recentChildren == 'false'){
            reloadPage.getParameters().put('calledFrom','detailPage'); 
        } else {
            reloadPage.getParameters().put('calledFrom','hierarchyPage');
        }
        reloadPage.setRedirect(true);
        return reloadPage;     
    }
    
    public void setHierarchy(String currentRecordId, String calType){
    try { 
            hasHierarchy = false;
            system.Assert(null!=calType,'The calendar type is not set when trying to determine if the calendar primary record has a hierarchy');
            Calendar_Content__c calendarContentObject = [Select Hierarchy_Object_Name__c,Hierarchy_Relation_Field__c from Calendar_Content__c where Calendar_Type__r.Name = :calType and Name = 'Client Events'];
            selectedRecord = Database.query('select id,name,' +calendarContentObject.Hierarchy_Relation_Field__c +' from '+calendarContentObject.Hierarchy_Object_Name__c +' where id = :currentRecordId limit 1');
            hasHierarchy = (selectedRecord.get('parentId') == null) ? false : true;
            if (!hasHierarchy) {
                List<sObject> isTopParent = database.query('Select id from ' + calendarContentObject.Hierarchy_Object_Name__c +' where ' + calendarContentObject.Hierarchy_Relation_Field__c +' = :currentRecordId limit 1');
                hasHierarchy = (isTopParent.size()) > 0 ? true : false;
            }
            if (!hasHierarchy){ pref.saveChildren( 'false' ); }
        }
        catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    
    public void updateEventResize() {
        Id eventId = qstr('eventId');
        String minuteDelta = qstr('minuteDelta');
        
        try {
            Event eventToUpdate = [select Id, EndDateTime from Event   where Id = :eventId limit 1];
            
            if(minuteDelta != '0' && minuteDelta != '' ){
                Integer minutes = Double.valueOf(minuteDelta).intValue();
                eventToUpdate.EndDateTime = eventToUpdate.EndDateTime.addMinutes(minutes);
            }
            
            update eventToUpdate;
        }
        catch (Exception e) {
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }       
    }

    private SharedCalPrefs pref = new SharedCalPrefs();
    private Datetime startDate { get; set; } { startDate = system.now().addMonths(-1); }
    private Datetime endDate { get; set; }   { endDate = system.now().addDays(7); }
    public transient List<Id> teamMemberIds {get; set; } { teamMemberIds = getRoleSubordinateUsers(userInfo.getUserId()); teamMemberIds.add(userInfo.getUserId()); }

    private static List<ID> getRoleSubordinateUsers(Id userId) {
        List<Id> theMembers = new List<Id>();
        // get requested user's role
        Id roleId = [select UserRoleId from User where Id = :userId].UserRoleId;
        // get all of the roles underneath the user
        Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{roleId});
        // get all of the ids for the users in those roles
        Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where UserRoleId IN :allSubRoleIds and isActive = true]);
        // return the ids as a set so you can do what you want with them
        theMembers.addAll(users.keySet());
        return theMembers;
    }
 
    private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {
        Set<ID> currentRoleIds = new Set<ID>();
        // get all of the roles underneath the passed roles
        for(UserRole userRole :[select Id from UserRole where ParentRoleId 
          IN :roleIds AND ParentRoleID != null])
        currentRoleIds.add(userRole.Id);
        // go fetch some more rolls!
        if(currentRoleIds.size() > 0)
          currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));
        return currentRoleIds;
  }
    
}