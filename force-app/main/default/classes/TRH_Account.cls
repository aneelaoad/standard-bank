/**
* We need to keep current functionality with additional.Additional is that we should recalculate sharing rules to ecosystem when owner is changed
* @author Marko Dvečko
* @date 14/04/2017
* @TestFile SVR_Ecosystem_Test.cls
* @Area  Account, Ecosystem
==========================================================
* @author       Maham Hassan
* @date         04/04/2022
* @description  Record Completeness score is getting calculated in before inset and before update
*               
*/
public class TRH_Account extends ABS_TriggerHandlerBase {
    @TestVisible private static Boolean runOnce = false;
    private Account[] records {
        get { return (Account[])Trigger.new; }
    } 

    private Account[] oldRecords {
        get { return (Account[])Trigger.old; }
    }

    private Map<Id, Account> id2OldRecords{
        get{
            if(Trigger.old == null){
                return null;
            }
            return new Map<Id, Account>((Account[])Trigger.old);
        }
    }

    public override void handleBeforeInsert(){
		DMN_Account.setCountryName(records);
		DMN_Account.validateOnInsert(records);
        DMN_Account.adjustData(records, id2OldRecords);
        DMN_Account.populateFieldsBasingOnIndustryCode(records, id2OldRecords);
        DMN_Account.checkCdgError(records);
        DMN_Account.updateCIBServiceTier(records, id2OldRecords);
        DMN_Account.calculateRecordCompleteness(records, null);
    } 

	public override void handleAfterInsert(){
        DMN_Account.createConnections(records, id2OldRecords);
		DMN_Account.removeMarkedClients(records, id2OldRecords); 
		DMN_Account.updateGCRSubSector(records, id2OldRecords); 
		//DMN_Account.recalculateAccess(records, id2OldRecords);
		DMN_ClientTeam.manageOwnersInTeam(records, id2OldRecords);
        SHR_Account.manageSharing(records, id2OldRecords);
	}

	public override void handleBeforeUpdate(){ 
        DMN_Account.adjustData(records, id2OldRecords);
		DMN_Account.populateFieldsBasingOnIndustryCode(records, id2OldRecords);
        DMN_Account.changeFAISReminderStatus(records, id2OldRecords);
        DMN_Account.updateGpIpAndPcc(records);
        DMN_Account.updatePathStepAndRecordType(records);
        DMN_Account.faisStatusFieldValidation(records, id2OldRecords);
        DMN_Account.updateCIBServiceTier(records, id2OldRecords);
        DMN_Account.calculateRecordCompleteness(records, id2OldRecords);
	}

    public override void handleAfterUpdate() { 
        Set<Id> accountIds = new Set<Id>();
        for (Account acc : records) {
            Account old = id2OldRecords.get(acc.Id);
            if (old.OwnerId != acc.OwnerId) {
                accountIds.add(acc.Id);
            }
        }
        //DMN_Account.propagateHierarchy(records, id2OldRecords);
        SRV_Ecosystem.updateSharing(accountIds);
        DMN_Account.propagateHierarchyChange(records, id2OldRecords);
		DMN_Account.createConnections(records, id2OldRecords);
		DMN_Account.removeMarkedClients(records, id2OldRecords);
		DMN_Account.sendEmailstoCC(records, id2OldRecords); 
		DMN_Account.updateGCRSubSector(records, id2OldRecords);
        //DMN_Account.recalculateAccess(records, id2OldRecords);
        if (!runOnce) {             
            DMN_ClientTeam.manageOwnersInTeam(records, id2OldRecords);
            runOnce = true;
        }
        SHR_Account.manageSharing(records, id2OldRecords);
        DMN_Account.cancelFAISReminders(records, id2OldRecords);
        DMN_Account.updateBusinessAssessment(records, id2OldRecords);
        DMN_Account.updateChildrenParentCSTValue(records, id2OldRecords);
        DMN_Account.syncClientSectorToProducts(records, id2OldRecords);
        if(!Test.isRunningTest()){
            DMN_Account.commbClientRGNNotifier(records);
        }

    }

    public override void handleBeforeDelete() {
        DMN_Account.deleteEcosystemEntities(oldRecords);
        AccountTriggerHandler_trgr.deleteClientTeamJunctionObject(id2OldRecords); 
    }

    public override void handleAfterDelete() { 
        SHR_Account.manageSharing(records, id2OldRecords); 
    }
}