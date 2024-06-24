/**
 * @description NBAC_AncillaryOpportunities_CTRL test class
 *
 * @author Nikita Haruk
 * @date 22/09/2023
 * 
 */
@isTest
private class NBAC_AncillaryOpportunities_TEST {
    private static final String	 TEST_USER_NAME       = 'triggerstdBank@nbacPDF.com';
	private static final Integer NBAC_METRIC_COUNT    = 10;
	private static final Integer NBAC_INDICATOR_COUNT = 20;
    private static final Decimal CURRENCY_VALUE1      = 100000000.00;
    private static final List<String> TEST_PRODUCT_NAMES = new List<String> {
        'Test Product1',
        'Test Product2',
        'Test Product3',
        'Test Product4',
        'Test Product5'
    };

	private static User standardUser {
		get {
			if (standardUser == null) {
				standardUser = [SELECT id FROM User WHERE UserName = :TEST_USER_NAME];
			}
			return standardUser;
		}
		set;
	}

    @TestSetup
    private static void createCommitData() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getProductFeeRecClientSectorMap()
        });

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

		User owner;
		System.runAs(new User(Id = UserInfo.getUserId())) {
			owner = (USER) new BLD_USER().userName(TEST_USER_NAME).useCib().syncContact().getRecord();
			uow.commitWork();
		}
        
        Test.startTest();
        Test.stopTest();

        System.runAs(owner) {
			BLD_Account bldAccount1	= new BLD_Account(uow).name('acc1').useCib().useGroupParent();
			BLD_Account bldAccount2	= new BLD_Account(uow).name('acc2').useCib().useGroupParent();
			BLD_Account bldAccount3	= new BLD_Account(uow).name('acc3').useCib().useGroupParent();

            uow.commitwork();

            BLD_Opportunity opportunityBld1 = new BLD_Opportunity(uow).develop().client(bldAccount1).currency(UTL_Currency.corporateIsoCode);
			BLD_Opportunity opportunityBld2 = new BLD_Opportunity(uow).develop().client(bldAccount2).currency(UTL_Currency.corporateIsoCode);
			BLD_Opportunity opportunityBld3 = new BLD_Opportunity(uow).develop().client(bldAccount2).currency(UTL_Currency.corporateIsoCode);
			BLD_Opportunity opportunityBld4 = new BLD_Opportunity(uow).develop().client(bldAccount3).currency(UTL_Currency.corporateIsoCode);
            
			new BLD_Product(uow).linkToOpp(opportunityBld1).notionalValueCurrency(CURRENCY_VALUE1).currency(UTL_Currency.corporateIsoCode);
			new BLD_Product(uow).linkToOpp(opportunityBld2).notionalValueCurrency(CURRENCY_VALUE1).currency(UTL_Currency.corporateIsoCode);
			new BLD_Product(uow).linkToOpp(opportunityBld2).notionalValueCurrency(CURRENCY_VALUE1).currency(UTL_Currency.corporateIsoCode);
			new BLD_Product(uow).linkToOpp(opportunityBld3).notionalValueCurrency(CURRENCY_VALUE1).currency(UTL_Currency.corporateIsoCode);
			new BLD_Product(uow).linkToOpp(opportunityBld4).notionalValueCurrency(CURRENCY_VALUE1).currency(UTL_Currency.corporateIsoCode);

            BLD_BusinessAssessment bAssessment = new BLD_BusinessAssessment(uow);
            bAssessment.client(bldAccount1);

            BLD_Assessment_Opportunity aOpportunity = new BLD_Assessment_Opportunity(uow);
            aOpportunity.opportunity(opportunityBld1);
            aOpportunity.businessAssessment(bAssessment);
    
            for (Integer i = 0; i < NBAC_INDICATOR_COUNT; i++) {
                new BLD_NBACFinancialAnalysis(uow).indicatior().businessAssessment(bAssessment);
            }
    
            for (Integer i = 0; i < NBAC_METRIC_COUNT; i++) {
                new BLD_NBACFinancialAnalysis(uow).metric().businessAssessment(bAssessment).metricYear1('1').metricYear2('2').metricYear3('3').metricYear4('4');
            }

            uow.commitwork();
        }
    }

    @isTest
    static void getAncillaryOpportunitiesTest() {
        Assessment_Opportunity__c aOpp = [SELECT Id, Business_Assessment__c, Opportunity__c FROM Assessment_Opportunity__c LIMIT 1];
        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        for (Opportunity opp : [SELECT Id FROM Opportunity WHERE Id != :aOpp.Opportunity__c]) {
            oppsToUpdate.add(new Opportunity(
                Id = opp.Id,
                Parent_Opportunity__c = aOpp.Opportunity__c
            ));
        }

        Test.startTest();
            update oppsToUpdate;

            List<SB_Product__c> ancillaryOpportunities = NBAC_AncillaryOpportunities_CTRL.getAncillaryOpportunities(aOpp.Business_Assessment__c);

            Assert.isFalse(ancillaryOpportunities.isEmpty(), 'Checking the list size');
            Assert.areEqual(4, ancillaryOpportunities.size(), 'Checking the list size');
        Test.stopTest();
    }
}