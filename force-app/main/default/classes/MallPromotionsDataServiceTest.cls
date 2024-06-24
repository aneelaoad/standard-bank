/**
 * 
 * @description Test Class for MallPromotionsDataService
 * @author Ankit Kumar  
 * @since 
 */
@isTest
private with sharing class MallPromotionsDataServiceTest {
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
        tg2.Parent__c = tagSeg.Id;
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

        Provider__c acc= new Provider__c();
        acc.Name='test1';
        insert acc;

        List<Tag_Provider__c> tagShoplist= new List<Tag_Provider__c>();
        Tag_Provider__c tgshop = new Tag_Provider__c();
        tgshop.Provider__c=acc.id;
        tgshop.Tag__c=tg1.id;
        tagShoplist.add(tgshop);

        Tag_Provider__c tgshop1 = new Tag_Provider__c();
        tgshop1.Provider__c=acc.id;
        tgshop1.Tag__c=tg2.id;

        Tag_Provider__c tgshop2 = new Tag_Provider__c();
        tgshop2.Provider__c=acc.id;
        tgshop2.Tag__c=tgCountrySA.id;

        tagShoplist.add(tgshop2);
        insert tagShoplist;
    
        Promotion__c promotion1= new Promotion__c();
        promotion1.Name='Test1';
        promotion1.Provider__c=acc.id;
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

    /**
     * 
     * @description This method queries all the Promotions by tag Country
     */
    @Istest
    static void getPromotionsByCountryNamesTest(){
        Publishing_Unit__c publishingUnit = new Publishing_Unit__c();
        publishingUnit.isPublished__c = true;
        publishingUnit.Published_from__c = Date.newInstance(2022, 2, 2);
        publishingUnit.Published_until__c = Date.newInstance(2023, 2, 4);
        insert publishingUnit;

        List<String> countryList=new List<String>();
        Tag__c tg1 = new Tag__c();
        tg1.Position__c = 1;
        tg1.Name='South Africa';
        insert tg1;
        
        Promotion__c promotion1 = new Promotion__c();
        promotion1.Publishing_Unit__c = [Select Id from Publishing_Unit__c where isOnline__c = true LIMIT 1].Id;
        promotion1.Name='South Africa';
        insert promotion1;

        Tag_Promotion__c tagPromotion1 = new Tag_Promotion__c();
        tagPromotion1.Tag__c = tg1.Id;
        tagPromotion1.Promotion__c = promotion1.Id;
        insert tagPromotion1;

        Tag__c tg2 = new Tag__c();
        tg2.Position__c = 2;
        tg2.Name='Angola';
        insert tg2; 

        Promotion__c promotion2 = new Promotion__c();
        promotion2.Name='Angola';
        insert promotion2;

        promotion2.Publishing_Unit__c = publishingUnit.Id;
        update promotion2;

        Tag_promotion__c tagpromotion2 = new Tag_promotion__c();
        tagpromotion2.Tag__c = tg2.Id;
        tagpromotion2.promotion__c = promotion2.Id;
        insert tagpromotion2;

        Tag__c tg3 = new Tag__c();
        tg3.Position__c = 3;
        tg3.Name='USA';
        insert tg3; 

        promotion__c promotion3 = new promotion__c();
        promotion3.Publishing_Unit__c = publishingUnit.Id;
        promotion3.Name='USA';
        insert promotion3;

        Tag_promotion__c tagpromotion3 = new Tag_promotion__c();
        tagpromotion3.Tag__c = tg3.Id;
        tagpromotion3.promotion__c = promotion3.Id;
        insert tagpromotion3;
        
        countryList.add(promotion1.name);
        countryList.add(promotion2.name);   
        countryList.add(promotion3.name);
        
        Test.startTest();
        MallPromotionsDataService mallPromotionsDataService=new MallPromotionsDataService();
        List<DenormalizedPromotion> promotions =  mallPromotionsDataService.getPromotionsByCountryNames(countryList);
        Assert.areEqual(2, promotions.size(), '2 prmotions configured');
        Test.stopTest();
    }

    /**
     * 
     * @description Test get promotions by Segment and Category
     */
    @IsTest
    static void getpromotionsBySegmentAndCategoryIdsTest(){
        try{
            Provider__c acc= new Provider__c();
            acc.Name='test1' + System.Now();
            
            insert acc;

            Publishing_Unit__c publishingUnit = new Publishing_Unit__c();
            publishingUnit.IsPublished__c = true;
            publishingUnit.Published_from__c = Date.newInstance(System.now().Year()-1, 2, 2);
            publishingUnit.Published_until__c = Date.newInstance(System.now().Year()+1, 2, 4);
            insert publishingUnit;

            List<String> segmentIds= new List<String>();
            List<String> categoryIds=new List<String>();
            Tag__c tag = new Tag__c();
            tag.Position__c=1;
            tag.Name='Category';
            insert tag;
            
            Tag__c tg1 = new Tag__c();
            tg1.Position__c=1;
            tg1.Root__c = tag.Id;
            tg1.Name='Finance';
            Insert tg1;

            Tag__c tagSeg = new Tag__c();
            tagSeg.Position__c=1;
            tagSeg.Name='Segment';
            insert tagSeg;
            
            Tag__c tg2 = new Tag__c();
            tg2.Position__c=1;
            tg2.Root__c = tagSeg.Id;
            tg2.Name='Individual';
            Insert tg2;
            
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
            
            Tag_Provider__c tgshop = new Tag_Provider__c();
            tgshop.Provider__c=acc.id;
            tgshop.Tag__c=tg1.id;
            insert tgshop;
            
            promotion__c promotion1= new promotion__c();
            promotion1.Name='Test1';
            promotion1.Provider__c=acc.id;
            insert promotion1;

            promotion__c promotion2= new promotion__c();
            promotion2.Name='Test2';
            promotion2.Provider__c=acc.id;
            insert promotion2;

            Tag_promotion__c tagp= new Tag_promotion__c();
            tagp.promotion__c=promotion2.id;
            tagp.Tag__c=tg1.id;
            insert tagp;

            Tag_promotion__c tagp1= new Tag_promotion__c();
            tagp1.promotion__c=promotion2.id;
            tagp1.Tag__c=tg2.id;
            insert tagp1;
            
            Tag_promotion__c tagp2= new Tag_promotion__c();
            tagp2.promotion__c=promotion2.id;
            tagp2.Tag__c=tgCountrySA.id;
            insert tagp2;

            segmentIds.add(tg2.id);
            categoryIds.add(tg1.id);            
            
            promotion2.Publishing_Unit__c  = publishingUnit.Id;
            update promotion2;

            Test.startTest();
            MallPromotionsDataService mallPromotionsDataService = new MallPromotionsDataService();
            List<DenormalizedPromotion> promotions =  mallPromotionsDataService.getpromotionsBySegmentAndCategoryIds(segmentIds,categoryIds);
            Assert.areNotEqual(NULL, promotions, 'not null');
            Test.stopTest();
        } catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        } 
    }
}