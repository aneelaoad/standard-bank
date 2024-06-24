/**
 * @description Test class for OSB_NewDeviceModal_CTRL
 *
 * @author Rasmi Panthangi (rasmi.panthangi@tetrad.co.za)
 * @date April 2021
 *
 * @LastModified May 2023
 * @author Milica Milicevic (milica.milicevic@standardbank.co.za)
 * @UserStory SFP-21026
 * @LastModifiedReason Update to test classes and new test method to accomodate flagging contacts
 *
 */
@isTest
public class OSB_NewDeviceModal_CTRL_TEST {
    private static final String TEST_USER_NAME = 'caseTest@ccc.com';
    public static final String OOB_STATUS_HANDLE = 'oobStatusHandle';
    public static final String TEST_USER = 'testUser';
    public static final String TEST_ORG_EMAIL = '@testorg.com';
    
    public static final String TEST_FLAG_VALUE = 'Hide MFA';
    public static final String TEST_FLAG_DEVICE_LINKED_VALUE = 'Device Linked to MFA';
    public static final Boolean TEST_FLAG_TRUE = true;

    @isTest
    static void shouldCheckLoginStatus() {
        Test.startTest();
        Boolean isLoggedIn = OSB_NewDeviceModal_CTRL.isUserLoggedIn();
        Test.stopTest();
        Assert.areEqual(isLoggedIn, true, 'User is logged in');
    }

    @isTest
    static void shouldGetQrCode() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OSB_SRV_NoknokIntegration serviceMock = (OSB_SRV_NoknokIntegration) mocks.mock(
            OSB_SRV_NoknokIntegration.class
        );
        ORG_Application.service.setMock(
            OSB_SRV_NoknokIntegration.IService.class,
            serviceMock
        );

        Test.startTest();
        Map<String, String> responseMap = OSB_NewDeviceModal_CTRL.getQrCodeDetails();
        Test.stopTest();
        Assert.areEqual(
            'TestQrImage',
            responseMap.get('qrImage'),
            'QR Image received from Nok Nok'
        );
    }

    @isTest
    static void shouldGetStatusofRegistration() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        OSB_SRV_NoknokIntegration serviceMock = (OSB_SRV_NoknokIntegration) mocks.mock(
            OSB_SRV_NoknokIntegration.class
        );
        ORG_Application.service.setMock(
            OSB_SRV_NoknokIntegration.IService.class,
            serviceMock
        );

        Test.startTest();
        Map<String, String> responseMap = OSB_NewDeviceModal_CTRL.getStatusofRegistration(
            OOB_STATUS_HANDLE
        );
        Test.stopTest();
        Assert.areEqual(
            OOB_STATUS_HANDLE,
            responseMap.get('handle'),
            'Registration Status received'
        );
    }

    @IsTest
    static void shouldFlagContact() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(
            mocks
        );
        SEL_Contacts contactsSelector = (SEL_Contacts) mocks.mock(
            SEL_Contacts.class
        );

        Account testAcc = (Account) new BLD_Account().useCommB().mock();

        Contact nominatedPerson = (Contact) new BLD_Contact()
            .setOSBDefaultData(
                DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP,
                DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED
            )
            .accountId(testAcc.Id)
            .contactCategory('Staff')
            .mock();

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User u = (User) new BLD_USER(uow)
            .userName(TEST_USER_NAME + '1')
            .useClientServiceUser()
            .syncContact()
            .getRecord();
        uow.commitWork();

        System.runAs(u) {
            mocks.startStubbing();
            mocks.when(contactsSelector.sObjectType())
                .thenReturn(Contact.SObjectType);
            mocks.when(contactsSelector.selectByUserId(new Set<Id>{ u.id }))
                .thenReturn(new List<Contact>{ nominatedPerson });
            mocks.stopStubbing();

            ORG_Application.unitOfWork.setMock(uowMock);
            ORG_Application.selector.setMock(contactsSelector);

            Test.startTest();
            String approveResult = OSB_NewDeviceModal_CTRL.flagContact(
                TEST_FLAG_VALUE,
                TEST_FLAG_TRUE
            );
            String approveResultwithMultipleFeatures = OSB_NewDeviceModal_CTRL.flagContact(
                TEST_FLAG_DEVICE_LINKED_VALUE,
                TEST_FLAG_TRUE
            );
            Test.stopTest();

            Assert.areEqual(
                approveResult,
                OSB_NewDeviceModal_CTRL.MFA_UPDATED_SUCCESS,
                'Successful result from flagged contact received'
            );
            Assert.areEqual(
                true,
                nominatedPerson.Manage_Site_Features__c.contains(
                    TEST_FLAG_VALUE
                ),
                'Contacts manage feature contains Hide MFA'
            );
            Assert.areEqual(
                true,
                nominatedPerson.Manage_Site_Features__c.contains(
                    TEST_FLAG_DEVICE_LINKED_VALUE
                ),
                'Contacts manage feature contains Device linked to MFA'
            );
            Assert.areEqual(
                approveResultwithMultipleFeatures,
                OSB_NewDeviceModal_CTRL.MFA_UPDATED_SUCCESS,
                'Successful result from flagged contact received'
            );
        }

    }
}