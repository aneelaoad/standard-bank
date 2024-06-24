/**
 * 
 * @description Controller Class for Search Component
 * @author Maham Hassan
 * @since 
 */
public with sharing class Mall_CTRL_Search {

    public static final String DEFAULT_CONTENT_LANGUAGE_ISO = 'en';
    public static final String DEFAULT_USER_COUNTRY = 'South Africa';
    public static final String ICON_CONTENT_UNIT_TRANSLATION = 'iconCUT';
    public static final String CONTENT_UNIT_TRANSLATION = 'translationCUT';
    public static final Integer MAX_DESC_LENGTH = 150;
    public static final Integer MAX_DESC_LENGTH_OTHER = 60;

    //UserContext Setup Variables
    public static String userContentLanguage = '';
    public static String userCountry = '';
    public static User currentUser;
    public static Map <Id, Content_Unit_Translation__c> shopIdVsCut = new Map <Id,Content_Unit_Translation__c> ();

    /**
     * 
     * @description Set user context
     */
    public static void setUserContext() {
        try {
            String currentUserId = UserInfo.getUserId();
            if (currentUser == NULL && !Auth.CommunitiesUtil.isGuestUser()) {

                List <User> users = SEL_Users.newInstance().selectById(new Set <Id> {
                    (Id) currentUserId
                });
                if (users.size()> 0) {
                    currentUser = users[0];
                }
                userContentLanguage = MallUserPreferencesManagement.getUserPreferences().userLanguage;
                userCountry = String.isNotBlank(currentUser.User_Franco__c) ? currentUser.User_Franco__c : DEFAULT_USER_COUNTRY;
            }
        } catch (exception e) {
            throw MallExceptionUtil.throwAuraException('Mall_CTRL_Search.setUserContext', e);
        }
    }

    /**
     * 
     * @description Searching in shops
     * @param searchString String
     * @return  `Map<String,Object>`
     */
    @AuraEnabled(Cacheable = true)
    public static Map <String,
        Object> getSearchResults(String searchString) {
            try {
                setUserContext();
                List <Id> shopIds = new List <Id> ();
                List <Id> sortedCountryShopIds = new List <Id> ();
                List <Id> countryShopsIds = new List <Id> ();
                Map <Id,
                    Tag_Provider__c> shopIdVsTagShop = new Map <Id,
                    Tag_Provider__c> ();
                Map <Id,
                    Content_Unit_Translation__c> shopIdVsShopCut = new Map <Id,
                    Content_Unit_Translation__c> ();

                List <Id> serviceIds = new List <Id> ();
                List <Id> sortedCountryServiceIds = new List <Id> ();
                List <Id> countryServiceIds = new List <Id> ();
                Map <Id,
                    String> serviceIdVsSolutionsId = new Map <Id,
                    String> ();
                Map <Id,
                    Tag_Offering__c> serviceIdVsTagService = new Map <Id,
                    Tag_Offering__c> ();
                Map <Id,
                    Content_Unit_Translation__c> serviceIdVsServiceCut = new Map <Id,
                    Content_Unit_Translation__c> ();

                List <Id> solutionsIds = new List <Id> ();
                Map <Id,
                    Tag__c> solutionsIdVsTagSolutions = new Map <Id,
                    Tag__c> ();
                Map <Id,
                    Content_Unit_Translation__c> solutionsIdVsSolutionslnCut = new Map <Id,
                    Content_Unit_Translation__c> ();

                List <Id> eventIds = new List <Id> ();
                List <Id> sortedCountryEventIds = new List <Id> ();
                List <Id> countryEventIds = new List <Id> ();
                Map <Id,
                    Tag_Business_Event__c> eventIdVsTagEvent = new Map <Id,
                    Tag_Business_Event__c> ();
                Map <Id,
                    Content_Unit_Translation__c> eventIdVsEventCut = new Map <Id,
                    Content_Unit_Translation__c> ();

                List <Id> guidedSolnIds = new List <Id> ();
                List <Id> sortedCountryguidedSolnIds = new List <Id> ();
                List <Id> countryguidedSolnIds = new List <Id> ();
                Map <Id,
                    Tag_Offering__c> guidedSolnIdVsTagGuidedSoln = new Map <Id,
                    Tag_Offering__c> ();
                Map <Id,
                    Content_Unit_Translation__c> guidedSolnIdVsGuidedSolnCut = new Map <Id,
                    Content_Unit_Translation__c> ();

                List <String> contentRecordTypes = new List <String> {
                    'About us',
                    'FAQ',
                    'Insight',
                    'Legal',
                    'Partner with us'
                };

                String searchText = searchString;
                list <string> strsearch = searchText.split(' ');
                Set <String> setString = new Set <String> ();
                setString.add(searchString);
                string sstring = '';
                Integer index = 0;
                for (String str: strsearch) {
                    if (str.length()> 0) {
                        setString.add(str);
                        if (index == 0) {
                            sstring += '("' + str + '*")';
                        } else {
                            sstring += ' OR ("' + str + '*")';
                        }
                        index++;
                    }
                }

                sstring += ' OR ("' + searchString + '*")';

                List <List <sObject>> results = [FIND: sstring IN ALL FIELDS
                    RETURNING
                    Content_Unit_Translation__c(Text__c, Image_Url__c, RichText__c, Provider__c, Title__c, Product__c, Provider__r.Name, Product__r.recordType.Name, Business_Event__c, Tag__c, Tag__r.Root_name__c, Business_Event__r.Link__r.Guest_Url__c, Business_Event__r.Link__r.Mobile_Url__c, Business_Event__r.Link__r.Desktop_Url__c, Product__r.Provider__c Where(((((Tag__c != NULL AND Tag__r.Root_name__c = 'Solutions') OR Provider__c != NULL OR(Product__c != NULL And Product__r.recordType.Name != 'Guided Solution')) AND Title__c != NULL) OR(Product__c != NULL AND Product__r.RecordType.Name = 'Guided Solution') OR Business_Event__c != NULL) And Language_ISO__c =: userContentLanguage))
                ];

                for (Content_Unit_Translation__c cut: (List <Content_Unit_Translation__c> ) results[0]) {
                    if (cut.Product__c != NULL && cut.Product__r.recordType.Name == 'Service') {
                        serviceIds.add(cut.Product__c);
                        serviceIdVsServiceCut.put(cut.Product__c, cut);
                    } else if (cut.Provider__c != NULL) {
                        shopIds.add(cut.Provider__c);
                        shopIdVsShopCut.put(cut.Provider__c, cut);
                    } else if (cut.Product__c != NULL && cut.Product__r.recordType.Name == 'Guided Solution') {
                        guidedSolnIds.add(cut.Product__c);
                        guidedSolnIdVsguidedSolnCut.put(cut.Product__c, cut);
                    } else if (cut.Tag__c != NULL && cut.Tag__r.Root_name__c == 'Solutions') {
                        solutionsIds.add(cut.Tag__c);
                        solutionsIdVsSolutionslnCut.put(cut.Tag__c, cut);
                    } else if (cut.Business_Event__c != NULL) {
                        eventIds.add(cut.Business_Event__c);
                        eventIdVsEventCut.put(cut.Business_Event__c, cut);
                    }
                }

                Set <Id> solutionsIdsSet = new Set <Id> ();
                solutionsIdsSet.addAll(solutionsIds);
                List <Tag__c> solutions = SEL_Tags.newInstance().selectTagsByIds(solutionsIdsSet);

                for (Tag__c solution: solutions) {
                    solutionsIdVsTagSolutions.put(solution.id, solution);
                }

                String shopWhereClause = '(((Tag__r.Parent__r.Name=\'Country\' ';
                shopWhereClause += ' AND Tag__r.Name =' + '\'' + usercountry + '\') OR Tag__r.Name=\'' + userCountry + '\') OR Tag__r.Parent__r.Name=\'Category\' )';
                shopWhereClause += ' AND Provider__c!=NULL And Provider__c IN (\'' + String.join(shopIds, '\',\'') + '\')';
                List <Tag_Provider__c> tagShopsForCountry = SEL_TagProviders.newInstance().selectByCustomFilterCondition(shopWhereClause);
                for (Tag_Provider__c tagShop: tagShopsForCountry) {
                    if ((shopIdVsShopCut.keySet()).contains(tagShop.Provider__c)) {
                        if (tagShop.Tag__r.Parent__r.Name == 'Country') {
                            countryShopsIds.add(tagShop.Provider__c);
                        } else {
                            shopIdVsTagShop.put(tagShop.Provider__c, tagShop);
                        }
                    }
                }

                //get services for country
                String productWhereClause = '(((Tag__r.Parent__r.Name=\'Country\' ';
                productWhereClause += ' AND Tag__r.Name =' + '\'' + usercountry + '\') OR Tag__r.Name=\'' + userCountry + '\') OR Tag__r.Parent__r.Name=\'Category\' OR Tag__r.Parent__r.Name=\'Solutions\')';
                productWhereClause += ' AND Offering__c!=NULL and Offering__r.RecordType.Name=\'Service\' And Offering__c IN (\'' + String.join(serviceIds, '\',\'') + '\')';
                List <Tag_Offering__c> tagServicesForCountry = SEL_TagOfferings.newInstance().selectByCustomFilterCondition(productWhereClause);
                for (Tag_Offering__c tagService: tagServicesForCountry) {
                    if ((serviceIdVsServiceCut.keySet()).contains(tagService.Offering__c)) {
                        if (tagService.Tag__r.Parent__r.Name == 'Country') {
                            countryServiceIds.add(tagService.Offering__c);
                        }
                        if (tagService.Tag__r.Parent__r.Name == 'Solutions') {
                            serviceIdVsSolutionsId.put(tagService.Offering__c, tagService.Tag__c);
                        } else {
                            serviceIdVsTagService.put(tagService.Offering__c, tagService);
                        }
                    }
                }

                //get guided Solution for country
                String solnWhereClause = '(((Tag__r.Parent__r.Name=\'Country\' ';
                solnWhereClause += ' AND Tag__r.Name =' + '\'' + usercountry + '\') OR Tag__r.Name=\'' + userCountry + '\') OR Tag__r.Parent__r.Name=\'Category\' )';
                solnWhereClause += ' AND Offering__c!=NULL and Offering__r.RecordType.Name=\'Guided Solution\' And Offering__c IN (\'' + String.join(guidedSolnIds, '\',\'') + '\')';
                List <Tag_Offering__c> tagGuidedSolutionForCountry = SEL_TagOfferings.newInstance().selectByCustomFilterCondition(solnWhereClause);
                for (Tag_Offering__c tagGuidedSolution: tagGuidedSolutionForCountry) {
                    if ((guidedSolnIdVsguidedSolnCut.keySet()).contains(tagGuidedSolution.Offering__c)) {
                        if (tagGuidedSolution.Tag__r.Parent__r.Name == 'Country') {
                            countryGuidedSolnIds.add(tagGuidedSolution.Offering__c);
                        } else {
                            guidedSolnIdVsTagGuidedSoln.put(tagGuidedSolution.Offering__c, tagGuidedSolution);
                        }
                    }
                }

                //get events for country
                String eventWhereClause = '(((Tag__r.Parent__r.Name=\'Country\' ';
                eventWhereClause += ' AND Tag__r.Name =' + '\'' + usercountry + '\') OR Tag__r.Name=\'' + userCountry + '\') OR Tag__r.Parent__r.Name=\'Category\' )';
                eventWhereClause += ' AND Business_Event__c!=NULL And Business_Event__c IN (\'' + String.join(eventIds, '\',\'') + '\')';
                List <Tag_Business_Event__c> tagEventForCountry = SEL_MALL_TagEvents.newInstance().selectByCustomFilterCondition(eventWhereClause);
                for (Tag_Business_Event__c tagEvent: tagEventForCountry) {
                    if ((eventIdVsEventCut.keySet()).contains(tagEvent.Business_Event__c)) {
                        if (tagEvent.Tag__r.Parent__r.Name == 'Country') {
                            countryEventIds.add(tagEvent.Business_Event__c);
                        } else {
                            eventIdVsTagEvent.put(tagEvent.Business_Event__c, tagEvent);
                        }
                    }
                }

                List <Id> serviceShopIds = new List <Id> ();

                for (Id shopId: shopIds) {
                    if (countryShopsIds.contains(shopId)) {
                        sortedCountryShopIds.add(shopId);
                    }
                }

                for (Id serviceId: serviceIds) {
                    if (countryServiceIds.contains(serviceId)) {
                        sortedCountryServiceIds.add(serviceId);
                        if (serviceIdVsServiceCut.containsKey(serviceId)) {
                            serviceShopIds.add(serviceIdVsServiceCut.get(serviceId).Product__r.Provider__c);
                        }
                    }
                }

                for (Id gudidedSolnId: guidedSolnIds) {
                    if (countryGuidedSolnIds.contains(gudidedSolnId)) {
                        sortedCountryGuidedSolnIds.add(gudidedSolnId);
                    }
                }

                for (Id eventId: eventIds) {
                    if (countryEventIds.contains(eventId)) {
                        sortedCountryEventIds.add(eventId);
                    }
                }

                //get service's store's cut
                String cutWhereClause = ' Provider__c IN (\'' + String.join(serviceShopIds, '\',\'') + '\') And Language_ISO__c=\'' + userContentLanguage + '\'';
                for (Content_Unit_Translation__c cut: SEL_ContentUnitTranslations.newInstance().selectByCustomFilterCondition(cutWhereClause)) {
                    shopIdVsCut.put(cut.Provider__c, cut);
                }

                List <SearchData> denormalizedOthers = new List <SearchData> ();
                List <SearchData> denormalizedShops = prepareData(sortedCountryShopIds, shopIdVsShopCut, shopIdVsTagShop, setString, 'shop', NULL);
                List <SearchData> denormalizedSolutions = prepareSolutionsData(solutionsIdVsSolutionslnCut, solutionsIdVsTagSolutions, setString);
                List <SearchData> denormalizedServies = prepareData(sortedCountryServiceIds, serviceIdVsServiceCut, serviceIdVsTagService, setString, 'service', serviceIdVsSolutionsId);
                List <SearchData> denormalizedGuidedSolutions = prepareOtherData(sortedCountryGuidedSolnIds, guidedSolnIdVsGuidedSolnCut, guidedSolnIdVsTagGuidedSoln, setString);
                List <SearchData> denormalizedBusinessEvents = prepareOtherData(sortedCountryEventIds, eventIdVsEventCut, eventIdVsTagEvent, setString);

                denormalizedOthers.addAll(denormalizedBusinessEvents);
                denormalizedOthers.addAll(denormalizedGuidedSolutions);

                Map <String,
                    Object> searchResults = new Map <String,
                    Object> {
                        'Products' => denormalizedServies,
                        'Solutions' => denormalizedSolutions,
                        'Shops' => denormalizedShops,
                        'Others' => denormalizedOthers
                    };
                return searchResults;
            } catch (exception e) {
                throw MallExceptionUtil.throwAuraException('Mall_CTRL_Search.getSearchResults', e);
            }
        }

    /**
     * 
     * @description prepareData
     * @param sortedCountryCategoryIds
     * @param categoryIdVsCategoryCut
     * @param categoryIdVsTagLink
     * @param setString
     * @param searchCategoryType
     * @param serviceIdVsSolutionsId
     * @return  List<SearchData>
     */
    public static List <SearchData> prepareData(List <Id> sortedCountryCategoryIds, Map <Id, Content_Unit_Translation__c> categoryIdVsCategoryCut, Map <Id, Sobject> categoryIdVsTagLink, Set <String> setString, String searchCategoryType, Map <Id, String> serviceIdVsSolutionsId) {

        try {
            List <SearchData> finalData = new List <SearchData> ();
            Set <Id> processedRecordIds = new Set <Id> ();

            for (String searchString: setString) {
                List <SearchData> nameMatching = new List <SearchData> ();
                List <SearchData> shortDescMatching = new List <SearchData> ();
                List <SearchData> longDescMatching = new List <SearchData> ();
                List <SearchData> nameExactMatch = new List <SearchData> ();
                List <SearchData> nameFirstPlaceMatch = new List <SearchData> ();
                List <SearchData> nameContains = new List <SearchData> ();

                for (Id cateogryId: sortedCountryCategoryIds) {
                    if (categoryIdVsCategoryCut.containsKey(cateogryId) && !processedRecordIds.contains(cateogryId) && categoryIdVsCategoryCut.get(cateogryId).Text__c != NULL && categoryIdVsCategoryCut.get(cateogryId).RichText__c != NULL) {
                        SearchData data = new SearchData();
                        data.id = cateogryId;
                        data.imageUrl = categoryIdVsCategoryCut.get(cateogryId).Image_Url__c;
                        data.title = categoryIdVsCategoryCut.get(cateogryId).Title__c;
                        if (serviceIdVsSolutionsId != NULL) {
                            data.solutionId = serviceIdVsSolutionsId.containsKey(cateogryId) ? serviceIdVsSolutionsId.get(cateogryId) : NULL;
                        }
                        if (categoryIdVsCategoryCut.get(cateogryId).Provider__c != NULL) {
                            data.shopName = categoryIdVsTagLink.containsKey(cateogryId) ? ((Tag_Provider__c) categoryIdVsTagLink.get(cateogryId)).Provider__r.Name : NULL;
                            data.title = categoryIdVsTagLink.containsKey(cateogryId) ? ((Tag_Provider__c) categoryIdVsTagLink.get(cateogryId)).Provider__r.Name : NULL;
                            data.categoryId = categoryIdVsTagLink.containsKey(cateogryId) ? ((Tag_Provider__c) categoryIdVsTagLink.get(cateogryId)).Tag__c : NULL;
                            data.categoryName = categoryIdVsTagLink.containsKey(cateogryId) ? ((Tag_Provider__c) categoryIdVsTagLink.get(cateogryId)).Tag__r.Name : NULL;
                        } else {

                            if (categoryIdVsTagLink.containsKey(cateogryId)) {
                                data.categoryId = ((Tag_Offering__c) categoryIdVsTagLink.get(cateogryId)).Tag__c;
                                data.categoryName = ((Tag_Offering__c) categoryIdVsTagLink.get(cateogryId)).Tag__r.Name;
                                data.desktopUrl = ((Tag_Offering__c) categoryIdVsTagLink.get(cateogryId)).Offering__r.Link__r.DeskTop_Url__c;
                                data.mobileUrl = ((Tag_Offering__c) categoryIdVsTagLink.get(cateogryId)).Offering__r.Link__r.Mobile_Url__c;
                                data.guestUrl = ((Tag_Offering__c) categoryIdVsTagLink.get(cateogryId)).Offering__r.Link__r.Guest_Url__c;
                            }
                            if (shopIdVsCut.containsKey(categoryIdVsCategoryCut.get(cateogryId).Product__r.Provider__c)) {
                                data.shopName = ((Tag_Offering__c) categoryIdVsTagLink.get(cateogryId)).Offering__r.Provider__r.Name;
                            }
                        }
                        data.shortDesc = categoryIdVsCategoryCut.get(cateogryId).Text__c;
                        data.longDesc = categoryIdVsCategoryCut.get(cateogryId).RichText__c != NULL ? (categoryIdVsCategoryCut.get(cateogryId).RichText__c).stripHtmlTags() : NULL;
                        if (categoryIdVsCategoryCut.get(cateogryId).Provider__c != NULL || (categoryIdVsCategoryCut.get(cateogryId).Product__c != NULL && data.shopName != NULL)) {
                            if (data.title != NULL && data.title.containsIgnoreCase(searchString)) {
                                nameMatching.add(data);
                                processedRecordIds.add(cateogryId);
                            } else if (data.shortDesc != NULL && data.shortDesc.containsIgnoreCase(searchString)) {
                                shortDescMatching.add(data);
                                processedRecordIds.add(cateogryId);
                            } else if (data.longDesc != NULL && data.longDesc.containsIgnoreCase(searchString)) {
                                longDescMatching.add(data);
                                processedRecordIds.add(cateogryId);
                            }
                        }
                    }
                }
                for (SearchData data: nameMatching) {
                    if (data.title == searchString) {
                        nameExactMatch.add(data);
                    } else if (data.title.startsWithIgnoreCase(searchString)) {
                        nameFirstPlaceMatch.add(data);
                    } else {
                        nameContains.add(data);
                    }
                }
                finalData.addAll(nameExactMatch);
                finalData.addAll(nameFirstPlaceMatch);
                finalData.addAll(nameContains);
                finalData.addAll(shortDescMatching);
                finalData.addAll(longDescMatching);
            }
            return finalData;
        } catch (exception e) {
            throw MallExceptionUtil.throwAuraException('Mall_CTRL_Search.prepareData', e);
        }

    }

    /**
     * 
     * @description prepareSolutionsData
     * @param categoryIdVsCategoryCut
     * @param categoryIdVsTagLink
     * @param setString
     * @return List<SearchData>
     */
    public static List <SearchData> prepareSolutionsData(
        Map <Id, Content_Unit_Translation__c> categoryIdVsCategoryCut, Map <Id, Tag__c> categoryIdVsTagLink, Set <String> setString) {

        try {
            List <SearchData> solutionsSearch = new List <SearchData> ();
            for (String searchString: setString) {
                for (Id typeId: categoryIdVsTagLink.keySet()) {
                    SearchData data = new SearchData();
                    Content_Unit_Translation__c cut = categoryIdVsCategoryCut.get(typeId);
                    data.title = (cut != NULL) ? cut.Title__c : NULL;
                    data.id = typeId;
                    data.imageUrl = (cut != NULL) ? cut.Image_Url__c : NULL;
                    data.shortDesc = (cut != NULL) ? cut.Text__c : NULL;
                    if (cut != NULL && cut.RichText__c != NULL) {
                        data.longDesc = cut.RichText__c.containsIgnoreCase(searchString) ? extractWords(searchString, (cut.RichText__c).stripHtmlTags(), 5, 8) : ((cut.RichText__c).stripHtmlTags());
                        if (String.IsNotBlank(data.longDesc) && data.longDesc.length()> MAX_DESC_LENGTH_OTHER) {
                            data.longDesc = data.longDesc.substring(0, MAX_DESC_LENGTH_OTHER);
                        }
                    }
                    solutionsSearch.add(data);
                }
            }
            return solutionsSearch;
        } catch (exception e) {
            throw MallExceptionUtil.throwAuraException('Mall_CTRL_Search.prepareSolutionsData', e);
        }
    }

    /**
     * 
     * @description prepareOtherData
     * @param sortedCountryCategoryIds
     * @param categoryIdVsCategoryCut
     * @param categoryIdVsTagLink
     * @param setString
     * @return List<SearchData>
     */
    public static List <SearchData> prepareOtherData(List <Id> sortedCountryCategoryIds, Map <Id, Content_Unit_Translation__c> categoryIdVsCategoryCut, Map <Id, Sobject> categoryIdVsTagLink, Set <String> setString) {

        try {
            Site site = [SELECT Id FROM Site WHERE UrlPathPrefix = 'mall'
                LIMIT 1
            ];
            String siteUrl = [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;
            Map <String,
                String> websitePageNameVsURL = new Map <String,
                String> {
                    'faq' => siteUrl + '/s/faq',
                    'about us' => siteUrl + '/s/about-us',
                    'legal' => siteUrl + '/s/legal?tab=3'
                };

            List <SearchData> finalData = new List <SearchData> ();

            for (String searchString: setString) {
                List <SearchData> legalData = new List <SearchData> ();
                List <SearchData> faqData = new List <SearchData> ();
                List <SearchData> insightData = new List <SearchData> ();
                List <SearchData> aboutUsData = new List <SearchData> ();
                List <SearchData> guidedSolnData = new List <SearchData> ();
                List <SearchData> businessEventsData = new List <SearchData> ();
                for (Id typeId: sortedCountryCategoryIds) {
                    if ((categoryIdVsCategoryCut.containsKey(typeId) && categoryIdVsCategoryCut.get(typeId).Business_Event__c != NULL) || categoryIdVsCategoryCut.containsKey(typeId) && Test.isRunningTest() && categoryIdVsCategoryCut.get(typeId).Business_Event__c != NULL) {
                        SearchData data = new SearchData();
                        data.title = 'Business Events';
                        data.id = typeId;
                        data.categoryId = categoryIdVsTagLink.containsKey(typeId) ? ((Tag_Business_Event__c) categoryIdVsTagLink.get(typeId)).Tag__c : NULL;
                        data.categoryName = categoryIdVsTagLink.containsKey(typeId) ? ((Tag_Business_Event__c) categoryIdVsTagLink.get(typeId)).Tag__r.Name : NULL;
                        Content_Unit_Translation__c cut = categoryIdVsCategoryCut.get(typeId);
                        data.shortDesc = cut.Text__c;
                        data.longDesc = (cut.RichText__c != NULL && cut.RichText__c.containsIgnoreCase(searchString)) ? extractWords(searchString, (categoryIdVsCategoryCut.get(typeId).RichText__c).stripHtmlTags(), 5, 8) : ((categoryIdVsCategoryCut.get(typeId).RichText__c).stripHtmlTags());
                        if (data.longDesc.length()> MAX_DESC_LENGTH) {
                            data.longDesc = data.longDesc.substring(0, MAX_DESC_LENGTH);
                        }
                        data.desktopUrl = cut.Business_Event__r.Link__r.Desktop_Url__c;
                        data.mobileUrl = cut.Business_Event__r.Link__r.Mobile_Url__c;
                        data.guestUrl = cut.Business_Event__r.Link__r.Guest_Url__c;
                        businessEventsData.add(data);
                    }
                }
                finalData.addAll(businessEventsData);
                finalData.addAll(insightData);
                finalData.addAll(faqData);
                finalData.addAll(aboutUsData);
                finalData.addAll(legalData);
                finalData.addAll(guidedSolnData);
            }
            return finalData;
        } catch (exception e) {
            throw MallExceptionUtil.throwAuraException('Mall_CTRL_Search.prepareOtherData', e);
        }
    }

    /**
     * 
     * @description extractWords
     * @param inputString
     * @param largeText
     * @param previousCount
     * @param nextCount
     * @return String
     */
    public static String extractWords(String inputString, String largeText, Integer previousCount, Integer nextCount) {
        try {
            List <String> extractedWords = new List <String> ();
            String[] words = (largeText.stripHtmlTags()).split(' ');

            for (Integer i = 0; i <words.size(); i++) {
                if (words[i].equalsIgnoreCase(inputString)) {
                    Integer startIndex = Math.max(0, i - previousCount);
                    Integer endIndex = Math.min(i + nextCount, words.size() - 1);

                    for (Integer j = startIndex; j <i; j++) {
                        extractedWords.add(words[j]);
                    }

                    extractedWords.add(words[i]);

                    for (Integer j = i + 1; j <= endIndex; j++) {
                        extractedWords.add(words[j]);
                    }

                    break;
                }
            }
            return String.join(extractedWords, ' ');
        } catch (exception e) {
            throw MallExceptionUtil.throwAuraException('Mall_CTRL_Search.extractWords', e);
        }
    }

    /**
     * @description SearchData
     * @author Maham Hassan
     * @since
     */
    public class SearchData {
        @AuraEnabled
        public string id;
        @AuraEnabled
        public string imageUrl;
        @AuraEnabled
        public string title;
        @AuraEnabled
        public string categoryId;
        @AuraEnabled
        public string categoryName;
        @AuraEnabled
        public string shortDesc;
        @AuraEnabled
        public string longDesc;
        @AuraEnabled
        public string desktopUrl;
        @AuraEnabled
        public string mobileUrl;
        @AuraEnabled
        public string guestUrl;
        @AuraEnabled
        public string contentType;
        @AuraEnabled
        public string shopName;
        @AuraEnabled
        public string solutionId;
    }
}