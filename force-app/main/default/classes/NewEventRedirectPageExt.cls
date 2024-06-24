/*************************************************************************\
    @ Func Area:    Events; Event Reports
    @ Author:       Vishnu Vundavalli
    @ Date:         25 May 2015
    @ Test File:    Test method (testMe()) at the end of this class
    @ Description:  This extension class is used for the NewEventRedirectPage for using
                    redirecting the user to new Event Report Page on new Event 

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : June 20, 2016
    @ Last Modified Reason  : US-1355 - Ensuring at least 2 Core Team Members exist on Internal Core Meetings
    
    @ Last Modified By  : Abhishek V
    @ Last Modified On  : Dec 2, 2016
    @ Last Modified Reason  : US-1695 - Ensuring the record typr for new event is always "Meeting" so as to skip RT selection page on New Event

    @ Last Modified By  : Derek Hughes
    @ Last Modified On  : Mar 30, 2023
    @ Last Modified Reason  : SFP-?????  Create a new static method to generate the URL so that it can be called from the new LWC controller.

/************************************************************************/
public with sharing class NewEventRedirectPageExt {
    
    public NewEventRedirectPageExt(ApexPages.StandardController stdController) {
       
    }

    /**
    * @description Get the custom URL and returns it to the NewEventRedirectPage VF page
    * @author Derek Hughes | 30-03-2023 
    * @return PageReference 
    **/
    public PageReference redirect(){

        string urlRedirect=redirectUrl(ApexPages.currentPage().getParameters());
        Pagereference pageRef = new PageReference(urlRedirect);
        pageRef.setRedirect(true);
        return pageRef;

    }

    //Generate a URL to navigate the user to the edit page of Event Report on click of new Event button
    public static String redirectUrl(Map<String,String> paramMap){

        User currentUser = SEL_Users.newInstance().selectUsersWithProfileByIds(new Set<Id> {UserInfo.getUserId()}).get(0);
        String urlStr = '';
        
        Schema.DescribeSObjectResult d = Schema.SObjectType.Call_Report__c;
        String keyPrefix = d.getKeyPrefix();
        Map<String, Schema.RecordTypeInfo> EventRecordTypeInfo = d.getRecordTypeInfosByName();
        Id emrtId = EventRecordTypeInfo.get('Meeting').getRecordTypeId();
        
        Schema.DescribeSObjectResult accountObject = Schema.SObjectType.Account;
        String AccountkeyPrefix = accountObject.getKeyPrefix();
        
        Schema.DescribeSObjectResult caseObject = Schema.SObjectType.Case;
        String CaseKeyPrefix = caseObject.getKeyPrefix();
        
        Schema.DescribeSObjectResult campaignObject = Schema.SObjectType.Campaign;
        String CampaignKeyPrefix = campaignObject.getKeyPrefix();
        
        Schema.DescribeSObjectResult oppObject = Schema.SObjectType.Opportunity;
        String OppKeyPrefix = oppObject.getKeyPrefix();
        
        Schema.DescribeSObjectResult conObject = Schema.SObjectType.Contact;
        String conKeyPrefix = conObject.getKeyPrefix();
        
        urlStr = urlStr + '/' + keyPrefix + '/e' ;
        Id loggedInUserID = userInfo.getUserID();
        String loggedInUserName = userInfo.getName() ;
        urlStr = urlStr + '?CF00N200000024QsA_lkid=' + loggedInUserID + '&CF00N200000024QsA='+ loggedInUserName+ '&RecordType='+emrtId;
        DateTime startDateTime = system.now();
        DateTime endDateTime = startDateTime.addHours(1);
        
        String startDateStr = startDateTime.format() ;
        String endDateStr = endDateTime.format();
        
        urlStr = urlStr + '&00N200000024RDK=' + startDateStr ;
        urlStr = urlStr + '&00N200000024RD7=' + endDateStr ;
        urlStr = urlStr + '&Name=' + label.EventReportDefaultName ;
                
        if(paramMap.containsKey('retURL')){
            
            String  retURLStr = paramMap.get('retURL');
            String objectKey = retURLStr.substring(1,4);
            string objectId ;
            
            if(retURLStr.indexOf('?') != -1){
                objectId = retURLStr.substring(1,retURLStr.indexOf('?'));
            }else{
                objectId = retURLStr.substring(1,retURLStr.length());
            }
            system.debug('>>> retURLStr : ' + retURLStr );
            system.debug('>>> retURLStr length  : ' + objectId.length() );
            system.debug('>>> objectId : ' + objectId );
            system.debug('>>> OppKeyPrefix : ' + OppKeyPrefix);
            
            
            if(objectId.length() == 15 || objectId.length() == 18){
                if(objectKey == AccountKeyPrefix){
                    Account acc = new account();
                    acc = [select id,name from Account where id =: objectId];
                    urlStr = urlStr + '&CF00N200000033cYu_lkid=' + objectId + '&CF00N200000033cYu=' + EncodingUtil.URLEncode(acc.name,'UTF-8') ;
                }else if(objectKey == CaseKeyPrefix){
                    Case c = new Case();
                    c= [select id,CaseNumber from Case where id =: objectId];
                    urlStr = urlStr + '&CF00N20000002osVA_lkid=' + objectId + '&CF00N20000002osVA=' + EncodingUtil.URLEncode(c.CaseNumber,'UTF-8') ;
                }else if(objectKey == CampaignKeyPrefix){
                
                    Campaign camp = new Campaign();
                    camp = [select id,name from Campaign where id =: objectId];
                    urlStr = urlStr + '&CF00N20000002osVB_lkid=' + objectId + '&CF00N20000002osVB=' + EncodingUtil.URLEncode(camp.name,'UTF-8')  ;
                }else if(objectKey == conKeyPrefix){
                
                    Contact con = new Contact();
                    con = [select id,name from Contact where id =: objectId];
                    urlStr = urlStr + '&CF00N200000033cYw_lkid=' + objectId + '&CF00N200000033cYw=' + EncodingUtil.URLEncode(con.name,'UTF-8')  ;
                }else if(objectKey == OppKeyPrefix ){

                    Opportunity opp = new Opportunity();
                    opp = [select id,name from Opportunity where id =: objectId];
                    urlStr = urlStr + '&CF00N200000033cYv_lkid=' + objectId + '&CF00N200000033cYv=' + EncodingUtil.URLEncode(opp.name,'UTF-8')  ;
                }
            }
            
            urlStr = urlStr + '&retURL=' + paramMap.get('retURL');
            urlStr = urlStr + '&saveURL=/apex/RedirectToAddAttendees';
        }
        Pagereference pageRef = new PageReference(urlStr);
        pageRef.setRedirect(true);

        return urlStr;
    }

}