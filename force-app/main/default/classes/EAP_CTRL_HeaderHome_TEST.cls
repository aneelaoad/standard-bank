/**
 * Test class for EAP_CTRL_HeaderHome
 * <br/>SFP-4690
 *
 * @author The Cocktail
 * @date June 2021
 * @description Test class for EAP_CTRL_HeaderHome
 */
@isTest
public  without sharing class EAP_CTRL_HeaderHome_TEST {
    private static final String TEST_USER_NAME = 'tetsEventsApp@test.com';
    private static final String TEST_CONTACT_PHONE = '123123123';
    private static final String TEST_USER_FIRSTNAME = 'Test';
    public static final String COMMUNITY_EVENTS = DMN_Profile.EVENTS_APP_COMMUNITY;

    private static User testUser {
        get {
            if(testUser == null) {
                testUser = [SELECT Id, ContactId,Email, Phone FROM User WHERE Username = :TEST_USER_NAME LIMIT 1];
            }
            return testUser;
        }
        set;
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
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
            new BLD_USER(uow)
                .userName(TEST_USER_NAME)
                .contactId(con.Id)
                .phone(TEST_CONTACT_PHONE)
                .firstName(TEST_USER_FIRSTNAME)
                .email(TEST_USER_NAME)
                .profile(COMMUNITY_EVENTS)
                .commitWork().getRecord();
            uow.commitWork();
        }
    }
    
    /**
    * @description 
    * @author TCK | 06-14-2022 
    **/
    @IsTest
    static void shouldGetUserData() {
        User currentUser;
        Test.startTest();
        System.runAs(testUser) {
            currentUser = EAP_CTRL_HeaderHome.getUserInfo();
        }
        Test.stopTest();
        System.assertEquals(TEST_USER_FIRSTNAME, currentUser.FirstName, 'Test user first name is current user first name');
    }
}