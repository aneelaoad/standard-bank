/**
* @description  Partner Portal Change Password Controller 
* User Story : SFP-5751
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date July 2021
*/
public without sharing class PP_ChangePassword_CTRL {
    
    public String oldPassword { get; set; }
    public String newPassword { get; set; }
    public String newPassword2 { get; set; }
    public Boolean isPasswordExpired { get; set; }
    

    /**
    * @description | Constructor
    * @author Syed Ovais Ali | July 2021
    **/
    public PP_ChangePassword_CTRL(){
         isPasswordExpired();
    }
        
     /**
    * @description | Used to Validate Password
    * @author Peter Guest July 2021 
    * @return Boolean
    **/
    public PageReference validPassword() {
        PageReference redirectPage = null;
        
        User usr = new User(Id=UserInfo.getUserId(), Username=UserInfo.getUserName());
       
        if(!Test.isRunningTest()){
            Site.validatePassword(usr, newPassword, newPassword2);  
        }
        if(ApexPages.getMessages().size() == 0) {            
            redirectPage = changePassword();                        
        }
        
        return redirectPage;
    }
    
     /**
    * @description | Used to Change Password of Community User
    * 
    * @author Peter Guest | July 2021 
    * @return Boolean
    **/ 
    public PageReference changePassword() {
        
        if(string.isEmpty(oldPassword)){
            oldPassword = null;
        }
        
        return Site.changePassword(newPassword, newPassword2, oldPassword); 
    } 
      
     /**
    * @description | Used to Check if Password has expired
    * 
    * @author Syed Ovais Ali | July 2021 
    **/  
    private void isPasswordExpired() {
        isPasswordExpired = Site.isPasswordExpired();
    }
}