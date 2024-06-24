/**
 * 
 * @description BackToMallController 
 * @author Maham Hassan
 * @since 
 */
public with sharing class BackToMallController {
    /**
     * 
     * @description targetUrl to be redirected
     */
    public String targetUrl{ get; set; }
   
    /**
     * @description BackToMallController Constructor
     */
    public BackToMallController() {
        try{
            if (!Auth.CommunitiesUtil.isGuestUser() 
                && Cache.Session.contains('lastVisitedPage') 
                && Cache.Session.contains('redirectTolastVisitedPage') 
                && (Boolean)Cache.Session.get('redirectTolastVisitedPage')==true){
                Cache.Session.put('redirectTolastVisitedPage',false);
                    targetUrl = (String)Cache.Session.get('lastVisitedPage');
            }
            else{
                Mall_SSO_Configuration__mdt mallSSOConfig = Mall_SSO_Configuration__mdt.getInstance('Mall_SSO_Configuration');
                targetUrl=mallSSOConfig.Mall_Home_Page__c;
            }
       }
       catch(Exception e){
        throw MallExceptionUtil.throwAuraException('BackToMallController.BackToMallController', e);
       }
    }
}