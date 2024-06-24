/*************************************************************************
    @ Author:       Petr Svestka
    @ Date:         19 July 2016
    @description :  US-1247: Provide search facilities for look-ups
*************************************************************************/

@IsTest
public class MeetingConsoleLookupsSupportTest {

    private final static String USER_LAST_NAME = 'us1247';
    
    @TestSetup
    static void prepareData() {

        System.runAs(new User(Id = UserInfo.getUserId())) {
          new BLD_USER().useCib()
              .lastName(USER_LAST_NAME)
              .commitWork();
        }

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Account(uow)
            .name('Standard Bank Employees')
            .addContact(
                new BLD_Contact(uow).useBankContact()
            )
            .commitWork();

    }
    
    @IsTest
    static void testUserLookup() {
        List<User> foundUsers = MeetingConsoleLookupsSupport.queryUsers(USER_LAST_NAME);
        system.assertEquals(1, foundUsers.size(), 'One User record was expected');
        
        List<User> result = MeetingConsoleLookupsSupport.queryUsers('');
        system.assertEquals(0, result.size(), 'No User record was expected');
    }
    
    @IsTest
    static void testContactLookup() {
        List<Contact> foundContacts = MeetingConsoleLookupsSupport.queryContacts('testcontact');
        system.assertEquals(1, foundContacts.size(), 'One Contact record was expected');
        
        List<Contact> result = MeetingConsoleLookupsSupport.queryContacts('');
        system.assertEquals(0, result.size(), 'No Contact record was expected');
    }
    
    @IsTest
    static void testForCoverage() {
     
        Account ugpAcc = new Account (Name = 'Acc Test No 1',Client_Segment__c='AB',Country_Risk__c='India');
        insert ugpAcc;
        Boolean isExceptionThrown = false;
        try {
            new MeetingConsoleLookupsSupport(new ApexPages.StandardController(ugpAcc));
            new MeetingConsoleLookupsSupport(new MeetingConsole_TasksController());
            new MeetingConsoleLookupsSupport(new CommitteeAttendee_ctrl());
            new MeetingConsoleLookupsSupport(new SubmissionAttendee_ctrl());
        }
        catch (Exception ex) {
            isExceptionThrown = true;
        }
        System.assert(!isExceptionThrown);
    }
    
}