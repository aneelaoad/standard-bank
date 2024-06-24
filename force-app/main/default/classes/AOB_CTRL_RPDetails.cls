/**
 * Calling the Get and Update RP details
 * @author dayakar
 * @date Oct 29th 2021
 */
public class AOB_CTRL_RPDetails{
   /**
    * @description calling the Get RP congfir API
    * @param Applicationid
    */
    @AuraEnabled
    public static void CallGetApplication(String Applicationid){
        System.enqueueJob(new AOB_SRV_GetRPconfig(Applicationid));    
    }
    
    
}