/**
 * @description Test class for AddCustomClient_Controller
 *
 * @author Konrad Bruszewski
 * @date March 2022
 */
@IsTest
public with sharing class AddCustomClient_Controller_Test {

    private static SEL_CustomPermissions cpSelector = SEL_CustomPermissions.newInstance();
    private static String testUsername1 = 'test.user1@add.custom.client.com';
    private static String testUsername2 = 'test.user2@add.custom.client.com';
    private static Id defaultAccountId = fflib_IDGenerator.generate(Account.SObjectType);

    // userWithoutCustomPermission id CC
    private static List<Custom_Client_Team__c> cstMock1 {
        get{
            if(userWithoutCustomPermission == null){
                cstMock1 = new List<Custom_Client_Team__c>();
            } else {
                cstMock1 = new List<Custom_Client_Team__c>{
                        new Custom_Client_Team__c(
                                Client_Coordinator__c = true,
                                Team_Member__c = userWithoutCustomPermission.Id,
                                Account__c = defaultAccountId,
                                Client_Coordinator_BM__c = false
                        )
                };
            }
            return cstMock1;
        }
        set;
    }

    // userWithoutCustomPermission is CCBM
    private static List<Custom_Client_Team__c> cstMock2 {
        get{
            if(userWithoutCustomPermission == null){
                cstMock2 = new List<Custom_Client_Team__c>();
            } else {
                cstMock2 = new List<Custom_Client_Team__c>{
                        new Custom_Client_Team__c(
                                Client_Coordinator__c = true,
                                Team_Member__c = fflib_IDGenerator.generate(User.SObjectType),
                                Account__c = defaultAccountId,
                                Client_Coordinator_BM__c = false
                        ),
                        new Custom_Client_Team__c(
                                Client_Coordinator__c = false,
                                Team_Member__c = userWithoutCustomPermission.Id,
                                Account__c = defaultAccountId,
                                Client_Coordinator_BM__c = true
                        )
                };
            }
            return cstMock2;
        }
        set;
    }

    // userWithoutCustomPermission is neither CC nor CCBM
    private static List<Custom_Client_Team__c> cstMock3 {
        get{
            if(userWithoutCustomPermission == null){
                cstMock3 = new List<Custom_Client_Team__c>();
            } else {
                cstMock3 = new List<Custom_Client_Team__c>{
                        new Custom_Client_Team__c(
                                Client_Coordinator__c = true,
                                Team_Member__c = fflib_IDGenerator.generate(User.SObjectType),
                                Account__c = defaultAccountId,
                                Client_Coordinator_BM__c = false
                        ),
                        new Custom_Client_Team__c(
                                Client_Coordinator__c = false,
                                Team_Member__c = fflib_IDGenerator.generate(User.SObjectType),
                                Account__c = defaultAccountId,
                                Client_Coordinator_BM__c = true
                        )
                };
            }
            return cstMock3;
        }
        set;
    }
    private static User userWithCustomPermission {
        get{
            if(userWithCustomPermission == null){
                userWithCustomPermission = SEL_Users.newInstance().selectByUserName(new Set<String>{testUsername1}).get(0);
            }
            return userWithCustomPermission;
        }
        set;
    }
    private static User userWithoutCustomPermission{
        get{
            if(userWithoutCustomPermission == null){
                userWithoutCustomPermission = SEL_Users.newInstance().selectByUserName(new Set<String>{testUsername2}).get(0);
            }
            return userWithoutCustomPermission;
        }
        set;
    }

    @TestSetup
    private static void testSetup(){
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new List<Schema.SObjectType>{
                        User.SObjectType,
                        PermissionSet.SObjectType,
                        SetupEntityAccess.SObjectType,
                        PermissionSetAssignment.SObjectType
                }
        );
        BLD_USER bldUser1 = new BLD_USER(uow).userName(testUsername1).useCib();
        BLD_USER bldUser2 = new BLD_USER(uow).userName(testUsername2).useCib();

        PermissionSet ps = new PermissionSet(
                Name = 'TestPermissionSet_928764001',
                Label = 'Test Permission Set Edit CST Visible To Client'
        );
        uow.registerNew(ps);

        SetupEntityAccess sea = new SetupEntityAccess(
                SetupEntityId = cpSelector.selectByDeveloperName(SEL_CustomPermissions.CIB_EDIT_CST_VISIBLE_TO_CLIENT).Id
        );
        uow.registerNew(sea);
        uow.registerRelationship(sea, SetupEntityAccess.ParentId, ps);
        PermissionSetAssignment psa = new PermissionSetAssignment(
        );
        uow.registerNew(psa);
        uow.registerRelationship(psa, PermissionSetAssignment.AssigneeId, bldUser1.getRecord());
        uow.registerRelationship(psa, PermissionSetAssignment.PermissionSetId, ps);
        uow.commitWork();
        System.runAs(new User(Id = UserInfo.getUserId())){
            insert new SB_Parameters__c(Name='CIB_User_Global_Area', Value__c='CIBI');
        }
    }

    /**
     * When user has profile or permission set with CIB_Edit_CST_Visible_To_Client custom permission, true should be returned
     */
    @IsTest
    private static void shouldReturnTrueWhenUserHasCustomPermission(){
        String ids = cpSelector.selectByDeveloperName(SEL_CustomPermissions.CIB_EDIT_CST_VISIBLE_TO_CLIENT).Id;
        System.runAs(userWithCustomPermission) {
            Test.startTest();
            Boolean result = AddCustomClient_Controller.showVisibleToClient(fflib_IDGenerator.generate(Account.SObjectType));
            Test.stopTest();
            System.assertEquals(true, result, 'Field should be shown for user wit custom permission');
        }
    }

    @IsTest
    private static void shouldReturnFalseWhenClientIdIsNull(){
        Test.startTest();
        Boolean result = AddCustomClient_Controller.showVisibleToClient(null);
        Test.stopTest();
        System.assertEquals(false, result, 'Field should not be shown when no client Id is passed');
    }

    @IsTest
    private static void shouldReturnFalseForInvalidId(){
        Test.startTest();
        Boolean result = AddCustomClient_Controller.showVisibleToClient('notId');
        Test.stopTest();
        System.assertEquals(false, result, 'Field should not be shown when invalid Id is passed');
    }

    @IsTest
    private static void shouldReturnTrueForCc() {
        System.runAs(userWithoutCustomPermission) {
            fflib_ApexMocks mocks = new fflib_ApexMocks();
            SEL_ClientTeams selClientTeamsMock = (SEL_ClientTeams) mocks.mock(SEL_ClientTeams.class);

            mocks.startStubbing();
            mocks.when(selClientTeamsMock.sObjectType()).thenReturn(Custom_Client_Team__c.SObjectType);
            mocks.when(selClientTeamsMock.selectCcAndCcbmByClientIds(new Set<Id>{
                    defaultAccountId
            })).thenReturn(cstMock1);
            mocks.stopStubbing();

            ORG_Application.selector.setMock(selClientTeamsMock);

            Test.startTest();
            Boolean result = AddCustomClient_Controller.showVisibleToClient(defaultAccountId);
            Test.stopTest();
            System.assertEquals(true, result, 'Field should be shown for user who is CC');
        }
    }

    @IsTest
    private static void shouldReturnTrueForCcBm() {
        System.runAs(userWithoutCustomPermission) {
            fflib_ApexMocks mocks = new fflib_ApexMocks();
            SEL_ClientTeams selClientTeamsMock = (SEL_ClientTeams) mocks.mock(SEL_ClientTeams.class);

            mocks.startStubbing();
            mocks.when(selClientTeamsMock.sObjectType()).thenReturn(Custom_Client_Team__c.SObjectType);
            mocks.when(selClientTeamsMock.selectCcAndCcbmByClientIds(new Set<Id>{
                    defaultAccountId
            })).thenReturn(cstMock2);
            mocks.stopStubbing();

            ORG_Application.selector.setMock(selClientTeamsMock);


            Test.startTest();
            Boolean result = AddCustomClient_Controller.showVisibleToClient(defaultAccountId);
            Test.stopTest();
            System.assertEquals(true, result, 'Field should be shown for user who is CCBM');
        }
    }

    @IsTest
    private static void shouldReturnFalseForUserWhoIsNotCcOrCcBm(){
        System.runAs(userWithoutCustomPermission) {
            fflib_ApexMocks mocks = new fflib_ApexMocks();
            SEL_ClientTeams selClientTeamsMock = (SEL_ClientTeams) mocks.mock(SEL_ClientTeams.class);

            mocks.startStubbing();
            mocks.when(selClientTeamsMock.sObjectType()).thenReturn(Custom_Client_Team__c.SObjectType);
            mocks.when(selClientTeamsMock.selectCcAndCcbmByClientIds(new Set<Id>{
                    defaultAccountId
            })).thenReturn(cstMock3);
            mocks.stopStubbing();

            ORG_Application.selector.setMock(selClientTeamsMock);


            Test.startTest();
            Boolean result = AddCustomClient_Controller.showVisibleToClient(defaultAccountId);
            Test.stopTest();
            System.assertEquals(false, result, 'Field should not be shown for user who is not CC or CCBM');
        }
    }
}