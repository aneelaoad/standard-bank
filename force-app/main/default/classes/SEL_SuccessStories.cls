/**
 * @description       : US: SFP-11066 - Generate agenda from a button
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : TCK
**/
public without sharing class SEL_SuccessStories extends fflib_SObjectSelector {

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            Success_Story__c.Id,
            Success_Story__c.Name,
            Success_Story__c.Challenge__c,
            Success_Story__c.IsOnline__c,
            Success_Story__c.Context__c,
            Success_Story__c.Image_Gallery__c,
            Success_Story__c.Language__c,
            Success_Story__c.Outcome__c,
            Success_Story__c.Parent_Success_Story__c,
            Success_Story__c.Solution__c,
            Success_Story__c.Summary__c,
            Success_Story__c.RecordTypeId,
            Success_Story__c.Publishing_Unit__c,
            Success_Story__c.CreatedDate,
            Success_Story__c.Customer_feedback__c,
            Success_Story__c.Customer_Full_Name__c,
            Success_Story__c.Customer_Image_Url__c
        };
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return Success_Story__c.sObjectType;
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return SEL_TagSuccessStories 
    **/
    public static SEL_SuccessStories newInstance() {
        return(SEL_SuccessStories) ORG_Application.selector.newInstance(Success_Story__c.SObjectType);
    }

    /**
     * @description select success stories based on custom filter condition
     * @param condition
     * @return List<Success_Story__c> - with query results
     */
    public List<Success_Story__c> selectByCustomFilterCondition(String condition) {
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Banner_Image__r.Image_Url__c')
            .selectField('RecordType.Name')
            .selectField('Video_Testimony__r.DeskTop_Url__c')
            .selectField('Video_Testimony__r.Mobile_Url__c')
            .selectField('Video_Testimony__r.Guest_url__c')
            .selectField('Publishing_Unit__r.isPublished__c')
            .selectField('Publishing_Unit__r.Published_From__c')
            .selectField('Publishing_Unit__r.Published_Until__c')
            .setCondition(condition)
            .toSOQL()
        );
    }
}