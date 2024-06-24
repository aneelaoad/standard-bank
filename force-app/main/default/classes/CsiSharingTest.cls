/*************************************************************************
    @ Author        : psvestka
    @ Date          : 5. 10. 2015
    @ Test File     : CsiSharingTest
    @ Description   : EN-865
    
    @Last Modified Date: 23 Nov 2015
    @Last ModifiedBy: Manoj Gupta
    @Last Modified Reason: TestData failure fixed for EN-701
    
    @Last Modified Date: 04 Dec 2015
    @Last ModifiedBy: Manoj Gupta
    @Last Modified Reason: EN:981 Including method removeCstMemberasCCFromClientWithCsi to check this functionality logged in as CC.
    
    @Last Modified Date: 16 Nov 2016
    @Last ModifiedBy: Abhishek V
    @Last Modified Reason: Mixed DML operation error fix
****************************************************************************/

@IsTest
public class CsiSharingTest {

    private final static String CSI_SHARING_REASON = Schema.Client_Satisfaction_Index__Share.rowCause.CST_Member_Can_Read_CSI_Records__c;
    private static Map<String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    private final static Id childRecTypeId = mapAccountRecordTypes.get('Child').getRecordTypeId();

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

    /**************************
     Manipulating CSI
     *************************/
     
    static testMethod void insertCsiToClientWithoutCst() {
        Account acc = createChildAccount();
        acc.Client_Co_ordinator__c = userCC.id;
        insert acc;

        Client_Satisfaction_Index__c csi = createCsi(acc);
        insert csi;

        Test.startTest();
        Test.stopTest();

        List<Client_Satisfaction_Index__Share> csiShares = [SELECT id
                                                              FROM Client_Satisfaction_Index__Share
                                                             WHERE rowCause = :CSI_SHARING_REASON
                                                               AND parentId = :csi.id];
        system.assertEquals(0, csiShares.size());
    }
    
    static testMethod void insertCsiToClientWithCst() {
        Account acc = createChildAccount();
        acc.Client_Co_ordinator__c = userCC.id;
        insert acc;

        Set<User> cctMemberUsers = new Set<User> {cstMem1, cstMem2};
        List<Custom_Client_Team__c> ccts = createCsts(acc, new List<User>(cctMemberUsers));
        insert ccts;

        Client_Satisfaction_Index__c csi = createCsi(acc);
        String expectedYear = csi.survey_year__c;
        insert csi;

        Test.startTest();
        Test.stopTest();
        List<Client_Satisfaction_Index__Share> csiShares = [SELECT id, rowCause, parentId, userOrGroupId, accessLevel
                                                              FROM Client_Satisfaction_Index__Share
                                                             WHERE rowCause = :CSI_SHARING_REASON
                                                               AND parentId = :csi.id
                                                               AND userOrGroupId IN :cctMemberUsers
                                                               AND accessLevel = 'Read'];
        system.assertEquals(2, csiShares.size());

        Account accWithYear = [SELECT id, survey_year__c FROM Account WHERE id = :acc.id LIMIT 1];
    
        system.assertNotEquals(null, accWithYear);
        system.assertEquals(expectedYear, accWithYear.survey_year__c);
    }

    static testMethod void upsertCsiToClientWithCst() {
        Account acc = createChildAccount();
        acc.Client_Co_ordinator__c = userCC.id;
        insert acc;

        Set<User> cctMemberUsers = new Set<User> {cstMem1, cstMem2};
        List<Custom_Client_Team__c> ccts = createCsts(acc, new List<User>(cctMemberUsers));
        insert ccts;

        Client_Satisfaction_Index__c csi = createCsi(acc);
        insert csi;

        csi.Overall_CIB_CSI_Rating_Number__c = 8; // changed value
        upsert csi;

        Test.startTest();
        Test.stopTest();
        List<Client_Satisfaction_Index__Share> csiShares = [SELECT id, rowCause, parentId, userOrGroupId, accessLevel
                                                              FROM Client_Satisfaction_Index__Share
                                                             WHERE rowCause = :CSI_SHARING_REASON
                                                               AND parentId = :csi.id
                                                               AND userOrGroupId IN :cctMemberUsers
                                                               AND accessLevel = 'Read'];
        system.assertEquals(2, csiShares.size());
    }

    static testMethod void deleteCsiFromClientWithCst() {

        Account acc = createChildAccount();
        acc.Client_Co_ordinator__c = userCC.id;
        insert acc;

        Set<User> cctMemberUsers = new Set<User> {cstMem1, cstMem2};
        List<Custom_Client_Team__c> ccts = createCsts(acc, new List<User>(cctMemberUsers));
        insert ccts;

        Client_Satisfaction_Index__c csi2015 = createCsi(acc);
        insert csi2015;

        Client_Satisfaction_Index__c csi2014 = createCsi(acc);
        csi2014.Survey_Year__c = '2014';
        insert csi2014;

        delete csi2014;

        Test.startTest();
        Test.stopTest();
        List<Client_Satisfaction_Index__Share> csiShares = [SELECT id, rowCause, parentId, userOrGroupId, accessLevel
                                                              FROM Client_Satisfaction_Index__Share
                                                             WHERE rowCause = :CSI_SHARING_REASON
                                                               AND parentId = :csi2015.id
                                                               AND userOrGroupId IN :cctMemberUsers
                                                               AND accessLevel = 'Read'];

        system.assertEquals(2, csiShares.size());

        List<Client_Satisfaction_Index__Share> csiSharesDeleted = [SELECT id, rowCause, parentId, userOrGroupId, accessLevel
                                                                     FROM Client_Satisfaction_Index__Share
                                                                    WHERE rowCause = :CSI_SHARING_REASON
                                                                      AND parentId = :csi2014.id
                                                                      AND userOrGroupId IN :cctMemberUsers
                                                                      AND accessLevel = 'Read'];
        
        system.assertEquals(0, csiSharesDeleted.size());
    }
    
    /**************************
     Manipulating CST
     *************************/
    
    static testMethod void insertCstMembersToClientWithoutCsi() {

        Account acc = createChildAccount();
        acc.Client_Co_ordinator__c = userCC.id;
        insert acc;

        Set<User> cctMemberUsers = new Set<User> {cstMem1, cstMem2};
        List<Custom_Client_Team__c> ccts = createCsts(acc, new List<User>(cctMemberUsers));
        insert ccts;

        Test.startTest();
        Test.stopTest();
        List<Client_Satisfaction_Index__Share> csiShares = [SELECT id
                                                              FROM Client_Satisfaction_Index__Share
                                                             WHERE rowCause = :CSI_SHARING_REASON];
        
        system.assertEquals(0, csiShares.size());
    }

    static testMethod void insertCstMembersToClientWithCsi() {

        Account acc = createChildAccount();
        acc.Client_Co_ordinator__c = userCC.id;
        insert acc;

        Client_Satisfaction_Index__c csi = createCsi(acc);
        insert csi;

        Set<User> cctMemberUsers = new Set<User>{cstMem1, cstMem2};
        List<Custom_Client_Team__c> ccts = createCsts(acc, new List<User>(cctMemberUsers));
        insert ccts;

        Test.startTest();
        Test.stopTest();
        List<Client_Satisfaction_Index__Share> csiShares = [SELECT id, rowCause, parentId, userOrGroupId, accessLevel
                                                              FROM Client_Satisfaction_Index__Share
                                                             WHERE rowCause = :CSI_SHARING_REASON
                                                               AND parentId = :csi.id
                                                               AND userOrGroupId IN :cctMemberUsers
                                                               AND accessLevel = 'Read'];
        
        system.assertEquals(2, csiShares.size());
    }

    static testMethod void updateCstMemberOnClientWithCsi() {

        Account acc = createChildAccount();
        acc.Client_Co_ordinator__c = userCC.id;
        insert acc;

        Client_Satisfaction_Index__c csi = createCsi(acc);
        insert csi;

        Set<User> cctMemberUsers = new Set<User> {cstMem1, cstMem2};
        List<Custom_Client_Team__c> ccts = createCsts(acc, new List<User>(cctMemberUsers));
        insert ccts;
 
        ccts.get(1).client_Role__c = 'Transaction Solutions Manager';
        update ccts.get(1);

        Test.startTest();
        Test.stopTest();
        List<Client_Satisfaction_Index__Share> csiShares = [SELECT id, rowCause, parentId, userOrGroupId, accessLevel
                                                              FROM Client_Satisfaction_Index__Share
                                                             WHERE rowCause = :CSI_SHARING_REASON
                                                               AND parentId = :csi.id
                                                               AND userOrGroupId IN :cctMemberUsers
                                                               AND accessLevel = 'Read'];
        
        system.assertEquals(2, csiShares.size());
    }

    static testMethod void removeCstMemberFromClientWithCsi() {

        Account acc = createChildAccount();
        acc.Client_Co_ordinator__c = userCC.id;
        insert acc;

        Client_Satisfaction_Index__c csi = createCsi(acc);
        insert csi;

        Set<User> cctMemberUsers = new Set<User> {cstMem1, cstMem2};
        List<Custom_Client_Team__c> ccts = createCsts(acc, new List<User>(cctMemberUsers));
        insert ccts;

        delete ccts.get(1);

        Test.startTest();
        Test.stopTest();
        List<Client_Satisfaction_Index__Share> csiShares = [SELECT id, rowCause, parentId, userOrGroupId, accessLevel
                                                              FROM Client_Satisfaction_Index__Share
                                                             WHERE rowCause = :CSI_SHARING_REASON
                                                               AND parentId = :csi.id
                                                               AND userOrGroupId IN :cctMemberUsers
                                                               AND accessLevel = 'Read'];

        system.assertEquals(1, csiShares.size());
    }
    
    
     static testMethod void removeCstMemberasCCFromClientWithCsi() {

        Account acc = createChildAccount();
        acc.Client_Co_ordinator__c = userCC.id;
        insert acc;

        Client_Satisfaction_Index__c csi = createCsi(acc);
        insert csi;

        Set<User> cctMemberUsers = new Set<User> {cstMem1, cstMem2, userCC};
        List<Custom_Client_Team__c> ccts = createCsts(acc, new List<User>(cctMemberUsers));
        insert ccts;
 
        //System.runas(users[0]){
            delete ccts.get(1);
       // }

        Test.startTest();
        Test.stopTest();
        List<Client_Satisfaction_Index__Share> csiShares = [SELECT id, rowCause, parentId, userOrGroupId, accessLevel
                                                              FROM Client_Satisfaction_Index__Share
                                                             WHERE rowCause = :CSI_SHARING_REASON
                                                               AND parentId = :csi.id
                                                               AND userOrGroupId IN :cctMemberUsers
                                                               AND accessLevel = 'Read'];
        
        system.assertEquals(2, csiShares.size());
    }

    static testMethod void deleteClient() {

        Account acc = createChildAccount();
        acc.Client_Co_ordinator__c = userCC.id;
        insert acc;

        Client_Satisfaction_Index__c csi = createCsi(acc);
        insert csi;

        Set<User> cctMemberUsers = new Set<User> {cstMem1, cstMem2};
        List<Custom_Client_Team__c> ccts = createCsts(acc, new List<User>(cctMemberUsers));
        insert ccts;

        delete acc;

        Test.startTest();
        Test.stopTest();
        List<Client_Satisfaction_Index__Share> csiShares = [SELECT id, rowCause, parentId, userOrGroupId, accessLevel
                                                              FROM Client_Satisfaction_Index__Share
                                                             WHERE rowCause = :CSI_SHARING_REASON
                                                               AND parentId = :csi.id
                                                               AND userOrGroupId IN :cctMemberUsers
                                                               AND accessLevel = 'Read'];
        
        system.assertEquals(0, csiShares.size());
    }

    static testMethod void checkNoVisibilityThruUserHierarchies() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User cstMem = (User) new BLD_USER(uow).useCib().getRecord();
        User userMan = (User) new BLD_USER(uow).useCib().getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
        }

        Account acc = createChildAccount();
        acc.Client_Co_ordinator__c = userCC.id;
        insert acc;

        Client_Satisfaction_Index__c csi = createCsi(acc);
        insert csi;

        Set<User> cctMemberUsers = new Set<User>{cstMem};
        List<Custom_Client_Team__c> ccts = createCsts(acc, new List<User>(cctMemberUsers));
        insert ccts;

        Test.startTest();
        Test.stopTest();
        List<Client_Satisfaction_Index__Share> csiShares = [SELECT id, rowCause, parentId, userOrGroupId, accessLevel
                                                              FROM Client_Satisfaction_Index__Share
                                                             WHERE rowCause = :CSI_SHARING_REASON
                                                               AND parentId = :csi.id
                                                               AND userOrGroupId IN :cctMemberUsers
                                                               AND accessLevel = 'Read'];
        List<Client_Satisfaction_Index__c> csiSharedToManager;
        system.runAs(userMan) {
            csiSharedToManager = [SELECT id
                                    FROM Client_Satisfaction_Index__c
                                   WHERE client__c = :acc.id];

            
        }

        
        system.assertEquals(1, csiShares.size());
        system.assertNotEquals(null, csiSharedToManager);
        system.assertEquals(0, csiSharedToManager.size());
    }
}