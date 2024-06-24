/**
 * 
 * @description MallSuccessStoriesCtrl_Test
 * @author Maham Hasan
 * @since 
 */
@IsTest
public class MallSuccessStoriesCtrl_Test {

    @isTest
    public static void getSuccessStoriesByCountryNamesTest() {

        List <String> countries = new List <String> ();
        countries.add('India');
        countries.add('Angala');
        countries.add('South Africe');

        Tag__c tg1 = new Tag__c();
        tg1.Position__c = 1;
        tg1.Name = 'Country';

        Insert tg1;

        Tag__c tg2 = new Tag__c();
        tg2.Position__c = 3;
        tg2.Name = 'South Africe';
        tg2.Parent__c = tg1.id;
        Insert tg2;
        
        Tag__c tg3 = new Tag__c();
        tg3.Position__c = 1;
        tg3.Name = 'Language';

        Insert tg3;

        Tag__c tg4 = new Tag__c();
        tg4.Position__c = 3;
        tg4.Name = 'pt-AO';
        tg4.Parent__c = tg3.id;
        tg4.Root__c = tg3.Id;
        Insert tg4;

        Tag__c tg5 = new Tag__c();
        tg5.Position__c = 2;
        tg5.Name = 'en';
        tg5.Parent__c = tg3.id;
        tg5.Root__c = tg3.Id;
        Insert tg5;  
        
        Content_Unit__c cu = new Content_Unit__c();
        cu.HasImage__c = true;
        insert cu;
        
        Content_Unit_Translation__c cut= new Content_Unit_Translation__c();
        cut.Language__c=tg5.id;
        cut.Text__c = 'Test Content Unit';
        cut.RichText__c = 'Rich Test Content Unit';
        cut.Image_Url__c = 'https://google.com';
        cut.Content_Unit__c = cu.Id;
        insert cut;

        Id storyRecType = Schema.SObjectType.Success_Story__c.getRecordTypeInfosByName().get('Success Story').getRecordTypeId();
        Id storyTranslationRecType = Schema.SObjectType.Success_Story__c.getRecordTypeInfosByName().get('Success Story Translation').getRecordTypeId();

        Success_Story__c story1 = new Success_Story__c();
        story1.Name = 'Test1';
        story1.RecordTypeId = storyRecType;
        story1.Image_Gallery__c = cu.Id;
        insert story1;
        
        Success_Story__c story2 = new Success_Story__c();
        story2.Name = 'Test1';
        story2.RecordTypeId = storyTranslationRecType;
        story2.Parent_Success_Story__c = story1.Id;
        story2.Language__c = tg4.Id;
        insert story2;   
        
        Tag_Success_Story__c tgs1 = new Tag_Success_Story__c();
        tgs1.Tag__c = tg2.Id;
        tgs1.Success_Story__c = story1.Id;
        insert tgs1;

        List <DenormalizedSuccessStory> denormalizedSuccessStories = new MallDataServiceHandler().getSuccessStoriesByCountryNames(countries);
        String whereClause = ' ID != NULL ';
        List<Tag_Success_Story__c> tagSuccessStories =  SEL_TagSuccessStories.newInstance().selectByCustomFilterCondition(whereClause);

        MallSuccessStoriesCtrl.SuccessStoriesTranslation sst = new MallSuccessStoriesCtrl.SuccessStoriesTranslation();
        Map<String, List<Content_Unit_Translation__c>> imageGalleryMap = new Map<String, List<Content_Unit_Translation__c>>();
        imageGalleryMap.put(cut.Id, new List<Content_Unit_Translation__c>{cut});
        sst.imageGalleryMap = imageGalleryMap;
        Map<Id,Success_Story__c> translatedContentMap = new Map<Id,Success_Story__c>();
        translatedContentMap.put(story2.Id, story2);
        sst.translatedContentMap = translatedContentMap;
        
        List<DenormalizedSuccessStory> ss = new MallSuccessStoriesCtrl().denormalizeSuccessStory(tagSuccessStories,sst);
        Assert.areNotEqual(denormalizedSuccessStories, null, 'should not be null');
        Assert.areNotEqual(ss, null, 'should not be null');
    }
    
    @isTest
    public static void getSuccessStoriesByCountryNamesTest2() {

        List <String> countries = new List <String> ();
        countries.add('India');
        countries.add('Angala');
        countries.add('South Africe');

        Tag__c tg1 = new Tag__c();
        tg1.Position__c = 1;
        tg1.Name = 'Country';

        Insert tg1;

        Tag__c tg2 = new Tag__c();
        tg2.Position__c = 3;
        tg2.Name = 'South Africe';
        tg2.Parent__c = tg1.id;
        Insert tg2;
        
        Tag__c tg3 = new Tag__c();
        tg3.Position__c = 1;
        tg3.Name = 'Language';

        Insert tg3;

        Tag__c tg4 = new Tag__c();
        tg4.Position__c = 3;
        tg4.Name = 'pt-AO';
        tg4.Parent__c = tg3.id;
        tg4.Root__c = tg3.Id;
        Insert tg4;

        Tag__c tg5 = new Tag__c();
        tg5.Position__c = 2;
        tg5.Name = 'en';
        tg5.Parent__c = tg3.id;
        tg5.Root__c = tg3.Id;
        Insert tg5;  
        
        Content_Unit__c cu = new Content_Unit__c();
        cu.HasImage__c = true;
        insert cu;
        
        Content_Unit_Translation__c cut= new Content_Unit_Translation__c();
        cut.Language__c=tg5.id;
        cut.Text__c = 'Test Content Unit';
        cut.RichText__c = 'Rich Test Content Unit';
        cut.Image_Url__c = 'https://google.com';
        cut.Content_Unit__c = cu.Id;
        insert cut;

        Id storyRecType = Schema.SObjectType.Success_Story__c.getRecordTypeInfosByName().get('Success Story').getRecordTypeId();
        Id storyTranslationRecType = Schema.SObjectType.Success_Story__c.getRecordTypeInfosByName().get('Success Story Translation').getRecordTypeId();

        Success_Story__c story1 = new Success_Story__c();
        story1.Name = 'Test1';
        story1.RecordTypeId = storyRecType;
        story1.Image_Gallery__c = cu.Id;
        insert story1;
        
        Success_Story__c story2 = new Success_Story__c();
        story2.Name = 'Test1';
        story2.RecordTypeId = storyTranslationRecType;
        story2.Parent_Success_Story__c = story1.Id;
        story2.Language__c = tg4.Id;
        insert story2;   
        
        Tag_Success_Story__c tgs1 = new Tag_Success_Story__c();
        tgs1.Tag__c = tg2.Id;
        tgs1.Success_Story__c = story1.Id;
        insert tgs1;

        String whereClause = ' ID != NULL ';
        List<Tag_Success_Story__c> tagSuccessStories = SEL_TagSuccessStories.newInstance().selectByCustomFilterCondition(whereClause);
        Assert.areNotEqual(tagSuccessStories, null, 'should not be null');
        MallSuccessStoriesCtrl.SuccessStoriesTranslation sst = new MallSuccessStoriesCtrl.SuccessStoriesTranslation();
        Map<String, List<Content_Unit_Translation__c>> imageGalleryMap = new Map<String, List<Content_Unit_Translation__c>>();
        imageGalleryMap.put(cut.Id, new List<Content_Unit_Translation__c>{cut});
        sst.imageGalleryMap = imageGalleryMap;
        Map<Id,Success_Story__c> translatedContentMap = new Map<Id,Success_Story__c>();
        translatedContentMap.put(story1.Id, story2);
        sst.translatedContentMap = translatedContentMap;
        List<DenormalizedSuccessStory> ss = new MallSuccessStoriesCtrl().denormalizeSuccessStory(new List<Tag_Success_Story__c>{tgs1},sst);
        Assert.areNotEqual(ss, null, 'should not be null');
    }

    @isTest
    public static void getSuccessStoriesByIdsTest() {
        List <String> successStoryIds = new List <String> ();
        test.startTest();
        List <DenormalizedSuccessStory> denormalizedSuccessStories = new MallDataServiceHandler().getSuccessStoriesByIds(successStoryIds);
        Assert.areNotEqual(denormalizedSuccessStories, null, 'should not be null');
        test.stopTest();
    }
}