/*****************************************************************************************************\
    @ Func Area     : Revenue and Profitability, Ecosystem
    @ Author        : Marko Dvečko
    @ Date          : 29/03/2017
    @ Test File     : 
	@ Specification : Unit tests for RevenueAndProfitabilityTrigger.trigger
******************************************************************************************************/

@isTest
private class RevenueAndProfitabilityTrigger_Test {
	
	/**
	 * Create account and revenue and profitability records and see what is happening
	 * We trigger should create one ecosystem with ecosystem entity linked to account and ecosystem
	 */
	@isTest 
	static void testCreateUpdateAndDelete() {
		Account acc = (Account) new BLD_Account().useChild().commitWork().getRecord();

		Contact con = new Contact(
			AccountId = acc.Id,
			FirstName = 'Test',
			LastName = 'Name');
		insert con;

		Revenue_and_Profitability__c rp = new Revenue_and_Profitability__c(
			Relationship_Group_Number__c = '0001',
			Client_Name__c = acc.Id,
			Net_Interest_Income__c = 12.00,
			Non_Interest_Revenue__c = 10.00,
			Operating_Income__c = 11.00,
			PMT_extract_date__c = Date.today());

		insert rp;

		Ecosystem__c[] ecos = 
			[ SELECT Id, Relationship_Group_Number__c, Actual_Net_Interest_Income__c,
			  Actual_Non_Interest_Revenue__c, Actual_Operating_Income__c 
			  FROM Ecosystem__c ];
		Ecosystem_Entity__c[] ecoEntities = [ SELECT Id, Entity__c, Ecosystem__c FROM Ecosystem_Entity__c ];
		System.assertEquals(1, ecos.size());
		System.assertEquals(1, ecoEntities.size());

		rp.Relationship_Group_Number__c = '0002';
		update rp;

		ecos = 
			[ SELECT Id, Relationship_Group_Number__c, Actual_Net_Interest_Income__c,
			  Actual_Non_Interest_Revenue__c, Actual_Operating_Income__c 
			  FROM Ecosystem__c ];
		ecoEntities = [ SELECT Id, Entity__c, Ecosystem__c FROM Ecosystem_Entity__c ];
		System.assertEquals(2, ecos.size());
		System.assertEquals(2, ecoEntities.size());

		rp.Person__c = con.Id;
		update rp;

		ecos = 
			[ SELECT Id, Relationship_Group_Number__c, Actual_Net_Interest_Income__c,
			  Actual_Non_Interest_Revenue__c, Actual_Operating_Income__c 
			  FROM Ecosystem__c ];
		ecoEntities = [ SELECT Id, Entity__c, Ecosystem__c FROM Ecosystem_Entity__c ];
		System.assertEquals(2, ecos.size());
		System.assertEquals(3, ecoEntities.size());

		rp.Person__c = null;
		update rp;
		ecos = 
			[ SELECT Id, Relationship_Group_Number__c, Actual_Net_Interest_Income__c,
			  Actual_Non_Interest_Revenue__c, Actual_Operating_Income__c 
			  FROM Ecosystem__c ];
		ecoEntities = [ SELECT Id, Entity__c, Ecosystem__c FROM Ecosystem_Entity__c ];
		System.assertEquals(2, ecos.size());
		System.assertEquals(3, ecoEntities.size());

		delete rp;
		ecos = 
			[ SELECT Id, Relationship_Group_Number__c, Actual_Net_Interest_Income__c,
			  Actual_Non_Interest_Revenue__c, Actual_Operating_Income__c 
			  FROM Ecosystem__c ];
		ecoEntities = [ SELECT Id, Entity__c, Ecosystem__c FROM Ecosystem_Entity__c ];
		System.assertEquals(2, ecos.size());
		System.assertEquals(3, ecoEntities.size());
	}
}