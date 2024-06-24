/**
 * Test class for Update_Estimated_Rev_Schedule
 *
 * @author		Youssef Ibrahim (yibrahim@deloittece.com)
 * @date		January 2021
*/
@IsTest
public class Update_Estimated_Rev_Schedule_TEST {

    private static final String ADMIN_USERNAME = 'test.adminUser@test.com';
    private static final String DEF_ACC_NAME = 'Def Name for Acc';
    private static final String DEF_OPP_NAME = 'Def Name for Opportunity';
    private static final Integer NUMBER_OF_MONTHS = 24;
    private static final Integer ERS_TEST_SIZE = 5;
    private static final Integer FEE_AMOUNT = 100;
    private static final Integer RISK_WEIGHTED_VALUE = 20;

    private static Account acc;
    private static Opportunity opp;
    private static User sysAdmin;

    private static void getData(){
        sysAdmin = [SELECT Username FROM User WHERE UserName = :ADMIN_USERNAME];
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
            uow.commitWork();
        }

        System.runAs(sysAdmin){

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

            BLD_Product bldProduct = new BLD_Product(uow)
                    .useAdvisory()
                    .riskWeightedValue(RISK_WEIGHTED_VALUE)
                    .feeAmount(FEE_AMOUNT)
                    .billingStartDate(System.today())
                    .billingEndDate(System.today().addMonths(NUMBER_OF_MONTHS+1))
                    .estRevSchUpdated(false)
                    .linkToOpp(opp.Id)
                    .grandParentProduct('Advisory Fees');
            uow.commitWork();

            for(Integer i=0; i < ERS_TEST_SIZE; i++) {
                bldProduct.addEstimatedRevenueSchedule(new BLD_EstimatedRevenueSchedule(uow)
                        .useAdvisory());
            }
            uow.commitWork();
        }
    }

    @IsTest
    public static void shouldUpdateEstimatedRevenueSchedule() {
        getData();
        SB_Product__c prod = [
                SELECT
                        Current_Year_Fees__c,
                        Total_Fees__c,
                        EstRevSch_Updated__c,
                        Fee_Amount__c,
                        Fee_Frequency__c,
                    (SELECT Name
                    FROM Estimated_Revenue_Schedules__r)
                FROM SB_Product__c
                WHERE Opportunity__r.Name = :DEF_OPP_NAME];
        System.debug('WHY:: ' + prod);
        List<Estimated_Revenue_Schedule__c> ers = prod.Estimated_Revenue_Schedules__r;
        System.assertEquals(ERS_TEST_SIZE, ers.size());

        List<Update_Estimated_Rev_Schedule.genERSReq> requests = generateRequests(new List<SB_Product__c> {prod});

        Test.startTest();
        Update_Estimated_Rev_Schedule.updateEstimatedRevSch(requests);
        Test.stopTest();
        integer currentYear = System.today().Year();

        AggregateResult currentYearFees = [
                SELECT SUM(Fee_Amount__c) fees
                FROM Estimated_Revenue_Schedule__c
                WHERE Product__c = :prod.Id
                AND CALENDAR_YEAR(Estimated_Revenue_Date__c) = :currentYear
        ];
        AggregateResult totalFees = [
                SELECT SUM(Fee_Amount__c) fees
                FROM Estimated_Revenue_Schedule__c
                WHERE Product__c = :prod.Id
        ];

        System.assertEquals(ERS_TEST_SIZE*FEE_AMOUNT, currentYearFees.get('fees'));
        System.assertEquals(ERS_TEST_SIZE*FEE_AMOUNT, totalFees.get('fees'));
    }

    private static List<Update_Estimated_Rev_Schedule.genERSReq> generateRequests(List<SB_Product__c> prods) {
        List<Update_Estimated_Rev_Schedule.genERSReq> requestsToReturn = new List<Update_Estimated_Rev_Schedule.genERSReq>();
        for (SB_Product__c prod : prods) {
            Update_Estimated_Rev_Schedule.genERSReq request = new Update_Estimated_Rev_Schedule.genERSReq();
            request.feeAmount = prod.Fee_Amount__c;
            request.feeFrequency = prod.Fee_Frequency__c;
            request.prodID = prod.Id;
            requestsToReturn.add(request);
        }
        return requestsToReturn;
    }
}