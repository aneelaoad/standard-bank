/***************************************************************************************
* @Name of the Class     :SEL_ZafinNegotiatedPricingFeeItem
* @description           :SFP-36983 Selector class for zafin_rrp__NegotiatedPricing_FeeItem__c SObject
* @Author                :Pradeep Kota 
* @Created Date          :Sep 27th 2023
/***************************************************************************************
*@Last Modified By         : Pradeep Kota  
*@Last Modified On         : 11 Mar 2024
*@Modification Description : SFP-36983
***************************************************************************************/
public inherited sharing class SEL_ZafinNegotiatedPricingFeeItem extends fflib_SObjectSelector {
    private static Set<String> fields=new Set<String>{'Id', 'Name','zafin_rrp__Negotiated_Pricing__c', 'zafin_rrp__AFP_Code__c', 'zafin_rrp__AFP_Name__c', 'zafin_rrp__Actual_Volume__c', 'zafin_rrp__Aggregate_Amount__c', 'zafin_rrp__Aggregation_Cycle__c', 'zafin_rrp__Aggregation_Period__c', 'zafin_rrp__AmountOrPercentage__c', 'zafin_rrp__Amount__c', 'zafin_rrp__Charging_Frequency__c', 'zafin_rrp__Charging_Model__c', 'zafin_rrp__Charging_Type__c', 'zafin_rrp__Current_Price_Text__c', 'zafin_rrp__Current_Price__c', 'zafin_rrp__Discount__c', 'zafin_rrp__DoNot_Charge_Prepaid_Fee__c', 'zafin_rrp__EachOrAggregate__c', 'zafin_rrp__FeePlan_Code__c', 'zafin_rrp__Fee_Code__c', 'zafin_rrp__Fee_Item_Code__c', 'zafin_rrp__Fee_Item_Description__c', 'zafin_rrp__Fee_Item_Name__c', 'zafin_rrp__GraceOrPartialPeriod__c', 'zafin_rrp__Grace_Period__c', 'zafin_rrp__Is_Discount__c', 'zafin_rrp__MaxValue__c', 'zafin_rrp__MinValue__c', 'zafin_rrp__Model__c', 'zafin_rrp__Negotiated_Amount__c', 'zafin_rrp__Negotiated_Percentage__c', 'zafin_rrp__Number_Of_Cycles__c', 'zafin_rrp__PartialPeriod_Minimum_Days__c', 'zafin_rrp__Partial_Period__c', 'zafin_rrp__Percentage__c', 'zafin_rrp__ProcessAheadCheck__c', 'zafin_rrp__Profitability_Fee_Item__c', 'zafin_rrp__Proposed_ChargingModel__c', 'zafin_rrp__Proposed_MaxValue__c', 'zafin_rrp__Proposed_MinValue__c', 'zafin_rrp__Proposed_Price_Text__c', 'zafin_rrp__Proposed_Volume__c', 'zafin_rrp__SimpleOrTier__c', 'zafin_rrp__Type__c', 'zafin_rrp__Unit_Cost__c', 'zafin_rrp__VolumeOrValue__c', 'zafin_rrp__Zafin_External_Id__c', 'zafin_rrp__Zafin_Product__c', 'zafin_rrp__Currency_Code__c', 'zafin_rrp__Current_Standard_Revenue__c', 'zafin_rrp__Current_Standard_Total_Cost__c', 'zafin_rrp__Current_Volume_Value__c', 'zafin_rrp__Discounted_Fee__c', 'zafin_rrp__Proposed_Price__c', 'zafin_rrp__Proposed_Profit_Margin__c', 'zafin_rrp__Proposed_Recovery__c', 'zafin_rrp__Proposed_Revenue__c', 'zafin_rrp__Proposed_Standard_Total_Cost__c', 'zafin_rrp__Proposed_Standard_revenue__c', 'zafin_rrp__Proposed_Total_Cost__c', 'zafin_rrp__Simplified_Arrangement__c', 'zafin_rrp__Standard_Price__c', 'zafin_rrp__Surplus_Shortfall__c', 'zafin_rrp__Value_Changed__c', 'zafin_rrp__Changed_Tiers__c', 'zafin_rrp__Lower_Threshold__c', 'zafin_rrp__Upper_Threshold__c' };
    /**
    * @description 
    * @author Pradeep Kota | 06-13-2023 
    * @return List<Schema.SObjectField> 
    **/
        public List<Schema.SObjectField> getSObjectFieldList() {
            return new List<Schema.SObjectField> {
                zafin_rrp__Negotiated_Pricing__c.Id,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Negotiated_Pricing__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__AFP_Code__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__AFP_Name__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Actual_Volume__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Aggregate_Amount__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Aggregation_Cycle__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Aggregation_Period__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__AmountOrPercentage__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Amount__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Charging_Frequency__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Charging_Model__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Charging_Type__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Current_Price_Text__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Current_Price__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Discount__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__DoNot_Charge_Prepaid_Fee__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__EachOrAggregate__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__FeePlan_Code__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Fee_Code__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Fee_Item_Code__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Fee_Item_Description__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Fee_Item_Name__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__GraceOrPartialPeriod__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Grace_Period__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Is_Discount__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__MaxValue__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__MinValue__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Model__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Negotiated_Amount__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Negotiated_Percentage__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Number_Of_Cycles__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__PartialPeriod_Minimum_Days__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Partial_Period__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Percentage__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__ProcessAheadCheck__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Profitability_Fee_Item__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Proposed_ChargingModel__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Proposed_MaxValue__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Proposed_MinValue__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Proposed_Price_Text__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Proposed_Volume__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__SimpleOrTier__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Type__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Unit_Cost__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__VolumeOrValue__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Zafin_External_Id__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Zafin_Product__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Currency_Code__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Current_Standard_Revenue__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Current_Standard_Total_Cost__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Current_Volume_Value__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Discounted_Fee__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Proposed_Price__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Proposed_Profit_Margin__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Proposed_Recovery__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Proposed_Revenue__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Proposed_Standard_Total_Cost__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Proposed_Standard_revenue__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Proposed_Total_Cost__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Simplified_Arrangement__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Standard_Price__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Surplus_Shortfall__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Value_Changed__c,
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Changed_Tiers__c, 
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Lower_Threshold__c, 
                    zafin_rrp__NegotiatedPricing_FeeItem__c.zafin_rrp__Upper_Threshold__c
                    };
                        }
    /**
* @description Creates a new instance of the selector via the class selectById
* @return Schema.SObjectType
*/
    public Schema.SObjectType getSObjectType() {
        return zafin_rrp__NegotiatedPricing_FeeItem__c.sObjectType;
    }
    /**
* @description Select by section
*  @param parentId
*  @param limitValue
* @return List<zafin_rrp__NegotiatedPricing_FeeItem__c>
*/
    public List<zafin_rrp__NegotiatedPricing_FeeItem__c> selectZafinNegotiationPricingFeeItemByIdAndLimit(Id parentId,integer limitValue) {
        fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('zafin_rrp__Negotiated_Pricing__r.Id = :parentId');
        fieldQueryFactory.setLimit(limitValue);
        fieldQueryFactory.selectFields(fields);  
        return Database.query(fieldQueryFactory.toSOQL());
    }
    /**
* @description Select by section
*  @param parentId
* @return List<zafin_rrp__NegotiatedPricing_FeeItem__c>
*/
    public List<zafin_rrp__NegotiatedPricing_FeeItem__c> selectZafinNegotiationPricingFeeItemById(Id parentId) {
        fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('zafin_rrp__Negotiated_Pricing__c = :parentId');
        fieldQueryFactory.selectFields(fields);  
        return Database.query(fieldQueryFactory.toSOQL());
    }
      /**
* @description Select by section
*  @param parentId
*  @param categoryValue
*  @param orderingField
* @return List<zafin_rrp__NegotiatedPricing_FeeItem__c>
*/  
        public List<zafin_rrp__NegotiatedPricing_FeeItem__c> selectZafinNegotiationPricingFeeItemByIdAndOrderBy(Id parentId,List<string> categoryValue,string orderingField) {
        fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('zafin_rrp__Negotiated_Pricing__r.Id = :parentId AND zafin_rrp__Fee_Item_Code__c in :categoryValue');
        fieldQueryFactory.selectFields(fields);  
        return Database.query(fieldQueryFactory.toSOQL());
    }
}