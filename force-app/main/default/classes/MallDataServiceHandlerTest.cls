/**
 * 
 * @description MallDataServiceHandlerTest
 * @author Maham Hasan
 * @since 
 */
@isTest
private class MallDataServiceHandlerTest {
    @isTest
    public static void testUserContext() {
        String mallContext;
        String currentUserId = UserInfo.getUserId();

        MallDataServiceHandler.setUserContext();
        List<User> userlist = SEL_Users.newInstance().selectById(new Set<Id>{(Id)currentUserId});

        MallDataServiceHandler mallDataHandler = new MallDataServiceHandler(mallContext);
        mallDataHandler.initializationStore();
        // Assertions
        Assert.areEqual(userlist[0].User_Franco__c, 'South Africa', 'expected null value');
    }

    @Istest
    public static void testMallDataServiceInitialization() {

        Publishing_Unit__c publishingUnit = new Publishing_Unit__c();
        publishingUnit.IsPreview__c = true;
        publishingUnit.Published_from__c = Date.newInstance(2022, 2, 2);
        publishingUnit.Published_until__c = Date.newInstance(2022, 2, 4);
        insert publishingUnit;

        Tag__c parentTag = new Tag__c();
        parentTag.name = 'Segment';
        parentTag.Publishing_Unit__c = publishingUnit.Id;
        insert parentTag;

        Tag__c tag = new Tag__c();
        tag.Parent__c = parentTag.Id;
        tag.Name = 'Individual';
        tag.Publishing_Unit__c = publishingUnit.Id;
        insert tag;

        Test.startTest();
        MallDataServiceHandler mallser = new MallDataServiceHandler();
        DenormalizedMallState denormalizedMallState = mallser.initialization();
        Test.stopTest();

        //Assertions
        Assert.areNotEqual(0, (denormalizedMallState.segments).size(), 'should be 0');
    }

    @Istest
    static void testGetTagsById() {

        Publishing_Unit__c publishingUnit = new Publishing_Unit__c();
        publishingUnit.IsPreview__c = true;
        publishingUnit.Published_from__c = Date.newInstance(2022, 2, 2);
        publishingUnit.Published_until__c = Date.newInstance(2022, 2, 4);
        insert publishingUnit;

        List <String> taglist = new List <String> ();
        Tag__c tg1 = new Tag__c();
        tg1.Position__c = 1;
        tg1.Publishing_Unit__c = publishingUnit.Id;
        tg1.Name = 'Country';

        Insert tg1;
        taglist.add(tg1.id);

        Tag__c tg2 = new Tag__c();
        tg2.Position__c = 3;
        tg2.Publishing_Unit__c = publishingUnit.Id;
        tg2.Name = 'Language';

        Insert tg2;
        taglist.add(tg2.id);

        Tag__c tg3 = new Tag__c();
        tg3.Position__c = 5;
        tg3.Publishing_Unit__c = publishingUnit.Id;
        tg3.Name = 'Related';

        Insert tg3;
        taglist.add(tg3.id);
        MallDataServiceHandler mallser = new MallDataServiceHandler();
        List <DenormalizedTag> tags = mallser.getTagsByIds(taglist);

        // Assertions
        Assert.areEqual('Country', tags.get(0).Name, 'should be equal');
        Assert.areEqual(true, tags.get(0).isOnline, 'should be equal');
    }

    @Istest
    static void testGetTagsByNames() {

        Publishing_Unit__c publishingUnit = new Publishing_Unit__c();
        publishingUnit.IsPreview__c = true;
        publishingUnit.Published_from__c = Date.newInstance(2022, 2, 2);
        publishingUnit.Published_until__c = Date.newInstance(2022, 2, 4);
        insert publishingUnit;

        List <String> taglist = new List <String> ();
        Tag__c tg1 = new Tag__c();
        tg1.Position__c = 1;
        tg1.Publishing_Unit__c = publishingUnit.Id;
        tg1.Name = 'Country';

        Insert tg1;
        taglist.add(tg1.id);

        Tag__c tg2 = new Tag__c();
        tg2.Position__c = 3;
        tg2.Publishing_Unit__c = publishingUnit.Id;
        tg2.Name = 'Language';

        Insert tg2;
        taglist.add(tg2.id);

        Tag__c tg3 = new Tag__c();
        tg3.Position__c = 5;
        tg3.Publishing_Unit__c = publishingUnit.Id;
        tg3.Name = 'Related';

        Insert tg3;
        taglist.add(tg3.id);
        MallDataServiceHandler mallser = new MallDataServiceHandler();
        List <DenormalizedTag> tags = mallser.getTagsByNames(taglist);

        // Assertions
        Assert.areEqual(0, tags.size(), 'should be 0');

    }

    @Istest
    static void getProductsByCountryNamesTest() {

        Publishing_Unit__c publishingUnit = new Publishing_Unit__c();
        publishingUnit.isPublished__c = true;
        publishingUnit.Published_from__c = Date.newInstance(2022, 2, 2);
        publishingUnit.Published_until__c = Date.newInstance(2023, 2, 4);
        insert publishingUnit;

        List <String> countryList = new List <String> ();
        Tag__c tg1 = new Tag__c();
        tg1.Position__c = 1;
        tg1.Name = 'South Africa';
        insert tg1;

        Offering__c product1 = new Offering__c();
        product1.Publishing_Unit__c = publishingUnit.id;
        product1.Name = 'South Africa';
        insert product1;

        Tag_Offering__c tagProduct1 = new Tag_Offering__c();
        tagProduct1.Tag__c = tg1.Id;
        tagProduct1.Offering__c = product1.Id;
        insert tagProduct1;

        Tag__c tg2 = new Tag__c();
        tg2.Position__c = 2;
        tg2.Name = 'Angola';
        insert tg2;

        Offering__c product2 = new Offering__c();

        product2.Name = 'Angola';
        insert product2;

        product2.Publishing_Unit__c = publishingUnit.Id;
        update product2;

        Tag_Offering__c tagProduct2 = new Tag_Offering__c();
        tagProduct2.Tag__c = tg2.Id;
        tagProduct2.Offering__c = product2.Id;
        insert tagProduct2;

        Tag__c tg3 = new Tag__c();
        tg3.Position__c = 3;
        tg3.Name = 'USA';
        insert tg3;

        Offering__c product3 = new Offering__c();
        product3.Publishing_Unit__c = publishingUnit.Id;
        product3.Name = 'USA';
        insert product3;

        Tag_Offering__c tagProduct3 = new Tag_Offering__c();
        tagProduct3.Tag__c = tg3.Id;
        tagProduct3.Offering__c = product3.Id;
        insert tagProduct3;

        countryList.add(product1.name);
        countryList.add(product2.name);
        countryList.add(product3.name);

        MallDataServiceHandler mallser = new MallDataServiceHandler();
        List <DenormalizedProduct> products = mallser.getProductsByCountryNames(countryList);


        // Assertions
        Assert.areEqual(0, products.size(), 'should be 0');
    }

    @Istest
    static void getProductsByIdsTest() {

        List <String> prodlist = new List <String> ();
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
        MallDataServiceHandler mallser = new MallDataServiceHandler();
        List <DenormalizedProduct> denormalizedProductList = mallser.getProductsByIds(prodlist);
        Assert.areNotEqual(null, denormalizedProductList, 'should not be null');
        Test.stopTest();
    }

    @Istest
    static void getShopsByTagIdsTest() {
        List <String> taglist = new List <String> ();
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

        Test.startTest();
        MallDataServiceHandler mallser = new MallDataServiceHandler();
        List <DenormalizedShop> denormalizedShopList = mallser.getShopsByTagIds(taglist);
        Assert.areNotEqual(null, denormalizedShopList, 'should not be null');
        Test.stopTest();
    }

    @Istest
    static void getShopsByParentTagIdsTest() {
        List <String> taglist = new List <String> ();
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
        MallDataServiceHandler mallser = new MallDataServiceHandler();
        List <DenormalizedShop> denormalizedShopList = mallser.getShopsByParentTagIds(taglist);
        Assert.areNotEqual(null, denormalizedShopList, 'should not be null');
        Test.stopTest();
    }

    @Istest
    static void getShopsByIdsTest() {

        Provider__c provider = new Provider__c();
        provider.Name = 'Provider test1';

        insert provider;

        List <String> taglist = new List <String> ();
        Tag__c tg1 = new Tag__c();
        tg1.Position__c = 1;
        tg1.Name = 'Country';

        Insert tg1;

        Tag_Provider__c tagProvider = new Tag_Provider__c();
        tagProvider.Provider__c = provider.id;
        tagProvider.Tag__c = tg1.id;

        insert tagProvider;
        taglist.add(tagProvider.Tag__c);

        Tag_Provider__c tagProvider1 = new Tag_Provider__c();
        tagProvider1.Provider__c = provider.id;
        tagProvider1.Tag__c = tg1.id;

        insert tagProvider1;
        taglist.add(tagProvider1.Tag__c);

        Test.startTest();
        MallDataServiceHandler mallser = new MallDataServiceHandler();
        List <DenormalizedShop> denormalizedShopList = mallser.getShopsByIds(taglist);
        Assert.areNotEqual(null, denormalizedShopList, 'should not be null');
        Test.stopTest();
    }

    @Istest
    static void getProductsByShopIdsTest() {

        Provider__c provider = new Provider__c();
        provider.Name = 'Provider test1';

        insert provider;

        Offering__c prod = new Offering__c();
        prod.Name = 'Test1';
        prod.Provider__c = provider.id;
        insert prod;

        List <String> taglist = new List <String> ();
        Tag__c tg1 = new Tag__c();
        tg1.Position__c = 1;
        tg1.Name = 'Country';

        Insert tg1;

        taglist.add(prod.Provider__c);

        Test.startTest();
        MallDataServiceHandler mallser = new MallDataServiceHandler();
        List <DenormalizedProduct> denormalizedProductList = mallser.getProductsByShopIds(taglist);
        Assert.areNotEqual(null, denormalizedProductList, 'should not be null');
        Test.stopTest();

    }

    @Istest
    static void getAllShopsTest() {

        Provider__c provider = new Provider__c();
        provider.Name = 'Provider test1';

        insert provider;

        Tag__c tg1 = new Tag__c();
        tg1.Position__c = 1;
        tg1.Name = 'Country';

        Insert tg1;

        Tag_Provider__c tagProvider1 = new Tag_Provider__c();

        tagProvider1.Provider__c = provider.id;
        tagProvider1.Tag__c = tg1.id;

        insert tagProvider1;

        Test.startTest();
        MallDataServiceHandler mallser = new MallDataServiceHandler();
        List <DenormalizedShop> denormalizedShopList = mallser.getAllShops();
        Assert.arenotEqual(null, denormalizedShopList, 'should not be null');
        Test.stopTest();

    }

    @IsTest
    static void getSearchResultsTest() {
        Provider__c provider = new Provider__c();
        provider.Name = 'Provider test1';

        insert provider;

        Tag__c tg1 = new Tag__c();
        tg1.Position__c = 1;
        tg1.Name = 'Country';

        Insert tg1;

        Tag_Provider__c tagProvider = new Tag_Provider__c();

        tagProvider.Provider__c = provider.id;
        tagProvider.Tag__c = tg1.id;

        insert tagProvider;

        Offering__c prod = new Offering__c();
        prod.Name = 'Test1';
        prod.Provider__c = provider.id;
        insert prod;

        Assert.areEqual('Test1', prod.Name, 'message');

    }

    @IsTest
    static void getContactUsEmailByCountryTest() {

        String countryName = 'Mexico';

        List <Country_Information__mdt> countrylist = [select id, Country_Name__c, Contact_Us_Email__c from Country_Information__mdt where Country_Name__c =: countryName];

        Assert.areEqual('Mexico', countrylist[0].Country_Name__c, 'should be equal');

        Test.startTest();
        MallDataServiceHandler mallser = new MallDataServiceHandler();
        String contactUsEmail = mallser.getContactUsEmailByCountry(countryName);
        Assert.areEqual(null, contactUsEmail, 'should be null');
        Test.stopTest();
    }

    @IsTest
    static void getLegalInfoTest() {

        List <String> countries = new List <String> ();
        List <String> languages = new List <String> ();

        countries.add('Angola');
        countries.add('USA');
        countries.add('India');
        languages.add('English');
        languages.add('Spanish');

        Test.startTest();
        MallDataServiceHandler mallser = new MallDataServiceHandler();
        List <DenormalizedContent> knowledgeList = mallser.getLegalInfo();
        Assert.areNotEqual(null, knowledgeList, 'should be NULl');
        Test.stopTest();

    }

    @IsTest
    static void processMallUserStateTest() {

        String mallContext = '{ "Id" : "00XXXXXXXXXXXXX", "StageName" : "Review", "AccountName" : "United Oil & Gas Corp." }';

        Test.startTest();
        MallDataServiceHandler.processMallUserState(mallContext);
        Test.stopTest();
        Assert.areEqual(null, MallDataServiceHandler.userCountry, 'should be null');

    }

    @IsTest
    static void getProductsByTagIdsTest() {

        List <String> taglist = new List <String> ();
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
        MallDataServiceHandler mallser = new MallDataServiceHandler();
        List <DenormalizedProduct> denormalizedProductList = mallser.getProductsByTagIds(taglist);
        Assert.areNotEqual(null, denormalizedProductList, 'should not be null');
        Test.stopTest();
    }

    @IsTest
    static void getProductsByParentTagIdsTest() {
        try {
            List <String> taglist = new List <String> ();
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
            MallDataServiceHandler mallser = new MallDataServiceHandler();
            List <DenormalizedProduct> denormalizedProductList = mallser.getProductsByParentTagIds(taglist);
            Assert.areNotEqual(null, denormalizedProductList, 'should not be null');
            Test.stopTest();
        } catch (exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @IsTest
    static void getShopsWhereNameStartsWith() {

        String searchString = 'Angola';

        Test.startTest();
        MallDataServiceHandler mallser = new MallDataServiceHandler();
        List <DenormalizedShop> shops = mallser.getShopsWhereNameStartsWith(searchString);
        Test.stopTest();
        Assert.areEqual(0, shops.size(), 'should be 0');

    }

    @IsTest
    static void getShopsByCountriesTest() {
        try {
            List <String> countries = new List <String> ();
            countries.add('Angola');
            countries.add('South Africa');
            countries.add('Uganda');

            Test.startTest();
            MallDataServiceHandler mallser = new MallDataServiceHandler();
            List <DenormalizedShop> denormalizedShopList = mallser.getShopsByCountries(countries);
            Assert.areNotEqual(null, denormalizedShopList, 'should not be null');
            Test.stopTest();

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @IsTest
    static void getProductsByTagNamesTest() {
        List <String> taglist = new List <String> ();
        try {

            Tag__c tg1 = new Tag__c();
            tg1.Position__c = 1;
            tg1.Name = 'Country';

            Insert tg1;

            Tag__c tg2 = new Tag__c();
            tg2.Position__c = 3;
            tg2.Name = 'South Africe';
            tg2.Parent__c = tg1.id;

            Insert tg2;
            taglist.add(tg2.Name);

            Tag__c tg3 = new Tag__c();
            tg3.Position__c = 5;
            tg3.Name = 'Angola';
            tg3.Parent__c = tg1.id;
            Insert tg3;
            taglist.add(tg3.Name);

            Test.startTest();
            MallDataServiceHandler mallser = new MallDataServiceHandler();
            List <DenormalizedProduct> denormalizedProductList = mallser.getProductsByTagNames(taglist);
            Assert.areNotEqual(null, denormalizedProductList, 'should not be Null');
            Test.stopTest();

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }

    @IsTest
    static void getProductsBySegmentAndCategoryIdsTest() {
        try {
            Provider__c provider = new Provider__c();
            provider.Name = 'Provider test1';

            insert provider;

            Publishing_Unit__c publishingUnit = new Publishing_Unit__c();
            publishingUnit.IsPreview__c = true;
            publishingUnit.Published_from__c = Date.newInstance(2022, 2, 2);
            publishingUnit.Published_until__c = Date.newInstance(2023, 2, 4);
            insert publishingUnit;

            List <String> segmentIds = new List <String> ();
            List <String> solutionIds = new List <String> ();
            List <String> categoryIds = new List <String> ();
            List <Tag_Offering__c> tagproductlist = new List <Tag_Offering__c> ();
            Tag__c tag = new Tag__c();
            tag.Position__c = 1;
            tag.Name = 'Category';
            insert tag;

            Tag__c tg1 = new Tag__c();
            tg1.Position__c = 1;
            tg1.Root__c = tag.Id;
            tg1.Name = 'Finance';

            Insert tg1;

            Tag__c sTag = new Tag__c();
            sTag.Position__c = 1;
            sTag.Name = 'Solutions';
            insert sTag;

            Tag__c sTag1 = new Tag__c();
            sTag1.Position__c = 1;
            sTag1.Root__c = sTag.Id;
            sTag1.Name = 'Bank';
            insert sTag1;

            Tag__c tagSeg = new Tag__c();
            tagSeg.Position__c = 1;
            tagSeg.Name = 'Segment';
            insert tagSeg;

            Tag__c tg2 = new Tag__c();
            tg2.Position__c = 1;
            tg2.Root__c = tagSeg.Id;
            tg2.Name = 'Finance';

            Insert tg2;

            Tag_Provider__c tagProvider = new Tag_Provider__c();

            tagProvider.Provider__c = provider.id;
            tagProvider.Tag__c = tg1.id;

            insert tagProvider;

            Offering__c prod = new Offering__c();
            prod.Name = 'Test1';
            prod.Provider__c = provider.id;
            insert prod;
            segmentIds.add(prod.id);
            categoryIds.add(prod.id);
            Offering__c prod2 = new Offering__c();
            prod2.Name = 'Test1';
            prod2.Provider__c = provider.id;
            insert prod2;

            Tag_Offering__c tagp = new Tag_Offering__c();
            tagp.Offering__c = prod2.id;
            tagp.Tag__c = tg1.id;
            insert tagp;

            Tag_Offering__c tagp1 = new Tag_Offering__c();
            tagp1.Offering__c = prod2.id;
            tagp1.Tag__c = tg2.id;
            insert tagp1;

            Tag_Offering__c tagSol = new Tag_Offering__c();
            tagSol.Offering__c = prod2.id;
            tagSol.Tag__c = sTag1.id;
            insert tagSol;

            tagproductlist.add(tagp);
            tagproductlist.add(tagp1);
            Assert.areNotEqual(tg1.id, prod.id, 'should not be equal');

            segmentIds.add(tg1.id);
            categoryIds.add(tg1.id);
            segmentIds.add(tg2.id);
            categoryIds.add(tg2.id);
            solutionIds.add(sTag1.id);
            prod2.Publishing_Unit__c = publishingUnit.Id;
            update prod2;

            Test.startTest();
            MallDataServiceHandler mallser = new MallDataServiceHandler();
            List <DenormalizedProduct> denormalizedProductList = mallser.getProductsBySegmentAndCategoryIds(segmentIds, categoryIds);
            Assert.areNotEqual(null, denormalizedProductList, 'should not be null');
            Test.stopTest();
        }
        Catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }

    @IsTest
    static void getSolutionsBySegmentAndCategoriesTest() {
        try {
            Provider__c provider = new Provider__c();
            provider.Name = 'Provider test';

            insert provider;

            Publishing_Unit__c publishingUnit = new Publishing_Unit__c();
            publishingUnit.IsPreview__c = true;
            publishingUnit.Published_from__c = Date.newInstance(2022, 2, 2);
            publishingUnit.Published_until__c = Date.newInstance(2023, 2, 4);
            insert publishingUnit;

            List <String> segmentIds = new List <String> ();
            List <String> solutionIds = new List <String> ();
            List <String> categoryIds = new List <String> ();
            List <Tag_Offering__c> tagproductlist = new List <Tag_Offering__c> ();
            Tag__c tag = new Tag__c();
            tag.Position__c = 1;
            tag.Name = 'Category';
            insert tag;

            Tag__c tg1 = new Tag__c();
            tg1.Position__c = 1;
            tg1.Root__c = tag.Id;
            tg1.Name = 'Finance';

            Insert tg1;

            Tag__c sTag = new Tag__c();
            sTag.Position__c = 1;
            sTag.Name = 'Solutions';
            insert sTag;

            Tag__c sTag1 = new Tag__c();
            sTag1.Position__c = 1;
            sTag1.Root__c = sTag.Id;
            sTag1.Name = 'Banking';
            insert sTag1;

            Tag__c tagSeg = new Tag__c();
            tagSeg.Position__c = 1;
            tagSeg.Name = 'Segment';
            insert tagSeg;

            Tag__c tg2 = new Tag__c();
            tg2.Position__c = 1;
            tg2.Root__c = tagSeg.Id;
            tg2.Name = 'Finance';

            Insert tg2;

            Tag_Provider__c tagProvider = new Tag_Provider__c();

            tagProvider.Provider__c = provider.id;
            tagProvider.Tag__c = tg1.id;

            insert tagProvider;

            Id recordTypeId = Schema.SObjectType.Offering__c.getRecordTypeInfosByName().get('Service').getRecordTypeId();
            Offering__c prod = new Offering__c();
            prod.Name = 'Test1';
            prod.RecordTypeId = recordTypeId;
            prod.Provider__c = provider.id;
            insert prod;

            segmentIds.add(prod.id);
            categoryIds.add(prod.id);

            Offering__c prod2 = new Offering__c();
            prod2.Name = 'Test1';
            prod2.Provider__c = provider.id;
            prod2.RecordTypeId = recordTypeId;
            insert prod2;

            Tag_Offering__c tagp = new Tag_Offering__c();
            tagp.Offering__c = prod2.id;
            tagp.Tag__c = tg1.id;
            insert tagp;

            Tag_Offering__c tagp1 = new Tag_Offering__c();
            tagp1.Offering__c = prod2.id;
            tagp1.Tag__c = tg2.id;
            insert tagp1;

            Tag_Offering__c tagSol = new Tag_Offering__c();
            tagSol.Offering__c = prod2.id;
            tagSol.Tag__c = sTag1.id;
            insert tagSol;

            tagproductlist.add(tagp);
            tagproductlist.add(tagp1);
            Assert.areNotEqual(tg1.id, prod.id, 'should not be equal');

            segmentIds.add(tg1.id);
            categoryIds.add(tg1.id);
            segmentIds.add(tg2.id);
            categoryIds.add(tg2.id);
            solutionIds.add(sTag1.id);
            prod2.Publishing_Unit__c = publishingUnit.Id;
            update prod2;

            Test.startTest();
            MallDataServiceHandler mallser = new MallDataServiceHandler();
            List <MallDataServiceHandler.SolutionResponse> denormalizedTagSolutions = mallser.getSolutionsBySegmentAndCategories(segmentIds, categoryIds);
            Assert.areNotEqual(null, denormalizedTagSolutions, 'should not be null');
            Test.stopTest();
        }
        Catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }

    @IsTest
    static void getOfferingsBySolutionIdsTest() {
        try {
            Provider__c provider = new Provider__c();
            provider.Name = 'Provider test1';

            insert provider;

            Publishing_Unit__c publishingUnit = new Publishing_Unit__c();
            publishingUnit.IsPreview__c = true;
            publishingUnit.Published_from__c = Date.newInstance(2022, 2, 2);
            publishingUnit.Published_until__c = Date.newInstance(2023, 2, 4);
            insert publishingUnit;

            List <String> segmentIds = new List <String> ();
            List <String> solutionIds = new List <String> ();
            List <String> categoryIds = new List <String> ();
            List <Tag_Offering__c> tagproductlist = new List <Tag_Offering__c> ();
            Tag__c tag = new Tag__c();
            tag.Position__c = 1;
            tag.Name = 'Category';
            insert tag;

            Tag__c tg1 = new Tag__c();
            tg1.Position__c = 1;
            tg1.Root__c = tag.Id;
            tg1.Name = 'Finance';

            Insert tg1;

            Tag__c sTag = new Tag__c();
            sTag.Position__c = 1;
            sTag.Name = 'Solutions';
            insert sTag;

            Tag__c sTag1 = new Tag__c();
            sTag1.Position__c = 1;
            sTag1.Root__c = sTag.Id;
            sTag1.Name = 'Banking';
            insert sTag1;

            Tag__c tagSeg = new Tag__c();
            tagSeg.Position__c = 1;
            tagSeg.Name = 'Segment';
            insert tagSeg;

            Tag__c tg2 = new Tag__c();
            tg2.Position__c = 1;
            tg2.Root__c = tagSeg.Id;
            tg2.Name = 'Finance';

            Insert tg2;

            Tag_Provider__c tagProvider = new Tag_Provider__c();

            tagProvider.Provider__c = provider.id;
            tagProvider.Tag__c = tg1.id;

            insert tagProvider;

            Id recordTypeId = Schema.SObjectType.Offering__c.getRecordTypeInfosByName().get('Service').getRecordTypeId();
            Offering__c prod = new Offering__c();
            prod.Name = 'Test1';
            prod.Provider__c = provider.id;
            prod.RecordTypeId = recordTypeId;
            insert prod;

            segmentIds.add(prod.id);
            categoryIds.add(prod.id);

            Offering__c prod2 = new Offering__c();
            prod2.Name = 'Test1';
            prod2.Provider__c = provider.id;
            prod2.RecordTypeId = recordTypeId;
            insert prod2;

            Tag_Offering__c tagp = new Tag_Offering__c();
            tagp.Offering__c = prod2.id;
            tagp.Tag__c = tg1.id;
            insert tagp;

            Tag_Offering__c tagp1 = new Tag_Offering__c();
            tagp1.Offering__c = prod2.id;
            tagp1.Tag__c = tg2.id;
            insert tagp1;

            Tag_Offering__c tagSol = new Tag_Offering__c();
            tagSol.Offering__c = prod2.id;
            tagSol.Tag__c = sTag1.id;
            insert tagSol;

            tagproductlist.add(tagp);
            tagproductlist.add(tagp1);
            Assert.areNotEqual(tg1.id, prod.id, 'should not be null');

            segmentIds.add(tg1.id);
            categoryIds.add(tg1.id);
            segmentIds.add(tg2.id);
            categoryIds.add(tg2.id);
            solutionIds.add(sTag1.id);
            prod2.Publishing_Unit__c = publishingUnit.Id;
            update prod2;

            Test.startTest();
            MallDataServiceHandler mallser = new MallDataServiceHandler();
            List <DenormalizedProduct> denormalizedProductList = mallser.getOfferingsBySolutionIds(new List <String> {
                sTag1.id
            }, 'Service');
            Assert.areNotEqual(null, denormalizedProductList, 'should not be null');
            Test.stopTest();
        }
        Catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

    }

    @isTest
    public static void getFAQsInfoTest() {
        Test.startTest();
        Tag__c tag = new Tag__c();
        tag.Position__c = 1;
        tag.Name = 'For shoppers';
        insert tag;

        List <String> tagIds = new List <String> {
            tag.Id
        };
        List <DenormalizedContent> result = new MallDataServiceHandler().getFAQsInfo(tagIds);
        Assert.areNotEqual(null, result, 'result should not be null');
        Test.stopTest();
    }

    @isTest
    public static void getContentsByCountryNamesAndRecordTypesTest() {

        List <String> countries = new List <String> ();
        List <String> recordTypes = new List <String> ();
        countries.add('India');
        countries.add('Angala');
        countries.add('USA');
        recordTypes.add('FAQ');
        recordTypes.add('Legal');
        Test.startTest();

        List <DenormalizedContent> denormalizedContent = new MallDataServiceHandler().getContentsByCountryNamesAndRecordTypes(countries, recordTypes);
        Assert.areNotEqual(denormalizedContent, null, 'should not be null');
        Test.stopTest();
    }

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
        insert tg2;

        Id storyRecType = Schema.SObjectType.Success_Story__c.getRecordTypeInfosByName().get('Success Story').getRecordTypeId();
        Id storyTranslationRecType = Schema.SObjectType.Success_Story__c.getRecordTypeInfosByName().get('Success Story Translation').getRecordTypeId();

        Success_Story__c story1 = new Success_Story__c();
        story1.Name = 'Test1';
        story1.RecordTypeId = storyRecType;
        insert story1;
        
        Success_Story__c story2 = new Success_Story__c();
        story2.Name = 'Test1';
        story2.RecordTypeId = storyTranslationRecType;
        story2.Parent_Success_Story__c = story1.Id;
        
        insert story2;   
        
        Tag_Success_Story__c tgs1 = new Tag_Success_Story__c();
        tgs1.Tag__c = tg2.Id;
        tgs1.Success_Story__c = story1.Id;
        insert tgs1;

        List <DenormalizedSuccessStory> denormalizedSuccessStories = new MallDataServiceHandler().getSuccessStoriesByCountryNames(countries);
        Assert.areNotEqual(denormalizedSuccessStories, null, 'should not be null');
    }

    @isTest
    public static void getSuccessStoriesByIdsTest() {
        List <String> successStoryIds = new List <String> ();
        Test.startTest();
        List <DenormalizedSuccessStory> denormalizedSuccessStories = new MallDataServiceHandler().getSuccessStoriesByIds(successStoryIds);
        Assert.areNotEqual(denormalizedSuccessStories, null, 'should not be null');
        Test.stopTest();
    }

    @isTest
    public static void getContentsByTagsRootTagsAndRecordTypeNamesTest() {
        List <String> rootTagNames = new List <String> ();
        List <String> tagNames = new List <String> ();
        List <String> recordTypes = new List <String> ();
        Test.startTest();
        List <DenormalizedContent> denormalizedContent = new MallDataServiceHandler().getContentsByTagsRootTagsAndRecordTypeNames(rootTagNames, tagNames, recordTypes);
        Assert.areNotEqual(denormalizedContent, null, 'should not be null');
        Test.stopTest();
    }

    @isTest
    public static void getContentsByTagIdsRootNamesAndRecordTypeNamesTest() {
        List <String> rootTagNames = new List <String> ();
        List <String> tagIds = new List <String> ();
        List <String> recordTypes = new List <String> ();
        Test.startTest();
        List <DenormalizedContent> denormalizedContent = new MallDataServiceHandler().getContentsByTagIdsRootNamesAndRecordTypeNames(rootTagNames, tagIds, recordTypes);
        Assert.areNotEqual(denormalizedContent, null, 'should not be null');
        Test.stopTest();
    }
}