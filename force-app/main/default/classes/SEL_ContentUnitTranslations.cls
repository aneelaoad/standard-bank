/**
 * @description       : SEL_ContentUnitTranslations
 * @author            : Ankit Kumar
 * @last modified on  : 02-27-2024
 * @last modified by  : Ankit Kumar
**/
public without sharing class SEL_ContentUnitTranslations extends fflib_SObjectSelector {

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            Content_Unit_Translation__c.Id,
            Content_Unit_Translation__c.Name,
            Content_Unit_Translation__c.Content_Unit__c,
            Content_Unit_Translation__c.Image_Url__c,
            Content_Unit_Translation__c.Image__c,
            Content_Unit_Translation__c.Text__c,
            Content_Unit_Translation__c.RichText__c,
            Content_Unit_Translation__c.Title__c,
            Content_Unit_Translation__c.Provider__c,
            Content_Unit_Translation__c.Language__c,
            Content_Unit_Translation__c.Language_ISO__c,
            Content_Unit_Translation__c.Link__c,
            Content_Unit_Translation__c.Product__c,
            Content_Unit_Translation__c.Tag__c,
            Content_Unit_Translation__c.Business_Event__c
        };
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return Content_Unit_Translation__c.sObjectType;
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024
    * @return SEL_ContentUnitTranslations 
    **/
    public static SEL_ContentUnitTranslations newInstance() {
        return(SEL_ContentUnitTranslations) ORG_Application.selector.newInstance(Content_Unit_Translation__c.SObjectType);
    }

    /**
     * @description select Content_Unit_Translation__c based on custom filter condition
     * @param condition String
     * @return List<Content_Unit_Translation__c>
     */
    public List<Content_Unit_Translation__c> selectByCustomFilterCondition(String condition) {
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Link__r.Icon__c')
            .selectField('Link__r.Offering__c')
            .selectField('Link__r.Desktop_url__c')
            .selectField('Link__r.Mobile_url__c')
            .selectField('Link__r.Guest_url__c')
            .selectField('Link__r.Comment__c')
            .selectField('Link__r.Status__c')
            .selectField('Link__r.IsOnline__c')
            .selectField('Link__r.Publishing_Unit__c')
            .setCondition(condition)
            .toSOQL()
        );
    }

        /**
     * @description select Content_Unit_Translation__c based on Ids
     * @param ids Set<Id>
     * @return List<Content_Unit_Translation__c> - with query results
     */
    public List<Content_Unit_Translation__c> selectByIds(Set<Id> ids) {
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Link__r.Icon__c')
            .selectField('Link__r.Offering__c')
            .selectField('Link__r.Desktop_url__c')
            .selectField('Link__r.Mobile_url__c')
            .selectField('Link__r.Guest_url__c')
            .selectField('Link__r.Comment__c')
            .selectField('Link__r.Status__c')
            .selectField('Link__r.IsOnline__c')
            .selectField('Link__r.Publishing_Unit__c')
            .setCondition(' Id in : ids')
            .toSOQL());
    } 
}