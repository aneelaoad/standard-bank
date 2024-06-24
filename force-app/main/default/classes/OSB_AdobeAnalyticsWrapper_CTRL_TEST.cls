/**
 * Test class for OSB_AdobeAnalyticsWrapper_CTRL
 * @author Wojciech Kowalczyk(wkowalczyk@deloittece.com
 * @date April 2020
 */
@IsTest
private class OSB_AdobeAnalyticsWrapper_CTRL_TEST {
    private static final String PAGE_NAME = 'name';
    private static final String PAGE_SECTION = 'section';
    private static final String PAGE_URL = 'url';
    @IsTest
    static void shouldGetPageDataByUrl() {
        mockRecords(PAGE_NAME, PAGE_SECTION, PAGE_URL);

        Test.startTest();
        Map<String, Object> adobeData = OSB_AdobeAnalyticsWrapper_CTRL.getPageData(PAGE_URL, false);
        Test.stopTest();

        OSB_AdobeAnalyticsData__mdt pageInfoRetrieved = (OSB_AdobeAnalyticsData__mdt) adobeData.get(OSB_AdobeAnalyticsWrapper_CTRL.PAGE_DETAILS_KEY);
        System.assertEquals(PAGE_NAME, pageInfoRetrieved.Page_Name__c);
        System.assertEquals(OSB_AdobeAnalyticsWrapper_CTRL.LOGGED_IN_STATUS, adobeData.get(OSB_AdobeAnalyticsWrapper_CTRL.LOGIN_STATUS_KEY));
    }

    @IsTest
    static void shouldGetPageDataBySection() {
        mockRecords(PAGE_NAME, PAGE_SECTION, PAGE_URL);
        Test.startTest();
        Map<String, Object> adobeData = OSB_AdobeAnalyticsWrapper_CTRL.getPageData(PAGE_SECTION, true);
        Test.stopTest();

        OSB_AdobeAnalyticsData__mdt pageInfoRetrieved = (OSB_AdobeAnalyticsData__mdt) adobeData.get(OSB_AdobeAnalyticsWrapper_CTRL.PAGE_DETAILS_KEY);
        System.debug(JSON.serializePretty(adobeData));
        System.assertEquals(PAGE_NAME, pageInfoRetrieved.Page_Name__c);
        System.assertEquals(OSB_AdobeAnalyticsWrapper_CTRL.LOGGED_IN_STATUS, adobeData.get(OSB_AdobeAnalyticsWrapper_CTRL.LOGIN_STATUS_KEY));
    }

    static void mockRecords(String name, String section, String url) {
        OSB_AdobeAnalyticsData__mdt pageInfo = new OSB_AdobeAnalyticsData__mdt(
                Page_Name__c = name,
                Page_Section__c = section,
                Page_URL__c = url
        );

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_AdobeAnalyticsData selector = (SEL_AdobeAnalyticsData) mocks.mock(SEL_AdobeAnalyticsData.class);
        mocks.startStubbing();
        mocks.when(selector.sObjectType()).thenReturn(OSB_AdobeAnalyticsData__mdt.SObjectType);
        mocks.when(selector.selectByPageUrl((Set<String>) fflib_Match.anyObject()))
                .thenReturn(new List<OSB_AdobeAnalyticsData__mdt>{pageInfo});
        mocks.when(selector.selectByPageSection((Set<String>) fflib_Match.anyObject()))
                .thenReturn(new List<OSB_AdobeAnalyticsData__mdt>{pageInfo});
        mocks.stopStubbing();
        ORG_Application.selector.setMock(selector);
    }
}