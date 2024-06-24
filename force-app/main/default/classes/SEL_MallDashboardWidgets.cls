/**
 * @description       : SEL_MallDashboardWidgets
 * @author            : Ankit Kumar
 * @group             : 
 * @last modified on  : 02-27-2024
**/
public without sharing class SEL_MallDashboardWidgets extends fflib_SObjectSelector {

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return List<Schema.SObjectField> 
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
            Mall_Dashboard_Widget__c.Id,
            Mall_Dashboard_Widget__c.Name,
            Mall_Dashboard_Widget__c.User__c,
            Mall_Dashboard_Widget__c.Position__c
        };
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return Schema.SObjectType 
    **/
    public Schema.SObjectType getSObjectType() {
        return Mall_Dashboard_Widget__c.sObjectType;
    }

    /**
    * @description 
    * @author Ankit Kumar | 02-27-2024 
    * @return SEL_MallDashboardWidgets 
    **/
    public static SEL_MallDashboardWidgets newInstance() {
        return(SEL_MallDashboardWidgets) ORG_Application.selector.newInstance(Mall_Dashboard_Widget__c.SObjectType);
    }

    /**
     * 
     * @description select Mall dashboard widgets by ids
     * @param userIds Set<Id> - Set of id's to filter through
     * @return List<Mall_Dashboard_Widget__c> - with query results
     */
    public List<Mall_Dashboard_Widget__c> selectByUserIds(Set<Id> userIds) {
        return Database.query(
            newQueryFactory(false, false, true)
            .setCondition(' User__c in : userIds')
            .toSOQL());
    } 
}