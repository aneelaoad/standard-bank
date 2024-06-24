@istest (SeeAllData = False)
/*****************************************************************************************************\
    @ Author        : Unknown
    @ Date          : 
    @description   :
    
    @ Last Modified By: Stephen Moore
    @ Last Modified Date: 26/10/2011
    @ Description:  Case#1876: Removal for the 'CRT_Region__c' field  (line 20)
        
    @ Last Modified By  : Nikhita Reddy 
    @ Last Modified On  : 01/03/2013
    @ Last Modified Reason  : Added test data and used best practices.
                  Moved the AP version to 27.

    @ Last Modified By  :   Petr Svestka
    @ Last Modified On  :   29th June 2016
    @ Last Modified Reason  : US-1415, unscheduling jobs already executed
******************************************************************************************************/

public class TC_SyncCustStdClientTeamForDeleteCCT{

    static testmethod void testSyncCustStdClientTeamForDeleteCCT(){
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        User admUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        User testUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow.commitWork();
            TEST_DataFactory.insertSettings(new List<Object> {
                TEST_DataFactory.getEnvironmentVariable(),
                TEST_DataFactory.getCcSettings(),
                TEST_DataFactory.getCstTeamRankings(),
                TEST_DataFactory.getCSTManyPerRegionTeamRoles(),
                TEST_DataFactory.getUserProfileIds()
            });
        }

        BLD_Account accBld = new BLD_Account(uow).useChild()
            .addOpportunity(
                new BLD_Opportunity(uow)
            );

        List<Custom_Client_Team__c> lstCCT = new List<Custom_Client_Team__c> {
            (Custom_Client_Team__c) new BLD_ClientTeam(uow)
                .account(accBld)
                .user(testUser.Id)
                .role(DMN_ClientTeam.ROLE_CREDIT_RISK)
                .getRecord()
        };

        uow.commitWork();

        System.RunAs(admUser){
        
            Test.startTest();
            
            for(Custom_Client_Team__c customClientTeam : lstCCT){
                customClientTeam.Client_Role__c= 'Transactor' ;
                customClientTeam.Team_Member__c= admUser.Id;
             }
            
            update lstCCT;
       
         SyncCustStdClientTeamForDeleteCCT b = new SyncCustStdClientTeamForDeleteCCT(); 
         b.query='Select Id from Account where id = \''+accBld.getRecordId()+'\' limit 1';

        for (CronTrigger ct: [SELECT id FROM CronTrigger WHERE nextFireTime = null]) {
            System.abortJob(ct.id);
        }

        try {
            String cronStr = '0 0 0 3 9 ? 2022';
            system.schedule('Test Batch Class2', cronStr, b);
        }
        catch(Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
        }
        
    }

}