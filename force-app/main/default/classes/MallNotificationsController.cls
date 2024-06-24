/**
 * 
 * @description Notification Controller Class
 * @author Maham Hassan
 * @since 
 */
public with sharing class MallNotificationsController {
    private static final String BCB_PLATFORM_INSIGHT_NOTIFICATION = 'BCB_Platform_Insight_Notification';
    private static final String BCB_PLATFORM_DEALS_AND_PROMOTIONS = 'BCB_Platform_Deals_And_Promotions';
    private static final String BCB_PLATFORM_APPROVAL_NOTIFICATION = 'BCB_Platform_Approval_Notification';
    private static final String BCB_PLATFORM_ALERTS_NOTIFICATION = 'BCB_Platform_Alerts_Notification';
    private static final String BCB_PLATFORM_WHATS_NEW_NOTIFICATION = 'BCB_Platform_Whats_New_Notification';
    private static final String BCB_PLATFORM_SFDC_API_VERSION = System.Label.BCB_PLATFORM_SFDC_API_VERSION;

    /**
     * 
     * @description Mall get Notification 
     * @return  `List<DenormalizedNotification>`
     * @exception CalloutException
     */
    @AuraEnabled
    public static List <DenormalizedNotification> getNotifications() {
        try {
            List <DenormalizedNotification> notifications = new List <DenormalizedNotification> ();
            List <DenormalizedNotification> finalNotifications = new List <DenormalizedNotification> ();
            if (!Auth.CommunitiesUtil.isGuestUser()) {
                String restAPIURL = Url.getOrgDomainUrl().toExternalForm() + '/services/data/' + BCB_PLATFORM_SFDC_API_VERSION + '/connect/notifications';
                HttpRequest httpRequest = new HttpRequest();
                httpRequest.setMethod(CMN_API_HttpBase.HTTP_VERB_GET);
                httpRequest.setHeader(CMN_API_HttpBase.HTTP_HEADER_AUTHORIZATION, CMN_API_HttpBase.HTTP_AUTH_TOKEN_BEARER + UserInfo.getSessionId());
                httpRequest.setHeader(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_JSON);
                httpRequest.setEndpoint(restAPIURL);
                Http http = new Http();
                HttpResponse httpResponse = http.send(httpRequest);
                if (httpResponse.getStatusCode() == 200) {
                    Map <String, List <DenormalizedNotification>> mapNotifications = (Map <String, List <DenormalizedNotification>> ) JSON.deserialize(httpResponse.getBody(), Map <String, List <DenormalizedNotification>> .class);
                    notifications = mapNotifications.get('notifications');
                } else {
                    throw new CalloutException(httpResponse.getBody());
                }
                if (!notifications.isEmpty()) {
                    finalNotifications = createFinalNotifications(notifications);
                }
            }
            return finalNotifications;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallNotificationsController.getNotifications', e);
        }
    }
    /**
     * @description createFinalNotifications
     * @param notifications
     * @return List<DenormalizedNotification>
     */
    public static List <DenormalizedNotification> createFinalNotifications(List <DenormalizedNotification> notifications) {
        try {
            String mallBaseUrl = (Mall_SSO_Configuration__mdt.getInstance('Mall_SSO_Configuration')).Mall_Home_Page__c;
            List<CustomNotificationType> customNotificationTypes = new List<CustomNotificationType>();
            customNotificationTypes = SEL_CustomNotificationTypes.newInstance().selectByDeveloperName(new Set<String> {
                BCB_PLATFORM_INSIGHT_NOTIFICATION, BCB_PLATFORM_WHATS_NEW_NOTIFICATION, BCB_PLATFORM_DEALS_AND_PROMOTIONS,
                BCB_PLATFORM_APPROVAL_NOTIFICATION, BCB_PLATFORM_ALERTS_NOTIFICATION
            });

            Map <Id, CustomNotificationType> idVsNotificationType = new Map <Id, CustomNotificationType> ();
            for (CustomNotificationType notificationType: customNotificationTypes) {
                idVsNotificationType.put(notificationType.Id, notificationType);
            }

            List <DenormalizedNotification> finalNotifications = new List <DenormalizedNotification> ();
            for (DenormalizedNotification notificationRecord: notifications) {
                if (idVsNotificationType.get(notificationRecord.type).DeveloperName == BCB_PLATFORM_INSIGHT_NOTIFICATION) {
                    notificationRecord.messageTitle = System.Label.MALL_WHAT_NEW_EMAIL_INSIGHT_SUBTITILE + ' ' + notificationRecord.messageTitle;
                    finalNotifications.add(notificationRecord);
                } else if (idVsNotificationType.get(notificationRecord.type).DeveloperName == BCB_PLATFORM_DEALS_AND_PROMOTIONS) {
                    notificationRecord.messageTitle = System.Label.MALL_WHAT_NEW_EMAIL_PROMOTION_SUBTITILE + ' ' + notificationRecord.messageTitle;
                    finalNotifications.add(notificationRecord);
                } else if (idVsNotificationType.get(notificationRecord.type).DeveloperName == BCB_PLATFORM_WHATS_NEW_NOTIFICATION) {
                    if (notificationRecord.target != null && ((Id)(notificationRecord.target)).getSObjectType().getDescribe().getName() == 'Provider__c') {
                        notificationRecord.url = mallBaseUrl;
                    } else {
                        notificationRecord.url = mallBaseUrl;
                    }
                    notificationRecord.messageTitle = notificationRecord.messageTitle + ' : ' + notificationRecord.messageBody;
                    finalNotifications.add(notificationRecord);
                } else if (idVsNotificationType.get(notificationRecord.type).DeveloperName == BCB_PLATFORM_APPROVAL_NOTIFICATION) {
                    notificationRecord.url = mallBaseUrl;
                    notificationRecord.messageTitle = notificationRecord.messageTitle;
                    notificationRecord.messageBody = notificationRecord.messageBody;
                    finalNotifications.add(notificationRecord);
                } else if (idVsNotificationType.get(notificationRecord.type).DeveloperName == BCB_PLATFORM_ALERTS_NOTIFICATION) {
                    notificationRecord.url = mallBaseUrl;
                    notificationRecord.messageTitle = notificationRecord.messageTitle + notificationRecord.messageBody;
                    finalNotifications.add(notificationRecord);
                }
            }
            return finalNotifications;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallNotificationsController.createFinalNotifications', e);
        }
    }

    /**
     * @description updateNotifications
     * @param jsonBody
     * @return Boolean
     */
    @AuraEnabled
    public static Boolean updateNotifications(String jsonBody) {
        try {
            Boolean returnVal;
            if (!Auth.CommunitiesUtil.isGuestUser()) {
                String restAPIURL = Url.getOrgDomainUrl().toExternalForm() + '/services/data/' + BCB_PLATFORM_SFDC_API_VERSION + '/connect/notifications';
                HttpRequest httpRequest = new HttpRequest();
                httpRequest.setMethod('PATCH');
                httpRequest.setHeader(CMN_API_HttpBase.HTTP_HEADER_AUTHORIZATION, CMN_API_HttpBase.HTTP_AUTH_TOKEN_BEARER + UserInfo.getSessionId());
                httpRequest.setHeader(CMN_API_HttpBase.HTTP_CONTENT_TYPE, CMN_API_HttpBase.HTTP_ENCODING_JSON);
                httpRequest.setEndpoint(restAPIURL);
                httpRequest.setBody(jsonBody);
                Http http = new Http();
                HttpResponse httpResponse = http.send(httpRequest);
                if (httpResponse.getStatusCode() == 200) {
                    returnVal = true;
                } else {
                    returnVal = false;
                }
            }
            return returnVal;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallNotificationsController.updateNotificationsToRead', e);
        }
    }
    /**
     * @description DenormalizedNotification
     */
    public class DenormalizedNotification {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public String messageTitle;
        @AuraEnabled
        public String messageBody;
        @AuraEnabled
        public String lastModified;
        @AuraEnabled
        public Boolean read;
        @AuraEnabled
        public Boolean seen;
        @AuraEnabled
        public String url;
        @AuraEnabled
        public String target;
    }
}