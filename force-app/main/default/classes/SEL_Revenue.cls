/**
 * Selector layer class for FinServ__Revenue__c SObject
 *
 * @author Michal Pekso (mpesko@deloittece.com)
 * @date October 2021
 */
public with sharing class SEL_Revenue extends fflib_SObjectSelector{
    /**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     * @return instance of the class
     */
    public static SEL_Revenue newInstance() {
        return (SEL_Revenue) ORG_Application.selector.newInstance(FinServ__Revenue__c.SObjectType);
    }

    /**
     * Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
     * queries.
     *
     * @return the SObject type for the selector.
     */
    public SObjectType getSObjectType() {
        return FinServ__Revenue__c.SObjectType;
    }

    /**
     * This is used to retrieve a specific set of SObject fields
     *
     * @return List of SObjectField
    */
    public List<SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                FinServ__Revenue__c.Id,
                FinServ__Revenue__c.CRT_ReportingYear__c,
                FinServ__Revenue__c.CRT_ReportingMonth__c,
                FinServ__Revenue__c.CRT_AverageBalanceLCY__c,
                FinServ__Revenue__c.CRT_AverageBalanceZAR__c,
                FinServ__Revenue__c.CRT_ActualRevenueZAR__c,
                FinServ__Revenue__c.CRT_ActualRevenueLCY__c,
                FinServ__Revenue__c.CRT_ProductDRCRIndicator__c,
                FinServ__Revenue__c.CRT_ClientRevenue__c,
                FinServ__Revenue__c.CRT_ActiveRevenue__c
        };
    }
    /**
     * Selecting Revenues by Global Client Id and year ordered by Reporting Month descending
     * @param globalClientId set of Global Client Revenues Ids
     * @param year year for filtering
     * @return List of Revenues
    */
    public List<FinServ__Revenue__c> selectByGlobalClientAndYear(Set<Id> globalClientId, String year){
        fflib_QueryFactory factory = newQueryFactory(false, false, true)
                .setCondition('CRT_ClientRevenue__c IN :globalClientId AND CRT_ReportingYear__c LIKE :year  AND CRT_ActiveRevenue__c = true')
                .addOrdering(FinServ__Revenue__c.CRT_ReportingMonth__c, fflib_QueryFactory.SortOrder.DESCENDING, true);
        return Database.query(factory.toSOQL());
    }

    /**
     * Selecting Revenues by Record type and last modified datetime
     * @param recordTypeName record Type Name of Revenues
     * @param lastModifiedTime select all revenues modified older than this time
     * @return List of Revenues
    */    
    public String selectByRecTypeAndLastModDate(String recordTypeName, String lastModifiedTime){
        fflib_QueryFactory factory = newQueryFactory(false, false, true)
                .setCondition('RecordType.Name = \''+recordTypeName+'\' AND LastModifiedDate < '+lastModifiedTime + 'AND CRT_ActiveRevenue__c = true');
        return factory.toSOQL();
    }
}