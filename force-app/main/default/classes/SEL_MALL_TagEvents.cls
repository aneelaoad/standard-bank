/**
 * @description       : SEL_MALL_TagEvents
 * @author            : Ankit Kumar
 * @group             : 
 * @last modified on  : 02-27-2024
**/
public without sharing class SEL_MALL_TagEvents extends fflib_SObjectSelector {

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            Tag_Business_Event__c.Id,
            Tag_Business_Event__c.Name,
            Tag_Business_Event__c.Business_Event__c,
            Tag_Business_Event__c.Tag__c
        };
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return Tag_Business_Event__c.sObjectType;
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return SEL_MALL_TagEvents 
    **/
    public static SEL_MALL_TagEvents newInstance() {
        return(SEL_MALL_TagEvents) ORG_Application.selector.newInstance(Tag_Business_Event__c.SObjectType);
    }

    /**
     * @description select Tag events based on custom filter condition
     * @param condition String
     * @return List<Tag_Business_Event__c> - with query results
     */
    public List<Tag_Business_Event__c> selectByCustomFilterCondition(String condition) {
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Business_Event__r.Start_Date__c')
            .selectField('Business_Event__r.End_Date__c')
            .selectField('Business_Event__r.isOnline__c')
            .selectField('Business_Event__r.Provider__c')
            .selectField('Business_Event__r.Provider__r.Name')
            .selectField('Business_Event__r.Link__c')
            .selectField('Business_Event__r.Id')
            .selectField('Business_Event__r.Name')
            .selectField('Tag__r.Id')
            .selectField('Tag__r.Name')
            .selectField('Tag__r.Parent_Name__c')
            .selectField('Tag__r.Root_Name__c')
            .selectField('Tag__r.Root__c')
            .selectField('Tag__r.Parent__r.Name')
            .selectField('Business_Event__r.Publishing_Unit__c')
            .selectField('Business_Event__r.Link__r.DeskTop_Url__c')
            .selectField('Business_Event__r.Link__r.Mobile_Url__c')
            .selectField('Business_Event__r.Link__r.Guest_url__c')
            .selectField('Business_Event__r.Link__r.IsOnline__c')
            .selectField('Business_Event__r.Publishing_Unit__r.isPublished__c')
            .selectField('Business_Event__r.Publishing_Unit__r.Published_From__c')
            .selectField('Business_Event__r.Publishing_Unit__r.Published_Until__c')
            .selectField('Business_Event__r.Offering__r.Id')
            .selectField('Business_Event__r.Offering__r.Name')
            .selectField('Business_Event__r.CreatedDate')
            .setCondition(condition)
            .toSOQL()
        );
    }

    /**
     * @description select tag events by tag names
     * @param tagNames Set<String> - Set of string to filter through
     * @return List<Tag_Business_Event__c> - with query results
     */
    public List<Tag_Business_Event__c> selectByTagNames(Set<String> tagNames) {
        
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Business_Event__r.Start_Date__c')
            .selectField('Business_Event__r.End_Date__c')
            .selectField('Business_Event__r.isOnline__c')
            .selectField('Business_Event__r.Provider__c')
            .selectField('Business_Event__r.Provider__r.Name')
            .selectField('Business_Event__r.Link__c')
            .selectField('Business_Event__r.Id')
            .selectField('Business_Event__r.Name')
            .selectField('Tag__r.Id')
            .selectField('Tag__r.Name')
            .selectField('Tag__r.Parent_Name__c')
            .selectField('Tag__r.Root_Name__c')
            .selectField('Tag__r.Root__c')
            .selectField('Tag__r.Parent__r.Name')
            .selectField('Business_Event__r.Publishing_Unit__c')
            .selectField('Business_Event__r.Link__r.DeskTop_Url__c')
            .selectField('Business_Event__r.Link__r.Mobile_Url__c')
            .selectField('Business_Event__r.Link__r.Guest_url__c')
            .selectField('Business_Event__r.Link__r.IsOnline__c')
            .selectField('Business_Event__r.Publishing_Unit__r.isPublished__c')
            .selectField('Business_Event__r.Publishing_Unit__r.Published_From__c')
            .selectField('Business_Event__r.Publishing_Unit__r.Published_Until__c')
            .selectField('Business_Event__r.Offering__r.Id')
            .selectField('Business_Event__r.Offering__r.Name')
            .selectField('Business_Event__r.CreatedDate')          
            .setCondition(' Tag__r.Name IN : tagNames AND Business_Event__r.isOnline__c = TRUE')
            .toSOQL());
    }

    
    /**
     * @description select tag events by tag Ids
     * @param tagIds Set<Id> - Set of Ids to filter through
     * @return List<Tag_Business_Event__c> - with query results
     */
    public List<Tag_Business_Event__c> selectByTagIds(Set<Id> tagIds) {
        
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Business_Event__r.Start_Date__c')
            .selectField('Business_Event__r.End_Date__c')
            .selectField('Business_Event__r.isOnline__c')
            .selectField('Business_Event__r.Provider__c')
            .selectField('Business_Event__r.Provider__r.Name')
            .selectField('Business_Event__r.Link__c')
            .selectField('Business_Event__r.Id')
            .selectField('Business_Event__r.Name')
            .selectField('Tag__r.Id')
            .selectField('Tag__r.Name')
            .selectField('Tag__r.Parent_Name__c')
            .selectField('Tag__r.Root_Name__c')
            .selectField('Tag__r.Root__c')
            .selectField('Tag__r.Parent__r.Name')
            .selectField('Business_Event__r.Publishing_Unit__c')
            .selectField('Business_Event__r.Link__r.DeskTop_Url__c')
            .selectField('Business_Event__r.Link__r.Mobile_Url__c')
            .selectField('Business_Event__r.Link__r.Guest_url__c')
            .selectField('Business_Event__r.Link__r.IsOnline__c')
            .selectField('Business_Event__r.Publishing_Unit__r.isPublished__c')
            .selectField('Business_Event__r.Publishing_Unit__r.Published_From__c')
            .selectField('Business_Event__r.Publishing_Unit__r.Published_Until__c')
            .selectField('Business_Event__r.Offering__r.Id')
            .selectField('Business_Event__r.Offering__r.Name')
            .selectField('Business_Event__r.CreatedDate')       
            .setCondition(' Tag__c IN : tagIds AND Business_Event__r.isOnline__c = TRUE')
            .toSOQL());
    }
}