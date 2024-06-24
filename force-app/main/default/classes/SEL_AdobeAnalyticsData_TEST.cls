/**
 * Test class for SEL_AdobeAnalyticsData
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date April 2020
 */
@IsTest(IsParallel=true)
private class SEL_AdobeAnalyticsData_TEST {
    @IsTest
    static void shouldSelectByPageUrl() {
        List<OSB_AdobeAnalyticsData__mdt> result = SEL_AdobeAnalyticsData.newInstance().selectByPageUrl(new Set<String>());
        System.assertNotEquals(null, result);
    }

    @IsTest
    static void shouldSelectByPageSection() {
        List<OSB_AdobeAnalyticsData__mdt> result = SEL_AdobeAnalyticsData.newInstance().selectByPageSection(new Set<String>());
        System.assertNotEquals(null, result);
    }
}