/**
* @description       : SFP-19834  Test class of PP_UserRegistration_CTRL controller class
* @author            : Areeba Khan (areeba.khan@standardbank.co.za)
* @group             : Cloudsmiths
* @last modified on  : 02-13-2024
* @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)
*/
@IsTest(Isparallel=true)
public with sharing class PP_UserRegistration_CTRL_Test {
    private static final String TEST_USER_NAME = 'testsgfdgds646@test.com';
    private static final String TEST_ADMIN_NAME = 'testgfdgsd335dssfs@test.com';
    private static final String TEST_CONTACT_EMAIL = 'test@Contact.com';
    private static final String TEST_USER_FIRSTNAME = 'User';
    private static final String TEST_CONTACT_ACCESS_ROLE = 'Authorised Person';
    private static final String TEST_CONTACT_FIRST_NAME = 'Test';
    private static final String TEST_CONTACT_MOBILE_NUMBER = '5236332552';
    private static final String TEST_CONTACT_LAST_NAME = 'Manager';
    
    private static Contact testContact {
        get {
            if (testContact == null) {
                testContact = [SELECT Id, MobilePhone, FirstName, LastName, Name, Email FROM Contact WHERE Email = :TEST_CONTACT_EMAIL LIMIT 1];
            }
            return testContact;
        }
        set;
    }
    
    @TestSetup
    static void setup() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWorkWithKnowledge();
        new BLD_Contact(uow)
            .name(TEST_CONTACT_FIRST_NAME, TEST_CONTACT_LAST_NAME)
            .communityAccessManager(new BLD_Contact(uow).communityAccessRole(TEST_CONTACT_ACCESS_ROLE))
            .email(TEST_CONTACT_EMAIL)
            .communityAccessRole(TEST_CONTACT_ACCESS_ROLE)
            .account(new BLD_Account(uow))
            .getRecord();
        uow.commitWork();
    }
    
    /**
* @description Called from the "Send Registration Invite" button and launched in a flow.
* @author Areeba Khan
*/
    @isTest
    public static void testSendRegistrationInvitationPass() {
        Test.startTest();
        Boolean encryptedURLSent = PP_UserRegistration_CTRL.sendRegistrationInvitation(testContact.id);
        Test.stopTest();
        Assert.areEqual(true, encryptedURLSent, 'results are not true');
    }
    /**
* @description Called from the "Send Registration Invite" button and launched in a flow.
* @author Areeba Khan
*/
    @isTest
    public static void testSendRegistrationInvitationFail() {
        try {
            Test.startTest();
            Boolean encryptedURLSent = PP_UserRegistration_CTRL.sendRegistrationInvitation(null);
            Test.stopTest();
        } catch (Exception ex) {
            Assert.areEqual(
                'Failed to send an invite due to technical issue.',
                ex.getMessage(),
                'Exception messages are not identical'
            );
        }
    }
    
    /**
* @description Validate link
* @author Areeba Khan
*/
    @isTest
    public static void testLinkNotValidFail() {
        SRV_Encryption encryptionService = (SRV_Encryption) SRV_Encryption.newInstance().initialise('Partner_Connect_User_Registration');
        //Construct invite to be encrypted.
        PP_UserRegistration_CTRL.Invitation invite = new PP_UserRegistration_CTRL.Invitation(
            testContact.id,
            testContact.Email,
            testContact.FirstName,
            testContact.LastName,
            testContact.MobilePhone,
            System.now().addHours(0)
        );
        
        String encryptedInvite = encryptionService.encryptWithManagedIV(JSON.serialize(invite));
        
        try {
            Test.startTest();
            PP_UserRegistration_CTRL.validateLink(encryptedInvite);
            Test.stopTest();
        } catch (Exception ex) {
            Assert.areEqual(
                'User registration link not valid, expired or there was a technical issue.',
                ex.getMessage(),
                'Exception messages are not identical'
            );
        }
    }
    @isTest
    public static void testValidateLinkPass() {
        SRV_Encryption encryptionService = (SRV_Encryption) SRV_Encryption.newInstance().initialise('Partner_Connect_User_Registration');
        //Construct invite to be encrypted.
        PP_UserRegistration_CTRL.Invitation invite = new PP_UserRegistration_CTRL.Invitation(
            testContact.id,
            testContact.Email,
            testContact.FirstName,
            testContact.LastName,
            testContact.MobilePhone,
            System.now().addHours(1)
        );
        
        String encryptedInvite = encryptionService.encryptWithManagedIV(JSON.serialize(invite));
        
        Test.startTest();
        PP_UserRegistration_CTRL.Invitation returnedValue = PP_UserRegistration_CTRL.validateLink(encryptedInvite);
        Test.stopTest();
        Assert.isNotNull(returnedValue, 'The value is null');
    }
    
    /**
* @description Test method to validate and search for customer email address
* @author Areeba Khan | 29-06-2023
*/
    @isTest
    public static void testValidateEmailAddressPass() {
        SRV_Encryption encryptionService = (SRV_Encryption) SRV_Encryption.newInstance().initialise('Partner_Connect_User_Registration');
        //Construct invite to be encrypted.
        PP_UserRegistration_CTRL.Invitation invite = new PP_UserRegistration_CTRL.Invitation(
            testContact.id,
            testContact.Email,
            testContact.FirstName,
            testContact.LastName,
            testContact.MobilePhone,
            System.now().addHours(0)
        );

        String encryptedInvite = encryptionService.encryptWithManagedIV(JSON.serialize(invite));
        
        PP_UserRegistrationSingleRequestMock fakeAccessToken = new PP_UserRegistrationSingleRequestMock(
            200,
            'Complete',
            '{"access_token":"fakeToken"}',
            null
        );
        
        PP_UserRegistrationSingleRequestMock fakeSearchCustomerSize = new PP_UserRegistrationSingleRequestMock(200, 'Complete', '{"size":1}', null);
        
        Map<String, HttpCalloutMock> endpointsToTest = new Map<String, HttpCalloutMock>();
        endpointsToTest.put('callout:PP_Ping_Get_Token/as/token.oauth2', fakeAccessToken);
        endpointsToTest.put(
            'callout:PP_Ping_Directory_Service/directory/v1/ou=People,dc=sbsa,dc=com/subtree?searchScope=wholeSubtree&filter=SB-mail%20eq%20%22' +
            testContact.Email +
            '%22',
            fakeSearchCustomerSize
        );

        HttpCalloutMock multiCalloutMock = new PP_UserRegistrationMockHttpResponse(endpointsToTest);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.startTest();
        Boolean b = PP_UserRegistration_CTRL.validateEmailAddress(encryptedInvite, testContact.Email);
        Test.stopTest();
        Assert.isTrue(b, 'Results are not True.');
    }
    
    
    /**
* @description Test method to validate and search for customer email address
* @author Areeba Khan | 29-06-2023
*/
    @isTest
    public static void testValidateEmailAddressFail() {
        SRV_Encryption encryptionService = (SRV_Encryption) SRV_Encryption.newInstance().initialise('Partner_Connect_User_Registration');
        //Construct invite to be encrypted.
        PP_UserRegistration_CTRL.Invitation invite = new PP_UserRegistration_CTRL.Invitation(
            testContact.id,
            testContact.Email,
            testContact.FirstName,
            testContact.LastName,
            testContact.MobilePhone,
            System.now().addHours(0)
        );
        
        String encryptedInvite = encryptionService.encryptWithManagedIV(JSON.serialize(invite));
        
        PP_UserRegistrationSingleRequestMock fakeAccessToken = new PP_UserRegistrationSingleRequestMock(
            200,
            'Complete',
            '{"access_token":"fakeToken"}',
            null
        );
        
        PP_UserRegistrationSingleRequestMock fakeSearchCustomerSize = new PP_UserRegistrationSingleRequestMock(200, 'Complete', '{"size":1}', null);
        
        Map<String, HttpCalloutMock> endpointsToTest = new Map<String, HttpCalloutMock>();
        endpointsToTest.put('callout:PP_Ping_Base_Service/as/token.oauth2', fakeAccessToken);
        endpointsToTest.put(
            'callout:PP_Ping_Directory_Service/directory/v1/ou=People,dc=sbsa,dc=com/subtree?searchScope=wholeSubtree&filter=SB-mail%20eq%20%22' +
            testContact.Email +
            '%22',
            fakeSearchCustomerSize
        );
        HttpCalloutMock multiCalloutMock = new PP_UserRegistrationMockHttpResponse(endpointsToTest);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        try{
            Test.startTest();
            Boolean b = PP_UserRegistration_CTRL.validateEmailAddress(encryptedInvite, null);
            Test.stopTest();
        } catch (Exception ex) {
            Assert.areEqual(
                'Provided email address does not match invitation or there was a technical issue.',
                ex.getMessage(),
                'Exception messages are not identical'
            );
        }
    }
    /**
* @description Test method to Register User
* @author Areeba Khan | 29-06-2023
*/
    @isTest
    public static void testRegisterUserPass() {
        string flowId = 'uRvOJ';
        
        Map<string, string> userData = new Map<string, string>();
        userData.put('firstName', 'fname');
        userData.put('lastName', 'lname');
        userData.put('mobileNumber', '5233662552');
        userData.put('emailAddress', 'fakeemail@gmail.com');
        userData.put('userName', 'fakeusername');
        userData.put('password', 'fakepassword');
        
        PP_UserRegistrationSingleRequestMock fakeAccessToken = new PP_UserRegistrationSingleRequestMock(
            200,
            'Complete',
            '{"access_token":"fakeToken", "id":"' + flowId + '"}',
            new Map<string, string>{ 'Set-Cookie' => 'fakeCookie' }
        );
        PP_UserRegistrationSingleRequestMock fakeFlowId = new PP_UserRegistrationSingleRequestMock(
            200,
            'Complete',
            '{"id":"' + flowId + '"}',
            new Map<string, string>{ 'Set-Cookie' => 'fakeCookie' }
        );
        PP_UserRegistrationSingleRequestMock fakeInitialiseRegistration = new PP_UserRegistrationSingleRequestMock(
            200,
            'Complete',
            '',
            new Map<string, string>{ 'Set-Cookie' => 'fakeCookie' }
        );
        PP_UserRegistrationSingleRequestMock fakeUserRegister = new PP_UserRegistrationSingleRequestMock(200, 'Complete', '{"id":"AdE25"}', null);
        
        Map<String, HttpCalloutMock> endpointsToTest = new Map<String, HttpCalloutMock>();
        endpointsToTest.put('callout:PP_Ping_Base_Service/as/token.oauth2', fakeAccessToken);
        //added Jaco de Lange 26/01/2024
        endpointsToTest.put('callout:PP_Ping_Get_Token/as/authorization.oauth2', fakeAccessToken);
        endpointsToTest.put('callout:PP_Ping_Base_Service/as/authorization.oauth2?client_id=e1d66758-42e7-4e79-9675-9823dc4304f0', fakeflowId);
        endpointsToTest.put('callout:PP_Ping_Base_Service/pf-ws/authn/flows/' + flowId + '?action=registerUser', fakeUserRegister);
        //added Jaco de Lange 26/01/2024
        endpointsToTest.put('callout:PP_Ping_Get_Token/pf-ws/authn/flows/' + flowId + '?action=initiateRegistration', fakeInitialiseRegistration);
        endPointsToTest.put('callout:PP_Ping_Get_Token/pf-ws/authn/flows/' + flowId + '?action=registerUser', fakeUserRegister);

        HttpCalloutMock multiCalloutMock = new PP_UserRegistrationMockHttpResponse(endpointsToTest);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.startTest();
        PP_IntegrationResult result = PP_UserRegistration_CTRL.registerUser(userData);
        Test.stopTest();
        Assert.areEqual('', result.resultMessage, 'Result message is not null');
        Assert.areEqual('Success', result.resultStatus, 'Status does not match');
    }
}