/**
 * @description       : Test for BCH_AR_AccountMaintenance
 * @author            : Derek Hughes
 * @group             : Tests
 * @last modified on  : 18-09-2023
 * @last modified by  : Derek Hughes
**/
@IsTest
public with sharing class BCH_AR_AccountMaintenance_Test {
   
    private final static fflib_SObjectUnitOfWork UOW = ABS_ObjectBuilderBase.getNewUnitOfWork();

    private static List<Account> accounts;
 
    @TestSetup
    static void setup() {

        for (Integer i=1; i<=5; i++) {
            BLD_Account accountBuilder = new BLD_Account(UOW);

            accountBuilder.name('Test Account '+i)
                .useRecordType('Commercial_Banking_Africa_Regions')
                .setField(Account.Portfolio_Code__c, 'XXBB0'+i)
                .setField(Account.RelationshipMgrCode__c, 'X000000'+i);
        }

        BLD_USER userBuilder;

        userBuilder = new BLD_USER('test1user1@test1.com.invalid', UOW);
        userBuilder.setField(User.ProfileId, UTL_Profile.getProfileId('BCC AR Custom Std User - Mobile'))
            .setField(User.User_CIB_Global_Area__c, 'BCC')
            .setField(User.User_Division__c, 'Business Banking')
            .setField(User.EmployeeNumber, 'X0000001')
            .setField(User.Portfolio_Codes__c, 'XXBB03,XXBB04');

        userBuilder = new BLD_USER('test2user2@test2.com.invalid', UOW);
        userBuilder.setField(User.ProfileId, UTL_Profile.getProfileId('BCC AR Custom Std User - Mobile'))
            .setField(User.User_CIB_Global_Area__c, 'BCC')
            .setField(User.User_Division__c, 'Business Banking')
            .setField(User.AE_Number__c, 'XXBB02')
            .setField(User.Portfolio_Codes__c, 'XXBB04,XXBB02');

        userBuilder = new BLD_USER('test3user3@test3.com.invalid', UOW);
        userBuilder.setField(User.ProfileId, UTL_Profile.getProfileId('BCC AR Custom Std User - Mobile'))
            .setField(User.User_CIB_Global_Area__c, 'BCC')
            .setField(User.User_Division__c, 'Business Banking')
            .setField(User.AE_Number__c, 'XXBB.*');
    
        UOW.commitWork();

    }

    private static void getTestData() {
        accounts = [SELECT Id, OwnerId, Name, Owner.Username, RelationshipMgrCode__c, Portfolio_Code__c, Completeness_Score__c, Owner_Aligned__c FROM Account];

    }

    @IsTest
    static void runTest() {

        getTestData();

        Decimal score0 = accounts[0].Completeness_Score__c.setScale(2);
        Decimal score1 = accounts[1].Completeness_Score__c.setScale(2);
       
        BLD_Contact contactBuilder = new BLD_Contact(UOW);
        contactBuilder.name('Test', 'Contact 1')
            .useClientContact()
            .accountId(accounts[0].Id)
            .commitWork();

        Test.startTest();

            BCH_AR_AccountMaintenance processor = new BCH_AR_AccountMaintenance();
            BCH_AR_AccountMaintenance.test();
            BCH_AR_AccountMaintenance.run();
            BCH_AR_AccountMaintenance.schedule('Test', '0 0 05 * * ?');
            
            try {
                BCH_AR_AccountMaintenance.schedule();
            }
            catch (Exception e) {
                //this will generally fail for repeat deployments - so have to ignore exceptions.
            }

        Test.stopTest();

        getTestData();

        Assert.isTrue(accounts[0].Completeness_Score__c.setScale(2) > score0, 'Incorrect score for test account 1');
        Assert.isTrue(accounts[1].Completeness_Score__c.setScale(2) == score1, 'Incorrect score for test account 2');

    }


}