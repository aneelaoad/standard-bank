/**
* @description  : Partner Portal Authentication Controller
* User Story : SFP-4844
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date July 2021
*/
public class PP_Authentication_CTRL {

    /**
  * To login into the community
  * Userstory : SFP-4844
  * @param username of a Community User
  * @param password of a Community User
  * @param startUrl to Redirect After Login
  * @return String
  */
    @AuraEnabled
    public static String loginIntoCommunity(String username, String password, String startUrl) {
        try{
            ApexPages.PageReference lgn = Site.login(username, password, startUrl);
            return lgn.getUrl();
        }
        catch (Exception ex) {
            SRV_Logger.newInstance().log(ex, DMN_Log.AREA_PARTNERPORTAL,PP_Authentication_CTRL.class.getname());
            return ex.getMessage();            
        }
    }

   /**
  * To trigger password reset email for community user
  * Userstory : SFP-4844
  * @param username of a community User
  * @return String
  */
    @AuraEnabled
    public static String forgotPasswordUsingUsername(String username) {
        
        try {
            Site.forgotPassword(username);
            if(!Site.isValidUsername(username)) {
                return 'Username is not valid';
            }
            return null;
        }
        catch (Exception ex) {
            SRV_Logger.newInstance().log(ex, DMN_Log.AREA_PARTNERPORTAL,PP_Authentication_CTRL.class.getname());
            return ex.getMessage();
        }
    }
    
    /**
    * @description | Used to Update Community User Password
    * @param currentPass 
 	* @param newPass
 	* @param newPass2 
    * @author Syed Ovais Ali July 2021 
    * @return String
    **/
    @AuraEnabled
    public static String updatePassword(String currentPass,String newPass,String newPass2) {
        try {
            User usr = new User(Id=UserInfo.getUserId(), Username=UserInfo.getUserName());
            if(!Test.isRunningTest()){
                Site.validatePassword(usr, newPass, newPass2);  
            }
            Site.changePassword(newPass, newPass2, currentPass); 
            return 'Success';
        } catch (Exception ex) {
            return ex.getMessage();
        }
    }
}