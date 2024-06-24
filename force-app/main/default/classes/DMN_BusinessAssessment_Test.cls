/***
  	@ Func Area     	:  IB
  	@ Author        	:  Wayne Solomon
  	@ Modified Date    	:  19 Feb 2020
  	@ User Story    	:  US-4492 -- DM NBAC: SPV New lightning component page layout added to existing JV Lightning record page
  	@description 	    :  Updated test class for DMN_BusinessAssessment

	@ Last Modified By  :   Nikita Haruk
    @ Last Modified On  :   22/09/2023
    @ Last Modified Reason  : SFP-30063 - Updated test class for DMN_BusinessAssessment
***/
@isTest
private class DMN_BusinessAssessment_Test {

	private static final String 
		TEST_USER_NAME          = 'stdBank@nbac.com',
		DEF_ACC_NAME            = 'Def Name for Acc',
		DEF_ACC_NAME_IMM       	= 'Def Name for Immediate',
		CIF_NUMBER            = '654321',
		IMM_CIF_NUMBER            = '654322',
		MILESTONE_TRANSACTION_OVERVIEW		= 'Transaction Overview';

	private static final Decimal
		 CURRENCY_VALUE1 = 1000.00,
		 CURRENCY_VALUE2 = 2000.00,
		 CURRENCY_VALUE3 = 3000.00,
		 CURRENCY_VALUE4 = 4000.00,
		 CURRENCY_VALUE5 = 5000.00,
		 CURRENCY_VALUE6 = 6000.00,
		 CURRENCY_VALUE7 = 100000000.00,
         NEW_CROC_VALUE = 200;
	
	private static User 
		usrOwner,
		usrCCBM,
		usrRiskManager;

	@TestSetup
	private static void prepareData() {

		TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        System.runAs(new User(Id = UserInfo.getUserId())){
            
            usrOwner = (User)new BLD_USER(uow).userName(TEST_USER_NAME+'1').useCib().syncContact().getRecord();
            usrCCBM = (User)new BLD_USER(uow).userName(TEST_USER_NAME+'2').useCib().syncContact().getRecord();
            usrRiskManager = (User)new BLD_USER(uow).userName(TEST_USER_NAME+'3').useCib().syncContact().getRecord();
            uow.commitWork();
        }
        Test.startTest();

        System.runAs(usrOwner){
            BLD_Account ugpClientBld	= (BLD_Account) new BLD_Account(uow).name(DEF_ACC_NAME).CIF(CIF_NUMBER).useCib().riskRating(DMN_Account.RISK_RATING_D1).useGroupParent()
            									.setField(Account.Country_Risk__c, DMN_Account.CTRY_OF_RISK)
            									.setField(Account.Client_Franco__c, DMN_Account.FRANCO_ANGOLA)
            									.setField(Account.Internal_Credit_Rating__c, DMN_Account.RISK_RATING_D2);

            uow.commitwork(); 
            
            ugpClientBld.setField(Account.Client_Sector__c, DMN_Account.SEC_CUSTOMER)
            			.setField(Account.Client_Sub_Sector__c, DMN_Account.SUB_SEC_AGRICULTURE);
            uow.registerDirty(ugpClientBld);
            
            BLD_Account childAccBld  = (BLD_Account) new BLD_Account(uow).name(DEF_ACC_NAME_IMM).CIF(IMM_CIF_NUMBER).useCib()
            							.useImmediateParent(ugpClientBld.getRecordId())
            							.setField(Account.Economic_Group_Parent__c,ugpClientBld.getRecordId());
            uow.commitwork();
            BLD_Opportunity opportunityBld1 = new BLD_Opportunity(uow).develop().client(ugpClientBld).currency(UTL_Currency.corporateIsoCode);
            BLD_Opportunity opportunityBld2 = new BLD_Opportunity(uow).develop().client(ugpClientBld).currency(UTL_Currency.corporateIsoCode);
            new BLD_Product(uow).linkToOpp(opportunityBld1).notionalValueCurrency(CURRENCY_VALUE7).currency(UTL_Currency.corporateIsoCode);
            new BLD_Product(uow).linkToOpp(opportunityBld2).notionalValueCurrency(CURRENCY_VALUE7).currency(UTL_Currency.corporateIsoCode);
            new BLD_Product(uow).linkToOpp(opportunityBld2).notionalValueCurrency(CURRENCY_VALUE7).currency(UTL_Currency.corporateIsoCode);

            new BLD_ClientTeam(uow).account(ugpClientBld).role(DMN_ClientTeam.ROLE_MANAGER_CLIENT_COVERAGE).coordinator(true).user(usrOwner.Id);
            new BLD_ClientTeam(uow).account(ugpClientBld).role(DMN_ClientTeam.ROLE_BUSINESS_DEV_MANAGER).ccbm(true).user(usrCCBM.Id);
            new BLD_ClientTeam(uow).account(ugpClientBld).role(DMN_ClientTeam.CREDIT_MANAGER).user(usrRiskManager.Id);

            new BLD_GlobalClientRevenue(uow).client(ugpClientBld).currentAndPreviousYear()
            		.tradingDivision(DMN_GlobalClientRevenue.TRADING_DIVISION_GLOBAL_MARKET)
            		.clientValueZarCurrentYear(CURRENCY_VALUE1).clientValueZarPreviousYear(CURRENCY_VALUE2);
            new BLD_GlobalClientRevenue(uow).client(ugpClientBld).currentAndPreviousYear()
            		.tradingDivision(DMN_GlobalClientRevenue.TRADING_DIVISION_INVESTMENT_BANKING)
            		.clientValueZarCurrentYear(CURRENCY_VALUE3).clientValueZarPreviousYear(CURRENCY_VALUE4);
    		new BLD_GlobalClientRevenue(uow).client(ugpClientBld).currentAndPreviousYear()
            		.tradingDivision(DMN_GlobalClientRevenue.TRADING_DIVISION_RANSACTIONAL_PRODUCTS_AND_SERVICES)
            		.clientValueZarCurrentYear(CURRENCY_VALUE5).clientValueZarPreviousYear(CURRENCY_VALUE6);
            
            new BLD_ClientCapitalAndRevenue(uow).clientCIF(CIF_NUMBER).CROCZAR(CURRENCY_VALUE2).currency(UTL_Currency.corporateIsoCode);
	        
	        String currentYear = String.valueOf(System.today().year());
	        new BLD_ShareWallet(uow).client(ugpClientBld)
	        		.division(DMN_ShareWallet.DIVISION_GLOBAL_MARKETS).financialYear(currentYear)
	        		.revenue(CURRENCY_VALUE1).totalWalletSize(CURRENCY_VALUE5);
	       	new BLD_ShareWallet(uow).client(ugpClientBld)
	        		.division(DMN_ShareWallet.DIVISION_INVESTMENT_BANKING).financialYear(currentYear)
	        		.revenue(CURRENCY_VALUE2).totalWalletSize(CURRENCY_VALUE4);
	        new BLD_ShareWallet(uow).client(ugpClientBld)
	        		.division(DMN_ShareWallet.DIVISION_TRANSACTIONAL_PRODUCTS_AND_SERVICES).financialYear(currentYear)
	        		.revenue(CURRENCY_VALUE1).totalWalletSize(CURRENCY_VALUE2);
			
	       	new BLD_CreditRiskAppetite(uow)
					.setField(Credit_Risk_Appetite__c.Country__c, DMN_Account.CTRY_OF_RISK)
					.setField(Credit_Risk_Appetite__c.Sector__c, DMN_Account.SEC_CUSTOMER)
					.setField(Credit_Risk_Appetite__c.Sub_Sector__c, DMN_Account.SUB_SEC_AGRICULTURE)
					.setField(Credit_Risk_Appetite__c.Sector_Credit_Appetite__c, DMN_RiskAppettite.RISK_HOLD)
					.setField(Credit_Risk_Appetite__c.Country_Credit_Appetite__c, DMN_RiskAppettite.RISK_HOLD);
			
			new BLD_CreditLine(uow).account(ugpClientBld).totalUtilisation(CURRENCY_VALUE2).creditLimit(CURRENCY_VALUE2).creditLimitReferenceNumber('testLimitRefNumber1');
			new BLD_CreditLine(uow).account(childAccBld).totalUtilisation(CURRENCY_VALUE3).creditLimit(CURRENCY_VALUE3).creditLimitReferenceNumber('testLimitRefNumber2');

			uow.commitwork();
			new BLD_BusinessAssessment(uow).client(ugpClientBld);

			uow.commitwork();

        	Test.stopTest();
		}
	}

	private static void getUsers(){
        for(User u : [  SELECT Username
		FROM User
		WHERE UserName in: (new String[]{TEST_USER_NAME+'1', TEST_USER_NAME+'2',TEST_USER_NAME+'3'})]){
			if(u.UserName == (TEST_USER_NAME+'1')){
				usrOwner = u;
			}
			if(u.UserName == (TEST_USER_NAME+'2')){
				usrCCBM = u;
			}
			if(u.UserName == (TEST_USER_NAME+'3')){
				usrRiskManager = u;
			}
		}
	}

	@isTest static void shouldThrowNoAssessmentException() {
		String exceptionMessage;
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		try{
			DMN_BusinessAssessment.assignOpportunities(null, null,uow);
		}catch(DMN_BusinessAssessment.BusinessAssessmentException ex){
			exceptionMessage = ex.getMessage();
		}

		Assert.areEqual(DMN_BusinessAssessment.NO_BUSINESS_ASSESSMENT_SPECIFIED, exceptionMessage, 'Checking exceptionMessage');
	}

	@isTest static void shouldThrowNoOpportuinityException() {
        Test.startTest();
		String exceptionMessage;
		
		Business_Assessment__c[] assessments = [SELECT Id
												FROM Business_Assessment__c limit 1];
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();										
		
		try{
			
			DMN_BusinessAssessment.assignOpportunities(assessments[0].Id, null,uow);

		}catch(DMN_BusinessAssessment.BusinessAssessmentException ex){
			exceptionMessage = ex.getMessage();
		}

		Assert.areEqual(DMN_BusinessAssessment.NO_OPPORTUNITY_SPECIFIED, exceptionMessage, 'Checking exceptionMessage');
        Test.stopTest();
	}

	@IsTest
	private static void shouldUpdateOpportunityOnBusinessAssessmentUpdate(){
		Test.startTest();
		Business_Assessment__c assessment = [
				SELECT Id, Account__c, Name, Credit_Paper_Approved_By__c
				FROM Business_Assessment__c
				limit 1
		];

		Opportunity[] opportunities = [
				SELECT Id
				FROM Opportunity
				WHERE AccountId = :assessment.Account__c
				LIMIT 1
		];

		List<Id> opportunitiesIds = new List<Id>(new Map<Id,SObject>(opportunities).keySet());
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

		DMN_BusinessAssessment.assignOpportunities(assessment.Id, opportunitiesIds, uow);
		uow.commitWork();
		assessment.Credit_Paper_Approved_By__c = 'John Doe';

		update assessment;

		Opportunity testOpp = [SELECT Id, Business_Assessment_Name__c, Credit_Paper_Approved_By__c FROM Opportunity WHERE Id = :opportunities.get(0).Id];
		Assert.areEqual(assessment.Name, testOpp.Business_Assessment_Name__c, 'Checking Business_Assessment_Name__c');
		Assert.areEqual(assessment.Credit_Paper_Approved_By__c, testOpp.Credit_Paper_Approved_By__c, 'Checking Credit_Paper_Approved_By__c');
		Test.stopTest();
	}

	@IsTest
	private static void shouldUpdateOpportunityOnBusinessAssessmentDelete(){
		Test.startTest();
		Business_Assessment__c assessment = [
				SELECT Id, Account__c, Name, Credit_Paper_Approved_By__c
				FROM Business_Assessment__c
				limit 1
		];

		Opportunity[] opportunities = [
				SELECT Id
				FROM Opportunity
				WHERE AccountId = :assessment.Account__c
				LIMIT 1
		];

		List<Id> opportunitiesIds = new List<Id>(new Map<Id,SObject>(opportunities).keySet());
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

		DMN_BusinessAssessment.assignOpportunities(assessment.Id, opportunitiesIds, uow);
		uow.commitWork();
		assessment.Credit_Paper_Approved_By__c = 'John Doe';

		update assessment;
		delete assessment;

		Opportunity testOpp = [SELECT Id, Business_Assessment_Name__c, Credit_Paper_Approved_By__c FROM Opportunity WHERE Id = :opportunities.get(0).Id];
		Assert.areEqual(null, testOpp.Business_Assessment_Name__c, 'Checking that null');
		Assert.areEqual(null, testOpp.Credit_Paper_Approved_By__c, 'Checking that null');
		Test.stopTest();
	}

	@IsTest
	private static void shouldUpdateOpportunityOnBusinessAssessmentUndelete(){
		Test.startTest();
		Business_Assessment__c assessment = [
				SELECT Id, Account__c, Name, Credit_Paper_Approved_By__c
				FROM Business_Assessment__c
				limit 1
		];

		Opportunity[] opportunities = [
				SELECT Id
				FROM Opportunity
				WHERE AccountId = :assessment.Account__c
				LIMIT 1
		];

		List<Id> opportunitiesIds = new List<Id>(new Map<Id,SObject>(opportunities).keySet());
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

		DMN_BusinessAssessment.assignOpportunities(assessment.Id, opportunitiesIds, uow);
		uow.commitWork();
		assessment.Credit_Paper_Approved_By__c = 'John Doe';

		update assessment;
		delete assessment;
		undelete assessment;

		Opportunity testOpp = [SELECT Id, Business_Assessment_Name__c, Credit_Paper_Approved_By__c FROM Opportunity WHERE Id = :opportunities.get(0).Id];
		Assert.areEqual(assessment.Name, testOpp.Business_Assessment_Name__c, 'Checking Business_Assessment_Name__c');
		Assert.areEqual(assessment.Credit_Paper_Approved_By__c, testOpp.Credit_Paper_Approved_By__c, 'Checking Credit_Paper_Approved_By__c');
		Test.stopTest();
	}

	@isTest static void shouldCreateAssessmentOpportunities() {
		Test.startTest();
		Business_Assessment__c[] assessments = [SELECT Id, Account__c
												FROM Business_Assessment__c limit 1];
		
		Opportunity[] opportunities = [SELECT Id 
										FROM Opportunity
										WHERE AccountId =: assessments[0].Account__c];

		List<Id> opportunitiesIds = new List<Id>(new Map<Id,SObject>(opportunities).keySet());
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		
		Assessment_Opportunity__c[] assessmentOpps = DMN_BusinessAssessment.assignOpportunities(assessments[0].Id, opportunitiesIds, uow);


		uow.commitWork();

		Business_Assessment__c assessment = [SELECT Delegated_Authority__c, Total_SB_Gross_Participation__c
												, NBAC_Committee__c, NBAC_Committee_Level__c
												FROM Business_Assessment__c LIMIT 1];
		Test.stopTest();
		Assert.areEqual(2, assessmentOpps.size(), 'Checking the size of list');
		Assert.areEqual(DMN_BusinessAssessment.DELEGATED_AUTHORITY_DA2, assessment.Delegated_Authority__c, 'Checking Delegated_Authority__c');
		Assert.areEqual((3*CURRENCY_VALUE7+CURRENCY_VALUE2+CURRENCY_VALUE3), assessment.Total_SB_Gross_Participation__c, 'Checking Total_SB_Gross_Participation__c');

		Assert.areEqual(DMN_BusinessAssessment.COMMITTEE_ANGOLA, assessment.NBAC_Committee__c, 'Checking COMMITTEE_ANGOLA');
		Assert.areEqual(DMN_BusinessAssessment.COMMITTEE_LEVEL_LOCAL, assessment.NBAC_Committee_Level__c, 'Checking COMMITTEE_LEVEL_LOCAL');
	}
	
	@isTest static void shouldSetDefaults() {
		Test.startTest();
		getUsers();
		Business_Assessment__c assessment = [SELECT Id, YTD_Group_Parent_Client_CROC__c, Economic_Group_Sector_Risk_Appetite__c,Economic_Group_Risk_Appetite__c
													, GM_Share_of_Wallet_Existing_SBG__c , IB_Share_of_Wallet_Existing_SBG__c, TPS_Share_of_Wallet_Existing_SBG__c
													, GM_Share_of_Wallet_Existing_Total__c , IB_Share_of_Wallet_Existing_Total__c, TPS_Share_of_Wallet_Existing_Total__c
													, Global_Markets_CY_Revenue__c , Investment_Banking_CY_Revenue__c, TPS_CY_Revenue__c
													, Global_Markets_PY_Revenue__c , Investment_Banking_PY_Revenue__c, TPS_PY_Revenue__c
													, Group_Parent_CC__c, Group_Parent_CCBM__c, Credit_Manager__c, Economic_Group_Parent_Credit_Limits__c 
													, CurrencyISOCode
												FROM Business_Assessment__c LIMIT 1];

		assessment.Milestone__c = MILESTONE_TRANSACTION_OVERVIEW;

		Assert.areEqual(assessment.YTD_Group_Parent_Client_CROC__c, CURRENCY_VALUE2, 'Checking YTD_Group_Parent_Client_CROC__c');
		
		Assert.areEqual(assessment.GM_Share_of_Wallet_Existing_SBG__c, (CURRENCY_VALUE1/CURRENCY_VALUE5)*100, 'Checking GM_Share_of_Wallet_Existing_SBG__c');
		Assert.areEqual(assessment.IB_Share_of_Wallet_Existing_SBG__c, (CURRENCY_VALUE2/CURRENCY_VALUE4)*100, 'Checking IB_Share_of_Wallet_Existing_SBG__c');
		Assert.areEqual(assessment.TPS_Share_of_Wallet_Existing_SBG__c, (CURRENCY_VALUE1/CURRENCY_VALUE2)*100, 'Checking TPS_Share_of_Wallet_Existing_SBG__c');
		
		Assert.areEqual(assessment.GM_Share_of_Wallet_Existing_Total__c, CURRENCY_VALUE5, 'Checking GM_Share_of_Wallet_Existing_Total__c');
		Assert.areEqual(assessment.IB_Share_of_Wallet_Existing_Total__c, CURRENCY_VALUE4, 'Checking IB_Share_of_Wallet_Existing_Total__c');
		Assert.areEqual(assessment.TPS_Share_of_Wallet_Existing_Total__c, CURRENCY_VALUE2, 'Checking TPS_Share_of_Wallet_Existing_Total__c');
		
		Assert.areEqual(assessment.Global_Markets_CY_Revenue__c, CURRENCY_VALUE1, 'Checking Global_Markets_CY_Revenue__c');
		Assert.areEqual(assessment.Investment_Banking_CY_Revenue__c, CURRENCY_VALUE3, 'Checking Investment_Banking_CY_Revenue__c');
		Assert.areEqual(assessment.TPS_CY_Revenue__c, CURRENCY_VALUE5, 'Checking TPS_CY_Revenue__c');
		
		Assert.areEqual(assessment.Global_Markets_PY_Revenue__c, CURRENCY_VALUE2, 'Checking Global_Markets_PY_Revenue__c');
		Assert.areEqual(assessment.Investment_Banking_PY_Revenue__c, CURRENCY_VALUE4, 'Checking Investment_Banking_PY_Revenue__c');
		Assert.areEqual(assessment.TPS_PY_Revenue__c, CURRENCY_VALUE6, 'Checking TPS_PY_Revenue__c');

		Assert.areEqual(assessment.Economic_Group_Parent_Credit_Limits__c, CURRENCY_VALUE2+CURRENCY_VALUE3, 'Checking Economic_Group_Parent_Credit_Limits__c');

		Assert.areEqual(assessment.Economic_Group_Sector_Risk_Appetite__c, DMN_RiskAppettite.RISK_HOLD, 'Checking Economic_Group_Sector_Risk_Appetite__c');
		Assert.areEqual(assessment.Economic_Group_Risk_Appetite__c, DMN_RiskAppettite.RISK_HOLD, 'Checking Economic_Group_Risk_Appetite__c');

		Assert.areEqual(assessment.CurrencyISOCode, UTL_Currency.corporateIsoCode, 'Checking CurrencyISOCode');
		
		Assert.areEqual(assessment.Group_Parent_CCBM__c, usrCCBM.Id, 'Checking Group_Parent_CCBM__c');
		Assert.areEqual(assessment.Credit_Manager__c, usrRiskManager.Id, 'Checking Credit_Manager__c');
		Assert.areEqual(assessment.Group_Parent_CC__c, usrOwner.Id, 'Checking Group_Parent_CC__c');
        Test.stopTest();
	}
	
	@isTest static void shouldCreatePdf() {
		Test.startTest();
        	getUsers();
			Business_Assessment__c assessment = [
                SELECT Milestone__c,
						(	SELECT Name
							FROM Attachments
						)
				FROM Business_Assessment__c
				LIMIT 1
			];

			Assert.areEqual(true, assessment.Attachments.isEmpty(), 'Checking Attachments');
			Assert.areNotEqual(DMN_BusinessAssessment.MILESTONE_SUPPORTED, assessment.Milestone__c, 'Checking Milestone__c');
        
			assessment.Milestone__c = DMN_BusinessAssessment.MILESTONE_SUPPORTED;
			assessment.RecordTypeId = UTL_RecordType.getRecordTypeId(	DMN_BusinessAssessment.OBJ_NAME,
																		DMN_BusinessAssessment.RT_NBAC);

			update assessment;

		assessment = [SELECT Milestone__c FROM Business_Assessment__c WHERE Id =: assessment.Id];
		Assert.areEqual(DMN_BusinessAssessment.MILESTONE_SUPPORTED, assessment.Milestone__c, 'Checking Milestone__c');
		Test.stopTest();
	}

	@isTest static void shouldUpdateRevenueData() {
		Test.startTest();
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

		List<Business_Assessment__c> bAssessments = [SELECT Account__r.CIF__c,  Global_Markets_CY_Revenue__c, Global_Markets_PY_Revenue__c FROM Business_Assessment__c LIMIT 1];
		Decimal oldCYValue = bAssessments[0].Global_Markets_CY_Revenue__c,
				oldPYValue = bAssessments[0].Global_Markets_PY_Revenue__c;
        List<Client_Capital_and_Revenue__c> ccRevenue = [SELECT CROC_ZAR__c FROM Client_Capital_and_Revenue__c LIMIT 1];
        ccRevenue[0].CROC_ZAR__c = NEW_CROC_VALUE;
        uow.registerDirty(ccRevenue);

		new BLD_GlobalClientRevenue(uow).currentAndPreviousYear()
				.tradingDivision(DMN_GlobalClientRevenue.TRADING_DIVISION_GLOBAL_MARKET)
				.clientValueZarCurrentYear(CURRENCY_VALUE1).clientValueZarPreviousYear(CURRENCY_VALUE2)
				.setField(Global_Client_Revenue__c.Client__c, bAssessments[0].Account__c)
				.setField(Global_Client_Revenue__c.Client_CIF_Number__c, bAssessments[0].Account__r.CIF__c);
        uow.commitWork();
			bAssessments = DMN_BusinessAssessment.updateRevenueAndCrocData(bAssessments);
            update bAssessments;

		List<Business_Assessment__c> businessAssessments = [SELECT YTD_Group_Parent_Client_CROC__c, Global_Markets_CY_Revenue__c, Global_Markets_PY_Revenue__c FROM Business_Assessment__c LIMIT 1];
		Assert.areEqual(oldCYValue + CURRENCY_VALUE1, businessAssessments[0].Global_Markets_CY_Revenue__c, 'Checking Global_Markets_CY_Revenue__c');
		Assert.areEqual(oldPYValue + CURRENCY_VALUE2, businessAssessments[0].Global_Markets_PY_Revenue__c, 'Checking Global_Markets_CY_Revenue__c');
        Assert.areEqual(NEW_CROC_VALUE, businessAssessments[0].YTD_Group_Parent_Client_CROC__c, 'Checking YTD_Group_Parent_Client_CROC__c');
		Test.stopTest();
	}

	@isTest static void shouldUpdateEntitiesRiskRating() {
		Test.startTest();
		Business_Assessment__c[] assessments = [SELECT Id, Account__c
		FROM Business_Assessment__c limit 1];

		Opportunity[] opportunities = [SELECT Id, Account.Name, Account.Internal_Credit_Rating__c
		FROM Opportunity
		WHERE AccountId =: assessments[0].Account__c];

		String entity1 = opportunities[0].Account.Name + ', ' + opportunities[0].Account.Internal_Credit_Rating__c;
		String entity2 = opportunities[1].Account.Name + ', ' + opportunities[1].Account.Internal_Credit_Rating__c;

		List<Id> opportunitiesIds = new List<Id>(new Map<Id,SObject>(opportunities).keySet());
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

		DMN_BusinessAssessment.assignOpportunities(assessments[0].Id, opportunitiesIds, uow);

		uow.commitWork();

		DMN_BusinessAssessment.updateEntitiesRiskRating(new Set<Id> {assessments[0].Account__c} );

		Business_Assessment__c bAssessment = [SELECT Entities_Risk_Rating__c, (SELECT Id FROM Assessment_Opportunities__r) FROM Business_Assessment__c WHERE Id = :assessments[0].Id];
		Test.stopTest();
		Assert.isTrue((bAssessment.Entities_Risk_Rating__c).contains(entity1), 'Checking Entities_Risk_Rating__c');
		Assert.isTrue((bAssessment.Entities_Risk_Rating__c).contains(entity2), 'Checking Entities_Risk_Rating__c');
	}

	@isTest static void updateDistributionAndRiskManMilestoneTest() {
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount0 = new BLD_Account(uow)
				.name('acc0')
				.useGroupParent()
		;
		BLD_BusinessAssessment bAsessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment(uow)
				.client(bAccount0.getRecordId());

		bAsessment.setField(Business_Assessment__c.SB_Gross_Participation__c,1);
		bAsessment.setField(Business_Assessment__c.SB_Hold__c,1);
		bAsessment.setField(Business_Assessment__c.SB_Sell_Down__c,1);
		bAsessment.setField(Business_Assessment__c.Market_Deal_Size__c,1);
		bAsessment.setField(Business_Assessment__c.Bank_Role__c,'Advisor');
		bAsessment.setField(Business_Assessment__c.Transaction_Type__c,'Bi-Lateral');
		bAsessment.setField(Business_Assessment__c.Listed_Instruments__c,'1');
		bAsessment.setField(Business_Assessment__c.Distribution_Price__c,'1');
		bAsessment.setField(Business_Assessment__c.Distribution_Commentary__c,'1');
		bAsessment.setField(Business_Assessment__c.Risk_Commentary__c,'1');
		Test.startTest();
		DMN_BusinessAssessment.updateDistributionAndRiskManMilestone((Business_Assessment__c)bAsessment.getRecord());
		Test.stopTest();
		Assert.isTrue(((Business_Assessment__c) bAsessment.getRecord()).Completed_Distribution_And_RiskMan__c, 'Checking Completed_Distribution_And_RiskMan__c');
	}

	@isTest static void updateComplianceMilestoneTest() {
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount0 = new BLD_Account(uow)
				.name('acc0')
				.useGroupParent()
		;
		BLD_BusinessAssessment bAsessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment(uow)
				.client(bAccount0.getRecordId());

		bAsessment.setField(Business_Assessment__c.GCCR_Status__c,'1');
		bAsessment.setField(Business_Assessment__c.KYC_Status__c,'1');
		bAsessment.setField(Business_Assessment__c.EDD_PEP__c,'1');
		bAsessment.setField(Business_Assessment__c.Sanctions__c,'1');
		Test.startTest();
		DMN_BusinessAssessment.updateComplianceMilestone((Business_Assessment__c)bAsessment.getRecord());
		Test.stopTest();
		Assert.isTrue(((Business_Assessment__c) bAsessment.getRecord()).Completed_Compliance__c, 'Checking Completed_Compliance__c');
	}

	@isTest static void updateEnvironmentalAssessmentMilestoneTest(){
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount0 = new BLD_Account(uow)
				.name('acc0')
				.useGroupParent()
		;
		BLD_BusinessAssessment bAsessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment(uow)
				.client(bAccount0.getRecordId());

		bAsessment.setField(Business_Assessment__c.ES_Risk_Commentary__c,'1');
		bAsessment.setField(Business_Assessment__c.Transaction_Risk__c,'1');
		bAsessment.setField(Business_Assessment__c.Client_Risk__c,'1');
		bAsessment.setField(Business_Assessment__c.Reference_Number__c,'1');
		bAsessment.setField(Business_Assessment__c.Transaction_on_the_Exceptions_List__c, true);
		bAsessment.setField(Business_Assessment__c.ENS_status__c, 'Completed');
		Test.startTest();
		DMN_BusinessAssessment.updateEnvironmentalAssessmentMilestone((Business_Assessment__c)bAsessment.getRecord());
		Test.stopTest();
		Assert.isTrue(((Business_Assessment__c) bAsessment.getRecord()).Completed_Environmental_Assessment__c, 'Checking Completed_Environmental_Assessment__c');
	}

	@isTest static void updateAnnexureDescriptionMilestoneTest(){
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount0 = new BLD_Account(uow)
				.name('acc0')
				.useGroupParent()
		;
		BLD_BusinessAssessment bAsessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment(uow)
				.client(bAccount0.getRecordId());

		bAsessment.setField(Business_Assessment__c.Submission_Type__c,'Type 3: Emphasis on risk / complexity');
		bAsessment.setField(Business_Assessment__c.Additional_Transaction_Description__c,'1');
		Test.startTest();
		DMN_BusinessAssessment.updateAnnexureDescriptionMilestone((Business_Assessment__c)bAsessment.getRecord());
		Test.stopTest();
		Assert.isTrue(((Business_Assessment__c) bAsessment.getRecord()).Completed_Annexure_Description__c, 'Checking Completed_Annexure_Description__c');
	}

	@isTest static void updateAnnexureRationaleMilestoneTest(){
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount0 = new BLD_Account(uow)
				.name('acc0')
				.useGroupParent()
		;
		BLD_BusinessAssessment bAsessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment(uow)
				.client(bAccount0.getRecordId());

		bAsessment.setField(Business_Assessment__c.Submission_Type__c,'Type 2: Emphasis on client strategy / returns');
		bAsessment.setField(Business_Assessment__c.Additional_Strategic_Rationale__c,'1');
		Test.startTest();
		DMN_BusinessAssessment.updateAnnexureRationaleMilestone((Business_Assessment__c)bAsessment.getRecord());
		Test.stopTest();
		Assert.isTrue(((Business_Assessment__c) bAsessment.getRecord()).Completed_Annexure_Rationale__c, 'Checking Completed_Annexure_Rationale__c');
	}

	@isTest static void updateStrategicRationaleMilestoneTest(){
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount0 = new BLD_Account(uow)
				.name('acc0')
				.useGroupParent()
		;
		BLD_BusinessAssessment bAsessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment(uow)
				.client(bAccount0.getRecordId());

		bAsessment.setField(Business_Assessment__c.Strategic_Rationale__c,'1');
		Test.startTest();
		DMN_BusinessAssessment.updateStrategicRationaleMilestone((Business_Assessment__c)bAsessment.getRecord());
		Test.stopTest();
		Assert.isTrue(((Business_Assessment__c) bAsessment.getRecord()).Completed_Strategic_Rationale__c, 'Checking Completed_Strategic_Rationale__c');
	}

	@isTest static void updateTransactionProfileMilestoneTest(){
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount0 = new BLD_Account(uow)
				.name('acc0')
				.useGroupParent()
		;
		BLD_BusinessAssessment bAsessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment(uow)
				.client(bAccount0.getRecordId());

		bAsessment.setField(Business_Assessment__c.Transaction_Description__c,'1');
		Test.startTest();
		DMN_BusinessAssessment.updateTransactionProfileMilestone((Business_Assessment__c)bAsessment.getRecord());
		Test.stopTest();
		Assert.isTrue(((Business_Assessment__c) bAsessment.getRecord()).Completed_Transaction_Profile__c, 'Checking Completed_Transaction_Profile__c');
	}

	@isTest static void updateTransactionCounterPartiesTest() {
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount0 = new BLD_Account(uow)
				.name('acc0')
				.useGroupParent()
		;
		BLD_BusinessAssessment bAsessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment(uow)
				.client(bAccount0.getRecordId());

		bAsessment.setField(Business_Assessment__c.RecordTypeId,Schema.SObjectType.Business_Assessment__c.getRecordTypeInfosByDeveloperName().get('NBAC_Joint_Venture').getRecordTypeId());
		bAsessment.setField(Business_Assessment__c.Account__c,bAccount0.getRecordId());
		bAsessment.setField(Business_Assessment__c.Gearing_Metric__c,'1');
		bAsessment.setField(Business_Assessment__c.Off_Taker__c,'1');
		bAsessment.setField(Business_Assessment__c.Max_Transaction_Gearing__c,1);
		bAsessment.setField(Business_Assessment__c.Nature_of_Business__c,'1');
		bAsessment.setField(Business_Assessment__c.Guarantor_Name__c,bAccount0.getRecordId());
		bAsessment.setField(Business_Assessment__c.Guarantor_Gearing_PreTransaction__c,'1');
		bAsessment.setField(Business_Assessment__c.Guarantor_Gearing_PostTransaction__c,'1');
		bAsessment.setField(Business_Assessment__c.Export_Credit_Agency__c,'1');
		bAsessment.setField(Business_Assessment__c.Political_Risk_Cover__c,1);
		bAsessment.setField(Business_Assessment__c.Commercial_Risk_Cover__c,1);
		Test.startTest();
		DMN_BusinessAssessment.updateTransactionCounterParties((Business_Assessment__c)bAsessment.getRecord());
		Test.stopTest();
		Assert.isTrue(!((Business_Assessment__c) bAsessment.getRecord()).Completed_Transaction_Counterparties__c, 'Checking Completed_Transaction_Counterparties__c');
	}

	@isTest static void updateClientDetailsTest() {
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount0 = new BLD_Account(uow)
				.name('acc0')
				.useGroupParent()
		;
		BLD_BusinessAssessment bAsessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment(uow)
				.client(bAccount0.getRecordId());

		bAsessment.setField(Business_Assessment__c.RecordTypeId,Schema.SObjectType.Business_Assessment__c.getRecordTypeInfosByDeveloperName().get('NBAC_Joint_Venture').getRecordTypeId());
		bAsessment.setField(Business_Assessment__c.Client_Rating__c,'1');
		bAsessment.setField(Business_Assessment__c.Construction_Risk_Grade__c,'1');
		bAsessment.setField(Business_Assessment__c.Operations_Risk_Grade__c,'1');
		bAsessment.setField(Business_Assessment__c.Client_Sector__c,'1');
		bAsessment.setField(Business_Assessment__c.Risk_Classification__c,'1');
		bAsessment.setField(Business_Assessment__c.Economic_Group_Sector_Risk_Appetite__c,'1');
		bAsessment.setField(Business_Assessment__c.Complexity__c,'1');
		bAsessment.setField(Business_Assessment__c.Decision_Emphasis__c,'1');
		bAsessment.setField(Business_Assessment__c.Construction_LGD__c,1);
		bAsessment.setField(Business_Assessment__c.Operation_LGD__c,1);
		bAsessment.setField(Business_Assessment__c.Ultimate_Shareholders__c,'1');
		bAsessment.setField(Business_Assessment__c.Sponsors__c,'1');
		Test.startTest();
		DMN_BusinessAssessment.updateClientDetails((Business_Assessment__c)bAsessment.getRecord());
		Test.stopTest();
		Assert.isTrue(((Business_Assessment__c) bAsessment.getRecord()).Completed_Client_Details_New__c, 'Checking Completed_Client_Details_New__c');
	}

	@isTest static void updateBusinessSOWTest(){
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount0 = new BLD_Account(uow)
				.name('acc0')
				.useGroupParent()
		;
		BLD_BusinessAssessment bAsessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment(uow)
				.client(bAccount0.getRecordId());

		bAsessment.setField(Business_Assessment__c.GM_Share_of_Wallet_Existing_Total__c,1);
		bAsessment.setField(Business_Assessment__c.GM_Share_of_Wallet_Existing_SBG__c,1);
		bAsessment.setField(Business_Assessment__c.IB_Share_of_Wallet_Existing_Total__c,1);
		bAsessment.setField(Business_Assessment__c.IB_Share_of_Wallet_Existing_SBG__c,1);
		bAsessment.setField(Business_Assessment__c.TPS_Share_of_Wallet_Existing_Total__c,1);
		bAsessment.setField(Business_Assessment__c.TPS_Share_of_Wallet_Existing_SBG__c,1);
		bAsessment.setField(Business_Assessment__c.Anticipated_Ancillary_Business_GM__c,'1');
		bAsessment.setField(Business_Assessment__c.Anticipated_Ancillary_Business_IB__c,'1');
		bAsessment.setField(Business_Assessment__c.Anticipated_Ancillary_Business_TPS__c,'1');
		Test.startTest();
		DMN_BusinessAssessment.updateBusinessSOW((Business_Assessment__c)bAsessment.getRecord());
		Test.stopTest();
		Assert.isTrue(((Business_Assessment__c) bAsessment.getRecord()).Completed_Business_and_SOW_New__c, 'Checking Completed_Business_and_SOW_New__c');
	}

	@isTest static void updateFinancialAnalysisTest(){
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount0 = new BLD_Account(uow)
				.name('acc0')
				.useGroupParent()
		;
		BLD_BusinessAssessment bAsessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment(uow)
				.client(bAccount0.getRecordId());
		Test.startTest();
		DMN_BusinessAssessment.updateFinancialAnalysis((Business_Assessment__c)bAsessment.getRecord());
		Test.stopTest();
		Assert.isTrue(!((Business_Assessment__c) bAsessment.getRecord()).Completed_Financial_Analysis_New__c, 'Checking Completed_Financial_Analysis_New__c');
	}

	@isTest static void updateTransactionPartiesTest(){
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount0 = new BLD_Account(uow)
				.name('acc0')
				.useGroupParent()
		;
		BLD_BusinessAssessment bAsessment = (BLD_BusinessAssessment) new BLD_BusinessAssessment(uow)
				.client(bAccount0.getRecordId());

		bAsessment.setField(Business_Assessment__c.Advisor__c,'1');
		bAsessment.setField(Business_Assessment__c.Mandated_Lead_Arranger__c,'1');
		bAsessment.setField(Business_Assessment__c.Other_Lenders__c,'1');
		Test.startTest();
		DMN_BusinessAssessment.updateTransactionParties((Business_Assessment__c)bAsessment.getRecord());
		Test.stopTest();
		Assert.isTrue(((Business_Assessment__c) bAsessment.getRecord()).Completed_Transaction_Parties_New__c, 'Checking Completed_Transaction_Parties_New__c');
	}

	@isTest
	static void updateAncillaryToYesTest() {
		List<Opportunity> opportunities = [SELECT Id FROM Opportunity];
		List<Business_Assessment__c> bAssessment = [SELECT Id FROM Business_Assessment__c];

        Test.startTest();
			insert new Assessment_Opportunity__c(
				Business_Assessment__c = bAssessment.get(0).Id,
				Opportunity__c = opportunities.get(0).Id
			);
        	update new Opportunity(
				Id = opportunities.get(1).Id,
				Parent_Opportunity__c = opportunities.get(0).Id
			);
			update new Business_Assessment__c(
				Id = bAssessment.get(0).Id,
				Ancillary_Revenue__c = 'Yes',
				Anticipated_Ancillary_Business_GM__c = '123',
				Anticipated_Ancillary_Business_IB__c = '234',
				Anticipated_Ancillary_Business_TPS__c = '345'
			);
		Test.stopTest();

		Set<Id> countedOppIds = new Set<Id>();
		Decimal estimatedAncillaryRevenue = 0;
		for (SB_Product__c product : [SELECT Id, Opportunity__c, Opportunity__r.Amount FROM SB_Product__c WHERE Opportunity__r.Parent_Opportunity__c = :opportunities.get(0).Id]) {
			if (!countedOppIds.contains(product.Opportunity__c)) {
				estimatedAncillaryRevenue += product.Opportunity__r.Amount;
				countedOppIds.add(product.Opportunity__c);
			}
		}
		Business_Assessment__c updateAssessment = [SELECT Id, Is_Completed_Ancillary_Business__c, Estimated_Ancillary_Revenue__c FROM Business_Assessment__c WHERE Id = :bAssessment.get(0).Id LIMIT 1];

		Assert.areEqual(true, updateAssessment.Is_Completed_Ancillary_Business__c, 'Checking the Is_Completed_Ancillary_Business__c');
		Assert.areEqual(true, updateAssessment.Estimated_Ancillary_Revenue__c != null, 'Checking the Estimated_Ancillary_Revenue__c');
		Assert.areEqual(estimatedAncillaryRevenue, updateAssessment.Estimated_Ancillary_Revenue__c, 'Checking the Estimated_Ancillary_Revenue__c');
	}

	@isTest
	static void updateAncillaryToNoTest() {
		List<Business_Assessment__c> bAssessment = [SELECT Id FROM Business_Assessment__c];

        Test.startTest();
			update new Business_Assessment__c(
				Id = bAssessment.get(0).Id,
				Ancillary_Revenue__c = 'No',
				Commentary_about_the_ancillary_absence__c = 'Commentary about the ancillary absence'
			);
		Test.stopTest();

		Business_Assessment__c updateAssessment = [SELECT Id, Is_Completed_Ancillary_Business__c FROM Business_Assessment__c WHERE Id = :bAssessment.get(0).Id LIMIT 1];

		Assert.areEqual(true, updateAssessment.Is_Completed_Ancillary_Business__c, 'Checking the Is_Completed_Ancillary_Business__c');
	}
}