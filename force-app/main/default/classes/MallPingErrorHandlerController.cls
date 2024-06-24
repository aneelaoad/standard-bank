/**
 * @description : MallPingErrorHandlerController
 * @author: Manasi Londhe
 * @since 
 */

public with sharing class MallPingErrorHandlerController {
   /**
   * 
   * @description : hideSignUpModal 
   */
    public String hideSignUpModal{ get; set; }
   /**
   * 
   * @description : targetUrl 
   */
    public String targetUrl{get; set;} 

   /**
   * 
   * @description : handleError 
   */
    public void handleError(){
        try{
            Mall_SSO_Configuration__mdt mallSSOConfig = Mall_SSO_Configuration__mdt.getInstance('Mall_SSO_Configuration');
            targetUrl= mallSSOConfig.Mall_Home_Page__c;
            if(ApexPages.currentPage().getParameters().get('ErrorDescription') == 'login_required'){ hideSignUpModal='true'; }
        } catch(Exception e) { 
            throw MallExceptionUtil.throwAuraException('MallPingErrorHandlerController.handleError', e); 
        }
    }
}