/*****************************************************************************************************************************************************************************************************************
    @ Author        : Shubham Khilauria
    @ Date          : 13 - Feb - 2014
    @ Test File     : TestClientOpCountryControllerClass
    @ Description   : Used in Client Plan Phase 3. This class contains the functionality for Drag and Drop Page
    				  where user have access to drag and drop countries from one status to other. Also can reassign
    				  the status to existing countries. Focus of this class is to create Client Operating Countries
    				  with or without CIB Presence.

    @ Last Modified By  	: Petr Svestka
    @ Last Modified On  	: 11 - Aug - 2015
    @ Last Modified Reason  : Force.com reviewer - Blocker and Critical issues - 20150608.xlsx
 ******************************************************************************************************************************************************************************************************************/

public with sharing class ClientOperatingCountryControllerClass {

	// holder to contain Client Id
	public string clientId;
	public string CIBPresence;
	public boolean boolCIBPresence {get;set;}

	public map<string ,Client_Operating_Countries__c> mapCOC ;
	public map<boolean,List<ClientOperCountry>>  mapNAAssignedList {get;set;}

	// Map contains map<CIBPresence,map<Existing/Prospective,map<CountryName,CountryRecord>>>
	public map<String,List<ClientOperCountry>> mapOld_statusVsCountryAssigned {get;set;}
	public map<String,List<String>> mapNew_statusVsCountryAssigned {get;set;}		

	//With CIB Presence
	public list<ClientOperCountry> CIBPresenceListEB {get;set;}
	public list<ClientOperCountry> CIBPresenceListPB {get;set;}

	/**
	 * @author :- Shubham Khilauria
	 * @date  :-  Feb -2014
	 * @description :- - Constructor of the class, used to get the values present in page URL.
       					 - Also initialize the member variables to be used in current context.
       					 - Prepare the country containers for existing Client Operating Country
       					   records. Call populateCountryList() method
	 * @param :- Standard Controller reference, in this case it is Account
	 * @return :- N/A
	 */
	public ClientOperatingCountryControllerClass(ApexPages.StandardController controller) {

		boolCIBPresence = false;
		clientId = ApexPages.currentPage().getParameters().get('id');

		CIBPresence = ApexPages.currentPage().getParameters().get('presence');
		if(CIBPresence.contains('true'))
			boolCIBPresence = true;
		Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=8');

		//called to initialize the variables
		initialize();

		//populate Client Operating Countries
		populateCountryList();
	}

	/**
	 * @author :- Shubham Khilauria
	 * @date  :-  Feb -2014
	 * @description :- - Initialise the member variables used in current Context and prepare the fresh copy of them.
	 * @param :- N/A
	 * @return :- void
	 */
	public void initialize(){
		//Initializing member variables
		// container for Not Assigned Countries. Will contain the list of countries not assigned to any status
		mapNAAssignedList = new map<boolean,List<ClientOperCountry>>();

		// container for existing values of Client Operating Countries Records. This will be initialized only once
		// and will not change value during the transaction.
		mapOld_statusVsCountryAssigned = new map<String,List<ClientOperCountry>>();

		// Existing business list of countries
		CIBPresenceListEB = new list<ClientOperCountry>();
		// Prospective business list of countries
		CIBPresenceListPB = new list<ClientOperCountry>();
	}

	/**
	 * @author :- Shubham Khilauria
	 * @date  :-  Feb -2014
	 * @description :- This method will query the existing records of Client Operating Countries 
       					 and populate value to respective place holders to display value on page as
       					 soon as user lands on drag and drop page.
	 * @param :- N/A
	 * @return :- void
	 */
	public void populateCountryList(){
		// Query existing records of Client Operating Countries to populate the containers.   
		list<Client_Operating_Countries__c> cocList = [SELECT CIB_Presence__c, Client_Name__c, Name, Country__c,  
		                                               Id, Status__c FROM Client_Operating_Countries__c
		                                               where Client_Name__c = : clientId Order By Country__c ];

		mapCOC = new map<String ,Client_Operating_Countries__c>();

		for(Client_Operating_Countries__c coc : cocList){
			mapCOC.put(coc.Country__c , coc);
		}

		//Get Custom Setting Data and populate the Countries Not Assigned container
		List<CS_Client_Operating_Countries__c> lstCountries = CS_Client_Operating_Countries__c.getAll().values();
		Map<String, CS_Client_Operating_Countries__c> CS_COC_Map = new Map<String, CS_Client_Operating_Countries__c>();

		for (CS_Client_Operating_Countries__c cOC: lstCountries) {
			CS_COC_Map.put(cOC.Country_Name__c, cOC);
		}

		//Checking the custom setting size
		if(CS_COC_Map.values().size() >0){
			CS_COC_Map.values().sort();
			system.debug(CS_COC_Map.values());
			system.debug(lstCountries);
			//Checking the Client Opearting Country list size
			if(cocList.size()>0){
				for (CS_Client_Operating_Countries__c csCOClst : lstCountries){
					List<ClientOperCountry> NAssignedlist = new List<ClientOperCountry>();
					List<ClientOperCountry> countryAssigned = new List<ClientOperCountry>();
					if(mapCOC.containsKey(csCOClst.Country_Name__c)){

						Client_Operating_Countries__c COCObj = mapCOC.get(csCOClst.Country_Name__c) ;

						if((COCObj.CIB_Presence__c && boolCIBPresence) || !(COCObj.CIB_Presence__c || boolCIBPresence)){
							if(COCObj.Status__c == 'Existing Business'){
								CIBPresenceListEB.add(new ClientOperCountry(new  Client_Operating_Countries__c(),'Existing Business',COCObj.Country__c,COCObj.CIB_Presence__c));
							}
							if(COCObj.Status__c == 'Prospective Business'){
								CIBPresenceListPB.add(new ClientOperCountry(new Client_Operating_Countries__c(),'Prospective Business',COCObj.Country__c,COCObj.CIB_Presence__c));
							} 
							if(mapOld_statusVsCountryAssigned!=null && mapOld_statusVsCountryAssigned.containsKey(COCObj.Status__c))
								countryAssigned = mapOld_statusVsCountryAssigned.get(COCObj.Status__c);
							countryAssigned.add(new ClientOperCountry(COCObj ,COCObj.Status__c,COCObj.Country__c,COCObj.CIB_Presence__c));
							mapOld_statusVsCountryAssigned.put(COCObj.Status__c,countryAssigned);
						}
					}
					else{
						Client_Operating_Countries__c cocnew = new Client_Operating_Countries__c();
						if(mapNAAssignedList!=null && mapNAAssignedList.containsKey(csCOClst.CIB_Presence__c))
							NAssignedlist = mapNAAssignedList.get(csCOClst.CIB_Presence__c);
						NAssignedlist.add(new ClientOperCountry(cocnew ,csCOClst.Country_Name__c, csCOClst.CIB_Presence__c));
						mapNAAssignedList.put(csCOClst.CIB_Presence__c,NAssignedlist);
					}
				}
			}  
			else{
				for (CS_Client_Operating_Countries__c csCOC : lstCountries){
					Client_Operating_Countries__c cocnew = new Client_Operating_Countries__c();
					List<ClientOperCountry> NAssignedlist = new List<ClientOperCountry>();
					if(mapNAAssignedList!=null && mapNAAssignedList.containsKey(csCOC.CIB_Presence__c))
						NAssignedlist = mapNAAssignedList.get(csCOC.CIB_Presence__c);
					NAssignedlist.add(new ClientOperCountry(cocnew ,csCOC.Country_Name__c, csCOC.CIB_Presence__c));
					mapNAAssignedList.put(csCOC.CIB_Presence__c,NAssignedlist);
				}
			}
		}
	}

	/**
	 * @author :- Shubham Khilauria
	 * @date  :-  Feb -2014
	 * @description :- This method will save the changes made by user like moving countries from one status to another
       					 and also will delete the exisitng records for which status of countries got changed. Also this method
       					 will redirect to Client Plan page after successful save of records.
	 * @param :- N/A
	 * @return :- pageReference
	 */
	public pageReference saveRecords(){

		List<Client_Operating_Countries__c> lstInsertRecords = new List<Client_Operating_Countries__c>();
		List<Client_Operating_Countries__c> lstDeleteRecords = new List<Client_Operating_Countries__c>();

		for(ClientOperCountry cOpCountryWrap : CIBPresenceListEB){
			Client_Operating_Countries__c cOpCountry = prepareCOORecord(cOpCountryWrap);
			lstInsertRecords.add(cOpCountry);
		}
		for(ClientOperCountry cOpCountryWrap : CIBPresenceListPB){
			Client_Operating_Countries__c cOpCountry = prepareCOORecord(cOpCountryWrap);
			lstInsertRecords.add(cOpCountry);
		}

		// Records to Delete
		for(String status : mapOld_statusVsCountryAssigned.keySet()){
			for(ClientOperCountry cOpCountryWrap : mapOld_statusVsCountryAssigned.get(status)){
				Client_Operating_Countries__c cOpCountry = prepareCOORecord(cOpCountryWrap);
				lstDeleteRecords.add(cOpCountry);
			}
		}
		delete lstDeleteRecords;
		upsert lstInsertRecords;


		return pageRedirect();
	}

	/**
	 * @author :- Shubham Khilauria
	 * @date  :-  Feb -2014
	 * @description :- This method will prepare the Client Operating Country reference from the received wrapper class instance. Used
       					 to populate the COC record with client name and other values like - country, status etc.
	 * @param :- ClientOperCOuntry wrapper class instance
	 * @return :- Client_Operating_Countries__c instance
	 */
	public Client_Operating_Countries__c prepareCOORecord(ClientOperCountry cOpCountryWrap){
		Client_Operating_Countries__c cOpCountry = new Client_Operating_Countries__c();
		cOpCountry = cOpCountryWrap.coCountry;
		cOpCountry.CIB_Presence__c = cOpCountryWrap.cibPresence;   
		if(cOpCountryWrap.coCountry.client_name__c == null)  	
			cOpCountry.Client_Name__c = clientId;
		cOpCountry.Country__c = cOpCountryWrap.cocCountry;
		cOpCountry.Status__c = cOpCountryWrap.cocStatus;
		return cOpCountry;
	}

	/**
	 * @author :- Shubham Khilauria
	 * @date  :-  Feb -2014
	 * @description :- This method will redirect to Client Plan Page after click on Save or Cancel.
	 * @param :- N/A
	 * @return :- pageReference
	 */
	public pagereference pageRedirect(){
		return new Pagereference('/'+clientId);
	}

	/**
	 * @author :- Shubham Khilauria
	 * @date  :-  Feb -2014
	 * @description :- This method will redirect to Client Plan Page without saving records after click on Cancel.
	 * @param :- N/A
	 * @return :- pageReference
	 */
	public pageReference cancel(){

		return pageRedirect();
	}

	/**
	 * @author :- Shubham Khilauria
	 * @date  :-  Feb -2014
	 * @description :- This method is invoked whenever a Country is picked and dropped to some another container
       					 It will add country to destination list and remove values from the source container list based on the country.
	 * @param :- N/A
	 * @return :- pageReference
	 */
	public void updateClientOperatingCountry(){

		//Savepoint sp = Database.setSavepoint();
		try{
			//Variable to contain the destination DIV Id
			String  statusCounPresence        = Apexpages.currentPage().getParameters().get('StatusPres');
			// Variable to contain the country name appended with source container's DIV Id.
			String  countryName               = Apexpages.currentPage().getParameters().get('Country');

			String sourceContainer = countryName.split('-')[1];
			countryName = countryName.split('-')[0];

			//Removing values from source container
			if(sourceContainer.equals('EBPreCount'))
				CIBPresenceListEB = removeFromList(CIBPresenceListEB,countryName);
			if(sourceContainer.equals('PBPreCount'))
				CIBPresenceListPB = removeFromList(CIBPresenceListPB,countryName);
			if(sourceContainer.equals('NAPreCount') && mapNAAssignedList!=null && mapNAAssignedList.containsKey(boolCIBPresence)){
				List<ClientOperCountry> NAssignedlist = new List<ClientOperCountry>();
				NAssignedlist = removeFromList(mapNAAssignedList.get(boolCIBPresence),countryName);
				mapNAAssignedList.put(boolCIBPresence,NAssignedlist);
			}

			//Adding values to the Lists
			if(statusCounPresence.equals('EBPreCount'))
				CIBPresenceListEB.add(new ClientOperCountry(new Client_Operating_Countries__c(),'Existing Business',CountryName,boolCIBPresence));
			if(statusCounPresence.equals('PBPreCount'))
				CIBPresenceListPB.add(new ClientOperCountry(new Client_Operating_Countries__c(),'Prospective Business',CountryName,boolCIBPresence));
			if(statusCounPresence.equals('NAPreCount') && mapNAAssignedList!=null && mapNAAssignedList.containsKey(boolCIBPresence)){
				List<ClientOperCountry> NAssignedlist = new List<ClientOperCountry>();
				NAssignedlist = mapNAAssignedList.get(boolCIBPresence);
				NAssignedlist.add(new ClientOperCountry(new Client_Operating_Countries__c(),CountryName, boolCIBPresence));
				NAssignedlist.sort();
				mapNAAssignedList.put(boolCIBPresence,NAssignedlist);
			}
			CIBPresenceListEB.sort();
			CIBPresenceListPB.sort();
		}
		catch (System.Dmlexception e){
			System.debug(e);
		}
	}

	/**
	 * @author :- Shubham Khilauria
	 * @date  :-  Feb -2014
	 * @description :- This method is used to remove particular value from the input list.This method will receive input List and the COuntry name.
       					 List is iterated over to see if it contains the list. If Country is present, remove the value from the list.
	 * @param :- List<ClientOperCOuntry> , String
	 * @return :- List<ClientOperCountry>
	 */
	public List<ClientOperCountry> removeFromList(List<ClientOperCountry> lstCountry, String countryName){
		for(Integer index=lstCountry.size()-1;index>=0;index--){
			if(lstCountry[index].cocCountry.contains(countryName))
				lstCountry.remove(index);
		}
		system.debug('---------Remove Country List---'+lstCountry);
		return lstCountry;
	}

}