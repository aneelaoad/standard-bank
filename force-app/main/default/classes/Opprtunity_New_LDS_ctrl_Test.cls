/*************************************************************************
    @ Author:       Abhishek V
    @ Date:         1 Sep 2016
    @ Description:  US-1425: Test Class for Opprtunity_New_LDS_ctrl
    
    @ Last Modified : Abhishek V
    @ Date          : 24 Nov 2016
    @ Description   : Introduced new test method to test ContactRole
    
    @ Last Modified : Abhishek V
    @ Date          : 08 Dec 2016
    @ Description   : Introduced new test method to test Campign functionality
*************************************************************************/

@IsTest
public class Opprtunity_New_LDS_ctrl_Test{

    
    @TestSetup
    static void prepareData() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Account(uow)
            .name('TestAccountLookup')
            .addContact(
                new BLD_Contact(uow)
                    .name('Test ', 'Contact Role')
            )
            .addOpportunity(
                new BLD_Opportunity(uow)
                    .name('TestOpptyLookup')
            );

        new BLD_Campaign(uow)
            .name('TestCampaignLookup')
            .active(true);

        uow.commitWork();
    }

    @IsTest
    static void testinsertoppty() {
        Account foundAccount = [Select Id from Account where Name = 'TestAccountLookup'];
        Opportunity parent = [Select ID from Opportunity where Name = 'TestOpptyLookup'];
        
        Schema.DescribeSObjectResult d = Schema.SObjectType.Opportunity;
        String keyPrefix = d.getKeyPrefix();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Opportunity());
        Opprtunity_New_LDS_ctrl ctrl = new Opprtunity_New_LDS_ctrl(sc);
        
        Pagereference pref = ctrl.canceloppty();
        System.assertEquals(ctrl.navigateurl, '/'+ keyPrefix +'/o');
        
        ApexPages.currentPage().getParameters().put('accId', foundAccount.Id);
        ApexPages.currentPage().getParameters().put(Label.Cross_Sell_Opportunity+'_lkId', parent.Id);
        ApexPages.currentPage().getParameters().put('opp14', 'Desc');
        
        ctrl = new Opprtunity_New_LDS_ctrl(sc);
        ctrl.saveoppty();
        System.assertnotEquals(ctrl.errorMsginsert, '');
        System.assertEquals(ctrl.navigateurl, '');
        
        ctrl.opprec.Name = 'Test Oppty';
        ctrl.StartDateString = '';
        ctrl.Enddatestring = '';
        ctrl.StartDateString = '12/11';
        ctrl.StartDateString = '12/11/2016';
        ctrl.Enddatestring = '12/11/2030';
        ctrl.opprec.Start_Date__c = Date.today();
        ctrl.opprec.CloseDate = Date.Today().addDays(10);
        ctrl.saveoppty();
        System.assertEquals(ctrl.errorMsginsert, '');
        System.assertnotEquals(ctrl.navigateurl, '');
        
        
        pref = ctrl.canceloppty();
        System.assertnotEquals(ctrl.navigateurl, '/'+ keyPrefix +'/o');
        
    }
    
    @IsTest
    static void testinsertoppty_contactrole() {
        Account foundAccount = [Select Id from Account where Name = 'TestAccountLookup' limit 1];
        Contact cont = [Select Id from Contact where LastName = 'Contact Role' limit 1];
        Campaign camp = [Select Id, Name from Campaign where Name = 'TestCampaignLookup' limit 1];
        
        Schema.DescribeSObjectResult d = Schema.SObjectType.Opportunity;
        String keyPrefix = d.getKeyPrefix();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Opportunity());
        
        ApexPages.currentPage().getParameters().put('conId', cont.Id);
        ApexPages.currentPage().getParameters().put('campid', camp.Id);
        ApexPages.currentPage().getParameters().put('accId', foundAccount.Id);
        ApexPages.currentPage().getParameters().put('opp14', 'Desc');
        Opprtunity_New_LDS_ctrl  ctrl1 = new Opprtunity_New_LDS_ctrl(sc);
        ctrl1.opprec.Name = 'Test Oppty';
        ctrl1.StartDateString = '12/11/2016';
        ctrl1.Enddatestring = '12/11/2030';
        ctrl1.opprec.Start_Date__c = Date.today();
        ctrl1.opprec.CloseDate = Date.Today().addDays(10);
        ctrl1.saveoppty();
        System.assertEquals(ctrl1.errorMsginsert, '');
        System.assertEquals(ctrl1.errorMsgcrinsert, '');
        Pagereference pref1 = ctrl1.canceloppty();
        System.assertEquals(ctrl1.navigateurl, '/'+ cont.Id);
    }
    
    @IsTest
    static void testinsertoppty_withcamp() {
        Account foundAccount = [Select Id from Account where Name = 'TestAccountLookup' limit 1];
        Campaign camp = [Select Id, Name from Campaign where Name = 'TestCampaignLookup' limit 1];
        
        Schema.DescribeSObjectResult d = Schema.SObjectType.Opportunity;
        String keyPrefix = d.getKeyPrefix();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Opportunity());
        
        ApexPages.currentPage().getParameters().put('campid', camp.Id);
        ApexPages.currentPage().getParameters().put('accId', foundAccount.Id);
        ApexPages.currentPage().getParameters().put('opp14', 'Desc');
        Opprtunity_New_LDS_ctrl  ctrl1 = new Opprtunity_New_LDS_ctrl(sc);
        ctrl1.opprec.Name = 'Test Oppty';
        ctrl1.StartDateString = '12/11/2016';
        ctrl1.Enddatestring = '12/11/2030';
        ctrl1.opprec.Start_Date__c = Date.today();
        ctrl1.opprec.CloseDate = Date.Today().addDays(10);
        ctrl1.saveoppty();
        System.assertEquals(ctrl1.errorMsginsert, '');
        System.assertEquals(ctrl1.errorMsgcrinsert, '');
        Pagereference pref1 = ctrl1.canceloppty();
        System.assertEquals(ctrl1.navigateurl, '/'+ camp.Id);
    }
        
}