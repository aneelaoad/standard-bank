/**
 * @Author Emmanuel Mulea Nocks
 * @date April 2024
 * @description This class contains unit tests for validating the behavior of scpwa_CommunityServiceWorkerCtrl
 */
@isTest
private class SCPWA_CommunityServiceWorkerCtrlTest {

    @isTest
    static void testGetContent() { 
        String staticBody = null;
        Test.startTest();
        scpwa_CommunityServiceWorkerCtrl scpwa = new scpwa_CommunityServiceWorkerCtrl();
        staticBody = scpwa.getContent();
        Test.stopTest();

        Assert.areNotEqual(staticBody,null);
    
    }
}