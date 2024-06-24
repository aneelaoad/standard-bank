/**
 * This is a test class that test CMN_DAL_WebserviceCallQueue
 * @author		Emmanuel Mulea(Nocks)
 * @date	    April 2021
*/

@IsTest
public class CMN_DAL_WebserviceCallQueue_Test {
    
    /**
	* @description testmethod for runServiceNameTest
	*/
	private static void runServiceNameTest(String serviceName)
	{
		CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(serviceName);

		Test.startTest();
		CMN_FACTORY_WebserviceManager.execute(new List<CMN_WebserviceCallQueue__c> {queueItem});
		Test.stopTest();
	}
    
    /**
	* @description testmethod for successfulCall
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
	* @description testmethod for getByBatchedStatusReturnZero
	*/
	@IsTest
	private static void getByBatchedStatusReturnZero()
	{
        CMN_WebserviceCallQueue__c webserve = CMN_DAL_DataFactory.newOutboundWebserviceQueue(CMN_DAL_WebserviceCallQueue.class.getName());
        insert webserve;

        Test.startTest();
		List<CMN_WebserviceCallQueue__c> webServList = CMN_DAL_WebserviceCallQueue.getByBatchedStatus();
        CMN_DAL_WebserviceCallQueue.updateNextRetryInfo(webserve,Datetime.now());        
        System.assert(webServList.size()==0);
        System.assert(webserve.CMN_Status__c==CMN_DAL_WebserviceCallQueue.STATUS_RETRY);
        Test.stopTest();
	}
    
    /**
	* @description testmethod for failedCall
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