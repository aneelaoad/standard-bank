public class ACM_YourSubscriptions {
    @AuraEnabled(cacheable=true)
    public static List<Subscription>  getSubscriptionList(string recId){
        List<Subscription> subscriptionList = new List<Subscription>();
        List<acm_pkg__AnypointApplications__x> acmApplicationList = [SELECT Id,ExternalId from acm_pkg__AnypointApplications__x 
                                                                     WHERE Id =: recId
                                                                    ];
        if(Test.isRunningTest())
            acmApplicationList = mockData();
        
        if(acmApplicationList.size() > 0){
            List<ACM_Subscription__c> subscriptionRecList = [SELECT Id,Product_Name__c,Product_Version__c,Status__c,Source_Environment_T__c FROM ACM_Subscription__c
                                                             WHERE Application_T__c=: acmApplicationList[0].ExternalId
                                                            ];
            if(subscriptionRecList.size() > 0){
                for(ACM_Subscription__c acmSubscriptionObject : subscriptionRecList){
                    Subscription subscriptionObj = new Subscription();
                    subscriptionObj.apiProduct = acmSubscriptionObject.Product_Name__c;
                    subscriptionObj.status = acmSubscriptionObject.Status__c;
                    subscriptionObj.version = acmSubscriptionObject.Product_Version__c;
                    subscriptionObj.enviornment = acmSubscriptionObject.Source_Environment_T__c;
                    subscriptionList.add(subscriptionObj);
                    
                }
            }
        }
        return subscriptionList;
    }
    
    public static List<acm_pkg__AnypointApplications__x> mockData() {
        List<acm_pkg__AnypointApplications__x> mockList = new List<acm_pkg__AnypointApplications__x>();
        acm_pkg__AnypointApplications__x mockObj = new acm_pkg__AnypointApplications__x();
        mockObj.ExternalId = 'mockData';
        mockList.add(mockObj);
        return mockList;
    }
    public class Subscription{
        @AuraEnabled 
        public string version{get;set;}
        @AuraEnabled 
        public string apiProduct{get;set;}
        @AuraEnabled 
        public string status{get;set;}
        @AuraEnabled 
        public string enviornment{get;set;}
    }
    
}