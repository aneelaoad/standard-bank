/*************************************************************************
    @ Author        : psvestka
    @ Date          : 18. 8. 2015
    @ Description : Force.com reviewer - Blocker and Critical issues - 20150608.xlsx
    
    @Last Modified By   : Abhishek V
    @Last Modified on   : 18/11/2015
    @Last Modified Reason: Due to a validation inclusion for EN - 0916, it is not possible to add products for a closed opportunity.

    @Last Modified By   : Dzianisik Maksim
    @Last Modified on   : Sep. 2021
    @description        : SFP-6290 Added test method for Insurance logic

    @Last Modified By   : Dzianisik Maksim
    @Last Modified on   : May. 2022
    @description        : SFP-12591 Added test method for Insurance Policy sync logic, updated api version
****************************************************************************/

@IsTest
private class SBProductTriggerTest {

    private static Map<String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    private static Id prospectRecTypeId = mapAccountRecordTypes.get('Prospect').getRecordTypeId();

    private static Map<String, Schema.RecordTypeInfo> mapProductRecordTypes = SB_Product__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    private static Id tradingRecTypeId = mapProductRecordTypes.get('Trading (Structure)').getRecordTypeId();

    private static final String INSURANCE = 'Insurance';
    private static final Id INSURANCE_PRODUCT_RT_ID = Schema.SObjectType.SB_Product__c.getRecordTypeInfosByName().get(INSURANCE).getRecordTypeId();
    private static final Map<PicklistEntry, List<PicklistEntry>> PRODUCT_2_PARENT = UTL_Picklist.getDependentToControllingMap(InsurancePolicy.Product_Type__c, InsurancePolicy.Parent_Product__c);
    private static final Map<PicklistEntry, List<PicklistEntry>> PARENT_2_G_PARENT = UTL_Picklist.getDependentToControllingMap(InsurancePolicy.Parent_Product__c, InsurancePolicy.Grand_Parent_Product__c);
    private static final Integer AMOUNT = 100;
    private static final Integer MONTHS = 12;

    @TestSetup
    private static void prepareData() {
        TEST_DataFactory.insertSettings(new List<Object> {
                TEST_DataFactory.getCcSettings(),
                TEST_DataFactory.getEnvironmentVariable(),
                TEST_DataFactory.getCstTeamRankings()
        });

        Account acc = new Account();
        acc.RecordTypeId = prospectRecTypeId;
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
        insert acc;

        insert new List<UserProfileId__c>{
                new UserProfileId__c(Name = 'UserProfileId', UserProfileId__c = UserInfo.getProfileId()),
                new UserProfileId__c(Name = 'Business Administrator', UserProfileId__c = GlobalCache.getProfileId('Business Administrator'))
        };

        Custom_Client_Team__c cCT = new Custom_Client_Team__c();
        cCT.Account__c = acc.Id;
        cCT.Client_Access__c = 'Read/Write';
        cCT.Client_Role__c = 'Credit Risk'; //
        cCT.Team_Member__c = UserInfo.getUserId();
        insert cCT;

        Opportunity opp = new Opportunity();
        opp.AccountId=acc.Id;
        opp.Name= 'Opportunity_'+ acc.Name;
        opp.CloseDate=System.today();
        opp.StageName='2 - Develop';
        opp.Short_Summary__c = 'test opportunity';
        opp.CurrencyIsoCode = 'ZAR';

        // Modified for EN - 916 - Not possible to create products for Closed oppty because of validation
        //opp.StageName = '4 - Closed Lost' ;
        opp.Reason_Won_Lost_Comments__c = 'Test Lost';
        insert opp;

        SB_Product__c prod = new SB_Product__c();
        prod.RecordTypeId = tradingRecTypeId;
        prod.Opportunity__c = opp.id;
        prod.SA_Product__c = 'ACB';
        prod.Grand_Parent_Product__c = 'Advisory Fees';
        prod.SA_Current_known_conflict_of_interest__c = 'test';
        prod.Country_of_Underlying_Risk__c = 'Belarus';
        prod.Balance_Sheet_of_Booking__c = 'Angola - Standard Bank de Angola S.A.';
        prod.Loan_Profile__c = 'Bullet Term Loan';
        prod.SB_Gross_Participation__c = 12;
        prod.Term_Tenor__c = 1;
        prod.CurrencyIsoCode = 'ZAR';
        prod.Current_Year_Fees__c = 10;
        prod.Total_Fees__c = 20;
        prod.Maturity_Date_Reminder__c = true;
        prod.SA_Maturity_Date__c = Date.today().addDays(14);
        insert prod;
    }

    static testMethod void testRecordsExist() {
        Integer cntA = [SELECT COUNT() FROM Account WHERE Name = 'Test Client'];
        Integer cntCCT = [SELECT COUNT() FROM Custom_Client_Team__c WHERE Team_Member__c = :(UserInfo.getUserId())];
        Integer cntO = [SELECT COUNT() FROM Opportunity WHERE Name = 'Opportunity_Test Client'];
        Integer cntP = [SELECT COUNT() FROM SB_Product__c WHERE SA_Product__c = 'ACB'];

        system.assert(cntA > 0, 'Account record "Test Client" should exist');
        system.assert(cntCCT > 0, 'Custom_Client_Team__c record should exist');
        system.assert(cntO > 0, 'Opportunity record "Opportunity_Test Client" should exist');
        system.assert(cntP > 0, 'SB_Product__c record "ACB" should exist');
    }

    private static testMethod void testTriggers() {
        Opportunity opp = [SELECT id, Name, AccountId, Account.Name, CurrencyISOCode FROM Opportunity WHERE Name = 'Opportunity_Test Client'];
        SB_Product__c prod = [SELECT id, Client__c, CurrencyISOCode FROM SB_Product__c WHERE SA_Product__c = 'ACB'];

        //before insert
        system.assertEquals(prod.Client__c, opp.AccountId, 'Product\'s Client__c should be equal to Opportunity.AccountId');
        system.assertEquals(opp.CurrencyISOCode, prod.CurrencyISOCode, 'Product\'s CurrencyISOCode should be equal to the Opportunity\'s');

        // Modified for EN - 916 - Not possible to create products for Closed oppty because of validation
        //after insert
        /*Task t = [SELECT id, Subject FROM Task WHERE WhatId = :opp.Id];
        system.assertEquals('Reminder: ' + opp.Name + ', ' + opp.Account.Name, t.Subject, 'Task\'s subject should be in form "Reminder: opp.Name, opp.Account.Name"');
        */

        List<Custom_Client_Team__c> cctList = [SELECT Id FROM Custom_Client_Team__c WHERE Account__c = :opp.AccountId];
        system.assertEquals(1, cctList.size(), 'cctList should contain only one item');

        Integer cntCctop = [SELECT COUNT()
        FROM ClientTeamOpportunity_Products__c
        WHERE Product__c = :prod.Id
        AND Opportunity__c = :opp.Id
        AND Custom_Client_Team__c = :cctList[0].Id
        AND ClientTeamId__c = :cctList[0].Id];
        system.assertEquals(1, cntCctop, 'There should be only one ClientTeamOpportunity_Products__c record');
    }

    @IsTest
    static void testInsuranceProductPositive() {
        Opportunity opp = [SELECT Id, Name, AccountId, Account.Name, CurrencyIsoCode FROM Opportunity WHERE Name = 'Opportunity_Test Client'];
        SB_Product__c insuranceProduct = createInsuranceProduct(opp);
        SB_Product__c testProduct;

        Test.startTest();
        insert insuranceProduct;

        testProduct = [
                SELECT Id, Total_Fees__c, Total_Commission__c, Current_Year_Fees__c, Current_Year_Commission__c,
                        Fee_Frequency__c, Commission_Frequency__c
                FROM SB_Product__c
                WHERE RecordTypeId =: INSURANCE_PRODUCT_RT_ID
        ];
        System.assertEquals((AMOUNT * (MONTHS + 1)), testProduct.Total_Fees__c);
        System.assertEquals((AMOUNT * (MONTHS + 1)), testProduct.Total_Commission__c);
        System.assertEquals((AMOUNT * MONTHS), testProduct.Current_Year_Commission__c);
        System.assertEquals((AMOUNT * MONTHS), testProduct.Current_Year_Fees__c);

        Integer numberOfERS = [SELECT COUNT() FROM Estimated_Revenue_Schedule__c WHERE Product__c =: testProduct.Id];
        System.assertEquals(MONTHS + 1, numberOfERS);

        testProduct.Fee_Frequency__c = 'Once off';
        testProduct.Commission_Frequency__c = 'Bi-annual';
        update testProduct;
        testProduct = [
                SELECT Id, Total_Fees__c, Total_Commission__c, Current_Year_Fees__c, Current_Year_Commission__c,
                        Fee_Frequency__c, Commission_Frequency__c
                FROM SB_Product__c
                WHERE RecordTypeId =: INSURANCE_PRODUCT_RT_ID
        ];

        System.assertEquals(AMOUNT, testProduct.Total_Fees__c);
        System.assertEquals(AMOUNT, testProduct.Current_Year_Fees__c);
        System.assertEquals(AMOUNT * ((MONTHS / 6) + 1), testProduct.Total_Commission__c);
        System.assertEquals(AMOUNT * (MONTHS / 6), testProduct.Current_Year_Commission__c);

        numberOfERS = [SELECT COUNT() FROM Estimated_Revenue_Schedule__c WHERE Product__c =: testProduct.Id];
        System.assertEquals((MONTHS / 6) + 1, numberOfERS);

        Test.stopTest();
    }

    @IsTest
    static void testInsuranceProductNegative() {
        Opportunity opp = [SELECT Id, Name, AccountId, Account.Name, CurrencyIsoCode FROM Opportunity WHERE Name = 'Opportunity_Test Client'];
        SB_Product__c insuranceProduct = createInsuranceProduct(opp);
        insuranceProduct.Fee_Frequency__c = 'invalid value';

        Test.startTest();
        try {
            insert insuranceProduct;
        } catch (DmlException ex) {
            System.assert(ex.getMessage().contains('Something wrong with Fee Frequency field'));
        }
        Test.stopTest();
    }

    @IsTest
    static void testInsurancePolicyPositive() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User insuranceUser = createInsuranceUser(uow, '0');
        User sysAdmin = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        uow.commitWork();

        List<PermissionSet> insurancePermissionSets = [SELECT Id FROM PermissionSet WHERE Name = 'FSCInsurance' OR Name = 'Insurance_Policies_and_Claims_User'];
        System.assertEquals(2, insurancePermissionSets.size(), 'The Org has to have both permission sets');
        List<PermissionSetAssignment> assignments = new List<PermissionSetAssignment>();

        for(PermissionSet tempPermission : insurancePermissionSets) {
            assignments.add(new PermissionSetAssignment(AssigneeId = insuranceUser.Id, PermissionSetId = tempPermission.Id));
        }

        System.runAs(sysAdmin) {
            insert assignments;
        }

        Test.startTest();
        Opportunity opp = [SELECT Id, Name, AccountId, Account.Name, CurrencyIsoCode FROM Opportunity WHERE Name = 'Opportunity_Test Client'];
        SB_Product__c insuranceProduct = createInsuranceProduct(opp);

        OpportunityShare oppShare = new OpportunityShare(OpportunityId = opp.Id, UserOrGroupId = insuranceUser.Id, OpportunityAccessLevel = 'edit', RowCause = 'manual');
        insert oppShare;

        System.runAs(insuranceUser) {
            insert insuranceProduct;

            InsurancePolicy tempPolicy = createInsurancePolicy(insuranceProduct.Id, opp.AccountId, 'test');
            insert tempPolicy;
        }

        List<InsurancePolicy> actualPolicies = [SELECT Id, StandardFeeAmount, Commission_Amount__c, Inception_Date__c, Expiry_Date__c FROM InsurancePolicy];
        System.assertEquals(1, actualPolicies.size(), 'The org has to have only 1 Insurance Policy record');
        Date startDate = Date.newInstance(System.today().year(), 1, 1);
        System.assertEquals(startDate, actualPolicies[0].Inception_Date__c, 'Has to be the same as the Product Inception Date');
        System.assertEquals(startDate.addMonths(MONTHS), actualPolicies[0].Expiry_Date__c, 'Has to be the same as the Product Expiry Date');

        System.runAs(insuranceUser) {
            insuranceProduct = [SELECT Id, Fee_Amount__c FROM SB_Product__c WHERE Id =: insuranceProduct.Id];
            insuranceProduct.Fee_Amount__c = AMOUNT * MONTHS;
            update insuranceProduct;
        }
        Test.stopTest();

        InsurancePolicy updatedPolicy = [SELECT Id, StandardFeeAmount FROM InsurancePolicy WHERE SB_Product__c =: insuranceProduct.Id];
        System.assertEquals(AMOUNT*MONTHS, updatedPolicy.StandardFeeAmount, 'InsurancePolicy has to be synced with the product');
    }

    @IsTest
    static void testInsurancePolicyNegative() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User insuranceUser1 = createInsuranceUser(uow, '1');
        User insuranceUser2 = createInsuranceUser(uow, '2');
        User sysAdmin = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        uow.commitWork();

        List<PermissionSet> insurancePermissionSets = [SELECT Id FROM PermissionSet WHERE Name = 'FSCInsurance' OR Name = 'Insurance_Policies_and_Claims_User'];
        System.assertEquals(2, insurancePermissionSets.size(), 'The Org has to have both permission sets');
        List<PermissionSetAssignment> assignments1 = new List<PermissionSetAssignment>();

        for(PermissionSet tempPermission : insurancePermissionSets) {
            assignments1.add(new PermissionSetAssignment(AssigneeId = insuranceUser1.Id, PermissionSetId = tempPermission.Id));
        }

        System.runAs(sysAdmin) {
            insert assignments1;
        }

        Opportunity opp = [SELECT Id, Name, AccountId, Account.Name, CurrencyIsoCode FROM Opportunity WHERE Name = 'Opportunity_Test Client'];

        List<OpportunityShare> oppShares = new List<OpportunityShare>{
                new OpportunityShare(OpportunityId = opp.Id, UserOrGroupId = insuranceUser1.Id, OpportunityAccessLevel = 'edit', RowCause = 'manual'),
                new OpportunityShare(OpportunityId = opp.Id, UserOrGroupId = insuranceUser2.Id, OpportunityAccessLevel = 'edit', RowCause = 'manual')};
        insert oppShares;

        SB_Product__c insuranceProduct = createInsuranceProduct(opp);

        System.runAs(insuranceUser1) {
            insert insuranceProduct;

            InsurancePolicy insurancePolicy1 = createInsurancePolicy(insuranceProduct.Id, opp.AccountId, 'test1'); //new InsurancePolicy();
            insert insurancePolicy1;
        }

        Test.startTest();
        System.runAs(insuranceUser2) {
            InsurancePolicy insurancePolicy2 = createInsurancePolicy(insuranceProduct.Id, opp.AccountId, 'test2');
            insert insurancePolicy2;

            SB_Product__c testProduct = [SELECT Id , Fee_Amount__c FROM SB_Product__c WHERE Id =: insuranceProduct.Id];
            testProduct.Fee_Amount__c = 1;
            try {
                update testProduct;
            } catch (Exception ex) {
                System.assert(ex.getMessage().contains(System.Label.Invalid_InsurancePolicy_Access));
            }
        }
        List<InsurancePolicy> actualPolicies = [SELECT Id, StandardFeeAmount, Commission_Amount__c, Inception_Date__c, Expiry_Date__c FROM InsurancePolicy];
        System.assertEquals(2, actualPolicies.size(), 'The org has to have only 2 Insurance Policy records');

        System.runAs(sysAdmin) {
            List<PermissionSetAssignment> assignments2 = new List<PermissionSetAssignment>();

            for(PermissionSet tempPermission : insurancePermissionSets) {
                assignments2.add(new PermissionSetAssignment(AssigneeId = insuranceUser2.Id, PermissionSetId = tempPermission.Id));
            }
            insert assignments2;
        }

        System.runAs(insuranceUser2) {
            SB_Product__c testProduct = [SELECT Id , Fee_Amount__c FROM SB_Product__c WHERE Id =: insuranceProduct.Id];
            testProduct.Fee_Amount__c = 1;
            try {
                update testProduct;
            } catch (Exception ex) {
                System.assert(ex.getMessage().contains(System.Label.InsurancePolisies_owned_by_another_User));
            }
        }

        Test.stopTest();
    }

    private static SB_Product__c createInsuranceProduct(Opportunity opp) {
        PicklistEntry grandParentValue = InsurancePolicy.Grand_Parent_Product__c.getDescribe().getPicklistValues()[0];
        PicklistEntry parenProductValue= PARENT_2_G_PARENT.get(grandParentValue)[0];
        PicklistEntry productValue = PRODUCT_2_PARENT.get(parenProductValue)[0];
        PicklistEntry countryOfUnderlyingRisk = SB_Product__c.Country_of_Underlying_Risk__c.getDescribe().getPicklistValues()[0];
        PicklistEntry currencyIsoCode = SB_Product__c.CurrencyIsoCode.getDescribe().getPicklistValues()[0];
        PicklistEntry legalEntityOfBooking = SB_Product__c.Balance_Sheet_of_Booking__c.getDescribe().getPicklistValues()[0];
        Date startDate = Date.newInstance(System.today().year(), 1,1);

        SB_Product__c insuranceProduct = new SB_Product__c(
                Opportunity__c = opp.Id,
                Client__c = opp.AccountId,
                Grand_Parent_Product__c = grandParentValue.value,
                Parent_Product__c = parenProductValue.value,
                SA_Product__c = productValue.value,
                Product_Division__c = INSURANCE,
                Country_of_Underlying_Risk__c = countryOfUnderlyingRisk.value,
                CurrencyIsoCode = currencyIsoCode.value,
                Balance_Sheet_of_Booking__c = legalEntityOfBooking.value,
                Premium_Amount__c = AMOUNT,
                Commission_Amount__c = AMOUNT,
                Fee_Amount__c = AMOUNT,
                Commission_Frequency__c = 'Monthly',
                Fee_Frequency__c = 'Monthly',
                Inception_Date__c = startDate,
                Expiry_Date__c = startDate.addMonths(MONTHS),
                RecordTypeId = INSURANCE_PRODUCT_RT_ID
        );
        return insuranceProduct;
    }

    private static User createInsuranceUser(fflib_SObjectUnitOfWork uow, String lName) {
        return (User) new BLD_USER(uow).
                cibGlobalArea(INSURANCE).
                division(INSURANCE).
                businessUnit(INSURANCE).
                lastName(INSURANCE + '_' + lName).
                setField(User.ProfileId, UTL_Profile.getProfileId(DCN_Profile.BUSINESS_ADMIN)).
                getRecord();
    }

    private static InsurancePolicy createInsurancePolicy(Id productId, Id accountId, String policyName) {
        return new InsurancePolicy(SB_Product__c = productId, NameInsuredId = accountId, Name = policyName);
    }
}