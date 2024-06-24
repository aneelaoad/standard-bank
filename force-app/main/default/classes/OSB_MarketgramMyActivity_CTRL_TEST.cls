/**
 * Test class for OSB_MarketgramMyActivity_CTRL
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date March 2020
 */
@IsTest
public with sharing class OSB_MarketgramMyActivity_CTRL_TEST {
    
    private static String TEST_USER_NAME = 'test@test.com';

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
        String contactPhone = '123123123';
        String firstName = 'Test';
        String accessRole = 'Authorised Person';
        String managerLastName = 'Manager';
        String lastName = 'NormalContact';
        String pingId = '123456789';
        String contactEmail = 'test@Contact.testcom';
        String secContactEmail = 'test2Two@Contact.testcom';
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        Account account = (Account) new BLD_Account(uow)
            .getRecord();
        
        Contact communityManagerCon = (Contact) new BLD_Contact(uow)
            .name(firstName,managerLastName)
            .communityAccessRole(accessRole)
            .email(contactEmail)
            .pingId(pingId)
            .getRecord();
        
        Contact con = (Contact) new BLD_Contact(uow)
			.name(firstName,lastName)
			.communityAccessRole(accessRole)
            .communityAccessManager(communityManagerCon.Id)
            .pingId(pingId)
			.email(secContactEmail)
            .getRecord();

        uow.registerRelationship(communityManagerCon,Contact.AccountId,account);
        uow.registerRelationship(con,Contact.AccountId,account);
        uow.commitWork();
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
            User u = (User) new BLD_USER()
                .profile(DMN_Profile.ONE_HUB_COMMUNITY)
                .userName(TEST_USER_NAME)
                .contactId(con.Id)
                .phone(contactPhone)
                .firstName(firstName)
                .email(TEST_USER_NAME)
                .commitWork().getRecord();
        }
    }
    
    @IsTest
    static void shouldGetPosts() {
        Test.startTest();
        Object result = OSB_MarketgramMyActivity_CTRL.getPosts(testUser.Id);
        Test.stopTest();
        System.assertNotEquals(null, result);
        System.assert(result instanceof List<FeedItem>);
    }
}