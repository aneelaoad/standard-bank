/**
 * @description       : US: SFP-11066 - Generate agenda from a button
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : TCK
**/
public without sharing class SEL_TagContents extends fflib_SObjectSelector {

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            Tag_Content__c.Id,
            Tag_Content__c.Name,
            Tag_Content__c.Content__c,
            Tag_Content__c.Tag__c
        };
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return Tag_Content__c.sObjectType;
    }

    /**
    * @description 
    * @author TCK | 06-13-2022 
    * @return SEL_TagContents 
    **/
    public static SEL_TagContents newInstance() {
        return(SEL_TagContents) ORG_Application.selector.newInstance(Tag_Content__c.SObjectType);
    }

    /**
     * @description select Tag contents based on custom filter condition
     * @param condition
     * @return List<Tag_Content__c> - with query results
     */
    public List<Tag_Content__c> selectByCustomFilterCondition(String condition) {
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Content__r.isOnline__c')
            .selectField('Content__r.Link__c')
            .selectField('Content__r.Order__c')
            .selectField('Content__r.Parent_Content__c')
            .selectField('Content__r.Duration__c')
            .selectField('Content__r.Text__c')
            .selectField('Content__r.Rich_Text__c')
            .selectField('Content__r.Section__c')
            .selectField('Content__r.Status__c')
            .selectField('Content__r.Version_Number__c')
            .selectField('Content__r.RecordType.DeveloperName')
            .selectField('Content__r.RecordType.Name')
            .selectField('Content__r.Id')
            .selectField('Content__r.Name')
            .selectField('Tag__r.Id')
            .selectField('Tag__r.Name')
            .selectField('Tag__r.Parent_Name__c')
            .selectField('Tag__r.Root_Name__c')
            .selectField('Tag__r.Root__c')
            .selectField('Tag__r.Parent__r.Name')
            .selectField('Content__r.Publishing_Unit__c')
            .selectField('Content__r.CreatedDate')
            .selectField('Content__r.Link__r.DeskTop_Url__c')
            .selectField('Content__r.Link__r.Mobile_Url__c')
            .selectField('Content__r.Link__r.Guest_url__c')
            .selectField('Content__r.Link__r.IsOnline__c')
            .selectField('Content__r.Publishing_Unit__r.isPublished__c')
            .selectField('Content__r.Publishing_Unit__r.Published_From__c')
            .selectField('Content__r.Publishing_Unit__r.Published_Until__c')
            .setCondition(condition)
            .toSOQL()
        );
    }
}