/**
 * @description Controller Class for AR Quick Links Component
 * @author Maham Hassan
 * @since 11-04-2022
 * 
 * 2023-03-27   Derek Hughes    SFP-23681 Added country filter and consolidated TRade Club as a normal link
 */
public with sharing class AR_QuickLinks_CTRL {
    /**
    * @description Returns list of AR quick links
    * @return List<AR_QuickLinks>
    */
	@AuraEnabled
	public static List<AR_QuickLinks> getQuickLinks(){
        
        List<AR_QuickLinks> arQuickLinks = new List<AR_QuickLinks>();
        User userDetails = SEL_Users.newInstance().selectUsersWithProfileByIds(new Set<Id> {UserInfo.getUserId()}).get(0);

        Map<String, AR_Quick_Link__mdt> quickLinks = AR_Quick_Link__mdt.getAll();
        for (AR_Quick_Link__mdt quickLink: quickLinks.values()) {
            // check if this is for all users (blank) or matches the current users profile
            if (String.IsBlank(quickLink.Show_for_Profile__c) || quickLink.Show_for_Profile__c.contains(userDetails.Profile.Name)) {
                // check if this is for all users (blank) or matches the current users Country
                if (String.IsBlank(quickLink.Show_for_Country__c) || quickLink.Show_for_Country__c.contains(userDetails.Country)) {
                    AR_QuickLinks arQuickLink = new AR_QuickLinks();
                    arQuickLink.link = 'http://' + quickLink.Link__c;
                    arQuickLink.label = quickLink.Label__c;
                    arQuickLink.icon = quickLink.Icon__c.replace('#' , ':');
                    arQuickLinks.add(arQuickLink);    
                }
            }
        }
     
        return arQuickLinks;
	}

    /**
     * @description returns list of Sector Resources
     * @return  List of AR_QuickLinks
     */
    @AuraEnabled
    public static List<AR_QuickLinks> getSectorResources(){

        List<AR_QuickLinks> sectorResources = new List<AR_QuickLinks>();
        Map<String, Sector_Resource__mdt> sectorResourcesList = Sector_Resource__mdt.getAll();

        for (Sector_Resource__mdt secResource: sectorResourcesList.values()) {
            AR_QuickLinks sectorResource = new AR_QuickLinks();
            sectorResource.icon = secResource.Icon__c;
            sectorResource.label = secResource.Label__c;
            sectorResource.link = secResource.Link__c;
            sectorResources.add(sectorResource);
        }
       
        return sectorResources;
    }

    /**
     * 
     * @description Wrapper Class for Quick Links
     */
    public class AR_QuickLinks {
        @AuraEnabled
        public string link;
        @AuraEnabled
        public string label;
        @AuraEnabled
        public string icon;
    }
}