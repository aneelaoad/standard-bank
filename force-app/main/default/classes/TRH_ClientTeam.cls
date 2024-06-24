/*****************************************************************************************************\
    @ Func Area     : Client Team, Ecosystem
    @ Author        : Marko Dvečko
    @ Date          : 14/04/2017
    @ Test File     : SVR_ClientTeam.cls
    @ Specification :

    We need to keep current functionality with additional.
    Additional is that we should recalculate sharing rules to ecosystem when client team member is added.
******************************************************************************************************
    @ Last Modified By  : Agnieszka Adrianowska
    @ Last Modified On  : Nov 03, 2017
    @ Modification Description : CC and CCBM email on business assessment object should be updated. 
                                 US-2441 - DM NBAC: Milestone Process - Send Email Notification
******************************************************************************************************
    @ Last Modified By  : Agnieszka Adrianowska
    @ Last Modified On  : Nov 14, 2017
    @ Modification Description : Credit Manager email on business assessment object should be updated. 
                                 US-2441 - DM NBAC: Milestone Process - Send Email Notification
 */

public class TRH_ClientTeam extends ABS_TriggerHandlerBase {
    private Custom_Client_Team__c[] records {
        get { return (Custom_Client_Team__c[])Trigger.new; }
    }

    private Custom_Client_Team__c[] oldRecords {
        get { return (Custom_Client_Team__c[])Trigger.old; }
    }

    private Map<Id, Custom_Client_Team__c> oldMap {
        get { return (Map<Id, Custom_Client_Team__c>)Trigger.oldMap; }
    }

    public override void handleBeforeInsert() {
        Custom_Client_Team__c[] existingTeamMembers = DMN_ClientTeam.fetchExistingTeam(records);

        DMN_ClientTeam.adjustGtbData(records);
        DMN_ClientTeam.populateAccess(records, oldMap);
        DMN_ClientTeam.checkIfUserIsAllowedToEditVisibleToClient(records, new Map<Id, Custom_Client_Team__c>());
        DMN_ClientTeam.populateSortorder(records, existingTeamMembers);
        DMN_ClientTeam.validateUniqueUsers(records, existingTeamMembers);
        DMN_ClientTeam.validateUniqueValuesAndRemove(records, existingTeamMembers);
        DMN_ClientTeam.validateCoreRoles(records);
        DMN_ClientTeam.validateMultipleTransactionSolutionsManager(records);
    }

    public override void handleAfterInsert() {
        DMN_ClientTeam.manageSharing(records, oldMap);
        DMN_ClientTeam.updateBusinessAssessments(records, null);
        DMN_ClientTeam.runGtbValidations(records, oldMap);
        DMN_ClientTeam.propagateCcToClient(records, oldMap);
        DMN_Account.populateManagedByDivision(records, false);
        DMN_ClientTeam.syncTeam(records, oldMap);
        DMN_ClientTeam.syncCoreRolesToClientFields(records, null);

        new insertCTOPfromCustClientTeamClass().insertCTOP_frmCCT(Trigger.new);
    }
    
    public override void handleBeforeUpdate() {
        Custom_Client_Team__c[] existingTeamMembers = DMN_ClientTeam.fetchExistingTeam(records);

        DMN_ClientTeam.adjustGtbData(records);
        DMN_ClientTeam.populateAccess(records, oldMap);
        DMN_ClientTeam.checkIfUserIsAllowedToEditVisibleToClient(records, oldMap);
        DMN_ClientTeam.populateSortorder(records, existingTeamMembers);
        DMN_ClientTeam.validateUniqueUsers(records, existingTeamMembers);
        DMN_ClientTeam.validateUniqueValuesAndRemove(records, existingTeamMembers);
        DMN_ClientTeam.validateCoreRoles(records);
        DMN_ClientTeam.validateMultipleTransactionSolutionsManager(records);
    }

    public override void handleAfterUpdate() {
        DMN_ClientTeam.manageSharing(records, oldMap);
        DMN_ClientTeam.updateBusinessAssessments(records, oldMap);
        DMN_ClientTeam.runGtbValidations(records, oldMap);
        DMN_ClientTeam.propagateCcToClient(records, oldMap);
        DMN_Account.populateManagedByDivision(records, false);
        DMN_Account.propagateTeamChanges(records, oldMap);
        DMN_ClientTeam.syncTeam(records, oldMap);
        DMN_ClientTeam.syncCoreRolesToClientFields(records, oldMap);

    }

    public override void handleBeforeDelete() {
        Custom_Client_Team__c[] existingTeamMembers = DMN_ClientTeam.fetchExistingTeam(oldMap.values());
        DMN_ClientTeam.populateSortorder(new Custom_Client_Team__c[]{} , existingTeamMembers);
        DMN_Account.populateManagedByDivision(oldMap.values(), true);
        DMN_ClientTeam.syncCoreRolesToClientFields(null, oldMap);

        new insertCTOPfromCustClientTeamClass().deleteCTOP_frmCCT(Trigger.old);
    }

    public override void handleAfterDelete() {
        DMN_ClientTeam.manageSharing(records, oldMap);
        DMN_ClientTeam.updateBusinessAssessments(oldRecords, null);
        DMN_ClientTeam.updateOwnerAfterCcRemove(oldMap);
        DMN_ClientTeam.removeExistingMembers(oldMap.values());
    }
}