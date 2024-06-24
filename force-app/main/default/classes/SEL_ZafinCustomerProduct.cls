/***************************************************************************************
* @Name of the Class     :SEL_ZafinCustomerProduct
* @description           :SFP-36983 Selector class for zafin_rrp__Bank_Account__c SObject
* @Author                :Pradeep Kota
* @Created Date          :Sep 27th 2023
/***************************************************************************************
*@Last Modified By         : Pradeep Kota
*@Last Modified On         : 11 Mar 2024
*@Modification Description : SFP-36983
***************************************************************************************/
public inherited sharing class SEL_ZafinCustomerProduct extends fflib_SObjectSelector {
    private static Set<String> fields=new Set<String>{'id','zafin_rrp__Customer__r.Name','zafin_rrp__Customer__r.id','zafin_rrp__Zafin_Product__c','zafin_rrp__Customer__c'};  
    /**
    * @description 
    * @author Pradeep Kota | 01-03-2024 
    * @return List<Schema.SObjectField> 
    **/
        public List<Schema.SObjectField> getSObjectFieldList() {
            return new List<Schema.SObjectField> {
                zafin_rrp__Bank_Account__c.Id,
                    zafin_rrp__Bank_Account__c.zafin_rrp__Customer__c,
                    zafin_rrp__Bank_Account__c.zafin_rrp__Account_Cohort__c,
                    zafin_rrp__Bank_Account__c.zafin_rrp__Account_Cohort_Name__c,
                    zafin_rrp__Bank_Account__c.zafin_rrp__Account_Region__c,
                    zafin_rrp__Bank_Account__c.zafin_rrp__Average_Balance__c,
                    zafin_rrp__Bank_Account__c.zafin_rrp__Balance__c,
                    zafin_rrp__Bank_Account__c.zafin_rrp__BankAccount_Row__c,
                    zafin_rrp__Bank_Account__c.zafin_rrp__Billing_Plan__c,
                    zafin_rrp__Bank_Account__c.zafin_rrp__Billing_Plan_Code__c,
                    zafin_rrp__Bank_Account__c.zafin_rrp__Branch_Id__c,
                    zafin_rrp__Bank_Account__c.zafin_rrp__Charge_Request_Enabled__c,
                    zafin_rrp__Bank_Account__c.zafin_rrp__Zafin_Product__c
            };
        }
    /**
* @description Creates a new instance of the selector via the class selectById
* @return Schema.SObjectType
*/
    public Schema.SObjectType getSObjectType() {
        return zafin_rrp__Bank_Account__c.sObjectType;
    }
    /**
* @description Select by section
* @return List<zafin_rrp__Bank_Account__c>
*/
    public List<zafin_rrp__Bank_Account__c> selectZafinCustomerProduct() {
        fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.selectFields(fields);  
        return Database.query(fieldQueryFactory.toSOQL());
    }
      /**
* @description Select by section
*  @param recordId
* @return List<zafin_rrp__Negotiated_Pricing__c>
*/
    public List<zafin_rrp__Bank_Account__c> selectZafinCustomerProductById(Id recordId) {
        fflib_QueryFactory fieldQueryFactory = newQueryFactory(false, false, false);
        fieldQueryFactory.setCondition('zafin_rrp__Customer__r.id = :recordId');
        fieldQueryFactory.selectFields(fields);  
        return Database.query(fieldQueryFactory.toSOQL());
    }
}