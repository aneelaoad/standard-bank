@isTest
private class StdBank_Ltn_QuickLinks_Test {
	public static final String LINKCONTEXT = 'Homepage';
	public static final String USERDIVISIONS = 'Business Enablers,Client Coverage,Client Services,Commercial Banking,Credit,General Management,Global Markets,Investment Banking,Real Estate,Transactional Products and Services';

	@isTest
	private static void noData(){
		Test.startTest();
			Map<Decimal,List<QuickLinks__c>> data = StdBank_Ltn_QuickLinks_Ctrl.getQuickLinks(new List<Decimal>{12},LINKCONTEXT);
		Test.stopTest();
		System.assertNotEquals(null,data);
		System.assertEquals(0, data.size());
	}
	@isTest
	private static void multiColumns(){
		Integer linksCount = 21;
		List<QuickLinks__c> linksToInsert = new List<QuickLinks__c>();
		List<Decimal> columns = new List<Decimal>();
		for(Integer i = 0 ; i < linksCount; i++){
			linksToInsert.add(new QuickLinks__c(Column_Id__c = i, Label_del__c = i + '21' + i, Name = i+'', Order__c = i, Link__c = 'www.google.com', Show_for_Division__c = USERDIVISIONS, Object_Visibility__c = LINKCONTEXT));
			columns.add(i);
		}
		INSERT linksToInsert;
		Test.startTest();
			Map<Decimal,List<QuickLinks__c>> data = StdBank_Ltn_QuickLinks_Ctrl.getQuickLinks(columns,LINKCONTEXT);
		Test.stopTest();
		System.assertNotEquals(null,data);
		System.assertEquals(linksCount, data.size());
	}
	@isTest
	private static void oneColumn(){
		Integer linksCount = 21;
		List<QuickLinks__c> linksToInsert = new List<QuickLinks__c>();
		List<Decimal> columns = new List<Decimal>();
		for(Integer i = 0 ; i < linksCount; i++){
			linksToInsert.add(new QuickLinks__c(Column_Id__c = 1, Label_del__c = i + '21' + i, Name = i+'', Order__c = i, Link__c = 'www.google.com', Show_for_Division__c = USERDIVISIONS, Object_Visibility__c = LINKCONTEXT));
			columns.add(i);
		}
		INSERT linksToInsert;
		Test.startTest();
			Map<Decimal,List<QuickLinks__c>> data = StdBank_Ltn_QuickLinks_Ctrl.getQuickLinks(columns,LINKCONTEXT);
		Test.stopTest();
		System.assertNotEquals(null,data);
		System.assertEquals(1, data.size());
	}
	@isTest
	private static void orderCheck(){
		Integer linksCount = 21;
		List<QuickLinks__c> linksToInsert = new List<QuickLinks__c>();
		List<Decimal> columns = new List<Decimal>();
		for(Integer i = linksCount ; i > 0 ; i--){
			linksToInsert.add(new QuickLinks__c(Column_Id__c = 1, Label_del__c = i + '21' + i, Name = i+'', Order__c = i, Link__c = 'www.google.com', Show_for_Division__c = USERDIVISIONS, Object_Visibility__c = LINKCONTEXT));
			columns.add(i);
		}
		INSERT linksToInsert;
		Test.startTest();
			Map<Decimal,List<QuickLinks__c>> data = StdBank_Ltn_QuickLinks_Ctrl.getQuickLinks(columns,LINKCONTEXT);
		Test.stopTest();
		System.assertNotEquals(null,data);
		System.assertEquals(1, data.size());
		System.assertEquals('1211', data.get(1)[0].Label_del__c);

	}
	@isTest
	private static void diffrentColumnId(){
		Integer linksCount = 21;
		List<QuickLinks__c> linksToInsert = new List<QuickLinks__c>();		
		for(Integer i = linksCount ; i > 0 ; i--){
			linksToInsert.add(new QuickLinks__c(Column_Id__c = 1, Label_del__c = i + '21' + i, Name = i+'', Order__c = i, Link__c = 'www.google.com', Show_for_Division__c = USERDIVISIONS, Object_Visibility__c = LINKCONTEXT));
		}
		INSERT linksToInsert;
		Test.startTest();
			Map<Decimal,List<QuickLinks__c>> data = StdBank_Ltn_QuickLinks_Ctrl.getQuickLinks(new List<Decimal>{213},LINKCONTEXT);
		Test.stopTest();
		System.assertNotEquals(null,data);
		System.assertEquals(0, data.size());	

	}


	/** this function will test the show dashboard
	 */
	@isTest
	private static void testShouldShowDashboard(){
		Boolean isDashboardShown = StdBank_Ltn_QuickLinks_Ctrl.shouldShowDashboard();
        System.assert(isDashboardShown);
	}


}