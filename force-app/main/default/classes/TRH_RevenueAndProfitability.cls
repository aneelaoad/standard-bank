/*****************************************************************************************************\
    @ Func Area     : Revenue and Profitability, Ecosystem
    @ Author        : Marko Dvečko
    @ Date          : 29/03/2017
    @ Test File     : RevenueAndProfitabilityTrigger_Test.cls
    @ Specification :

    We need to create trigger that will:
        - Create ecosystem with group number if it doesn't exists
        - Create or update ecosystem entity or ecosystem individual record if needed
        - Update BPID value on related account or contact

******************************************************************************************************/

public class TRH_RevenueAndProfitability extends ABS_TriggerHandlerBase {
    static Map<String, Schema.RecordTypeInfo> mapEcosystemEntityRecordTypes = Ecosystem_Entity__c.SObjectType.getDescribe().getRecordTypeInfosByDeveloperName();
    static final String ENTITY_RT = mapEcosystemEntityRecordTypes.get('Ecosystem_Entity').getRecordTypeId();
    static final String INDIVIDUAL_RT = mapEcosystemEntityRecordTypes.get('Ecosystem_Individual_Entity').getRecordTypeId();

    private Revenue_and_Profitability__c[] records {
        get { return (Revenue_and_Profitability__c[])Trigger.new; }
    }

    private Revenue_and_Profitability__c[] oldRecords {
        get { return (Revenue_and_Profitability__c[])Trigger.old; }
    }

    public override void handleAfterInsert() {
        propagateBPIDAndGropNubmer();
        createEcosystemConnections();
    }

    public override void handleAfterUpdate() {
        propagateBPIDAndGropNubmer();
        createEcosystemConnections();
    }

    public override void handleAfterDelete() {
    }

    public override void handleAfterUndelete() {
        propagateBPIDAndGropNubmer();
        createEcosystemConnections();
    }

    // accountBPID = [accountId -> BPID]
    // contactBPID = [contactId -> BPID]
    // accountIds = DOMAIN accountBPID
    // contactIds = DOMAIN contactBPID
    // accountsForUpdate = [Int -> Account]
    // contactsForUpdate = [Int -> Contact]

    // Logic
    // /\ \/ account.BPID /= accountBPID[account.Id]
    //    \/ account.GM /= accountGN[account.Id]
    // /\ account' = account EXCEPT !BPID = accountBPID[account.Id]
    // /\ accountsForUpdate' = accountsForUpdate EXCEPT !last = account
    private void propagateBPIDAndGropNubmer() {
        Map<Id, String> accountBPID = new Map<Id, String>();
        Map<Id, String> accountGN = new Map<Id, String>();
        Map<Id, String> contactBPID = new Map<Id, String>();
        Map<Id, String> contactGN = new Map<Id, String>();
        Account[] accountsForUpdate = new List<Account>();
        Contact[] contactsForUpdate = new List<Contact>();
        for (Revenue_and_Profitability__c rp : records) {
            if (rp.Client_Name__c != null) {
                accountBPID.put(rp.Client_Name__c, rp.BPID__c);
                accountGN.put(rp.Client_Name__c, rp.Relationship_Group_Number__c);
            }
            if (rp.Person__c != null) {
                contactBPID.put(rp.Person__c, rp.BPID__c);
                contactGN.put(rp.Person__c, rp.Relationship_Group_Number__c);
            }
        }
		if(!accountBPID.isEmpty()){
			for (Account acc : [ SELECT Id, BPID__c FROM Account WHERE Id IN :accountBPID.keySet() ]) {
				String bpid = accountBPID.get(acc.Id);
				if (String.isNotBlank(bpid) && acc.BPID__c != bpid) {
					acc.BPID__c = bpid;
					accountsForUpdate.add(acc);
				}
			}
		}

		if(!contactBPID.isEmpty()){
			for (Contact con : [ SELECT Id, BPID__c, Relationship_Group_Number__c FROM Contact WHERE Id IN :contactBPID.keySet() ]) {
				String bpid = contactBPID.get(con.Id);
				String groupNumber = contactGN.get(con.Id);
				if (con.BPID__c != bpid || con.Relationship_Group_Number__c != groupNumber) {
					con.BPID__c = bpid;
					con.Relationship_Group_Number__c = groupNumber;
					contactsForUpdate.add(con);
				}
			}
		}
        if (!accountsForUpdate.isEmpty()) {
            update accountsForUpdate;
        }

        if (!contactsForUpdate.isEmpty()) {
            update contactsForUpdate;
        }
    }

    //
    // groupNumbers = {GN}
    // accountIds = {accountId}
    // contactIds = {contactId}
    // ecosystemMap = [GN -> id]
    // ecosystemsForUpsert
    // ecoEntitiesExisting = {(groupNumber, accountId)}
    // ecoEntitiesForInsert = [ecoEntity]
    private void createEcosystemConnections() {
        Set<String> groupNumbers = new Set<String>();
        Set<String> accountIds = new Set<String>();
        Set<String> contactIds = new Set<String>();
        Map<String, Id> ecosystemMap = new Map<String, Id>();
        Set<String> ecoEntitiesExisting = new Set<String>();
        Ecosystem__c[] ecosystemsForUpsert = new List<Ecosystem__c>();
        Ecosystem_Entity__c[] ecoEntitiesForInsert = new List<Ecosystem_Entity__c>();

        for (Revenue_and_Profitability__c rp : records) {
            if (rp.Relationship_Group_Number__c != null) {
                groupNumbers.add(rp.Relationship_Group_Number__c);
            }
            if (rp.Client_Name__c != null) {
                accountIds.add(rp.Client_Name__c);
            }
            if (rp.Person__c != null) {
                contactIds.add(rp.Person__c);
            }
        }
		if(!groupNumbers.isEmpty()){
			for (String groupNumber : groupNumbers) {
				ecosystemsForUpsert.add(new Ecosystem__c(Relationship_Group_Number__c = groupNumber));
			}
			Database.upsert(ecosystemsForUpsert, Ecosystem__c.Relationship_Group_Number__c, true);
		
			for (Ecosystem__c eco : [ SELECT Id, Relationship_Group_Number__c 
									  FROM Ecosystem__c 
									  WHERE Relationship_Group_Number__c IN :groupNumbers ]) {
				ecosystemMap.put(eco.Relationship_Group_Number__c, eco.Id);
			}

			for (Ecosystem_Entity__c ecoEntity : [ SELECT Entity__c, Individual_Entity__c, Ecosystem__r.Relationship_Group_Number__c 
												   FROM Ecosystem_Entity__c
												   WHERE (Entity__c IN :accountIds
														  OR Individual_Entity__c IN :contactIds)
												   AND Ecosystem__r.Relationship_Group_Number__c IN :groupNumbers ]) {
				String identifier = ecoEntity.Individual_Entity__c != null 
					? ecoEntity.Individual_Entity__c
					: ecoEntity.Entity__c;
				ecoEntitiesExisting.add(ecoEntity.Ecosystem__r.Relationship_Group_Number__c + identifier);
			}
		}
        for (Revenue_and_Profitability__c rp : records) {
            String groupNumber = rp.Relationship_Group_Number__c;
            String identifier = rp.Person__c != null
                ? rp.Person__c
                : rp.Client_Name__c;
            if (groupNumber != null && identifier != null) {
                if (!ecoEntitiesExisting.contains(groupNumber + identifier)) {
                    if (rp.Person__c != null) {
                        Ecosystem_Entity__c ecoEntity = new Ecosystem_Entity__c(
                            Individual_Entity__c = rp.Person__c,
                            Ecosystem__c = ecosystemMap.get(groupNumber),
                            RecordTypeId = INDIVIDUAL_RT);
                        ecoEntitiesForInsert.add(ecoEntity);
                    }
                    else {
                        Ecosystem_Entity__c ecoEntity = new Ecosystem_Entity__c(
                            Entity__c = rp.Client_Name__c,
                            Ecosystem__c = ecosystemMap.get(groupNumber),
                            RecordTypeId = ENTITY_RT);
                        ecoEntitiesForInsert.add(ecoEntity);
                    }
                }
            }
        }

        if (!ecoEntitiesForInsert.isEmpty()) {
            insert ecoEntitiesForInsert;
        }
    }
}