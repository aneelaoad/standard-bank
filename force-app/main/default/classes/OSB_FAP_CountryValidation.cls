/**
 *
 * @description OSB_FAP_CountryValidation class for handling permission set logic
 *
 * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
 * @date July 2022
 */
@SuppressWarnings('PMD.NcssMethodCount,PMD.CognitiveComplexity')
public without sharing class OSB_FAP_CountryValidation {
    private static final String DCS = 'DCS_';

    public static Boolean checkUserCountry(List<Financial_Account_Permission__c> financialAccountPermissions){
        String userId = UserInfo.getUserId();
        User runningUser = [Select Id, Country from User where Id =: userId];
        for(Financial_Account_Permission__c finAccPermission : financialAccountPermissions){
            if (finAccPermission.Country__c == runningUser.Country){
                return true;
            }
        }
        return false;
    }

    public static Boolean checkUserCountryFA(List<Financial_Account__c> financialAccounts){
        String userId = UserInfo.getUserId();
        User runningUser = [Select Id, Country from User where Id =: userId];
        for(Financial_Account__c finAcc : financialAccounts){
            if (finAcc.Country__c == runningUser.Country){
                return true;
            }
        }
        return false;
    }
    
    public static Boolean checkActivatedCountry(List<Financial_Account__c> financialAccounts){
        String userId = UserInfo.getUserId();
        User runningUser = [Select Id, Country from User where Id =: userId];
        DCS_country_setting__mdt dcsCountry  = getDCSCountrySetting(runningUser.Country);
        return dcsCountry == null ? false : dcsCountry.Activated__c;
    }

    /**
     * @description getDCSCountrySetting method for selecting data from DCS_country_setting__mdt metadata object
     *
     * @param inputCountryName String - countryName input variable
     * 
     * @return DCS_country_setting__mdt object
     * 
     * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
     * @date July 2022
     */
    private static DCS_country_setting__mdt getDCSCountrySetting(String inputCountryName) {
        String countryParameter = DCS + inputCountryName.replace(' ', '_');
        List<DCS_country_setting__mdt> connectionDetails = [
                SELECT
                    Id,
                    Statement_Email_Address__c,
                    Statement_Fault_Template__c,
                    Statement_Formal_name__c,
                    Statement_Full_Email_Address__c,
                    Statement_Template__c,
                    Email_Banner_Image__c,
                    Email_Footer_Image__c,
                    Activated__c
                FROM DCS_country_setting__mdt
                WHERE DeveloperName = :countryParameter
        ];
        
        return connectionDetails.isEmpty() ? null : connectionDetails[0];
    }
}