/**
 * @author      Dzianisik Maksim
 * @date        Dec 2022
 * @description SFP-14444, test class for IAC_HomePageController class
 */
@IsTest
private class IAC_HomePageController_TEST {

    private static final Map<PicklistEntry, List<PicklistEntry>> PRODUCT_2_PARENT = UTL_Picklist.getDependentToControllingMap(InsurancePolicy.Product_Type__c, InsurancePolicy.Parent_Product__c);
    private static final Map<PicklistEntry, List<PicklistEntry>> PARENT_2_G_PARENT = UTL_Picklist.getDependentToControllingMap(InsurancePolicy.Parent_Product__c, InsurancePolicy.Grand_Parent_Product__c);
    private static final Integer AMOUNT = 100;
    private static final Integer MONTHS = 11;
    private static final Integer NUMBER_OF_RECORDS = 10;
    private static final String USER_NAME = 'testinsurancepolicy@example.com';
    private static final List<String> FILTERS = new List<String>{'MTD', 'QTD', 'YTD'};


    @TestSetup
    static void testSetup() {
        User testUser = (User) new BLD_USER().useSysAdmin().userName(USER_NAME).commitWork().getRecord();

        System.runAs(testUser) {
            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            BLD_Account testAcc = new BLD_Account(uow)
                    .useGroupParent()
                    .CIF('0')
                    .CIFActiveCode('A');
            for(Integer i = 0; i < NUMBER_OF_RECORDS; ++i) {
                new BLD_Opportunity(uow)
                        .client(testAcc)
                        .stage(DMN_Opportunity.ST_DEVELOP)
                        .name('toCloseWon' + i);
            }
            for(Integer i = 0; i < NUMBER_OF_RECORDS; ++i) {
                new BLD_Opportunity(uow)
                        .client(testAcc)
                        .stage(DMN_Opportunity.ST_DEVELOP);
            }
            uow.commitWork();
        }
    }

    @IsTest
    static void bookOfBusinessInceptedTest() {
        User testUser = SEL_Users.newInstance().selectByUserName(new Set<String>{USER_NAME}).get(0);
        System.runAs(testUser) {
            List<Account> accounts = new SEL_Accounts().selectWithoutCondition();
            Assert.isTrue(accounts.size() == 1, 'There has to be only 1 account');

            Test.startTest();
            List<InsurancePolicy> policies = new List<InsurancePolicy>();
            for(Integer i = 0; i < NUMBER_OF_RECORDS; ++i){
                policies.add(createInsurancePolicy(accounts[0].Id, 'Temp_policy_' + i));
            }

            insert policies;

            List<Opportunity> opportunities = [SELECT Id, StageName FROM Opportunity WHERE Name LIKE 'toCloseWon%'];
            Assert.areEqual(NUMBER_OF_RECORDS, opportunities.size(), 'Checking the number of records');

            List<SB_Product__c> products = new List<SB_Product__c>();
            for (Opportunity tempOpp : opportunities) {
                products.add(
                        (SB_Product__c) new BLD_Product()
                                .linkToOpp(tempOpp.Id)
                                .getRecord()
                );
                tempOpp.StageName = DMN_Opportunity.ST_CLOSED_WON;
                tempOpp.ReasonForWinLossPickList__c = 'Pricing Competitive';
                tempOpp.Reason_Won_Lost_Detail__c = 'Pricing Competitive';
                tempOpp.Reason_Won_Lost_Comments__c = BLD_Opportunity.WON_COMMENTS;
            }
            insert products;
            update opportunities;

            IAC_HomePageController.BookOfBusinessWrapper testWrapper = new IAC_HomePageController.BookOfBusinessWrapper();
            for(String filter : FILTERS) {
                testWrapper = IAC_HomePageController.getBookOfBusiness(filter);
                checkingAssertForIncepted(testWrapper, filter);
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void bookOfBusinessRenewedTest() {
        User testUser = SEL_Users.newInstance().selectByUserName(new Set<String>{USER_NAME}).get(0);
        System.runAs(testUser) {
            List<Account> accounts = new SEL_Accounts().selectWithoutCondition();
            Assert.isTrue(accounts.size() == 1, 'There has to be only 1 account');

            Test.startTest();
            List<InsurancePolicy> policies = new List<InsurancePolicy>();
            Date newStartDate = Date.newInstance(System.today().year() - 1, 1,1);
            Date today = System.today();
            for (Integer i = 0; i < NUMBER_OF_RECORDS; ++i) {
                InsurancePolicy tempPolicy = createInsurancePolicy(accounts[0].Id, 'Temp_policy_' + i);
                tempPolicy.Inception_Date__c = newStartDate;
                tempPolicy.Renewal_Date__c = today;
                tempPolicy.Date_Renewed__c = today;
                tempPolicy.Expiry_Date__c = today;
                policies.add(tempPolicy);
            }
            insert policies;

            List<Opportunity> opportunities = [SELECT Id, StageName FROM Opportunity WHERE Name LIKE 'toCloseWon%'];
            Assert.areEqual(NUMBER_OF_RECORDS, opportunities.size(), 'Checking the number of records');

            List<SB_Product__c> products = new List<SB_Product__c>();
            for (Opportunity tempOpp : opportunities) {
                products.add(
                        (SB_Product__c) new BLD_Product()
                        .linkToOpp(tempOpp.Id)
                        .getRecord()
                );
                tempOpp.StageName = DMN_Opportunity.ST_CLOSED_WON;
                tempOpp.ReasonForWinLossPickList__c = 'Pricing Competitive';
                tempOpp.Reason_Won_Lost_Detail__c = 'Pricing Competitive';
                tempOpp.Reason_Won_Lost_Comments__c = BLD_Opportunity.WON_COMMENTS;
            }
            insert products;
            update opportunities;

            IAC_HomePageController.BookOfBusinessWrapper testWrapper = new IAC_HomePageController.BookOfBusinessWrapper();
            for(String filter : FILTERS) {
                testWrapper = IAC_HomePageController.getBookOfBusiness(filter);
                checkingAssertForRenewed(testWrapper);
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void monthActionsTest() {
        User testUser = SEL_Users.newInstance().selectByUserName(new Set<String>{USER_NAME}).get(0);
        System.runAs(testUser) {
            List<Account> accounts = new SEL_Accounts().selectWithoutCondition();
            Assert.isTrue(accounts.size() == 1, 'There has to be only 1 account');

            List<InsurancePolicy> policies = new List<InsurancePolicy>();
            Date today = System.today();
            for(Integer i = 0; i < NUMBER_OF_RECORDS; ++i){
                InsurancePolicy tempPolicy = createInsurancePolicy(accounts[0].Id, 'Temp_policy_' + i);
                tempPolicy.Renewal_Date__c = today;
                tempPolicy.Date_Renewed__c = today.addDays(1);
                policies.add(tempPolicy);
            }
            insert policies;

            Test.startTest();
            IAC_HomePageController.MonthActionItemsWrapper monthActionItemsWrapper = IAC_HomePageController.getMonthActions();
            Assert.areEqual(NUMBER_OF_RECORDS, monthActionItemsWrapper.policiesUpForRenewal, 'Has to have ' + NUMBER_OF_RECORDS + ' records');
            Assert.areEqual(0, monthActionItemsWrapper.openClaims, 'Has to be zero');
            Assert.areEqual(NUMBER_OF_RECORDS * 2, monthActionItemsWrapper.openOpp, 'Has to have ' + (NUMBER_OF_RECORDS * 2) + ' records');
            Test.stopTest();
        }
    }


    private static void checkingAssertForIncepted(IAC_HomePageController.BookOfBusinessWrapper wrapper, String filter) {
        Integer multiplier = filter == 'MTD' ? 1 : filter == 'QTD' ? 3 : 12;
        Assert.areEqual(NUMBER_OF_RECORDS, wrapper.actualPoliciesIncepted, 'There have to be only ' + NUMBER_OF_RECORDS + ' records');
        Assert.areEqual(0, wrapper.actualPoliciesRenewed, ' There have not to be Renewed policies');
        Assert.areEqual(NUMBER_OF_RECORDS * AMOUNT * multiplier, (Integer) wrapper.actualPremOfPoliciesIncepted, ' The value of received amount from all policies for the ' + filter);
        Assert.areEqual(50, wrapper.oppConversionRatio, 'Opportunity Conversion Ratio has to be 50%');
    }

    private static void checkingAssertForRenewed(IAC_HomePageController.BookOfBusinessWrapper wrapper) {
        Assert.areEqual(NUMBER_OF_RECORDS, wrapper.actualPoliciesRenewed, 'There have to be only ' + NUMBER_OF_RECORDS + ' records');
        Assert.areEqual(NUMBER_OF_RECORDS, wrapper.actualPoliciesIncepted, 'There have to be only ' + NUMBER_OF_RECORDS + ' records');
        Assert.areEqual(NUMBER_OF_RECORDS * AMOUNT, (Integer) wrapper.actualPremOfPoliciesRenewed, ' The value of received amount from all policies');
        Assert.areEqual(50, wrapper.oppConversionRatio, 'Opportunity Conversion Ratio has to be 50%');
    }

    private static InsurancePolicy createInsurancePolicy(Id accountId, String pName) {
        PicklistEntry grandParentValue = InsurancePolicy.Grand_Parent_Product__c.getDescribe().getPicklistValues()[0];
        PicklistEntry parenProductValue= PARENT_2_G_PARENT.get(grandParentValue)[0];
        PicklistEntry productValue = PRODUCT_2_PARENT.get(parenProductValue)[0];
        Date startDate = Date.newInstance(System.today().year(), 1,1);
        return new InsurancePolicy(
                Name = pName,
                NameInsuredId = accountId,
                Product_Type__c = productValue.value,
                Parent_Product__c = parenProductValue.value,
                Grand_Parent_Product__c = grandParentValue.value,
                Inception_Date__c = startDate,
                Expiry_Date__c = startDate.addMonths(MONTHS),
                PremiumAmount = AMOUNT,
                PremiumFrequency = 'Monthly',
                Status = 'In Force'
        );
    }
}