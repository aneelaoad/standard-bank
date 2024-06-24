/**
 * @description : GenericMallRedirectionController
 * @author Manasi Londhe
 * @since 
 */

public with sharing class GenericMallRedirectionController {    
   /**
   * 
   * @description handleRedirection
   * @param currentPageUrl String
   * @return  `String`
   */
    @AuraEnabled
    public static string handleRedirection(String currentPageUrl) 
    { 
      Mall_SSO_Configuration__mdt mallSSOConfig = Mall_SSO_Configuration__mdt.getInstance('Mall_SSO_Configuration');
      try{
          if(Auth.CommunitiesUtil.isGuestUser()) {
            return mallSSOConfig.Mall_SSO_Provider_No_Prompt__c;
          }
       } catch(exception e){
          throw MallExceptionUtil.throwAuraException('GenericMallRedirectionController.handleRedirection', e);
       }
      return NULL;
    }

   /**
   * 
   * @description getPingSettings
   * @param : None
   * @return  `String`
   */
    @AuraEnabled
    public static Mall_SSO_Configuration__mdt getPingSettings(){
      Mall_SSO_Configuration__mdt mallSSOConfig = Mall_SSO_Configuration__mdt.getInstance('Mall_SSO_Configuration');
      return mallSSOConfig;
    } 
}