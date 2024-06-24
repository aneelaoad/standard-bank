/****************************************************************
@ Author                    : Anurag Jain
@ Created Date              : 10/12/2011
@description               : Test Class for singleDeleteCCT controller class

@ Last Modified By          : Nikhita Reddy 
@ Last Modified Date        : 28/01/2013
@ Last Modified Reason      : Added test data and best practices and increasd coverage. 
                              Moved API version from 20 to 27.

@ Last Modified By          : Nikhita Reddy 
@ Last Modified Date        : 05/08/2013
@ Last Modified Reason      : Moved API version from 27 to 28

@ Last Modified By          : Abhishek Vaideeswaran
@ Last Modified On          : 07/12/2015
@ Last Modified Reason      : EN - 958 - Included test cases for validation to avoid deletion of Core Team Members for CIF Target Client by CC/CCBM

@ Last Modified By          : Abhishek Vaideeswaran
@ Last Modified On          : Feb 2016
@ Last Modified Reason      : EN - 1097 - Included test cases for validation to avoid deletion of Core Team Members for UGP/Immediate Parent CIF Target Client by CC/CCBM 

@ Last Modified By          : Jana Cechova
@ Last Modified On          : Apr 2016
@ Last Modified Reason      : US-1223: CST - Show error message immediately. Add test method for tessting functionality which was added to singleDeleteCCT.cls
*******************************************************************/
@IsTest
public class TC_singleDeleteCCT {
    @TestSetup
    private static void setupData() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getEnvironmentVariable(),
            TEST_DataFactory.getCcSettings(),
            TEST_DataFactory.getUserProfileIds(),
            TEST_DataFactory.getCstTeamRankings()
        });
    }
    
    @IsTest
    static void testSingleDeleteCct() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User u1 = (User) new BLD_USER(uow).useCib().getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow.commitWork();
        }

        Custom_Client_Team__c cctRec = (Custom_Client_Team__c) new BLD_ClientTeam(uow)
            .user(u1.Id)
            .role(DMN_ClientTeam.ROLE_CREDIT_RISK)
            .account(
                new BLD_Account(uow).useGroupParent()
                    .addOpportunity(
                    new BLD_Opportunity(uow)
                        .addTeamMember(
                        new BLD_OpportunityTeamMember(uow)
                            .userId(u1.Id)
                    )
                )
            )
            .getRecord();

        uow.commitWork();

        Test.startTest();
        try {
            Pagereference p = page.singleDeleteCCT;
            System.Test.setCurrentPage(p);
            p.getParameters().put('id', cctRec.Id);

            ApexPages.StandardController stdCon = new ApexPages.StandardController(cctRec);
            singleDeleteCCT controller = new singleDeleteCCT(stdCon);

            controller.back();

            controller.setcheckboxValue1(True);
            controller.getcheckboxValue1();
            controller.deleteSinglecct();

            controller.setcheckboxValue1(False);
            controller.getcheckboxValue1();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testSingleDeleteCctCcCoreUgp() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User ccUser = (User) new BLD_USER(uow).useCib().getRecord();
        User testUser = (User) new BLD_USER(uow).useCib().getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())){
        	uow.commitWork();
            List<SObject> settings = new List<SObject> {TEST_DataFactory.getEnvironmentVariable()};
            settings.addAll((List<SObject>) TEST_DataFactory.getCcSettings());
            settings.addAll((List<SObject>) TEST_DataFactory.getUserProfileIds());
        }

        BLD_Account accBld1 = new BLD_Account(uow).useGroupParent()
            .cibTarget(true)
            .CIF('Test_934085')
            .onboardedInSfdc(true);
        BLD_Account accBld2 = new BLD_Account(uow).useGroupParent()
            .cibTarget(true);

        System.runAs(ccUser){
            uow.commitWork();
        }

        Custom_Client_Team__c cct1 = (Custom_Client_Team__c) new BLD_ClientTeam(uow)
            .account(accBld1)
            .role(DMN_ClientTeam.ROLE_CREDIT_RISK)
            .user(testUser.Id)
            .coordinator(true)
            .getRecord();
        Custom_Client_Team__c cct2 = (Custom_Client_Team__c) new BLD_ClientTeam(uow)
            .account(accBld2)
            .role(DMN_ClientTeam.ROLE_GM_CHAMPION)
            .user(testUser.Id)
            .getRecord();

        uow.commitWork();

        Account a1 = [SELECT OwnerId FROM Account WHERE Id = :accBld1.getRecordId()];
        System.assertEquals(a1.OwnerId, testUser.Id);
        Test.startTest();
        System.runAs(testUser) {
            Pagereference p = page.singleDeleteCCT;
            System.Test.setCurrentPage(p);
            p.getParameters().put('idArray', cct1.Id + ',' + cct2.Id);
            
            ApexPages.StandardController stdCon = new ApexPages.StandardController(cct1);
            singleDeleteCCT controller = new singleDeleteCCT(stdCon);
            
            
            controller.setcheckboxValue1(True);
            controller.getcheckboxValue1();
            controller.deleteSinglecct();
            System.assertEquals(controller.corememberpresent, True);
            
            
            controller.setcheckboxValue1(False);
            controller.getcheckboxValue1();
            }                
        Test.stopTest();
        
    }
    
    @IsTest
    static void testSingleDeleteCctCcCoreIp() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User ccUser = (User) new BLD_USER(uow).useCib().getRecord();
        User testUser = (User) new BLD_USER(uow).useCib().getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
        }

        BLD_Account accBld1 = new BLD_Account(uow).useImmediateParent()
            .cibTarget(true)
            .CIF('Test_934085')
            .onboardedInSfdc(true);
        BLD_Account accBld2 = new BLD_Account(uow).useImmediateParent()
            .cibTarget(true);

        System.runAs(ccUser){
            uow.commitWork();
        }

        Custom_Client_Team__c cct1 = (Custom_Client_Team__c) new BLD_ClientTeam(uow)
            .account(accBld1)
            .role(DMN_ClientTeam.ROLE_CREDIT_RISK)
            .user(testUser.Id)
            .coordinator(true)
            .getRecord();
        Custom_Client_Team__c cct2 = (Custom_Client_Team__c) new BLD_ClientTeam(uow)
            .account(accBld2)
            .role(DMN_ClientTeam.ROLE_GM_CHAMPION)
            .user(testUser.Id)
            .getRecord();

        uow.commitWork();

        Account a1 = [SELECT OwnerId FROM Account WHERE Id = :accBld1.getRecordId()];
        System.assertEquals(a1.OwnerId, testUser.Id);
        test.startTest();
        System.RunAs(testUser){
            Pagereference p = page.singleDeleteCCT;
            System.Test.setCurrentPage(p);
            p.getParameters().put('idArray', cct1.Id + ',' + cct2.Id);

            ApexPages.StandardController stdCon = new ApexPages.StandardController(cct1);
            singleDeleteCCT controller = new singleDeleteCCT(stdCon);
            
            
            controller.setcheckboxValue1(True);
            controller.getcheckboxValue1();
            controller.deleteSinglecct();
            System.assertEquals(controller.corememberpresent, True);
            
            
            controller.setcheckboxValue1(False);
            controller.getcheckboxValue1();
            }                
             test.stopTest();
        
    }
    
    @IsTest
    static void testSingleDeleteCctCc() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User testUser = (User) new BLD_USER(uow).useCib().getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
        }

        Custom_Client_Team__c cctRec = (Custom_Client_Team__c) new BLD_ClientTeam(uow)
            .account(
                new BLD_Account(uow).useGroupParent()
            )
            .role(DMN_ClientTeam.ROLE_CREDIT_RISK)
            .coordinator(true)
            .user(testUser.Id)
            .getRecord();

        uow.commitWork();
        
        test.startTest();
        System.runAs(testUser) {
            Pagereference p = page.singleDeleteCCT;
            System.Test.setCurrentPage(p);
            p.getParameters().put('idArray', cctRec.Id);
            
            ApexPages.StandardController stdCon = new ApexPages.StandardController(cctRec);
            singleDeleteCCT controller = new singleDeleteCCT(stdCon);
            
            
            controller.setcheckboxValue1(True);
            controller.getcheckboxValue1();
            controller.deleteSinglecct();
            System.assertEquals(controller.corememberpresent, false);
            
            
            controller.setcheckboxValue1(False);
            controller.getcheckboxValue1();
            }                
             test.stopTest();
        
    }

    @IsTest
    static void testSingleDeleteCctCcbm() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User testUser = (User) new BLD_USER(uow).useCib().getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
        }

        Custom_Client_Team__c cctRec = (Custom_Client_Team__c) new BLD_ClientTeam(uow)
            .account(
                new BLD_Account(uow).useGroupParent()
            )
            .role(DMN_ClientTeam.ROLE_CREDIT_RISK)
            .ccbm(true)
            .user(testUser.Id)
            .getRecord();

        uow.commitWork();
        
        test.startTest();
        System.runAs(testUser) {
            Pagereference p = page.singleDeleteCCT;
            System.Test.setCurrentPage(p);
            p.getParameters().put('idArray', cctRec.Id);
            
            ApexPages.StandardController stdCon = new ApexPages.StandardController(cctRec);
            singleDeleteCCT controller = new singleDeleteCCT(stdCon);
            
            
            controller.setcheckboxValue1(True);
            controller.getcheckboxValue1();
            controller.deleteSinglecct();
            System.assertEquals(controller.corememberpresent, false);
            
            
            controller.setcheckboxValue1(False);
            controller.getcheckboxValue1();
            }                
             test.stopTest();
    }

    @IsTest
    static void testSingleDeleteCctCcbmCoreUgp() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User testUser = (User) new BLD_USER(uow).useCib().getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
        }

        Custom_Client_Team__c cctRec = (Custom_Client_Team__c) new BLD_ClientTeam(uow)
            .account(
                new BLD_Account(uow).useGroupParent()
                    .cibTarget(true)
                    .CIF('Test_934085')
                    .onboardedInSfdc(true)
            )
            .role(DMN_ClientTeam.ROLE_GM_CHAMPION)
            .coordinator(true)
            .user(testUser.Id)
            .getRecord();

        uow.commitWork();
        
        test.startTest();
        System.runAs(testUser) {
            Pagereference p = page.singleDeleteCCT;
            System.Test.setCurrentPage(p);
            p.getParameters().put('idArray', cctRec.Id);
            
            ApexPages.StandardController stdCon = new ApexPages.StandardController(cctRec);
            singleDeleteCCT controller = new singleDeleteCCT(stdCon);
            
            
            controller.setcheckboxValue1(True);
            controller.getcheckboxValue1();
            controller.deleteSinglecct();
            System.assertEquals(controller.corememberpresent, True);
            
            
            controller.setcheckboxValue1(False);
            controller.getcheckboxValue1();
            }                
             test.stopTest();
    }
    
    @IsTest
    static void testSingleDeleteCctCcbmCoreIp() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User testUser = (User) new BLD_USER(uow).useCib().getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
        }

        Custom_Client_Team__c cctRec = (Custom_Client_Team__c) new BLD_ClientTeam(uow)
            .account(
                new BLD_Account(uow).useImmediateParent()
                    .cibTarget(true)
                    .CIF('Test_934085')
                    .onboardedInSfdc(true)
            )
            .role(DMN_ClientTeam.ROLE_GM_CHAMPION)
            .coordinator(true)
            .user(testUser.Id)
            .getRecord();

        uow.commitWork();
        
        test.startTest();
        System.runAs(testUser) {
            Pagereference p = page.singleDeleteCCT;
            System.Test.setCurrentPage(p);
            p.getParameters().put('idArray', cctRec.Id);
            
            ApexPages.StandardController stdCon = new ApexPages.StandardController(cctRec);
            singleDeleteCCT controller = new singleDeleteCCT(stdCon);
            
            controller.setcheckboxValue1(True);
            controller.getcheckboxValue1();
            controller.deleteSinglecct();
            System.assertEquals(controller.corememberpresent, True);
            
            
            controller.setcheckboxValue1(False);
            controller.getcheckboxValue1();
            }                
             test.stopTest();
    }

    @IsTest
    static void testSingleDeleteCctDoesUserHasPrivilges() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User testUser = (User) new BLD_USER(uow).useCib().getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
        }

        Custom_Client_Team__c cctRec = (Custom_Client_Team__c) new BLD_ClientTeam(uow)
            .account(
                new BLD_Account(uow).useImmediateParent()
                    .cibTarget(true)
                    .CIF('Test_934085')
                    .onboardedInSfdc(true)
            )
            .role(DMN_ClientTeam.ROLE_GM_CHAMPION)
            .coordinator(true)
            .user(testUser.Id)
            .getRecord();

        uow.commitWork();
        
        test.startTest();
        System.runAs(testUser) {
            Pagereference p = page.singleDeleteCCT;
            System.Test.setCurrentPage(p);
            p.getParameters().put('idArray', cctRec.Id);

            ApexPages.StandardController stdCon = new ApexPages.StandardController(cctRec);
            singleDeleteCCT controller = new singleDeleteCCT(stdCon);
            
            set<id> newTestSet = new set<Id>();
            newTestSet.add(cctRec.Id);
            
            // Testing public string that should always return message for further execution logic for singleDeleteCCt.cls
            System.assertNotEquals(null,controller.doesUserHasPrivilges(newTestSet),'Returned msg from singleDeleteCCT.cls is empty unexpectedly.');
            
            
           }                
       test.stopTest();
    }

    @IsTest
    static void testSingleDeleteCctTestConstructor() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User testUser = (User) new BLD_USER(uow).useCib().getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
        }

        Custom_Client_Team__c cctRec = (Custom_Client_Team__c) new BLD_ClientTeam(uow)
            .account(
                new BLD_Account(uow).useImmediateParent()
                    .cibTarget(true)
                    .CIF('Test_934085')
                    .onboardedInSfdc(true)
            )
            .role(DMN_ClientTeam.ROLE_GM_CHAMPION)
            .coordinator(true)
            .user(testUser.Id)
            .getRecord();

        uow.commitWork();
        
        Test.startTest();
        try {
            System.runAs(testUser) {
                Pagereference p = page.singleDeleteCCT;
                System.Test.setCurrentPage(p);
                p.getParameters().put('idArray', cctRec.Id);
                singleDeleteCCT controller = new singleDeleteCCT();
            }
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
       Test.stopTest();
    }
}