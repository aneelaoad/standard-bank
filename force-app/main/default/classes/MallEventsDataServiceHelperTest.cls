/**
 * 
 * @description Test Class for MallEventsDataServiceHelperTest
 * @author Ankit Kumar
 * @since 
 */
@isTest
private with sharing class MallEventsDataServiceHelperTest {

    @testSetup static void setup() {
        List<Tag_Business_Event__c> tageventslist= new List<Tag_Business_Event__c>();       
        
        Tag__c tag = new Tag__c();
        tag.Position__c=1;
        tag.Name='Category';
        insert tag;

        Tag__c tg1 = new Tag__c();
        tg1.Position__c=1;
        tg1.Root__c = tag.Id;
        tg1.Parent__c = tag.Id;
        tg1.Name='Finance';
        Insert tg1;

        Tag__c tagSeg = new Tag__c();
        tagSeg.Position__c=1;
        tagSeg.Name='Segment';
        insert tagSeg;

        Tag__c tg2 = new Tag__c();
        tg2.Position__c=2;
        tg2.Root__c = tagSeg.Id;
        tg1.Parent__c = tagSeg.Id;
        tg2.Name='Business';
        Insert tg2;

        Tag__c tgLang = new Tag__c();
        tgLang.Position__c=1;
        tgLang.Name='Language';
        Insert tgLang;
    
        Tag__c tgEn = new Tag__c();
        tgEn.Position__c=1;
        tgEn.Name='en';
        tgEn.Root__c = tgLang.Id;
        tgEn.Parent__c=tgLang.id;
        Insert tgEn;

        Tag__c tgCountry = new Tag__c();
        tgCountry.Position__c=1;
        tgCountry.Name='Country';
        Insert tgCountry;

        Tag__c tgCountrySA = new Tag__c();
        tgCountrySA.Position__c=1;
        tgCountrySA.Name='South Africa';
        tgCountrySA.Root__c= tgCountry.Id;
        tgCountrySA.Parent__c= tgCountry.Id;
        Insert tgCountrySA;

        Publishing_Unit__c pu = new Publishing_Unit__c();
        pu.Published_from__c = system.today();
        pu.Published_until__c = system.today()+2;
        pu.IsPublished__c = true;
        insert pu;  

        Link__c link = new Link__c();
        link.Desktop_url__c = 'www.google.com';
        link.Guest_url__c = 'www.google.com';
        link.Mobile_url__c = 'www.google.com';
        insert link;

        Provider__c provider= new Provider__c();
        provider.Name='test1';
        insert provider;

        List<Tag_Provider__c> shoplist= new List<Tag_Provider__c>();
        Tag_Provider__c tgshop = new Tag_Provider__c();
        tgshop.Provider__c = provider.id;
        tgshop.Tag__c= tg1.id;
        shoplist.add(tgshop);

        Tag_Provider__c tgshop1 = new Tag_Provider__c();
        tgshop1.Provider__c=provider.id;
        tgshop1.Tag__c=tg2.id;

        Tag_Provider__c tgshop2 = new Tag_Provider__c();
        tgshop2.Provider__c=provider.id;
        tgshop2.Tag__c=tgCountrySA.id;

        shoplist.add(tgshop2);
        insert shoplist;

        Business_Event__c event = new Business_Event__c();
        event.Name='Test Event';
        insert event;
        event.Publishing_Unit__c= pu.id;
        event.Link__c = link.Id;
        event.Provider__c = provider.Id;
        update event;

        Tag_Business_Event__c eventTag1 = new Tag_Business_Event__c();
        eventTag1.Business_Event__c = event.Id;
        eventTag1.Tag__c = tg1.Id;
        insert eventTag1;
        tageventslist.add(eventTag1);

        Tag_Business_Event__c eventTag2 = new Tag_Business_Event__c();
        eventTag2.Business_Event__c = event.Id;
        eventTag2.Tag__c = tg2.Id;
        insert eventTag2;
        tageventslist.add(eventTag2);

        Tag_Business_Event__c eventTag3 = new Tag_Business_Event__c();
        eventTag3.Business_Event__c = event.Id;
        eventTag3.Tag__c = tgCountrySA.Id;
        insert eventTag3;
        tageventslist.add(eventTag3);

        Content_Unit_Translation__c cut= new Content_Unit_Translation__c();
        cut.Language__c = tgEn.id;
        cut.Business_Event__c = event.id;
        cut.Text__c = 'Test Content Unit';
        cut.RichText__c = 'Rich Test Content Unit';
        cut.Image_Url__c = 'https://google.com';
        insert cut;
    }


    @isTest
    static void prepareEventsForLanguageTest(){       
        List<Tag_Business_Event__c> tagEventsLst = [Select Id, Business_Event__c, Tag__r.Name, Tag__r.Parent_Name__c FROM Tag_Business_Event__c];
        Test.startTest();
        MallEventsDataServiceHelper mallEventsDataServiceHelper =new MallEventsDataServiceHelper();
        mallEventsDataServiceHelper.prepareEventsForCountry(tagEventsLst);
        Map<String,Map<Id,Content_Unit_Translation__c>> translationsMapLst = mallEventsDataServiceHelper.prepareEventsForLanguage(tagEventsLst);
        assert.areNotEqual(translationsMapLst, null, 'should not be null');
        Test.stopTest();
    }
}