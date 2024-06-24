/**
 * @description SBGFooterBarController
 * @author Maham Hasan
 * @since 
 */
public with sharing class SBGFooterBarController {
    /**
    * 
    * @description Apex Type wrapper for parent footer items
    */
    public class FooterItem {
        @AuraEnabled
        public string name;
        @AuraEnabled
        public string id;
        @AuraEnabled
        public List<FooterChildItem> footerChildItems;
    }

    /**
    * 
    * @description FooterChildItem
    */
    public class FooterChildItem {
        @AuraEnabled
        public string name;
        @AuraEnabled
        public string id;
        @AuraEnabled
        public string url;
    }

    /**
    * 
    * @description getFooterItems
    * @return List<FooterItem> 
    */
    @AuraEnabled(cacheable=true)
    public static List<FooterItem> getFooterItems() {
        try {
            String currentUserId = userInfo.getUserId();
            List<User> users = SEL_Users.newInstance().selectUsersWithProfileByIds(new Set<Id>{(Id)currentUserId});
            
            if(users.size() > 0) {
                User user = users[0];
                Map<String, FooterItem> footerItems = new Map<String, FooterItem>();
                if(!user.Profile.Name.contains('Store')  || (user.Profile.Name.contains('Store') && user.BCB_Platform_Tenant_Mode__c != 'Edit')) {
                    footerItems = new Map<String, FooterItem>(); 
                    List<SBG_Footer_Item__mdt> sbgFooterItems = SEL_MALL_FooterItems.newInstance().selectFooterItems();
                    for (SBG_Footer_Item__mdt sbgFooterItem: sbgFooterItems) {
                        if (sbgFooterItem.Level__c == 1) {
                            FooterItem footerItem = new FooterItem();
                            footerItem.name = sbgFooterItem.MasterLabel;
                            footerItem.id = sbgFooterItem.id;
                            footerItem.footerChildItems = new List<FooterChildItem>();
                            footerItems.put(footerItem.name, footerItem);
                        } else {
                            FooterChildItem footerChildItem = new FooterChildItem();
                            footerChildItem.name = sbgFooterItem.MasterLabel;
                            footerChildItem.id = sbgFooterItem.id;
                            footerChildItem.url = sbgFooterItem.Item_URL__c;
                            footerItems.get(sbgFooterItem.Parent_Tab__c).footerChildItems.add(footerChildItem);
                        }
                    }
                }
                return footerItems.values();
            } else {
                return NULL;
            }
        } catch(Exception e){            
            throw MallExceptionUtil.throwAuraException('SBGFooterBarController.getFooterItems', e);
        }
    }
}