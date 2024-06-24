/*****************************************************************************************************\
    @ Func Area     : Ecosystem
    @ Author        : Marko Dvečko
    @ Date          : 15/04/2017
    @ Test File     : 
    @ Specification : Unit tests for SRV_Ecosystem.cls
******************************************************************************************************/

@isTest
private class SRV_Ecosystem_Test {
    @isTest static void testEcosystemSharing() {

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User testUser = (User) new BLD_USER(uow).useCommB().cibGlobalArea(DMN_User.CIB_GA_CIBI).getRecord();
        User accOwnerUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow.commitWork();
        }

        Account acc = (Account) new BLD_Account()
            .proposedClientCoordinator(accOwnerUser)
            .commitWork()
            .getRecord();

        Ecosystem__c eco = new Ecosystem__c(Relationship_Group_Number__c = '1000');
        insert eco;

        Ecosystem_Entity__c ecoEntity = new Ecosystem_Entity__c(Entity__c = acc.Id, Ecosystem__c = eco.Id);
        insert ecoEntity;

        Ecosystem__Share[] ecoShares = [SELECT Id, UserOrGroup.Name, AccessLevel FROM Ecosystem__Share WHERE RowCause = 'Manual'];
       // System.assertEquals(1, ecoShares.size());

        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getCcSettings(),
            TEST_DataFactory.getUserProfileIds()
        });

        Custom_Client_Team__c clientTeam = new Custom_Client_Team__c(
            Team_Member__c = testUser.Id,
            Account__c = acc.Id,
            Client_Role__c = DMN_ClientTeam.ROLE_ANALYST);
        insert clientTeam;

        ecoShares = [SELECT Id FROM Ecosystem__Share WHERE RowCause = 'Manual'];
       // System.assertEquals(1, ecoShares.size());

        delete clientTeam;
        ecoShares = [SELECT Id FROM Ecosystem__Share WHERE RowCause = 'Manual'];
        //System.assertEquals(1, ecoShares.size());

        delete acc;
        ecoShares = [SELECT Id FROM Ecosystem__Share WHERE RowCause = 'Manual'];
    }
}