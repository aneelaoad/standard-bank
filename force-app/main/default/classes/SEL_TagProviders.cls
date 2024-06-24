/**
 * @description       : SEL_TagProviders
 * @author            : Ankit Kumar
 * @group             : 
 * @last modified on  : 02-27-2024
**/
public without sharing class SEL_TagProviders extends fflib_SObjectSelector {

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            Tag_Provider__c.Id,
            Tag_Provider__c.Name,
            Tag_Provider__c.Provider__c,
            Tag_Provider__c.Tag__c,
            Tag_Provider__c.CreatedDate
        };
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return Tag_Provider__c.sObjectType;
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return SEL_TagProviders 
    **/
    public static SEL_TagProviders newInstance() {
        return(SEL_TagProviders) ORG_Application.selector.newInstance(Tag_Provider__c.SObjectType);
    }

    /**
     * @description select Tag providers based on custom filter condition
     * @param condition String
     * @return List<Tag_Provider__c> - with query results
     */
    public List<Tag_Provider__c> selectByCustomFilterCondition(String condition) {
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Tag__r.Id')
            .selectField('Tag__r.Name')
            .selectField('Tag__r.Parent__c')
            .selectField('Tag__r.Parent_Name__c')
            .selectField('Tag__r.Root__c')
            .selectField('Tag__r.Root_Name__c')
            .selectField('Tag__r.Parent__r.Name')
            .selectField('Provider__r.Link__c')
            .selectField('Provider__r.Link__r.DeskTop_Url__c')
            .selectField('Provider__r.Link__r.Mobile_Url__c')
            .selectField('Provider__r.Link__r.Guest_url__c')
            .selectField('Provider__r.Parent_Provider__c')
            .selectField('Provider__r.Name')
            .selectField('Provider__r.Icon__c')
            .selectField('Provider__r.isOnline__c')
            .selectField('Provider__r.Publishing_Unit__c')
            .selectField('Provider__r.Default_Translation__c')
            .selectField('Provider__r.Publishing_Unit__r.isPublished__c')
            .selectField('Provider__r.Publishing_Unit__r.published_From__c')
            .selectField('Provider__r.Publishing_Unit__r.published_Until__c')
            .selectField('Provider__r.Default_Translation__r.Image_URL__c')
            .selectField('Provider__r.Default_Translation__r.Text__c')
            .selectField('Provider__r.Default_Translation__r.RichText__c')
            .selectField('Provider__r.Default_Translation__r.Id')
            .selectField('Provider__r.Default_Translation__r.Name')
            .selectField('Provider__r.Default_Translation__r.Content_Unit__c')
            .selectField('Provider__r.Default_Translation__r.Image__c')
            .selectField('Provider__r.Default_Translation__r.Language__c')
            .selectField('Provider__r.Default_Translation__r.Language_ISO__c')
            .selectField('Provider__r.Default_Translation__r.Link__c')
            .selectField('Provider__r.Default_Translation__r.Product__c')
            .selectField('Provider__r.Default_Translation__r.Provider__c')
            .selectField('Provider__r.Default_Translation__r.Tag__c')
            .selectField('Provider__r.CreatedDate')
            .setCondition(condition)
            .toSOQL()
        );
    }

    /**
     * @description select tag providers by offering Ids
     * @param tagNames Set<String> - Set of tag names to filter through
     * @return List<Tag_Provider__c> - with query results
     */
    public List<Tag_Provider__c> selectByTagNames(Set<String> tagNames) {
        
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Tag__r.Id')
            .selectField('Tag__r.Name')
            .selectField('Tag__r.Parent__c')
            .selectField('Tag__r.Parent_Name__c')
            .selectField('Tag__r.Root__c')
            .selectField('Tag__r.Root_Name__c')
            .selectField('Tag__r.Parent__r.Name')
            .selectField('Provider__r.Link__c')
            .selectField('Provider__r.Link__r.DeskTop_Url__c')
            .selectField('Provider__r.Link__r.Mobile_Url__c')
            .selectField('Provider__r.Link__r.Guest_url__c')
            .selectField('Provider__r.Parent_Provider__c')
            .selectField('Provider__r.Name')
            .selectField('Provider__r.Icon__c')
            .selectField('Provider__r.isOnline__c')
            .selectField('Provider__r.Publishing_Unit__c')
            .selectField('Provider__r.Default_Translation__c')
            .selectField('Provider__r.Publishing_Unit__r.isPublished__c')
            .selectField('Provider__r.Publishing_Unit__r.published_From__c')
            .selectField('Provider__r.Publishing_Unit__r.published_Until__c')
            .selectField('Provider__r.Default_Translation__r.Image_URL__c')
            .selectField('Provider__r.Default_Translation__r.Text__c')
            .selectField('Provider__r.Default_Translation__r.RichText__c')
            .selectField('Provider__r.Default_Translation__r.Id')
            .selectField('Provider__r.Default_Translation__r.Name')
            .selectField('Provider__r.Default_Translation__r.Content_Unit__c')
            .selectField('Provider__r.Default_Translation__r.Image__c')
            .selectField('Provider__r.Default_Translation__r.Language__c')
            .selectField('Provider__r.Default_Translation__r.Language_ISO__c')
            .selectField('Provider__r.Default_Translation__r.Link__c')
            .selectField('Provider__r.Default_Translation__r.Product__c')
            .selectField('Provider__r.Default_Translation__r.Provider__c')
            .selectField('Provider__r.Default_Translation__r.Tag__c')
            .selectField('Provider__r.CreatedDate')
            .setCondition(' Tag__r.Name IN : tagNames AND Provider__r.isOnline__c = TRUE')
            .toSOQL());
    }
}