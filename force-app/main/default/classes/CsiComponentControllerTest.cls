/*************************************************************************
    @ Author        : psvestka
    @ Date          : 20. 10. 2015
    
    @Last Modified Date: 23 Nov 2015
    @Last ModifiedBy: Manoj Gupta
    @Last Modified Reason: TestData failure fixed for EN-701.Changed Overall_CIB_CSI_Rating__c from 3 to 7.
****************************************************************************/

@IsTest
private class CsiComponentControllerTest {
    private final static Map<String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    private final static Id childRecTypeId  = mapAccountRecordTypes.get('Child').getRecordTypeId();

    private static final String CC_USERNAME = 'ccUser@eadwadwa.com';
    private static final String CSTMEM1_USERNAME = 'ctm1User@eadwadwa.com';
    private static final String CSTMEM2_USERNAME = 'ctm2User@eadwadwa.com';

    private static User userCC {
        get {
            if (userCC == null) {
                fetchUsers();
            }
            return userCC;
        }
        set;
    }
    private static User cstMem1 {
        get {
            if (cstMem1 == null) {
                fetchUsers();
            }
            return cstMem1;
        }
        set;
    }
    private static User cstMem2 {
        get {
            if (cstMem2 == null) {
                fetchUsers();
            }
            return cstMem2;
        }
        set;
    }

    private static void fetchUsers() {
        for (User usr : [SELECT Username FROM User WHERE Username IN :(new Set<String> {CC_USERNAME, CSTMEM1_USERNAME, CSTMEM2_USERNAME})]) {
            if (usr.Username == CC_USERNAME) {
                userCC = usr;
            } else if (usr.Username == CSTMEM1_USERNAME) {
                cstMem1 = usr;
            } else if (usr.Username == CSTMEM2_USERNAME) {
                cstMem2 = usr;
            }
        }
    }

    @TestSetup
    private static void prepareData() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getUserProfileIds(),
            TEST_DataFactory.getEnvironmentVariable()
        });

        List<CsiProjectCountry__c> csiProjCtrs = new List<CsiProjectCountry__c>();
        for (String ctry: new String[]{'South Africa','Botswana','Malawi','Tanzania','Kenya','Mauritius','Uganda','Namibia','Mozambique','Ghana','Nigeria','Angola','Zimbabwe','Zambia','Lesotho'}) {
            csiProjCtrs.add(new CsiProjectCountry__c(name = ctry));
        }
        insert csiProjCtrs;

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_USER.useInTestSetup();
        new BLD_USER(uow).useCib().userName(CC_USERNAME).getRecord();
        new BLD_USER(uow).useCib().userName(CSTMEM1_USERNAME).getRecord();
        new BLD_USER(uow).useCib().userName(CSTMEM2_USERNAME).getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow.commitWork();
        }
    }

    private static Account createChildAccount() {
        Account acc = new Account();
        acc.RecordTypeId = childRecTypeId;
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

    private static Client_Satisfaction_Index__c createCsi(Account acc) {
        Client_Satisfaction_Index__c csi = new Client_Satisfaction_Index__c();
        csi.Client__c = acc.id;
        csi.Overall_CIB_CSI_Rating_Number__c = 7;
        csi.Survey_Year__c = '2015';
        csi.csi_project_country__c = 'South Africa';

        return csi;
    }

    private static List<Custom_Client_Team__c> createCsts(Account acc, List<User> cstMembers) {
        if (acc == null || acc.id == null || cstMembers == null || cstMembers.isEmpty()) {
            return new List<Custom_Client_Team__c>();
        }

        List<Custom_Client_Team__c> ccts = new List<Custom_Client_Team__c>();
        List<String> roles = new List<String>{'Analyst', 'Business Development Manager', 'Client Analyst', 'Credit Officer', 'Credit Risk'}; // add more if needed from Setup | Create | Objects | Client Team Custom | Team Role

        for (Integer i = 0; i < cstMembers.size(); i++) {
            Custom_Client_Team__c cct = new Custom_Client_Team__c();
            cct.account__c = acc.Id;
            cct.client_Access__c = 'Read/Write';
            cct.client_Role__c = roles.get(i);
            cct.team_Member__c = cstMembers.get(i).Id;
            ccts.add(cct);
        }

        return ccts;
    }

    static testMethod void testCsiInvalidCountryPrevented() {

        Account acc = createChildAccount();
        acc.Client_Co_ordinator__c = userCC.id;
        insert acc;

        try {
            Client_Satisfaction_Index__c csi = createCsi(acc);
            csi.csi_project_country__c = 'XXX';
            upsert csi;
        } catch (DmlException dmle) {
            system.assert(true);
            return;
        }

        system.assert(false, 'Only certain countries are allowed');
    }

    static testMethod void testMultipleCsiRecordsPerSingleChildClient() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User cstNoMem = (User) new BLD_USER(uow).useCib().getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
        }

        Account childAcc = createChildAccount();
        childAcc.Client_Co_ordinator__c = userCC.id;
        insert childAcc;

        Set<User> cctMemberUsers = new Set<User> {cstMem1, cstMem2};
        List<Custom_Client_Team__c> ccts = createCsts(childAcc, new List<User>(cctMemberUsers));
        insert ccts;

        List<Client_Satisfaction_Index__c> csis = new List<Client_Satisfaction_Index__c>();
        Client_Satisfaction_Index__c csi1 = createCsi(childAcc);
        Client_Satisfaction_Index__c csi2 = createCsi(childAcc);
        csi2.survey_year__c = '2014';

        insert new List<Client_Satisfaction_Index__c>{csi1, csi2};

        Test.startTest();
        Test.stopTest();

        // a no-CST member gets nothing
        system.runAs(cstNoMem) {
            CsiComponentController ccc = new CsiComponentController();
            ccc.accId = childAcc.id;
            ccc.pageController = new ClientPlanClass(new ApexPages.StandardController(childAcc));

            system.assertNotEquals(null, ccc.cwUGP);
            system.assertEquals(null, ccc.cwUGP.csi_client_name);

            system.assertNotEquals(null, ccc.cwsImPMap);
            system.assert(ccc.cwsImPMap.isEmpty());

            system.assertNotEquals(null, ccc.cwsChildMap);
            system.assert(ccc.cwsChildMap.isEmpty());
        }

        // a CST member sees for this Client only Child CSI records
        system.runAs(cstMem1) {
            CsiComponentController ccc = new CsiComponentController();
            ccc.accId = childAcc.id;
            ccc.pageController = new ClientPlanClass(new ApexPages.StandardController(childAcc));

            system.assertNotEquals(null, ccc.cwUGP);
            system.assertEquals(null, ccc.cwUGP.csi_client_name);

            system.assertNotEquals(null, ccc.cwsImPMap);
            system.assert(ccc.cwsImPMap.isEmpty());

            system.assertNotEquals(null, ccc.cwsChildMap);
            system.assertEquals(1, ccc.cwsChildMap.size());
            system.assertEquals(childAcc.name + CsiComponentController.CLIENT_TYPE_CHILD, ccc.cwsChildMap.get(childAcc.id).csi_client_name);
            system.assertEquals(csi1.survey_year__c, ccc.cwsChildMap.get(childAcc.id).survey_year);
        }
    }

    static testMethod void testImmediateParentClient() {

        Account ugPAcc = createChildAccount();
        ugPAcc.name = 'UGP Client';
        ugPAcc.Client_Co_ordinator__c = userCC.id;
        ugPAcc.CRT_Parent_Child__c = 'TP';
        insert ugPAcc;

        Account imPAcc = createChildAccount();
        imPAcc.name = 'ImP Client';
        imPAcc.cif__c = 'ImP 1234';
        imPAcc.Client_Co_ordinator__c = userCC.id;
        impAcc.CRT_Parent_Child__c = 'IP';
        impAcc.parentId = ugPAcc.id;
        insert imPAcc;

        Set<User> cctMemberUsers = new Set<User> {cstMem1};
        List<Custom_Client_Team__c> ccts = createCsts(imPAcc, new List<User>(cctMemberUsers));
        insert ccts;

        List<Client_Satisfaction_Index__c> csis = new List<Client_Satisfaction_Index__c>();
        Client_Satisfaction_Index__c csi1 = createCsi(imPAcc);
        Client_Satisfaction_Index__c csi2 = createCsi(imPAcc);
        csi2.survey_year__c = '2014';

        insert new List<Client_Satisfaction_Index__c>{csi1, csi2};
        Test.startTest();
        Test.stopTest();

        // a CST member sees for the ImP Client only ImP CSI records
        system.runAs(cstMem1) {
            CsiComponentController ccc = new CsiComponentController();
            ccc.accId = imPAcc.id;
            ccc.pageController = new ClientPlanClass(new ApexPages.StandardController(imPAcc));

            system.assertNotEquals(null, ccc.cwUGP);
            system.assertEquals(null, ccc.cwUGP.csi_client_name);

            system.assertNotEquals(null, ccc.cwsImPMap);
            system.assertEquals(1, ccc.cwsImPMap.size());
            system.assertEquals(imPAcc.name + CsiComponentController.CLIENT_TYPE_IMMP, ccc.cwsImPMap.get(imPAcc.id).csi_client_name);
            system.assertEquals(csi1.survey_year__c, ccc.cwsImPMap.get(imPAcc.id).survey_year);

            system.assertNotEquals(null, ccc.cwsChildMap);
            system.assert(ccc.cwsChildMap.isEmpty());
        }

        // a CST member sees for the UGP Client only ImP CSI records
        system.runAs(cstMem1) {
            CsiComponentController ccc = new CsiComponentController();
            ccc.accId = ugPAcc.id;
            ccc.pageController = new ClientPlanClass(new ApexPages.StandardController(ugPAcc));

            system.assertNotEquals(null, ccc.cwUGP);
            system.assertEquals(null, ccc.cwUGP.csi_client_name);

            system.assertNotEquals(null, ccc.cwsImPMap);
            system.assertEquals(1, ccc.cwsImPMap.size());
            system.assertEquals(imPAcc.name + CsiComponentController.CLIENT_TYPE_IMMP, ccc.cwsImPMap.get(imPAcc.id).csi_client_name);
            system.assertEquals(csi1.survey_year__c, ccc.cwsImPMap.get(imPAcc.id).survey_year);

            system.assertNotEquals(null, ccc.cwsChildMap);
            system.assert(ccc.cwsChildMap.isEmpty());
        }
    }

    static testMethod void testImmediateParentClient_2() {

        Account ugPAcc = createChildAccount();
        ugPAcc.name = 'UGP Client';
        ugPAcc.Client_Co_ordinator__c = userCC.id;
        ugPAcc.CRT_Parent_Child__c = 'TP';
        insert ugPAcc;

        Account imPAcc = createChildAccount();
        imPAcc.name = 'ImP Client';
        imPAcc.cif__c = 'ImP 1234';
        imPAcc.Client_Co_ordinator__c = userCC.id;
        impAcc.CRT_Parent_Child__c = 'IP';
        impAcc.parentId = ugPAcc.id;
        insert imPAcc;

        Set<User> cctMemberUsers = new Set<User> {cstMem1};
        List<Custom_Client_Team__c> ccts = createCsts(imPAcc, new List<User>(cctMemberUsers));
        insert ccts;

        List<Client_Satisfaction_Index__c> csis = new List<Client_Satisfaction_Index__c>();
        Client_Satisfaction_Index__c csi1 = createCsi(imPAcc);
        Client_Satisfaction_Index__c csi2 = createCsi(imPAcc);
        csi2.survey_year__c = '2014';

        insert new List<Client_Satisfaction_Index__c>{csi1, csi2};
       

        // put cstMem2 on the UGP Acc's CST team
        insert createCsts(ugPAcc, new List<User>(new Set<User> {cstMem2}));
        // create a CSI for UGP Acc
        insert createCsi(ugPAcc);

        Test.startTest();
        Test.stopTest();

        // cstMem2 from the UGP's point of view should see only UGP's CSI
        system.runAs(cstMem2) {
            CsiComponentController ccc = new CsiComponentController();
            ccc.accId = ugPAcc.id;
            ccc.pageController = new ClientPlanClass(new ApexPages.StandardController(ugPAcc));

            system.assertNotEquals(null, ccc.cwUGP);
            system.assertEquals(ugPAcc.name + CsiComponentController.CLIENT_TYPE_UGP, ccc.cwUGP.csi_client_name);

            system.assertNotEquals(null, ccc.cwsImPMap);
            system.assert(ccc.cwsImPMap.isEmpty());

            system.assertNotEquals(null, ccc.cwsChildMap);
            system.assert(ccc.cwsChildMap.isEmpty());
        }
    }

    static testMethod void testUGParentClientWithChildren() {

        Account ugPAcc = createChildAccount();
        ugPAcc.name = 'UGP Client';
        ugPAcc.Client_Co_ordinator__c = userCC.id;
        ugPAcc.CRT_Parent_Child__c = 'TP';
        insert ugPAcc;

        Account childAcc = createChildAccount();
        childAcc.name = 'Child Client';
        childAcc.cif__c = 'Child 1234';
        childAcc.Client_Co_ordinator__c = userCC.id;
        childAcc.parentId = ugPAcc.id;
        insert childAcc;

        Set<User> cctMemberUsers = new Set<User> {cstMem1};
        List<Custom_Client_Team__c> ccts = createCsts(childAcc, new List<User>(cctMemberUsers));
        insert ccts;

        List<Client_Satisfaction_Index__c> csis = new List<Client_Satisfaction_Index__c>();
        Client_Satisfaction_Index__c csi1 = createCsi(childAcc);

        insert new List<Client_Satisfaction_Index__c>{csi1};

        Test.startTest();
        Test.stopTest();

        // a CST member sees for the Child Client only Child CSI records
        system.runAs(cstMem1) {
            CsiComponentController ccc = new CsiComponentController();
            ccc.accId = childAcc.id;
            ccc.pageController = new ClientPlanClass(new ApexPages.StandardController(childAcc));

            system.assertNotEquals(null, ccc.cwUGP);
            system.assertEquals(null, ccc.cwUGP.csi_client_name);

            system.assertNotEquals(null, ccc.cwsImPMap);
            system.assert(ccc.cwsImPMap.isEmpty());

            system.assertNotEquals(null, ccc.cwsChildMap);
            system.assertEquals(1, ccc.cwsChildMap.size());
            system.assertEquals(childAcc.name + CsiComponentController.CLIENT_TYPE_CHILD, ccc.cwsChildMap.get(childAcc.id).csi_client_name);
            system.assertEquals(csi1.survey_year__c, ccc.cwsChildMap.get(childAcc.id).survey_year);
        }

        // a CST member sees for the UGP Client only Child CSI records
        system.runAs(cstMem1) {
            CsiComponentController ccc = new CsiComponentController();
            ccc.accId = ugPAcc.id;
            ccc.pageController = new ClientPlanClass(new ApexPages.StandardController(ugPAcc));

            system.assertNotEquals(null, ccc.cwUGP);
            system.assertEquals(null, ccc.cwUGP.csi_client_name);

            system.assertNotEquals(null, ccc.cwsImPMap);
            system.assert(ccc.cwsImPMap.isEmpty());

            system.assertNotEquals(null, ccc.cwsChildMap);
            system.assertEquals(1, ccc.cwsChildMap.size());
            system.assertEquals(childAcc.name + CsiComponentController.CLIENT_TYPE_CHILD, ccc.cwsChildMap.get(childAcc.id).csi_client_name);
            system.assertEquals(csi1.survey_year__c, ccc.cwsChildMap.get(childAcc.id).survey_year);
        }
    }

    static testMethod void testUGParentClientWithChildrenWithoutCsi() {

        Account ugPAcc = createChildAccount();
        ugPAcc.name = 'UGP Client';
        ugPAcc.Client_Co_ordinator__c = userCC.id;
        ugPAcc.CRT_Parent_Child__c = 'TP';
        insert ugPAcc;

        Account childAcc = createChildAccount();
        childAcc.name = 'Child Client';
        childAcc.cif__c = 'Child 1234';
        childAcc.Client_Co_ordinator__c = userCC.id;
        childAcc.parentId = ugPAcc.id;
        insert childAcc;

        Set<User> cctMemberUsers = new Set<User> {cstMem1};
        List<Custom_Client_Team__c> ccts = createCsts(childAcc, new List<User>(cctMemberUsers));
        insert ccts;

        // no CSI records are created

        // a CST member sees for the Child Client no Child, since there's no CSI for it
        system.runAs(cstMem1) {
            CsiComponentController ccc = new CsiComponentController();
            ccc.accId = childAcc.id;
            ccc.pageController = new ClientPlanClass(new ApexPages.StandardController(childAcc));

            system.assertNotEquals(null, ccc.cwUGP);
            system.assertEquals(null, ccc.cwUGP.csi_client_name);

            system.assertNotEquals(null, ccc.cwsImPMap);
            system.assert(ccc.cwsImPMap.isEmpty());

            system.assertNotEquals(null, ccc.cwsChildMap);
            system.assertEquals(0, ccc.cwsChildMap.size());
        }

        // a CST member sees for the UGP Client no Child, since there's no CSI for it
        system.runAs(cstMem1) {
            CsiComponentController ccc = new CsiComponentController();
            ccc.accId = ugPAcc.id;
            ccc.pageController = new ClientPlanClass(new ApexPages.StandardController(ugPAcc));

            system.assertNotEquals(null, ccc.cwUGP);
            system.assertEquals(null, ccc.cwUGP.csi_client_name);

            system.assertNotEquals(null, ccc.cwsImPMap);
            system.assert(ccc.cwsImPMap.isEmpty());

            system.assertNotEquals(null, ccc.cwsChildMap);
            system.assertEquals(0, ccc.cwsChildMap.size());
        }
    }
}