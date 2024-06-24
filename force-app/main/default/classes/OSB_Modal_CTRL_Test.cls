/**
 * @description test class for OSB_Modal_CTRL
 * @author Ephetehe Mokgopanyane (ephetehe.mokgopanyane@tetrad.co.za)
 * @date August 2020
 *
 * @LastModified May 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-21026
 * @LastModifiedReason New method for adding multiple subscribed solutions test methods
 *
 **/
@SuppressWarnings('PMD.ApexUnitTestClassShouldHaveAsserts')
@IsTest
public class OSB_Modal_CTRL_Test {
    private static final String API_URL_NAME = 'Api';
    private static final String TEST_USER_NAME = 'test@test.com';
    private static final String CASE_SUBJECT = 'OneHub - Refinitiv';
    private static final String TEST_CONTACT_FISRT_NAME = 'Test';
    private static final String TEST_CONTACT_LAST_NAME = 'Manager';
    private static final String TEST_COMPANY = 'Disney';
    private static final String TEST_SOLUTIONAME = 'FRDM';
    private static final String TEST_SHORTCUT_NAME = 'Test Shortcut';
    private static final String TEST_SHORTCUT_URL = 'Test.com';
    private static final String PING_START_VALUE = 'entryUUID=';
    private static final String PING_END_VALUE = ',ou=People,dc=sbsa,dc=com';
    private static final String TEST_PING_ID = 'samplePingId';
    private static final String TEST_STATUS_CODE = 'OK';
    private static final String TEST_SHORTCUT = 'shortcut';
    private static final String TEST_DATA = 'data';
    private static final String TEST_DATA_RECEIVED = '{shortcut=shortcut}';

    private static User testUser {
        get {
            if (testUser == null) {
                testUser = [
                    SELECT Id, ContactId, Email
                    FROM User
                    WHERE Username = :TEST_USER_NAME
                    LIMIT 1
                ];
            }
            return testUser;
        }
        set;
    }

    @TestSetup
    static void setup() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        String testPingUUID = PING_START_VALUE + TEST_PING_ID + PING_END_VALUE;

        List<SObject> customSettingsList = new List<SObject>();
        customSettingsList.addAll(TEST_DataFactory.getOsbUrls());

        CMN_WebserviceSetting__mdt settings = new CMN_WebserviceSetting__mdt();
        settings.CMN_ClientID__c = 'testclientid';
        settings.CMN_Client_Secret__c = 'testclientsecret';
        settings.DeveloperName = 'OSB_Shortcuts_API';
        settings.CMN_Path__c = 'https://api-gatewaynp.standardbank.co.za';
        insert customSettingsList;


        Contact con = (Contact) new BLD_Contact(uow)
            .pingId(testPingUUID)
            .email(TEST_USER_NAME)
            .ownerId(UserInfo.getUserId())
            .name(TEST_CONTACT_FISRT_NAME, TEST_CONTACT_LAST_NAME)
            .companyName(TEST_COMPANY)
            .account(new BLD_Account(uow))
            .getRecord();
        uow.commitWork();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            User u = (User) new BLD_USER()
                .useOneHub()
                .userName(TEST_USER_NAME)
                .contactId(con.Id)
                .commitWork()
                .getRecord();
        }
    }

    @IsTest
    static void shouldCreateUserSubscribedSolution() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(
            mocks
        );
        SEL_Contacts contactsSelector = (SEL_Contacts) mocks.mock(
            SEL_Contacts.class
        );
        ORG_Application.unitOfWork.setMock(uowMock);

        Contact idContact = initializeContact();

        Knowledge__kav article = (Knowledge__kav) new BLD_Knowledge()
            .setOSBData()
            .isComingSoon(false)
            .useSolution()
            .commitWork()
            .getRecord();


        mocks.startStubbing();
        mocks.when(contactsSelector.sObjectType())
            .thenReturn(Contact.SObjectType);
        mocks.when(
                contactsSelector.selectByIdWoSharing(new Set<Id>{ testUser.Id })
            )
            .thenReturn(new List<Contact>{ idContact });
        mocks.stopStubbing();

        Test.startTest();
        System.runAs(testUser) {
            OSB_Modal_CTRL.createUserSubscribedSolution(article.Id);
        }
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(
            fflib_ISObjectUnitOfWork.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
            .registerNew((Subscribed_Solutions__c) argument.capture());
        Subscribed_Solutions__c subscribedSolution = (Subscribed_Solutions__c) argument.getValue();
        Assert.areEqual(
            article.Id,
            subscribedSolution.Solution__c,
            'Subscribed solution has been created'
        );
    }

    @IsTest
    static void shouldCreateUserShortcutSubscribedSolution() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(
            mocks
        );
        SEL_Contacts contactsSelector = (SEL_Contacts) mocks.mock(
            SEL_Contacts.class
        );
        ORG_Application.unitOfWork.setMock(uowMock);

        Contact idContact = initializeContact();

        Knowledge__kav article = (Knowledge__kav) new BLD_Knowledge()
            .setOSBData()
            .isComingSoon(false)
            .useSolution()
            .commitWork()
            .getRecord();

        Subscribed_Solutions__c testSubscribedSolution = new Subscribed_Solutions__c();
        testSubscribedSolution.Solution__c = article.Id;
        testSubscribedSolution.Short_Cut_Name__c = TEST_SHORTCUT_NAME;
        testSubscribedSolution.Short_Cut_Redirect_URL__c = TEST_SHORTCUT_URL;
        List<Subscribed_Solutions__c> shortcuts = new List<Subscribed_Solutions__c>{
            testSubscribedSolution
        };

        
        mocks.startStubbing();
        mocks.when(contactsSelector.sObjectType())
            .thenReturn(Contact.SObjectType);
        mocks.when(
                contactsSelector.selectByIdWoSharing(new Set<Id>{ testUser.Id })
            )
            .thenReturn(new List<Contact>{ idContact });
        mocks.stopStubbing();

        Test.startTest();
        System.runAs(testUser) {
            OSB_Modal_CTRL.createUserSubscribedShorcut(shortcuts);
        }
        Test.stopTest();

        fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(
            fflib_ISObjectUnitOfWork.class
        );
        ((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1))
            .registerNew((List<Subscribed_Solutions__c>) argument.capture());
        List<Subscribed_Solutions__c> subscribedSolution = (List<Subscribed_Solutions__c>) argument.getValue();
        Assert.areEqual(
            TEST_SHORTCUT_NAME,
            subscribedSolution[0].Short_Cut_Name__c,
            'Subscribed shortcut solution has been created'
        );
    }

    @IsTest
    static void shouldCreateUserSubscribedSolutionError() {
        Knowledge__kav article = (Knowledge__kav) new BLD_Knowledge()
            .setOSBData()
            .isComingSoon(false)
            .useSolution()
            .commitWork()
            .getRecord();
        try {
            OSB_Modal_CTRL.createUserSubscribedSolution(article.Id);
        } catch (Exception e) {
            Assert.areEqual(
                'List index out of bounds: 0',
                e.getMessage(),
                'Exception thrown'
            );
        }
    }


    private static Contact initializeContact() {
        Contact con = (Contact) new BLD_Contact()
            .setOSBDefaultData(
                DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP,
                DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED
            )
            .mock();
        return con;
    }

    @isTest
    static void shouldRetrieveShortcuts() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OSB_SRV_SolutionAPI serviceMock = (OSB_SRV_SolutionAPI) mocks.mock(
            OSB_SRV_SolutionAPI.class
        );
        ORG_Application.service.setMock(
            OSB_SRV_SolutionAPI.IService.class,
            serviceMock
        );
        Map<String, Object> responseMap = new Map<String, Object>();
        Test.startTest();
        System.runAs(testUser) {
            responseMap = OSB_Modal_CTRL.viewShortcuts(TEST_SOLUTIONAME);
        }
        Test.stopTest();

        Assert.areEqual(
            TEST_DATA_RECEIVED,
            String.valueOf(responseMap.get(TEST_DATA)),
            'Shortcuts method reached and returned shortcuts'
        );
    }
}