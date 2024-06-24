/*************************************************************************
    @ Author        : psvestka
    @ Date          : 12. 8. 2015
    @description   : Force.com reviewer - Blocker and Critical issues - 20150608.xlsx

    @ Last Modified By: Petr Roubal
    @ Last Modified Date: 5 Jan 2016
    @ Description:  EN-0498 - Client Sector Fields - Deletion of fields (Clean-up)
    
    @ Last Modified By:     Manoj Gupta
    @ Last Modified On:     May 2016
    @ Last Modified Reason: EN 1352: Replaced Client_Name__c,Client__c field references to Related_to_Client__C    
****************************************************************************/
@IsTest
private class SA_EventReportNavigateControllerTest {

    @IsTest
    static void testController() {
        list < ClientCoordinatorSettings__c > lstCCS = TEST_DataFactory.getCcSettings();
        insert lstCCS;

        Account a = new Account();
        a.Name = 'Standard Bank Employees';
        a.Industry = 'Airline';
        a.Country_Rating__c = '5';
        a.Correspondence_Addr_Line1__c = 'test';
        a.Correspondence_Addr_Line2__c = 'test';
        a.Correspondence_Postal_Code__c = '1234';
        a.Correspondence_Country__c = 'Angola';
        insert a;

        ID bankContactRecordtype = [Select r.Id From RecordType r where SobjectType = 'Contact' and DeveloperName = 'SA_Bank_Contact_Record_Type'].Id;
        ID clientContactRecordtype = [Select r.Id From RecordType r where SobjectType = 'Contact' and DeveloperName = 'SA_Client_Contact_Record_Type'].Id;

        Contact cc = (Contact) new BLD_Contact().getRecord();
        cc.FirstName = 'Jack';
        cc.LastName = 'Parrow';
        cc.AccountId = a.Id;
        cc.Email = 'jj@parrow.com';
        cc.RecordTypeId = clientContactRecordtype;
        insert cc;

        Contact bc = (Contact) new BLD_Contact().getRecord();
        bc.FirstName = 'Axel';
        bc.LastName = 'Rose';
        bc.AccountId = a.Id;
        bc.Email = 'gunsnroses@liveorletdie.net';
        bc.RecordTypeId = bankContactRecordtype;
        insert bc;

        Event e = new Event();
        e.Subject = 'Dummy Event';
        e.WhatId = a.Id;
        e.WhoId = cc.Id;
        e.Description = 'New Dummy Report';
        e.ActivityDateTime = Date.today();
        e.DurationInMinutes = 60;
        e.Meeting_Purpose__c = 'Client Meeting';
        e.Location = 'Room 101';
        try {
            insert e;
        } catch (Exception ex) {
            System.assert(false);
        }

        Call_Report__c rep = new Call_Report__c();
        rep.Subject__c = 'Dummy Event';
        rep.Name = 'Dummy Event' + '-' + 'Fly by night';
        rep.Relate_to_Client__c = a.Id;
        rep.Report_Client_Contact__c = cc.Id;
        rep.Description__c = 'New Dummy Report';
        rep.Start__c = e.ActivityDateTime;
        rep.End__c = Date.today();
        rep.Meeting_Audience__c = 'External';
        rep.Meeting_Purpose__c = 'Client Meeting';
        rep.Location__c = 'Room 101';
        try {
            insert rep;
        } catch (Exception ex) {
            System.assert(false);
        }

        e.Call_Report_Created__c = true;
        update e;

        String tempEventId = '';
        tempEventId = e.Id;

        ApexPages.StandardController stdController;
        SA_EventReportNavigateController cont = new SA_EventReportNavigateController(stdController);
        cont.reportId = rep.Id;
        cont.eventId = tempEventId.substring(0, 15);
        ApexPages.currentPage().getParameters().put('id', tempEventId.substring(0, 15));
        cont.buildURL();
        SA_EventReportNavigateController.getEventReport(rep.Id);
        cont.navigateView();
        cont.navigateEdit();

        update e;
        ApexPages.currentPage().getParameters().put('id', tempEventId.substring(0, 15));
        cont.buildURL();
        String retURL = '/' + a.Id;
        cont.buildParamURL(retURL);
        retURL = '/' + cc.Id + '?nooverride=1';
        cont.buildParamURL(retURL);
        retURL = 'home/home.jsp';
        cont.buildParamURL(retURL);
        retURL = '/00Qwwwwwwwwwwww';
        cont.buildParamURL(retURL);
        retURL = '/001wwwwwwwwwwwwDER';
        cont.buildParamURL(retURL);
        retURL = '/003wwwwwwwwwwww';
        cont.buildParamURL(retURL);
        retURL = '/006wwwwwwwwwwwwDDE';
        cont.buildParamURL(retURL);

        try {
             cont.navigateView();
             cont.navigateEdit();
             cont.navigateNew();
        } Catch (Exception ex) {
            System.assert(false);
        }
    }
}