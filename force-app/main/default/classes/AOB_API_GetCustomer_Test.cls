/**
* @description Test class to test the Outbound API call
*
* 
*
* @author Nomcebo Nzimande
*
* @date Nov 23th 2022
*/
@IsTest
public class AOB_API_GetCustomer_Test {
    
    /**
* @description Tests to see if the getBaseURL works as expected*/
    
    @IsTest
    private static void getBaseUrl() {
        AOB_API_GetCustomer service = new AOB_API_GetCustomer('');
        Test.startTest();
        String baseUrl = service.getBaseUrl();
        Test.stopTest();
        Assert.areNotEqual(
            service.getWebServiceEndPoint(),
            baseUrl,
            'Invalid base URL'
        );
    }
    
    /**
* @description Tests to see if the getVerb works as expected
*/
    @IsTest
    private static void getVerb() {
        AOB_API_GetCustomer service = new AOB_API_GetCustomer('');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new CMN_API_HttpBaseOutboundMock());
        String verb = service.getVerb();
        string verb1=service.getResponseBody();
        string verb2=service.getQueryParameters();
        Test.stopTest();
        Assert.areEqual(verb, 'GET', 'Invalid Verb');
    }
    
    /* * @description Tests to see if the triggeringObjectRequired works as expected*/
    
    @IsTest
    private static void triggeringObjectRequired_Test() {
        AOB_API_GetCustomer service = new AOB_API_GetCustomer('');
        try{
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CMN_API_HttpBaseOutboundMock());
            Boolean triggerObj = service.triggeringObjectRequired(); 
            Test.stopTest();
            Assert.areEqual(triggerObj, false, 'Invalid triggering object');
        }
        catch(exception ex){
            Assert.areEqual(null, ex.getMessage());
        }
    }
    
    
    
    /* * @description Tests to perform a test for the API Mock*/
    
    @IsTest
    private static void Getcustomer_Test() {
        AOB_API_GetCustomer customerServiceCall = new AOB_API_GetCustomer('');
        try{
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new CMN_API_HttpBaseOutboundMock());
            customerServiceCall.process(
            CMN_DAL_DataFactory.newWebserviceQueue(AOB_API_GetCustomer.SERVICE_NAME));
            AOB_API_GetCustomer.DTO_Response result = (AOB_API_GetCustomer.DTO_Response) customerServiceCall.baseResponseDTO;
            Test.stopTest();
            Assert.areNotEqual(result, null);
        }
        catch(exception ex){
            Assert.areNotEqual(null, ex.getMessage());
        }
    }
    
}