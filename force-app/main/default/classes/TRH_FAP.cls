/**
 *
 * @description TRH_FAP class for handling trigger permission set logic
 *
 * @author Aleksa Atanackovic (aleksa.atanackovic@standardbank.co.za)
 * @date July 2022
 */
@SuppressWarnings('PMD.AvoidDirectAccessTriggerMap')
public class TRH_FAP extends ABS_TriggerHandlerBase 
{
    private list<Financial_Account_Permission__c> records
    {
        get { return (list<Financial_Account_Permission__c>)Trigger.new; }
    } 

    public override void handleBeforeInsert()
    {
        OSB_FAP_DuplicatePrevention.preventDupe(records);

		Boolean isAllowed = OSB_FAP_CountryValidation.checkUserCountry(records);
        if(isAllowed == false){
            trigger.New[0].adderror(System.Label.OSB_VA_User_not_allowed);
        }
	}
    
    public override void handleBeforeUpdate()
    {  
        OSB_FAP_DuplicatePrevention.preventDupe(records);
	}
}