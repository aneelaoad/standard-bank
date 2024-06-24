/**
 * @FuncArea PBB Lifestyle
 * @Author Zofia Walczewska
 * @Date 31.03.2020
 * @UserStory US-4728
 * @Description APEX Test class for DMN_accountInformation.
 */
@IsTest
public with sharing class DMN_AccountInformation_TEST {
    @TestSetup
    private static void setupData(){
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Account(uow)
            .name('test')
            .bpid('455456768676')
            .addAccountInformation(
                new BLD_AccountInformation(uow)
                    .name('220076138')
                    .accountName('220076138')
                );
        new BLD_Account(uow)
                .name('test2')
                .addAccountInformation(
                new BLD_AccountInformation(uow)
                        .name('2200761383452')
                        .accountName('2200761383452')
            );
        uow.commitWork();
    }
    @IsTest
    private static void shouldInsertExternalIdOnPBBAccountInfosWhenAccountInfoIsCreated(){
        Test.startTest();
        List<Account_Information__c> accountsPBB = [SELECT Id, Proact_External_Id__c FROM Account_Information__c WHERE Proact_External_Id__c != NULL ];
        System.assertEquals('220076138-455456768676', accountsPBB[0].Proact_External_Id__c);
        System.assertEquals(1, accountsPBB.size());
    }
    @IsTest
    private static void shouldNotInsertExternalIdOnNotPBBAccountInfosWhenAccountInfoIsCreated(){
        Test.startTest();
        List<Account_Information__c> accountsWithoutExternalId = [SELECT Id, Proact_External_Id__c FROM Account_Information__c WHERE Proact_External_Id__c = NULL];
        System.assertEquals(1, accountsWithoutExternalId.size());
        System.assertEquals(null, accountsWithoutExternalId[0].Proact_External_Id__c);
    }
}