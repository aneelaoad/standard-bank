/**
 * @description Apex Controller for AddCustomClient lightning web component
 *
 * @author Konrad Bruszewski
 * @date February 2022
 */
public without sharing class AddCustomClient_Controller {

    /**
     * Return true if Visible to Client field should be displayed on the AddCustomClient component. Returns false otherwise
     *
     * @param clientId - id of the client for which check is performed
     *
     * @return Boolean
     */
    @AuraEnabled
    public static Boolean showVisibleToClient(String clientId){
        Boolean result;
        try{
            if(clientId == null || Id.valueOf(clientId).getSobjectType() != Account.SObjectType){
                return false;
            }
            if(FeatureManagement.checkPermission(SEL_CustomPermissions.CIB_EDIT_CST_VISIBLE_TO_CLIENT)){
                return true;
            }
            Map<Id, DMN_ClientTeam.CcCcbmWrapper> clientId2CAndCcbm = DMN_ClientTeam.getCcAndCcBmsMap(new Set<Id>{clientId});
            DMN_ClientTeam.CcCcbmWrapper wrapper = clientId2CAndCcbm.get(clientId);
            result = (wrapper.cc == UserInfo.getUserId() || wrapper.ccbm == UserInfo.getUserId()) && CR_Container_Controller.isUserCib();
        } catch (Exception ex){
            result = false;
        }
        return result;
    }
}