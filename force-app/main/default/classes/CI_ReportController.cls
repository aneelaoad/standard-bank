public with sharing class CI_ReportController {
   @AuraEnabled
    public static CI_ResponseDto getReportIdAction(String reportName){
        List<Report> reportList = [SELECT Id,DeveloperName FROM Report WHERE DeveloperName = :reportName];
        
        if(reportList.size() == 0)
            return new CI_ResponseDto(false, 'Report not found');
        
        String reportId = (String)reportList.get(0).get('Id');
        return new CI_ResponseDto(reportId);
    }
}