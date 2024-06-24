/**
*  @FuncArea PBB Lifestyle
*  @Author Mykhailo Reznyk
*  @Date 05.03.2020
*  @UserStory US-4570, US-4572
*  @Description Test class of APEX Controller for PBB_SapNotes component
*/
@IsTest
private class PBB_SapNotes_Controller_Test {
    private static String testNoteCreationDateTime = '';
    private static final String TEST_EMPLOYEE_EMAIL = 'testuser@sometestorgpurple.com';

    private static User testUser {
        set;
        get {
            if (testUser == null) {
                testUser = [SELECT Id, Name FROM USER WHERE email = :TEST_EMPLOYEE_EMAIL];
            }
            return testUser;
        }
    }
/***
    @ param  	    :  No params
    @ return   	    :  void
    @ Description 	:  Setup method that creates test data.
***/
    @testSetup
    static void setupData() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        //Create PBB Note Types Custom Settings values
        Boolean isAccountNotepad = false;
        Boolean isCustomerNotepad = false;
        for(Integer i = 0; i < 5; i++){
            if(i < 3){
                isAccountNotepad = false;
                isCustomerNotepad = true;
            }
            else{
                isAccountNotepad = true;
                isCustomerNotepad = false;
            }
            new BLD_PbbNoteTypes(uow)
                .name('noteCategory-' + i)
                .noteTypeName('noteCategory-' + i)
                .accountNotepad(isAccountNotepad)
                .customerNotepad(isCustomerNotepad);
        }
        uow.commitWork();

        //Create test user
        BLD_USER testUser;
        System.runAs(new User(Id=UserInfo.getUserId())){
            testUser = new BLD_USER();
            testUser.usePbb()
                    .email(TEST_EMPLOYEE_EMAIL)
                    .employeeNumber('EmpNumberTest')
                    .profile('System Administrator')
                    .commitWork();
        }

        //Create Test Account
        new BLD_Account(uow)
                .name('Test Account')
                .clientCoordinator((User)testUser.getRecord())
                .guid('00000000000000000000000000000000');
        new BLD_Account(uow)
                .name('Fail Test Account')
                .clientCoordinator((User)testUser.getRecord())
                .guid('4554f98f-7cc5-0135-0000-00000ab61234');
        uow.commitWork();
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
    @ param  	    :  Account account, Account failAccount
    @ return   	    :  void
    @ Description 	:  Create different mock Responses which are returned based on what Account(success or fail) will be passed to getNotes method.
***/
    private static void mockAuthenticationAndRequestProviderResponse(Account account, Account failAccount) {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayAPI_GetNotes mockedRequestProvider = (PBB_SRV_GatewayAPI_GetNotes) mocks.mock(PBB_SRV_GatewayAPI_GetNotes.class);
        mocks.startStubbing();
        mocks.when(mockedRequestProvider.getNotes(account.Id, 1, 2, new List<String>{'ALL'})).thenReturn(generateResponse(1, 2, true, true));
        mocks.when(mockedRequestProvider.getNotes(failAccount.Id, 1, 2, new List<String>{'ALL'})).thenReturn(generateResponse(1, 2, true, false));
        mocks.when(mockedRequestProvider.createNote(account.Id, 'New Note Body', 'New Note Category')).thenReturn(200);
        mocks.when(mockedRequestProvider.createNote(failAccount.Id, 'New Note Body', 'New Note Category')).thenReturn(500);
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayAPI_GetNotes.IService.class, mockedRequestProvider);
    }

/***
    @ param  	    :  No params
    @ return   	    :  Id - created User's Id
    @ Description 	:  Creates test User
***/

/***
    @ param  	    :  No params
    @ return   	    :  void
    @ Description 	:  Tests if getAllCategories() method returns all values from PBB_Note_Types__c Custom Settings
***/
    @IsTest
    public static void testGetAllCustomerNotepadCategories() {
        List<PBB_Note_Types__c> allCustomerNotepadTypes = PBB_SapNotes_Controller.getAllCustomerNotepadCategories();
        System.assertEquals(3, allCustomerNotepadTypes.size());
    }

/***
    @ param  	    :  No params
    @ return   	    :  void
    @ Description 	:  Tests if getNotes(accountId, index, offset, categories) method returns proper Response, when proper Account Id is passed
***/
    @IsTest
    public static void testGetNotesCallOut() {
        Account account = [SELECT Id, Name FROM Account WHERE Name='Test Account'];
        Account failAccount = [SELECT Id, Name FROM Account WHERE Name='Fail Test Account'];

        mockAuthenticationAndRequestProviderResponse(account, failAccount);
        PBB_SRV_GatewayAPI_GetNotes.Response response = new PBB_SRV_GatewayAPI_GetNotes.Response();
        System.runAs(testUser){
            response = PBB_SapNotes_Controller.getNotes(account.Id, 1, 2, new List<String>{'ALL'});
        }

        //Response assertion
        System.assertEquals(1, response.index);
        System.assertEquals(2, response.offset);
        System.assertEquals(true, response.remainingPage);
        System.assertEquals(2, response.notes.size());

        //Note 1 content assertion
        System.assertEquals(testNoteCreationDateTime, response.notes[0].noteDatedOn);
        System.assertEquals(testUser.Name, response.notes[0].noteCreatedBy);
        System.assertEquals('Note Text 1', response.notes[0].noteDetails);
        System.assertEquals('CREDIT CHECK', response.notes[0].type);

        //Note 2 content assertion
        System.assertEquals(testNoteCreationDateTime, response.notes[1].noteDatedOn);
        System.assertEquals(testUser.Name, response.notes[1].noteCreatedBy);
        System.assertEquals('Note Text 2', response.notes[1].noteDetails);
        System.assertEquals('ACCOUNT NOTE', response.notes[1].type);

    }

/***
    @ param  	    :  No params
    @ return   	    :  void
    @ Description 	:  Tests if getNotes(accountId, index, offset, categories) method returns null, when Fail Account Id is passed
***/
    @IsTest
    public static void testGetNotesCallOutReturnsNull() {
        Account account = [SELECT Id, Name FROM Account WHERE Name='Test Account'];
        Account failAccount = [SELECT Id, Name FROM Account WHERE Name='Fail Test Account'];

        mockAuthenticationAndRequestProviderResponse(account, failAccount);
        PBB_SRV_GatewayAPI_GetNotes.Response response = new PBB_SRV_GatewayAPI_GetNotes.Response();
        System.runAs(testUser){
            response = PBB_SapNotes_Controller.getNotes(failAccount.Id, 1, 2, new List<String>{'ALL'});
        }

        //Response assertion
        System.assertEquals(null, response);
    }

/***
    @ param  	    :  No params
    @ return   	    :  void
    @ Description 	:  Tests if Status Code of Response of createNote(accountId, noteBode, noteCategory) method is 200, when successful Request is sent.
***/
    @IsTest
    public static void testCreateNoteCallOutWith200StatusCode() {

        Account account = [SELECT Id, Name FROM Account WHERE Name='Test Account'];
        Account failAccount = [SELECT Id, Name FROM Account WHERE Name='Fail Test Account'];

        mockAuthenticationAndRequestProviderResponse(account, failAccount);
        Integer responseStatusCode;
        System.runAs(testUser){
            responseStatusCode = PBB_SapNotes_Controller.createNewNote(account.Id, 'New Note Body', 'New Note Category');
        }

        System.assertEquals(200, responseStatusCode);
    }

/***
    @ param  	    :  No params
    @ return   	    :  void
    @ Description 	:  Tests if Status Code of Response of createNote(accountId, noteBode, noteCategory) method is 500, when there is some Internal Server Error.
***/
    @IsTest
    public static void testCreateNoteCallOutWith500StatusCode() {

        Account account = [SELECT Id, Name FROM Account WHERE Name='Test Account'];
        Account failAccount = [SELECT Id, Name FROM Account WHERE Name='Fail Test Account'];
        Integer responseStatusCode;

        mockAuthenticationAndRequestProviderResponse(account, failAccount);
        System.runAs(testUser){
            responseStatusCode = PBB_SapNotes_Controller.createNewNote(failAccount.Id, 'New Note Body', 'New Note Category');
        }

        System.assertEquals(500, responseStatusCode);
    }
}