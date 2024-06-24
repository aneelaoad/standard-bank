/**
 * @description       : US: SFP-11066 - Generate agenda from a button
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : TCK
**/
public without sharing class SEL_PromotionTranslations extends fflib_SObjectSelector {

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            Promotion_Translation__c.Id,
            Promotion_Translation__c.Name,
            Promotion_Translation__c.Promotion__c,
            Promotion_Translation__c.Small_Title__c,
            Promotion_Translation__c.Large_Title__c,
            Promotion_Translation__c.SubText__c,
            Promotion_Translation__c.Button_Label__c,
            Promotion_Translation__c.Button_Title__c,
            Promotion_Translation__c.Language_ISO__c,
            Promotion_Translation__c.Language__c
        };
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return Promotion_Translation__c.sObjectType;
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return SEL_PromotionTranslations 
    **/
    public static SEL_PromotionTranslations newInstance() {
        return(SEL_PromotionTranslations) ORG_Application.selector.newInstance(Promotion_Translation__c.SObjectType);
    }

    /**
     * @description select promotions translations based on custom filter condition
     * @param condition
     * @return List<Promotion_Translation__c> - with query results
     */
    public List<Promotion_Translation__c> selectByCustomFilterCondition(String condition) {
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Promotion__r.Name')
            .setCondition(condition)
            .toSOQL()
        );
    }
}