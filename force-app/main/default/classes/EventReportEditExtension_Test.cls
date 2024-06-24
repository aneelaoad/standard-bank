@isTest
private class EventReportEditExtension_Test {
	
	@isTest 
	static void testEverything() {
		ApexPages.StandardController stdController = 
			new ApexPages.StandardController(
				new Call_Report__c(End__c = DateTime.now())
			);
		EventReportEditExtension extension = new EventReportEditExtension(stdController);
        ApexPages.PageReference reference1 = extension.save();
		stdController = 
			new ApexPages.StandardController(
				new Call_Report__c()
			);
		extension = new EventReportEditExtension(stdController);
        ApexPages.PageReference reference2 = extension.save();
        System.assertEquals(null, reference1);
        System.assertEquals(null, reference2);
	}
	
}