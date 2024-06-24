@IsTest
private class DMN_ClientTeam_Test {

	private static final String CC_USER_NAME 			= '74y387or443wlfrertuw5893u4wef32453@testdwadwada.com';
	private static final String NOT_CC_USER_NAME = 'regularTeamMemberUsr12321312312@testedawdwadwr.com';
	private static final String ACC_NAME = 'test Account';
	private static final String SYNC_ROLES_CLIENT_NAME 	= 'Sync Core Roles To Client Tests';

	private static Custom_Client_Team__c cc;
	private static Custom_Client_Team__c teamMemberNew1;
	private static Custom_Client_Team__c teamMemberNew2;
	private static Custom_Client_Team__c teamMemberOld1;
	private static Custom_Client_Team__c teamMemberOld2;

	private static User ccUser {
		get {
			if (ccUser == null) {
				ccUser = [SELECT Id, Email FROM User WHERE UserName = :CC_USER_NAME];
			}
			return ccUser;
		}
	}
	private static final String CCBM_USER_NAME = 'ccBmUsr12321312312@testedawdwadwr.com';
    private static final String CCBB_USER_NAME = 'ccBmUsr12321312312bb@testedawdwadwr.com';
    private static final String CCCOMMB_USER_NAME = 'ccBmUsr12321312312commB@testedawdwadwr.com';
    private static final String CCGTB_USER_NAME = 'ccBmUsr12321312312gtb@testedawdwadwr.com';
    private static final String CCGTB2_USER_NAME = 'ccBmUsr12321312312gt2b@testedawdwadwr.com';
	private static User ccBmUser {
		get {
			if (ccBmUser == null) {
				ccBmUser = [SELECT Id, Email FROM User WHERE UserName = :CCBM_USER_NAME];
			}
			return ccBmUser;
		}
	}

	private static User regularTeamMemberUser {
		get {
			if (regularTeamMemberUser == null) {
				regularTeamMemberUser = [SELECT Id, Email FROM User WHERE UserName = :NOT_CC_USER_NAME];
			}
			return regularTeamMemberUser;
		}
	}

    private static Account syncRolesAccount {
        get {
            if (syncRolesAccount == null) {
                syncRolesAccount = [SELECT Id FROM Account WHERE Name = :SYNC_ROLES_CLIENT_NAME];
            }
            return syncRolesAccount;
        }
    }

	@TestSetup
	static void setup() {
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

		BLD_USER.useInTestSetup();
		User ccUsr = (User) new BLD_User(uow).userName(CC_USER_NAME).useSysAdmin().division(DMN_User.GM_DIVISION).getRecord();
		new BLD_User(uow).userName(NOT_CC_USER_NAME).useCib().getRecord();

		User ccBmUsr = (User) new BLD_User(uow).userName(CCBM_USER_NAME).useCib().getRecord();
        User ccBBUsr = (User) new BLD_User(uow).userName(CCBB_USER_NAME).useBB().getRecord();
        User ccCommBUsr = (User) new BLD_User(uow).userName(CCCOMMB_USER_NAME).useCommB().getRecord();
        User gtbUser = (User) new BLD_User(uow).userName(CCGTB_USER_NAME).useCib().division(DMN_User.TPS_DIVISION).getRecord();
        User gtbUser2 = (User) new BLD_User(uow).userName(CCGTB2_USER_NAME).useCib().division(DMN_User.TPS_DIVISION).getRecord();

		List<User> teamMembers = new List<User>();
		for (Integer i = 0; i < 3; i++) {
			teamMembers.add((User)new BLD_USER(uow).useCib().getRecord());
		}
		teamMembers.get(0).User_Division__c = DMN_User.IB_DIVISION;

		uow.commitWork();

		System.runAs(ccUsr) {

			UserProfileId__c[] userProfileIds = new UserProfileId__c[]{
				new UserProfileId__c(Name = 'UserProfileId', UserProfileId__c = UTL_Profile.getProfileId('System Administrator')),
				new UserProfileId__c(Name = 'Business Administrator', UserProfileId__c = UTL_Profile.getProfileId('Business Administrator'))
			};
			ClientCoordinatorSettings__c[] accessSettingMap = new ClientCoordinatorSettings__c[]{
				new ClientCoordinatorSettings__c(Name = 'CC_OpportunityAccessLevel', AccessLevel__c = 'Read/Write'),
				new ClientCoordinatorSettings__c(Name = 'CC_ContactAccessLevel', AccessLevel__c = 'Read/Write'),
				new ClientCoordinatorSettings__c(Name = 'CC_ClientAccessLevel', AccessLevel__c = 'Full Access'),
				new ClientCoordinatorSettings__c(Name = 'CC_CaseAccessLevel', AccessLevel__c = 'Read Only'),
				new ClientCoordinatorSettings__c(Name = 'CC_Client_Coverage_OppAccessLevel', AccessLevel__c = 'Read Only')
			};
			ErrorMessages__c[] errorMessages = new ErrorMessages__c[]{
				new ErrorMessages__c(Name = 'SameTeamRoleValidation', Error_String__c = 'Same Team Role exist for Client Team Member. Please select a different Team Role.', Where_is_this_used__c = 'CustomClientTeamUtility Class'),
				new ErrorMessages__c(Name = 'SameUserExists', Error_String__c = 'Same User already exists in the Client Team.', Where_is_this_used__c = 'CustomClientTeamUtility Class')
			};

			SObject[] customSettings = new SObject[]{};
			customSettings.addAll((SObject[]) userProfileIds);
			customSettings.addAll((SObject[]) accessSettingMap);
			customSettings.addAll((SObject[]) errorMessages);
            customSettings.addAll((SObject[]) TEST_DataFactory.getCstTeamRankings());

			insert customSettings;

			fflib_SObjectUnitOfWork newUow = ABS_ObjectBuilderBase.getNewUnitOfWork();

			ABS_ObjectBuilderBase[] builders = new ABS_ObjectBuilderBase[]{};
			for (Integer i=0; i<5; i++) {
				builders.add(new BLD_Account(newUow)
					.addClientTeam(new BLD_ClientTeam(newUow)
						.coordinator(true)
						.ccbm(false)
						.role(DMN_ClientTeam.ROLE_GM_EXECUTION_MANAGER)
						.user(ccUser.Id)
					)
					.addClientTeam(new BLD_ClientTeam(newUow)
						.coordinator(false)
						.ccbm(true)
						.role(DMN_ClientTeam.ROLE_TRADER)
						.user(ccBmUser.Id)
					)
					.addBusinessAssessment(new BLD_BusinessAssessment(newUow))
				);

				builders.add(new BLD_Account(newUow)
					.addClientTeam(new BLD_ClientTeam(newUow)
						.coordinator(true)
						.ccbm(false)
						.role(DMN_ClientTeam.ROLE_GM_EXECUTION_MANAGER)
						.user(ccUser.Id)
					)
					.addClientTeam(new BLD_ClientTeam(newUow)
						.coordinator(false)
						.ccbm(false)
						.role(DMN_ClientTeam.CREDIT_MANAGER)
						.user(ccBmUser.Id)
					)
					.addBusinessAssessment(new BLD_BusinessAssessment(newUow))
				);

				builders.add(new BLD_Account(newUow)
					.addClientTeam(new BLD_ClientTeam(newUow)
						.coordinator(false)
						.ccbm(true)
						.role(DMN_ClientTeam.ROLE_TRADER)
						.user(ccBmUser.Id)
					)
					.addBusinessAssessment(new BLD_BusinessAssessment(newUow))
				);

				builders.add(new BLD_Account(newUow)
					.addBusinessAssessment(new BLD_BusinessAssessment(newUow))
				);

			}
            builders.add(new BLD_Account(newUow).useBB()
                         .addClientTeam(new BLD_ClientTeam(newUow)
                                        .coordinator(true)
                                        .ccbm(false)
                                        .user(ccBBUsr.Id)
                                        .role(DMN_ClientTeam.ROLE_COMMB_RELATION_MANGER)));
            builders.add(new BLD_Account(newUow).useCommB()
                         .addClientTeam(new BLD_ClientTeam(newUow)
                                        .coordinator(true)
                                        .ccbm(false)
                                        .user(ccCommBUsr.Id)
                                        .role(DMN_ClientTeam.ROLE_COMMB_RELATION_MANGER)));
            builders.add(new BLD_Account(newUow)
                         .addClientTeam(new BLD_ClientTeam(newUow)
                                        .coordinator(true)
                                        .ccbm(false)
                                        .role(DMN_ClientTeam.ROLE_GTB)
                                        .GTB(true)
                                        .user(gtbUser.Id)
                                       )
                         .addClientTeam(new BLD_ClientTeam(newUow)
                                        .coordinator(false)
                                        .ccbm(false)
                                        .role(DMN_ClientTeam.CREDIT_MANAGER)
                                        .user(ccBmUser.Id)
                                       )
                        );
            builders.add(new BLD_Account(newUow)
                         .addClientTeam(new BLD_ClientTeam(newUow)
                                        .coordinator(true)
                                        .ccbm(false)
                                        .role(DMN_ClientTeam.ROLE_GTB)
                                        .GTB(true)
                                        .user(gtbUser2.Id)
                                       ));
			syncRolesAccount = (Account) new BLD_Account(newUow).name(SYNC_ROLES_CLIENT_NAME)
					.addClientTeam(new BLD_ClientTeam(newUow).user(teamMembers.get(0).Id)
							.role(DMN_ClientTeam.ROLE_ADVISORY_BANKER))
					.addClientTeam(new BLD_ClientTeam(newUow).user(teamMembers.get(1).Id)
							.role(DMN_ClientTeam.ROLE_EXEC_SPONSOR))
					.addClientTeam(new BLD_ClientTeam(newUow).user(teamMembers.get(2).Id)
							.role(DMN_ClientTeam.ROLE_CREDIT_RISK))
                    .getRecord();
			newUow.commitWork();
        }
    }

	@IsTest
	static void testUpdateBusinessAssessments() {
		Map<Id, Account> accounts;
		Custom_Client_Team__c[] ccts;

		System.runAs(ccUser) {

			ccts = [
				SELECT Client_Coordinator__c
					, Client_Coordinator_BM__c
					, Team_Member__c
					, Account__c
					, Client_Role__c
				FROM Custom_Client_Team__c
			];

			Test.startTest();
				DMN_ClientTeam.updateBusinessAssessments(ccts, null);
			Test.stopTest();
		}

		accounts = new Map<Id,Account>([
			SELECT 
				(SELECT Client_Coordinator__c,
					Client_Coordinator_BM__c,
					Team_Member__c,
					Client_Role__c
				FROM Custom_Client_Teams__r)
			FROM Account
		]);

		Business_Assessment__c[] businessAssessments = [
			SELECT Group_Parent_CC__c,
				Group_Parent_CCBM__c,
				Account__c,
				Credit_Manager__c
			FROM Business_Assessment__c
		];

		for (Business_Assessment__c ba : businessAssessments) {

			Account acc = accounts.get(ba.Account__c);

			Boolean ccNotFound = true;
			Boolean ccBmNotFound = true;
			Boolean creditManagerNotFound = true;

			for (Custom_Client_Team__c cct : acc.Custom_Client_Teams__r) {
				if (cct.Client_Coordinator__c) {
					ccNotFound = false;
					System.assertEquals(cct.Team_Member__c, ba.Group_Parent_CC__c, 'Group Parent CC on Business Assessment should be the same as on Client');
				}
				if (cct.Client_Coordinator_BM__c) {
					ccBmNotFound = false;
					System.assertEquals(cct.Team_Member__c, ba.Group_Parent_CCBM__c, 'Group Parent CC BM on Business Assessment should be the same as on Client');
				}
				if (cct.Client_Role__c == DMN_ClientTeam.CREDIT_MANAGER) {
					creditManagerNotFound = false;
					System.assertEquals(cct.Team_Member__c, ba.Credit_Manager__c, 'Credit Manager on Business Assessment should be the same as on Client');
				}
			}

			if (ccNotFound) {
				System.assert(String.isBlank(ba.Group_Parent_CC__c), 'Group Parent CC should be blank');
			}
			if (ccBmNotFound) {
				System.assert(String.isBlank(ba.Group_Parent_CCBM__c), 'Group Parent CC BM should be blank');
			}
			if (creditManagerNotFound) {
				System.assert(String.isBlank(ba.Credit_Manager__c), 'Credit manager should be blank');
			}

		}

	}
    
	static void testGatherAssociatedAccounts() {
		Map<Id, Account> accounts;
		Map<Id, Custom_Client_Team__c> oldCcts;
		Custom_Client_Team__c[] ccts;

		oldCcts = new Map<Id, Custom_Client_Team__c> ([
				SELECT Id, Client_Coordinator__c
					, Client_Coordinator_BM__c
					, Team_Member__c
					, Account__c
					, Client_Role__c
				FROM Custom_Client_Team__c
			]);
		ccts = oldCcts.values();
		for (Custom_Client_Team__c cct : ccts) {
				if (cct.Client_Coordinator__c) {
					cct.Client_Coordinator__c = false;
				}
				if (cct.Client_Coordinator_BM__c) {
					cct.Client_Coordinator_BM__c = false;
				}
				if (cct.Client_Role__c == DMN_ClientTeam.CREDIT_MANAGER) {
					cct.Client_Role__c = DMN_ClientTeam.ROLE_GM_EXECUTION_MANAGER;
				}
		}

		System.runAs(ccUser) {
			Test.startTest();
				DMN_ClientTeam.updateBusinessAssessments(ccts, oldCcts);
			Test.stopTest();
		}

		accounts = new Map<Id,Account>([
			SELECT 
				(SELECT Client_Coordinator__c,
					Client_Coordinator_BM__c,
					Team_Member__c,
					Client_Role__c
				FROM Custom_Client_Teams__r)
			FROM Account
		]);

		Business_Assessment__c[] businessAssessments = [
			SELECT Group_Parent_CC__c,
				Group_Parent_CCBM__c,
				Account__c,
				Credit_Manager__c
			FROM Business_Assessment__c
		];

		for (Business_Assessment__c ba : businessAssessments) {

			Account acc = accounts.get(ba.Account__c);

			Boolean ccNotFound = true;
			Boolean ccBmNotFound = true;
			Boolean creditManagerNotFound = true;

			for (Custom_Client_Team__c cct : acc.Custom_Client_Teams__r) {
				if (cct.Client_Coordinator__c) {
					ccNotFound = false;
					System.assertEquals(cct.Team_Member__c, ba.Group_Parent_CC__c, 'Group Parent CC on Business Assessment should be the same as on Client');
				}
				if (cct.Client_Coordinator_BM__c) {
					ccBmNotFound = false;
					System.assertEquals(cct.Team_Member__c, ba.Group_Parent_CCBM__c, 'Group Parent CC BM on Business Assessment should be the same as on Client');
				}
				if (cct.Client_Role__c == DMN_ClientTeam.CREDIT_MANAGER) {
					creditManagerNotFound = false;
					System.assertEquals(cct.Team_Member__c, ba.Credit_Manager__c, 'Credit Manager on Business Assessment should be the same as on Client');
				}
			}

			if (ccNotFound) {
				System.assert(String.isBlank(ba.Group_Parent_CC__c), 'Group Parent CC should be blank');
			}
			if (ccBmNotFound) {
				System.assert(String.isBlank(ba.Group_Parent_CCBM__c), 'Group Parent CC BM should be blank');
			}
			if (creditManagerNotFound) {
				System.assert(String.isBlank(ba.Credit_Manager__c), 'Credit manager should be blank');
			}
		}
	}
    
    @IsTest
    static void testhandleTeamMemberChange() {
		Map<Id, Custom_Client_Team__c> oldCcts;
		Custom_Client_Team__c[] objCcts;

        
		oldCcts = new Map<Id, Custom_Client_Team__c> ([
				SELECT Id, Client_Coordinator__c
					, Client_Coordinator_BM__c
					, Team_Member__c
					, Account__c
					, Client_Role__c
				FROM Custom_Client_Team__c LIMIT 1
			]);
		objCcts = oldCcts.values();
        User bbUser = [SELECT Id ,User_Division__c FROM USER WHERE User_Division__c = 'Global Markets' and 
                       ID !=: objCcts[0].Team_Member__c LIMIT 1];
        objCcts[0].Team_Member__c = bbUser.Id;
        objCcts[0].Client_Coordinator__c = false;
        objCcts[0].Client_Coordinator_BM__c = false;
        update objCcts;
		for (Custom_Client_Team__c cct : oldCcts.values()) {
            cct.Client_Coordinator__c = true;
            cct.Client_Coordinator_BM__c = true;
            cct.Client_Role__c = DMN_ClientTeam.CREDIT_MANAGER;
        }
		System.runAs(ccUser) {
			Test.startTest();
				DMN_ClientTeam.updateBusinessAssessments(objCcts, oldCcts);
			Test.stopTest();
		}
        System.assert(!objCcts.isEmpty(), True);
    }
    
    @IsTest
    static void isSyncCoreRolesToClientFieldsOnInsert() {

        List<Custom_Client_Team__c> coreRoleMembers = [
				SELECT Id, Account__c, Client_Role__c, Team_Member__c, Core__c,
						Account__r.IB_Champion__c,
						Account__r.Executive_Sponsor__c, Account__r.Credit_Risk__c
				FROM Custom_Client_Team__c
				WHERE Account__c = :syncRolesAccount.Id
		];

        Test.startTest();
        DMN_ClientTeam.syncCoreRolesToClientFields(coreRoleMembers, null);
        Test.stopTest();
        Account client = [
                SELECT Id, Executive_Sponsor__c, Credit_Risk__c, IB_Champion__c
                FROM Account
                WHERE Id = :syncRolesAccount.Id
        ];
		//System.assertEquals(coreRoleMembers.get(0).Team_Member__c, client.IB_Champion__c, 'Should set IB Champion on the client');
		System.assertEquals(coreRoleMembers.get(1).Team_Member__c, client.Executive_Sponsor__c, 'Should set Executive sponsor on the client record');
		System.assertEquals(coreRoleMembers.get(2).Team_Member__c, client.Credit_Risk__c, 'Should set Credit Risk on the client record');
    }

    @IsTest
    static void isSyncCoreRolesToClientFieldsOnUpdateNoCoreToCore() {

        List<Custom_Client_Team__c> coreRoleMembers = [
				SELECT Id, Account__c, Client_Role__c, Team_Member__c, Core__c,
						Account__r.IB_Champion__c,
						Account__r.Executive_Sponsor__c, Account__r.Credit_Risk__c
				FROM Custom_Client_Team__c
				WHERE Account__c = :syncRolesAccount.Id
		];

        Map<Id, Custom_Client_Team__c> oldCoreRoleMembers = new Map<Id, Custom_Client_Team__c>();
        for (Custom_Client_Team__c member : coreRoleMembers) {
            Custom_Client_Team__c tempCCT = member.clone(true);
            oldCoreRoleMembers.put(tempCCT.Id, tempCCT);
        }

		List<String> nonCoreRoles = new List<String>{DMN_ClientTeam.ROLE_TRADER,
				DMN_ClientTeam.ROLE_ANALYST,
				DMN_ClientTeam.ROLE_BUSINESS_DEV_MANAGER};

		for (Custom_Client_Team__c cct : oldCoreRoleMembers.values()) {
			cct.Client_Role__c = nonCoreRoles.get(oldCoreRoleMembers.values().indexOf(cct));
		}

        Test.startTest();
		DMN_ClientTeam.syncCoreRolesToClientFields(coreRoleMembers, oldCoreRoleMembers);
        Test.stopTest();
        Account client = [
                SELECT Id, Executive_Sponsor__c, Credit_Risk__c, IB_Champion__c
                FROM Account
                WHERE Id = :syncRolesAccount.Id
        ];
        //System.assertEquals(coreRoleMembers.get(0).Team_Member__c, client.IB_Champion__c, 'Should set IB Champion on the client');
		System.assertEquals(coreRoleMembers.get(1).Team_Member__c, client.Executive_Sponsor__c, 'Should set Executive sponsor on the client record');
		System.assertEquals(coreRoleMembers.get(2).Team_Member__c, client.Credit_Risk__c, 'Should set Credit Risk on the client record');
    }
    
    @IsTest
    static void isSyncCoreRolesToClientFieldsOnUpdateCoreToNoCore() {

        List<Custom_Client_Team__c> coreRoleMembers = [
				SELECT Id, Account__c, Client_Role__c, Team_Member__c, Core__c,
						Account__r.IB_Champion__c,
						Account__r.Executive_Sponsor__c, Account__r.Credit_Risk__c
				FROM Custom_Client_Team__c
				WHERE Account__c = :syncRolesAccount.Id
        ];

        List<String> nonCoreRoles = new List<String>{DMN_ClientTeam.ROLE_TRADER,
                DMN_ClientTeam.ROLE_ANALYST,
                DMN_ClientTeam.ROLE_BUSINESS_DEV_MANAGER};

        Map<Id, Custom_Client_Team__c> oldCoreRoleMembers = new Map<Id, Custom_Client_Team__c>();
        for (Custom_Client_Team__c member : coreRoleMembers) {
			Custom_Client_Team__c tempCCT = member.clone(true);
			oldCoreRoleMembers.put(tempCCT.Id, tempCCT);
			member.Client_Role__c = nonCoreRoles.get(coreRoleMembers.indexOf(member));
		}
		update coreRoleMembers;

        Test.startTest();
        DMN_ClientTeam.syncCoreRolesToClientFields(coreRoleMembers, oldCoreRoleMembers);
        Test.stopTest();
        Account client = [
                SELECT Id, Executive_Sponsor__c, Credit_Risk__c, IB_Champion__c
                FROM Account
                WHERE Id = :syncRolesAccount.Id
        ];
		System.assertEquals(null, client.IB_Champion__c, 'IB Champion on the client record should be null');
		System.assertEquals(null, client.Executive_Sponsor__c, 'Executive Sponsor on the client record should be null');
		System.assertEquals(null, client.Credit_Risk__c, 'Credit Risk on the client record should be null');
    }

    @IsTest
    static void isSyncCoreRolesToClientFieldsOnDelete() {

        Map<Id, Custom_Client_Team__c> oldCoreRoleMembers = new Map<Id, Custom_Client_Team__c>([
                SELECT Id, Account__c, Client_Role__c, Team_Member__c, Core__c,
						Account__r.IB_Champion__c,
						Account__r.Executive_Sponsor__c, Account__r.Credit_Risk__c
                FROM Custom_Client_Team__c
                WHERE Account__c = :syncRolesAccount.Id
        ]);

        Test.startTest();
		DMN_ClientTeam.syncCoreRolesToClientFields(null, oldCoreRoleMembers);
		Test.stopTest();
        Account client = [
                SELECT Id, Executive_Sponsor__c, Credit_Risk__c, IB_Champion__c
                FROM Account
                WHERE Id = :syncRolesAccount.Id
        ];
        System.assertEquals(null, client.IB_Champion__c, 'IB Champion on the client record should be null');
        System.assertEquals(null, client.Executive_Sponsor__c, 'Executive Sponsor on the client record should be null');
        System.assertEquals(null, client.Credit_Risk__c, 'Credit Risk on the client record should be null');
	}

	@IsTest
	static void testManageOwnersInTeam() {

		Account acc = [SELECT Id,Market_Segments__c,Primary_Relationship_Holder__c FROM Account
		WHERE Primary_Relationship_Holder__c='Business Banking'];
		User bbUser = [SELECT Id ,User_Division__c FROM USER WHERE Username =: CCBB_USER_NAME];
		Map<Id, Account> id2OldAcc = new Map<Id, Account>();
		Account[] accounts = new List<Account>();
		id2OldAcc.put(acc.id, acc);
		acc.OwnerId = bbUser.Id;
		accounts.add(acc);

		update accounts;
		System.runAs(bbUser) {
			Test.startTest();
			DMN_ClientTeam.manageOwnersInTeam(accounts,id2OldAcc);
			Test.stopTest();
		}
		Custom_Client_Team__c objCct = [SELECT Id, Client_Role__c FROM Custom_Client_Team__c WHERE Account__c =: acc.Id];
		System.assertEquals(objCct.Client_Role__c, 'BCC Relationship Manager');
	}

	@IsTest
	static void testBuildcctBB() {

		Account acc = [SELECT Id,Market_Segments__c,Primary_Relationship_Holder__c FROM Account
		WHERE Primary_Relationship_Holder__c='Business Banking'];
		User bbUser = [SELECT Id ,User_Division__c FROM USER WHERE Username =: CCBB_USER_NAME];
		Custom_Client_Team__c cct ;
		System.runAs(bbUser) {

			Test.startTest();
			cct  = DMN_ClientTeam.buildCctRecord(acc,bbUser.Id,null,'Business Banking');
			Test.stopTest();
		}
		//System.assertNotEquals(cct.Client_Role__c, 'BCC Relationship Manager','BCC Relationship Manager');
	}

	@IsTest
	static void testBuildcctCommB() {

		Account acc = [SELECT Id,Market_Segments__c,Primary_Relationship_Holder__c FROM Account
		WHERE Primary_Relationship_Holder__c='Commercial Banking'];
		User commBUser = [SELECT Id ,User_Division__c FROM USER WHERE Username =: CCCOMMB_USER_NAME];
		Custom_Client_Team__c cct ;
		String recType = UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_POTENTIAL_CLIENT);
		System.runAs(commBUser) {

			Test.startTest();
			cct  = DMN_ClientTeam.buildCctRecord(acc,commBUser.Id,recType,'Commercial Banking');
			Test.stopTest();
		}
		System.assertEquals(cct.Client_Role__c, 'BCC Relationship Manager','BCC Relationship Manager');
	}

	@IsTest
	static void testManageOwnersInTeamUseCommB() {

		Account acc = [SELECT Id,Market_Segments__c,Primary_Relationship_Holder__c FROM Account
		WHERE Primary_Relationship_Holder__c='Commercial Banking'];
		User commBUser = [SELECT Id ,User_Division__c FROM USER WHERE Username =: CCCOMMB_USER_NAME];
		Map<Id, Account> id2OldAcc = new Map<Id, Account>();
		Account[] accounts = new List<Account>();
		id2OldAcc.put(acc.id, acc);
		acc.RecordTypeId = UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_POTENTIAL_CLIENT);
		acc.Client_Co_ordinator__c = commBUser.Id;
		accounts.add(acc);
		System.runAs(commBUser) {
			Test.startTest();
			update accounts;
			DMN_ClientTeam.manageOwnersInTeam(accounts,id2OldAcc);
			Test.stopTest();
		}
		Custom_Client_Team__c objCct = [SELECT Id, Client_Role__c FROM Custom_Client_Team__c WHERE Account__c =: acc.Id];
		System.assertEquals(objCct.Client_Role__c, 'BCC Relationship Manager','BCC Relationship Manager');
	}

	@IsTest
	static void testManageOwnersInTeamIsCC() {

		Account acc = [SELECT Id,Market_Segments__c,Primary_Relationship_Holder__c FROM Account
		WHERE Primary_Relationship_Holder__c='Commercial Banking'];
		User commBUser = [SELECT Id ,User_Division__c FROM USER WHERE Username =: CCCOMMB_USER_NAME];
		Map<Id, Account> id2OldAcc = new Map<Id, Account>();
		Account[] accounts = new List<Account>();
		id2OldAcc.put(acc.id, acc);
		acc.RecordTypeId = UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_POTENTIAL_CLIENT);
		acc.Client_Co_ordinator__c = commBUser.Id;
		accounts.add(acc);
		System.runAs(commBUser) {
			Test.startTest();
			update accounts;
			DMN_ClientTeam.manageOwnersInTeam(accounts,id2OldAcc);
			Test.stopTest();
		}
        System.assertEquals(!accounts.isEmpty(), True,'Not Empty');
	}

	@IsTest
	static void testManageOwnersInTeamUseCIB() {

		Test.startTest();
		Account acc = [SELECT Id,Market_Segments__c,Primary_Relationship_Holder__c FROM Account
		WHERE Name=:SYNC_ROLES_CLIENT_NAME];
		User cibUser = [SELECT Id ,User_Division__c FROM USER WHERE Username =: CCBM_USER_NAME];
		Map<Id, Account> id2OldAcc = new Map<Id, Account>();
		Account[] accounts = new List<Account>();
		id2OldAcc.put(acc.id, acc);
		acc.RecordTypeId = UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_POTENTIAL_CLIENT);
		acc.Client_Co_ordinator__c = cibUser.Id;
		accounts.add(acc);
		update accounts;
		System.runAs(cibUser) {
			DMN_ClientTeam.manageOwnersInTeam(accounts,id2OldAcc);
		}
        System.assertEquals(!accounts.isEmpty(), True,'Not Empty');
        Test.stopTest();
	}
    
	@IsTest
	static void testUpdateOwnerAfterCcRemove(){

		Account acc = [SELECT Id,OwnerId,Market_Segments__c,Primary_Relationship_Holder__c FROM Account
		WHERE Primary_Relationship_Holder__c='Business Banking'];
		User bbUser = [SELECT Id ,User_Division__c FROM USER WHERE Username =: CCBB_USER_NAME];
		acc.OwnerId = bbUser.Id;
		Test.startTest();
		update acc;
		Map<Id, Custom_Client_Team__c> oldCoreRoleMembers = new Map<Id, Custom_Client_Team__c>(
		[SELECT Id, Client_Coordinator__c,Account__c
		FROM Custom_Client_Team__c
		WHERE Account__c =: acc.Id]);
		DMN_ClientTeam.updateOwnerAfterCcRemove(oldCoreRoleMembers);
		Test.stopTest();
		acc = [SELECT Id,OwnerId,Market_Segments__c,Primary_Relationship_Holder__c FROM Account
		WHERE Primary_Relationship_Holder__c='Business Banking'];
		System.assertEquals(acc.OwnerId, bbUser.Id,'Equal');
	}

	@IsTest
	static void testRemoveExistingMembers(){

		Account acc = [SELECT Id,Market_Segments__c,Primary_Relationship_Holder__c FROM Account
		WHERE Primary_Relationship_Holder__c='Business Banking'];
		User bbUser = [SELECT Id ,User_Division__c FROM USER WHERE Username =: CCBB_USER_NAME];
		Custom_Client_Team__c[] roleMembers;
		acc.OwnerId = bbUser.Id;
		Test.startTest();
		update acc;
		roleMembers = [SELECT Id,Team_Member__c, Client_Coordinator__c,Account__c FROM Custom_Client_Team__c WHERE Account__c =: acc.Id];
		DMN_ClientTeam.removeExistingMembers(roleMembers);
		Test.stopTest();
		roleMembers = [SELECT Id,Team_Member__c, Client_Coordinator__c,Account__c FROM Custom_Client_Team__c WHERE Account__c =: acc.Id];
		System.assertEquals(bbUser.Id, roleMembers[0].Team_Member__c,'Equal Member');
	}
    
    @IsTest
    static void testrunGtbValidations(){
        
        Map<Id,Account> accMap = new Map<Id,Account>(
            [SELECT Id,OwnerId,Market_Segments__c,Primary_Relationship_Holder__c FROM Account]);
        Custom_Client_Team__c[] roleMembers = [SELECT Id,Team_Member__c, Client_Coordinator__c,Account__c,GTB__c,Client_Role__c FROM Custom_Client_Team__c
                                               WHERE Account__c IN: accMap.KeySet()];
        Map<Id, Custom_Client_Team__c> oldCoreRoleMembers = new Map<Id, Custom_Client_Team__c>(roleMembers);
        Custom_Client_Team__c[] roleMemberList = new List<Custom_Client_Team__c>();
        for(Custom_Client_Team__c cct : roleMembers){
            if(cct.GTB__c){
                roleMemberList.add(cct);
                break;
           }
        }
        Test.startTest();       
        	DMN_ClientTeam.runGtbValidations(roleMemberList,oldCoreRoleMembers);
        Test.stopTest();
        System.assertEquals(!roleMemberList.isEmpty(), True,'Not Empty');
    }
    
    @IsTest
    static void testmanageSharing(){
        
        User ccUser = [SELECT Id ,User_Division__c FROM USER WHERE Username =: CC_USER_NAME]; 
        Map<Id,Account> accMap = new Map<Id,Account>(
            [SELECT Id,OwnerId,Market_Segments__c,Primary_Relationship_Holder__c FROM Account 
             WHERE OwnerId=:ccUser.Id]);
        Custom_Client_Team__c[] roleMembers = [SELECT Id,Team_Member__c, Client_Coordinator__c,Account__c,GTB__c,Client_Role__c,Client_Coordinator_BM__c
                                               ,Top_Client_Id__c FROM Custom_Client_Team__c WHERE Account__c IN: accMap.KeySet()];
        Map<Id, Custom_Client_Team__c> oldCoreRoleMembers = new Map<Id, Custom_Client_Team__c>(roleMembers);
        Test.startTest();       
            DMN_ClientTeam.manageSharing(roleMembers,oldCoreRoleMembers);
            DMN_ClientTeam.manageSharing(null,oldCoreRoleMembers);
            DMN_ClientTeam.manageSharing(roleMembers,null);
        Test.stopTest();
        System.assertEquals(!roleMembers.isEmpty(), True,'Not Empty');
    }
    
	@IsTest
    static void testgetCstWithVisibleToClientChanged(){
        
        User ccUser = [SELECT Id ,User_Division__c FROM USER WHERE Username =: CC_USER_NAME]; 
        Map<Id,Account> accMap = new Map<Id,Account>(
            [SELECT Id,OwnerId,Market_Segments__c,Primary_Relationship_Holder__c FROM Account 
             WHERE OwnerId=:ccUser.Id]);
        Custom_Client_Team__c[] roleMembers = [SELECT Id,Visible_to_Client__c,Team_Member__c, Client_Coordinator__c,Account__c,GTB__c,Client_Role__c,Client_Coordinator_BM__c
                                               ,Top_Client_Id__c FROM Custom_Client_Team__c WHERE Account__c IN: accMap.KeySet() LIMIT 1];
        roleMembers[0].Visible_to_Client__c = true; 
        Map<Id, Custom_Client_Team__c> oldCoreRoleMembers = new Map<Id, Custom_Client_Team__c>();
        Test.startTest();       
        	DMN_ClientTeam.getCstWithVisibleToClientChanged(roleMembers,oldCoreRoleMembers);
        Test.stopTest();
        System.assertEquals(!roleMembers.isEmpty(), True,'Not Empty');
    }
    
    @IsTest
	static void testNegGatherAssociatedAccounts() {
		Map<Id, Custom_Client_Team__c> oldCcts;
		Custom_Client_Team__c[] cctsv;
		oldCcts = new Map<Id, Custom_Client_Team__c> ([
				SELECT Id, Client_Coordinator__c
					, Client_Coordinator_BM__c
					, Team_Member__c
					, Account__c
					, Client_Role__c
				FROM Custom_Client_Team__c
			]);
        User gtbuser = [SELECT Id ,User_Division__c FROM USER WHERE Username =: CCGTB_USER_NAME];  
        cctsv = oldCcts.values();

		for (Custom_Client_Team__c cct : cctsv) {
            cct.Team_Member__c = gtbuser.Id;
            cct.Client_Role__c = DMN_ClientTeam.CREDIT_MANAGER;
            if (cct.Client_Coordinator__c) {
                cct.Client_Coordinator__c = false;
            }
            if (cct.Client_Coordinator_BM__c) {
                cct.Client_Coordinator_BM__c = false;
            }
            
		}
		System.runAs(ccUser) {
			Test.startTest();
            	DMN_ClientTeam.gatherAssociatedAccounts(cctsv, oldCcts);
			Test.stopTest();
		}
        System.assertEquals(!cctsv.isEmpty(), True,'Not Empty');
	}
    
    @IsTest
    static void testValidateUniqueValuesAndRemove(){
        
        Account acc = [SELECT Id,Market_Segments__c,Primary_Relationship_Holder__c FROM Account 
                       WHERE Primary_Relationship_Holder__c='Commercial Banking'];
        User bbUser = [SELECT Id ,User_Division__c FROM USER WHERE Username =: CCBB_USER_NAME];  
        Custom_Client_Team__c[] roleMembers;
        Custom_Client_Team__c[] roleMembersList= new List<Custom_Client_Team__c>();
        Custom_Client_Team__c[] roleMembersList2 = new List<Custom_Client_Team__c>();
        Custom_Client_Team__c newcct = new Custom_Client_Team__c(
            Team_Member__c=bbUser.Id,
            Client_Coordinator__c=true,
            Account__c=acc.Id,
            SourceFlag__c=10,
            Client_Role__c = DMN_ClientTeam.ROLE_COMMB_RELATION_MANGER
        );
        Custom_Client_Team__c newcct2 = new Custom_Client_Team__c(
            Team_Member__c=bbUser.Id,
            Client_Coordinator__c=true,
            Account__c=acc.Id,
            SourceFlag__c=12,
            Client_Role__c = DMN_ClientTeam.ROLE_COMMB_RELATION_MANGER
        );
        roleMembersList.add(newcct);
        roleMembersList2.add(newcct2);
        Test.startTest();
            roleMembers = [SELECT Id,GTB__c,Client_Role__c,Team_Member__c,SourceFlag__c, Client_Coordinator__c,Account__c ,Client_Coordinator_BM__c FROM Custom_Client_Team__c WHERE Account__c =: acc.Id];
            DMN_ClientTeam.validateUniqueValuesAndRemove(roleMembersList,roleMembers);
        DMN_ClientTeam.validateUniqueValuesAndRemove(roleMembersList2,roleMembers);
        Test.stopTest();
        System.assertEquals(!roleMembersList.isEmpty(), True,'Not Empty');
    }
        
    @IsTest
    static void testpropagateCcToClientAndgetCcAndCcBmsMap(){
        
        User ccUser = [SELECT Id ,User_Division__c FROM USER WHERE Username =: CC_USER_NAME]; 
        Map<Id,Account> accMap = new Map<Id,Account>(
            [SELECT Id,OwnerId,Market_Segments__c,Primary_Relationship_Holder__c FROM Account 
             WHERE OwnerId=:ccUser.Id]);
        Custom_Client_Team__c[] roleMembers = [SELECT Id,Team_Member__c, Client_Coordinator__c,Account__r.OwnerId,Account__c,GTB__c,Client_Role__c,Client_Coordinator_BM__c
                                               ,Top_Client_Id__c,Account_Owner__c FROM Custom_Client_Team__c WHERE Account__c IN: accMap.KeySet()];
        Map<Id, Custom_Client_Team__c> oldCoreRoleMembers = new Map<Id, Custom_Client_Team__c>(roleMembers);
        for (Custom_Client_Team__c cct : roleMembers) {
            cct.Team_Member__c = cct.Account__r.OwnerId;
        }
        Set<Id> clientIds = new Set<Id>();
        for(Account objAccount : accMap.values())
        {
            clientIds.add(objAccount.Id);
        }
        Test.startTest(); 
            DMN_ClientTeam.propagateCcToClient(roleMembers,oldCoreRoleMembers);
        	Map<Id, DMN_ClientTeam.CcCcbmWrapper> getCcAndCcBmsMap = DMN_ClientTeam.getCcAndCcBmsMap(clientIds);
        Test.stopTest();
        
        System.assertEquals(False, getCcAndCcBmsMap.isEmpty(), 'Should not be Empty');
    }

	@IsTest
	static void shouldAllowAdminUserToChangeVisibleToClient() {
		generateTestDataForVisibleToClientTest();
		List<Custom_Client_Team__c> records = new List<Custom_Client_Team__c>{
				teamMemberNew1, teamMemberNew2
		};
		Map<Id, Custom_Client_Team__c> id2OldRecords = new Map<Id, Custom_Client_Team__c>{
				teamMemberOld1.Id => teamMemberOld1,
				teamMemberOld2.Id => teamMemberOld2
		};

		fflib_ApexMocks mocks = new fflib_ApexMocks();
		SEL_ClientTeams selClientTeamMock = (SEL_ClientTeams) mocks.mock(SEL_ClientTeams.class);

		mocks.startStubbing();
		mocks.when(selClientTeamMock.sObjectType()).thenReturn(Custom_Client_Team__c.SObjectType);
		mocks.when(selClientTeamMock.selectCcAndCcbmByClientIds(new Set<Id>{
				cc.Account__c
		})).thenReturn(new List<Custom_Client_Team__c>{
				cc
		});
		mocks.stopStubbing();

		ORG_Application.selector.setMock(selClientTeamMock);

		Test.startTest();
		DMN_ClientTeam.checkIfUserIsAllowedToEditVisibleToClient(records, id2OldRecords);
		Test.stopTest();

		System.assertEquals(0, teamMemberNew1.getErrors().size(), 'Error shouldn\'t be added to the Client Team record');
		System.assertEquals(0, teamMemberNew2.getErrors().size(), 'Error shouldn\'t be added to the Client Team record');
	}

	@IsTest
	static void shouldAllowCCBMUserToChangeVisibleToClient() {
		generateTestDataForVisibleToClientTest();
		List<Custom_Client_Team__c> records = new List<Custom_Client_Team__c>{
				teamMemberNew1, teamMemberNew2
		};
		Map<Id, Custom_Client_Team__c> id2OldRecords = new Map<Id, Custom_Client_Team__c>{
				teamMemberOld1.Id => teamMemberOld1,
				teamMemberOld2.Id => teamMemberOld2
		};

		fflib_ApexMocks mocks = new fflib_ApexMocks();
		SEL_ClientTeams selClientTeamMock = (SEL_ClientTeams) mocks.mock(SEL_ClientTeams.class);

		mocks.startStubbing();
		mocks.when(selClientTeamMock.sObjectType()).thenReturn(Custom_Client_Team__c.SObjectType);
		mocks.when(selClientTeamMock.selectCcAndCcbmByClientIds(new Set<Id>{
				cc.Account__c
		})).thenReturn(new List<Custom_Client_Team__c>{
				cc
		});
		mocks.stopStubbing();

		ORG_Application.selector.setMock(selClientTeamMock);

		Test.startTest();
		System.runAs(ccUser){
			DMN_ClientTeam.checkIfUserIsAllowedToEditVisibleToClient(records, id2OldRecords);
		}
		Test.stopTest();

		System.assertEquals(0, teamMemberNew1.getErrors().size(), 'Error shouldn\'t be added to the Client Team record');
		System.assertEquals(0, teamMemberNew2.getErrors().size(), 'Error shouldn\'t be added to the Client Team record');
	}

	@IsTest
	static void shouldNotAllowUserToChangeVisibleToClient() {
		generateTestDataForVisibleToClientTest();
		List<Custom_Client_Team__c> records = new List<Custom_Client_Team__c>{
				teamMemberNew1, teamMemberNew2
		};
		Map<Id, Custom_Client_Team__c> id2OldRecords = new Map<Id, Custom_Client_Team__c>{
				teamMemberOld1.Id => teamMemberOld1,
				teamMemberOld2.Id => teamMemberOld2
		};

		fflib_ApexMocks mocks = new fflib_ApexMocks();
		SEL_ClientTeams selClientTeamMock = (SEL_ClientTeams) mocks.mock(SEL_ClientTeams.class);

		mocks.startStubbing();
		mocks.when(selClientTeamMock.sObjectType()).thenReturn(Custom_Client_Team__c.SObjectType);
		mocks.when(selClientTeamMock.selectCcAndCcbmByClientIds(new Set<Id>{
				cc.Account__c
		})).thenReturn(new List<Custom_Client_Team__c>{
				cc
		});
		mocks.stopStubbing();

		ORG_Application.selector.setMock(selClientTeamMock);

		Test.startTest();
		System.runAs(regularTeamMemberUser) {
			DMN_ClientTeam.checkIfUserIsAllowedToEditVisibleToClient(records, id2OldRecords);
		}
		Test.stopTest();

		System.assertNotEquals(0, teamMemberNew1.getErrors().size(), 'Error should be added to the Client Team record');
		System.assertEquals('Only Client Coordinator or Client Coordinator\'s Business Manager can change Visible to Client field\'s value',
				teamMemberNew1.getErrors().get(0).getMessage(),
				'Should throw an error indicating that only Client Coordinator or his/her Business Manager can change value of Visible to Client Field\'s value'
		);
		System.assertEquals(0, teamMemberNew2.getErrors().size(), 'Error shouldn\'t be added to the Client Team record');
	}

	static private void generateTestDataForVisibleToClientTest() {
		Id id1 = fflib_IDGenerator.generate(Custom_Client_Team__c.SObjectType);
		Id id2 = fflib_IDGenerator.generate(Custom_Client_Team__c.SObjectType);
		Id id3 = fflib_IDGenerator.generate(Custom_Client_Team__c.SObjectType);
		Id userId1 = fflib_IDGenerator.generate(User.SObjectType);
		Id userId2 = fflib_IDGenerator.generate(User.SObjectType);
		Id accountId = fflib_IDGenerator.generate(Account.SObjectType);
		cc = (Custom_Client_Team__c) new BLD_ClientTeam().account(accountId).user(ccBmUser.Id).ccbm(false).coordinator(true).role(DMN_ClientTeam.ROLE_GM_EXECUTION_MANAGER).id(id3).visibleToClient(true).getRecord();
		teamMemberNew1 = (Custom_Client_Team__c) new BLD_ClientTeam().account(accountId).user(userId1).ccbm(false).coordinator(false).role(DMN_ClientTeam.ROLE_TRADER).id(id1).visibleToClient(true).getRecord();
		teamMemberNew2 = (Custom_Client_Team__c) new BLD_ClientTeam().account(accountId).user(userId2).ccbm(false).coordinator(false).role(DMN_ClientTeam.CREDIT_MANAGER).id(id2).visibleToClient(false).getRecord();
		teamMemberOld1 = (Custom_Client_Team__c) new BLD_ClientTeam().account(accountId).user(userId1).ccbm(false).coordinator(false).role(DMN_ClientTeam.ROLE_TRADER).id(id1).visibleToClient(false).getRecord();
		teamMemberOld2 = (Custom_Client_Team__c) new BLD_ClientTeam().account(accountId).user(userId2).ccbm(false).coordinator(false).role(DMN_ClientTeam.CREDIT_MANAGER).id(id2).visibleToClient(false).getRecord();
	}
}