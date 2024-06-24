/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 07-01-2022
 * @last modified by  : TCK
**/
public with sharing class SEL_Group extends fflib_SObjectSelector {
    /**
    * @description 
    * @author TCK | 06-22-2022 
    * @return SEL_Group 
    **/
    public static SEL_Group newInstance() {
        return (SEL_Group) ORG_Application.selector.newInstance(Group.SObjectType);
    }

    /**
     * @description Get SObject field list
     *
     * @return List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                Group.Id,
                Group.Name,
                Group.Type,
                Group.DeveloperName
        };
    }

    /**
     * @description Get SObject type
     *
     * @return Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Group.sObjectType;
    }

    /**
    * @description 
    * @author TCK | 06-22-2022 
    * @param names 
    * @return List<Group> 
    **/
    public List<Group> selectByName(List<Id> names){
        return (List<Group>) Database.query(
                newQueryFactory()
                        .setCondition('Name IN :names')
                        .toSOQL()
        );
    }

    /**
    * @description 
    * @author TCK | 06-22-2022 
    * @param names 
    * @return List<Group> 
    **/
    public List<Group> selectByName(List<String> names){
        return (List<Group>) Database.query(
                newQueryFactory()
                        .setCondition('Name IN :names')
                        .toSOQL()
        );
    }

    /**
    * @description 
    * @author TCK | 06-22-2022 
    * @param name 
    * @return Group 
    **/
    public Group selectByNameId(Id name){
        return (Group) Database.query(
                newQueryFactory()
                        .setCondition('Name = :name')
                        .setLimit(1)
                        .toSOQL()
        );
    }

    /**
    * @description 
    * @author TCK | 06-22-2022 
    * @param name 
    * @return Group 
    **/
    public Group selectByName(String name){
        return (Group) Database.query(
                newQueryFactory()
                        .setCondition('Name LIKE :name')
                        .setLimit(1)
                        .toSOQL()
        );
    }

    /**
    * @description 
    * @author TCK | 06-22-2022 
    * @param type 
    * @return List<Group> 
    **/
    public List<Group> selectByType(String type){
        return (List<Group>) Database.query(
                newQueryFactory()
                        .setCondition('Type = :type')
                        .toSOQL()
        );
    }
    
    /**
    * @description 
    * @author Raja Kumaar | 23rd March 2023
    * @param type and Developer Name of the group
    * @return List<Group> 
    **/
    public List<Group> selectByTypeAndDeveloperName(String type,String developerName){
        return (List<Group>) Database.query(
                newQueryFactory()
                        .setCondition('Type = :type AND DeveloperName = :developerName')
                        .toSOQL()
        );
    }
}