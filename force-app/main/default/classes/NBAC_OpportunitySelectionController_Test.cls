/***
  	@ Func Area     	:  IB
  	@ Author        	:  Wayne Solomon
  	@ Modified Date    	:  17 Apr 2020
  	@ User Story    	:  US-3376 -- DM NBAC: Starting an SPV
  	@ Description 	    :  Updated test class for NBAC_OpportunitySelectionController
***/

@isTest
private class NBAC_OpportunitySelectionController_Test {

	private static final String
			TEST_USER_NAME          = 'stdBank@nbac.com',
			DEF_ACC_NAME            = 'Def Name for Acc',
			DEF_ACC_NAME_IMM       	= 'Def Name for Immediate';

	private static final Decimal CURRENCY_VALUE1 = 100000000.00;

	private static User
			usrOwner,
			usrCCBM,
        	commBUser,
			userNotTeamMember;
    /**
    * @description Test setup to prepare Data
    * 
    */
	@TestSetup
	private static void prepareData() {

		TEST_DataFactory.generateConfiguration();
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		System.runAs(new User(Id = UserInfo.getUserId())){

			usrOwner = (User)new BLD_USER(uow).userName(TEST_USER_NAME+'1').useCib().syncContact().getRecord();
			usrCCBM = (User)new BLD_USER(uow).userName(TEST_USER_NAME+'2').useCib().syncContact().getRecord();
			userNotTeamMember = (User)new BLD_USER(uow).userName(TEST_USER_NAME+'3').useCib().syncContact().getRecord();
            commBUser = (User)new BLD_USER(uow).userName(TEST_USER_NAME+'4').useCommB().syncContact().getRecord();
			uow.commitWork();
		}

		Test.startTest();
		Test.stopTest();

		System.runAs(usrOwner){
			BLD_Account ugpClientBld	= new BLD_Account(uow).name(DEF_ACC_NAME).useCib().useGroupParent();
			BLD_Account cibClientBld	= new BLD_Account(uow).name(DEF_ACC_NAME+'1').useCib().useGroupParent();
			BLD_Account commbClientBld	= new BLD_Account(uow).name(DEF_ACC_NAME+'2').useCommB().useGroupParent();

			cibClientBld.setField(Account.Primary_Relationship_Holder__c,'Corporate and Investment Banking');
			commbClientBld.setField(Account.Primary_Relationship_Holder__c,'Commercial Banking');

            uow.commitwork(); 
            
            BLD_Account childAccBld  = (BLD_Account) new BLD_Account(uow).name(DEF_ACC_NAME_IMM).useCib()
            							.useImmediateParent(ugpClientBld.getRecordId());

			BLD_Opportunity opportunityBld1 = new BLD_Opportunity(uow).develop().client(ugpClientBld).currency(UTL_Currency.corporateIsoCode);
			BLD_Opportunity opportunityBld2 = new BLD_Opportunity(uow).develop().client(childAccBld).currency(UTL_Currency.corporateIsoCode);
			BLD_Opportunity opportunityBld3 = new BLD_Opportunity(uow).develop().client(cibClientBld).currency(UTL_Currency.corporateIsoCode);
			BLD_Opportunity opportunityBld4 = new BLD_Opportunity(uow).develop().client(commbClientBld).currency(UTL_Currency.corporateIsoCode);
			BLD_Product productBld1 = new BLD_Product(uow).linkToOpp(opportunityBld1).notionalValueCurrency(CURRENCY_VALUE1).currency(UTL_Currency.corporateIsoCode);
			BLD_Product productBld2 = new BLD_Product(uow).linkToOpp(opportunityBld2).notionalValueCurrency(CURRENCY_VALUE1).currency(UTL_Currency.corporateIsoCode);
			BLD_Product productBld3 = new BLD_Product(uow).linkToOpp(opportunityBld2).notionalValueCurrency(CURRENCY_VALUE1).currency(UTL_Currency.corporateIsoCode);
			BLD_Product productBld4 = new BLD_Product(uow).linkToOpp(opportunityBld3).notionalValueCurrency(CURRENCY_VALUE1).currency(UTL_Currency.corporateIsoCode);
			BLD_Product productBld5 = new BLD_Product(uow).linkToOpp(opportunityBld4).notionalValueCurrency(CURRENCY_VALUE1).currency(UTL_Currency.corporateIsoCode);

			BLD_ClientTeam ccBld = new BLD_ClientTeam(uow).account(ugpClientBld).role(DMN_ClientTeam.ROLE_MANAGER_CLIENT_COVERAGE).coordinator(true).user(usrOwner.Id);
			BLD_ClientTeam ccbmBld = new BLD_ClientTeam(uow).account(ugpClientBld).role(DMN_ClientTeam.ROLE_BUSINESS_DEV_MANAGER).ccbm(true).user(usrCCBM.Id);

			cibClientBld.setField(Account.Primary_Relationship_Holder__c,'Corporate and Investment Banking');
			commbClientBld.setField(Account.Primary_Relationship_Holder__c,'Commercial Banking');

			uow.commitwork();
		}
	}
    /**
    * @description a method to set users
    * 
    */
	private static void getUsers(){
		for(User u : [  SELECT Username
		FROM User
		WHERE UserName in: (new String[]{TEST_USER_NAME+'1', TEST_USER_NAME+'2',TEST_USER_NAME+'3',TEST_USER_NAME+'4'})]){
			if(u.UserName == (TEST_USER_NAME+'1')){
				usrOwner = u;
			}
			if(u.UserName == (TEST_USER_NAME+'2')){
				usrCCBM = u;
			}
			if(u.UserName == (TEST_USER_NAME+'3')){
				userNotTeamMember = u;
			}
            if(u.UserName == (TEST_USER_NAME+'4')){
				 commBUser = u;
			}
		}
	}
    /**
    * @description negative testing on saveAssessment
    * 
    */
	@IsTest
	public static void shouldThrowNoClientSpecifiedExceptionOnSave(){
		getUsers();
		String errorMessage;
		Test.startTest();
		System.runAs(usrOwner){
			try{
				NBAC_OpportunitySelectionController.saveAssessment(null, null);
			}catch(Exception ex){
				errorMessage = ex.getMessage();
			}
		}
		Test.stopTest();
		Assert.areNotEqual(null, errorMessage,'errorMessage should not be null');
	}
    /**
    * @description negative testing on saveAssessment
    * 
    */    
	@IsTest
	public static void shouldThrowExceptionOnSave(){
		getUsers();
        String errorMessage;
		Account ugpClient = [SELECT Id FROM Account WHERE Name = :DEF_ACC_NAME LIMIT 1];
		Map<Id,SObject> opportunitiesMap = new Map<Id,SObject>((new NBAC_OpportunitySelectionController.OpportunitySelector()).getOpportunitiesByClientId(ugpClient.Id));
		Business_Assessment__c assessment;
		Test.startTest();
		System.runAs(usrCCBM){
            try{
			assessment = NBAC_OpportunitySelectionController.saveAssessment(new List<Id>(opportunitiesMap.keySet())[0], new List<Id>(opportunitiesMap.keySet()));
			}catch(Exception ex){
				errorMessage = ex.getMessage();
			}
		}
		Test.stopTest();

		Assert.areNotEqual(null, errorMessage,'errorMessage should not be null');
	}
    /**
    * @description negative testing on saveAssessment
    * 
    */	
	@IsTest
	public static void shouldThrowNoOppsSpecifiedExceptionOnSave(){
    	getUsers();
    	String errorMessage;
    	Account ugpClient = [SELECT Id FROM Account WHERE Name = :DEF_ACC_NAME LIMIT 1];
    	
    	Test.startTest();
    	System.runAs(usrOwner){
	    	try{
	    		NBAC_OpportunitySelectionController.saveAssessment(ugpClient.id, new Id[]{});
	    	}catch(Exception ex){
	    		errorMessage = ex.getMessage();
	    	}
	    }
	    Test.stopTest();
		Assert.areNotEqual(null, errorMessage,'errorMessage should not be null');
	}
    /**
    * @description negative testing on getOpportunities for CIB
    * 
    */
	@IsTest
	public static void shouldThrowInsuffiecienPrivilegesExceptions(){
    	getUsers();
    	String errorMessage;
    	Account ugpClient = [SELECT Id FROM Account WHERE Name = :DEF_ACC_NAME LIMIT 1];

		Test.startTest();
		System.runAs(userNotTeamMember){
			try{
				NBAC_OpportunitySelectionController.getOpportunities(ugpClient.Id);
			}catch(Exception ex){
				errorMessage = ex.getMessage();
			}
		}

		Assert.areNotEqual(null, errorMessage,'errorMessage should not be null');
		errorMessage = null;
		System.runAs(usrCCBM){
			try{
				NBAC_OpportunitySelectionController.getOpportunities(ugpClient.Id);
			}catch(Exception ex){
				errorMessage = ex.getMessage();
			}
		}
		Assert.areNotEqual(null, errorMessage,'errorMessage should not be null');
		Test.stopTest();


	}
    /**
    * @description negative testing on getOpportunities for CommB
    * 
    */	
	@IsTest
	public static void shouldThrowInsuffiecienPrivilegesExceptionsCommB(){
    	getUsers();
    	String errorMessage;
    	Account ugpComBClient = [SELECT Id FROM Account WHERE Name = :DEF_ACC_NAME+'2' LIMIT 1];

		Test.startTest();
		System.runAs(commBUser){
			try{
				NBAC_OpportunitySelectionController.getOpportunities(ugpComBClient.Id);
			}catch(Exception ex){
				errorMessage = ex.getMessage();
			}
		}

		Assert.areNotEqual(null, errorMessage,'errorMessage should not be null');
		errorMessage = null;
		System.runAs(usrCCBM){
			try{
				NBAC_OpportunitySelectionController.getOpportunities(ugpComBClient.Id);
			}catch(Exception ex){
				errorMessage = ex.getMessage();
			}
		}

		Assert.areNotEqual(null, errorMessage,'errorMessage should not be null');
		Test.stopTest();


	}
    /**
    * @description testing shouldReturnOpportunities this should return 2 Opps
    * 
    */	
	@IsTest
	public static void shouldReturnOpportunities(){
    	getUsers();
		Account ugpClient = [SELECT Id FROM Account WHERE Name = :DEF_ACC_NAME LIMIT 1];
    	Opportunity[] opportunities;
    	Test.startTest();
    	System.runAs(usrOwner){
	    	opportunities = (new NBAC_OpportunitySelectionController.OpportunitySelector()).getOpportunitiesByClientId(ugpClient.Id);

		}
		Test.stopTest();
		Assert.areEqual(2, opportunities.size(),'opportunities size should be two');
	}
    /**
    * @description testing shouldReturnCibOpportunities with a user assigned perm, this should return 1 Opps
    * 
    */
	@IsTest
	public static void shouldReturnCibOpportunities(){
		getUsers();
		String errorMessage = '';

		List<PermissionSetAssignment> pmas = new List<PermissionSetAssignment>();
		pmas.add(
				new PermissionSetAssignment(
				PermissionSetId =[select id from PermissionSet where name='NBAC_SPV_CIF'].Id,
				AssigneeId=usrOwner.Id
		));
		pmas.add(
				new PermissionSetAssignment(
				PermissionSetId =[select id from PermissionSet where name='NBAC_SPV_NOCIF'].Id,
				AssigneeId=usrOwner.Id
		));
		insert pmas;

		Account ugpClient = [SELECT Id FROM Account WHERE Primary_Relationship_Holder__c = 'Corporate and Investment Banking' LIMIT 1];

		Opportunity[] opportunities;
		Test.startTest();
		usrOwner.User_Division__c = 'Client Coverage';
		System.runAs(usrOwner){
			try{
				opportunities = NBAC_OpportunitySelectionController.getOpportunities(ugpClient.Id);
			}catch(Exception ex){
				errorMessage = ex.getMessage(); return;
			}
		}
		Test.stopTest();
		Assert.areEqual(1, opportunities.size(),'opportunities size should be one');
	}
    /**
    * @description testing shouldReturnCombOpportunities with a user assigned perm, this should return 0 Opps
    * 
    */
	@IsTest
	public static void shouldReturnCombOpportunities(){
		getUsers();
		String errorMessage = '';

		List<PermissionSetAssignment> pmas = new List<PermissionSetAssignment>();
		pmas.add(
				new PermissionSetAssignment(
				PermissionSetId =[select id from PermissionSet where name='NBAC_SPV_CIF'].Id,
				AssigneeId=usrOwner.Id
		));
		pmas.add(
				new PermissionSetAssignment(
				PermissionSetId =[select id from PermissionSet where name='NBAC_SPV_NOCIF'].Id,
				AssigneeId=usrOwner.Id
		));
		insert pmas;

		Account ugpClient = [SELECT Id FROM Account WHERE Primary_Relationship_Holder__c = 'Commercial Banking' LIMIT 1];

		Opportunity[] opportunities;
		Test.startTest();
		usrOwner.User_Division__c = 'Commercial Banking';
		System.runAs(usrOwner){
			try{
				opportunities = NBAC_OpportunitySelectionController.getOpportunities(ugpClient.Id);
			}catch(Exception ex){
				errorMessage = ex.getMessage();  return;
			}
		}
		Test.stopTest();
		Assert.areEqual(0, opportunities.size(),'opportunities size should be zero');
	}
    /**
    * @description testing shouldCreateBusinessAssessment this should not create assessment
    * 
    */
	@IsTest
	public static void shouldCreateBusinessAssessment(){
		getUsers();
		Account ugpClient = [SELECT Id FROM Account WHERE Name = :DEF_ACC_NAME LIMIT 1];
		Map<Id,SObject> opportunitiesMap = new Map<Id,SObject>((new NBAC_OpportunitySelectionController.OpportunitySelector()).getOpportunitiesByClientId(ugpClient.Id));
		Business_Assessment__c assessment;
		Test.startTest();
		System.runAs(usrCCBM){
			assessment = NBAC_OpportunitySelectionController.saveAssessment(ugpClient.Id, new List<Id>(opportunitiesMap.keySet()));

		}
		Test.stopTest();

		Assert.areNotEqual(null, assessment,'assessment should not be null');
	}
    /**
    * @description testing testHasEconomicOrUltimateParent this should return true is the client is UltimateParent
    * 
    */
    @IsTest
    public static void testHasEconomicOrUltimateParent(){
        Account ugpClient = [SELECT Id FROM Account WHERE Name = :DEF_ACC_NAME LIMIT 1];
		Boolean isEconoOrUltimateParent ;
        Test.startTest();
      		isEconoOrUltimateParent =  NBAC_OpportunitySelectionController.hasEconomicOrUltimateParent(ugpClient);
        Test.stopTest();
		Assert.areNotEqual(true, isEconoOrUltimateParent,'isEconoOrUltimateParent should not be true');
    }

}