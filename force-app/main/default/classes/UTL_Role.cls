/**
 * @description Utility class for UserRole Object
 */
public without sharing class UTL_Role{
    
    private static Map<Id,String> mapRoleDevName;
    private static Map<Id,String> mapRoleLabel;
    private static Map<String,Id> mapRoleName2Id;
    private static Boolean firstUse = true;
    private static SEL_UserRole userRoleSelector = (SEL_UserRole) ORG_Application.selector.newInstance(UserRole.SObjectType);

    /**
     * Get role's Id for given developer name
     *
     * @param roleDevName
     *
     * @return
     */
    public static Id getRoleId(String roleDevName) {
        rolesLoader();
        Id roleId = mapRoleName2Id.get(roleDevName);
        if(roleId == null) {
            throw new G_RolesException('User Role not exists: '+roleDevName);
        }
        return roleId;
    }

    /**
     * Get role's developer name for given role Id
     *
     * @param roleId
     *
     * @return
     */
    public static String getRoleDeveloperName(Id roleId) {
        rolesLoader();
        String roleName = mapRoleDevName.get(roleId);
        if(roleName == null) {
            throw new G_RolesException('User Role Id is incorrect: '+roleId);
        }
        return roleName;
    }

    /**
     * Get label of a role for given role Id
     *
     * @param roleId - Id
     *
     * @return
     */
    public static String getRoleLabel(Id roleId) {
        rolesLoader();
        String roleLabel = mapRoleDevName.get(roleId);
        if(roleLabel == null) {
            throw new G_RolesException('User Role Id is incorrect: '+roleId);
        }
        return roleLabel;
    }

    /**
     * For given set of developer names of roles, Ids of those roles and internal subordinate roles get returned
     *
     * @param roleNames - Set<String> developer names
     *
     * @return
     */
    public static Set<String> getInternalSubordinateRolesIds(Set<String> roleNames) {
        // get all roles in the org except portal roles
        List<UserRole> allRoles = userRoleSelector.selectByPortalType('None');
        Set<String> selectedRoleNames = new Set<String>();
        List<UserRole> selectedRoles = userRoleSelector.selectByDeveloperNames(roleNames);
        Set<String> parentRoles = new Set<String>();
        Set<String> selectedRolesAndSubordinateRolesIds = new Set<String>();
        for (UserRole role : selectedRoles) {
            selectedRoleNames.add(role.DeveloperName);
            parentRoles.add(role.Id);
            selectedRolesAndSubordinateRolesIds.add(role.Id);
        }

        Set<String> childRoles = new Set<String>();

        while (true) {
            // go one level deeper in the role hierarchy
            for (UserRole role : allRoles) {
                if (parentRoles.contains(role.ParentRoleId)) {
                    childRoles.add(role.Id);
                    selectedRoleNames.add(role.DeveloperName);
                }
            }

            // If no child roles have been found during this iteration, then stop the search
            if (childRoles.isEmpty()) {
                break;
            }

            // If any child roles have been found, add them to all found roles
            selectedRolesAndSubordinateRolesIds.addAll(childRoles);
            // Current child roles become parent roles for next iteration
            parentRoles.clear();
            parentRoles.addAll(childRoles);
            childRoles.clear();
        }
        return selectedRolesAndSubordinateRolesIds;
    }

    private static void rolesLoader() {
        if(firstUse) {
            loadRoles();
            firstUse = false;
        }
    }

    private static void loadRoles() {
        List<UserRole> allRoles = [SELECT Id,DeveloperName,Name FROM UserRole];
        mapRoleDevName = new Map<Id,String>();
        mapRoleLabel = new Map<Id,String>();
        mapRoleName2Id = new Map<String,Id>();
        for(UserRole role: allRoles) {
            mapRoleDevName.put(role.Id,role.DeveloperName);
            mapRoleLabel.put(role.Id,role.Name);
            mapRoleName2Id.put(role.DeveloperName,role.Id);
        }
    }
    
    public class G_RolesException extends Exception {}
}