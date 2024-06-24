/**
 * @description       : SEL_Offerings
 * @author            : Ankit Kumar
 * @group             : 
 * @last modified on  : 02-27-2024
**/
public without sharing class SEL_Offerings extends fflib_SObjectSelector {

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            Offering__c.Id,
            Offering__c.Name,
            Offering__c.Link__c,
            Offering__c.Publishing_Unit__c,
            Offering__c.Parent_Offering__c,
            Offering__c.Comments__c
        };
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return Offering__c.sObjectType;
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return SEL_Offerings 
    **/
    public static SEL_Offerings newInstance() {
        return(SEL_Offerings) ORG_Application.selector.newInstance(Offering__c.SObjectType);
    }

    /**
     * @description select Offerings based on custom filter condition
     * @param condition String
     * @return List<Offering__c> - with query results
     */
    public List<Offering__c> selectByCustomFilterCondition(String condition) {
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Link__r.Desktop_url__c')
            .selectField('Link__r.Mobile_Url__c')
            .selectField('Link__r.Guest_url__c')
            .selectField('Default_Translation__r.Image_Url__c')
            .selectField('Provider__r.Publishing_Unit__r.Published_From__c')
            .selectField('Publishing_Unit__r.isPublished__c')
            .selectField('Publishing_Unit__r.Published_From__c')
            .selectField('Publishing_Unit__r.Published_Until__c')
            .selectField('Provider__r.IsOnline__c')
            .setCondition(condition)
            .toSOQL()
        );
    }

    /**
     * @description select offerings by parent offering Ids
     * @param parentOfferingIds Set<Id> - Set of parent id's to filter through
     * @return List<Offering__c> - with query results
     */
    public List<Offering__c> selectByParentOffering(Set<Id> parentOfferingIds) {
        
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Link__r.Desktop_url__c')
            .selectField('Link__r.Mobile_Url__c')
            .selectField('Link__r.Guest_url__c')
            .selectField('Default_Translation__r.Image_Url__c')
            .selectField('Provider__r.Publishing_Unit__r.Published_From__c')
            .selectField('Publishing_Unit__r.isPublished__c')
            .selectField('Publishing_Unit__r.Published_From__c')
            .selectField('Publishing_Unit__r.Published_Until__c')
            .selectField('Provider__r.IsOnline__c')       
            .setCondition('Parent_Offering__c IN : parentOfferingIds')
            .toSOQL());
    }
}