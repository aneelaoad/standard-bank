/**
 *
 * @description Controller class OSB_VA_CountryName_CTRL with logic invoked from the OneHub chat bot for retrieving country name variable
 *
 * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
 * @date March 2022
 */
@SuppressWarnings('PMD.CognitiveComplexity, PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity, PMD.NcssMethodCount, PMD.UnusedLocalVariable')
public with sharing class OSB_VA_CountryName_CTRL {
    private static final String DCS = 'DCS_',
                                INFO = 'Info',
                                ONE_HUB = 'OneHub';

    /**
     * @description DTO class with input params for requesting country name
     */
    public class CountryNameInput {
        @InvocableVariable
        public String contactId;
    }

    /**
     * @description DTO class with output params for requesting country name
     */
    public class CountryNameOutput {
        @InvocableVariable
        public String countryName;
        @InvocableVariable
        public Boolean oneCountryActive;
        @InvocableVariable
        public List<String> availableCountryList;
    }

    /**
     * @description Invocable method for requesting country name 
     *
     * @param inputs List
     *
     * @return List<CountryNameOutput> result
     * 
     * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
     * @date March 2022
     */
    @InvocableMethod(Label='VA get country name')
    public static List<CountryNameOutput> getCountryName(List<CountryNameInput> inputs) {
        List<CountryNameOutput> results = new List<CountryNameOutput>();
        CountryNameOutput result = new CountryNameOutput();
        result.availableCountryList = new List<String>();
        SEL_Contacts contactSelector = new SEL_Contacts();
        Set<Id> contactIds = new Set<Id>();
        Map<String, Set<String>> contactsCountriesPermissions = new Map<String, Set<String>>();

        for (CountryNameInput input : inputs) {
            contactIds.add(input.contactId);
            contactsCountriesPermissions.put(input.contactId, getDCSFAPCountries(input.contactId));
        }
        List<Contact> contacts = contactSelector.selectById(contactIds);
        if(contacts[0].OSB_Operating_Country__c == null){
            result.countryName = '';
            result.oneCountryActive = false;
            result.availableCountryList = null;
        } else {
            List<String> availableCountries = contacts[0].OSB_Operating_Country__c.split(';');
            // get permissions for Contact
            Set<String> contactPermissionCountries = new Set<String>();
            if(contactsCountriesPermissions.containsKey(contacts[0].Id)){
                Boolean setresult = contactPermissionCountries.addAll(contactsCountriesPermissions.get(contacts[0].Id));
            }

            List<DCS_country_setting__mdt> countrySettings = getDCSCountrySetting();            
            for (DCS_country_setting__mdt countryCmd : countrySettings) {
                for (String availableCountry : availableCountries) {
                    // Test if also permissoin is available
                    if(countryCmd.Name__c == availableCountry && contactPermissionCountries.contains(availableCountry) ){
                        result.availableCountryList.add(availableCountry);
                    }
                }
            }
        }
        if(result.availableCountryList != null){
            if(result.availableCountryList.size() == 1){
                result.countryName = result.availableCountryList[0];
                result.oneCountryActive = true;
            } else if (result.availableCountryList.size() > 1) {
                result.countryName = '';
                result.oneCountryActive = false;
            }
        }

        results.add(result);

        return results;
    }

    /**
     * @description getDCSCountrySetting method for selecting data from DCS_country_setting__mdt metadata object
     *
     * @return DCS_country_setting__mdt object
     * 
     * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
     * @date March 2022
     */
    private static List<DCS_country_setting__mdt> getDCSCountrySetting() {
        List<DCS_country_setting__mdt> countrySettings = [
                SELECT
                    Id,
                    Name__c,
                    Activated__c
                FROM DCS_Country_Setting__mdt
                WHERE Activated__c = TRUE
        ];
        return countrySettings;
    }

    /**
     * @description getDCSFAPCountries method for selecting data from DCS_country_setting__mdt metadata object
     *
     * @param String contactId
     * @return Set of CountryNames (String)
     * 
     * @author Martin Kacenak (martin.kacenak@standardbank.co.za)
     * @date August 2022
     */
    private static Set<String> getDCSFAPCountries(String contactId) {
        List<Financial_Account_Permission__c> contactPermissions = [
            SELECT Id, Country__c 
            FROM Financial_Account_Permission__c
            WHERE Active__c = TRUE
            AND Authorized_Person__c = :contactId
            ];
        Set<String> countryWithPermissions = new Set<String>();
        // conversion of List to set HERE - For cycle
        if(contactPermissions != null && !contactPermissions.isEmpty()){
            for(Financial_Account_Permission__c contactPerm : contactPermissions) {
                if(!String.isEmpty(contactPerm.Country__c)) {
                    System.debug('getDCSFAPCountries - detail:'+ contactPerm.Id + ' > ' + contactPerm.Country__c);
                    countryWithPermissions.add(contactPerm.Country__c);
                }
            }
        }
        return countryWithPermissions;
    }
}