/**
 * Selector class for OSB_AdobeAnalyticsData__mdt custom metadata
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date April 2020
 */
public with sharing class SEL_AdobeAnalyticsData extends fflib_SObjectSelector {

    /**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     */
    public static SEL_AdobeAnalyticsData newInstance() {
        return (SEL_AdobeAnalyticsData) ORG_Application.selector.newInstance(OSB_AdobeAnalyticsData__mdt.SObjectType);
    }

    /**
     * Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
     * queries.
     */
    public SObjectType getSObjectType() {
        return OSB_AdobeAnalyticsData__mdt.SObjectType;
    }

    public List<SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                OSB_AdobeAnalyticsData__mdt.Page_Category__c,
                OSB_AdobeAnalyticsData__mdt.Page_Name__c,
                OSB_AdobeAnalyticsData__mdt.Sub_Section_1__c,
                OSB_AdobeAnalyticsData__mdt.Sub_Section_2__c,
                OSB_AdobeAnalyticsData__mdt.Sub_Section_3__c,
                OSB_AdobeAnalyticsData__mdt.Sub_Section_4__c,
                OSB_AdobeAnalyticsData__mdt.Sub_Section_5__c
        };
    }

    /**
     * Selects OSB_AdobeAnalyticsData__mdt based on page url
     *
     * @param pageUrls - url of current page
     *
     * @return list of OSB_AdobeAnalyticsData__mdt
     */
    public List<OSB_AdobeAnalyticsData__mdt> selectByPageUrl(Set<String> pageUrls) {
        return Database.query(
                newQueryFactory(false, false, true)
                        .setCondition('Page_URL__c IN :pageUrls')
                        .toSOQL());
    }

    /**
     * Selects OSB_AdobeAnalyticsData__mdt based on single page application section
     *
     * @param pageSections - name of current single page application section
     *
     * @return list of OSB_AdobeAnalyticsData__mdt
     */
    public List<OSB_AdobeAnalyticsData__mdt> selectByPageSection(Set<String> pageSections) {
        return Database.query(
                newQueryFactory(false, false, true)
                        .setCondition('Page_Section__c IN :pageSections')
                        .toSOQL());
    }
}