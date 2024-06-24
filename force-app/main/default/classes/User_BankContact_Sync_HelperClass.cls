/*****************************************************************************************************\
    @ Author        : Rudolf Niehaus
    @ Date          : 12/2010
    @ Test File     : None - Test Method in this class
    @ Description   : Trigger helper class that makes sure that the User Contact Sync triggers updating 
                      the objects visa versa do not run into an endless loop 
    @ Last Modified By  : Ankit Khandelwal
    @ Last Modified On  : 8/7/2013
    @ Modification Description : Updated API from 24 to 27
******************************************************************************************************/
public class User_BankContact_Sync_HelperClass {
    
    public static boolean alreadySyncUser = false;
    private static boolean alreadySyncContact = false;
    private static boolean asyncExceptionThrown = false;
    
    
    public static boolean hasAlreadySyncUser(){
        return alreadySyncUser;
    }
    public static boolean hasAlreadySyncContact(){
       
        return alreadySyncContact;
    }
    
    public static void setAlreadySyncUser(){
        alreadySyncUser = true;
    }
    public static void setAlreadySyncContact(){
        
        alreadySyncContact = true;
    }
    
    public static void setAsyncExceptionThrown(){
        asyncExceptionThrown = true;
    }
    public static boolean getAsyncExceptionThrown(){
        return asyncExceptionThrown;
    }
    
    //######################## TEST METODS #############################
    static testMethod void testMe(){
        
        User_BankContact_Sync_HelperClass.setAlreadySyncUser();
        System.assertEquals(User_BankContact_Sync_HelperClass.hasAlreadySyncUser(),true);
        User_BankContact_Sync_HelperClass.setAlreadySyncContact();
        System.assertEquals(User_BankContact_Sync_HelperClass.hasAlreadySyncContact(),true);
        User_BankContact_Sync_HelperClass.setAsyncExceptionThrown();
        System.assertEquals(User_BankContact_Sync_HelperClass.getAsyncExceptionThrown(),true);
    }

}