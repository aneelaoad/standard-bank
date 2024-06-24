/**
 * @description       : 
 * @author            : Derek Hughes
 * @group             : 
 * @last modified on  : 11-07-2023
 * @last modified by  : Tukelo Moseamo
**/
@IsTest
public with sharing class BCH_AccountTeamMaintenance_Test {
    
    private final static fflib_SObjectUnitOfWork UOW = ABS_ObjectBuilderBase.getNewUnitOfWork();

    private static List<Account> accounts;
    private static User user1;
    private static User user2;
    private static User user3;
    private static User user4;
 
    @TestSetup
    static void setup() {
        
		User owner;
        User ownerManager;
		System.runAs(new User(Id = UserInfo.getUserId())) {

			ownerManager = (USER) new BLD_USER(UOW).userName('bcbsaRunAsManager@test2.com.invalid').useSysAdmin().syncContact().getRecord();
            	UOW.commitWork();
           	owner = (USER) new BLD_USER(UOW).userName('bcbsaRunAs@test2.com.invalid').managerId(ownerManager.Id).useSysAdmin().syncContact().getRecord();
			UOW.commitWork();
		}

        
        for (Integer i=1; i<=5; i++) {
            BLD_Account accountBuilder = new BLD_Account(UOW);

            accountBuilder.name('Test Account '+i)
                .useRecordType('Commercial_Banking_Africa_Regions')
                .setField(Account.Portfolio_Code__c, 'XXBB0'+i)
                .setField(Account.RelationshipMgrCode__c, 'X000000'+i)
                .setField(Account.ExternalCIFCountry__c,'GH');
        }
        for (Integer i=1; i<=5; i++) {
            BLD_Account accountBuilder = new BLD_Account(UOW);

            accountBuilder.name('BCBSA '+i)
                .useRecordType(DMN_Account.RT_PERSONAL_BUSINESS_BANKING_CLIENT)
                .setField(Account.Portfolio_Code__c, 'XXBB00'+i)
                .setField(Account.ExternalCIFCountry__c,'ZA')
            	.setField(Account.OwnerId,owner.Id);
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
            
        userBuilder = new BLD_USER('bcbsa@test2.com.invalid', UOW);
        userBuilder.setField(User.ProfileId, UTL_Profile.getProfileId('BCC Custom Std User - Mobile'))
            .setField(User.User_CIB_Global_Area__c, 'BCC')
            .setField(User.User_Division__c, 'Business Banking')
            .setField(User.AE_Number__c, 'XXBB001');

        userBuilder = new BLD_USER('test3user3@test3.com.invalid', UOW);
        userBuilder.setField(User.ProfileId, UTL_Profile.getProfileId('BCC AR Custom Std User - Mobile'))
            .setField(User.User_CIB_Global_Area__c, 'BCC')
            .setField(User.User_Division__c, 'Business Banking')
            .setField(User.AE_Number__c, 'XXBB.*');
        
        userBuilder = new BLD_USER('duplicateUser1@test1.com.invalid', UOW);
        userBuilder.setField(User.ProfileId, UTL_Profile.getProfileId('BCC AR Custom Std User - Mobile'))
            .setField(User.User_CIB_Global_Area__c, 'BCC')
            .setField(User.User_Division__c, 'Business Banking')
            .setField(User.EmployeeNumber, 'X0000010')
            .setField(User.Portfolio_Codes__c, 'XXBB03,XXBB04');
        		System.runAs(owner) {
        UOW.commitWork();
                }
        Environment_Variable__c env = TEST_DataFactory.getEnvironmentVariable();
        insert env;

    }

    private static void getTestData() {
        accounts = [SELECT Id, OwnerId, owner.ManagerId, ExternalCIFCountry__c,Name, Owner.Username, RelationshipMgrCode__c, Portfolio_Code__c, Owner_Aligned__c FROM Account];
        user1 = [SELECT Id, Username, EmployeeNumber, AE_Number__c, Portfolio_Codes__c FROM User WHERE Username = 'test1user1@test1.com.invalid'];
        user2 = [SELECT Id, Username, EmployeeNumber, AE_Number__c, Portfolio_Codes__c FROM User WHERE Username = 'test2user2@test2.com.invalid'];
        user3 = [SELECT Id, Username, EmployeeNumber, AE_Number__c, Portfolio_Codes__c FROM User WHERE Username = 'test3user3@test3.com.invalid'];
        user4 = [SELECT Id, Username, EmployeeNumber, AE_Number__c, Portfolio_Codes__c FROM User WHERE Username = 'bcbsa@test2.com.invalid'];
        

    }

    @IsTest
    static void runTest() {

        getTestData();

        BLD_Contact contactBuilder = new BLD_Contact(UOW);
        contactBuilder.name('Test', 'Contact 1')
            .useClientContact()
            .accountId(accounts[0].Id);

        Account acc = new Account();
        for (Account a : accounts){
            if (a.ExternalCIFCountry__c == 'ZA') {
                acc = a;
                break;
            }
        }

        BLD_ClientTeam teamBuilder = new BLD_ClientTeam(UOW);
        teamBuilder.role('BCC Business Center Manager')
            .account(acc.Id)
            .user(acc.owner.ManagerId);

        teamBuilder = new BLD_ClientTeam(UOW);
        teamBuilder.role('BCC Business Center Manager')
            .account(acc.Id)
            .user(acc.ownerId);
            
        UOW.commitWork();    

        Test.startTest();

            BCH_AccountTeamMaintenance.test();
            
            try {
                BCH_AccountTeamMaintenance.schedule();
            }
            catch (Exception e) {
                //this will generally fail for repeat deployments - so have to ignore exceptions.
                Assert.areNotEqual(e.getMessage(), null, 'error message is null');
            }

        Test.stopTest();

        getTestData();

        Assert.areEqual(user1.Username, accounts[0].Owner.Username, 'Incorrect owner for test account 1');
        Assert.areEqual(user2.Username, accounts[1].Owner.Username, 'Incorrect owner for test account 2');
        Assert.areEqual(user3.Username, accounts[4].Owner.Username, 'Incorrect owner for test account 5');
        Assert.areEqual(user4.Username, accounts[5].Owner.Username, 'Incorrect owner for test account 6');

    }
    
    @isTest
    static void testRun() {
        
        getTestData();

        BLD_Contact contactBuilder = new BLD_Contact(UOW);
        contactBuilder.name('Test', 'Contact 1')
            .useClientContact()
            .accountId(accounts[0].Id);

        Account acc = new Account();
        for (Account a : accounts){
            if (a.ExternalCIFCountry__c == 'ZA') {
                acc = a;
                break;
            }
        }

        BLD_ClientTeam teamBuilder = new BLD_ClientTeam(UOW);
        teamBuilder.role('BCC Business Center Manager')
            .account(acc.Id)
            .user(acc.owner.ManagerId);

        teamBuilder = new BLD_ClientTeam(UOW);
        teamBuilder.role('BCC Business Center Manager')
            .account(acc.Id)
            .user(acc.ownerId);
        
        BLD_USER userBuilder = new BLD_USER('duplicateUser2@test2.com.invalid', UOW);
        userBuilder.setField(User.ProfileId, UTL_Profile.getProfileId('BCC AR Custom Std User - Mobile'))
            .setField(User.User_CIB_Global_Area__c, 'BCC')
            .setField(User.User_Division__c, 'Business Banking')
            .setField(User.EmployeeNumber, 'X0000010')
            .setField(User.Portfolio_Codes__c, 'XXBB10,XXBB10')
            .setField(User.alias, 'Dup')
            .setField(User.CommunityNickname, 'Dup');
    
            
        UOW.commitWork();
        
        Test.startTest();
        BCH_AccountTeamMaintenance.run();
        
        Test.stopTest();
        List<Custom_Client_Team__c> clientTeam = [SELECT Id, Team_Member__c, Account__c FROM Custom_Client_Team__c];
        List<Account> clients = [SELECT Id, OwnerId, Owner.managerId FROM Account WHERE ExternalCIFCountry__c = 'ZA'];
        Assert.areEqual(clientTeam.size(), clients.size(), 'team members created are not the same number as ZA accounts created');
    }


}