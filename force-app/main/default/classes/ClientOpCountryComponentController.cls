/*****************************************************************************************************************************************************************************************************************
    @ Author        : Shubham Khilauria
    @ Date          : 13 - Feb - 2014
    @ Test File     : Test_ClientOpCountryCompController
    @ Description   : Used in Client Plan Phase 3. This class contains the functionality for displaying client operating countries
    				  present on a client. This class is controller of visual force component displayed on Client Plan page and controller
    				  of page (StandardCOCDisplay.page) used to display client operating countries on CLient detail page with edit logic.
    				  Edit button will take user to drag and drop page for changing client operating countries/ changing their status.
 ******************************************************************************************************************************************************************************************************************/

public class ClientOpCountryComponentController {

	public string acctId{get;set;}
	public Account currentAccount {get;set;}
	public map<string,string> mapCIBPresentCountries {get;set;}
	public map<string,string> mapNotCIBPresentCountries {get;set;}
	public Boolean redirect {get;set;}
	public string redirectUrl{get;set;}
	public String currentUserId;

	public static final set<string> countryStatusSet = new set<String>{'Existing Business','Prospective Business'};
	public static final string noneString = '';

	/**
	 * @author :- Shubham Khilauria
	 * @date  :-  Feb -2014
	 * @description :- - Constructor of the class, used to initialize member variables used on client detail page. This will call
	 					 a method to populate client operating countries for a client.
	 * @param :- Standard Controller reference, in this case it is Account
	 * @return :- N/A
	 */
	public ClientOpCountryComponentController(ApexPages.StandardController std){
		currentAccount = (Account) std.getRecord();
		this.currentUserId = UserInfo.getUserId();
		redirect = false;
		callFromConstructor();
	}
	/**
	 * @author :- Shubham Khilauria
	 * @date  :-  Feb -2014
	 * @description :- - Constructor of the class, used to initialize member variables used on client Plan page. Invoked from 
	 					 visualforce component present on client plan page.This will call a method to populate client operating 
	 					 countries for a client.
	 * @param :- N/A
	 * @return :- N/A
	 */
	public ClientOpCountryComponentController(){

		callFromConstructor();
	}

	/**
	 * @author :- Shubham Khilauria
	 * @date  :-  Feb -2014
	 * @description :- - called from both constructors of the class, used to initialize member variables This will call a method 
	 					 to populate client operating countries for a client.
	 * @param :- N/A
	 * @return :- N/A
	 */
	public void callFromConstructor(){
		if(acctId==null)
			acctId = ApexPages.currentPage().getParameters().containsKey('Id')?ApexPages.currentPage().getParameters().get('Id'):currentAccount.Id;
			mapCIBPresentCountries = new map<String,String>();
			mapNotCIBPresentCountries = new map<String,String>();
			fetchClientOperCountry();

	}

	/* @description :- - Check Current UserRole to Control Access to the Client Operating Country Edit Link. Will provide access to all client team 
						 members along with their managers in the org.
	 */
	public Boolean canChangeCOC { get {
		List<Id> teamMembersIds = new List<Id>();

		for (AccountShare acctShare :[SELECT Id from AccountShare WHERE AccountAccessLevel = 'Edit' AND AccountId = :acctId AND RowCause = 'Manual' AND UserOrGroupId = :currentUserId]){
			return true;
		}
		for (AccountTeamMember teamMember : [Select UserId From AccountTeamMember Where AccountId =: acctId]){
			if (userInfo.getUserId() == teamMember.UserId){
				return true;
			}
			teamMembersIds.add(teamMember.UserId);
		}
		if (teamMembersIds.size() > 0) {
			return RoleUtility.isManagerOfUsers(teamMembersIds, currentUserId );
		}
		return false;
	}  private set;
	} 


	/**
	 * @author :- Shubham Khilauria
	 * @date  :-  Feb -2014
	 * @description :- - called from both constructors of the class, used to populate client operating countries for a client. This method will
	 					 populate two maps for CIB present and CIB absent countries.
	 * @param :- N/A
	 * @return :- N/A
	 */
	public void fetchClientOperCountry(){
		for(Client_Operating_Countries__c cOP : [SELECT id,name,country__c,status__c,CIB_Presence__c, client_name__c
		                                         FROM Client_Operating_Countries__c WHERE client_name__c = : acctId order by country__c]){
			String tempString = '';
			if(cOP.CIB_Presence__c && mapCIBPresentCountries!=null)
				mapCIBPresentCountries = populateMapCountry(mapCIBPresentCountries,cOP.status__c,cOP.country__c);
			else if(!cOP.CIB_Presence__c && mapNotCIBPresentCountries!=null)
				mapNotCIBPresentCountries = populateMapCountry(mapNotCIBPresentCountries,cOP.status__c,cOP.country__c);
		}
		system.debug('---mapCIB----'+mapCIBPresentCountries);
		populateNoneValues(mapCIBPresentCountries);
		populateNoneValues(mapNotCIBPresentCountries);

	}

	/**
	 * @author :- Shubham Khilauria
	 * @date  :-  Feb -2014
	 * @description :- - utility method called from fetchClientOperCountry(), used to populate map with key as status of country and
	 					 value as combination of all countries on that status. Country Names are separated by semicolon ';'.
	 * @param :-map<String,String> , String countryStatus, String CountryName
	 * @return :- map<String,String>
	 */
	public map<string,string> populateMapCountry(map<String,String> mapCountry, string status, string country){
		String tempString = '';
		if(mapCountry.containsKey(status))
			tempString = mapCountry.get(status);
		tempString += country + '; ';
		mapCountry.put(status,tempString);

		return mapCountry;
	}

	/**
	 * @author :- Shubham Khilauria
	 * @date  :-  Feb -2014
	 * @description :- - utility method called from fetchClientOperCountry(), used to populate none values in the map where country is not 
	 					 present for that status.
	 * @param :- map<String,String>
	 * @return :- N/A
	 */
	public void populateNoneValues(map<string,string> mapCountry){
		if(mapCountry!=null && !mapCountry.keyset().containsAll(countryStatusSet)){
			for(String status : countryStatusSet){
				if(!mapCountry.containsKey(status))
					mapCountry.put(status,noneString);
			}
		}
	}

	/**
	 * @author :- Shubham Khilauria
	 * @date  :-  Feb -2014
	 * @description :- - Redirection method called from Edit Link on Visual force page, used to redirect user to drag and drop page 
	 					 respective to CIB present and CIB absent edit link press.
	 * @param :- N/A
	 * @return :- pagereference
	 */
	public pageReference editCOCRecord(){
		String presence = 'false';
		if(ApexPages.currentPage().getParameters().containsKey('presence'))
			presence = ApexPages.currentPage().getParameters().get('presence');
		redirect = true;
		redirectUrl = '/apex/ClientOperatingCountryPage?presence='+presence+'&Id=' + acctId ;
		return null;
	}


}