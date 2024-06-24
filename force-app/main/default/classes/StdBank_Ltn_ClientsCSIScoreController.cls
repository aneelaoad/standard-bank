public with sharing class StdBank_Ltn_ClientsCSIScoreController {
	
	@AuraEnabled
	public static Map<String, Decimal> getCSIScore(Id clientId){

		Map<String, Decimal> name2CSIvalues = StdBank_Ltn_ClientsStatisticsController.getClientsCSIScoreValue(clientId);

		return name2CSIvalues;
	}

	@AuraEnabled
	public static String getReportId(){

		SB_Parameters__c sbParam = SB_Parameters__c.getValues('Ltn_Cmp_ClientsCsiScore_ReportId');

		return sbParam==null?'':sbParam.Value__c;
	}
}