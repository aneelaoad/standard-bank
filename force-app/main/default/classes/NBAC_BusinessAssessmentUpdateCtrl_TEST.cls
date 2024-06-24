@isTest
private class NBAC_BusinessAssessmentUpdateCtrl_TEST {

    private static final String
            DEF_ACC_NAME            = 'Def Name for Acc',
            CIF_NUMBER              = '654321';

    @TestSetup
    private static void prepareData() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Account ugpClientBld	= (BLD_Account) new BLD_Account(uow).name(DEF_ACC_NAME).CIF(CIF_NUMBER).useCib().riskRating(DMN_Account.RISK_RATING_D1).useGroupParent()
                .setField(Account.Country_Risk__c, DMN_Account.CTRY_OF_RISK)
                .setField(Account.Client_Franco__c, DMN_Account.FRANCO_ANGOLA)
                .setField(Account.Internal_Credit_Rating__c, DMN_Account.RISK_RATING_D2);
        uow.commitWork();

        BLD_BusinessAssessment assessment = new BLD_BusinessAssessment(uow).client(ugpClientBld);

        uow.commitwork();


    }

    @isTest
    static void shouldReturnTrue() {
        List<Business_Assessment__c> businessAssessments = [SELECT Id FROM Business_Assessment__c LIMIT 1];

        Test.startTest();
        Boolean isUpdated = NBAC_BusinessAssessmentUpdateController.updateBusinessAssessment(businessAssessments[0].Id);
        Test.stopTest();

        System.assert(isUpdated);

    }
}