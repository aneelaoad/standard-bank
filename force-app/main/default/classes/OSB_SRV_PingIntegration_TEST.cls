/**
 * Test Class Class for OSB_SRV_PingIntegration
 * 
 * @author Ayush Garg (ayusgarg@deloitte.com)
 * @date March 2020
 * 
 */
@isTest
public class OSB_SRV_PingIntegration_TEST {
    private static final String TEST_ACCESS_TOKEN = 'dummyaccesstoken';
    private static final String TEST_SFDC_NETWORK_ID = 'test';
    private static final String TEST_FIRST_CONTACT_EMAIL = 'test1user@example.org';
    private static final String TEST_NEW_CONTACT_FIRSTNAME = 'newFirst';
    private static final String TEST_NEW_CONTACT_LASTNAME = 'newLast';
    private static final String TEST_NEW_CONTACT_PHONE = '1234567809';
    private static final String TEST_NEW_CONTACT_TITLE = 'newTitle';
    private static final String TEST_NEW_CONTACT_ORGANIZATION = 'newOrg';
    private static final String TEST_NEW_CONTACT_INDUSTRY = 'Agriculture';
    private static final String TEST_NEW_CONTACT_COUNTRY_CODE = 'Afghanistan    +93';
    private static final String TEST_DN = 'TestDn';
    private static final String TEST_PASSWORD = 'Popcorn*963';
    private static final String TEST_STATUS_CODE = 'OK';
    private static final String TEST_STATUS_CODE_BAD_REQUEST = 'Bad Request Error';
    
    @TestSetup
    static void setup() {
        List<SObject> customSettingsList = new List<SObject>();
        customSettingsList.addAll(TEST_DataFactory.getOsbPingIntegrationKeys());
        customSettingsList.addAll(TEST_DataFactory.getOsbUrls());
        customSettingsList.addAll(TEST_DataFactory.getOsbPingIntegrationResponseKeys());

        insert customSettingsList;
    }
    
    @isTest
    static void shouldUpdateUserProfile(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts contactsSel = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        
        Contact communityContact = (Contact) new BLD_Contact()
            .pingId(TEST_DN)
            .mock();
        
        Map<String, String> mockResponseHeaders = new Map<String, String>();
        mockResponseHeaders.put(OSB_SRV_PingIntegration.HEADER_KEY_CONTENT_TYPE, OSB_SRV_PingIntegration.HEADER_VALUE_CONTENT_TYPE_JSON);
		Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, TEST_STATUS_CODE, TEST_SFDC_NETWORK_ID,mockResponseHeaders));
        
        mocks.startStubbing();
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSel.selectByNameEmailPingIdWoSharing((Set<String>) fflib_Match.anyObject(),(Set<String>) fflib_Match.anyObject())).thenReturn(new List<Contact> {communityContact});
        mocks.stopStubbing();
        
        ORG_Application.selector.setMock(contactsSel);
        ORG_Application.unitOfWork.setMock(uowMock);
        
        Map<String, String> userDetailMap = new Map<String, String>();
        userDetailMap.put('givenName', TEST_NEW_CONTACT_FIRSTNAME);
        userDetailMap.put('familyName', TEST_NEW_CONTACT_LASTNAME);
        userDetailMap.put('industry', TEST_NEW_CONTACT_INDUSTRY);
        userDetailMap.put('phoneNumber', TEST_NEW_CONTACT_PHONE);
        userDetailMap.put('organization', TEST_NEW_CONTACT_ORGANIZATION);
        userDetailMap.put('countryCode', TEST_NEW_CONTACT_COUNTRY_CODE);
        userDetailMap.put('title', TEST_NEW_CONTACT_TITLE);
        Test.startTest();
        OSB_SRV_PingIntegration.newInstance().updateUserProfile(userDetailMap);
        Test.stopTest();
        
        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerDirty((Contact) argument.capture());
        Contact updatedContact = (Contact) argument.getValue();
        System.assertEquals(TEST_NEW_CONTACT_FIRSTNAME, updatedContact.FirstName);
        System.assertEquals(TEST_NEW_CONTACT_LASTNAME, updatedContact.LastName);
        System.assertEquals(TEST_NEW_CONTACT_PHONE, updatedContact.Phone);
        System.assertEquals(TEST_NEW_CONTACT_ORGANIZATION, updatedContact.OSB_Company_name__c);
    }
    
    @isTest
    static void shouldGetUserDetails(){
        String mockBody = '{"Industry": "'+TEST_NEW_CONTACT_INDUSTRY+'","SB-SurName": "'+TEST_NEW_CONTACT_LASTNAME+'", "SB-CellPhone": "'+TEST_NEW_CONTACT_PHONE+'","CountryCode": "'+TEST_NEW_CONTACT_COUNTRY_CODE+'","title": ["'+TEST_NEW_CONTACT_TITLE+'"],"SB-FirstName": "'+TEST_NEW_CONTACT_FIRSTNAME+'","o": ["'+TEST_NEW_CONTACT_ORGANIZATION+'"], "_dn": "'+TEST_DN+'","SB-EmailVerificationStatus": false, "uid": ["'+TEST_FIRST_CONTACT_EMAIL+'"]}';
        Map<String,String> mockResponseHeaders = new Map<String,String>();
        mockResponseHeaders.put(OSB_SRV_PingIntegration.HEADER_KEY_CONTENT_TYPE, OSB_SRV_PingIntegration.HEADER_VALUE_CONTENT_TYPE_JSON);
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, TEST_STATUS_CODE, mockBody,mockResponseHeaders));
        Test.startTest();
        Map<String,String> responseMap = OSB_SRV_PingIntegration.newInstance().getUserDetails();
        Test.stopTest();
        System.assertEquals(TEST_NEW_CONTACT_FIRSTNAME, responseMap.get('givenName'));
    }
    
    @isTest
    static void shouldCreateUser(){
        Contact communityContact = (Contact) new BLD_Contact().mock();
        String mockBody = '{"'+OSB_SRV_PingIntegration.RESPONSE_KEY_DN+'": "'+TEST_DN+'"}';
        Map<String,String> mockResponseHeaders = new Map<String,String>();
        mockResponseHeaders.put(OSB_SRV_PingIntegration.HEADER_KEY_CONTENT_TYPE, OSB_SRV_PingIntegration.HEADER_VALUE_CONTENT_TYPE_JSON);
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(201, TEST_STATUS_CODE, mockBody,mockResponseHeaders));
        Map<String, Object> attributes = new Map<String, Object>();
        attributes.put('Contact',communityContact);
        attributes.put('userPassword',TEST_PASSWORD);
        Test.startTest();
        String pingID = OSB_SRV_PingIntegration.newInstance().createUser(attributes);
        Test.stopTest();
        System.assertEquals(TEST_DN, pingID);
    }
    
    @isTest
    static void shouldNotCreateUser(){
        Contact communityContact = (Contact) new BLD_Contact().mock();
        String mockBody ='{"'+OSB_SRV_PingIntegration.ERROR_DETAIL_KEY+'": [{"code": "'+TEST_STATUS_CODE_BAD_REQUEST+'"}]}';
        Map<String,String> mockResponseHeaders = new Map<String,String>();
        mockResponseHeaders.put(OSB_SRV_PingIntegration.HEADER_KEY_CONTENT_TYPE, OSB_SRV_PingIntegration.HEADER_VALUE_CONTENT_TYPE_JSON);
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(400, TEST_STATUS_CODE_BAD_REQUEST, mockBody,mockResponseHeaders));
        Map<String, Object> attributes = new Map<String, Object>();
        attributes.put('Contact',communityContact);
        attributes.put('userPassword',TEST_PASSWORD);
        Exception actualException;
        Test.startTest();
        try {
            OSB_SRV_PingIntegration.newInstance().createUser(attributes);
        } catch (Exception e) {
            actualException = e;
        }
        Test.stopTest();
        System.assertEquals(true, actualException.getMessage().contains(TEST_STATUS_CODE_BAD_REQUEST));
    }
    
    @isTest
    static void shouldGetUser(){
        String mockBody = '{"'+OSB_SRV_PingIntegration.EMBEDDED+'": {"'+OSB_SRV_PingIntegration.ENTRIES+'": [{"'+OSB_SRV_PingIntegration.RESPONSE_KEY_DN+'": "'+TEST_DN+'"}]}}';
        Map<String,String> mockResponseHeaders = new Map<String,String>();
        mockResponseHeaders.put(OSB_SRV_PingIntegration.HEADER_KEY_CONTENT_TYPE, OSB_SRV_PingIntegration.HEADER_VALUE_CONTENT_TYPE_JSON);
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, TEST_STATUS_CODE, mockBody, mockResponseHeaders));
        Test.startTest();
        String pingID = OSB_SRV_PingIntegration.newInstance().getUser(TEST_FIRST_CONTACT_EMAIL);
        Test.stopTest();
        System.assertEquals(TEST_DN, pingID);
    }

    @isTest
    static void shouldGetAndUpdateUser(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts contactsSel = (SEL_Contacts) mocks.mock(SEL_Contacts.class);
        Boolean result;
        Contact communityContact = (Contact) new BLD_Contact()
            .pingId(TEST_DN)
            .mock();
        
        String mockBody = '{"'+OSB_SRV_PingIntegration.EMBEDDED+'": {"'+OSB_SRV_PingIntegration.ENTRIES+'": [{"'+OSB_SRV_PingIntegration.RESPONSE_KEY_DN+'": "'+TEST_DN+'"}]}}';
        Map<String,String> mockResponseHeaders = new Map<String,String>();
        mockResponseHeaders.put(OSB_SRV_PingIntegration.HEADER_KEY_CONTENT_TYPE, OSB_SRV_PingIntegration.HEADER_VALUE_CONTENT_TYPE_JSON);
        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, TEST_STATUS_CODE, mockBody, mockResponseHeaders));
        
        ORG_Application.unitOfWork.setMock(uowMock);

        Test.startTest();
        result = OSB_SRV_PingIntegration.newInstance().checkUserAndUpdate(TEST_DN,communityContact);
        Test.stopTest();
        
        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerDirty((Contact) argument.capture());
        Contact updatedContact = (Contact) argument.getValue();
        System.assertEquals(true, result);
    }
}