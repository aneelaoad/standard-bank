/**
 * @description SEL_Products test class
 *
 * @author Kyle Cockcroft (kyle@bsky.co.za)
 * @date 2019-06-06
 * 
 *  @ Last Modified By  :   Nikita Haruk
 *  @ Last Modified On  :   22/09/2023
 *  @ Last Modified Reason  : SFP-30063 - Updated test class for SEL_Products
 * 
 *  @ Last Modified By  :   Augustine Chirombo
 *  @ Last Modified On  :   15/04/2024
 *  @ Last Modified Reason : SFP-36900 - Updated test class for SEL_Products 
 */
@isTest
public class SEL_Products_TEST {
    
    public static List <SB_Product__c> methodOneProducts;
    public static List <SB_Product__c> methodTwoProducts;
    public static Set<Id> allIds = new Set<Id>();
    public static String grandParentProductType = 'GrandParentProductType';
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

    @IsTest
    static void shouldSelectWithoutCondition() {
        List<SB_Product__c> result = SEL_Products.newInstance().selectWithoutCondition();
        Assert.areNotEqual(null, result, 'Checking result');
    }

    @IsTest
    private static void selectByIdTest() {
        
        //Instantiate Selector class
        SEL_Products selector = new SEL_Products();
        //Call Test Method
        methodOneProducts = selector.selectById(allIds);
        
        //Validate Test Results
        Assert.areNotEqual(methodOneProducts,null,'success');
    }

    @IsTest
    private static void selectByOpportunityIdAndGrandParentProductTypeTest() {
        
        //Instantiate Selector class
        SEL_Products selector = new SEL_Products();
        //Call Test Method
        methodTwoProducts = selector.selectByOpportunityIdAndGrandParentProductType(allIds, grandParentProductType);
        
        //Validate Test Results
        Assert.areNotEqual(methodTwoProducts,null,'success');
    }

    @IsTest
    private static void shouldSelectByOpportunityStages() {
        List<SB_Product__c> result = SEL_Products.newInstance().selectByOpportunityStages(new Set<String>());
        Assert.areNotEqual(null, result, 'Checking result');
    }

    @IsTest
    private static void shouldCreateCorrectQueryConditionForSelectByOpportunityId(){
        SEL_Products selector = new SEL_Products();
        Set<Id> oppIds = new Set<Id>{
                fflib_IDGenerator.generate(Opportunity.SObjectType)
        };

        Test.startTest();
        selector.selectByOpportunityId(oppIds);
        Test.stopTest();

        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual('Opportunity__c IN :opportunityIds', result.getCondition(), 'Checking condition');
    }

    @IsTest
    private static void shouldCreateCorrectQueryWithComplexCondition() {
        SEL_Products selector = new SEL_Products();
        Set<Id> oppIds = new Set<Id>{
                fflib_IDGenerator.generate(Opportunity.SObjectType)
        };

        List<Schema.RecordTypeInfo> recordTypeInfos = SB_Product__c.SObjectType.getDescribe().getRecordTypeInfos();
        String recordTypeDevName = recordTypeInfos[0].getDeveloperName();
        String additionalCond = 'AND Parent_Product__c != NULL';
        String orderField = 'CreatedDate';

        Test.startTest();
        selector.selectByOppIdRecordTypeProductLeadSource(
                oppIds,
                recordTypeDevName,
                additionalCond,
                orderField,
                fflib_QueryFactory.SortOrder.ASCENDING,
                true );
        Test.stopTest();

        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.isTrue(result.getCondition().contains(additionalCond), 'Checking result');
        Assert.isTrue(result.getOrderings().toString().contains('field='+orderField), 'Checking result');
    }

    @isTest
    static void selectByOppParentIdsAndStagesTest() {
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

            List<SB_Product__c> ancillaryOpportunities = new SEL_Products().selectByOppParentIdsAndStages(
                new Set<Id> { aOpp.Opportunity__c },
                new Set<String>  {
                    DMN_Opportunity.ST_LEAD,
                    DMN_Opportunity.ST_DEVELOP,
                    DMN_Opportunity.ST_CLOSED_WON
                });

            Assert.isFalse(ancillaryOpportunities.isEmpty(), 'Checking the array size');
            Assert.areEqual(4, ancillaryOpportunities.size(), 'Checking the array size');
        Test.stopTest();
    }
    
    @isTest
    static void selectByOppParentIdsAndStagesWithoutTest() {
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

            List<SB_Product__c> ancillaryOpportunities = new SEL_Products().selectByOppParentIdsAndStagesWithoutSharing(
                new Set<Id> { aOpp.Opportunity__c },
                new Set<String>  {
                    DMN_Opportunity.ST_LEAD,
                    DMN_Opportunity.ST_DEVELOP,
                    DMN_Opportunity.ST_CLOSED_WON
                });

            Assert.isFalse(ancillaryOpportunities.isEmpty(), 'Checking the array size');
            Assert.areEqual(4, ancillaryOpportunities.size(), 'Checking the array size');
        Test.stopTest();
    }

}