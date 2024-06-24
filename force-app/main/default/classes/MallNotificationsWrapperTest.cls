@IsTest
private with sharing class MallNotificationsWrapperTest {
    @IsTest
    public static void testNotificationWrapper() {
        Test.startTest();
        MallNotificationsWrapper response = new MallNotificationsWrapper();
        MallNotificationsWrapper responseCopy = MallNotificationsWrapper.parse(System.JSON.serialize(response));

        Assert.isTrue(response != NULL, 'Response not null');
        Assert.isTrue(responseCopy != NULL, 'Response copy not null');
        Test.stopTest();
    }
}