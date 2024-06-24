/**
 * 
 * @description Test Class for Mall Data Service
 * @author Maham Hasan
 * @since   
 */
@IsTest
public class MallDataServiceTest {

    /**
     * 
     * @description getActiveRootTagsTest
     */
    @istest
    static void getActiveRootTagsTest() {
        Test.startTest();
        List < DenormalizedTag > denormalizedTagList = MallDataService.getActiveRootTags();
        Assert.areNotEqual(denormalizedTagList, null, 'should not be null');
        Test.stopTest();
    }

    /**
     * 
     * @description This method queries all the Tags for Category tree
     */
    @istest
    static void getActiveRootCategoriesTest() {
        Test.startTest();
        List < DenormalizedTag > denormalizedTagList = MallDataService.getActiveRootCategories();
        Assert.areNotEqual(denormalizedTagList, null, 'should not be null');
        Test.stopTest();
    }

    /**
     * 
     * @description This method queries all the Tags from Segment Tree
     */
    @istest
    static void getSegmentTagsTest() {
        Test.startTest();
        List < DenormalizedTag > denormalizedTagList = MallDataService.getSegmentTags();
        Assert.areNotEqual(denormalizedTagList, null, 'should not be null');
        Test.stopTest();
    }

    /**
     * 
     * @description Get Child Tags Based on Parent Tag Ids
     */
    @istest
    static void getChildTagsByParentIdTest() {

        List < String > taglist = new List < String > ();

        Tag__c tg1 = new Tag__c();
        tg1.Position__c = 1;
        tg1.Name = 'Country';
        Insert tg1;

        Tag__c tg2 = new Tag__c();
        tg2.Position__c = 3;
        tg2.Name = 'Language';
        tg2.Parent__c = tg1.id;
        Insert tg2;

        taglist.add(tg2.id);

        Tag__c tg3 = new Tag__c();
        tg3.Position__c = 5;
        tg3.Name = 'Related';
        tg3.Parent__c = tg1.id;
        Insert tg3;

        taglist.add(tg3.id);

        Test.startTest();
        List < DenormalizedTag > denormalizedTagList = MallDataService.getChildTagsByParentId(taglist);
        List < DenormalizedProduct > denormalizedProductList = MallDataService.getProductsByTagIds(taglist);
        Assert.areNotEqual(denormalizedTagList, null, 'should not be null');
        Assert.areNotEqual(denormalizedProductList, null, 'should not be null');
        Test.stopTest();

    }

    /**
     * 
     * @description Test Parent Names by Child Tags
     */
    @istest
    static void getChildTagsByParentNameTest() {

        List < String > taglist = new List < String > ();

        Tag__c tg1 = new Tag__c();
        tg1.Position__c = 1;
        tg1.Name = 'Country';
        Insert tg1;

        taglist.add(tg1.Name);

        Tag__c tg2 = new Tag__c();
        tg2.Position__c = 3;
        tg2.Name = 'Language';
        Insert tg2;

        taglist.add(tg2.Name);

        Tag__c tg3 = new Tag__c();
        tg3.Position__c = 5;
        tg3.Name = 'Related';
        Insert tg3;

        taglist.add(tg3.Name);

        Test.startTest();
        List < DenormalizedTag > denormalizedTagList = MallDataService.getChildTagsByParentName(taglist);
        List < DenormalizedTag > denormalizedTagNameList = MallDataService.getTagsByNames(taglist);
        List < DenormalizedProduct > denormalizedProductList = MallDataService.getProductsByTagNames(taglist);
        Assert.areNotEqual(denormalizedTagList, null, 'should not be null');
        Assert.areNotEqual(denormalizedTagNameList, null, 'should not be null');
        Assert.areNotEqual(denormalizedProductList, null, 'should not be null');
        Test.stopTest();
    }

    /**
     * 
     * @description Get Tags Based on Parent Tag Ids
     */
    @istest
    static void getTagsByIdsTest() {

        List < String > taglist = new List < String > ();

        Tag__c tg1 = new Tag__c();
        tg1.Position__c = 1;
        tg1.Name = 'Country';
        Insert tg1;

        Tag__c tg2 = new Tag__c();
        tg2.Position__c = 3;
        tg2.Name = 'Language';
        tg2.Parent__c = tg1.id;
        Insert tg2;

        taglist.add(tg2.Parent__c);

        Tag__c tg3 = new Tag__c();
        tg3.Position__c = 5;
        tg3.Name = 'Related';
        tg3.Parent__c = tg1.id;
        Insert tg3;

        taglist.add(tg3.Parent__c);

        Test.startTest();
        List < DenormalizedTag > denormalizedTagList = MallDataService.getTagsByIds(taglist);
        List < DenormalizedProduct > denormalizedProductList = MallDataService.getProductsByParentTagIds(taglist);
        Assert.areNotEqual(denormalizedTagList, null, 'should not be null');
        Assert.areNotEqual(denormalizedProductList, null, 'should not be null');
        Test.stopTest();
    }

    /**
     * 
     * @description get Products By  Country
     */
    @istest
    static void getProductsByCountryNamesTest() {

        List < String > taglist = new List < String > ();

        Tag__c tg1 = new Tag__c();
        tg1.Position__c = 1;
        tg1.Name = 'Country';
        Insert tg1;

        Tag__c tg2 = new Tag__c();
        tg2.Position__c = 3;
        tg2.Name = 'Language';
        tg2.Parent__c = tg1.id;
        Insert tg2;

        taglist.add(tg2.id);

        Tag__c tg3 = new Tag__c();
        tg3.Position__c = 5;
        tg3.Name = 'Related';
        tg3.Parent__c = tg1.id;
        Insert tg3;

        taglist.add(tg3.id);

        Test.startTest();
        List < DenormalizedTag > denormalizedTagList = MallDataService.getChildTagsByParentId(taglist);
        List < DenormalizedProduct > denormalizedProductList = MallDataService.getProductsByTagIds(taglist);
        List < DenormalizedShop > denormalizedShopList = MallDataService.getShopsByParentTagIds(taglist);
        Assert.areNotEqual(denormalizedTagList, null, 'should not be null');
        Assert.areNotEqual(denormalizedProductList, null, 'should not be null');
        Assert.areNotEqual(denormalizedShopList, null, 'should not be null');
        Test.stopTest();

    }

    /**
     * 
     * @description get Shops By tagIds
     */
    @istest
    static void getShopsByTagIdsTest() {

        String searchString = 'Angola';

        List < String > taglist = new List < String > ();

        Tag__c tg1 = new Tag__c();
        tg1.Position__c = 1;
        tg1.Name = 'Country';
        Insert tg1;

        taglist.add(tg1.id);

        Tag__c tg2 = new Tag__c();
        tg2.Position__c = 3;
        tg2.Name = 'Language';
        Insert tg2;

        taglist.add(tg2.id);

        Tag__c tg3 = new Tag__c();
        tg3.Position__c = 5;
        tg3.Name = 'Related';
        Insert tg3;

        taglist.add(tg3.id);

        String mallContext = '{ "Id" : "00XXXXXXXXXXXXX", "StageName" : "Review", "AccountName" : "United Oil & Gas Corp." }';
        List < String > countries = new List < String > ();
        countries.add('Angola');
        countries.add('South Africa');
        countries.add('Uganda');

        Test.startTest();
        List < DenormalizedProduct > denormalizedProductList = MallDataService.getProductsByCountryNames(mallContext, countries);
        List < DenormalizedShop > denormalizedShopList = MallDataService.getShopsByTagIds(mallContext, taglist);
        List < DenormalizedShop > denormalizedAllShopList = MallDataService.getAllShops(mallContext);
        List < DenormalizedShop > denormalizedShopWhereList = MallDataService.getShopsWhereNameStartsWith(mallContext, searchString);
        Assert.areNotEqual(denormalizedProductList, null, 'should not be null');
        Assert.areNotEqual(denormalizedShopList, null, 'should not be null');
        Assert.areNotEqual(denormalizedAllShopList, null, 'should not be null');
        Assert.areNotEqual(denormalizedShopWhereList, null, 'should not be null');
        Test.stopTest();
    }

    /**
     * 
     * @description get Shops By tagIds
     */
    @istest
    static void getShopsBySegmentAndCategoryIdsTest() {

        String mallContext = '{ "Id" : "00XXXXXXXXXXXXX", "StageName" : "Review", "AccountName" : "United Oil & Gas Corp." }';

        Provider__c provider = new Provider__c();
        provider.Name = 'test1';
        insert provider;

        List < String > segmentIds = new List < String > ();
        List < String > categoryIds = new List < String > ();
        List < String > shopids = new List < String > ();

        Tag__c tg1 = new Tag__c();
        tg1.Position__c = 1;
        tg1.Name = 'Country';
        Insert tg1;

        Tag_Provider__c tgshop = new Tag_Provider__c();
        tgshop.Provider__c = provider.id;
        tgshop.Tag__c = tg1.id;
        insert tgshop;


        Offering__c prod = new Offering__c();
        prod.Name = 'Test1';
        prod.Provider__c = provider.id;
        insert prod;

        segmentIds.add(prod.id);
        categoryIds.add(prod.id);
        shopids.add(prod.Provider__c);

        Offering__c prod2 = new Offering__c();
        prod2.Name = 'Test1';
        prod2.Provider__c = provider.id;
        insert prod2;

        Tag_Offering__c tagp = new Tag_Offering__c();
        tagp.Offering__c = prod.id;
        tagp.Tag__c = tg1.id;
        insert tagp;

        segmentIds.add(prod2.id);
        categoryIds.add(prod2.id);

        Test.startTest();
        List < DenormalizedShop > denormalizedShopList = MallDataService.getShopsBySegmentAndCategoryIds(mallContext, segmentIds, categoryIds);
        List < DenormalizedProduct > denormalizedProductList = MallDataService.getProductsBySegmentAndCategoryIds(mallContext, segmentIds, categoryIds);
        List < DenormalizedPromotion > denormalizedProductList1 = MallDataService.getPromotionsBySegmentAndCategoryIds(mallContext, segmentIds, categoryIds);
        DenormalizedMallState denormalizedMallState = MallDataService.initialization(mallContext);
        List < DenormalizedTag > denormalizedtagList = MallDataService.getSegmentTagsByMallContext(mallContext);
        List < DenormalizedShop > denormalizedShopIdList = MallDataService.getShopsByIds(mallContext, shopids);
        Assert.areNotEqual(denormalizedShopList, null, 'should not be null');
        Assert.areNotEqual(denormalizedProductList, null, 'should not be null');
        Assert.areNotEqual(denormalizedMallState, null, 'should not be null');
        Assert.areNotEqual(denormalizedShopIdList, null, 'should not be null');
        Assert.areNotEqual(denormalizedProductList1, null, 'should not be null');
        Assert.areNotEqual(denormalizedtagList, null, 'should not be null');
        try {
            denormalizedShopList = MallDataService.getShopsBySegmentAndCategoryIds('invalidJSON', segmentIds, categoryIds);
        }catch(Exception e) {
            Assert.isTrue(e != NULL, 'Exception should not be null');
        }
        try {
            denormalizedProductList = MallDataService.getProductsBySegmentAndCategoryIds('invalidJSON', segmentIds, categoryIds);
        }catch(Exception e) {
            Assert.isTrue(e != NULL, 'Exception should not be null');
        }
        try {
            denormalizedProductList1 = MallDataService.getPromotionsBySegmentAndCategoryIds('invalidJSON', segmentIds, categoryIds);
        }catch(Exception e) {
            Assert.isTrue(e != NULL, 'Exception should not be null');
        }
        try {
            denormalizedMallState = MallDataService.initialization('invalidJSON');
        }catch(Exception e) {
            Assert.isTrue(e != NULL, 'Exception should not be null');
        }
        try {
           denormalizedtagList = MallDataService.getSegmentTagsByMallContext('invalidJSON');
        }catch(Exception e) {
            Assert.isTrue(e != NULL, 'Exception should not be null');
        }
        try {
            denormalizedShopIdList = MallDataService.getShopsByIds('invalidJSON', shopids);
        }catch(Exception e) {
             Assert.isTrue(e != NULL, 'Exception should not be null');
        }

        Test.stopTest();
    }

    /**
     * 
     * @description Test Refresh Mall State
     */
    @istest
    static void refreshMallStateTest() {
        Test.startTest();
        List < DenormalizedTag > segments = new List < DenormalizedTag > ();
        List < DenormalizedTag > selectedSegments = new List < DenormalizedTag > ();

        DenormalizedTag dt = new DenormalizedTag();
        dt.parentName = 'test';
        dt.name = 'test';
        dt.isRootTag = true;
        dt.isPublished = true;
        dt.parentName = 'test';
        segments.add(dt);
        selectedSegments.add(dt);
        DenormalizedMallState denormalizedMallState = MallDataService.refreshMallState(segments, selectedSegments);
        Assert.areNotEqual(denormalizedMallState, null, 'should not be null');
        Test.stopTest();
    }

    /**
     * 
     * @description test get Products by Shop Ids
     */
    @istest
    static void getProductsByShopIdsTest() {

        String mallContext = '{ "Id" : "00XXXXXXXXXXXXX", "StageName" : "Review", "AccountName" : "United Oil & Gas Corp." , "mallUserSelectedLanguage" : "en-US"}';

        Provider__c provider = new Provider__c();
        provider.Name = 'test1';
        insert provider;

        Offering__c prod = new Offering__c();
        prod.Name = 'Test1';
        prod.Provider__c = provider.id;
        insert prod;

        List < String > taglist = new List < String > ();

        Tag__c tg1 = new Tag__c();
        tg1.Position__c = 1;
        tg1.Name = 'Country';
        Insert tg1;

        taglist.add(prod.Provider__c);

        MallDataServiceHandler.userContentLanguage = 'en-US';

        Test.startTest();
        List < DenormalizedProduct > denormalizedProduct = MallDataService.getProductsByShopIds(mallContext, taglist);
        List < DenormalizedContent > knowledgeList = MallDataService.getLegalInfo(mallContext);

        Assert.areNotEqual(denormalizedProduct, null, 'should not be null');
        Assert.areNotEqual(knowledgeList, null, 'should not be null');
        try {
            denormalizedProduct = MallDataService.getProductsByShopIds('invalidJSON', taglist);
        }catch(Exception e) {
             Assert.isTrue(e != NULL, 'Exception should not be null');
        }
        try {
            knowledgeList = MallDataService.getLegalInfo('invalidJSON');
        }catch(Exception e) {
             Assert.isTrue(e != NULL, 'Exception should not be null');
        }
        Test.stopTest();
    }

    /**
     * 
     * @description test Get Product by Ids Test
     */
    @istest
    static void getProductsByIdsTest() {

        String mallContext = '{ "Id" : "00XXXXXXXXXXXXX", "StageName" : "Review", "AccountName" : "United Oil & Gas Corp." }';
        List < String > prodlist = new List < String > ();

        Offering__c prod = new Offering__c();
        prod.Name = 'Test1';
        insert prod;

        prodlist.add(prod.Id);

        Offering__c prod1 = new Offering__c();
        prod1.Name = 'Test2';
        insert prod1;

        prodlist.add(prod1.Id);

        Offering__c prod3 = new Offering__c();
        prod3.Name = 'Test2';
        insert prod3;

        prodlist.add(prod3.Id);

        Test.startTest();
        List < DenormalizedProduct > denormalizedProductList = MallDataService.getProductsByIds(mallContext, prodlist);
        Assert.areNotEqual(denormalizedProductList, null, 'should not be null');
        try {
            denormalizedProductList = MallDataService.getProductsByIds(mallContext, prodlist);
        }catch(Exception e) {
             Assert.isTrue(e != NULL, 'Exception should not be null');
        }
        Test.stopTest();

    }

    /**
     * 
     * @description test get Contact us email by country
     */
    @istest
    static void getContactUsEmailByCountryTest() {

        List < String > countries = new List < String > ();
        countries.add('India');
        countries.add('Angala');
        countries.add('USA');
        String countryName = 'South Africa';

        String email = MallDataService.getContactUsEmailByCountry(countryName);
        countryName = 'Mexico';
        List < DenormalizedShop > denormalizedShopList = MallDataService.getShopsByCountryNames(countries);
        Assert.areNotEqual(denormalizedShopList, null, 'should not be null');
        Assert.areNotEqual(email, null, 'should not be null');
        try {
            denormalizedShopList = MallDataService.getShopsByCountryNames(NULL);
        }catch(Exception e) {
             Assert.isTrue(e != NULL, 'Exception should not be null');
        }
    }

    /**
     * 
     * @description test get products by Ids
     */
    @istest
    static void getProductsByIdsTestexception() {

        String mallContext = 'test';
        List < String > prodlist = new List < String > ();

        Offering__c prod = new Offering__c();
        prod.Name = 'Test1';
        insert prod;

        prodlist.add(prod.Id);

        Offering__c prod1 = new Offering__c();
        prod1.Name = 'Test2';
        insert prod1;

        prodlist.add(prod1.Id);

        Offering__c prod3 = new Offering__c();
        prod3.Name = 'Test2';
        insert prod3;

        prodlist.add(prod3.Id);

        Test.startTest();
        String exceptionMessage;
        try {
            MallDataService.getProductsByIds(mallContext, prodlist);
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
        }
        Assert.areNotEqual(exceptionMessage, null, 'error expected');
        Test.stopTest();
    }

    /**
     * 
     * @description test get Products By Shop ids
     */
    @istest
    static void getProductsByShopIdsTestexception() {
        String mallContext = 'test';
        Test.startTest();
        String exceptionMessage;
        try {
            MallDataService.getLegalInfo(mallContext);
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
        }
        Assert.areNotEqual(exceptionMessage, null, 'should not be null');
        Test.stopTest();
    }

    /**
     * 
     * @description test get shop by Ids
     */
    @istest
    static void getShopsByIdsTestexception() {
        String mallContext = 'test';

        Provider__c provider = new Provider__c();
        provider.Name = 'test1';
        insert provider;

        Tag__c tg1 = new Tag__c();
        tg1.Position__c = 1;
        tg1.Name = 'Country';
        Insert tg1;

        Tag_Provider__c tgshop = new Tag_Provider__c();
        tgshop.Provider__c = provider.id;
        tgshop.Tag__c = tg1.id;

        insert tgshop;

        Offering__c prod = new Offering__c();
        prod.Name = 'Test1';
        prod.Provider__c = provider.id;
        insert prod;

        Offering__c prod2 = new Offering__c();
        prod2.Name = 'Test1';
        prod2.Provider__c = provider.id;
        insert prod2;

        Tag_Offering__c tagp = new Tag_Offering__c();
        tagp.Offering__c = prod.id;
        tagp.Tag__c = tg1.id;
        insert tagp;

        Test.startTest();
        String exceptionMessage;
        try {
            MallDataService.initialization(mallContext);
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
        }
        Assert.areNotEqual(exceptionMessage, null, 'should not be null');
        Test.stopTest();

    }

    /**
     * 
     * @description get Shop Ids
     */
    @istest
    static void getShopsByIdsTestexception1() {
        String mallContext = 'test';

        Provider__c provider = new Provider__c();
        provider.Name = 'test1';
        insert provider;

        List < String > shopids = new List < String > ();

        Tag__c tg1 = new Tag__c();
        tg1.Position__c = 1;
        tg1.Name = 'Country';
        Insert tg1;

        Tag_Provider__c tgshop = new Tag_Provider__c();
        tgshop.Provider__c = provider.id;
        tgshop.Tag__c = tg1.id;
        insert tgshop;

        Offering__c prod = new Offering__c();
        prod.Name = 'Test1';
        prod.Provider__c = provider.id;
        insert prod;

        shopids.add(prod.Provider__c);

        Offering__c prod2 = new Offering__c();
        prod2.Name = 'Test1';
        prod2.Provider__c = provider.id;
        insert prod2;

        Tag_Offering__c tagp = new Tag_Offering__c();
        tagp.Offering__c = prod.id;
        tagp.Tag__c = tg1.id;
        insert tagp;

        Test.startTest();
        String exceptionMessage;
        try {
            MallDataService.getShopsByIds(mallContext, shopids);
        } catch (Exception e) {
            exceptionMessage = e.getMessage();
        }
        Assert.areNotEqual(exceptionMessage, null, 'should not be null');
        Test.stopTest();

    }

    /**
     * 
     * @description test get Label tabs
     */
    @IsTest
    static void testgetOrdId() {

        Test.startTest();
        String orgId = MallDataService.getORGId();
        Assert.areNotEqual(orgId, null, 'should not be null');
        Test.stopTest();

    }
    @istest
    static void getShopsByCountryNamesWithContextTest() {

        List < String > countries = new List < String > ();
        countries.add('India');
        countries.add('Angala');
        countries.add('USA');
        countries.add('Mexico');
        String mallContext = '{ "Id" : "00XXXXXXXXXXXXX", "StageName" : "Review", "AccountName" : "United Oil & Gas Corp." }';

        List < DenormalizedShop > denormalizedShopList = MallDataService.getShopsByCountryNamesWithContext(mallContext, countries);
        Assert.areNotEqual(denormalizedShopList, null, 'should not be null');
        try {
            denormalizedShopList = MallDataService.getShopsByCountryNamesWithContext('mallContext', countries);
        }catch(Exception e) {
             Assert.isTrue(e != NULL, 'Exception should not be null');
        }
    }

    @isTest
    static void getEventsBySegmentAndCategoryIdsTest() {
        String mallContext = '{ "Id" : "00XXXXXXXXXXXXX", "StageName" : "Review", "AccountName" : "United Oil & Gas Corp." }';

        Provider__c provider = new Provider__c();
        provider.Name = 'test1';
        insert provider;

        List < String > segmentIds = new List < String > ();
        List < String > categoryIds = new List < String > ();
        List < String > shopids = new List < String > ();

        Tag__c tg1 = new Tag__c();
        tg1.Position__c = 1;
        tg1.Name = 'Country';
        Insert tg1;

        Tag_Provider__c tgshop = new Tag_Provider__c();
        tgshop.Provider__c = provider.id;
        tgshop.Tag__c = tg1.id;
        insert tgshop;


        Offering__c prod = new Offering__c();
        prod.Name = 'Test1';
        prod.Provider__c = provider.id;
        insert prod;

        segmentIds.add(prod.id);
        categoryIds.add(prod.id);
        shopids.add(prod.Provider__c);

        Offering__c prod2 = new Offering__c();
        prod2.Name = 'Test1';
        prod2.Provider__c = provider.id;
        insert prod2;

        Tag_Offering__c tagp = new Tag_Offering__c();
        tagp.Offering__c = prod.id;
        tagp.Tag__c = tg1.id;
        insert tagp;

        segmentIds.add(prod2.id);
        categoryIds.add(prod2.id);

        Test.startTest();
        List < DenormalizedEvent > denormalizedEventsList = MallDataService.getEventsBySegmentAndCategoryIds(mallContext, segmentIds, categoryIds);
        Assert.areNotEqual(denormalizedEventsList, null, 'should not be null');
        try {
            denormalizedEventsList = MallDataService.getEventsBySegmentAndCategoryIds(mallContext, segmentIds, categoryIds);
        }catch(Exception e) {
             Assert.isTrue(e != NULL, 'Exception should not be null');
        }
        Test.stopTest();
    }

    @isTest
    public static void initializationStoreTest() {
        String mallContext = '{ "Id" : "00XXXXXXXXXXXXX", "StageName" : "Review", "AccountName" : "United Oil & Gas Corp." }';
        Test.startTest();
        DenormalizedMallState denormalizedState = MallDataService.initializationStore(mallContext);
        Assert.areNotEqual(denormalizedState, null, 'should not be null');
        try {
            denormalizedState = MallDataService.initializationStore('mallContext');
        }catch(Exception e) {
             Assert.isTrue(e != NULL, 'Exception should not be null');
        }
        Test.stopTest();
    }


    @isTest
    public static void getSuccessStoriesByCountryNamesTest() {
        String mallContext = '{ "Id" : "00XXXXXXXXXXXXX", "StageName" : "Review", "AccountName" : "United Oil & Gas Corp." }';
        List < String > countries = new List < String > ();
        countries.add('India');
        countries.add('Angala');
        countries.add('USA');
        Test.startTest();
        List < DenormalizedSuccessStory > denormalizedSuccessStories = MallDataService.getSuccessStoriesByCountryNames(mallContext, countries);
        Assert.areNotEqual(denormalizedSuccessStories, null, 'should not be null');
        try {
            denormalizedSuccessStories = MallDataService.getSuccessStoriesByCountryNames('mallContext', countries);
        }catch(Exception e) {
             Assert.isTrue(e != NULL, 'Exception should not be null');
        }
        Test.stopTest();
    }

    @isTest
    public static void getSuccessStoriesByIdsTest() {
        String mallContext = '{ "Id" : "00XXXXXXXXXXXXX", "StageName" : "Review", "AccountName" : "United Oil & Gas Corp." }';
        List < String > successStoryIds = new List < String > ();
        Test.startTest();
        List < DenormalizedSuccessStory > denormalizedSuccessStories = MallDataService.getSuccessStoriesByIds(mallContext, successStoryIds);
        Assert.areNotEqual(denormalizedSuccessStories, null, 'should not be null');
        try {
            denormalizedSuccessStories = MallDataService.getSuccessStoriesByIds('mallContext', successStoryIds);
        }catch(Exception e) {
             Assert.isTrue(e != NULL, 'Exception should not be null');
        }
        Test.stopTest();
    }

    @isTest
    public static void testGetTagsByIdsByContext() {
        Tag__c tg1 = new Tag__c();
        tg1.Position__c = 1;
        tg1.Name = 'Country';
        Insert tg1;

        String mallContext = '{ "Id" : "00XXXXXXXXXXXXX", "StageName" : "Review", "AccountName" : "United Oil & Gas Corp." }';
        Test.startTest();
        List<DenormalizedTag> denormalizedTag = MallDataService.getTagsByIdsByContext(mallContext, new List<String>{tg1.id});
        Assert.areNotEqual(denormalizedTag, null, 'should not be null');
        try {
            denormalizedTag = MallDataService.getTagsByIdsByContext('mallContext', NULL);
        }catch(Exception e) {
             Assert.isTrue(e != NULL, 'Exception should not be null');
        }
        try {
            MallDataService.getSolutionsBySegmentAndCategories('mallContext', NULL, NULL);
        }catch(Exception e) {
             Assert.isTrue(e != NULL, 'Exception should not be null');
        }
        try {
            MallDataService.getContentsByTagIdsRootNamesAndRecordTypeNames('mallContext', NULL, NULL, NULL);
        }catch(Exception e) {
             Assert.isTrue(e != NULL, 'Exception should not be null');
        }
        Test.stopTest();
    }
}