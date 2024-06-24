/**
 *
 * @author Emmanuel Mulea Nocks(BlueSky)
 * @date Oct 2020
 * @description Getting a list of Country codes from a custom setting
 */
public with sharing class ComboBoxMobileNumberCodes {

    /**
    * Getting a list of Country codes from a custom setting
    * @return listOfCountryCodes
    */
    @AuraEnabled
    public static List<CountryCodes__c> getListOfCountryCodes(){

        List<CountryCodes__c> listOfCountryCodes = new List<CountryCodes__c>();
        Map<String,CountryCodes__c> mapCountries = CountryCodes__c.getall();
        List<String> countryNames = new List<String>();
        countryNames.addAll(mapCountries.keySet());
        countryNames.sort();

        for (String countryName : countryNames) {
            CountryCodes__c country = mapCountries.get(countryName);
            listOfCountryCodes.add(country);
        }
        return listOfCountryCodes;
    }
}