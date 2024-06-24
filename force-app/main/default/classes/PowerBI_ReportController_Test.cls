/**
 * Created by mpesko on 8/5/2021.
 */

@IsTest
public with sharing class PowerBI_ReportController_Test {

    @IsTest
    public static void shouldGetBiReportId(){
        Client_Industry_MI__c biReport = new Client_Industry_MI__c(Name = 'Test Report', Power_BI_Id__c = '123456');
        insert biReport;
        Test.startTest();
            String biReportId = PowerBI_ReportController.getPowerBiReportId(biReport.Id);
        Test.stopTest();

        System.assertEquals(biReport.Power_BI_Id__c, biReportId);
    }
}