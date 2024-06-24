/**
 * Selector layer class for Global_Client_Revenue__c SObject
 *
 * @author Michal Pekso (mpesko@deloittece.com)
 * @date October 2021
 */
public with sharing class SEL_GlobalClientRevenue extends fflib_SObjectSelector{
    /**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
     * @return instance of the class
     */
    public static SEL_GlobalClientRevenue newInstance() {
        return (SEL_GlobalClientRevenue) ORG_Application.selector.newInstance(Global_Client_Revenue__c.SObjectType);
    }

    /**
     * Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
     * queries.
     * @return the SObject type for the selector.
     */
    public SObjectType getSObjectType() {
        return Global_Client_Revenue__c.SObjectType;
    }

    /**
     * This is used to retrieve a specific set of SObject fields
     *
     * @return List of SObjectField
    */
    public List<SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                Global_Client_Revenue__c.Id,
                Global_Client_Revenue__c.CRT_ActualRevenueYTDZAR__c,
                Global_Client_Revenue__c.CRT_ActualRevenueYTDLCY__c,
                Global_Client_Revenue__c.CRT_AverageCreditBalanceYTDLCY__c,
                Global_Client_Revenue__c.CRT_AverageCreditBalanceYTDZAR__c,
                Global_Client_Revenue__c.CRT_AverageDebitBalanceYTDLCY__c,
                Global_Client_Revenue__c.CRT_AverageDebitBalanceYTDZAR__c
        };
    }

    /**
     * Selecting Global Client Revenue by Ids
     * @param globalClientRevenueId set of Global Client Revenues Ids
     * @return List of Global Client Revenues
    */
    public List<Global_Client_Revenue__c> selectById(Set<Id> globalClientRevenueId){
        fflib_QueryFactory factory = newQueryFactory(false, false, true)
                .setCondition('Id = :globalClientRevenueId');
        return Database.query(factory.toSOQL());
    }
}