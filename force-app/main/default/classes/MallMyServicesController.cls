/**
 * @description : MallMyServicesController
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallMyServicesController {
    /**
    * 
    * @description getMyServices
    * @param tagIds List<String>
    * @return List<DenormalizedShopService>
    */
    @AuraEnabled
    public static List<DenormalizedShopService> getMyServices(List<String> tagIds) {
        try {
            List<Id> tags=new List<Id>();
            if(tagIds.IsEmpty()){
                for(DenormalizedTag tag:MallDataService.getActiveRootCategories()){
                    tags.add(tag.id);
                }
            }
            else{
                tags=tagIds;
            }
            List<String> finalShopIds=new List<String>();
            Set<Id> shopIds=new Set<Id>();
            List<DenormalizedShop> finalShops=new List<DenormalizedShop>();
            String whereClause=' User__c=\''+UserInfo.getUserId()+'\' And Provider__c != NULL';
    
            for(Shortcut__c service: SEL_Shortcuts.newInstance().selectByCustomFilterCondition(whereClause)){
                shopIds.add(service.Provider__c);
            }
    
            if(!shopIds.IsEmpty()){
                for(DenormalizedShop shop:MallDataService.getShopsByTagIds(null,tags)){
                    if(shopIds.contains(shop.id)){
                            finalShops.add(shop);
                            finalShopIds.add(shop.id);
                    }
                }
            }
            if(!finalShopIds.IsEmpty()) {
                return getDenormalizedShopAndService(finalShops,finalShopIds);
            }
            else {
                return new List<DenormalizedShopService>();
            }
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallMyServicesController.getMyServices', e);
        }
    }

    /**
    * 
    * @description getDenormalizedShopAndService
    * @param shops List<DenormalizedShop>
    * @param finalShopIds List<String>
    * @return List<DenormalizedShopService>
    */
    public static List<DenormalizedShopService> getDenormalizedShopAndService(List<DenormalizedShop> shops,List<String> finalShopIds) {
        try {
            Map<Id,List<Offering__c>> shopIdVsServices=new Map<Id,List<Offering__c>>();
            String whereClause = ' Provider__c IN (\'' + String.join(finalShopIds, '\',\'') + '\') AND IsOnline__c = TRUE and RecordType.DeveloperName=\'Service\'';
            for(Offering__c service : SEL_Offerings.newInstance().selectByCustomFilterCondition(whereClause)){
                if(!shopIdVsServices.containsKey(service.Provider__c)){
                    shopIdVsServices.put(service.Provider__c,new List<Offering__c>{service});
                }
                else{
                    shopIdVsServices.get(service.Provider__c).add(service);
                }
            }
     
            return prepareFinalData(shopIdVsServices,shops);
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallMyServicesController.getDenormalizedShopAndService', e);
        }
    }

    /**
    * 
    * @description prepareFinalData
    * @param shopIdVsServices Map<Id,List<Offering__c>>
    * @param shops List<DenormalizedShop>
    * @return List<DenormalizedShopService>
    */
    public static List<DenormalizedShopService> prepareFinalData(Map<Id,List<Offering__c>> shopIdVsServices,List<DenormalizedShop> shops) {
        try {
            List<DenormalizedShopService> data=new List<DenormalizedShopService>();
            for(DenormalizedShop shop:shops){
                DenormalizedShopService shopService=new DenormalizedShopService();
                shopService.imageUrl=shop.imageUrl;
                shopService.shopId=shop.id;
                shopService.name=shop.name;
                if(shopIdVsServices.containsKey(shop.id)){
                    shopService.services=shopIdVsServices.get(shop.id);
                }
                shopService.shortDesc=shop.title;
                shopService.isNew=shop.publishedFrom >  (System.today().addDays(-5));
                data.add(shopService);
            }
            return data;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallMyServicesController.prepareFinalData', e);
        }
    }

    /**
    * 
    * @description getShops
    * @param tagIds List<String>
    * @return List<DenormalizedShop>
    */
    @AuraEnabled
    public static List<DenormalizedShop> getShops(List<String> tagIds){
        try {
            return MallDataService.getShopsByTagIds(null,tagIds);
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallMyServicesController.getShops', e);
        }
    }

    /**
    * 
    * @description updateShortcuts
    * @param shopIds List<String>
    */
    @AuraEnabled
    public static void updateShortcuts(List<String> shopIds) {
        try {
            delete SEL_Shortcuts.newInstance().selectByCustomFilterCondition('User__c=\'' + UserInfo.getUserId() + '\' And Provider__c != NULL');
            List<Shortcut__c> shortcutsToInsert=new List<Shortcut__c>();
            for(Id shopId:shopIds){
              Shortcut__c shortcut=new Shortcut__c(Provider__c=shopId,User__c=UserInfo.getUserId());
              shortcutsToInsert.add(shortcut);
            }
            insert shortcutsToInsert;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallMyServicesController.updateShortcuts', e);
        }
    }
    
    /**
    * 
    * @description DenormalizedShopService
    */
    public class DenormalizedShopService{
        @AuraEnabled
        public String imageUrl;
        @AuraEnabled
        public String shopId;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public List<Offering__c> services;
        @AuraEnabled
        public List<Link__c> links;
        @AuraEnabled
        public String shortDesc;
        @AuraEnabled
        public Boolean isNew;
     }
}