/**
* @FuncArea PBB Lifestyle
* @Author Zofia Walczewska
* @Date 30.10.2019
* @UserStory US-4311
* @Description APEX test class for PBB_Lifestyle_FocusClientController.
*/
@isTest
public with sharing class PBB_Lifestyle_FocusClientControllerTest {

    /**
    * @return  Account 	  testAccount   testAccount generated with related Revenue and Profitabiliy records.
    * @Description Generates Account record with related Revenue and Profitability records used for testing.
    */
    @TestSetup
    private static void setupData(){
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        for(Integer i=0; i<10; i++){
            new BLD_Account(uow)
                    .name('Test Account')
                    .addRevenueAndProfitability(
                        new BLD_RevenueAndProfitability(uow)
                            .pmtExtractDate(Date.today())
                    );
        }
        for(Integer i=0; i<10; i++){
            new BLD_Account(uow)
                    .name('Test Account');
        }
        uow.commitWork();
    }
    /**
    *@Description Generates Account record with related Account Information records and tests the
                        PBB_Lifestyle_FocusClientController.fetchAccounts() method.
    */
    @isTest
    public static void shouldFetchOnlyAccountsWithRevenueAndProfitabilityWhenFetchingRecords() {
        List<PBB_Lifestyle_FocusClientController.wrapperClass> returnedRevenueList = new List<PBB_Lifestyle_FocusClientController.wrapperClass>();
        Test.startTest();
        returnedRevenueList = PBB_Lifestyle_FocusClientController.fetchAccounts();
        Test.stopTest();
        system.assertEquals(10, returnedRevenueList.size());
    }
}