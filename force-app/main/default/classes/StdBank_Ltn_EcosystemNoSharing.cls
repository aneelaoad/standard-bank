/**
 *
    @ Author  : Unknown
    @description : Ecosystem 2020 | Add Ecosystem View on Ecosystem Tab (US-4605),US-2456,US-2331,C-00003016
 */
public without sharing class StdBank_Ltn_EcosystemNoSharing {

	/**
	* Search ecosystem by groupNumber
	*
	* @param inputSearch String
	* @param accountId String
	* @return Ecosystem__c[]
	*/
	public static Ecosystem__c[] searchEcosystems(String inputSearch, String accountId) {
        Ecosystem__c[] ecosystems;
		String cleanInputSearch = '%'+String.escapeSingleQuotes(inputSearch) +'%';
		ecosystems =
			[ SELECT Id, Name, Relationship_Group_Number__c,Relationship_Group_Name__c
			  FROM Ecosystem__c
			  WHERE (Relationship_Group_Number__c LIKE :cleanInputSearch OR Relationship_Group_Name__c LIKE :cleanInputSearch)
			  AND Id NOT IN (SELECT Ecosystem__c FROM Ecosystem_Entity__c WHERE Entity__c = :accountId)
			  LIMIT 5 ];

		return ecosystems;
	}

	/**
	* create Ecosystem Entity record
	* @param ecosystemEntity
	* @return Ecosystem_Entity__c
	*/
	public static Ecosystem_Entity__c createEcosystemEntity(DTO_Ecosystem.EcosystemEntity ecosystemEntity) {
		Ecosystem_Entity__c entity = new Ecosystem_Entity__c(
			Ecosystem__c = ecosystemEntity.ecosystemId,
			Entity__c = ecosystemEntity.accountId,
			Primary_Relationship_Holder__c = ecosystemEntity.prh,
			Name = ecosystemEntity.entityName,
			Entity_Type__c = ecosystemEntity.type,
			BPID__c =  ecosystemEntity.bpid,
			Status__c = 'Valid');
		insert entity;
		updateEcosystemKnownBanked(ecosystemEntity.ecosystemId,ecosystemEntity.type);
		return entity;
	}

	public static void updateEcosystemKnownBanked(String ecosystemId,String entityType) {
		Ecosystem__c eco = new Ecosystem__c(Id=ecosystemId);
		List<Ecosystem_Entity__c> eeList = [SELECT Id  FROM Ecosystem_Entity__c
		 WHERE Ecosystem__c=:ecosystemId AND Entity_Type__c=:entityType AND (Entity__r.BPID__c!=null OR Entity__r.CIF__c!=null)];
		
		if( entityType=='Shareholder / Director'){
			eco.Known_Banked_Shareholders_Directors__c = eeList.size();
			update eco;
		}
		else if(entityType=='Debtor / Client'){
			eco.Known_Banked_Debtors_Creditors__c = eeList.size();
			update eco;
		}
		else if(entityType=='Subsidiary'){			
			eco.Known_Banked_Subsidiaries__c = eeList.size();
			update eco;
		}
		else if(entityType=='Partner'){
			eco.Known_Banked_Partners__c = eeList.size();
			update eco;
		}
		else if(entityType=='Employee'){
			eco.Known_Banked_Employees__c = eeList.size();
			update eco;
		}
		else if(entityType=='Creditor / Supplier'){
			eco.Known_Banked_Clients_Distributors__c = eeList.size();
			update eco;
		}
	}

	/**
	* get Profitability
	*
	* @param groupNumber String
	* @param currencyCode String
	* @return DTO_Ecosystem.RevenueAndProfitability[]
	*/
	public static DTO_Ecosystem.RevenueAndProfitability[] getProfitability(String groupNumber, String currencyCode) { 
		Account[] accounts;

		if (String.isNotBlank(groupNumber)) {
			accounts = [SELECT Id,
						(	SELECT Entity_Type__c
							FROM Ecosystem_Entities__r
							WHERE Ecosystem__r.Relationship_Group_Number__c = :groupNumber),
						(	SELECT Net_Interest_Income__c, Revenue_Current_YTD__c, Operating_Income__c, Headline_Earnings__c, 
									Non_Interest_Revenue__c, ROE__c, CurrencyIsoCode
							FROM Revenues_and_Profitabilities__r)
						FROM Account
						WHERE Id IN (SELECT Entity__c FROM Ecosystem_Entity__c WHERE Ecosystem__r.Relationship_Group_Number__c = :groupNumber)];
		}
		else {
			accounts = new Account[] {};
		}


		Map<String, DTO_Ecosystem.RevenueAndProfitability> type2Profitability = new Map<String, DTO_Ecosystem.RevenueAndProfitability>
													{DMN_Ecosystem.PARTNER => new DTO_Ecosystem.RevenueAndProfitability(DMN_Ecosystem.PARTNER, currencyCode),
													DMN_Ecosystem.SUBSIDIARY => new DTO_Ecosystem.RevenueAndProfitability(DMN_Ecosystem.SUBSIDIARY, currencyCode),
													DMN_Ecosystem.SHAREHOLDER_DIRECTOR => new DTO_Ecosystem.RevenueAndProfitability(DMN_Ecosystem.SHAREHOLDER_DIRECTOR, currencyCode),
													DMN_Ecosystem.DEBTOR_CREDITOR => new DTO_Ecosystem.RevenueAndProfitability(DMN_Ecosystem.DEBTOR_CREDITOR, currencyCode),
													DMN_Ecosystem.CLIENT_DISTRIBUTOR => new DTO_Ecosystem.RevenueAndProfitability(DMN_Ecosystem.CLIENT_DISTRIBUTOR, currencyCode),
													DMN_Ecosystem.EMPLOYEE => new DTO_Ecosystem.RevenueAndProfitability(DMN_Ecosystem.EMPLOYEE, currencyCode)};

		for (Account acc : accounts) {

			if (acc.Ecosystem_Entities__r.isEmpty() 
				|| String.isBlank(acc.Ecosystem_Entities__r[0].Entity_Type__c)
				|| acc.Revenues_and_Profitabilities__r.isEmpty()
				|| !type2Profitability.containsKey(acc.Ecosystem_Entities__r[0].Entity_Type__c)) {
				continue;
			}

			String elementType = acc.Ecosystem_Entities__r[0].Entity_Type__c;
			DTO_Ecosystem.RevenueAndProfitability dto = type2Profitability.get(elementType);

			dto.netIncome += UTL_Currency.sumUp(acc.Revenues_and_Profitabilities__r, 'Net_Interest_Income__c', currencyCode);
			dto.netRevenue += UTL_Currency.sumUp(acc.Revenues_and_Profitabilities__r, 'Revenue_Current_YTD__c', currencyCode);
			dto.operationalIncome += UTL_Currency.sumUp(acc.Revenues_and_Profitabilities__r, 'Operating_Income__c', currencyCode);
			dto.headlineErnings += UTL_Currency.sumUp(acc.Revenues_and_Profitabilities__r, 'Headline_Earnings__c', currencyCode);
			dto.nonRevenue += UTL_Currency.sumUp(acc.Revenues_and_Profitabilities__r, 'Non_Interest_Revenue__c', currencyCode);
			dto.roe += UTL_Currency.sumUp(acc.Revenues_and_Profitabilities__r, 'ROE__c', currencyCode);
			dto.count += acc.Revenues_and_Profitabilities__r.size();
			
			type2Profitability.put(elementType, dto);
		}
		return type2Profitability.values();
	}

	/**
	* get Products
	*
	* @param groupNumber String
	* @return SB_Product__c[]
	*/
	public static SB_Product__c[] getProducts(String groupNumber) {
		SB_Product__c[] result = new List<SB_Product__c>();
		for (Opportunity opp : 
			[ SELECT ( SELECT Opportunity__r.Account.Name, Parent_Product__c, Opportunity__r.Name, 
					   Opportunity__r.StageName, Facility_Size__c	, 
					   Opportunity__r.Owner.Name, Opportunity__r.CloseDate, Opportunity__r.Description, 
					   Opportunity__r.CommentsOnProgress__c, CurrencyIsoCode
					   FROM Products__r )
			  FROM Opportunity
			  WHERE AccountId IN ( SELECT Entity__c FROM Ecosystem_Entity__c 
				    			   WHERE Ecosystem__r.Relationship_Group_Number__c = :groupNumber )
		      AND CreatedDate = THIS_YEAR ]) {
			result.addAll(opp.Products__r);
		}
		return result;
	}

	/**
	* get Products Pipeline
	*
	* @param groupNumber String
	* @return SB_Product__c[]
	*/
	public static SB_Product__c[] getProductsPipeline(String groupNumber) {
		SB_Product__c[] result = new List<SB_Product__c>();
		for (Opportunity opp : 
			[ SELECT ( SELECT Opportunity__r.Account.Name, Parent_Product__c, Opportunity__r.Name,
			 		   Opportunity__r.StageName, Facility_Size__c,
			 		   Opportunity__r.Owner.Name, Opportunity__r.CloseDate, Opportunity__r.Description,
			 		   Opportunity__r.CommentsOnProgress__c, CurrencyIsoCode
			 		   FROM Products__r )
			  FROM Opportunity
			  WHERE AccountId IN ( SELECT Entity__c FROM Ecosystem_Entity__c 
			    			   WHERE Ecosystem__r.Relationship_Group_Number__c = :groupNumber )
			  AND CreatedDate = THIS_YEAR
			  AND IsClosed = false ]) {
			result.addAll(opp.Products__r);
		}
		return result;
	}

	/**
	* get Products Banked
	*
	* @param groupNumber String
	* @return SB_Product__c[]
	*/
	public static SB_Product__c[] getProductsBanked(String groupNumber) {
		SB_Product__c[] result = new List<SB_Product__c>(); 
		for (Opportunity opp : 
			 [ SELECT ( SELECT Opportunity__r.Account.Name, Parent_Product__c, Opportunity__r.Name,
				 		Opportunity__r.StageName, Facility_Size__c,
				 		Opportunity__r.Owner.Name, Opportunity__r.CloseDate, Opportunity__r.Description,
				 		Opportunity__r.CommentsOnProgress__c, CurrencyIsoCode
				 		FROM Products__r )
			   FROM Opportunity
			   WHERE AccountId IN ( SELECT Entity__c FROM Ecosystem_Entity__c 
			    			   WHERE Ecosystem__r.Relationship_Group_Number__c = :groupNumber )
			   AND CloseDate = THIS_YEAR
			   AND IsClosed = true
			   AND IsWon = true ]) {
			result.addAll(opp.Products__r);
		}
		return result;
	}
	/**
	* get Hierachy Opportunities
	*
	* @param groupNumber String
	* @return Opportunity[]
	*/
	public static Opportunity[] getHierachyOpportunities(String groupNumber) {
		
		Opportunity[] result = new Opportunity[]{};
		if (String.isBlank(groupNumber)) {
			return result;
		}
			
		result = [
			SELECT
				StageName,
				(SELECT Facility_Size__c FROM Products__r)
			FROM
				Opportunity
			WHERE 
				Account.Relationship_Group_Number__c = :groupNumber
				AND ((IsClosed = true AND CloseDate = THIS_YEAR)
					OR (IsClosed = false AND CreatedDate = THIS_YEAR))
		];
		return result;								
	}
	/**
	* get Hierarchy Members
	*
	* @param groupNumber String
	* @param currencyCode String
	* @return DTO_Ecosystem.HierarchyMember[]
	*/
	public static DTO_Ecosystem.HierarchyMember[] getHierarchyMembers(String groupNumber, String currencyCode) {
		
		Account[] accounts = [
			SELECT Id, Name,
				( SELECT Net_Interest_Income__c, Revenue_Current_YTD__c, Operating_Income__c, Headline_Earnings__c, 
						Non_Interest_Revenue__c, ROE__c, CurrencyIsoCode
					FROM Revenues_and_Profitabilities__r)
			FROM Account
			WHERE Relationship_Group_Number__c = :groupNumber
		];
		


		DTO_Ecosystem.HierarchyMember[] hierMembers = new DTO_Ecosystem.HierarchyMember[]{};

		for (Account acc : accounts) {

			DTO_Ecosystem.RevenueAndProfitability dto = new DTO_Ecosystem.RevenueAndProfitability('Hierarchy Member', currencyCode);

			if (!acc.Revenues_and_Profitabilities__r.isEmpty()) {
				dto.netIncome += UTL_Currency.sumUp(acc.Revenues_and_Profitabilities__r, 'Net_Interest_Income__c', currencyCode);
				dto.netRevenue += UTL_Currency.sumUp(acc.Revenues_and_Profitabilities__r, 'Revenue_Current_YTD__c', currencyCode);
				dto.operationalIncome += UTL_Currency.sumUp(acc.Revenues_and_Profitabilities__r, 'Operating_Income__c', currencyCode);
				dto.headlineErnings += UTL_Currency.sumUp(acc.Revenues_and_Profitabilities__r, 'Headline_Earnings__c', currencyCode);
				dto.nonRevenue += UTL_Currency.sumUp(acc.Revenues_and_Profitabilities__r, 'Non_Interest_Revenue__c', currencyCode);
				dto.roe += UTL_Currency.sumUp(acc.Revenues_and_Profitabilities__r, 'ROE__c', currencyCode);
				dto.count += acc.Revenues_and_Profitabilities__r.size();
			}

			hierMembers.add(new DTO_Ecosystem.HierarchyMember(acc, dto));

		}
		return hierMembers;
	}
	/**
	* update Account
	*
	* @param acc String
	*/
	public static void updateAccount(Account acc) {
		update acc;
	}

}