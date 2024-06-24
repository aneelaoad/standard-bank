/**
 * @description DMN_OpportunityTest class.
 *              US-4021: Advisory Opportunity Weighted Probability
 *              methods: oppsToBeCalculatedTest ()
 * @author Kyle Cockcroft   <kyle@bsky.co.za>
 * @date Aug 2019
*/
@isTest
public class DMN_OpportunityTest {
    
    public static user testUser1 ;
    public static List < Account > olstTestAccount;
    public static List < Opportunity > olstTestOpps;
    public static List < Opportunity > nlstTestOpps;
    public static List < SB_Product__c > products;
    public static List<Id> allIds = new List<Id>();

    @testSetup static void setupData() {
        testUser1 = (User) new BLD_USER().useSysAdmin().commitWork().getRecord();
        
        System.runAs(testUser1) {
            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            new BLD_Account(uow)
                .addOpportunity(
                    new BLD_Opportunity(uow)
                        .addProduct(
                            new BLD_Product(uow)
                                .grandParentProduct('Advisory Fees')
                                .riskWeightedValue(50)
                                .totalFees(20)
                                .currentYearFees(10)
                        )
                );
            uow.commitWork();
        }
    }

    public static testmethod void oppsToBeCalculatedTest() {
       
        nlstTestOpps = [Select Id from Opportunity where Short_Summary__c = 'test opportunity'];
        //Add oppIds to List
        allIds.add(nlstTestOpps[0].Id);

        Test.startTest();
        DMN_Opportunity.oppsToBeCalculated(allIds);
        
        //Validate Test Results
        Set<ID> oppIdsSet = new Set<ID>(); oppIdsSet.addAll(allIds);
        String grandParentProductType = 'Advisory Fees';
        
        SEL_Opportunities selector = new SEL_Opportunities();
        List<Opportunity> testOppsToBeValidated = selector.selectByOppIdAndGrandParentProductType(oppIdsSet, grandParentProductType);
        
        for(Opportunity oppy : testOppsToBeValidated){
            //system.debug('test Opp Data -->' + oppy.Probability + ' ' + oppy.Short_Summary__c);
            System.Assert(oppy.Probability==50);
            /*Calc breakdown:
            3) probability = (totalWeightedFeeValue/totalFeeValue)*100); = (10/20) * 100 = 50%
            */
            
            for(SB_Product__c product : oppy.Products__r){
                //system.debug('test Product Data -->' + product.Risk_Weighted_Value__c + ' ' + product.Total_Fees__c);
                System.Assert(product.Risk_Weighted_Value__c==50.00);
                System.Assert(product.Total_Fees__c==20);
                /*Calc breakdown:
                Risk_Weighted_Value__c = 50.00
                feeAmount = 20
                1) riskWeightedValue = product.Risk_Weighted_Value__c/100 = 50/100 = 50%
                2) weightedFeeValue = (riskWeightedValue * feeAmount);  (50 % * 20) = 10
                3) probability = (totalWeightedFeeValue/totalFeeValue)*100); = (10/20) * 100 = 50%
                */
            }   
        }

        Test.stopTest();
    }

    @isTest
    public static void shouldUpdateEsrDates(){
        Id capitalMarketsRecId = UTL_RecordType.getRecordTypeId(DMN_SB_Product.OBJ_NAME, DMN_SB_Product.RT_CAPITAL_MARKETS);
        Opportunity opp = [
                SELECT Id
                FROM Opportunity
                LIMIT 1
        ];
        Opportunity oldOpp = opp.clone();

        opp.StageName = DMN_Opportunity.ST_DEVELOP;
        opp.CloseDate = System.today().addDays(5);
        update opp;
        Opportunity newOpp = [
                SELECT
                        Id, CloseDate,
                        Actual_Close_Date__c,
                        StageName
                FROM Opportunity
                WHERE Id = :opp.Id];

        SB_Product__c prod = [
                SELECT Id,Total_Fees__c, Total_Margin__c,
                        Finance_Approved_Fee_Recognition__c,
                        Term_Tenor__c, Opportunity__c,
                        CurrencyIsoCode, SA_Net_P_L_Amount_in_R__c,
                        SA_Gross_P_L_Amount_in_R__c,
                        Current_Year_Fees__c, Current_Year_Margin__c,
                        (SELECT Id
                        FROM Estimated_Revenue_Schedules__r)
                FROM SB_Product__c
                WHERE Opportunity__c = :opp.Id
                LIMIT 1
        ];
        SB_Product__c oldProd = prod.clone();
        Integer numberOfErsBefore = prod.Estimated_Revenue_Schedules__r.size();

        prod.RecordTypeId = capitalMarketsRecId;
        prod.Total_Fees__c = 3400000;
        prod.Total_Margin__c = 230000;
        prod.Term_Tenor__c = 12;
        prod.Finance_Approved_Fee_Recognition__c = 50;
        update prod;
        SB_Product__c newProd = [
                SELECT Id,Total_Fees__c, Total_Margin__c,
                        Finance_Approved_Fee_Recognition__c,
                        Term_Tenor__c, Opportunity__c,
                        CurrencyIsoCode, SA_Net_P_L_Amount_in_R__c,
                        SA_Gross_P_L_Amount_in_R__c,
                        Current_Year_Fees__c, Current_Year_Margin__c
                FROM SB_Product__c
                WHERE Id = :prod.Id
        ];

        Test.startTest();
        DMN_Opportunity.updateErsDates(new List<Opportunity>{newOpp}, new Map<Id, Opportunity>{oldOpp.Id => oldOpp});
        Test.stopTest();

        List<Estimated_Revenue_Schedule__c> resultERS = [
                SELECT Id, Product__c, Estimated_Revenue_Date__c,
                        CurrencyIsoCode, RecordTypeId, Fee_Amount__c,
                        Updated_by_LEX__c
                FROM Estimated_Revenue_Schedule__c
                WHERE Product__c = :prod.Id
        ];
        System.assertNotEquals(numberOfErsBefore, resultERS.size());
        System.assertEquals(prod.Term_Tenor__c, resultERS.size());
        Date oppDate = opp.CloseDate.addDays(1);
        System.assertEquals(oppDate, resultERS[0].Estimated_Revenue_Date__c);
        Id cibErsRecordTypeId = UTL_RecordType.getRecordTypeId(DMN_EstimatedRevenueSchedule.OBJ_NAME,
                DMN_EstimatedRevenueSchedule.RT_ESR_NII_NIR);
        for (Integer i = 1, j = resultERS.size(); i < j; i++) {
            oppDate = oppDate.addMonths(1);
            System.assertEquals(prod.CurrencyIsoCode, resultERS[i].CurrencyIsoCode);
            System.assertEquals(oppDate, resultERS[i].Estimated_Revenue_Date__c);
            System.assertEquals(cibErsRecordTypeId, resultERS[i].RecordTypeId);
            System.assert(!resultERS[i].Updated_by_LEX__c);
            System.assert(resultERS[i].Fee_Amount__c <= prod.Total_Fees__c);
        }
        System.assertNotEquals(oldProd.Current_Year_Fees__c, newProd.Current_Year_Fees__c);
        System.assertNotEquals(oldProd.Current_Year_Margin__c, newProd.Current_Year_Margin__c);
    }

    @IsTest
    private static void shouldCompareBusinessAssessmentApprovalDatesCorrectly(){
        Assessment_Opportunity__c record1 = new Assessment_Opportunity__c();
        Business_Assessment__c ba1 = new Business_Assessment__c(Approval_Milestone_Date__c=Datetime.now().addDays(-1));
        record1.Business_Assessment__r=ba1;
        Assessment_Opportunity__c record2 = new Assessment_Opportunity__c();
        Business_Assessment__c ba2 = new Business_Assessment__c();
        record2.Business_Assessment__r=ba2;
        Assessment_Opportunity__c record3 = new Assessment_Opportunity__c();
        Business_Assessment__c ba3 = new Business_Assessment__c(Approval_Milestone_Date__c=Datetime.now().addDays(-2));
        record3.Business_Assessment__r=ba3;
        Test.startTest();
        Assessment_Opportunity__c result1 = DMN_Opportunity.compareBusinessAssessmentApprovalDate(record1, record2);
        Assessment_Opportunity__c result2 = DMN_Opportunity.compareBusinessAssessmentApprovalDate(record2, record1);
        Assessment_Opportunity__c result3 = DMN_Opportunity.compareBusinessAssessmentApprovalDate(record1, record3);
        Assessment_Opportunity__c result4 = DMN_Opportunity.compareBusinessAssessmentApprovalDate(record3, record1);
        Assessment_Opportunity__c result5 = DMN_Opportunity.compareBusinessAssessmentApprovalDate(record1, record1);
        Test.stopTest();
        System.assert(result1 == record1);
        System.assert(result2 == record1);
        System.assert(result3 == record1);
        System.assert(result4 == record1);
        System.assert(result5 == null);
    }

    @IsTest
    private static void shouldCompareCreditPaperDatesCorrectly(){
        Assessment_Opportunity__c record1 = new Assessment_Opportunity__c();
        Business_Assessment__c ba1 = new Business_Assessment__c(
                Credit_Paper_Application_Created__c = Datetime.now(),
                Credit_Paper_Approval__c = Datetime.now(),
                Credit_Paper_Decline_Date__c = Datetime.now(),
                Credit_Paper_Sent_for_Approval__c = Datetime.now()
        );
        record1.Business_Assessment__r=ba1;
        Assessment_Opportunity__c record2 = new Assessment_Opportunity__c();
        Business_Assessment__c ba2 = new Business_Assessment__c(
                Credit_Paper_Application_Created__c = ba1.Credit_Paper_Application_Created__c,
                Credit_Paper_Approval__c = ba1.Credit_Paper_Approval__c,
                Credit_Paper_Decline_Date__c = ba1.Credit_Paper_Decline_Date__c,
                Credit_Paper_Sent_for_Approval__c = ba1.Credit_Paper_Sent_for_Approval__c
        );
        record2.Business_Assessment__r=ba2;
        Assessment_Opportunity__c record3 = new Assessment_Opportunity__c();
        Business_Assessment__c ba3 = new Business_Assessment__c(
                Credit_Paper_Application_Created__c = ba1.Credit_Paper_Application_Created__c,
                Credit_Paper_Approval__c = ba1.Credit_Paper_Approval__c,
                Credit_Paper_Decline_Date__c = ba1.Credit_Paper_Decline_Date__c
        );
        record3.Business_Assessment__r=ba3;
        Assessment_Opportunity__c record4 = new Assessment_Opportunity__c();
        Business_Assessment__c ba4 = new Business_Assessment__c(
                Credit_Paper_Application_Created__c = Datetime.now().addDays(-3),
                Credit_Paper_Approval__c = ba1.Credit_Paper_Approval__c
        );
        record4.Business_Assessment__r=ba4;
        Test.startTest();
        Assessment_Opportunity__c result1 = DMN_Opportunity.compareCreditPaperDates(record1, record2);
        Assessment_Opportunity__c result2 = DMN_Opportunity.compareCreditPaperDates(record1, record3);
        Assessment_Opportunity__c result3 = DMN_Opportunity.compareCreditPaperDates(record3, record1);
        Assessment_Opportunity__c result4 = DMN_Opportunity.compareCreditPaperDates(record1, record4);
        Assessment_Opportunity__c result5 = DMN_Opportunity.compareCreditPaperDates(record4, record1);
        Test.stopTest();
        System.assert(result1 == null);
        System.assert(result2 == record1);
        System.assert(result3 == record1);
        System.assert(result4 == record1);
        System.assert(result5 == record1);
    }

    @IsTest
    private static void shouldGetAssessmentOpportunityWithMostRecentBusinessAssessment(){
        Assessment_Opportunity__c record1 = (Assessment_Opportunity__c)JSON.deserialize('{"attributes":{"type":"Assessment_Opportunity__c"},"Business_Assessment__r":{"attributes":{"type":"Business_Assessment__c"},"Credit_Paper_Application_Created__c":"2021-10-06T20:24:11.332+0000","Credit_Paper_Approval__c":"2021-10-06T20:24:11.333+0000","Credit_Paper_Decline_Date__c":"2021-10-06T20:24:11.333+0000","Credit_Paper_Sent_for_Approval__c":"2021-10-06T20:24:11.333+0000","LastModifiedDate":"2021-10-06T20:24:11.333+0000"}}', Assessment_Opportunity__c.class);
        Assessment_Opportunity__c record2 = (Assessment_Opportunity__c)JSON.deserialize('{"attributes":{"type":"Assessment_Opportunity__c"},"Business_Assessment__r":{"attributes":{"type":"Business_Assessment__c"},"Credit_Paper_Application_Created__c":"2021-10-06T20:24:11.332+0000","Credit_Paper_Approval__c":"2021-10-06T20:24:11.333+0000","Credit_Paper_Decline_Date__c":"2021-10-06T20:24:11.333+0000","Credit_Paper_Sent_for_Approval__c":"2021-10-06T20:24:11.333+0000","LastModifiedDate":"2021-10-06T21:24:11.333+0000"}}', Assessment_Opportunity__c.class);

        Test.startTest();
        Assessment_Opportunity__c result1 = DMN_Opportunity.getMoreRecentBusinessAssessment(record1, record2);
        Assessment_Opportunity__c result2 = DMN_Opportunity.getMoreRecentBusinessAssessment(record2, record1);
        Assessment_Opportunity__c result3 = DMN_Opportunity.getMoreRecentBusinessAssessment(record1, null);
        Assessment_Opportunity__c result4 = DMN_Opportunity.getMoreRecentBusinessAssessment(null, record1);
        Test.stopTest();
        System.assert(result1 == record2);
        System.assert(result2 == record2);
        System.assert(result3 == record1);
        System.assert(result4 == record1);
    }
   
    @IsTest
    public static void shouldShareOpportunitiesAndpopulateValuesOnOppAssessment(){
        	
            nlstTestOpps = [Select Id from Opportunity where Short_Summary__c = 'test opportunity'];
            //Add oppIds to Set<ID>
            Set<Id> oppIds = new Set<Id>();
        	oppIds.add(nlstTestOpps[0].Id);
        
        	//Add userIds to Set<ID>
        	testUser1 = [Select Id from USER where Alias='1TestNa'];
        	Set<Id> userIds = new Set<Id>();
        	userIds.add(testUser1.Id);    
        	
        	Map<Id, Opportunity> opps = new Map<Id, Opportunity>();
        	opps.put(nlstTestOpps[0].Id, nlstTestOpps[0]);
        
        	Test.startTest();
        	OpportunityShare[] oppShare = DMN_Opportunity.shareOpportunities(oppIds, userIds, 'Read');
        	DMN_Opportunity.populateValuesOnOppAssessment(opps);
        	Test.stopTest();
        	
        System.assert(oppShare != null,'Opportunity Sharing Successfull');
    }
    
    @IsTest
    public static void shouldrecalculateDcpFields(){
        
         nlstTestOpps = [Select Id from Opportunity where Short_Summary__c = 'test opportunity'];
         fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        
        Assessment_Opportunity__c record1 = new Assessment_Opportunity__c();
        Business_Assessment__c ba1 = new Business_Assessment__c(
                Credit_Paper_Application_Created__c = Datetime.now(),
                Credit_Paper_Approval__c = Datetime.now(),
                Credit_Paper_Decline_Date__c = Datetime.now(),
                Credit_Paper_Sent_for_Approval__c = Datetime.now()
        );
        Insert ba1;
        record1.Business_Assessment__c = ba1.Id;
        record1.Opportunity__c = nlstTestOpps[0].Id;
        Insert record1;
         Test.startTest();
         DMN_Opportunity.recalculateDcpFields(nlstTestOpps, uow);
         Test.stopTest();
        
        System.Assert(nlstTestOpps != null,'Opportunity record exists');
    }
}