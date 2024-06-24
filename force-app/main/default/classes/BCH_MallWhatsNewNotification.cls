/**
 * @description : BCH_MallWhatsNewNotification : batch: sends newly created Shops/Products email and in app Notifications to user. 
 * @author: Manasi Londhe
 * @since 
 */
public class BCH_MallWhatsNewNotification implements Database.Batchable <sObject>{

    private static final String MALL_WHATS_NEW_EMAIL_TEMPLATE_NAME = 'BCB_Platform_What_s_New_Notification';

    /**
     * 
     * @description start
     * @param bc Database.BatchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext bc) {
        List <String>mallNotificationUserProfiles = new List <String>{
            System.label.Mall_Experience_User_Profile,
            System.Label.Store_Manager_Profile,
            System.Label.Store_Worker_Profile
        };
        //Get All the active mall experience users
        String query = 'SELECT Id ,Name, Email, Profile.Name From USER ';
        String whereClause = ' WHERE Profile.Name IN (\'' + String.join(mallNotificationUserProfiles, '\',\'') + '\')';
        whereClause += ' AND IsActive = TRUE';
        query = query + whereClause;
        return Database.getQueryLocator(query);
    }

    /**
     * 
     * @description execute
     * @param bc Database.BatchableContext
     * @param users List<User>
     */
    public void execute(Database.BatchableContext bc, List <User>users) {
        try {
            Set <String>userIds = new Set <String>();
            List <String>userIdsLst = new List <String>();
            for (User user: users) {
                userIds.add(user.Id);
            }
            userIdsLst.addAll(userIds);

            Set <String>userIdsSet = new Set <String>();
            userIdsSet.addAll(userIdsLst);
            if (!userIdsLst.IsEmpty()) {
                MallNotificationsWrapper notification = new MallNotificationsWrapper();
                notification.userIds = userIdsSet;
                notification.emailTemplateName = MALL_WHATS_NEW_EMAIL_TEMPLATE_NAME;
                if(!Test.isRunningTest()) {
                    new MallEmailNotifications().sendNotifications(notification);
                }
            }

            if (!userIdsLst.IsEmpty()) {
                processProviders(userIdsLst);
                processOfferings(userIdsLst);
                processPromotions(users);
            }
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('BCH_MallWhatsNewNotification.execute', e);
        }
    }

    /**
     * 
     * @description processProviders
     * @param userIdsLst List<String>
     */
    private static void processProviders(List <String>userIdsLst) {
        try {
            Set <String>userIdsSet = new Set <String>();
            userIdsSet.addAll(userIdsLst);
            List <Tag_Provider__c>tagProviders = new List <Tag_Provider__c>();
            String tagProviderWhereClause = ' Tag__r.Parent_Name__c=\'Category\' And Provider__r.Publishing_Unit__r.Published_from__c = LAST_MONTH AND Provider__r.IsOnline__c=TRUE';
            tagProviders = SEL_TagProviders.newInstance().selectByCustomFilterCondition(tagProviderWhereClause);
            if (!userIdsLst.IsEmpty()) {
                String providerCategories = '';
                for (Tag_Provider__c tagProvider: tagProviders) {
                    providerCategories = providerCategories + tagProvider.Tag__r.Name + ', ';
                }

                if (!String.isBlank(providerCategories)) {
                    MallNotificationsWrapper notification = new MallNotificationsWrapper();
                    notification.batchType = 'BCB_Platform_Whats_New_Notification';
                    notification.notificationTitle = System.Label.MALL_WHAT_NEW_EMAIL_DEFAULT_TITILE;
                    notification.customNotificationBody = System.Label.MALL_WHAT_NEW_EMAIL_DEFAULT_TITLE_PREFIX + ' ' + providerCategories + ' ' + System.Label.MALL_WHAT_NEW_EMAIL_PROVIDER_TITLE_SUFFIX;
                    notification.userIds = userIdsSet;
                    notification.targetId = tagProviders[0].Provider__c;
                    new MallCustomNotifications().sendNotifications(notification);
                }
            }
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('BCH_MallWhatsNewNotification.processProviders', e);
        }
    }

    /**
     * 
     * @description processOfferings
     * @param userIdsLst List<String>
     */
    private static void processOfferings(List <String>userIdsLst) {
        try {
            Set <String>userIdsSet = new Set <String>();
            userIdsSet.addAll(userIdsLst);
            List <Tag_Offering__c>tagOfferings = new List <Tag_Offering__c>();
            String tagProductWhereClause = ' Tag__r.Parent_Name__c=\'Category\' And Offering__r.Publishing_Unit__r.Published_from__c= LAST_MONTH AND Offering__r.IsOnline__c=TRUE';
            tagOfferings = SEL_TagOfferings.newInstance().selectByCustomFilterCondition(tagProductWhereClause);
            if (!userIdsLst.IsEmpty()) {
                String offeringCategories = '';
                for (Tag_Offering__c tagOffering: tagOfferings) {
                    offeringCategories = offeringCategories + tagOffering.Tag__r.Name + ', ';
                }

                if (!String.isBlank(offeringCategories)) {
                    MallNotificationsWrapper notification = new MallNotificationsWrapper();
                    notification.batchType = 'BCB_Platform_Whats_New_Notification';
                    notification.userIds = userIdsSet;
                    notification.notificationTitle = System.Label.MALL_WHAT_NEW_EMAIL_DEFAULT_TITILE;
                    notification.customNotificationBody = System.Label.MALL_WHAT_NEW_EMAIL_DEFAULT_TITLE_PREFIX + ' ' + offeringCategories + ' ' + System.Label.MALL_WHAT_NEW_EMAIL_OFFERING_TITLE_SUFFIX;
                    notification.targetId = tagOfferings[0].Offering__c;
                    new MallCustomNotifications().sendNotifications(notification);
                }
            }
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('BCH_MallWhatsNewNotification.processOfferings', e);
        }
    }

    /**
     * 
     * @description processPromotions
     * @param users List<User>
     */
    private static void processPromotions(List <User>users) {
        try {
            String promotionWhereClause = 'Publishing_Unit__r.Published_from__c = THIS_MONTH AND IsOnline__c = TRUE';
            List <Promotion__c>promotions = SEL_Promotions.newInstance().selectByCustomFilterCondition(promotionWhereClause);
            if (!promotions.isEmpty()) {
                MallNotificationsWrapper notificationPromo = new MallNotificationsWrapper();
                notificationPromo = new MallNotificationsWrapper();
                notificationPromo.users = users;
                notificationPromo.batchType = 'BCB_Platform_Deals_And_Promotions';
                for (Promotion__c promotion: promotions) {
                    notificationPromo.notificationTitle = promotion.Small_Title__c;
                    notificationPromo.customNotificationBody = promotion.SubText__c;
                    notificationPromo.targetId = promotion.Id;
                    new MallCustomNotifications().sendNotifications(notificationPromo);
                }
            }
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('BCH_MallWhatsNewNotification.processPromotions', e);
        }
    }

    /**
     * 
     * @description finish
     * @param info Database.BatchableContext
     */
    public void finish(Database.BatchableContext info) {
        MallExceptionUtil.LOGGER.info('BCH_MallWhatsNewNotification.finish : Batch process ended at :: ' + DateTime.now());
    }
}