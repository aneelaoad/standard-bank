/*************************************************************************\
    @ Func Area:    Events; Event Reports
    @ Author:       Rudolf Niehaus
    @ Date:         11/2010
    @ Test File:    SA_EventReportNavigateControllerTest.cls
    @ Description:  This controller class is used to
                              
    @ Last Modified By  : Caro Reinecke
    @ Last Modified On  : 15 August 2011
    @ Last Modified Reason  : Regression - Event standardisation - Remove Energy user record type and flag.
     
    @ Last Modified By  : Rudolf Niehaus
    @ Last Modified On  : 14 October 2011
    @ Last Modified Reason  : Add method that will navigate to the "New" page of and event report.
                              This method will be the default action in the Visualforce page SA_EventNavigateNew
                              and the page is used to override the standard "New Event" button on the Event object.
                              Teh return url is used to determine where we came from and by using this logic we can
                              then pre-populate the related Client, Contact and Opportunity records if needed 
   
    @ Last Modified By: Stephen Moore
    @ Last Modified Date: 26 Oct 2011
    @ Description:  Case#1876: Removal for the 'CRT_Region__c' field (Line 239)
                    
    @ Last Modified By  : Caro Reinecke
    @ Last Modified On  : 06/01/2012
    @ Modification Description : Case#548 Regression Remove redundant fields

    @ Last Modified By  : Caro Reinecke
    @ Last Modified On  : 12/03/2012
    @ Modification Description : Case#4983 When the user clicks a link To an Event records that has been deleted, redirect him To a record deleted page.                                         
    
    @ Last Modified By  : Wayne Gray
    @ Last Modified On  : June 2012
    @ Modification Description : Case #6521- Change contact to use TestFatcory 
                                  API Version moved from 24 to 25 
                                  
    @ Last Modified By  : Tracy Roberts
    @ Last Modified On  : 09 October 2012
    @ Modification Description : Case #8438- Event Navigation Error(Change ULR to URL)
    
    @ Last Modified By  : Tracy Roberts
    @ Last Modified On  : 14 November 2012
    @ Modification Description : Case #8873 - Event REport are now 18 digits and not 15 digits.
                                 Update the code to save the EventId on the Event Report as a 18 digit and not a 15 digit.
    
    @ Last Modified By  : Nitish Kumar
    @ Last Modified On  : March 2013
    @ Modification Description : EN-31- Change contact to use TestDataUtility   
                                 API Version moved from 25 to 27 
                                 
    @ Last Modified By  : Navin Rai
    @ Last Modified On  : 21 Aug 2013
    @ Modification Description : EN-231- Event Report functionality   

    @ Last Modified By:     Prabhanshu Agrawal
    @ Last Modified On:     Mar 2015
    @ Last Modified Reason: En 656 - Removing Type field and adding Meeting Type and Meeting Audience

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Aug 11, 2015 
    @ Modification Description : Force.com reviewer - Blocker and Critical issues - 20150608.xlsx

    @ Last Modified By  : Marko Dvečko
    @ Last Modified On  : Jan 27, 2017
    @ Moidification Description : Comparing 18 and 15 characters long Salesforce Ids
                                                                
****************************************************************************/ 
public class SA_EventReportNavigateController {

    public String reportId = '';
    public String eventId = '';

    public SA_EventReportNavigateController(ApexPages.StandardController stdController) {
        
    }
    
    public PageReference navigateView() { 

       
            Map<String,String> paramMap = ApexPages.currentPage().getParameters();

            String newURL = buildURL();
            
            PageReference pageRef;
            
            // Case 4983 - if the URL returned from BuildURL is less than 15 interpret it as unable to find the event 
            if (newUrl.length() < 15) {
                pageRef = Page.recordDeleted;
            } else {
                if (paramMap.containsKey('retURL')) {
                    newURL = newURL + '?retURL=' + ApexPages.currentPage().getParameters().get('retURL');
                }
                
                pageRef = new PageReference(newURL);
            }
            
            
            pageRef.setRedirect(true); 
            return pageRef;
        
        
        
    }

    public PageReference navigateEdit() {
        
            Map<String,String> paramMap = ApexPages.currentPage().getParameters();
            
            String newURL = buildURL() + '/e';
            
            if (paramMap.containsKey('retURL')) {
                newURL = newURL + '?retURL=' + ApexPages.currentPage().getParameters().get('retURL');
            }
            
            PageReference pageRef = new PageReference(newURL);
            
            pageRef.setRedirect(true);
            return pageRef;
        
    }
    
    public PageReference navigateNew() {
        
            
            Map<String,String> paramMap = ApexPages.currentPage().getParameters();
            String newURL = '/a0K/e';
            
            if (paramMap.containsKey('retURL')) {
                newURL = newURL + '?retURL=' + ApexPages.currentPage().getParameters().get('retURL');
                newURL = newURL + buildParamURL(ApexPages.currentPage().getParameters().get('retURL'));
            }
            
            PageReference pageRef = new PageReference(newURL);
         
            
            pageRef.setRedirect(true);
            return pageRef;
        
    }
    
    public String buildURL() {
        
        String URL = '/';
        eventId = ApexPages.currentPage().getParameters().get('id');
        System.debug('Event ID: ' + eventId);
        reportId = getEventReport(eventId);
        URL = URL + reportId;
        return URL;
        
    }
    
    public String buildParamURL(String retURL) {
    
        String paramURL = retURL;
        String assignTo = 'CF00N200000024QsA';
        String clientName = '00N200000024RD3';
        String startDate = '00N200000024RDK';
        String endDate = '00N200000024RD7';
        String showTimeAs = '00N200000033cYy';
        String relatedContact = 'CF00N200000033cYw';
        String relatedClient = 'CF00N200000033cYu';
        String relatedOpp = 'CF00N200000033cYv';
        
        //get Object ID prefix and record Id from URL
        String idPrefix = retURL.substring(1,4);
        String recId = '';
        if (retURL.contains('?') || retURL.contains('&')) {
            Integer p1 = retURL.indexOf('?');
            Integer p2 = retURL.indexOf('&');
            
            if (p1 > 0) {
                 recId = retURL.substring(1,p1);
            } else if (p2 > 0) {
                recId = retURL.substring(1,p2);
            }
        } else {
            if (!retURL.contains('home')) {
                if (retURL.length() >= 18) {
                    recId = retURL.substring(1,19);
                } else {
                    recId = retURL.substring(1,16);
                }
            }
        }
        
        paramURL = '&' + assignTo + '=' + UserInfo.getName();

        //Lead
        if (idPrefix.equals('00Q')) {
            
            List<Lead> l = [Select Name From Lead Where Id =: recId limit 1];
            if (l.size() > 0) {
                String lname = l[0].Name;
                lname = lname.replaceAll('&','%26');
                
                paramURL = paramURL + '&' + relatedContact + '=' + lname;
            }
        //Contact   
        } else if (idPrefix.equals('003')) {
            
            List<Contact> con = [Select Name, Account.Name From Contact Where Id =: recId limit 1];
            if (con.size() > 0) {
                String conname = con[0].Name;
                conname = conname.replaceAll('&','%26');
                
                String accname = con[0].Account.Name;
                accname = accname.replaceAll('&','%26');
                
                paramURL = paramURL + '&' + relatedContact + '=' + conname + '&' + clientName + '=' + accname;
            }
        //Client    
        } else if (idPrefix.equals('001')) {
            
            List<Account> acc = [Select Name From Account Where Id =: recId limit 1];
            
            if (acc.size() > 0) {
                String cname = acc[0].Name;
                cname = cname.replaceAll('&','%26');
                paramURL = paramURL + '&' + relatedClient + '=' + cname + '&' + clientName + '=' + cname;
            }
        //Opportunity   
        } else if (idPrefix.equals('006')) {
            
            List<Opportunity> opp = [Select Name From Opportunity Where Id =: recId limit 1];
            
            if (opp.size() > 0) {
                String oppname = opp[0].Name;
                oppname = oppname.replaceAll('&','%26');
                
                paramURL = paramURL + '&' + relatedOpp + '=' + oppname;
            }
        }
    
                    
        paramURL = paramURL + '&' + showTimeAs + '=Busy&' + startDate + '=' + Datetime.now().format() + '&' + endDate + '=' + Datetime.now().addHours(1).format();  
     
        return paramURL;
    
    }
    
    public static String getEventReport(String eventId) {
        String reportId = '';
        
        List<Call_Report__c> r = new List<Call_Report__c>();
        List<Call_Report__c> eventReportList = [select id,Eventid__c from Call_Report__c where Eventid__c LIKE :eventId.substring(0, 15) +'%'];
        system.debug('---------' + eventReportList);

        for (Call_Report__c callEvent : eventReportList)
        {
            try {
                if (Id.valueOf(callEvent.Eventid__c)  == Id.valueOf(eventId)) {
                   r.add(callEvent);
                }
            }
            catch(Exception e) {}
        }
        
        if (r.size() > 0) {
            reportId = r[0].id;
        } 
        else {
            //update current Event that will fire the Create Event Report trigger and this trigger will then do an upsert and 
            //create a Event Report for this Event. 
            List<Event> e = [select id,Short_Description__c from Event where Id = :eventID];
            system.debug('--Event Exist --' + e);
            if (e.size() > 0) {
                e[0].Short_Description__c = '-';
                update e;
            }
            
            List<Call_Report__c> rp = [select id from Call_Report__c where Eventid__c = :eventID];
            system.debug('++++RP+++  ' + rp);
            if (rp.size() > 0) {
                reportId = rp[0].id;
            }
        }
        
        system.debug('++++ReportID++++++++ ' + reportID);
        return reportId;
    }
}