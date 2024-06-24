/**
* Controller class of OSB404 component
* is used to log errors on page load
* <br/>SGPRT-3822
*
* @author Denys Yelchaninov (dyelchaninov@deloittece.com)
* @date November 2020
*/
public with sharing class OSB_404_CTRL {
    
    
    /**
     * Creates log when 404 page is loaded
     * @param String url of page from which user was redirected
     **/
     @AuraEnabled
    public static void logPageEntry(string pageURL){
        try{
            OSB_404ReachedException e = new OSB_404ReachedException();
            e.setMessage('Page ' + pageURL + ' is not found.');
            throw e;
        }
        catch(Exception e){
            List<String> messages = new List<String>{'User ' + UserInfo.getName() + 
                                                ' tried to access nonexistnd page with url of ' 
                                                + pageURL};
            
            SRV_Logger.newInstance().log(e, DMN_Log.AREA_ONEHUB, OSB_404_CTRL.class.getName(), messages);
        }
    }

    public class OSB_404ReachedException extends Exception {

    }
}