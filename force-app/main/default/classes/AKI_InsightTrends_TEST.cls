/**
 * Test class for Akili Trends
 * 
 * @author Khakhu Ramakuela
 * @date October 2021
 */
@isTest
public with sharing class AKI_InsightTrends_TEST {
    
    /**
     * Tests that getOpportunityState retrieves the relevant data for all cases
     */
    @isTest
    static void getOpportunityStateTest()
    {
        List<AggregateResult> o7;
        List<AggregateResult> o14;
        List<AggregateResult> o30;
        AKI_TestData.createOpp(5);
        Test.startTest();
        o7 = AKI_COMP_InsightTrends.getOpportunityState(7);
        o14 = AKI_COMP_InsightTrends.getOpportunityState(14);
        o30 = AKI_COMP_InsightTrends.getOpportunityState(30);
        Test.stopTest();
        System.assert(o7.size() > 0, 'Was expecting to find at least one opportunity');
        System.assert(o14.size() > 0, 'Was expecting to find at least one opportunity');
        System.assert(o30.size() > 0, 'Was expecting to find at least one opportunity');
    }

    /**
     * Tests that getSnoozedInsights retrieves the relevant data for all cases
     */
    @isTest
    static void getSnoozedInsightsTest()
    {
        List<AggregateResult> i7;
        List<AggregateResult> i14;
        List<AggregateResult> i30;
        AKI_TestData.createSnoozedInsights(5);
        Test.startTest();
        i7 = AKI_COMP_InsightTrends.getSnoozedInsights(7);
        i14 = AKI_COMP_InsightTrends.getSnoozedInsights(14);
        i30 = AKI_COMP_InsightTrends.getSnoozedInsights(30);
        Test.stopTest();
        System.assert(i7.size() > 0, 'Was expecting to find at least one insight');
        System.assert(i14.size() > 0, 'Was expecting to find at least one insight');
        System.assert(i30.size() > 0, 'Was expecting to find at least one insight');
    }

    /**
     * Tests that getInsightsPerClient retrieves the relevant data for all cases
     */
    @isTest
    static void getInsightsPerClientTest()
    {
        List<AggregateResult> i7;
        List<AggregateResult> i14;
        List<AggregateResult> i30;
        AKI_TestData.createInsightsWithClients(5);
        Test.startTest();
        i7 = AKI_COMP_InsightTrends.getInsightsPerClient(7);
        i14 = AKI_COMP_InsightTrends.getInsightsPerClient(14);
        i30 = AKI_COMP_InsightTrends.getInsightsPerClient(30);
        Test.stopTest();
        System.assert(i7.size() > 0, 'Was expecting to find at least one insight');
        System.assert(i14.size() > 0, 'Was expecting to find at least one insight');
        System.assert(i30.size() > 0, 'Was expecting to find at least one insight');
    }

    /**
     * Tests that getValuableInsights retrieves the relevant data for all cases
     */
    @isTest
    static void getValuableInsightsTest()
    {
        List<AggregateResult> ins;
        List<Insight_Action__c> ans=AKI_TestData.createValIns(5);
        Test.startTest();
        ins = AKI_COMP_InsightTrends.getValuableInsights();
        Test.stopTest();
        System.assert(ins.size() > 0, 'Was expecting to find at least one insight action');
    }
}