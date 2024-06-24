/**
 * Retrieving data used in the landing page header
 * <br/>SFP-4690
 *
 * @author The Cocktail
 * @date June 2021
 * @description Retrieving data used in the landing page header
 */
public without sharing class EAP_CTRL_HeaderHome {
    
    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @return User 
    **/
    @AuraEnabled(cacheable=true)
    public static User getUserInfo(){
        Set<Id> userId = new Set<Id>();
        userId.add(UserInfo.getUserId());
        User userInfo = SEL_Users.newInstance().selectById(userId).get(0);
        return userInfo;
    }
}