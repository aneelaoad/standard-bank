public with sharing class StdBank_Ltn_ClientsNoOfMeetingsCtrl {
	public static final String INTERNAL_MEETING = 'Internal';
	public static final String EXTERNAL_MEETING = 'External';

	@AuraEnabled
	public static Integer getNumberOfInternalMeetings(Id clientId){
		Integer noOfMeetings = 0;

		System.debug('getNumberOfInternalMeetings client id: ' + clientId);

		AggregateResult[] aggregatedMeetings = StdBank_Ltn_ClientsStatisticsController.getNumberOfMeetingsThisYear(clientId);
		System.debug('aggregatedMeetings : ' + aggregatedMeetings);
		noOfMeetings = StdBank_Ltn_ClientsStatisticsController.getValuesByMeetingAudience(aggregatedMeetings, INTERNAL_MEETING);
		return noOfMeetings;
	}

	@AuraEnabled
	public static Integer getNumberOfExternalMeetings(Id clientId){
		Integer noOfMeetings = 0;

		System.debug('getNumberOfExternalMeetings client id: ' + clientId);

		AggregateResult[] aggregatedMeetings = StdBank_Ltn_ClientsStatisticsController.getNumberOfMeetingsThisYear(clientId);
		noOfMeetings = StdBank_Ltn_ClientsStatisticsController.getValuesByMeetingAudience(aggregatedMeetings, EXTERNAL_MEETING);
		return noOfMeetings;
	}
}