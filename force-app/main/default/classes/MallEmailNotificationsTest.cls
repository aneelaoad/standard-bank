@IsTest
private with sharing class MallEmailNotificationsTest {
    @IsTest
    private static void testSendNotifications() {
        Test.startTest();
        MallNotificationsWrapper notification = new MallNotificationsWrapper();
        notification.batchType = 'BCB_Platform_Whats_New_Notification';
        notification.userIds = new Set<String>{UserInfo.getUserId()};
        notification.notificationTitle = System.Label.MALL_WHAT_NEW_EMAIL_DEFAULT_TITILE;
        notification.customNotificationBody = System.Label.MALL_WHAT_NEW_EMAIL_DEFAULT_TITLE_PREFIX + ' ' + System.Label.MALL_WHAT_NEW_EMAIL_OFFERING_TITLE_SUFFIX;
        notification.targetId = UserInfo.getUserId();
        new MallEmailNotifications().sendNotifications(notification);    
        Assert.isTrue(notification.targetId == UserInfo.getUserId(), 'should be equal');    
        Test.stopTest();
    }
}