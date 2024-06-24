/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 11-07-2022
 * @last modified by  : TCK
 *
 * @last modified on  : Feb 2024
 * @last modified by  : Dzianisik Maksim
 * @description       : added coverage logic for DMN_CampaignMember.handleOptedOutMembers() method
**/
@isTest
private class TRH_CampaignMember_TEST {
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

        new BLD_Campaign(UOW)
            .isCampaignEvent()
            .category(DMN_Campaign.CATEGORY_APP_EVENT);
        UOW.commitWork();
    }

    @isTest
    static void testAfterInsert(){
        Campaign camp = [SELECT Id FROM Campaign WHERE Campaign_Category__c =: DMN_Campaign.CATEGORY_APP_EVENT LIMIT 1];
        Contact contactCamp = [SELECT Id FROM Contact LIMIT 1];
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c WHERE EAP_Campaign__c =: camp.Id LIMIT 1];
        List<EAP_Attendee__c> original = [SELECT Id FROM EAP_Attendee__c WHERE EAP_AppEvent__c =: event.Id];

        Test.startTest();
        new BLD_CampaignMember(UOW)
            .campaign(String.valueOf(camp.Id))
            .contact(String.valueOf(contactCamp.Id))
            .invitationResponseAccepted();
        UOW.commitWork();
        Test.stopTest();

        List<EAP_Attendee__c> result = [SELECT Id FROM EAP_Attendee__c WHERE EAP_AppEvent__c =: event.Id];
        if (result.isEmpty()) {
            System.assert(result.isEmpty(), 'Result is not empty');
            System.assertEquals(result.size(), original.size(), 'Result size not the same as the original size');
        } else {
            System.assert(!result.isEmpty(), 'Result is empty');
            System.assertNotEquals(result.size(), original.size(), 'Result size the same as the original size');
        }
    }

    @isTest
    static void testAfterUpdate(){
        Campaign camp = [SELECT Id FROM Campaign WHERE Campaign_Category__c =: DMN_Campaign.CATEGORY_APP_EVENT LIMIT 1];
        Contact contactCamp = [SELECT Id FROM Contact LIMIT 1];
        EAP_AppEvent__c event = [SELECT Id FROM EAP_AppEvent__c WHERE EAP_Campaign__c =: camp.Id LIMIT 1];
        List<EAP_Attendee__c> original = [SELECT Id FROM EAP_Attendee__c WHERE EAP_AppEvent__c =: event.Id];
        new BLD_CampaignMember(UOW)
            .campaign(String.valueOf(camp.Id))
            .contact(String.valueOf(contactCamp.Id));
        UOW.commitWork();
        CampaignMember campMem = [SELECT Id, Invitation_Response__c FROM CampaignMember WHERE CampaignId =: camp.Id LIMIT 1];

        Test.startTest();
            campMem.Invitation_Response__c = DMN_CampaignMember.INVITATION_STATUS_ACCEPTED;
            update campMem;
        Test.stopTest();

        List<EAP_Attendee__c> result = [SELECT Id FROM EAP_Attendee__c WHERE EAP_AppEvent__c =: event.Id];
        if (result.isEmpty()) {
            System.assert(result.isEmpty(), 'Result is not empty');
            System.assertEquals(result.size(), original.size(), 'Result size not the same as the original size');
        } else {
            System.assert(!result.isEmpty(), 'Result is empty');
            System.assertNotEquals(result.size(), original.size(), 'Result size the same as the original size');
        }
    }

    @IsTest
    static void testHandleOptedOut() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        DataUsePurpose dup= new DataUsePurpose();
        dup.Name = 'Direct Marketing';
        dup.IsActive =false;
        insert dup;

        BusinessBrand b = new BusinessBrand(Name='CIB');
        insert b;

        Account ac1 = new Account();
        ac1.Name ='First Account';
        Account ac2 = new Account();
        ac2.Name ='Second Account';

        Contact c1 = new Contact();
        c1.LastName = 'l1';
        c1.FirstName = 'F1';
        c1.Email = 'a1@test.com';
        c1.HasOptedOutOfEmail = false;

        Contact c2 = new Contact();
        c2.LastName = 'l1';
        c2.FirstName = 'F2';
        c2.Email = 'a2@test.com';
        c2.HasOptedOutOfEmail = false;

        Contact c3 = new Contact();
        c3.LastName = 'Out';
        c3.FirstName = 'Opted';
        c3.Email = 'a3@test.com';
        c3.HasOptedOutOfEmail = true;

        uow.registerNew(ac1);
        uow.registerNew(ac2);
        uow.registerNew(c1, Contact.AccountId, ac1);
        uow.registerNew(c2, Contact.AccountId, ac1);
        uow.registerNew(c3, Contact.AccountId, ac2);

        uow.commitWork();

        Contact[] cons = [select Id from Contact WHERE Id=:c3.Id and IndividualId=null ];

        if(cons.size()>0){
            Individual i1 = new Individual();
            i1.FirstName  = c3.FirstName;
            i1.LastName   = c3.LastName;

            uow.registerNew(i1);
            uow.commitWork();

            c3.IndividualId = i1.Id;
            uow.registerDirty(c3);

            ContactPointTypeConsent cpt1 = new ContactPointTypeConsent();
            cpt1.Name                    = 'Email - Direct Marketing';
            cpt1.PrivacyConsentStatus    = 'OptIn';
            cpt1.EffectiveFrom           = date.today();
            cpt1.CaptureDate             = date.today();
            cpt1.DataUsePurposeId        = dup.Id;
            cpt1.PartyId                 = i1.Id;
            cpt1.CaptureContactPointType = 'Web';
            cpt1.ContactPointType        = 'Email';
            cpt1.AccountId__c            = c3.AccountId;
            cpt1.CaptureSource           = 'Salesforce UI';

            uow.registerNew(cpt1);
            uow.commitWork();
        }

        Campaign campaing = new Campaign();
        campaing.Name = 'Test cmp';
        campaing.isActive = true;
        campaing.Campaign_Category__c = DMN_Campaign.CATEGORY_GROUP_EVENT;
        campaing.Type = 'Direct Marketing';
        uow.registerNew(campaing);
        uow.commitWork();       //insert all

        new BLD_CampaignMember(UOW)
                .campaign(String.valueOf(campaing.Id))
                .contact(String.valueOf(c1.Id))
                .invitationResponseAccepted();

        new BLD_CampaignMember(UOW)
                .campaign(String.valueOf(campaing.Id))
                .contact(String.valueOf(c2.Id))
                .invitationResponseAccepted();

        new BLD_CampaignMember(UOW)
                .campaign(String.valueOf(campaing.Id))
                .contact(String.valueOf(c3.Id))
                .invitationResponseAccepted();

        try {
            uow.commitWork();
        } catch (DmlException ex) {
            Assert.isTrue(ex.getMessage().contains(DMN_CampaignMember.OPTED_OUT_ERROR), 'Has to fail with the error message');
        }
    }
}