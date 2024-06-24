/**
*
* @CreatedBy Michal Pesko mpesko@deloittece.com
* @CreatedDate August 2021
* @description Apex Controller for PowerBi_RecordReport
*/
public with sharing class PowerBI_ReportController {

    /**
    * Aura Enabled Method for getting Power Bi Report Id by Record Salesforce Id
    * @param reportId - Salesforce record Id
    * @return Power BI Report Id
    */
    @AuraEnabled
    public static String getPowerBiReportId(Id reportId) {
        Client_Industry_MI__c report = [
                SELECT Id, Power_BI_Id__c
                FROM Client_Industry_MI__c
                WHERE Id = :reportId
        ];
        return report.Power_BI_Id__c;
    }
}