/**
 * Test class for Generate_Estimated_Rev_Schedule
 *
 * @author		Youssef Ibrahim (yibrahim@deloittece.com)
 * @date		December 2020
*/
@IsTest
public class Generate_Estimated_Rev_Schedule_TEST {

    private static final String ADMIN_USERNAME = 'test.adminUser@test.com';
    private static final String TEST_CIB_USERNAME = 'test.cibUser@test.com';
    private static final String TEST_COMMB_USERNAME = 'test.commbUser@test.com';
    private static final String DEF_ACC_NAME = 'Def Name for Acc';
    private static final String DEF_CON_NAME = 'DefNamefor Contact';
    private static final String DEF_OPP_NAME = 'Def Name for Opportunity';
    private static final Integer NUMBER_OF_MONTHS = 24;
    private static final Integer ERS_TEST_SIZE = 5;
    private static final Integer FEE_AMOUNT = 100;
    private static final Integer RISK_WEIGHTED_VALUE = 20;

    private static Account acc;
    private static Opportunity opp;
    private static User sysAdmin;
    private static User cibUser;
    private static User commbUser;

    private static void getData(){
        for(User u : [  SELECT Username
        FROM User
        WHERE UserName IN: new String[]{TEST_COMMB_USERNAME, TEST_CIB_USERNAME, ADMIN_USERNAME}]){
            if(u.UserName == TEST_CIB_USERNAME){
                cibUser = u;
            }
            if(u.UserName == TEST_COMMB_USERNAME){
                commbUser = u;
            }
            if(u.UserName == ADMIN_USERNAME){
                sysAdmin = u;
            }
        }

        acc = [SELECT Name, Task_Name__c FROM Account WHERE Name = :DEF_ACC_NAME];
        opp = [SELECT Name, Task_Name__c FROM Opportunity WHERE Name = :DEF_OPP_NAME];
    }

    @testSetup
    static void prepareData() {

        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow;
        System.runAs(new User(Id = UserInfo.getUserId())){
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

            sysAdmin = (User)new BLD_USER(uow).userName(ADMIN_USERNAME).useSysAdmin().syncContact().getRecord();
            cibUser = (User)new BLD_USER(uow).userName(TEST_CIB_USERNAME).useCib().syncContact().getRecord();
            commbUser = (User)new BLD_USER(uow).userName(TEST_COMMB_USERNAME).useCommB().syncContact().getRecord();
            uow.commitWork();
        }


        System.runAs(sysAdmin){
            Set<String> prodFrequencies = new Set<String> {
                    DMN_SB_Product.FREQ_ONCE_OFF,
                    DMN_SB_Product.FREQ_MONTHLY,
                    DMN_SB_Product.FREQ_QUARTERLY,
                    DMN_SB_Product.FREQ_ANNUAL,
                    DMN_SB_Product.FREQ_BIANNUAL

            };
            BLD_Opportunity bldOpportunity = new BLD_Opportunity(uow)
                    .name(DEF_OPP_NAME)
                    .stage(DMN_Opportunity.ST_DEVELOP);

            BLD_Account bldAcc = new BLD_Account(uow)
                    .name(DEF_ACC_NAME)
                    .addOpportunity(bldOpportunity);
            uow.commitWork();

            acc = (Account) bldAcc.getRecord();
            opp = (Opportunity) bldOpportunity.getRecord();
            Datetime before2010 = Datetime.newInstance(2009,1,1,0,0,0);
            Test.setCreatedDate(acc.Id, before2010);
            Test.setCreatedDate(opp.Id, before2010);

            for(String freq : prodFrequencies) {
                BLD_Product bldProduct = new BLD_Product(uow)
                        .useAdvisory()
                        .feeFrequency(freq)
                        .riskWeightedValue(RISK_WEIGHTED_VALUE)
                        .feeAmount(FEE_AMOUNT)
                        .billingStartDate(System.today())
                        .billingEndDate(System.today().addMonths(NUMBER_OF_MONTHS+1))
                        .estRevSchUpdated(false)
                        .linkToOpp(opp.Id)
                        .grandParentProduct('Advisory Fees');

                for(Integer i=0; i < ERS_TEST_SIZE; i++) {
                    bldProduct.addEstimatedRevenueSchedule(new BLD_EstimatedRevenueSchedule(uow)
                            .useAdvisory());
                }
            }
            uow.commitWork();
        }
    }

    @IsTest
    static void shouldGenerateEstimatedRevSchForOnceOffFrequencyProduct() {
        SB_Product__c prod = [
                SELECT
                        Billing_Start_Date__c, Billing_End_Date__c,
                        Fee_Frequency__c, Fee_Amount__c,
                        Risk_Weighted_Value__c, EstRevSch_Updated__c,
                (SELECT
                        Name
                FROM Estimated_Revenue_Schedules__r)
                FROM SB_Product__c
                WHERE Opportunity__r.Name = :DEF_OPP_NAME
                AND Fee_Frequency__c = :DMN_SB_Product.FREQ_ONCE_OFF];

        List<Estimated_Revenue_Schedule__c> ers = prod.Estimated_Revenue_Schedules__r;
        System.assertEquals(ERS_TEST_SIZE+1, ers.size());

        List<Generate_Estimated_Rev_Schedule.genERSReq> requests = generateRequests(new List<SB_Product__c> {prod});

        Test.startTest();
        Generate_Estimated_Rev_Schedule.generateEstimatedReveSch(requests);
        Test.stopTest();

        SB_Product__c prodAfterUpdate = [
                SELECT Current_Year_Fees__c, Fee_Amount__c, Total_Fees__c, EstRevSch_Updated__c
                FROM SB_Product__c
                WHERE Id = :prod.Id
        ];

        List<AggregateResult> relatedERS = [
                SELECT SUM(Fee_Amount__c)
                FROM Estimated_Revenue_Schedule__c
                WHERE Product__c = :prod.Id
        ];

        System.assertEquals(prod.Fee_Amount__c, prodAfterUpdate.Fee_Amount__c);
        System.assertEquals(relatedERS.get(0).get('expr0'), prodAfterUpdate.Total_Fees__c);
        System.assertEquals(relatedERS.get(0).get('expr0'), prodAfterUpdate.Current_Year_Fees__c);
        System.assert(prodAfterUpdate.EstRevSch_Updated__c);
    }

    @IsTest
    static void shouldGenerateEstimatedRevSchForMonthlyFrequencyProduct() {
        SB_Product__c prod = [
                SELECT
                        Billing_Start_Date__c, Billing_End_Date__c,
                        Fee_Frequency__c, Fee_Amount__c,
                        Risk_Weighted_Value__c, EstRevSch_Updated__c,
                        Opportunity__r.CreatedDate,
                        (SELECT Name
                        FROM Estimated_Revenue_Schedules__r)
                FROM SB_Product__c
                WHERE Opportunity__r.Name = :DEF_OPP_NAME
                AND Fee_Frequency__c = :DMN_SB_Product.FREQ_MONTHLY];

        List<Estimated_Revenue_Schedule__c> ers = prod.Estimated_Revenue_Schedules__r;
        System.assertEquals(NUMBER_OF_MONTHS+ERS_TEST_SIZE+2, ers.size());

        Set<Id> ersShouldBeDelete = new Set<Id>();
        for (Estimated_Revenue_Schedule__c e : ers) {
            ersShouldBeDelete.add(e.Id);
        }

        List<Generate_Estimated_Rev_Schedule.genERSReq> requests = generateRequests(new List<SB_Product__c> {prod});

        Test.startTest();
        Generate_Estimated_Rev_Schedule.generateEstimatedReveSch(requests);
        Test.stopTest();

        List<Estimated_Revenue_Schedule__c> deletedErs = [
                SELECT Id
                FROM Estimated_Revenue_Schedule__c
                WHERE Id IN :ersShouldBeDelete
        ];

        List<Estimated_Revenue_Schedule__c> insertedErs = [
                SELECT Id, Fee_Amount__c, Risk_Weighted_Value__c
                FROM Estimated_Revenue_Schedule__c
                WHERE Product__c = :prod.Id
        ];


        System.assertEquals(0, deletedErs.size());
        System.assertEquals(NUMBER_OF_MONTHS+2, insertedErs.size());

        for (Estimated_Revenue_Schedule__c er : insertedErs) {
            System.assertEquals(prod.Fee_Amount__c, er.Fee_Amount__c);
            System.assertEquals(prod.Risk_Weighted_Value__c*prod.Fee_Amount__c, er.Risk_Weighted_Value__c);
        }
    }

    @IsTest
    static void shouldGenerateEstimatedRevSchForQuarterlyProduct() {
        SB_Product__c prod = [
                SELECT
                        Billing_Start_Date__c, Billing_End_Date__c,
                        Fee_Frequency__c, Fee_Amount__c,
                        Risk_Weighted_Value__c, EstRevSch_Updated__c,
                        Opportunity__r.CreatedDate,
                        (SELECT Name
                        FROM Estimated_Revenue_Schedules__r)
                FROM SB_Product__c
                WHERE Opportunity__r.Name = :DEF_OPP_NAME
                AND Fee_Frequency__c = :DMN_SB_Product.FREQ_QUARTERLY];

        List<Estimated_Revenue_Schedule__c> ers = prod.Estimated_Revenue_Schedules__r;
        System.assertEquals((NUMBER_OF_MONTHS/3)+ERS_TEST_SIZE+2, ers.size());

        Set<Id> ersShouldBeDelete = new Set<Id>();
        for (Estimated_Revenue_Schedule__c e : ers) {
            ersShouldBeDelete.add(e.Id);
        }

        List<Generate_Estimated_Rev_Schedule.genERSReq> requests = generateRequests(new List<SB_Product__c> {prod});

        Test.startTest();
        Generate_Estimated_Rev_Schedule.generateEstimatedReveSch(requests);
        Test.stopTest();

        List<Estimated_Revenue_Schedule__c> deletedErs = [
                SELECT Id
                FROM Estimated_Revenue_Schedule__c
                WHERE Id IN :ersShouldBeDelete
        ];

        List<Estimated_Revenue_Schedule__c> insertedErs = [
                SELECT Id, Fee_Amount__c, Risk_Weighted_Value__c
                FROM Estimated_Revenue_Schedule__c
                WHERE Product__c = :prod.Id
        ];


        System.assertEquals(0, deletedErs.size());
        System.assertEquals((NUMBER_OF_MONTHS/3)+2, insertedErs.size());

        for (Estimated_Revenue_Schedule__c er : insertedErs) {
            System.assertEquals(prod.Fee_Amount__c, er.Fee_Amount__c);
            System.assertEquals(prod.Risk_Weighted_Value__c*prod.Fee_Amount__c, er.Risk_Weighted_Value__c);
        }
    }

    @IsTest
    static void shouldGenerateEstimatedRevSchForAnnualProduct() {
        SB_Product__c prod = [
                SELECT
                        Billing_Start_Date__c, Billing_End_Date__c,
                        Fee_Frequency__c, Fee_Amount__c,
                        Risk_Weighted_Value__c, EstRevSch_Updated__c,
                        Opportunity__r.CreatedDate,
                        (SELECT Name
                        FROM Estimated_Revenue_Schedules__r)
                FROM SB_Product__c
                WHERE Opportunity__r.Name = :DEF_OPP_NAME
                AND Fee_Frequency__c = :DMN_SB_Product.FREQ_ANNUAL];

        List<Estimated_Revenue_Schedule__c> ers = prod.Estimated_Revenue_Schedules__r;
        System.assertEquals((NUMBER_OF_MONTHS/12)+ERS_TEST_SIZE+1, ers.size());

        Set<Id> ersShouldBeDelete = new Set<Id>();
        for (Estimated_Revenue_Schedule__c e : ers) {
            ersShouldBeDelete.add(e.Id);
        }

        List<Generate_Estimated_Rev_Schedule.genERSReq> requests = generateRequests(new List<SB_Product__c> {prod});

        Test.startTest();
        Generate_Estimated_Rev_Schedule.generateEstimatedReveSch(requests);
        Test.stopTest();

        List<Estimated_Revenue_Schedule__c> deletedErs = [
                SELECT Id
                FROM Estimated_Revenue_Schedule__c
                WHERE Id IN :ersShouldBeDelete
        ];

        List<Estimated_Revenue_Schedule__c> insertedErs = [
                SELECT Id, Fee_Amount__c, Risk_Weighted_Value__c
                FROM Estimated_Revenue_Schedule__c
                WHERE Product__c = :prod.Id
        ];


        System.assertEquals(0, deletedErs.size());
        System.assertEquals((NUMBER_OF_MONTHS/12)+1, insertedErs.size());

        for (Estimated_Revenue_Schedule__c er : insertedErs) {
            System.assertEquals(prod.Fee_Amount__c, er.Fee_Amount__c);
            System.assertEquals(prod.Risk_Weighted_Value__c*prod.Fee_Amount__c, er.Risk_Weighted_Value__c);
        }
    }

    @IsTest
    static void shouldGenerateEstimatedRevSchForBiAnnualProduct() {
        SB_Product__c prod = [
                SELECT
                        Billing_Start_Date__c, Billing_End_Date__c,
                        Fee_Frequency__c, Fee_Amount__c,
                        Risk_Weighted_Value__c, EstRevSch_Updated__c,
                        Opportunity__r.CreatedDate,
                        (SELECT Name
                        FROM Estimated_Revenue_Schedules__r)
                FROM SB_Product__c
                WHERE Opportunity__r.Name = :DEF_OPP_NAME
                AND Fee_Frequency__c = :DMN_SB_Product.FREQ_BIANNUAL];

        List<Estimated_Revenue_Schedule__c> ers = prod.Estimated_Revenue_Schedules__r;
        System.assertEquals((NUMBER_OF_MONTHS/6)+ERS_TEST_SIZE+2, ers.size());

        Set<Id> ersShouldBeDelete = new Set<Id>();
        for (Estimated_Revenue_Schedule__c e : ers) {
            ersShouldBeDelete.add(e.Id);
        }

        List<Generate_Estimated_Rev_Schedule.genERSReq> requests = generateRequests(new List<SB_Product__c> {prod});

        Test.startTest();
        Generate_Estimated_Rev_Schedule.generateEstimatedReveSch(requests);
        Test.stopTest();

        List<Estimated_Revenue_Schedule__c> deletedErs = [
                SELECT Id
                FROM Estimated_Revenue_Schedule__c
                WHERE Id IN :ersShouldBeDelete
        ];

        List<Estimated_Revenue_Schedule__c> insertedErs = [
                SELECT Id, Fee_Amount__c, Risk_Weighted_Value__c
                FROM Estimated_Revenue_Schedule__c
                WHERE Product__c = :prod.Id
        ];


        System.assertEquals(0, deletedErs.size());
        System.assertEquals((NUMBER_OF_MONTHS/6)+2, insertedErs.size());

        for (Estimated_Revenue_Schedule__c er : insertedErs) {
            System.assertEquals(prod.Fee_Amount__c, er.Fee_Amount__c);
            System.assertEquals(prod.Risk_Weighted_Value__c*prod.Fee_Amount__c, er.Risk_Weighted_Value__c);
        }
    }

    private static List<Generate_Estimated_Rev_Schedule.genERSReq> generateRequests(List<SB_Product__c> prods) {
        List<Generate_Estimated_Rev_Schedule.genERSReq> requestsToReturn = new List<Generate_Estimated_Rev_Schedule.genERSReq>();
        for (SB_Product__c prod : prods) {
            Generate_Estimated_Rev_Schedule.genERSReq request = new Generate_Estimated_Rev_Schedule.genERSReq();
            request.billingStartDate = prod.Billing_Start_Date__c;
            request.billingEndDate = prod.Billing_End_Date__c;
            request.feeAmount = prod.Fee_Amount__c;
            request.feeFrequency = prod.Fee_Frequency__c;
            request.riskWeightedValue = prod.Risk_Weighted_Value__c;
            request.prodID = prod.Id;
            request.EstRevSch_Updated = prod.EstRevSch_Updated__c;
            requestsToReturn.add(request);
        }
        return requestsToReturn;
    }
}