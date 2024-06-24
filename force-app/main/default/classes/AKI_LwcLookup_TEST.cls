/**
 * Test class for Akili LWC Lookup
 * 
 * @author Khakhu Ramakuela
 * @date October 2021
 */
@isTest
public class AKI_LwcLookup_TEST {

    /**
     * Tests that findRecordTest retrieves the relevant data
     */
    @isTest
    static void findRecordTest(){
        List<SObject> obj;
        AKI_TESTDATA.createInsights(5);
        Test.startTest();
        obj = AKI_COMP_LwcLookupController.findRecords('AI', 'Insight__c');
        Test.stopTest();
        System.assert(obj.size() >0, 'Was expecting to find at least one insight');
    }
}