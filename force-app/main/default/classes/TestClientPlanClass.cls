/************************************************************************
* @author       Nitish Kumar
* @date         Oct -2013
* @description  Test class for ClientPlanClass

    @ Last Modified By  :   Prabhanshu Agrawal
    @ Last Modified On  :   20- Mar -2014

    @ Last Modified By  : Abhishek V
    @ Last Modified On  : Jan 2016
    @ Modification Description : EN-686 : Introduced a test method testClientPlanClass_francoaccess to test
                                 Client Plan Access to CIBROA CC South & Central Africa Mgt Public Group based on Client Reporting Franco
                                 
    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Mar 1, 2016
    @ Modification Description : US-1177 : adjusting logic using ProductSubsets__c
    
    @ Last Modified By  : Jana Cechova
    @ Last Modified On  : Apr 19, 2016
    @ Modification Description : US-1282 : adjusting logic for CommB/CIB - Display appropriate error message.
************************************************************************/
@IsTest
private class TestClientPlanClass{

    // Get Account Record type Map
        public static Map < String, Schema.RecordTypeInfo > mapAccountRecordTypes = Account.SObjectType.getDescribe().getRecordTypeInfosByName();
        // Get the record type id of from the Map based on the Name
        public static Id childRecTypeId = mapAccountRecordTypes.get('Child').getRecordTypeId();

        // Get Contact Record type Map
        public static Map < String, Schema.RecordTypeInfo > mapContactRecordTypes = Contact.SObjectType.getDescribe().getRecordTypeInfosByName();
        // Get the record type id of from the Map based on the Name
        public static Id clientContactRecordtype = mapContactRecordTypes.get('Client Contact Record Type').getRecordTypeId();

         //Static data Member
          public static List < Account > olstTestAccount;
          public static List < Contact > olstContact;
    public static List < Opportunity > olstOpportunity;
          public static List < Custom_Client_Team__c > lstCCT;
          public static List < Reporting_Franco_to_Public_Group__c > lstfranco;
          public static List < CSTTeamRoleRanking__c > olstCstTeamRankingSettings ;
          public static List <CSTManyperRegionTeamRoles__c> olstCSTManyperRegionTeamRoles ;
          public static List < ClientCoordinatorSettings__c > lstCCS;
          public static List < UserProfileId__c > lstUPI;
          public static List < Opportunity > createOppList;
          public static List < Task > createTaks ;
          public static User logInUsr;

      @TestSetup static void francosetup() {

                UserRole role1 = [Select ID from UserRole where DeveloperName = 'CIBROAGlobalArea'];

                User u1 = (User) new BLD_USER('testjaco.burger@standardbank.co.za').getRecord();
                u1.ProfileId = UTL_Profile.getProfileId(DMN_Profile.CLIENT_COVERAGE_MOBILE_USER_INSIGHTS);
                u1.alias = 'testjaco';
                u1.Title = 'Head: Corporate Banking Africa';
                u1.email = 'testjaco.burger@standardbank.co.za';
                u1.lastname = 'Burger';
                u1.city = 'Johannesburg';
                u1.UserRoleId = role1.ID;
                u1.User_Division__c = 'Client Coverage';
                u1.Business_Unit__c = 'Management';
                u1.User_CIB_Global_Area__c = 'CIBROA';
                u1.country = 'South Africa';
                u1.State = 'Gauteng';
                u1.RecieveBirthdayReminderTasks__c = False;
                u1.Sync_with_Contact__c = True;
                u1.timezonesidkey = 'Africa/Johannesburg';
                insert u1;

                Group g = [Select ID, Name, DeveloperName from Group where Name = 'CIBROA Core Markets'];

                GroupMember gm = new GroupMember(UserOrGroupId = u1.Id, GroupId = g.Id);
                insert gm;

      }
      static void createTestData(){
        //TEST DATA
          fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
          User testUser = (User) new BLD_USER(uow).useCib().getRecord();
          User testUser2 = (User) new BLD_USER(uow).useCib().getRecord();
          User testUser3 = (User) new BLD_USER(uow).useCib().getRecord();
          User testUser4 = (User) new BLD_USER(uow).useSysAdmin().getRecord();
          logInUsr = (User) new BLD_USER(uow).useSysAdmin().getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
        }   

          TEST_DataFactory.insertSettings(new List<Object> {
              TEST_DataFactory.getCcSettings(),
              TEST_DataFactory.getReportingFrancos(),
              TEST_DataFactory.getCstTeamRankings(),
              TEST_DataFactory.getCSTManyPerRegionTeamRoles(),
              TEST_DataFactory.getEnvironmentVariable()
          });

          BLD_Account accBld = new BLD_Account(uow).useChild()
              .proposedClientCoordinator(testUser4).CIF('0').CIFActiveCode('A');
          olstTestAccount = new List<Account> {
              (Account) accBld.getRecord()
          };

          createTaks = new List<Task> {
              (Task) new BLD_Task(uow).linkToParent(accBld).getRecord(),
              (Task) new BLD_Task(uow).linkToParent(accBld).getRecord()
          };

          createOppList = new List<Opportunity> {
              (Opportunity) new BLD_Opportunity(uow).client(accBld)
                  .addProduct(new BLD_Product(uow))
                  .addProduct(new BLD_Product(uow))
                  .getRecord(),
              (Opportunity) new BLD_Opportunity(uow).client(accBld).getRecord(),
              (Opportunity) new BLD_Opportunity(uow).client(accBld).getRecord(),
              (Opportunity) new BLD_Opportunity(uow).client(accBld).getRecord(),
              (Opportunity) new BLD_Opportunity(uow).client(accBld).getRecord(),
              (Opportunity) new BLD_Opportunity(uow).client(accBld)
                  .addProduct(new BLD_Product(uow))
                  .getRecord()
          };

          lstCCT = new List<Custom_Client_Team__c> {
              (Custom_Client_Team__c) new BLD_ClientTeam(uow).account(accBld).clientAccess(DMN_ClientTeam.ACCESS_EDIT).role(DMN_ClientTeam.ROLE_TPS_CHAMPION).user(testUser.Id).getRecord(),
              (Custom_Client_Team__c) new BLD_ClientTeam(uow).account(accBld).clientAccess(DMN_ClientTeam.ACCESS_EDIT).role(DMN_ClientTeam.ROLE_CLIENT_ANALYST).user(testUser2.Id).getRecord(),
              (Custom_Client_Team__c) new BLD_ClientTeam(uow).account(accBld).clientAccess(DMN_ClientTeam.ACCESS_EDIT).role(DMN_ClientTeam.ROLE_CLIENT_ANALYST).user(testUser3.Id).getRecord(),
              (Custom_Client_Team__c) new BLD_ClientTeam(uow).account(accBld).clientAccess(DMN_ClientTeam.ACCESS_EDIT).role(DMN_ClientTeam.ROLE_CLIENT_ANALYST).user(testUser4.Id).getRecord()
          };

          uow.commitWork();

          createOppList[4].StageName = DMN_Opportunity.ST_CLOSED_LOST ;
          createOppList[4].ReasonForWinLossPickList__c = 'Legal';
          createOppList[4].Reason_Won_Lost_Detail__c = 'Legal Terms Unfavourable';
          createOppList[4].Reason_Won_Lost_Comments__c = 'Comment';
          createOppList[5].StageName = DMN_Opportunity.ST_CLOSED_WON ;
          createOppList[5].ReasonForWinLossPickList__c = 'Pricing Competitive';
          createOppList[5].Reason_Won_Lost_Detail__c = 'Pricing Competitive';
          createOppList[5].Reason_Won_Lost_Comments__c = 'Comment';

          update new List<Opportunity>{createOppList[4], createOppList[5]};

      }

    @IsTest
    static void testClientPlan(){

            createTestData();

            Client_Plan__c cplan = new Client_Plan__c();
            cplan.Client_Name__c = olstTestAccount[0].Id;
            insert cplan;

            CAM_Selection__c caM = new CAM_Selection__c();
            caM.Client_Id__c = olstTestAccount[0].Id;
            insert caM ;

            cplan.Opportunity_Selection__c = createOppList[0].Id + ',' + createOppList[5].Id;
            cplan.Task_Selection__c = createTaks[0].Id ;
            cplan.Team_Selection__c = lstCCT[0].Id ;

            update cplan ;

            Test.startTest();
            try {
                ApexPages.StandardController controller = new ApexPages.StandardController(olstTestAccount[0]);
                ClientPlanClass cp = new ClientPlanClass(controller);
                cp.csiComponentController = new CsiComponentController(olstTestAccount[0].Id,cp);

                ClientPlanClass cp1 = new ClientPlanClass();
                cp.checkClientPlan();
                Date testSnapShotDate = cp.snapshotDate ;
                List<ClientPlanClass.cPlanOpportunity> cPlanOpp = cp.getOpportunitylst();
                List<ClientPlanClass.cPlanWonLostOpp > cplanWOnOpp = cp.getWonLostOpportunitylst();
                List<ClientPlanClass.CPTeamSelection> cPTeam = cp.getClientTeam();
                List<ClientPlanClass.cPlanOpportunity> cPlanOpp2 = cp.getSelectedOpportunitylst();
                ClientPlanClass.cPlanOpportunity testOpp = new  ClientPlanClass.cPlanOpportunity();
                List<ClientPlanClass.cPlanWonLostOpp > cplanWOnOpp2 = cp.getSelectedWonLostOpportunitylst();
                List<ClientPlanClass.CPTaskSelection > cplanTask = cp.getTasks();
                ClientPlanClass.CPTeamSelection cpTeamTest = new ClientPlanClass.CPTeamSelection();
                ClientPlanClass.CPTaskSelection cpTaskTest = new ClientPlanClass.CPTaskSelection();

                Attachment att = new Attachment();
                att.parentId = caM.Id ;
                att.Name = 'Client Plan 2012-12-01 Test V-1.pdf' ;
                Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
                att.Body = bodyBlob ;
                insert att ;

                testOpp.opp = createOppList[0];
                testOpp.currentRev = 2.00 ;
                testOpp.currentRevcurr = 1.00 ;
                testOpp.totalRev = 5.00 ;

                ClientPlanClass.cPlanWonLostOpp testOpp2 = new ClientPlanClass.cPlanWonLostOpp();
                testOpp2.wonLostOpp = createOppList[4];
                testOpp2.wonLostcurrrev = 2.00;
                testOpp2.wonLosttotalRev = 3.00 ;

                cp.getPicklistValues() ;
                cp.getRelationship();
                cp.getcPlanCurrency();
                cp.setcPlanCurrency('USD');
                cp.getCurrencies();
                cp.getISO();
                cp.getcPlanCurrencyTop();
                cp.setcPlanCurrencyTop('USD');
                cp.getSelectedTasks();
                Boolean testAccess = cp.checkPermission ;
                cp.attachClientPlan();
                cp.checkClientPlan();
                cp.getClientTeamCC();
                cp.getClientTeamNotCC();
                cp.getDivisionMap();
                cp.refreshPage();
                cp.refreshPage1();
            }
            catch (Exception ex) {
                System.assert(false, ex.getMessage());
            }
            Test.stopTest();
    }

    @IsTest
    static void testClientPlan2(){
        try {
            olstTestAccount = new List<Account> {(Account) new BLD_Account().useChild().CIF('0').CIFActiveCode('A').commitWork().getRecord()};

            ProductSubsets__c pSubSet = new ProductSubsets__c();
            pSubSet.name = 'Advisory';
            pSubSet.parent_product__c = 'Advisory';
            pSubSet.Product_Division__c = 'Investment Banking';
            insert  pSubSet;

            ApexPages.StandardController controller = new ApexPages.StandardController(olstTestAccount[0]);
            ClientPlanClass cp = new ClientPlanClass(controller);

            cp.checkClientPlan();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
     }

    @IsTest
    static void testClientPlan3(){
        createTestData();
        Test.startTest();
        try {
            System.runAs(logInUsr){
                ApexPages.StandardController controller = new ApexPages.StandardController(olstTestAccount[0]);
                ClientPlanClass cp = new ClientPlanClass(controller);
                cp.csiComponentController = new CsiComponentController(olstTestAccount[0].Id,cp);
                Date testSnapShotDate = cp.snapshotDate ;

                List<ClientPlanClass.cPlanOpportunity> cPlanOpp = cp.getOpportunitylst();
                List<ClientPlanClass.cPlanWonLostOpp > cplanWOnOpp = cp.getWonLostOpportunitylst();
                List<ClientPlanClass.CPTeamSelection> cPTeam = cp.getClientTeam();
                List<ClientPlanClass.cPlanOpportunity> cPlanOpp2 = cp.getSelectedOpportunitylst();
                ClientPlanClass.cPlanOpportunity testOpp = new  ClientPlanClass.cPlanOpportunity();
                List<ClientPlanClass.cPlanWonLostOpp > cplanWOnOpp2 = cp.getSelectedWonLostOpportunitylst();
                List<ClientPlanClass.CPTaskSelection > cplanTask = cp.getTasks();

                testOpp.opp = createOppList[0];
                testOpp.currentRev = 2.00 ;
                testOpp.currentRevcurr = 1.00 ;
                testOpp.totalRev = 5.00 ;

                ClientPlanClass.cPlanWonLostOpp testOpp2 = new ClientPlanClass.cPlanWonLostOpp();
                testOpp2.wonLostOpp = createOppList[4];
                testOpp2.wonLostcurrrev = 2.00;
                testOpp2.wonLosttotalRev = 3.00 ;

                cp.getPicklistValues() ;
                cp.getRelationship();
                cp.getcPlanCurrency();
                cp.setcPlanCurrency('USD');
                cp.getCurrencies();
                cp.getISO();
                cp.getcPlanCurrencyTop();
                cp.setcPlanCurrencyTop('USD');
                cp.getSelectedTasks();
                Boolean testAccess = cp.checkPermission ;
                cp.attachClientPlan();
                cp.checkClientPlan();
                cp.getClientTeamCC();
                cp.getClientTeamNotCC();
                cp.getDivisionMap();
                cp.refreshPage();
                cp.refreshPage1();
            }
            Test.stopTest();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }

    @IsTest
    static void testClientPlan4(){
        createTestData();
        Test.startTest();
        try {
            ApexPages.StandardController controller = new ApexPages.StandardController(olstTestAccount[0]);
            ClientPlanClass cp = new ClientPlanClass(controller);
            cp.csiComponentController = new CsiComponentController(olstTestAccount[0].Id,cp);
            PageReference pageRef = Page.ClientPlan;
            Test.setCurrentPage(pageRef);

            Date testSnapShotDate = cp.snapshotDate ;
            List<ClientPlanClass.cPlanOpportunity> cPlanOpp = cp.getOpportunitylst();
            List<ClientPlanClass.cPlanWonLostOpp > cplanWOnOpp = cp.getWonLostOpportunitylst();
            List<ClientPlanClass.CPTeamSelection> cPTeam = cp.getClientTeam();
            List<ClientPlanClass.cPlanOpportunity> cPlanOpp2 = cp.getSelectedOpportunitylst();
            ClientPlanClass.cPlanOpportunity testOpp = new  ClientPlanClass.cPlanOpportunity();
            List<ClientPlanClass.cPlanWonLostOpp > cplanWOnOpp2 = cp.getSelectedWonLostOpportunitylst();
            List<ClientPlanClass.CPTaskSelection > cplanTask = cp.getTasks();

            testOpp.opp = createOppList[0];
            testOpp.currentRev = 2.00 ;
            testOpp.currentRevcurr = 1.00 ;
            testOpp.totalRev = 5.00 ;

            ClientPlanClass.cPlanWonLostOpp testOpp2 = new ClientPlanClass.cPlanWonLostOpp();
            testOpp2.wonLostOpp = createOppList[4];
            testOpp2.wonLostcurrrev = 2.00;
            testOpp2.wonLosttotalRev = 3.00 ;

            cp.getPicklistValues() ;
            cp.getRelationship();
            cp.getcPlanCurrency();
            cp.setcPlanCurrency('USD');
            cp.getCurrencies();
            cp.getISO();
            cp.getcPlanCurrencyTop();
            cp.setcPlanCurrencyTop('USD');
            cp.getSelectedTasks();
            Boolean testAccess = cp.checkPermission ;
            cp.attachClientPlan();
            cp.checkClientPlan();
            cp.getClientTeamCC();
            cp.getClientTeamNotCC();
            cp.getDivisionMap();
            cp.refreshPage();
            cp.refreshPage1();
            cp.submitForApproval();
            cp.check_Permission_for_sector_manager();
        }
        catch(Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testClientPlanFrancoAccess(){

                createTestData();
                Boolean usrchk = false;
                Group g = [Select ID, Name, DeveloperName from Group where Name = 'CIBROA Core Markets'];
                User u1 = [Select ID, UserName from User where alias = 'testjaco' limit 1];
                List<GroupMember> gm = [Select GroupId, UserOrGroupId from GroupMember where GroupID = :g.Id];

                for(GroupMember grpm: gm){
                    if(grpm.UserOrGroupId == u1.Id){
                        usrchk = true;
                    }
                }

                System.assertEquals(usrchk, true);

                olstTestAccount[0].Client_Franco__c = 'West Africa';
                update olstTestAccount[0];

                Account acc = [Select ID, Client_Franco__c from Account where ID = :olstTestAccount[0].Id];
                System.assertEquals(acc.Client_Franco__c, 'West Africa');
                
                if(acc.Client_Franco__c == 'West Africa'){
                    AccountShare accsrec = new AccountShare(AccountID = olstTestAccount[0].ID, UserOrGroupID = u1.ID, AccountAccessLevel = 'Edit', OpportunityAccessLevel = 'Read');
                    insert accsrec;
                }
                
                //Check if user has Edit Access on Account

            Test.startTest();
                System.runAs(u1){
                    ApexPages.StandardController controller = new ApexPages.StandardController(olstTestAccount[0]);
                    ClientPlanClass cp = new ClientPlanClass(controller);
                    cp.csiComponentController = new CsiComponentController(olstTestAccount[0].Id,cp);
                    System.assertEquals(cp.currentId , olstTestAccount[0].Id);
                    PageReference pageRef = Page.ClientPlan;
                    Test.setCurrentPage(pageRef);
                    cp.currentId = olstTestAccount[0].Id;
                    Boolean cpchk = cp.checkPermission;

                    // Check if Client plan was created
                    List <Client_Plan__c> isClientPlanIsCreated = [select id from Client_Plan__c where Client_Name__c =: olstTestAccount[0].id];
                    // User has acces to edit but client plan does not created so the method checkPermission return true
                    System.assertEquals(cpchk , true);
                    
                    System.assertEquals(cp.check_Permission_for_client_reporting_franco(), True);
                }
            }
}