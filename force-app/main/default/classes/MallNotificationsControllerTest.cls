/**
 * @description MallNotificationsControllerTest
 * @author Maham Hassan
 * @since
 */
@isTest
public with sharing class MallNotificationsControllerTest {
    private static final String BCB_PLATFORM_INSIGHT_NOTIFICATION = 'BCB_Platform_Insight_Notification';
    private static final String BCB_PLATFORM_DEALS_AND_PROMOTIONS = 'BCB_Platform_Deals_And_Promotions';
    private static final String BCB_PLATFORM_APPROVAL_NOTIFICATION = 'BCB_Platform_Approval_Notification';
    private static final String BCB_PLATFORM_ALERTS_NOTIFICATION = 'BCB_Platform_Alerts_Notification';
    private static final String BCB_PLATFORM_WHATS_NEW_NOTIFICATION = 'BCB_Platform_Whats_New_Notification';


    @IsTest
    static void getNotificationsTest(){
        Test.setMock(HttpCalloutMock.class, new NotificationsMock());
        Test.startTest();
        List<MallNotificationsController.DenormalizedNotification> denormalizedNotificationList = MallNotificationsController.getNotifications();
        if(denormalizedNotificationList == NULL) {
            Assert.isTrue(denormalizedNotificationList == NULL, 'expected outcome null');
        } else if(denormalizedNotificationList != NULL) {
            Assert.isTrue(denormalizedNotificationList.size() != 0, 'expected outcome not 0'); 
        }
        Test.stopTest();
    }
	
    @isTest
    static void createFinalNotificationsTest(){
        Account account = new Account();
        account.Name = 'Test Account';
        insert account;
        
        Promotion__c promotion = new Promotion__c();
        promotion.Name = 'Test Promotion';
        insert promotion;
        List<MallNotificationsController.DenormalizedNotification> denormalizedNotifications = new  List<MallNotificationsController.DenormalizedNotification>();
        List<CustomNotificationType> customNotificationTypes = new List<CustomNotificationType>();
        customNotificationTypes = SEL_CustomNotificationTypes.newInstance().selectByDeveloperName(new Set<String> {
            BCB_PLATFORM_INSIGHT_NOTIFICATION, BCB_PLATFORM_WHATS_NEW_NOTIFICATION, BCB_PLATFORM_DEALS_AND_PROMOTIONS,
            BCB_PLATFORM_APPROVAL_NOTIFICATION, BCB_PLATFORM_ALERTS_NOTIFICATION
        });
        Integer count = 1234;
        for(CustomNotificationType notificationType : customNotificationTypes){
            MallNotificationsController.DenormalizedNotification denNotification = new MallNotificationsController.DenormalizedNotification();
            denNotification.id = String.valueOf(count);
            denNotification.type = notificationType.Id;
            denNotification.messageTitle = 'Message Title';
            denNotification.messageBody = 'Message Body';
            denNotification.target = notificationType.DeveloperName == 'Deals_And_Promotions' ? promotion.id: account.id;
            count+=1000;
            
            denormalizedNotifications.add(denNotification);
        }
      List<MallNotificationsController.DenormalizedNotification> result =  MallNotificationsController.createFinalNotifications(denormalizedNotifications);
      Assert.isTrue(result.size() > 0, 'Expected outcome') ; 
    }
    
    @IsTest
    static void getUpdateNotificationTest(){
        Test.setMock(HttpCalloutMock.class, new NotificationsMock());
        Test.startTest();
        Boolean returnVal = MallNotificationsController.updateNotifications('{"notifications" : [{"id":"1234", "type":"order", "messageTitle":"Message Title", "messageBody":"Message Body"}]}');
        Assert.isTrue(returnVal==true, 'message');
        Test.stopTest();
        
    }
/**
 * @description NotificationsMock
 */
    public class NotificationsMock implements HttpCalloutMock  {
    /**
    * @description respond
    * @param req HttpRequest
    * @return HttpResponse
    */
        public HttpResponse respond(HttpRequest req) {
             Account account = new Account();
       		 account.Name = 'Test Account';
        	insert account;
            List<MallNotificationsController.DenormalizedNotification> denormalizedDonations = new  List<MallNotificationsController.DenormalizedNotification>();
            
            List<CustomNotificationType> customNotificationTypes = new List<CustomNotificationType>();
            customNotificationTypes = SEL_CustomNotificationTypes.newInstance().selectByDeveloperName(new Set<String> {
                BCB_PLATFORM_INSIGHT_NOTIFICATION, BCB_PLATFORM_WHATS_NEW_NOTIFICATION, BCB_PLATFORM_DEALS_AND_PROMOTIONS,
                BCB_PLATFORM_APPROVAL_NOTIFICATION, BCB_PLATFORM_ALERTS_NOTIFICATION
            });         
            Integer count = 1234;
            for(CustomNotificationType notificationType : customNotificationTypes){
                MallNotificationsController.DenormalizedNotification denNotification = new MallNotificationsController.DenormalizedNotification();
                denNotification.id = String.valueOf(count);
                denNotification.type = notificationType.Id;
                denNotification.messageTitle = 'Message Title';
                denNotification.messageBody = 'Message Body';
                denNotification.target = account.id;
                count+=1000;
                denormalizedDonations.add(denNotification);
            }
            Map<String, List<MallNotificationsController.DenormalizedNotification>> mapNotifications = new Map<String, List<MallNotificationsController.DenormalizedNotification>>();
            mapNotifications.put('notifications', denormalizedDonations);

            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(mapNotifications));
            res.setStatusCode(200);
            return res;
        }
    }
}