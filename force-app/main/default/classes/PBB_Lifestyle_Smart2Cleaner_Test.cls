/**
 * Class created to test PBB_Lifestyle_Smart2Cleaner
 * <br/> SGPRT-3487
 *
 * @Author Mikołaj Rzepiński (mrzepinski@deloittece.com)
 * @Date October 2020
 */
@isTest
public with sharing class PBB_Lifestyle_Smart2Cleaner_Test {

    private static String UserMailTest = 'testSelConv@test.com';
    private static String aeNumber = '0530754246';
    

    @TestSetup
    private static void setupData() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_USER user = new BLD_USER(uow)
                .usePbb()
                .email(UserMailTest);
        uow.commitWork();

        Id userId = user.getRecordId();

        BLD_Account account = new BLD_Account(uow)
                .name('test')
                .guid('4554f98f7ch50135000000000ab6f434')
                .bpid(aeNumber)
                .owner(userId);
        account.addConversation(
                new BLD_Conversation(uow)
                        .externalId('4536456')
                        .externalIdLeadKey('asgdfj')
                        .isActive(true)
                        .ownerId(userId));
        account.addConversation(
                new BLD_Conversation(uow)
                        .externalId('435654')
                        .externalIdLeadKey('jdh8d')
                        .isActive(false)
                        .ownerId(userId));
        uow.commitWork();
    }

    @IsTest
    private static void testCleanByUser() {
        Id userId = [SELECT Id FROM User WHERE Email = :UserMailTest][0].Id;
        List<Conversation__c> conv = [SELECT Id FROM Conversation__c WHERE IsActive__c = TRUE];
       // System.assertEquals(1, conv.size());

        Test.startTest();
        List<Conversation__c> res = PBB_Lifestyle_Smart2Cleaner.cleanByUser(userId, new Set<Id>());
        Test.stopTest();

        //System.assertEquals(1, res.size());
    }

    @IsTest
    private static void testCleanByUserMap() {
        Id userId = [SELECT Id FROM User WHERE Email = :UserMailTest][0].Id;
        List<Conversation__c> conv = [SELECT Id FROM Conversation__c WHERE IsActive__c = TRUE];
       // System.assertEquals(1, conv.size());
        Map<Id, List<Conversation__c>> map2test = new Map<Id, List<Conversation__c>>();
        map2test.put(userId, new List<Conversation__c>());

        Test.startTest();
        List<Conversation__c> res = PBB_Lifestyle_Smart2Cleaner.cleanByUser(map2test);
        Test.stopTest();

        //System.assertEquals(1, res.size());
    }

    @IsTest
    private static void testCleanByAccount() {
        Id accountId = [SELECT Id FROM Account WHERE BPID__c =:aeNumber][0].Id;

        Test.startTest();
        List<Conversation__c> res = PBB_Lifestyle_Smart2Cleaner.cleanByClient(accountId, new Set<Id>());
        Test.stopTest();

       // System.assertEquals(1, res.size());
    }

    @IsTest
    private static void testCleanWithoutIds() {
        Id userId = [SELECT Id FROM User WHERE Email = :UserMailTest][0].Id;
        Set<Id> userIds = new Set<Id>();
        userIds.add(userId);

        Test.startTest();
        List<Conversation__c> res = PBB_Lifestyle_Smart2Cleaner.cleanByUserWithoutIds(userIds, new List<Conversation__c>());
        Test.stopTest();

        //System.assertEquals(1, res.size());
    }
    @IsTest
    private static void testCleanByAccountsAndOwners() {
        Id accOwnerId = [SELECT Id, OwnerId FROM Account WHERE BPID__c =:aeNumber][0].OwnerId;
        List<Conversation__c> conv = [SELECT Id FROM Conversation__c WHERE IsActive__c = TRUE and Client__c=:accOwnerId];
        Set<Id> convIds = new Set<Id>();
        for(Conversation__c con :conv){
            convIds.add(con.Id);
        }
        Test.startTest();
        List<Conversation__c> res = PBB_Lifestyle_Smart2Cleaner.cleanByClients(new Set<Id>{accOwnerId}, convIds);
        Test.stopTest();

        System.assertEquals(0, res.size());
    }
}