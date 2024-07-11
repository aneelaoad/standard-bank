public with sharing class CTRL_MallSubNavigationItems {

    /**
    * @description getMallSubNavigationItems
    * @return SubNavigationItemWrapper 
    */

    @AuraEnabled(cacheable=true)
    public static List<SubNavigationItemWrapper> getMallSubNavigationItems(){
        try{
        List<Mall_Sub_Navigation_Item__mdt> subNavItems = [
            SELECT Id,Label, Available_In_Main_Navigation__c, Available_In_Solution_Page__c, Is_Main__c, Order_Number__c, SBG_Navigation_Items__r.Label, Set_As_Active__c, URL_Link__c, Icon__c, Tagline__c
            FROM Mall_Sub_Navigation_Item__mdt
            //WHERE SBG_Navigation_Items__r.Label = 'our solutions'
            ORDER BY Order_Number__c ASC];

            List<SubNavigationItemWrapper> subNavigationItems = new List<SubNavigationItemWrapper>();

            for (Mall_Sub_Navigation_Item__mdt subNavItem : subNavItems) {

                subNavigationItems.add(new SubNavigationItemWrapper(subNavItem));

            }

        return subNavigationItems; 

        }catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('CTRL_MallSubNavigationItems.getMallSubNavigationItems', e);
        }
    }

    /**
    * @description getSolutionPageMainCategories
    * @return SubNavigationItemWrapper 
    */

    @AuraEnabled(cacheable=true)
    public static List<SubNavigationItemWrapper> getSolutionPageMainCategories(){
        try {
        List<Mall_Sub_Navigation_Item__mdt> mainCategories = [
            SELECT Id,Label, Available_In_Main_Navigation__c, Available_In_Solution_Page__c, Is_Main__c, Order_Number__c, SBG_Navigation_Items__r.Label, Set_As_Active__c, URL_Link__c, Icon__c, Tagline__c
            FROM Mall_Sub_Navigation_Item__mdt
            WHERE SBG_Navigation_Items__r.Label = 'our solutions'
            AND Is_Main__c = TRUE
            AND Available_In_Solution_Page__c = TRUE
            ORDER BY Order_Number__c ASC];

            List<SubNavigationItemWrapper> subNavigationItems = new List<SubNavigationItemWrapper>();

            for (Mall_Sub_Navigation_Item__mdt subNavItem : mainCategories) {

                subNavigationItems.add(new SubNavigationItemWrapper(subNavItem));

            }
            
            return subNavigationItems; 

        }catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('CTRL_MallSubNavigationItems.getSolutionPageMainCategories', e);
        }
           
    }


    /**
    * @description SubNavigationItemWrapper
    */

    public class SubNavigationItemWrapper {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public Boolean availableInMainNavigation { get; set; }
        @AuraEnabled public Boolean availableInSolutionPage { get; set; }
        @AuraEnabled public Boolean isMain { get; set; }
        @AuraEnabled public Integer orderNumber { get; set; }
        @AuraEnabled public String sBGNavigationItemsLabel { get; set; }
        @AuraEnabled public Boolean setAsActive { get; set; }
        @AuraEnabled public String uRLLink { get; set; }
        @AuraEnabled public String icon { get; set; }
        @AuraEnabled public String tagline { get; set; }
        @AuraEnabled public String buttonClass { get; set; }

        public SubNavigationItemWrapper(Mall_Sub_Navigation_Item__mdt item) {
            this.id    = item.Id;
            this.label = item.Label;
            this.availableInMainNavigation = item.Available_In_Main_Navigation__c;
            this.availableInSolutionPage = item.Available_In_Solution_Page__c;
            this.isMain = item.Is_Main__c;
            this.orderNumber =  (item.Order_Number__c).intValue();
            this.sBGNavigationItemsLabel = item.SBG_Navigation_Items__r != null ? item.SBG_Navigation_Items__r.Label : null;
            this.setAsActive = item.Set_As_Active__c;
            this.uRLLink = item.URL_Link__c;
            this.icon = item.Icon__c;
            this.tagline = item.Tagline__c;
            this.buttonClass = '';
        }
    }    


}