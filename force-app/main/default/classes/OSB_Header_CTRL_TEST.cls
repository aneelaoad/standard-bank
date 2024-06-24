/**
 * @description Test class for OSB_Header_CTRL
 * 
 * @author Ayush Garg (ayusgarg@deloitte.com)
 * @date April 2020
 * 
 * @LastModified October 2023
 * @author Lyne Keet (lyne.keet@standardbank.co.za)
 * @UserStory SFP-31440
 * @LastModifiedReason Remove hardcoded urls and update to meet standards.
 */

@IsTest(IsParallel=true)
public with sharing class OSB_Header_CTRL_TEST {
    private static final String TEST_USER_NAME = 'testRandom1011@test.com';
    private static final String TEST_CONTACT_PHONE = '123123123';
    private static final String TEST_USER_FIRSTNAME = 'Test';
    private static final String TEST_LOGIN = '/services/auth/sso/Ping_Authentication';
    private static final String TEST_IELOGIN = '/s/unsupported-internet-explorer';
    private static final String TERMS_LINK_SEL = 'OSB_T&C';

    private static User testUser {
        get {
            if(testUser == null) {
                testUser = [SELECT Id, ContactId,Email, Phone FROM User WHERE Username = :TEST_USER_NAME LIMIT 1];
            }
            return testUser;
        }
        set;
    }
    
    @TestSetup
    static void setup() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        Contact con = (Contact) new BLD_Contact(uow)
            .ownerId(UserInfo.getUserId())
            .communityAccessRole(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP)
            .account(
                new BLD_Account(uow)
            )
            .getRecord();
        uow.commitWork();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            User u = (User) new BLD_USER()
                .useOneHub()
                .userName(TEST_USER_NAME)
                .contactId(con.Id)
                .phone(TEST_CONTACT_PHONE)
                .firstName(TEST_USER_FIRSTNAME)
                .email(TEST_USER_NAME)
                .commitWork().getRecord();
        }

        List<SObject> customSettingsList = new List<SObject>();
        customSettingsList.addAll(TEST_DataFactory.getOsbUrls());
        insert customSettingsList;
    }
    
    @IsTest
    static void shouldGetNotification() {
        Integer actualNotificationCount;
        Test.startTest();
        System.runAs(testUser) {
            actualNotificationCount = OSB_Header_CTRL.getUnreadFeedItemsNumberForUser();
        }
        Test.stopTest();
        Assert.areEqual( 1, actualNotificationCount, 'One notification should be created per user');
    }
    
    @IsTest
    static void shouldGetUserName() {
        User currentUser;
        Test.startTest();
        System.runAs(testUser) {
            currentUser = OSB_Header_CTRL.getUserNameIfLoggedIn();
        }
        Test.stopTest();
        Assert.areEqual(TEST_USER_FIRSTNAME, currentUser.FirstName,'User first name match');
    }
    
    @IsTest
    static void shouldGetContactRole() {
        String role;
        Test.startTest();
        System.runAs(testUser) {
            role = OSB_Header_CTRL.getContactAuth();
        }
        Test.stopTest();
        Assert.areEqual(DMN_Contact.OSB_COMMUNITY_ACCESS_ROLE_AP, role, 'User Community access role match');
    }
    
    @IsTest
    static void shouldGetPingPasswordChangeURL() {
        insert TEST_DataFactory.getOsbUrls();
        String url;
        Test.startTest();
        System.runAs(testUser) {
            url = OSB_Header_CTRL.getChangePasswordUrlPing();
        }
        Test.stopTest();
        Assert.areEqual(true, url.containsIgnoreCase(testUser.Email),'Change password url match');
    }

    @isTest
    static void shouldGetDocumentUrl(){

        String expectedLink = OSB_URLs__c.getValues(TERMS_LINK_SEL).Value__c;     

        Test.startTest();
        String result = OSB_Header_CTRL.getTermsLink();
        Test.stopTest();
    
        Assert.areEqual(expectedLink, result, 'Terms link match the custom setting value.');
    }

    @IsTest
    static void getLoginUrlTest(){
        String url;
        Test.startTest();
        System.runAs(testUser) {
            url = OSB_Header_CTRL.getLoginURL();
        }
        Test.stopTest();
        Assert.areEqual(TEST_LOGIN, url,'Login url match');
    }

    @IsTest
    static void getIeLoginUrlTest(){
        String url;
        Test.startTest();
        System.runAs(testUser) {
            url = OSB_Header_CTRL.getIELoginURL();
        }
        Test.stopTest();
        Assert.areEqual(TEST_IELOGIN, url,'Interner Explorer login url match');
    }
}