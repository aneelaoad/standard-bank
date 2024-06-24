/**
 * 
 * @description Test Class for MallContentDataServiceHelperTest
 * @author Ankit Kumar
 * @since 
 */
@IsTest
public with sharing class MallContentDataServiceHelperTest {
    
    @testSetup static void setup() {
        Publishing_Unit__c pu = new Publishing_Unit__c();
        pu.Published_from__c = system.today();
        pu.Published_until__c = system.today()+2;
        pu.IsPublished__c = true;
        insert pu;  

        Tag__c tagSeg = new Tag__c();
        tagSeg.Position__c=1;
        tagSeg.Name='Segment';
        tagSeg.Publishing_Unit__c = pu.Id;
        insert tagSeg;

        Tag__c tgBusiness = new Tag__c();
        tgBusiness.Position__c=2;
        tgBusiness.Root__c = tagSeg.Id;
        tgBusiness.Parent__c = tagSeg.Id;
        tgBusiness.Name='Business';
        tgBusiness.Publishing_Unit__c = pu.Id;
        Insert tgBusiness;
        
        Tag__c tagCat = new Tag__c();
        tagCat.Position__c=1;
        tagCat.Name='Category';
        tagCat.Publishing_Unit__c = pu.Id;   
        insert tagCat;

        Tag__c tgFinance = new Tag__c();
        tgFinance.Position__c=1;
        tgFinance.Root__c = tagCat.Id;
        tgFinance.Parent__c = tagCat.Id;
        tgFinance.Name='Finance';
        tgFinance.Publishing_Unit__c = pu.Id;   
        Insert tgFinance;

        Tag__c tgLang = new Tag__c();
        tgLang.Position__c=1;
        tgLang.Name='Language';
        tgLang.Publishing_Unit__c = pu.Id;   
        Insert tgLang;
    
        Tag__c tgEn = new Tag__c();
        tgEn.Position__c=1;
        tgEn.Name='en';
        tgEn.Publishing_Unit__c = pu.Id;   
        tgEn.Root__c = tgLang.Id;
        tgEn.Parent__c=tgLang.id;
        Insert tgEn;

        Tag__c tgCountry = new Tag__c();
        tgCountry.Position__c=1;
        tgCountry.Publishing_Unit__c = pu.Id;   
        tgCountry.Name='Country';
        Insert tgCountry;

        Tag__c tgCountrySA = new Tag__c();
        tgCountrySA.Position__c=1;
        tgCountrySA.Name='South Africa';
        tgCountrySA.Root__c= tgCountry.Id;
        tgCountrySA.Parent__c= tgCountry.Id;
        tgCountrySA.Publishing_Unit__c = pu.Id;   
        Insert tgCountrySA;


        Link__c link = new Link__c();
        link.Desktop_url__c = 'www.google.com';
        link.Guest_url__c = 'www.google.com';
        link.Mobile_url__c = 'www.google.com';
        link.Publishing_Unit__c = pu.Id;   
        insert link;
    }

    /**
     * 
     * @description getContentsByCountryNamesAndRecordTypesTest
    */
    @Istest
    static void getContentsByCountryNamesAndRecordTypesTest() {
        Test.startTest();
        String mallContext = '{"mallUserSelectedCountry":"South Africa","mallUserSelectedLanguage":"en","selectedSegmentNames":["Business"],"selectedSegmentIds":[],"selectedCategoriesIds":[],"selectedCategoryNames":[]}';
        List<String> countries = new List<String>{'South Africa'};
        List<String> recordTypes = new List<String>{'Partner_with_us'};
        List<DenormalizedContent> contents = new MallDataServiceHandler(mallContext).getContentsByCountryNamesAndRecordTypes(countries, recordTypes);
        Assert.areNotEqual(NULL, contents,'contents');
        Test.stopTest();
    }

    /**
     * 
     * @description getContentsByTagsRootTagsAndRecordTypeNamesTest
    */
    @Istest
    static void getContentsByTagsRootTagsAndRecordTypeNamesTest() {
        Test.startTest();
        
        String mallContext = '{"mallUserSelectedCountry":"South Africa","mallUserSelectedLanguage":"en","selectedSegmentNames":["Business"],"selectedSegmentIds":[],"selectedCategoriesIds":[],"selectedCategoryNames":[]}';
        List<String> rootTagNames = new List<String>{ 'Country', 'Segment', 'Category'};
        List<String> tagNames = new List<String>{ 'South Africa', 'Business', 'Finance'};
        List<String> recordTypes = new List<String>{'Partner_with_us'};
        List<DenormalizedContent> contents = new MallDataServiceHandler(mallContext).getContentsByTagsRootTagsAndRecordTypeNames(rootTagNames, tagNames, recordTypes);
        Assert.areNotEqual(NULL, contents,'contents');
        Test.stopTest();
    }

    /**
     * 
     * @description getContentsByTagIdsRootNamesAndRecordTypeNamesTest
    */
    @Istest
    static void getContentsByTagIdsRootNamesAndRecordTypeNamesTest() {
        Test.startTest();
        List<Tag_content__c> tagFinance = [Select Id, Tag__r.Name, Tag__c, Content__c FROM Tag_content__c WHERE Tag__r.Name = 'Finance'];
        String mallContext = '{"mallUserSelectedCountry":"South Africa","mallUserSelectedLanguage":"en","selectedSegmentNames":["Business"],"selectedSegmentIds":[],"selectedCategoriesIds":[],"selectedCategoryNames":[]}';
        List<String> rootTagNames = new List<String>{ 'Country', 'Category'};
        List<String> tagIds = new List<String>{tagFinance[0].Id};
        List<String> recordTypes = new List<String>{'Partner_with_us'};
        List<DenormalizedContent> contents = new MallDataServiceHandler(mallContext).getContentsByTagIdsRootNamesAndRecordTypeNames(rootTagNames, tagIds, recordTypes);
        Assert.areNotEqual(NULL, contents,'contents');
        Test.stopTest();
    }
}