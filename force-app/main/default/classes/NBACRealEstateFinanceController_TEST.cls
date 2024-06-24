/**
 * @description Test class for NBACRealEstateFinanceController
 *
 * @author      Stane Murhula (stane.murhula@standardbank.co.za)
 * @date        March 2024
 * 
 */

@IsTest(IsParallel=true)
private class NBACRealEstateFinanceController_TEST {
    
    @isTest
    static void getRefDataTest() {
        HandledException exceptionMock = new HandledException();
        fflib_ApexMocks mocks = new fflib_ApexMocks();

        NBAC_Real_Estate_Finance__c refMock = (NBAC_Real_Estate_Finance__c) new BLD_NbacRealEstateFinance()
        .mock();

        SEL_NbacRealEstateFinance refSelectorMock = (SEL_NbacRealEstateFinance) mocks.mock(
          SEL_NbacRealEstateFinance.class
        );

        List<NBAC_Real_Estate_Finance__c> refData = new List<NBAC_Real_Estate_Finance__c>();
        
        mocks.startStubbing();
        
        mocks.when(refSelectorMock.SObjectType())
        .thenReturn(NBAC_Real_Estate_Finance__c.SObjectType);

        mocks.when(
            refSelectorMock.selectRefByBaId(
              (Set<String>) fflib_Match.anyObject()
            )
          )
          .thenThrow(exceptionMock)
          .thenReturn(new  List<NBAC_Real_Estate_Finance__c>{ refMock });

        mocks.stopStubbing();

        ORG_Application.selector.setMock(refSelectorMock);

        Test.startTest();
        try {

        refData = NBACRealEstateFinanceController.getRefData((String) fflib_Match.anyString());
        Assert.isTrue(false, 'Should have thrown an exception');

        } catch (AuraHandledException e) {
        Assert.areEqual('Script-thrown exception', e.getMessage(),'should throw an expection');
        }
        refData = NBACRealEstateFinanceController.getRefData((String) fflib_Match.anyString());
        Test.stopTest();

        Assert.areEqual(refMock.Metric__c, refData[0].Metric__c, 'Should be equal');
    }

    @IsTest
   static void saveRefDataTestPositive() {
       
       Business_Assessment__c baRec = (Business_Assessment__c)new BLD_BusinessAssessment()
           .commitWork()
           .getRecord();

       List<NBAC_Real_Estate_Finance__c> refData = new List<NBAC_Real_Estate_Finance__c>();
           refData.add(new NBAC_Real_Estate_Finance__c(Metric__c = 'Test Metric 1'));
           refData.add(new NBAC_Real_Estate_Finance__c(Metric__c = 'Test Metric 2'));
       
        Test.startTest();
        	List<NBAC_Real_Estate_Finance__c> savedRefData = NBACRealEstateFinanceController.saveRefData(refData, baRec, baRec.Id);
        Test.stopTest();
        
        Assert.areEqual(2, savedRefData.size(), 'Number of saved records should match input data');

        for (Integer i = 0; i < refData.size(); i++) {
             Assert.areEqual(refData[i].Metric__c, savedRefData[i].Metric__c, 'Metric__c should match');
        }
    }

    @IsTest
    static void saveRefDataTestNegative() {

	    fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        SEL_NbacRealEstateFinance refSelectorMock = (SEL_NbacRealEstateFinance)mocks.mock(SEL_NbacRealEstateFinance.class);
        HandledException exceptionMock = new HandledException();
        
        Business_Assessment__c baRec = (Business_Assessment__c)new BLD_BusinessAssessment()
         .commitWork()
         .getRecord();

  
		List<NBAC_Real_Estate_Finance__c> refData = new List<NBAC_Real_Estate_Finance__c>();
    		refData.add(new NBAC_Real_Estate_Finance__c(Metric__c = 'Test Metric 1'));
   			refData.add(new NBAC_Real_Estate_Finance__c(Metric__c = 'Test Metric 2'));

         mocks.startStubbing();
            mocks.when(refSelectorMock.SObjectType())
            .thenReturn(NBAC_Real_Estate_Finance__c.SObjectType);
            mocks.when(refSelectorMock.selectRefByBaId(
                (Set<String>)fflib_Match.anyObject())
                )
            .thenThrow(exceptionMock);
        mocks.stopStubbing();

        ORG_Application.selector.setMock(refSelectorMock);


        Test.startTest();
        try {
            NBACRealEstateFinanceController.saveRefData(refData,baRec,baRec.Id);
            Assert.isTrue(false, 'Should have thrown an exception');
        } catch (Exception e) {
            Assert.areEqual('Script-thrown exception', e.getMessage(), 'Should throw an exception');
        }       
        Test.stopTest();
    }
    
    
    
    
    @IsTest
    static void deleteRefMetricPositiveTest(){

        NBAC_Real_Estate_Finance__c refMock = (NBAC_Real_Estate_Finance__c) new BLD_NbacRealEstateFinance().mock();
        NBAC_Real_Estate_Finance__c refMetric = new NBAC_Real_Estate_Finance__c(
             Business_Assessment__c = refMock.Business_Assessment__c,
             Metric__c = 'TEST3'
        );
        
        insert refMetric;
        
		String refId = (refMetric.Id).toString();

        Test.startTest();
		NBACRealEstateFinanceController.deleteRefMetric(new List<String> {refId});
        Test.stopTest();

        List<NBAC_Real_Estate_Finance__c> ref = [SELECT Id FROM NBAC_Real_Estate_Finance__c WHERE Id = :refId];
        Assert.areEqual(0, ref.size(), 'Should be empty');
    }

    @IsTest
    static void deleteRefMetricNegativeTest(){
        
        HandledException exceptionMock = new HandledException();
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        NBAC_Real_Estate_Finance__c refMock = (NBAC_Real_Estate_Finance__c) new BLD_NbacRealEstateFinance().mock();
     
        NBAC_Real_Estate_Finance__c refMetric = new NBAC_Real_Estate_Finance__c(
             Business_Assessment__c = refMock.Business_Assessment__c, 
             Metric__c = 'TEST3'
        );
        insert refMetric;
        
       String refId = (refMetric.Id).toString();
        
       SEL_NbacRealEstateFinance refSelectorMock = (SEL_NbacRealEstateFinance)mocks.mock(SEL_NbacRealEstateFinance.class);
       
        mocks.startStubbing();
        mocks.when(refSelectorMock.SObjectType()).thenReturn(NBAC_Real_Estate_Finance__c.SObjectType);
        mocks.when(refSelectorMock.selectRefByRefId((List<String>)fflib_Match.anyObject()))
            .thenThrow(exceptionMock);
        mocks.stopStubbing();
        
        ORG_Application.selector.setMock(refSelectorMock);

        Test.startTest();
       	try {
       	 NBACRealEstateFinanceController.deleteRefMetric(new List<String> {refId});
       	 Assert.isTrue(false, 'Should have thrown an exception');
        } catch (Exception e) {
       	 Assert.areEqual('Script-thrown exception', e.getMessage(), 'Should be an exception');
		}
        Test.stopTest();

        List<NBAC_Real_Estate_Finance__c> ref = [SELECT Id FROM NBAC_Real_Estate_Finance__c WHERE Id = :refId];
        Assert.areEqual(1, ref.size(), 'Should not be empty');
    }
    

    @isTest
    static void testGetFieldSetValues() {
        List<String> fieldSetNames = new List<String>{'RefLabelSectionOne', 'RefLabelSectionTwo'};

        Test.startTest();
        List<List<Map<String, String>>> result = NBACRealEstateFinanceController.getFieldSetValues('NBAC_Real_Estate_Finance__c',fieldSetNames);
        Test.stopTest();

       	Assert.areNotEqual(null, result, 'Should be null');
        Assert.areEqual(2, result.size(), 'Should be the same');
    }
}