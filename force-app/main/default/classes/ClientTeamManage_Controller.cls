/**
 * Provide logic for ClientTeamManage lightning component
 * @author Tomasz Sobota
 * @version 0
 *
 */
public without sharing class ClientTeamManage_Controller {

    @AuraEnabled
    public static List<String> getCoreRoles() {
        List <String> coreRolesValues = new List<String>();
        for (CST_Core_Roles__c coreRole : [SELECT Value__c FROM CST_Core_Roles__c]) {
            coreRolesValues.add(coreRole.Value__c);
        }
        return coreRolesValues;
    }
    @AuraEnabled
    public static Map<String, String> getUserDivisionAndCountry(String userId) {
        List<User> users = [
                SELECT
                        Name,
                        User_Country__c,
                        User_Division__c
                FROM User
                WHERE
                        Id = :userId
        ];
        Map<String, String> mapToReturn = new Map<String, String>();
        if (!users.isEmpty()) {
            mapToReturn.put('User_Country__c', users[0].User_Country__c);
            mapToReturn.put('User_Division__c', users[0].User_Division__c);
            mapToReturn.put('Name', users[0].Name);
        }
        return mapToReturn;
    }
    @AuraEnabled
    public static Account getAccount(Id recordId) {
        return [
                SELECT
                        Name
                FROM Account
                WHERE Id = :recordId
        ];
    }
    @AuraEnabled
    public static Boolean isUserActive(String userId) {
        List <String> notRestrictedDivisions = getNotRestrictedDivisions();
        Integer numberOfActiveUsers = [
                SELECT
                      COUNT()
                FROM User
                WHERE
                    Id = :userId
                AND
                    IsActive = true
                AND
                    User_Division__c IN :notRestrictedDivisions
        ];
        return numberOfActiveUsers > 0;
    }
    @AuraEnabled
    public static List <String> getNotRestrictedDivisions () {
        List <SB_Parameters__c> notRestrictedDivisionsSettings = [
        SELECT
                Value__c
        FROM SB_Parameters__c
        WHERE
                Name = 'Not_Restricted_Divisions'
        ];
        List<String> notRestrictedDivisions = new List<String>();
        if (!notRestrictedDivisionsSettings.isEmpty()) {
            notRestrictedDivisions = notRestrictedDivisionsSettings[0].Value__c.split('\\;');
        }
        return notRestrictedDivisions;
    }
    @AuraEnabled
    public static List <String> getTpsCoreRoles() {
        List <SB_Parameters__c> tpsCoreRolesSettings = [
                SELECT
                        Value__c
                FROM SB_Parameters__c
                WHERE
                        Name = 'TPS_Core_Roles'
        ];
        List<String> tpsCoreRoles = new List<String>();
        if (!tpsCoreRolesSettings.isEmpty()) {
            tpsCoreRoles = tpsCoreRolesSettings[0].Value__c.split('\\;');
        }
        return tpsCoreRoles;
    }

    @AuraEnabled
    public static String getCurrentCcName (Id accountId) {
        Account currentAccount = [
                SELECT Owner.Name
                FROM Account
                WHERE id = :accountId
                LIMIT 1
        ];
        return currentAccount.Owner.Name;
    }

    @AuraEnabled
    public static Boolean isCurrentUserCcOrCcbm(Id clientId){
        DMN_ClientTeam.CcCcbmWrapper ccAndCcbm = DMN_ClientTeam.getCcAndCcBmsMap(new Set<Id>{clientId}).get(clientId);
        return ccAndCcbm.cc == UserInfo.getUserId() || ccAndCcbm.ccbm == UserInfo.getUserId();
    }
}