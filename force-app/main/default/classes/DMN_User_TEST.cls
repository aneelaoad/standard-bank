/**
 * Test class for DMN_User class
 *
 * @author		Youssef Ibrahim (yibrahim@deloittece.com)
 * @date		December 2020
 */
@IsTest
public  class DMN_User_TEST {

    @IsTest
    static void shouldInsertNotifications() {
        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow;
        User testUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            List<String> fullName = Label.Archived_Clients.split(' ');
            testUser = (User) new BLD_USER(uow)
                    .userName('userNotification@test.com')
                    .useCib()
                    .division('Transactional Products and Services')
                    .syncContact()
                    .getRecord();
            uow.commitWork();
        }

        Integer beforeNotifcationsSize = [SELECT Id FROM Notification__c].size();
        Set<Id> usersIds = new Set<Id>{testUser.Id};
        Test.startTest();
        DMN_User.handleWelcomeNotificationInsert(usersIds);
        Test.stopTest();
        Integer afterNotifcationsSize = [SELECT Id FROM Notification__c].size();
        System.assertEquals(beforeNotifcationsSize+usersIds.size(), afterNotifcationsSize);
    }

}