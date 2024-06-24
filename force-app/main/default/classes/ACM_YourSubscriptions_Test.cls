@isTest
public class ACM_YourSubscriptions_Test {
    public static testmethod void getSubscriptionList(){
        acm_pkg__AnypointApplications__x acmApp = new acm_pkg__AnypointApplications__x();
        acmApp.ExternalId = 'mockData';
        ACM_Subscription__c obj = new ACM_Subscription__c();
        obj.Name = 'Test';
        obj.Application_T__c = 'mockData';
        insert obj;
        ACM_YourSubscriptions.getSubscriptionList('mockData');
    }
}