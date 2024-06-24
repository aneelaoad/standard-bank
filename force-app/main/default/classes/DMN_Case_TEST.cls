/**
 * Test class for DMN_Case class
 *
 * @author      Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date        March 2020
 */
@IsTest
private class DMN_Case_TEST {
        
    private static final String TEST_USER_NAME     = 'caseTest@ccc.com';
    private static User usrOwner;
    private static String ServiceTier = 'Standard';
    private static String USER_TEAM = 'CIBSA-Transactional Products and Services-International Trade Services-Cross Border CoE';
    
       private static final String ADMIN_USERNAME = 'DMN_ClientDataChangeTestAdmin@test.com';
    private static final String CDC_CURRENT_CC_USERNAME = 'DMN_ClientDataChangeTestCurrentCC@test.com';
    private static final String CDC_NEW_CC_USERNAME = 'DMN_ClientDataChangeTestNewCC@test.com';
    private static final String CDC_TM1_USERNAME = 'DMN_ClientDataChangeTestMember1@test.com';
    private static final String CDC_TM2_USERNAME = 'DMN_ClientDataChangeTestMember2@test.com';
    private static final String ACC_1_NAME = 'Test Account 1 DMN_ClientDataChange';
    private static final String ACC_2_NAME = 'Test Account 2 DMN_ClientDataChange';

    private static Account firstTestAccount;
    private static Account secondTestAccount;
    private static User currentCC;
    private static User newCC;
    private static User firstClientTeamMember;
    private static User secondClientTeamMember;
    
      private static void getData(){
        for (Account acc : [SELECT Name FROM Account WHERE Name IN :new Set<String>{ACC_1_NAME, ACC_2_NAME}]) {
            if (acc.Name == ACC_1_NAME) {
                firstTestAccount = acc;
            }
            else if (acc.Name == ACC_2_NAME) {
                secondTestAccount = acc;
            }
        }

        for (User usr : [SELECT Username, Division, IsActive FROM User WHERE Username IN :new Set<String>
                                        {CDC_CURRENT_CC_USERNAME, CDC_NEW_CC_USERNAME, CDC_TM1_USERNAME, CDC_TM2_USERNAME}]) {
            if (usr.Username == CDC_CURRENT_CC_USERNAME) {
                currentCC = usr;
            }
            else if (usr.Username == CDC_NEW_CC_USERNAME) {
                newCC = usr;
            }
            else if (usr.Username == CDC_TM1_USERNAME) {
                firstClientTeamMember = usr;
            }
            else if (usr.Username == CDC_TM2_USERNAME) {
                secondClientTeamMember = usr;
            }
        }


    }
    
        @testSetup
    static void prepareData() {

        TEST_DataFactory.generateConfiguration();
        
        User sysAdmin;
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        System.runAs(new User(Id = UserInfo.getUserId())){

            usrOwner = (User)new BLD_USER(uow).userName(TEST_USER_NAME+'1').useClientServiceUser().syncContact().getRecord();
            uow.commitWork();
        }
        Test.startTest();
        Test.stopTest(); 
        
        
        System.runAs(new User(Id = UserInfo.getUserId())){
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            sysAdmin = (User)new BLD_USER(uow)
                    .userName(ADMIN_USERNAME)
                    .useSysAdmin()
                    .syncContact()
                    .getRecord();
            currentCC = (User)new BLD_USER(uow)
                    .userName(CDC_CURRENT_CC_USERNAME)
                    .useCib()
                    .division('Global Markets')
                    .syncContact()
                    .getRecord();
            newCC = (User)new BLD_USER(uow)
                    .userName(CDC_NEW_CC_USERNAME)
                    .useCib()
                    .division('Global Markets')
                    .syncContact()
                    .getRecord();
            firstClientTeamMember = (User)new BLD_USER(uow)
                    .userName(CDC_TM1_USERNAME)
                    .useCib()
                    .division('Global Markets')
                    .syncContact()
                    .getRecord();
            secondClientTeamMember = (User)new BLD_USER(uow)
                    .userName(CDC_TM2_USERNAME)
                    .useCib()
                    .division('Global Markets')
                    .syncContact()
                    .getRecord();

            uow.commitWork();
        }


        System.runAs(sysAdmin){
            firstTestAccount = (Account)new BLD_Account(uow)
                    .name(ACC_1_NAME)
                    .addClientTeam(new BLD_ClientTeam(uow)
                            .coordinator(false)
                            .role(DMN_ClientTeam.ROLE_GM_EXECUTION_MANAGER)
                            .user(currentCC.Id)
                    )
                    .addClientTeam(new BLD_ClientTeam(uow)
                            .coordinator(true)
                            .role(DMN_ClientTeam.ROLE_ANALYST)
                            .user(secondClientTeamMember.Id)
                    )
                    .addClientTeam(new BLD_ClientTeam(uow)
                            .coordinator(false)
                            .role(DMN_ClientTeam.ROLE_GM_CHAMPION)
                            .user(newCC.Id)
                    )
                    .addClientTeam(new BLD_ClientTeam(uow)
                            .coordinator(false)
                            .role(DMN_ClientTeam.ROLE_TPS_CHAMPION)
                            .user(firstClientTeamMember.Id)
                    )
                    .addClientDataChange(new BLD_ClientDataChange(uow)
                            .name('TestCdc')
                            .currentClientCoordinator(currentCC.Id)
                            .currentClientCoordinatorRole(DMN_ClientTeam.ROLE_EXEC_SPONSOR)
                            .currentClientCoordinatorNewRole(DMN_ClientTeam.ROLE_MANAGER_CLIENT_COVERAGE)
                            .newClientCoordinator(newCC.Id)
                            .newClientCoordinatorRole(DMN_ClientTeam.ROLE_TPS_CHAMPION)
                    )
                    .getRecord();

            secondTestAccount = (Account)new BLD_Account(uow)
                    .name(ACC_2_NAME)
                    .getRecord();

            uow.commitWork();
        }
        
         system.runAs(usrOwner){
            
          BLD_ServiceType serviceType = new BLD_ServiceType(uow).setRequiredFields()
                                        .cibServiceTier(ServiceTier)
                                        .useTeam(USER_TEAM);
          uow.commitwork();  
          BLD_Case parentCaseRec = new BLD_Case(uow).useCrossBorder()
                .serviceType(serviceType)
                .cibServiceTier(ServiceTier)
                .close();
            uow.commitwork(); 
          BLD_Case childCaseRec = new BLD_Case(uow).useRtHandOff() 
                .serviceType(serviceType)
                .cibServiceTier(ServiceTier)
                .parent(parentCaseRec);
            uow.commitwork(); 
        }
    }


    

    @IsTest
    static void shouldAssignDefaultEntitlement() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SRV_Entitlement entServiceMock = (SRV_Entitlement) mocks.mock(SRV_Entitlement.class);

        Entitlement defaultEntRec = new Entitlement(
            Id = fflib_IDGenerator.generate(Entitlement.SObjectType)
        );

        mocks.startStubbing();
        mocks.when(entServiceMock.getDefaultEntitlement()).thenReturn(defaultEntRec);
        mocks.stopStubbing();

        ORG_Application.service.setMock(SRV_Entitlement.IService.class, entServiceMock);

        Case caseRec = (Case) new BLD_Case().useCrossBorder().getRecord();

        Test.startTest();
        DMN_Case.assignEntitlements(new List<Case> {caseRec}, null);
        Test.stopTest();

        System.assertEquals(defaultEntRec.Id, caseRec.EntitlementId);
    }
    
    @IsTest
    static void autoCloseChildCases() {
        List<CASE> parentCaseRec = [SELECT id,Status,recordTypeId,parentId FROM CASE WHERE parentId=null];
        List<CASE> parentCaseRec2 =  [SELECT id,Status, parentId FROM CASE];
        Case oldCase = parentCaseRec[0].clone(true);
        oldCase.Status = DMN_Case.STATUS_NEW;
        
        TEST.startTest(); 
        DMN_Case.autoCloseChildCases(new List<Case> {parentCaseRec[0]},new Map<Id, Case> {oldCase.Id => oldCase});
        DMN_Case.createCaseWithUserContactId(parentCaseRec2[0]);
        TEST.stopTest();
        List<CASE> childCaseRec = [SELECT id,Status FROM CASE WHERE parentId=:parentCaseRec[0].id];
        System.assertEquals(parentCaseRec[0].Status, childCaseRec[0].Status);

    }
    
    @IsTest
    static void testCreateCloseCaseComments() {
        List<CASE> caseUpdatedList = new list<case>();
        for(Case c:[SELECT id,Status, parentId FROM CASE]){
            c.Resolution_Comment__c='test';
            caseUpdatedList.add(c);
        }
        update caseUpdatedList;
        
        TEST.startTest(); 
        DMN_Case.createCloseCaseComments(caseUpdatedList);
        TEST.stopTest();
        assert.areEqual(String.isEmpty(caseUpdatedList[0].Resolution_Comment__c), false);

    }
    
     @IsTest
    static void getClosedCaseStatus(){
        TEST.startTest(); 
         DMN_Case.getCloseStatus();
        TEST.stopTest();
    }
    
    @IsTest
    static void CreateCifReject(){
          User testUser = TEST_DataFactory.sysAdmin;
        test.startTest();
        try {
            System.runAs(TestUser) {
                new BLD_Contact().useBankContact()
                        .accountId(TEST_DataFactory.stdBankEmpAcc.Id)
                        .commitWork();
            }
            test.stopTest();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }
    
    @IsTest
    static void CreateCasesForFailedData(){
           getData();
        Client_Data_Change__c oldCdc = [
                SELECT Client_Name__c, Name,
                        Current_Client_Coordinator__c,
                        Current_Client_Coordinator_Role__c,
                        Current_Client_Coordinator_New_Role__c,
                        New_Client_Coordinator__c,
                        New_Client_Coordinator_Role__c,
                        Keep_Current_CC__c,
                        Status__c
                FROM Client_Data_Change__c
                WHERE Client_Name__c = :firstTestAccount.Id
        ];

        Client_Data_Change__c afterUpdateCdc = oldCdc.clone(true, true);
        afterUpdateCdc.Status__c = DMN_ClientDataChange.APPROVED;
        afterUpdateCdc.Keep_Current_CC__c = true;
        afterUpdateCdc.Current_Client_Coordinator_New_Role__c = null;

        Test.startTest();
        DMN_ClientDataChange.ccChangeApprove(new List<Client_Data_Change__c>{afterUpdateCdc},
                new Map<Id, Client_Data_Change__c>{oldCdc.Id => oldCdc});
        Test.stopTest();

        Client_Data_Change__c newDataUpdateCdc = [
                SELECT Id, Status__c
                FROM Client_Data_Change__c
                WHERE Id = :oldCdc.Id
        ];
        System.assertEquals(DMN_ClientDataChange.PROPAGATION_FAILED, newDataUpdateCdc.Status__c);
    }
    
    
    
}