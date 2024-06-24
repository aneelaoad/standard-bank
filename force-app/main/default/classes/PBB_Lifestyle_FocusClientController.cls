/**
* @FuncArea PBB Lifestyle
* @Author Zofia Walczewska
* @Date   25.10.2019.
* @UserStory  US-4311
* @Description  APEX Controller class for PBB_Lifestyle_FocusClient component.
*/
public without sharing class PBB_Lifestyle_FocusClientController {
	public class wrapperClass {
		@AuraEnabled public Account acc { get; set; } 
		@AuraEnabled public Revenue_and_Profitability__c rev { get; set; }

	}
	/**
	* @param Id 	      user ID 	   Current User Id
	*
	* @return PBB_Lifestyle_FocusClientController.wrapperClass	  wrapperList
    *                   Current user's list of Accounts and related to them Revenue and Profitabilities records.
	* @DESCRIPTION Retrieves the List of Accounts owned by current user and the most recent related
    *					Revenue and Profitability record to each of those Accounts.
	*/
	@AuraEnabled
	public static List<wrapperClass> fetchAccounts() {
		List<Account> accList = [SELECT Id, Name, BPID__c,
									(SELECT Id, YTD_Operating_Income__c, YTD_Net_Interest_Income__c, YTD_Non_Interest_Revenue__c
										FROM Revenues_and_Profitabilities__r
										ORDER BY PMT_extract_date__c DESC, CreatedDate DESC LIMIT 1)
									FROM Account
									WHERE OwnerId = :UserInfo.getUserId()
									AND id in (SELECT Client_Name__c
												FROM Revenue_and_Profitability__c
												WHERE Client_Name__r.OwnerId = :UserInfo.getUserId())];
		List<wrapperClass> wrapperList = new List<wrapperClass> ();
		for (Account acc : accList) {
			wrapperClass wrapper = new wrapperClass();
			wrapper.acc = acc;
			for (Revenue_and_Profitability__c revenue : acc.Revenues_and_Profitabilities__r) {
				wrapper.rev = revenue;
			}
			wrapperList.add(wrapper);
		}
		return wrapperList;
	}
}