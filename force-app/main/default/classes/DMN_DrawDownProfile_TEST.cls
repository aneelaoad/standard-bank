/**
* @description Test class for DMN_DrawDownProfile class.
*
* @author Wayne Solomon
* @date Feb 2021
*/
@IsTest
private class DMN_DrawDownProfile_TEST {

    @TestSetup
    static void testSetup() {
        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Account ugpClientBld = new BLD_Account(uow).name('Acc').useCib().useGroupParent().CIF('505968788');
        BLD_DrawDownProfile drawDownProfileBld = new BLD_DrawDownProfile(uow).drawDate(System.today().addDays(-1)).funding(10500);
        BLD_Product productBld = new BLD_Product(uow).addDrawDownProfile(drawDownProfileBld);
        BLD_Opportunity opportunityBld = new BLD_Opportunity(uow).develop().client(ugpClientBld).closeDate(System.today().addDays(-5)).addProduct(productBld);
        BLD_BusinessAssessment baBld = new BLD_BusinessAssessment(uow).client(ugpClientBld).guarantorName(ugpClientBld).approvalMilestoneDate(System.today());
        uow.commitWork();
        Test.startTest();
        BLD_Assessment_Opportunity aoBld = new BLD_Assessment_Opportunity(uow).businessAssessment(baBld).opportunity(opportunityBld);
        uow.commitWork();
        Test.stopTest();
    }

    @IsTest
    static void runSyncDrawdownDatesToOppEstClosedDateTest() {
        Map<Id, Opportunity> id2OldRecords = new Map<Id, Opportunity>([select Id, CloseDate from Opportunity LIMIT 1]);
        Map<Id, Opportunity> id2NewRecords = new Map<Id, Opportunity>();
        Opportunity opp = id2OldRecords.values().get(0).clone(true, true, true, true);
        opp.CloseDate = System.today().addDays(2);
        id2NewRecords.put(opp.Id, opp);

        Test.startTest();
        DMN_DrawDownProfile.syncDrawdownDatesToOppEstClosedDate(id2NewRecords, id2OldRecords);
        Test.stopTest();

        System.assertEquals(System.today().addDays(2), [select Draw_Date__c from Draw_Down_Profile__c limit 1].Draw_Date__c);
    }
}