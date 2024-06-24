/**
* This is the server-side controller class for OSBDeviceManagement aura component
* 
* @author Rasmi Panthangi (rasmi.panthangi@tetrad.co.za)
* @date April 2021
* 
*/
public without sharing class OSB_DeviceManagement_CTRL {
   
     /**
     * Checks if the current user is login to community
     *
     * @return Boolean
     **/
    @AuraEnabled(Cacheable=true)
    public static Boolean isUserLoggedIn() {
        return UTL_User.isLoggedInUser();
    }
    
    /**
     * Gets the list of registered devices for MFA 
     *
     * @return Map<String,Map<String,Object>>
     **/
    @AuraEnabled(Cacheable=true)
    public static Map<String,Map<String,Object>> getDeviceDetails(){
        Map<String,Map<String,Object>> deviceDetailsMap = new Map<String,Map<String,Object>>();
        try{
        deviceDetailsMap = OSB_SRV_NoknokIntegration.newInstance().getDeviceList();
        }
        catch (Exception e) {
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_DeviceManagement_CTRL.class.getName()); 
        }
        return deviceDetailsMap; 
    }
    
    /**
     * Deletes the list of selected device authenticators that are registered fro MFA. 
     * @param List<string> 
     * @return List<Map<String,String>>
     **/
   @AuraEnabled(Cacheable=false)
    public static List<Map<String,String>> deleteDevices(List<String> authHandleList){
        List<Map<String, String>> deleteRegReponseList = new  List<Map<String, String>>();
        try{
        for(String authHandle : authHandleList){        
        Map<String,String> eachDeleteRegReponseMap = OSB_SRV_NoknokIntegration.newInstance().deleteRegisteredDevice(authHandle);
            deleteRegReponseList.add(eachDeleteRegReponseMap);
        }
        }
        catch (Exception e) {
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_DeviceManagement_CTRL.class.getName());
        }
        return deleteRegReponseList;
    }
}