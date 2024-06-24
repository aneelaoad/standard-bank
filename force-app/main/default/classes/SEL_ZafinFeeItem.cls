/***************************************************************************************
* @Name of the Class     :SEL_ZafinFeeItem
* @description           :SFP-36983 Test Selector class for zafin_rrp__Fee_Item__c SObject
* @Author                :Likhitha Karusala
* @Created Date          :Sep 27th 2023
/***************************************************************************************
*@Last Modified By         : Likhitha Karusala 
*@Last Modified On         : 11 Mar 2024
*@Modification Description : SFP-36983
***************************************************************************************/
public inherited sharing class SEL_ZafinFeeItem extends fflib_SObjectSelector {
    private static Set<String> fields=new Set<String>{'Id', 'zafin_rrp__Currency_Code__c','zafin_rrp__Fee_Item_Code__c',
        'zafin_rrp__Fee_Code__c','zafin_rrp__Plan__r.zafin_rrp__Zafin_Product__c',
        'zafin_rrp__Amount__c', 'zafin_rrp__Fee_Item_Name__c', 'zafin_rrp__Plan__c', 'CreatedDate',
      'CurrencyIsoCode', 'zafin_rrp__AFP_Code__c','zafin_rrp__AFP_Name__c','zafin_rrp__Free_Items__c',
       'zafin_rrp__Max_Limit__c', 'zafin_rrp__MaxValue__c','zafin_rrp__MinValue__c','zafin_rrp__Number_Of_Cycles__c',
        'zafin_rrp__Percentage__c','zafin_rrp__Plan_Feature__c','zafin_rrp__Reset_Frequency__c',
        'zafin_rrp__SimpleOrTier__c','zafin_rrp__Total_Unit_Cost__c','zafin_rrp__Transaction_Group__c'};
    /**
    * @description 
    * @author Likhitha Karusala | 01-03-2024 
    * @return List<Schema.SObjectField> 
    **/
        public List<Schema.SObjectField> getSObjectFieldList() {
            return new List<Schema.SObjectField> {
                zafin_rrp__Fee_Item__c.Id,
                    zafin_rrp__Fee_Item__c.zafin_rrp__Currency_Code__c	,
                    zafin_rrp__Fee_Item__c.zafin_rrp__Fee_Item_Code__c,
                    zafin_rrp__Fee_Item__c.zafin_rrp__Fee_Code__c,
                    zafin_rrp__Fee_Item__c.zafin_rrp__Amount__c,
                    zafin_rrp__Fee_Item__c.zafin_rrp__Fee_Item_Name__c,
                    zafin_rrp__Fee_Item__c.zafin_rrp__Plan__c,
                    zafin_rrp__Fee_Item__c.CreatedDate,
                    zafin_rrp__Fee_Item__c.CurrencyIsoCode,
                    zafin_rrp__Fee_Item__c.zafin_rrp__AFP_Code__c,
                    zafin_rrp__Fee_Item__c.zafin_rrp__AFP_Name__c,
                    zafin_rrp__Fee_Item__c.zafin_rrp__Free_Items__c	,
                    zafin_rrp__Fee_Item__c.zafin_rrp__Max_Limit__c,
                    zafin_rrp__Fee_Item__c.zafin_rrp__MaxValue__c,
                    zafin_rrp__Fee_Item__c.zafin_rrp__MinValue__c,
                    zafin_rrp__Fee_Item__c.zafin_rrp__Number_Of_Cycles__c,
                    zafin_rrp__Fee_Item__c.zafin_rrp__Percentage__c,
                    zafin_rrp__Fee_Item__c.zafin_rrp__Plan_Feature__c,
                    zafin_rrp__Fee_Item__c.zafin_rrp__Reset_Frequency__c,
                    zafin_rrp__Fee_Item__c.zafin_rrp__SimpleOrTier__c,
                    zafin_rrp__Fee_Item__c.zafin_rrp__Total_Unit_Cost__c,
                    zafin_rrp__Fee_Item__c.zafin_rrp__Transaction_Group__c
                    };
                        }
    /**
* @description Creates a new instance of the selector via the class selectById
* @return Schema.SObjectType
*/
    public Schema.SObjectType getSObjectType() {
        return zafin_rrp__Fee_Item__c.sObjectType;
    }
    /**
* @description Select by section
* @return List<zafin_rrp__Fee_Item__c>
*/
    public List<zafin_rrp__Fee_Item__c> selectZafinFeeItemAll() {
        fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.selectFields(fields);  
        return Database.query(fieldQueryFactory.toSOQL());
    }
      /**
* @description Select by section
*  @param recordId
* @return List<zafin_rrp__Fee_Item__c>
*/
    public List<zafin_rrp__Fee_Item__c> selectZafinFeeItemByProductIds(set<Id> recordId) {
        fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('zafin_rrp__Plan__r.zafin_rrp__Zafin_Product__c IN :recordId');
        fieldQueryFactory.selectFields(fields);  
        return Database.query(fieldQueryFactory.toSOQL());
    }
}