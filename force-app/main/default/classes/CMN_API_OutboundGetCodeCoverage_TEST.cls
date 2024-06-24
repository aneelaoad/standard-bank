/**
 * @description Test class to test the OutboundGetCodeCoverage API class
 *
 * @author Accenture
 *
 * @date 2020
 */
@IsTest(SeeAllData=false)
private class CMN_API_OutboundGetCodeCoverage_TEST
{
	/**
	 * @description Emulates a successful call
	 */
	@IsTest
	private static void successfulCall()
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(CMN_API_OutboundGetCodeCoverage.SERVICE_NAME, null);

		List<CMN_API_HttpBase> httpHandlers = CMN_API_RestBaseOutboundTestHelper.successfulCall(new List<CMN_WebserviceCallQueue__c> {queueItem});
		List<CMN_API_OutboundGetCodeCoverage.CodeCoverage> codeCoverages = ((CMN_API_OutboundGetCodeCoverage)httpHandlers[0]).codeCoverages;

		System.assertNotEquals(true, codeCoverages.isEmpty(), 'No code coverages returned');
		System.assert(codeCoverages[0].percentCovered < codeCoverages[codeCoverages.size() - 1].percentCovered, 'List not sorted correctly');
	}
}