/*************************************************************************
    @ Author        : psvestka
    @ Date          : 18. 8. 2015
    @ Description : Force.com reviewer - Blocker and Critical issues - 20150608.xlsx

    @ Last Modified By      :   Petr Svestka
    @ Last Modified On      :   Sep 19, 2016
    @ Last Modified Reason  :   US-1495 - efficient fetching of RTs require a RT label, the test uses an old RT label - changing to a new one
    
    @ Last Modified By      :   Jana Cechova
    @ Last Modified On      :   Nov 4, 2016
    @ Last Modified Reason  :   US-1655: OB: Delegated Approver for Client Onboarding - users are not able to change Delegated Approver (except Admins)
****************************************************************************/

@IsTest
private class UserTriggerTest {

    @TestSetup
    private static void prepareData() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getCcSettings(),
            TEST_DataFactory.getEnvironmentVariable()
        });
    }

    static testMethod void testBankContactSync() {
        // after insert, after update
        Test.startTest();

        User u = (User) new BLD_USER().useSysAdmin().syncContact()
            .outlookId('asdwadwa')
            .commitWork()
            .getRecord();

        Test.stopTest(); //will run @future method

        List<Contact> cons = [SELECT id, Name, Outlook_Exchange_System_ID__c FROM Contact WHERE OwnerId = :u.id];
        system.assertEquals(1, cons.size(), 'There should be a single contact created that is related to the user');

        User uAfter = [SELECT id, Contact_Sync_ID__c, Outlook_Exchange_System_ID__c FROM User WHERE id = :u.id];
        system.assertEquals(cons[0].id, uAfter.Contact_Sync_ID__c, 'User\'s Contact_Sync_ID__c should be equal to an Id of a Contact related via Outlook_Exchange_System_ID__c');
    }

    static testMethod void testHandleCaseOnUser() {
        Test.startTest();

        User u = (User) new BLD_USER().useCib().cibGlobalArea(DMN_User.CIB_GA_CIBSA).syncContact().commitWork().getRecord();

        Test.stopTest(); //will run @future method

        Case defaultCase = New Case();
        defaultCase.OwnerId = u.id;
        defaultCase.Status = 'New';
        defaultcase.Subject = 'Test Subject';
        defaultcase.Description = 'Test Description';
        defaultcase.Priority  = 'Medium';
        defaultcase.CurrencyIsoCode = 'ZAR';
        defaultcase.recordtypeid = GlobalCache.getRecordTypeId('Case', 'CIB Client Case');
        defaultCase.Origin = 'Email';
        insert defaultCase;

        // after update
        User uAfter = [SELECT id, Contact_Sync_ID__c, Outlook_Exchange_System_ID__c FROM User WHERE id = :u.id];
        uAfter.User_CIB_Global_Area__c = 'CIBI'; // change
        update uAfter;

        Case foundCase = [SELECT id, Case_Owner_CIB_Global_Area__c FROM Case WHERE id = :defaultCase.id];
        system.assertEquals(uAfter.User_CIB_Global_Area__c, foundCase.Case_Owner_CIB_Global_Area__c, 'Case should be updated so that Case_Owner_CIB_Global_Area__c equals to its Owner\'s User_CIB_Global_Area__c');
    }
    static testMethod void testUserNotAbleToChangeDelegatedApprover() {
        
        Test.startTest();

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User u = (User) new BLD_USER(uow).useCib().outlookId('something here').syncContact().getRecord();
        User u2 = (User) new BLD_USER(uow).useCib().outlookId('something here').syncContact().getRecord();
        uow.commitWork();
        
        Test.stopTest(); //will run @future method

        User uAfter = [SELECT id, DelegatedApproverId FROM User WHERE id = :u.id];
        system.assertEquals(null, uAfter.DelegatedApproverId);
        
        // Try to update
        uAfter.DelegatedApproverId = u2.Id;
        
        system.runAs(u){
            try {
                update uAfter;
                } catch (DmlException e) {
                    System.assert( e.getMessage().contains(Label.Delegated_Approver_Error), 
                    e.getMessage() );
                }
        }
    
    }
    static testMethod void testAdminAbleToChangeDelegatedApprover() {
        Test.startTest();

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User u = (User) new BLD_USER(uow).useSysAdmin().outlookId('something here').syncContact().getRecord();
        User u2 = (User) new BLD_USER(uow).useSysAdmin().outlookId('something here').syncContact().getRecord();
        User u3 = (User) new BLD_USER(uow).useCib().outlookId('something here').syncContact().getRecord();
        uow.commitWork();
        
        Test.stopTest(); //will run @future method


        User uAfter = [SELECT id, DelegatedApproverId FROM User WHERE id = :u.id];
        system.assertEquals(null, uAfter.DelegatedApproverId);
        uAfter.DelegatedApproverId = u3.Id;
        
        system.runAs(u2){
                update uAfter;    
        }
        uAfter = [SELECT id, DelegatedApproverId FROM User WHERE id = :u.id];
        system.assertNotEquals(null, uAfter.DelegatedApproverId,'Delegated Approver was not changed correctly via Admin.');
    }
}