/**
 * @description       : SEL_TagLinks
 **/
public without sharing class SEL_TagLinks extends fflib_SObjectSelector {

    /**
     * @description Returns a list of fields for Tag_Link__c object.
     * @return List<Schema.SObjectField>
     **/
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Tag_Link__c.Id,
            Tag_Link__c.Tag__c,
            Tag_Link__c.Link__c,
            Tag_Link__c.Link__r.Name,
            Tag_Link__c.Tag__r.Name,
            Tag_Link__c.Tag__r.Parent__r.Name
        };
    }

    /**
     * @description Returns the SObject type for Tag_Link__c.
     * @return Schema.SObjectType
     **/
    public Schema.SObjectType getSObjectType() {
        return Tag_Link__c.sObjectType;
    }

    /**
     * @description Returns a new instance of SEL_TagLinks.
     * @return SEL_TagLinks
     **/
    public static SEL_TagLinks newInstance() {
        return (SEL_TagLinks) ORG_Application.selector.newInstance(Tag_Link__c.SObjectType);
    }

    /**
     * @description Select Tag Links based on a custom filter condition.
     * @param condition String
     * @return List<Tag_Link__c> - with query results
     */
    public List<Tag_Link__c> selectByCustomFilterCondition(String condition) {
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Id')
            .selectField('Tag__c')
            .selectField('Link__c')
            .selectField('Link__r.Name')
            .selectField('Tag__r.Name')
            .selectField('Tag__r.Parent__r.Name')
            .setCondition(condition)
            .toSOQL()
        );
    }
}
