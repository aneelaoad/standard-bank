/**
 * Test class for DMN_Account class
 *
 * @author      
 * @date        
 * 
 *****************************************************************************************
 *  2022-04-04  Maham HAssan    Added a test method for record completeness.
 *  2023-09-18  Derek Hughes    Workaround:  Move some test data generation code after startTest() to avoid SOQL limits
 *                              Added some System.debug statements to help monitor SOQL usage - RETAIN FOR NOW
 * 
 *****************************************************************************************
 */
@isTest
public without sharing class DMN_Account_TEST {
    public static final String 
    TASK_SUBJECT        = 'Update FAIS Information of recurring batch test acc',
    TEST_USER_NAME_1    = 'test.StdBank_Ltn_Ecosystem_Test@test.com',
    TEST_USER_NAME_2    = '2test.StdBank_Ltn_Ecosystem_Test@test.com',
    TEST_USER_NAME_3    = '3test.StdBank_Ltn_Ecosystem_Test@test.com',
    TEST_USER_NAME_4    = '4test.StdBank_Ltn_Ecosystem_Test@test.com',
    TEST_USER_NAME_5    = '5test.StdBank_Ltn_Ecosystem_Test@test.com',
    DEF_ACC_NAME        = 'Def Name for Acc',
    DEF_ACC_NAME5       = 'Def Name for Acc5',
    DEF_ACC_NAME_IMM    = 'Def Name for Immm',
    DEF_ACC_NAME_CHILD  = 'Def Name for Child',
    GROUP_NUMBER        = '1234';

    private static User testUser1;
    private static User testUser2;
    private static User testUser3;
    private static User testUser4;
    private static User testUser5;
    private static Account acc;
    private static Account child;
    private static Account grandChild;
    private static Task task;

    private static void getData(){
        getUsers();
        getAccounts();
    }

    private static void getUsers() {
        for(User usr : [  SELECT Username
        FROM User
        WHERE UserName =: TEST_USER_NAME_1
        OR UserName =: TEST_USER_NAME_2
        OR UserName =: TEST_USER_NAME_3
        OR UserName =: TEST_USER_NAME_4
        OR UserName =: TEST_USER_NAME_5
        LIMIT 5]){
            if(usr.UserName == TEST_USER_NAME_1){
                testUser1 = usr;
            }
            if(usr.UserName == TEST_USER_NAME_2){
                testUser2 = usr;
            }
            if(usr.UserName == TEST_USER_NAME_3){
                testUser3 = usr;
            }
            if (usr.UserName == TEST_USER_NAME_4) {
                testUser4 = usr;
            }
            if (usr.UserName == TEST_USER_NAME_5) {
                testUser5 = usr;
            }
        }
    }

    private static void getAccounts() {
        for(Account accRec : [  SELECT Name, Client_Co_ordinator__c, Client_Coordinator_Division__c,
                Client_Sector__c, RecordTypeId, FAIS_reminder__c, RecordType.Name
        FROM Account
        WHERE Name  =: DEF_ACC_NAME
        OR Name =: DEF_ACC_NAME_IMM
        OR Name =: DEF_ACC_NAME_CHILD
        LIMIT 3]){
            if(accRec.Name == DEF_ACC_NAME){
                acc = accRec;
            }
            if(accRec.Name == DEF_ACC_NAME_IMM){
                child = accRec;
            }
            if(accRec.Name == DEF_ACC_NAME_CHILD){
                grandChild = accRec;
            }
        }
    }
    
    @testSetup
    private static void setup(){

        // 0 SOQL Statements to start
        System.debug('setup: START: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));

        TEST_DataFactory.generateConfiguration();

        // above block uses 20 SOQL statements
        System.debug('setup: CHECK 1: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));

        fflib_SObjectUnitOfWork uow;
        System.runAs(new User(Id = UserInfo.getUserId())){
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

            testUser1 = (User)new BLD_USER(uow).userName(TEST_USER_NAME_1).useCommB().syncContact().getRecord();
            testUser2 = (User)new BLD_USER(uow).userName(TEST_USER_NAME_2).useCommB().syncContact().getRecord();
            testUser3 = (User)new BLD_USER(uow).userName(TEST_USER_NAME_3).useCommB().syncContact().getRecord();
            testUser4 = (User)new BLD_USER(uow).userName(TEST_USER_NAME_4).useCib().syncContact().getRecord();
            testUser5 = (User)new BLD_User(uow).userName(TEST_USER_NAME_5).useAPIUser().getRecord();
            uow.commitWork();
        }

        // above block uses 3 SOQL statements
        System.debug('setup: CHECK 2: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));
        
        System.runAs(testUser1) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            ABS_ObjectBuilderBase accBld = new BLD_Account(uow)
                .name(DEF_ACC_NAME)
                .useCommB()
                .useGroupParent()
                .groupNumber(GROUP_NUMBER)
                .addContact(
                    new BLD_Contact(uow)
                    .useClientContact()
                );

            System.debug('setup: CHECK 3a: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));
            
            accBld.commitWork();
               
            // above block uses 9 SOQL statements
            System.debug('setup: CHECK 3b: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));

            ABS_ObjectBuilderBase childAcc = new BLD_Account().name(DEF_ACC_NAME_IMM).useCommB().useImmediateParent(accBld.getRecordId()).groupNumber(GROUP_NUMBER).commitWork();
            
            // above statement uses 7 SOQL statements
            System.debug('setup: CHECK 3c: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));
            
            ABS_ObjectBuilderBase grandchildAcc = new BLD_Account().name(DEF_ACC_NAME_CHILD).useCommB().useChild(childAcc.getRecordId(), childAcc.getRecordId()).groupNumber(GROUP_NUMBER ).commitWork();
            
            // above statement uses 8 SOQL statements
            System.debug('setup: CHECK 3d: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));
            
            task = (Task) new BLD_Task(uow)
                .subject(TASK_SUBJECT)
                .itemToAction()
                .linkToParent(
                    accBld
                ).getRecord();

            uow.commitWork();
            // this statement uses 3 SOQL statements
            System.debug('setup: DONE: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));
        }

        // test setup uses 50 SOQL statements in total
             
    }

    @IsTest
    public static void shouldUpdateGpIpAndPpcThirdLevel() {
        getData();
        fflib_SObjectUnitOfWork fflibSObjectUnitOfWork = ABS_ObjectBuilderBase.getNewUnitOfWork();
        acc = (Account)new BLD_Account(acc, fflibSObjectUnitOfWork).CIF('grand parent').getRecord();
        child = (Account) new BLD_Account(child, fflibSObjectUnitOfWork).CIF('parent').getRecord();
        grandChild = (Account) new BLD_Account(grandChild, fflibSObjectUnitOfWork).useRecordType(DMN_Account.RT_LOCKED_POTENTIAL_CIF)
                .proposedClientCoordinator(testUser1)
                .clientRelationshipHierarchy(DMN_Account.REL_HIERARCHY_CHILD).getRecord();

        System.runAs(testUser1) {
            update new List<Account>{acc, child, grandChild};
        }

        System.runAs(testUser1) {
            Test.startTest();
            update grandChild;
            Test.stopTest();
        }
        grandChild = [
                SELECT Parent.Name, Parent.Parent.Name, Parent.CIF__c, Parent.Parent.CIF__c, Name, CIF_Number_of_Proposed_Group_Parent__c, CIF__c, CIF_Number_of_Proposed_Immediate_Parent__c, GP_IP_PPC_Are_Changed__c,
                        Proposed_Group_Parent__c, Proposed_Immediate_Parent__c, Proposed_Parent_Client__c
                FROM Account WHERE Id = :grandChild.Id
        ];
        Assert.areEqual(grandChild.Parent.Parent.CIF__c, grandChild.CIF_Number_of_Proposed_Group_Parent__c);
        Assert.areEqual(grandChild.Parent.CIF__c, grandChild.CIF_Number_of_Proposed_Immediate_Parent__c);
        Assert.areNotEqual(null, grandChild.GP_IP_PPC_Are_Changed__c);
        Assert.areEqual(grandChild.Parent.Parent.Name, grandChild.Proposed_Group_Parent__c);
        Assert.areEqual(grandChild.Parent.Name, grandChild.Proposed_Immediate_Parent__c);
        Assert.areEqual(grandChild.Parent.Name, grandChild.Proposed_Parent_Client__c);
    }

    @IsTest
    public static void shouldUpdateGpIpAndPpcSecondLevel() {
        getData();
        Account parent;
        Account testAccountChild;
        Account testAccountImmedParent;
		Test.startTest();
        parent = (Account) new BLD_Account().name('Parent').useCommB().CIF('CIF Parent').getRecord();
        System.runAs(testUser1) {
            insert parent;
        }

        testAccountChild = (Account) new BLD_Account().name('A child').useRecordType(DMN_Account.RT_POTENTIAL_CLIENT)
                .kycLocation(DMN_Account.DEFAULT_COMMB_KYC_LOCATION).proposedClientCoordinator(testUser1)
                .clientRelationshipHierarchy(DMN_Account.REL_HIERARCHY_CHILD)
                .parentId(parent)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_COMMB).getRecord();

        testAccountImmedParent = (Account)testAccountChild.clone(false, true, false, false);
        testAccountImmedParent.Client_Relationship_Hierarchy__c = DMN_Account.REL_HIERARCHY_IMMEDIATE;
        testAccountImmedParent.Name = 'An Immediate parent';

        List<Account> accounts = new List<Account>{testAccountChild, testAccountImmedParent};
        System.runAs(testUser1) {
            insert accounts;     // the records type will be potential
            testAccountChild.CIF__c = 'CIF Child';
            testAccountImmedParent.CIF__c = 'CIF Immediate Parent';
            
            update accounts;
            
        }
        Map<Id, Account> idToAccount = new Map<Id, Account>([
                SELECT Parent.Name, Parent.CIF__c, Name, CIF_Number_of_Proposed_Group_Parent__c, CIF__c, CIF_Number_of_Proposed_Immediate_Parent__c, GP_IP_PPC_Are_Changed__c,
                        Proposed_Group_Parent__c, Proposed_Immediate_Parent__c, Proposed_Parent_Client__c
                FROM Account WHERE Id IN :accounts
        ]);
        testAccountChild = idToAccount.get(testAccountChild.Id);
        testAccountImmedParent = idToAccount.get(testAccountImmedParent.Id);

        Assert.areEqual(testAccountChild.Parent.CIF__c, testAccountChild.CIF_Number_of_Proposed_Group_Parent__c);
        Assert.areEqual(testAccountChild.Parent.CIF__c, testAccountChild.CIF_Number_of_Proposed_Immediate_Parent__c);
        Assert.areNotEqual(null, testAccountChild.GP_IP_PPC_Are_Changed__c);
        Assert.areEqual(testAccountChild.Parent.Name, testAccountChild.Proposed_Group_Parent__c);
        Assert.areEqual(testAccountChild.Parent.Name, testAccountChild.Proposed_Immediate_Parent__c);
        Assert.areEqual(testAccountChild.Parent.Name, testAccountChild.Proposed_Parent_Client__c);

        Assert.areEqual(testAccountImmedParent.Parent.CIF__c, testAccountImmedParent.CIF_Number_of_Proposed_Group_Parent__c);
        Assert.areEqual(testAccountImmedParent.CIF__c, testAccountImmedParent.CIF_Number_of_Proposed_Immediate_Parent__c);
        Assert.areNotEqual(null, testAccountImmedParent.GP_IP_PPC_Are_Changed__c);
        Assert.areEqual(testAccountImmedParent.Parent.Name, testAccountImmedParent.Proposed_Group_Parent__c);
        Assert.areEqual(testAccountImmedParent.Name, testAccountImmedParent.Proposed_Immediate_Parent__c);
        Assert.areEqual(testAccountImmedParent.Parent.Name, testAccountImmedParent.Proposed_Parent_Client__c);
        Test.stopTest();
    }

    @IsTest
    public static void shouldUpdateGpIpAndPpcFirstLevel() {
        getData();
        Test.startTest();
        Account testAccount = (Account) new BLD_Account().name('A potential').useRecordType(DMN_Account.RT_POTENTIAL_CLIENT)
                .proposedClientCoordinator(testUser4)
                .clientRelationshipHierarchy(DMN_Account.REL_HIERARCHY_ULTIMATE)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB).getRecord();
        System.runAs(testUser4) {
            insert testAccount;     // the record type will be Potential client
            testAccount = [SELECT RecordTypeId, Client_Relationship_Hierarchy__c, Primary_Relationship_Holder__c FROM Account WHERE Id = :testAccount.Id];
            testAccount.CIF__c = 'CIF Number';
            
            update testAccount;
            
            testAccount = [SELECT Name, CIF_Number_of_Proposed_Group_Parent__c, CIF__c, CIF_Number_of_Proposed_Immediate_Parent__c, GP_IP_PPC_Are_Changed__c,
                    Proposed_Group_Parent__c, Proposed_Immediate_Parent__c, Proposed_Parent_Client__c
            FROM Account WHERE Id = :testAccount.Id];

            Assert.areEqual(testAccount.CIF__c, testAccount.CIF_Number_of_Proposed_Group_Parent__c);
            Assert.areEqual(testAccount.CIF__c, testAccount.CIF_Number_of_Proposed_Immediate_Parent__c);

            Assert.areNotEqual(null, testAccount.GP_IP_PPC_Are_Changed__c);
            Assert.areEqual(testAccount.Name, testAccount.Proposed_Group_Parent__c);
            Assert.areEqual(testAccount.Name, testAccount.Proposed_Immediate_Parent__c);
            Assert.areEqual(testAccount.Name, testAccount.Proposed_Parent_Client__c);
            Test.stopTest();
        }
    }

    @IsTest
    public static void shouldUpdateGpIpAndPccToNull() {
        getData();
        Test.startTest();
        Account testAccount = (Account) new BLD_Account().name('A potential').useRecordType(DMN_Account.RT_POTENTIAL_CLIENT)
                .kycLocation(DMN_Account.DEFAULT_COMMB_KYC_LOCATION).proposedClientCoordinator(testUser4)
                .CIF('CIF Number').getRecord();
        System.runAs(testUser4) {
            insert testAccount;     // the record will have Potential client record type
            testAccount = [SELECT RecordTypeId, Name FROM Account WHERE Id = :testAccount.Id];
            testAccount.Update_Path__c = false;
            testAccount.CIF_Number_of_Proposed_Group_Parent__c = 'CIF Number of Proposed Group Parent';
            testAccount.Proposed_Group_Parent__c = 'Proposed Group Parent';
            testAccount.Proposed_Immediate_Parent__c = 'Proposed Immediate Parent';
            testAccount.Proposed_Parent_Client__c = 'Proposed Parent Client';
            
            update testAccount;
            
            testAccount = [SELECT CIF_Number_of_Proposed_Group_Parent__c, CIF__c, GP_IP_PPC_Are_Changed__c, Proposed_Group_Parent__c,
                    Proposed_Immediate_Parent__c, Proposed_Parent_Client__c FROM Account WHERE Id = :testAccount.Id];
            Test.stopTest();
        }
        Assert.areEqual(null, testAccount.CIF_Number_of_Proposed_Group_Parent__c);
        Assert.areEqual(null, testAccount.CIF__c);
        Assert.areNotEqual(null,  testAccount.GP_IP_PPC_Are_Changed__c);
    }

    @IsTest
    public static void shouldUpdatePathStepAndRecordType() {
        getData();
        Test.startTest();
        List<Account> testAccounts = new List<Account>{
                (Account) new BLD_Account().name('A prospect').useRecordType(DMN_Account.RT_PROSPECT)
                        .usePathStep(DMN_Account.PT_STEPS_CREATE_PROSPECT).proposedClientCoordinator(testUser1)
                        .kycLocation(DMN_Account.DEFAULT_COMMB_KYC_LOCATION).getRecord(),

                (Account) new BLD_Account().name('A prospect').useRecordType(DMN_Account.RT_PROSPECT)
                        .usePathStep(DMN_Account.PT_STEPS_DEVELOP_PROSPECT).proposedClientCoordinator(testUser1)
                        .kycLocation(DMN_Account.DEFAULT_COMMB_KYC_LOCATION).useRelationshipRole(DMN_Account.REL_ROLE_CLIENT).getRecord(),

                (Account) new BLD_Account().name('A prospect').useRecordType(DMN_Account.RT_PROSPECT)
                        .usePathStep(DMN_Account.PT_STEPS_DEVELOP_PROSPECT).proposedClientCoordinator(testUser1)
                        .kycLocation(DMN_Account.DEFAULT_COMMB_KYC_LOCATION).useRelationshipRole(DMN_Account.REL_ROLE_EXCHANGE).getRecord()
        };
        List<Account> testAccountsAfterFirstUpdate = new List<Account>();
        List<Account> testAccountsAfterSecondUpdate = new List<Account>();
        System.runAs(testUser1) {
            insert testAccounts;
            testAccounts[0].Update_Path__c = testAccounts[1].Update_Path__c = testAccounts[2].Update_Path__c = true;
            update testAccounts;
            Map<Id, Account> idToAccount = new Map<Id, Account> (
            [SELECT Update_Path__c, Path_Steps__c, RecordType.DeveloperName FROM Account WHERE Id IN :testAccounts]
            );
            for (Account acc : testAccounts) {
                testAccountsAfterFirstUpdate.add(idToAccount.get(acc.Id));
            }
        }
        Assert.areEqual(DMN_Account.PT_STEPS_DEVELOP_PROSPECT, testAccountsAfterFirstUpdate[0].Path_Steps__c);
        Assert.areEqual(DMN_Account.RT_POTENTIAL_CLIENT, testAccountsAfterFirstUpdate[0].RecordType.DeveloperName);
        Assert.areEqual(false, testAccountsAfterFirstUpdate[1].Update_Path__c);
        Assert.areEqual(DMN_Account.PT_STEPS_SUBMIT_FOR_ONBOARDING, testAccountsAfterFirstUpdate[1].Path_Steps__c);
        Assert.areEqual(DMN_Account.RT_POTENTIAL_GOLDTIER, testAccountsAfterFirstUpdate[1].RecordType.DeveloperName);
        Assert.areEqual(false, testAccountsAfterFirstUpdate[2].Update_Path__c);
        Assert.areEqual(DMN_Account.PT_STEPS_SUBMIT_FOR_ONBOARDING, testAccountsAfterFirstUpdate[2].Path_Steps__c);
        Assert.areEqual(DMN_Account.RT_POTENTIAL_CIF, testAccountsAfterFirstUpdate[2].RecordType.DeveloperName);

        System.runAs(testUser1) {
            testAccountsAfterFirstUpdate[1].Status__c = testAccountsAfterFirstUpdate[2].Status__c = DMN_Account.STATUS_SUBMITTED_FOR_ONB;
            testAccountsAfterFirstUpdate[1].Update_Path__c = testAccountsAfterFirstUpdate[2].Update_Path__c = true;
            
            update testAccountsAfterFirstUpdate;
            
            Map<Id, Account> idToAccount = new Map<Id, Account> (
            [SELECT Update_Path__c, Path_Steps__c, RecordType.DeveloperName FROM Account WHERE Id IN :testAccountsAfterFirstUpdate]
            );
            for (Account acc : testAccountsAfterFirstUpdate) {
                testAccountsAfterSecondUpdate.add(idToAccount.get(acc.Id));
            }
        }
        Assert.areEqual(false, testAccountsAfterSecondUpdate[1].Update_Path__c);
        Assert.areEqual(DMN_Account.RT_LOCKED_POTENTIAL_GOLDTIER, testAccountsAfterSecondUpdate[1].RecordType.DeveloperName);
        Assert.areEqual(false, testAccountsAfterSecondUpdate[2].Update_Path__c);
        Assert.areEqual(DMN_Account.RT_LOCKED_POTENTIAL_CIF, testAccountsAfterSecondUpdate[2].RecordType.DeveloperName);
        Test.stopTest();
    }

    @IsTest
    public static void adjustDataNoDml(){
        getData();

        Account accClone = acc.clone(true, false, false, false);
        Account[] newAccs = new Account[]{acc};
        Map<Id, Account> id2OldAcc = new Map<Id, Account>{acc.Id => accClone};

        System.runAs(testUser1){
            // Case 1 - new 
            acc.cif__c = null;
            acc.Client_Co_ordinator__c = testUser2.Id;
            acc.Client_Sector__c = DMN_Account.SEC_CUSTOMER;
            acc.Ignore_CCValidation__c = true;

            DMN_Account.adjustData(newAccs, null);

            Assert.areEqual(testUser2.Id, acc.OwnerId);
            Assert.areEqual(DMN_Account.SEC_CUSTOMER, acc.Industry);

            // Case 2 - update
            acc.Client_Co_ordinator__c = testUser3.Id;
            acc.Client_Sector__c = DMN_Account.SEC_OIL_N_GAS;

            Assert.areNotEqual(acc.Client_Co_ordinator__c, accClone.Client_Co_ordinator__c);
            Assert.areNotEqual(acc.Client_Sector__c, accClone.Client_Sector__c);

            DMN_Account.adjustData(newAccs, id2OldAcc); 

            Assert.areEqual(testUser3.Id, acc.OwnerId);
            Assert.areEqual(DMN_Account.SEC_OIL_N_GAS, acc.Industry);
        }
    }

    @IsTest
    public static void adjustData(){

        getData();

        System.runAs(testUser1){
            Test.startTest();
                acc.Client_Co_ordinator__c = testUser3.Id;
                acc.Client_Sector__c = DMN_Account.SEC_OIL_N_GAS;
                acc.Ignore_CCValidation__c = true;
                acc.Industry_Code__c = '00007';
                acc.RecordTypeId = UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_POTENTIAL_CIF);
                update acc;
            Test.stopTest();
        }

        acc = [SELECT OwnerId, Industry FROM Account WHERE Id =: acc.Id];

        Assert.areEqual(testUser3.Id, acc.OwnerId);
        Assert.areEqual(DMN_Account.SEC_OIL_N_GAS, acc.Industry);
    }

    @IsTest
    public static void shouldFaisStatusFieldValidate() {
        
        System.debug('shouldFaisStatusFieldValidate: START: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));

        List<Database.SaveResult> saveResults;
        List<Account> accounts;

        System.runAs((User) new BLD_USER('newTester@example.com').useCommB().getRecord()) {
            System.debug('shouldFaisStatusFieldValidate: CHECK 1: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));
            accounts = new List<Account>{new Account(Name = 'FAIS 1'), new Account(Name = 'FAIS 2')};
          
            
            Test.startTest();
                //Workaround moved insert accounts and kycstatus into Test block as limits are reset

                insert accounts;
                System.debug('shouldFaisStatusFieldValidate: CHECK 2: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));

                KYC_Status__c kycStatus = new KYC_Status__c(Entity_Code__c = DMN_KYC_Status.ENTITY_CODE_SBSA, Client__c = accounts[0].Id);
                insert kycStatus;
                System.debug('shouldFaisStatusFieldValidate: CHECK 3: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));
                accounts[0].AUM__c = Integer.valueOf(Math.random() * 1000) + 1;

                System.debug('shouldFaisStatusFieldValidate: START TEST: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));
                
                saveResults = Database.update(accounts, false);
                
                System.debug('shouldFaisStatusFieldValidate: STOP TEST: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));
            Test.stopTest();
        }

        Integer unSuccessful = 0;
        for (Database.SaveResult saveResult : saveResults) {
            if (saveResult.isSuccess()) {
                Assert.areEqual(accounts[1].Id, saveResult.getId());
            }
            else {
                unSuccessful++;
                Assert.areEqual(1, saveResult.getErrors().size());
                Database.Error error = saveResult.getErrors()[0];
                Assert.areEqual(DMN_KYC_Status.FAIS_STATUS_ERROR, error.getMessage());
            }
        }
        Assert.areEqual(1, unSuccessful);
    }

    @IsTest
    public static void validateOnInsertNoDml(){
        getData();
        System.runAs(new User(Id = UserInfo.getUserId())){
            testUser1.ProfileId = UTL_CustomSetting.getApiUserProfileId();
            update testUser1;
        } 

        System.runAs(testUser1){
            // Case 1 - valid
            acc = [SELECT Id,Name,CIF__c,Client_Coordinator_from_CDG__c, OwnerId, RecordTypeId FROM Account WHERE Id =: acc.Id];
            acc.CIF_Client_Type__c = DMN_Account.CIF_C_TYPE;
            Assert.areNotEqual(UTL_CustomSetting.getPbbUserId(), acc.OwnerId);
            DMN_Account.validateOnInsert(new Account[]{acc});
            Assert.areEqual(UTL_CustomSetting.getPbbUserId(), acc.OwnerId);

            //Case 2 - without SF Id
            acc = [SELECT Id,Name,CIF__c,RecordTypeId, Without_SF_Id__c FROM Account WHERE Id =: acc.Id];
            acc.CIF_Client_Type__c = 'Dummy';
            acc.Client_Coordinator_from_CDG__c  = BLD_USER.USER_LASTNAME.toUpperCase();
            Assert.areEqual(false, acc.Without_SF_Id__c);
            DMN_Account.validateOnInsert(new Account[]{acc});
            Assert.areEqual(true, acc.Without_SF_Id__c);

            //Case 3 - invalid Client
            acc = [SELECT Id,Name,CIF__c,RecordTypeId, To_Delete__c FROM Account WHERE Id =: acc.Id];
            acc.CIF_Client_Type__c              = 'Dummy';
            acc.Client_Coordinator_from_CDG__c  = ''; 
            Assert.areEqual(false, acc.To_Delete__c);
            DMN_Account.validateOnInsert(new Account[]{acc});
            Assert.areEqual(true, acc.To_Delete__c);

            acc.Client_Coordinator_from_CDG__c  = 'Dummy'; 
            acc.To_Delete__c = false;
            DMN_Account.validateOnInsert(new Account[]{acc});
            Assert.areEqual(true, acc.To_Delete__c);
            
        } 
    }

    @IsTest
    public static void shouldChangeFAISReminder() {
        getData();
        Account accUltimatePar = new Account();
        accUltimatePar.Id = acc.Id;
        acc.FAIS_reminder__c = 'NEED_REMINDER';
        acc.RecordTypeId = UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_CHILD);
        List<Account> accs = new List<Account>{acc};
        accUltimatePar.RecordTypeId= UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_ULTIMATE_PARENT);
        Map<Id, Account> id2acc = new Map<Id, Account>();
        id2acc.put(accUltimatePar.Id, accUltimatePar);
        Test.startTest();
            DMN_Account.changeFAISReminderStatus(accs, id2acc);
        Test.stopTest();
        Assert.areEqual('NO_NEED', acc.FAIS_reminder__c);
    }

    @IsTest
    public static void shouldCancelTasks() {
        getData();
        Account accUltimatePar = new Account();
        accUltimatePar.Id = child.Id;
        child.FAIS_reminder__c = 'NEED_REMINDER';
        child.RecordTypeId = UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_CHILD);
        List<Account> accs = new List<Account>{child};
        accUltimatePar.RecordTypeId= UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_ULTIMATE_PARENT);
        Map<Id, Account> id2acc = new Map<Id, Account>();
        id2acc.put(accUltimatePar.Id, accUltimatePar);
        String taskName = 'Update FAIS Information of ' + child.Name;
        Task task = new Task();
        task.WhatId = child.Id;
        task.Subject = taskName;
        task.Status = 'Not Started';
        insert task;
        Assert.areEqual(false,[
                SELECT Subject, AccountId, Account.Name, Status, Item_to_action__c
                FROM Task
                WHERE Id = :task.Id
        ][0].Item_to_action__c);
    }

    @IsTest
    public static void shouldUpdateNewlyCreatedClientCSTValueToStandard() {

        getData();

        Account acc1 = (Account) new BLD_Account().name('IP')
                .useRecordType(DMN_Account.RT_IMMEDIATE_PARENT)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .getRecord();

        Account acc2 = (Account) new BLD_Account().name('UGP')
                .useRecordType(DMN_Account.RT_ULTIMATE_PARENT)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .getRecord();
        Account acc3 = (Account) new BLD_Account().name('Child1')
                .useRecordType(DMN_Account.RT_CHILD)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .getRecord();
        Account[] accounts = new Account[] { acc1, acc2, acc3 };

        System.runAs(testUser1) {

            Test.startTest();
            insert accounts;
            Test.stopTest();

            Account[] accs = [SELECT Id, CIB_Service_Tier__c FROM Account WHERE Id IN :accounts];

            Assert.areEqual(DMN_Account.CST_STANDARD, accs[0].CIB_Service_Tier__c);
            Assert.areEqual(DMN_Account.CST_STANDARD, accs[1].CIB_Service_Tier__c);
            Assert.areEqual(DMN_Account.CST_STANDARD, accs[2].CIB_Service_Tier__c);
        }
    }

    @IsTest
    public static void shouldUpdateNewlyCreatedClientCSTValueToMatchParent() {

        getData();

        Account parentAccount1 = (Account) new BLD_Account().name('IP')
                .useRecordType(DMN_Account.RT_IMMEDIATE_PARENT)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .getRecord();

        Account parentAccount2 = (Account) new BLD_Account().name('UGP')
                .useRecordType(DMN_Account.RT_ULTIMATE_PARENT)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .getRecord();
        Account[] parents = new Account[] { parentAccount1, parentAccount2 };

        System.runAs(testUser1) {

            parentAccount1.CIB_Service_Tier__c = DMN_Account.CST_HIGH_TOUCH;
            parentAccount2.CIB_Service_Tier__c = DMN_Account.CST_PREMIUM;

            insert parents;
        }

        Account childAccount1 = (Account) new BLD_Account().name('Child1')
                .useRecordType(DMN_Account.RT_CHILD)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .parentId(parentAccount1)
                .getRecord();

        Account childAccount2 = (Account) new BLD_Account().name('Child2')
                .useRecordType(DMN_Account.RT_CHILD)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .parentId(parentAccount1)
                .getRecord();

        Account childAccount3 = (Account) new BLD_Account().name('Child3')
                .useRecordType(DMN_Account.RT_CHILD)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .parentId(parentAccount2)
                .getRecord();
        Account[] children = new Account[] { childAccount1, childAccount2, childAccount3 };

        System.runAs(testUser1) {
            
            Test.startTest();
            	insert children;
            Test.stopTest();

            Map<Id, Account> accs = new Map<Id, Account>([SELECT Name, Id, CIB_Service_Tier__c, ParentId FROM Account WHERE Id IN :children]);

            Assert.areEqual(parentAccount1.CIB_Service_Tier__c, accs.get(childAccount1.Id).CIB_Service_Tier__c, childAccount1.Name+' Service Tier not updated to match parent');
            Assert.areEqual(parentAccount1.CIB_Service_Tier__c, accs.get(childAccount2.Id).CIB_Service_Tier__c, childAccount2.Name+' Service Tier not updated to match parent');
            Assert.areEqual(parentAccount2.CIB_Service_Tier__c, accs.get(childAccount3.Id).CIB_Service_Tier__c, childAccount3.Name+' Service Tier not updated to match parent');
         
        }
    }

     @IsTest
    public static void shouldUpdateChildrenClientCSTValueToMatchNewParent() {

        getData();

        Account parentAccount1 = (Account) new BLD_Account().name('IP')
                .useRecordType(DMN_Account.RT_IMMEDIATE_PARENT)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .getRecord();

        Account parentAccount2 = (Account) new BLD_Account().name('UGP')
                .useRecordType(DMN_Account.RT_ULTIMATE_PARENT)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .getRecord();
        Account[] parents = new Account[] { parentAccount1, parentAccount2 };

        System.runAs(testUser1) {

            parentAccount1.CIB_Service_Tier__c = DMN_Account.CST_HIGH_TOUCH;
            parentAccount2.CIB_Service_Tier__c = DMN_Account.CST_PREMIUM;

            insert parents;
        }

        Account childAccount1 = (Account) new BLD_Account().name('Child1')
                .useRecordType(DMN_Account.RT_CHILD)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .parentId(parentAccount1)
                .getRecord();

        Account childAccount2 = (Account) new BLD_Account().name('Child2')
                .useRecordType(DMN_Account.RT_CHILD)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .parentId(parentAccount1)
                .getRecord();

        Account childAccount3 = (Account) new BLD_Account().name('Child3')
                .useRecordType(DMN_Account.RT_CHILD)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .parentId(parentAccount2)
                .getRecord();
        Account[] children = new Account[] { childAccount1, childAccount2, childAccount3 };

        System.runAs(testUser1) {

            Test.startTest();
            	//Workaround moved insert children into Test block as limits are reset
            	insert children;
    
                childAccount1.ParentId = parentAccount2.Id;
                childAccount2.ParentId = parentAccount2.Id;
                childAccount3.ParentId = parentAccount1.Id;
               
                update children;
            Test.stopTest();

            Map<Id, Account> accs = new Map<Id, Account>([SELECT Name, Id, CIB_Service_Tier__c, ParentId FROM Account WHERE Id IN :children]);

            Assert.areEqual(parentAccount2.CIB_Service_Tier__c, accs.get(childAccount1.Id).CIB_Service_Tier__c, childAccount1.Name+' Service Tier not updated to match parent');
            Assert.areEqual(parentAccount2.CIB_Service_Tier__c, accs.get(childAccount2.Id).CIB_Service_Tier__c, childAccount2.Name+' Service Tier not updated to match parent');
            Assert.areEqual(parentAccount1.CIB_Service_Tier__c, accs.get(childAccount3.Id).CIB_Service_Tier__c, childAccount3.Name+' Service Tier not updated to match parent');
        }
    }

    @IsTest
    public static void shouldShowErrorWhenEditingChildClientCSTDirectly() {

        getData();

        Account acc1 = (Account) new BLD_Account().name('IP')
                .useRecordType(DMN_Account.RT_IMMEDIATE_PARENT)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .getRecord();

        System.runAs(testUser1) {

            acc1.CIB_Service_Tier__c = DMN_Account.CST_HIGH_TOUCH;
            insert acc1;
        }

        Account acc3 = (Account) new BLD_Account().name('Child1')
                .useRecordType(DMN_Account.RT_CHILD)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .parentId(acc1)
                .getRecord();

        System.runAs(testUser1) {

          
            Test.startTest();
                // workaround - move this after startTest to avoid SOQL limits
                insert acc3;
                acc3.CIB_Service_Tier__c = DMN_Account.CST_PREMIUM;

                Database.SaveResult saveResult = Database.update(acc3, false);
            Test.stopTest();

            Account[] a = [SELECT Id, CIB_Service_Tier__c FROM Account WHERE Id = :acc3.Id];

            Assert.areEqual(DMN_Account.CST_HIGH_TOUCH, a[0].CIB_Service_Tier__c);
            Assert.areEqual(false, saveResult.isSuccess());
            Assert.areEqual(1, saveResult.errors.size());
        }
    }

    @IsTest
    public static void shouldReturnParentIds() {

        System.debug('shouldReturnParentIds: START: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));

        getData();

        // statement above uses 2 SOQL statements
        System.debug('shouldReturnParentIds: CHECK 1: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));

        Account acc1 = (Account) new BLD_Account().name('IP')
                .useRecordType(DMN_Account.RT_IMMEDIATE_PARENT)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .getRecord();

        Account acc2 = (Account) new BLD_Account().name('UGP')
                .useRecordType(DMN_Account.RT_ULTIMATE_PARENT)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .getRecord();
        Account[] parents = new Account[] { acc1, acc2 };

        System.runAs(testUser1) {
            insert parents;
        }

        // block above uses 5 SOQL Statements 
        System.debug('shouldReturnParentIds: CHECK 2: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));

        Account acc3 = (Account) new BLD_Account().name('Child1')
                .useRecordType(DMN_Account.RT_CHILD)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .parentId(acc1)
                .getRecord();

        Account acc4 = (Account) new BLD_Account().name('Child2')
                .useRecordType(DMN_Account.RT_CHILD)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .parentId(acc1)
                .getRecord();

        Account acc5 = (Account) new BLD_Account().name('Child3')
                .useRecordType(DMN_Account.RT_CHILD)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .parentId(acc2)
                .getRecord();
        Account acc6 = (Account) new BLD_Account().name('Child3')
                .useRecordType(DMN_Account.RT_CHILD)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .getRecord();
        Account[] children = new Account[] { acc3, acc4, acc5, acc6 };

        
        System.debug('shouldReturnParentIds: CHECK 3: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));

        System.runAs(testUser1) {
            Test.startTest();
                System.debug('shouldReturnParentIds: START TEST: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));

                //When this outside then the limits in SingleTRack are hit due to reptitive account insert operations
                //Workaround moved insert children into Test block as limits are reset
                insert children;

                // block above uses > 11 SOQL statements 
                System.debug('shouldReturnParentIds: CHECK 4: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));


                Set<Id> set1 = DMN_Account.getParentIds(parents, true);
                Set<Id> set2 = DMN_Account.getParentIds(children, false);

                System.debug('shouldReturnParentIds: STOP TEST: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));

            Test.stopTest();

            Assert.areEqual(0, set1.size());
            Assert.areEqual(2, set2.size());
            Assert.areEqual(true, set2.contains(acc1.Id));
            Assert.areEqual(true, set2.contains(acc2.Id));
        }
    }

    @IsTest
    public static void shouldReturnParentClient() {

        getData();

        Account parentAccount1 = (Account) new BLD_Account().name('IP')
                .useRecordType(DMN_Account.RT_IMMEDIATE_PARENT)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .getRecord();

        Account parentAccount2 = (Account) new BLD_Account().name('UGP')
                .useRecordType(DMN_Account.RT_ULTIMATE_PARENT)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .getRecord();
        Account[] parents = new Account[] { parentAccount1, parentAccount2 };

        System.runAs(testUser1) {
            insert parents;
        }

        Account childAccount1 = (Account) new BLD_Account().name('Child1')
                .useRecordType(DMN_Account.RT_CHILD)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .parentId(parentAccount1)
                .getRecord();

        Account childAccount2 = (Account) new BLD_Account().name('Child2')
                .useRecordType(DMN_Account.RT_CHILD)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .parentId(parentAccount1)
                .getRecord();

        Account childAccount3 = (Account) new BLD_Account().name('Child3')
                .useRecordType(DMN_Account.RT_CHILD)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .parentId(parentAccount2)
                .getRecord();
        Account[] children = new Account[] { childAccount1, childAccount2, childAccount3 };

        System.runAs(testUser1) {

            Test.startTest();
                // workaround move this after starTest to avoid SOQL limi
                insert children;

                Map<Id, Account> map1 = DMN_Account.getParentAccounts(parents, true);
                Map<Id, Account> map2 = DMN_Account.getParentAccounts(children, false);

            Test.stopTest();

            Assert.areEqual(0, map1.size(), 'Should not have parent accounts');
            Assert.areEqual(2, map2.size(), 'Incorrect number of parent accounts');
            Assert.isTrue(map2.containsKey(parentAccount1.Id), 'Missing parent account 1');
            Assert.isTrue(map2.containsKey(parentAccount2.Id), 'Missing parent account 2');
        }
    }

    @IsTest
    public static void shouldUpdateChildrenCSTValue() {

        getData();

        Account parentAccount1 = (Account) new BLD_Account().name('IP')
                .useRecordType(DMN_Account.RT_IMMEDIATE_PARENT)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .getRecord();

        Account parentAccount2 = (Account) new BLD_Account().name('UGP')
                .useRecordType(DMN_Account.RT_ULTIMATE_PARENT)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .getRecord();
        Account[] parents = new Account[] { parentAccount1, parentAccount2 };

        System.runAs(testUser1) {

            parentAccount1.CIB_Service_Tier__c = DMN_Account.CST_HIGH_TOUCH;
            parentAccount2.CIB_Service_Tier__c = DMN_Account.CST_PREMIUM;

            insert parents;
        }

        Account childAccount1 = (Account) new BLD_Account().name('Child1')
                .useRecordType(DMN_Account.RT_CHILD)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .parentId(parentAccount1)
                .getRecord();

        Account childAccount2 = (Account) new BLD_Account().name('Child2')
                .useRecordType(DMN_Account.RT_CHILD)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .parentId(parentAccount1)
                .getRecord();

        Account childAccount3 = (Account) new BLD_Account().name('Child3')
                .useRecordType(DMN_Account.RT_CHILD)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .parentId(parentAccount2)
                .getRecord();
        Account[] children = new Account[] { childAccount1, childAccount2, childAccount3 };

        System.runAs(testUser1) {


            Test.startTest();
                //Workaround moved insert children into Test block as limits are reset
                insert children;

                DMN_Account.updateChildrenClientsCSTValue(children);
            Test.stopTest();

            
           	Map<Id, Account> accs = new Map<Id, Account>([SELECT Name, Id, CIB_Service_Tier__c, ParentId FROM Account WHERE Id IN :children]);

            Assert.areEqual(parentAccount1.CIB_Service_Tier__c, accs.get(childAccount1.Id).CIB_Service_Tier__c, childAccount1.Name+' Service Tier not updated to match parent');
            Assert.areEqual(parentAccount1.CIB_Service_Tier__c, accs.get(childAccount2.Id).CIB_Service_Tier__c, childAccount2.Name+' Service Tier not updated to match parent');
            Assert.areEqual(parentAccount2.CIB_Service_Tier__c, accs.get(childAccount3.Id).CIB_Service_Tier__c, childAccount3.Name+' Service Tier not updated to match parent');

        }
    }

    @IsTest
    public static void shouldUpdateChildrenCSTValueAfterParentHasBeenUpdated() {

        getData();
	
        Account parentAccount1 = (Account) new BLD_Account().name('IP')
                .useRecordType(DMN_Account.RT_IMMEDIATE_PARENT)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .getRecord();

        Account parentAccount2 = (Account) new BLD_Account().name('UGP')
                .useRecordType(DMN_Account.RT_ULTIMATE_PARENT)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .getRecord();
        Account[] parents = new Account[] { parentAccount1, parentAccount2 };

        System.runAs(testUser1) {
            insert parents;
        }

        Account childAccount1 = (Account) new BLD_Account().name('Child1')
                .useRecordType(DMN_Account.RT_CHILD)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .parentId(parentAccount1)
                .getRecord();

        Account childAccount2 = (Account) new BLD_Account().name('Child2')
                .useRecordType(DMN_Account.RT_CHILD)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .parentId(parentAccount1)
                .getRecord();

        Account childAccount3 = (Account) new BLD_Account().name('Child3')
                .useRecordType(DMN_Account.RT_CHILD)
                .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_CIB)
                .parentId(parentAccount2)
                .getRecord();
        Account[] children = new Account[] { childAccount1, childAccount2, childAccount3 };

        System.runAs(testUser1) {

            Test.startTest();
                insert children;
    
                parentAccount1.CIB_Service_Tier__c = DMN_Account.CST_HIGH_TOUCH;
                parentAccount2.CIB_Service_Tier__c = DMN_Account.CST_PREMIUM;
                update parents;
                    
                DMN_Account.updateChildrenCSTValue(parents);
    		Test.stopTest();
            
            Map<Id, Account> accs = new Map<Id, Account>([SELECT Name, Id, CIB_Service_Tier__c, ParentId FROM Account WHERE Id IN :children]);

            Assert.areEqual(parentAccount1.CIB_Service_Tier__c, accs.get(childAccount1.Id).CIB_Service_Tier__c, childAccount1.Name+' Service Tier not updated to match parent');
            Assert.areEqual(parentAccount1.CIB_Service_Tier__c, accs.get(childAccount2.Id).CIB_Service_Tier__c, childAccount2.Name+' Service Tier not updated to match parent');
            Assert.areEqual(parentAccount2.CIB_Service_Tier__c, accs.get(childAccount3.Id).CIB_Service_Tier__c, childAccount3.Name+' Service Tier not updated to match parent');
 
        }
    }

    @isTest
    public static void shouldSyncClientSectorToProducts() {
        Account accountWithProducts = [
                SELECT Id,(
                        SELECT Id, Client__c,
                                Finance_Approved_Fee_Recognition__c,
                                RecordTypeId, Client__r.Client_Sector__c
                        FROM Products2__r)
                FROM Account
                WHERE Client_Sector__c <> 'Oil and Gas'
                LIMIT 1
        ];
        Account oldAccount = accountWithProducts.clone();

        accountWithProducts.Client_Sector__c = 'Oil and Gas';
        update accountWithProducts;
        Account newAccount = [
                SELECT Id,(
                        SELECT Id, Client__c,
                                Finance_Approved_Fee_Recognition__c,
                                RecordTypeId, Client__r.Client_Sector__c
                        FROM Products2__r)
                FROM Account
                WHERE Id = :accountWithProducts.Id
                LIMIT 1
        ];

        List<SB_Product__c> prods = newAccount.Products2__r;
        Id capitalMarketsRecId = UTL_RecordType.getRecordTypeId(DMN_SB_Product.OBJ_NAME, DMN_SB_Product.RT_CAPITAL_MARKETS);
        for (Integer i = 0, j = prods.size(); i < j; i++) {
            prods[i].RecordTypeId = capitalMarketsRecId;
        }
        update prods;

        Test.startTest();
        DMN_Account.syncClientSectorToProducts(new List<Account>{newAccount}, new Map<Id, Account>{oldAccount.Id => oldAccount});
        Test.stopTest();


        List<SB_Product__c> resultProds = [
                SELECT Id, Finance_Approved_Fee_Recognition__c
                FROM SB_Product__c
                WHERE Client__c = :newAccount.Id
                AND RecordTypeId = :capitalMarketsRecId
        ];

        for (Integer i = 0, j = resultProds.size(); i < j; i++) {
            Assert.areEqual(50, resultProds[i].Finance_Approved_Fee_Recognition__c);
        }
    }

    @IsTest
    public static void shouldDeleteEcosystemEntityOnAccountDelete() {
        String accountName = 'Account With EcosystemEntity';
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Account(uow)
                .name(accountName)
                .addEcosystemEntity(
                    new BLD_EcosystemEntity(uow).ecosystem(
                        new BLD_Ecosystem(uow).groupNumber(GROUP_NUMBER)));
        uow.commitWork();

        List<Account> accountsToDelete = [
                SELECT Id
                FROM Account
                WHERE Name = :accountName
        ];


        Test.startTest();
        delete accountsToDelete;
        Test.stopTest();

        List<Ecosystem_Entity__c> ecosystemEntities = [
                SELECT Id
                FROM Ecosystem_Entity__c
                WHERE Entity__c IN (SELECT Id FROM Account WHERE Name =:accountName)
        ];
        Assert.isTrue(ecosystemEntities.isEmpty());
    }
        
    @IsTest
    public static void testUpdateContactRecords() {
        Map<Id,Account> accountsToUpdate = new Map<Id,Account>([
            SELECT Id
            FROM Account
            WHERE Name = :DEF_ACC_NAME
        ]);
        Map<Id,Account> accountsToChange = new Map<Id,Account>([
            SELECT Id
            FROM Account
            WHERE Name = :DEF_ACC_NAME_IMM
        ]);  
        Test.startTest();
            DMN_Account.updateContactRecords(accountsToUpdate.keySet(),accountsToChange.keySet());
        Test.stopTest();
    }
            
    @IsTest
    public static void testShareAccounts() {
        Map<Id,Account> acc = new Map<Id,Account>([
            SELECT Id
            FROM Account
            WHERE Name = :DEF_ACC_NAME
        ]);
        Map<Id,User> userId = new Map<Id,User>([
            SELECT Id
            FROM User
            WHERE UserName = :TEST_USER_NAME_1
        ]);  
  
        Test.startTest();
            DMN_Account.AccessWrapper accW = new DMN_Account.AccessWrapper('Edit','Edit','Edit','Edit');
            DMN_Account.shareAccounts(acc.keySet(),userId.keySet(),accW);
        Test.stopTest();
    }
                
    @IsTest
    public static void testupdateChildrenCSTValue() {
        List<Account> acc = [
            SELECT Id,CIB_Service_Tier__c,parentId
            FROM Account
            WHERE Name = :DEF_ACC_NAME_IMM
        ];

        Test.startTest();
            DMN_Account.updateChildrenCSTValue(acc);
        Test.stopTest();
    }
                        
    @IsTest
    public static void testupdateChildrenClientsCSTValue() {
        List<Account> acc = [
            SELECT Id,CIB_Service_Tier__c,parentId
            FROM Account
            WHERE Name = :DEF_ACC_NAME_CHILD
        ];

        Test.startTest();
            DMN_Account.updateChildrenClientsCSTValue(acc);
        Test.stopTest();
    }
                        
    @IsTest
    public static void testpopulateDefaultPBBCLientFields() {
        List<Account> acc = [
            SELECT Id
            FROM Account
            WHERE Name = :DEF_ACC_NAME_CHILD
        ];

        Test.startTest();
            DMN_Account.populateDefaultPBBCLientFields(acc);
        Test.stopTest();
    }
                            
    @IsTest
    public static void testcommbClientRGNNotifier() {

        Test.startTest();
            List<Account> acc = [SELECT Id ,ParentId ,Client_Relationship_Hierarchy__c ,Primary_Relationship_Holder__c FROM Account];
            DMN_Account.commbClientRGNNotifier(acc);
        Test.stopTest();
    }
        
    @IsTest
    static void testPropagateTeamChanges(){

        System.debug('testPropagateTeamChanges: START: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));
       
        getUsers();

        System.debug('testPropagateTeamChanges: CHECK 1: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));

        Map<Id,Account> accMap = new Map<Id,Account>([SELECT Id FROM Account WHERE Name=:DEF_ACC_NAME]);
        fflib_SObjectUnitOfWork uow =  ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_ClientTeam ct = new BLD_ClientTeam(uow)
                               .coordinator(true)
                               .ccbm(false)
                               .account(accMap.values()[0].Id)
                               .role(DMN_ClientTeam.ROLE_COMMB_RELATION_MANGER)
                               .user(testUser1.Id);

         
        Test.startTest();    
            //Workaround moved commitWork into Test block as limits are reset
            uow.commitWork();      
            System.debug('testPropagateTeamChanges: CHECK 2: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));

            Custom_Client_Team__c[] roleMembers = [SELECT Id,Team_Member__c, Client_Coordinator__c,Account__c,Client_Role__c,User_Division__c
                                                   ,Client_Managed_By__c,Account_Owner__c FROM Custom_Client_Team__c WHERE Account__c IN: accMap.KeySet()];
           System.debug('testPropagateTeamChanges: START TEST: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));
            
            Map<Id, Custom_Client_Team__c> oldCoreRoleMembers = new Map<Id, Custom_Client_Team__c>(roleMembers);
            DMN_Account.propagateTeamChanges(roleMembers,oldCoreRoleMembers);
        
            System.debug('testPropagateTeamChanges: STOP TEST: SOQL: '+Limits.getQueries()+' CPU: '+Limits.getCpuTime()/(1000));
        Test.stopTest();
    }
            
    @IsTest
    static void testremoveMarkedClients(){
        getUsers();
        Account[] accList = [SELECT Id FROM Account WHERE Name=:DEF_ACC_NAME];
        accList[0].To_Delete__c = true;
        System.runAs(testUser5){
        Test.startTest();    
            DMN_Account.removeMarkedClients(accList,null);
        Test.stopTest();
        }
    }
              
    @IsTest
    static void testSetCountryName(){
        getUsers();
        Account[] accList = [SELECT Id FROM Account WHERE Name=:DEF_ACC_NAME];
        accList[0].BillingCountry = 'South Africa';
        accList[0].CIF__c = '00667363';
        System.runAs(testUser5){
        Test.startTest();    
            DMN_Account.setCountryName(accList);
        Test.stopTest();
        }
    } 
                  
    @IsTest
    static void testisCommBClient(){
        getUsers();
        Account[] accList = [SELECT Id ,Client_Coordinator_Division__c,CIF__c,Primary_Relationship_Holder__c,CIF_Client_Type__c FROM Account WHERE Name=:DEF_ACC_NAME];
        accList[0].CIF__c = '00667363';
        accList[0].Primary_Relationship_Holder__c = 'Commercial Banking';
        accList[0].CIF_Client_Type__c = 'R';
        System.runAs(testUser5){
        Test.startTest();    
          Boolean isCommB = DMN_Account.isCommBClient(accList[0]);
        Test.stopTest();
        }
    }
    
    @IsTest
    static void testCheckCdgError(){
        getUsers();
        Account[] accList = [SELECT Id,Owner.Name,Name,Client_Coordinator_from_CDG__c,Tech_CC_CDG_Failed_Mapping__c,OwnerId FROM Account WHERE Name=:DEF_ACC_NAME];
        accList[0].CIF__c = '00667363';
        accList[0].Primary_Relationship_Holder__c = 'Commercial Banking';
        accList[0].CIF_Client_Type__c = 'R';
        accList[0].Client_Coordinator_from_CDG__c = accList[0].Owner.Name;
        System.runAs(testUser5){
        Test.startTest();    
           DMN_Account.checkCdgError(accList);
        Test.stopTest();
        }
    }
    
    @IsTest
    static void testUpdateBusinessAssessment(){
        getUsers();
        Account[] accList = [SELECT Id,Name,Internal_Credit_Rating__c FROM Account WHERE Name=:DEF_ACC_NAME];
        Map<Id, Account> accMap = new Map<Id, Account>(accList);
        accList[0].Internal_Credit_Rating__c = 'SB01';
        accList[0].Name = 'Commercial Banking Test';
        System.runAs(testUser5){
        Test.startTest();    
           DMN_Account.updateBusinessAssessment(accList,accMap);
        Test.stopTest();
        }
    }

}