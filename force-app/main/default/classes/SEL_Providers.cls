/**
 * @description       : US: SFP-11066 - Generate agenda from a button
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : TCK
**/
public without sharing class SEL_Providers extends fflib_SObjectSelector {

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            Provider__c.Id,
            Provider__c.Name,
            Provider__c.Cellphone__c,
            Provider__c.Default_Translation__c,
            Provider__c.VAT_Registration_Number__c,
            Provider__c.Status__c,
            Provider__c.Approval_Comment__c,
            Provider__c.CIPC__c,
            Provider__c.Parent_Provider__c,
            Provider__c.Email__c,
            Provider__c.Icon__c,
            Provider__c.Link__c,
            Provider__c.IsOnline__c,
            Provider__c.Publishing_Unit__c,
            Provider__c.OwnerId,
            Provider__c.Related_Client__c
        };
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return Provider__c.sObjectType;
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return SEL_Providers 
    **/
    public static SEL_Providers newInstance() {
        return(SEL_Providers) ORG_Application.selector.newInstance(Provider__c.SObjectType);
    }

    /**
     * @description select providers based on custom filter condition
     * @param condition
     * @return List<Provider__c> - with query results
     */
    public List<Provider__c> selectByCustomFilterCondition(String condition) {
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Parent_Provider__r.Related_Client__c')
            .selectField('Link__r.Desktop_url__c')
            .selectField('Link__r.Mobile_url__c')
            .selectField('Link__r.Guest_url__c')
            .selectField('Default_Translation__r.Image_Url__c')
            .selectField('Default_Translation__r.RichText__c')
            .selectField('Default_Translation__r.Text__c')
            .selectField('Default_Translation__r.Title__c')
            .setCondition(condition)
            .toSOQL()
        );
    }

    public List<Provider__c> selectByIds(Set<Id> ids) {
        
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Parent_Provider__r.Related_Client__c')
            .selectField('Link__r.Desktop_url__c')
            .selectField('Link__r.Mobile_url__c')
            .selectField('Link__r.Guest_url__c')
            .selectField('Default_Translation__r.Image_Url__c')
            .selectField('Default_Translation__r.RichText__c')
            .selectField('Default_Translation__r.Text__c')
            .selectField('Default_Translation__r.Title__c')
            .setCondition(' Id in : ids')
            .toSOQL());
    } 

}