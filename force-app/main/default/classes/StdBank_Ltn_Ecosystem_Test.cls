/**
*
* @author Unknown
* @description Test class for StdBank_Ltn_Ecosystem
*/
@isTest
public without sharing class StdBank_Ltn_Ecosystem_Test {

    public static final Integer UPPER_LIMIT 	= 20;
    public static final String GROUP_NUMBER		= '123456';
    public static final String GROUP_NUMBER_WITH_ECOSYTEM		= '1234567';
    public static final String TEST_USER_NAME	= 'test.StdBank_Ltn_Ecosystem_Test@test.com';
    public static final String DEF_ACC_NAME 	= 'Def Name for Acc';
    public static final String DEF_ACC_NAME_WITH_ECOSYSTEM 	= 'DEF_ACC_NAME_WITH_ECOSYSTEM';

    private static User usr;

    private static User getUser(){
        return [SELECT Id
        FROM User
        WHERE UserName =: TEST_USER_NAME
        LIMIT 1];
    }

    private static Account getAccount(){
        return [SELECT Id, CIF_Client_Status__c
        FROM Account
        WHERE Name =: DEF_ACC_NAME
        LIMIT 1];
    }



    private static Ecosystem__c getEcosystem(){

        return [ SELECT Id,Relationship_Group_Number__c
                 FROM Ecosystem__c
                 WHERE Relationship_Group_Number__c =: GROUP_NUMBER
                 LIMIT 1 ];

    }



    @testSetup
    static void prepareData() {

        usr = (User)new BLD_USER(TEST_USER_NAME).useCommB().syncContact().commitWork().getRecord();

        System.runAs(usr){
            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            new BLD_Account(uow)
                .useCommB()
                .name(DEF_ACC_NAME)
                .groupNumber(GROUP_NUMBER)
                .useGroupParent()
                .addOpportunity(
                    new BLD_Opportunity(uow)
                        .currency('USD'))
                .addContact(
                    new BLD_Contact(uow)
                        .useClientContact())
                .addEcosystemEntity(
                    new BLD_EcosystemEntity(uow)
                        .ecosystem(
                            new BLD_Ecosystem(uow)
                                .groupNumber(GROUP_NUMBER))
                		.entityType(DMN_Ecosystem.SUBSIDIARY));

          BLD_Account client =  new BLD_Account(uow)
                                    .useCommB()
                                    .name(DEF_ACC_NAME_WITH_ECOSYSTEM)
                                    .groupNumber(GROUP_NUMBER_WITH_ECOSYTEM)
                                    .useGroupParent()
                                    .addOpportunity(
                                        new BLD_Opportunity(uow)
                                            .currency('USD'))
                                    .addContact(
                                        new BLD_Contact(uow)
                                            .useClientContact());



          BLD_EcosystemEntity ecoEntity = new BLD_EcosystemEntity(uow)
                        .ecosystem(
                            new BLD_Ecosystem(uow)
                                .groupNumber(GROUP_NUMBER_WITH_ECOSYTEM)
                        		.groupName(client));
            uow.commitWork();
        }

    }




    /**
    * @description this function will test the getPicklistValue function
    */
    @isTest
    private static void testGetPicklistValue(){

        Set< String > expected = getEntityTypePicklistValues();
        List< String > result;
        String excludeValue;

        System.runAs( getUser() ) {
            result = StdBank_Ltn_Ecosystem.getPicklistValues('Ecosystem_Entity__c', 'Entity_Type__c', new List< String >());
        }

        System.assert( expected.containsAll( result ) );

        result = new List< String >( expected );
        excludeValue = result[0];          //we will exclude the
        expected.remove( excludeValue );           //remove the exclude values

        system.runAs( getUser() ){

            List< String > excludeList = new List< String >();
            excludeList.add( excludeValue );
            result = StdBank_Ltn_Ecosystem.getPicklistValues( 'Ecosystem_Entity__c', 'Entity_Type__c', excludeList );

        }

       System.assert( expected.containsAll( result ) );

    }

    /**
    * @AUTHOR Artur Kepczynski
    * @date 30-05-2017
    * @description fetch proper Account Data based on Relationship Group Number
    */
    private static testmethod void accountDataCheck() {

        usr = getUser();

        Account[] accs = [	SELECT Id, Name
        FROM Account
        WHERE Name != 'Standard Bank Employees'];
        Contact[] cons = [	SELECT Name
        FROM Contact];
        Ecosystem__c[] ecos = [	SELECT Relationship_Group_Number__c
        FROM Ecosystem__c];
        Ecosystem_Entity__c[] ents = [	SELECT Id
        FROM Ecosystem_Entity__c];
        System.assertEquals(2, accs.size());
        System.assertEquals(3, cons.size());
        System.assertEquals(2, ecos.size());

        Account acc;
        Account acc2;


        System.runAs(usr){
            Test.startTest();
            acc 	= StdBank_Ltn_Ecosystem.getAccount(accs[0].Id);
            acc2 	= StdBank_Ltn_Ecosystem.getAccount(null);

            Test.stopTest();
        }

        System.assertEquals(null, acc2);
    }

    @isTest
    private static void getClientDataTest(){
        usr = getUser();

        Account[] accs = [SELECT Id, Name FROM Account WHERE Name =: DEF_ACC_NAME];
        Account clientData;
        System.runAs(usr){
            Test.startTest();
            clientData 	= StdBank_Ltn_Ecosystem.getClientData(accs[0].Id);

            Test.stopTest();
        }

        System.assertEquals(clientData.Name, DEF_ACC_NAME);
    }
    /**
    * @AUTHOR Artur Kepczynski
    * @date 30-05-2017
    * @description fetch options (avaliable currrency codes)
    */
    private static testmethod void getOptions(){
        usr = getUser();
        DTO_Ecosystem.Option[] options;

        System.runAs(usr){
            options = StdBank_Ltn_Ecosystem.getOptions();
        }

        System.assertEquals(UTL_Currency.getCurrencies().size(), options.size());
    }
    @isTest
    private static void getEcosystemStructureTestNeg(){
        usr = getUser();

        Account[] accs = [SELECT Id, Name FROM Account WHERE Name =: DEF_ACC_NAME];
        Map<String,Object> clientData;
        System.runAs(usr){
            Test.startTest();
            clientData 	= StdBank_Ltn_Ecosystem.getEcosystemStructure(accs[0].Id);

            Test.stopTest();
        }

       System.assertEquals(clientData.get('isEcosystem'), false);
    }
    @isTest
    private static void getEcosystemStructureTestPos(){
        usr = getUser();

        Account[] accs = [SELECT Id, Name FROM Account WHERE Name =: DEF_ACC_NAME_WITH_ECOSYSTEM];
        Map<String,Object> clientData;
        System.runAs(usr){
            Test.startTest();
            clientData 	= StdBank_Ltn_Ecosystem.getEcosystemStructure(accs[0].Id);

            Test.stopTest();
        }

      System.assertEquals(clientData.get('isEcosystem'), true);
    }
    @isTest
    private static void getEcosystemClient(){
        Account acc = [SELECT Id FROM Account WHERE Name =: DEF_ACC_NAME];
        usr = getUser();
		Ecosystem__c results;
        System.runAs(usr){
            Test.startTest();
            results = StdBank_Ltn_Ecosystem.getEcosystemClient(acc.Id);
            Test.stopTest();
        }
        System.assertNotEquals(results, null);
    }
    
    @isTest
    private static void createEcosystem(){
        String rgNumber = '9844773';
        Ecosystem__c eco = new Ecosystem__c(Relationship_Group_Number__c=rgNumber,Relationship_Group_Name__c=rgNumber);
        usr = getUser();
        System.runAs(usr){
            Test.startTest();
            Ecosystem__c results = StdBank_Ltn_Ecosystem.createEcosystem(eco);
            Test.stopTest();
        }
        Ecosystem__c eco2 = [SELECT  Relationship_Group_Number__c FROM Ecosystem__c WHERE Relationship_Group_Number__c =: rgNumber];
        System.assertEquals(eco2.Relationship_Group_Number__c, rgNumber);
    }
    /**
    * @AUTHOR Artur Kepczynski
    * @date 30-05-2017
    * @description upsert Ecosystem Object fields
    */
    private static testmethod void upsertEcosystem(){
        usr = getUser();
        DTO_Ecosystem.SaveResult results;
        Ecosystem__c eco = [SELECT Unknown_Unbanked_Employees__c, Relationship_Group_Number__c
        FROM Ecosystem__c
        WHERE Relationship_Group_Number__c =: GROUP_NUMBER
        LIMIT 1 ];

        System.runAs(usr){
            System.assertEquals(0, eco.Unknown_Unbanked_Employees__c);

            Test.startTest();
            eco.Unknown_Unbanked_Employees__c 	= 1;

            results = StdBank_Ltn_Ecosystem.upsertEcosystem(eco);
            Test.stopTest();
        }

        eco = [	SELECT Unknown_Unbanked_Employees__c
        FROM Ecosystem__c
        WHERE Id =: eco.Id];

        System.assertEquals(1, eco.Unknown_Unbanked_Employees__c);

        System.assertEquals(true, results.success);
        System.assertEquals(eco.Id, results.objectId);
    }


    /**
    * @AUTHOR Artur Kepczynski
    * @date 30-05-2017
    * @description upsert Ecosystem Object fields, without Relationship Group Number
                            which cause eror and block DML
    */
    private static testmethod void upsertEcosystemFail(){
        usr = getUser();
        DTO_Ecosystem.SaveResult results;
        Ecosystem__c eco = [SELECT Unknown_Unbanked_Employees__c
        FROM Ecosystem__c
        WHERE Relationship_Group_Number__c =: GROUP_NUMBER
        LIMIT 1 ];

        System.runAs(usr){
           System.assertEquals(0, eco.Unknown_Unbanked_Employees__c);

            Test.startTest();
            eco.Unknown_Unbanked_Employees__c 	= 1;

            results = StdBank_Ltn_Ecosystem.upsertEcosystem(eco);
            Test.stopTest();
        }

        eco = [	SELECT Unknown_Unbanked_Employees__c
        FROM Ecosystem__c
        WHERE Id =: eco.Id];

        System.assertEquals(0, eco.Unknown_Unbanked_Employees__c);

        System.assertEquals(false, results.success);
        System.assertEquals(null, results.objectId);
    }

    /**
    * @AUTHOR Artur Kepczynski
    * @date 30-05-2017
    * @description upsert Ecosystem child records, Individuals and  Entities
    */
    private static testmethod void upsertEntities(){
        usr = getUser();
        DTO_Ecosystem.SaveResult[] results;
        Ecosystem_Entity__c ent = [	SELECT Entity_Type__c
        FROM Ecosystem_Entity__c
        LIMIT 1];

        System.runAs(usr){

            Test.startTest();
            ent.Entity_Type__c = DMN_Ecosystem.PARTNER;

            results = StdBank_Ltn_Ecosystem.upsertEntities(new Sobject[]{ent});
            Test.stopTest();
        }

        ent = [	SELECT Entity_Type__c
        FROM Ecosystem_Entity__c
        LIMIT 1];

        System.assertEquals(DMN_Ecosystem.PARTNER, ent.Entity_Type__c);

        System.assertEquals(results[0].success, true);

        System.assertEquals(results[0].objectId, ent.Id);
    }

    /**
    * @AUTHOR Artur Kepczynski
    * @date 30-05-2017
    * @description unlink Ecosystem child records, which cause error
    */
    private static testmethod void upsertEntitiesRemoveParents(){
        usr = getUser();
        DTO_Ecosystem.SaveResult[] results;
        Ecosystem_Entity__c ent = [	SELECT Entity_Type__c
        FROM Ecosystem_Entity__c
        LIMIT 1];

        System.runAs(usr){

            Test.startTest();
            ent.Ecosystem__c 	= null;

            results = StdBank_Ltn_Ecosystem.upsertEntities(new Sobject[]{ent});
            Test.stopTest();
        }

        ent = [	SELECT Entity_Type__c
        FROM Ecosystem_Entity__c
        LIMIT 1];


        System.assertEquals(results[0].success, false);

        System.assertEquals(null, results[0].objectId);
    }

    /**
    * @AUTHOR Artur Kepczynski
    * @date 30-05-2017
    * @description fetch banked clients records
    */
    private static testmethod void bankedClientsCheck(){
        DTO_Ecosystem.BankedClient[] bankedClients;
        DTO_Ecosystem.BankedClient[] bankedClientsNullNo;
        Account acc;

        usr = getUser();

        System.runAs(usr){

            acc = [SELECT Id, Name
            FROM Account
            WHERE Name != 'Standard Bank Employees'
            LIMIT 1];

            Test.startTest();
            bankedClients = StdBank_Ltn_Ecosystem.getBankedClients(GROUP_NUMBER);
            bankedClientsNullNo = StdBank_Ltn_Ecosystem.getBankedClients(null);
            Test.stopTest();
        }

        System.assertEquals(Ecosystem_Entity__c.SobjectType, bankedClients[0].entity.getSobjectType());
        System.assertEquals(DMN_Ecosystem.SUBSIDIARY, 	(String)bankedClients[0].entity.get('Entity_Type__c'));

        System.assertEquals(DMN_Ecosystem.SUBSIDIARY, 	bankedClients[0].elementType);

        System.assertEquals(acc.Id, bankedClients[0].client.Id);

        System.assertEquals(0, bankedClientsNullNo.size());


    }

    /**
    * @AUTHOR Artur Kepczynski
    * @date 30-05-2017
    * @description fetch banked clients records when there are multiple clients (with different numbers)
    */
    private static testmethod void bankedClientsCheckMultiple(){
        DTO_Ecosystem.BankedClient[] bankedClients;
        DTO_Ecosystem.BankedClient[] bankedClientsNullNo;
        DTO_Ecosystem.BankedClient[] bankedClientsIncNo;
        Account acc;

        usr = getUser();

        System.runAs(usr){

            acc = [	SELECT Id, Name
            FROM Account
            WHERE Name != 'Standard Bank Employees'
            LIMIT 1];

            Account[] newAccs 	= new Account[]{};

            for(Integer i=0; i < UPPER_LIMIT; i++ ){
                newAccs.add((Account)new BLD_Account().useCommB().useGroupParent()
                        .getRecord());
            }

            insert newAccs;

            Test.startTest();
            bankedClients = StdBank_Ltn_Ecosystem.getBankedClients(GROUP_NUMBER);
            bankedClientsNullNo = StdBank_Ltn_Ecosystem.getBankedClients(null);
            bankedClientsIncNo  = StdBank_Ltn_Ecosystem.getBankedClients(GROUP_NUMBER + '1');
            Test.stopTest();
        }

        System.assertEquals(Ecosystem_Entity__c.SobjectType, bankedClients[0].entity.getSobjectType());

        System.assertEquals(DMN_Ecosystem.SUBSIDIARY, 	(String)bankedClients[0].entity.get('Entity_Type__c'));

        System.assertEquals(DMN_Ecosystem.SUBSIDIARY, 	bankedClients[0].elementType);

        System.assertEquals(acc.Id, bankedClients[0].client.Id);

        System.assertEquals(0, bankedClientsNullNo.size());
        System.assertEquals(0, bankedClientsIncNo.size());


    }


    /**
    * @AUTHOR Artur Kepczynski
    * @date 30-05-2017
    * @description fetch banked clients records with multiple Individual related to Client
    */
    private static testmethod void bankedClientsCheckMoreIndv(){
        DTO_Ecosystem.BankedClient[] bankedClients;
        Account acc;

        usr = getUser();

        System.runAs(usr){

            acc = [	SELECT Id, Name
            FROM Account
            WHERE Name != 'Standard Bank Employees'
            LIMIT 1];

            Contact[] cons = new Contact[]{};

            for(Integer i=0; i < UPPER_LIMIT; i++ ){
                cons.add((Contact) new BLD_Contact().useClientContact().accountId(acc.Id).getRecord());
            }
            Database.DMLOptions dml = new Database.DMLOptions();
            dml.DuplicateRuleHeader.AllowSave = true;
            dml.OptAllOrNone = false;
            Database.insert(cons, dml);

            Test.startTest();
            bankedClients = StdBank_Ltn_Ecosystem.getBankedClients(GROUP_NUMBER);
            Test.stopTest();
        }
        System.assertEquals(Ecosystem_Entity__c.SobjectType, bankedClients[0].entity.getSobjectType());
        System.assertEquals(DMN_Ecosystem.SUBSIDIARY, 	bankedClients[0].elementType);
        System.assertEquals(acc.Id, bankedClients[0].client.Id);


    }

    /**
    * @AUTHOR Artur Kepczynski
    * @date 30-05-2017
    * @description get unbanked Client data from Ecosystem
    */
    private static testmethod void getUnbankedClients(){
        usr = getUser();
        Ecosystem__c eco;
        Ecosystem__c ecoNoRec;

        System.runAs(usr){
            Test.startTest();
            eco 		= StdBank_Ltn_Ecosystem.getUnbankedClients(GROUP_NUMBER);
            ecoNoRec	= StdBank_Ltn_Ecosystem.getUnbankedClients(null);
            Test.stopTest();
        }

        System.assertNotEquals(null, eco.Id);
        System.assertEquals(null, ecoNoRec.Id);

        System.assertEquals(2, eco.Ecosystem_Entities__r.size());
        System.assertEquals(GROUP_NUMBER, eco.Relationship_Group_Number__c);


    }

    /**
    * @AUTHOR Artur Kepczynski
    * @date 30-05-2017
    * @description calculate total value of all DTFs(based on products related to Client's Opportunities)
    */
    private static testmethod void getDtfTotalValue(){
        usr = getUser();
        Decimal totalValue;

        System.runAs(usr){
            totalValue 		= StdBank_Ltn_Ecosystem.getDtfTotalValue(GROUP_NUMBER, 'USD');
        }

        System.assertEquals(0, totalValue);
    }

    /**
    * @AUTHOR Artur Kepczynski
    * @date 30-05-2017
    * @description calculate value Ecosystem DTFs grouped by Element Type, test when there are no related
                            Opportunity record
    */
    private static testmethod void getDtfDataByElementNoOpp(){
        usr = getUser();
        DTO_Ecosystem.DeliverTheFirm[] dtfData;

        System.runAs(usr){
            dtfData 		= StdBank_Ltn_Ecosystem.getDtfDataByElement(GROUP_NUMBER, 'USD');
        }
        System.assertEquals(6, dtfData.size());

        for(DTO_Ecosystem.DeliverTheFirm dto : dtfData){
            System.assertEquals('USD', dto.currencyCode);
            System.assertEquals(0, dto.notionalValue);
        }

    }


    /**
    * @AUTHOR Artur Kepczynski
    * @date 30-05-2017
    * @description calculate value Ecosystem DTFs grouped by Element Type, test when there are related
                            Opportunity with products related to Client
    */
    private static testmethod void getDtfDataByElementOppWithNoProd(){
        usr = getUser();
        DTO_Ecosystem.DeliverTheFirm[] dtfData;
        Opportunity[] opps = new Opportunity[]{};

        Account acc = [SELECT Id
        FROM Account
        WHERE Name != 'Standard Bank Employees'
        LIMIT 1];

        System.runAs(usr){
            dtfData 		= StdBank_Ltn_Ecosystem.getDtfDataByElement(GROUP_NUMBER, 'USD');

            for(Integer i = 0; i < UPPER_LIMIT; i++){
                opps.add((Opportunity)new BLD_Opportunity().linkAccountId(acc.Id).getRecord());
            }

            insert opps;
        }

        System.assertEquals(6, dtfData.size());

        for(DTO_Ecosystem.DeliverTheFirm dto : dtfData){
            System.assertEquals('USD', dto.currencyCode);
            System.assertEquals(0, dto.notionalValue);
        }


    }

    /**
    * @AUTHOR Artur Kepczynski
    * @date 30-05-2017
    * @description calculate value Ecosystem DTFs grouped by Element Type, test when there are related
                            Opportunity with products related to Client
    */
    private static testmethod void getDtfDataByElementOppWithVal(){
        usr = getUser();
        DTO_Ecosystem.DeliverTheFirm[] dtfData;
        Opportunity[] opps = new Opportunity[]{};
        SB_Product__c[] products = new SB_Product__c[]{};
        Decimal defValue = 100;

        Account acc = [SELECT Id
        FROM Account
        WHERE Name != 'Standard Bank Employees'
        LIMIT 1];

        System.runAs(usr){
            for(Integer i = 0; i < UPPER_LIMIT; i++){
                opps.add((Opportunity)new BLD_Opportunity().linkAccountId(acc.Id).getRecord());
            }
            insert opps;

            for(Opportunity opp : opps){
                products.add((SB_Product__c) new BLD_Product().currency('USD').linkToOpp(opp.Id).notionalValue(defValue).getRecord());
            }
            insert products;

            Test.startTest();
            dtfData 		= StdBank_Ltn_Ecosystem.getDtfDataByElement(GROUP_NUMBER, 'USD');
            Test.stopTest();
        }

        System.assertEquals(6, dtfData.size());

        for(DTO_Ecosystem.DeliverTheFirm dto : dtfData){
            System.assertEquals('USD', dto.currencyCode);
        }


    }


    /**
    * @AUTHOR Artur Kepczynski
    * @date 30-05-2017
    * @description calculate Revenue and Profilability when there is no such record
    */
    private static testmethod void getProfitabilityNoRecord(){
        usr = getUser();
        DTO_Ecosystem.RevenueAndProfitability[] profitability;
        DTO_Ecosystem.RevenueAndProfitability[] profitabilityForNull;
        DTO_Ecosystem.RevenueAndProfitability[] profitabilityForBlank;

        System.runAs(usr){
            profitability 			= StdBank_Ltn_Ecosystem.getProfitability(GROUP_NUMBER, 'USD');
            profitabilityForNull	= StdBank_Ltn_Ecosystem.getProfitability(null, 'USD');
            profitabilityForBlank	= StdBank_Ltn_Ecosystem.getProfitability('', 'USD');
        }

        System.assertEquals(6, profitability.size());
        System.assertEquals(6, profitabilityForNull.size());
        System.assertEquals(6, profitabilityForBlank.size());

        for(DTO_Ecosystem.RevenueAndProfitability[] prof : new List<DTO_Ecosystem.RevenueAndProfitability[]>{
                profitability,
                profitabilityForNull,
                profitabilityForBlank}){
            for(Integer i = 0; i < 6; i++){
                System.assertEquals(0, prof[i].netIncome );
                System.assertEquals(0, prof[i].netRevenue );
                System.assertEquals(0, prof[i].operationalIncome );
                System.assertEquals(0, prof[i].headlineErnings );
                System.assertEquals(0, prof[i].roe );
            }
        }


    }

    /**
    * @AUTHOR Artur Kepczynski
    * @date 30-05-2017
    * @description calculate Revenue and Profilability
    */
    private static testmethod void getProfitability(){
        usr = getUser();
        DTO_Ecosystem.RevenueAndProfitability[] profitability;
        Account acc = getAccount();

        System.runAs(usr){

            Revenue_and_Profitability__c[] revenues = new Revenue_and_Profitability__c[]{};

            for(Integer i = 0; i < 10; i++){
                revenues.add((Revenue_and_Profitability__c) new BLD_RevenueAndProfitability().accountId(acc.Id)
                        .groupNumber(GROUP_NUMBER).roe(100).getRecord());
            }

            insert revenues;

            Test.startTest();
            profitability 	= StdBank_Ltn_Ecosystem.getProfitability(GROUP_NUMBER, 'USD');
            Test.stopTest();
        }

        System.assertEquals(6, profitability.size());


    }


    /**
    * @AUTHOR Bartosz Sliwinski
    * @description create acc hierarchy, retrieve oppotunities from it
    */
    private static testmethod void getOpportunitiesForAccountHierarchy() {
        usr = getUser();
        Opportunity[] opportunities;
        Account acc = getAccount();

        System.runAs(usr) {
            Test.startTest();
            Account immediateParent = new Account(Name = 'Immediate');

            insert immediateParent;

            Account childAcc = (Account) new BLD_Account()
                    .name('Child Acc')
                    .groupNumber(GROUP_NUMBER)
                    .useCommB()
                    .useChild(immediateParent.Id, acc.Id)
                    .setField(Account.ParentId, acc.Id)
                    .getRecord();

            insert childAcc;

            Opportunity[] opps = new Opportunity[]{};

            for (Integer i=0; i<10; i++) {
                opps.add((Opportunity) new BLD_Opportunity().linkAccountId(acc.Id).getRecord());
                opps.add((Opportunity) new BLD_Opportunity().linkAccountId(childAcc.Id).getRecord());
                opps.add((Opportunity) new BLD_Opportunity().linkAccountId(immediateParent.Id).getRecord());
            }

            insert opps;

            opportunities = StdBank_Ltn_Ecosystem.getOpportunitiesForAccountHierarchy(GROUP_NUMBER);
            Test.stopTest();
        }

       System.assertEquals(21, opportunities.size());
    }


    /**
    * @AUTHOR Bartosz Sliwinski
    * @description create acc hierarchy, retrieve oppotunities from it
    */
    private static testmethod void getHierarchyMembers() {
        usr = getUser();
        DTO_Ecosystem.HierarchyMember[] hierMembers;
        Account acc = getAccount();

        System.runAs(usr){
            Test.startTest();
            Account immediateParent = new Account(Name = 'Immediate');

            insert immediateParent;

            Account childAcc = (Account) new BLD_Account()
                    .name('Child Acc')
                    .useCommB()
                    .groupNumber(GROUP_NUMBER)
                    .useChild(immediateParent.Id, acc.Id)
                    .setField(Account.ParentId, acc.Id)
                    .getRecord();

            insert childAcc;

            Revenue_and_Profitability__c[] revenues = new Revenue_and_Profitability__c[]{};

            for(Integer i = 0; i < 10; i++){
                revenues.add((Revenue_and_Profitability__c) new BLD_RevenueAndProfitability().accountId(acc.Id)
                        .groupNumber(GROUP_NUMBER).roe(100).getRecord());
                revenues.add((Revenue_and_Profitability__c) new BLD_RevenueAndProfitability().accountId(childAcc.Id)
                        .groupNumber(GROUP_NUMBER).roe(100).getRecord());
            }

            insert revenues;

            hierMembers = StdBank_Ltn_Ecosystem.getHierarchyMembers(GROUP_NUMBER, 'USD');
            Test.stopTest();
        }

        System.assertEquals(2, hierMembers.size());
    }

    private static testmethod void ecosystemEntityFunctionality() {
        TEST_DataFactory.generateConfiguration();
        Ecosystem__c ecosystem = new Ecosystem__c(Relationship_Group_Number__c = 'Test');
        insert ecosystem;

        Test.startTest();
        Id recordTypeId = StdBank_Ltn_Ecosystem.getEcosystemRecordTypeId();
        Id currentUserId = StdBank_Ltn_Ecosystem.getCurrentUserId();
        String primaryRelationshipHolder = 'Commercial Banking';
        String entityName = 'CommB Test PTY Ltd';
        DTO_SelectOption[] options = StdBank_Ltn_Ecosystem.getAccountOptions();

        Account acc = new Account(Name = 'Test', RecordTypeId = recordTypeId, CIF__c = '123456', Primary_Relationship_Holder__c = options[0].value);
        StdBank_Ltn_Ecosystem.createAccount(acc);

        System.assert(StdBank_Ltn_Ecosystem.createAccount(acc) instanceof String);

        Ecosystem_Entity__c entity = StdBank_Ltn_Ecosystem.createEcosystemEntity(ecosystem.Id, acc.Id, 'Shareholder',primaryRelationshipHolder,entityName,acc.CIF__c);

        StdBank_Ltn_Ecosystem.deleteEntities(new List<Ecosystem_Entity__c>{entity},true);
        StdBank_Ltn_Ecosystem.searchAccounts('Te', ecosystem.Id);

        Id individualRtId = UTL_RecordType.getRecordTypeId('Account', 'Commercial_Banking_Individual_Client');


        Test.stopTest();
    }


    /** this function will test the searchAccountsUnbanked
     */
    private static testmethod void testSearchAccountsUnbanked(){

        User testUser = getUser();                             //get the user
        Ecosystem__c testEcosystem = getEcosystem();           //get the test ecosystem
        Account[] resultList;                                  //this is the result list

        //run in user context
        System.runAs( testUser ){

            resultList = StdBank_Ltn_Ecosystem.searchAccountsUnbanked( DEF_ACC_NAME, testEcosystem.Id );

        }//end of run as block
        system.assertEquals(0,resultList.size());
    }//end of function definition





    /** this function will test searchEcosystems function
     */
    private static testmethod void testSearchEcosystems(){

        User testUser = getUser();                 //get the user
        Account testAccount = getAccount();        //get the user account
        Ecosystem__c[] resultList;                 //this is the result list

        //run in user context
        System.runAs( testUser ){

            resultList = StdBank_Ltn_Ecosystem.searchEcosystems( GROUP_NUMBER, testAccount.Id );                      //execute test

        }//end of runAs-block
        system.assertNotEquals(0,resultList.size());
    }//end of function definition




    /** this function will test getEcosystems
     */
    private static testmethod void testGetEcosystems(){

        User testUser = getUser();                             //get test user
        Account testAccount = getAccount();                    //get test accounts
        DTO_Ecosystem.BankedClient[] resultList;

        System.runAs( testUser ){

            resultList = StdBank_Ltn_Ecosystem.getEcosystems( testAccount.Id );

        }//end of runAs-block
        system.assertNotEquals(0,resultList.size());
    }//end of function definition





    private static testmethod void testGetEcosystemById(){

        User testUser = getUser();                         //get the user
        Ecosystem__c testEcosystem = getEcosystem();       //get the ecosystem
        Ecosystem__c eco;
        System.runAs( testUser ){

            eco = StdBank_Ltn_Ecosystem.getEcosystemById( testEcosystem.Id );

        }//end of runAs-block
        system.assertEquals(GROUP_NUMBER,eco.Relationship_Group_Number__c);
    }//end of function defintion





    private static testmethod void testGetDftDataPipeline(){

        User testUser = getUser();                     //get the user
        DTO_Ecosystem.DeliverTheFirm[] dtfList;
        System.runAs( testUser ){

            dtfList = StdBank_Ltn_Ecosystem.getDtfDataPipeline( GROUP_NUMBER );

        }//end of runAs-block
        system.assertEquals(0,dtfList.size());
    }//end of function definition




    private static testMethod void testGetDftDataBanked(){

        User testUser = getUser();                 //get the user
        DTO_Ecosystem.DeliverTheFirm[] dtfList;
        System.runAs( testUser ){

            dtfList = StdBank_Ltn_Ecosystem.getDtfDataBanked( GROUP_NUMBER );

        }//end of runAs-block
        system.assertEquals(0,dtfList.size());
    }




    private static testMethod void testGetDtfDataPipelineByElement(){

        User testUser = getUser();
        DTO_Ecosystem.DeliverTheFirm[] dtfList;
        System.runAs( testUser ){

            dtfList = StdBank_Ltn_Ecosystem.getDtfDataPipelineByElement( GROUP_NUMBER, 'USD' );

        }
        system.assertNotEquals(0,dtfList.size());
    }





    private static testMethod void testGetDtfDataBankedByElement(){

        User testUser = getUser();
        DTO_Ecosystem.DeliverTheFirm[] dtfList;
        System.runAs( testUser ){

            dtfList = StdBank_Ltn_Ecosystem.getDtfDataBankedByElement( GROUP_NUMBER, 'USD' );

        }
        system.assertNotEquals(0,dtfList.size());
    }




    /**currencyCode
     * @description this function will get the pbb division opt
     */
    private static testmethod void testGetPbbDivisionOptions(){

        User testUser = getUser();
        DTO_SelectOption[] optList;
        System.runAs( testUser ){

            optList = StdBank_Ltn_Ecosystem.getPbbDivisionOptions();

        }
        system.assertNotEquals(0,optList.size());
    }



    /**
     * @description this function will update Account
     */
    private static testMethod void testUpdateAccount(){

        User testUser = getUser();
        Account acc = getAccount();
        Account updatedAcc;
        System.runAs( testUser ){

            updatedAcc = StdBank_Ltn_Ecosystem.updateAccount( acc.Id, 'Name', 'Test Name' );

        }
        system.assertEquals('Test Name',updatedAcc.Name);

    }


    /**
     * @description this function will get the prospect record type
     */
    private static testmethod void testGetProspectRecordTypeId(){

        User testUser = getUser();
        String recType = null;
        System.runAs( testUser ){

            recType = StdBank_Ltn_Ecosystem.getProspectRecordTypeId();

        }
        system.assertNotEquals(null,recType);
    }




    /**
    * @description this function will test getResponsibleRegionOptions
     */
    private static testmethod void testGetResponsibleOptions(){

        User testUser = getUser();
        DTO_SelectOption[] optList;
        System.runAs( testUser ){

            optList = StdBank_Ltn_Ecosystem.getResponsibleRegionOptions();

        }
        system.assertNotEquals(0,optList.size());

    }//end of function definition




    /**
    * @description this function will test isOwnerManager
     */
    private static testMethod void testIsOwnerManager(){

        User testUser = getUser();
        Account acc = getAccount();
        Boolean isOwnerManager = false;
        System.runAs( testUser ){

            isOwnerManager = StdBank_Ltn_Ecosystem.isOwnerManager( acc.Id );

        }
        system.assertEquals(false,isOwnerManager);

    }


    /**
     *@description this function will retrieve picklist values
     *@return Set< String >
     */
    private static Set< String > getEntityTypePicklistValues(){

        List< String > picklistValues = new List< String >();
        Schema.SObjectType sObjct = Schema.getGlobalDescribe().get( 'Ecosystem_Entity__c' );				//get the describe info
        Schema.DescribeSObjectResult sObjectDescription = sObjct.getDescribe();					//get the object info
        Schema.DescribeFieldResult sobjectField = sObjectDescription.fields.getMap().get( 'Entity_Type__c' ).getDescribe();			//get field info
        List< Schema.PicklistEntry > picklistValue = sobjectField.getPicklistValues();						//this is the picklist value

        //loop through the picklist value
        for( Schema.PicklistEntry currentEntry : picklistValue ) {
            picklistValues.add(currentEntry.getLabel());                    //add current entry to the return list
        }
        return new Set< String >( picklistValues );

    }

    private static void setMocks(String resBody){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayApi_Conversations mockedRequestProvider = (PBB_SRV_GatewayApi_Conversations) mocks.mock(PBB_SRV_GatewayApi_Conversations.class);
        PBB_SRV_GatewayRequestProvider mockedRequestProvider3 = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        SRV_HttpRequestSender mockedRequestProvider2 = (SRV_HttpRequestSender) mocks.mock(SRV_HttpRequestSender.class);
        mocks.startStubbing();
        mocks.when(mockedRequestProvider.getConversationsByRiskGroup(Integer.ValueOf(GROUP_NUMBER))).thenReturn((List<PBB_SRV_GatewayApi_Conversations.ConversationGroup>)JSON.deserialize(resBody, List<PBB_SRV_GatewayApi_Conversations.ConversationGroup>.class));
        mocks.when(mockedRequestProvider3.getRequestWithToken()).thenReturn(new HttpRequest());
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayApi_Conversations.IService.class, mockedRequestProvider);
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider3);
        ORG_Application.service.setMock(SRV_HttpRequestSender.IService.class, mockedRequestProvider2);
    }

    @isTest
    private static void getCoversationsCountTest(){
        User testUser = getUser();
        Ecosystem__c eco = getEcosystem();
        Integer count = 0;
        String resBody = '[{"customerNumber":1552587,"conversationId":22062423988,"category":"PortfolioManagement","catPosition":6,"subCategory":"CompetitorAccounts","subCatPosition":97,"detail":"TheClienthasthefollowingexternalpayaways;Investments/RAswithDISCOVERY,LIBERTYamt31406;CCwithDISCamt754","actionScript":"COMPETITORACCOUNTS","contactType":null,"response":null,"reason":null,"additionalInformation":null,"expectedRevenue":0.0,"futureContactDate":null,"leadKey":"000000015525871938"},{"customerNumber":209204568,"conversationId":220624349467,"category":"PeopleLikeYou","catPosition":51,"subCategory":"Vehicleloan","subCatPosition":143,"detail":"#ClientcouldqualifyforVAFtomeettheirlendingneeds,subjecttoverificationofaffordabilityandriskprofile##","actionScript":"VEHICLELOAN","contactType":null,"response":null,"reason":null,"additionalInformation":null,"expectedRevenue":11512.0,"futureContactDate":null,"leadKey":"000002092045682747"},{"customerNumber":209204568,"conversationId":220624349466,"category":"PeopleLikeYou","catPosition":51,"subCategory":"Prestigecurrentaccount","subCatPosition":49,"detail":"#Titaniumcreditcard#Ucount#","actionScript":"PRESTIGECURRENTACCOUNT","contactType":null,"response":null,"reason":null,"additionalInformation":null,"expectedRevenue":1400.0,"futureContactDate":null,"leadKey":"000002092045682916"}]';
        Map<String, String> resHeaders = new Map<String, String> ();
        setMocks(resBody);
        Test.startTest();
        System.runAs( testUser ){

            count = StdBank_Ltn_Ecosystem.getCoversationsCount(eco.Id);

        }
        Test.stopTest();
        system.assertEquals(3,count);

    }


}