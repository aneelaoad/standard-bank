/**
 * 
 * @description Test Class for MallDataServiceHelper
 * @author Maham Hasan
 * @since 
 */

@isTest
public class MallDataServiceHelperTest {

    /**
     * 
     * @description Test Denormalized Shops
     * @exception AuraHandledException
     */
    @isTest
    static void denormalizeShopTest() {

        Map < Id, Content_Unit_Translation__c > mapContentIdAndContentTranslation = new Map < Id, Content_Unit_Translation__c > ();
        Map < Id, Content_Unit_Translation__c > mapShopIdAndContentTranslation = new Map < Id, Content_Unit_Translation__c > ();
        Map < Id, Content_Unit_Translation__c > mapProductIdAndContentTranslation = new Map < Id, Content_Unit_Translation__c > ();

        Link__c link = new Link__c();
        link.Desktop_url__c = 'www.google.com';
        link.Guest_url__c = 'www.google.com';
        link.Mobile_url__c = 'www.google.com';
        insert link;

        Provider__c provider = new Provider__c();
        provider.Name = 'test1';
        provider.Link__c = link.Id;
        insert provider;


        Publishing_Unit__c publishingUnit = new Publishing_Unit__c();
        publishingUnit.IsPreview__c = true;
        publishingUnit.Published_from__c = Date.newInstance(2022, 2, 2);
        publishingUnit.Published_until__c = Date.newInstance(2023, 2, 4);
        insert publishingUnit;


        Offering__c prodp = new Offering__c();
        prodp.Name = 'Test1';
        prodp.Provider__c = provider.id;

        insert prodp;



        Offering__c prod = new Offering__c();
        prod.Name = 'Test1';
        prod.Provider__c = provider.id;
        prod.is_a_Standard_Bank_Product__c = true;

        prod.Link__c = link.id;
        insert prod;

        Tag__c tg1 = new Tag__c();
        tg1.Position__c = 1;
        tg1.Name = 'Language';


        Insert tg1;

        List < Tag_Provider__c > shoplist = new List < Tag_Provider__c > ();
        Tag_Provider__c tgshop = new Tag_Provider__c();

        tgshop.Provider__c = provider.id;
        tgshop.Tag__c = tg1.id;

        insert tgshop;
        shoplist.add(tgshop);
        Tag_Provider__c tgshop1 = new Tag_Provider__c();

        tgshop1.Provider__c = provider.id;
        tgshop1.Tag__c = tg1.id;

        insert tgshop1;
        shoplist.add(tgshop);

        List < Tag_Offering__c > tagproductlist = new List < Tag_Offering__c > ();

        Tag_Offering__c tagp = new Tag_Offering__c();
        tagp.Offering__c = prod.id;
        tagp.Tag__c = tg1.id;

        insert tagp;

        Tag__c tag2 = new Tag__c();
        tag2.Root__c = tg1.id;
        insert tag2;

        Content_Unit_Translation__c cut = new Content_Unit_Translation__c();

        cut.Language__c = tag2.id;
        cut.Provider__c = provider.id;
        cut.Tag__c = tg1.id;
        cut.Product__c = prod.id;
        cut.Text__c = 'Test Content Unit';
        cut.RichText__c = 'Rich Test Content Unit';
        cut.Image_Url__c = 'https://google.com';
        insert cut;
        mapContentIdAndContentTranslation.put(cut.id, cut);
        mapShopIdAndContentTranslation.put(provider.id, cut);
        mapProductIdAndContentTranslation.put(prod.id, cut);

        test.startTest();

        prod.Publishing_Unit__c = publishingUnit.id;
        update prod;

        provider.Publishing_Unit__c = publishingUnit.id;
        update provider;


        MallDataServiceHelper mds = new MallDataServiceHelper();
        tagproductlist = SEL_TagOfferings.newInstance().selectByCustomFilterCondition('ID != NULL');
        shoplist = SEL_TagProviders.newInstance().selectByCustomFilterCondition('ID != NULL');

        List < DenormalizedProduct > listDemproduct = mds.denormalizeProducts(tagproductlist, mapProductIdAndContentTranslation);
        mds.denormalizeShop(shoplist, mapContentIdAndContentTranslation, mapShopIdAndContentTranslation);
        Assert.areNotEqual(listDemproduct, null, 'should not be null');
        test.stopTest();


    }

    /**
     * 
     * @description Test prepare products for Language
     */
    @isTest
    static void prepareProductsForLanguagetest() {

        Provider__c provider = new Provider__c();
        provider.Name = 'test1';
        insert provider;

        Link__c link = new Link__c();
        link.Desktop_url__c = 'www.google.com';
        link.Guest_url__c = 'www.google.com';
        link.Mobile_url__c = 'www.google.com';
        insert link;

        Offering__c prodp = new Offering__c();
        prodp.Name = 'Test1';
        prodp.Provider__c = provider.id;
        prodp.Link__c = link.Id;

        insert prodp;

        Publishing_Unit__c pu = new Publishing_Unit__c();
        pu.Published_from__c = system.today();
        pu.Published_until__c = system.today() + 2;
        insert pu;

        Offering__c prod = new Offering__c();
        prod.Name = 'Test1';
        prod.Provider__c = provider.id;
        prod.is_a_Standard_Bank_Product__c = true;
        prod.Publishing_Unit__c = pu.id;
        prod.Link__c = link.Id;
        insert prod;

        Tag__c tg1 = new Tag__c();
        tg1.Position__c = 1;
        tg1.Name = 'Language';

        Insert tg1;

        Tag__c tg2 = new Tag__c();
        tg2.Position__c = 1;
        tg2.Name = 'en';
        tg2.Root__c = tg1.Id;
        tg2.Parent__c = tg1.id;
        Insert tg2;

        List < Tag_Provider__c > shoplist = new List < Tag_Provider__c > ();
        Tag_Provider__c tgshop = new Tag_Provider__c();

        tgshop.Provider__c = provider.id;
        tgshop.Tag__c = tg1.id;

        insert tgshop;
        shoplist.add(tgshop);
        Tag_Provider__c tgshop1 = new Tag_Provider__c();

        tgshop1.Provider__c = provider.id;
        tgshop1.Tag__c = tg1.id;

        insert tgshop1;
        shoplist.add(tgshop);

        List < Tag_Offering__c > tagproductlist = new List < Tag_Offering__c > ();

        Tag_Offering__c tagp = new Tag_Offering__c();
        tagp.Offering__c = prod.id;
        tagp.Tag__c = tg1.id;

        insert tagp;
        tagproductlist.add(tagp);

        Tag__c newtagRecord = new Tag__c();
        newtagRecord.Name = 'test tag';
        newtagRecord.IsRoot_Tag__c = false;

        insert newtagRecord;

        assert.areEqual('test tag', newtagRecord.Name, 'message');
        Content_Unit_Translation__c cut = new Content_Unit_Translation__c();
        cut.Product__c = prod.id;
        cut.Language__c = tg2.id;
        insert cut;

        Test.startTest();
        MallDataServiceHelper mds = new MallDataServiceHelper();
        Map < String, Map < Id, Content_Unit_Translation__c >> maplist = mds.prepareProductsForLanguage(tagproductlist);
        Assert.areNotEqual(maplist, null, 'should not be null');
        Test.stopTest();

    }

    /**
     * 
     * @description test prepare shops for Language
     */
    @isTest
    static void prepareShopsForLanguageTest() {

        Provider__c provider = new Provider__c();
        provider.Name = 'test1';
        insert provider;

        Offering__c prodp = new Offering__c();
        prodp.Name = 'Test1';
        prodp.Provider__c = provider.id;

        insert prodp;
        assert.areEqual('Test1', prodp.Name, 'message');
        Publishing_Unit__c pu = new Publishing_Unit__c();
        pu.Published_from__c = system.today();
        pu.Published_until__c = system.today() + 2;
        insert pu;


        Tag__c tg1 = new Tag__c();
        tg1.Position__c = 1;
        tg1.Name = 'Language';

        Insert tg1;

        Tag__c tg2 = new Tag__c();
        tg2.Position__c = 1;
        tg2.Name = 'en';
        tg2.Root__c = tg1.Id;
        tg2.Parent__c = tg1.id;
        Insert tg2;
        Assert.areEqual('en', tg2.Name, 'should be equal');
        List < Tag_Provider__c > shoplist = new List < Tag_Provider__c > ();
        Tag_Provider__c tgshop = new Tag_Provider__c();

        tgshop.Provider__c = provider.id;
        tgshop.Tag__c = tg1.id;

        insert tgshop;
        shoplist.add(tgshop);
        Tag_Provider__c tgshop1 = new Tag_Provider__c();

        tgshop1.Provider__c = provider.id;
        tgshop1.Tag__c = tg1.id;

        insert tgshop1;
        shoplist.add(tgshop);

        List < Tag_Provider__c > tagShopList = new List < Tag_Provider__c > ();

        Tag_Provider__c tags = new Tag_Provider__c();
        tags.Provider__c = provider.id;
        tags.Tag__c = tg1.id;

        insert tags;
        tagShopList.add(tags);

        Tag__c newtagRecord = new Tag__c();
        newtagRecord.Name = 'test tag';
        newtagRecord.IsRoot_Tag__c = false;

        insert newtagRecord;

        Content_Unit_Translation__c cut = new Content_Unit_Translation__c();
        cut.Provider__c = provider.id;
        cut.Language__c = tg2.id;
        insert cut;

        test.startTest();
        MallDataServiceHelper mds = new MallDataServiceHelper();
        Map < String, Map < Id, Content_Unit_Translation__c >> cuunit = mds.prepareShopsForLanguage(tagShopList);
        Assert.areNotEqual(cuunit, null, 'should not be null');
        test.stopTest();
    }

    /**
     * 
     * @description test denormalized Links
     */
    @isTest
    static void testDenormalizedLinks() {
        List < Link__c > links = new List < Link__c > ();
        List < DenormalizedLink > denormalizedLinks = new List < DenormalizedLink > ();
        Link__c link = new Link__c();
        link.Desktop_url__c = 'www.google.com';
        link.Guest_url__c = 'www.google.com';
        link.Mobile_url__c = 'www.google.com';


        links.add(link);
        MallDataServiceHelper mallServiceHelper = new MallDataServiceHelper();
        denormalizedLinks = mallServiceHelper.denormalizeLink(links);

        Assert.areEqual(link.Guest_url__c, denormalizedLinks.get(0).guestUrl, 'should be equal');
    }

    @istest
    static void testPrepareProductsForCountry() {

        Publishing_Unit__c publishingUnit = new Publishing_Unit__c();
        publishingUnit.isPublished__c = true;
        publishingUnit.Published_from__c = system.today();
        publishingUnit.Published_until__c = system.today() + 2;
        insert publishingUnit;

        Tag__c tag = new Tag__c();
        tag.Name = 'Category';
        tag.Publishing_Unit__c = publishingUnit.Id;
        insert tag;
        Assert.areEqual('Category', tag.Name, 'should be equal');
        Tag__c secondaryTag = new Tag__c();
        secondaryTag.Name = 'South Africa';
        secondaryTag.Publishing_Unit__c = publishingUnit.Id;
        secondaryTag.Parent__c = tag.Id;
        insert secondaryTag;

        Assert.areEqual('South Africa', secondaryTag.Name, 'should be equal');
        Offering__c product = new Offering__c();
        product.Name = 'Test Product';
        product.is_a_Standard_Bank_Product__c = true;
        insert product;
        Assert.areEqual('Test Product', product.Name, 'should be equal');
        product.Publishing_Unit__c = publishingUnit.id;
        update product;


        Tag_Offering__c productTag = new Tag_Offering__c();
        productTag.Offering__c = product.Id;
        productTag.Tag__c = secondaryTag.Id;
        insert productTag;

        MallDataServiceHandler.userCountry = 'South Africa';

        String whereClause = ' Offering__r.Name= \'Test Product\'';
        whereClause += ' OR Tag__r.Name =\'South Africa\'';
        List < Tag_Offering__c > tagProducts = SEL_TagOfferings.newInstance().selectByCustomFilterCondition(whereClause);


        MallDataServiceHelper mallServiceHelper = new MallDataServiceHelper();
        List < Tag_Offering__c > countryProducts = mallServiceHelper.prepareProductsForCountry(tagProducts);

        Assert.areEqual('Test Product', countryProducts.get(0).Offering__r.Name, 'should be equal');
    }

    /**
     * 
     * @description Test prepare shops
     */
    @istest
    static void testPrepareShopsForCountry() {

        Publishing_Unit__c publishingUnit = new Publishing_Unit__c();
        publishingUnit.isPublished__c = true;
        publishingUnit.Published_from__c = system.today();
        publishingUnit.Published_until__c = system.today() + 2;
        insert publishingUnit;

        Tag__c tag = new Tag__c();
        tag.Name = 'Category';
        tag.Publishing_Unit__c = publishingUnit.Id;
        insert tag;
        Assert.areEqual('Category', tag.Name, 'should be equal');
        Tag__c secondaryTag = new Tag__c();
        secondaryTag.Name = 'South Africa';
        secondaryTag.Publishing_Unit__c = publishingUnit.Id;
        secondaryTag.Parent__c = tag.Id;
        insert secondaryTag;

        Provider__c provider = new Provider__c();
        provider.Name = 'Test Provider';
        insert provider;

        provider.Publishing_Unit__c = publishingUnit.Id;
        update provider;


        Tag_Provider__c shopTag = new Tag_Provider__c();
        shopTag.Provider__c = provider.Id;
        shopTag.Tag__c = secondaryTag.Id;
        insert shopTag;

        Tag__c newTag = new Tag__c();
        newTag.Name = 'Angola';
        newTag.Publishing_Unit__c = publishingUnit.Id;
        newTag.Parent__c = tag.Id;
        insert newTag;

        Tag_Provider__c shopTag2 = new Tag_Provider__c();
        shopTag2.Provider__c = provider.Id;
        shopTag2.Tag__c = newTag.Id;
        insert shopTag2;



        MallDataServiceHandler.userCountry = 'South Africa';

        String whereClause = ' Provider__r.Name= \'Test Provider\'';
        whereClause += ' OR Tag__r.Name =\'South Africa\'';
        List < Tag_Provider__c > tagShops = SEL_TagProviders.newInstance().selectByCustomFilterCondition(whereClause);

        MallDataServiceHelper mallServiceHelper = new MallDataServiceHelper();
        List < Tag_Provider__c > countryShops = mallServiceHelper.prepareShopsForCountry(tagShops);

        Assert.areEqual('Test Provider', countryShops.get(0).Provider__r.Name, 'should be equal');

    }

    /**
     * 
     * @description Test prepare tags for language
     */
    @isTest
    static void testPrepareTagsForLanguage() {
        Publishing_Unit__c publishingUnit = new Publishing_Unit__c();
        publishingUnit.isPublished__c = true;
        publishingUnit.Published_from__c = system.today();
        publishingUnit.Published_until__c = system.today() + 2;
        insert publishingUnit;

        Content_Unit__c contentUnit = new Content_Unit__c();
        contentUnit.hasImage__c = true;
        contentUnit.hasText__c = true;
        insert contentUnit;


        Tag__c tag = new Tag__c();
        tag.Name = 'Category';
        tag.Tag_Icon__c = contentUnit.Id;
        tag.Publishing_Unit__c = publishingUnit.Id;
        insert tag;

        List <Tag__c> tagsLst = SEL_Tags.newInstance().selectTagsByIds(new Set<Id>{tag.Id});
        MallDataServiceHelper mallServiceHelper = new MallDataServiceHelper();
        Map < String, Map < Id, Content_Unit_Translation__c >> mapContentTypMapContentUnitTranslation = mallServiceHelper.prepareTagsForLanguage(tagsLst);
        List<DenormalizedTag> denormalizedTags = MallServiceHelper.denormalizeTags(tagsLst, mapContentTypMapContentUnitTranslation.get(MallDataServiceHandler.ICON_CONTENT_UNIT_TRANSLATION), mapContentTypMapContentUnitTranslation.get(MallDataServiceHandler.CONTENT_UNIT_TRANSLATION));
        Assert.isTrue(denormalizedTags.size() > 0, 'should not be 0');
    }
}