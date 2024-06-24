/**
 * SEL_SupportServiceType Test class.
 *
 * @author Raja Kumar (raja.kumar@standardbank.co.za)
 * @date April 2023
 */
@IsTest
private class SEL_SupportServiceType_TEST {

    @IsTest
    private static void testSelectById() {
        Test.startTest();
        SEL_SupportServiceType selector = new SEL_SupportServiceType();
        List<SVC_SupportServiceTypes__c> messages = selector.selectById(new Set<Id>());
        Test.stopTest();
        Assert.areEqual(messages.isEmpty(), True);

    }

	@IsTest
    private static void testSelectByTeamIdAndServiceTier() {
        Test.startTest();
        SEL_SupportServiceType selector = new SEL_SupportServiceType();
        selector.selectByTeamIdAndServiceTier(new Set<id>(),'standard');
        List<SVC_SupportServiceTypes__c> messages = SEL_SupportServiceType.newInstance().selectByTeamIdAndServiceTier(new Set<id>(),'Standard');
        Test.stopTest();
		Assert.areEqual(messages.isEmpty(), True);
    }

    @IsTest
    private static void testSelectByServiceTypeIdTeamIdAndTier() {
        Test.startTest();
        SEL_SupportServiceType selector = new SEL_SupportServiceType();
        selector.selectByServiceTypeIdTeamIdAndTier(new Set<id>(),new Set<id>(),new Set<String>());
        List<SVC_SupportServiceTypes__c> messages = SEL_SupportServiceType.newInstance().selectByServiceTypeIdTeamIdAndTier(new Set<id>(),new Set<id>(),new Set<String>());
        Test.stopTest();
		Assert.areEqual(messages.isEmpty(), True);
    }
}