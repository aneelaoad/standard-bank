/* @Class Name   : OnboardingTrackerExtTest_Proper
 * @Description  : Test class for the OnboardingTrackerExt class
 * @Created By   : Jana Cechova
 * @Created On   : 21 Mar 2016 
 * @Modification Log:  
 * --------------------------------------------------------------------------------------------------
 * @Developer                Date                   Description
 * --------------------------------------------------------------------------------------------------
 * ---------------------------------------------------------------------------------------------------
*/
@isTest(SeeAllData = False)
private class OnboardingTrackerExtTest_Proper {

    private static final String USERNAME = 'dwaeq2321312@example.com';
    private static User sysAdmin {
        get {
            if (sysAdmin == null) {
                sysAdmin = [SELECT Id FROM User WHERE Username = :USERNAME];
            }
            return sysAdmin;
        }
        set;
    }

    @testSetup
    static void prepareData() {
        TEST_DataFactory.generateConfiguration();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            new BLD_USER(USERNAME).useSysAdmin().commitWork();
        }
    }

    static testMethod void scenario1(){

        List<Account> lstTestAccount = new List<Account> {
            (Account) new BLD_Account().usePotential()
                .proposedClientCoordinator(sysAdmin)
                .getRecord()
        };

        insert lstTestAccount;

        //Setting the OnboardingTracker page as a test page for the test class
        PageReference pageRef = Page.OnboardingTracker;
        Test.setCurrentPage(pageRef);

        //passing parameters for the url
        ApexPages.CurrentPage().getParameters().put('id',lstTestAccount[0].id);

		system.Test.startTest();

        ApexPages.StandardController stdController = new ApexPages.StandardController(lstTestAccount[0]);
        OnboardingTrackerExt a = new OnboardingTrackerExt(stdController);

		system.Test.stopTest();

         // Asserts
        system.assertequals(null,lstTestAccount[0].submission_date__c,'Submission date on Account was populated uncorrectly.');
        system.assertequals(false,a.exceededLimit,'ExceededLimit was true uncorrectly.');
    }

    static testMethod void scenario2(){

        List<Account> lstTestAccount = new List<Account> {
            (Account) new BLD_Account().usePotential()
                .proposedClientCoordinator(sysAdmin)
                .getRecord()
        };
        insert lstTestAccount ;

        lstTestAccount[0].submission_date__c = date.today().adddays(-40);
        update lstTestAccount[0];

        //Setting the OnboardingTracker page as a test page for the test class
        PageReference pageRef = Page.OnboardingTracker;
        Test.setCurrentPage(pageRef);

        //passing parameters for the url
        ApexPages.CurrentPage().getParameters().put('id',lstTestAccount[0].id);

		system.Test.startTest();

        ApexPages.StandardController stdController = new ApexPages.StandardController(lstTestAccount[0]);
        OnboardingTrackerExt a = new OnboardingTrackerExt(stdController);

		system.Test.stopTest();

        // Asserts
        system.assertequals(date.today().adddays(-40),lstTestAccount[0].submission_date__c,'Submission date on Account was changed uncorrectly.');
        system.assertequals(true,a.exceededLimit,'ExceededLimit was false uncorrectly.');
    }
    static testMethod void scenario3(){

        List<Account> lstTestAccount = new List<Account> {
            (Account) new BLD_Account().usePotential()
                .proposedClientCoordinator(sysAdmin)
                .getRecord()
        };
        insert lstTestAccount ;

        // Update Submission date
        lstTestAccount[0].submission_date__c = date.today();
        update lstTestAccount[0];

        //Setting the OnboardingTracker page as a test page for the test class
        PageReference pageRef = Page.OnboardingTracker;
        Test.setCurrentPage(pageRef);

        //passing parameters for the url
        ApexPages.CurrentPage().getParameters().put('id',lstTestAccount[0].id);

		system.Test.startTest();

        ApexPages.StandardController stdController = new ApexPages.StandardController(lstTestAccount[0]);
        OnboardingTrackerExt a = new OnboardingTrackerExt(stdController);

		system.Test.stopTest();

        // Asserts
        system.assertequals(date.today(),lstTestAccount[0].submission_date__c,'Submission date on Account was changed uncorrectly.');
        system.assertequals(false,a.exceededLimit,'ExceededLimit was true uncorrectly.');
    }
    static testMethod void scenario4(){

        List<Account> lstTestAccount = new List<Account> {
            (Account) new BLD_Account().usePotential()
                .proposedClientCoordinator(sysAdmin)
                .submissionDate(Date.today().addDays(-31))
                .getRecord()
        };

        insert lstTestAccount;

        //Setting the OnboardingTracker page as a test page for the test class
        PageReference pageRef = Page.OnboardingTracker;
        Test.setCurrentPage(pageRef);

        //passing parameters for the url
        ApexPages.currentPage().getParameters().put('id', lstTestAccount[0].Id);

		system.Test.startTest();

        ApexPages.StandardController stdController = new ApexPages.StandardController(lstTestAccount[0]);
        OnboardingTrackerExt a = new OnboardingTrackerExt(stdController);

		system.Test.stopTest();

        // Asserts
    	System.assertEquals(Date.today().addDays(-31), lstTestAccount[0].Submission_Date__c, 'Submission date on Account was changed uncorrectly.');
    }
    static testMethod void scenario5(){

        List<Account> lstTestAccount = new List<Account> {
            (Account) new BLD_Account().usePotential()
                .proposedClientCoordinator(sysAdmin)
                .submissionDate(Date.today().addDays(120))
                .getRecord()
        };

        insert lstTestAccount;

        //Setting the OnboardingTracker page as a test page for the test class
        PageReference pageRef = Page.OnboardingTracker;
        Test.setCurrentPage(pageRef);

        //passing parameters for the url
        ApexPages.currentPage().getParameters().put('id', lstTestAccount[0].Id);

		system.Test.startTest();

        ApexPages.StandardController stdController = new ApexPages.StandardController(lstTestAccount[0]);
        OnboardingTrackerExt a = new OnboardingTrackerExt(stdController);

		system.Test.stopTest();

        // Asserts
    	System.assertEquals(Date.today().addDays(120), lstTestAccount[0].Submission_Date__c, 'Submission date on Account was changed uncorrectly.');
        System.assertEquals(false, a.exceededLimit, 'ExceededLimit was true uncorrectly.');

    }

    @isTest
    static void testAccessClassic() {
        Account account = (Account) new BLD_Account().commitWork().getRecord();

        PageReference pgRef = Page.OnboardingTracker;

        Test.setCurrentPage(pgRef);

        Test.startTest();

        ApexPages.StandardController standardController = new ApexPages.StandardController(account);
        OnboardingTrackerExt  controller = new OnboardingTrackerExt(standardController);

        System.assertEquals(false, controller.getIsLightning());
        System.assertEquals(true, controller.getIsClassic());

        Test.stopTest();
    }

    @isTest
    static void testAccessLightning() {
        Account account = (Account) new BLD_Account().commitWork().getRecord();

        PageReference pgRef = Page.OnboardingTracker;

        Test.setCurrentPage(pgRef);

        ApexPages.currentPage().getParameters().put('isdtp', 'p1');

        Test.startTest();

        ApexPages.StandardController standardController = new ApexPages.StandardController(account);
        OnboardingTrackerExt  controller = new OnboardingTrackerExt(standardController);

        System.assertEquals(true, controller.getIsLightning());
        System.assertEquals(false, controller.getIsClassic());

        Test.stopTest();
    }
}