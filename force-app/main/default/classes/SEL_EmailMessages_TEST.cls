/**
 * SEL_EmailMessages Test class.
 *
 * @author Kyle Cockcroft (kcockcroft@deloitte.co.za)
 * @date 2019-04-24
 */
@IsTest
private class SEL_EmailMessages_TEST {

    @IsTest
    private static void testSelectorMethods() {
        Test.startTest();
        SEL_EmailMessages selector = new SEL_EmailMessages();
        selector.selectByParentId(new Set<Id>());
        List<EmailMessage> messages = selector.selectById(new Set<Id>());
        Test.stopTest();
        Assert.areEqual(messages.isEmpty(), True);

    }

	@IsTest
    private static void testSelectByThreadIdentifier() {
        Test.startTest();
        SEL_EmailMessages selector = new SEL_EmailMessages();
        selector.selectByThreadIdentifier(new Set<string>());
        List<EmailMessage> messages = SEL_EmailMessages.newInstance().selectByThreadIdentifier(new Set<string>());
        Test.stopTest();
		Assert.areEqual(messages.isEmpty(), True);
    }

}