/**
 * @description       : SEL_MALL_FooterItems
 * @author            : Ankit Kumar
 * @since             :
**/
public without sharing class SEL_MALL_FooterItems extends fflib_SObjectSelector {

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            SBG_Footer_Item__mdt.Id,
            SBG_Footer_Item__mdt.MasterLabel,
            SBG_Footer_Item__mdt.Parent_Tab__c,
            SBG_Footer_Item__mdt.Level__c,
            SBG_Footer_Item__mdt.Item_URL__c,
            SBG_Footer_Item__mdt.Order_Number__c
        };
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return SBG_Footer_Item__mdt.sObjectType;
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return SEL_MALL_FooterItems 
    **/
    public static SEL_MALL_FooterItems newInstance() {
        return(SEL_MALL_FooterItems) ORG_Application.selector.newInstance(SBG_Footer_Item__mdt.SObjectType);
    }

    /**
     * @description select footer items
     * @return List<SBG_Footer_Item__mdt> - with query results
     */
    public List<SBG_Footer_Item__mdt> selectFooterItems() {
        return Database.query(
            newQueryFactory(false, false, true)
            .addOrdering('Order_Number__c', fflib_QueryFactory.SortOrder.ASCENDING)
            .toSOQL()
        );
    }
}