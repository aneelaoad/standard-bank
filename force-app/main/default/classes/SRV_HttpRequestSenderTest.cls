@isTest
private class SRV_HttpRequestSenderTest {

	@isTest
	private static void shouldSendOneRequest() {
		HttpRequest mockRequest = new HttpRequest();
		mockRequest.setEndpoint('www.salesforce.com');

		SRV_HttpRequestSender.IService senderService = SRV_HttpRequestSender.newInstance();
		Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, 'OK', '', new Map<String, String> ()));

		Test.startTest();
		HttpResponse response = senderService.send(mockRequest);
		Test.stopTest();

        System.assertNotEquals(null, response);
	}
}