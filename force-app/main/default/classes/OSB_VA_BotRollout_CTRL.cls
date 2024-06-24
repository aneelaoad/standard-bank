/**
 *
 * Controller class with logic invoked from the OneHub chat bot
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date February 2021
 */
@SuppressWarnings('PMD.CognitiveComplexity')
public with sharing class OSB_VA_BotRollout_CTRL {
    public static final List<Enhanced_VA_Rollout_Country__mdt> COUNTRIES = [SELECT Id, Label FROM Enhanced_VA_Rollout_Country__mdt];

    /**
     * Method checks if enhanced chat bot services are enabled for at least one of Contact's operating countries
     *
     * @param contactIds
     *
     * @return List<Boolean> true for contacts with with operating countries for which services are enabled
     */
    @InvocableMethod
    public static List<Boolean> isVAEnabledForContactCountry(List<String> contactIds) {
        List<Boolean> result = new List<Boolean>();
        Set<Id> conIdsSet = new Set<Id>();
        for(String contactId: contactIds){
            if(contactId != null){
                conIdsSet.add(Id.valueOf(contactId));
            }
        }
        List<Contact> contacts = SEL_Contacts.newInstance().selectById(conIdsSet);
        Map<String, Contact> id2Contact = new Map<String, Contact>(contacts);

        for (String contactId : contactIds) {
            if(contactId == null){
                result.add(false);
                continue;
            }
            Boolean isEnhancedVAEnabledForContactCountry = false;
            Contact con = id2Contact.get(contactId);
            if(con.OSB_Operating_Country__c != null){
                List<String> operatingCountries = con.OSB_Operating_Country__c.split(';');
                for(Enhanced_VA_Rollout_Country__mdt country : COUNTRIES){
                    if(operatingCountries.contains(country.Label)){
                        isEnhancedVAEnabledForContactCountry = true;
                        break;
                    }
                }
            } else {
                result.add(false);
                continue;
            }
            result.add(isEnhancedVAEnabledForContactCountry);
        }
        return result;
    }
}