/**
 * @description       : SEL_TagSuccessStories
 * @author            : Ankit Kumar
 * @group             : 
 * @last modified on  : 02-27-2024
**/
public without sharing class SEL_TagSuccessStories extends fflib_SObjectSelector {

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            Tag_Success_Story__c.Id,
            Tag_Success_Story__c.Name,
            Tag_Success_Story__c.Success_Story__c,
            Tag_Success_Story__c.Tag__c
        };
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return Tag_Success_Story__c.sObjectType;
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return SEL_TagSuccessStories 
    **/
    public static SEL_TagSuccessStories newInstance() {
        return(SEL_TagSuccessStories) ORG_Application.selector.newInstance(Tag_Success_Story__c.SObjectType);
    }

    /**
     * @description select Tag success stories based on custom filter condition
     * @param condition String
     * @return List<Tag_Success_Story__c> - with query results
     */
    public List<Tag_Success_Story__c> selectByCustomFilterCondition(String condition) {
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Success_Story__r.Customer_feedback__c')
            .selectField('Success_Story__r.Customer_Full_Name__c')
            .selectField('Success_Story__r.Customer_Image_Url__c')
            .selectField('Success_Story__r.Banner_Image__r.Image_Url__c')
            .selectField('Success_Story__r.Challenge__c')
            .selectField('Success_Story__r.isOnline__c')
            .selectField('Success_Story__r.Context__c')
            .selectField('Success_Story__r.Image_Gallery__c')
            .selectField('Success_Story__r.Language__c')
            .selectField('Success_Story__r.Language__r.Name')
            .selectField('Success_Story__r.Id')
            .selectField('Success_Story__r.Name')
            .selectField('Success_Story__r.Outcome__c')
            .selectField('Success_Story__r.Parent_Success_Story__c')
            .selectField('Success_Story__r.Solution__c')
            .selectField('Success_Story__r.Summary__c')
            .selectField('Success_Story__r.RecordTypeId')
            .selectField('Success_Story__r.RecordType.Name')
            .selectField('Tag__r.Id')
            .selectField('Tag__r.Name')
            .selectField('Tag__r.Parent_Name__c')
            .selectField('Tag__r.Root_Name__c')
            .selectField('Tag__r.Root__c')
            .selectField('Tag__r.Parent__r.Name')
            .selectField('Success_Story__r.Publishing_Unit__c')
            .selectField('Success_Story__r.Video_Testimony__r.DeskTop_Url__c')
            .selectField('Success_Story__r.Video_Testimony__r.Mobile_Url__c')
            .selectField('Success_Story__r.Video_Testimony__r.Guest_url__c')
            .selectField('Success_Story__r.Publishing_Unit__r.isPublished__c')
            .selectField('Success_Story__r.Publishing_Unit__r.Published_From__c')
            .selectField('Success_Story__r.Publishing_Unit__r.Published_Until__c')
            .selectField('Success_Story__r.CreatedDate')
            .setCondition(condition)
            .toSOQL()
        );
    }

    /**
     * @description select tag success stories by tag names
     * @param tagNames Set<String> - Set of string to filter through
     * @return List<Tag_Success_Story__c> - with query results
     */
    public List<Tag_Success_Story__c> selectByTagNames(Set<String> tagNames) {
        
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Success_Story__r.Customer_feedback__c')
            .selectField('Success_Story__r.Customer_Full_Name__c')
            .selectField('Success_Story__r.Customer_Image_Url__c')
            .selectField('Success_Story__r.Banner_Image__r.Image_Url__c')
            .selectField('Success_Story__r.Challenge__c')
            .selectField('Success_Story__r.isOnline__c')
            .selectField('Success_Story__r.Context__c')
            .selectField('Success_Story__r.Image_Gallery__c')
            .selectField('Success_Story__r.Language__c')
            .selectField('Success_Story__r.Language__r.Name')
            .selectField('Success_Story__r.Id')
            .selectField('Success_Story__r.Name')
            .selectField('Success_Story__r.Outcome__c')
            .selectField('Success_Story__r.Parent_Success_Story__c')
            .selectField('Success_Story__r.Solution__c')
            .selectField('Success_Story__r.Summary__c')
            .selectField('Success_Story__r.RecordTypeId')
            .selectField('Success_Story__r.RecordType.Name')
            .selectField('Tag__r.Id')
            .selectField('Tag__r.Name')
            .selectField('Tag__r.Parent_Name__c')
            .selectField('Tag__r.Root_Name__c')
            .selectField('Tag__r.Root__c')
            .selectField('Tag__r.Parent__r.Name')
            .selectField('Success_Story__r.Publishing_Unit__c')
            .selectField('Success_Story__r.Video_Testimony__r.DeskTop_Url__c')
            .selectField('Success_Story__r.Video_Testimony__r.Mobile_Url__c')
            .selectField('Success_Story__r.Video_Testimony__r.Guest_url__c')
            .selectField('Success_Story__r.Publishing_Unit__r.isPublished__c')
            .selectField('Success_Story__r.Publishing_Unit__r.Published_From__c')
            .selectField('Success_Story__r.Publishing_Unit__r.Published_Until__c')
            .selectField('Success_Story__r.CreatedDate')        
            .setCondition(' Tag__r.Name IN : tagNames AND Success_Story__r.isOnline__c = TRUE')
            .toSOQL());
    }
}