/**
 * @description Test class for SRV_NBACRealEstateFinance
 *
 * @author      Stane Murhula (stane.murhula@standardbank.co.za)
 * @date        March 2024
 * 
 * @LastModifiedDate 
 * @author 
 * @UserStory 
 * @LastModifiedReason 
 */

@IsTest(IsParallel=true)
private class SRV_NBACRealEstateFinance_TEST {
    @isTest
    public static void saveRefDataTest() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);

        List<NBAC_Real_Estate_Finance__c> refData = new List<NBAC_Real_Estate_Finance__c>();
        refData.add(new NBAC_Real_Estate_Finance__c(Metric__c = 'Test Metric 1'));
        refData.add(new NBAC_Real_Estate_Finance__c(Metric__c = 'Test Metric 2'));


        Business_Assessment__c baRec = (Business_Assessment__c)new BLD_BusinessAssessment()
        .commitWork()
        .getRecord();

        ORG_Application.unitOfWork.setMock(uowMock);

        Test.startTest();
        SRV_NBACRealEstateFinance.newInstance().saveRefData(refData, baRec, baRec.Id, uowMock);
        Test.stopTest();

        Assert.areEqual(baRec, baRec, 'should be equal');

        ((fflib_ISObjectUnitOfWork)mocks.verify(uowMock)).registerDirty(baRec);
        ((fflib_ISObjectUnitOfWork)mocks.verify(uowMock)).registerNew(refData);
        
    }   
}