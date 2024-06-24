/**
 * 
 * @description MallProductRangeItemController
 * @author Maham Hasan
 * @since 
 */
public with sharing class MallProductRangeItemController {
    
    //global instance of rf lib logger
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('MallProductRangeItemController');

    @AuraEnabled(cacheable=true)
    public static void setPingSessionVariable(){
        try{
            Cache.Session.put('pingSessionChecked',true);
        }catch(Exception e){ LOGGER.error('setPingSessionVariable', e); }
    }

    @AuraEnabled(cacheable=true)
    public static void setSessionVariables(String pageUrl){
        try{
            Cache.Session.put('lastVisitedPage',pageUrl);
            Cache.Session.put('redirectTolastVisitedPage',true);
        }catch(Exception e){
            LOGGER.error('setSessionVariables', e);
        }
    }
}