/**
 * @description Selector class for PermissionSetAssignment
 *
 * @author Konrad Bruszewski
 * @date October 2021
 */
public with sharing class SEL_PermissionSetAssignments extends fflib_SObjectSelector{

    /**
    * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
    * and inject a mock instead of this class or to switch out this class for a new version.
    * @return SEL_PermissionSetAssignments class instance
    */
    public static SEL_PermissionSetAssignments newInstance() {
        return (SEL_PermissionSetAssignments) ORG_Application.selector.newInstance(PermissionSetAssignment.SObjectType);
    }

    /**
    * Returns the SObject fields on this sObject
    * @return PermissionSetAssignment  fields list
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            PermissionSetAssignment.AssigneeId,
            PermissionSetAssignment.Id,
            PermissionSetAssignment.PermissionSetId
        };
    }

    /**
    * Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
    * queries.
    * @return PermissionSetAssignment  object type
    */
    public Schema.SObjectType getSObjectType() {
        return PermissionSetAssignment.SObjectType;
    }

    /**
     * Returns query locator for the given condition
     *
     * @param condition  String with query condition
     *
     * @return query locator
     */
    public String getQueryWithCustomCondition(String condition) {
        return newQueryFactory().setCondition(condition).toSOQL();
    }

    /**
     * Returns list of permission set assignments for given permission set name
     *
     * @param permissionSetName
     * @param assigneeIds
     *
     * @return List<PermissionSetAssignment>
     */
    public List<PermissionSetAssignment> selectByPermissionSetNameAndAssigneeIds(String permissionSetName, Set<Id> assigneeIds){
        return (List<PermissionSetAssignment>) Database.query(newQueryFactory()
            .setCondition('PermissionSet.Name = :permissionSetName AND AssigneeId IN :assigneeIds')
            .toSOQL());
    }

    /**
     * Returns list of permission set assignments for active user for given permission set name
     *
     * @param permissionSetName
     *
     * @return List<PermissionSetAssignment>
     */
    public List<PermissionSetAssignment> selectByPermissionSetName(String permissionSetName) {
        return (List<PermissionSetAssignment>) Database.query(newQueryFactory()
            .setCondition('PermissionSet.Name = :permissionSetName AND Assignee.IsActive = true')
            .toSOQL());
    }
}