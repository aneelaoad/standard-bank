/**
 * 
    @ Last Modified By  : Bartosz Sliwinski
    @ Last Modified On  : Oct 12, 2017
    @ Modification Description : Added isOwnerManager(). US-2331 - CommB - Ecosystem: Ecosystem access in role hierarchy

    @ Last Modified By  : Bartosz Sliwinski
    @ Last Modified On  : Oct 17, 2017
    @ Modification Description : Modified createAccount(). US-2456 - CommB: Duplicate message when creating new banked client on ecosystem

	@ Last Modified By  : Emmanuel Mulea Nocks
    @ Last Modified On  : Nov 19, 2019
    @ Modification Description : Modified createAccount(). C-00003016 - CommB: Show error message when creating new client on ecosystem and query RG number from a client

    @ Last Modified By  : Emmanuel Mulea Nocks
    @ Last Modified On  : Feb 28, 2020
    @description : Ecosystem 2020 | Add Ecosystem View on Ecosystem Tab (US-4605)
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class StdBank_Ltn_Ecosystem {
	private static final PBB_SRV_GatewayApi_Conversations.IService CONVERSATION_SERVICE = PBB_SRV_GatewayApi_Conversations.newInstance();
	private static final String HAS_NO_ACCESS = 'No Access';
	/**
    * Get Account by account recordId
    *
    * @param accountId Id
    * @return Account
    */
	@AuraEnabled
	public static Account getAccount(Id accountId) {
		Account[] accounts = 
			[ SELECT Id, OwnerId, Name, CurrencyIsoCode, 
			  ( SELECT Team_Member__c FROM Custom_Client_Teams__r ) 
			  FROM Account 
			  WHERE Id = :accountId ];
		if (accounts.isEmpty()) {
			return null;
		}
		else {
			return accounts[0];
		}
	}

	/**
	* Search accounts cif Or Name
	*
	* @param cifOrName String
	* @param ecosystemId String
	* @return Account[]
	*/
	@AuraEnabled
	public static Account[] searchAccounts(String cifOrName, String ecosystemId) {
		String likeQuery = cifOrName + '%';
		Account[] accounts = 
			[ SELECT Id, Name, CIF__c
			  FROM Account
			  WHERE ( CIF__c LIKE :likeQuery
			  		  OR Name LIKE :likeQuery )
			  AND CIF__c != null
			  AND Status__c NOT IN ('Prospect', 'Potential')
			  AND Id NOT IN (SELECT Entity__c FROM Ecosystem_Entity__c WHERE Ecosystem__c = :ecosystemId)
			  LIMIT 5 ];
		return accounts;
	}
	/** 
	* Search accounts unbanked
	*
	* @param name string
	* @param ecosystemId string
	* @return Account[]
	*/
	@AuraEnabled
	public static Account[] searchAccountsUnbanked(String name, String ecosystemId) {
		String likeQuery = name + '%';
		Account[] accounts = 
			[ SELECT Id, Name, Status__c
			  FROM Account
			  WHERE Name LIKE :likeQuery 
			  AND Status__c IN ('Prospect', 'Potential')
			  AND Id NOT IN (SELECT Entity__c FROM Ecosystem_Entity__c WHERE Ecosystem__c = :ecosystemId)
			  LIMIT 5 ];
		return accounts;
	}
	/**
    * Search ecosystems
    *
    * @param groupNumber String
    * @param accountId String
    * @return Ecosystem__c[]
    */
	@AuraEnabled
	public static Ecosystem__c[] searchEcosystems(String groupNumber, String accountId) {
		return StdBank_Ltn_EcosystemNoSharing.searchEcosystems(groupNumber, accountId);
	}
	/**
    * Get currency options
    *
    * @return DTO_Ecosystem.Option[]
    */
	@AuraEnabled
	public static DTO_Ecosystem.Option[] getOptions() {

		DTO_Ecosystem.Option[] currencies = new DTO_Ecosystem.Option[]{};

		for(String curr : UTL_Currency.getCurrencies()){ 
			currencies.add(new DTO_Ecosystem.Option(curr, curr));
		}
		return currencies;
	}
	/**
    * insert or update ecosystem
    *
    * @param eco SObject
    * @return DTO_Ecosystem.SaveResult
    */
	@AuraEnabled
	public static DTO_Ecosystem.SaveResult upsertEcosystem(SObject eco) {
		Ecosystem__c ecosystem = (Ecosystem__c)eco;
		Database.UpsertResult result = Database.upsert(ecosystem, Ecosystem__c.Relationship_Group_Number__c, false);
		return new DTO_Ecosystem.SaveResult(result);
	}
	/**
    * insert or update list of SObject
    *
    * @param entities SObject[]
    * @return DTO_Ecosystem.SaveResult[]
    */
	@AuraEnabled
	public static DTO_Ecosystem.SaveResult[] upsertEntities(SObject[] entities) {
		Map<SobjectType, Sobject[]> id2record = new Map<SobjectType, Sobject[]>();
		for (SObject obj : entities) {
			SobjectType sType = ((Id)obj.get('Id')).getSObjectType();
			if(!id2record.containsKey(sType)){
				id2record.put(sType, new Sobject[]{});
			}
			id2record.get(sType).add(obj);
		}

		Sobject[] recordsToUpdate = new Sobject[]{};

		for(Sobject[] recordList : id2record.values()){
			recordsToUpdate.addAll(recordList);
		}

		Database.SaveResult[] results = Database.update(recordsToUpdate, false);
		DTO_Ecosystem.SaveResult[] saveResults = new DTO_Ecosystem.SaveResult[]{};
		for (Database.SaveResult result : results) {
			saveResults.add(new DTO_Ecosystem.SaveResult(result)); 
		}
		return saveResults;
	}
	/**
    * Delete list of SObject
    *
    * @param entities SObject[]
    * @return DTO_Ecosystem.DeleteResult[]
    */
	@AuraEnabled
	public static DTO_Ecosystem.DeleteResult[] deleteEntities(SObject[] entities,Boolean isBanked) {
		Id entityId = (Id)entities[0].get('Id');
		Ecosystem_Entity__c ecoEntity = [SELECT Id, Ecosystem__c,Entity_Type__c FROM Ecosystem_Entity__c WHERE Id =:entityId];
		Database.DeleteResult[] results = Database.delete(entities, false);
		DTO_Ecosystem.DeleteResult[] deleteResults = new DTO_Ecosystem.DeleteResult[]{};
		for (Database.DeleteResult result : results) {
			deleteResults.add(new DTO_Ecosystem.DeleteResult(result));
		}
		if(isBanked){
		StdBank_Ltn_EcosystemNoSharing.updateEcosystemKnownBanked(ecoEntity.Ecosystem__c,ecoEntity.Entity_Type__c);
		}
		return deleteResults;
	}
	/**
    * Get banked clients
    *
    * @param groupNumber string
    * @return DTO_Ecosystem.BankedClient[]
    */
	@AuraEnabled
	public static DTO_Ecosystem.BankedClient[] getBankedClients(String groupNumber) {
		DTO_Ecosystem.BankedClient[] result = new DTO_Ecosystem.BankedClient[]{};

		if (String.isNotBlank(groupNumber)) {

			for(Ecosystem_Entity__c entity : [	SELECT Ecosystem__c,Primary_Relationship_Holder__c,Name, Entity__c, Entity_Type__c, CreatedDate, CreatedBy.Name,
												    eco.Name,eco.Relationship_Group_Number__c, acc.Relationship_Group_Number__c, eco.Relationship_Group_Name__c, eco.Client_Name__r.Name,
													acc.CIF__c, acc.BPID__c, acc.Name, acc.Group_Parent__c, acc.Group_Parent__r.Name,
													acc.RecordType.DeveloperName, acc.Status__c, acc.Primary_Relationship_Holder__c,
													acc.Client_Coordinator_Name__c, acc.CIF_Client_Status__c, acc.CIF_Client_Active_Code__c,
													Status__c,Customer_Start_Date__c,BPID__c
												FROM Ecosystem_Entity__c,
													Ecosystem_Entity__c.Entity__r acc,
													Ecosystem_Entity__c.Ecosystem__r eco
												WHERE Ecosystem__r.Relationship_Group_Number__c =: groupNumber]){
				result.add(new DTO_Ecosystem.BankedClient(entity));
			}

		}
		return result;
	}
	/**
    * Get ecosystems
    *
    * @param accountId string
    * @return DTO_Ecosystem.BankedClient[]
    */
	@AuraEnabled
	public static DTO_Ecosystem.BankedClient[] getEcosystems(String accountId) {
		DTO_Ecosystem.BankedClient[] result = new DTO_Ecosystem.BankedClient[]{};

		if (String.isNotBlank(accountId)) {

			for(Ecosystem_Entity__c entity : [	SELECT Ecosystem__c,Primary_Relationship_Holder__c,Name, Entity__c, Entity_Type__c, CreatedDate, CreatedBy.Name,
												    eco.Name,eco.Id,eco.Relationship_Group_Number__c, acc.Relationship_Group_Number__c, eco.Client_Name__r.Name,eco.Relationship_Group_Name__c,
													acc.CIF__c, acc.BPID__c, acc.Name, acc.Group_Parent__c, acc.Group_Parent__r.Name,
													acc.RecordType.DeveloperName, acc.Status__c, acc.Primary_Relationship_Holder__c,
													acc.Client_Coordinator_Name__c, acc.CIF_Client_Status__c,BPID__c,Status__c,Customer_Start_Date__c
												FROM Ecosystem_Entity__c,
													Ecosystem_Entity__c.Entity__r acc,
													Ecosystem_Entity__c.Ecosystem__r eco
												WHERE Entity__c =: accountId]) {
				result.add(new DTO_Ecosystem.BankedClient(entity));
			}

			result.sort();
		}
		return result;
	}
	/**
    * Get an ecosystem by recordId
    *
    * @param ecosystemId string
    * @return Ecosystem__c
    */
	@AuraEnabled
	public static Ecosystem__c getEcosystemById(String ecosystemId) {
		Ecosystem__c result;

		if (String.isNotBlank(ecosystemId)) {
			Ecosystem__c[] ecosystems =
				[SELECT Unknown_Unbanked_Partners__c, Unknown_Unbanked_Subsidiaries__c,
						Unknown_Unbanked_Shareholders_Directors__c, Unknown_Unbanked_Debtors_Creditors__c,
						Unknown_Unbanked_Clients_Distributors__c, Unknown_Unbanked_Employees__c,
						Relationship_Group_Number__c,Relationship_Group_Name__c, Client_Name__r.Name,Client_Name__c,
						(	SELECT Ecosystem__c, Entity__c, Entity_Type__c,
							Entity__r.RecordType.DeveloperName, Entity__r.Status__c
							FROM 	Ecosystem_Entities__r)
						FROM Ecosystem__c
						WHERE Id =: ecosystemId];
			if (!ecosystems.isEmpty()) {
				result = ecosystems[0];
			}
		}
		return result;
	}
	/**
    * Get unbanked clients by groupNumber
    *
    * @param groupNumber String
    * @return Ecosystem__c
    */
	@AuraEnabled
	public static Ecosystem__c getUnbankedClients(String groupNumber) {
		return getEcosystem(groupNumber);
	}

	/**
	* @description get Ecosystem record by AccountID
	* @param accountId 	Id 	This is an account recordId
	* @return Ecosystem__c	result	,Ecosystem record
	*/
	@AuraEnabled
	public static Ecosystem__c getEcosystemClient(String accountId) {
		Ecosystem__c result  = new Ecosystem__c();
		if (String.isNotBlank(accountId)) {
			Ecosystem__c[] ecosystems =
			[SELECT Id,Name,Relationship_Group_Number__c,Relationship_Group_Name__c, Client_Name__r.Name,Owner.Name,Client_Name__c
			FROM Ecosystem__c
			WHERE Client_Name__r.id =: accountId];
			if (!ecosystems.isEmpty()) {
                result = ecosystems[0];
			}
		}
		return result;
	}
	/**
	* @description calculating the number of unbanked and banked entities that are related to a specific client US-1234
	* @param accountId 	Id 	This is an account recordId
	* @return Map<string , Object>  results	,mapped EntityType with record count
	*/
	@AuraEnabled
	public static Map<string , Object> getEcosystemStructure(Id accountId) {
		Ecosystem__c result  = new Ecosystem__c();
		Map<string , Object> results = new Map<string , Object>();
		Ecosystem__c[] ecosystems =
		[SELECT Id, Name,Relationship_Group_Number__c,Relationship_Group_Name__c, Client_Name__r.Name,Owner.Name,Client_Name__c
		FROM Ecosystem__c
		WHERE Client_Name__r.id =: accountId];

		if (ecosystems.isEmpty()) {
			result = new Ecosystem__c();
		}
		else {
			result = ecosystems[0];
		}
		if(ecosystems.size()>0){
			results.put('isEcosystem' ,true);
			results.put('ecosystemName' ,ecosystems[0].Relationship_Group_Name__c);
			results.put('Relationship_Group_Number__c',ecosystems[0].Relationship_Group_Number__c);
			List<AggregateResult> bankedEcoEntities = [SELECT  Entity_Type__c,COUNT(Id) num
			FROM Ecosystem_Entity__c
			WHERE Ecosystem__c =: ecosystems[0].Id AND (Ecosystem_Entity__c.Entity__r.CIF__c!=null
			OR Ecosystem_Entity__c.Entity__r.BPID__c!=null)
			Group By Entity_Type__c];

			List<AggregateResult> unbankedEcoEntities = [SELECT  Entity_Type__c,COUNT(Id) num
			FROM Ecosystem_Entity__c
			WHERE Ecosystem__c =: ecosystems[0].Id AND (Ecosystem_Entity__c.Entity__r.CIF__c=null
			AND Ecosystem_Entity__c.Entity__r.BPID__c=null)
			Group By Entity_Type__c];

			for(AggregateResult bankedEcoEntity:bankedEcoEntities){
				results.put('banked.'+String.valueOf(bankedEcoEntity.get('Entity_Type__c')),bankedEcoEntity.get('num'));
			}

			for(AggregateResult unbankedEcoEntity:unbankedEcoEntities){
				results.put('unbanked.'+String.valueOf(unbankedEcoEntity.get('Entity_Type__c')),unbankedEcoEntity.get('num'));
			}
		}
		else {
			results.put('isEcosystem' ,false);
		}


		return results;
	}
	/**
	* @description Querying Account Object by recordId
	* @param recordId 	RecordId 	This is an account recordId
	* @return List<Account> 	resultList	,list of accounts by ID
	*/
	@AuraEnabled
	public static Account  getClientData(String recordId) {
		Account result = SEL_Accounts.newInstance().selectById(new Set<Id>{recordId})[0];
		return result;
	}
	/**
	*@description Get ecosystem by groupNumber
	* @param groupNumber string
	* @return Ecosystem__c
	*/
	private static Ecosystem__c getEcosystem(String groupNumber) {
		Ecosystem__c result = new Ecosystem__c(Relationship_Group_Number__c = groupNumber); // initiate in case of no ecosystem
		if (String.isNotBlank(groupNumber)) {
			Ecosystem__c[] ecosystems =
				[SELECT Unknown_Unbanked_Partners__c, Unknown_Unbanked_Subsidiaries__c,
						Unknown_Unbanked_Shareholders_Directors__c, Unknown_Unbanked_Debtors_Creditors__c,
						Unknown_Unbanked_Clients_Distributors__c, Unknown_Unbanked_Employees__c,
						Ecosmart_Employees__c,Ecosmart_Supplier__c,Known_Banked_Clients_Distributors__c,
						Known_Banked_Debtors_Creditors__c,Known_Banked_Employees__c,Known_Banked_Partners__c,
						Known_Banked_Shareholders_Directors__c,Known_Banked_Subsidiaries__c,
						Known_Unbanked_Clients_Distributors__c,Known_Unbanked_Debtors_Creditors__c,Known_Unbanked_Employees__c,
						Known_Unbanked_Partners__c,Known_Unbanked_Shareholders_Directors__c,Known_Unbanked_Subsidiaries__c,
						Relationship_Group_Number__c, Client_Name__r.Name,Relationship_Group_Name__c,Client_Name__c,
						(	SELECT Ecosystem__c, Entity__c, Entity_Type__c,
							Entity__r.RecordType.DeveloperName, Entity__r.Status__c, Entity__r.CIF__c
							FROM 	Ecosystem_Entities__r)
						FROM Ecosystem__c
						WHERE Relationship_Group_Number__c =: groupNumber];

			if (ecosystems.isEmpty()) {
				result = new Ecosystem__c();
			}
			else {
				result = ecosystems[0];
			}
		}
		return result;
	}
	/**
    * Get DTF data,We assume one type per Account!
    *
    * @param groupNumber string
    * @return DTO_Ecosystem.DeliverTheFirm[]
    */
	@AuraEnabled
	public static DTO_Ecosystem.DeliverTheFirm[] getDtfData(String groupNumber){
		DTO_Ecosystem.DeliverTheFirm[] dtfs = new DTO_Ecosystem.DeliverTheFirm[]{};
		Map<Id, String> accId2Type = new Map<Id, String>();

		SB_Product__c[] products = StdBank_Ltn_EcosystemNoSharing.getProducts(groupNumber);

		if(products.isEmpty()){
			return dtfs;
		}

		for (SB_Product__c sb : products) {
			accId2Type.put(sb.Opportunity__r.AccountId, null);
		}

		for(Ecosystem_Entity__c entity : [	SELECT Entity_Type__c, Entity__c
											FROM Ecosystem_Entity__c
											WHERE Entity__c IN: accId2Type.keySet()]){
			accId2Type.put(entity.Entity__c, entity.Entity_Type__c);
		}

		for(SB_Product__c sb : products){ 
			String entityType = accId2Type.get(sb.Opportunity__r.AccountId);
			dtfs.add(new DTO_Ecosystem.DeliverTheFirm(entityType, sb));
		}
		return dtfs;
	}
	/**
    * Get DTF data pipeline
    *
    * @param groupNumber Id
    * @return DTO_Ecosystem.DeliverTheFirm[]
    */
	@AuraEnabled
	public static DTO_Ecosystem.DeliverTheFirm[] getDtfDataPipeline(String groupNumber) {
		DTO_Ecosystem.DeliverTheFirm[] dtfs = new DTO_Ecosystem.DeliverTheFirm[]{};
		Map<Id, String> accId2Type = new Map<Id, String>();

		SB_Product__c[] products = StdBank_Ltn_EcosystemNoSharing.getProductsPipeline(groupNumber);

		if(products.isEmpty()){
			return dtfs;
		}

		for(SB_Product__c sb : products){
			accId2Type.put(sb.Opportunity__r.AccountId, null);
		}

		for(Ecosystem_Entity__c entity : [	SELECT Entity_Type__c, Entity__c
											FROM Ecosystem_Entity__c
											WHERE Entity__c IN: accId2Type.keySet()]){
			accId2Type.put(entity.Entity__c, entity.Entity_Type__c);
		}

		for(SB_Product__c sb : products){ 
			String entityType = accId2Type.get(sb.Opportunity__r.AccountId);
			dtfs.add(new DTO_Ecosystem.DeliverTheFirm(entityType, sb));
		}
		return dtfs;
	}
	/**
    * Get DTF data banked
    *
    * @param groupNumber string
    * @return DTO_Ecosystem.DeliverTheFirm[]
    */
	@AuraEnabled
	public static DTO_Ecosystem.DeliverTheFirm[] getDtfDataBanked(String groupNumber) {
		DTO_Ecosystem.DeliverTheFirm[] dtfs = new DTO_Ecosystem.DeliverTheFirm[]{};
		Map<Id, String> accId2Type = new Map<Id, String>();

		SB_Product__c[] products = StdBank_Ltn_EcosystemNoSharing.getProductsBanked(groupNumber);

		if(products.isEmpty()){
			return dtfs;
		}

		for(SB_Product__c sb : products){
			accId2Type.put(sb.Opportunity__r.AccountId, null);
		}

		for(Ecosystem_Entity__c entity : [	SELECT Entity_Type__c, Entity__c
											FROM Ecosystem_Entity__c
											WHERE Entity__c IN: accId2Type.keySet()]){
			accId2Type.put(entity.Entity__c, entity.Entity_Type__c);
		}

		for(SB_Product__c sb : products){ 
			String entityType = accId2Type.get(sb.Opportunity__r.AccountId);
			dtfs.add(new DTO_Ecosystem.DeliverTheFirm(entityType, sb));
		}
		return dtfs;
	}
	/**
    * Get DTF data total value
    *
    * @param groupNumber string
    * @param currencyCode string
    * @return Decimal
    */
	@AuraEnabled
	public static Decimal getDtfTotalValue(String groupNumber, String currencyCode){
		return UTL_Currency.sumUp(StdBank_Ltn_EcosystemNoSharing.getProducts(groupNumber), 'Facility_Size__c', currencyCode);
	}
	/**
    * Get DTF data by element
    *
    * @param groupNumber string
    * @param currencyCode string
    * @return DTO_Ecosystem.DeliverTheFirm[]
    */
	@AuraEnabled
	public static DTO_Ecosystem.DeliverTheFirm[] getDtfDataByElement(String groupNumber, String currencyCode){
		DTO_Ecosystem.DeliverTheFirm[] dtfs = new DTO_Ecosystem.DeliverTheFirm[]{};
		Map<String, Decimal> elemntType2Value = new Map<String, Decimal>();
		initiateMap(elemntType2Value, 0);

		for(DTO_Ecosystem.DeliverTheFirm sb : getDtfData(groupNumber)){
			if(String.isBlank(sb.elementType) || !elemntType2Value.containsKey(sb.elementType)){
				continue;
			}

			if(sb.notionalValue != null && sb.notionalValue != 0){
				Decimal notionalValue = elemntType2Value.get(sb.elementType) +  UTL_Currency.convert(sb.notionalValue, sb.currencyCode, currencyCode);
				elemntType2Value.put(sb.elementType,  notionalValue);
			}
		}

		for(String elementType : elemntType2Value.keySet()){
			dtfs.add(new DTO_Ecosystem.DeliverTheFirm(elementType, elemntType2Value.get(elementType), currencyCode));
		}

		return dtfs;
	}
	/**
    * Get DTF data pipeline by element
    *
    * @param groupNumber string
    * @param currencyCode string
    * @return DTO_Ecosystem.DeliverTheFirm[]
    */
	@AuraEnabled
	public static DTO_Ecosystem.DeliverTheFirm[] getDtfDataPipelineByElement(String groupNumber, String currencyCode) {
		DTO_Ecosystem.DeliverTheFirm[] dtfs = new DTO_Ecosystem.DeliverTheFirm[]{};
		Map<String, Decimal> elemntType2Value = new Map<String, Decimal>();
		initiateMap(elemntType2Value, 0);

		for(DTO_Ecosystem.DeliverTheFirm sb : getDtfDataPipeline(groupNumber)){
			if(String.isBlank(sb.elementType) || !elemntType2Value.containsKey(sb.elementType)){
				continue;
			}

			if(sb.notionalValue != null && sb.notionalValue != 0){
				Decimal notionalValue = elemntType2Value.get(sb.elementType) +  UTL_Currency.convert(sb.notionalValue, sb.currencyCode, currencyCode);
				elemntType2Value.put(sb.elementType,  notionalValue);
			}
		}

		for(String elementType : elemntType2Value.keySet()){
			dtfs.add(new DTO_Ecosystem.DeliverTheFirm(elementType, elemntType2Value.get(elementType), currencyCode));
		}

		return dtfs;
	}
	/**
    * Get DTF data banked by element
    *
    * @param groupNumber string
    * @param currencyCode string
    * @return DTO_Ecosystem.DeliverTheFirm[]
    */
	@AuraEnabled
	public static DTO_Ecosystem.DeliverTheFirm[] getDtfDataBankedByElement(String groupNumber, String currencyCode) {
		DTO_Ecosystem.DeliverTheFirm[] dtfs = new DTO_Ecosystem.DeliverTheFirm[]{};
		Map<String, Decimal> elemntType2Value = new Map<String, Decimal>();
		initiateMap(elemntType2Value, 0);

		for(DTO_Ecosystem.DeliverTheFirm sb : getDtfDataBanked(groupNumber)){
			if(String.isBlank(sb.elementType) || !elemntType2Value.containsKey(sb.elementType)){
				continue;
			}

			if(sb.notionalValue != null && sb.notionalValue != 0){
				Decimal notionalValue = elemntType2Value.get(sb.elementType) +  UTL_Currency.convert(sb.notionalValue, sb.currencyCode, currencyCode);
				elemntType2Value.put(sb.elementType,  notionalValue);
			}
		}

		for(String elementType : elemntType2Value.keySet()){
			dtfs.add(new DTO_Ecosystem.DeliverTheFirm(elementType, elemntType2Value.get(elementType), currencyCode));
		}

		return dtfs;
	}
	/**
    * Get opportunities for account hierarchy
    *
    * @param groupNumber Id
    * @return Opportunity[]
    */
	@AuraEnabled
	public static Opportunity[] getOpportunitiesForAccountHierarchy(String groupNumber) {
		return StdBank_Ltn_EcosystemNoSharing.getHierachyOpportunities(groupNumber);
	}
	/**
    * Get hierarchy members
    *
    * @param groupNumber string
    * @param currencyCode string
    * @return DTO_Ecosystem.HierarchyMember[]
    */
	@AuraEnabled
	public static DTO_Ecosystem.HierarchyMember[] getHierarchyMembers(String groupNumber, String currencyCode) {
		return StdBank_Ltn_EcosystemNoSharing.getHierarchyMembers(groupNumber, currencyCode);
	}
	/**
    * Will create ecosystem entity
    *
    * @param ecosystemId Id
    * @param accountId Id
    * @param type string
    * @param prh string
    * @param entityName string
    * @return Ecosystem_Entity__c
    */
	@AuraEnabled
	public static Ecosystem_Entity__c createEcosystemEntity(Id ecosystemId, Id accountId, String type,String prh,String entityName,String bpid) {
		DTO_Ecosystem.EcosystemEntity ecosystemEntity  = new DTO_Ecosystem.EcosystemEntity();
		ecosystemEntity.ecosystemId= ecosystemId;
		ecosystemEntity.accountId= accountId;
		ecosystemEntity.type= type;
		ecosystemEntity.prh= prh;
		ecosystemEntity.entityName= entityName;
		ecosystemEntity.bpid = bpid;
		return StdBank_Ltn_EcosystemNoSharing.createEcosystemEntity(ecosystemEntity);
	}
	/**
    * Get ecosystem recordTypeId
    *
    * @return String
    */
	@AuraEnabled
	public static String getEcosystemRecordTypeId() {
		return UTL_RecordType.getRecordTypeId('Account', 'Ecosystem');
	}
	/**
    * Get prospect recordTypeId
    *
    * @return String
    */
	@AuraEnabled
	public static String getProspectRecordTypeId() {
		return UTL_RecordType.getRecordTypeId('Account', 'Prospect');
	}
	/**
    * Get individual client recordTypeId
    *
    * @return String
    */
	@AuraEnabled
	public static String getIndividualClientRecordTypeId() {
		return UTL_RecordType.getRecordTypeId('Account', 'Commercial_Banking_Individual_Client');
	}
	/**
    *@description Get the current userId
    *
    * @return String
    */
	@AuraEnabled
	public static String getCurrentUserId() {
		return UserInfo.getUserId();
	}


	/**
	 *@description this function will return PRH options
	 * @return will return list of
	 */
	@AuraEnabled 
	public static DTO_SelectOption[] getAccountOptions(){

		List< DTO_SelectOption > picklistValueList = DTO_SelectOption.fetchOptions( Account.Primary_Relationship_Holder__c );		//fetch the available picklist values
		List< DTO_SelectOption > returnValueList = new List< DTO_SelectOption >();													//this will hold picklist values

		//loop through the available pick list values
		for( DTO_SelectOption currentSelection : picklistValueList ) {
			//check if its valid
			if ((currentSelection.label == 'Commercial Banking') || (currentSelection.label == 'Corporate and Investment Banking')) {
				returnValueList.add(currentSelection);
			}
		}
		return returnValueList;					//return list of picklist values

	}//end of function definition
	/**
    * Get Pbb division options
    * @return DTO_SelectOption[]
    */
	@AuraEnabled 
	public static DTO_SelectOption[] getPbbDivisionOptions() {
		return DTO_SelectOption.fetchOptions(Account.PBB_Division__c);
	}
	/**
    * Get responsible region options
    * @return DTO_SelectOption[]
    */
	@AuraEnabled 
	public static DTO_SelectOption[] getResponsibleRegionOptions() {
		return DTO_SelectOption.fetchOptions(Account.Responsible_Region__c);
	}
	/**
    * Create Account
    *
    * @param acc Account
    * @return Object
    */
	@AuraEnabled
	public static Object createAccount(Account acc) {
		
    try{
		//check if the CIF field is populated
		if( String.isNotBlank( acc.CIF__c ) ){

			Account[] accs = [ SELECT Name, CIF__c
							   FROM Account
							   WHERE ( Name = :acc.Name ) OR ( CIF__c = :acc.CIF__c ) OR (BPID__c = :acc.CIF__c)];

			//check if we have a record that exists
			if( !accs.isEmpty() ) {
				return Label.Duplicate_Banked_Client;                //return message
			}

		}//end of if-block

		acc.RecordTypeId = UTL_RecordType.getRecordTypeId( 'Account', 'Prospect' );

		if(Schema.sObjectType.Account.isCreateable()){
			insert acc;
		}
		else{
			return HAS_NO_ACCESS;
		}


		//check if email should be sent ---> CIF is not blank
		if( String.isNotBlank( acc.CIF__c ) && ( acc.Primary_Relationship_Holder__c == DMN_Account.PRIMARY_REL_HOLDER_COMMB ||
				acc.Primary_Relationship_Holder__c == DMN_Account.PRIMARY_REL_HOLDER_BUSINESS) ) {
			sendProdSupportEmail(acc);                    //send the support email
		}

        }
	catch(System.DmlException e){

		return e.getDmlMessage(0);
	}
		return acc;
	}
	/**
    * Update Account
    *
    * @param accountId Id
    * @param field String
    * @param fieldValue String
    * @return Account
    */
	@AuraEnabled
	public static Account updateAccount(Id accountId, String field, String fieldValue) {
		Account acc = new Account(Id = accountId);
		acc.put(field, fieldValue);
		StdBank_Ltn_EcosystemNoSharing.updateAccount(acc);
		return acc;
	}
	/**
    * Create Ecosystem
    *
    * @param ecosystem Ecosystem__c
    * @return Ecosystem
    */
	@AuraEnabled
	public static Ecosystem__c createEcosystem(Ecosystem__c ecosystem) {
		insert ecosystem;
		return ecosystem;
	}
	/**
    * create map
    *
    * @param type2Value Map<String, Object>
    * @param defaultValue Object
    */
	private static void initiateMap(Map<String, Object> type2Value, Object defaultValue){
		for(String elementType : new String[]{	DMN_Ecosystem.PARTNER,
												DMN_Ecosystem.SUBSIDIARY,
												DMN_Ecosystem.SHAREHOLDER_DIRECTOR,
												DMN_Ecosystem.CLIENT_DISTRIBUTOR,
												DMN_Ecosystem.DEBTOR_CREDITOR,
												DMN_Ecosystem.EMPLOYEE}){
			type2Value.put(elementType, defaultValue);
		}
	}
	/**
    * Get Profitability
    *
    * @param groupNumber String
    * @param currencyCode String
    * @return DTO_Ecosystem.RevenueAndProfitability[]
    */
	@AuraEnabled
	public static DTO_Ecosystem.RevenueAndProfitability[] getProfitability(String groupNumber, String currencyCode){
		return StdBank_Ltn_EcosystemNoSharing.getProfitability(groupNumber, currencyCode);
	}
	/**
    * Check if Owner is Manager
    *
    * @param accountId Id
    * @return Boolean
    */
	@AuraEnabled
	public static Boolean isOwnerManager(Id accountId) {
		Account[] accs = [SELECT OwnerId FROM Account WHERE Id = :accountId];
		if (accs.isEmpty()) {
			return false;
		}
		return RoleUtility.isManagerOfUsers(new Id[]{accs[0].OwnerId}, UserInfo.getUserId());
	}







	/**@description this function will return the picklist values for a given
	 * field on a given object( US-3984 - Create Single Modal for Creating Both banked and unbanked entity )
	 * @param objectNameP is the name of the object we want to extract value
	 * @param fieldNameP is the picklist field on the object that we want
	 * @param fieldsToExcludeP is a set of values
	 * @return list containing picklist values
	 *
	 * @author Chibuye Kunda
	 */
	@AuraEnabled
	public static List< String > getPicklistValues( String objectNameP, String fieldNameP, List< String > fieldsToExcludeP ){

		Schema.SObjectType sObjct = Schema.getGlobalDescribe().get( objectNameP );				//get the describe info
		Schema.DescribeSObjectResult sObjectDescription = sObjct.getDescribe();					//get the object info
		Schema.DescribeFieldResult sObjectField = sObjectDescription.fields.getMap().get( fieldNameP ).getDescribe();			//get field info
		List< Schema.PicklistEntry > picklistValue = sObjectField.getPicklistValues();						//this is the picklist value

		List< String > picklistValues = new List< String >();
		Set< String > fieldsToExclude = new Set< String >();

        //check if we dont have a null value
        if( !fieldsToExcludeP.isEmpty() ) {
			fieldsToExclude.addAll(fieldsToExcludeP);                 //add to the fields to exclude
		}

		//loop through the picklist value
		for( Schema.PicklistEntry currentEntry : picklistValue ) {

			//check if current picklist value should be excluded
			if( !fieldsToExclude.isEmpty() && fieldsToExclude.contains( currentEntry.getLabel() ) ) {
				continue;                    //move to the next element --> label in list already
			}

			picklistValues.add( currentEntry.getLabel() );					//add current entry to the return list

		}

		return picklistValues;

	}
	
	/** this method will return number of conversation from smart2
	 * @param recordId this is the recordId of ecosystem
	 * @return Integer
	 */
	@AuraEnabled
	public static Integer getCoversationsCount(Id recordId){
		Ecosystem__c eco = [SELECT Id,Relationship_Group_Number__c FROM Ecosystem__c Where Id=:recordId];
		List<PBB_SRV_GatewayApi_Conversations.ConversationGroup> convList = CONVERSATION_SERVICE.getConversationsByRiskGroup(Integer.valueOf(eco.Relationship_Group_Number__c));
		return convList.size();
	}

	/** this function will send email to support for CIF publishing
	 * @param accountP this is the account we want published
	 * @return will return true on success
	 */
	private static Boolean sendProdSupportEmail( Account accountP ){

		String emailText =  '';
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();				//create the new email object
		EmailTemplate emailTemplate = [ SELECT  Body
										 FROM EmailTemplate
										 WHERE Name= 'CIF Request' ];

		emailText = emailTemplate.Body;			//get the body text
		emailText = emailText.Replace( '{!Account.Name}', accountP.Name );
		emailText = emailText.Replace( '{!Account.CIF__c}', accountP.CIF__c );
		emailText = emailText.Replace( '{!Account.Id}', accountP.Id );

		email.setSubject( 'Publish Salesforce Record to CIF' );									//set the subject
		email.setToAddresses( new List< String >{ SB_Parameters__c.getValues( 'CRMHelpdeskEmail' ).Value__c } );		//set the email address
		email.setCcAddresses( new List< String >{ UserInfo.getUserEmail() } );									//cc the user email address
		email.setPlainTextBody( emailText );						//set the email body

		if(!Test.isRunningTest()){
		Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
		}

		return true;				//indicate success

	}//end of function definition


}