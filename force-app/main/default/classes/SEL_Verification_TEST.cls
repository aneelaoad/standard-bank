/**
 * @description: SFP-25090 - unit test class for the selector class
 *
 * @see SEL_Verification
 *
 * @author Mthobisi Ndlovu
 *
 * @date July 2023
 */
@IsTest
private class SEL_Verification_TEST
{
	@IsTest
	static void testSelectByApplication()
	{
		SEL_Verification selector = new SEL_Verification();
		Test.startTest();
		List<Verification__c> verifications = selector.selectByApplication(
				new Set<Id>
				{
						CMN_DAL_SObjectDomain.generateRandomSObjectId(Verification__c.SObjectType)
				}
		);
		Test.stopTest();
		Assert.isTrue(verifications.isEmpty(), 'The list is not empty');
	}

	@IsTest
	static void testSelectByContact()
	{
		SEL_Verification selector = new SEL_Verification();
		Test.startTest();
		List<Verification__c> verifications = selector.selectByContact(
				new Set<Id>
				{
						CMN_DAL_SObjectDomain.generateRandomSObjectId(Verification__c.SObjectType)
				}
		);
		Test.stopTest();
		Assert.isTrue(verifications.isEmpty(), 'The list is not empty');
	}
}