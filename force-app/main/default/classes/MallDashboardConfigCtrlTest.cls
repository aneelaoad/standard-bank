@isTest
private class MallDashboardConfigCtrlTest{

    @IsTest
    private static void getConfiguredDashboardWidgetsTest(){
        Test.startTest();
        List<Mall_Dashboard_Configuration__mdt> widgets = MallDashboardConfigCtrl.getConfiguredDashboardWidgets();
        Assert.areNotEqual(widgets, null, 'widgets should not be null');
        Test.stopTest();
    }

    @IsTest
    private static void getSavedDashboardWidgetConfigurationsTest(){
        Test.startTest();
        List<Mall_Dashboard_Widget__c> widgets = MallDashboardConfigCtrl.getSavedDashboardWidgetConfigurations();
        Assert.areEqual(widgets.size(), 0, 'widgets should be null');
        Test.stopTest();
    }
	
    @IsTest
    private static void saveDashboardWidgetConfigurationsTest(){
        String userId = userInfo.getUserId();
        List<Mall_Dashboard_Widget__c> widgets = new List<Mall_Dashboard_Widget__c>();
        Mall_Dashboard_Widget__c widget1 = new Mall_Dashboard_Widget__c();
        widget1.Name = 'Weather';
        widget1.Position__c = 1;
        widget1.User__c = userId;
        insert widget1;

        Mall_Dashboard_Widget__c widget2 = new Mall_Dashboard_Widget__c();
        widget2.Name = 'LoadShedding';
        widget2.Position__c = 1;
        widget2.User__c = userId;

        widgets.add(widget1);
        widgets.add(widget2);

        Test.startTest();
        try{
            MallDashboardConfigCtrl.saveDashboardWidgetConfigurations(widgets);
            List<Mall_Dashboard_Widget__c> savedWidgets= MallDashboardConfigCtrl.getSavedDashboardWidgetConfigurations();
            Assert.areEqual(2, savedWidgets.size(), 'widgets count should be 2');
            MallDashboardConfigCtrl.saveDashboardWidgetConfigurations(new List<Mall_Dashboard_Widget__c>{widget1});
            savedWidgets= MallDashboardConfigCtrl.getSavedDashboardWidgetConfigurations();
            Assert.areEqual(1, savedWidgets.size(),  'widgets count should be 1');
            MallDashboardConfigCtrl.saveDashboardWidgetConfigurations(NULL);

        }catch(Exception e) {
            AuraHandledException aueaEx = MallExceptionUtil.throwAuraException('saveDashboardWidgetConfigurations',e);
            Assert.isTrue(aueaEx != NULL, 'error expected');
        }
        Test.stopTest();
    }
}