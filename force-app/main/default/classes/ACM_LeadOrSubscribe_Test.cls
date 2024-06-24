/**

@description Queries for access type for each API

@className ACM_LeadOrSubscribeTEst

@Author - Vuyo Xhamfu

@email  vuyo.xhamfu@standardbank.co.za

@company  Standardbank    

@date  June 13th, 2023

**/

@isTest

public class ACM_LeadOrSubscribe_Test {

    public static testmethod void getSubscriptionList(){

        final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ACM_LeadOrSubscribe');
		acm_pkg__CommunityApi__c communityApi = new acm_pkg__CommunityApi__c();
        communityApi.acm_pkg__Name__c = 'Example API';
        communityApi.acm_pkg__ApiId__c = 'bdd1bbab-b9f2-4d92-9ce1-c09421fa021f:hello-world';
        communityApi.acm_pkg__AssetVersion__c = '2.0.0';
        communityApi.acm_pkg__AssetType__c = 'rest-api';
        communityApi.acm_pkg__VersionGroup__c = 'v2';
        communityApi.acm_pkg__Visibility__c = 'Public'; 
        insert communityApi;
        ACM_LeadOrSubscribe.getAPIAccessType(communityApi.Id);
        ACM_LeadOrSubscribe.getAPIAccessType('');
    }

}