@isTest
private class StdBank_Ltn_ReportLinkController_Test {
	
	@isTest static void shouldThrowNoReportException() {
		User stdUser = (User) new BLD_USER().useCib().getRecord();
		String reportName = 'BlankName';
		Boolean hasExcetpion = false;
		String exceptionMesage; 
		String expectedExceptionMessage = String.format(Label.No_record_found, new String[]{reportName});

		
		Test.startTest();
		System.runAs(stdUser) {
			try{
				StdBank_Ltn_ReportLinkController.getReportId(reportName);
			}
			catch(StdBank_Ltn_ReportLinkController.ReportLinkException ex){
				hasExcetpion = true;
				exceptionMesage = ex.getMessage();
			}
		}
		Test.stopTest();
		System.assertEquals(true, hasExcetpion);
		System.assertEquals(expectedExceptionMessage, exceptionMesage);

	}
	
	@isTest static void shouldThrowNoReportNameException() {
		User stdUser = (User) new BLD_USER().useCib().getRecord();
		String reportName;
		Boolean hasExcetpion = false;
		String exceptionMesage; 
		String expectedExceptionMessage = Label.No_input_parameter_defined;

		
		Test.startTest();
		System.runAs(stdUser) {
			try{
				StdBank_Ltn_ReportLinkController.getReportId(reportName);
			}
			catch(StdBank_Ltn_ReportLinkController.ReportLinkException ex){
				hasExcetpion = true;
				exceptionMesage = ex.getMessage();
			}
		}
		Test.stopTest();
		System.assertEquals(true, hasExcetpion);
		System.assertEquals(expectedExceptionMessage, exceptionMesage);
	}

}