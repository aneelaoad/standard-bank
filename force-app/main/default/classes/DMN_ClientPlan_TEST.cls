/**
 * @description Test class for DMN_ClientPlan.cls
 */
@isTest
public without sharing class DMN_ClientPlan_TEST {
	
	public static final String TEST_USER_NAME   = 'test.StdBank_Ltn_Ecosystem_Test@test.com';
    public static final String TEST_USER_NAME_2 = '2test.StdBank_Ltn_Ecosystem_Test@test.com';
    public static final String TEST_USER_NAME_3 = '3test.StdBank_Ltn_Ecosystem_Test@test.com';
    public static final String TEST_USER_SYS_ADMIN = 'sysAdmin.StdBank_Ltn_Ecosystem_Test@test.com';
    public static final String DEF_ACC_NAME     = 'Def Name for Acc';
    public static final String DEF_ACC_NAME_IMM     = 'Def Name for Immm';
    public static final String DEF_ACC_NAME_CHILD   = 'Def Name for Child';
    public static final String DEF_ACC_NAME_ULT   = 'Def Name for ULT';
    public static final String GROUP_NUMBER     = '123456';

    private static Account acc;
    private static Account child;
    private static Account grandChild;
    private static Account ultParent;
    private static User usr;
    private static User otherUsr;
    private static User otherUsr2;
    private static User sysAdmin;
    private static Client_Plan__c plan;
    private static Client_Plan__c plan2;

    private static void getData(){
        for(User u : [  SELECT Username 
                        FROM User
                        WHERE UserName =: TEST_USER_NAME_2 
                        	OR UserName =: TEST_USER_NAME
                      		OR UserName =: TEST_USER_NAME_3
                            OR UserName =: TEST_USER_SYS_ADMIN
                        LIMIT 4]){
            if(u.UserName == TEST_USER_NAME){
                usr = u;
            }
            if(u.UserName == TEST_USER_NAME_2){
                otherUsr = u;
            }
            if(u.UserName == TEST_USER_NAME_3){
                otherUsr2 = u;
            }
            if(u.UserName == TEST_USER_SYS_ADMIN){
                sysAdmin = u;
            }
        }
    
        for(Account accRec : [  SELECT Name
                                FROM Account
                                WHERE Name  =: DEF_ACC_NAME
                                    OR Name =: DEF_ACC_NAME_IMM
                                    OR Name =: DEF_ACC_NAME_CHILD
                                    OR Name =: DEF_ACC_NAME_ULT
                                LIMIT 4]){
            if(accRec.Name == DEF_ACC_NAME){
                acc = accRec;
            }
            if(accRec.Name == DEF_ACC_NAME_IMM){
                child = accRec;
            }
            if(accRec.Name == DEF_ACC_NAME_CHILD){
                grandChild = accRec;
            }
            if (accRec.Name == DEF_ACC_NAME_ULT) {
                ultParent = accRec;
            }
        }

        plan = [SELECT Id FROM Client_Plan__c WHERE Client_Name__c =: acc.Id LIMIT 1];
        plan2 = [SELECT Id FROM Client_Plan__c WHERE Client_Name__c =: ultParent.Id LIMIT 1];
    }

    @testSetup
    static void prepareData() { 

        sysAdmin = (User)new BLD_USER(TEST_USER_SYS_ADMIN).useSysAdmin().syncContact().getRecord();
        otherUsr = (User)new BLD_USER(TEST_USER_NAME_2).useCommB().syncContact().getRecord();
        otherUsr2 = (User)new BLD_USER(TEST_USER_NAME_3).useCommB().syncContact().getRecord();
        usr = (User)new BLD_USER(TEST_USER_NAME).useCommB().syncContact().getRecord();

        insert new User[]{sysAdmin, usr, otherUsr, otherUsr2};

        System.runAs(sysAdmin){
            insert TEST_DataFactory.getUserProfileIds();
            insert TEST_DataFactory.getCcSettings();
            insert TEST_DataFactory.getEnvironmentVariable();
            insert TEST_DataFactory.getCstTeamRankings();
            insert TEST_DataFactory.getCstCoreRoles();
        }
        
        System.runAs(usr){ 
        	Test.startTest();
        	    ABS_ObjectBuilderBase accBld = new BLD_Account().name(DEF_ACC_NAME).useCommB().useGroupParent().groupNumber(GROUP_NUMBER).cibTarget(true).commitWork(); 
	            ABS_ObjectBuilderBase childAcc = new BLD_Account().name(DEF_ACC_NAME_IMM).useCommB().useImmediateParent(accBld.getRecordId()).groupNumber(GROUP_NUMBER).commitWork();
	            ABS_ObjectBuilderBase grandchildAcc = new BLD_Account().name(DEF_ACC_NAME_CHILD).useCommB().useChild(childAcc.getRecordId(), childAcc.getRecordId()).groupNumber(GROUP_NUMBER).commitWork();
                
	            ABS_ObjectBuilderBase ultParentBld = new BLD_Account().name(DEF_ACC_NAME_ULT).useGroupParent().groupNumber(GROUP_NUMBER).cibTarget(true).commitWork(); 
	            
	            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

	            ABS_ObjectBuilderBase teamBld = new BLD_ClientTeam(uow).account(accBld).role(DMN_ClientTeam.ROLE_COMMB_RELATION_MANGER).user(otherUsr.Id);
	            ABS_ObjectBuilderBase teamBld2 = new BLD_ClientTeam(uow).account(ultParentBld).role(DMN_ClientTeam.ROLE_COMMB_RELATION_MANGER).user(otherUsr2.Id);
	            ABS_ObjectBuilderBase plan = new BLD_ClientPlan(uow).account(accBld);
	            ABS_ObjectBuilderBase plan2 = new BLD_ClientPlan(uow).account(ultParentBld);

	            uow.commitWork();  
            Test.stopTest();
		}
    } 
    
  	private static testmethod void defaultDataCheck() {
       	getData();
       	Assert.areNotEqual(null, plan);
       	Assert.areEqual(2, [SELECT Id FROM Client_Plan__c].size());
       	Assert.areEqual(5, [SELECT Id FROM Account].size());
       	Assert.areEqual(2, [SELECT Id FROM Custom_Client_Team__c].size());
    }
    
    private static testmethod void approvalForCommBCheck() {
    	getData();

    	Integer sendEmails = Limits.getEmailInvocations();

    	System.runAs(usr){
    		Test.startTest();
    			new BLD_ClientPlan(plan).approve().commitWork();
    		Test.stopTest();
    	}

    	Assert.areEqual(1, [SELECT Id FROM Client_Plan__c WHERE Client_Plan_Status__c =: DMN_ClientPlan.APPROVED].size());
    }

    private static testmethod void approvalForUltParentCheck() {
    	getData();

    	Integer sendEmails = Limits.getEmailInvocations();

    	System.runAs(usr){
    		Test.startTest();
    			new BLD_ClientPlan(plan2).approve().commitWork();
    		Test.stopTest();
    	}

    	Assert.areEqual(1, [SELECT Id FROM Client_Plan__c WHERE Client_Plan_Status__c =: DMN_ClientPlan.APPROVED].size());
    }

    private static testmethod void canBeSubmittedCheck() {
    	getData();

    	Integer sendEmails = Limits.getEmailInvocations();

    	System.runAs(usr){
    		Test.startTest();
    			new BLD_ClientPlan(plan).canBeSubmitted(true).commitWork();
    		Test.stopTest();
    	}

    	Assert.areEqual(0, [SELECT Id FROM Client_Plan__c WHERE Client_Plan_Status__c =: DMN_ClientPlan.APPROVED].size());
    }

    private static testmethod void checkHistory() {
    	getData();
        List<ProcessInstance> CPApprovalHistList = new List<ProcessInstance>();
        
        System.runAs(usr) {
            Test.startTest();
                CPApprovalHistList = ClientPlan_ApprovalHistoryController.getApprovalHistory();
            Test.stopTest();
        }

        Assert.areEqual(0, CPApprovalHistList.size());
    }
    
}