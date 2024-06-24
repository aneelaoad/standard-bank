/*************************************************************************
    @ Author        : milipinski
    @ Date          : March 6, 2017
    @ TestClass     : StdBank_Ltn_QuickLinks_Test
    @description   : US-1937
****************************************************************************/
public class StdBank_Ltn_QuickLinks_Ctrl {
	/**
    * ge Quick Links
    * @param columns Id
    * @param componentContext String
    * @return Map<Decimal,List<QuickLinks__c>>
    */
	@AuraEnabled
	public static Map<Decimal,List<QuickLinks__c>> getQuickLinks( List<Decimal> columns, String componentContext){
        String currentUserDivision = [Select User_Division__c From User Where Id = :UserInfo.getUserId()][0].User_Division__c;
        System.debug(currentUserDivision);
        System.debug(componentContext);
		Map<Decimal,List<QuickLinks__c>> linksToReturn = new Map<Decimal,List<QuickLinks__c>>();
		//GET	 
		List<QuickLinks__c> allLinks = [SELECT Icon__c, Label_del__c, Link__c, Order__c, Column_Id__c, Show_for_Division__c, Object_Visibility__c
										FROM  QuickLinks__c WHERE Column_Id__c in :columns ORDER BY Order__c];
		//DEVIDE
		
		for(QuickLinks__c link : allLinks){
            String showForDivision = link.Show_for_Division__c;
            String objectVisibility = link.Object_Visibility__c;
            if(showForDivision.contains(currentUserDivision) && objectVisibility.contains(componentContext)){
                if(linksToReturn.containsKey(link.Column_Id__c)){
                    linksToReturn.get(link.Column_Id__c).add(link);
                } else {
                    linksToReturn.put(link.Column_Id__c, new List<QuickLinks__c>{link});
                }
        	}
		}

		System.debug(linksToReturn);
		//RETURN
		return linksToReturn;
	}





	/** this function will determine if the user should be show dashboard
	 *  @return true if the dashboard should be shown
	 */
	@AuraEnabled
	public static Boolean shouldShowDashboard(){

		String userDivision = [ SELECT User_Division__c
							     FROM User
								 WHERE Id =: UserInfo.getUserId() ][0].User_Division__c;

		return (userDivision != DMN_User.COMMB_DIVISION || userDivision != DMN_User.BB_DIVISION ||
				userDivision != DMN_User.ENTREPRENEUR_DIVISION);
	}//end of function definition


}