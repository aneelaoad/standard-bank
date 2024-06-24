/***********************************************************************************************
    @ Author        : Caro Reinecke
    @ Date          : 23/11/2012
    @description   : Unknown

    @ Last Modified : Charles Mutsu
    @ Modify Date   : 24/7/2013
    @ Reason        : API Version moved from 25 to 28
    
    @ Last Modified : Nitish Kumar
    @ Modify Date   : 29/7/2013
    @ Reason        : Improved Code Coverage
    
    @ Last Modified By  :   Nitish Kumar    
    @ Last Modified On  :   August,2013
    @ Description         :  Added Custom Setting Data
    
    @ Last Modified By  :  Nitish Kumar    
    @ Last Modified On  :  January,2014
    @ Description       :  Test Class update due to Client Sector Validation

    @ Last Modified By:     Prabhanshu Agrawal
    @ Last Modified On:     Mar 2015
    @ Last Modified Reason: En 656 - Removing Type field and adding Meeting Type and Meeting Audience
                      
    @ Last Modified By    :   Prabhanshu Agrawal        
   @ Last Modified On    :   Apr 2015
  @ Last Modified Reason  :   EN-662, Added Meeting audience and Meeting type in the test data for validation rule    

    @ Last Modified By    :   Petr Svestka
   @ Last Modified On    :   September 7, 2015
  @ Last Modified Reason  :   fixed account hierarchy to pass VR
   
    @ Last Modified By  : Abhishek V
    @ Last Modified On  : Oct 2016
    @ Modification Description : US: 1548 - To assign value to Report_Client_Contact__c on Event records owing to new design 
***************************************************************************************************/ 
@SuppressWarnings('PMD.NcssMethodCount,PMD.AvoidHardcodingId')
@IsTest
private class SharedCalendarUtilsTest {
    
    // Get Account Record type Map
    public static Map <String,Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    // Get the record type id of from the Map based on the Name
    public static Id prospectRecTypeId = mapAccountRecordTypes.get('Child').getRecordTypeId();
    public static Id immParentRecTypeId = mapAccountRecordTypes.get('Immediate Parent').getRecordTypeId();

    @IsTest
    static void testSharedCalendarFromTab() {
      
       //get Custom Setting Record
       insert TEST_DataFactory.getCcSettings();

       List<Account> testAccounts = new List<Account>();
        // put an account
        string uniquename = 'sdlkjsdlsdjflsjdfsdfwieurosdfcxcv1'; 
        Account ac = new Account();
        
        ac.name = uniquename;
        
        testAccounts.add(ac);
        insert testAccounts;
                
        // insert contact
        Contact co = new Contact();
        co.Lastname = uniquename;
        co.accountId = ac.Id;
        insert co;
        
        // insert opportunity
        Opportunity op = new Opportunity();
        op.name = uniquename+1;
        op.accountId = ac.Id;
        op.StageName = 'dummy';
        op.closedate = System.Date.Today();
        insert op;
        
        // insert Calendar Type
        Calendar_Type__c testCalType = new Calendar_Type__c();
        testCalType.Name = 'Client';
        insert testCalType;
        
        // insert Filter Views
        List<Calendar_Filter_View__c> testFilters = new List<Calendar_Filter_View__c>();
        Calendar_Filter_View__c testFilterView = new Calendar_Filter_View__c(Name='Single Client',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView);
        Calendar_Filter_View__c testFilterView2 = new Calendar_Filter_View__c(Name='CRT Client Hierarchy',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView2);
        Calendar_Filter_View__c testFilterView3 = new Calendar_Filter_View__c(Name='My Team\'s Clients',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView3);
        Calendar_Filter_View__c testFilterView4 = new Calendar_Filter_View__c(Name='My Client Team\'s Clients',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView4);
        Calendar_Filter_View__c testFilterView5 = new Calendar_Filter_View__c(Name='My Clients',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView5);
        Calendar_Filter_View__c testFilterView6 = new Calendar_Filter_View__c(Name='My Custom View',View_Type__c='Custom',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView6);
        
        insert testFilters;
        
        
        //insert Calendar Content
        List<Calendar_Content__c> testCalCon = new List<Calendar_Content__c>();
        Calendar_Content__c testCalContent = new Calendar_Content__c();
        testCalContent.Name = 'Client Events';
        testCalContent.Event_Start_Field__c = 'Start';
        testCalContent.Event_Title_Field__c = 'Subject';
        testCalContent.Event_Legend_Field__c = 'Meeting_Purpose__c';
        testCalContent.Event_Object_Name__c = 'Event';
        testCalContent.Hierarchy_Object_Name__c = 'Account';
        testCalContent.Hierarchy_Relation_Field__c = 'ParentId';
        testCalContent.Calendar_Type__c = testCalType.Id;
        testCalCon.add(testCalContent);
        
        Calendar_Content__c testCalContent1 = new Calendar_Content__c();
        testCalContent1.Name = 'Client Contact Events';
        testCalContent1.Event_Start_Field__c = 'Start';
        testCalContent1.Event_Title_Field__c = 'Subject';
        testCalContent1.Event_Legend_Field__c = 'Meeting_Purpose__c';
        testCalContent1.Event_Object_Name__c = 'Event';
        testCalContent1.Hierarchy_Object_Name__c = 'Contact';
        testCalContent1.Hierarchy_Relation_Field__c = 'ReportsToId';
        testCalContent1.Calendar_Type__c = testCalType.Id;
        testCalCon.add(testCalContent1);
        
        Calendar_Content__c testCalContent2 = new Calendar_Content__c();
        testCalContent2.Name = 'Client Opportunity Events';
        testCalContent2.Event_Start_Field__c = 'Start';
        testCalContent2.Event_Title_Field__c = 'Subject';
        testCalContent2.Event_Legend_Field__c = 'Meeting_Purpose__c';
        testCalContent2.Event_Object_Name__c = 'Event';
        testCalContent2.Hierarchy_Object_Name__c = 'Opportunity';
        testCalContent2.Calendar_Type__c = testCalType.Id;
        testCalCon.add(testCalContent2);
        insert testCalCon ;
        
        //insert Calendar Legend
        Calendar_Legend__c calLegend = new Calendar_Legend__c();
        calLegend.Name = 'Call';
        calLegend.Background_Color__c = 'blue';
        calLegend.Calendar_Content__c = testCalContent.Id;
        insert calLegend;
        
        List<Event> testEvents = new List<Event>();
        
        // put in an event related to client
        Event ev = new Event(activityDateTime=System.now());
        ev.Meeting_Audience__c = 'Internal';
        ev.Meeting_Purpose__c = 'Day To Day Meeting';

        ev.DurationInMinutes = 1;
        ev.whatId = ac.Id;
        testEvents.add(ev);
        Event ev2 = new Event(activityDateTime=System.now());
        ev2.Meeting_Audience__c = 'Internal';
        ev2.Meeting_Purpose__c = 'Day To Day Meeting';

        ev2.DurationInMinutes = 1;
        ev2.whatId = ac.Id;
        testEvents.add(ev2);
        
        Event evallday = new Event(activityDate=System.today().addDays(2));
        evallday.IsAllDayEvent = true;
        evallday.Meeting_Audience__c = 'Internal';
        evallday.Meeting_Purpose__c = 'Day To Day Meeting';

        evallday.whatId = ac.Id;
        testEvents.add(evallday);
        
        // put in an event related to client contact
        Event ev3 = new Event(activityDateTime=System.now());
        ev3.Meeting_Audience__c = 'External';
        ev3.Meeting_Purpose__c = 'Client Email';

        ev3.DurationInMinutes = 1;
        ev3.whatId = null;
        ev3.whoId = co.Id;
        ev3.Report_Client_Contact__c = ev3.whoId;
        testEvents.add(ev3);
        Event ev4 = new Event(activityDateTime=System.now().addDays(2));
        ev4.Meeting_Audience__c = 'External';
        ev4.Meeting_Purpose__c = 'Client Email';

        ev4.DurationInMinutes = 1;
        ev4.whatId = null;
        ev4.whoId = co.Id;
        ev4.Report_Client_Contact__c = ev4.whoId;
        testEvents.add(ev4);
        
        Event evallday2 = new Event(activityDate=System.today().addDays(2));
        evallday2.IsAllDayEvent = true;
        evallday2.Meeting_Audience__c = 'External';
        evallday2.Meeting_Purpose__c = 'Client Email';

        evallday2.whatId = null;
        evallday2.whoId = co.Id;
        evallday2.Report_Client_Contact__c = evallday2.whoId;
        testEvents.add(evallday2);
        
        // put in an event related to opportunity
        Event ev5 = new Event(activityDateTime=System.now());
        ev5.Meeting_Audience__c = 'Internal';
        ev5.Meeting_Purpose__c = 'Day To Day Meeting';

        ev5.DurationInMinutes = 1;
        ev5.whatId = op.Id;
        testEvents.add(ev5);
        Event ev6 = new Event(activityDateTime=System.now());
        ev6.Meeting_Audience__c = 'Internal';
        ev6.Meeting_Purpose__c = 'Day To Day Meeting';

        ev6.DurationInMinutes = 1;
        ev6.whatId = op.Id;
        testEvents.add(ev6);
        
        Event evallday3 = new Event(activityDate=System.today().addDays(2));
        evallday3.IsAllDayEvent = true;
        evallday3.Meeting_Audience__c = 'Internal';
        evallday3.Meeting_Purpose__c = 'Day To Day Meeting';

        evallday3.whatId = op.Id;
        testEvents.add(evallday3);
        
        insert testEvents;
        
        list<AccountTeamMember> olstAccountTeamMember = new list<AccountTeamMember>();
          
        AccountTeamMember atm = new AccountTeamMember(); 
        atm.AccountId= testAccounts[0].id; 
        atm.UserId= UserInfo.getUserId(); 
        atm.TeamMemberRole = 'Client Analyst'; 
        olstAccountTeamMember.add(atm);
        insert olstAccountTeamMember; 
        
        Test.startTest();
        /***************************************************************************************
        /**
        /** Test Calendar Invoked from the Calendar Tab for the first time.
        /**
        /** Calendar should load with default view set to the stadard view 'My Team\'s Clients'
        /**
        /**************************************************************************************/
        
        Test.setCurrentPage( Page.SharedCalendar);
        //page parameters required for event data loading on the calendar
        ApexPages.currentPage().getParameters().put('Type',ev.Meeting_Purpose__c+','+evallday.Meeting_Purpose__c);
        ApexPages.currentPage().getParameters().put('start', 
            string.valueof( ev.ActivityDateTime.addMinutes(-1).getTime()/1000)  );
        ApexPages.currentPage().getParameters().put('end',
            string.valueof( ev.ActivityDateTime.addDays(ev.durationInMinutes+1).getTime()/1000) );
            
         //Invoke the calendar from the calendar Tab
        ApexPages.currentPage().getParameters().put('sfdc.tabName','01rW00000000CVG'); // The actual Id here is irrelevant. The test is for existance only. 
        
        SharedCalendarUtils_page f = new SharedCalendarUtils_page ();
        // Invoke Page Action Method
        f.updateRecentViewed();
        
        SharedCalPrefs pref = new SharedCalPrefs();
        System.assertEquals(pref.RecentFilterName, 'Single Client','Filter View NOT saved correctly when invoking from VF Tab');
        System.assertNotEquals(pref.RecentFilter, null);
        System.assertEquals(f.recentFilter.View_Type__c, 'Standard');
        System.assertEquals(f.isCustomView,false);
        
        /***************************************************************************************
        /**
        /** End of Test for Calendar Invoked from the Calendar Tab for the first time.
        /**
        /**************************************************************************************/
        
        // Add both Opportunity Events and Contact events
        ApexPages.currentPage().getParameters().put('includeBoth','true'); 
        f.includeBoth();
        pref = new SharedCalPrefs();
        System.assertEquals(pref.RecentContacts,'true');
        f.updateRecentViewed();
        
        //Change View
        ApexPages.currentPage().getParameters().put('filterName','Single Client'); 
        ApexPages.currentPage().getParameters().put('filterId',testFilters[0].Id);
        f.changeFilterView();
        
        pref = new SharedCalPrefs();
        System.assertEquals(pref.RecentContacts,null);
        f.updateRecentViewed();
        
        //Change the date
        ApexPages.currentPage().getParameters().put('Day','23');
        ApexPages.currentPage().getParameters().put('Month','10');
        ApexPages.currentPage().getParameters().put('Year','1968');
        SharedCalendarUtils_page.updateDateChanged('23','11','1968');
        
        ApexPages.currentPage().getParameters().put('Type','Day To Day Meeting');
        ApexPages.currentPage().getParameters().put('legendFor','Opportunity'); 
        ApexPages.currentPage().getParameters().put('object','Event');
        List<fullcalendarEvent> testEvents2 = f.allEvents;
        
        ApexPages.currentPage().getParameters().put('Type','Day To Day Meeting');
        ApexPages.currentPage().getParameters().put('legendFor','Contact'); 
        ApexPages.currentPage().getParameters().put('object','Event');
        List<fullcalendarEvent> testEvents4 = f.allEvents;
        
        System.assert(testEvents2.size()==0);
        
        ApexPages.currentPage().getParameters().put('calType','Client');
        ApexPages.currentPage().getParameters().put('calledFrom','homePage');
        ApexPages.currentPage().getParameters().put('recordId','None');
        f.saveRecentRecord('Single Client',null,ac.Id); 
        
        //f.saveRecentRecord('Single Client',null,ac.Id); 
        f.updateRecentViewed();
        
        //Invoke the calendar from hierarchy component on the calendar page
        ApexPages.currentPage().getParameters().put('calledFrom','hierarchyPage');
        f.saveRecentRecord('Single Client',null,ac.Id); 
        ApexPages.currentPage().getParameters().put('includeChildren','true');
        f.includeChildren();
        f = new SharedCalendarUtils_page ();
        f.updateRecentViewed();
        
        //Invoke the calendar from hierarchy component on the calendar page without Children
        ApexPages.currentPage().getParameters().put('calledFrom','hierarchyPage');
        f.saveRecentRecord('Single Client',null,ac.Id); 
        ApexPages.currentPage().getParameters().put('includeChildren','false');
        f.includeChildren();
        f = new SharedCalendarUtils_page ();
        f.updateRecentViewed();
        
        
        
        f.selectSearchedRecord();
        
        //Change View
        ApexPages.currentPage().getParameters().put('filterName','CRT Client Hierarchy'); 
        ApexPages.currentPage().getParameters().put('filterId',testFilters[1].Id);
        f.changeFilterView();
        
        
        
        //Change View
        ApexPages.currentPage().getParameters().put('filterName','My Team\'s Clients'); 
        ApexPages.currentPage().getParameters().put('filterId',testFilters[2].Id);
        f.changeFilterView();
        
        //Change View
        ApexPages.currentPage().getParameters().put('filterName','My Client Team\'s Clients'); 
        ApexPages.currentPage().getParameters().put('filterId',testFilters[3].Id);
        f.changeFilterView();
        
        //Change View
        ApexPages.currentPage().getParameters().put('filterName','My Clients'); 
        ApexPages.currentPage().getParameters().put('filterId',testFilters[4].Id);
        f.changeFilterView();
        
        //Change View
        ApexPages.currentPage().getParameters().put('filterName','My Custom View'); 
        ApexPages.currentPage().getParameters().put('filterId',testFilters[5].Id);
        f.changeFilterView();
        
        //Change View
        ApexPages.currentPage().getParameters().put('filterName','My Team\'s Client Team Clients'); 
        ApexPages.currentPage().getParameters().put('filterId',testFilters[5].Id);
        f.changeFilterView();

        // Data
        ApexPages.currentPage().getParameters().put('legendFor','Account'); 
        ApexPages.currentPage().getParameters().put('object','Event');
        ApexPages.currentPage().getParameters().put('Type','Day To Day Meeting');
     f.allEvents = null;
        List<fullcalendarEvent> theTestEvents = f.allEvents;
        //fullcalendarEvent[] ff = f.allEvents;
        //for( fullcalendarEvent ff :f.allEvents ) { mymap.put(ff.id,ff); }
        Test.stopTest();
    }
    
    @IsTest
    static void testSharedCalendarUtils() {
      
       insert TEST_DataFactory.getCcSettings();

        // insert Calendar Type
        Calendar_Type__c testCalType = new Calendar_Type__c();
        testCalType.Name = 'Client';
        insert testCalType;
        
        // insert Filter Views
        List<Calendar_Filter_View__c> testFilters = new List<Calendar_Filter_View__c>();
        Calendar_Filter_View__c testFilterView = new Calendar_Filter_View__c(Name='Single Client',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView);
        insert testFilters;
        
        // put an account
        string uniquename = 'sdlkjsdlsdjflsjdfsdfwieurosdfcxcv2'; 
        Account ac = new Account(name=uniquename );
        insert ac;
        
        // insert contact
        Contact co = new Contact();
        co.Lastname = uniquename;
        co.accountId = ac.Id;
        insert co;
                
        // insert opportunity
        Opportunity op = new Opportunity();
        op.name = uniquename;
        op.accountId = ac.Id;
        op.StageName = 'dummy';
        op.closedate = System.Date.Today();
        insert op;
        
        // add an event linked to client
        List<Event> testEvents = new List<event>();
        
        Event ev7 = new Event(activityDateTime=System.now());
        ev7.Meeting_Audience__c = 'Internal';
        ev7.Meeting_Purpose__c = 'Day To Day Meeting';

        ev7.DurationInMinutes = 1;
        ev7.whatId = ac.id;
        testEvents.add(ev7);
        
        Event ev = new Event(activityDateTime=System.now());
        ev.Meeting_Audience__c = 'Internal';
        ev.Meeting_Purpose__c = 'Day To Day Meeting';

        ev.DurationInMinutes = 1;
        ev.whatId = ac.Id;
        testEvents.add(ev);
        
        Event ev2 = new Event(activityDateTime=System.now());
        ev2.Meeting_Audience__c = 'Internal';
        ev2.Meeting_Purpose__c = 'Day To Day Meeting';

        ev2.DurationInMinutes = 1;
        ev2.whatId = ac.Id;
        testEvents.add(ev2);
        
        Event evallday = new Event(activityDate=System.today());
        evallday.IsAllDayEvent = true;
        evallday.Meeting_Audience__c = 'Internal';
        evallday.Meeting_Purpose__c = 'Day To Day Meeting';

        evallday.whatId = ac.Id;
        testEvents.add(evallday);
        
        // put in an event related to client contact
        Event ev3 = new Event(activityDateTime=System.now());
        ev3.Meeting_Audience__c = 'External';
        ev3.Meeting_Purpose__c = 'Client Email';

        ev3.DurationInMinutes = 1;
        ev3.whatId = null;
        ev3.whoId = co.Id;
        ev3.Report_Client_Contact__c = ev3.whoId;
        testEvents.add(ev3);
        
        Event ev4 = new Event(activityDateTime=System.now());
        ev4.Meeting_Audience__c = 'External';
        ev4.Meeting_Purpose__c = 'Client Email';

        ev4.DurationInMinutes = 1;
        ev4.whatId = null;
        ev4.whoId = co.Id;
        ev4.Report_Client_Contact__c = ev4.whoId;
        testEvents.add(ev4);
        
        Event evallday2 = new Event(activityDate=System.today());
        evallday2.IsAllDayEvent = true;
        evallday2.Meeting_Audience__c = 'External';
        evallday2.Meeting_Purpose__c = 'Client Email';

        evallday2.whatId = null;
        evallday2.whoId = co.Id;
        evallday2.Report_Client_Contact__c = evallday2.whoId;
        testEvents.add(evallday2);
        
        // put in an event related to opportunity
        Event ev5 = new Event(activityDateTime=System.now());
        ev5.Meeting_Audience__c = 'Internal';
        ev5.Meeting_Purpose__c = 'Day To Day Meeting';

        ev5.DurationInMinutes = 1;
        ev5.whatId = op.Id;
        //ev5.whoId = co.Id;
        testEvents.add(ev5);
        Event ev6 = new Event(activityDateTime=System.now());
        ev6.Meeting_Audience__c = 'Internal';
        ev6.Meeting_Purpose__c = 'Day To Day Meeting';

        ev6.DurationInMinutes = 1;
        ev6.whatId = op.Id;
        testEvents.add(ev6);

        
        Event evallday3 = new Event(activityDate=System.today());
        evallday3.IsAllDayEvent = true;
        evallday3.Meeting_Audience__c = 'Internal';
        evallday3.Meeting_Purpose__c = 'Day To Day Meeting';

        evallday3.whatId = op.Id;
        testEvents.add(evallday3);
        
        insert testEvents;
               
        SharedCalPrefs pref = new SharedCalPrefs();
        Test.startTest();
        try {
            Test.setCurrentPage( Page.SharedCalendar);
            //page parameters required for event data loading on the calendar
            ApexPages.currentPage().getParameters().put('Type','Day To Day Meeting');
            ApexPages.currentPage().getParameters().put('start', string.valueof(testEvents[0].activityDateTime.addMinutes(-1).getTime()/1000)  );
            ApexPages.currentPage().getParameters().put('end', string.valueof( testEvents[0].activityDateTime.addDays(1).getTime()/1000) );

            //Calendar Invoke
            //Invoke the calendar from the record detail Page
            ApexPages.currentPage().getParameters().put('calType','Client');
            ApexPages.currentPage().getParameters().put('recordId',ac.Id);
            ApexPages.currentPage().getParameters().put('calledFrom','detailPage');

            SharedCalendarUtils_page f = new SharedCalendarUtils_page ();

            f.saveRecentRecord('Single Client', testFilters[0].id, null );
            f.saveRecentRecord(null, testFilters[0].id, null );

            ApexPages.currentPage().getParameters().put('filterId',testFilters[0].id);
            ApexPages.currentPage().getParameters().put('sfdc.tabName','01rW00000000CVG');
            f.updateRecentViewed();

            f.selectSearchedRecord();


            //My Clients
            pref.saveFilterName('My Clients');
            pref.saveRecord('');
            f.selectSearchedRecord();
            f.eventObjectName = 'Event';
            ApexPages.currentPage().getParameters().put('Type','Day To Day Meeting');
            ApexPages.currentPage().getParameters().put('object','Event');
            ApexPages.currentPage().getParameters().put('legendFor','Contact');
            ApexPages.currentPage().getParameters().put('includeContacts','true');
            f.includeContacts();
            List<fullcalendarEvent> testEvents8 = f.allEvents;

            ApexPages.currentPage().getParameters().put('Type','Day To Day Meeting');
            ApexPages.currentPage().getParameters().put('includeOppys','true');
            ApexPages.currentPage().getParameters().put('legendFor','Opportunity');
            ApexPages.currentPage().getParameters().put('object','Event');
            f.includeOppys();
            f.updateRecentViewed();
            List<fullcalendarEvent> testEvents11 = f.allEvents;

            ApexPages.currentPage().getParameters().put('Type','Day To Day Meeting');
            ApexPages.currentPage().getParameters().put('object','Event');
            ApexPages.currentPage().getParameters().put('legendFor','Account');
            ApexPages.currentPage().getParameters().put('includeChildren','false');
            f.includeChildren();
            f.updateRecentViewed();
            List<fullcalendarEvent> testEvents12 = f.allEvents;

            //My Team's Clients
            pref.saveFilterName('My Team\'s Clients');
            pref.saveRecord('');
            f.selectSearchedRecord();
            f.eventObjectName = 'Event';
            ApexPages.currentPage().getParameters().put('Type','Day To Day Meeting');
            ApexPages.currentPage().getParameters().put('object','Event');
            ApexPages.currentPage().getParameters().put('legendFor','Contact');
            ApexPages.currentPage().getParameters().put('includeContacts','true');
            f.includeContacts();
            List<fullcalendarEvent> testEvents9 = f.allEvents;

            ApexPages.currentPage().getParameters().put('Type','Day To Day Meeting');
            ApexPages.currentPage().getParameters().put('includeChildren','false');
            ApexPages.currentPage().getParameters().put('legendFor','Account');
            ApexPages.currentPage().getParameters().put('object','Event');
            f.includeChildren();
            f.updateRecentViewed();
            List<fullcalendarEvent> testEvents10 = f.allEvents;

            ApexPages.currentPage().getParameters().put('Type','Day To Day Meeting');
            ApexPages.currentPage().getParameters().put('includeOppys','true');
            ApexPages.currentPage().getParameters().put('legendFor','Opportunity');
            ApexPages.currentPage().getParameters().put('object','Event');
            f.includeOppys();
            f.updateRecentViewed();
            List<fullcalendarEvent> testEvents6 = f.allEvents;

            pageReference newPage = new pageReference('apex/sharedCalendar?');
            Test.setCurrentPage(newPage);
            ApexPages.currentPage().getParameters().put('Type','Day To Day Meeting');
            SharedCalendarUtils_page controller = new SharedCalendarUtils_page ();

            //My Client Team's Clients
            pref.saveFilterName('My Client Team\'s Clients');
            pref.saveRecord('');
            f.selectSearchedRecord();
            f.eventObjectName = 'Event';

            ApexPages.currentPage().getParameters().put('Type','Day To Day Meeting');
            ApexPages.currentPage().getParameters().put('object','Event');
            ApexPages.currentPage().getParameters().put('legendFor','Contact');
            ApexPages.currentPage().getParameters().put('includeContacts','true');
            f.includeContacts();
            List<fullcalendarEvent> testEvents4 = f.allEvents;

            ApexPages.currentPage().getParameters().put('Type','Day To Day Meeting');
            ApexPages.currentPage().getParameters().put('includeChildren','false');
            ApexPages.currentPage().getParameters().put('legendFor','Account');
            ApexPages.currentPage().getParameters().put('object','Event');
            f.includeChildren();
            f.updateRecentViewed();
            List<fullcalendarEvent> testEvents5 = f.allEvents;


            ApexPages.currentPage().getParameters().put('recordId','');
            f.updateRecentViewed();
            f.changeFilterView();

            // move a normal event
            ApexPages.currentPage().getParameters().put('eventId',testEvents[0].id);
            ApexPages.currentPage().getParameters().put('dayDelta','1');
            ApexPages.currentPage().getParameters().put('minuteDelta','10');
            SharedCalendarUtils_page.updateEventMove(testEvents[0].id,'1','10');

            // move an all day event
            ApexPages.currentPage().getParameters().put('eventId',testEvents[2].id);
            ApexPages.currentPage().getParameters().put('dayDelta','1');
            ApexPages.currentPage().getParameters().put('minuteDelta','0');
            SharedCalendarUtils_page.updateEventMove(testEvents[3].id,'1','0');

            ApexPages.currentPage().getParameters().put('eventId',testEvents[0].id);
            ApexPages.currentPage().getParameters().put('minuteDelta','10');
            f.updateEventResize();
            SharedCalendarUtils_page.deleteEventById(testEvents[0].id);
        }
        catch(Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
     }

    @IsTest
    static void testSharedCalendarUtilsSingleClient() {
        
       insert TEST_DataFactory.getCcSettings();

        List<account> testAccounts = new List<account>();
        // put an account
        string uniquename = 'sdlkjsdlsdjflsjdfsdfwieurosdfcxcv2'; 
        Account ac = new Account();
        
        ac.name = uniquename;
        ac.RecordTypeId = immParentRecTypeId;
        insert ac;
        
        // put a child account
        string uniquechildname = 'childsdlkjsdlsdjflsjdfsdfwieurosdfcxcv1'; 
        Account achild = new Account();
        
        achild.name = uniquechildname;
        achild.parentId = ac.Id;
        achild.Client_Relationship_Hierarchy__c = 'Child';
        achild.RecordTypeId = prospectRecTypeId;
        achild.Client_Sector__c = 'Unknown Sector';
        achild.Client_Sub_Sector__c = 'Unknown Sub-Sector';
        testAccounts.add(achild);
        insert achild ;
        
        // insert contact
        Contact co = new Contact();
        co.Lastname = uniquename;
        co.accountId = ac.Id;
        insert co;
        
        // insert opportunity
        Opportunity op = new Opportunity();
        op.name = uniquename;
        op.accountId = ac.Id;
        op.StageName = 'dummy';
        op.closedate = System.Date.Today();
        insert op;
        
        // insert Calendar Type
        Calendar_Type__c testCalType = new Calendar_Type__c();
        testCalType.Name = 'Client';
        insert testCalType;
        
        // insert Filter Views
        List<Calendar_Filter_View__c> testFilters = new List<Calendar_Filter_View__c>();
        Calendar_Filter_View__c testFilterView = new Calendar_Filter_View__c(Name='Single Client',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView);
        Calendar_Filter_View__c testFilterView2 = new Calendar_Filter_View__c(Name='CRT Client Hierarchy',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView2);
        Calendar_Filter_View__c testFilterView3 = new Calendar_Filter_View__c(Name='My Team\'s Clients',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView3);
        Calendar_Filter_View__c testFilterView4 = new Calendar_Filter_View__c(Name='My Client Team\'s Clients',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView4);
        Calendar_Filter_View__c testFilterView5 = new Calendar_Filter_View__c(Name='My Clients',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView5);
        Calendar_Filter_View__c testFilterView6 = new Calendar_Filter_View__c(Name='My Custom View',View_Type__c='Custom',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView6);
        
        insert testFilters;
        
        
        //insert Calendar Content
        List<Calendar_Content__c> testCalCon = new List<Calendar_Content__c>();
        Calendar_Content__c testCalContent = new Calendar_Content__c();
        testCalContent.Name = 'Client Events';
        testCalContent.Event_Start_Field__c = 'Start';
        testCalContent.Event_Title_Field__c = 'Subject';
        testCalContent.Event_Legend_Field__c = 'Meeting_Purpose__c';
        testCalContent.Event_Object_Name__c = 'Event';
        testCalContent.Hierarchy_Object_Name__c = 'Account';
        testCalContent.Hierarchy_Relation_Field__c = 'ParentId';
        testCalContent.Calendar_Type__c = testCalType.Id;
        testCalCon.add(testCalContent);
        
        Calendar_Content__c testCalContent1 = new Calendar_Content__c();
        testCalContent1.Name = 'Client Contact Events';
        testCalContent1.Event_Start_Field__c = 'Start';
        testCalContent1.Event_Title_Field__c = 'Subject';
        testCalContent1.Event_Legend_Field__c = 'Meeting_Purpose__c';
        testCalContent1.Event_Object_Name__c = 'Event';
        testCalContent1.Hierarchy_Object_Name__c = 'Contact';
        testCalContent1.Hierarchy_Relation_Field__c = 'ReportsToId';
        testCalContent1.Calendar_Type__c = testCalType.Id;
        testCalCon.add(testCalContent1);
        
        Calendar_Content__c testCalContent2 = new Calendar_Content__c();
        testCalContent2.Name = 'Client Opportunity Events';
        testCalContent2.Event_Start_Field__c = 'Start';
        testCalContent2.Event_Title_Field__c = 'Subject';
        testCalContent2.Event_Legend_Field__c = 'Meeting_Purpose__c';
        testCalContent2.Event_Object_Name__c = 'Event';
        testCalContent2.Hierarchy_Object_Name__c = 'Opportunity';
        testCalContent2.Calendar_Type__c = testCalType.Id;
        testCalCon.add(testCalContent2);
        insert testCalCon ;
        
        //insert Calendar Legend
        Calendar_Legend__c calLegend = new Calendar_Legend__c();
        calLegend.Name = 'Call';
        calLegend.Background_Color__c = 'blue';
        calLegend.Calendar_Content__c = testCalContent.Id;
        insert calLegend;
        
        // add an event linked to client
        List<Event> testEvents = new List<event>();
        Event ev = new Event(activityDateTime=System.now());
        ev.Meeting_Audience__c = 'Internal';
        ev.Meeting_Purpose__c = 'Day To Day Meeting';

        ev.DurationInMinutes = 1;
        ev.whatId = ac.Id;
        testEvents.add(ev);
        Event ev2 = new Event(activityDateTime=System.now());
        ev2.Meeting_Audience__c = 'Internal';
        ev2.Meeting_Purpose__c = 'Day To Day Meeting';

        ev2.DurationInMinutes = 1;
        ev2.whatId = ac.Id;
        testEvents.add(ev2);
        
        Event evallday = new Event(activityDate=System.today());
        evallday.IsAllDayEvent = true;
        evallday.Meeting_Audience__c = 'Internal';
        evallday.Meeting_Purpose__c = 'Day To Day Meeting';

        evallday.whatId = ac.Id;
        testEvents.add(evallday);
        
        // put in an event related to client contact
        Event ev3 = new Event(activityDateTime=System.now());
        ev3.Meeting_Audience__c = 'External';
        ev3.Meeting_Purpose__c = 'Client Email';

        ev3.DurationInMinutes = 1;
        ev3.whatId = null;
        ev3.whoId = co.Id;
        ev3.Report_Client_Contact__c = ev3.whoId;
        testEvents.add(ev3);
        
        Event ev4 = new Event(activityDateTime=System.now());
        ev4.Meeting_Audience__c = 'External';
        ev4.Meeting_Purpose__c = 'Client Email';

        ev4.DurationInMinutes = 1;
        ev4.whatId = null;
        ev4.whoId = co.Id;
        ev4.Report_Client_Contact__c = ev4.whoId;
        testEvents.add(ev4);
        
        Event evallday2 = new Event(activityDate=System.today());
        evallday2.IsAllDayEvent = true;
        evallday2.Meeting_Audience__c = 'External';
        evallday2.Meeting_Purpose__c = 'Client Email';

        evallday2.whatId = null;
        evallday2.whoId = co.Id;
        evallday2.Report_Client_Contact__c = evallday2.whoId;
        testEvents.add(evallday2);
        
        // put in an event related to opportunity
        Event ev5 = new Event(activityDateTime=System.now());
        ev5.Meeting_Audience__c = 'Internal';
        ev5.Meeting_Purpose__c = 'Day To Day Meeting';

        ev5.DurationInMinutes = 1;
        ev5.whatId = op.Id;
        //ev5.whoId = co.Id;
        testEvents.add(ev5);
        Event ev6 = new Event(activityDateTime=System.now());
        ev6.Meeting_Audience__c = 'Internal';
        ev6.Meeting_Purpose__c = 'Day To Day Meeting';

        ev6.DurationInMinutes = 1;
        ev6.whatId = op.Id;
        testEvents.add(ev6);

        
        Event evallday3 = new Event(activityDate=System.today());
        evallday3.IsAllDayEvent = true;
        evallday3.Meeting_Audience__c = 'Internal';
        evallday3.Meeting_Purpose__c = 'Day To Day Meeting';

        evallday3.whatId = op.Id;
        testEvents.add(evallday3);
        
        insert testEvents;
        
        SharedCalPrefs pref = new SharedCalPrefs();
        Test.startTest();
        try {
            Test.setCurrentPage( Page.SharedCalendar);
            //page parameters required for event data loading on the calendar
            ApexPages.currentPage().getParameters().put('Type',testEvents[0].Meeting_Purpose__c+','+testEvents[2].Meeting_Purpose__c);
            ApexPages.currentPage().getParameters().put('start', string.valueof( ev.ActivityDateTime.addMinutes(-1).getTime()/1000)  );
            ApexPages.currentPage().getParameters().put('end', string.valueof( ev.ActivityDateTime.addDays(ev.durationInMinutes+1).getTime()/1000) );

            //Calendar Invoke
            //Invoke the calendar from the record detail Page
            ApexPages.currentPage().getParameters().put('calType','Client');
            ApexPages.currentPage().getParameters().put('recordId',ac.Id);
            ApexPages.currentPage().getParameters().put('calledFrom','detailPage');

            SharedCalendarUtils_page f = new SharedCalendarUtils_page ();

            // Search for a client
            //allDynamicRecords

            ApexPages.currentPage().getParameters().put('term',uniquechildname);
            Account[] gl = f.allDynamicRecords;
            system.assert( gl[0].name == uniquechildname,' missing client');

            //Invoke the calendar from the autocomplete client search
            ApexPages.currentPage().getParameters().put('calType','Client');
            ApexPages.currentPage().getParameters().put('selectedRecordId',gl[0].Id);
            ApexPages.currentPage().getParameters().put('calledFrom','detailPage');
            SharedCalendarUtils_page f2 = new SharedCalendarUtils_page ();

            //allDynamicRecords no default calendar type

            ApexPages.currentPage().getParameters().put('term',uniquechildname);
            Account[] gl2 = f.allDynamicRecords;
            system.assert( gl2[0].name == uniquechildname,' missing client');

            //Invoke the calendar from the autocomplete client search
            ApexPages.currentPage().getParameters().put('calType','');
            ApexPages.currentPage().getParameters().put('selectedRecordId',gl2[0].Id);
            ApexPages.currentPage().getParameters().put('calledFrom','detailPage');
            SharedCalendarUtils_page f3 = new SharedCalendarUtils_page ();


            //Legend 0
            CalendarLegend_page l0 = new CalendarLegend_page();
            l0.objectName = 'Opportunity';
            List<CalendarLegend_page.eventTypeClass> testEventType0 = l0.eventType;

            //Legend 1
            CalendarLegend_page l1 = new CalendarLegend_page();
            l1.objectName = 'Contact';
            l1.eventObjectName = 'Event';
            List<CalendarLegend_page.eventTypeClass> testEventType1 = l1.eventType;

            //Legend 2
            CalendarLegend_page l2 = new CalendarLegend_page();
            l2.objectName = 'Account';
            List<CalendarLegend_page.eventTypeClass> testEventType2 = l2.eventType;

            // Components - Show hierarchy
            HierarchyStructure_page testBaseComp = new HierarchyStructure_page();
            f2.setComponentController(testBaseComp);
            f2.getMyComponentController();
            f2.getThis();
            f2.setComponentControllerMap('accountHierarchy',testBaseComp );
            f2.getComponentControllerMap();
            f.getMyComponentController();
            f2.setHierarchy(gl2[0].Id,'Client');
            system.assert(f2.hasHierarchy == true);

            pref.saveContacts('true');
            pref.saveChildren('true');

            //List<Id> testRecordIds = f2.recordIds;
            ComponentControllerBase tc = f2.MyComponentController;
            // Filters & Views
            List<SelectOption> testViewNames = f.viewNames;
            f.currentView = testFilterView.Id;

            Boolean test1 = f.showClientOppyEvents ;
            Boolean test2 = f.renderLegend  ;

            // Single Client View
            pref.saveFilterName('Single Client');
            pref.saveRecord('');
            f.updateRecentViewed();
            f.selectSearchedRecord();
            f.setHierarchy(ac.Id, 'Client');
            f.eventObjectName = 'Event';
            //List<Id> theIds = f.recordIds;
            f.myComponentController = null;

            ApexPages.currentPage().getParameters().put('Type','Client Call');
            ApexPages.currentPage().getParameters().put('includeOppys','true');
            ApexPages.currentPage().getParameters().put('legendFor','Opportunity');
            ApexPages.currentPage().getParameters().put('object','Event');
            ApexPages.currentPage().getParameters().put('recordId',ac.Id);
            ApexPages.currentPage().getParameters().put('filterName','Single Client');
            f.includeOppys();
            f.updateRecentViewed();
            List<fullcalendarEvent> testEvents3 = f.allEvents;

            ApexPages.currentPage().getParameters().put('Type','Client Call');
            ApexPages.currentPage().getParameters().put('object','Event');
            ApexPages.currentPage().getParameters().put('legendFor','Account');
            ApexPages.currentPage().getParameters().put('includeChildren','false');
            f.includeChildren();
            f.updateRecentViewed();
            List<fullcalendarEvent> testEvents2 = f.allEvents;
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();                            
    }   

    @IsTest
    static void testSharedCalendarUtilsOther() {
       insert TEST_DataFactory.getCcSettings();
        SharedCalPrefs pref = new SharedCalPrefs();
        Test.startTest();
        try {
            Test.setCurrentPage( Page.SharedCalendar);
            //page parameters required for event data loading on the calendar
            ApexPages.currentPage().getParameters().put('Type','Client Conference Call,Client Meeting');
            ApexPages.currentPage().getParameters().put('start', string.valueof( System.Now().addMinutes(-1).getTime()/1000)  );
            ApexPages.currentPage().getParameters().put('end', string.valueof( System.Now().addDays(+1).getTime()/1000) );

            SharedCalendarUtils_page f = new SharedCalendarUtils_page ();
            ApexPages.currentPage().getParameters().put('view','month');
            SharedCalendarUtils_page.viewDisplay('month');
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testSharedCalendarUtilsMyClients() {
     
       insert TEST_DataFactory.getCcSettings();

        List<account> testAccounts = new List<account>();
        // put an account
        string uniquename = 'sdlkjsdlsdjflsjdfsdfwieurosdfcxcv2'; 
        Account ac = new Account();
        
        ac.name = uniquename;
        ac.RecordTypeId = immParentRecTypeId;
        insert ac;
        
        // put a child account
        string uniquechildname = 'childsdlkjsdlsdjflsjdfsdfwieurosdfcxcv1'; 
        Account achild = new Account();
        
        achild.name = uniquechildname;
        achild.parentId = ac.Id;
        achild.Client_Relationship_Hierarchy__c = 'Child';
        achild.RecordTypeId = prospectRecTypeId;
        achild.Client_Sector__c = 'Unknown Sector';
        achild.Client_Sub_Sector__c = 'Unknown Sub-Sector';
        testAccounts.add(achild);
        insert achild ;
        
        // insert contact
        Contact co = new Contact();
        co.Lastname = uniquename;
        co.accountId = ac.Id;
        insert co;
        
        // insert opportunity
        Opportunity op = new Opportunity();
        op.name = uniquename;
        op.accountId = ac.Id;
        op.StageName = 'dummy';
        op.closedate = System.Date.Today();
        insert op;
        
        // insert Calendar Type
        Calendar_Type__c testCalType = new Calendar_Type__c();
        testCalType.Name = 'Client';
        insert testCalType;
        
        // insert Filter Views
        List<Calendar_Filter_View__c> testFilters = new List<Calendar_Filter_View__c>();
        Calendar_Filter_View__c testFilterView = new Calendar_Filter_View__c(Name='Single Client',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView);
        Calendar_Filter_View__c testFilterView2 = new Calendar_Filter_View__c(Name='CRT Client Hierarchy',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView2);
        Calendar_Filter_View__c testFilterView3 = new Calendar_Filter_View__c(Name='My Team\'s Clients',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView3);
        Calendar_Filter_View__c testFilterView4 = new Calendar_Filter_View__c(Name='My Client Team\'s Clients',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView4);
        Calendar_Filter_View__c testFilterView5 = new Calendar_Filter_View__c(Name='My Clients',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView5);
        Calendar_Filter_View__c testFilterView6 = new Calendar_Filter_View__c(Name='My Custom View',View_Type__c='Custom',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView6);
        
        insert testFilters;
        
        
        //insert Calendar Content
        List<Calendar_Content__c> testCalCon = new List<Calendar_Content__c>();
        Calendar_Content__c testCalContent = new Calendar_Content__c();
        testCalContent.Name = 'Client Events';
        testCalContent.Event_Start_Field__c = 'Start';
        testCalContent.Event_Title_Field__c = 'Subject';
        testCalContent.Event_Legend_Field__c = 'Meeting_Purpose__c';
        testCalContent.Event_Object_Name__c = 'Event';
        testCalContent.Hierarchy_Object_Name__c = 'Account';
        testCalContent.Hierarchy_Relation_Field__c = 'ParentId';
        testCalContent.Calendar_Type__c = testCalType.Id;
        testCalCon.add(testCalContent);
        
        Calendar_Content__c testCalContent1 = new Calendar_Content__c();
        testCalContent1.Name = 'Client Contact Events';
        testCalContent1.Event_Start_Field__c = 'Start';
        testCalContent1.Event_Title_Field__c = 'Subject';
        testCalContent1.Event_Legend_Field__c = 'Meeting_Purpose__c';
        testCalContent1.Event_Object_Name__c = 'Event';
        testCalContent1.Hierarchy_Object_Name__c = 'Contact';
        testCalContent1.Hierarchy_Relation_Field__c = 'ReportsToId';
        testCalContent1.Calendar_Type__c = testCalType.Id;
        testCalCon.add(testCalContent1);
        
        Calendar_Content__c testCalContent2 = new Calendar_Content__c();
        testCalContent2.Name = 'Client Opportunity Events';
        testCalContent2.Event_Start_Field__c = 'Start';
        testCalContent2.Event_Title_Field__c = 'Subject';
        testCalContent2.Event_Legend_Field__c = 'Meeting_Purpose__c';
        testCalContent2.Event_Object_Name__c = 'Event';
        testCalContent2.Hierarchy_Object_Name__c = 'Opportunity';
        testCalContent2.Calendar_Type__c = testCalType.Id;
        testCalCon.add(testCalContent2);
        insert testCalCon ;
        
        //insert Calendar Legend
        Calendar_Legend__c calLegend = new Calendar_Legend__c();
        calLegend.Name = 'Call';
        calLegend.Background_Color__c = 'blue';
        calLegend.Calendar_Content__c = testCalContent.Id;
        insert calLegend;
        
        // add an event linked to client
        List<Event> testEvents = new List<event>();
        Event ev = new Event(activityDateTime=System.now());
        ev.Meeting_Audience__c = 'Internal';
        ev.Meeting_Purpose__c = 'Day To Day Meeting';

        ev.DurationInMinutes = 1;
        ev.whatId = ac.Id;
        testEvents.add(ev);
        Event ev2 = new Event(activityDateTime=System.now());
        ev2.Meeting_Audience__c = 'Internal';
        ev2.Meeting_Purpose__c = 'Day To Day Meeting';

        ev2.DurationInMinutes = 1;
        ev2.whatId = ac.Id;
        testEvents.add(ev2);
        
        Event evallday = new Event(activityDate=System.today());
        evallday.IsAllDayEvent = true;
        evallday.Meeting_Audience__c = 'Internal';
        evallday.Meeting_Purpose__c = 'Day To Day Meeting';

        evallday.whatId = ac.Id;
        testEvents.add(evallday);
        
        // put in an event related to client contact
        Event ev3 = new Event(activityDateTime=System.now());
        ev3.Meeting_Audience__c = 'External';
        ev3.Meeting_Purpose__c = 'Client Email';

        ev3.DurationInMinutes = 1;
        ev3.whatId = null;
        ev3.whoId = co.Id;
        ev3.Report_Client_Contact__c = ev3.whoId;
        testEvents.add(ev3);
        
        Event ev4 = new Event(activityDateTime=System.now());
        ev4.Meeting_Audience__c = 'External';
        ev4.Meeting_Purpose__c = 'Client Email';

        ev4.DurationInMinutes = 1;
        ev4.whatId = null;
        ev4.whoId = co.Id;
        ev4.Report_Client_Contact__c = ev4.whoId;
        testEvents.add(ev4);
        
        Event evallday2 = new Event(activityDate=System.today());
        evallday2.IsAllDayEvent = true;
        evallday2.Meeting_Audience__c = 'External';
        evallday2.Meeting_Purpose__c = 'Client Email';

        evallday2.whatId = null;
        evallday2.whoId = co.Id;
        evallday2.Report_Client_Contact__c = evallday2.whoId;
        testEvents.add(evallday2);
        
        // put in an event related to opportunity
        Event ev5 = new Event(activityDateTime=System.now());
        ev5.Meeting_Audience__c = 'Internal';
        ev5.Meeting_Purpose__c = 'Day To Day Meeting';

        ev5.DurationInMinutes = 1;
        ev5.whatId = op.Id;
        ev5.whoId = co.Id;
        testEvents.add(ev5);
        Event ev6 = new Event(activityDateTime=System.now());
        ev6.Meeting_Audience__c = 'Internal';
        ev6.Meeting_Purpose__c = 'Day To Day Meeting';

        ev6.DurationInMinutes = 1;
        ev6.whatId = op.Id;
        testEvents.add(ev6);

        
        Event evallday3 = new Event(activityDate=System.today());
        evallday3.IsAllDayEvent = true;
        evallday3.Meeting_Audience__c = 'Internal';
        evallday3.Meeting_Purpose__c = 'Day To Day Meeting';

        evallday3.whatId = op.Id;
        testEvents.add(evallday3);
        
        insert testEvents;
        
        SharedCalPrefs pref = new SharedCalPrefs();
        
        
        Test.startTest();
        Test.setCurrentPage( Page.SharedCalendar);
        //page parameters required for event data loading on the calendar
        ApexPages.currentPage().getParameters().put('Type',testEvents[0].Meeting_Purpose__c+','+testEvents[2].Meeting_Purpose__c);
        ApexPages.currentPage().getParameters().put('start', string.valueof( ev.ActivityDateTime.addMinutes(-1).getTime()/1000)  );
        ApexPages.currentPage().getParameters().put('end', string.valueof( ev.ActivityDateTime.addDays(ev.durationInMinutes+1).getTime()/1000) );
        
        //Calendar Invoke
        //Invoke the calendar from the record detail Page
        ApexPages.currentPage().getParameters().put('calType','Client');
        ApexPages.currentPage().getParameters().put('recordId',ac.Id);
        ApexPages.currentPage().getParameters().put('calledFrom','detailPage');
        
        SharedCalendarUtils_page f = new SharedCalendarUtils_page ();
            
        // Search for a client
        //allDynamicRecords
        
        ApexPages.currentPage().getParameters().put('term',uniquechildname); 
        Account[] gl = f.allDynamicRecords;
        system.assert( gl[0].name == uniquechildname,' missing client'); 
        
        //Invoke the calendar from the autocomplete client search
        ApexPages.currentPage().getParameters().put('calType','Client');
        ApexPages.currentPage().getParameters().put('selectedRecordId',gl[0].Id);
        ApexPages.currentPage().getParameters().put('calledFrom','detailPage');
        SharedCalendarUtils_page f2 = new SharedCalendarUtils_page ();
        
        //allDynamicRecords no default calendar type
        
        ApexPages.currentPage().getParameters().put('term',uniquechildname); 
        Account[] gl2 = f.allDynamicRecords;
        system.assert( gl2[0].name == uniquechildname,' missing client'); 
        
        //Invoke the calendar from the autocomplete client search
        ApexPages.currentPage().getParameters().put('calType','');
        ApexPages.currentPage().getParameters().put('selectedRecordId',gl2[0].Id);
        ApexPages.currentPage().getParameters().put('calledFrom','detailPage');
        SharedCalendarUtils_page f3 = new SharedCalendarUtils_page ();

        
        //Legend 0
        CalendarLegend_page l0 = new CalendarLegend_page();
        l0.objectName = 'Opportunity';
        List<CalendarLegend_page.eventTypeClass> testEventType0 = l0.eventType;
        
        //Legend 1
        CalendarLegend_page l1 = new CalendarLegend_page();
        l1.objectName = 'Contact';
        l1.eventObjectName = 'Event';
        List<CalendarLegend_page.eventTypeClass> testEventType1 = l1.eventType;

        //Legend 2
        CalendarLegend_page l2 = new CalendarLegend_page();
        l2.objectName = 'Account';
        List<CalendarLegend_page.eventTypeClass> testEventType2 = l2.eventType;
       
        // Components - Show hierarchy
        HierarchyStructure_page testBaseComp = new HierarchyStructure_page();
        f2.setComponentController(testBaseComp);
        f2.getMyComponentController();
        f2.getThis();
        f2.setComponentControllerMap('accountHierarchy',testBaseComp );
        f2.getComponentControllerMap();
        f.getMyComponentController();
        f2.setHierarchy(gl2[0].Id,'Client');
        system.assert(f2.hasHierarchy == true);
        
        pref.saveContacts('true');
        pref.saveChildren('true');
        
        //List<Id> testRecordIds = f2.recordIds;
        ComponentControllerBase tc = f2.MyComponentController;
        // Filters & Views
        List<SelectOption> testViewNames = f.viewNames;
        f.currentView = testFilterView.Id;
        
        
        // Single Client View
        pref.saveFilterName('My Clients');
        pref.saveRecord('');
        f.updateRecentViewed();
        f.selectSearchedRecord();
        f.setHierarchy(ac.Id, 'Client');
        f.eventObjectName = 'Event';
        //List<Id> theIds = f.recordIds;
        f.myComponentController = null;
        
        ApexPages.currentPage().getParameters().put('Type','Day To Day Meeting');
        ApexPages.currentPage().getParameters().put('object','Event');
        ApexPages.currentPage().getParameters().put('legendFor','Account'); 
        ApexPages.currentPage().getParameters().put('includeChildren','false');  
        f.includeChildren();
        f.updateRecentViewed();
        List<fullcalendarEvent> testEvents2 = f.allEvents;
        
        ApexPages.currentPage().getParameters().put('Type','Day To Day Meeting');
        ApexPages.currentPage().getParameters().put('object','Event');
        ApexPages.currentPage().getParameters().put('legendFor','Contact'); 
        ApexPages.currentPage().getParameters().put('includeContacts','true'); 
        f.includeContacts();
        f.updateRecentViewed();
        List<fullcalendarEvent> testEvents1 = f.allEvents;
        
        ApexPages.currentPage().getParameters().put('Type','Day To Day Meeting');
        ApexPages.currentPage().getParameters().put('includeOppys','true'); 
        ApexPages.currentPage().getParameters().put('legendFor','Opportunity'); 
        ApexPages.currentPage().getParameters().put('object','Event');
        f.includeOppys();
        f.updateRecentViewed();
        List<fullcalendarEvent> testEvents3 = f.allEvents;
         
        map<id,fullcalendarEvent> mymap = new Map<id,fullcalendarEvent>();
        f.allEvents = null;
        //for( fullcalendarEvent ff:f.allEvents ) { mymap.put(ff.id,ff); }
        //System.assert( mymap.get(ev.id) != null , 'missing event ');
        //System.assert( mymap.get(evallday.id) != null , 'missing event ');
        
        ApexPages.currentPage().getParameters().put('eventId',testEvents[0].id);
        ApexPages.currentPage().getParameters().put('ownerId',Userinfo.getUserId() );

        Test.stopTest();                            
    }

    @IsTest
    static void testSharedCalendarUtilsMyTeamsClients() {
      
       insert TEST_DataFactory.getCcSettings();

        List<Account> testAccounts = new List<Account>();
        // put an account
        string uniquename = 'sdlkjsdlsdjflsjdfsdfwieurosdfcxcv1'; 
        Account ac = new Account();
        
        ac.name = uniquename;
        
        testAccounts.add(ac);
        insert testAccounts;
                
        // insert contact
        Contact co = new Contact();
        co.Lastname = uniquename;
        co.accountId = ac.Id;
        insert co;
        
        // insert opportunity
        Opportunity op = new Opportunity();
        op.name = uniquename+1;
        op.accountId = ac.Id;
        op.StageName = 'dummy';
        op.closedate = System.Date.Today();
        insert op;
        
        // insert Calendar Type
        Calendar_Type__c testCalType = new Calendar_Type__c();
        testCalType.Name = 'Client';
        insert testCalType;
        
        // insert Filter Views
        List<Calendar_Filter_View__c> testFilters = new List<Calendar_Filter_View__c>();
        Calendar_Filter_View__c testFilterView = new Calendar_Filter_View__c(Name='Single Client',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView);
        Calendar_Filter_View__c testFilterView2 = new Calendar_Filter_View__c(Name='CRT Client Hierarchy',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView2);
        Calendar_Filter_View__c testFilterView3 = new Calendar_Filter_View__c(Name='My Team\'s Clients',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView3);
        Calendar_Filter_View__c testFilterView4 = new Calendar_Filter_View__c(Name='My Client Team\'s Clients',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView4);
        Calendar_Filter_View__c testFilterView5 = new Calendar_Filter_View__c(Name='My Clients',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView5);
        Calendar_Filter_View__c testFilterView6 = new Calendar_Filter_View__c(Name='My Custom View',View_Type__c='Custom',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView6);
        
        insert testFilters;
        
        
        //insert Calendar Content
        List<Calendar_Content__c> testCalCon = new List<Calendar_Content__c>();
        Calendar_Content__c testCalContent = new Calendar_Content__c();
        testCalContent.Name = 'Client Events';
        testCalContent.Event_Start_Field__c = 'Start';
        testCalContent.Event_Title_Field__c = 'Subject';
        testCalContent.Event_Legend_Field__c = 'Meeting_Purpose__c';
        testCalContent.Event_Object_Name__c = 'Event';
        testCalContent.Hierarchy_Object_Name__c = 'Account';
        testCalContent.Hierarchy_Relation_Field__c = 'ParentId';
        testCalContent.Calendar_Type__c = testCalType.Id;
        testCalCon.add(testCalContent);
        
        Calendar_Content__c testCalContent1 = new Calendar_Content__c();
        testCalContent1.Name = 'Client Contact Events';
        testCalContent1.Event_Start_Field__c = 'Start';
        testCalContent1.Event_Title_Field__c = 'Subject';
        testCalContent1.Event_Legend_Field__c = 'Meeting_Purpose__c';
        testCalContent1.Event_Object_Name__c = 'Event';
        testCalContent1.Hierarchy_Object_Name__c = 'Contact';
        testCalContent1.Hierarchy_Relation_Field__c = 'ReportsToId';
        testCalContent1.Calendar_Type__c = testCalType.Id;
        testCalCon.add(testCalContent1);
        
        Calendar_Content__c testCalContent2 = new Calendar_Content__c();
        testCalContent2.Name = 'Client Opportunity Events';
        testCalContent2.Event_Start_Field__c = 'Start';
        testCalContent2.Event_Title_Field__c = 'Subject';
        testCalContent2.Event_Legend_Field__c = 'Meeting_Purpose__c';
        testCalContent2.Event_Object_Name__c = 'Event';
        testCalContent2.Hierarchy_Object_Name__c = 'Opportunity';
        testCalContent2.Calendar_Type__c = testCalType.Id;
        testCalCon.add(testCalContent2);
        insert testCalCon ;
        
        //insert Calendar Legend
        Calendar_Legend__c calLegend = new Calendar_Legend__c();
        calLegend.Name = 'Call';
        calLegend.Background_Color__c = 'blue';
        calLegend.Calendar_Content__c = testCalContent.Id;
        insert calLegend;
        
        List<Event> testEvents = new List<Event>();
        
        // put in an event related to client
        Event ev = new Event(activityDateTime=System.now());
        ev.Meeting_Audience__c = 'Internal';
        ev.Meeting_Purpose__c = 'Day To Day Meeting';

        ev.DurationInMinutes = 1;
        ev.whatId = ac.Id;
        testEvents.add(ev);
        Event ev2 = new Event(activityDateTime=System.now());
        ev2.Meeting_Audience__c = 'Internal';
        ev2.Meeting_Purpose__c = 'Day To Day Meeting';

        ev2.DurationInMinutes = 1;
        ev2.whatId = ac.Id;
        testEvents.add(ev2);
        
        Event evallday = new Event(activityDate=System.today());
        evallday.IsAllDayEvent = true;
        evallday.Meeting_Audience__c = 'Internal';
        evallday.Meeting_Purpose__c = 'Day To Day Meeting';

        evallday.whatId = ac.Id;
        testEvents.add(evallday);
        
        // put in an event related to client contact
        Event ev3 = new Event(activityDateTime=System.now());
        ev3.Meeting_Audience__c = 'External';
        ev3.Meeting_Purpose__c = 'Client Email';

        ev3.DurationInMinutes = 1;
        ev3.whatId = null;
        ev3.whoId = co.Id;
        ev3.Report_Client_Contact__c = ev3.whoId;
        testEvents.add(ev3);
        Event ev4 = new Event(activityDateTime=System.now());
        ev4.Meeting_Audience__c = 'External';
        ev4.Meeting_Purpose__c = 'Client Email';

        ev4.DurationInMinutes = 1;
        ev4.whatId = null;
        ev4.whoId = co.Id;
        ev4.Report_Client_Contact__c = ev4.whoId;
        testEvents.add(ev4);
        
        Event evallday2 = new Event(activityDate=System.today());
        evallday2.IsAllDayEvent = true;
        evallday2.Meeting_Audience__c = 'External';
        evallday2.Meeting_Purpose__c = 'Client Email';

        evallday2.whatId = null;
        evallday2.whoId = co.Id;
        evallday2.Report_Client_Contact__c = evallday2.whoId;
        testEvents.add(evallday2);
        
        // put in an event related to opportunity
        Event ev5 = new Event(activityDateTime=System.now());
        ev5.Meeting_Audience__c = 'Internal';
        ev5.Meeting_Purpose__c = 'Day To Day Meeting';

        ev5.DurationInMinutes = 1;
        ev5.whatId = op.Id;
        testEvents.add(ev5);
        Event ev6 = new Event(activityDateTime=System.now());
        ev6.Meeting_Audience__c = 'Internal';
        ev6.Meeting_Purpose__c = 'Day To Day Meeting';

        ev6.DurationInMinutes = 1;
        ev6.whatId = op.Id;
        testEvents.add(ev6);
        
        Event evallday3 = new Event(activityDate=System.today());
        evallday3.IsAllDayEvent = true;
        evallday3.Meeting_Audience__c = 'Internal';
        evallday3.Meeting_Purpose__c = 'Day To Day Meeting';

        evallday3.whatId = op.Id;
        testEvents.add(evallday3);
        
        insert testEvents;

        Test.startTest();
        try {
            SharedCalPrefs pref = new SharedCalPrefs();
            Test.setCurrentPage( Page.SharedCalendar);
            //page parameters required for event data loading on the calendar
            ApexPages.currentPage().getParameters().put('Type',ev.Meeting_Purpose__c+','+evallday.Meeting_Purpose__c);
            ApexPages.currentPage().getParameters().put('start',
                    string.valueof( ev.ActivityDateTime.addMinutes(-1).getTime()/1000)  );
            ApexPages.currentPage().getParameters().put('end',
                    string.valueof( ev.ActivityDateTime.addDays(ev.durationInMinutes+1).getTime()/1000) );
            ApexPages.currentPage().getParameters().put('calType','');
            ApexPages.currentPage().getParameters().put('term','123');
            SharedCalendarUtils_page f = new SharedCalendarUtils_page ();
            pref.saveFilterName('My Team\'s Clients');
            pref.saveRecord('');
            f.updateRecentViewed();
            f.selectSearchedRecord();
            List<sObject> testList = f.allDynamicRecords;

            f.eventObjectName = 'Event';

            // Data
            ApexPages.currentPage().getParameters().put('legendFor','Account');
            ApexPages.currentPage().getParameters().put('object','Event');
            ApexPages.currentPage().getParameters().put('Type','Day To Day Meeting');
            map<id,fullcalendarEvent> mymap = new Map<id,fullcalendarEvent>();
            f.allEvents = null;
            List<fullcalendarEvent> theTestEvents = f.allEvents;

            ApexPages.currentPage().getParameters().put('Type','Day To Day Meeting');
            ApexPages.currentPage().getParameters().put('legendFor','Contact');
            ApexPages.currentPage().getParameters().put('object','Event');
            List<fullcalendarEvent> testEvents2 = f.allEvents;

            ApexPages.currentPage().getParameters().put('Type','Day To Day Meeting');
            ApexPages.currentPage().getParameters().put('legendFor','Opportunity');
            ApexPages.currentPage().getParameters().put('object','Event');
            List<fullcalendarEvent> testEvents3 = f.allEvents;
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testSharedCalendarUtilsPageMyClients() {
      
       insert TEST_DataFactory.getCcSettings();

        List<Account> testAccounts = new List<Account>();
        // put an account
        string uniquename = 'sdlkjsdlsdjflsjdfsdfwieurosdfcxcv1'; 
        Account ac = new Account();
        
        ac.name = uniquename;
        
        testAccounts.add(ac);
        insert testAccounts;
                
        // insert contact
        Contact co = new Contact();
        co.Lastname = uniquename;
        co.accountId = ac.Id;
        insert co;
        
        // insert opportunity
        Opportunity op = new Opportunity();
        op.name = uniquename+1;
        op.accountId = ac.Id;
        op.StageName = 'dummy';
        op.closedate = System.Date.Today();
        insert op;
        
        // insert Calendar Type
        Calendar_Type__c testCalType = new Calendar_Type__c();
        testCalType.Name = 'Client';
        insert testCalType;
        
        // insert Filter Views
        List<Calendar_Filter_View__c> testFilters = new List<Calendar_Filter_View__c>();
        Calendar_Filter_View__c testFilterView = new Calendar_Filter_View__c(Name='Single Client',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView);
        Calendar_Filter_View__c testFilterView2 = new Calendar_Filter_View__c(Name='CRT Client Hierarchy',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView2);
        Calendar_Filter_View__c testFilterView3 = new Calendar_Filter_View__c(Name='My Team\'s Clients',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView3);
        Calendar_Filter_View__c testFilterView4 = new Calendar_Filter_View__c(Name='My Client Team\'s Clients',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView4);
        Calendar_Filter_View__c testFilterView5 = new Calendar_Filter_View__c(Name='My Clients',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView5);
        Calendar_Filter_View__c testFilterView6 = new Calendar_Filter_View__c(Name='My Custom View',View_Type__c='Custom',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView6);
        
        insert testFilters;
        
        
        //insert Calendar Content
        List<Calendar_Content__c> testCalCon = new List<Calendar_Content__c>();
        Calendar_Content__c testCalContent = new Calendar_Content__c();
        testCalContent.Name = 'Client Events';
        testCalContent.Event_Start_Field__c = 'Start';
        testCalContent.Event_Title_Field__c = 'Subject';
        testCalContent.Event_Legend_Field__c = 'Meeting_Purpose__c';
        testCalContent.Event_Object_Name__c = 'Event';
        testCalContent.Hierarchy_Object_Name__c = 'Account';
        testCalContent.Hierarchy_Relation_Field__c = 'ParentId';
        testCalContent.Calendar_Type__c = testCalType.Id;
        testCalCon.add(testCalContent);
        
        Calendar_Content__c testCalContent1 = new Calendar_Content__c();
        testCalContent1.Name = 'Client Contact Events';
        testCalContent1.Event_Start_Field__c = 'Start';
        testCalContent1.Event_Title_Field__c = 'Subject';
        testCalContent1.Event_Legend_Field__c = 'Meeting_Purpose__c';
        testCalContent1.Event_Object_Name__c = 'Event';
        testCalContent1.Hierarchy_Object_Name__c = 'Contact';
        testCalContent1.Hierarchy_Relation_Field__c = 'ReportsToId';
        testCalContent1.Calendar_Type__c = testCalType.Id;
        testCalCon.add(testCalContent1);
        
        Calendar_Content__c testCalContent2 = new Calendar_Content__c();
        testCalContent2.Name = 'Client Opportunity Events';
        testCalContent2.Event_Start_Field__c = 'Start';
        testCalContent2.Event_Title_Field__c = 'Subject';
        testCalContent2.Event_Legend_Field__c = 'Meeting_Purpose__c';
        testCalContent2.Event_Object_Name__c = 'Event';
        testCalContent2.Hierarchy_Object_Name__c = 'Opportunity';
        testCalContent2.Calendar_Type__c = testCalType.Id;
        testCalCon.add(testCalContent2);
        insert testCalCon ;
        
        //insert Calendar Legend
        Calendar_Legend__c calLegend = new Calendar_Legend__c();
        calLegend.Name = 'Call';
        calLegend.Background_Color__c = 'blue';
        calLegend.Calendar_Content__c = testCalContent.Id;
        insert calLegend;
        
        List<Event> testEvents = new List<Event>();
        
        // put in an event related to client
        Event ev = new Event(activityDateTime=System.now());
        ev.Meeting_Audience__c = 'Internal';
        ev.Meeting_Purpose__c = 'Day To Day Meeting';

        ev.DurationInMinutes = 1;
        ev.whatId = ac.Id;
        testEvents.add(ev);
        Event ev2 = new Event(activityDateTime=System.now());
        ev2.Meeting_Audience__c = 'Internal';
        ev2.Meeting_Purpose__c = 'Day To Day Meeting';

        ev2.DurationInMinutes = 1;
        ev2.whatId = ac.Id;
        testEvents.add(ev2);
        
        Event evallday = new Event(activityDate=System.today());
        evallday.IsAllDayEvent = true;
        evallday.Meeting_Audience__c = 'Internal';
        evallday.Meeting_Purpose__c = 'Day To Day Meeting';

        evallday.whatId = ac.Id;
        testEvents.add(evallday);
        
        // put in an event related to client contact
        Event ev3 = new Event(activityDateTime=System.now());
        ev3.Meeting_Audience__c = 'External';
        ev3.Meeting_Purpose__c = 'Client Email';

        ev3.DurationInMinutes = 1;
        ev3.whatId = null;
        ev3.whoId = co.Id;
        ev3.Report_Client_Contact__c = ev3.whoId;
        testEvents.add(ev3);
        Event ev4 = new Event(activityDateTime=System.now());
        ev4.Meeting_Audience__c = 'External';
        ev4.Meeting_Purpose__c = 'Client Email';

        ev4.DurationInMinutes = 1;
        ev4.whatId = null;
        ev4.whoId = co.Id;
        ev4.Report_Client_Contact__c = ev4.whoId;
        testEvents.add(ev4);
        
        Event evallday2 = new Event(activityDate=System.today());
        evallday2.IsAllDayEvent = true;
        evallday2.Meeting_Audience__c = 'External';
        evallday2.Meeting_Purpose__c = 'Client Email';

        evallday2.whatId = null;
        evallday2.whoId = co.Id;
        evallday2.Report_Client_Contact__c = evallday2.whoId;
        testEvents.add(evallday2);
        
        // put in an event related to opportunity
        Event ev5 = new Event(activityDateTime=System.now());
        ev5.Meeting_Audience__c = 'Internal';
        ev5.Meeting_Purpose__c = 'Day To Day Meeting';

        ev5.DurationInMinutes = 1;
        ev5.whatId = op.Id;
        testEvents.add(ev5);
        Event ev6 = new Event(activityDateTime=System.now());
        ev6.Meeting_Audience__c = 'Internal';
        ev6.Meeting_Purpose__c = 'Day To Day Meeting';

        ev6.DurationInMinutes = 1;
        ev6.whatId = op.Id;
        testEvents.add(ev6);
        
        Event evallday3 = new Event(activityDate=System.today());
        evallday3.IsAllDayEvent = true;
        evallday3.Meeting_Audience__c = 'Internal';
        evallday3.Meeting_Purpose__c = 'Day To Day Meeting';

        evallday3.whatId = op.Id;
        testEvents.add(evallday3);
        
        insert testEvents;

        Test.startTest();
        try {
            SharedCalPrefs pref = new SharedCalPrefs();
            Test.setCurrentPage( Page.SharedCalendar);
            //page parameters required for event data loading on the calendar
            ApexPages.currentPage().getParameters().put('Type',ev.Meeting_Purpose__c+','+evallday.Meeting_Purpose__c);
            ApexPages.currentPage().getParameters().put('start',
                    string.valueof( ev.ActivityDateTime.addMinutes(-1).getTime()/1000)  );
            ApexPages.currentPage().getParameters().put('end',
                    string.valueof( ev.ActivityDateTime.addDays(ev.durationInMinutes+1).getTime()/1000) );
            ApexPages.currentPage().getParameters().put('calType','');
            ApexPages.currentPage().getParameters().put('term','123');
            SharedCalendarUtils_page f = new SharedCalendarUtils_page ();
            pref.saveFilterName('My Clients');
            pref.saveRecord('');
            f.updateRecentViewed();
            f.selectSearchedRecord();
            List<sObject> testList = f.allDynamicRecords;

            f.eventObjectName = 'Event';

            //Change View
            ApexPages.currentPage().getParameters().put('filterName','My Clients');
            ApexPages.currentPage().getParameters().put('filterId',testFilters[4].Id);
            f.changeFilterView();

            // Data
            ApexPages.currentPage().getParameters().put('legendFor','Account');
            ApexPages.currentPage().getParameters().put('object','Event');
            ApexPages.currentPage().getParameters().put('Type','Day To Day Meeting');
            map<id,fullcalendarEvent> mymap = new Map<id,fullcalendarEvent>();
            f.allEvents = null;
            List<fullcalendarEvent> theTestEvents = f.allEvents;

            ApexPages.currentPage().getParameters().put('Type','Day To Day Meeting');
            ApexPages.currentPage().getParameters().put('legendFor','Contact');
            ApexPages.currentPage().getParameters().put('object','Event');
            List<fullcalendarEvent> testEvents2 = f.allEvents;

            ApexPages.currentPage().getParameters().put('Type','Day To Day Meeting');
            ApexPages.currentPage().getParameters().put('legendFor','Opportunity');
            ApexPages.currentPage().getParameters().put('object','Event');
            List<fullcalendarEvent> testEvents3 = f.allEvents;
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testSharedCalendarUtilsMyClientsTeamsClients() {
      
       insert TEST_DataFactory.getCcSettings();

        List<Account> testAccounts = new List<Account>();
        // put an account
        string uniquename = 'sdlkjsdlsdjflsjdfsdfwieurosdfcxcv1'; 
        Account ac = new Account();
        
        ac.name = uniquename;
        
        testAccounts.add(ac);
        insert testAccounts;
                
        // insert contact
        Contact co = new Contact();
        co.Lastname = uniquename;
        co.accountId = ac.Id;
        insert co;
        
        // insert opportunity
        Opportunity op = new Opportunity();
        op.name = uniquename+1;
        op.accountId = ac.Id;
        op.StageName = 'dummy';
        op.closedate = System.Date.Today();
        insert op;
        
       list<AccountTeamMember> olstAccountTeamMember = new list<AccountTeamMember>();
          
        AccountTeamMember atm = new AccountTeamMember(); 
        atm.AccountId= testAccounts[0].id; 
        atm.UserId= UserInfo.getUserId(); 
        atm.TeamMemberRole = 'Client Analyst'; 
        olstAccountTeamMember.add(atm);
        insert olstAccountTeamMember; 
          
        // insert Calendar Type
        Calendar_Type__c testCalType = new Calendar_Type__c();
        testCalType.Name = 'Client';
        insert testCalType;
        
        // insert Filter Views
        List<Calendar_Filter_View__c> testFilters = new List<Calendar_Filter_View__c>();
        Calendar_Filter_View__c testFilterView = new Calendar_Filter_View__c(Name='Single Client',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView);
        Calendar_Filter_View__c testFilterView2 = new Calendar_Filter_View__c(Name='CRT Client Hierarchy',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView2);
        Calendar_Filter_View__c testFilterView3 = new Calendar_Filter_View__c(Name='My Team\'s Clients',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView3);
        Calendar_Filter_View__c testFilterView4 = new Calendar_Filter_View__c(Name='My Client Team\'s Clients',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView4);
        Calendar_Filter_View__c testFilterView5 = new Calendar_Filter_View__c(Name='My Clients',View_Type__c='Standard',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView5);
        Calendar_Filter_View__c testFilterView6 = new Calendar_Filter_View__c(Name='My Custom View',View_Type__c='Custom',Calendar_Type__c=testCalType.Id);
        testFilters.add(testFilterView6);
        
        insert testFilters;
        
        
        //insert Calendar Content
        List<Calendar_Content__c> testCalCon = new List<Calendar_Content__c>();
        Calendar_Content__c testCalContent = new Calendar_Content__c();
        testCalContent.Name = 'Client Events';
        testCalContent.Event_Start_Field__c = 'Start';
        testCalContent.Event_Title_Field__c = 'Subject';
        testCalContent.Event_Legend_Field__c = 'Meeting_Purpose__c';
        testCalContent.Event_Object_Name__c = 'Event';
        testCalContent.Hierarchy_Object_Name__c = 'Account';
        testCalContent.Hierarchy_Relation_Field__c = 'ParentId';
        testCalContent.Calendar_Type__c = testCalType.Id;
        testCalCon.add(testCalContent);
        
        Calendar_Content__c testCalContent1 = new Calendar_Content__c();
        testCalContent1.Name = 'Client Contact Events';
        testCalContent1.Event_Start_Field__c = 'Start';
        testCalContent1.Event_Title_Field__c = 'Subject';
        testCalContent1.Event_Legend_Field__c = 'Meeting_Purpose__c';
        testCalContent1.Event_Object_Name__c = 'Event';
        testCalContent1.Hierarchy_Object_Name__c = 'Contact';
        testCalContent1.Hierarchy_Relation_Field__c = 'ReportsToId';
        testCalContent1.Calendar_Type__c = testCalType.Id;
        testCalCon.add(testCalContent1);
        
        Calendar_Content__c testCalContent2 = new Calendar_Content__c();
        testCalContent2.Name = 'Client Opportunity Events';
        testCalContent2.Event_Start_Field__c = 'Start';
        testCalContent2.Event_Title_Field__c = 'Subject';
        testCalContent2.Event_Legend_Field__c = 'Meeting_Purpose__c';
        testCalContent2.Event_Object_Name__c = 'Event';
        testCalContent2.Hierarchy_Object_Name__c = 'Opportunity';
        testCalContent2.Calendar_Type__c = testCalType.Id;
        testCalCon.add(testCalContent2);
        insert testCalCon ;
        
        //insert Calendar Legend
        Calendar_Legend__c calLegend = new Calendar_Legend__c();
        calLegend.Name = 'Call';
        calLegend.Background_Color__c = 'blue';
        calLegend.Calendar_Content__c = testCalContent.Id;
        insert calLegend;
        
        List<Event> testEvents = new List<Event>();
        
        // put in an event related to client
        Event ev = new Event(activityDateTime=System.now());
        ev.Meeting_Audience__c = 'Internal';
        ev.Meeting_Purpose__c = 'Day To Day Meeting';

        ev.DurationInMinutes = 1;
        ev.whatId = ac.Id;
        testEvents.add(ev);
        Event ev2 = new Event(activityDateTime=System.now());
        ev2.Meeting_Audience__c = 'Internal';
        ev2.Meeting_Purpose__c = 'Day To Day Meeting';

        ev2.DurationInMinutes = 1;
        ev2.whatId = ac.Id;
        testEvents.add(ev2);
        
        Event evallday = new Event(activityDate=System.today());
        evallday.IsAllDayEvent = true;
        evallday.Meeting_Audience__c = 'Internal';
        evallday.Meeting_Purpose__c = 'Day To Day Meeting';

        evallday.whatId = ac.Id;
        testEvents.add(evallday);
        
        // put in an event related to client contact
        Event ev3 = new Event(activityDateTime=System.now());
        ev3.Meeting_Audience__c = 'External';
        ev3.Meeting_Purpose__c = 'Client Email';

        ev3.DurationInMinutes = 1;
        ev3.whatId = null;
        ev3.whoId = co.Id;
        ev3.Report_Client_Contact__c = ev3.whoId;
        testEvents.add(ev3);
        Event ev4 = new Event(activityDateTime=System.now());
        ev4.Meeting_Audience__c = 'External';
        ev4.Meeting_Purpose__c = 'Client Email';

        ev4.DurationInMinutes = 1;
        ev4.whatId = null;
        ev4.whoId = co.Id;
        ev4.Report_Client_Contact__c = ev4.whoId;
        testEvents.add(ev4);
        
        Event evallday2 = new Event(activityDate=System.today());
        evallday2.IsAllDayEvent = true;
        evallday2.Meeting_Audience__c = 'External';
        evallday2.Meeting_Purpose__c = 'Client Email';

        evallday2.whatId = null;
        evallday2.whoId = co.Id;
        evallday2.Report_Client_Contact__c = evallday2.whoId;
        testEvents.add(evallday2);
        
        // put in an event related to opportunity
        Event ev5 = new Event(activityDateTime=System.now());
        ev5.Meeting_Audience__c = 'Internal';
        ev5.Meeting_Purpose__c = 'Day To Day Meeting';

        ev5.DurationInMinutes = 1;
        ev5.whatId = op.Id;
        testEvents.add(ev5);
        Event ev6 = new Event(activityDateTime=System.now());
        ev6.Meeting_Audience__c = 'Internal';
        ev6.Meeting_Purpose__c = 'Day To Day Meeting';

        ev6.DurationInMinutes = 1;
        ev6.whatId = op.Id;
        testEvents.add(ev6);
        
        Event evallday3 = new Event(activityDate=System.today());
        evallday3.IsAllDayEvent = true;
        evallday3.Meeting_Audience__c = 'Internal';
        evallday3.Meeting_Purpose__c = 'Day To Day Meeting';

        evallday3.whatId = op.Id;
        testEvents.add(evallday3);
        
        insert testEvents;

        Test.startTest();
        try {
            SharedCalPrefs pref = new SharedCalPrefs();
            Test.setCurrentPage( Page.SharedCalendar);
            //page parameters required for event data loading on the calendar
            ApexPages.currentPage().getParameters().put('Type',ev.Meeting_Purpose__c+','+evallday.Meeting_Purpose__c);
            ApexPages.currentPage().getParameters().put('start',
                    string.valueof( ev.ActivityDateTime.addMinutes(-1).getTime()/1000)  );
            ApexPages.currentPage().getParameters().put('end',
                    string.valueof( ev.ActivityDateTime.addDays(ev.durationInMinutes+1).getTime()/1000) );
            ApexPages.currentPage().getParameters().put('calType','');
            ApexPages.currentPage().getParameters().put('term','123');
            SharedCalendarUtils_page f = new SharedCalendarUtils_page ();
            pref.saveFilterName('My Client Team\'s Clients');
            pref.saveRecord('');
            f.updateRecentViewed();
            f.selectSearchedRecord();
            List<sObject> testList = f.allDynamicRecords;

            f.eventObjectName = 'Event';

            //Change View
            ApexPages.currentPage().getParameters().put('filterName','My Client Team\'s Clients');
            ApexPages.currentPage().getParameters().put('filterId',testFilters[3].Id);
            f.changeFilterView();


            // Data
            ApexPages.currentPage().getParameters().put('legendFor','Account');
            ApexPages.currentPage().getParameters().put('object','Event');
            ApexPages.currentPage().getParameters().put('Type','Day To Day Meeting');
            map<id,fullcalendarEvent> mymap = new Map<id,fullcalendarEvent>();
            f.allEvents = null;
            List<fullcalendarEvent> theTestEvents = f.allEvents;

            ApexPages.currentPage().getParameters().put('Type','Day To Day Meeting');
            ApexPages.currentPage().getParameters().put('legendFor','Contact');
            ApexPages.currentPage().getParameters().put('object','Event');
            List<fullcalendarEvent> testEvents2 = f.allEvents;

            ApexPages.currentPage().getParameters().put('Type','Day To Day Meeting');
            ApexPages.currentPage().getParameters().put('legendFor','Opportunity');
            ApexPages.currentPage().getParameters().put('object','Event');
            List<fullcalendarEvent> testEvents3 = f.allEvents;
            Test.stopTest();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }
}