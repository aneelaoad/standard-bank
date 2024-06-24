/**
* Test class for ContactTriggerFunctions.
*
* @author Unknown
* @date Unknown
*/
@IsTest
public class ContactTriggerFunctions_test {

    static String defAccName  = 'TEST CONTACT TRIGGER ACC';
    static String testUserName1  = 'test.StdBank_Ltn_Ecosystem_Test@test.com';
    static String testUserName2  = 'test2222222.StdBank_Ltn_Ecosystem_Test@test.com';
    static String contactNameFirst  = 'TEST CONTACT FIRST NAME';
    static String contactNameLast  = 'TEST CONTACT LAST NAME';
    static User testUser {
        get {
            if (testUser == null) {
                testUser = [SELECT Id FROM User WHERE UserName = :testUserName1 LIMIT 1];
            }
            return testUser;
        }
        set;
    }
    static User testUser2 {
        get {
            if (testUser2 == null) {
                testUser2 = [SELECT Id FROM User WHERE UserName = :testUserName2 LIMIT 1];
            }
            return testUser2;
        }
        set;
    }
    static Account account {
        get {
            if (account == null) {
                account = [SELECT Id FROM Account WHERE Name = :defAccName LIMIT 1];
            }
            return account;
        }
        set;
    }

    @TestSetup
    public static void testSetup() {
        fflib_SObjectUnitOfWork uow;

        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            testUser = (User) new BLD_USER(uow).userName(testUserName1).useCommB().syncContact().getRecord();
            testUser2 = (User) new BLD_USER(uow).userName(testUserName2).useCommB().syncContact().getRecord();
            uow.commitWork();
        }
        System.runAs(testUser) {
            new BLD_Account(uow).useCommB().useGroupParent()
                .name(defAccName)
                .addContact(
                    new BLD_Contact(uow).useClientContact()
                        .name(contactNameFirst, contactNameLast)
                        .contactCategory(DMN_Contact.CATEGORY_CEO)
                );
            uow.commitWork();
        }

    }
    /**
     * Checks if new Contact Team Member is Created when creating new Contact
     */
    @IsTest
    static void shouldAddNewContactTeamMember() {
        Contact con = (Contact) new BLD_Contact().useClientContact().accountId(account.Id).getRecord();
        Test.startTest();
        System.runAs(testUser) {
            insert con;
        }
        Test.stopTest();
        System.assertEquals(1, [SELECT Id FROM SA_Contact_Team_Member__c WHERE SA_Contact__c = :con.Id].size());
    }

    /**
     * Checks if Contact Team Members are updated when Updating Contact
     */
    @IsTest
    static void shouldUpdateTeamMembers() {
        Contact con = [SELECT Id FROM Contact WHERE LastName = :contactNameLast];
        System.assertEquals(1, [SELECT Id FROM SA_Contact_Team_Member__c WHERE SA_User__c = :testUser.Id].size());
        Test.startTest();
        System.runAs(testUser) {
            con.OwnerId = testUser2.Id;
            update con;
        }
        Test.stopTest();
        System.assertEquals(2, [SELECT Id FROM SA_Contact_Team_Member__c WHERE SA_Contact__c = :con.Id].size());
        System.assertEquals(false, [SELECT Id, Primary_Contact_Person__c FROM SA_Contact_Team_Member__c WHERE SA_User__c = :testUser.Id][0].Primary_Contact_Person__c);
        System.assertEquals(true, [SELECT Id, Primary_Contact_Person__c FROM SA_Contact_Team_Member__c WHERE SA_User__c = :testUser2.Id][0].Primary_Contact_Person__c);
    }

    /**
     * Checks if information on related Event Report Attendees is updated when updating Contact
     */
    @IsTest
    static void shouldUpdateRelateReportAttendees() {
        TEST_DataFactory.generateConfiguration();
        Contact con = [SELECT Id FROM Contact WHERE LastName = :contactNameLast];

        Call_Report__c callReport = new Call_Report__c();
        callReport.Description__c = 'description';
        callReport.Subject__c = 'subject';
        callReport.Relate_to_Client__c = account.Id;
        callReport.End__c = Datetime.now().addDays(2);
        insert callReport;

        Call_Report_Attendees__c callReportAttendees = new Call_Report_Attendees__c();
        callReportAttendees.Contact_id__c = con.Id;
        callReportAttendees.Contact_id__r = con;
        callReportAttendees.Call_Report__c = callReport.Id;
        insert callReportAttendees;
        System.assertEquals('CEO', [SELECT Contact_Category__c FROM Call_Report_Attendees__c WHERE Id = :callReportAttendees.Id][0].Contact_Category__c);
        con.Contact_Category__c = 'Analyst';
        Test.startTest();
        update con;
        Test.stopTest();
        System.assertEquals('Analyst', [SELECT Contact_Category__c FROM Call_Report_Attendees__c WHERE Id = :callReportAttendees.Id][0].Contact_Category__c);
    }

    /**
     * Checks if KYCContactCheckbox on Client object is checked when adding Kyc Contact
     */
    @IsTest
    static void shouldSetKYCContactCheckbox() {
        Contact con = (Contact) new BLD_Contact().useClientContact().accountId(account.Id).roleAtClient(DMN_Contact.RAC_KYC_CONTACT).getRecord();
        Test.startTest();
        System.runAs(testUser) {
            insert con;
        }
        Test.stopTest();
        System.assertEquals(true, [SELECT Group_KYC_Contact__c FROM Account WHERE Id = :account.Id][0].Group_KYC_Contact__c);
    }

    /**
     * Checks if Related Event Attendees are deleted when deleting Contact
     */
    @IsTest
    static void shouldDeleteEventAttendees() {

        TEST_DataFactory.generateConfiguration();
        Contact con = [SELECT Id FROM Contact WHERE LastName = :contactNameLast];
        Contact con2 = (Contact) new BLD_Contact().useClientContact().accountId(account.Id).commitWork().getRecord();

        Call_Report__c callReport = new Call_Report__c();
        callReport.Description__c = 'description';
        callReport.Subject__c = 'subject';
        callReport.Relate_to_Client__c = account.Id;
        callReport.End__c = Datetime.now().addDays(2);
        insert callReport;

        Call_Report_Attendees__c callReportAttendees = new Call_Report_Attendees__c();
        callReportAttendees.Contact_id__c = con.Id;
        callReportAttendees.Contact_id__r = con;
        callReportAttendees.Call_Report__c = callReport.Id;
        insert callReportAttendees;

        Id conId = con.Id;

        System.assertEquals(1, [SELECT Id FROM Call_Report_Attendees__c WHERE Contact_id__c = :conId].size());

        Test.startTest();
        merge con2 con;
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM Call_Report_Attendees__c WHERE Contact_id__c = :conId].size());
    }

    /**
     * Checks if Contact Team Member is deleted when deleting related Contact
     */
    @IsTest
    static void shouldRemoveContactTeamMembers() {
        Contact con = [SELECT Id FROM Contact WHERE LastName = :contactNameLast];
        Contact con2 = (Contact) new BLD_Contact().useClientContact().accountId(account.Id).commitWork().getRecord();
        Id conId = con.Id;
        System.assertEquals(1, [SELECT Id FROM SA_Contact_Team_Member__c WHERE SA_Contact__c = :conId].size());
        Test.startTest();
        merge con2 con;
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM SA_Contact_Team_Member__c WHERE SA_Contact__c = :conId].size());
    }

    /**
     * Checks if related Campaign Hosts and Members are properly merged when merging the contacts
     */
    @IsTest
    static void shouldMergeCampaignHostsAndMembers() {
        Contact con = [SELECT Id FROM Contact WHERE LastName = :contactNameLast];
        Contact con2 = (Contact) new BLD_Contact().useClientContact().accountId(account.Id).commitWork().getRecord();
        Campaign campaign = new Campaign();
        campaign.Name = 'campaignOnes';
        insert campaign;

        Campaign_Member_Host__c campaignMemberHost = new Campaign_Member_Host__c();
        campaignMemberHost.Campaign__c = campaign.Id;
        campaignMemberHost.Member__c = con.Id;
        insert campaignMemberHost;

        Campaign_Member_Host__c campaignMemberHost2 = new Campaign_Member_Host__c();
        campaignMemberHost2.Campaign__c = campaign.Id;
        campaignMemberHost2.Member__c = con2.Id;
        insert campaignMemberHost2;

        Campaign_Hosts__c campaignHosts = new Campaign_Hosts__c();
        campaignHosts.Campaign_Member_Host__c = campaignMemberHost.Id;
        campaignHosts.Bank_Contact__c = con.Id;
        insert campaignHosts;

        Campaign_Hosts__c campaignHosts2 = new Campaign_Hosts__c();
        campaignHosts2.Campaign_Member_Host__c = campaignMemberHost2.Id;
        campaignHosts2.Bank_Contact__c = con2.Id;
        insert campaignHosts2;

        Id conId = con.Id;
        System.assertEquals(1, [SELECT Id FROM Campaign_Hosts__c WHERE Bank_Contact__c = :conId].size());
        System.assertEquals(1, [SELECT Id FROM Campaign_Member_Host__c WHERE Member__c = :conId].size());
        Test.startTest();
        merge con2 con;
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM Campaign_Hosts__c WHERE Bank_Contact__c = :conId].size());
        System.assertEquals(0, [SELECT Id FROM Campaign_Member_Host__c WHERE Member__c = :conId].size());
    }

    /**
     * Checks if Campaign Hosts and Members are deleted when deleting related Contact
     */
    @IsTest
    static void shouldRemoveCampaignHostsAndMembers() {
        Contact con = [SELECT Id FROM Contact WHERE LastName = :contactNameLast];
        Campaign campaign = new Campaign();
        campaign.Name = 'campaignOnes';
        insert campaign;

        Campaign_Member_Host__c campaignMemberHost = new Campaign_Member_Host__c();
        campaignMemberHost.Campaign__c = campaign.Id;
        campaignMemberHost.Member__c = con.Id;
        insert campaignMemberHost;

        Campaign_Hosts__c campaignHosts = new Campaign_Hosts__c();
        campaignHosts.Campaign_Member_Host__c = campaignMemberHost.Id;
        campaignHosts.Bank_Contact__c = con.Id;
        insert campaignHosts;

        Id conId = con.Id;
        System.assertEquals(1, [SELECT Id FROM Campaign_Hosts__c WHERE Bank_Contact__c = :conId].size());
        System.assertEquals(1, [SELECT Id FROM Campaign_Member_Host__c WHERE Member__c = :conId].size());
        Test.startTest();
        delete con;
        Test.stopTest();
        System.assertEquals(0, [SELECT Id FROM Campaign_Hosts__c WHERE Bank_Contact__c = :conId].size());
        System.assertEquals(0, [SELECT Id FROM Campaign_Member_Host__c WHERE Member__c = :conId].size());
    }
}