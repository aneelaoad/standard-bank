/**
 * SEL_ServiceTypes Test class.
 *
 * @author Raja Kumar (raja.kumar@standardbank.co.za)
 * @date April 2023
 */
@IsTest
private class SEL_ServiceTypes_TEST {

    @IsTest
    private static void testSelectById() {
        Test.startTest();
        SEL_ServiceTypes selector = new SEL_ServiceTypes();
        selector.selectById(new Set<Id>());
        List<Service_Type__c> messages = SEL_ServiceTypes.newInstance().selectById(new Set<Id>());
        Test.stopTest();
        Assert.areEqual(messages.isEmpty(), True);

    }

}