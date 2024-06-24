/*****************************************************************************************************************************************************************************************************************
    @ Author        : Shubham Khilauria
    @ Date          : 13 - Feb - 2014
    @ Description   : Test Class for ClientOperatingCountryControllerClass.cls. This class will test the Unit test for Drag and Drop Page
    				  which will include creating Existing Business Records, Prospective Business Records and also the scenario when 
    				  Client doesn't have any Client Operating COuntries associated to it.
******************************************************************************************************************************************************************************************************************/

@isTest(seealldata = false)
private class Test_ClientOpCountryControllerClass {
	/************************************************************************************************
	Scenario - Positive -Test Existing Business Records. Move few countries from Not assigned 
				status to Existing and prospective and save the records.
	*************************************************************************************************/
    static testMethod void testExistingBusinessRecord() {
		TEST_DataFactory.insertClientOperatingCountriesSettings();

		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

		BLD_Account accBld = new BLD_Account(uow).useChild();
		uow.commitWork();

		test.startTest();
		System.runAs(new User(Id = UserInfo.getUserId())) {
			String status = 'Existing Business';
			new BLD_ClientOperatingCountries(uow).client(accBld).country('South Africa').status(status).cibPresence(true);
			new BLD_ClientOperatingCountries(uow).client(accBld).country('India').status(status).cibPresence(true);
			new BLD_ClientOperatingCountries(uow).client(accBld).country('Australia').status(status).cibPresence(true);
			uow.commitWork();
        	ApexPages.StandardController std_Controller = new ApexPages.StandardController(accBld.getRecord());
        	PageReference testPage 	= Page.ClientOperatingCountryPage;
			testPage.getParameters().put('Id',accBld.getRecordId());  		// passing the Record ID of associated Customer
			testPage.getParameters().put('presence','true');
			Test.setCurrentPage(testPage);
			system.assertEquals(ApexPages.currentPage().getParameters().get('Id'),accBld.getRecordId());
        	ClientOperatingCountryControllerClass COpCCC = new ClientOperatingCountryControllerClass(std_controller);
        	
        	// Moving Hong Kong from Not Assigned to Prospective Business
        	ApexPages.currentPage().getParameters().put('StatusPres','PBPreCount');
        	ApexPages.currentPage().getParameters().put('Country','Hong Kong-NAPreCount');
        	CopCCC.updateClientOperatingCountry();
        	
        	//Moving China from Not Assigned to Existing Business
        	ApexPages.currentPage().getParameters().put('StatusPres','EBPreCount');
        	ApexPages.currentPage().getParameters().put('Country','China-NAPreCount');
        	CopCCC.updateClientOperatingCountry();
        	
        	// Moving Kenya from Not Assigned to Prospective Business
        	ApexPages.currentPage().getParameters().put('StatusPres','PBPreCount');
        	ApexPages.currentPage().getParameters().put('Country','Kenya-NAPreCount');
        	CopCCC.updateClientOperatingCountry();
        	
        	//Moving back China to Not Assigned List.
        	ApexPages.currentPage().getParameters().put('StatusPres','NAPreCount');
        	ApexPages.currentPage().getParameters().put('Country','China-EBPreCount');
        	CopCCC.updateClientOperatingCountry();
        	
        	//Moving Hong Kong back to Not Assigned List.
        	ApexPages.currentPage().getParameters().put('StatusPres','NAPreCount');
        	ApexPages.currentPage().getParameters().put('Country','Hong Kong-PBPreCount');
        	CopCCC.updateClientOperatingCountry();
        	
        	// Saving the Changed Records
        	CopCCC.saveRecords();
		}	
	
	   test.stopTest();
	}
	
	/************************************************************************************************
	Scenario - Negative - Test prospective Business Records. Move few countries from Not assigned 
				status to prospective and cancel the records without saving.
	*************************************************************************************************/
	 static testMethod void testProspectiveBusinessRecord() {
        TEST_DataFactory.insertClientOperatingCountriesSettings();

		 fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

		 BLD_Account accBld = new BLD_Account(uow).useChild();
		 uow.commitWork();

		test.startTest();
		System.runAs(new User(Id = UserInfo.getUserId())) {
			String status = 'Prospective Business';
			new BLD_ClientOperatingCountries(uow).client(accBld).country('South Africa').status(status).cibPresence(true);
			new BLD_ClientOperatingCountries(uow).client(accBld).country('India').status(status).cibPresence(true);
			new BLD_ClientOperatingCountries(uow).client(accBld).country('Australia').status(status).cibPresence(true);
			uow.commitWork();
        	ApexPages.StandardController std_Controller = new ApexPages.StandardController(accBld.getRecord());
        	PageReference testPage 	= Page.ClientOperatingCountryPage;
			testPage.getParameters().put('Id',accBld.getRecordId());  		// passing the Record ID of associated Customer
			testPage.getParameters().put('presence','true');
			Test.setCurrentPage(testPage);
			System.assertEquals(ApexPages.currentPage().getParameters().get('Id'),accBld.getRecordId());
        	ClientOperatingCountryControllerClass COpCCC = new ClientOperatingCountryControllerClass(std_controller);
        	
        	// Moving Hong Kong from Not Assigned to Prospective Business
        	ApexPages.currentPage().getParameters().put('StatusPres','PBPreCount');
        	ApexPages.currentPage().getParameters().put('Country','Hong Kong-NAPreCount');
        	CopCCC.updateClientOperatingCountry();
        	
        	//Moving China from Not Assigned to Existing Business
        	ApexPages.currentPage().getParameters().put('StatusPres','EBPreCount');
        	ApexPages.currentPage().getParameters().put('Country','China-NAPreCount');
        	CopCCC.updateClientOperatingCountry();
        	
        	// Cancel the changes
        	CopCCC.cancel();       	
        	
		}	
	
	   test.stopTest();
	} 
	
	/************************************************************************************************
	Scenario - Negative - Test No saving of Records. Move few countries from Not assigned 
				status to prospective and cancel the records without saving.
	*************************************************************************************************/
	static testMethod void testNoClientOperatingCountryRecords() {
        TEST_DataFactory.insertClientOperatingCountriesSettings();

		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

		BLD_Account accBld = new BLD_Account(uow).useChild();
		uow.commitWork();
        
		test.startTest();
		System.runAs(new User(Id = UserInfo.getUserId())) {
			
        	ApexPages.StandardController std_Controller = new ApexPages.StandardController(accBld.getRecord());
        	PageReference testPage 	= Page.ClientOperatingCountryPage;
			testPage.getParameters().put('Id',accBld.getRecordId());  		// passing the Record ID of associated Customer
			testPage.getParameters().put('presence','true');
			Test.setCurrentPage(testPage);
			System.assertEquals(ApexPages.currentPage().getParameters().get('Id'),accBld.getRecordId());
        	ClientOperatingCountryControllerClass COpCCC = new ClientOperatingCountryControllerClass(std_controller);
        	
        	// Moving Hong Kong from Not Assigned to Prospective Business
        	ApexPages.currentPage().getParameters().put('StatusPres','PBPreCount');
        	ApexPages.currentPage().getParameters().put('Country','Hong Kong-NAPreCount');
        	CopCCC.updateClientOperatingCountry();
        	
        	//Moving China from Not Assigned to Existing Business
        	ApexPages.currentPage().getParameters().put('StatusPres','EBPreCount');
        	ApexPages.currentPage().getParameters().put('Country','China-NAPreCount');
        	CopCCC.updateClientOperatingCountry();
        	
        	// Cancel the changes
        	CopCCC.saveRecords();       	
        	
		}	
	
	   test.stopTest();
	} 
}