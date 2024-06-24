/**
 * @description Mock class for AKILI Insights
 *
 * @author Vipeen Sarode
 * @date October 2021
 * 
 * @LastModified Oct 2023
 * @author Mokkala Chandrasekhar (chandrasekhar.mokkala@standardbank.co.za)
 * @UserStory SFP-28741
 * @LastModifiedReason Added description param for the method
 */
@isTest
public with sharing class AKI_GetInsights_TEST {
    /**
     *@description Test method to cover get insight  api
    */
    @isTest
    public static void getInsightsDataTest() {
        test.startTest();
        test.setMock(HTTPCalloutMock.class, new AKI_InsightsMock());
        AKI_ScheduleGetInsights sh = new AKI_ScheduleGetInsights();
        String cronStr = '0 0 23 * * ?'; 
        system.schedule('Test Get Insight schedule', cronStr, sh); 
        // Verify that the class is scheduled
        Integer cronJobGetInsights = [SELECT COUNT() FROM CronTrigger WHERE CronJobDetail.Name = 'Test Get Insight schedule'];
        Assert.areEqual(1, cronJobGetInsights, 'Job scheduled successfully');
        test.stopTest();
    }
    
}