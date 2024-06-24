/****************************************************************
@ Author                    : Anurag Jain
@ Created Date              : 10/12/2011
@description               : Test Class for SyncCustClientTeam  controller class

@ Last Modified By          : Nikhita Reddy 
@ Last Modified Date        : 28/01/2013
@ Last Modified Reason      : Added test data and best practices and increased coverage. 
                              Moved API version from 20 to 27.
                              
@ Last Modified by : Nitish Kumar
@ Last Modified on : 16/07/2013
@ Modification Description : Improved the Code coverage

@ Last Modified By  :   Charles Mutsu    
@ Last Modified On  :   05-Aug-2013
@ Description   :       Updated API version from 27 to 28

@ Last Modified By  :   Petr Svestka
@ Last Modified On  :   29th June 2016
@ Last Modified Reason  : US-1415, unscheduling jobs already executed
*******************************************************************/

@istest(SeeAllData=False) 

public class TC_SyncCustClientTeam{
    
    public static list < Account > lstAcc;

    @TestSetup
    private static void setupData() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getEnvironmentVariable(),
            TEST_DataFactory.getCstTeamRankings(),
            TEST_DataFactory.getCcSettings(),
            TEST_DataFactory.getUserProfileIds(),
            TEST_DataFactory.getCSTManyPerRegionTeamRoles()
        });
    }

    @IsTest
    static void testSyncCustClientTeam11(){

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User admUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        User testUser2 = (User) new BLD_USER(uow).useCib().getRecord();
        User testUser3 = (User) new BLD_USER(uow).useCib().getRecord();
        User testUser4 = (User) new BLD_USER(uow).useCib().getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
        }

        lstAcc = new List<Account> {
            (Account) new BLD_Account().getRecord(),
            (Account) new BLD_Account().getRecord()
        };
        insert lstAcc;
        
        
       System.RunAs(admUser){
       
       Test.startTest();
       try {
           AccountTeamMember accountTeamMember =new AccountTeamMember(AccountId=lstAcc[0].Id,UserId=admUser.Id,TeamMemberRole='TPS Champion');

           AccountTeamMember testAtm=new AccountTeamMember(AccountId=lstAcc[0].Id,UserId=testUser3.Id,TeamMemberRole='TPS Champion');

           AccountTeamMember testAtm2=new AccountTeamMember(AccountId=lstAcc[0].Id,UserId=testUser4.Id,TeamMemberRole='Trader');
           insert new AccountTeamMember[]{accountTeamMember, testAtm, testAtm2};

           AccountShare testShare1 = new AccountShare();
           testShare1.AccountAccessLevel = ClientCoordinatorSettings__c.getValues('AccountAccessLevel').AccessLevel__c;
           testShare1.OpportunityAccessLevel = ClientCoordinatorSettings__c.getValues('OpportunityAccessLevel').AccessLevel__c;
           testShare1.ContactAccessLevel = ClientCoordinatorSettings__c.getValues('ContactAccessLevel').AccessLevel__c;
           testShare1.CaseAccessLevel = ClientCoordinatorSettings__c.getValues('CaseAccessLevel').AccessLevel__c;
           testShare1.AccountId = lstAcc[1].Id ;
           testShare1.UserOrGroupId = testUser2.Id ;
           insert testShare1;

           for (CronTrigger ct: [SELECT id FROM CronTrigger WHERE nextFireTime = null]) {
               System.abortJob(ct.id);
           }

           String cronExp = '0 0 0 3 9 ? 2022';
           String jobId = System.schedule('testBasicScheduledApex',cronExp, new SyncCustClientTeam());
       }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
       
       Test.stopTest();
       }
    }

    @IsTest
    static void testSyncCustClientTeam12(){
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User admUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        User testUser1 = (User) new BLD_USER(uow).useCib().getRecord();
        User testUser2 = (User) new BLD_USER(uow).useCib().getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())){
            uow.commitWork();
        }

        lstAcc = new List<Account> {
            (Account) new BLD_Account().getRecord(),
            (Account) new BLD_Account().getRecord()
        };
        insert lstAcc;


        System.RunAs(admUser){
        Test.startTest();
        try {
            AccountTeamMember atm =new AccountTeamMember(AccountId=lstAcc[0].Id,UserId=testUser1.Id,TeamMemberRole='Trader');
            insert atm ;
            AccountShare testShare1 = new AccountShare();
            testShare1.AccountAccessLevel = ClientCoordinatorSettings__c.getValues('AccountAccessLevel').AccessLevel__c;
            testShare1.OpportunityAccessLevel = ClientCoordinatorSettings__c.getValues('OpportunityAccessLevel').AccessLevel__c;
            testShare1.ContactAccessLevel = ClientCoordinatorSettings__c.getValues('ContactAccessLevel').AccessLevel__c;
            testShare1.CaseAccessLevel = ClientCoordinatorSettings__c.getValues('CaseAccessLevel').AccessLevel__c;
            testShare1.AccountId = lstAcc[1].Id ;
            testShare1.UserOrGroupId = testUser2.Id ;
            insert testShare1;

            for (CronTrigger ct: [SELECT id FROM CronTrigger WHERE nextFireTime = null]) {
                System.abortJob(ct.id);
            }
            String cronExp  = '0 0 0 3 9 ? 2022';
            String jobId = System.schedule('testBasicScheduledApex',cronExp , new SyncCustClientTeam());
            Test.stopTest();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }

      }
    }
}