@IsTest
private inherited sharing class SRV_Logger_TEST {

	@TestSetup
    private static void createData() {
        sbgplatform__rflib_Logger_Settings__c newrec = new sbgplatform__rflib_Logger_Settings__c
        	(sbgplatform__Archive_Log_Level__c='NONE',sbgplatform__Batched_Log_Event_Reporting_Level__c='NONE',
            sbgplatform__Client_Console_Log_Level__c='DEBUG',sbgplatform__Client_Log_Size__c=100,sbgplatform__Client_Server_Log_Level__c='INFO',
            sbgplatform__Email_Log_Level__c='NONE',sbgplatform__Enable_Log_Masking__c=false,sbgplatform__Flush_Log_Cache_Level__c='NONE',
            sbgplatform__Functions_Compute_Log_Level__c='DEBUG',sbgplatform__Functions_Log_Size__c=100,sbgplatform__Functions_Server_Log_Level__c='WARN',
            sbgplatform__General_Log_Level__c='TRACE',sbgplatform__Log_Event_Reporting_Level__c='INFO',
            sbgplatform__Log_Finalizer_Class__c='rflib_DefaultLogFinalizer',sbgplatform__Log_Size__c=100,
            sbgplatform__Log_Timer_Class__c='rflib_DefaultLogTimer',sbgplatform__Logger_Factory_Class__c='rflib_DefaultLoggerFactory',
            sbgplatform__System_Debug_Log_Level__c='DEBUG', SetupOwnerId=UserInfo.getOrganizationId());
        insert newrec;
    }

	@IsTest
	private static void shouldLogExceptionAndSource() {
		/*fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
		ORG_Application.unitOfWork.setMock(uowMock);

		String expectedArea = 'area';
		Test.startTest();
		new SRV_Logger().log(new DmlException('test'), expectedArea);
		Test.stopTest();

		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
		((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerPublishBeforeTransaction((Log_Event__e) argument.capture());
		Log_Event__e publishedEvent = (Log_Event__e) argument.getValue();
		System.assertEquals(DMN_Log.TYPE_ERROR, publishedEvent.Type__c);
		System.assertEquals(expectedArea, publishedEvent.Area__c);*/

		Test.startTest();
    	String expectedArea = 'area';
		new SRV_Logger().log(new DmlException('test'), expectedArea);
		Test.getEventBus().deliver();
    	Test.stopTest();
		List<sbgplatform__rflib_Log__c> debugRecord = 	[SELECT sbgplatform__Request_ID__c, createddate, sbgplatform__Log_Level__c, 
														sbgplatform__Context__c, Name, sbgplatform__Log_Messages__c 
														FROM sbgplatform__rflib_Log__c WHERE sbgplatform__Log_Level__c='ERROR'];
		Assert.areEqual(1, debugRecord.size(), 'log stored for error level');
		Assert.isTrue(debugRecord[0].sbgplatform__Log_Messages__c.contains(expectedArea));
	}

	@IsTest
	private static void shouldLogExceptionAndSourceAndArea() {
		/*fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
		ORG_Application.unitOfWork.setMock(uowMock);
		String expectedSource = 'source';
		String expectedArea = 'area';

		Test.startTest();
		new SRV_Logger().log(new DmlException('test'), expectedArea, expectedSource);
		Test.stopTest();
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
		((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerPublishBeforeTransaction((Log_Event__e) argument.capture());
		Log_Event__e publishedEvent = (Log_Event__e) argument.getValue();

		System.assertEquals(DMN_Log.TYPE_ERROR, publishedEvent.Type__c);
		System.assertEquals(expectedSource, publishedEvent.Source__c);
		System.assertEquals(expectedArea, publishedEvent.Area__c);*/

		Test.startTest();
    	String expectedArea = 'area';
		String expectedSource = 'source';
		new SRV_Logger().log(new DmlException('test'), expectedArea, expectedSource);
		Test.getEventBus().deliver();
    	Test.stopTest();

		List<sbgplatform__rflib_Log__c> debugRecord = 	[SELECT sbgplatform__Request_ID__c, createddate, sbgplatform__Log_Level__c, 
														sbgplatform__Context__c, Name, sbgplatform__Log_Messages__c 
														FROM sbgplatform__rflib_Log__c WHERE sbgplatform__Log_Level__c='ERROR'];
		Assert.areEqual(1, debugRecord.size(), 'log stored for error level');
		Assert.isTrue(debugRecord[0].sbgplatform__Log_Messages__c.contains(expectedArea));
		Assert.isTrue(debugRecord[0].sbgplatform__Log_Messages__c.contains(expectedSource));
	}

	@IsTest
	private static void shouldLogExceptionAndSourceAndAreaAndMessages() {
		/*fflib_ApexMocks mocks = new fflib_ApexMocks();
		fflib_ISObjectUnitOfWork uowMock = new fflib_SObjectMocks.SObjectUnitOfWork(mocks);
		ORG_Application.unitOfWork.setMock(uowMock);
		String expectedSource = 'source';
		String expectedArea = 'area';
		String message = 'test';
		DmlException ex = new DmlException(message);
		List<String> additionalMessages = new List<String>{'message'};

		Test.startTest();
		new SRV_Logger().log(ex, expectedArea, expectedSource, additionalMessages);
		Test.stopTest();
		fflib_ArgumentCaptor argument = fflib_ArgumentCaptor.forClass(fflib_ISObjectUnitOfWork.class);
		((fflib_ISObjectUnitOfWork) mocks.verify(uowMock, 1)).registerPublishBeforeTransaction((Log_Event__e) argument.capture());
		Log_Event__e publishedEvent = (Log_Event__e) argument.getValue();

		System.assertEquals(DMN_Log.TYPE_ERROR, publishedEvent.Type__c);
		System.assertEquals(expectedSource, publishedEvent.Source__c);
		System.assertEquals(expectedArea, publishedEvent.Area__c);
		System.assertEquals(ex.getTypeName() + ': ' + ex.getMessage() + '\n' +additionalMessages[0], publishedEvent.Message__c);*/

		Test.startTest();
    	String expectedArea = 'area';
		String expectedSource = 'source';
		String message = 'test';
		List<String> additionalMessages = new List<String>{'message'};
		DmlException ex = new DmlException(message);
		new SRV_Logger().log(ex, expectedArea, expectedSource, additionalMessages);
		Test.getEventBus().deliver();
    	Test.stopTest();

		List<sbgplatform__rflib_Log__c> debugRecord = 	[SELECT sbgplatform__Request_ID__c, createddate, sbgplatform__Log_Level__c, 
														sbgplatform__Context__c, Name, sbgplatform__Log_Messages__c 
														FROM sbgplatform__rflib_Log__c WHERE sbgplatform__Log_Level__c='ERROR' AND sbgplatform__Context__c='SRV_Logger'];
		Assert.areEqual(1, debugRecord.size(), 'log stored for error level');
		Assert.isTrue(debugRecord[0].sbgplatform__Log_Messages__c.contains(expectedArea));
		Assert.isTrue(debugRecord[0].sbgplatform__Log_Messages__c.contains(expectedSource));
		Assert.isTrue(debugRecord[0].sbgplatform__Log_Messages__c.contains(message));
	}

	@IsTest
	private static void shouldLogErrorAndSourceAndAreaAndMessages() {
		Test.startTest();
    	String expectedArea = 'area';
		String expectedSource = 'source';
		String expectedError = 'error';		
		new SRV_Logger().log(expectedError, expectedArea, expectedSource);
		Test.getEventBus().deliver();
    	Test.stopTest();

		List<sbgplatform__rflib_Log__c> debugRecord = 	[SELECT sbgplatform__Request_ID__c, createddate, sbgplatform__Log_Level__c, 
														sbgplatform__Context__c, Name, sbgplatform__Log_Messages__c 
														FROM sbgplatform__rflib_Log__c WHERE sbgplatform__Log_Level__c='ERROR' AND sbgplatform__Context__c='SRV_Logger'];
		Assert.areEqual(1, debugRecord.size(), 'log stored for error level');
		Assert.isTrue(debugRecord[0].sbgplatform__Log_Messages__c.contains(expectedArea));
		Assert.isTrue(debugRecord[0].sbgplatform__Log_Messages__c.contains(expectedSource));
		Assert.isTrue(debugRecord[0].sbgplatform__Log_Messages__c.contains(expectedError));
	}

	@IsTest
	private static void shouldLogInsertExceptionAndDMLException() {
		Test.startTest();
    	String expectedArea = 'area';
		String expectedSource = 'source';
		Contact c = new Contact();
		List<Contact> conList = new List<Contact>();
		conList.add(c);
		List<Database.SaveResult> saveResults = Database.insert(conList, false);
		System.debug('saveResults : '+saveResults);
		new SRV_Logger().log(saveResults, expectedArea, expectedSource);
		Test.getEventBus().deliver();
    	Test.stopTest();

		List<sbgplatform__rflib_Log__c> debugRecord = 	[SELECT sbgplatform__Request_ID__c, createddate, sbgplatform__Log_Level__c, 
														sbgplatform__Context__c, Name, sbgplatform__Log_Messages__c 
														FROM sbgplatform__rflib_Log__c WHERE sbgplatform__Log_Level__c='ERROR' AND sbgplatform__Context__c='SRV_Logger'];
		Assert.areEqual(1, debugRecord.size(), 'log stored for error level');
		Assert.isTrue(debugRecord[0].sbgplatform__Log_Messages__c.contains(expectedArea));
		Assert.isTrue(debugRecord[0].sbgplatform__Log_Messages__c.contains(expectedSource));
	}

	@IsTest
	private static void shouldLogInsertDMLException() {
		Test.startTest();
    	String expectedArea = 'area';
		Contact c = new Contact();
		List<Contact> conList = new List<Contact>();
		conList.add(c);
		List<Database.SaveResult> saveResults = Database.insert(conList, false);
		System.debug('saveResults : '+saveResults);
		new SRV_Logger().log(saveResults, expectedArea);
		Test.getEventBus().deliver();
    	Test.stopTest();

		List<sbgplatform__rflib_Log__c> debugRecord = 	[SELECT sbgplatform__Request_ID__c, createddate, sbgplatform__Log_Level__c, 
														sbgplatform__Context__c, Name, sbgplatform__Log_Messages__c 
														FROM sbgplatform__rflib_Log__c WHERE sbgplatform__Log_Level__c='ERROR' AND sbgplatform__Context__c='SRV_Logger'];
		Assert.areEqual(1, debugRecord.size(), 'log stored for error level');
		Assert.isTrue(debugRecord[0].sbgplatform__Log_Messages__c.contains(expectedArea));
	}

	@IsTest
	private static void shouldLogUpsertExceptionAndDMLException() {
		Test.startTest();
    	String expectedArea = 'area';
		String expectedSource = 'source';
		Contact c = new Contact();
		List<Contact> conList = new List<Contact>();
		conList.add(c);
		List<Database.UpsertResult> saveResults = Database.upsert(conList, false);
		System.debug('saveResults : '+saveResults);		
		new SRV_Logger().log(saveResults, expectedArea, expectedSource);
		Test.getEventBus().deliver();
    	Test.stopTest();

		List<sbgplatform__rflib_Log__c> debugRecord = 	[SELECT sbgplatform__Request_ID__c, createddate, sbgplatform__Log_Level__c, 
														sbgplatform__Context__c, Name, sbgplatform__Log_Messages__c 
														FROM sbgplatform__rflib_Log__c WHERE sbgplatform__Log_Level__c='ERROR' AND sbgplatform__Context__c='SRV_Logger'];
		Assert.areEqual(1, debugRecord.size(), 'log stored for error level');
		Assert.isTrue(debugRecord[0].sbgplatform__Log_Messages__c.contains(expectedArea));
		Assert.isTrue(debugRecord[0].sbgplatform__Log_Messages__c.contains(expectedSource));
	}

	@IsTest
	private static void shouldLogUpsertDMLException() {
		Test.startTest();
    	String expectedArea = 'area';
		Contact c = new Contact();
		List<Contact> conList = new List<Contact>();
		conList.add(c);
		List<Database.UpsertResult> saveResults = Database.upsert(conList, false);
		System.debug('saveResults : '+saveResults);		
		new SRV_Logger().log(saveResults, expectedArea);
		Test.getEventBus().deliver();
    	Test.stopTest();

		List<sbgplatform__rflib_Log__c> debugRecord = 	[SELECT sbgplatform__Request_ID__c, createddate, sbgplatform__Log_Level__c, 
														sbgplatform__Context__c, Name, sbgplatform__Log_Messages__c 
														FROM sbgplatform__rflib_Log__c WHERE sbgplatform__Log_Level__c='ERROR' AND sbgplatform__Context__c='SRV_Logger'];
		Assert.areEqual(1, debugRecord.size(), 'log stored for error level');
		Assert.isTrue(debugRecord[0].sbgplatform__Log_Messages__c.contains(expectedArea));
	}

	@IsTest
	private static void shouldLogDeleteExceptionAndDMLException() {
		Test.startTest();
    	String expectedArea = 'area';
		String expectedSource = 'source';
		Contact c = new Contact(LastName='TestContact');
		List<Contact> conList = new List<Contact>();
		conList.add(c);
		insert conList;
		List<Database.DeleteResult> saveResults = Database.delete(conList, false);
		System.debug('saveResults : '+saveResults);
		new SRV_Logger().log(saveResults, expectedArea, expectedSource);
		Test.getEventBus().deliver();
    	Test.stopTest();

		List<sbgplatform__rflib_Log__c> debugRecord = 	[SELECT sbgplatform__Request_ID__c, createddate, sbgplatform__Log_Level__c, 
														sbgplatform__Context__c, Name, sbgplatform__Log_Messages__c 
														FROM sbgplatform__rflib_Log__c WHERE sbgplatform__Log_Level__c='ERROR' AND sbgplatform__Context__c='SRV_Logger'];
		Assert.areEqual(0, debugRecord.size(), 'log stored for error level');
	}

	@IsTest
	private static void shouldLogDeleteDMLException() {
		Test.startTest();
    	String expectedArea = 'area';
		Contact c = new Contact(LastName='TestContact');
		List<Contact> conList = new List<Contact>();
		conList.add(c);
		insert conList;
		List<Database.DeleteResult> saveResults = Database.delete(conList, false);
		System.debug('saveResults : '+saveResults);
		new SRV_Logger().log(saveResults, expectedArea);
		Test.getEventBus().deliver();
    	Test.stopTest();

		List<sbgplatform__rflib_Log__c> debugRecord = 	[SELECT sbgplatform__Request_ID__c, createddate, sbgplatform__Log_Level__c, 
														sbgplatform__Context__c, Name, sbgplatform__Log_Messages__c 
														FROM sbgplatform__rflib_Log__c WHERE sbgplatform__Log_Level__c='ERROR' AND sbgplatform__Context__c='SRV_Logger'];
		Assert.areEqual(0, debugRecord.size(), 'log stored for error level');
	}
}