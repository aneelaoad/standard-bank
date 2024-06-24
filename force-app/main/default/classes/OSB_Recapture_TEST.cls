/**
 * @description Test Class Class for OSB_Recapture
 * 
 * @author Wayde Fagan (Wayde.fagan@tetrad.co.za)
 * @date August 2021
 * 
 * @LastModified October 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-31440
 * @LastModifiedReason Removal of Hard coded URLS and improvements to meet standards
 * 
 */
@isTest
public class OSB_Recapture_TEST {
    private static final String TEST_STATUS_CODE = 'OK';
    private static final String TOKEN = 'fakeTojken1025541';
    
	@TestSetup
    static void setup() {
        List<SObject> customSettingsList = new List<SObject>();
       	OSB_URLs__c osbUrl = new OSB_URLs__c();
        osbUrl.Name = 'Google_Recapture_Endpoint';
        osbUrl.Value__c = 'callout:Google_recapture';
        customSettingsList.add(osbUrl);
        
        SB_Parameters__c sB = new SB_Parameters__c();
		sB.Name = 'OSB_RecaptureKey';
        sB.Value__c = '6LfzIM0bAAAAAGT4n5jmvs1Y_APs3UOFg74Q56sB';
        customSettingsList.add(sB);
        insert customSettingsList;
    }
    
    @isTest
    static void testCheckCapture(){
        String communityUrl =  initializeCommunityUrl();
        String recaptureTestBody = '{ "success": true, "challenge_ts": "2021-08-15T10:10:54Z", "hostname": "'+communityUrl+'"}';
        Map<String, String> mockResponseHeaders = new Map<String, String>();
		Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, TEST_STATUS_CODE, recaptureTestBody,mockResponseHeaders));
        
        Test.startTest();
        Boolean result = OSB_Recapture.checkRecapture(TOKEN);
        Test.stopTest();

        Assert.areEqual(true, result, 'Recapture worked successfully.');
    }

    @isTest
    static void testCheckCaptureFailure(){
        String communityUrl =  initializeCommunityUrl();
        String recaptureTestBody = '{ "success": false, "challenge_ts": "2021-08-15T10:10:54Z", "hostname": "'+communityUrl+'"}';
        Map<String, String> mockResponseHeaders = new Map<String, String>();
		Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, TEST_STATUS_CODE, recaptureTestBody,mockResponseHeaders));
        
        Test.startTest();
        Boolean result = OSB_Recapture.checkRecapture(TOKEN);
        Test.stopTest();

        Assert.areEqual(false, result, 'Recapture did not work successfully.');
    }

    @isTest
    static void testCheckStatusCodeFailure(){
        String communityUrl =  initializeCommunityUrl();
        String recaptureTestBody = '{ "success": false, "challenge_ts": "2021-08-15T10:10:54Z", "hostname": "'+communityUrl+'"}';
        Map<String, String> mockResponseHeaders = new Map<String, String>();
		Test.setMock(HttpCalloutMock.class, new SingleRequestMock(401, TEST_STATUS_CODE, recaptureTestBody,mockResponseHeaders));
        
        Test.startTest();
        Boolean result = OSB_Recapture.checkRecapture(TOKEN);
        Test.stopTest();

        Assert.areEqual(false, result, 'Recapture did not work successfully.');
    }

    private static String initializeCommunityUrl() {
        Site site = [SELECT Id, Name FROM Site WHERE Name = 'Onehub' LIMIT 1];
        String communityUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;
        return communityUrl;
    }
}