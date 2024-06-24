/**
 * @description       : Selector class for PermissionSet
 * @author            : Jaco de Lange
 * @last modified on  : 02-08-2024
**/
public with sharing class SEL_PermissionSet extends fflib_SObjectSelector {
    /**
    * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
    * and inject a mock instead of this class or to switch out this class for a new version.
    * @return SEL_PermissionSet class instance
    */
    public static SEL_PermissionSet newInstance() {
        return (SEL_PermissionSet) ORG_Application.selector.newInstance(PermissionSet.SObjectType);
    }
    /**
    * Returns the SObject fields on this sObject
    * @return PermissionSet  fields list
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            PermissionSet.Id,
            PermissionSet.Name,
            PermissionSet.Label
        };
    }
     /**
    * Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
    * queries.
    * @return PermissionSet  object type
    */
    public Schema.SObjectType getSObjectType() {
        return PermissionSet.SObjectType;
    }
    /**
     * Returns list of permission set for active user for given permission set name
     * @param permissionSetName
     * @return List<PermissionSet>
     */
    public List<PermissionSet> selectByPermissionSetName(String permissionSetName) {
        return (List<PermissionSet>) Database.query(newQueryFactory()
                .setCondition('Name = :permissionSetName')
                .toSOQL());
    }
}