/*****************************************************************************************************************************************************************************************************************
    @ Author        : Shubham Khilauria
    @ Date          : 13 - Feb - 2014
    @description   : Test Class for ClientOpCountryComponentController.cls. This class will test the Unit test for the component displayed
    				  on Client Plan page.Scenarios which will include creating Existing Business Records, Prospective Business Records for CIB present as well 
    				  not present countries.
******************************************************************************************************************************************************************************************************************/
@IsTest
private class Test_ClientOpCountryCompController {

    @IsTest
    static void testCIBPresentRecord() {
		TEST_DataFactory.insertClientOperatingCountriesSettings();
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		User admUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
		System.runAs(new User(Id = UserInfo.getUserId())) {
			uow.commitWork();
		}
		Account accRec = (Account) new BLD_Account(uow).useChild()
			.addOperatingCountry(
				new BLD_ClientOperatingCountries(uow)
					.cibPresence(true)
					.status('Existing Business')
			)
			.addOperatingCountry(
				new BLD_ClientOperatingCountries(uow)
					.cibPresence(true)
					.status('Prospective Business')
			)
			.getRecord();

		uow.commitWork();

		test.startTest();
        try {
            System.runAs(admUser) {
                ApexPages.StandardController standardControllerController = new ApexPages.StandardController(accRec);
                PageReference testPage 	= Page.ClientPlan;
                testPage.getParameters().put('Id', accRec.Id);  		// passing the Record ID of associated Customer
                Test.setCurrentPage(testPage);
                ClientOpCountryComponentController clientOpCountryComponentController = new ClientOpCountryComponentController(standardControllerController);

                testPage.getParameters().put('presence','true');
                clientOpCountryComponentController.editCOCRecord();
            }
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
	
	   test.stopTest();
	}

    @IsTest
    static void testCIBNotPresentRecord() {
		TEST_DataFactory.insertClientOperatingCountriesSettings();
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		User admUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        system.runAs(new User(Id = UserInfo.getUserId())){
        	 uow.commitWork();
        }
		Account accRec = (Account) new BLD_Account(uow).useChild()
			.addOperatingCountry(
				new BLD_ClientOperatingCountries(uow)
					.cibPresence(false)
					.status('Existing Business')
			)
			.addOperatingCountry(
				new BLD_ClientOperatingCountries(uow)
					.cibPresence(false)
					.status('Prospective Business')
			)
			.getRecord();

		uow.commitWork();

		test.startTest();
        try {
            system.runAs(admUser){
                ApexPages.StandardController standardController = new ApexPages.StandardController(accRec);
                PageReference testPage 	= Page.ClientPlan;
                testPage.getParameters().put('Id', accRec.Id);  		// passing the Record ID of associated Customer
                Test.setCurrentPage(testPage);
                ClientOpCountryComponentController clientOpCountryComponentController = new ClientOpCountryComponentController(standardController);
                testPage.getParameters().put('presence','false');
                clientOpCountryComponentController.editCOCRecord();
            }
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
	   test.stopTest();
	}
}