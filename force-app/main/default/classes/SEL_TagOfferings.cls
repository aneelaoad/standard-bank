/**
 * @description       : SEL_TagOfferings
 * @author            : Ankit Kumar
 * @group             : 
 * @last modified on  : 02-27-2024
**/
public without sharing class SEL_TagOfferings extends fflib_SObjectSelector {

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            Tag_Offering__c.Id,
            Tag_Offering__c.Name,
            Tag_Offering__c.Offering__c,
            Tag_Offering__c.Tag__c
        };
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return Tag_Offering__c.sObjectType;
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return SEL_TagOfferings 
    **/
    public static SEL_TagOfferings newInstance() {
        return(SEL_TagOfferings) ORG_Application.selector.newInstance(Tag_Offering__c.SObjectType);
    }

    /**
     * @description select Tag Offerings based on custom filter condition
     * @param condition String
     * @return List<Tag_Offering__c> - with query results
     */
    public List<Tag_Offering__c> selectByCustomFilterCondition(String condition) {
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Offering__r.isOnline__c')
            .selectField('Offering__r.Provider__c')
            .selectField('Offering__r.Provider__r.Name')
            .selectField('Offering__r.Link__c')
            .selectField('Offering__r.Provider__r.Default_Translation__c')
            .selectField('Offering__r.Provider__r.Default_Translation__r.Image_URL__c')
            .selectField('Offering__r.Id')
            .selectField('Offering__r.Name')
            .selectField('Tag__r.Id')
            .selectField('Tag__r.Name')
            .selectField('Tag__r.Parent_Name__c')
            .selectField('Tag__r.Root_Name__c')
            .selectField('Tag__r.Root__c')
            .selectField('Offering__r.Publishing_Unit__c')
            .selectField('Offering__r.Link__r.DeskTop_Url__c')
            .selectField('Offering__r.Link__r.Mobile_Url__c')
            .selectField('Offering__r.Link__r.Guest_url__c')
            .selectField('Offering__r.Link__r.IsOnline__c')
            .selectField('Offering__r.Publishing_Unit__r.isPublished__c')
            .selectField('Offering__r.Publishing_Unit__r.Published_From__c')
            .selectField('Offering__r.Publishing_Unit__r.Published_Until__c')
            .selectField('Offering__r.Default_Translation__c')
            .selectField('Offering__r.RecordTypeId')
            .selectField('Offering__r.RecordType.Name')
            .selectField('Offering__r.Default_Translation__r.Image_URL__c')
            .selectField('Offering__r.Default_Translation__r.Text__c')
            .selectField('Offering__r.Default_Translation__r.RichText__c')
            .selectField('Offering__r.Default_Translation__r.Id')
            .selectField('Offering__r.Default_Translation__r.Name')
            .selectField('Offering__r.Default_Translation__r.Content_Unit__c')
            .selectField('Offering__r.Default_Translation__r.Image__c')
            .selectField('Offering__r.Default_Translation__r.Language__c')
            .selectField('Offering__r.Default_Translation__r.Language_ISO__c')
            .selectField('Offering__r.Default_Translation__r.Link__c')
            .selectField('Offering__r.Default_Translation__r.Product__c')
            .selectField('Offering__r.Default_Translation__r.Provider__c')
            .selectField('Offering__r.Default_Translation__r.Tag__c')
            .selectField('Offering__r.CreatedDate')
            .selectField('Tag__r.Parent__r.Name')
            .setCondition(condition)
            .toSOQL()
        );
    }

    /**
     * @description select tag offerings by offering Ids
     * @param tagNames Set<String> - Set of id's to filter through
     * @return List<Tag_Offering__c> - with query results
     */
    public List<Tag_Offering__c> selectByTagNames(Set<String> tagNames) {
        
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Offering__r.isOnline__c')
            .selectField('Offering__r.Provider__c')
            .selectField('Offering__r.Provider__r.Name')
            .selectField('Offering__r.Link__c')
            .selectField('Offering__r.Provider__r.Default_Translation__c')
            .selectField('Offering__r.Provider__r.Default_Translation__r.Image_URL__c')
            .selectField('Offering__r.Id')
            .selectField('Offering__r.Name')
            .selectField('Tag__r.Id')
            .selectField('Tag__r.Name')
            .selectField('Tag__r.Parent_Name__c')
            .selectField('Tag__r.Root_Name__c')
            .selectField('Tag__r.Root__c')
            .selectField('Offering__r.Publishing_Unit__c')
            .selectField('Offering__r.Link__r.DeskTop_Url__c')
            .selectField('Offering__r.Link__r.Mobile_Url__c')
            .selectField('Offering__r.Link__r.Guest_url__c')
            .selectField('Offering__r.Link__r.IsOnline__c')
            .selectField('Offering__r.Publishing_Unit__r.isPublished__c')
            .selectField('Offering__r.Publishing_Unit__r.Published_From__c')
            .selectField('Offering__r.Publishing_Unit__r.Published_Until__c')
            .selectField('Offering__r.Default_Translation__c')
            .selectField('Offering__r.RecordTypeId')
            .selectField('Offering__r.RecordType.Name')
            .selectField('Offering__r.Default_Translation__r.Image_URL__c')
            .selectField('Offering__r.Default_Translation__r.Text__c')
            .selectField('Offering__r.Default_Translation__r.RichText__c')
            .selectField('Offering__r.Default_Translation__r.Id')
            .selectField('Offering__r.Default_Translation__r.Name')
            .selectField('Offering__r.Default_Translation__r.Content_Unit__c')
            .selectField('Offering__r.Default_Translation__r.Image__c')
            .selectField('Offering__r.Default_Translation__r.Language__c')
            .selectField('Offering__r.Default_Translation__r.Language_ISO__c')
            .selectField('Offering__r.Default_Translation__r.Link__c')
            .selectField('Offering__r.Default_Translation__r.Product__c')
            .selectField('Offering__r.Default_Translation__r.Provider__c')
            .selectField('Offering__r.Default_Translation__r.Tag__c')
            .selectField('Offering__r.CreatedDate')
            .selectField('Tag__r.Parent__r.Name')            
            .setCondition(' Tag__r.Name IN : tagNames AND Offering__r.isOnline__c = TRUE')
            .toSOQL());
    }
}