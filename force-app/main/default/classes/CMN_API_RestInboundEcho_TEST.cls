/**
 * @description test class to test the Inbound API call that will echo exactly what was sent
 *
 * @author Accenture
 *
 * @date 2019
 */
@IsTest(SeeAllData=false)
private class CMN_API_RestInboundEcho_TEST
{
	/**
	 * @description This method is use to test a successful call to Echo service
	 */
	@IsTest
	private static void successfulCall()
	{
		DTO_InboundTest inboundRequest = new DTO_InboundTest();
		inboundRequest.helloWorld = CMN_DAL_SObjectDomain.generateRandomName();

		String request = inboundRequest.serialize();

		RestContext.request = new RestRequest();
		RestContext.request.headers.put(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_JSON);
		RestContext.request.addParameter(CMN_DAL_SObjectDomain.generateRandomName(), CMN_DAL_SObjectDomain.generateRandomName());
		RestContext.response = new RestResponse();
		RestContext.request.requestBody = Blob.valueOf(request);

		Test.startTest();

		CMN_URL_Echo.echo();

		Test.stopTest();

		CMN_DAL_WebserviceCallQueue.checkServiceCompleted(CMN_API_RestInboundEcho.SERVICE_NAME);

		System.assertNotEquals(null, RestContext.response.responseBody, 'Response Body was not set.');
		System.assertEquals(request, RestContext.response.responseBody.toString(), 'Response does not match what was expected');
	}

	/**
	 * @description This method is use to test a failed call to Echo service
	 */
	@IsTest
	private static void failedCall()
	{
		DTO_InboundTest inboundRequest = new DTO_InboundTest();
		inboundRequest.helloWorld = CMN_DAL_SObjectDomain.generateRandomName();

		String request = inboundRequest.serialize();

		RestContext.request = new RestRequest();
		RestContext.request.headers.put(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_JSON);
		RestContext.request.addParameter(CMN_DAL_SObjectDomain.generateRandomName(), CMN_DAL_SObjectDomain.generateRandomName());
		RestContext.request.addParameter(CMN_API_HttpBaseInbound.QUERY_PARAM_ADD_STACK_TRACE, String.valueOf(true));
		RestContext.response = new RestResponse();
		RestContext.request.requestBody = Blob.valueOf(request);

		// this will result in an exception is throw
		CMN_API_HttpBaseInbound.returnErrorResponse = true;

		Test.startTest();

		CMN_URL_Echo.echo();

		Test.stopTest();

		List<CMN_WebserviceCallQueue__c> queueItems = CMN_DAL_WebserviceCallQueue.checkServiceFailedCorrectly(CMN_API_RestInboundEcho.SERVICE_NAME, CMN_UTIL_String.EMPTY);

		List<String> errors = CMN_UTIL_System.convertStringToList(queueItems[0].CMN_Errors__c, CMN_UTIL_String.CR + CMN_UTIL_String.LF);

		System.assertEquals(2, errors.size(), 'Expected Error Message and Stack Trace');
		System.assertEquals(CMN_API_HttpBaseInbound.ERROR_TEST_EXCEPTION_HANDLING, errors[0]);
	}

	private class DTO_InboundTest extends CMN_DTO_Json
	{
		public String helloWorld;
	}
}