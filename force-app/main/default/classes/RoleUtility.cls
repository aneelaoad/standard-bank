/*************************************************************************\
    @ Author        :     Caro Reinecke
    @ Date          :     16 August 2011
    @ Test File     :     Covered in SA_TEST_CreateEventReportTrigger
    @ Description   :     Util methods to: 
                           - deteremine users in the role hierarchy tree
                           - check if a user's role is in the confidential Activities group
                          
    @ Last Modified By  : Caro Reinecke
    @ Last Modified On  : 24 May 2012
    @ Last Modified Reason  : Added two new methods to:
                                - determine if a specified role is above a user's role in the role hierarchy (isManagerOfRole)
                                - determine if a specified user is above a user's role in the role hierarchy (isManagerOfUser)
    
    @ Last Modified By  : Caro Reinecke
    @ Last Modified On  : 22 Ja 2013
    @ Last Modified Reason  : Case 1263 Client Overview Page Control
                                Added new method to determine if a specified list of users is managed by a specific user in the role hierarchy (isManagerOfUsers)
    
    @ Last Modified By  : Nitish Kumar
    @ Last Modified On  : 28 Nov 2013
    @ Last Modified Reason  : Made the class global so that it can be used in the custom button  
    
    @ Last Modified By  : Charles Mutsu
    @ Last Modified On  : 12 Dec 2013
    @ Last Modified Reason  : Updated API version to 29

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Aug 11, 2015 
    @ Modification Description : Force.com reviewer - Blocker and Critical issues - 20150608.xlsx
****************************************************************************/ 
Global with sharing class RoleUtility {

    //Check if User Role is in a higher postition in the Hierarchy (Using User Ids)
    public static Boolean isManagerOfUsers(List<Id> teamMemberIds, Id pManagementUser){
        Set<Id> batchUserRoles = new Set<Id>();
        Set<Id> roleToCheck = new Set<Id>();
        List<UserRole> rolesHierarchy = new List<UserRole>();
        Integer beforeLoop = 0;
        Integer afterLoop = 0;

        for (List<UserRole> userRoles: [SELECT Id
                                              ,ParentRoleId
                                          FROM UserRole
                                         LIMIT 10000]) { // max should be < 50k because the method is called in a context
            rolesHierarchy.addAll(userRoles);
        }

        //Get Data From the User at Role Object
        If (teamMemberIds.size() != 0) {
            List <User> getInfoFromUser = [Select Id, UserRoleId from User where Id in :teamMemberIds];

            if (getInfoFromUser.size() != 0) {
                for (User userDataReturned : getInfoFromUser) {
                    batchUserRoles.add(userDataReturned.UserRoleId);
                }
            }

            List<UserRole> userRolesParent = [Select Id, ParentRoleId from UserRole where Id in :batchUserRoles];

            for (UserRole rolesList : userRolesParent) {
                if (rolesList.ParentRoleId != null) {
                    roleToCheck.add(rolesList.ParentRoleId);
                }
            }
        }

        beforeLoop = roleToCheck.size();

        // Check the Role Hierarchy for "Reports To" Roles
        if (beforeLoop != 0) {
            while (beforeLoop != afterLoop) {
                beforeLoop = roleToCheck.size();

                for (UserRole parentRoleCheck : rolesHierarchy) {
                    if (roleToCheck.contains(parentRoleCheck.Id) && parentRoleCheck.ParentRoleId != null) {
                        roleToCheck.add(parentRoleCheck.ParentRoleId);
                        afterLoop = roleToCheck.size();
                    } else if (afterLoop == 0) {
                        afterLoop = beforeLoop;
                    }
                }
            }
        }

        // Checks if the specified User is higher in the Role Hierarchy than the teamMemberIds
        if (pManagementUser != null) {
            String pManRoleId = '';

            List <User> managerUser = [Select Id, UserRoleId from User where Id = :pManagementUser];

            if (managerUser.size() != 1) {
                return false;
            }

            pManRoleId = managerUser[0].UserRoleId;

            if (roleToCheck.contains(pManRoleId)) {
                return true;
            }
        }

        return false;
    }

    //Check if User Role is in a higher postition in the Hierarchy (Using Role Ids)
     public static Boolean isManagerOfRole(Id managerRoleId, Id userRoleId){
        // Get role to users mapping in a map with key as role id

        Map<Id, UserRole> roleUsersMap = new Map<Id, UserRole>([select Id, Name, parentRoleId, (select id, name, Business_Unit__c, User_Division__c from users where isActive=true) from UserRole order by parentRoleId]);

        // populate child role - parent roles map
            Set<Id> managerRoleIds = new Set<Id>();
            Map<Id, List<UserRole>> childParentRoleMap = new Map<Id, List<UserRole>>();
            List<UserRole> immediateParentList;
            List<UserRole> parentsParentList;
            Boolean atTheTop = false;
            for (UserRole r : roleUsersMap.values()) {
                if (r.id <> userRoleId) continue;
                atTheTop = false;
                immediateParentList = new List<UserRole>();
                While (!atTheTop)  {
                    if (!childParentRoleMap.containsKey(r.Id)){
                        immediateParentList.Add(roleUsersMap.get(r.ParentRoleId));
                        childParentRoleMap.put(r.Id, immediateParentList);
                        managerRoleIds.add(r.ParentRoleId);
                        if (r.ParentRoleId == null) atTheTop = true;
                    }
                    else {
                        immediateParentList = (List<UserRole>)childParentRoleMap.get(r.Id);
                        parentsParentList = new List<UserRole>();
                        for (UserRole r2 : immediateParentList){
                           if (r2.ParentRoleId == null){
                               atTheTop = true;
                               break;
                           } else {
                               parentsParentList.Add(roleUsersMap.get(r2.ParentRoleId));
                               managerRoleIds.add(r2.ParentRoleId);
                           }
                        }
                        immediateParentList.addAll(parentsParentList);
                        childParentRoleMap.put(r.Id, immediateParentList);
                    }
                }
                break;
            }
            return managerRoleIds.contains(managerRoleId);
     }
     //Check if User Role is in a higher postition in the Hierarchy (Using User Ids & Role Ids)
     public static Boolean isManagerOfUser(Id managerRoleId, Id userId){
        // Get role to users mapping in a map with key as role id

        Map<Id, UserRole> roleUsersMap = new Map<Id, UserRole>([select Id, Name, parentRoleId, (select id from users where isActive=true) from UserRole order by parentRoleId]);

        // populate child role - parent roles map
            Set<Id> managerRoleIds = new Set<Id>();
            Set<Id> userIds = new Set<Id>();
            Map<Id, List<UserRole>> childParentRoleMap = new Map<Id, List<UserRole>>();
            List<UserRole> immediateParentList;
            List<UserRole> parentsParentList;
            Boolean atTheTop = false;
            for (UserRole r : roleUsersMap.values()) {
                // Find the user
                for (User theUser : r.Users){
                    userIds.add(theUser.Id);
                }
                if (!userIds.contains(userId)) {
                    userIds = new Set<Id>();
                    continue;
                }
                atTheTop = false;
                immediateParentList = new List<UserRole>();
                While (!atTheTop)  {
                    if (!childParentRoleMap.containsKey(r.Id)){
                        immediateParentList.Add(roleUsersMap.get(r.ParentRoleId));
                        childParentRoleMap.put(r.Id, immediateParentList);
                        managerRoleIds.add(r.ParentRoleId);
                        if (r.ParentRoleId == null) atTheTop = true;
                    }
                    else {
                        immediateParentList = (List<UserRole>)childParentRoleMap.get(r.Id);
                        parentsParentList = new List<UserRole>();
                        for (UserRole r2 : immediateParentList){
                           if (r2.ParentRoleId == null){
                               atTheTop = true;
                               break;
                           } else {
                               parentsParentList.Add(roleUsersMap.get(r2.ParentRoleId));
                               managerRoleIds.add(r2.ParentRoleId);
                           }
                        }
                        immediateParentList.addAll(parentsParentList);
                        childParentRoleMap.put(r.Id, immediateParentList);
                    }
                }
                break;
            }
            return managerRoleIds.contains(managerRoleId);
     }

     //Check if User Role is in a higher postition in the Hierarchy (Using Role Ids)
     public static Boolean isAboveUserHierarchy(Map<Id, UserRole> roleUsersMap,Id managerRoleId, Id userRoleId){

        // populate child role - parent roles map
            Set<Id> managerRoleIds = new Set<Id>();
            Map<Id, List<UserRole>> childParentRoleMap = new Map<Id, List<UserRole>>();
            List<UserRole> immediateParentList;
            List<UserRole> parentsParentList;
            Boolean atTheTop = false;
            for (UserRole r : roleUsersMap.values()) {
                if (r.id <> userRoleId) continue;
                atTheTop = false;
                immediateParentList = new List<UserRole>();
                While (!atTheTop)  {
                    if (!childParentRoleMap.containsKey(r.Id)){
                        immediateParentList.Add(roleUsersMap.get(r.ParentRoleId));
                        childParentRoleMap.put(r.Id, immediateParentList);
                        managerRoleIds.add(r.ParentRoleId);
                        if (r.ParentRoleId == null) atTheTop = true;
                    }
                    else {
                        immediateParentList = (List<UserRole>)childParentRoleMap.get(r.Id);
                        parentsParentList = new List<UserRole>();
                        for (UserRole r2 : immediateParentList){
                           if (r2.ParentRoleId == null){
                               atTheTop = true;
                               break;
                           } else {
                               parentsParentList.Add(roleUsersMap.get(r2.ParentRoleId));
                               managerRoleIds.add(r2.ParentRoleId);
                           }
                        }
                        immediateParentList.addAll(parentsParentList);
                        childParentRoleMap.put(r.Id, immediateParentList);
                    }
                }
                break;
            }
            return managerRoleIds.contains(managerRoleId);
     }

     //Check if User Role is in a higher postition in the Hierarchy (Using User Ids & Role Ids)
     public static Boolean isManagerOfUserByProvidingRoles(Map<Id, UserRole> roleUsersMap, Id managerRoleId, Id userId){

        // populate child role - parent roles map
            Set<Id> managerRoleIds = new Set<Id>();
            Set<Id> userIds = new Set<Id>();
            Map<Id, List<UserRole>> childParentRoleMap = new Map<Id, List<UserRole>>();
            List<UserRole> immediateParentList;
            List<UserRole> parentsParentList;
            Boolean atTheTop = false;
            for (UserRole r : roleUsersMap.values()) {
                // Find the user
                for (User theUser : r.Users){
                    userIds.add(theUser.Id);
                }
                if (!userIds.contains(userId)) {
                    userIds = new Set<Id>();
                    continue;
                }
                atTheTop = false;
                immediateParentList = new List<UserRole>();
                While (!atTheTop)  {
                    if (!childParentRoleMap.containsKey(r.Id)){
                        immediateParentList.Add(roleUsersMap.get(r.ParentRoleId));
                        childParentRoleMap.put(r.Id, immediateParentList);
                        managerRoleIds.add(r.ParentRoleId);
                        if (r.ParentRoleId == null) atTheTop = true;
                    }
                    else {
                        immediateParentList = (List<UserRole>)childParentRoleMap.get(r.Id);
                        parentsParentList = new List<UserRole>();
                        for (UserRole r2 : immediateParentList){
                           if (r2.ParentRoleId == null){
                               atTheTop = true;
                               break;
                           } else {
                               parentsParentList.Add(roleUsersMap.get(r2.ParentRoleId));
                               managerRoleIds.add(r2.ParentRoleId);
                           }
                        }
                        immediateParentList.addAll(parentsParentList);
                        childParentRoleMap.put(r.Id, immediateParentList);
                    }
                }
                break;
            }
            return managerRoleIds.contains(managerRoleId);
     }
    /* These methods are commented out for future use when no govenor limits exists.
      private static Set<ID> getAllSubRoleIds(Set<ID> roleIds) {

        Set<ID> currentRoleIds = new Set<ID>();

        // get all of the roles underneath the passed roles
        for(UserRole userRole :[select Id from UserRole where ParentRoleId
          IN :roleIds AND ParentRoleID != null])
        currentRoleIds.add(userRole.Id);

        // go fetch some more rolls!
        if(currentRoleIds.size() > 0)
          currentRoleIds.addAll(getAllSubRoleIds(currentRoleIds));

        return currentRoleIds;

      }

       public static Set<ID> getRoleSubordinateUsers(Id userId) {

        // get requested user's role
        Id roleId = [select UserRoleId from User where Id = :userId].UserRoleId;
        // get all of the roles underneath the user
        Set<Id> allSubRoleIds = getAllSubRoleIds(new Set<ID>{roleId});
        // get all of the ids for the users in those roles
        Map<Id,User> users = new Map<Id, User>([Select Id, Name From User where
          UserRoleId IN :allSubRoleIds]);
        // return the ids as a set so you can do what you want with them
        return users.keySet();

      }
    */
}