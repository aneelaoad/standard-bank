/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-22-2022
 * @last modified by  : TCK
**/
@isTest
private class TRH_EAP_AppEvent_TEST {
    private static final String TEST_USER_NAME = 'testsgfdgds646@test.com';
    private static final String TEST_ADMIN_NAME = 'testgfdgsd335dssfs@test.com';
    private static final String TEST_CONTACT_EMAIL = 'test@Contact.testcom';
    private static final String TEST_USER_FIRSTNAME = 'User';
    private static final String TEST_CONTACT_ACCESS_ROLE = 'Authorised Person';
    private static final String TEST_CONTACT_FIRST_NAME = 'Test';
    private static final String TEST_CONTACT_LAST_NAME = 'Manager';
    private static final String SOLUTION_URL_NAME = 'Solution';
    private static final String TEST_CONTACT_PING_ID = '123456789';

    public static final String COMMUNITY_EVENTS = DMN_Profile.EVENTS_APP_COMMUNITY;
    public static final fflib_SObjectUnitOfWork UOW = ABS_ObjectBuilderBase.getNewUnitOfWork();

    private static User testUser {
        get {
            if(testUser == null) {
                testUser = [SELECT Id, ContactId, Email, Phone, Name FROM User WHERE Username = :TEST_USER_NAME LIMIT 1];
            }
            return testUser;
        }
        set;
    }

    private static Contact testContact {
        get {
            if(testContact == null) {
                testContact = [SELECT Id, FirstName, LastName, Name, Email, Ping_Id__c FROM Contact WHERE Email = :TEST_CONTACT_EMAIL LIMIT 1];
            }
            return testContact;
        }
        set;
    }

    @TestSetup
    static void setup() {
        new BLD_Contact(UOW)
            .name(TEST_CONTACT_FIRST_NAME, TEST_CONTACT_LAST_NAME)
            .communityAccessManager(new BLD_Contact(UOW).communityAccessRole(TEST_CONTACT_ACCESS_ROLE))
            .email(TEST_CONTACT_EMAIL)
            .ownerId(UserInfo.getUserId())
            .communityAccessRole(TEST_CONTACT_ACCESS_ROLE)
            .pingId(TEST_CONTACT_PING_ID)
            .account(new BLD_Account(UOW))
            .getRecord();
        UOW.commitWork();

        User eventAdmin;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            eventAdmin = (User) new BLD_USER(UOW)
                .useSysAdmin()
                .firstName(TEST_ADMIN_NAME)
                .getRecord();
            User communityUser = (User) new BLD_USER(UOW)
                .profile(COMMUNITY_EVENTS)
                .userName(TEST_USER_NAME)
                .email(testContact.Email)
                .firstName(TEST_CONTACT_FIRST_NAME)
                .lastName(TEST_CONTACT_LAST_NAME)
                .contactId(testContact.Id)
                .contactSyncId(testContact.Id)
                .getRecord();
            UOW.commitWork();

            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'EAP_EventAppCommunityPermission'];
            insert new PermissionSetAssignment(AssigneeId = communityUser.id, PermissionSetId = ps.Id);

        }

        new BLD_EAP_AppEvent(UOW);
        UOW.commitWork();
    }

    @isTest
    static void testAfterInsert(){
        List<Group> original = [SELECT Id, Name, Type FROM Group WHERE Type = 'Regular'];
        List<Group> result = new List<Group>();
        EAP_AppEvent__c event = new EAP_AppEvent__c(Name='Test',
                                                    EAP_Description__c='Test Event',
                                                    EAP_EndDate__c= datetime.now().addHours(1),
                                                    EAP_StartDate__c=  datetime.now(),
                                                    EAP_Location__c='Madrid');
        Test.startTest();
            Database.UpsertResult resultDatabase = Database.upsert(event, false);
            //insert event;
        Test.stopTest();
        result = [SELECT Id, Name, Type FROM Group WHERE Type = 'Regular'];
        System.assert(!result.isEmpty(), 'Result is not empty');
        System.assertEquals(1, (result.size() - original.size()), '----- Errores: ' +resultDatabase.getErrors()+ '-----');
    }

    @isTest
    static void testAfterUpdate(){
        List<Group> original = [SELECT Id, Name, Type FROM Group WHERE Type = 'Regular'];
        List<Group> result = new List<Group>();
        EAP_AppEvent__c event = new EAP_AppEvent__c(Name='Test',
                                                    EAP_Description__c='Test Event',
                                                    EAP_EndDate__c= datetime.now().addHours(1),
                                                    EAP_StartDate__c=  datetime.now(),
                                                    EAP_Location__c='Madrid');
        insert event;
        event.EAP_Location__c = 'Barcelona';
        Test.startTest();
            update event;
        Test.stopTest();
        result = [SELECT Id, Name, Type FROM Group WHERE Type = 'Regular'];
        System.assert(!result.isEmpty(), 'Result is not empty');
        System.assertEquals(1, (result.size() - original.size()), 'Result size is 1');
    }

    @isTest
    static void testBeforeDelete(){
        List<Group> original = [SELECT Id, Name, Type FROM Group WHERE Type = 'Regular'];
        List<Group> result = new List<Group>();
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];
        Test.startTest();
            delete event;
        Test.stopTest();
        result = [SELECT Id, Name, Type FROM Group WHERE Type = 'Regular'];
        System.assert(!result.isEmpty(), 'Result is not empty');
        System.assertEquals(1, (original.size() - result.size()), 'Result size is 1');
    }

}