/****************************************************************
@ Author                    : Anurag Jain
@ Created Date              : 10/12/2010
@ Description               : Test Class for insertCTOPfromCustClientTeamClass class

@ Last Modified By          : Nikhita Reddy 
@ Last Modified Date        : 01/03/2013
@ Last Modified Reason      : Added test data and best practices and increasd coverage. 
                              Moved API version from 20 to 27.
                              
@ Last Modified By  :   Ankit Khandelwal    
@ Last Modified On  :   14 -July-2013
@description   :      Added the isTest annotation

@ Last Modified By  :   Charles Mutsu    
@ Last Modified On  :   05-Aug-2013
@ Description   :       Updated API version from 27 to 28
*******************************************************************/

@isTest (SeeAllData = False)

public class TC_insertCTOPfromCustClientTeam {    

    @IsTest
    static void testinsertCTOPfromCustClientTeam() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        
        test.startTest();
        try {
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

            List<Custom_Client_Team__c> lstCCT = new List<Custom_Client_Team__c> {
                    (Custom_Client_Team__c) new BLD_ClientTeam(uow)
                            .account(
                                    new BLD_Account(uow).useChild()
                                            .addOpportunity(
                                            new BLD_Opportunity(uow)
                                    )
                            )
                            .user(testUser.Id)
                            .role(DMN_ClientTeam.ROLE_CREDIT_RISK)
                            .getRecord()
            };

            uow.commitWork();

            insertCTOPfromCustClientTeamClass ctop = new insertCTOPfromCustClientTeamClass();
            ctop.insertCTOP_frmCCT(lstCCT);
            ctop.deleteCTOP_frmCCT(lstCCT);
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }

        test.stopTest();
     }
}