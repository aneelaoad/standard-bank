/**
 * @Author Emmanuel Mulea Nocks
 * @date April 2024
 * @description This class contains unit tests for validating the behavior of scpwa_CommunityPwaLoaderCtrl
 */
@isTest
private class SCPWA_CommunityPwaLoaderCtrlTest {

    @isTest
    static void testGetContent() { 
        String staticBody = null;
        Test.startTest();
        scpwa_CommunityPwaLoaderCtrl scpwa = new scpwa_CommunityPwaLoaderCtrl();
        staticBody = scpwa.getContent();
        Test.stopTest();

        Assert.areNotEqual(staticBody,null);
    
    }
}