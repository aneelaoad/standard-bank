/*************************************************************************
	@ Author 		: psvestka
	@ Date 		    : 2. 3. 2016
	@ Test File 	: {ProductSubsetsTest}
	@ Description	: US-1177 : adjusting logic using ProductSubsets__c
****************************************************************************/

@IsTest
private class ProductSubsetsTest {

	private static Map<String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
	private final static Id ugpRecTypeId = mapAccountRecordTypes.get('Ultimate Group Parent').getRecordTypeId();

	private final static String USERNAME = 'usernamdwadwa@dwaea.com';
	private static User userCC {
		get {
			if (userCC == null) {
				userCC = [SELECT Id FROM User WHERE Username = :USERNAME];
			}
			return userCC;
		}
		set;
	}

	@TestSetup
	private static void prepareData() {
		TEST_DataFactory.insertSettings(new List<Object> {
			TEST_DataFactory.getUserProfileIds(),
			TEST_DataFactory.getEnvironmentVariable(),
			TEST_DataFactory.getCcSettings(),
			TEST_DataFactory.getErrorMessages()
		});

		new BLD_USER(USERNAME).useCib().commitWork();
	}

	private static Account createAccount() {
		Account acc = new Account();
		acc.RecordTypeId = ugpRecTypeId;
		acc.Name = 'Test Client';
		acc.BillingStreet = 'Test street';
		acc.Client_Sector__c = 'Unknown Sector';
		acc.Client_Sub_Sector__c = 'Unknown Sub-Sector';
		acc.Client_Segment__c = 'AB';
		acc.Country_Risk__c = 'India';
		acc.Correspondence_Addr_Line1__c = 'Test Street Line 1';
		acc.Correspondence_City__c = 'City';
		acc.Correspondence_Postal_Code__c = '123456';
		acc.Correspondence_Country__c = 'India';
		acc.BillingCountry = 'South Africa';
		acc.BillingCity = 'Durban';

		acc.CIF__c = '1234';

		return acc;
	}

	private static List<ProductSubsets__c> createAllProductSubsets() {
		return new List<ProductSubsets__c>{
				new ProductSubsets__c(name='Advisory', product_division__c='Investment Banking', parent_product__c='Advisory'),
				new ProductSubsets__c(name='Capital Markets', product_division__c='Investment Banking', parent_product__c='Capital Markets'),
				new ProductSubsets__c(name='Card', product_division__c='Business Banking', parent_product__c='Card'),
				new ProductSubsets__c(name='Cash Equity', product_division__c='Global Markets', parent_product__c='Cash Equity'),
				new ProductSubsets__c(name='Cash Management', product_division__c='Transactional Products and Services', parent_product__c='Cash Management'),
				new ProductSubsets__c(name='Commodities', product_division__c='Global Markets', parent_product__c='Commodities'),
				new ProductSubsets__c(name='Credit', product_division__c='Global Markets', parent_product__c='Credit'),
				new ProductSubsets__c(name='Debt Products', product_division__c='Investment Banking', parent_product__c='Debt Products'),
				new ProductSubsets__c(name='Distributor Finance', product_division__c='Business Banking', parent_product__c='Distributor Finance'),
				new ProductSubsets__c(name='Enterprise Development', product_division__c='Business Banking', parent_product__c='Enterprise Development'),
				new ProductSubsets__c(name='Equity Derivatives', product_division__c='Global Markets', parent_product__c='Equity Derivatives'),
				new ProductSubsets__c(name='Foreign Exchange', product_division__c='Global Markets', parent_product__c='Foreign Exchange'),
				new ProductSubsets__c(name='Investor Services', product_division__c='Transactional Products and Services', parent_product__c='Investor Services'),
				new ProductSubsets__c(name='LC African Product', product_division__c='Global Markets', parent_product__c='LC African Product'),
				new ProductSubsets__c(name='Liberty and Stanlib', product_division__c='Wealth', parent_product__c='Liberty and Stanlib'),
				new ProductSubsets__c(name='Local Markets and IRT (IRD)', product_division__c='Global Markets', parent_product__c='Local Markets and IRT (IRD)'),
				new ProductSubsets__c(name='Mobile', product_division__c='Business Banking', parent_product__c='Mobile'),
				new ProductSubsets__c(name='Money Markets', product_division__c='Global Markets', parent_product__c='Money Markets'),
				new ProductSubsets__c(name='Private Clients', product_division__c='Wealth', parent_product__c='Private Clients'),
				new ProductSubsets__c(name='Real Estate', product_division__c='Real Estate', parent_product__c='Real Estate'),
				new ProductSubsets__c(name='Strategic Investments', product_division__c='Investment Banking', parent_product__c='Strategic Investments'),
				new ProductSubsets__c(name='Structured Finance', product_division__c='Investment Banking', parent_product__c='Structured Finance'),
				new ProductSubsets__c(name='Trade', product_division__c='Transactional Products and Services', parent_product__c='Trade'),
				new ProductSubsets__c(name='VAF', product_division__c='Business Banking', parent_product__c='VAF'),
				new ProductSubsets__c(name='Work Place Banking', product_division__c='Business Banking', parent_product__c='Work Place Banking'),
				new ProductSubsets__c(name='Term Loans', product_division__c='Loans', parent_product__c='Term Loans'),
				new ProductSubsets__c(name='CommB_VAF', product_division__c='Loans', parent_product__c='VAF'), // was causing troubles
				new ProductSubsets__c(name='BOL', product_division__c='Payments', parent_product__c='BOL'),
				new ProductSubsets__c(name='Cash', product_division__c='Payments', parent_product__c='Cash'),
				new ProductSubsets__c(name='Merchant Acquiring', product_division__c='Payments', parent_product__c='Merchant Acquiring'),
				new ProductSubsets__c(name='Payments', product_division__c='Trade and Forex', parent_product__c='Payments'),
				new ProductSubsets__c(name='CommB_Trade', product_division__c='Trade and Forex', parent_product__c='Trade'), // was causing troubles
				new ProductSubsets__c(name='Current Accounts', product_division__c='Transaction Accounts', parent_product__c='Current Accounts'),
				new ProductSubsets__c(name='TPFA', product_division__c='Transaction Accounts', parent_product__c='TPFA'),
				new ProductSubsets__c(name='Insurance', product_division__c='Wealth and Insurance', parent_product__c='Insurance'),
				new ProductSubsets__c(name='Wealth', product_division__c='Wealth and Insurance', parent_product__c='Wealth'),
				new ProductSubsets__c(name='Debtors Finance', product_division__c='Working Capital', parent_product__c='Debtors Finance'),
				new ProductSubsets__c(name='Overdraft', product_division__c='Working Capital', parent_product__c='Overdraft'),
				new ProductSubsets__c(name='Corporate Card', product_division__c='Card', parent_product__c='Corporate Card'),
				new ProductSubsets__c(name='Investments', product_division__c='Investments', parent_product__c='Investments'),
				new ProductSubsets__c(name='Investments - Call', product_division__c='Investments', parent_product__c='Investments - Call'),
				new ProductSubsets__c(name='Investments - Fixed', product_division__c='Investments', parent_product__c='Investments - Fixed'),
				new ProductSubsets__c(name='Investments - Notice', product_division__c='Investments', parent_product__c='Investments - Notice'),
				new ProductSubsets__c(name='Commercial Property Finance', product_division__c='Loans', parent_product__c='Commercial Property Finance'),
				new ProductSubsets__c(name='Fleet', product_division__c='Loans', parent_product__c='Fleet'),
				new ProductSubsets__c(name='Revolving Loans', product_division__c='Loans', parent_product__c='Revolving Loans')
		};
	}

	@IsTest
	static void testProductPotentialsAreAddedToNewClient() {

		List<ProductSubsets__c> pss = createAllProductSubsets();
		insert pss;

		Account acc = createAccount();
		acc.Client_Co_ordinator__c = userCC.id;
		acc.primary_relationship_holder__c = 'Corporate and Investment Banking';

		Test.startTest();

		system.runAs(userCC) {
			insert acc;
			system.assert(acc != null && acc.id != null);

			system.assertEquals(0, [SELECT id FROM Product_Potential__c WHERE client__c = :acc.id].size());

			PageReference p = Page.ClientPlan;
			p.getParameters().put('id', acc.id);
			System.Test.setCurrentPage(p);
			ApexPages.StandardController controller = new ApexPages.StandardController(acc);

			ClientPlanClass cp = new ClientPlanClass(controller);

			cp.checkClientPlan(); // manipulate Product Potentials

		}

		Test.stopTest();

		List<Product_Potential__c> pps = [SELECT id
												,product_division__c
												,product_potential__c
												,product_subset__c
										FROM Product_Potential__c
										WHERE client__c = :acc.id];

		system.assertEquals(pss.size(), pps.size());

		Map<String, Boolean> foundMatches = new Map<String, Boolean>();
		for (ProductSubsets__c ps: pss) {
			foundMatches.put(ps.parent_product__c + '#' + ps.product_division__c, false);
		}

		for (Product_Potential__c pp: pps) {
			if (foundMatches.get(pp.Product_Subset__c + '#' + pp.Product_Division__c) == true) {
				system.assert(false, 'Product Potential record with (' + pp.Product_Subset__c + ',' + pp.Product_Division__c + ') created as a duplicate');
			} else {
				foundMatches.put(pp.Product_Subset__c + '#' + pp.Product_Division__c, true);
			}
		}

		system.assertEquals(pss.size(), foundMatches.keySet().size(), 'Product Potential records created that were not expected');

		for (String k: foundMatches.keySet()) {
			system.assert(foundMatches.get(k), 'Product Potential record was not created for (' + k.replace('#', ', ') + ')');
		}
	}

	@IsTest
	static void testProductPotentialsDontChangeOnClient() {

		List<ProductSubsets__c> pss = createAllProductSubsets();
		insert pss;

		Account acc = createAccount();
		acc.Client_Co_ordinator__c = userCC.id;
		acc.primary_relationship_holder__c = 'Corporate and Investment Banking';

		Test.startTest();

		system.runAs(userCC) {
			insert acc;
			system.assert(acc != null && acc.id != null);

			List<Product_Potential__c> pps = new List<Product_Potential__c>();
			for (ProductSubsets__c ps: pss) {
				Product_Potential__c pp = new Product_Potential__c();
				pp.client__c = acc.id;
				pp.product_division__c = ps.product_division__c;
				pp.product_subset__c = ps.parent_product__c;
				pps.add(pp);
			}
			insert pps;

			system.assertEquals(pss.size(), [SELECT id FROM Product_Potential__c WHERE client__c = :acc.id].size());

			PageReference p = Page.ClientPlan;
			p.getParameters().put('id', acc.id);
			System.Test.setCurrentPage(p);
			ApexPages.StandardController controller = new ApexPages.StandardController(acc);

			ClientPlanClass cp = new ClientPlanClass(controller);

			cp.checkClientPlan(); // manipulate Product Potentials

		}

		Test.stopTest();

		List<Product_Potential__c> pps2 = [SELECT id
												,product_division__c
												,product_potential__c
												,product_subset__c
										FROM Product_Potential__c
										WHERE client__c = :acc.id];

		system.assertEquals(pss.size(), pps2.size());

		Map<String, Boolean> foundMatches = new Map<String, Boolean>();
		for (ProductSubsets__c ps: pss) {
			foundMatches.put(ps.parent_product__c + '#' + ps.product_division__c, false);
		}

		for (Product_Potential__c pp: pps2) {
			if (foundMatches.get(pp.Product_Subset__c + '#' + pp.Product_Division__c) == true) {
				system.assert(false, 'Product Potential record with (' + pp.Product_Subset__c + ',' + pp.Product_Division__c + ') created as a duplicate');
			} else {
				foundMatches.put(pp.Product_Subset__c + '#' + pp.Product_Division__c, true);
			}
		}

		system.assertEquals(pss.size(), foundMatches.keySet().size(), 'Product Potential records created that were not expected');

		for (String k: foundMatches.keySet()) {
			system.assert(foundMatches.get(k), 'Product Potential record was not created for (' + k.replace('#', ', ') + ')');
		}
	}

	@IsTest
	static void testProductPotentialsAreAdded() {

		List<ProductSubsets__c> pss = createAllProductSubsets();
		insert pss;

		Account acc = createAccount();
		acc.Client_Co_ordinator__c = userCC.id;
		acc.primary_relationship_holder__c = 'Corporate and Investment Banking';

		Test.startTest();

		system.runAs(userCC) {
			insert acc;
			system.assert(acc != null && acc.id != null);

			List<Product_Potential__c> pps = new List<Product_Potential__c>();
			for (ProductSubsets__c ps: pss) {
				Product_Potential__c pp = new Product_Potential__c();
				pp.client__c = acc.id;
				pp.product_division__c = ps.product_division__c;
				pp.product_subset__c = ps.parent_product__c;
				pps.add(pp);
			}
			insert pps;

			system.assertEquals(pss.size(), [SELECT id FROM Product_Potential__c WHERE client__c = :acc.id].size());

			// create a new Product Subset
			ProductSubsets__c psNew = new ProductSubsets__c(name='x', product_division__c='div', parent_product__c='parent');
			insert psNew;
			pss.add(psNew); // pss will now reflect that

			PageReference p = Page.ClientPlan;
			p.getParameters().put('id', acc.id);
			System.Test.setCurrentPage(p);
			ApexPages.StandardController controller = new ApexPages.StandardController(acc);

			ClientPlanClass cp = new ClientPlanClass(controller);

			cp.checkClientPlan(); // manipulate Product Potentials

		}

		Test.stopTest();

		List<Product_Potential__c> pps2 = [SELECT id
												,product_division__c
												,product_potential__c
												,product_subset__c
										FROM Product_Potential__c
										WHERE client__c = :acc.id];

		system.assertEquals(pss.size(), pps2.size());

		Map<String, Boolean> foundMatches = new Map<String, Boolean>();
		for (ProductSubsets__c ps: pss) {
			foundMatches.put(ps.parent_product__c + '#' + ps.product_division__c, false);
		}

		for (Product_Potential__c pp: pps2) {
			if (foundMatches.get(pp.Product_Subset__c + '#' + pp.Product_Division__c) == true) {
				system.assert(false, 'Product Potential record with (' + pp.Product_Subset__c + ',' + pp.Product_Division__c + ') created as a duplicate');
			} else {
				foundMatches.put(pp.Product_Subset__c + '#' + pp.Product_Division__c, true);
			}
		}

		system.assertEquals(pss.size(), foundMatches.keySet().size(), 'Product Potential records created that were not expected');

		for (String k: foundMatches.keySet()) {
			system.assert(foundMatches.get(k), 'Product Potential record was not created for (' + k.replace('#', ', ') + ')');
		}
	}

	@IsTest
	static void testProductPotentialsAreRemoved() {

		List<ProductSubsets__c> pss = createAllProductSubsets();
		insert pss;

		Account acc = createAccount();
		acc.Client_Co_ordinator__c = userCC.id;
		acc.primary_relationship_holder__c = 'Corporate and Investment Banking';

		Test.startTest();

		system.runAs(userCC) {
			insert acc;
			system.assert(acc != null && acc.id != null);

			List<Product_Potential__c> pps = new List<Product_Potential__c>();
			for (ProductSubsets__c ps: pss) {
				Product_Potential__c pp = new Product_Potential__c();
				pp.client__c = acc.id;
				pp.product_division__c = ps.product_division__c;
				pp.product_subset__c = ps.parent_product__c;
				pps.add(pp);
			}
			insert pps;

			system.assertEquals(pss.size(), [SELECT id FROM Product_Potential__c WHERE client__c = :acc.id].size());

			// delete a Product Subset
			delete [SELECT id FROM ProductSubsets__c WHERE product_division__c='Loans' AND parent_product__c='Revolving Loans'];
			List<ProductSubsets__c> temp = new List<ProductSubsets__c>();
			for (ProductSubsets__c ps: pss) {
				if (!(ps.product_division__c == 'Loans' && ps.parent_product__c == 'Revolving Loans')) {
					temp.add(ps);
				}
			}
			pss = temp; // pss will now reflect it

			PageReference p = Page.ClientPlan;
			p.getParameters().put('id', acc.id);
			System.Test.setCurrentPage(p);
			ApexPages.StandardController controller = new ApexPages.StandardController(acc);

			ClientPlanClass cp = new ClientPlanClass(controller);

			cp.checkClientPlan(); // manipulate Product Potentials

		}

		Test.stopTest();

		List<Product_Potential__c> pps2 = [SELECT id
												,product_division__c
												,product_potential__c
												,product_subset__c
										FROM Product_Potential__c
										WHERE client__c = :acc.id];

		system.assertEquals(pss.size(), pps2.size());

		Map<String, Boolean> foundMatches = new Map<String, Boolean>();
		for (ProductSubsets__c ps: pss) {
			foundMatches.put(ps.parent_product__c + '#' + ps.product_division__c, false);
		}

		for (Product_Potential__c pp: pps2) {
			if (foundMatches.get(pp.Product_Subset__c + '#' + pp.Product_Division__c) == true) {
				system.assert(false, 'Product Potential record with (' + pp.Product_Subset__c + ',' + pp.Product_Division__c + ') created as a duplicate');
			} else {
				foundMatches.put(pp.Product_Subset__c + '#' + pp.Product_Division__c, true);
			}
		}

		system.assertEquals(pss.size(), foundMatches.keySet().size(), 'Product Potential records created that were not expected');

		for (String k: foundMatches.keySet()) {
			system.assert(foundMatches.get(k), 'Product Potential record was not created for (' + k.replace('#', ', ') + ')');
		}
	}

	//-------------------------------------------------

	@IsTest
	static void testSowProductsAreAddedToNewClient() {

		List<ProductSubsets__c> pss = createAllProductSubsets();
		insert pss;

		Account acc = createAccount();
		acc.Client_Co_ordinator__c = userCC.id;
		acc.primary_relationship_holder__c = 'Corporate and Investment Banking';

		List<ShareOfWalletProductsVFPController.ShareWalletProduct> swps;

		Test.startTest();

		system.runAs(userCC) {
			insert acc;
			system.assert(acc != null && acc.id != null);

			Share_Wallet__c sow = new Share_Wallet__c();
			sow.client__c = acc.id;
			sow.division__c = 'Loans';
			sow.currencyisocode = 'USD';
			insert sow;
			system.assert(sow.id != null);

			system.assertEquals(0, [SELECT id FROM Share_of_Wallet_Product__c WHERE share_of_wallet__c = :sow.id].size());

			PageReference p = Page.ShareOfWalletProducts;
			p.getParameters().put('id', sow.id);
			System.Test.setCurrentPage(p);

			ApexPages.StandardController sc = new ApexPages.StandardController(sow);
			// manipulate Product Potentials
			ShareOfWalletProductsVFPController controller = new ShareOfWalletProductsVFPController(sc);

			swps = controller.shareWalletProductLst;
		}

		Test.stopTest();

		system.assert(swps != null);

		system.assertEquals(5, swps.size(), 'Incorrect number of SOWProduct items was created'); // "Loans" is 5 times among divisions in Product Subsets
	}

	@IsTest
	static void testSowProductsAreAdded() {

		List<ProductSubsets__c> pss = createAllProductSubsets();
		insert pss;

		Account acc = createAccount();
		acc.Client_Co_ordinator__c = userCC.id;
		acc.primary_relationship_holder__c = 'Corporate and Investment Banking';

		List<ShareOfWalletProductsVFPController.ShareWalletProduct> swps;

		Test.startTest();

		system.runAs(userCC) {
			insert acc;
			system.assert(acc != null && acc.id != null);

			Share_Wallet__c sow = new Share_Wallet__c();
			sow.client__c = acc.id;
			sow.division__c = 'Loans';
			sow.currencyisocode = 'USD';
			insert sow;
			system.assert(sow.id != null);

			List<Share_of_Wallet_Product__c> swpsDb = new List<Share_of_Wallet_Product__c>();
			Share_of_Wallet_Product__c sowp1 = new Share_of_Wallet_Product__c();
			sowp1.Share_of_Wallet__c = sow.id;
			sowp1.Product_Subset__c = 'Commercial Property Finance';
			sowp1.Budget__c = 20.22 ;
			sowp1.Estimated_Total_Wallet_Size__c = 43.22;
			sowp1.Estimated_Standard_Bank_Revenue__c = 23.22 ;
			sowp1.Competitors__c = 'SBI';
			swpsDb.add(sowp1);
			insert swpsDb;

			system.assertEquals(1, [SELECT id FROM Share_of_Wallet_Product__c WHERE share_of_wallet__c = :sow.id].size());

			PageReference p = Page.ShareOfWalletProducts;
			p.getParameters().put('id', sow.id);
			System.Test.setCurrentPage(p);

			ApexPages.StandardController sc = new ApexPages.StandardController(sow);
			// manipulate Product Potentials
			ShareOfWalletProductsVFPController controller = new ShareOfWalletProductsVFPController(sc);

			swps = controller.shareWalletProductLst;
		}

		Test.stopTest();

		system.assert(swps != null);

		system.assertEquals(5, swps.size(), 'Incorrect number of SOWProduct items was created'); // "Loans" is 5 times among divisions in Product Subsets
	}
}