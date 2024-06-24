@isTest
private class SHR_BusinessAssessment_TEST {
	
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
    GROUP_NUMBER_2          = '123456',
    CURR                    = 'ZAR';

    private static Account acc, child, grandChild, grandChild_2,
                    otrAcc, otrChild, otrGrandChild, otrGrandChild_2;
    private static User sysAdmin, usr, testUser, testUser_2, otherUser_1, otherUser_2;

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
                testUser_2 = u;
            }
            if(u.UserName == OTHR_USER_NAME_1){
                otherUser_1 = u;
            }
            if(u.UserName == OTHR_USER_NAME_2){
                otherUser_2 = u;
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
                grandChild_2 = accRec;
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
                otrGrandChild_2 = accRec;
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
            testUser = (User)new BLD_USER(uow).userName(TEST_USER_NAME_2).useCib().syncContact().getRecord();
            testUser_2 = (User)new BLD_USER(uow).userName(TEST_USER_NAME_3).useCib().syncContact().getRecord();
            otherUser_1 = (User)new BLD_USER(uow).userName(OTHR_USER_NAME_1).useCib().syncContact().getRecord();
            otherUser_2 = (User)new BLD_USER(uow).userName(OTHR_USER_NAME_2).useCib().syncContact().getRecord();
            usr = (User)new BLD_USER(uow).userName(TEST_USER_NAME).useCib().syncContact().getRecord();
            uow.commitWork();
        }
        Test.startTest();
        Test.stopTest(); 
		
        ABS_ObjectBuilderBase accBld;
        ABS_ObjectBuilderBase otrAccBld;
        
        System.runAs(usr){
            accBld                						= new BLD_Account(uow).name(DEF_ACC_NAME).useCib().useGroupParent().groupNumber(GROUP_NUMBER); 
            otrAccBld             						= new BLD_Account(uow).name(OTR_ACC_NAME).useCib().useGroupParent().groupNumber(GROUP_NUMBER_2).commitWork(); 
            uow.commitWork();
            
            ABS_ObjectBuilderBase childAcc              = new BLD_Account(uow).name(DEF_ACC_NAME_IMM).useCib().useImmediateParent(accBld.getRecordId()).groupNumber(GROUP_NUMBER + 10);
            ABS_ObjectBuilderBase otrChildAcc           = new BLD_Account(uow).name(OTR_ACC_NAME_IMM).useCib().useImmediateParent(otrAccBld.getRecordId()).groupNumber(GROUP_NUMBER_2 + 10);
            uow.commitWork();
            
            ABS_ObjectBuilderBase grandchildAcc         = new BLD_Account(uow).name(DEF_ACC_NAME_CHILD).useCib().useChild(childAcc.getRecordId(), accBld.getRecordId()).groupNumber(GROUP_NUMBER +20 );
            ABS_ObjectBuilderBase grandchildAcc_2       = new BLD_Account(uow).name(DEF_ACC_NAME_CHILD_2).useCib().useChild(childAcc.getRecordId(), accBld.getRecordId()).groupNumber(GROUP_NUMBER +30 ); 
            ABS_ObjectBuilderBase otrGrandchildAcc      = new BLD_Account(uow).name(OTR_ACC_NAME_CHILD).useCib().useChild(otrChildAcc.getRecordId(), otrAccBld.getRecordId()).groupNumber(GROUP_NUMBER_2 +20 );
            ABS_ObjectBuilderBase otrGrandchildAcc_2    = new BLD_Account(uow).name(OTR_ACC_NAME_CHILD_2).useCib().useChild(otrChildAcc.getRecordId(), otrAccBld.getRecordId()).groupNumber(GROUP_NUMBER_2 +30 );
            uow.commitWork();
        } 
        
         System.runAs(sysAdmin){
            ABS_ObjectBuilderBase teamBld_2             = new BLD_ClientTeam(uow).account(otrAccBld.getRecordId()).role(DMN_ClientTeam.ROLE_MANAGER_CLIENT_COVERAGE).user(otherUser_1.Id).coordinator(true);
        	ABS_ObjectBuilderBase teamBld               = new BLD_ClientTeam(uow).account(accBld.getRecordId()).role(DMN_ClientTeam.ROLE_MANAGER_CLIENT_COVERAGE).user(testUser.Id).coordinator(false).ccbm(true);
            uow.commitWork();
         }
    }
    
    private static testmethod void defaultDataCheck() {
        System.assertEquals(9, [SELECT Id FROM Account].size());
        System.assertEquals(7, [SELECT Id FROM Contact].size());
        System.assertEquals(2, [SELECT Id FROM Custom_Client_Team__c].size());
        System.assertEquals(0, [SELECT Id FROM Opportunity].size());
        System.assertEquals(0, [SELECT Id FROM Business_Assessment__c].size());

        getData(); 

        System.runAs(usr){
            System.assertEquals(8, [SELECT Id FROM Account].size());
            System.assertEquals(1, [SELECT Id FROM Contact].size());
            System.assertEquals(1, [SELECT Id FROM Custom_Client_Team__c].size());
            System.assertEquals(0, [SELECT Id FROM Opportunity].size());
            System.assertEquals(0, [SELECT Id FROM Business_Assessment__c].size());
        }
    } 
    
    private static testmethod void newBa() {
        getData();

        System.runAs(usr){
            Test.startTest();
                ABS_ObjectBuilderBase baBld = new BLD_BusinessAssessment().client(acc.Id).commitWork();
            Test.stopTest();
        }
        System.assertEquals(1, [SELECT Id FROM Business_Assessment__c].size());
        System.assertEquals(2, [SELECT Id FROM Custom_Client_Team__c].size());
        System.assertEquals(1, [SELECT Id FROM Business_Assessment__share WHERE RowCause =: SHR_BusinessAssessment.CLIENT_COORDINATOR AND UserOrGroupId =: testUser.Id].size());
    } 

    private static testmethod void newBa_OnChild() {
        getData();

        System.runAs(usr){
            Test.startTest();
                ABS_ObjectBuilderBase baBld = new BLD_BusinessAssessment().client(child.Id).commitWork();
            Test.stopTest();
        }
        System.assertEquals(1, [SELECT Id FROM Business_Assessment__c].size());
        System.assertEquals(2, [SELECT Id FROM Custom_Client_Team__c].size());
        System.assertEquals(1, [SELECT Id FROM Business_Assessment__share WHERE RowCause =: SHR_BusinessAssessment.CLIENT_COORDINATOR AND UserOrGroupId =: testUser.Id].size());
    }

    private static testmethod void newBa_OnGrandChild() {
        getData();

        System.runAs(usr){
            Test.startTest();
                ABS_ObjectBuilderBase baBld = new BLD_BusinessAssessment().client(grandChild.Id).commitWork();
            Test.stopTest();
        }
        System.assertEquals(1, [SELECT Id FROM Business_Assessment__c].size());
        System.assertEquals(2, [SELECT Id FROM Custom_Client_Team__c].size());
        System.assertEquals(1, [SELECT Id FROM Business_Assessment__share WHERE RowCause =: SHR_BusinessAssessment.CLIENT_COORDINATOR AND UserOrGroupId =: testUser.Id].size());
    }


    private static testmethod void newTeam_CCBM() {
        getData();

        ABS_ObjectBuilderBase baBld = new BLD_BusinessAssessment().client(acc.Id).commitWork();

        System.runAs(sysAdmin){
            Test.startTest();
               new BLD_ClientTeam().account(acc.Id).role(DMN_ClientTeam.ROLE_BUSINESS_DEV_MANAGER).user(testUser_2.Id).coordinator(true).commitWork();
            Test.stopTest();
        }
        System.assertEquals(1, [SELECT Id FROM Business_Assessment__c].size());
        System.assertEquals(3, [SELECT Id FROM Custom_Client_Team__c].size());
        System.assertEquals(1, [SELECT Id FROM Business_Assessment__share WHERE RowCause =: SHR_BusinessAssessment.CLIENT_COORDINATOR AND UserOrGroupId =: testUser.Id].size());
        System.assertEquals(1, [SELECT Id FROM Business_Assessment__share WHERE RowCause =: SHR_BusinessAssessment.CLIENT_COORDINATOR AND UserOrGroupId =: testUser_2.Id].size());
    }

    private static testmethod void newTeam() {
        getData();

        System.runAs(usr){
            Test.startTest();
                new BLD_BusinessAssessment().client(acc.Id).commitWork();
                new BLD_ClientTeam().account(acc.Id).role(DMN_ClientTeam.ROLE_BUSINESS_DEV_MANAGER).user(testUser_2.Id).coordinator(false).commitWork();
            Test.stopTest();
        }
        System.assertEquals(1, [SELECT Id FROM Business_Assessment__c].size());
        System.assertEquals(3, [SELECT Id FROM Custom_Client_Team__c].size());
        System.assertEquals(1, [SELECT Id FROM Business_Assessment__share WHERE RowCause =: SHR_BusinessAssessment.CLIENT_COORDINATOR AND UserOrGroupId =: testUser.Id].size());
        System.assertEquals(0, [SELECT Id FROM Business_Assessment__share WHERE RowCause =: SHR_BusinessAssessment.CLIENT_COORDINATOR AND UserOrGroupId =: testUser_2.Id].size());
    }

    private static testmethod void newTeam_CreditOfficer() {
        getData();

        System.runAs(usr){
            Test.startTest();
                new BLD_BusinessAssessment().client(acc.Id).commitWork();
                new BLD_ClientTeam().account(acc.Id).role(DMN_ClientTeam.ROLE_CREDIT_OFFICER).user(testUser_2.Id).coordinator(false).commitWork();
            Test.stopTest();
        }
        System.assertEquals(1, [SELECT Id FROM Business_Assessment__c].size());
        System.assertEquals(3, [SELECT Id FROM Custom_Client_Team__c].size());
        System.assertEquals(1, [SELECT Id FROM Business_Assessment__share WHERE RowCause =: SHR_BusinessAssessment.CLIENT_COORDINATOR AND UserOrGroupId =: testUser.Id].size());
        System.assertEquals(1, [SELECT Id FROM Business_Assessment__share WHERE RowCause =: SHR_BusinessAssessment.CREDIT_OFFICER AND UserOrGroupId =: testUser_2.Id].size());
    }

    private static testmethod void newTeam_CreditOfficer_Revoked() {
        getData();

        System.runAs(usr){
            Test.startTest();
                new BLD_BusinessAssessment().client(acc.Id).commitWork();
                Custom_Client_Team__c cct =  (Custom_Client_Team__c)new BLD_ClientTeam().account(acc.Id).role(DMN_ClientTeam.ROLE_CREDIT_OFFICER).user(testUser_2.Id).coordinator(false).commitWork().getRecord();
                
                cct.Client_Role__c = DMN_ClientTeam.ROLE_BUSINESS_DEV_MANAGER;
                update cct;

            Test.stopTest();
        }
        System.assertEquals(1, [SELECT Id FROM Business_Assessment__c].size());
        System.assertEquals(3, [SELECT Id FROM Custom_Client_Team__c].size());
        System.assertEquals(1, [SELECT Id FROM Business_Assessment__share WHERE RowCause =: SHR_BusinessAssessment.CLIENT_COORDINATOR AND UserOrGroupId =: testUser.Id].size());
        System.assertEquals(0, [SELECT Id FROM Business_Assessment__share WHERE RowCause =: SHR_BusinessAssessment.CREDIT_OFFICER AND UserOrGroupId =: testUser_2.Id].size());
    }

    private static testmethod void newTeam_CreditOfficer_Created() {
        getData();

        System.runAs(usr){
            Test.startTest();
                new BLD_BusinessAssessment().client(acc.Id).commitWork();
                Custom_Client_Team__c cct =  (Custom_Client_Team__c)new BLD_ClientTeam().account(acc.Id).role(DMN_ClientTeam.ROLE_BUSINESS_DEV_MANAGER).user(testUser_2.Id).coordinator(false).commitWork().getRecord();
                
                cct.Client_Role__c = DMN_ClientTeam.ROLE_CREDIT_OFFICER;
                update cct;

            Test.stopTest();
        }
        System.assertEquals(1, [SELECT Id FROM Business_Assessment__c].size());
        System.assertEquals(3, [SELECT Id FROM Custom_Client_Team__c].size());
        System.assertEquals(1, [SELECT Id FROM Business_Assessment__share WHERE RowCause =: SHR_BusinessAssessment.CLIENT_COORDINATOR AND UserOrGroupId =: testUser.Id].size());
        System.assertEquals(1, [SELECT Id FROM Business_Assessment__share WHERE RowCause =: SHR_BusinessAssessment.CREDIT_OFFICER AND UserOrGroupId =: testUser_2.Id].size());
    }

}