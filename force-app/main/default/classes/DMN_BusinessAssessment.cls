/*************************************************************************\
    @description Domain class for Business_Assessment__c object

    @ Last Modified By  :   Nikita Haruk
    @ Last Modified On  :   22/09/2023
    @ Last Modified Reason  : SFP-30063 - Added logic to calculate and verify ancillary business values.

  	@ Func Area     	:  IB
  	@ Author        	:  Wayne Solomon
  	@ Modified Date    	:  02 Mar 2020
  	@ User Story    	:  US-4492 -- DM NBAC: SPV New lightning component page layout added to existing JV Lightning record page
  	@ Description 	    :  As a SF user I want to view a lightning component page in order to complete a SPV NBAC.
  						   In this code I added or amended for methods to validate spv record and converted formula field
  						   validations into code through these methods.
  						   DMN_BusinessAssessment.updateTransactionCounterParties(assessment);
						   DMN_BusinessAssessment.updateClientDetails(assessment);
						   DMN_BusinessAssessment.updateBusinessSOW(assessment);
						   DMN_BusinessAssessment.updateFinancialAnalysis(assessment);
						   DMN_BusinessAssessment.updateTransactionParties(assessment);
						   Also fixed some spelling errors.
***/
@SuppressWarnings('PMD.CognitiveComplexity, PMD.ExcessivePublicCount, PMD.ExcessiveParameterList')
public with sharing class DMN_BusinessAssessment extends ABS_Sharing{

	private static Map<String, String> shareWalteDivision2field;
	private static Map<String, String> totalWalletDivision2field;
	private static Map<String, String> cyRevenueDivision2field;
	private static Map<String, String> pyRevenueDivision2field;
	static Id defaultRecTypeId;
	static Id nbacRecTypeId;
	static Id spvRecTypeId;
	static Id spvroRecTypeId;

	public static final String
		DELEGATED_AUTHORITY_DA1 		= 'DA1',
		DELEGATED_AUTHORITY_DA2 		= 'DA2',
		COMMITTEE_ANGOLA				= 'Angola NBAC',
		COMMITTEE_GLOBAL				= 'Global NBAC',
		COMMITTEE_LEVEL_LOCAL			= 'Local',
		COMMITTEE_LEVEL_GLOBAL			= 'Global',
		MILESTONE_SUPPORTED				= 'Supported',
		MILESTONE_SUBMITTED				= 'Submitted',
		MILESTONE_APPROVAL				= 'Approval',
		RT_BUSINESS_ASSESSMENT          = 'Business_Assessment',
		RT_NBAC_COMMB                   = 'NBAC_CommB',
        RT_NBAC                         = 'NBAC',
        RT_NBAC_READONLY                = 'NBAC_Read_Only',
		RT_NBAC_JOINT_VENTURE			= 'NBAC_Joint_Venture',
		RT_NBAC_JOINT_VENTURE_READONLY	= 'NBAC_Joint_Venture_READONLY',
        OBJ_NAME                        = 'Business_Assessment__c',
		COMMITTEE_REAL_ESTATE_REG		= 'Real Estate Regional NBAC',
		USER_INVESTMENT_BANK			= 'Investment Banking',
		USER_BUSINESS_UNIT				= 'Debt Products',
		USER_TEAM						= 'Real Estate Finance',
		CIBNBACSPVNOCIF                 = 'CibNbacSpvNoCif',
        CIBNBACSPVCIF                   = 'CibNbacSpvCif',
    	LOW                        	    = 'Low',
        COMPLETED                       = 'Completed';


	static {
		shareWalteDivision2field = new Map<String, String> ();
		shareWalteDivision2field.put(DMN_ShareWallet.DIVISION_GLOBAL_MARKETS, 'GM_Share_of_Wallet_Existing_SBG__c');
		shareWalteDivision2field.put(DMN_ShareWallet.DIVISION_INVESTMENT_BANKING, 'IB_Share_of_Wallet_Existing_SBG__c');
		shareWalteDivision2field.put(DMN_ShareWallet.DIVISION_TRANSACTIONAL_PRODUCTS_AND_SERVICES, 'TPS_Share_of_Wallet_Existing_SBG__c');

		totalWalletDivision2field = new Map<String, String> ();
		totalWalletDivision2field.put(DMN_ShareWallet.DIVISION_GLOBAL_MARKETS, 'GM_Share_of_Wallet_Existing_Total__c');
		totalWalletDivision2field.put(DMN_ShareWallet.DIVISION_INVESTMENT_BANKING, 'IB_Share_of_Wallet_Existing_Total__c');
		totalWalletDivision2field.put(DMN_ShareWallet.DIVISION_TRANSACTIONAL_PRODUCTS_AND_SERVICES, 'TPS_Share_of_Wallet_Existing_Total__c');

		cyRevenueDivision2field = new Map<String, String> ();
		cyRevenueDivision2field.put(DMN_GlobalClientRevenue.TRADING_DIVISION_GLOBAL_MARKET, 'Global_Markets_CY_Revenue__c');
		cyRevenueDivision2field.put(DMN_GlobalClientRevenue.TRADING_DIVISION_INVESTMENT_BANKING, 'Investment_Banking_CY_Revenue__c');
		cyRevenueDivision2field.put(DMN_GlobalClientRevenue.TRADING_DIVISION_RANSACTIONAL_PRODUCTS_AND_SERVICES, 'TPS_CY_Revenue__c');
		cyRevenueDivision2field.put(DMN_GlobalClientRevenue.TRADING_DIVISION_TPS_NEW, 'TPS_CY_Revenue__c');

		pyRevenueDivision2field = new Map<String, String> ();
		pyRevenueDivision2field.put(DMN_GlobalClientRevenue.TRADING_DIVISION_GLOBAL_MARKET, 'Global_Markets_PY_Revenue__c');
		pyRevenueDivision2field.put(DMN_GlobalClientRevenue.TRADING_DIVISION_INVESTMENT_BANKING, 'Investment_Banking_PY_Revenue__c');
		pyRevenueDivision2field.put(DMN_GlobalClientRevenue.TRADING_DIVISION_RANSACTIONAL_PRODUCTS_AND_SERVICES, 'TPS_PY_Revenue__c');
		pyRevenueDivision2field.put(DMN_GlobalClientRevenue.TRADING_DIVISION_TPS_NEW, 'TPS_PY_Revenue__c');

		defaultRecTypeId = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_BUSINESS_ASSESSMENT);
		nbacRecTypeId    = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_NBAC);
		spvRecTypeId     = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_NBAC_JOINT_VENTURE);
		spvroRecTypeId   = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_NBAC_JOINT_VENTURE_READONLY);
		

	}
	public static final String	SUBMISSION_TYPE_1 = 'Type 1: For noting purposes',
								SUBMISSION_TYPE_2 = 'Type 2: Emphasis on client strategy / returns',
								SUBMISSION_TYPE_3 = 'Type 3: Emphasis on risk / complexity',
								SUBMISSION_TYPE_4 = 'Type 4: Full discussion',
								CLIENT_COORDINATOR = 'CC',
								CLIENT_COORDINATOR_BM = 'CCBM',
								CREDIT_MANAGER = 'Credit Risk',
								NO_BUSINESS_ASSESSMENT_SPECIFIED = 'No Business Assessment specifed.',
								NO_OPPORTUNITY_SPECIFIED = 'No opportunities specified for Business Assessment.';

	/**
	 * @description Assign opportunities
	 *
	 * @param assessmentId
	 * @param opportunitiesIds
	 * @param uow
	 *
	 * @return Assessment_Opportunity__c[]
	 */
	public static Assessment_Opportunity__c[] assignOpportunities(Id assessmentId, Id[] opportunitiesIds, fflib_SObjectUnitOfWork uow) {
		Assessment_Opportunity__c[] results;

		if (String.isEmpty(assessmentId)) {
			throw new BusinessAssessmentException(NO_BUSINESS_ASSESSMENT_SPECIFIED);
		}

		if (opportunitiesIds==null || opportunitiesIds.isEmpty()) {
			throw new BusinessAssessmentException(NO_OPPORTUNITY_SPECIFIED);
		}

		results = new Assessment_Opportunity__c[] { };

		for (Id opportunityId : opportunitiesIds) {
			Assessment_Opportunity__c assessmentOpp = new Assessment_Opportunity__c();
			assessmentOpp.Business_Assessment__c = assessmentId;
			assessmentOpp.Opportunity__c = opportunityId;
			results.add(assessmentOpp);
			if (uow != null) {
				uow.registerNew(assessmentOpp);
			}
		}
		if (!results.isEmpty() && uow == null) {
			insert results;
		}

		return results;
	}

	/**
	 * @description Assign delegated approvers
	 *
	 * @param assessment
	 */
	public static void assignDelegatedApprovers(Business_Assessment__c assessment) {

		if (assessment != null) {
			assessment.Delegated_Authority__c = null;
			if (String.isEmpty(assessment.Economic_Group_Client_Risk_Rating__c)) {
				return;
			}
			if (assessment.Total_SB_Gross_Participation__c == null) {
				return;
			}
			
			Decimal notionalValue = assessment.Total_SB_Gross_Participation__c;
			DA_Lending_Limits__c daLimits = DA_Lending_Limits__c.getValues(assessment.Economic_Group_Client_Risk_Rating__c);

			if (daLimits == null) {
				return;
			}

			for (Integer approvalIndex = 1; approvalIndex <= 8; approvalIndex++) {
				String delegatedAuthority = 'DA' + approvalIndex;
				Decimal approvalMin = (Decimal) daLimits.get('Approval_Min_' + delegatedAuthority + '__c');
				Decimal approvalMax = (Decimal) daLimits.get('Approval_Max_' + delegatedAuthority + '__c');

				if (approvalMin <= notionalValue && (approvalMax == null || notionalValue <= approvalMax)) {
					assessment.Delegated_Authority__c = delegatedAuthority;
					break;
				}
			}
		}
	}

	/**
	 * @description Fetch related assessment opportunities
	 *
	 * @param businessAssessmentIds
	 *
	 * @return
	 */
	public static Map<Id, Assessment_Opportunity__c[]> fetchRelatedAssessmentOpportunities(Set<Id> businessAssessmentIds) {
		Assessment_Opportunity__c[] assessmentOpportunities = new Assessment_Opportunity__c[] { };
		Map<Id, Assessment_Opportunity__c[]> businessAssessmentId2AssessmentOpps = new Map<Id, Assessment_Opportunity__c[]>();
		if(businessAssessmentIds == null || businessAssessmentIds.isEmpty()) {
			return businessAssessmentId2AssessmentOpps;
		}
		assessmentOpportunities = [Select Id, Opportunity__c, Business_Assessment__c, Opportunity__r.CreatedBy.User_Team__c, 
									Opportunity__r.CreatedBy.Business_Unit__c, Opportunity__r.CreatedBy.User_Division__c 
									From Assessment_Opportunity__c Where Business_Assessment__c IN :businessAssessmentIds];
		for(Assessment_Opportunity__c assessmentOpp : assessmentOpportunities) {
			if(businessAssessmentId2AssessmentOpps.get(assessmentOpp.Business_Assessment__c) == null) {
                businessAssessmentId2AssessmentOpps.put(assessmentOpp.Business_Assessment__c, new Assessment_Opportunity__c[]{});
			}
            businessAssessmentId2AssessmentOpps.get(assessmentOpp.Business_Assessment__c).add(assessmentOpp);
		}
		return businessAssessmentId2AssessmentOpps;
	}

	/**
	 * @description Assign committee and level
	 *
	 * @param assessment
	 * @param assessmentOpps
	 */
	public static void assignCommitteeAndLevel(Business_Assessment__c assessment, Assessment_Opportunity__c[] assessmentOpps) {
		if (assessment != null) {
			String globalKey = assessment.Delegated_Authority__c;
			String regionalKey = assessment.Delegated_Authority__c + '' + assessment.Group_Parent_CIF_Reporting_Franco__c;
			String localKey = assessment.Delegated_Authority__c + '' + assessment.Group_Parent_CIF_Reporting_Franco__c;
			String committee;
			String committeeLevel;
			Boolean realEstateRegionalNBAC = false;
			if(NBAC_Committee_RegGlob_Map__c.getInstance(globalKey) != null && globalKey != null) {
				committee = NBAC_Committee_RegGlob_Map__c.getInstance(globalKey).Committee__c;
				committeeLevel = NBAC_Committee_RegGlob_Map__c.getInstance(globalKey).Committee_Level__c;
			}
			else if(NBAC_Committee_RegGlob_Map__c.getInstance(regionalKey) != null && regionalKey != null) {
				committee = NBAC_Committee_RegGlob_Map__c.getInstance(regionalKey).Committee__c;
				committeeLevel = NBAC_Committee_RegGlob_Map__c.getInstance(regionalKey).Committee_Level__c;
			}
			else if(NBAC_Committee_Local_Map__c.getInstance(localKey) != null && localKey != null) {
				committee = NBAC_Committee_Local_Map__c.getInstance(localKey).Committee__c;
				committeeLevel = NBAC_Committee_Local_Map__c.getInstance(localKey).Committee_Level__c;
			}
			if(committee != null) {
				assessment.NBAC_Committee__c = committee;
			}
			if(committeeLevel != null) {
				assessment.NBAC_Committee_Level__c = committeeLevel;
			}
			if(assessmentOpps != null) {
				for(Assessment_Opportunity__c assessmentOpp : assessmentOpps) {
					if(assessmentOpp.Opportunity__r.CreatedBy.User_Division__c == USER_INVESTMENT_BANK && 
						assessmentOpp.Opportunity__r.CreatedBy.Business_Unit__c == USER_BUSINESS_UNIT && 
						assessmentOpp.Opportunity__r.CreatedBy.User_Team__c == USER_TEAM) {
						realEstateRegionalNBAC = true;
					}
					else {
						realEstateRegionalNBAC = false;
						break;
					}
				}
			}
			if(realEstateRegionalNBAC) {
				assessment.NBAC_Committee__c = COMMITTEE_REAL_ESTATE_REG;
			}
		}
	}

	/**
	 * @description Set default values for Business Assessment
	 *
	 * @param assessments
	 */
	public static void setDefaults(Business_Assessment__c[] assessments) {
		
		if (assessments == null) {
			throw new BusinessAssessmentException('No Business Assessment specifed.');
		}


		Map<Id, Account> id2Account = new Map<Id, Account> ();
		Set<Id> economicGroupParentsIds = new Set<Id>();
		Map<Id,AggregateResult> clientId2CreditLimit;
		Map<String, Credit_Risk_Appetite__c> code2RiskAppetite = new Map<String, Credit_Risk_Appetite__c> ();
		String[] valuesForCode;

		for (Business_Assessment__c assessment : assessments) {
			if (!String.isBlank(assessment.Account__c)) {
				id2Account.put(assessment.Account__c, null);
				economicGroupParentsIds.add(assessment.Economic_Group_Parent_Client_Id__c);
			}

			valuesForCode = new String[]{assessment.Economic_Group_Client_Sector__c
													, assessment.Economic_Group_Client_Sub_Sector__c 
													, assessment.Economic_Group_Client_Country_of_Risk__c };

			code2RiskAppetite.put(UTL_Collections.generateCode(valuesForCode), null);

			valuesForCode[2] = DMN_Account.CTRY_OF_RISK_UNKNOWN;
			code2RiskAppetite.put(UTL_Collections.generateCode(valuesForCode), null);

		}

		if (!id2Account.isEmpty()) {
			Account[] accounts = (new DMN_BusinessAssessment_RevenueData()).getClientsWithRelatedData(id2Account.keySet(), shareWalteDivision2field, totalWalletDivision2field, cyRevenueDivision2field, pyRevenueDivision2field);
			AggregateResult[] creditLimits = getCreditLimitsInfo(economicGroupParentsIds);
			clientId2CreditLimit = new Map<Id,AggregateResult>(creditLimits);
			id2Account = new Map<Id, Account> (accounts);
		}

		if (!code2RiskAppetite.isEmpty()) {
			
			Credit_Risk_Appetite__c[] riskAppetites = getCreditRiskAppetites(code2RiskAppetite.keySet());
			for (Credit_Risk_Appetite__c riskAppetite : riskAppetites) {
				code2RiskAppetite.put(riskAppetite.Sub_Sector_Country_Code__c, riskAppetite);
			}
		}

		for (Business_Assessment__c assessment : assessments) {
			setCorporateCurrency(assessment);
			Account assessmentAccount = id2Account.get(assessment.Account__c);
			if (assessmentAccount!=null) {
				
				setDefaultCROC(assessment, assessmentAccount);
				setShareWalletValues(assessment, assessmentAccount);
				setRevenueValues(assessment, assessmentAccount);
				setLookups(assessment, assessmentAccount);
				setCreditLimit(assessment, assessmentAccount, clientId2CreditLimit);

			}

			valuesForCode = new String[]{assessment.Economic_Group_Client_Sector__c
													, assessment.Economic_Group_Client_Sub_Sector__c 
													, assessment.Economic_Group_Client_Country_of_Risk__c };

			Credit_Risk_Appetite__c riskAppetite = code2RiskAppetite.get(UTL_Collections.generateCode(valuesForCode));
			if (riskAppetite==null) {
				valuesForCode[2] = DMN_Account.CTRY_OF_RISK_UNKNOWN;
				riskAppetite = code2RiskAppetite.get(UTL_Collections.generateCode(valuesForCode));
			}

			setRiskAppetite(assessment, riskAppetite);
		}

	}

	private static void setCreditLimit(Business_Assessment__c assessment, Account assessmentAccount, Map<Id, AggregateResult> clientId2CreditLimit){
		if(assessment!=null && clientId2CreditLimit !=null && assessmentAccount!=null){
			Decimal totalcreditLimit = 0.0;

			AggregateResult creditInfo = clientId2CreditLimit.get(assessmentAccount.Id);
			if(creditInfo!=null){
				totalcreditLimit += (Decimal)creditInfo.get('creditLimit');
			}
			if(assessmentAccount.Accounts__r!=null){
				for(Account accountChild : assessmentAccount.Accounts__r){
					creditInfo = clientId2CreditLimit.get(accountChild.Id);
					if(creditInfo!=null){
						totalcreditLimit += (Decimal)creditInfo.get('creditLimit');
					}
				}
			}


			assessment.Economic_Group_Parent_Credit_Limits__c = totalcreditLimit;
		}

	}

	private static void setLookups(Business_Assessment__c assessment, Account assessmentAccount) {
		if(assessmentAccount.Custom_Client_Teams__r!=null){
			for(Custom_Client_Team__c teamMember : assessmentAccount.Custom_Client_Teams__r){
				if (teamMember.Client_Coordinator__c == true) {
					assessment.Group_Parent_CC__c =  teamMember.Team_Member__c;
				}
				if (teamMember.Client_Coordinator_BM__c == true) {
					assessment.Group_Parent_CCBM__c = teamMember.Team_Member__c;
				}
				if (teamMember.Client_Role__c == DMN_ClientTeam.CREDIT_MANAGER) {
					assessment.Credit_Manager__c = teamMember.Team_Member__c;
				}
			}
		}

	}

	private static void setRiskAppetite(Business_Assessment__c assessment, Credit_Risk_Appetite__c riskAppetite) {
		if (assessment == null || riskAppetite == null) {
			return;
		}

		assessment.Economic_Group_Risk_Appetite__c = riskAppetite.Sector_Credit_Appetite__c;
		assessment.Economic_Group_Sector_Risk_Appetite__c = riskAppetite.Country_Credit_Appetite__c;

	}

	private static void setDefaultCROC(Business_Assessment__c assessment, Account assessmentAccount) {
		
		if (assessmentAccount.Client_Capital_and_Revenue__r != null
		    && !assessmentAccount.Client_Capital_and_Revenue__r.isEmpty()) {
			assessment.YTD_Group_Parent_Client_CROC__c = assessmentAccount.Client_Capital_and_Revenue__r[0].CROC_ZAR__c;
		}
	}

	private static void setShareWalletValues(Business_Assessment__c assessment, Account assessmentAccount) {
		if (assessmentAccount.Share_of_Wallet__r != null
		    && !assessmentAccount.Share_of_Wallet__r.isEmpty()) {

			for (Share_Wallet__c shareWallet : assessmentAccount.Share_of_Wallet__r) {

				String assessmentField = shareWalteDivision2field.get(shareWallet.Division__c);
				Decimal fieldValue = (Decimal) assessment.get(assessmentField);
				fieldValue = fieldValue != null ? fieldValue : 0.0;
				Decimal shareWalletValue = (Decimal) shareWallet.Share_of_Wallet__c;
				shareWalletValue = shareWalletValue != null ? shareWalletValue : 0.0;
				assessment.put(assessmentField, fieldValue + shareWalletValue);

				assessmentField = totalWalletDivision2field.get(shareWallet.Division__c);
				fieldValue = (Decimal) assessment.get(assessmentField);
				fieldValue = fieldValue != null ? fieldValue : 0.0;
				shareWalletValue = (Decimal) shareWallet.Total_Wallet_Size__c;
				shareWalletValue = shareWalletValue != null ? shareWalletValue : 0.0;
				assessment.put(assessmentField, fieldValue + shareWalletValue);
			}

		}
	}

	private static void setRevenueValues(Business_Assessment__c assessment, Account assessmentAccount) {

		if (assessmentAccount.Global_Client_Revenue__r != null
		    && !assessmentAccount.Global_Client_Revenue__r.isEmpty()) {
			for (Global_Client_Revenue__c clientRevenue : assessmentAccount.Global_Client_Revenue__r) {
				String assessmentField = pyRevenueDivision2field.get(clientRevenue.Trading_Division__c);
				Decimal fieldValue = (Decimal) assessment.get(assessmentField);
				fieldValue = fieldValue != null ? fieldValue : 0.0;
				Decimal clientRevenueValue = (Decimal) clientRevenue.Client_Value_ZAR_Previous_Year__c;
				clientRevenueValue = clientRevenueValue != null ? clientRevenueValue : 0.0;
				assessment.put(assessmentField, fieldValue + clientRevenueValue);

				assessmentField = cyRevenueDivision2field.get(clientRevenue.Trading_Division__c);
				fieldValue = (Decimal) assessment.get(assessmentField);
				fieldValue = fieldValue != null ? fieldValue : 0.0;
				clientRevenueValue = (Decimal) clientRevenue.Client_Value_ZAR_Current_Year__c;
				clientRevenueValue = clientRevenueValue != null ? clientRevenueValue : 0.0;
				assessment.put(assessmentField, fieldValue + clientRevenueValue);
			}

		}
	}

	private static void clearRevenueValues(Business_Assessment__c assessment) {

		for(String cyRevenueField : cyRevenueDivision2field.values()) {
			assessment.put(cyRevenueField, 0.0);
		}

		for(String pyRevenueField : pyRevenueDivision2field.values()) {
			assessment.put(pyRevenueField, 0.0);
		}

	}

	private static Credit_Risk_Appetite__c[] getCreditRiskAppetites(Set<String> subSectorCodes) {
		Credit_Risk_Appetite__c[] results;
		if (subSectorCodes != null && !subSectorCodes.isEmpty()) {
			results = [SELECT Sub_Sector_Country_Code__c
			           , Sector_Credit_Appetite__c
			           , Country_Credit_Appetite__c
			           FROM Credit_Risk_Appetite__c
			           WHERE Sub_Sector_Country_Code__c IN :subSectorCodes];
		}
		
		return results;
	}

	private static AggregateResult[] getCreditLimitsInfo(Set<Id> clientsIds){
		AggregateResult[] results;
		
		if(!clientsIds.isEmpty()){
			results = StdBank_Ltn_ClientsStatisticsController.getCreditLineInfo(clientsIds,null,true);
		}

		return results;
	}

	private static void setCorporateCurrency(Business_Assessment__c assessment) {
		assessment.CurrencyISOCode = UTL_Currency.corporateIsoCode;
	}

	/**
	 * @description Update treasury and cap man milestone
	 *
	 * @param assessment
	 */
	public static void updateTreasuryAndCapManMilestone(Business_Assessment__c assessment) {
		assessment.Completed_Treasury_and_CapMan__c = String.isNotBlank(assessment.TCM_Details__c) && String.isNotBlank(assessment.TCM_Commentary__c);
	}

	/**
	 * @description Update distribution and risk man milestone
	 *
	 * @param assessment
	 */
	public static void updateDistributionAndRiskManMilestone(Business_Assessment__c assessment) {
		assessment.Completed_Distribution_And_RiskMan__c =
		assessment.Market_Deal_Size__c != null &&
		assessment.SB_Gross_Participation__c != null &&
		assessment.SB_Hold__c != null &&
		assessment.SB_Sell_Down__c != null &&
		String.isNotBlank(assessment.Bank_Role__c) &&
		String.isNotBlank(assessment.Transaction_Type__c) &&
		String.isNotBlank(assessment.Listed_Instruments__c) &&
		String.isNotBlank(assessment.Distribution_Price__c) &&
		String.isNotBlank(assessment.Distribution_Commentary__c) &&
		String.isNotBlank(assessment.Risk_Commentary__c);
	}

	/**
	 * @description Update compliance milestone
	 *
	 * @param assessment
	 */
	public static void updateComplianceMilestone(Business_Assessment__c assessment) {
		assessment.Completed_Compliance__c =
		String.isNotBlank(assessment.GCCR_Status__c) &&
		String.isNotBlank(assessment.KYC_Status__c) &&
		String.isNotBlank(assessment.EDD_PEP__c) &&
		String.isNotBlank(assessment.Sanctions__c);
	}

	/**
	 * @description Update environmental assessment milestone
	 *
	 * @param assessment
	 */
	public static void updateEnvironmentalAssessmentMilestone(Business_Assessment__c assessment){
	  assessment.Completed_Environmental_Assessment__c =
		(
            (
                String.isNotBlank(assessment.Transaction_Risk__c) &&
				String.isNotBlank(assessment.Client_Risk__c)
            )
            &&
            (
                (
                    assessment.Transaction_Risk__c == LOW &&
                    assessment.Client_Risk__c == LOW &&
                    assessment.ENS_status__c == MILESTONE_SUBMITTED
                ) 
                ||
                assessment.ENS_status__c == COMPLETED
            )
		);			
	}

	/**
	 * @description Update annexure description milestone
	 *
	 * @param assessment
	 */
	public static void updateAnnexureDescriptionMilestone(Business_Assessment__c assessment){
	  assessment.Completed_Annexure_Description__c = true;
	  if(assessment.Submission_Type__c == SUBMISSION_TYPE_3 || assessment.Submission_Type__c == SUBMISSION_TYPE_4){
		assessment.Completed_Annexure_Description__c = String.isNotBlank(assessment.Additional_Transaction_Description__c);
	  }		
	}

	/**
	 * @description Update annexure rationale milestone
	 *
	 * @param assessment
	 */
	public static void updateAnnexureRationaleMilestone(Business_Assessment__c assessment){
	  assessment.Completed_Annexure_Rationale__c = true;
	  if(assessment.Submission_Type__c == SUBMISSION_TYPE_2 || assessment.Submission_Type__c == SUBMISSION_TYPE_4){
		assessment.Completed_Annexure_Rationale__c = String.isNotBlank(assessment.Additional_Strategic_Rationale__c);
	  }		
	}

	/**
	 * @description Uptdate strategic rationale milestone
	 *
	 * @param assessment
	 */
	public static void updateStrategicRationaleMilestone(Business_Assessment__c assessment){
	  assessment.Completed_Strategic_Rationale__c = String.isNotBlank(assessment.Strategic_Rationale__c);
	}

	/**
	 * @description Update transaction profile milestone
	 *
	 * @param assessment
	 */
	public static void updateTransactionProfileMilestone(Business_Assessment__c assessment){
	  assessment.Completed_Transaction_Profile__c = String.isNotBlank(assessment.Transaction_Description__c);
	}

	/**
	 * @description Update transaction counter parties
	 *
	 * @param assessment
	 */
	public static void updateTransactionCounterParties(Business_Assessment__c assessment) {
		if (assessment.RecordTypeId == spvRecTypeId || assessment.RecordTypeId == spvroRecTypeId) {
			assessment.Completed_Transaction_Counterparties__c = (String.isNotBlank(assessment.Account__c) &&
					String.isNotBlank(assessment.Gearing_Metric__c) &&
					String.isNotBlank(assessment.Off_Taker__c) &&
					assessment.Max_Transaction_Gearing__c!=null &&
					String.isNotBlank(assessment.Nature_of_Business__c) &&
					String.isNotBlank(assessment.Export_Credit_Agency__c) &&
					assessment.Political_Risk_Cover__c!=null &&
					assessment.Commercial_Risk_Cover__c!=null &&
					(String.isNotBlank(assessment.Guarantor_Name__c) || (String.isNotBlank(assessment.Guarantor_Gearing_PostTransaction__c) && String.isNotBlank(assessment.Guarantor_Gearing_PreTransaction__c)))
			);
		} else {
			assessment.Completed_Transaction_Counterparties__c = (String.isNotBlank(assessment.Gearing_Metric__c) &&
					String.isNotBlank(assessment.Nature_of_Business__c) &&
					(String.isNotBlank(assessment.Guarantor_Name__c) || (String.isNotBlank(assessment.Guarantor_Gearing_PostTransaction__c) && String.isNotBlank(assessment.Guarantor_Gearing_PreTransaction__c)))
			);
		}
	}

	/**
	 * @description Update client details
	 *
	 * @param assessment
	 */
	public static void updateClientDetails(Business_Assessment__c assessment) {
		if(String.valueOf(assessment.RecordTypeId) == String.valueOf(spvRecTypeId) || String.valueOf(assessment.RecordTypeId) == (spvroRecTypeId)) {
			assessment.Completed_Client_Details_New__c = (String.isNotBlank(assessment.Client_Rating__c) &&
					String.isNotBlank(assessment.Construction_Risk_Grade__c) &&
					String.isNotBlank(assessment.Operations_Risk_Grade__c) &&
					String.isNotBlank(assessment.Client_Sector__c) &&
					String.isNotBlank(assessment.Economic_Group_Sector_Risk_Appetite__c) &&
					String.isNotBlank(assessment.Risk_Classification__c) &&
					String.isNotBlank(assessment.Complexity__c) &&
					String.isNotBlank(assessment.Decision_Emphasis__c) &&
					assessment.Construction_LGD__c!=null &&
					assessment.Operation_LGD__c!=null &&
					String.isNotBlank(assessment.Ultimate_Shareholders__c) &&
					String.isNotBlank(assessment.Sponsors__c));
		} else {
			assessment.Completed_Client_Details_New__c = (String.isNotBlank(assessment.Risk_Classification__c ) &&
					String.isNotBlank(assessment.Complexity__c) &&
					String.isNotBlank(assessment.Decision_Emphasis__c) &&
					assessment.Client_LGD__c!=null &&
					String.isNotBlank(assessment.Ultimate_Shareholders__c) &&
					String.isNotBlank(assessment.Group_Directors__c));
		}
	}

	/**
	 * @description Update Business Assessment SOW
	 *
	 * @param assessment - new version of a Business Assessment record
	 */
	public static void updateBusinessSOW(Business_Assessment__c assessment){
		assessment.Completed_Business_and_SOW_New__c = (
			assessment.GM_Share_of_Wallet_Existing_Total__c!=null &&
			assessment.GM_Share_of_Wallet_Existing_SBG__c!=null &&
			assessment.IB_Share_of_Wallet_Existing_Total__c!=null &&
			assessment.IB_Share_of_Wallet_Existing_SBG__c!=null &&
			assessment.TPS_Share_of_Wallet_Existing_Total__c!=null &&
			assessment.TPS_Share_of_Wallet_Existing_SBG__c!=null
		);
	}

	/**
     * @description Updates the updating Ancillary Business section
     *
     * @param assessment - new version of a Business Assessment record
     *
     */
	public static void updateAncillaryBusiness(Business_Assessment__c assessment) {
		assessment.Is_Completed_Ancillary_Business__c = (
			(
				String.valueOf(assessment.Ancillary_Revenue__c) == 'No' &&
				String.isNotBlank(assessment.Commentary_about_the_ancillary_absence__c)
			)
			||
			(
				String.valueOf(assessment.Ancillary_Revenue__c) == 'Yes' &&
				String.isNotBlank(assessment.Anticipated_Ancillary_Business_GM__c ) &&
				String.isNotBlank(assessment.Anticipated_Ancillary_Business_IB__c ) &&
				String.isNotBlank(assessment.Anticipated_Ancillary_Business_TPS__c ) &&
				assessment.Estimated_Ancillary_Revenue__c != null
			)
		);
	}

	/**
     * @description Calculates the Estimated Ancillary Revenue value for update Business Assessments
     *
     * @param businessAssessmentId2AssessmentOpps - the map of Assessment Opportunity records to business assessment Ids
     * @param businessAssessmentIdMap - new version of a Business Assessment record
     *
     */
	public static void updateEstimatedAncillaryRevenue(Map<Id, Assessment_Opportunity__c[]> businessAssessmentId2AssessmentOpps, Map<Id, Business_Assessment__c> businessAssessmentIdMap) {
		Set<Id> countedOppIds = new Set<Id>();
		Map<Id, Id> oppId2baId = new Map<Id, Id>();
		Map<Id, Decimal> baId2EstimatedRevenue = new Map<Id, Decimal>();

        if(!businessAssessmentIdMap.isEmpty()){
           for (Id baId : businessAssessmentIdMap.keySet()) {
               if(businessAssessmentId2AssessmentOpps.get(baId) != null ){
                for (Assessment_Opportunity__c tempOpp : businessAssessmentId2AssessmentOpps.get(baId)) {
                        oppId2baId.put(tempOpp.Opportunity__c, baId);
					}
               }
           }
 
        if(!oppId2baId.isEmpty()){
            for (SB_Product__c product : new SEL_Products().selectByOppParentIdsAndStages(
                oppId2baId.keySet(),
                new Set<String> { DMN_Opportunity.ST_LEAD, DMN_Opportunity.ST_DEVELOP, DMN_Opportunity.ST_CLOSED_WON }
            )) {
                if (!countedOppIds.contains(product.Opportunity__c)) {
                    if (baId2EstimatedRevenue.get(oppId2baId.get(product.Opportunity__r.Parent_Opportunity__c)) == null) {
                        baId2EstimatedRevenue.put(
                            oppId2baId.get(product.Opportunity__r.Parent_Opportunity__c),
                            product.Opportunity__r.Amount != null ? product.Opportunity__r.Amount : 0.0
                        );
                    } else {
                        baId2EstimatedRevenue.put(
                            oppId2baId.get(product.Opportunity__r.Parent_Opportunity__c),
                            baId2EstimatedRevenue.get(oppId2baId.get(product.Opportunity__r.Parent_Opportunity__c)) + product.Opportunity__r.Amount
                        );
                    }
    
                    countedOppIds.add(product.Opportunity__c);
                }
            }
        }

            for (Id baId : businessAssessmentIdMap.keySet()) {
                businessAssessmentIdMap.get(baId).Estimated_Ancillary_Revenue__c = baId2EstimatedRevenue.get(baId);
            } 
        }
	}

	/**
	 * @description Update financial analysis
	 *
	 * @param assessment
	 */
	public static void updateFinancialAnalysis(Business_Assessment__c assessment){
		assessment.Completed_Financial_Analysis_New__c = (assessment.Metric_Completed_Count__c > 0 &&
				assessment.Indicator_Completed_Count__c > 0);
	}

	/**
	 * @description Update transaction parties
	 *
	 * @param assessment
	 */
	public static void updateTransactionParties(Business_Assessment__c assessment){
		assessment.Completed_Transaction_Parties_New__c = (String.isNotBlank(assessment.Advisor__c ) &&
				String.isNotBlank(assessment.Mandated_Lead_Arranger__c ) &&
				String.isNotBlank(assessment.Other_Lenders__c ));
	}

	/**
	 * @description Generate final PDF for Business Assessment
	 *
	 * @param assessments
	 * @param id2OldAssessment
	 */
	public static void generateFinalPdf(Business_Assessment__c[] assessments, Map<Id, Business_Assessment__c> id2OldAssessment){
		Set<Id> assessmentIds = new Set<Id>();

		for(Business_Assessment__c ba : assessments){
			if(ba.Milestone__c == MILESTONE_SUPPORTED
			&& ba.RecordTypeId != UTL_RecordType.getRecordTypeId(DMN_BusinessAssessment.OBJ_NAME, DMN_BusinessAssessment.RT_NBAC_CommB)
				&& ba.Milestone__c != id2OldAssessment.get(ba.Id).Milestone__c){
				assessmentIds.add(ba.Id);
			}
		}
		if(!assessmentIds.isEmpty()){
			generateFinalPdf(assessmentIds);
		}
	}

	@Future(callout=true)
	private static void generateFinalPdf(Set<Id> assessmentIds) {
		generateBAFinalPdf(assessmentIds);
	}

	/**
	 * @param assessmentIds Set<Id>
	 *
	 * @return PageReference
	 * @description generateBAFinalPdf method
	 */
	public static PageReference generateBAFinalPdf(Set<Id> assessmentIds) {
		PageReference pdfPage;
		Set<Id> setOfConVers = new Set<Id>();
		List<ContentVersion> contentVersions = new List<ContentVersion>();
		List<ContentDocumentLink> contentDocumentLinksToInsert = new List<ContentDocumentLink>();
	
		for (Business_Assessment__c busAssm : [SELECT Id, Name, Account__r.Name, RecordType.DeveloperName, Milestone__c FROM Business_Assessment__c WHERE Id IN :assessmentIds]) {
			Boolean isSupported = (
				busAssm.Milestone__c == 'Supported' &&
				busAssm.RecordType.DeveloperName.contains(DMN_BusinessAssessment.RT_NBAC_JOINT_VENTURE) &&
				(
					FeatureManagement.checkPermission(CIBNBACSPVNOCIF) ||
					FeatureManagement.checkPermission(CIBNBACSPVCIF)
				)
			);
			String fileName = isSupported
				? 'NBAC Support Approved Form - ' + busAssm.Account__r.Name + ' - '+ date.today().format() +'.pdf'
				: 'NBAC Form - ' + busAssm.Account__r.Name + ' - '+ date.today().format() +'.pdf';
			pdfPage = new PageReference('/apex/NBAC_PDF?id=' + busAssm.Id); //create a page that references the NBAC PDF
			Blob pdfBlob;
			if (!Test.isRunningTest()) {
				pdfBlob = pdfPage.getContent();
			} else {
				pdfBlob = Blob.valueOf('Test');
			}
			contentVersions.add(new ContentVersion(Title = fileName, PathOnClient = fileName, VersionData = pdfBlob));
		}
		
		if (!contentVersions.isEmpty()) {
			Database.insert(contentVersions, false);
			for (ContentVersion contVers : contentVersions) {
				setOfConVers.add(contVers.Id);
			}
		}
		
		for (Id assessmentId : assessmentIds) {
			for (ContentVersion contVers : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN :setOfConVers]) {
				if (contVers.Id != null) {
					contentDocumentLinksToInsert.add(new ContentDocumentLink(
						ContentDocumentId = contVers.ContentDocumentId,
						LinkedEntityId = assessmentId,
						ShareType = 'I'
					));
				}
			}
		}
		
		Database.insert(contentDocumentLinksToInsert, false);

		return pdfPage;
	}

	/**
	 * @description Share Business Assessment with related opportunity team members
	 *
	 * @param assessmentID - Business Assessment Id
	 * @param opportunitiesIds - Ids of related opportunities
	 */
	public static void addRelatedOpportunityTeamUsers(Id assessmentID, List<Id> opportunitiesIds) {
		Sobject[] shares = new Sobject[]{};

		if (opportunitiesIds != null && !opportunitiesIds.isEmpty()) {
			OpportunityTeamMember[] oppTeam = [SELECT OpportunityId, UserId
												FROM OpportunityTeamMember
												WHERE OpportunityId IN :opportunitiesIds];

			Map<Id, Integer> oppMemIds = new Map<Id, Integer>();
			for(OpportunityTeamMember oppTeamMem : oppTeam) {
				if (oppMemIds.containsKey(oppTeamMem.UserId)) {
					oppMemIds.put(oppTeamMem.UserId, oppMemIds.get(oppTeamMem.UserId) + 1);
				} else {
					oppMemIds.put(oppTeamMem.UserId, 1);
				}
			}

			for (Id key : oppMemIds.keySet()) {
				if(oppMemIds.get(key) == opportunitiesIds.size()) {
					Business_Assessment__share share = new Business_Assessment__share(ParentId  = assessmentID,
															UserOrGroupId = key,
															AccessLevel = 'Edit',
															RowCause = 'Manual');
					shares.add(share);
				}
			}			
		}

		if(!shares.isEmpty()){
			UTL_DmlResult.GenericResult[] shareDmlREsults = new UTL_DmlResult.GenericResult[]{};
			shareDmlREsults.addAll(UTL_DmlResult.insertRecords(shares, false, false));
		}
    }

	/**
	 * @description Update revenues and croc data of Business Assessments
	 *
	 * @param bAssessments2Update - Business Assessments to update
	 *
	 * @return List<Business_Assessment__c>
	 */
	public static List<Business_Assessment__c> updateRevenueAndCrocData(List<Business_Assessment__c> bAssessments2Update) {

		Set<Id> clientIds = new Set<Id>();

		for(Business_Assessment__c assessment : bAssessments2Update) {
			if(assessment.Account__c != null) {
				clientIds.add(assessment.Account__c);
			}
		}
		Account[] accounts = (new DMN_BusinessAssessment_RevenueData()).getClientsWithRelatedData(clientIds, shareWalteDivision2field, totalWalletDivision2field, cyRevenueDivision2field, pyRevenueDivision2field);
		Map<Id, Account> id2Account = new Map<Id, Account>(accounts);
		for(Business_Assessment__c assessment : bAssessments2Update) {
			setDefaultCROC(assessment, id2Account.get(assessment.Account__c));
			clearRevenueValues(assessment);
			setRevenueValues(assessment, id2Account.get(assessment.Account__c));
		}

		return bAssessments2Update;
	}

	/**
	 * @description Update entities risk rating for Business Assessments
	 *
	 * @param ids - ids of Business Assessments to update
	 */
	public static void updateEntitiesRiskRating(Set<Id> ids) {

        List<Business_Assessment__c> businessAssessments = retrieveBAssessments(ids);

		for(Business_Assessment__c bAssessment : businessAssessments) {
			List<String> entityRiskRating = new List<String>();
            Set<Id> accountIds = new Set<Id>();
			for(Assessment_Opportunity__c aOpportunity : bAssessment.Assessment_Opportunities__r) {
                if(!accountIds.contains(aOpportunity.Opportunity__r.AccountId)) {
                    entityRiskRating.add(aOpportunity.Opportunity__r.Account.Name + ', ' + aOpportunity.Opportunity__r.Account.Internal_Credit_Rating__c);
                    accountIds.add(aOpportunity.Opportunity__r.AccountId);
                }

			}

			bAssessment.Entities_Risk_Rating__c = String.join(entityRiskRating, '\n');
		}

		if(businessAssessments != null && !businessAssessments.isEmpty()) {
			update businessAssessments;
		}

	}

	private static List<Business_Assessment__c> retrieveBAssessments(Set<Id> ids) {
		String query =  ' SELECT Id, (SELECT Opportunity__r.AccountId, Opportunity__r.Account.Name, Opportunity__r.Account.Internal_Credit_Rating__c FROM Assessment_Opportunities__r) ' +
				' FROM Business_Assessment__c ' +
				' WHERE Id IN (SELECT Business_Assessment__c FROM Assessment_Opportunity__c WHERE ';

		String objType = String.valueOf( new List<Id> (ids)[0].getSobjectType());

		String whereClause = (objType == 'Opportunity') ? ' Opportunity__c ' : ((objType == 'Account') ? ' Opportunity__r.AccountId ' : ' Id ' );

		query += whereClause + ' IN :ids) ';

		return Database.query(query);
	}

	/**
	 * @description Custom exception to use for errors related to BusinessAssessment object
	 */
	public class BusinessAssessmentException extends Exception { }

	/**
	 * @description Wrapper class for enforcing without sharing when quering revenue data
	 */
	public without sharing class DMN_BusinessAssessment_RevenueData {

		/**
		 * @description Get clients with related data
		 *
		 * @param clientsIds
		 * @param shareWalteDivision2field
		 * @param totalWalletDivision2field
		 * @param cyRevenueDivision2field
		 * @param pyRevenueDivision2field
		 *
		 * @return Account[]
		 */
		public Account[] getClientsWithRelatedData(Set<Id> clientsIds, Map<String, String> shareWalteDivision2field, Map<String, String> totalWalletDivision2field, Map<String, String> cyRevenueDivision2field, Map<String, String> pyRevenueDivision2field) {
			Account[] results;

			if (clientsIds != null && !clientsIds.isEmpty()) {
				Integer currentYear = System.today().year();
				Set<String> shareWalletDivisions = new Set<String> ();
				shareWalletDivisions.addAll(shareWalteDivision2field.keySet());
				shareWalletDivisions.addAll(totalWalletDivision2field.keySet());

				Set<String> revenueDivisions = new Set<String> ();
				revenueDivisions.addAll(cyRevenueDivision2field.keySet());
				revenueDivisions.addAll(pyRevenueDivision2field.keySet());

				results = [SELECT Id, Economic_Group_Parent_Id__c, Economic_Group_Parent_Client_Name__c
						, (SELECT Id , CROC_ZAR__c
							FROM Client_Capital_and_Revenue__r
							LIMIT 1)
						, (SELECT Trading_Division__c, Client_Value_ZAR_Current_Year__c, Client_Value_ZAR_Previous_Year__c
							FROM Global_Client_Revenue__r
							WHERE RecordType.DeveloperName = :DMN_GlobalClientRevenue.RTD_CURRENT_PREVIOUS_YEAR
								AND Trading_Division__c IN :revenueDivisions)
						, (SELECT Division__c, Share_of_Wallet__c, Total_Wallet_Size__c
							FROM Share_of_Wallet__r
							WHERE Financial_Year__c = :String.valueOf(currentYear)
								AND Division__c IN :shareWalletDivisions)
							, (SELECT Id, Client_Coordinator__c, Client_Coordinator_BM__c
										, Account__r.Id, Client_Role__c, Team_Member__c
								FROM Custom_Client_Teams__r
								WHERE Client_Coordinator__c=true OR Client_Coordinator_BM__c=true OR Client_Role__c = :DMN_ClientTeam.CREDIT_MANAGER)
							, (SELECT Id
								FROM Accounts__r)
						FROM Account
						WHERE Id in :clientsIds];
			}

			return results;
		}
	}


	/**
     * @description Checks if support has been received for the Business Assessment record
     *
     * @param assessment - Business Assessment record
     *
     * @return Boolean - has support been received for the Business Assessment record
     */
	public static Boolean isSupportReceived(Business_Assessment__c assessment) {
		return (assessment.Milestone__c == DMN_BusinessAssessment.MILESTONE_SUBMITTED ||
				assessment.Milestone__c == DMN_BusinessAssessment.MILESTONE_SUPPORTED ||
				assessment.Milestone__c == DMN_BusinessAssessment.MILESTONE_APPROVAL);
	}

	/**
     * @description Populates the Link_to_ENS__c field for the Business Assessment record
     *
     * @param assessment - new version of a Business Assessment record
     * @param oldRecord - old version of a Business Assessment record
     *
     */
	public static void setDefaultLinkToEnS(Business_Assessment__c assessment, Business_Assessment__c oldRecord) {
		Boolean isLinkNeeded = (
			assessment.RecordTypeId != oldRecord.RecordTypeId &&
			oldRecord.RecordTypeId  == defaultRecTypeId &&
			assessment.RecordTypeId == nbacRecTypeId
		);

		if (isLinkNeeded) {
			assessment.Link_to_ENS__c = ENS_Integration_Info__c.getInstance()?.Default_Link_To_ENS__c;
		}
	}

	/**
     * @description Prevents the updating EnS field to null values for the Business Assessment record
     *
     * @param assessment - new version of a Business Assessment record
     * @param oldRecord - old version of a Business Assessment record
     *
     */
	public static void preventUpdatingEnSFieldToNull(Business_Assessment__c assessment, Business_Assessment__c oldRecord) {
		assessment.ENS_status__c = String.isBlank(assessment.ENS_status__c) && String.isNotBlank(oldRecord.ENS_status__c)
			? oldRecord.ENS_status__c
			: assessment.ENS_status__c;
		assessment.Link_to_ENS__c = String.isBlank(assessment.Link_to_ENS__c) && String.isNotBlank(oldRecord.Link_to_ENS__c)
			? oldRecord.Link_to_ENS__c
			: assessment.Link_to_ENS__c;
		assessment.Client_Risk__c = String.isBlank(assessment.Client_Risk__c) && String.isNotBlank(oldRecord.Client_Risk__c)
			? oldRecord.Client_Risk__c
			: assessment.Client_Risk__c;
		assessment.Transaction_Risk__c = String.isBlank(assessment.Transaction_Risk__c) && String.isNotBlank(oldRecord.Transaction_Risk__c)
			? oldRecord.Transaction_Risk__c
			: assessment.Transaction_Risk__c;
	}
}