/**
* This is the Test class for Noknok Integration class OSB_SRV_NoknokIntegration
* 
* @author Rasmi Panthangi (rasmi.panthangi@tetrad.co.za)
* @date April 2021
* 
*/
@isTest
public class OSB_SRV_NoknokIntegration_TEST {
    
    private static final String START_OOB_REG = 'START_OOB_REG';
    private static final String NOKNOK_TOKEN ='noknokToken' ;
    private static final String TEST_DN = 'Test';
    private static final String TEST_STATUS_CODE = 'OK';
    private static final String HANDLE = 'handle';
    private static final String AUTH_HANDLE = 'authhandle';
    
    @TestSetup
    static void setup() {
        List<SObject> customSettingsList = new List<SObject>();
        customSettingsList.addAll(TEST_DataFactory.getOsbPingIntegrationKeys());
        customSettingsList.addAll(TEST_DataFactory.getOsbUrls());
        customSettingsList.addAll(TEST_DataFactory.getOsbPingIntegrationResponseKeys());
        
        insert customSettingsList;
    }
    @isTest 
    public static void getNoknokAccessToken(){
        String mockBody = '{"'+OSB_SRV_NoknokIntegration.RESPONSE_KEY_ACCESS_TOKEN+'":"'+TEST_DN+'","issued_token_type":"issued_token_type","token_type":"'+OSB_SRV_NoknokIntegration.BEARER+'","expires_in": "299"}';
        Map<String,String> mockResponseHeaders2Values = new Map<String,String>();
        mockResponseHeaders2Values.put(OSB_SRV_NoknokIntegration.HEADER_KEY_CONTENT_TYPE, OSB_SRV_NoknokIntegration.HEADER_VALUE_CONTENT_TYPE_FORM);
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, TEST_STATUS_CODE, mockBody, mockResponseHeaders2Values));
        Test.startTest();
        String accessToken = OSB_SRV_NoknokIntegration.getNoknokAccessToken();
        Test.stopTest();
        System.assertEquals(TEST_DN, accessToken);
    }
    @isTest
    public static void shouldGetQrCode() {
        
        String mockBody = '{\n'+
            '"statusCode": 4000,\n' +
            '"id": "8tRPiMmL-cnQjIRAUp6wwA",\n' +
            '"lifetimeMillis": 180000,\n' +
            '"additionalInfo": {},\n' +
            '"oobStatusHandle": "TestHandle",\n' +
            '"modeResult": {\n' +
            '"qrCode": {\n' +
            ' "qrImage": "TestQrImage"\n' +
            '},\n' +
            ' "rawData": "https://gatewaynp.standardbank.co.za:5543/npextorg/test"\n' +
            '}\n' +
            '}';
        Map<String,String> mockResponseHeaders2Values = new Map<String,String>();
        mockResponseHeaders2Values.put(OSB_SRV_NoknokIntegration.HEADER_KEY_CONTENT_TYPE, OSB_SRV_NoknokIntegration.HEADER_VALUE_CONTENT_TYPE_JSON);
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, TEST_STATUS_CODE, mockBody, mockResponseHeaders2Values));
        Test.startTest();
        Map<String, String> responseHeaders2Values = OSB_SRV_NoknokIntegration.newInstance().getNoknokQrCode();
        Test.stopTest();
        System.assertEquals('TestQrImage',responseHeaders2Values.get('qrImage'));
    }
    @isTest
    public static void shouldGetRegistrationStatus() {
        String mockBody = '{\n'+
            '"statusCode": 4000,\n'+
            '"id": "gY1uhDsIKcDkzD5PFBg2Cg",\n'+
            '"additionalInfo": {\n'+
            '"device": {\n'+
            '"id": "MTCxZKm8Ybet4RExKx7UxF2X76di0csyf1zIR4uGKx8",\n'+
            '"type": "android",\n'+
            '"info": "HMD+Global",\n'+
            '"model": "Nokia+8.1",\n'+
            '"os": "android 10",\n'+
            '"manufacturer": "HMD+Global"\n'+
            '},\n'+
            '"authenticatorsResult": [\n'+
            '{\n'+
            '"handle": "'+HANDLE+'"\n'+
            '}\n'+
            ']\n'+
            '}\n'+
            '}';
        Map<String,String> mockResponseHeaders2Values = new Map<String,String>();
        mockResponseHeaders2Values.put(OSB_SRV_NoknokIntegration.HEADER_KEY_CONTENT_TYPE, OSB_SRV_NoknokIntegration.HEADER_VALUE_CONTENT_TYPE_JSON);
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, TEST_STATUS_CODE, mockBody, mockResponseHeaders2Values));
        Test.startTest();
        Map<String, String> responseHeaders2Values = OSB_SRV_NoknokIntegration.newInstance().getRegistrationStatus(HANDLE);
        Test.stopTest();
        System.assertEquals(HANDLE,responseHeaders2Values.get(HANDLE));
    }
    @isTest
    public static void shouldGetDeviceList() {
        String mockBody = '{\n'+
            '"statusCode": 4000,\n'+
            '"id": "i6cAnFM32oqiPyKVijAUcg",\n'+
            '"registrations": [\n'+
            '{\n'+
            '"device": {\n'+
            '"id": "MTCxZKm8Ybet4RExKx7UxF2X76di0csyf1zIR4uGKx8",\n'+
            '"info": "HMD+Global",\n'+
            '"deviceType": "android",\n'+
            '"os": "android 10",\n'+
            '"manufacturer": "HMD+Global",\n'+
            '"model": "Nokia+8.1"\n'+
            '},\n'+
            '"app": {\n'+
            '"id": "android:apk-key-hash:Bc9rEk16GTEpN3bbD+4zV/H3Msk",\n'+
            '"name": "android:com.noknok.android.passport2"\n'+
            '},\n'+
            '"authenticators": [\n'+
            '{\n'+
            '"description": "Android Fingerprint",\n'+
            '"createdTimeStamp": 1601907211708,\n'+
            '"handle": "WyJ1YWZfMS4wIiwiNGU0ZSM0MDE4IiwiRlB5S2tYU092WGZPeTAxMTNDbEpXWm9LU2NmazNkYVkxWGpJaTFkRjB0dyJd",\n'+
            '"status": 1\n'+
            '}\n'+
            ']\n'+
            '}\n'+
            '],\n'+
            '"additionalInfo": {}\n'+
            '}';
        Map<String,String> mockResponseHeaders2Values = new Map<String,String>();
        mockResponseHeaders2Values.put(OSB_SRV_NoknokIntegration.HEADER_KEY_CONTENT_TYPE, OSB_SRV_NoknokIntegration.HEADER_VALUE_CONTENT_TYPE_JSON);
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, TEST_STATUS_CODE, mockBody, mockResponseHeaders2Values));
        Test.startTest();
        Map<String,Map<String,Object>> responseHeaders2Values = OSB_SRV_NoknokIntegration.newInstance().getDeviceList();
        Map<String,String> status2Id = (Map<String,String>)responseHeaders2Values.get('statusAndIdMap');
        Test.stopTest();
        System.assertEquals('4000',status2Id.get('responseStatusCodeString')); 
    }
    @isTest
    public static void shouldDeleteRegisteredDevice() {
        String mockBody = '{\n'+
            '"statusCode": 4000,\n'+
            '"id": "6KUPa6pBndTpjFmZ9VVM5g",\n'+
            '"message": "eyJwcm90b2NvbE1",\n'+
            '"additionalInfo": {}\n'+
            '}';
        Map<String,String> mockResponseHeaders2Values = new Map<String,String>();
        mockResponseHeaders2Values.put(OSB_SRV_NoknokIntegration.HEADER_KEY_CONTENT_TYPE, OSB_SRV_NoknokIntegration.HEADER_VALUE_CONTENT_TYPE_JSON);
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, TEST_STATUS_CODE, mockBody, mockResponseHeaders2Values));
        Test.startTest();
        Map<String,String> responseHeaders2Values = OSB_SRV_NoknokIntegration.newInstance().deleteRegisteredDevice(AUTH_HANDLE);
        Test.stopTest();
        System.assertEquals('4000',responseHeaders2Values.get('statusCodeString'));  
    }
    @isTest
    public static void unsuccessfulCallout() {
        String mockBody ='{\n'+
            '"statusCode": 5501,\n'+
            '"error": "invalid_request"\n'+
            '}';
        Map<String,String> mockResponseHeaders2Values = new Map<String,String>();
        mockResponseHeaders2Values.put(OSB_SRV_NoknokIntegration.HEADER_KEY_CONTENT_TYPE, OSB_SRV_NoknokIntegration.HEADER_VALUE_CONTENT_TYPE_JSON);
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(400, TEST_STATUS_CODE, mockBody, mockResponseHeaders2Values));
        Test.startTest();
        Map<String,String> responseHeaders2Values = OSB_SRV_NoknokIntegration.newInstance().deleteRegisteredDevice(AUTH_HANDLE);
        Test.stopTest();
        System.assertEquals('5501',responseHeaders2Values.get('statusCode'));  
    }
}