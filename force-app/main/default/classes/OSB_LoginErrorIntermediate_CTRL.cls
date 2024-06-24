/**
 * Controller class for OSBLoginErrorIntermediate aura component
 * <br/> US-4824
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date June 2020
 */
public without sharing class OSB_LoginErrorIntermediate_CTRL {

    /**
     * Creates a log for sign in errors
     *
     * @param errorMessage error message
     * 
     **/
    @AuraEnabled
    public static void createLog(String errorMessage) {
        SRV_Logger.newInstance().log(new LoginErrorException(errorMessage), DMN_Log.AREA_ONEHUB, OSB_LoginErrorIntermediate_CTRL.class.getName());
    }

    class LoginErrorException extends Exception {}
}