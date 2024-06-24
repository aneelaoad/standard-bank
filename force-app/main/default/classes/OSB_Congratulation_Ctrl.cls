/**
 * Controller class for OSB_Congratulation_Ctrl component
 *
 * @author Wayde Fagan (wayde.fagan@tetrad.co.za)
 * @date April 2020
 *
 **/
public without sharing class OSB_Congratulation_Ctrl {
	
    Public static Final String PLACE_HOLDER_MANAGER = 'OneHub Manager';
    /**
     * Checks for the contact that authorised this user
     *
     * @return String name of user contact
     **/
    @AuraEnabled(Cacheable=true)
    public static String getContactName(){
        List <Contact> contactUser = SEL_Contacts.newInstance().selectByUserIdWoSharing(new Set<Id>{UserInfo.getUserId()});
        if(!contactUser.isEmpty()){
           return contactUser[0].OSB_Community_Access_Manager__r.Name;
        }
        return PLACE_HOLDER_MANAGER;
    }
}