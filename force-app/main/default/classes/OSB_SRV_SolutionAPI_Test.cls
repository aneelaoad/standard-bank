/**
* @description This is the test class for OSB_SRV_SolutionAPI.
* 
* @author Milica Milicevic(Milica.Milicevic@standardbank.co.za)
* @description Test class and methods for OSB_SRV_SolutionAPI service class.
* @date April 2023
* 
*/
@isTest
public class OSB_SRV_SolutionAPI_Test {
    private static final String TEST_ACCESS_TOKEN = 'Test';
    private static final String TEST_STATUS_CODE = 'OK';
    private static final String TEST_CONTACT_EMAIL = 'test1user@example.org';
    private static final String TEST_SOLUTION_NAME = 'Test Solution';
    private static final String TEST_PING_ID = 'samplePingId';
    private static final String TEST_SHORTCUT = 'shortcut';
    private static final String TEST_DATA = 'data';
    private static final String TEST_DATA_RECEIVED = '{shortcut=shortcut}';

    @TestSetup
    static void setup() {
        List<SObject> customSettingsList = new List<SObject>();
        customSettingsList.addAll(TEST_DataFactory.getOsbUrls());
        
        CMN_WebserviceSetting__mdt settings = new CMN_WebserviceSetting__mdt();
        settings.CMN_ClientID__c = 'testclientid';
        settings.CMN_Client_Secret__c = 'testclientsecret';
        settings.DeveloperName = 'OSB_Shortcuts_API';
        settings.CMN_Path__c = 'https://api-gatewaynp.standardbank.co.za';
        insert customSettingsList;
    }

    @isTest 
    public static void retrieveAccessToken(){
        String mockBody = '{"token_type":"'+OSB_SRV_SolutionAPI.BEARER+'","'+OSB_SRV_SolutionAPI.RESPONSE_KEY_ACCESS_TOKEN+'": "'+TEST_ACCESS_TOKEN+'","scope": "corporate","expires_in": 7200,"consented_on": 1685387551,"metadata": "error on metadata url"}';
        Map<String,String> mockResponseHeaders2Values = new Map<String,String>();
        mockResponseHeaders2Values.put(OSB_SRV_SolutionAPI.HEADER_KEY_CONTENT_TYPE, OSB_SRV_SolutionAPI.HEADER_VALUE_CONTENT_TYPE_FORM);
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, TEST_STATUS_CODE, mockBody, mockResponseHeaders2Values));
        Test.startTest();
        String accessToken = OSB_SRV_SolutionAPI.getAccessToken();
        Test.stopTest();
        Assert.areEqual(TEST_ACCESS_TOKEN, accessToken, 'Shortcuts access token received.');
    }

    @isTest
    public static void shouldRetrieveShortcuts(){
        String mockBody = '{\n'+
        '"userId":"'+TEST_PING_ID+'",\n' +
        '"email": "'+TEST_CONTACT_EMAIL+'",\n' +
        '"shopname": "'+TEST_SOLUTION_NAME+'",\n' +
        '"data": {\n' +
        ' "shortcut": "'+TEST_SHORTCUT+'"\n' +
        '}\n' +
        '}\n' +
        '}';
        Map<String,String> mockResponseHeaders2Values = new Map<String,String>();
        mockResponseHeaders2Values.put(OSB_SRV_SolutionAPI.HEADER_KEY_CONTENT_TYPE, OSB_SRV_SolutionAPI.HEADER_VALUE_CONTENT_TYPE_JSON);
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, TEST_STATUS_CODE, mockBody, mockResponseHeaders2Values));
        Test.startTest();
        Map<String, Object> response = OSB_SRV_SolutionAPI.newInstance().getShortcutsAvailable(TEST_PING_ID,TEST_CONTACT_EMAIL,TEST_SOLUTION_NAME);
        Test.stopTest();
        Assert.areEqual(TEST_DATA_RECEIVED, String.valueOf(response.get(TEST_DATA)), 'Shortcut data received.');

    }

}