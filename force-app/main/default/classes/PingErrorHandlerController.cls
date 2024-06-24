/**
 * @description : PingErrorHandlerController
 * @author: Manasi Londhe
 * @since 
 */

public with sharing class PingErrorHandlerController {

    //global instance of rf lib logger
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('PingErrorHandlerController');
    public String hideSignUpModal{ get; set; }
    public String targetUrl{get; set;} 

   /**
   * 
   * @description : handleError 
   *  @param : None
   *  @return : None 
   */
    public void handleError(){
        try{
            Mall_SSO_Configuration__mdt mallSSOConfig = Mall_SSO_Configuration__mdt.getInstance('Mall_SSO_Configuration');
            targetUrl= mallSSOConfig.Mall_Home_Page__c;
            if(ApexPages.currentPage().getParameters().get('ErrorDescription')=='login_required'){ hideSignUpModal='true'; }
        }catch(Exception e){ throw throwAuraException('handleError', e); }
    }

    /* @description Method to return Exception for each catch block
    * @param message String 
    * @param e Exception
    * @return  `AuraHandledException`
    */
    public static AuraHandledException throwAuraException(String message, Exception e) {
        LOGGER.error(message, e);
        AuraHandledException auraException = new AuraHandledException(e.getMessage());
        auraException.setMessage(e.getMessage());
        return auraException;
    }
}