/**
 * @description Selector class for UserRole
 *
 * @author Konrad Bruszewski
 * @date October 2021
 */
public with sharing class SEL_UserRole extends fflib_SObjectSelector{

   /**
    * Returns the list of UserRole fields
    *
    * @return List of fields
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                UserRole.DeveloperName,
                UserRole.Id,
                UserRole.ParentRoleId
        };
    }

   /**
    * Returns SObject type
    *
    * @return SObject type
    */
    public Schema.SObjectType getSObjectType() {
        return UserRole.sObjectType;
    }

    /**
     * Select roles by portal type
     *
     * @param portalType - role portal type
     *
     * @return List<UserRole>
     */
    public List<UserRole> selectByPortalType(String portalType){
        return (List<UserRole>) Database.query(newQueryFactory()
                .setCondition('PortalType = :portalType')
                .toSOQL()
        );
    }

    /**
     * Selects roles by developer names
     *
     * @param roleNames - Set<String> developer names of the roles
     *
     * @return List<UserRole>
     */
    public List<UserRole> selectByDeveloperNames(Set<String> roleNames){
        return (List<UserRole>) Database.query(newQueryFactory()
                .setCondition('DeveloperName IN :roleNames')
                .toSOQL());
    }
}