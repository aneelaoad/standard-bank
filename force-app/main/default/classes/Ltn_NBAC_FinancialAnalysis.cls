public class Ltn_NBAC_FinancialAnalysis {
	@AuraEnabled
	public static DTO getInitialData(Id contextId, String indicatorDevName, String metricDevName) {
		DTO response = new DTO();
		response.indicatorRT = UTL_RecordType.getRecordTypeId(NBAC_Financial_Analysis__c.getSobjectType().getDescribe().getName(), indicatorDevName);
		response.metricRT = UTL_RecordType.getRecordTypeId(NBAC_Financial_Analysis__c.getSobjectType().getDescribe().getName(), metricDevName);

		return response;
	}

	@AuraEnabled
	public static Ltn_RelatedList.DTO getData(Id contextRecordId, String relationName, String parrentField, String fieldSetName, String filters, String defaults) {
		return Ltn_RelatedList.getData(contextRecordId, relationName, parrentField, fieldSetName, filters, defaults);
	}

	@AuraEnabled
	public static void saveRecords(List<SObject> record, Map<String, String> defaults) {
		Ltn_RelatedList.saveRecords(record, defaults);
	}

	@AuraEnabled
	public static void removeRecord(SObject record) {
		if (record != null) {
			if (record.ID == null) {
				throw new LTN_NBAC_FinancialAnalysisException('No Id provided for record');
			}
			delete record;
		}
	}

	@AuraEnabled
	public static List<Ltn_RelatedList.Field> getColumns(String fields) {
		return Ltn_RelatedList.fieldsfromList(fields.split(','), NBAC_Financial_Analysis__c.sobjectType);
	}

	@AuraEnabled
	public static NBAC_Financial_Analysis__c getMock(String recordId, String fields) {
		NBAC_Financial_Analysis__c mockRecord = new NBAC_Financial_Analysis__c();
		List<Ltn_RelatedList.Field> fieldsl = Ltn_RelatedList.fieldsfromList(fields.split(','), NBAC_Financial_Analysis__c.sobjectType);
		List<String> queryFields = new List<String> ();
		for (Ltn_RelatedList.Field f : fieldsl) {
			queryFields.add(f.apiName);
		}
		String rt = DMN_NBACFinancialAnalysis.RT_METRIC;
		String recId = recordId;
		System.debug(recId);
		List<NBAC_Financial_Analysis__c> records = Database.query(String.format('SELECT Id, {0} FROM NBAC_Financial_Analysis__c WHERE RecordType.DeveloperName = :rt AND Business_Assessment__c = :recId', new List<String> { String.join(queryFields, ', ') }));
		if (!records.isEmpty()) {
			for (Ltn_RelatedList.Field f : fieldsl) {
				mockRecord.put(f.apiName, records[0].get(f.apiName));
			}
		}
		return mockRecord;
	}

	public class DTO {
		@AuraEnabled
		public String metricRT;
		@AuraEnabled
		public String indicatorRT;
	}
	public class LTN_NBAC_FinancialAnalysisException extends Exception { }
}