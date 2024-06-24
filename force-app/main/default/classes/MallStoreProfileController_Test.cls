/**
 * 
 * @description Test Class for MallStoreProfileController_Test
 * @author Ankit Kumar  
 * @since 
 */


 @isTest
 public with sharing class MallStoreProfileController_Test {
 
     @TestSetup
     static void makeData() {
        Publishing_Unit__c publishingUnit = new Publishing_Unit__c();
        publishingUnit.IsPreview__c = true;
        publishingUnit.Published_from__c = Date.newInstance(2022, 2, 2);
        publishingUnit.Published_until__c = Date.newInstance(2023, 2, 4);
        insert publishingUnit;

        Tag__c tagCategory = new Tag__c();
        tagCategory.Position__c = 1;
        tagCategory.Name = 'Category';
        insert tagCategory;

        Tag__c tagCategoryChild = new Tag__c();
        tagCategoryChild.Position__c = 1;
        tagCategoryChild.Root__c = tagCategory.Id;
        tagCategoryChild.Name = 'Grow';

        Insert tagCategoryChild;

        Tag__c tagSegment = new Tag__c();
        tagSegment.Position__c = 1;
        tagSegment.Name = 'Segment';
        insert tagSegment;

        Tag__c tagSegmentChild = new Tag__c();
        tagSegmentChild.Position__c = 1;
        tagSegmentChild.Root__c = tagSegment.Id;
        tagSegmentChild.Name = 'Business';
        Insert tagSegmentChild;

        Tag__c tagCountry = new Tag__c();
        tagCountry.Position__c = 1;
        tagCountry.Name = 'Country';
        insert tagCountry;

        Tag__c tagCountryChild = new Tag__c();
        tagCountryChild.Position__c = 1;
        tagCountryChild.Root__c = tagCountry.Id;
        tagCountryChild.Name = 'South Africa';
        Insert tagCountryChild;

        Account account = new Account();
        account.Name = 'Test account';
        insert account;

        Provider__c provider = new Provider__c();
        provider.Name = 'Provider test1';
        provider.Related_Client__c = account.Id;
        provider.Status__c = 'Published';
        insert provider;

        Tag_Provider__c segment = new Tag_Provider__c();
        segment.Tag__c = tagSegmentChild.Id;
        segment.Provider__c = provider.Id;
        insert segment;

        Tag_Provider__c category = new Tag_Provider__c();
        category.Tag__c = tagCategoryChild.Id;
        category.Provider__c = provider.Id;
        insert category;

        Tag_Provider__c country = new Tag_Provider__c();
        country.Tag__c = tagCountryChild.Id;
        country.Provider__c = provider.Id;
        insert country;
     }
 
     @IsTest
     static void testgetStoreProfile() {
        Account account = [SELECT ID FROM ACCOUNT LIMIT 1];
        MallStoreProfileController.AccountInfo accountInfo = MallStoreProfileController.getStoreProfile(account.Id);
        Assert.areEqual(accountInfo.account.Id, account.Id, 'should be equal');
     }
 }