/*************************************************************************\
    @ Author        : Anurag Jain
    @ Date          : April, 2011
    @ Test File     : NA
    @ Description   : This Test class covers the test cases for the SA_AddCustomClientTeam controller class
    @
    @
    @ Audit Trial   : Repeating block for each change to the code
    @ Last Modified By  :   Nikhita Reddy
    @ Last Modified On  :   26/02/2013
    @ Last Modified Reason  :   Used test data and added best practices.
                                Changed the version from 20 to 27.
                                
    @ Last Modified By  :   Ankit Khandelwal    
    @ Last Modified On  :   10-July-2013
    @ Description   :       Increased code coverage 
    
    @ Last Modified By  :   Charles Mutsu    
    @ Last Modified On  :   05-Aug-2013
    @ Description   :       Updated API version from 27 to 28 
    
    @ Last Modified By          : Abhishek Vaideeswaran
    @ Last Modified On          : 07/12/2015
    @ Last Modified Reason      : EN - 958 - Included test cases for validation to avoid addition of Core Team Members for CIF Target Client by CC/CCBM   
    
    @ Last Modified By          : Abhishek Vaideeswaran
    @ Last Modified On          : Feb 2016
    @ Last Modified Reason      : EN - 1097 - Included test cases for validation to avoid addition of Core Team Members for UGP/Immediate Parent CIF Target Client by CC/CCBM   
****************************************************************************/

@isTest(SeeAllData=false)
public class TC_SA_AddCustomClientTeam {

    @TestSetup
    private static void setupData() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getEnvironmentVariable(),
            TEST_DataFactory.getErrorMessages(),
            TEST_DataFactory.getCstCoreRoles()
        });
    }

    //To test CST member addition with CIB roles
    static testMethod void testSA_AddCustomClientTeam() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User stdUser = (User) new BLD_USER(uow).useCib().getRecord();
        User admUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        User admUser_teammem1 = (User) new BLD_USER(uow).useSysAdmin().division(DMN_User.GM_DIVISION).getRecord();
        User admUser_teammem2 = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        User admUser_teammem3 = (User) new BLD_USER(uow).useSysAdmin().division(DMN_User.GM_DIVISION).getRecord();
        User admUser_teammem4 = (User) new BLD_USER(uow).useSysAdmin().getRecord();
		System.runAs(new User(Id = UserInfo.getUserId())) {
        	uow.commitWork();
        }
        
        System.runAs(admUser) {

            TEST_DataFactory.insertSettings(new List<Object> {
                TEST_DataFactory.getCcSettings(),
                TEST_DataFactory.getCstTeamRankings(),
                TEST_DataFactory.getCSTManyPerRegionTeamRoles(),
                TEST_DataFactory.getUserProfileIds()
            });

            BLD_Account accBld = new BLD_Account(uow).useGroupParent()
                .cibTarget(true);
            List<Account> lstAcc = new List<Account> {
                (Account) accBld.getRecord()
            };

            List<Custom_Client_Team__c> lstCCT1 = new List<Custom_Client_Team__c> {
                (Custom_Client_Team__c) new BLD_ClientTeam(uow)
                    .account(accBld)
                    .role(DMN_ClientTeam.ROLE_GM_EXECUTION_MANAGER)
                    .user(admUser_teammem1.Id)
                    .coordinator(true)
                    .getRecord(),
                (Custom_Client_Team__c) new BLD_ClientTeam(uow)
                    .account(accBld)
                    .role(DMN_ClientTeam.ROLE_CREDIT_RISK)
                    .user(stdUser.Id)
                    .ccbm(true)
                    .getRecord()
            };

            uow.commitWork();

            system.Test.startTest();
            Pagereference p = page.SA_AddCustomClient_UserView;

            p.getParameters().put('id', lstAcc[0].id);
            p.getParameters().put('Owner', String.valueof(lstAcc[0].OwnerId));

            System.Test.setCurrentPage(p);
    
            SA_AddCustomClientTeam controller = new SA_AddCustomClientTeam();
            System.assertEquals(controller.Adminflag, True);
            System.assertEquals(controller.ccorbmcoreinsert, false);
            System.assertEquals(controller.disableReplaceBtn, True);
            Controller.CCTObj.Client_Role__c = DMN_ClientTeam.ROLE_GM_EXECUTION_MANAGER;
            controller.CCTObj.team_member__c = admUser_teammem2.Id;
            Controller.SaveNew();
            System.assertEquals(controller.disableReplaceBtn, True);
            Controller.ReplaceRec();
            Controller.back();
            Controller.Cancel();
            
            SA_AddCustomClientTeam controller1 = new SA_AddCustomClientTeam();
            controller1.CCTObj.Client_Role__c = Null;
            Controller1.CCTObj.Client_coordinator__c = false;
            controller1.CCTObj.team_member__c = admUser_teammem3.Id;

            system.runas(stdUser) {
                SA_AddCustomClientTeam controller4 = new SA_AddCustomClientTeam();
                Controller4.CCTObj.Client_Role__c = 'Structurer';
                Controller4.CCTObj.Client_coordinator__c = false;
                Controller4.CCTObj.team_member__c = admUser_teammem2.Id;
                Controller4.SaveRec();
                System.assertEquals(controller.ccorbmcoreinsert, false);
            }
            
            SA_AddCustomClientTeam controller5 = new SA_AddCustomClientTeam();
            Controller5.CCTObj.Client_Role__c = 'GM Champion';
            Controller5.CCTObj.Account__c = lstAcc[0].Id ;
            Controller5.CCTObj.Client_coordinator__c = true;
            Controller5.CCTObj.team_member__c = admUser_teammem4.Id;

            SA_AddCustomClientTeam controller6 = new SA_AddCustomClientTeam();
            Controller6.CCTObj.Client_Role__c = 'GM Champion';
            Controller6.CCTObj.Account__c = lstAcc[0].Id ;
            Controller6.CCTObj.Client_coordinator_BM__c = true;
            Controller6.CCTObj.team_member__c = admUser_teammem4.Id;

            SA_AddCustomClientTeam controller7 = new SA_AddCustomClientTeam();
            Controller7.CCTObj.Client_Role__c = DMN_ClientTeam.ROLE_ADVISORY_BANKER;
            Controller7.CCTObj.Account__c = lstAcc[0].Id ;
            Controller7.CCTObj.Client_coordinator__c = True;
            Controller7.CCTObj.Client_coordinator_BM__c = True;
            Controller7.CCTObj.team_member__c = lstCCT1[0].team_member__c;

            SA_AddCustomClientTeam controller8 = new SA_AddCustomClientTeam();
            Controller8.CCTObj.Client_Role__c = '';
            Controller8.CCTObj.Account__c = lstAcc[0].Id ;
            Controller8.CCTObj.Client_coordinator_BM__c = true;
            Controller8.CCTObj.team_member__c = stdUser.Id;

            system.runas(stdUser) {
                    SA_AddCustomClientTeam controller9 = new SA_AddCustomClientTeam();
                    Controller9.CCTObj.Client_Role__c = DMN_ClientTeam.ROLE_ADVISORY_BANKER;
                    Controller9.CCTObj.team_member__c = admUser_teammem2.Id;
                    Controller9.CCTObj.Account__c = lstAcc[0].Id ;
                    Controller9.SaveRec();
                    System.assertEquals(controller.ccorbmcoreinsert, false);
                    System.Debug(controller9.TeamMember); 
            }
            
            system.Test.StopTest();
        }
}
    /*This method tries to test the error message which will be thrown if a team member with same role/ already a CC exists*/
    static testMethod void testSA_AddCustomClientTeam_2() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User stdUser = (User) new BLD_USER(uow).useCib().getRecord();

        User admUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        User admUser_teammem1 = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        User admUser_teammem2 = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
        }

        System.runAs(admUser) {

            TEST_DataFactory.insertSettings(new List<Object> {
                TEST_DataFactory.getCcSettings(),
                TEST_DataFactory.getCstTeamRankings(),
                TEST_DataFactory.getCSTManyPerRegionTeamRoles(),
                TEST_DataFactory.getUserProfileIds()
            });

            BLD_Account accBld = new BLD_Account(uow).useGroupParent()
                .cibTarget(true);
            List<Account> lstAcc = new List<Account> {
                (Account) accBld.getRecord()
            };

            new List<Custom_Client_Team__c> {
                (Custom_Client_Team__c) new BLD_ClientTeam(uow)
                    .account(accBld)
                    .role(DMN_ClientTeam.ROLE_GM_CHAMPION)
                    .user(admUser_teammem1.Id)
                    .coordinator(true)
                    .getRecord(),
                (Custom_Client_Team__c) new BLD_ClientTeam(uow)
                    .account(accBld)
                    .role(DMN_ClientTeam.ROLE_CREDIT_RISK)
                    .user(stdUser.Id)
                    .ccbm(true)
                    .getRecord()
            };

            uow.commitWork();

            system.Test.startTest();
            Pagereference p = page.SA_AddCustomClient_UserView;

            p.getParameters().put('id', lstAcc[0].id);
            p.getParameters().put('Owner', String.valueof(lstAcc[0].OwnerId));

            System.Test.setCurrentPage(p);

            SA_AddCustomClientTeam controller = new SA_AddCustomClientTeam();
            System.assertEquals(controller.Adminflag, True);
            System.assertEquals(controller.ccorbmcoreinsert, false);
            System.assertEquals(controller.disableReplaceBtn, True);
            Controller.CCTObj.Client_Role__c = 'GM Champion';
            Controller.CCTObj.Client_Coordinator__c = True;
            controller.CCTObj.team_member__c = admUser_teammem2.Id;
            Controller.SaveNew();
            System.assertEquals(controller.disableReplaceBtn, false);
            
            SA_AddCustomClientTeam controller2 = new SA_AddCustomClientTeam();
            controller2.CCTObj.Client_Role__c = 'Analyst';
            controller2.CCTObj.Client_Coordinator_BM__c = True;
            controller2.CCTObj.team_member__c = admUser_teammem2.Id;
            controller2.SaveNew();
            
            SA_AddCustomClientTeam controller3 = new SA_AddCustomClientTeam();
            System.assertEquals(controller3.Adminflag, True);
            System.assertEquals(controller3.ccorbmcoreinsert, false);
            System.assertEquals(controller3.disableReplaceBtn, True);
            Controller3.CCTObj.Client_Role__c = 'GM Champion';
            Controller3.CCTObj.Client_Coordinator_BM__c = True;
            controller3.CCTObj.team_member__c = admUser_teammem2.Id;
            Controller3.SaveNew();
            System.assertEquals(controller3.disableReplaceBtn, false);
            
            }
       }
       
       //To test the CST member Addition for CommB roles
       
   static testMethod void testSA_AddCustomClientTeam_CommB() {
       fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

       User stdUser = (User) new BLD_USER(uow).useCib().getRecord();

        User commUser = (User) new BLD_USER(uow).useSysAdmin()
            .division(DMN_User.GM_DIVISION)
            .cibGlobalArea('BCC')
            .getRecord();

       User admUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
       User admUser_teammem2 = (User) new BLD_USER(uow).useSysAdmin().getRecord();
       User admUser_teammem3 = (User) new BLD_USER(uow).useSysAdmin().getRecord();
       User admUser_teammem4 = (User) new BLD_USER(uow).useSysAdmin().getRecord();
       System.runAs(new User(Id = UserInfo.getUserId())) {
           uow.commitWork();
       }
        
        System.runAs(admUser) {

            TEST_DataFactory.insertSettings(new List<Object> {
                TEST_DataFactory.getCcSettings(),
                TEST_DataFactory.getCstTeamRankings(),
                TEST_DataFactory.getCSTManyPerRegionTeamRoles(),
                TEST_DataFactory.getUserProfileIds()
            });

            BLD_Account accBld = new BLD_Account(uow).useGroupParent()
                .cibTarget(true);
            List<Account> lstAcc = new List<Account> {
                (Account) accBld.getRecord()
            };

            List<Custom_Client_Team__c> lstCCT1 = new List<Custom_Client_Team__c> {
                (Custom_Client_Team__c) new BLD_ClientTeam(uow)
                    .account(accBld)
                    .role(DMN_ClientTeam.ROLE_COMMB_PORTFOLIO_MANGER)
                    .user(commUser.Id)
                    .coordinator(true)
                    .getRecord(),
                (Custom_Client_Team__c) new BLD_ClientTeam(uow)
                    .account(accBld)
                    .role(DMN_ClientTeam.ROLE_CREDIT_RISK)
                    .user(stdUser.Id)
                    .ccbm(true)
                    .getRecord()
            };

            uow.commitWork();

            system.Test.startTest();
            Pagereference p = page.SA_AddCustomClient_UserView;

            p.getParameters().put('id', lstAcc[0].id);
            p.getParameters().put('Owner', String.valueof(lstAcc[0].OwnerId));

            System.Test.setCurrentPage(p);
    
            SA_AddCustomClientTeam controller = new SA_AddCustomClientTeam();
            System.assertEquals(controller.Adminflag, True);
            System.assertEquals(controller.ccorbmcoreinsert, false);
            System.assertEquals(controller.disableReplaceBtn, True);
            Controller.CCTObj.Client_Role__c = DMN_ClientTeam.ROLE_GM_EXECUTION_MANAGER;
            controller.CCTObj.team_member__c = admUser_teammem2.Id;
            Controller.SaveNew();
            System.assertEquals(controller.disableReplaceBtn, True);
            Controller.ReplaceRec();
            Controller.back();
            Controller.Cancel();

            SA_AddCustomClientTeam controller1 = new SA_AddCustomClientTeam();
            controller1.CCTObj.Client_Role__c = Null;
            Controller1.CCTObj.Client_coordinator__c = false;
            controller1.CCTObj.team_member__c = admUser_teammem3.Id;
            Controller1.SaveNew();

            system.runas(stdUser) {
                SA_AddCustomClientTeam controller4 = new SA_AddCustomClientTeam();
                Controller4.CCTObj.Client_Role__c = 'Structurer';
                Controller4.CCTObj.Client_coordinator__c = false;
                Controller4.CCTObj.team_member__c = admUser_teammem2.Id;
                Controller4.SaveRec();
                System.assertEquals(controller.ccorbmcoreinsert, false);
                Controller4.ReplaceRec();
            }

            SA_AddCustomClientTeam controller5 = new SA_AddCustomClientTeam();
            Controller5.CCTObj.Client_Role__c = 'BCC Relationship Manager';
            Controller5.CCTObj.Account__c = lstAcc[0].Id ;
            Controller5.CCTObj.Client_coordinator__c = true;
            Controller5.CCTObj.team_member__c = admUser_teammem4.Id;
            Controller5.SaveRec();
            Controller5.ReplaceRec();

            SA_AddCustomClientTeam controller6 = new SA_AddCustomClientTeam();
            Controller6.CCTObj.Client_Role__c = 'BCC Portfolio Manager';
            Controller6.CCTObj.Account__c = lstAcc[0].Id ;
            Controller6.CCTObj.Client_coordinator_BM__c = true;
            Controller6.CCTObj.team_member__c = admUser_teammem4.Id;
            Controller6.SaveRec();
            Controller6.ReplaceRec();
            
            SA_AddCustomClientTeam controller7 = new SA_AddCustomClientTeam(); 
            Controller7.CCTObj.Client_Role__c = DMN_ClientTeam.ROLE_ADVISORY_BANKER;
            Controller7.CCTObj.Account__c = lstAcc[0].Id ;
            Controller7.CCTObj.Client_coordinator__c = True;
            Controller7.CCTObj.Client_coordinator_BM__c = True;
            Controller7.CCTObj.team_member__c = lstCCT1[0].team_member__c;
            Controller7.SaveRec();
            Controller7.ReplaceRec();
            
            SA_AddCustomClientTeam controller8 = new SA_AddCustomClientTeam(); 
            Controller8.CCTObj.Client_Role__c = '';
            Controller8.CCTObj.Account__c = lstAcc[0].Id ;
            Controller8.CCTObj.Client_coordinator_BM__c = true;
            Controller8.CCTObj.team_member__c = stdUser.Id;
            Controller8.ReplaceRec();
        
            system.runas(stdUser) {
                    SA_AddCustomClientTeam controller9 = new SA_AddCustomClientTeam();
                    Controller9.CCTObj.Client_Role__c = DMN_ClientTeam.ROLE_ADVISORY_BANKER;
                    Controller9.CCTObj.team_member__c = admUser_teammem2.Id;
                    Controller9.CCTObj.Account__c = lstAcc[0].Id ;
                    Controller9.SaveRec();
                    System.assertEquals(controller.ccorbmcoreinsert, false);
                    System.Debug(controller9.TeamMember); 
            }
        
            system.Test.StopTest();
        }
    } 
    
    //Method to test insertion of core roles by CC/CCBM for a UGP Target Client with CIF
    static testMethod void testSA_AddCustomClientTeam_UGP() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User stdUser = (User) new BLD_USER(uow).useCib().getRecord();
        User stdUser1 = (User) new BLD_USER(uow).useCib().getRecord();
        User stdUser2 = (User) new BLD_USER(uow).useCib().getRecord();

        User admUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow.commitWork();
        }


        System.runAs(admUser) {

            TEST_DataFactory.insertSettings(new List<Object> {
                TEST_DataFactory.getCcSettings(),
                TEST_DataFactory.getCstTeamRankings(),
                TEST_DataFactory.getCSTManyPerRegionTeamRoles(),
                TEST_DataFactory.getUserProfileIds()
            });

            List<Account> lstAcc = new List<Account> {
                (Account) new BLD_Account(uow).useGroupParent()
                    .cibTarget(true)
                    .CIF('Test_934085')
                    .onboardedInSfdc(true)
                    .getRecord()
            };

            uow.commitWork();

            system.Test.startTest();
            Pagereference p = page.SA_AddCustomClient_UserView;

            p.getParameters().put('id', lstAcc[0].id);
            p.getParameters().put('Owner', String.valueof(lstAcc[0].OwnerId));

            System.Test.setCurrentPage(p);
    
            SA_AddCustomClientTeam controller = new SA_AddCustomClientTeam();
            System.assertEquals(controller.Adminflag, True);
            System.assertEquals(controller.ccorbmcoreinsert, false);
            System.assertEquals(controller.disableReplaceBtn, True);
            Controller.CCTObj.Client_Role__c = 'GM Champion';
            Controller.CCTObj.Client_Coordinator__c = True;
            controller.CCTObj.team_member__c = stdUser.Id;
            Controller.SaveNew();
            Controller.ReplaceRec();
            
           system.RunAs(stdUser){
                SA_AddCustomClientTeam controller2 = new SA_AddCustomClientTeam();
                System.assertEquals(controller2.ccorbmcoreinsert, false);
                System.assertEquals(controller2.disableReplaceBtn, True);
                controller2.CCTObj.Client_Role__c = DMN_ClientTeam.ROLE_ADVISORY_BANKER;
                controller2.CCTObj.team_member__c = stdUser1.Id;
                controller2.SaveNew();
                System.assertEquals(controller2.ccorbmcoreinsert, false);
           }
           
           SA_AddCustomClientTeam controller3 = new SA_AddCustomClientTeam();
           System.assertEquals(controller3.ccorbmcoreinsert, false);
           System.assertEquals(controller3.disableReplaceBtn, True);
           controller3.CCTObj.Client_Role__c = 'TPS Champion';
           controller3.CCTObj.Client_Coordinator_BM__c = True;
           controller3.CCTObj.team_member__c = stdUser2.Id;
           controller3.SaveNew();  
               
           system.RunAs(stdUser2){
                SA_AddCustomClientTeam controller4 = new SA_AddCustomClientTeam();
                System.assertEquals(controller4.ccorbmcoreinsert, false);
                System.assertEquals(controller4.disableReplaceBtn, True);
                controller4.CCTObj.Client_Role__c = DMN_ClientTeam.ROLE_ADVISORY_BANKER;
                controller4.CCTObj.team_member__c = stdUser1.Id;
                controller4.SaveNew();
                System.assertEquals(controller4.ccorbmcoreinsert, false);
           }   
        }
    }
   
   //Method to test insertion of core roles by CC/CCBM for a Immediate Parent Target Client with CIF
    static testMethod void testSA_AddCustomClientTeam_IP() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User stdUser = (User) new BLD_USER(uow).useCib().getRecord();
        User stdUser1 = (User) new BLD_USER(uow).useCib().getRecord();
        User stdUser2 = (User) new BLD_USER(uow).useCib().getRecord();

        User admUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow.commitWork();
        }


        System.runAs(admUser) {

            TEST_DataFactory.insertSettings(new List<Object> {
                TEST_DataFactory.getCcSettings(),
                TEST_DataFactory.getCstTeamRankings(),
                TEST_DataFactory.getCSTManyPerRegionTeamRoles(),
                TEST_DataFactory.getUserProfileIds()
            });

            List<Account> lstAcc = new List<Account> {
                (Account) new BLD_Account(uow).useImmediateParent()
                    .cibTarget(true)
                    .CIF('Test_934085')
                    .onboardedInSfdc(true)
                    .getRecord()
            };

            uow.commitWork();

            system.Test.startTest();
            Pagereference p = page.SA_AddCustomClient_UserView;

            p.getParameters().put('id', lstAcc[0].id);
            p.getParameters().put('Owner', String.valueof(lstAcc[0].OwnerId));

            System.Test.setCurrentPage(p);
    
            SA_AddCustomClientTeam controller = new SA_AddCustomClientTeam();
            System.assertEquals(controller.Adminflag, True);
            System.assertEquals(controller.ccorbmcoreinsert, false);
            System.assertEquals(controller.disableReplaceBtn, True);
            Controller.CCTObj.Client_Role__c = 'GM Champion';
            Controller.CCTObj.Client_Coordinator__c = True;
            controller.CCTObj.team_member__c = stdUser.Id;
            Controller.SaveNew();
            Controller.ReplaceRec();
            
           system.RunAs(stdUser){
                SA_AddCustomClientTeam controller2 = new SA_AddCustomClientTeam();
                System.assertEquals(controller2.ccorbmcoreinsert, false);
                System.assertEquals(controller2.disableReplaceBtn, True);
                controller2.CCTObj.Client_Role__c = DMN_ClientTeam.ROLE_ADVISORY_BANKER;
                controller2.CCTObj.team_member__c = stdUser1.Id;
                controller2.SaveNew();
                System.assertEquals(controller2.ccorbmcoreinsert, false);
           }
           
           SA_AddCustomClientTeam controller3 = new SA_AddCustomClientTeam();
           System.assertEquals(controller3.ccorbmcoreinsert, false);
           System.assertEquals(controller3.disableReplaceBtn, True);
           controller3.CCTObj.Client_Role__c = 'TPS Champion';
           controller3.CCTObj.Client_Coordinator_BM__c = True;
           controller3.CCTObj.team_member__c = stdUser2.Id;
           controller3.SaveNew();  
               
           system.RunAs(stdUser2){
                SA_AddCustomClientTeam controller4 = new SA_AddCustomClientTeam();
                System.assertEquals(controller4.ccorbmcoreinsert, false);
                System.assertEquals(controller4.disableReplaceBtn, True);
                controller4.CCTObj.Client_Role__c = DMN_ClientTeam.ROLE_ADVISORY_BANKER;
                controller4.CCTObj.team_member__c = stdUser1.Id;
                controller4.SaveNew();
                System.assertEquals(controller4.ccorbmcoreinsert, false);
           }   
            
        }
    }
   

}