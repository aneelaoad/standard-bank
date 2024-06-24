@IsTest
private class MallManageNotificationsCtrlTest {
    
    @IsTest
    private static void getNotificationTypesTest(){
        Test.startTest();
        List<Mall_Notification_Management__mdt> notificationmdt = MallManageNotificationsCtrl.getNotificationTypes();
        List<Mall_Notification_Management__mdt> notificationmdt2 =(List<Mall_Notification_Management__mdt>) MallManageNotificationsCtrl.getUserNotificationTypes();
        Assert.areEqual(notificationmdt.size(),notificationmdt2.size(),'some notifications should be configured');
        Test.stopTest();    
    }

    @IsTest
    private static void upsertObjectsTest(){
        Test.startTest();
        List<SObject> result =  MallManageNotificationsCtrl.upsertNotifications(new List<SObject>());
        Assert.areEqual(result.size(),0,'same notifications records');
        Test.stopTest();
    }
}