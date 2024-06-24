/**
 * SEL_Opportunities test class.
 * @description Test Class for SEL_Opportunities
 * @author Kyle Cockcroft (kyle@bsky.co.za)
 * @date 07-08-2019
 *
 *****************************************************************************************
 *   @ Last Modified By  :   Maham Hassan
 *   @ Last Modified On  :   08/04/2022
 *   @ Last Modified Reason  : Updated this class to update the coverage required for 
 *                              deployment
 * 
 *   @Last Modified By  : Augustine Chirombo
 *   @Last Modified On  : Sep 13, 2023
 *   @Modification Description : Change the static reference of Record types to new labels 
 * 
 *   @Last Modified By  : Augustine Chirombo
 *   @Last Modified On  : Nov 23, 2023
 *   @Modification Description : Updating test coverage
 *****************************************************************************************
 */
@isTest
public class SEL_Opportunities_TEST {
    
    public static List < Opportunity > methodOneOpps;
    public static List < Opportunity > methodTwoOpps;
    public static Set<Id> allIds = new Set<Id>();
    public static String grandParentProductType = 'GrandParentProductType';

    @isTest
    private static void selectByOppIdAndGrandParentProductTypeTest() {
        
        SEL_Opportunities selector = new SEL_Opportunities();
        methodOneOpps = selector.selectByOppIdAndGrandParentProductType(allIds, grandParentProductType);
        Assert.areNotEqual(methodOneOpps,null,'success');
          for(Opportunity oppy : methodOneOpps){
            Assert.areEqual('test opportunity', oppy.Short_Summary__c, 'Opportunity short summary should be test opportunity');            
            for(SB_Product__c product : oppy.Products__r){
                Assert.areEqual(50.00, product.Risk_Weighted_Value__c, 'Product risk weighted value should be 50');
                Assert.areEqual(20, product.Total_Fees__c, 'Product total fees should be 20');
            }   
        }
    }

    @isTest
    private static void selectByIdTest() {
        
        SEL_Opportunities selector = new SEL_Opportunities();
        methodTwoOpps = selector.selectById(allIds);
        Assert.areNotEqual(methodTwoOpps,null,'success');
        
        for(Opportunity oppy : methodTwoOpps){
            Assert.areEqual('test opportunity', oppy.Short_Summary__c, 'Opportunity short summary should be test opportunity'); 
        }
    }
    
    @isTest
    private static void selectByCIFNumberWithStartDateTest() {
        
        SEL_Opportunities selector = new SEL_Opportunities();
        List<Opportunity> methodOneOpps = selector.selectByCIFNumberWithStartDate(
                new Set<String>{''},UserInfo.getUserId(),Date.valueOf('2019-01-01')
        );
        Assert.areEqual(0, methodOneOpps.size(), 'Opportunity with CIF Number should be 0');
    }

    @IsTest
    public static void testSelectByIdWithActiveTeamMembers() {
        SEL_Opportunities selector = new SEL_Opportunities();
        Set<Id> oppIds = new Set<Id>{fflib_IDGenerator.generate(Opportunity.SObjectType)};

        Test.startTest();
        selector.selectByIdWithActiveTeamMembers(oppIds);
        Test.stopTest();

        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(1, result.getSubselectQueries().size(), 'Opportunity List size should be 1');
    }
    
    @IsTest
    public static void testSelectByNbacIds() {
        SEL_Opportunities selector = new SEL_Opportunities();
        Set<Id> nbacIds = new Set<Id>{fflib_IDGenerator.generate(Business_Assessment__c.SObjectType)};

        Test.startTest();
        selector.selectByNBACIds(nbacIds);
        Test.stopTest();

        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(2, result.getSubselectQueries().size(), 'Opportunity List size should not be null');
    }

    @isTest
    public static void testEnableExtraAttributes() {
        SEL_Opportunities opp = SEL_Opportunities.newInstance().
                                withCrudAssert(false).
                                withFlsEnforced(true).
                                includeSelectorFields(true);
        opp.selectByIdsWithoutCrudAndFlsEnforcement(allIds);
        opp.selectByIdsWithoutSharing(allIds);
        opp.selectByIds(allIds);
        Assert.areEqual(0, opp.selectByIds(allIds).size(), 'Opportunity record should be 0');
    }
    
     @isTest
    private static void selectByIdAndStageTest() {
        
        SEL_Opportunities selector = new SEL_Opportunities();
        methodTwoOpps = selector.selectById(allIds);
        Assert.areNotEqual(methodTwoOpps,null,'success');
        
        for(Opportunity oppy : methodTwoOpps){
            oppy.StageName = '2 - Develop'; 
        }
        update methodTwoOpps; 
        methodTwoOpps = selector.selectByIdAndStage(new List<Id>(allIds), new Set<String>{'2 - Develop'});
        Assert.areNotEqual(methodTwoOpps,null,'success');
        
    }
    
}