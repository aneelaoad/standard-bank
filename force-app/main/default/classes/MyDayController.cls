/*************************************************************************************************************************************************************************
    @ Author        : Nitish Kumar
    @ Date          : Sept 2014
    @ Test File     : 
    @ Description   : Controller class for My Day.This visualforce page is built for SF 1 , so that users can have list views of event reports 
                                   where there are added as attendees or the event report to which they are assigned.

    @ Last Modified By:     Prabhanshu Agrawal
    @ Last Modified On:     Oct 2014
    @ Last Modified Reason: En 523

    @ Last Modified By:     Prabhanshu Agrawal
    @ Last Modified On:     Mar 2015
    @ Last Modified Reason: En 656 - Removing Type field and adding Meeting Type and Meeting Audience
    
    @ Last Modified By:     Manoj Gupta
    @ Last Modified On:     May 2016
    @ Last Modified Reason: EN 1352: Replaced Client_Name__c,Client__r.Name field and in the SOQL filter and other occurences

*************************************************************************************************************************************************************************/
public with sharing class MyDayController {

    //Variable which stores the selected list view name 
    public string filterValue {
        get;
        set;
    }

    //List of Event Report
    public list < Call_Report__c > eventReportList {
        get;
        set;
    }

    /**
     * @author :- Nitish Kumar
     * @date  :-  Sept -2014
     * @description :- Public Select Option method which stores the list of options
     * @param :- N/A
     * @return :- List<SelectOption>
     **/
    public List < SelectOption > getViews() {
        List < SelectOption > options = new List < SelectOption > ();
        options.add(new SelectOption('All My Events', 'All My Events'));
        options.add(new SelectOption('My Event Reports Current Month', 'My Event Reports Current Month'));
        options.add(new SelectOption('My Event Reports for the last 7 days', 'My Event Reports for the last 7 days'));
        options.add(new SelectOption('My Event Reports Previous Month', 'My Event Reports Previous Month'));
        options.add(new SelectOption('My Event Reports this Year', 'My Event Reports this Year'));
        options.add(new SelectOption('My Future Events', 'My Future Events'));
        options.add(new SelectOption('My Incomplete Event Reports', 'My Incomplete Event Reports'));
        options.add(new SelectOption('Today', 'Today'));
        return options;
    }

    // Constructor    
    public MyDayController() {

        //Inititalizing the list of Event Report
        eventReportList = new list < Call_Report__c > ();

        //Setting the default view of My Day page
        if (filterValue == null){
            filterValue = 'Today';
            refreshEventViews();
        }

    }

    /**
     * @author :- Nitish Kumar
     * @date  :-  Sept -2014
     * @description :- Void method which sets the list of Event Report based on the filter.
     * @param :- N/A
     * @return :- N/A
     **/
    public void refreshEventViews() {

        //local variables
        list < Call_Report_Attendees__c > eventReportListAttendess = new list < Call_Report_Attendees__c > ();
        Set < Id > eventReportId = new Set < Id > ();
        list < Call_Report__c > eventReportLst = new list < Call_Report__c >();

        eventReportList.clear();

        //Querying the list of Event Report Attendees where the user is added as an attendee
        eventReportListAttendess = [select Contact_id__c, Call_Report__c, Call_Report__r.Start__c,Call_Report__r.End__c
                                    from Call_Report_Attendees__c where Contact_id__r.OwnerId = : UserInfo.getUserId()];

        //If the Selected list view is today
        if (filterValue == 'Today') {

            eventReportLst = [select Id from Call_Report__c where Start__c = TODAY 
                                AND(Assigned_To__c = : UserInfo.getUserId() OR OwnerId = : UserInfo.getUserId())];

            for (Call_Report__c evenReport: eventReportLst) {
                eventReportId.add(evenReport.Id);
            }

            for (Call_Report_Attendees__c attend: eventReportListAttendess) {
                if (attend.Call_Report__r.Start__c.dayOfYear() == date.today().dayOfYear()) {
                    //Checking if the Event Report is already added in the list
                    if (!eventReportId.contains(attend.Call_Report__c)) {
                        eventReportId.add(attend.Call_Report__c);
                    }
                }
            }
            
            eventReportList = [select Id, name, Subject__c, Start__c, End__c, Assigned_To__r.Name, Report_Client_Contact__r.Name,
                                Relate_to_Client__r.Name, Contact__r.Name, Meeting_Audience__c, Meeting_Purpose__c, Relate_to_Client__c from Call_Report__c
                                where Id IN : eventReportId order by Start__c DESC];
            
        }

        //If the Selected list view is All Events
        if (filterValue == 'All My Events') {

            eventReportLst = [select Id from Call_Report__c 
                                where Assigned_To__c = : UserInfo.getUserId() OR OwnerId = : UserInfo.getUserId()];

            for (Call_Report__c evenReport: eventReportLst) {
                eventReportId.add(evenReport.Id);
            }

            for (Call_Report_Attendees__c attend: eventReportListAttendess) {
                //Checking if the Event Report is already added in the list
                if (!eventReportId.contains(attend.Call_Report__c)) {
                        eventReportId.add(attend.Call_Report__c);
                }
            }
            
            eventReportList = [select Id, name, Subject__c, Start__c, End__c, Assigned_To__r.Name, Relate_to_Client__r.Name, Contact__r.Name, 
                                Report_Client_Contact__r.Name, Meeting_Audience__c, Meeting_Purpose__c, Relate_to_Client__c from Call_Report__c
                                where Id IN : eventReportId order by Start__c DESC];
            
        }

        //If the Selected list view is My Event Reports in the Last Month
        if (filterValue == 'My Event Reports Previous Month') {

            eventReportLst = [select Id from Call_Report__c where Start__c =  LAST_MONTH 
                                AND(Assigned_To__c = : UserInfo.getUserId() OR OwnerId = : UserInfo.getUserId())];

            for (Call_Report__c evenReport: eventReportLst) {
                eventReportId.add(evenReport.Id);
            }

            for (Call_Report_Attendees__c attend: eventReportListAttendess) {
                if (date.today().month() - attend.Call_Report__r.Start__c.month() == 1 || date.today().month() - attend.Call_Report__r.Start__c.month() == -11) {
                    //Checking if the Event Report is already added in the list
                    if (!eventReportId.contains(attend.Call_Report__c)) {
                        eventReportId.add(attend.Call_Report__c);
                    }
                }
            }

            eventReportList = [select Id, name, Subject__c, Start__c, End__c, Assigned_To__r.Name, Relate_to_Client__r.Name, Contact__r.Name, 
                                Report_Client_Contact__r.Name, Meeting_Audience__c, Meeting_Purpose__c, Relate_to_Client__c from Call_Report__c
                                where Id IN : eventReportId order by Start__c DESC];

        }

        //If the Selected list view is My Event Reports this Year
        if (filterValue == 'My Event Reports this Year') {

            eventReportLst = [select Id from Call_Report__c where Start__c = THIS_YEAR 
                                AND(Assigned_To__c = : UserInfo.getUserId() OR OwnerId = : UserInfo.getUserId())];

            for (Call_Report__c evenReport: eventReportLst) {
                eventReportId.add(evenReport.Id);
            }

            for (Call_Report_Attendees__c attend: eventReportListAttendess) {
                if (attend.Call_Report__r.Start__c.year() == date.today().year()) {
                    //Checking if the Event Report is already added in the list
                    if (!eventReportId.contains(attend.Call_Report__c)) {
                        eventReportId.add(attend.Call_Report__c);
                    }
                }
            }

            eventReportList = [select Id, name, Subject__c, Start__c, End__c, Assigned_To__r.Name, Relate_to_Client__r.Name, Contact__r.Name, 
                               Report_Client_Contact__r.Name, Meeting_Audience__c, Meeting_Purpose__c, Relate_to_Client__c from Call_Report__c
                                where Id IN : eventReportId order by Start__c DESC];

        }

        //If the Selected list view is My Incomplete Event Reports
        if (filterValue == 'My Incomplete Event Reports') {

            eventReportLst = [select Id from Call_Report__c where End__c > TODAY 
                                AND(Assigned_To__c = : UserInfo.getUserId() OR OwnerId = : UserInfo.getUserId()) 
                                AND (Relate_to_Client__c !=  null OR Relate_to_Client__c !=  '') AND (Meeting_Audience__c != null AND Meeting_Purpose__c != null)];

            for (Call_Report__c evenReport: eventReportLst) {
                eventReportId.add(evenReport.Id);
            }

            for (Call_Report_Attendees__c attend: eventReportListAttendess) {
                if (attend.Call_Report__r.End__c > date.today()) {
                    //Checking if the Event Report is already added in the list
                    if (!eventReportId.contains(attend.Call_Report__c)) {
                        eventReportId.add(attend.Call_Report__c);
                    }
                }
            }

            eventReportList = [select Id, name, Subject__c, Start__c, End__c, Assigned_To__r.Name, Relate_to_Client__r.Name, Contact__r.Name, 
                                Report_Client_Contact__r.Name, Meeting_Audience__c, Meeting_Purpose__c, Relate_to_Client__c from Call_Report__c
                                where Id IN : eventReportId order by Start__c DESC];

        }

        //If the Selected list view is My Future Events
        if (filterValue == 'My Future Events') {

            eventReportLst = [select Id from Call_Report__c where Start__c > TODAY 
                                AND(Assigned_To__c = : UserInfo.getUserId() OR OwnerId = : UserInfo.getUserId())];

            for (Call_Report__c evenReport: eventReportLst) {
                eventReportId.add(evenReport.Id);
            }

            for (Call_Report_Attendees__c attend: eventReportListAttendess) {
                if (attend.Call_Report__r.Start__c > date.today()) {
                    //Checking if the Event Report is already added in the list
                    if (!eventReportId.contains(attend.Call_Report__c)) {
                        eventReportId.add(attend.Call_Report__c);
                    }
                }
            }

            eventReportList = [select Id, name, Subject__c, Start__c, End__c, Assigned_To__r.Name, Relate_to_Client__r.Name, Contact__r.Name, 
                                Report_Client_Contact__r.Name, Meeting_Audience__c, Meeting_Purpose__c, Relate_to_Client__c from Call_Report__c
                                where Id IN : eventReportId order by Start__c DESC];

        }
        
        //If the Selected list view is My Event Reports for the last 7 days
        if (filterValue == 'My Event Reports for the last 7 days') {

            eventReportLst = [select Id from Call_Report__c where Start__c = LAST_N_DAYS:7 
                                AND(Assigned_To__c = : UserInfo.getUserId() OR OwnerId = : UserInfo.getUserId())];

            for (Call_Report__c evenReport: eventReportLst) {
                eventReportId.add(evenReport.Id);
            }

            for (Call_Report_Attendees__c attend: eventReportListAttendess) {
                if (date.today().dayOfYear() - attend.Call_Report__r.Start__c.dayOfYear() <= 7 && date.today().dayOfYear() - attend.Call_Report__r.Start__c.dayOfYear() >= 0) {
                    //Checking if the Event Report is already added in the list
                    if (!eventReportId.contains(attend.Call_Report__c)) {
                        eventReportId.add(attend.Call_Report__c);
                    }
                }
            }

            eventReportList = [select Id, name, Subject__c, Start__c, End__c, Assigned_To__r.Name, Relate_to_Client__r.Name, Contact__r.Name, 
                               Report_Client_Contact__r.Name, Meeting_Audience__c, Meeting_Purpose__c, Relate_to_Client__c from Call_Report__c
                                where Id IN : eventReportId order by Start__c DESC];

        }

        //If the Selected list view is My Event Reports for this Month
        if (filterValue == 'My Event Reports Current Month') {

            eventReportLst = [select Id from Call_Report__c where Start__c = THIS_MONTH 
                                AND(Assigned_To__c = : UserInfo.getUserId() OR OwnerId = : UserInfo.getUserId())];

            for (Call_Report__c evenReport: eventReportLst) {
                eventReportId.add(evenReport.Id);
            }

            for (Call_Report_Attendees__c attend: eventReportListAttendess) {
                if (attend.Call_Report__r.Start__c.month() == date.today().month() ) {
                    //Checking if the Event Report is already added in the list
                    if (!eventReportId.contains(attend.Call_Report__c)) {
                        eventReportId.add(attend.Call_Report__c);
                    }
                }
            }

            eventReportList = [select Id, name, Subject__c, Start__c, End__c, Assigned_To__r.Name, Relate_to_Client__r.Name, Contact__r.Name, 
                               Report_Client_Contact__r.Name, Meeting_Audience__c, Meeting_Purpose__c, Relate_to_Client__c from Call_Report__c
                                where Id IN : eventReportId order by Start__c DESC];
        }        
    }
}