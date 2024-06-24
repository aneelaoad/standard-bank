/*************************************************************************
    @ Author        : psvestka
    @ Date          : Nov 13, 2015
    @ Test File     : CbCstRolesTest
    @ Description   : EN-910

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Nov 19, 2015
    @ Modification Description : EN-912 - added new tests
    
    @ Last Modified By  :   Manoj Gupta       
    @ Last Modified On  :   Dec 2015
    @ Last Modified Reason  : EN:0838 - Replacing Corporate Banking references to Client Coverage
    
    @ Last Modified By  :   Manoj Gupta       
    @ Last Modified On  :   Jan 2016
    @ Last Modified Reason  : EN:0967 - Replacing 'CB Relationship Manager','CB Portfolio Manager','CB Product Specialist', and 'CB Service Manager'
                                with 'CommB Relationship Manager','CommB Portfolio Manager','CommB Product Specialist' and 'CommB Service Manager'

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Jan 13, 2016
    @ Modification Description : EN-966 - adjusted tests when 'CommB Portfolio Manager' is allowed more than once per CST

    @ Last Modified By  : Jana Cechova
    @ Last Modified On  : Feb 5, 2016
    @ Modification Description : EN-0989 - adjusted conditions for creating users and accounts based on added validation rules
    
    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Feb 26, 2016
    @ Modification Description : US-1042 - fixed SOQL-101 by moving startTest()
    
    @ Last Modified By  : Jana Cechova
    @ Last Modified On  : Mar 31, 2016
    @ Modification Description : EN-0910 - Default Access for CommB CST Role was changed Read/Write -> Private.
    
    @ Last Modified By  : Jana Cechova
    @ Last Modified On  : Apr 06, 2016
    @ Modification Description : DEF-001770: Do not automatically check CC check box when CommB role are selected
    
        @ Last Modified By  : Jana Cechova
    @ Last Modified On  : Jul 22, 2016
    @ Modification Description : US-1479: RTB - Update Existing CommB Onboarding Validations to Validate only Onboarding RecordTypes => user_division__c = 'Commercial Banking'; 
    
    @ Last Modified By  :   Petr Svestka
    @ Last Modified On  :   Sep 22, 2016
    @ Last Modified Reason  : US-1534 - Replicating "CommB Product Specialist" into "CommB CSU Agent" and "CommB CSU Manager"   
****************************************************************************/

@IsTest
private class CbCstRolesTest {
    private static Map<String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    private final static Id ugpRecTypeId = mapAccountRecordTypes.get('Ultimate Group Parent').getRecordTypeId();
    private final static Id potRecTypeId = mapAccountRecordTypes.get('Potential Client').getRecordTypeId();

    //todo roles const

    @TestSetup
    private static void prepareData() {
        TEST_DataFactory.generateConfiguration();

        List<CSTManyperRegionTeamRoles__c> cstmprtr = TEST_DataFactory.getCSTManyPerRegionTeamRoles();
        cstmprtr.add(new CSTManyperRegionTeamRoles__c(name = 'BCC Portfolio Manager'));
        cstmprtr.add(new CSTManyperRegionTeamRoles__c(name = 'BCC Product Specialist'));
        cstmprtr.add(new CSTManyperRegionTeamRoles__c(name = 'BCC CSU Agent'));
        cstmprtr.add(new CSTManyperRegionTeamRoles__c(name = 'BCC CSU Manager'));
        cstmprtr.add(new CSTManyperRegionTeamRoles__c(name = 'BCC Service Manager'));
        insert cstmprtr;
    }

    private static User createUser() {
        return (User) new BLD_USER()
            .profile(DMN_Profile.CLIENT_COVERAGE_MOBILE_USER_INSIGHTS)
            .cibGlobalArea(DMN_User.CIB_GA_COMMB)
            .getRecord();
    }

    private static Account createAccount() {
        Account acc = new Account();
        acc.RecordTypeId = ugpRecTypeId;
        acc.CRT_Parent_Child__c = 'TP';
        acc.Name = 'Test Client';
        acc.BillingStreet = 'Test street';
        acc.Client_Sector__c = 'Unknown Sector';
        acc.Client_Sub_Sector__c = 'Unknown Sub-Sector';
        acc.Client_Segment__c = 'AB';
        acc.Country_Risk__c = 'India';
        acc.Correspondence_Addr_Line1__c = 'Test Street Line 1';
        acc.Correspondence_City__c = 'City';
        acc.Correspondence_Postal_Code__c = '123456';
        acc.Correspondence_Country__c = 'India';
        acc.BillingCountry = 'South Africa';
        acc.BillingCity = 'Durban';

        acc.CIF__c = '1234';

        return acc;
    }

    private static Custom_Client_Team__c createCst(Account acc, User cstMember, String cstRole) {
        if (acc == null || acc.id == null || cstMember == null || cstMember.id == null || String.isEmpty(cstRole)) {
            system.debug('createCst: one of the arguments is empty');
            return new Custom_Client_Team__c();
        }

        Custom_Client_Team__c cct = new Custom_Client_Team__c();
        cct.account__c = acc.Id;
        cct.client_Access__c = 'Read/Write';
        cct.client_Role__c = cstRole;
        cct.team_Member__c = cstMember.Id;

        return cct;
    }

    private static List<Custom_Client_Team__c> createCsts(Account acc, List<User> cstMembers, List<String> cstRoles) {
        if (acc == null || acc.id == null || cstMembers == null || cstMembers.isEmpty() || cstRoles == null || cstRoles.isEmpty() || cstMembers.size() != cstRoles.size()) {
            system.debug('createCsts: one of the arguments is empty');
            return new List<Custom_Client_Team__c>();
        }

        List<Custom_Client_Team__c> ccts = new List<Custom_Client_Team__c>();

        for (Integer i = 0; i < cstMembers.size(); i++) {
            ccts.add(createCst(acc, cstMembers.get(i), cstRoles.get(i)));
        }

        return ccts;
    }

    private static Map<String, Map<String, String>> createExpectedAccess() {
        Map<String, String> expectedAccessCBRM = new Map<String, String>{'client' => 'Read/Write'
        ,'opportunity' => 'Private'
        ,'contact' => 'Read/Write'
        ,'case' => 'Read Only'};
        Map<String, String> expectedAccessCBPM = new Map<String, String>{'client' => 'Read/Write'
        ,'opportunity' => 'Private'
        ,'contact' => 'Read/Write'
        ,'case' => 'Read Only'};
        Map<String, String> expectedAccessCBPS = new Map<String, String>{'client' => 'Read/Write'
        ,'opportunity' => 'Private'
        ,'contact' => 'Read/Write'
        ,'case' => 'Read Only'};
        Map<String, String> expectedAccessCBSM = new Map<String, String>{'client' => 'Read/Write'
        ,'opportunity' => 'Private'
        ,'contact' => 'Read/Write'
        ,'case' => 'Read Only'};

        Map<String, Map<String, String>> expectedAccess = new Map<String, Map<String, String>>();
        expectedAccess.put('BCC Relationship Manager', expectedAccessCBRM);
        expectedAccess.put('BCC Portfolio Manager', expectedAccessCBPM);
        expectedAccess.put('BCC Product Specialist', expectedAccessCBPS);
        expectedAccess.put('BCC Service Manager', expectedAccessCBSM);

        return expectedAccess;
    }

    //--------
    static testMethod void testCstRolesAccess() {
        User userCC, userCBRM, userCBPM, userCBPS, userCBSM;
        List<User> users = new List<User>();

        System.runas(new User(Id = UserInfo.getUserId())) {
            userCC = createUser();
            userCC.user_division__c = 'Commercial Banking';
            userCC.Division = 'Commercial Banking';
            users.add(userCC);

            userCBRM = createUser();
            userCBRM.user_division__c = 'Commercial Banking';
            users.add(userCBRM);

            userCBPM = createUser();
            userCBPM.user_division__c = 'Commercial Banking';
            users.add(userCBPM);

            userCBPS = createUser();
            userCBPS.user_division__c = 'Commercial Banking';
            users.add(userCBPS);

            userCBSM = createUser();
            users.add(userCBSM);

            insert users;
        }
        system.assert(userCC != null && userCC.id != null);

        Account acc = createAccount();
        acc.client_Co_ordinator__c = userCC.id;
        acc.primary_relationship_holder__c = 'Commercial Banking';
        acc.KYC_Location__c = DMN_Account.DEFAULT_COMMB_KYC_LOCATION;

        Test.startTest();

        system.runAs(userCC) {
            insert acc;
            system.debug('###### after inserting acc');

            system.assert(acc.id != null);

            List<Custom_Client_Team__c> ccts = createCsts(acc, users, new List<String>{'BCC Relationship Manager'
                    ,'BCC Portfolio Manager'
                    ,'BCC Product Specialist'
                    ,'BCC Service Manager'});
            insert ccts;
        }

        Test.stopTest();

        Map<String, Map<String, String>> expectedAccessMap = createExpectedAccess();

        List<Custom_Client_Team__c> cctsFetched = [SELECT team_Member__r.name
                ,client_Role__c
                ,client_Access__c
                ,opportunity_Access__c
                ,contact_Access__c
                ,case_Access__c
        FROM Custom_Client_Team__c
        WHERE account__c = :acc.id];

        for (Custom_Client_Team__c cct: cctsFetched) {
            if (expectedAccessMap.containsKey(cct.client_Role__c)) {
                Map<String, String> expectedAccessForRole = expectedAccessMap.get(cct.client_Role__c);
                system.assertEquals(expectedAccessForRole.get('client'), cct.client_Access__c, 'Incorrect access for Client for team role ' + cct.client_Role__c);
                system.assertEquals(expectedAccessForRole.get('opportunity'), cct.opportunity_Access__c, 'Incorrect access for Opportunity for team role ' + cct.client_Role__c);
                system.assertEquals(expectedAccessForRole.get('contact'), cct.contact_Access__c, 'Incorrect access for Contact for team role ' + cct.client_Role__c);
                system.assertEquals(expectedAccessForRole.get('case'), cct.case_Access__c, 'Incorrect access for Case for team role ' + cct.client_Role__c);
            }
        }
    }

    static testMethod void testCstRoleMultiplicityCBRM() {
        User userCC, userCBRM;
        List<User> users = new List<User>();

        System.runas(new User(Id = UserInfo.getUserId())) {
            userCC = createUser();
            userCC.Division = 'Commercial Banking'; // CST team member will be role CBRM
            userCC.user_division__c = 'Commercial Banking';
            userCC.business_Unit__c = 'Client Coverage';
            users.add(userCC);

            userCBRM = createUser();
            userCBRM.Division = 'Commercial Banking'; // CST team member will be role CBRM
            userCBRM.user_division__c = 'Commercial Banking';
            userCBRM.business_Unit__c = 'Client Coverage';
            users.add(userCBRM);

            insert users;
        }
        system.assert(userCC != null && userCBRM.id != null);

        Account acc = createAccount();
        acc.CIF__c = null;
        acc.RecordTypeId = potRecTypeId;
        acc.client_Co_ordinator__c = userCC.id;
        acc.primary_relationship_holder__c = 'Commercial Banking';
        acc.KYC_Location__c = DMN_Account.DEFAULT_COMMB_KYC_LOCATION;

        Test.startTest();

        system.runAs(userCC) {
            insert acc;

            // will try to create another CST team member with role CBRM

            Pagereference p = page.SA_AddCustomClient_UserView;
            p.getParameters().put('id', acc.id);
            p.getParameters().put('Owner', String.valueof(acc.ownerId));
            System.Test.setCurrentPage(p);

            SA_AddCustomClientTeam ctrl = new SA_AddCustomClientTeam();
            ctrl.CCTObj.Client_Role__c = 'BCC Relationship Manager';
            ctrl.CCTObj.team_member__c = userCBRM.Id;
            ctrl.SaveRec();

            Boolean searchedForErrorFound = false;
            for(ApexPages.Message message: ApexPages.getMessages()) {
                if (message.getSummary().startsWith('Same Team Role exist for Client Team Member')) {
                    searchedForErrorFound = true;
                }
            }
          //  system.assert(searchedForErrorFound, 'A second CST member in the role of "CommB Relationship Manager" should be prevented'); because DEF-001770: Do not automatically check CC check box when CommB role are selected
        }
    }

    static testMethod void testCstRoleMultiplicityCBPM() {
        User userCC, userCBPM, userCBPM2;
        List<User> users = new List<User>();

        System.runas(new User(Id = UserInfo.getUserId())) {
            userCC = createUser(); // CST team member will be "Manager Client Coverage"
            userCC.user_division__c = 'Commercial Banking';
            userCC.Division = 'Commercial Banking';
            users.add(userCC);

            userCBPM = createUser();
            userCBPM.user_division__c = 'Commercial Banking';
            userCBPM.Division = 'Commercial Banking';
            users.add(userCBPM);

            userCBPM2 = createUser();
            userCBPM2.user_division__c = 'Commercial Banking';
            userCBPM2.Division = 'Commercial Banking';
            users.add(userCBPM2);

            insert users;
        }
        system.assert(userCC != null && userCBPM.id != null && userCBPM2.id != null);

        Account acc = createAccount();
        acc.CIF__c = null;
        acc.RecordTypeId = potRecTypeId;
        acc.client_Co_ordinator__c = userCC.id;
        acc.primary_relationship_holder__c = 'Commercial Banking';
        acc.KYC_Location__c = DMN_Account.DEFAULT_COMMB_KYC_LOCATION;
       
        Test.startTest();

        system.runAs(userCC) {
            insert acc;

            Pagereference p;
            SA_AddCustomClientTeam ctrl;

            // adds a CST team member with role CBPM

            p = page.SA_AddCustomClient_UserView;
            p.getParameters().put('id', acc.id);
            p.getParameters().put('Owner', String.valueof(acc.ownerId));
            System.Test.setCurrentPage(p);
            ctrl = new SA_AddCustomClientTeam();
            ctrl.CCTObj.Client_Role__c = 'BCC Portfolio Manager';
            ctrl.CCTObj.team_member__c = userCBPM.Id;
            ctrl.SaveRec();
            
            system.assert(ApexPages.getMessages().size() == 0);

            // will try to create another CST team member with role CBPM

            p = page.SA_AddCustomClient_UserView;
            p.getParameters().put('id', acc.id);
            p.getParameters().put('Owner', String.valueof(acc.ownerId));
            System.Test.setCurrentPage(p);
            ctrl = new SA_AddCustomClientTeam();
            ctrl.CCTObj.Client_Role__c = 'BCC Portfolio Manager';
            ctrl.CCTObj.team_member__c = userCBPM2.Id;
            ctrl.SaveRec();

            system.assert(ApexPages.getMessages().size() == 0);
        }
    }

    static testMethod void testCstRoleAllowedMultiplicities() {
        User userCC, userCBPS, userCBPS2, userCBSM, userCBSM2;
        List<User> users = new List<User>();

        System.runas(new User(Id = UserInfo.getUserId())) {
            userCC = createUser(); // CST team member will be "Manager Client Coverage"
            userCC.user_division__c = 'Commercial Banking';
            userCC.Division = 'Commercial Banking';
            users.add(userCC);

            userCBPS = createUser();
            userCBPS.user_division__c = 'Commercial Banking';
            userCC.Division = 'Commercial Banking';
            users.add(userCBPS);

            userCBPS2 = createUser();
            userCBPS2.user_division__c = 'Commercial Banking';
            userCC.Division = 'Commercial Banking';
            users.add(userCBPS2);

            userCBSM = createUser();
            userCBSM.user_division__c = 'Commercial Banking';
            userCC.Division = 'Commercial Banking';
            users.add(userCBSM);

            userCBSM2 = createUser();
            userCBSM2.user_division__c = 'Commercial Banking';
            userCC.Division = 'Commercial Banking';
            users.add(userCBSM2);

            insert users;
        }
        system.assert(userCC != null && userCBPS.id != null && userCBPS2.id != null && userCBSM.id != null && userCBSM2.id != null);

        Account acc = createAccount();
        acc.CIF__c = null;
        acc.RecordTypeId = potRecTypeId;
        acc.client_Co_ordinator__c = userCC.id;
        acc.primary_relationship_holder__c = 'Commercial Banking';
        acc.KYC_Location__c = DMN_Account.DEFAULT_COMMB_KYC_LOCATION;
        
        system.runAs(userCC) {
            insert acc;

            Pagereference p;
            SA_AddCustomClientTeam ctrl;

            // will add two CST team members with role CBPS

            p = page.SA_AddCustomClient_UserView;
            p.getParameters().put('id', acc.id);
            p.getParameters().put('Owner', String.valueof(acc.ownerId));
            System.Test.setCurrentPage(p);
            ctrl = new SA_AddCustomClientTeam();
            ctrl.CCTObj.Client_Role__c = 'BCC Product Specialist';
            ctrl.CCTObj.team_member__c = userCBPS.Id;
            ctrl.SaveRec();

            system.assert(ApexPages.getMessages().size() == 0);

            p = page.SA_AddCustomClient_UserView;
            p.getParameters().put('id', acc.id);
            p.getParameters().put('Owner', String.valueof(acc.ownerId));
            System.Test.setCurrentPage(p);
            ctrl = new SA_AddCustomClientTeam();
            ctrl.CCTObj.Client_Role__c = 'BCC Product Specialist';
            ctrl.CCTObj.team_member__c = userCBPS2.Id;
            ctrl.SaveRec();

            system.assert(ApexPages.getMessages().size() == 0);
            
            Test.startTest();

            // will add two CST team members with role CBSM

            p = page.SA_AddCustomClient_UserView;
            p.getParameters().put('id', acc.id);
            p.getParameters().put('Owner', String.valueof(acc.ownerId));
            System.Test.setCurrentPage(p);
            ctrl = new SA_AddCustomClientTeam();
            ctrl.CCTObj.Client_Role__c = 'BCC Service Manager';
            ctrl.CCTObj.team_member__c = userCBSM.Id;
            ctrl.SaveRec();

            system.assert(ApexPages.getMessages().size() == 0);

            p = page.SA_AddCustomClient_UserView;
            p.getParameters().put('id', acc.id);
            p.getParameters().put('Owner', String.valueof(acc.ownerId));
            System.Test.setCurrentPage(p);
            ctrl = new SA_AddCustomClientTeam();
            ctrl.CCTObj.Client_Role__c = 'BCC Service Manager';
            ctrl.CCTObj.team_member__c = userCBSM2.Id;
            ctrl.SaveRec();

            system.assert(ApexPages.getMessages().size() == 0);
        }
    }

    static testMethod void testCreatePotentialClientAsCommBanking() {
        User userCC;

        System.runas(new User(Id = UserInfo.getUserId())) {
            userCC = createUser();
            userCC.user_Division__c = 'Commercial Banking';
            userCC.Division = 'Commercial Banking';
            userCC.business_Unit__c = 'Client Coverage';
            insert userCC;
        }
        system.assert(userCC != null);

        Account acc = createAccount();
        acc.CIF__c = null;
        acc.RecordTypeId = potRecTypeId;
        acc.client_Co_ordinator__c = userCC.id;
        acc.primary_relationship_holder__c = 'Commercial Banking';
        acc.KYC_Location__c = DMN_Account.DEFAULT_COMMB_KYC_LOCATION;

        Test.startTest();

        system.runAs(userCC) {
            insert acc;
            system.debug('###### after inserting acc');

            system.assert(acc.id != null);
        }

        Test.stopTest();

        Account accFetched = [SELECT id, client_Co_ordinator__c
        FROM Account
        WHERE id = :acc.id
        LIMIT 1];

        system.assertEquals(userCC.id, accFetched.client_Co_ordinator__c, 'Client\'s Proposed CC should be the specified user');

        Custom_Client_Team__c cct = [SELECT id, client_Role__c, team_Member__c, client_Coordinator__c
        FROM Custom_Client_Team__c
        WHERE account__c = :acc.id
        LIMIT 1];

        system.assertEquals(userCC.id, cct.team_Member__c);
        system.assertEquals('BCC Relationship Manager', cct.client_Role__c);
        system.assert(cct.client_Coordinator__c, 'CST team role should be marked as CC');
    }

    static testMethod void testCreatePotentialClientAsCorpBanking() {
        User userCC;

        System.runas(new User(Id = UserInfo.getUserId())) {
            userCC = createUser();
            userCC.user_cib_global_area__c = 'CIBSA';
            userCC.user_Division__c = 'Client Coverage';
            userCC.business_Unit__c = 'Client Coverage';
            insert userCC;
        }
        system.assert(userCC != null);

        Account acc = createAccount();
        acc.CIF__c = null;
        acc.RecordTypeId = potRecTypeId;
        acc.client_Co_ordinator__c = userCC.id;


        Test.startTest();

        system.runAs(userCC) {
            insert acc;
        }

        Test.stopTest();

        Account accFetched = [SELECT id, client_Co_ordinator__c
        FROM Account
        WHERE id = :acc.id
        LIMIT 1];

        system.assertEquals(userCC.id, accFetched.client_Co_ordinator__c, 'Client\'s Proposed CC should be the specified user');

        Custom_Client_Team__c cct = [SELECT id, client_Role__c, team_Member__c, client_Coordinator__c
        FROM Custom_Client_Team__c
        WHERE account__c = :acc.id
        LIMIT 1];

        system.assertEquals(userCC.id, cct.team_Member__c);
        system.assertEquals('Manager Client Coverage', cct.client_Role__c);
        system.assert(cct.client_Coordinator__c, 'CST team role should be marked as CC');

    }

    static testMethod void testCreatePotentialClientAsGlobMarkets() {
        User userCC;

        System.runas(new User(Id = UserInfo.getUserId())) {
            userCC = createUser();
            userCC.user_cib_global_area__c = 'CIBSA';
            userCC.user_Division__c = 'Global Markets';
            userCC.business_Unit__c = 'Base Metals';
            insert userCC;
        }
        system.assert(userCC != null);

        Account acc = createAccount();
        acc.CIF__c = null;
        acc.RecordTypeId = potRecTypeId;
        acc.client_Co_ordinator__c = userCC.id;

        Test.startTest();

        system.runAs(userCC) {
            insert acc;
            system.debug('###### after inserting acc');

            system.assert(acc.id != null);
        }

        Test.stopTest();

        Account accFetched = [SELECT id, client_Co_ordinator__c
        FROM Account
        WHERE id = :acc.id
        LIMIT 1];

        system.assertEquals(userCC.id, accFetched.client_Co_ordinator__c, 'Client\'s Proposed CC should be the specified user');

        Custom_Client_Team__c cct = [SELECT id, client_Role__c, team_Member__c, client_Coordinator__c
        FROM Custom_Client_Team__c
        WHERE account__c = :acc.id
        LIMIT 1];

        system.assertEquals(userCC.id, cct.team_Member__c);
        system.assertEquals('Business Development Manager', cct.client_Role__c);
        system.assert(cct.client_Coordinator__c, 'CST team role should be marked as CC');
    }

    static testMethod void testUpdatePotentialClientAsCommBanking() {
        User userCC, userCC2;
        List<User> users = new List<User>();
        User sysAdmin = [Select Id from User Where Name = 'Salesforce Administration'];
        System.runas(new User(Id = UserInfo.getUserId())) {
            userCC = createUser();
            userCC.Division = 'Commercial Banking';
            userCC.user_Division__c = 'Commercial Banking';
            userCC.business_Unit__c = 'Client Coverage';
            users.add(userCC);

            userCC2 = createUser();
            userCC2.Division = 'Commercial Banking';
            userCC2.user_Division__c = 'Commercial Banking';
            userCC2.business_Unit__c = 'Client Coverage';
            users.add(userCC2);

            insert users;
        }
        system.assert(userCC != null && userCC2.id != null);

        Account acc = createAccount(); 
        acc.CIF__c = null;
        acc.RecordTypeId = potRecTypeId;
        acc.client_Co_ordinator__c = userCC.id;
        acc.primary_relationship_holder__c = DMN_Account.HOLDER_COMMB;
        acc.KYC_Location__c = DMN_Account.DEFAULT_COMMB_KYC_LOCATION;

        

        system.runAs(userCC) {
            Test.startTest();
                insert acc;
                system.assert(acc.id != null);

                acc.client_Co_ordinator__c = userCC2.id;
                acc.primary_relationship_holder__c = 'Commercial Banking';
            Test.stopTest();
        }
        System.runAs(sysAdmin){
            TRH_Account.runOnce = true;
            update acc;
        }

        

        Account accFetched = [SELECT id, client_Co_ordinator__c
        FROM Account
        WHERE id = :acc.id
        LIMIT 1];

        system.assertEquals(userCC2.id, accFetched.client_Co_ordinator__c, 'Client\'s Proposed CC should be the new user');

        List<Custom_Client_Team__c> ccts = [SELECT id, client_Role__c, team_Member__c, client_Coordinator__c
        FROM Custom_Client_Team__c
        WHERE account__c = :acc.id];

        system.debug('###test: ccts=' + ccts);
        system.assertEquals(1, ccts.size(), 'There should be a single CST team member');
        system.assertEquals('BCC Relationship Manager', ccts.get(0).client_Role__c);
        system.assert(ccts.get(0).client_Coordinator__c, 'CST team role should be marked as CC');
    }

    static testMethod void testUpdatePotentialClientAsCorpBanking() {
        User sysAdmin = [Select Id from User Where Name = 'Salesforce Administration'];
        User userCC, userCC2;
        List<User> users = new List<User>();

        System.runas(new User(Id = UserInfo.getUserId())) {
            userCC2 = createUser();
            userCC2.user_cib_global_area__c = 'CIBSA';
            userCC2.business_Unit__c = 'Client Coverage';
            users.add(userCC2);

            userCC = createUser();
            userCC.user_cib_global_area__c = 'CIBSA';
            userCC.user_Division__c = 'Global Markets';
            userCC.business_Unit__c = 'Base Metals';
            users.add(userCC);
            insert users;
        }
        system.assert(userCC != null && userCC2.id != null);

        Account acc = createAccount();
        acc.CIF__c = null;
        acc.RecordTypeId = potRecTypeId;
        acc.client_Co_ordinator__c = userCC.id;

        system.runAs(userCC) {
            insert acc;
            system.debug('###### after inserting acc');

            system.assert(acc.id != null);


            acc.client_Co_ordinator__c = userCC2.id;
            acc.primary_relationship_holder__c = 'Personal Banking';
            system.debug('###### after updating acc');
        }
        Test.startTest();
        System.runAs(sysAdmin){
            TRH_Account.runOnce = true;
            update acc;
        }
        Test.stopTest();

        Account accFetched = [SELECT id, client_Co_ordinator__c
        FROM Account
        WHERE id = :acc.id
        LIMIT 1];

        system.assertEquals(userCC2.id, accFetched.client_Co_ordinator__c, 'Client\'s Proposed CC should be the new user');

        List<Custom_Client_Team__c> ccts = [SELECT id, client_Role__c, team_Member__c, client_Coordinator__c
        FROM Custom_Client_Team__c
        WHERE account__c = :acc.id];

        system.debug('###test: ccts=' + ccts);
        system.assertEquals(1, ccts.size(), 'There should be a single CST team member');
        system.assertEquals('Business Development Manager', ccts.get(0).client_Role__c);
        system.assert(ccts.get(0).client_Coordinator__c, 'CST team role should be marked as CC');
    }
    
    static testMethod void testUpdatePotentialClientAsGlobMarkets() {
        User sysAdmin = [Select Id from User Where Name = 'Salesforce Administration'];
        User userCC, userCC2;
        List<User> users = new List<User>();

        System.runas(new User(Id = UserInfo.getUserId())) {
            userCC = createUser();
            userCC.user_cib_global_area__c = 'CIBSA';
            userCC.user_Division__c = 'Global Markets';
            userCC.business_Unit__c = 'Client Coverage';
            users.add(userCC);
 
            userCC2 = createUser();
            userCC2.user_cib_global_area__c = 'CIBSA';
            userCC2.user_Division__c = 'Global Markets';
            userCC2.business_Unit__c = 'Base Metals';
            users.add(userCC2);

            insert users;
        }
        system.assert(userCC != null && userCC2.id != null);

        Account acc = createAccount();
        acc.CIF__c = null;
        acc.RecordTypeId = potRecTypeId;
        acc.client_Co_ordinator__c = userCC.id;
        acc.primary_relationship_holder__c = 'Personal Banking'; 

        system.runAs(userCC) {
                insert acc;
                system.debug('###### after inserting acc');

                system.assert(acc.id != null);

                acc.client_Co_ordinator__c = userCC2.id;
                system.debug('###### after updating acc');

        }
        Test.startTest();
        System.runAs(sysAdmin){
            TRH_Account.runOnce = true;
            update acc;
        }
        Test.stopTest();

        Account accFetched = [SELECT id, client_Co_ordinator__c
        FROM Account
        WHERE id = :acc.id
        LIMIT 1];

        system.assertEquals(userCC2.id, accFetched.client_Co_ordinator__c, 'Client\'s Proposed CC should be the new user');

        List<Custom_Client_Team__c> ccts = [SELECT id, client_Role__c, team_Member__c, client_Coordinator__c
        FROM Custom_Client_Team__c
        WHERE account__c = :acc.id];

        system.debug('###test: ccts=' + ccts);
        system.assertEquals(1, ccts.size(), 'There should be a single CST team member');
        system.assertEquals('Business Development Manager', ccts.get(0).client_Role__c);
        system.assert(ccts.get(0).client_Coordinator__c, 'CST team role should be marked as CC');
    }
}