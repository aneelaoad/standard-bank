@isTest
public class CI_ReportControllerTest {
    
    @isTest(SeeAllData='true')
    static void getReportIdActionTest() {
        CI_ResponseDto resp = CI_ReportController.getReportIdAction('test no report');
        System.assertEquals(false, resp.IsSuccess);

        List<Report> report = [SELECT Id, DeveloperName FROM Report LIMIT 1];
        if(!report.IsEmpty()){
            resp = CI_ReportController.getReportIdAction(report[0].DeveloperName);
            System.assertEquals(resp.Data, report[0].Id);
        }
    }
}