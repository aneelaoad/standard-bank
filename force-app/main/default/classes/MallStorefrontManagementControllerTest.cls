/**
 * 
 * @description MallStorefrontManagementControllerTest
 * @author Ankit Kumar
 * @since 
*/
@isTest
public with sharing class MallStorefrontManagementControllerTest {
    
    @testSetup static void setup() {
        Publishing_Unit__c pu = new Publishing_Unit__c();
        pu.isPublished__c = true;
        pu.Published_from__c = system.today() - 1;
        pu.Published_until__c = system.today() + 2;
    	insert pu;

        Publishing_Unit__c pu1 = new Publishing_Unit__c();
        pu1.isPublished__c = false;
        pu1.Published_from__c = system.today() - 1;
        pu1.Published_until__c = system.today() + 2;
    	insert pu1;

        Account account = new Account();
        account.Name = 'Test Account';
        insert account;

        Provider__c provider = new Provider__c();
        provider.Name = 'Provider name';
        provider.Related_Client__c = account.Id;
        provider.Publishing_Unit__c = pu1.Id;
        insert provider;

        Tag__c parentTag = new Tag__c();
        parentTag.Name = 'Language';
        insert parentTag;
        assert.areEqual('Language', parentTag.Name, 'parent tag language');

        Tag__c tag = new Tag__c();
        tag.Name = 'en';
        tag.Root__c = parentTag.Id;
        insert tag;
        assert.areEqual('en', tag.Name, 'tag name english');

        tag.Publishing_Unit__c = pu.Id;
        update tag;
    }

    @IsTest
    static void getProviderInfoTest() {

        Test.startTest();
        List<Account> accounts = SEL_Accounts.newInstance().selectWithoutCondition();
        MallStorefrontManagementController.ProviderInfo providerInfo = MallStorefrontManagementController.getProviderInfo(accounts[0].Id);        
        MallStorefrontManagementController.providerUpdateRequest(providerInfo.publishedProvider.Id, '');
        providerInfo = MallStorefrontManagementController.getProviderInfo(accounts[0].Id);
        MallStorefrontManagementController.providerUpdateRequest(providerInfo.publishedProvider.Id, providerInfo.clonedProvider.Id);
        providerInfo = MallStorefrontManagementController.getProviderInfo(accounts[0].Id);
        assert.areEqual('Draft', providerInfo.clonedProvider.Status__c, 'provider info icon should be there');
        Test.stopTest(); 
    }

    @IsTest
    static void imageRequestTest() { 
        List<Account> accounts = SEL_Accounts.newInstance().selectWithoutCondition();
        MallStorefrontManagementController.ProviderInfo providerInfo = MallStorefrontManagementController.getProviderInfo(accounts[0].Id);        
        MallStorefrontManagementController.providerUpdateRequest(providerInfo.publishedProvider.Id, '');
        
        Content_Unit_Translation__c cut = new Content_Unit_Translation__c();
        cut.Image_Url__c = '';
        cut.Provider__c = providerInfo.publishedProvider.Id;
        cut.Language__c = SEL_Tags.newInstance().selectTagsByNames(new Set<String>{'en'})[0].Id;
        insert cut;

        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;

        ContentVersion cv1=new Contentversion();
        cv1.title='ABC';
        cv1.PathOnClient ='test';
        cv1.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv1;
        
        Test.startTest();
        MallStorefrontManagementController.updateImageRequest(accounts[0].Id, providerInfo.publishedProvider.Id, cv.Id, cut.Id);
        providerInfo = MallStorefrontManagementController.getProviderInfo(accounts[0].Id);
        MallStorefrontManagementController.submitProviderForApproval(providerInfo.clonedProvider.Id, 'Test Comment');
        providerInfo = MallStorefrontManagementController.getProviderInfo(accounts[0].Id);
        assert.isTrue(providerInfo.clonedProvider.Id != NULL, 'status submitted');
        Test.stopTest(); 
    }

    @IsTest
    static void publishProviderTest() {
        List<Account> accounts = SEL_Accounts.newInstance().selectWithoutCondition();
        MallStorefrontManagementController.ProviderInfo providerInfo = MallStorefrontManagementController.getProviderInfo(accounts[0].Id);        
        MallStorefrontManagementController.providerUpdateRequest(providerInfo.publishedProvider.Id, '');
        providerInfo = MallStorefrontManagementController.getProviderInfo(accounts[0].Id);     

        Tag__c tag = SEL_Tags.newInstance().selectTagsByNames(new Set<String>{'en'})[0];
        Content_Unit_Translation__c cut = new Content_Unit_Translation__c();
        cut.Image_Url__c = '';
        cut.Provider__c = providerInfo.publishedProvider.Id;
        cut.Language__c = tag.Id;
        insert cut;

        Content_Unit_Translation__c cut1 = new Content_Unit_Translation__c();
        cut1.Image_Url__c = '';
        cut1.Provider__c = providerInfo.publishedProvider.Id;
        cut1.Language__c = tag.Id;
        insert cut1;
       
        providerInfo = MallStorefrontManagementController.getProviderInfo(accounts[0].Id);     

        Test.startTest();
        MallStorefrontManagementController.publishProvider(System.JSON.serialize(providerInfo));
        providerInfo = MallStorefrontManagementController.getProviderInfo(accounts[0].Id);
        assert.areEqual(true, String.isBlank(providerInfo.publishedProvider.Status__c), 'should be equal');
        Test.stopTest();
    }

    @IsTest
    static void updateProviderInfoTest2() {
        List<Account> accounts = SEL_Accounts.newInstance().selectWithoutCondition();
        MallStorefrontManagementController.ProviderInfo providerInfo = MallStorefrontManagementController.getProviderInfo(accounts[0].Id);        
        MallStorefrontManagementController.providerUpdateRequest(providerInfo.publishedProvider.Id, '');
        providerInfo = MallStorefrontManagementController.getProviderInfo(accounts[0].Id);        

        Content_Unit_Translation__c cut = new Content_Unit_Translation__c();
        cut.Image_Url__c = '';
        cut.Text__c = 'image text';
        cut.Provider__c = providerInfo.publishedProvider.Id;
        cut.Language__c = SEL_Tags.newInstance().selectTagsByNames(new Set<String>{'en'})[0].Id;
        insert cut;

        ContentVersion cv=new Contentversion();
        cv.title='ABC';
        cv.PathOnClient ='test';
        cv.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv;

        ContentVersion cv1=new Contentversion();
        cv1.title='ABC';
        cv1.PathOnClient ='test';
        cv1.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert cv1;
        
        Test.startTest();
        MallStorefrontManagementController.updateImageRequest(accounts[0].Id, providerInfo.publishedProvider.Id, cv.Id, cut.Id);
        ContentVersion content = [SELECT ContentDocumentId FROM ContentVersion WHERE ID =: cv.Id LIMIT 1];
        MallStorefrontManagementController.deleteImageRequest(accounts[0].Id, providerInfo.clonedProvider.Id, content.ContentDocumentId, cut.Id);
        providerInfo = MallStorefrontManagementController.getProviderInfo(accounts[0].Id);
        assert.areEqual(true, String.isBlank(providerInfo.cut.Image_Url__c), 'should be blank');
        MallStorefrontManagementController.cancelProviderUpdates(providerInfo.publishedProvider.Id);
        providerInfo = MallStorefrontManagementController.getProviderInfo(accounts[0].Id);
        assert.areEqual(true, String.isBlank(providerInfo.cut.Text__c), 'should be blank');
        Test.stopTest();
    }

    @IsTest
    static void updateRecordsTest() {
        provider__c provider = new Provider__c();
        provider.Name = 'Test provider';
        provider.Status__c = 'Draft';
        insert provider;

        Test.startTest();
        provider.Name += ' updated';
        MallStorefrontManagementController.updateProviders(System.JSON.serialize(new List<Provider__c>{provider}));
        List<Provider__c> providers = SEL_Providers.newInstance().selectByIds(new Set<Id>{(Id)provider.Id});
        MallStorefrontManagementController.updateSObjects(new List<Provider__c>{provider});
        assert.areEqual(true, String.IsNotBlank(providers[0].Name), 'should not be blank');
        Test.stopTest();
    }
}