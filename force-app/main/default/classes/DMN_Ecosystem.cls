/**
    @ Last Modified By  : Bartosz Sliwinski
    @ Last Modified On  : Oct 17, 2017
    @ Modification Description : Modified validateDuplicates(). US-2424 - CommB: Duplicate message when creating ecosystem
 */
public class DMN_Ecosystem {

	public static final String 	PARTNER 				= 'Partner',
								SUBSIDIARY   			= 'Subsidiary',
								SHAREHOLDER_DIRECTOR	= 'Shareholder / Director',
								DEBTOR_CREDITOR			= 'Debtor / Creditor',
								CLIENT_DISTRIBUTOR 		= 'Client / Distributor',
								EMPLOYEE 				= 'Employee';

	public static void validateDuplicates(Ecosystem__c[] ecosystems) {
		Map<String, Ecosystem__c> relationshipGN2Ecosystem = new Map<String, Ecosystem__c>();
		for (Ecosystem__c eco : ecosystems) {
			if (relationshipGN2Ecosystem.containsKey(eco.Relationship_Group_Number__c)) {
				eco.addError(Label.Duplicate_Relationship_Group_Number_on_Ecosystem);
			}
			else {
				relationshipGN2Ecosystem.put(eco.Relationship_Group_Number__c, eco);
			}
		}

		if (!relationshipGN2Ecosystem.isEmpty()) {

			for (Ecosystem__c eco : [SELECT Relationship_Group_Number__c
									FROM Ecosystem__c
									WHERE Relationship_Group_Number__c in :relationshipGN2Ecosystem.keySet()
									]) {
				Ecosystem__c triggerEco = relationshipGN2Ecosystem.get(eco.Relationship_Group_Number__c);
				if (eco.Id != triggerEco.Id) {
					triggerEco.addError(Label.Duplicate_Relationship_Group_Number_on_Ecosystem);
				}
			}

		}
		
	}


}