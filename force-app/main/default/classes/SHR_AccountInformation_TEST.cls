/**
* @ModifiedBy Emmanuel Mulea Nocks(BlueSky)
* @date Aug 2021
* @description Test class
*/
@isTest
private class SHR_AccountInformation_TEST {
	
	public static final String 
    ADMIN_USER_NAME          = 'admin.StdBank_Ltn_Ecosystem_Test@test.com',
    TEST_USER_NAME          = 'test.StdBank_Ltn_Ecosystem_Test@test.com',
    TEST_USER_NAME_2        = '2test.StdBank_Ltn_Ecosystem_Test@test.com',
    TEST_USER_NAME_3        = '3test.StdBank_Ltn_Ecosystem_Test@test.com',
    OTHR_USER_NAME_1        = '4test.StdBank_Ltn_Ecosystem_Test@test.com',
    OTHR_USER_NAME_2        = '5test.StdBank_Ltn_Ecosystem_Test@test.com',
    DEF_ACC_NAME            = 'Def Name for Acc',
    DEF_ACC_NAME_IMM        = 'Def Name for Immm',
    DEF_ACC_NAME_CHILD      = 'Def Name for Child',
    DEF_ACC_NAME_CHILD_2    = 'Def Name for Other',
    OTR_ACC_NAME            = 'OTR Name for Acc',
    OTR_ACC_NAME_IMM        = 'OTR Name for Immm',
    OTR_ACC_NAME_CHILD      = 'OTR Name for Child',
    OTR_ACC_NAME_CHILD_2    = 'OTR Name for Other',
    GROUP_NUMBER            = '654321',
    GROUP_NUMBER_2          = '123456';

    private static Account acc;
    private static Account child;
    private static Account grandChild;
    private static Account grandChild2;

    private static Account  otrAcc;
    private static Account otrChild;
    private static Account otrGrandChild;
    private static Account otrGrandChild2;
    private static User sysAdmin;
    private static User usr;
    private static User testUser;
    private static User testUser2;
    private static User otherUser1;
    private static User otherUser2;

    private static void getData(){ 
        for(User u : [  SELECT Username  
                        FROM User
                        WHERE UserName IN: new String[]{TEST_USER_NAME_2, TEST_USER_NAME, TEST_USER_NAME_3,
                                                        OTHR_USER_NAME_1, OTHR_USER_NAME_2, ADMIN_USER_NAME}]){
            if(u.UserName == TEST_USER_NAME){
                usr = u;
            }
            if(u.UserName == TEST_USER_NAME_2){
                testUser = u;
            }
            if(u.UserName == TEST_USER_NAME_3){
                testUser2 = u;
            }
            if(u.UserName == OTHR_USER_NAME_1){
                otherUser1 = u;
            }
            if(u.UserName == OTHR_USER_NAME_2){
                otherUser2 = u;
            }
            if(u.UserName == ADMIN_USER_NAME){
                sysAdmin = u;
            }
        }
 
        for(Account accRec : [  SELECT Name
                                FROM Account
                                WHERE Name  IN: new String[]{DEF_ACC_NAME, DEF_ACC_NAME_IMM, DEF_ACC_NAME_CHILD,
                                                        DEF_ACC_NAME_CHILD_2, OTR_ACC_NAME, OTR_ACC_NAME_IMM, 
                                                        OTR_ACC_NAME_CHILD, OTR_ACC_NAME_CHILD_2}]){
            if(accRec.Name == DEF_ACC_NAME){
                acc = accRec;
            }
            if(accRec.Name == DEF_ACC_NAME_IMM){
                child = accRec;
            }
            if(accRec.Name == DEF_ACC_NAME_CHILD){
                grandChild = accRec;
            }

            if(accRec.Name == DEF_ACC_NAME_CHILD_2){
                grandChild2 = accRec;
            }
            if(accRec.Name == OTR_ACC_NAME){
                otrAcc = accRec;
            }
            if(accRec.Name == OTR_ACC_NAME_IMM){
                otrChild = accRec;
            }
            if(accRec.Name == OTR_ACC_NAME_CHILD){
                otrGrandChild = accRec;
            }

            if(accRec.Name == OTR_ACC_NAME_CHILD_2){
                otrGrandChild2 = accRec;
            }
        }
    }

    @testSetup
    static void prepareData() { 

        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow;
        System.runAs(new User(Id = UserInfo.getUserId())){
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

            sysAdmin = (User)new BLD_USER(uow).userName(ADMIN_USER_NAME).useSysAdmin().syncContact().getRecord();
            testUser = (User)new BLD_USER(uow).userName(TEST_USER_NAME_2).useCommB().syncContact().getRecord();
            testUser2 = (User)new BLD_USER(uow).userName(TEST_USER_NAME_3).useCommB().syncContact().getRecord();
            otherUser1 = (User)new BLD_USER(uow).userName(OTHR_USER_NAME_1).useCommB().syncContact().getRecord();
            otherUser2 = (User)new BLD_USER(uow).userName(OTHR_USER_NAME_2).useCommB().syncContact().getRecord();
            usr = (User)new BLD_USER(uow).userName(TEST_USER_NAME).useCommB().syncContact().getRecord();
            uow.commitWork();
        }
        
        Test.startTest();
        Test.stopTest();
		ABS_ObjectBuilderBase accBld;
        ABS_ObjectBuilderBase otrAccBld;
        
        System.runAs(usr){
            accBld                						= new BLD_Account(uow).cif('123').name(DEF_ACC_NAME).useCommB().useGroupParent().groupNumber(GROUP_NUMBER);
            //accBld                						= new BLD_Account(uow).name(DEF_ACC_NAME).useCommB().useGroupParent().groupNumber(GROUP_NUMBER);
            otrAccBld             						= new BLD_Account(uow).name(OTR_ACC_NAME).useCommB().useGroupParent().groupNumber(GROUP_NUMBER_2);
            ABS_ObjectBuilderBase gcr 					= new BLD_AccountInformation(uow).client(accBld);
            uow.commitWork();           
            
            ABS_ObjectBuilderBase childAcc          	= new BLD_Account(uow).name(DEF_ACC_NAME_IMM).useCommB().useImmediateParent(accBld.getRecordId()).groupNumber(GROUP_NUMBER );
            ABS_ObjectBuilderBase otrChildAcc           = new BLD_Account(uow).name(OTR_ACC_NAME_IMM).useCommB().useImmediateParent(otrAccBld.getRecordId()).groupNumber(GROUP_NUMBER_2);
            uow.commitWork();
            
            ABS_ObjectBuilderBase grandchildAcc         = new BLD_Account(uow).name(DEF_ACC_NAME_CHILD).useCommB().useChild(childAcc.getRecordId(), accBld.getRecordId()).groupNumber(GROUP_NUMBER );
            ABS_ObjectBuilderBase grandchildAcc2       = new BLD_Account(uow).name(DEF_ACC_NAME_CHILD_2).useCommB().useChild(childAcc.getRecordId(), accBld.getRecordId()).groupNumber(GROUP_NUMBER );
            ABS_ObjectBuilderBase otrGrandchildAcc      = new BLD_Account(uow).name(OTR_ACC_NAME_CHILD).useCommB().useChild(otrChildAcc.getRecordId(), otrAccBld.getRecordId()).groupNumber(GROUP_NUMBER_2);
            ABS_ObjectBuilderBase otrGrandchildAcc2    = new BLD_Account(uow).name(OTR_ACC_NAME_CHILD_2).useCommB().useChild(otrChildAcc.getRecordId(), otrAccBld.getRecordId()).groupNumber(GROUP_NUMBER_2);
            uow.commitWork();
            
        } 
        
        System.runAs(sysAdmin){
            ABS_ObjectBuilderBase teamBld               = new BLD_ClientTeam(uow).account(accBld.getRecordId()).role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER).user(testUser.Id).coordinator(true);
            //ABS_ObjectBuilderBase teamBld_2             = new BLD_ClientTeam(uow).account(otrAccBld.getRecordId()).role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER).user(otherUser_1.Id).coordinator(true);
            ABS_ObjectBuilderBase teamBld3   			= new BLD_ClientTeam(uow).account(otrAccBld.getRecordId()).role(DMN_ClientTeam.ROLE_COMMB_PORTFOLIO_MANGER).user(testUser2.Id).coordinator(false).ccbm(true);
            uow.commitWork();
        }
    } 
       
    private static testmethod void defaultDataCheck() {
        System.assertEquals(9, [SELECT Id FROM Account].size());
        System.assertEquals(7, [SELECT Id FROM Contact].size());
        System.assertEquals(2, [SELECT Id FROM Custom_Client_Team__c].size());
        System.assertEquals(1, [SELECT Id FROM Account_Information__share WHERE RowCause = 'CST_Member_Can_Access_Accounts_Info__c'].size());

        getData(); 

        System.runAs(usr){
            System.assertEquals(8, [SELECT Id FROM Account].size());
            System.assertEquals(1, [SELECT Id FROM Contact].size());
            System.assertEquals(1, [SELECT Id FROM Custom_Client_Team__c].size());
            System.assertEquals(1, [SELECT Id FROM Account_Information__share WHERE RowCause = 'CST_Member_Can_Access_Accounts_Info__c'].size());
        }
        System.assertEquals(2, [SELECT Id FROM Custom_Client_Team__c].size());
    } 
    
    private static testmethod void newMemberGrandchildTeam() {
        getData();
        System.assertEquals(9, [SELECT Id FROM Account].size());
        System.assertEquals(7, [SELECT Id FROM Contact].size());
        System.assertEquals(2, [SELECT Id FROM Custom_Client_Team__c].size());
        System.assertEquals(1, [SELECT Id FROM Account_Information__share WHERE RowCause = 'CST_Member_Can_Access_Accounts_Info__c'].size());

        System.runAs(sysAdmin){ 
            Test.startTest();
                ABS_ObjectBuilderBase teamBld   = new BLD_ClientTeam().account(grandChild.Id)
                                                                    .role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER)
                                                                    .user(testUser2.Id).coordinator(true)
                                                                    .commitWork();
            Test.stopTest();
        }
        System.assertEquals(9, [SELECT Id FROM Account].size());
        System.assertEquals(7, [SELECT Id FROM Contact].size());
        System.assertEquals(3, [SELECT Id FROM Custom_Client_Team__c].size());
        System.assertEquals(1, [SELECT Id FROM Account_Information__share WHERE RowCause = 'CST_Member_Can_Access_Accounts_Info__c'].size());
    }
    
    private static testmethod void newMemberChildTeam() {
        getData();

        System.runAs(sysAdmin){
            Test.startTest();
                ABS_ObjectBuilderBase teamBld   = new BLD_ClientTeam().account(child.Id)
                                                                    .role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER)
                                                                    .user(testUser2.Id).coordinator(true)
                                                                    .commitWork();
            Test.stopTest();
        }

        System.assertEquals(1, [SELECT Id FROM Account_Information__share WHERE RowCause = 'CST_Member_Can_Access_Accounts_Info__c'].size());
        System.assertEquals(0, [SELECT Id FROM Account_Information__share WHERE RowCause = 'CST_Member_Can_Access_Accounts_Info__c' AND UserOrGroupId =: testUser2.Id].size());
    }  
    
    private static testmethod void newMemberTopTeamCCBM() {
        getData();

        System.runAs(testUser){
            Test.startTest();
                ABS_ObjectBuilderBase teamBld   = new BLD_ClientTeam().account(acc.Id)
                                                                    .role(DMN_ClientTeam.ROLE_COMMB_PORTFOLIO_MANGER)
                                                                    .user(testUser2.Id)
                                                                    .coordinator(false)
                                                                    .ccbm()
                                                                    .commitWork();
            Test.stopTest();
        }

        System.assertEquals(3, [SELECT Id FROM Custom_Client_Team__c].size());
        System.assertEquals(2, [SELECT Id FROM Account_Information__share WHERE RowCause = 'CST_Member_Can_Access_Accounts_Info__c'].size());
        System.assertEquals(1, [SELECT Id FROM Account_Information__share WHERE RowCause = 'CST_Member_Can_Access_Accounts_Info__c' AND UserOrGroupId =: testUser2.Id].size());
    } 
    
    private static testmethod void newMemberTopTeam() {
        getData();

        System.assertEquals(1, [SELECT Id FROM Account_Information__share WHERE RowCause = 'CST_Member_Can_Access_Accounts_Info__c'].size());
        System.assertEquals(0, [SELECT Id FROM Account_Information__share WHERE RowCause = 'CST_Member_Can_Access_Accounts_Info__c' AND UserOrGroupId =: testUser2.Id].size());
        System.assertEquals(2, [SELECT Id FROM Custom_Client_Team__c].size());
        System.runAs(testUser){
            Test.startTest();
                ABS_ObjectBuilderBase teamBld   = new BLD_ClientTeam().account(acc.Id)
                                                                    .role(DMN_ClientTeam.ROLE_COMMB_PORTFOLIO_MANGER)
                                                                    .user(testUser2.Id)
                                                                    .coordinator(false)
                                                                    .commitWork();
            Test.stopTest();
        } 
        System.assertEquals(3, [SELECT Id FROM Custom_Client_Team__c].size());
        System.assertEquals(2, [SELECT Id FROM Account_Information__share WHERE RowCause = 'CST_Member_Can_Access_Accounts_Info__c'].size());
        System.assertEquals(1, [SELECT Id FROM Account_Information__share WHERE RowCause = 'CST_Member_Can_Access_Accounts_Info__c' AND UserOrGroupId =: testUser2.Id].size());
    }

    private static testmethod void newMemberTopTeamRemove() {
        getData();

        System.runAs(usr){
            
			Custom_Client_Team__c clientTeamMamber = [SELECT Id FROM Custom_Client_Team__c WHERE Client_Coordinator_BM__c = true LIMIT 1];
            
            Test.startTest();
                delete clientTeamMamber;
            Test.stopTest();
        } 
 
        System.assertEquals(1, [SELECT Id FROM Account_Information__share WHERE RowCause = 'CST_Member_Can_Access_Accounts_Info__c'].size());
        System.assertEquals(0, [SELECT Id FROM Account_Information__share WHERE RowCause = 'CST_Member_Can_Access_Accounts_Info__c' AND UserOrGroupId =: testUser2.Id].size());
    }

    private static testmethod void newMemberTopTeamReplace() {
        getData();

        System.runAs(sysAdmin){
            Test.startTest();
                ABS_ObjectBuilderBase teamBld   = new BLD_ClientTeam().account(acc.Id)
                                                                    .role(DMN_ClientTeam.ROLE_COMMB_PORTFOLIO_MANGER)
                                                                    .user(testUser2.Id)
                                                                    .coordinator(true)
                                                                    .ccbm(false)
                                                                    .commitWork();
            Test.stopTest();
        } 
 
        System.assertEquals(1, [SELECT Id FROM Account_Information__share WHERE RowCause = 'CST_Member_Can_Access_Accounts_Info__c'].size());
        System.assertEquals(1, [SELECT Id FROM Account_Information__share WHERE RowCause = 'CST_Member_Can_Access_Accounts_Info__c' AND UserOrGroupId =: testUser2.Id].size());
    }
}