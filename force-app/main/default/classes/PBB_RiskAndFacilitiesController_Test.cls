/**
 * Test class for PBB_RiskAndFacilitiesController
 * US-1008
 *
 * @author Mikołaj Rzepiński (mrzepinski@deloittece.com)
 * @date September 2020
 */
@isTest
private class PBB_RiskAndFacilitiesController_Test {
    static final String USER_EMAIL_FOR_TEST = '123@sb.co.za';
    @TestSetup
    private static void setup() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_USER user = new BLD_USER(uow)
        .usePbb()
        .email(USER_EMAIL_FOR_TEST)
        .aeNumber('TST123A');
        uow.commitWork();
        Id userId = [SELECT Id FROM User WHERE Email = :USER_EMAIL_FOR_TEST][0].Id;

        BLD_Account acc = new BLD_Account(uow)
                .name('test')
                .owner(userId)
                .guid('4554f98f7cc50135000000000ab6f52b');
        acc.addAccountInformation(
                new BLD_AccountInformation(uow)
                        .currentBalance(10)
                        .name('testInfo')
                        .accountName('test')
        )
        .addClientTeam(new BLD_ClientTeam(uow).user(userId).role(DMN_ClientTeam.ROLE_BUSINESS_DEV_MANAGER));
        uow.commitWork();
    }
 
    @IsTest
    private static void fetchRiskAndFacilities() {
        Account account = [SELECT Id, GUID__c FROM Account][0];
        User ownerUser = [SELECT Id FROM User WHERE Email = :USER_EMAIL_FOR_TEST][0];
        PBB_SRV_GatewayAPI_RiskAndFacilities.RiskAndFacilities risk = new PBB_SRV_GatewayAPI_RiskAndFacilities.RiskAndFacilities();
        risk.CURRENT_LIMIT = 800;
        risk.DAYS_DISHONOURS_L6M = 0;
        risk.DAYS_IN_EXCESS_L6M = 0;
        risk.DIRECTOR_JUDGEMENT_FLAG = false;
        risk.ERI1=14;
        risk.ERL1=0;
        risk.EXP_MONTHLY_CR_TURN='0';
        risk.HEADROOM='0';
        risk.JUDGEMENT_FLAG=false;
        risk.RISK_MONITORING_TYPE=null;

        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayAPI_RiskAndFacilities mockedRequestProvider = (PBB_SRV_GatewayAPI_RiskAndFacilities) mocks.mock(PBB_SRV_GatewayAPI_RiskAndFacilities.class);
        PBB_SRV_GatewayApi_AccountInformation mockedRequestProvider2 = (PBB_SRV_GatewayApi_AccountInformation) mocks.mock(PBB_SRV_GatewayApi_AccountInformation.class);
        mocks.startStubbing();
        mocks.when(mockedRequestProvider.getData(account.GUID__c)).thenReturn(new List<PBB_SRV_GatewayAPI_RiskAndFacilities.RiskAndFacilities>{risk});
        mocks.when(mockedRequestProvider2.getAccountsBalances(account.GUID__c)).thenReturn(new List<PBB_SRV_GatewayApi_AccountInformation.AccountBalances>());
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayAPI_RiskAndFacilities.IService.class, mockedRequestProvider);
        ORG_Application.service.setMock(PBB_SRV_GatewayApi_AccountInformation.IService.class, mockedRequestProvider2);
        System.runAs(ownerUser){
        PBB_RiskAndFacilitiesController.DataWrapper wrapper = (PBB_RiskAndFacilitiesController.DataWrapper) PBB_RiskAndFacilitiesController.fetchData(account.Id);
        
        System.assertEquals(false, wrapper.riskAndFacilitiesAPIReturnedError);
        System.assertEquals(false, wrapper.balanceAPIReturnedError);
        }
    }

    @IsTest
    private static void fetchRiskAndFacilitiesNoData() {
        Account account = [SELECT Id, GUID__c FROM Account][0];
        User ownerUser = [SELECT Id FROM User WHERE Email = :USER_EMAIL_FOR_TEST][0];
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        PBB_SRV_GatewayAPI_RiskAndFacilities mockedRequestProvider = (PBB_SRV_GatewayAPI_RiskAndFacilities) mocks.mock(PBB_SRV_GatewayAPI_RiskAndFacilities.class);
        PBB_SRV_GatewayApi_AccountInformation mockedRequestProvider2 = (PBB_SRV_GatewayApi_AccountInformation) mocks.mock(PBB_SRV_GatewayApi_AccountInformation.class);
        mocks.startStubbing();
        mocks.when(mockedRequestProvider.getData(account.GUID__c)).thenReturn(new List<PBB_SRV_GatewayAPI_RiskAndFacilities.RiskAndFacilities>());
        mocks.when(mockedRequestProvider2.getAccountsBalances(account.GUID__c)).thenReturn(new List<PBB_SRV_GatewayApi_AccountInformation.AccountBalances>());
        mocks.stopStubbing();
        ORG_Application.service.setMock(PBB_SRV_GatewayAPI_RiskAndFacilities.IService.class, mockedRequestProvider);
        ORG_Application.service.setMock(PBB_SRV_GatewayApi_AccountInformation.IService.class, mockedRequestProvider2);
        System.runAs(ownerUser){
        PBB_RiskAndFacilitiesController.DataWrapper wrapper = (PBB_RiskAndFacilitiesController.DataWrapper) PBB_RiskAndFacilitiesController.fetchData(account.Id);
        
        System.assertEquals(false, wrapper.riskAndFacilitiesAPIReturnedError);
        System.assertEquals(false, wrapper.balanceAPIReturnedError);
        }
    }

    @IsTest
    private static void fetchRiskAndFacilitiesError() {
        Account account = [SELECT Id, GUID__c FROM Account][0];
        User ownerUser = [SELECT Id FROM User WHERE Email = :USER_EMAIL_FOR_TEST][0];
        Test.startTest();
        System.runAs(ownerUser){
        PBB_RiskAndFacilitiesController.DataWrapper wrapper = (PBB_RiskAndFacilitiesController.DataWrapper) PBB_RiskAndFacilitiesController.fetchData(account.Id);

        System.assertEquals(true, wrapper.riskAndFacilitiesAPIReturnedError);
        System.assertEquals(true, wrapper.balanceAPIReturnedError);
        }
        Test.stopTest();
    }
    @IsTest
    private static void fetchBalanceDataWrapper() {
        Account account = [SELECT Id, GUID__c FROM Account][0];
        User ownerUser = [SELECT Id FROM User WHERE Email = :USER_EMAIL_FOR_TEST][0];
        List<PBB_SRV_GatewayApi_AccountInformation.AccountBalances> accbalList = new  List<PBB_SRV_GatewayApi_AccountInformation.AccountBalances>();
        PBB_SRV_GatewayApi_AccountInformation.AccountBalances accbal = new PBB_SRV_GatewayApi_AccountInformation.AccountBalances();
        accbal.balances = new list<PBB_SRV_GatewayApi_AccountInformation.accountBalance>();
        PBB_SRV_GatewayApi_AccountInformation.accountBalance ab = new PBB_SRV_GatewayApi_AccountInformation.accountBalance();
        ab.balance = '-1';
        ab.balanceType = 'Actual';
        ab.balanceDate = '2020-05-24';
        ab.accountCurrency = 'ZAR';
        accbal.balances.add(ab);
        accbalList.add(accbal);
 
        Test.startTest();
        System.runAs(ownerUser){

            PBB_RiskAndFacilitiesController.BalanceDataWrapper bd = new PBB_RiskAndFacilitiesController.BalanceDataWrapper(accbalList);
            
            System.assertNotEquals(0, bd.totalExposure);
        }
        Test.stopTest();
    }

}