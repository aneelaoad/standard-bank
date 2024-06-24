@isTest
public without sharing class AccountHierarchy_LTN_CTRL_TEST {

	public static final String TEST_USER_NAME	= 'test.StdBank_Ltn_Ecosystem_Test@test.com';
	public static final String DEF_ACC_NAME 	= 'Def Name for Acc';

	public static final Integer IMM_PARENT_NO 			=  2;
	public static final Integer DIRECT_CHILDREN_NO 		=  2;
	public static final Integer INDIRECT_CHILDREN_NO 	=  2;

	private static Integer defaultHierSize {
											get{
												return (IMM_PARENT_NO * INDIRECT_CHILDREN_NO) + IMM_PARENT_NO 
														+ DIRECT_CHILDREN_NO + 1;
											}
											set;
											}

	private static User 	usr;
	private static Account 	acc;

	private static void getUsers(){
		for(User u : [	SELECT Username 
						FROM User
						WHERE UserName =: TEST_USER_NAME
						LIMIT 1]){
			if(u.UserName == TEST_USER_NAME){
				usr = u;
			}
		}
	}

	private static void getAccount(){
		for(Account accRec : [	SELECT Name
								FROM Account
								WHERE Name 	=: DEF_ACC_NAME
								LIMIT 1]){
			if(accRec.Name == DEF_ACC_NAME){
				acc = accRec;
			}
		}
	}


	@testSetup
    static void prepareData() {
		usr = (User)new BLD_USER(TEST_USER_NAME).useCommB().syncContact().getRecord();
    	User sysAdmin = (User)new BLD_USER().useSysAdmin().syncContact().getRecord();

    	insert new User[]{usr, sysAdmin};

    	System.runAs(sysAdmin){
    		insert TEST_DataFactory.getUserProfileIds();
    	}
    	
    	System.runAs(usr){
			ABS_ObjectBuilderBase accBld = new BLD_Account().name(DEF_ACC_NAME).useCommB().useGroupParent().commitWork(); 
			createChildren(accBld.getRecordId(), IMM_PARENT_NO,INDIRECT_CHILDREN_NO);
		}
    }

    private static void createChildren(Id rootId, Integer immParentNo, Integer indirectChildrenNo){

    	Account[] directChildren = new Account[]{};

    	for(Integer i = 0; i < immParentNo; i++){
    		ABS_ObjectBuilderBase childAcc = new BLD_Account().name(String.valueOf(i + 'immParents')).useCommB()
    											.useImmediateParent(rootId);
    		directChildren.add((Account)childAcc.getRecord());
    	}

    	for(Integer i = 0; i < indirectChildrenNo; i++){
    		ABS_ObjectBuilderBase childAcc = new BLD_Account().name(String.valueOf(i + 'directChildren')).useCommB()
    											.useChild(rootId, rootId); 
    		directChildren.add((Account)childAcc.getRecord());
    	}

    	if(!directChildren.isEmpty()){
    		insert directChildren;
    	}

    	Account[] grandChildren = new Account[]{};

    	for(Account parent : directChildren){

    		if(parent.Client_relationship_hierarchy__c != DMN_Account.REL_HIERARCHY_IMMEDIATE){
    			continue;
    		}

    		for(Integer i = 0; i < indirectChildrenNo; i++){
    			ABS_ObjectBuilderBase childAcc = new BLD_Account().name(String.valueOf(i + 'grandChildren')).useCommB()
    											.useChild(rootId, rootId); 
    			grandChildren.add((Account)childAcc.getRecord());
    		}
    	}

    	if(!grandChildren.isEmpty()){
    		insert grandChildren;
    	}
    }
    
    private static testmethod void creationTest() {
		getUsers();
		getAccount(); 
		Set<Id> relatedIds;

		System.runAs(usr){
			Test.startTest();
				relatedIds = AccountHierarchy_LTN_CTRL.getHierarchyIds(acc.Id);
			Test.stopTest();
		} 

		System.assertEquals(defaultHierSize, relatedIds.size());
	}

	private static testmethod void getAccountTest() {
		getUsers();
		getAccount(); 

		Account rec;

		System.runAs(usr){
			Test.startTest();
				rec = AccountHierarchy_LTN_CTRL.getAccount(acc.Id);
				System.assertNotEquals(0, AccountHierarchy_LTN_CTRL.getStageNames().size());
				System.assertNotEquals(0, AccountHierarchy_LTN_CTRL.getContactRoles().size());
			Test.stopTest();
		} 

		System.assertEquals(acc.Id, rec.Id);
		System.assertEquals(DEF_ACC_NAME, rec.Name);
	}

	private static testmethod void agmColumnStatusVisible() {
		getUsers();
		boolean result;

		System.runAs(usr){
			Test.startTest();
			result = AccountHierarchy_LTN_CTRL.agmColumnStatusVisible();
			Test.stopTest();
		} 

		System.assertEquals(false, result);		
	}

	private static testmethod void ContactsTest() {
		getUsers();
		getAccount(); 
		Contact[] contacts;

		System.runAs(usr){
			Test.startTest();
				contacts = AccountHierarchy_LTN_CTRL.getContacts(acc.Id);
			Test.stopTest();
		}

		System.assertEquals(0, contacts.size());
	}

	private static testmethod void OpportunitiesTest() {
		getUsers();
		getAccount(); 
		Opportunity[] opps;

		System.runAs(usr){
			Test.startTest();
				opps = AccountHierarchy_LTN_CTRL.getOpportunities(acc.Id);
			Test.stopTest();
		}

		System.assertEquals(0, opps.size());
	}
	
	private static testmethod void AccountsTest() {
		getUsers();
		getAccount(); 
		Account[] accounts;

		System.runAs(usr){
			Test.startTest();
				accounts = AccountHierarchy_LTN_CTRL.getAccounts(acc.Id);
			Test.stopTest();
		}

		System.assertEquals(defaultHierSize, accounts.size());
	}
	
	private static testmethod void AccountsTest_Imm() {
		getUsers();
		getAccount(); 
		Account[] accounts;

		Account rec = [	SELECT Id 
						FROM Account
						WHERE group_parent__c =: acc.Id
							AND Client_relationship_hierarchy__c =: DMN_Account.REL_HIERARCHY_IMMEDIATE 
						LIMIT 1];

		System.runAs(usr){
			Test.startTest();
				accounts = AccountHierarchy_LTN_CTRL.getAccounts(rec.Id);
			Test.stopTest();
		}

		System.assertEquals(defaultHierSize, accounts.size());
	}

	private static testmethod void AccountsTest_child() {
		getUsers();
		getAccount(); 
		Account[] accounts;

		Account rec = [	SELECT Id 
						FROM Account
						WHERE group_parent__c =: acc.Id
							AND Client_relationship_hierarchy__c =: DMN_Account.REL_HIERARCHY_CHILD 
						LIMIT 1];

		System.runAs(usr){
			Test.startTest();
				accounts = AccountHierarchy_LTN_CTRL.getAccounts(rec.Id);
			Test.stopTest();
		} 

		System.assertEquals(defaultHierSize, accounts.size());
	}
}