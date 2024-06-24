/***
    @ Func Area     	:  PBB Lifestyle
    @ Author        	:  Mykhailo Reznyk
    @ Date          	:  06.03.2020
    @ User Story    	:  US-4570, US-4572
    @ Description 	    :  Test class of PBB_SRV_GatewayAPI_GetNotes APEX class which is responsible for API callouts.
***/


@IsTest
private class PBB_SRV_GatewayAPI_GetNotes_Test {
    private static String testNoteCreationDateTime = '';
	private static final String TEST_EMPLOYEE = '-A2345678';
    private static final String TEST_EMPLOYEE_EMAIL = 'test@test.test';
/***
    @ param  	    :  No params
    @ return   	    :  void
    @ Description 	:  Setup method that creates test data.
***/
    @TestSetup
    private static void setupData(){
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_USER testUser;
        BLD_USER testUser2;
		System.runAs(new User(Id=UserInfo.getUserId())){
			testUser = new BLD_USER();
			testUser.usePbb().employeeNumber(TEST_EMPLOYEE).commitWork();
            testUser2 = new BLD_USER();
            testUser2.usePbb().email(TEST_EMPLOYEE_EMAIL).commitWork();
		}
        new BLD_Account(uow)
                .name('Test Account')
				.clientCoordinator((User)testUser.getRecord())
                .guid('4554f98f-7cc5-0135-0000-00000ab6f52b');
        new BLD_Account(uow)
                .name('Test Account2')
                .clientCoordinator((User)testUser2.getRecord())
                .guid('4554f98f-7cc5-0135-0000-00000ab61234');
        uow.commitWork();
    }

	private static User testUser {
        set;
        get {
            if (testUser == null) {
                testUser = [SELECT Id FROM USER WHERE EmployeeNumber = :TEST_EMPLOYEE];
            }
            return testUser;
        }
    }
    private static User testUserWithoutEmployeeNumber {
        set;
        get {
            if (testUserWithoutEmployeeNumber == null) {
                testUserWithoutEmployeeNumber = [SELECT Id FROM USER WHERE Email = :TEST_EMPLOYEE_EMAIL];
            }
            return testUserWithoutEmployeeNumber;
        }
    }

/***
    @ param  	    :  Integer index, Integer offset, Boolean isThereRemainingPage, Boolean isSuccess
    @ return   	    :  PBB_SRV_GatewayAPI_GetNotes.Response response - generated PBB_SRV_GatewayAPI_GetNotes.Response object
    @ Description 	:  Generates PBB_SRV_GatewayAPI_GetNotes.Response object with specified index, offset and remainingPage values, as well as list of notes, if isSuccess is true. Otherwise returns null.
***/
    private static PBB_SRV_GatewayAPI_GetNotes.Response generateResponse(Integer index, Integer offset, Boolean isThereRemainingPage, Boolean isSuccess){
        PBB_SRV_GatewayAPI_GetNotes.Response response = new PBB_SRV_GatewayAPI_GetNotes.Response();
        if(isSuccess){
            List<PBB_SRV_GatewayAPI_GetNotes.SapNote> notes = new List<PBB_SRV_GatewayAPI_GetNotes.SapNote>();
            testNoteCreationDateTime = Datetime.now().format('yyyy-MM-dd HH:mm:ss');
            for(Integer i = index; i < offset+1; i++){
                PBB_SRV_GatewayAPI_GetNotes.SapNote noteToAdd = new PBB_SRV_GatewayAPI_GetNotes.SapNote();
                noteToAdd.noteDatedOn = testNoteCreationDateTime;
                noteToAdd.type = i == 1 ? 'CREDIT CHECK' : 'ACCOUNT NOTE';
                noteToAdd.noteDetails = 'Note Text ' + i;
                noteToAdd.noteCreatedBy = 'EMPNUMBERTEST';
                notes.add(noteToAdd);
            }
            response.notes = notes;
            response.index = index;
            response.offset = offset;
            response.remainingPage = isThereRemainingPage;
        }
        else{
            response = null;
        }
        return response;
    }

/***
    @ param  	    :  No params
    @ return   	    :  void
    @ Description 	:  Mocks authentication. Create empty HttpRequest mock which is returned when authentication happens.
***/
    private static void mockAuthenticationAndRequestProviderResponse() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayRequestProvider mockedRequestProvider = (PBB_SRV_GatewayRequestProvider) mocks.mock(PBB_SRV_GatewayRequestProvider.class);
        mocks.startStubbing();
        mocks.when(mockedRequestProvider.getRequestWithToken()).thenReturn(new HttpRequest());
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayRequestProvider.IService.class, mockedRequestProvider);
    }

/***
    @ param  	    :  No params
    @ return   	    :  void
    @ Description 	:  Tests if Status Code of Response of createNote(accountId, noteBode, noteCategory) method is 200, when successful Request is sent.
***/
    @IsTest
    static void testCreateNoteCallOutWith200StatusCode() {

        Account account = [SELECT Id, Name FROM Account WHERE Name='Test Account'];

        mockAuthenticationAndRequestProviderResponse();

        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(201, '', '{"status":"successful"}', null));
        Integer statusCode;
        
        System.runAs(testUser){
            Test.startTest();
            statusCode = new PBB_SRV_GatewayAPI_GetNotes().createNote(account.Id, 'Note Body', 'Note Category');
            Test.stopTest();
        }
        System.assertEquals(201, statusCode);
    }
/***
    @ param  	    :  No params
    @ return   	    :  void
    @ Description 	:  Tests if createNote(accountId, noteBode, noteCategory) throws exception when user doesnt have Employee number.
***/
    @IsTest
    static void shouldThrowExceptionWhenUserDoesntHaveEmployeeNumber() {

        Account account = [SELECT Id, Name FROM Account WHERE Name='Test Account2'];

        mockAuthenticationAndRequestProviderResponse();

        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, '', '{"status":"successful"}', null));
        Integer statusCode;

        System.runAs(testUserWithoutEmployeeNumber){
            Test.startTest();
            try{
                statusCode = new PBB_SRV_GatewayAPI_GetNotes().createNote(account.Id, 'Note Body', 'Note Category');
                System.assert(false, 'Should throw an exception');
            }catch(Exception exp){
                System.assertEquals('You cannot create note, Please contact System Administrator.', exp.getMessage());
            }
            Test.stopTest();
        }
    }

/***
    @ param  	    :  No params
    @ return   	    :  void
    @ Description 	:  Tests if Status Code of Response of createNote(accountId, noteBode, noteCategory) method is 500, when there is some Internal Server Error.
***/
    @IsTest
    static void testCreateNoteCallOutWith500StatusCode() {

        Account account = [SELECT Id, Name FROM Account WHERE Name='Test Account'];
        Integer statusCode;
        Boolean flag = false;

        mockAuthenticationAndRequestProviderResponse();

        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(500, '', '{"trace_id":"test-trace-id"}', null));
        System.runAs(testUser){
            Test.startTest();
            try {
                statusCode = new PBB_SRV_GatewayAPI_GetNotes().createNote(account.Id, 'Note Body', 'Note Category');
            } catch (PBB_SRV_GatewayAPI_GetNotes.ApiException e) {
                flag = true;
                System.assertEquals('Error! For client ' + account.Id + ' Got 500 with , body {"trace_id":"test-trace-id"}', e.getMessage());
                System.assertEquals(null, statusCode);
            }

            Test.stopTest();
        }
        System.assertEquals(true, flag);
    }

/***
    @ param  	    :  No params
    @ return   	    :  void
    @ Description 	:  Tests if getNotes(accountId, index, offset, categories) method returns proper Response, when successful Request is sent
***/
    @IsTest
    static void testGetNotesCallOutWith200StatusCode() {

        Account account = [SELECT Id, Name FROM Account WHERE Name='Test Account'];

        mockAuthenticationAndRequestProviderResponse();

        PBB_SRV_GatewayAPI_GetNotes.Response responseBody = generateResponse(1, 2, true, true);

        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(200, '', JSON.serialize(responseBody), null));

        Test.startTest();
        PBB_SRV_GatewayAPI_GetNotes.Response response = new PBB_SRV_GatewayAPI_GetNotes().getNotes(account.Id, 1, 2, new List<String>{'ALL'});
        Test.stopTest();

        //Response assertion
        System.assertEquals(1, response.index);
        System.assertEquals(2, response.offset);
        System.assertEquals(true, response.remainingPage);
        System.assertEquals(2, response.notes.size());

        //Note 1 content assertion
        System.assertEquals(testNoteCreationDateTime, response.notes[0].noteDatedOn);
        System.assertEquals('EMPNUMBERTEST', response.notes[0].noteCreatedBy);
        System.assertEquals('Note Text 1', response.notes[0].noteDetails);
        System.assertEquals('CREDIT CHECK', response.notes[0].type);

        //Note 2 content assertion
        System.assertEquals(testNoteCreationDateTime, response.notes[0].noteDatedOn);
        System.assertEquals('EMPNUMBERTEST', response.notes[1].noteCreatedBy);
        System.assertEquals('Note Text 2', response.notes[1].noteDetails);
        System.assertEquals('ACCOUNT NOTE', response.notes[1].type);
    }

/***
    @ param  	    :  No params
    @ return   	    :  void
    @ Description 	:  Tests if getNotes(account, index, offset, categories) method returns null, when there is Internal Server Error
***/
    @IsTest
    static void testGetNotesCallOutWith500StatusCode() {
        Boolean flag = false;
        PBB_SRV_GatewayAPI_GetNotes.Response response;
        Account account = [SELECT Id, Name FROM Account WHERE Name='Test Account'];

        mockAuthenticationAndRequestProviderResponse();

        PBB_SRV_GatewayAPI_GetNotes.Response responseBody = generateResponse(1, 2, true, false);

        Test.setMock(HttpCalloutMock.class, new SingleRequestMock(500, '', JSON.serialize(responseBody), null));

        Test.startTest();
        try {
            response = new PBB_SRV_GatewayAPI_GetNotes().getNotes(account.Id, 1, 2, new List<String>{'ALL'});
        } catch (PBB_SRV_GatewayAPI_GetNotes.ApiException e) {
            flag = true;
            System.assertEquals('Error! For client ' + account.Id + ' Got 500 with , body null', e.getMessage());
            System.assertEquals(null, response);
        }

        Test.stopTest();

        //Response assertion
        System.assertEquals(true, flag);

    }


}