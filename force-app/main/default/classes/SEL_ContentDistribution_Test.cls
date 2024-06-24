/**
 * 
 * @description Test class for SEL_ContentDistribution
 * @author Ankit Kumar
 * @since 
 */
@IsTest
public with sharing class SEL_ContentDistribution_Test {
    /**
     * 
     * @description testContentDistributionsSelector
     */
    @isTest
    public static void testContentDistributionsSelector() {
        Test.startTest();
        ContentVersion contentVersion=new Contentversion();
        contentVersion.title='Test Document Content';
        contentVersion.PathOnClient ='Testest';
        contentVersion.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert contentVersion;

        ContentDistribution contentDistribution = new ContentDistribution();
        contentDistribution.Name = contentVersion.Title;
        contentDistribution.ContentVersionId = contentVersion.Id;
        contentDistribution.PreferencesAllowViewInBrowser= true;
        contentDistribution.PreferencesLinkLatestVersion=true;
        contentDistribution.PreferencesNotifyOnVisit=false;
        contentDistribution.PreferencesPasswordRequired=false;
        contentDistribution.PreferencesAllowOriginalDownload= true;
        insert contentDistribution;

    	List<ContentDistribution> contentDistributions1 = SEL_ContentDistribution.newInstance().selectByContentVersionId(new Set<Id>{(Id)contentVersion.Id});
        List<ContentDistribution> contentDistributions2 = SEL_ContentDistribution.newInstance().selectById(new Set<Id>{(Id)contentDistribution.Id});
        Assert.areEqual(1, contentDistributions1.size(),'1 ContentDistributions created');
        Assert.areEqual(1, contentDistributions2.size(),'1 ContentDistributions created');
        Test.stopTest();
	}
}