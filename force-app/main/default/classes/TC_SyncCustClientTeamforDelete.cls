/****************************************************************
@ Author                    : Anurag Jain
@ Created Date              : 10/12/2011
@description               : Test Class for SyncCustClientTeamforDelete batch class

@ Last Modified By          : Nikhita Reddy 
@ Last Modified Date        : 28/01/2013
@ Last Modified Reason      : Added test data and best practices and increased coverage. 
                              Moved API version from 20 to 27.
                              
@ Last Modified By          : Nitish Kumar 
@ Last Modified Date        : August, 2013
@ Last Modified Reason      : Improved Code Coverage 
                                       Updated the API Version to 28

@ Last Modified By  :   Petr Svestka
@ Last Modified On  :   29th June 2016
@ Last Modified Reason  : US-1415, unscheduling jobs already executed
*******************************************************************/

@istest (SeeAllData = False)

public class TC_SyncCustClientTeamforDelete{
    
    @IsTest
    static void testSyncCustClientTeamforDelete(){

        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getEnvironmentVariable(),
            TEST_DataFactory.getCcSettings(),
            TEST_DataFactory.getUserProfileIds()
        });

        User admUser = (User) new BLD_USER().useSysAdmin().getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())){
             insert admUser;
        }
        
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_Account accBld = new BLD_Account(uow)
            .addClientTeam(
                new BLD_ClientTeam(uow)
                    .user(admUser.Id)
                    .role(DMN_ClientTeam.ROLE_ANALYST)
                    .clientAccess(DMN_ClientTeam.ACCESS_EDIT)
            );

        uow.commitWork();

        System.RunAs(admUser){
        Test.startTest();
       
        SyncCustClientTeamforDelete b = new SyncCustClientTeamforDelete();
        b.query='Select Id from Account where id = \''+accBld.getRecordId()+'\' limit 10';

        for (CronTrigger ct: [SELECT id FROM CronTrigger WHERE nextFireTime = null]) {
            System.abortJob(ct.id);
        }
            try {
             String sch = '0 0 23 * * ?';
             system.schedule('Test Batch Class2', sch, b);
            }
            Catch(Exception ex){
                System.assert(false, ex.getMessage());
            }
        Test.stopTest();
        }
    }
}