/**
 * @description       : SEL_Tags
 * @author            : Ankit Kumar
 * @group             : 
 * @last modified on  : 02-27-2024
**/
public without sharing class SEL_Tags extends fflib_SObjectSelector {

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            Tag__c.Id,
            Tag__c.Name,
            Tag__c.IsOnline__c,
            Tag__c.IsRoot_Tag__c,
            Tag__c.Parent__c,
            Tag__c.Publishing_Unit__c,
            Tag__c.Tag_Icon__c,
            Tag__c.Parent_Name__c,
            Tag__c.Root__c, 
            Tag__c.Root_Name__c,
            Tag__c.IsRoot__c,
            Tag__c.Position__c,
            Tag__c.Related_Tag__c
        };
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return Tag__c.sObjectType;
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return SEL_Tags 
    **/
    public static SEL_Tags newInstance() {
        return(SEL_Tags) ORG_Application.selector.newInstance(Tag__c.SObjectType);
    }

    /**
     * @description select Tags based on custom filter condition
     * @param condition String
     * @return List<Tag__c> - with query results
     */
    public List<Tag__c> selectByCustomFilterCondition(String condition) {
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Parent__r.Name')
            .selectField('Publishing_Unit__r.isPublished__c')
            .selectField('Publishing_Unit__r.Published_From__c')
            .selectField('Publishing_Unit__r.Published_Until__c')
            .selectField('Related_Tag__r.Name')
            .setCondition(condition)
            .toSOQL()
        );
    }

    /**
     * @description select tags by  ids
     * @param ids Set<Id> - Set of id's to filter through
     * @return List<Tag__c> - with query results
     */
    public List<Tag__c> selectTagsByIds(Set<Id> ids) {
        
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Parent__r.Name')
            .selectField('Publishing_Unit__r.isPublished__c')
            .selectField('Publishing_Unit__r.Published_From__c')
            .selectField('Publishing_Unit__r.Published_Until__c')
            .selectField('Related_Tag__r.Name')
            .setCondition('Id in : ids AND IsOnline__c = TRUE')
            .toSOQL());
    } 

    /**
     * @description select tags by  names
     * @param names Set<String> - Set of names to filter through
     * @return List<Tag__c> - with query results
     */
    public List<Tag__c> selectTagsByNames(Set<String> names) {
        
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Parent__r.Name')
            .selectField('Publishing_Unit__r.isPublished__c')
            .selectField('Publishing_Unit__r.Published_From__c')
            .selectField('Publishing_Unit__r.Published_Until__c')
            .selectField('Related_Tag__r.Name')
            .setCondition('Name in : names AND IsOnline__c = TRUE')
            .toSOQL());
    }

        /**
     * @description select tags by  names
     * @param parentNames Set<String> - Set of names to filter through
     * @return List<Tag__c> - with query results
     */
    public List<Tag__c> selectTagsByParentNames(Set<String> parentNames) {
        
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Parent__r.Name')
            .selectField('Publishing_Unit__r.isPublished__c')
            .selectField('Publishing_Unit__r.Published_From__c')
            .selectField('Publishing_Unit__r.Published_Until__c')
            .selectField('Related_Tag__r.Name')
            .setCondition('Parent_Name__c in : parentNames AND IsOnline__c = TRUE')
            .toSOQL());
    }

        /**
     * @description select tags by  names
     * @param rootNames Set<String> - Set of names to filter through
     * @return List<Tag__c> - with query results
     */
    public List<Tag__c> selectTagsByRootNames(Set<String> rootNames) {
        
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Parent__r.Name')
            .selectField('Publishing_Unit__r.isPublished__c')
            .selectField('Publishing_Unit__r.Published_From__c')
            .selectField('Publishing_Unit__r.Published_Until__c')
            .selectField('Related_Tag__r.Name')
            .setCondition('Root_name__c in : rootNames AND IsOnline__c = TRUE')
            .toSOQL());
    }
}