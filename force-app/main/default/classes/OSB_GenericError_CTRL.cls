/**
 * Controller for Lightning Component OSBGeneralError
 * 
 * @author Ephetehe Mokgopanyane (ephetehe.mokgopanyane@tetrad.co.za)
 * @date July 2020
 */
public with sharing class OSB_GenericError_CTRL {
    
    /**
     * Prepare User Data for salesforce from the data received from Ping Auth. Provider
     * 
     * @param data User data recieved from auth provider
     * @param u User object instance created with the data
     * 
     * @return String containing Access Manager Name and Surname
     */ 
    @AuraEnabled
    public static String getApDpName(Id apDpContactId){
        List < Contact > lstContact = SEL_Contacts.newInstance()
                .selectByIdWoSharing(new Set<Id>{apDpContactId});
        return lstContact[0].FirstName + ' ' + lstContact[0].LastName;
    }

    /**
     * Used to get logout url 
     * 
     * @return String with logout url
     */ 
    @AuraEnabled
    public static String getLogoutUrl(){
        AuthProvider authProvider = [SELECT Id, LogoutUrl, DeveloperName FROM AuthProvider WHERE DeveloperName =: OSB_SRV_PingIntegration.AUTH_PROVIDER_NAME];
        return authProvider.LogoutUrl ;
    }
}