/***************************************************************************************
* @Name of the Class     :SEL_ZafinStatementFeeCategory
* @description           :SFP-36983 Selector class for zafin_rrp__Statement_Fee_Category__c SObject
* @Author                :Likhitha Karusala
* @Created Date          :Sep 27th 2023
/***************************************************************************************
*@Last Modified By         : Likhitha Karusala 
*@Last Modified On         : 11 Mar 2024
*@Modification Description : SFP-33357
***************************************************************************************/
public inherited sharing class SEL_ZafinStatementFeeCategory extends fflib_SObjectSelector {
    private static Set<String> fields =new Set<String>{'Id','zafin_rrp__Category_Code__c','zafin_rrp__Category_Description__c',
       'zafin_rrp__Category_Name__c', 'CreatedById','CurrencyIsoCode','zafin_rrp__Fee_Code__c','zafin_rrp__Fee_Name__c',
        'LastModifiedById','OwnerId','Name','zafin_rrp__External_Id__c'};
    /**
    * @description Retrieving fields from Schema of zafin_rrp__Statement_Fee_Category__c Object
    * @author Likhitha Karusala | 01-03-2024 
    * @return List<Schema.SObjectField> 
    **/
        public List<Schema.SObjectField> getSObjectFieldList() {
            return new List<Schema.SObjectField> {
                zafin_rrp__Statement_Fee_Category__c.Id
            };
        }
    /**
* @description Creates a new instance of the selector via the class selectById
* @return Schema.SObjectType
*/
    public Schema.SObjectType getSObjectType() {
        return zafin_rrp__Statement_Fee_Category__c.sObjectType;
    }
    /**
* @description Select by section
* @return List<zafin_rrp__Statement_Fee_Category__c>
*/
    public List<zafin_rrp__Statement_Fee_Category__c> selectZafinStatementFeeCategory() {
        fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.selectFields(fields);  
        return Database.query(fieldQueryFactory.toSOQL());
    }
}