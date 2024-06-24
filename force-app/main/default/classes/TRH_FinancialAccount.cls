/**
 *
 * @description TRH_FinancialAccount class for handling trigger permission set logic for Financial Account
 *
 * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
 * @date July 2022
 */
@SuppressWarnings('PMD')
public without sharing class TRH_FinancialAccount extends ABS_TriggerHandlerBase{
    private List<Financial_Account__c> records
    {
        get { return (List<Financial_Account__c>)Trigger.new; }
    } 
    
	public override void handleBeforeInsert()
    {
        Boolean isAllowed = OSB_FAP_CountryValidation.checkActivatedCountry(records);
        if(isAllowed == false){
            trigger.New[0].adderror(System.Label.OSB_VA_Related_country_not_activated); //related country
        }
        Boolean isUserCoutryAllowed = OSB_FAP_CountryValidation.checkUserCountryFA(records);
        if(isUserCoutryAllowed == false){
            trigger.New[0].adderror(System.Label.OSB_VA_User_not_allowed);
        }
	}
}