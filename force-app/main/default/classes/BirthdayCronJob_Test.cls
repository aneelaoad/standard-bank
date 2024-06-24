/*****************************************************************************************************\
    @ Author        : Revashlin Iyman
    @ Date          : September 2010
    @ Description   : Test Class For BirthdayCronJob.cls         
                  
    @ Last Modified By  : Wayne Gray
    @ Last Modified On  : June 2012
    @ Modification Description : Move test methods into external class  
                                 Case #6521- Change contact to use TestFatcory
    @ Last Modified By  : Nikhita Reddy
    @ Last Modified On  : 14 January 2012
    @ Modification Description : Adding Best Practices to the test class. Creating the test data in a utility class.
                                 Updated the API version to 27
******************************************************************************************************/

@isTest(SeeAllData = False)
public class BirthdayCronJob_Test {

    static testMethod void testBatch() {
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        //Insert test user ONE (Client Owner)
        User user01 = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        //Insert test user TWO (Contact Owner)
        User user02 = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        //Insert test user THREE (Contact Team Member)
        User user03 = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        //Insert test user FOUR (Birthday User)
        User user04 = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        user04.Birth_Day_Month__c = al.StringUtils.leftPad(System.today().day().format(),2,'0')+'/'+ al.StringUtils.leftPad(System.today().month().format(),2,'0');
        //Insert test user Five (Inactive User)
        User user05 = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        uow.commitWork();

        Account accRec;
        System.runAs(user01) {
            accRec = (Account) new BLD_Account()
                .commitWork()
                .getRecord();
        }

        Date birthDay = System.today().addDays(7);

        List<Contact> contacts = new List<Contact>();
        System.runAs(user02) {
            contacts.add((Contact) new BLD_Contact(uow).useClientContact()
                .birthDayMonth(al.StringUtils.leftPad(birthDay.day().format(), 2, '0') + '/' + al.StringUtils.leftPad(birthDay.month().format(), 2, '0'))
                .getRecord());
            contacts.add((Contact) new BLD_Contact(uow).useClientContact().getRecord());
            contacts.add((Contact) new BLD_Contact(uow).useClientContact().getRecord());
            uow.commitWork();
        }

        System.runAs(user01) {
            new BLD_ContactTeamMember(uow).contact(contacts[0].Id).user(user03.Id);
            new BLD_ContactTeamMember(uow).contact(contacts[1].Id).user(user04.Id);
            new BLD_ContactTeamMember(uow).contact(contacts[2].Id).user(user05.Id);
            uow.commitWork();
        }

        Test.startTest();

        // Schedule the test job
        String jobId = System.schedule('testBasicScheduledApex', BirthdayCronJob.CRON_EXP, new BirthdayCronJob());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = : jobId];
        // Verify the expressions are the same
        System.assertEquals(BirthdayCronJob.CRON_EXP, ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        // Verify the next time the job will run
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        batchContactTeamBirthdayReminders b1 = new batchContactTeamBirthdayReminders();
        b1.runTestMethod = true;
        ID batchprocessid = Database.executeBatch(b1);
        batchContactClientOwnerBirthdayReminders b2 = new batchContactClientOwnerBirthdayReminders();
        b2.runTestMethod = true;
        batchprocessid = Database.executeBatch(b2);
        emailBirthdayUsers eTest = new emailBirthdayUsers();
        Integer totalMailsSent = eTest.sendMail();
        //Check Email Sent Tasks
        System.assert(totalMailsSent > 0);
        Test.stopTest();
    }
}