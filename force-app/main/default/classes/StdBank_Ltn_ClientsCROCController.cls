public without sharing class StdBank_Ltn_ClientsCROCController {
	@AuraEnabled
	public static String getCROC(Id recordId) {
		String croc = 'No Context';
		if (recordId == null) { return croc; }
		List<Client_Capital_and_Revenue__c> acc = [SELECT id, CROC_ZAR__c FROM Client_Capital_and_Revenue__c where Client__C = :recordId];
		if(!acc.isEmpty() && acc[0].CROC_ZAR__c != null){
			croc = String.valueOf(acc[0].CROC_ZAR__c);
		} else{
			croc = '';
		}
		return croc;
	}
}