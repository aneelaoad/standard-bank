/***************************************************************************************
* @Name of the Class     :SEL_ZafinNegotiatedPricingFeeItem_TEST
* @description           :SFP-36983 Test Selector class for SEL_ZafinNegotiatedPricingFeeItem SObject
* @Author                :Likhitha Karusala
* @Created Date          :Sep 27th 2023
/***************************************************************************************
*@Last Modified By         : Likhitha Karusala 
*@Last Modified On         : 11 Mar 2024
*@Modification Description : SFP-36983
***************************************************************************************/
@IsTest
public class SEL_ZafinNegotiatedPricingFeeItem_TEST {
    @IsTest
    static void selectZafinNegotiationPricingFeeItemByIdAndLimit() {
        Id pricingId;
        Integer limitValue;
        Test.startTest();
        SEL_ZafinNegotiatedPricingFeeItem negotiated = new SEL_ZafinNegotiatedPricingFeeItem();
        negotiated.selectZafinNegotiationPricingFeeItemByIdAndLimit(pricingId,limitValue);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(result.getCondition().containsIgnoreCase('zafin_rrp__Negotiated_Pricing__r.Id = :parentId'), true,'success');
    }
    @IsTest
    static void selectZafinNegotiationPricingFeeItemByIdAndOrderBy() {
        Id parentId;
        string orderingField;
        Test.startTest();
        SEL_ZafinNegotiatedPricingFeeItem negotiatedRec = new SEL_ZafinNegotiatedPricingFeeItem();
        negotiatedRec.selectZafinNegotiationPricingFeeItemByIdAndOrderBy(parentId,new List<string>(),orderingField);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areEqual(result.getCondition().containsIgnoreCase('zafin_rrp__Negotiated_Pricing__r.Id = :parentId AND zafin_rrp__Fee_Item_Code__c in :categoryValue'), true,'success');
    }
    @IsTest
    static void selectZafinNegotiationPricingFeeItemById(){
        Id pricingId ;
        Test.startTest();
        SEL_ZafinNegotiatedPricingFeeItem ss = new SEL_ZafinNegotiatedPricingFeeItem();
        ss.selectZafinNegotiationPricingFeeItemById(pricingId);
        Test.stopTest();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        Assert.areNotEqual(result.getCondition().containsIgnoreCase('zafin_rrp__Negotiated_Pricing__r.Id = :parentId'), true, 'result should not match');
    }
}