/**
 * @description MallQuickLinksController
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallQuickLinksController {
    /**
     * 
     * @description getQuickLinks: Method to return configured quicklinks
     * @return  List<DashboardQuicklinkData>
     */
    @AuraEnabled
    public static List <DashboardQuicklinkData> getQuickLinks() {
        try {
            String shortcutWhereClause = ' User__c=\'' + UserInfo.getUserId() + '\' And Link__c != NULL';
            List <Shortcut__c> shortcuts = SEL_Shortcuts.newInstance().selectByCustomFilterCondition(shortcutWhereClause);
            List <Link__c> links = SEL_Links.newInstance().selectByCustomFilterCondition(' Offering__c != NULL');
            Map <Id, Id> linkIdVsIconId = new Map <Id, Id> ();
            Map <Id, Link__c> linkIdVsShorcut = new Map <Id, Link__c> ();
            Map <Id, String> cuIdVsIconUrl = new Map <Id, String> ();
            Map <Id, Content_Unit_Translation__c> linkIdVsServiceCut = new Map <Id, Content_Unit_Translation__c> ();
            List <Id> servicesIds = new List <Id> ();
            Map <Id, List <Id>> serviceIdVsCategoriesId = new Map <Id, List <Id>> ();
            Map <Id, List <Link>> serviceIdVsLinks = new Map <Id, List <Link>> ();
            Map <Id, Id> serviceIdVsLinkId = new Map <Id, Id> ();
            List <Id> userSavedLinkIds = new List <Id> ();
            List <Id> servicesWithSavedLinks = new List <Id> ();
            List <Content_Unit_Translation__c> servicesWithoutLinks = new List <Content_Unit_Translation__c> ();

            for (Shortcut__c shortcut: shortcuts) {
                userSavedLinkIds.add(shortcut.Link__c);
            }

            for (Offering__c service: SEL_Offerings.newInstance().selectByCustomFilterCondition('Status__c = \'Published\'')) {
                servicesIds.add(service.Id);
            }

            for (Link__c quickLink: links) {
                linkIdVsShorcut.put(quickLink.Id, quickLink);
                linkIdVsIconId.put(quickLink.Id, quickLink.Icon__c);
                serviceIdVsLinkId.put(quickLink.Offering__c, quickLink.Id);
            }

            List <Id> linkIds = new List <Id> ();
            linkIds.addAll(linkIdVsIconId.KeySet());
            String whereClause = ' ( Link__c IN (\'' + String.join(linkIds, '\',\'') + '\')';
            whereClause += ' OR  Content_Unit__c IN (\'' + String.join(linkIdVsIconId.values(), '\',\'') + '\') OR Product__c IN (\'' + String.join(servicesIds, '\',\'') + '\') )';
            whereClause += ' And Language_ISO__C=\'en\'';

            List <Content_Unit_Translation__c> cuts = SEL_ContentUnitTranslations.newInstance().selectByCustomFilterCondition(whereClause);

            for (Content_Unit_Translation__c cut: cuts) {
                if (cut.Content_Unit__c != NULL) {
                    cuIdVsIconUrl.put(cut.Content_Unit__c, cut.Image_Url__c);
                } else if (cut.Product__c != NULL && serviceIdVsLinkId.containsKey(cut.Product__c)) {
                    linkIdVsServiceCut.put(serviceIdVsLinkId.get(cut.Product__c), cut);
                } else if (cut.Product__c != NULL && !serviceIdVsLinkId.containsKey(cut.Product__c)) {
                    servicesWithoutLinks.add(cut);
                }
            }

            for (Content_Unit_Translation__c cut: cuts) {
                if (cut.Link__c != NULL && linkIdVsShorcut.containsKey(cut.Link__c) && cuIdVsIconUrl.containsKey(cut.Link__r.Icon__c)) {
                    Link link = new Link();
                    link.title = cut.Title__c;
                    link.id = cut.Link__c;
                    link.icon = cuIdVsIconUrl.get(cut.Link__r.Icon__c);
                    link.desktopUrl = linkIdVsShorcut.get(cut.Link__c).DeskTop_Url__c;
                    link.guestUrl = linkIdVsShorcut.get(cut.Link__c).Guest_url__c;
                    link.mobileUrl = linkIdVsShorcut.get(cut.Link__c).Mobile_Url__c;
                    link.userSaved = userSavedLinkIds.contains(cut.Link__c);
                    if (link.userSaved) {
                        servicesWithSavedLinks.add(cut.Link__r.Offering__c);
                    }
                    if (!serviceIdVsLinks.containsKey(linkIdVsShorcut.get(cut.Link__c).Offering__c)) {
                        serviceIdVsLinks.put(linkIdVsShorcut.get(cut.Link__c).Offering__c, new List <Link> {
                            link
                        });
                    } else {
                        serviceIdVsLinks.get(linkIdVsShorcut.get(cut.Link__c).Offering__c).add(link);
                    }
                }
            }

            String whereTpClause = ' Offering__c IN (\'' + String.join(servicesIds, '\',\'') + '\') And Tag__r.Parent_Name__c=\'Category\'';
            for (Tag_Offering__c tagService: SEL_TagOfferings.newInstance().selectByCustomFilterCondition(whereTpClause)) {
                if (!serviceIdVsCategoriesId.containsKey(tagService.Offering__c)) {
                    serviceIdVsCategoriesId.put(tagService.Offering__c, new List <String> {
                        tagService.Tag__c
                    });
                } else {
                    serviceIdVsCategoriesId.get(tagService.Offering__c).add(tagService.Tag__c);
                }
            }

            List <DashboardQuicklinkData> finalData = new List <DashboardQuicklinkData> ();
            for (Id linkId: linkIdVsServiceCut.KeySet()) {
                if (serviceIdVsCategoriesId.containsKey(linkIdVsServiceCut.get(linkId).Product__c) &&
                    serviceIdVsLinks.get(linkIdVsServiceCut.get(linkId).Product__c) != NULL &&
                    !serviceIdVsLinks.get(linkIdVsServiceCut.get(linkId).Product__c).isEmpty()) {
                    DashboardQuicklinkData data = new DashboardQuicklinkData();
                    data.id = linkIdVsServiceCut.get(linkId).Product__c;
                    data.title = linkIdVsServiceCut.get(linkId).Title__c;
                    data.imageUrl = linkIdVsServiceCut.get(linkId).Image_URL__c;
                    data.categoryIds = serviceIdVsCategoriesId.get(linkIdVsServiceCut.get(linkId).Product__c);
                    data.collection = serviceIdVsLinks.get(linkIdVsServiceCut.get(linkId).Product__c);
                    data.hasUserSavedLinks = true;
                    data.hasQuickLinks = true;
                    finalData.add(data);
                }
            }

            for (Content_Unit_Translation__c cut: servicesWithoutLinks) {
                if (serviceIdVsCategoriesId.containsKey(cut.Product__c) && cut.Title__c != NULL) {
                    DashboardQuicklinkData data = new DashboardQuicklinkData();
                    data.id = cut.Product__c;
                    data.title = cut.Title__c;
                    data.imageUrl = cut.Image_URL__c;
                    data.categoryIds = serviceIdVsCategoriesId.get(cut.Product__c);
                    data.hasUserSavedLinks = false;
                    data.hasQuickLinks = false;
                    finalData.add(data);
                }
            }
            return finalData;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallQuickLinksController.getQuickLinks', e);
        }
    }

    /**
     * 
     * @description Method to update Quick Links
     * @param linkIds `List<String>`
     */
    @AuraEnabled
    public static void updateQuickLinks(List <String> linkIds) {
        try {
            delete SEL_Shortcuts.newInstance().selectByCustomFilterCondition('User__c=\'' + UserInfo.getUserId() + '\' And Link__c != NULL');
            List <Shortcut__c> shortcutsToInsert = new List <Shortcut__c> ();
            for (Id linkId: linkIds) {
                Shortcut__c shortcut = new Shortcut__c(Link__c = linkId, User__c = UserInfo.getUserId());
                shortcutsToInsert.add(shortcut);
            }
            insert shortcutsToInsert;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallQuickLinksController.updateQuickLinks', e);
        }
    }

    /**
     * 
     * @description Method to delete quick links
     * @param linkIds `List<String>`
     */
    @AuraEnabled
    public static void deleteQuickLinks(List <String> linkIds) {
        try {
            delete SEL_Shortcuts.newInstance().selectByCustomFilterCondition('User__c=\'' + UserInfo.getUserId() + '\' AND Link__c IN (\'' + String.join(linkIds, '\',\'') + '\')');
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallQuickLinksController.updateQuickLinks', e);
        }
    }

    /**
     *
     * @description Wrapper Apex Type for the Links
     */
    public class Link {
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String icon;
        @AuraEnabled
        public String desktopUrl;
        @AuraEnabled
        public String mobileUrl;
        @AuraEnabled
        public String guestUrl;
        @AuraEnabled
        public boolean userSaved;
    }
    /**
     *
     * @description Wrapper Apex Type for QUick links data for dashboard
     */
    public class DashboardQuicklinkData {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String title;
        @AuraEnabled
        public String imageUrl;
        @AuraEnabled
        public List <Link> collection;
        @AuraEnabled
        public List <String> categoryIds;
        @AuraEnabled
        public boolean hasUserSavedLinks;
        @AuraEnabled
        public boolean hasQuickLinks;
    }
}