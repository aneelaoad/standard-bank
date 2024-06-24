public with sharing class StdBank_Ltn_ReportLinkController {
	
	@AuraEnabled
	public static String getReportId(String developerName){
		if(String.isEmpty(developerName))
			throw new ReportLinkException(Label.No_input_parameter_defined);
		List<Report> reports = [SELECT Id FROM Report
									WHERE DeveloperName = :developerName];
		if(reports.isEmpty())
			throw new ReportLinkException(String.format(Label.No_record_found, new String[]{developerName}));

		return reports[0].Id;
	}

	public class ReportLinkException extends Exception{}

}