/**
 * @FuncArea PBB Lifestyle
 * @Author Zofia Walczewska
 * @Date 06.03.2020
 * @UserStory
 * @Description Apex controller class for PBB_Lifestyle_ContactInformation aura component
 */
public with sharing class PBB_Lifestyle_ContactInformationCTRL {
    private static final PBB_SRV_GatewayApi_GetCustomers.IService customerInfoService = PBB_SRV_GatewayApi_GetCustomers.newInstance();
    /**
     * Method (which is used by PBB_Lifestyle_ContactInfo component) that calls the PBB_SRV_GatewayApi_GetCustomers method
      * and returns a List of Contacts Information received from the API
     *
     * @param clientId
     *
     * @return
     */
    @AuraEnabled
    public static PBB_SRV_GatewayApi_GetCustomers.ContactObject[] fetchContactInfo(Id clientId) {
        List<PBB_SRV_GatewayApi_GetCustomers.ContactObject> response = new List<PBB_SRV_GatewayApi_GetCustomers.ContactObject> ();
        try {
            response = customerInfoService.getCustomerContacts(clientId);
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return response;
    }
}