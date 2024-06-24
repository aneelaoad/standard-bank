/**
 * 
 * @description Test Class for MallPromotionsDataServiceHelper
 * @author Ankit Kumar
 * @since 
 */
@isTest
private with sharing class MallPromotionsDataServiceHelperTest {

    @testSetup static void setup() {
        List<Tag_promotion__c> tagpromotionlist= new List<Tag_promotion__c>();       
        
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
        tg2.Name='Individual';
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

        Provider__c provider = new Provider__c();
        provider.Name='provider test';
        insert provider;
        
        List<Tag_Provider__c> shoplist= new List<Tag_Provider__c>();
        
        Tag_Provider__c tgshop = new Tag_Provider__c();
        tgshop.Provider__c=provider.id;
        tgshop.Tag__c=tg1.id;
        shoplist.add(tgshop);

        Tag_Provider__c tgshop1 = new Tag_Provider__c();
        tgshop1.Provider__c=provider.id;
        tgshop1.Tag__c=tg2.id;

        Tag_Provider__c tgshop2 = new Tag_Provider__c();
    	tgshop2.Provider__c=provider.id;
        tgshop2.Tag__c=tgCountrySA.id;

        shoplist.add(tgshop2);
        insert shoplist;
    
        Promotion__c promotion1= new Promotion__c();
        promotion1.Name='Test1';
     	promotion1.Provider__c=provider.id;
        promotion1.Publishing_Unit__c=pu.id;
        insert promotion1;

        Tag_promotion__c tagp= new Tag_promotion__c();
        tagp.promotion__c=promotion1.id;
        tagp.Tag__c=tg1.id;
        tagpromotionlist.add(tagp);

        Tag_promotion__c tagp1= new Tag_promotion__c();
        tagp1.promotion__c=promotion1.id;
        tagp1.Tag__c=tg2.id;
        tagpromotionlist.add(tagp1);

        Tag_promotion__c tagp2= new Tag_promotion__c();
        tagp2.promotion__c=promotion1.id;
        tagp2.Tag__c=tgCountrySA.id;
        tagpromotionlist.add(tagp2);

        insert tagpromotionlist;

        Promotion_Translation__c pt= new Promotion_Translation__c();
        pt.promotion__c = promotion1.id;
        pt.Language__c = tgEn.id;
        pt.Button_Label__c = 'Label';
        pt.Button_Title__c = 'Title';
        pt.Small_Title__c = 'Small Title';
        pt.Large_Title__c = 'Large Title';
        pt.SubText__c = 'SubText';
        insert pt;
    }


    @isTest
    static void preparePromotionsForLanguageTest(){       
        List<Tag_promotion__c> tagpromotionlist = [Select Id, Promotion__c, Tag__r.Name, Tag__r.Parent_Name__c FROM Tag_Promotion__c];
        Test.startTest();
        MallPromotionsDataServiceHelper mallPromotionsDataServiceHelper =new MallPromotionsDataServiceHelper();
        mallPromotionsDataServiceHelper.preparePromotionsForCountry(tagpromotionlist);
        Map<Id,Promotion_Translation__c> promotions = mallPromotionsDataServiceHelper.preParepromotionsForLanguage(tagpromotionlist);
        Assert.areEqual(1, promotions.values().size(), '1 translation');
        Test.stopTest();
    }
}