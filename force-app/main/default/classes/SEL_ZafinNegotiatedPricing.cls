/***************************************************************************************
* @Name of the Class     :SEL_ZafinNegotiatedPricing
* @description           :SFP-36983 Selector class for zafin_rrp__Negotiated_Pricing__c SObject
* @Author                :Likhitha Karusala 
* @Created Date          :Sep 27th 2023
/***************************************************************************************
*@Last Modified By         : Likhitha Karusala  
*@Last Modified On         : 11 Mar 2024
*@Modification Description : SFP-36983
***************************************************************************************/
public inherited sharing class SEL_ZafinNegotiatedPricing extends fflib_SObjectSelector {
    private static Set<String> fields=new Set<String>{'Id','Name','zafin_rrp__Agreement_Id__c','zafin_rrp__Arrangement_Type__c','zafin_rrp__Reason__c','zafin_rrp__Agreement_Name__c','zafin_rrp__Amount__c','zafin_rrp__Fee_Item__c','zafin_rrp__Fee_Item_Code__c','zafin_rrp__Fee_Item_Name__c','zafin_rrp__Reporting_Customer__c','zafin_rrp__Reporting_Customer__r.Name','zafin_rrp__Reporting_Customer__r.CIF__c'};
    /**
    * @description 
    * @author Likhitha Karusala | 12-07-2022 
    * @return List<Schema.SObjectField> 
    **/
       public List<Schema.SObjectField> getSObjectFieldList() {
            return new List<Schema.SObjectField> {
                zafin_rrp__Negotiated_Pricing__c.Id,
                    zafin_rrp__Negotiated_Pricing__c.zafin_rrp__Agreement_Id__c,
                    zafin_rrp__Negotiated_Pricing__c.zafin_rrp__Arrangement_Type__c,
                    zafin_rrp__Negotiated_Pricing__c.zafin_rrp__Reason__c,
                    zafin_rrp__Negotiated_Pricing__c.zafin_rrp__Agreement_Name__c,
                    zafin_rrp__Negotiated_Pricing__c.zafin_rrp__Amount__c,
                    zafin_rrp__Negotiated_Pricing__c.zafin_rrp__Fee_Item__c,
                    zafin_rrp__Negotiated_Pricing__c.zafin_rrp__Fee_Item_Code__c,
                    zafin_rrp__Negotiated_Pricing__c.zafin_rrp__Fee_Item_Name__c,
                    zafin_rrp__Negotiated_Pricing__c.zafin_rrp__Reporting_Customer__c,
                    zafin_rrp__Negotiated_Pricing__c.zafin_rrp__Reporting_Customer__r.Name
                    };
                        }
    /**
* @description Creates a new instance of the selector via the class selectById
* @return Schema.SObjectType
*/
    public Schema.SObjectType getSObjectType() {
        return zafin_rrp__Negotiated_Pricing__c.sObjectType;
    }
    /**
* @description Select by section
*  @param recordId
* @return List<zafin_rrp__Negotiated_Pricing__c>
*/
    public List<zafin_rrp__Negotiated_Pricing__c> selectZafinNegotiationPricingById(Id recordId) {
        fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('zafin_rrp__Reporting_Customer__c = :recordId');
        fieldQueryFactory.selectFields(fields);  
        return Database.query(fieldQueryFactory.toSOQL());
    }
 /**
* @description Select by section
*  @param recordId
* @return zafin_rrp__Negotiated_Pricing__c
*/
    public List<zafin_rrp__Negotiated_Pricing__c> selectZafinNegotiationPricingByRecordId(Id recordId) {
        fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('id = :recordId');
        fieldQueryFactory.selectFields(fields);  
        return Database.query(fieldQueryFactory.toSOQL());
    }
    /**
* @description Select by section
*  @param recordId
* @return zafin_rrp__Negotiated_Pricing__c
*/
    public zafin_rrp__Negotiated_Pricing__c selectZafinNegotiationByRecordId(Id recordId) {
        fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('id = :recordId');
        fieldQueryFactory.selectFields(fields);  
        return Database.query(fieldQueryFactory.toSOQL());
    }
}