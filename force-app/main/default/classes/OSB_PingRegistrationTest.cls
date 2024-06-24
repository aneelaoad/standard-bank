/**
 * @description test Class for OSB_PingRegistration Apex Class
 * @author Ayush Garg (ayusgarg@deloitte.com)
 * @date March 2020
 */

@isTest
public with sharing class OSB_PingRegistrationTest{

    private static final String TEST_FIRST_CONTACT_LONGNAME = 'testuserlong';
    private static final String TEST_SFDC_NETWORK_ID = 'test';
    private static final String TEST_FIRST_CONTACT_FIRSTNAME = 'testFirst';
    private static final String TEST_FIRST_CONTACT_LASTNAME = 'testLast';
    private static final String TEST_FIRST_CONTACT_EMAIL = 'testuser@example.org';
    private static final String TEST_FIRST_PING_ID = 'samplePingId';
    private static final String TEST_LANGUAGE = 'en_US';
    private static final String TEST_AUTH_PROVIDER_NAME = 'ping';
    private static final String TEST_SUFFIX = '.onehub';
	private static final String TEST_NEW_USER_EMAIL = 'testnewuser@example.org';
	private static final String TEST_NEW_USER_FIRST_NAME = 'testNewFirst';
	private static final String TEST_NEW_USER_LAST_NAME = 'testNewLast';
	private static final String TEST_NEW_USER_LONG_NAME = 'testnewuserlong';
    private static final String TEST_FIRST_USER_ALIAS = 'testFirs';
    private static final String TEST_USER_NULL_CHECK = 'User should be null for internal user';
    private static final String TEST_KEY_LANGUAGE = 'language';
    private static final String TEST_KEY_NETWORK = 'sfdc_networkid';
    private static final String TEST_KEY_FIRST_NAME = 'First_name';
    private static final String TEST_KEY_LAST_NAME = 'Last_name';
    private static final String TEST_KEY_EMAIL = 'email';
    private static final String TEST_KEY_SUB = 'sub';
    private static final String TEST_KEY_ID = 'id';
    private static final String TEST_DATE_OF_BIRTH = 'DateOfBirth';
    private static final String TEST_BIRTH_DAY = '2022-04-05';
    private static final String TEST_USER_NAME = 'test@test.com';
    private static final String TEST_CONTACT_FIRST_NAME = 'Test';
    private static final String TEST_CONTACT_LAST_NAME = 'Contact';
    
    @TestSetup
    static void setup() {
        List<OSB_PingRegistrationResponse__c> osbPingRegistrationKeys = TEST_DataFactory.getOsbPingRegistrationResponseKeys();
        insert osbPingRegistrationKeys;
    }
    
    @IsTest
    public static void shouldCreateUser() {
        OSB_PingRegistration handler = new OSB_PingRegistration();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts contactsSel = (SEL_Contacts) mocks.mock(SEL_Contacts.class);

        Contact communityContact = (Contact) new BLD_Contact()
            .name(TEST_CONTACT_FIRST_NAME, TEST_CONTACT_LAST_NAME)
            .email(TEST_USER_NAME)
            .pingId(TEST_FIRST_PING_ID)
            .mock();

        mocks.startStubbing();
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSel.selectByPingUUID((Set<String>) fflib_Match.anyObject())).thenReturn(new List<Contact> {communityContact});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(contactsSel);
        ORG_Application.unitOfWork.setMock(uowMock);

        Auth.UserData sampleData = new Auth.UserData(
            TEST_USER_NAME, TEST_CONTACT_FIRST_NAME, TEST_CONTACT_LAST_NAME,
            TEST_CONTACT_FIRST_NAME + ' ' + TEST_CONTACT_LAST_NAME, TEST_USER_NAME, null,
            TEST_FIRST_CONTACT_LONGNAME, TEST_LANGUAGE, TEST_AUTH_PROVIDER_NAME,
            null, new Map < String, String >{
                TEST_KEY_LANGUAGE => TEST_LANGUAGE,
                    TEST_KEY_NETWORK => TEST_SFDC_NETWORK_ID,
                    TEST_KEY_FIRST_NAME => TEST_CONTACT_FIRST_NAME,
                    TEST_KEY_LAST_NAME => TEST_CONTACT_LAST_NAME,
                    TEST_KEY_SUB => TEST_USER_NAME,
                    TEST_KEY_ID => TEST_FIRST_PING_ID
                    });
        Test.startTest();
        User u = handler.createUser(null, sampleData);
        String userName = UTL_User.applySuffix(TEST_USER_NAME+TEST_SUFFIX);
        System.assertEquals(userName, u.userName,'Username check failed');
        System.assertEquals(TEST_USER_NAME, u.email,'User email check failed');
        System.assertEquals(TEST_CONTACT_FIRST_NAME, u.FirstName,'First name check failed');
        System.assertEquals(TEST_CONTACT_LAST_NAME, u.LastName,'Last name check failed');
        System.assertEquals(TEST_CONTACT_FIRST_NAME, u.alias,'alias check failed');
        Test.stopTest();
    }

    @IsTest
    public static void testCreateUserEMT() {
        OSB_PingRegistration handler = new OSB_PingRegistration();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts contactsSel = (SEL_Contacts) mocks.mock(SEL_Contacts.class);

        mocks.startStubbing();
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.stopStubbing();

        ORG_Application.selector.setMock(contactsSel);
        ORG_Application.unitOfWork.setMock(uowMock);

        Auth.UserData sampleData = new Auth.UserData(
            TEST_USER_NAME, TEST_CONTACT_FIRST_NAME, TEST_CONTACT_LAST_NAME,
            TEST_CONTACT_FIRST_NAME + ' ' + TEST_CONTACT_LAST_NAME, TEST_USER_NAME, null,
            TEST_FIRST_CONTACT_LONGNAME, TEST_LANGUAGE, TEST_AUTH_PROVIDER_NAME,
            null, new Map < String, String >{
                TEST_KEY_LANGUAGE => TEST_LANGUAGE,
                    TEST_KEY_NETWORK => TEST_SFDC_NETWORK_ID,
                    TEST_KEY_FIRST_NAME => TEST_CONTACT_FIRST_NAME,
                    TEST_KEY_LAST_NAME => TEST_CONTACT_LAST_NAME,
                    TEST_KEY_SUB => TEST_USER_NAME,
                    TEST_KEY_ID => TEST_FIRST_PING_ID,
                    TEST_DATE_OF_BIRTH => TEST_BIRTH_DAY
                    });
        Test.startTest();
        try{
            User u = handler.createUser(null, sampleData);
            String userName = UTL_User.applySuffix(TEST_USER_NAME+TEST_SUFFIX);
            System.assertEquals(userName, u.userName,'Username check failed');
        }catch(Exception e){
        }
        Test.stopTest();
    }
    
    @IsTest
    public static void shouldUpdateUser() {
        OSB_PingRegistration handler = new OSB_PingRegistration ();

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SEL_Contacts contactsSel = (SEL_Contacts) mocks.mock(SEL_Contacts.class);

        Contact communityContact = (Contact) new BLD_Contact()
            .name(TEST_CONTACT_FIRST_NAME, TEST_CONTACT_LAST_NAME)
            .email(TEST_USER_NAME)
            .pingId(TEST_FIRST_PING_ID)
            .mock();

        mocks.startStubbing();
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSel.selectByPingUUID((Set<String>) fflib_Match.anyObject())).thenReturn(new List<Contact> {communityContact});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(contactsSel);
        ORG_Application.unitOfWork.setMock(uowMock);
        Id uid = fflib_IDGenerator.generate(User.SObjectType);
        Test.startTest();
        Auth.UserData sampleData = new Auth.UserData(
            TEST_NEW_USER_EMAIL, TEST_NEW_USER_FIRST_NAME, TEST_NEW_USER_LAST_NAME,
            TEST_NEW_USER_FIRST_NAME+ ' ' +TEST_NEW_USER_LAST_NAME, TEST_NEW_USER_EMAIL, null, TEST_NEW_USER_LONG_NAME, TEST_LANGUAGE, TEST_AUTH_PROVIDER_NAME,
            null, new Map < String, String >{
                TEST_KEY_FIRST_NAME => TEST_NEW_USER_FIRST_NAME,
                    TEST_KEY_LAST_NAME => TEST_NEW_USER_LAST_NAME,
                    TEST_KEY_SUB => TEST_NEW_USER_EMAIL,
                    TEST_KEY_ID => TEST_FIRST_PING_ID
                    });
        handler.updateUser(uid, null, sampleData);
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerDirty((User) argument.capture());
        User updatedUser = (User) argument.getValue();
        System.assertEquals(TEST_NEW_USER_EMAIL, updatedUser.email,'Email check failed');
        System.assertEquals(TEST_NEW_USER_LAST_NAME, updatedUser.lastName,'Last name check failed');
        System.assertEquals(TEST_NEW_USER_FIRST_NAME, updatedUser.firstName,'First name check failed');
    }
    
    @IsTest
    public static void shouldNotCreateInternalUser() {
        OSB_PingRegistration handler = new OSB_PingRegistration ();
        Auth.UserData sampleData = new Auth.UserData(
                TEST_FIRST_CONTACT_EMAIL, TEST_FIRST_CONTACT_FIRSTNAME, TEST_FIRST_CONTACT_LASTNAME,
                TEST_FIRST_CONTACT_FIRSTNAME + ' ' + TEST_FIRST_CONTACT_LASTNAME, TEST_FIRST_CONTACT_EMAIL, null,
                TEST_FIRST_CONTACT_LONGNAME, TEST_LANGUAGE, TEST_AUTH_PROVIDER_NAME,
                null, new Map < String, String >{
                        TEST_KEY_LANGUAGE => TEST_LANGUAGE,
                        TEST_KEY_FIRST_NAME => TEST_FIRST_CONTACT_FIRSTNAME,
                        TEST_KEY_LAST_NAME => TEST_FIRST_CONTACT_LASTNAME,
                        TEST_KEY_EMAIL => TEST_FIRST_CONTACT_EMAIL,
                        TEST_KEY_SUB => TEST_FIRST_CONTACT_EMAIL,
                        TEST_KEY_ID => TEST_FIRST_PING_ID
                }
        );

        Test.startTest();
        User u = handler.createUser(null, sampleData);
        Test.stopTest();
        System.Assert(u==null,TEST_USER_NULL_CHECK);
    }

    @SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
    @IsTest
    public static void shouldNotUpdateUser() {
        OSB_PingRegistration handler = new OSB_PingRegistration ();
        Exception ex;

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
        SRV_Logger serviceMock = (SRV_Logger) mocks.mock(SRV_Logger.class);
        SEL_Contacts contactsSel = (SEL_Contacts) mocks.mock(SEL_Contacts.class);

        Contact inactiveCommunityContact = (Contact) new BLD_Contact()
            .name(TEST_CONTACT_FIRST_NAME, TEST_CONTACT_LAST_NAME)
            .email(TEST_USER_NAME)
            .pingId(TEST_FIRST_PING_ID)
            .communityAccessStatus(DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_INACTIVE)
            .mock();

        mocks.startStubbing();
        mocks.when(contactsSel.sObjectType()).thenReturn(Contact.SObjectType);
        mocks.when(contactsSel.selectByFirstNameLastNameEmail(
            (Set<String>) fflib_Match.anyObject(),
            (Set<String>) fflib_Match.anyObject(),
            (Set<String>) fflib_Match.anyObject()))
            .thenReturn(new List<Contact> {inactiveCommunityContact});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(contactsSel);
        ORG_Application.service.setMock(SRV_Logger.IService.class, serviceMock);
        ORG_Application.unitOfWork.setMock(uowMock);

        Id uid = fflib_IDGenerator.generate(User.SObjectType);

        Test.startTest();
        Auth.UserData sampleData = new Auth.UserData(
            TEST_NEW_USER_EMAIL, TEST_NEW_USER_FIRST_NAME, TEST_NEW_USER_LAST_NAME,
            TEST_NEW_USER_FIRST_NAME+ ' ' +TEST_NEW_USER_LAST_NAME, TEST_NEW_USER_EMAIL, null, TEST_NEW_USER_LONG_NAME, TEST_LANGUAGE, TEST_AUTH_PROVIDER_NAME,
            null, new Map < String, String >{
                TEST_KEY_FIRST_NAME => TEST_NEW_USER_FIRST_NAME,
                    TEST_KEY_LAST_NAME => TEST_NEW_USER_LAST_NAME,
                    TEST_KEY_SUB => TEST_NEW_USER_EMAIL,
                    TEST_KEY_ID => TEST_FIRST_PING_ID
                    });
        try{
            handler.updateUser(uid, null, sampleData);
        }
        catch (Exception e){
            ex=e;
        }
        Test.stopTest();
        
        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 0)).registerDirty((User) argument.capture());

        ((SRV_Logger) mocks.verify(serviceMock, 1))
                .log((Exception) fflib_Match.anyObject(), fflib_Match.anyString(), fflib_Match.anyString(), (List<String>) fflib_Match.anyObject());
    }
    
    @IsTest
    public static void shouldThrowExcepOnUpdate() {
        OSB_PingRegistration handler = new OSB_PingRegistration ();
        Id uid = fflib_IDGenerator.generate(User.SObjectType);
        Exception ex;
        Auth.UserData sampleData = new Auth.UserData(null,null,null,null,null,null,null,null,null,null, new Map < String, String >{
                TEST_KEY_FIRST_NAME => TEST_NEW_USER_FIRST_NAME,
                    TEST_KEY_LAST_NAME => TEST_NEW_USER_LAST_NAME,
                    TEST_KEY_SUB => TEST_NEW_USER_EMAIL,
                    TEST_KEY_ID => TEST_FIRST_PING_ID
                    });
        try{
           handler.updateUser(uid, null, sampleData); 
        }catch(Exception e){
           ex=e;
        }   
        system.assertEquals(ex.getMessage(), 'Contact_not_found','Exception casued');  
    }
    
    @IsTest
    public static void shouldThrowExcepOnCreate() {
        OSB_PingRegistration handler = new OSB_PingRegistration ();
        Id uid = fflib_IDGenerator.generate(User.SObjectType);
        Exception ex;
        Auth.UserData sampleData = new Auth.UserData(null,null,null,null,null,null,null,null,null,null, new Map < String, String >{
                        TEST_KEY_LANGUAGE => TEST_LANGUAGE,
                        TEST_KEY_FIRST_NAME => TEST_FIRST_CONTACT_FIRSTNAME,
                        TEST_KEY_LAST_NAME => TEST_FIRST_CONTACT_LASTNAME,
                        TEST_KEY_EMAIL => TEST_FIRST_CONTACT_EMAIL,
                        TEST_KEY_SUB => TEST_FIRST_CONTACT_EMAIL,
                        TEST_KEY_ID => TEST_FIRST_PING_ID,
                        TEST_KEY_NETWORK => TEST_FIRST_CONTACT_EMAIL
                });
        try{
           handler.createUser(null, sampleData); 
        }catch(Exception e){
           ex=e;
        }   
        system.assertEquals(ex.getMessage(), 'Contact_not_found','Exception casued');     
    }
    
}