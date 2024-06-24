/**
 * @Author Emmanuel Mulea Nocks
 * @date April 2024
 * @description This class contains unit tests for validating the behavior of scpwa_CommunityManifestCtrl
 */
@isTest
private class SCPWA_CommunityManifestCtrlTest {

    @isTest
    static void testGetContent() { 
        String staticBody = null;
        Test.startTest();
        scpwa_CommunityManifestCtrl scpwa = new scpwa_CommunityManifestCtrl();
        staticBody = scpwa.getContent();
        Test.stopTest();

        Assert.areNotEqual(staticBody,null);
    
    }

    @isTest
    static void testReplaceUrlPrefix() { 
        String staticBody = null;
        Test.startTest();
        staticBody = scpwa_CommunityManifestCtrl.replaceUrlPrefix('');
        Test.stopTest();

        Assert.areEqual(staticBody,'');
    
    }

    @isTest
    static void testReplaceResourcesLastModified() { 
        String staticBody = null;
        Test.startTest();
        staticBody = scpwa_CommunityManifestCtrl.replaceResourcesLastModified('');
        Test.stopTest();

        Assert.areEqual(staticBody,'');
    
    }

}