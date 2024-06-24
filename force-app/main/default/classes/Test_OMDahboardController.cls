/****************************************************************\
    @ Author        : Prabhanshu Agrawal
    @ Date          : Feb 2015
    @description   : Test class for OMDashboardController.cls

    @ Last Modified By  :   Manoj Gupta       
    @ Last Modified On  :   Dec 2015
    @ Last Modified Reason  : EN:0838 - Replacing Corporate Banking references to Client Coverage
*****************************************************************/
@IsTest
private class Test_OMDahboardController {

    public static list<Opportunity> olstOpportunity = new list<Opportunity>();

    static void setupData(){
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
      
        olstOpportunity = new List<Opportunity>();
        for (Integer i = 0; i < 10; i++){
            olstOpportunity.add(
                (Opportunity) new BLD_Opportunity(uow)
                    .client(new BLD_Account(uow).useChild()
                        .franco('Angola')
                        .sector('Agriculture and Forestry')
                        .CIF('0' + i)
                        .CIFActiveCode('A')
                    )
                    .addProduct(
                        new BLD_Product(uow)
                    )
                    .getRecord()
            );
        }
        for (Integer i = 10; i < 20; i++){
            olstOpportunity.add(
                (Opportunity) new BLD_Opportunity(uow)
                    .client(new BLD_Account(uow).useChild()
                        .franco('Asia')
                        .sector('Fast Moving Consumer Goods')
                        .CIF('00' + i)
                        .CIFActiveCode('A')
                    )
                    .addProduct(
                        new BLD_Product(uow)
                    )
                    .getRecord()
            );
        }

        uow.commitWork();

        olstOpportunity[0].StageName = '3 - Closed Won';
        olstOpportunity[0].Reason_Won_Lost_Comments__c = '3 - Closed Won';                  
        olstOpportunity[1].StageName = '4 - Closed Lost';
        olstOpportunity[1].Reason_Won_Lost_Comments__c = '4 - Closed Lost';                 
        olstOpportunity[2].StageName = '3 - Closed Won';
        olstOpportunity[2].Reason_Won_Lost_Comments__c = '3 - Closed Won';                  
        olstOpportunity[3].StageName = '4 - Closed Lost';
        olstOpportunity[3].Reason_Won_Lost_Comments__c = '4 - Closed Lost';                 
        update olstOpportunity ;

        olstOpportunity[0].Actual_Close_Date__c = System.today() - 32;
        olstOpportunity[1].Actual_Close_Date__c = System.today() - 32;
        olstOpportunity[2].Actual_Close_Date__c = System.today().addYears(-1);
        olstOpportunity[3].Actual_Close_Date__c = System.today().addYears(-1);
        update olstOpportunity ;
        
    }

    @IsTest
    static void testForCorporateBanking() {
        User testUser = (User) new BLD_USER().useSysAdmin()
            .division('Client Coverage')
            .commitWork()
            .getRecord();

        test.startTest();
        system.runAs(testUser){
         
            setupData();
            try {
                OMDashboardController controller = new OMDashboardController();
                controller.getomJSON();
                controller.getAllOpportunitySectorlst();
                controller.getAllOpportunityPipelineDivlst();
                controller.gettopOpp();
                controller.getAllOpportunityPipelineSectorDivlst();
                controller.getSectorTopOpp();
                controller.getAllClosedOpportunitylst();
                controller.getAllClosedOpportunitySeclst();
                controller.getAllOpportunityPipelineFrancolst();
                controller.getTopOppPipelineDrillDownFranco();
                controller.getTopOppPipelineDrillDownSector();
                controller.getAllOpportunityClosedFrancolst();
                controller.getTopOppClosedWonDrillDownFranco();
                controller.getTopOppClosedLostDrillDownFranco();
                controller.getTopOppClosedWonPipelineDrillDownSector();
                controller.getTopOppClosedLostPipelineDrillDownSector();
            }
            catch (Exception ex) {
                System.assert(false, ex.getMessage());
            }
        }
        test.stopTest();
    }
  
    @IsTest
    static void testForBusinessEnablers() {
        User testUser = (User) new BLD_USER().useSysAdmin()
            .division('Business Enablers')
            .commitWork()
            .getRecord();
        setupData();
        test.startTest();
        system.runAs(testUser){
            try {
                OMDashboardController controller = new OMDashboardController();
                controller.getomJSON();
                controller.getAllOpportunitySectorlst();
                controller.getAllOpportunityPipelineDivlst();
                controller.gettopOpp();
                controller.getAllOpportunityPipelineSectorDivlst();
                controller.getSectorTopOpp();
                controller.getAllClosedOpportunitylst();
                controller.getAllClosedOpportunitySeclst();
                controller.getAllOpportunityPipelineFrancolst();
                controller.getTopOppPipelineDrillDownFranco();
                controller.getTopOppPipelineDrillDownSector();
                controller.getAllOpportunityClosedFrancolst();
                controller.getTopOppClosedWonDrillDownFranco();
                controller.getTopOppClosedLostDrillDownFranco();
                controller.getTopOppClosedWonPipelineDrillDownSector();
                controller.getTopOppClosedLostPipelineDrillDownSector();
            }
            catch (Exception ex) {
                System.assert(false, ex.getMessage());
            }
        }
        test.stopTest();
    }
  
    @IsTest
    static void testForGeneralManagement() {
        User testUser = (User) new BLD_USER().useSysAdmin()
            .division('General Management')
            .commitWork()
            .getRecord();
        setupData();
        test.startTest();
        system.runAs(testUser){
            try {
                OMDashboardController controller = new OMDashboardController();
                controller.getomJSON();
                controller.getAllOpportunitySectorlst();
                controller.getAllOpportunityPipelineDivlst();
                controller.gettopOpp();
                controller.getAllOpportunityPipelineSectorDivlst();
                controller.getSectorTopOpp();
                controller.getAllClosedOpportunitylst();
                controller.getAllClosedOpportunitySeclst();
                controller.getAllOpportunityPipelineFrancolst();
                controller.getTopOppPipelineDrillDownFranco();
                controller.getTopOppPipelineDrillDownSector();
                controller.getAllOpportunityClosedFrancolst();
                controller.getTopOppClosedWonDrillDownFranco();
                controller.getTopOppClosedLostDrillDownFranco();
                controller.getTopOppClosedWonPipelineDrillDownSector();
                controller.getTopOppClosedLostPipelineDrillDownSector();
            }
            catch (Exception ex) {
                System.assert(false, ex.getMessage());
            }
        }
        test.stopTest();
    }
  
    @IsTest
    static void testForGlobalMarkets() {
        User testUser = (User) new BLD_USER().useSysAdmin()
            .division('Global Markets')
            .commitWork()
            .getRecord();
        setupData();
        test.startTest();
        system.runAs(testUser){
            try {
                OMDashboardController controller = new OMDashboardController();
                controller.getomJSON();
                controller.getAllOpportunitySectorlst();
                controller.getAllOpportunityPipelineDivlst();
                controller.gettopOpp();
                controller.getAllOpportunityPipelineSectorDivlst();
                controller.getSectorTopOpp();
                controller.getAllClosedOpportunitylst();
                controller.getAllClosedOpportunitySeclst();
                controller.getAllOpportunityPipelineFrancolst();
                controller.getTopOppPipelineDrillDownFranco();
                controller.getTopOppPipelineDrillDownSector();
                controller.getAllOpportunityClosedFrancolst();
                controller.getTopOppClosedWonDrillDownFranco();
                controller.getTopOppClosedLostDrillDownFranco();
                controller.getTopOppClosedWonPipelineDrillDownSector();
                controller.getTopOppClosedLostPipelineDrillDownSector();
            }
            catch (Exception ex) {
                System.assert(false, ex.getMessage());
            }
        }
        test.stopTest();
    }
  
    @IsTest
    static void testForInvestmentBanking() {
        User testUser = (User) new BLD_USER().useSysAdmin()
            .division('Investment Banking')
            .commitWork()
            .getRecord();
        setupData();
        test.startTest();
        system.runAs(testUser){
            try {
                OMDashboardController controller = new OMDashboardController();
                controller.getomJSON();
                controller.getAllOpportunitySectorlst();
                controller.getAllOpportunityPipelineDivlst();
                controller.gettopOpp();
                controller.getAllOpportunityPipelineSectorDivlst();
                controller.getSectorTopOpp();
                controller.getAllClosedOpportunitylst();
                controller.getAllClosedOpportunitySeclst();
                controller.getAllOpportunityPipelineFrancolst();
                controller.getTopOppPipelineDrillDownFranco();
                controller.getTopOppPipelineDrillDownSector();
                controller.getAllOpportunityClosedFrancolst();
                controller.getTopOppClosedWonDrillDownFranco();
                controller.getTopOppClosedLostDrillDownFranco();
                controller.getTopOppClosedWonPipelineDrillDownSector();
                controller.getTopOppClosedLostPipelineDrillDownSector();
            }
            catch (Exception ex) {
                System.assert(false, ex.getMessage());
            }
        }
        test.stopTest();
    }
  
    @IsTest
    static void testForRealEstate() {
        //User
        User testUser = (User) new BLD_USER().useSysAdmin()
            .division('Real Estate')
            .commitWork()
            .getRecord();
        setupData();
        test.startTest();
        system.runAs(testUser){
            try {
                OMDashboardController controller = new OMDashboardController();
                controller.getomJSON();
                controller.getAllOpportunitySectorlst();
                controller.getAllOpportunityPipelineDivlst();
                controller.gettopOpp();
                controller.getAllOpportunityPipelineSectorDivlst();
                controller.getSectorTopOpp();
                controller.getAllClosedOpportunitylst();
                controller.getAllClosedOpportunitySeclst();
                controller.getAllOpportunityPipelineFrancolst();
                controller.getTopOppPipelineDrillDownFranco();
                controller.getTopOppPipelineDrillDownSector();
                controller.getAllOpportunityClosedFrancolst();
                controller.getTopOppClosedWonDrillDownFranco();
                controller.getTopOppClosedLostDrillDownFranco();
                controller.getTopOppClosedWonPipelineDrillDownSector();
                controller.getTopOppClosedLostPipelineDrillDownSector();
            }
            catch(Exception ex) {
                System.assert(false, ex.getMessage());
            }
        }
        test.stopTest();
    }
  
    @IsTest
    static void testForTransactionalProductsAndServices() {
        User testUser = (User) new BLD_USER().useSysAdmin()
            .division('Transactional Products and Services')
            .commitWork()
            .getRecord();
        setupData();
        Test.startTest();
        System.runAs(testUser){
            try {
                OMDashboardController controller = new OMDashboardController();
                controller.getomJSON();
                controller.getAllOpportunitySectorlst();
                controller.getAllOpportunityPipelineDivlst();
                controller.gettopOpp();
                controller.getAllOpportunityPipelineSectorDivlst();
                controller.getSectorTopOpp();
                controller.getAllClosedOpportunitylst();
                controller.getAllClosedOpportunitySeclst();
                controller.getAllOpportunityPipelineFrancolst();
                controller.getTopOppPipelineDrillDownFranco();
                controller.getTopOppPipelineDrillDownSector();
                controller.getAllOpportunityClosedFrancolst();
                controller.getTopOppClosedWonDrillDownFranco();
                controller.getTopOppClosedLostDrillDownFranco();
                controller.getTopOppClosedWonPipelineDrillDownSector();
                controller.getTopOppClosedLostPipelineDrillDownSector();
            }
            catch (Exception ex) {
                System.assert(false, ex.getMessage());
            }
        }
        Test.stopTest();
    }

}