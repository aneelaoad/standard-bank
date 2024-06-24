/**
 * @author :        Dzianisik Maksim
 * @date :          Apr. 2024
 * @description :   SFP-37889 Code coverage for OpportunityTeamMember trigger logic
 */

@IsTest(SeeAllData=false)
private class DMN_OpportunityTeamMember_TEST {

    private static final String CIB_USER_EMAIL = 'testcibuser2024@example.com';
    private static final String DISTRIBUTE_USER_EMAIL = 'testdistribute2024@example.com';
    private static User cibUser;
    private static User distributionUser;

    @TestSetup
    private static void setup() {
        User cibUser = (User) new BLD_USER()
                .useCib()
                .email(CIB_USER_EMAIL)
                .profile(DCN_Profile.CUSTOM_STD_MOBILE)
                .division(DMN_User.IB_DIVISION)
                .commitWork().getRecord();

        new BLD_USER()
                .profile(DCN_Profile.COMMB_STD_MOBILE)
                .email(DISTRIBUTE_USER_EMAIL)
                .division(DMN_User.IB_DIVISION)
                .businessUnit(DMN_User.BUSINESS_UNIT_DISTRIBUTION)
                .commitWork();

        System.runAs(cibUser) {
            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            new BLD_Account(uow)
                    .addOpportunity(
                            new BLD_Opportunity(uow)
                    );
            uow.commitWork();
        }
    }

    @IsTest
    static void testDistributedPositive() {
        List<User> testUsers = [SELECT Id, Email FROM User WHERE Email =: CIB_USER_EMAIL OR Email =: DISTRIBUTE_USER_EMAIL];
        Assert.isTrue(testUsers.size() == 2, 'Has to be 2 Users');

        assignUsers(testUsers);
        Assert.areEqual(cibUser.Email, CIB_USER_EMAIL, 'Has to be the same');
        Assert.areEqual(distributionUser.Email, DISTRIBUTE_USER_EMAIL, 'Has to be the same');

        List<Opportunity> actualOpp = getActualRecords();
        Assert.isTrue(actualOpp.size() == 1, 'Has to be only one Opportunity');
        Assert.isFalse(actualOpp[0].Is_Opportunity_Distributed__c, 'Opportunity has not to be distributed');

        OpportunityTeamMember distributionMember = newMember(actualOpp[0].Id, distributionUser.Id);
        System.runAs(cibUser) {
            insert distributionMember;
        }

        actualOpp = getActualRecords();
        Assert.isTrue(actualOpp[0].Is_Opportunity_Distributed__c, 'Opportunity has to be distributed');

        Test.startTest();
        delete actualOpp;
        undelete actualOpp;
        Test.stopTest();

        actualOpp = getActualRecords();
        Assert.isTrue(actualOpp[0].Is_Opportunity_Distributed__c, 'Opportunity has to be distributed');

        delete distributionMember;
        actualOpp = getActualRecords();
        Assert.isFalse(actualOpp[0].Is_Opportunity_Distributed__c, 'Opportunity has not to be distributed');
    }

    @IsTest
    static void testDistributedNegative() {
        List<User> testUsers = [SELECT Id, Email, Business_Unit__c FROM User WHERE Email =: CIB_USER_EMAIL OR Email =: DISTRIBUTE_USER_EMAIL];
        Assert.isTrue(testUsers.size() == 2, 'Has to be 2 Users');

        assignUsers(testUsers);
        Assert.areEqual(cibUser.Email, CIB_USER_EMAIL, 'Has to be the same');

        distributionUser.Business_Unit__c = 'Debt Capital Markets';
        update distributionUser;

        List<Opportunity> actualOpp = getActualRecords();
        Assert.isTrue(actualOpp.size() == 1, 'Has to be only one Opportunity');
        Assert.isFalse(actualOpp[0].Is_Opportunity_Distributed__c, 'Opportunity has not to be distributed');

        OpportunityTeamMember nonDistributionMember = newMember(actualOpp[0].Id, distributionUser.Id);
        System.runAs(cibUser) {
            insert nonDistributionMember;
        }

        actualOpp = getActualRecords();
        Assert.isFalse(actualOpp[0].Is_Opportunity_Distributed__c, 'Opportunity has not to be distributed');

    }

    @IsTest
    static void testDistributionBulk() {
        List<User> testUsers = [SELECT Id, Email, Business_Unit__c FROM User WHERE Email =: CIB_USER_EMAIL OR Email =: DISTRIBUTE_USER_EMAIL];
        Assert.isTrue(testUsers.size() == 2, 'Has to be 2 Users');

        assignUsers(testUsers);
        Assert.areEqual(cibUser.Email, CIB_USER_EMAIL, 'Has to be the same');

        List<Account> actualAcc = [SELECT Id FROM Account];
        Assert.isTrue(actualAcc.size() == 1, 'Has to be only 1 Account');

        List<Opportunity> newOpp = new List<Opportunity>();
        Date currentDate = Date.today();
        Integer numberOfOpportunities;
        for (numberOfOpportunities = 0; numberOfOpportunities < 10; ++numberOfOpportunities) {
            newOpp.add(new Opportunity(
                    AccountId = actualAcc[0].Id,
                    Name = 'test_name_' + numberOfOpportunities,
                    Description = 'test_description_' + numberOfOpportunities,
                    Start_Date__c = currentDate,
                    CloseDate = currentDate.addMonths(5),
                    StageName = DMN_Opportunity.ST_LEAD
            ));
        }

        List<Opportunity> actualRecords;

        System.runAs(cibUser) {
            insert newOpp;

            actualRecords = getActualRecords();
            Assert.areEqual(actualRecords.size(), numberOfOpportunities + 1, 'has to be the same');

            for (Opportunity tempOpp: actualRecords) {
                Assert.isFalse(tempOpp.Is_Opportunity_Distributed__c, 'Opportunity has not to be distributed');
            }

            List<OpportunityTeamMember> newMembers = new List<OpportunityTeamMember>();
            for (Opportunity tempOpp : actualRecords) {
                newMembers.add(newMember(tempOpp.Id, distributionUser.Id));
            }

            Test.startTest();
            insert newMembers;
            Test.stopTest();
        }

        actualRecords = getActualRecords();
        for (Opportunity tempOpp: actualRecords) {
            Assert.isTrue(tempOpp.Is_Opportunity_Distributed__c, 'Opportunity has to be distributed');
        }

    }

    private static List<Opportunity> getActualRecords() {
        return [SELECT Id, Is_Opportunity_Distributed__c FROM Opportunity];
    }

    private static OpportunityTeamMember newMember(Id opportunityId, Id userId) {
        return new OpportunityTeamMember(
                OpportunityId = opportunityId,
                OpportunityAccessLevel = 'Read',
                TeamMemberRole = 'Product Specialist',
                UserId = userId
        );
    }

    private static void assignUsers(List<User> testUsers) {
        for (User u : testUsers) {
            if (u.Email == CIB_USER_EMAIL) {
                cibUser = u;
            }else {
                distributionUser = u;
            }
        }
    }
}