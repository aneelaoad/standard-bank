/**
* @ModifiedBy Emmanuel Mulea Nocks(BlueSky)
* @date Aug 2021
* @description Test class
*/
@isTest
public class SRV_AccountSharing_TEST {
	public static final String 
    TEST_USER_NAME          = 'test.StdBank_Ltn_Ecosystem_Test@test.com',
    TEST_USER_NAME_2        = '2test.StdBank_Ltn_Ecosystem_Test@test.com',
    TEST_USER_NAME_3        = '3test.StdBank_Ltn_Ecosystem_Test@test.com',
    OTHR_USER_NAME_1        = '4test.StdBank_Ltn_Ecosystem_Test@test.com',
    OTHR_USER_NAME_2        = '5test.StdBank_Ltn_Ecosystem_Test@test.com',
    SYS_ADMIN_NAME          = 'testAdmin.StdBank_Ltn_Ecosystem_Test@test.com',
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

    public static final Integer LIMITVAL = 100;

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
                                                        OTHR_USER_NAME_1, OTHR_USER_NAME_2, SYS_ADMIN_NAME}]){
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
            if(u.UserName == SYS_ADMIN_NAME){
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

            sysAdmin = (User)new BLD_USER(uow).userName(SYS_ADMIN_NAME).useSysAdmin().syncContact().getRecord();
            testUser = (User)new BLD_USER(uow).userName(TEST_USER_NAME_2).useCommB().syncContact().getRecord();
            testUser2 = (User)new BLD_USER(uow).userName(TEST_USER_NAME_3).useCommB().syncContact().getRecord();
            otherUser1 = (User)new BLD_USER(uow).userName(OTHR_USER_NAME_1).useCommB().syncContact().getRecord();
            otherUser2 = (User)new BLD_USER(uow).userName(OTHR_USER_NAME_2).useCommB().syncContact().getRecord();
            usr = (User)new BLD_USER(uow).userName(TEST_USER_NAME).useCommB().syncContact().getRecord();
            uow.commitWork();
        }
        
        Test.startTest();
        Test.stopTest();

        System.runAs(usr){

            ABS_ObjectBuilderBase accBld                = new BLD_Account(uow).cif('123').name(DEF_ACC_NAME).useCommB().useGroupParent().groupNumber(GROUP_NUMBER);
            //ABS_ObjectBuilderBase otrAccBld             = new BLD_Account(uow).cif('456').name(OTR_ACC_NAME).useCommB().useGroupParent().groupNumber(GROUP_NUMBER_2);
            uow.commitWork();

            ABS_ObjectBuilderBase childAcc              = new BLD_Account(uow).cif('124').name(DEF_ACC_NAME_IMM).useCommB().useImmediateParent(accBld.getRecordId()).groupNumber(GROUP_NUMBER );
            //ABS_ObjectBuilderBase otrChildAcc           = new BLD_Account(uow).name(OTR_ACC_NAME_IMM).useCommB().useImmidiateParent(otrAccBld.getRecordId()).groupNumber(GROUP_NUMBER_2 + 10);
            //uow.commitWork();

            //ABS_ObjectBuilderBase grandchildAcc         = new BLD_Account(uow).cif('125').name(DEF_ACC_NAME_CHILD).useCommB().useChild(childAcc.getRecordId(), accBld.getRecordId()).groupNumber(GROUP_NUMBER +20 );
            //ABS_ObjectBuilderBase grandchildAcc_2       = new BLD_Account(uow).cif('126').name(DEF_ACC_NAME_CHILD_2).useCommB().useChild(childAcc.getRecordId(), accBld.getRecordId()).groupNumber(GROUP_NUMBER +30 );
			//ABS_ObjectBuilderBase otrGrandchildAcc      = new BLD_Account(uow).name(OTR_ACC_NAME_CHILD).useCommB().useChild(otrChildAcc.getRecordId(), otrAccBld.getRecordId()).groupNumber(GROUP_NUMBER_2 +20 );
            //ABS_ObjectBuilderBase otrGrandchildAcc_2    = new BLD_Account(uow).name(OTR_ACC_NAME_CHILD_2).useCommB().useChild(otrChildAcc.getRecordId(), otrAccBld.getRecordId()).groupNumber(GROUP_NUMBER_2 +30 );

        	//uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            //for(ABS_ObjectBuilderBase bld : new ABS_ObjectBuilderBase[]{accBld, childAcc, grandchildAcc, grandchildAcc_2}){
            for(ABS_ObjectBuilderBase bld : new ABS_ObjectBuilderBase[]{accBld, childAcc}){
	        	for(Integer i = 0; i < LIMITVAL; i++){
	        		new BLD_CreditLine(uow).account((BLD_Account)bld).product('');
	        		new BLD_AccountInformation(uow).client(bld); 
	        		new BLD_GlobalClientRevenue(uow).currentAndPreviousYear()
	          														.clientValueZarCurrentYear(111)
	          														.clientCIFNumber(GROUP_NUMBER)
	          														.client(bld);
	          		new BLD_ClientSatisfactionIndex(uow).client((BLD_Account)bld).rating(2).year(2017);
	        	}
	        }
        	uow.commitWork();
            
        } 
    }  
    
    private static testmethod void defaultDataCheck() {
    	getData(); 

        System.assertEquals(3, [SELECT Id FROM Account].size());
        System.assertEquals(7, [SELECT Id FROM Contact].size());
        System.assertEquals(0, [SELECT Id FROM Custom_Client_Team__c].size());
        System.assertEquals(0, [SELECT Id FROM Accountshare WHERE RowCause = 'Manual'].size());
        System.assertEquals(2 * LIMITVAL, [	SELECT Id
        									FROM Credit_Line__c 
            								WHERE Client_Name__c =: acc.Id 
												OR Client_Name__r.ParentId =: acc.Id 
												OR Client_Name__r.Parent.ParentId =: acc.Id ].size());
        System.assertEquals(2 * LIMITVAL, [SELECT Id FROM Client_Satisfaction_Index__c].size());
        System.assertEquals(2 * LIMITVAL, [SELECT Id FROM Global_Client_Revenue__c].size());
        System.assertEquals(2 * LIMITVAL, [SELECT Id FROM Account_Information__c].size());

        System.runAs(usr){
            System.assertEquals(3, [SELECT Id FROM Account].size());
            System.assertEquals(1, [SELECT Id FROM Contact].size());
            System.assertEquals(0, [SELECT Id FROM Custom_Client_Team__c].size());
            System.assertEquals(0, [SELECT Id FROM Accountshare WHERE RowCause = 'Manual'].size());
        }
    }
    
    private static testmethod void newMember() {
    	getData();  
    	System.runAs(sysAdmin){
    		Test.startTest();
    			new BLD_ClientTeam().account(acc.Id).role(DMN_ClientTeam.ROLE_COMMB_CSU_MANGER).user(testUser.Id).coordinator(true).commitWork();
    		Test.stopTest();
    	}

    	
        System.assertEquals(2 * LIMITVAL, [SELECT Id FROM Client_Satisfaction_Index__share WHERE RowCause =: SHR_ClientSatisfactionIndex.DEF_SHARING].size());
        System.assertEquals(2 * LIMITVAL, [SELECT Id FROM Global_Client_Revenue__share WHERE RowCause =: SHR_GlobalClientRevenue.DEF_SHARING].size());
        System.assertEquals(2 * LIMITVAL, [SELECT Id FROM Account_Information__share WHERE RowCause =: SHR_AccountInformation.DEF_SHARING].size());
        System.assertEquals(2 * LIMITVAL, [SELECT Id FROM Credit_Line__share WHERE RowCause =: SHR_CreditLine.DEF_SHARING].size());
    }
}