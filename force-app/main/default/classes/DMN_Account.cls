/**
* Domain layer class for Account SObject
*
* @author Unknown
* @date Unknown
*****************************************************************************************
*   @ Last Modified By  :   Maham Hassan
*   @ Last Modified On  :   15/03/2022
*   @ Last Modified Reason  : Added Calculate Record Completeness actions on insert
*                             and update. It calculates score for record completeness.
*   @ Last Modified By  :   Derek Hughes
*   @ Last Modified On  :   03/06/2022
*   @ Last Modified Reason  : Suppress record completeness calculations for bulk operations
**
*****************************************************************************************
*/
@SuppressWarnings('PMD.ExcessiveClassLength, PMD.CognitiveComplexity, PMD.ExcessivePublicCount')
public inherited sharing class DMN_Account {

    public static final String 	OBJ_NAME 								= 'Account',
						 		RT_COMMB 								= 'Commercial_Banking_Client',
								RT_COMMB_INDIVIDUAL_CLIENT              = 'Commercial_Banking_Individual_Client',
							 	RT_POTENTIAL_CLIENT 					= 'Potential_Client',
							 	RT_POTENTIAL_CIF 						= 'Potential_CIF',
							 	RT_POTENTIAL_GOLDTIER  					= 'Potential_Goldtier',
								RT_LOCKED_POTENTIAL_GOLDTIER 			= 'Locked_Potential_Goldtier',
								RT_LOCKED_POTENTIAL_CIF 				= 'Locked_Potential_CIF',
							 	RT_PROSPECT		 						= 'Prospect',
							 	RT_ULTIMATE_PARENT						= 'TopParent',
							 	RT_IMMEDIATE_PARENT						= 'Immediate_Parent',
								RT_CHILD                                = 'Child',
                                RT_ONBOARDED_PARTNER                    = 'Onboarded_Partner',
       						    RT_PROSPECT_PARTNER                     = 'Prospect_Partner',
                                RT_PERSONAL_BUSINESS_BANKING_CLIENT     = 'Personal_Business_Banking_Client',
                                RT_INACTIVE                             = 'Inactive',
							 	HOLDER_COMMB 							= 'Commercial Banking',
							 	CRT_PC_TP 							    = 'TP',
								CTRY_OF_RISK                            = 'Albania',
                                CTRY_OF_RISK_UNKNOWN                    = 'Unknown',
                                SEC_CUSTOMER							= 'Consumer',
								SEC_FINANTIAL_INSTITUTIONS				= 'Financial Institutions',
								SEC_MINING_N_METALS						= 'Mining and Metals',
								SEC_OIL_N_GAS							= 'Oil and Gas',
								SEC_POWER_N_INFRASTRUCTURE				= 'Power and Infrastructure',
								SEC_TELECOMS_N_MEDIA					= 'Telecoms and Media',
								SUB_SEC_ALTERNATIVE_INVESTMENT_VEHICLES = 'Alternative Investment Vehicles',
								SUB_SEC_ASSET_MANAGERS					= 'Asset Managers',
								SUB_SEC_BROKERS_N_EXCHANGES				= 'Brokers and Exchanges',
								SUB_SEC_INSURANCE						= 'Insurance',
                                SUB_SEC_AGRICULTURE                     = 'Agriculture',
                                SUB_SEC_NICHE_FINANCE_COMPANIES         = 'Niche Finance Companies',
                                SUB_SEC_PENSION_N_REGULATED_FUNDS       = 'Pension and Regulated Funds',
                                FAIS_STATUS_IMPACTED                    = 'FAIS Impacted',
                                CIF_C_TYPE                              = 'R',
                                REL_HIERARCHY_ULTIMATE                  = 'Group Parent',
                                REL_HIERARCHY_IMMEDIATE                 = 'Immediate Parent',
                                REL_HIERARCHY_CHILD                     = 'Child',
                                COMMB_CIB_GA                            = 'BCC',
                                PRIMARY_REL_HOLDER_COMMB                = 'Commercial Banking',
                                PRIMARY_REL_HOLDER_PERSONAL             = 'Personal Banking',
                                PRIMARY_REL_HOLDER_BUSINESS             = 'Business Banking',
                                PRIMARY_REL_HOLDER_CIB                  = 'Corporate and Investment Banking',
                                MARKET_SEGMENT_LIFESTYLE                = '400 - Lifestyle',
                                MISSING_ISIC_CODE                       = 'Missing CIF ISIC code',
                                MISSING_ISIC_MAPPING                    = 'Missing ISIC mapping',
                                NO_DETAILS                              = 'No details provided',
                                NO_ACTIVE_USER_IN_SF                    = 'Active User not found in Salesforce',
                                MULTIPLE_MATCHING_USERS                 = 'There are more than one user with this name',
                                CC_DIV_CLIENT_COVERAGE                  = 'Client Coverage',
                                CC_DIV_COMMERCIAL_BANKING               = 'Commercial Banking',
                                CC_DIV_BUSINESS_BANKING                 = 'Business Banking',
                                CC_DIV_ENTREPRENEUR                 	= 'Entrepreneur',
                                UNKNOWN_SECTOR                          = 'Unknown Sector',
                                UNKNOWN_SUB_SECTOR                      = 'Unknown Sub-Sector',
                                STANDARD_BANK_EMPLOYEES                 = 'Standard Bank Employees',
                                RISK_RATING_D1                          = 'D1',
                                RISK_RATING_D2                          = 'D2',
                                FRANCO_ANGOLA                           = 'Angola',
                                CC_DIVISION_COMMB                       = 'Commercial Banking',
                                CLIENT_TYPE_R                           = 'R',
                                REL_ROLE_CLIENT                         = 'Client',
                                REL_ROLE_CORRESPONDING_BANK             = 'Corresponding Bank',
                                REL_ROLE_MANAGED_FUND                   = 'Managed Fund',
                                REL_ROLE_EXCHANGE                       = 'Exchange',
                                DEFAULT_COMMB_KYC_LOCATION              = 'SBSA - Standard Bank of South Africa Ltd',
                                KYC_LOCATION_SBSA                       = 'SBSA - Standard Bank of South Africa Ltd',
                                KYC_LOCATION_SBMU                       = 'SBMU - Standard Bank (Mauritius) Ltd',
                                KYC_LOCATION_SBLS                       = 'SBLS - Standard Lesotho Bank Ltd',
                                KYC_LOCATION_SBCD                       = 'SBCD - Stanbic Bank Congo SARL',
                                KYC_LOCATION_SBCI                       = 'SBCI - Standard Bank Cote D\'Ivoire SA',
                                GT_REQ_CODE_PREFIX                      = 'GT_REQ_CODE_',
                                PT_STEPS_SUBMIT_FOR_ONBOARDING          = 'Submit for On-Boarding',
                                PT_STEPS_DEVELOP_PROSPECT               = 'Develop Prospect',
                                PT_STEPS_CREATE_PROSPECT                = 'Create Prospect',
                                STATUS_SUBMITTED_FOR_ONB                = 'Submitted for Onboarding',
                                CST_STANDARD                            = 'Standard',
                                CST_HIGH_TOUCH                          = 'High Touch',
                                CST_PREMIUM                             = 'Premium',
                                RELATIONSHIP_GROUP_NUMBER_NOTIFICATION  = 'Relationship_Group_Number_Notification',
                                CLIENT_STATUS_CLOSED                    = 'Closed',
                                ENTERPRISE_AFRICA_TYPE 					= 'Enterprise Banking Africa Regions',
                                COMMERCIAL_AFRICA_TYPE                  = 'Commercial Banking Africa Regions';

    
	public final static Set<String> BUSINESS_BANKING_MARKET_SEG = new Set<String>{
        	'552 - Business',
            '401 - Entrepreneur',
            '420 - Agric Small (Entrepreneur)',
            '421 - Agric Medium',
            '422 - Agric Large',
            '429 - Agric BEE (Business)'
                
	};
	public final static Set<String> NON_CIB_PRH = new Set<String>{
			'Commercial Banking',
			'Commercial Banking',
			'Personal Banking',
			'Business Banking',
			'Other PBB Divisions'
	};


    /**
    * Method to update GP, IP and PCC based on hierarchy level
    *
    * @param accounts List of updated Account records.
    */
	public static void updateGpIpAndPcc(Account[] accounts) {
        Set<Id> parentIds = new Set<Id>();

        for (Account acc : accounts) {
			if (acc.ParentId != null) {
				parentIds.add(acc.ParentId);
			}
        }
		Map<Id, Account> ancestors = getAncestors(parentIds);

		for (Account acc : accounts) {


			if (acc.RecordTypeId != null && UTL_RecordType.getRecordTypeName(OBJ_NAME, acc.RecordTypeId).contains('Potential')) {

				Account parent = ancestors.get(acc.ParentId);
				Account grandParent = ancestors.get(acc.ParentId) == null ? null : ancestors.get(acc.ParentId).Parent;

				if (isRelationshipHierarchyNull(acc)) { //  Relationship Hierarchy = None?
					acc.CIF_Number_of_Proposed_Group_Parent__c = null;
					acc.CIF__c = null;
					acc.GP_IP_PPC_Are_Changed__c = String.valueOf(Datetime.now());
					acc.Proposed_Group_Parent__c = null;
					acc.Proposed_Group_Parent_CC__c = null;
					acc.Proposed_Immediate_Parent__c = null;
					acc.Proposed_Parent_Client__c = null;
				}

				if (isGroupParent1Level(acc)) {
					acc.CIF_Number_of_Proposed_Group_Parent__c = acc.CIF__c;
					acc.CIF_Number_of_Proposed_Immediate_Parent__c = acc.CIF__c;
					acc.GP_IP_PPC_Are_Changed__c = String.valueOf(Datetime.now());
					acc.Proposed_Group_Parent__c = acc.Name;
					acc.Proposed_Group_Parent_CC__c = acc.OwnerId;
					acc.Proposed_Immediate_Parent__c = acc.Name;
					acc.Proposed_Parent_Client__c = acc.Name;
				}

				if (parent != null && isImmediateParentOrChild2Level(acc, parent)) {
					acc.CIF_Number_of_Proposed_Group_Parent__c = parent.CIF__c;
					acc.GP_IP_PPC_Are_Changed__c = String.valueOf(Datetime.now());
					acc.Proposed_Group_Parent__c = parent.Name;
					acc.Proposed_Group_Parent_CC__c = parent.OwnerId;
					acc.Proposed_Parent_Client__c = parent.Name;

					if (REL_HIERARCHY_IMMEDIATE.equals(acc.Client_Relationship_Hierarchy__c)) {
						acc.CIF_Number_of_Proposed_Immediate_Parent__c = acc.CIF__c;
						acc.Proposed_Immediate_Parent__c = acc.Name;
					} else {  // client relationship hierarchy is child
						acc.CIF_Number_of_Proposed_Immediate_Parent__c = parent.CIF__c;
						acc.Proposed_Immediate_Parent__c = parent.Name;
					}
				}

				if (parent != null && grandParent != null && isChild3Level(acc, parent, grandParent)) {
					acc.CIF_Number_of_Proposed_Group_Parent__c = grandParent.CIF__c;
					acc.CIF_Number_of_Proposed_Immediate_Parent__c = parent.CIF__c;
					acc.GP_IP_PPC_Are_Changed__c = String.valueOf(Datetime.now());
					acc.Proposed_Group_Parent__c = grandParent.Name;
					acc.Proposed_Group_Parent_CC__c = grandParent.OwnerId;
					acc.Proposed_Immediate_Parent__c = parent.Name;
					acc.Proposed_Parent_Client__c = parent.Name;
				}
			}
		}
	}

    /**
    * Method to update path step and record type after validation
    *
    * @param accounts List of updated Account records.
    */
	public static void updatePathStepAndRecordType(Account[] accounts) {
		for (Account acc : accounts) {
			if (acc.Update_Path__c) {

				if (isProspectValid(acc)) {    // Move to Develop Prospect
					acc.Path_Steps__c = PT_STEPS_DEVELOP_PROSPECT;
					acc.RecordTypeId = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_POTENTIAL_CLIENT);
					acc.Update_Path__c = false;
				}

				if (isDevelopValidGT(acc)) {    // Move to GT
					acc.Path_Steps__c = PT_STEPS_SUBMIT_FOR_ONBOARDING;
					acc.RecordTypeId = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_POTENTIAL_GOLDTIER);
					acc.Update_Path__c = false;
				}

				if (isDevelopValidCIF(acc)) {    // Move to CIF
					acc.Path_Steps__c = PT_STEPS_SUBMIT_FOR_ONBOARDING;
					acc.RecordTypeId = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_POTENTIAL_CIF);
					acc.Update_Path__c = false;
				}

				if (isDevelopValidLockedGT(acc)) {    // Lock GT
					acc.RecordTypeId = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_LOCKED_POTENTIAL_GOLDTIER);
					acc.Update_Path__c = false;
				}

				if (isDevelopValidLockedCIF(acc)) {    // Lock CIF
					acc.RecordTypeId = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_LOCKED_POTENTIAL_CIF);
					acc.Update_Path__c = false;
				}
			}
		}
	}

    /**
    * Method to update account owner and industry based on CC and Sector
    *
    * @param accounts List of updated Account records.
    * @param id2OldAccount Map of Id to Account of records before update
    */
	public static void adjustData(Account[] accounts, Map<Id, Account> id2OldAccount){
		for (Account acc : accounts) {
			Account oldAcc = id2OldAccount == null ? null : id2OldAccount.get(acc.Id);
 
			if(acc.cif__c == null 
				&& ((acc.Client_Co_ordinator__c != null
					&& oldAcc == null)
					|| (oldAcc != null
						&& acc.Client_Co_ordinator__c != oldAcc.Client_Co_ordinator__c))){
               	acc.ownerid = acc.Client_Co_ordinator__c ;
          	}  
          	if (String.isNotBlank(acc.Client_Sector__c) 
          		&& (oldAcc == null
          			|| (oldAcc != null
          				&& acc.Client_Sector__c != oldAcc.Client_Sector__c))){
              	acc.Industry = acc.Client_Sector__c;
          	}
		}
	}
    /**
    * Method to validate account records
    *
    * @param accounts List of inserted Account records.
    */
    public static void validateOnInsert(Account[] accounts){
        Set<String> ownerLst = new Set<String>();
      for (Account acct: accounts) {
            ownerLst.add(acct.Client_Coordinator_from_CDG__c);
        }
        ownerLst.remove(null);
        List<User> usrList = new List<User>();
        if (!ownerLst.isEmpty()) {
            usrList = [
                SELECT Name,
                    Profile.Name
                FROM User
                WHERE Name IN :ownerLst
                    AND IsActive = TRUE
            ];
        }

        Map<string, User> usrMap = new Map<string, User>();
        for(User u : usrList){
            usrMap.put(u.Name.toUpperCase(), u);
        }

    	Account[] invalidAccounts = new Account[]{};
        for (Account acc: accounts) {

        	Set<String> recordTypeSet = new Set<String>(new String[]{
                                                 UTL_RecordType.getRecordTypeId('Account', RT_ULTIMATE_PARENT)
                                                ,UTL_RecordType.getRecordTypeId('Account', RT_IMMEDIATE_PARENT)
                                                ,UTL_RecordType.getRecordTypeId('Account', RT_CHILD)
                                                ,UTL_RecordType.getRecordTypeId('Account', RT_PERSONAL_BUSINESS_BANKING_CLIENT)
                                                ,UTL_RecordType.getRecordTypeId('Account', RT_INACTIVE)});

            if(recordTypeSet.contains(acc.RecordTypeId)){   
                acc.Client_Sector__c        = UNKNOWN_SECTOR; 
                acc.Client_Sub_Sector__c    = UNKNOWN_SUB_SECTOR;
            }

        	if(UserInfo.getProfileId() == UTL_CustomSetting.getApiUserProfileId()){
	        	if(acc.CIF_Client_Type__c == CIF_C_TYPE ){
	              	acc.OwnerId  = UTL_CustomSetting.getPbbUserId(); 
	          }
            else if(String.isBlank(acc.Client_Coordinator_from_CDG__c)){
		          acc.To_Delete__c = true; 
              invalidAccounts.add(acc);
		      	}
            else if(!usrMap.containsKey(acc.Client_Coordinator_from_CDG__c.toUpperCase())){
              acc.To_Delete__c = true; 
              invalidAccounts.add(acc);               
            }
		      	else{ 
	               	acc.Without_SF_Id__c = true; 
	         	}
	       	}
        }

        if(!invalidAccounts.isEmpty()){ 
        	//SRV_Email.sendRejectionCifClient(invalidAccounts); 
        	DMN_Case.createCifReject(invalidAccounts);
        }
    }

    /**
    * Method to update Biling Country based on custom settings
    *
    * @param accounts List of inserted Account records.
    */
    public static void setCountryName(Account[] accounts){
    	for(Account acc : accounts){
    		if(String.isNotBlank(acc.CIF__c) && String.isNotBlank(acc.BillingCountry)){
    			CountrySettings__c cs = CountrySettings__c.getInstance(acc.BillingCountry.toUpperCase());
    			if(cs != null){
    				acc.BillingCountry = cs.Name.toUpperCase();
    			}
    		}
    	}
    }

    /**
    * Method to update sector and sub sector based on industry code
    *
    * @param accounts List of updated Account records.
    * @param id2Account Map of Id to Account of records before update
    */
    public static void populateFieldsBasingOnIndustryCode(Account[] accounts, Map<Id, Account> id2Account){
    	Account[] accountsToProcess = new Account[]{};
    	Set<String> codes = new Set<String>();

    	for(Account acc : accounts){
			Account oldAcc = id2Account == null ? null : id2Account.get(acc.Id);

			if (oldAcc != null && oldAcc.Primary_Relationship_Holder__c == PRIMARY_REL_HOLDER_COMMB
					&& (acc.Primary_Relationship_Holder__c == PRIMARY_REL_HOLDER_BUSINESS
						|| acc.Primary_Relationship_Holder__c == PRIMARY_REL_HOLDER_PERSONAL)) {
				acc.Client_Sector__c = UNKNOWN_SECTOR;
				acc.Client_Sub_Sector__c = UNKNOWN_SUB_SECTOR;
			}

    		if(String.isNotBlank(acc.Industry_Code__c)){
    			if (oldAcc == null
						|| acc.Industry_Code__c != oldAcc.Industry_Code__c
						|| (isCommBClient(acc) && !isCommBClient(oldAcc))){
    				accountsToProcess.add(acc);
    				codes.add(acc.Industry_Code__c);
    			}
    		}
    		else{
    			acc.SA_Industry_Description__c = MISSING_ISIC_CODE;
    		}
    	}

    	if(codes.isEmpty()){
    		return;
    	}

        Map<String, ISIC_Mapping_Client_Sector__c> indCode2ClientSectorMapping = ISIC_Mapping_Client_Sector__c.getAll();

        for (Account acc : accountsToProcess) {
            if (indCode2ClientSectorMapping.containsKey(acc.Industry_Code__c)) {
                acc.SA_Industry_Description__c = indCode2ClientSectorMapping.get(acc.Industry_Code__c).CIF_ISIC_Description__c;
            } else {
                acc.SA_Industry_Description__c = MISSING_ISIC_MAPPING;
            }

            if (isCommBClient(acc)) {
                ISIC_Mapping_Client_Sector__c clientSectorMapping = indCode2ClientSectorMapping.get(acc.Industry_Code__c);
                if (clientSectorMapping != null) {
                    acc.Client_Sector__c = acc.Client_Sector__c == UNKNOWN_SECTOR ?
                            clientSectorMapping.Client_Sector__c : acc.Client_Sector__c;
                    acc.Client_Sub_Sector__c = acc.Client_Sub_Sector__c == UNKNOWN_SUB_SECTOR ?
                            clientSectorMapping.Client_Sub_Sector__c : acc.Client_Sub_Sector__c;
                }
            }
        }
    }
	@TestVisible
    private static Boolean isCommBClient(Account acc) {
        return (acc.Client_Coordinator_Division__c == CC_DIVISION_COMMB)
                && String.isNotBlank(acc.CIF__c)
                && acc.Primary_Relationship_Holder__c == PRIMARY_REL_HOLDER_COMMB
                && acc.CIF_Client_Type__c == CLIENT_TYPE_R;
    }

    /**
    * Method to validate accounts and check for CDG errors
    *
    * @param accounts List of inserted Account records.
    */
    public static void checkCdgError(Account[] accounts) {
        Account[] accountsToProcess = new Account[]{
        };
        Map<String, String> accName2CdgUserName = new Map<String, String>();

        for (Account acc : accounts) {
            if (UserInfo.getProfileId() != UTL_CustomSetting.getApiUserProfileId()
                    || acc.OwnerId == UTL_CustomSetting.getPbbUserId()) {
                continue;
            }
            if (String.isNotBlank(acc.Client_Coordinator_from_CDG__c)) {
                accountsToProcess.add(acc);
                accName2CdgUserName.put(acc.Name, acc.Client_Coordinator_from_CDG__c.toUpperCase());
            } else {
                acc.Tech_CC_CDG_Failed_Mapping__c = NO_DETAILS;
            }
        }

        if (accountsToProcess.isEmpty()) {
            return;
        }

        Map<String, Id> userName2Id = new Map<String, Id>();
        for (User usr : [
                SELECT Name
                FROM User
                WHERE Name IN :accName2CdgUserName.values()
                AND IsActive = true
        ]) {
            String usrName = usr.Name.toUpperCase();
            if (!userName2Id.containsKey(usrName)) {
                userName2Id.put(usrName, usr.Id);
            } else {
                userName2Id.put(usrName, null);
            }
        }

        for (Account acc : accountsToProcess) {
            String usrName = acc.Client_Coordinator_from_CDG__c.toUpperCase();
            if (!userName2Id.containsKey(usrName)) {
                acc.Tech_CC_CDG_Failed_Mapping__c = NO_ACTIVE_USER_IN_SF;
            } else if (userName2Id.get(usrName) == null) {
                acc.Tech_CC_CDG_Failed_Mapping__c = MULTIPLE_MATCHING_USERS;
            } else {
                acc.OwnerId = userName2Id.get(usrName);
            }
        }
    }

    /**
     * Populates (Parent) CIF numbers on related Contacts upon hierarchy update.
     *
     * @param newAcc new accounts from trigger
     * @param id2OldAcc old accounts from trigger
     */
    public static void propagateHierarchyChange(List<Account> newAcc, Map<Id, Account> id2OldAcc) {

        Set<Id> accountsTochange = new Set<Id>();
        Set<Id> accountsToupdate = new Set<Id>();

        Set<Id> accountRecTypesIds = new Set<Id>{
                UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_POTENTIAL_CLIENT),
                UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_PROSPECT)
        };

        for (Account acc : newAcc) {
            Account oldAcc = id2OldAcc.get(acc.Id);
            if (acc.Group_Parent_CIF_Number__c != oldAcc.Group_Parent_CIF_Number__c) {
                accountsTochange.add(acc.Id);
            }
            if (accountRecTypesIds.contains(acc.recordtypeId)
                    && acc.CIF_Number_of_Proposed_Group_Parent__c != oldAcc.CIF_Number_of_Proposed_Group_Parent__c) {
                accountsToupdate.add(acc.Id);
            }
        }

        if (!accountsTochange.isEmpty() || !accountsToupdate.isEmpty()) {
            updateContactRecords(accountsToupdate, accountsTochange);
        }
    }
	@TestVisible 
    private static void updateContactRecords(Set<Id> accountsToupdate, Set<Id> accountsTochange) {
        list<Contact> udpateContactList = new list<Contact>();
        for (Contact con : [
                SELECT Group_Parent_CIF_Number__c, Account.CIF_Number_of_Proposed_Group_Parent__c,
                        CIF_Number__c, AccountId, Account.Group_Parent_CIF_Number__c
                FROM Contact
                WHERE AccountId IN :accountsToupdate
                OR AccountId IN:accountsTochange
        ]) {
            if (accountsToupdate.contains(con.AccountId)) {
                con.Group_Parent_CIF_Number__c = con.Account.CIF_Number_of_Proposed_Group_Parent__c;
                con.CIF_Number__c = con.AccountId;
            }

            if (accountsTochange.contains(con.AccountId)
                    && con.Group_Parent_CIF_Number__c != con.Account.Group_Parent_CIF_Number__c) {
                con.Group_Parent_CIF_Number__c = con.Account.Group_Parent_CIF_Number__c;
            }
            udpateContactList.add(con);
        }
        if (!udpateContactList.isEmpty()) {
            Database.SaveResult[] results = Database.update(udpateContactList, false);
            checkContactUpdateResult(results, udpateContactList);
        }
    }

    private static void checkContactUpdateResult(Database.SaveResult[] results, Contact[] contacts) {
        Contact[] contactWithErrors = new Contact[]{
        };

        for (integer i = 0; i < results.size(); i++) {
            Database.SaveResult sr = results[i];

            if (!sr.isSuccess()) {
                String errorMessage = '';
                for (Database.Error err : sr.getErrors()) {
                    errorMessage += err.getMessage();
                }
                contactWithErrors.add(new Contact(Id = contacts[i].Id,
                        CIF_Update_Error__c = errorMessage));
            }
        }

        if (!contactWithErrors.isEmpty()) {
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true;
            dml.OptAllOrNone = false;
            Database.update(contactWithErrors, dml);
        }
    }

    /**
    * Method to create SF2SF connection and share records
    *
    * @param accounts List of updated Account records.
    * @param id2OldAcc Map of Id to Account of records before update
    */
    public static void createConnections(Account[] accounts, Map<Id, Account> id2OldAcc) {
        PartnerNetworkRecordConnection[] newConnections = new PartnerNetworkRecordConnection[]{
        };
        Id connectionId = UTL_Connection.getConnectionId('Standard Bank CCC');

        for (Account client : accounts) {
            if (String.isNotBlank(client.CIF__c)
                    && (id2OldAcc == null
                    || client.CIF__c != id2OldAcc.get(client.Id).CIF__c)) {
                PartnerNetworkRecordConnection newConnection =
                        new PartnerNetworkRecordConnection(
                                ConnectionId = connectionId,
                                LocalRecordId = client.Id,
                                SendClosedTasks = false,
                                SendOpenTasks = false,
                                SendEmails = false,
                                RelatedRecords = 'Contact');
                newConnections.add(newConnection);
            }
        }

        if (!newConnections.isEmpty()) {
            UTL_DmlResult.insertRecords(newConnections, false);
        }
    }


    /**
    * Method to delete marked accounts
    *
    * @param accounts List of deleted Account records.
    * @param id2OldAcc Map of Id to Account of records before delete
    */
    public static void removeMarkedClients(Account[] accounts, Map<Id, Account> id2OldAcc) {
        Set<Id> accIds = new Set<Id>();
        for (Account acc : accounts) {
            if (acc.To_Delete__c
                    && (id2OldAcc == null
                    || !id2OldAcc.get(acc.Id).To_Delete__c)) {
                accIds.add(acc.Id);
            }
        }

        if (!accIds.isEmpty()) {
            SRV_Email.sendRejectionCifClient(accIds);
            removeMarkedClients(accIds);
        }
    }


    /**
    * Method to enqueue delete job for accounts
    *
    * @param accIds Set of account ids to be deleted .
    */
    public static void removeMarkedClients(Set<Id> accIds) {
        QueueDelete deleteJob = new QueueDelete(accIds);
        System.enqueueJob(deleteJob);
    }

    private static Set<Id> changedSubsectorAccIds = new Set<Id>();

    /**
    * Method to update global client revenue's sub sector
    *
    * @param accounts List of updated Account records.
    * @param id2OldAcc Map of Id to Account of records before update
    */
    public static void updateGCRSubSector(Account[] accounts, Map<Id, Account> id2OldAcc) {
        Set<Id> accWithNewSubSectorIds = new Set<Id>();
        Set<Id> rtIds = new Set<Id>{
                UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_POTENTIAL_CLIENT),
                UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_POTENTIAL_CIF),
                UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_POTENTIAL_GOLDTIER),
                UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_PROSPECT)
        };

        for (Account acc : accounts) {
            Account oldAcc = id2OldAcc == null ? null : id2OldAcc.get(acc.Id);

            if (oldAcc == null ||
                    (rtIds.contains(acc.RecordTypeId)
                            && acc.Client_Co_ordinator__c != acc.LastmodifiedbyID
                            && (oldAcc.Client_Sector__c != acc.Client_Sector__c
                            || oldAcc.Client_Sub_Sector__c != acc.Client_Sub_Sector__c
                            || oldAcc.Client_Relationship_Hierarchy__c != acc.Client_Relationship_Hierarchy__c
                            || oldAcc.Client_Co_ordinator__c != acc.Client_Co_ordinator__c))) {
                accWithNewSubSectorIds.add(acc.Id);
                changedSubsectorAccIds.add(acc.Id);
            }
        }

        if (!accWithNewSubSectorIds.isEmpty()) {
            DMN_GlobalClientRevenue.updateSubsectors(accWithNewSubSectorIds);
        }
    }

    /**
    * Method to send email to CC
    *
    * @param accounts List of updated Account records.
    * @param id2OldAcc Map of Id to Account of records before update
    */
    public static void sendEmailstoCC(Account[] accounts, Map<Id, Account> id2OldAcc) {
        Account[] accountsToProcess = new Account[]{
        };
        for (Account acc : accounts) {
            Account oldAcc = id2OldAcc == null ? null : id2OldAcc.get(acc.Id);
            if (oldAcc != null
                    && changedSubsectorAccIds.contains(acc.Id)
                    && oldAcc.GP_IP_PPC_Are_Changed__c != acc.GP_IP_PPC_Are_Changed__c) {
                accountsToProcess.add(acc);
            }
        }

        if (!accountsToProcess.isEmpty()) {
            SRV_Email.sendOnboardingSubsectorChange(accountsToProcess);
        }
    }

    /**
    * Method to share accounts
    *
    * @param accIds Set of account ids to be inserted
    * @param userIds Set of user ids to share accounts with
    * @param accessSettings wrapped access levels
    * @return List of AccountShares to be inserted
    */
    public static AccountShare[] shareAccounts(Set<Id> accIds, Set<Id> userIds, AccessWrapper accessSettings) {

        AccountShare[] sharingRecords = new AccountShare[]{
        };
        for (Id accId : accIds) {
            for (Id usrId : userIds) {
                AccountShare shr = new AccountShare(AccountId = accId,
                        UserOrGroupId = usrId,
                        AccountAccessLevel = accessSettings.accAccess,
                        OpportunityAccessLevel = accessSettings.oppAccess,
                        CaseAccessLevel = accessSettings.casAccess,
                        ContactAccessLevel = accessSettings.conAccess,
                        RowCause = 'Manual');
                sharingRecords.add(shr);
            }
        }
        return sharingRecords;
    }

    /**
     * Serves as an argument for shareAccounts method to reduce total number
     */
    public inherited sharing class AccessWrapper {
        public String accAccess;
        public String oppAccess;
        public String conAccess;
        public String casAccess;

        /**
         * Sets access levels for given objects
         *
         * @param accAccess Account access
         * @param oppAccess Opportunity access
         * @param conAccess Contact access
         * @param casAccess Case access
         */
        public AccessWrapper(String accAccess, String oppAccess, String conAccess, String casAccess) {
            this.accAccess = accAccess;
            this.oppAccess = oppAccess;
            this.conAccess = conAccess;
            this.casAccess = casAccess;
        }
    }

    /**
    * Method to validate FAIS status
    *
    * @param accounts List of account records to be updated
    * @param id2OldAcc Map of Id to Account records before update
    */
    public static void faisStatusFieldValidation(Account[] accounts, Map<Id, Account> id2OldAcc) {
        if (UTL_User.isAutomatedProcess()) {
            return;
        }
        //C-00002875 Get Profile Names to Exclude Admin and Api Users
        String profileName = UTL_Profile.getProfileName(UserInfo.getProfileId());
        if (DMN_Profile.SYSTEM_ADMINISTRATOR.equals(profileName) || DMN_Profile.BUSINESS_ADMINISTRATOR.equals(profileName) ||
                DMN_Profile.API_USER.equals(profileName)) {
            return ;
        }
        Set<Id> changedAccounts = new Set<Id>();
        for (Account account : accounts) {
            // if one of the FAIS fields has changed
            if ((account.FAIS_Status__c != id2OldAcc.get(account.Id).FAIS_Status__c ||
                    account.AUM__c != id2OldAcc.get(account.Id).AUM__c ||
                    account.NAV__c != id2OldAcc.get(account.Id).NAV__c ||
                    account.FAIS_Status_Comments__c != id2OldAcc.get(account.Id).FAIS_Status_Comments__c) &&
                    String.isBlank(account.FAIS_Status__c)) {
                changedAccounts.add(account.Id);
            }
        }
        if (!changedAccounts.isEmpty()) {
            Map<Id, Account> accountMap = new Map<Id, Account>([
                    SELECT (SELECT Id FROM KYC_Statuses__r WHERE Entity_Code__c = :DMN_KYC_Status.ENTITY_CODE_SBSA)
                    FROM Account
                    WHERE Id IN :changedAccounts
            ]);

            for (Account account : accounts) {
                if (accountMap.get(account.Id) != null) {

                    List<KYC_Status__c> kycStatuses = accountMap.get(account.Id).KYC_Statuses__r;
                    if (kycStatuses != null && !kycStatuses.isEmpty()) {
                        account.addError(DMN_KYC_Status.FAIS_STATUS_ERROR);
                    }
                }

            }
        }

    }

    /**
     * Method updates the value of the CIB_Service_Tier__c field for newly created client records or updated children ones.
     * <br/> US-4653
     * @param accounts contains a list of the new versions of the client records.
     * @param id2OldAccount contains a map of the old versions of the client records.
     */
    public static void updateCIBServiceTier(Account[] accounts, Map<Id, Account> id2OldAccount) {

        Id childRT = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_CHILD);
        Id ultimateRT = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_ULTIMATE_PARENT);
        Id immediateRT = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_IMMEDIATE_PARENT);

        List<Account> insertedOrUpdatedChildren = new List<Account>();

        Map<Id, Account> id2ParentAccount = getParentAccounts(accounts, true);

        for (Account acc : accounts) {
            if (acc.Primary_Relationship_Holder__c != null
                    && !acc.Primary_Relationship_Holder__c.equals(PRIMARY_REL_HOLDER_CIB)) {
                continue;
            }

            Account oldAcc = id2OldAccount == null ? null : id2OldAccount.get(acc.Id);

            if (acc.RecordTypeId == ultimateRT || acc.RecordTypeId == immediateRT) {
                if (oldAcc == null
                        && String.isBlank(acc.CIB_Service_Tier__c)) {
                    acc.CIB_Service_Tier__c = CST_Standard;
                }
            }

            if (acc.RecordTypeId == childRT) {
                if (oldAcc == null || acc.ParentId != oldAcc.ParentId) {
                    insertedOrUpdatedChildren.add(acc);
                } else if (oldAcc != null && acc.ParentId != null
                        && acc.CIB_Service_Tier__c != oldAcc.CIB_Service_Tier__c
                        && oldAcc.CIB_Service_Tier__c == id2ParentAccount.get(acc.ParentId).CIB_Service_Tier__c) {
                    acc.addError('Cannot change field value for a child Client. Value inherited from parent Client.');
                }
            }
        }

        updateChildrenClientsCSTValue(insertedOrUpdatedChildren);
    }

    @TestVisible
    private static void updateChildrenClientsCSTValue(List<Account> childrenAccounts) {

        if (childrenAccounts.isEmpty()) {
            return;
        }

        Map<Id, Account> id2ParentAccount = getParentAccounts(childrenAccounts, false);

        for (Account cAcc : childrenAccounts) {
            if (id2ParentAccount.containsKey(cAcc.ParentId)) {
                cAcc.CIB_Service_Tier__c = id2ParentAccount.get(cAcc.ParentId).CIB_Service_Tier__c;
            } else {
                cAcc.CIB_Service_Tier__c = CST_STANDARD;
            }
        }
    }

    @TestVisible
    private static Map<Id, Account> getParentAccounts(List<Account> childrenAccounts, Boolean checkForChild) {

        Set<Id> parentIds = getParentIds(childrenAccounts, checkForChild);
        if (parentIds.isEmpty()) {
            return new Map<Id, Account>();
        }

        return new Map<Id, Account>([
                SELECT Id, CIB_Service_Tier__c
                FROM Account
                WHERE Id IN :getParentIds(childrenAccounts, checkForChild)
        ]);
    }

    @TestVisible
    private static Set<Id> getParentIds(List<Account> accounts, Boolean checkForChild) {

        Id childRT = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_CHILD);

        Set<Id> ids = new Set<Id>();

        for (Account acc : accounts) {
            if (acc.ParentId == null) {
                continue;
            }

            if (!checkForChild) {
                ids.add(acc.ParentId);
            } else if (checkForChild && acc.RecordTypeId == childRT) {
                ids.add(acc.ParentId);
            }
        }

        return ids;
    }

    /**
     * Method updates the value of the CIB_Service_Tier__c field for children records of newly updated parents.
     * <br/> US-4653
     * @param accounts List of account records to be updated
    * @param id2OldAccount Map of Id to Account records before update
     */
    public static void updateChildrenParentCSTValue(Account[] accounts, Map<Id, Account> id2OldAccount) {

        Id ultimateRT = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_ULTIMATE_PARENT);
        Id immediateRT = UTL_RecordType.getRecordTypeId(OBJ_NAME, RT_IMMEDIATE_PARENT);

        List<Account> childrenParentUpdated = new List<Account>();

        for (Account acc : accounts) {
            if (acc.Primary_Relationship_Holder__c != null
                    && !acc.Primary_Relationship_Holder__c.equals(PRIMARY_REL_HOLDER_CIB)) {
                continue;
            }

            Account oldAcc = id2OldAccount.get(acc.Id);

            if ((acc.RecordTypeId == ultimateRT || acc.RecordTypeId == immediateRT)
                    && acc.CIB_Service_Tier__c != oldAcc.CIB_Service_Tier__c) {
                childrenParentUpdated.add(acc);
            }
        }

        updateChildrenCSTValue(childrenParentUpdated);
    }

    @TestVisible
    private static void updateChildrenCSTValue(List<Account> parentAccounts) {

        if (parentAccounts.isEmpty()) {
            return;
        }

        List<Account> childrenAccounts = [
                SELECT Id, CIB_Service_Tier__c, ParentId
                FROM Account
                WHERE ParentId IN :parentAccounts
        ];

        Map<Id, Account> id2ParentAccount = new Map<Id, Account>(parentAccounts);

        for (Account cAcc : childrenAccounts) {
            cAcc.CIB_Service_Tier__c = id2ParentAccount.get(cAcc.ParentId).CIB_Service_Tier__c;
        }

        if (!childrenAccounts.isEmpty()) {
            update childrenAccounts;
        }
    }

    /**
     * Removes FAIS reminder for accounts that became Child Accounts
     *
     * @param accounts new accounts from trigger
     * @param id2OldAcc old accounts from trigger
     */
    public static void changeFAISReminderStatus(Account[] accounts, Map<Id, Account> id2OldAcc) {
        Id childRT = UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_CHILD);
        Id ultimateRT = UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_ULTIMATE_PARENT);
        Id immediateRT = UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_IMMEDIATE_PARENT);
        for (Account acc : accounts) {
            if (acc.RecordTypeId == childRT &&
                    (id2OldAcc.get(acc.Id).RecordTypeId == ultimateRT || id2OldAcc.get(acc.Id).RecordTypeId == immediateRT)) {
                acc.FAIS_reminder__c = 'NO_NEED';
            }
        }
    }

    /**
     * Updates BAs' Entity Risk Ratings for Accounts with changed Name or Internal_Credit_Rating__c
     *
     * @param accounts new accounts from trigger
     * @param id2OldAcc old accounts from trigger
     */
    public static void updateBusinessAssessment(Account[] accounts, Map<Id, Account> id2OldAcc) {
        Set<Id> accIds = new Set<Id>();
        for (Account acc : accounts) {
            if (acc.Name != id2OldAcc.get(acc.Id).Name || acc.Internal_Credit_Rating__c != id2OldAcc.get(acc.Id).Internal_Credit_Rating__c) {
                accIds.add(acc.Id);
            }
        }

        if (!accIds.isEmpty()) {
            DMN_BusinessAssessment.updateEntitiesRiskRating(accIds);
        }
    }

    /**
     * Cancel Fais reminder tasks for inactive clients, called from TRH_Account
     * @param accounts Account[] - list of accounts 
     * @param id2OldAcc Map<Id, Account> - Map of Id's of updated accounts
     */
    public static void cancelFAISReminders(Account[] accounts, Map<Id, Account> id2OldAcc) {
        Id childRT = UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_CHILD);
        Id ultimateRT = UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_ULTIMATE_PARENT);
        Id immediateRT = UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_IMMEDIATE_PARENT);
        List<Account> accountsWithOwnerRel = new SEL_Accounts().selectAccountsWithOwnerRelByAccountId(id2OldAcc.keySet());
        Set<Id> accId = new Set<Id>();
        Set<Id> archivedAccId = new Set<Id>();
        List<Task> tasksToComplete = new List<Task>();
        List<Task> inactiveTasksToComplete = new List<Task>();        
        List<Task> tasksToUpdate = new List<Task>();
        List<Task> recurringTasks = new List<Task>();
        Boolean clientInactive = false;   
        Boolean isChanged = false;    
        
        for (Account acc : accountsWithOwnerRel) {
            if (acc.RecordTypeId == childRT &&
                  (id2OldAcc.get(acc.Id).RecordTypeId == ultimateRT || id2OldAcc.get(acc.Id).RecordTypeId == immediateRT)) {
                isChanged = true;
                accId.add(acc.Id);
            }

            if (acc.CIF_Client_Status__c  == CLIENT_STATUS_CLOSED || acc.Owner.Alias ==  DMN_User.ARCHIVED_OWNER_ALIAS) {
                clientInactive = true;
                archivedAccId.add(acc.Id);
            }
        } 

        if (isChanged) {
            tasksToComplete = new SEL_Tasks().selectBySubjectAndAccountId(DMN_Task.SUBJECT_FAIS_UPDATE, accId);
        }
        if (clientInactive) {
            inactiveTasksToComplete = new SEL_Tasks().selectBySubjectAndAccountId(DMN_Task.SUBJECT_FAIS_UPDATE, archivedAccId);  
        }

        if (!inactiveTasksToComplete.isEmpty()) {
            for (Task task : inactiveTasksToComplete) {
                if (!task.IsRecurrence && (task.Item_to_Action__c || !task.Status.contains(DMN_Task.STATUS_CANCELLED))) {                    
                    task.Status = DMN_Task.STATUS_CANCELLED;  
                    task.Item_to_action__c = false;
                    tasksToUpdate.add(task);
                } else  if (task.IsRecurrence || task.RecurrenceActivityId != null) {
                    recurringTasks.add(task);
                }                       
            }	            
        }

        if (!tasksToComplete.isEmpty()) {
            for (Task task : tasksToComplete) {
                task.Status = DMN_Task.STATUS_COMPLETED;                
            }
            tasksToUpdate.addAll(tasksToComplete);
        }

        if (!tasksToUpdate.isEmpty()) {
            update tasksToUpdate;
        }

        if (!recurringTasks.isEmpty()) {         
            Database.executeBatch(new BCH_CancelRecurringFaisTasks(recurringTasks), 1);             
        }   
                
    }

    private class QueueDelete implements Queueable {

        private Set<Id> lstAccIds;

        private QueueDelete(Set<Id> ids) {
            this.lstAccIds = ids;
        }

        /**
         * Deletes given accounts
         *
         * @param context default param
         */
        public void execute(QueueableContext context) {
            Account[] lstAcc = [SELECT Id FROM Account WHERE Id IN :lstAccIds];
            delete lstAcc;
        }
    }

    /**
     * Populates Managed By field based on User's role in CCT
     *
     * @param teamMembers New CCT records from trigger
     * @param isDeleteTrigger Indicates whether it's insert/update or delete trigger.
     */
    public static void populateManagedByDivision(Custom_Client_Team__c[] teamMembers, Boolean isDeleteTrigger) {
        Map<Id, Custom_Client_Team__c[]> accId2Members = UTL_Collections.builListMap(teamMembers, Custom_Client_Team__c.Account__c);
        Map<Id, Account> accId2Acc = new Map<Id, Account>();

        for (Custom_Client_Team__c[] members : accId2Members.values()) {
            for (Custom_Client_Team__c cct : members) {
                if (isDeleteTrigger && cct.Client_Coordinator__c) {
                    accId2Acc.put(cct.Account__c, new Account(Id = cct.Account__c, Client_Managed_By__c = 'Unmanaged'));
                }
                if (cct.Client_Managed_By__c == cct.User_Division__c) {
                    continue;
                }
                if (cct.Client_Coordinator__c) {
                    accId2Acc.put(cct.Account__c, new Account(Id = cct.Account__c, Client_Managed_By__c = cct.User_Division__c));
                } else if (cct.Client_Role__c == label.MCCClientRole) {
                    accId2Acc.put(cct.Account__c, new Account(Id = cct.Account__c, Client_Managed_By__c = cct.User_Division__c));
                }
            }
        }

        if (!accId2Acc.isEmpty()) {
            update accId2Acc.values();
        }
    }

    /**
	* Method to populate the default PBB fields
	* @param clients List of updated Account records.
	*/
    public static void populateDefaultPBBCLientFields(Account[] clients) {
        for (Account acc : clients) {
            acc.RecordTypeId = UTL_RecordType.getRecordTypeId(Account.getSobjectType().getDescribe().getName(), RT_PERSONAL_BUSINESS_BANKING_CLIENT);
            acc.Primary_Relationship_Holder__c = PRIMARY_REL_HOLDER_BUSINESS;
            acc.Market_Segments__c = MARKET_SEGMENT_LIFESTYLE;
        }
    }

    /**
	* Method to propagate team changes to account fields and rollups
	* @param newTeam List of updated client team records.
	* @param id2OldRecord Map of old client team records before the update.
	*/
    public static void propagateTeamChanges(Custom_Client_Team__c[] newTeam, Map<Id, Custom_Client_Team__c> id2OldRecord) {
        Custom_Client_Team__c[] clientTeamMembers = newTeam != null ? newTeam : id2OldRecord.values();
        Map<Id, Custom_Client_Team__c[]> accId2Team = UTL_Collections.builListMap(clientTeamMembers, Custom_Client_Team__c.Account__c);
        Map<Id, Account> id2Client = new Map<Id, Account>();
        Map<Id, Custom_Client_Team__c> id2Member = new Map<Id, Custom_Client_Team__c>(clientTeamMembers);
        Map<Id, Id> accId2CctId = new Map<Id, Id>();

        for (Custom_Client_Team__c[] team : accId2Team.values()) {

            Account acc = new Account(Id = team[0].Account__c,
                    Client_Coordinator_Exists__c = newTeam != null,
                    Client_Managed_By__c = team[0].Client_Managed_By__c);
            Boolean isChanged = false;

            for (Custom_Client_Team__c member : team) {
                Custom_Client_Team__c cct = newTeam != null ? member : null;
                Custom_Client_Team__c oldCct = id2OldRecord == null ? null : id2OldRecord.get(cct.Id);

                Id accOwnerId = Id.valueOf(cct.Account_Owner__c);

                if (cct != null
                        && cct.Client_Coordinator__c
                        && (oldCct == null || !oldCct.Client_Coordinator__c)
                        && cct.Team_Member__c != accOwnerId) {

                    acc.Client_Coordinator_Exists__c = true;
                    accId2CctId.put(cct.Account__c, cct.Id);
                    isChanged = true;
                } else if (cct != null
                        && !cct.Client_Coordinator__c
                        && oldCct != null
                        && oldCct.Client_Coordinator__c
                        && cct.Team_Member__c == accOwnerId) {
                    acc.Client_Coordinator_Exists__c = true;
                    accId2CctId.put(cct.Account__c, cct.Id);
                    isChanged = true;
                }

                if (cct != null && acc.Client_Managed_By__c == cct.User_Division__c) {
                    continue;
                } else if (cct != null && cct.Client_Coordinator__c) {
                    acc.Client_Managed_By__c = cct.User_Division__c;
                    accId2CctId.put(cct.Account__c, cct.Id);
                    isChanged = true;
                } else if (cct != null && cct.Client_Role__c == label.MCCClientRole && String.isBlank(acc.Client_Managed_By__c)) {
                    acc.Client_Managed_By__c = cct.User_Division__c;
                    accId2CctId.put(cct.Account__c, cct.Id);
                    isChanged = true;
                }
            }

            if (isChanged) {
                id2Client.put(acc.Id, acc);
            }
        }

        if (!id2Client.isEmpty()) {
            UTL_DmlResult.GenericResult[] results = UTL_DmlResult.updateRecords(id2Client.values(), false, false);

            for (UTL_DmlResult.GenericResult res : results) {
                if (!res.isSuccess()) {
                    Id cctId = accId2CctId.get(res.getId());
                    id2Member.get(cctId).addError(res.getErrorMessage());
                }
            }
        }
    }

    /**
	* Method to synchronize and update products when Client Sector changes.
	* SGPRT-1937 - Revenue Forecasting: Updated calculation of Fee Amount
	* @param accountRecords List of updated Account records.
	* @param id2OldAccounts Map of old Account records before the update.
	*/
    public static void syncClientSectorToProducts(List<Account> accountRecords, Map<Id, Account> id2OldAccounts) {
        Map<Id, Account> id2AccountMap = new Map<Id, Account>();

        for (Integer i = 0, j = accountRecords.size(); i < j; i++) {
            if (id2OldAccounts.get(accountRecords[i].Id) != null
                    && accountRecords[i].Client_Sector__c != id2OldAccounts.get(accountRecords[i].Id).Client_Sector__c) {
                id2AccountMap.put(accountRecords[i].Id, accountRecords[i]);
            }
        }

        if (id2AccountMap.size() == 0) {
            return;
        }

        List<SB_Product__c> products = [
				SELECT Id, Client__r.Client_Sector__c,
						RecordTypeId, Term_Tenor__c,
						Finance_Approved_Fee_Recognition__c,
						Opportunity__r.Actual_Close_Date__c,
						Opportunity__r.StageName,
						Grand_Parent_Product__c,
                        Parent_Product__c,
                        Locked_Fee_Recognition__c
				FROM SB_Product__c
				WHERE Client__c IN :id2AccountMap.keySet()
				AND RecordTypeId IN :DMN_SB_Product.CIB_RECORDTYPE_IDS
                AND Locked_Fee_Recognition__c = FALSE
				AND Opportunity__r.StageName <> :DMN_Opportunity.ST_CLOSED_CANCEL
                AND Opportunity__r.StageName <> :DMN_Opportunity.ST_CLOSED_LOST
                AND Opportunity__r.StageName <> :DMN_Opportunity.ST_LEAD

        ];

        if (products.size() == 0) {
            return;
        }

        List<SB_Product__c> productToProcess = new List<SB_Product__c>();

        for (Integer i = 0, j = products.size(); i < j; i++) {
            if ((products[i].Opportunity__r.StageName == DMN_Opportunity.ST_CLOSED_WON
                    && products[i].Opportunity__r.Actual_Close_Date__c.year() == System.today().year())
                    || products[i].Opportunity__r.StageName == DMN_Opportunity.ST_DEVELOP) {
                productToProcess.add(products[i]);
            }
        }


        DMN_SB_Product.setFinanceApprovedFeeRecognition(productToProcess, id2AccountMap);
        update productToProcess;
    }

    private static Map<Id, Account> getAncestors(Set<Id> accountIds) {

        Map<Id, Account> ancestors = new Map<Id, Account>();
        if (!accountIds.isEmpty()) {
            ancestors = new Map<Id, Account>([
                SELECT Name, OwnerId, Parent.Name, CIF__c, Parent.CIF__c, Primary_Relationship_Holder__c,
                    Parent.Primary_Relationship_Holder__c,
                    RecordTypeId, Parent.RecordTypeId, Parent.OwnerId
                FROM Account
                WHERE Id IN :accountIds
            ]);
        }
        return ancestors;
    }

    private static Boolean isRelationshipHierarchyNull(Account record) {
        return record.Client_Relationship_Hierarchy__c == null;
    }

    private static Boolean isGroupParent1Level(Account record) {
        return record.ParentId == null &&
                REL_HIERARCHY_ULTIMATE.equals(record.Client_Relationship_Hierarchy__c)
                && (PRIMARY_REL_HOLDER_CIB.equals(record.Primary_Relationship_Holder__c)
                || PRIMARY_REL_HOLDER_COMMB.equals(record.Primary_Relationship_Holder__c));
    }

    private static Boolean isChild3Level(Account record, Account parent, Account grandParent) {
        String parentRecordType = UTL_RecordType.getRecordTypeName(OBJ_NAME, parent.RecordTypeId);
        String grandParentRecordType = UTL_RecordType.getRecordTypeName(OBJ_NAME, grandParent.RecordTypeId);

        return (PRIMARY_REL_HOLDER_CIB.equals(record.Primary_Relationship_Holder__c) ||
                PRIMARY_REL_HOLDER_COMMB.equals(record.Primary_Relationship_Holder__c)) &&
                REL_HIERARCHY_CHILD.equals(record.Client_Relationship_Hierarchy__c) &&
                ((RT_IMMEDIATE_PARENT.equals(parentRecordType) &&
                        PRIMARY_REL_HOLDER_CIB.equals(parent.Primary_Relationship_Holder__c))
                        ||
                        (RT_COMMB.equals(parentRecordType) &&
                                PRIMARY_REL_HOLDER_COMMB.equals(parent.Primary_Relationship_Holder__c))) &&
                ((RT_ULTIMATE_PARENT.equals(grandParentRecordType) &&
                        PRIMARY_REL_HOLDER_CIB.equals(grandParent.Primary_Relationship_Holder__c)) || (
                        RT_COMMB.equals(grandParentRecordType) &&
                                PRIMARY_REL_HOLDER_COMMB.equals(grandParent.Primary_Relationship_Holder__c)
                ));
    }

    private static Boolean isImmediateParentOrChild2Level(Account record, Account parent) {
        String parentRecordType = UTL_RecordType.getRecordTypeName(OBJ_NAME, parent.RecordTypeId);

        return parentRecordType != null && parent.Primary_Relationship_Holder__c != null &&
                ((RT_ULTIMATE_PARENT.equals(parentRecordType) &&
                        PRIMARY_REL_HOLDER_CIB.equals(parent.Primary_Relationship_Holder__c)) || (
                        RT_COMMB.equals(parentRecordType) &&
                                PRIMARY_REL_HOLDER_COMMB.equals(parent.Primary_Relationship_Holder__c)
                )) &&
                (PRIMARY_REL_HOLDER_CIB.equals(record.Primary_Relationship_Holder__c) ||
                        PRIMARY_REL_HOLDER_COMMB.equals(record.Primary_Relationship_Holder__c)) &&
                (REL_HIERARCHY_IMMEDIATE.equals(record.Client_Relationship_Hierarchy__c) ||
                        REL_HIERARCHY_CHILD.equals(record.Client_Relationship_Hierarchy__c));
    }

    private static Boolean isSARelationshipRoles(Account record) {
        return record.Relationship_Roles__c != null
                && (record.Relationship_Roles__c.equals(REL_ROLE_CLIENT)
                || record.Relationship_Roles__c.contains(REL_ROLE_CORRESPONDING_BANK)
                || record.Relationship_Roles__c.contains(REL_ROLE_MANAGED_FUND)
        );
    }

    private static Boolean isProperKycLocation(Account record) {
        String locationCode = record.KYC_Location__c.split('-', 2)[0].trim();
        String gtRequestKey = GT_REQ_CODE_PREFIX + locationCode;
        SB_Parameters__c gtRequestCodeSettings = SB_Parameters__c.getValues(gtRequestKey);
        return (record.KYC_Location__c != null && gtRequestCodeSettings != null);

    }

    private static Boolean isProspectValid(Account record) {
        return record.Update_Path__c && PT_STEPS_CREATE_PROSPECT.equals(record.Path_Steps__c);
    }

    private static Boolean isDevelopValidGT(Account record) {
        return record.Update_Path__c && PT_STEPS_DEVELOP_PROSPECT.equals(record.Path_Steps__c)
                && isSARelationshipRoles(record) && isProperKycLocation(record);
    }

    private static Boolean isDevelopValidCIF(Account record) {
        return record.Update_Path__c && PT_STEPS_DEVELOP_PROSPECT.equals(record.Path_Steps__c)
                && (!isSARelationshipRoles(record) || !isProperKycLocation(record));
    }

    private static Boolean isDevelopValidLockedGT(Account record) {
        return record.Update_Path__c && PT_STEPS_SUBMIT_FOR_ONBOARDING.equals(record.Path_Steps__c)
                && RT_POTENTIAL_GOLDTIER.equals(UTL_RecordType.getRecordTypeName(OBJ_NAME, record.RecordTypeId))
                && record.Status__c == DMN_Account.STATUS_SUBMITTED_FOR_ONB;
    }

    private static Boolean isDevelopValidLockedCIF(Account record) {
        return record.Update_Path__c && PT_STEPS_SUBMIT_FOR_ONBOARDING.equals(record.Path_Steps__c)
                && RT_POTENTIAL_CIF.equals(UTL_RecordType.getRecordTypeName(OBJ_NAME, record.RecordTypeId))
                && record.Status__c == DMN_Account.STATUS_SUBMITTED_FOR_ONB;
    }

    /**
    * Notifies the logged in user`s manager if the parent client does not have group number
    *@param accountList list of accounts
    */
    @TestVisible 
    public static void commbClientRGNNotifier(list<Account> accountList){


        try {
            String notificationTitle = 'Relationship Group Number';
            String permName = 'CommB_Field_Edit';
            Set<String> userIds = UTL_Permission.getAllUserIdInPermissionSet(permName);
            if(!userIds.isEmpty()) {
                Id notifyId = SEL_CustomNotificationTypes.newInstance().selectByDeveloperName(new Set<String>{RELATIONSHIP_GROUP_NUMBER_NOTIFICATION})[0].Id;
                Set<Id> parentAccountIds = new Set<Id>();
                for (Account accountData : accountList) {
                    parentAccountIds.add(accountData.ParentId);
                }
                Map<Id, Account> id2Account = new Map<Id, Account>(SEL_Accounts.newInstance().selectById(parentAccountIds));
                for (Account accountData : accountList) {

                    if ((accountData.Client_Relationship_Hierarchy__c == REL_HIERARCHY_CHILD ||
                            accountData.Client_Relationship_Hierarchy__c == REL_HIERARCHY_IMMEDIATE) &&
                            accountData.Primary_Relationship_Holder__c == PRIMARY_REL_HOLDER_COMMB) {
                        Account parentAccount = id2Account.get(accountData.ParentId);
                        if (String.isBlank(parentAccount.Relationship_Group_Number__c)) {
                            Messaging.CustomNotification notification = new Messaging.CustomNotification();
                            notification.setTitle(notificationTitle);
                            notification.setBody('The following Commercial Banking Parent does not have a Relationship Group Number,' + parentAccount.Name);
                            notification.setSenderId(Userinfo.getUserId());
                            notification.setNotificationTypeId(notifyId);
                            notification.setTargetId(parentAccount.Id);
                            notification.send(userIds);

                        }
                    }
                }
            }
        }
        catch(Exception ex){
            SRV_Logger.newInstance().log(ex, DMN_Log.AREA_COMMB, DMN_Account.class.getName());
        }
    }
	/** Method to delete Ecosystem Entites connected to an Account - moved from TRH_Account.cls
	* SFP-5865 Revenue Forecasting: Updated calculation of Fee Amount
	* @param records List of deleted Account records.
	*/
    public static void deleteEcosystemEntities(List<Account> records) {
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : records) {
            accountIds.add(acc.Id);
        }
        delete [SELECT Id FROM Ecosystem_Entity__c WHERE Entity__c IN :accountIds];
    }
    
    /**
    * @description Method to calculate record Completeness 
    * @author Maham | 19-09-2022 
    * @param records List<Account> - list of the new records
    * @param oldRecords Map<Id Account> - map of the old records when doing an update 
    **/
    public static void calculateRecordCompleteness(List<Account> records, Map<Id, Account> oldRecords) {
      
        // SFP-11772 
        // If the AR Maintenance Batch is running then do not update record completeness as this is done by the batch
        if (BCH_AR_AccountMaintenance.isRunning) {
            return;
        }
        // SFP-13848 CPU LIMIT issue.
        // Need to prevent calculation if the batch size is more than 10.  This still allows real time calculation on individual record
        // updates, but when records are updated in bulk those are handled by the maintenance batch
        if (records.size() > 10) {
            return;
        }
        
        Map<Id, Account> accountsTobeUpdated = new Map<Id, Account>();
        List <Account> accountsTobeInserted = new List <Account>();
        Map<Id, Schema.RecordTypeInfo> recordTypes = SEL_Accounts.getRecordTypes();
        for (Account acc: records) {
            String recordTypeName = recordTypes.get(acc.RecordTypeId)?.Name;
            if (recordTypeName == DMN_Account.COMMERCIAL_AFRICA_TYPE || recordTypeName == DMN_Account.ENTERPRISE_AFRICA_TYPE ||
                ( recordTypeName == DMN_Account.RT_PROSPECT && acc.Client_Coordinator_Role__c?.left(6) ==  'BCC AR' )) {
                   if (oldRecords != null && oldRecords.get(acc.Id) != null) {
                    accountsTobeUpdated.put(acc.Id, acc);   
                } else {
                    accountsTobeInserted.add(acc);
                }
            }
        }
        if (accountsTobeUpdated.size() > 0) {
            Map<Account,Map<String,Integer>> recordCompletenessRelatedData = Record_Completeness_RR_Helper.getRelatedRecord(accountsTobeUpdated.keySet(), accountsTobeUpdated);
            CalculateRecordCompleteness.updateRecordCompletenessScore(recordCompletenessRelatedData);
        }
        if (accountsTobeInserted.size() > 0) {
            Map<Account,Map<String,Integer>> recordCompletenessRelatedData = Record_Completeness_RR_Helper.createRelatedMapForInsert(accountsTobeInserted);
            CalculateRecordCompleteness.updateRecordCompletenessScore(recordCompletenessRelatedData);
        }
    }
}