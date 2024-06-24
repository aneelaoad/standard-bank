/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : TCK
**/
@isTest
private class EAP_CTRL_ArchiveDetailPage_TEST {

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

    /**
     * @author TCK
     * @description Test setup
     * @date June 2022
     */    
    @TestSetup
    static void setup() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        
        new BLD_Contact(uow)
            .name(TEST_CONTACT_FIRST_NAME, TEST_CONTACT_LAST_NAME)
            .communityAccessManager(new BLD_Contact(uow).communityAccessRole(TEST_CONTACT_ACCESS_ROLE))
            .email(TEST_CONTACT_EMAIL)
            .ownerId(UserInfo.getUserId())
            .communityAccessRole(TEST_CONTACT_ACCESS_ROLE)
            .pingId(TEST_CONTACT_PING_ID)
            .account(new BLD_Account(uow))
            .getRecord();
        uow.commitWork();

        User eventAdmin;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            eventAdmin = (User) new BLD_USER(uow)
                .useSysAdmin()
                .firstName(TEST_ADMIN_NAME)
                .getRecord();
            User communityUser = (User) new BLD_USER(uow)
                .profile(COMMUNITY_EVENTS)
                .userName(TEST_USER_NAME)
                .email(testContact.Email)
                .firstName(TEST_CONTACT_FIRST_NAME)
                .lastName(TEST_CONTACT_LAST_NAME)
                .contactId(testContact.Id)
                .contactSyncId(testContact.Id)
                .getRecord();
            uow.commitWork();

            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'EAP_EventAppCommunityPermission'];
            insert new PermissionSetAssignment(AssigneeId = communityUser.id, PermissionSetId = ps.Id);


            BLD_EAP_AppEvent bldAppEvent = new BLD_EAP_AppEvent(uow);
            uow.commitWork();

            BLD_EAP_Document bldDocument = new BLD_EAP_Document(uow)
                .event(bldAppEvent);
            uow.commitWork();

            new BLD_ContentVersion(uow)
                .document(bldDocument)
                .getRecord();
            uow.commitWork();

            BLD_EAP_Document bldDocumentPhoto = new BLD_EAP_Document(uow)
                .event(bldAppEvent)
                .pictureDocument();
            uow.commitWork();

            new BLD_ContentVersion(uow)
                .document(bldDocumentPhoto)
                .getRecord();
            uow.commitWork();

        }
    }

    /**
    * @description Function to test getEventById
    * @author TCK | 11-10-2021 
    **/
    @isTest
    static void testArchiveDetailPageEventById(){
        EAP_CTRL_ArchiveDetailPage.Event_Wrapper result;
        List<EAP_AppEvent__c> eventList = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];

        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_ArchiveDetailPage.getEventById(eventList.get(0).Id);
        }
        Test.stopTest();
        System.assert(result != null, 'No Events returned');
    }

    /**
    * @description Function to test getEventDocs
    * @author TCK | 11-10-2021 
    **/
    @isTest
    static void testArchiveDetailPageEventDocs(){
        List<EAP_Document__c> result;
        List<EAP_AppEvent__c> eventList = [SELECT Id FROM EAP_AppEvent__c LIMIT 1];

        Test.startTest();
        System.runAs(testUser) {
            result = EAP_CTRL_ArchiveDetailPage.getEventDocs(eventList.get(0).Id);
        }
        Test.stopTest();
        System.assert(!result.isEmpty(), 'No documents returned');
        System.assertEquals(1, result.size(), 'No documents returned');
    }
}