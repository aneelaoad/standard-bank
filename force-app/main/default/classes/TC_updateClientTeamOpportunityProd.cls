/*****************************************************************************************************\
    @ Author        : Anurag Jain  
    @ Date          : 10/12/2010
    @description   :
    
    @ Last Modified By: Stephen Moore
    @ Last Modified Date: 26/10/2011
    @ Description:  Case#1876: Removal for the 'CRT_Region__c' but no changes where made due to the fact
                    that the reference to the account object has been commented out on line 22
    
    @ Last Modified By: Charles Mutsu
    @ Last Modified Date: 01/02/2013
    @ Description:  Implemented TestDataUtilityClass for generating Test Data
                     Changed the version from 20 to 27.                                                                      
******************************************************************************************************/
@IsTest
private class TC_updateClientTeamOpportunityProd {

    @IsTest
    static void testupdateClientTeamOpportunityProd() {

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User testUser = (User)new BLD_USER(uow).useSysAdmin().getRecord();
        User testUser5 = (User)new BLD_USER(uow).useSysAdmin().getRecord();
        uow.commitWork();

        try {
            System.runAs(testUser) {
                Test.startTest();

                TEST_DataFactory.insertSettings(new List<Object> {
                        TEST_DataFactory.getCcSettings(),
                        TEST_DataFactory.getEnvironmentVariable(),
                        TEST_DataFactory.getCstTeamRankings()
                });

                //accounts
                BLD_Account accBld1 = new BLD_Account(uow).useChild()
                        .proposedClientCoordinator(testUser5);
                BLD_Account accBld2 = new BLD_Account(uow).useChild()
                        .proposedClientCoordinator(testUser5);

                BLD_Opportunity oppBld = new BLD_Opportunity(uow)
                        .client(accBld1);
                Opportunity oppRec = (Opportunity) oppBld.getRecord();

                uow.commitWork();

                BLD_ClientTeam cctBld1 = new BLD_ClientTeam(uow)
                        .role(DMN_ClientTeam.ROLE_BUSINESS)
                        .account(accBld1)
                        .user(testUser5.Id);
                new BLD_ClientTeam(uow)
                        .role(DMN_ClientTeam.ROLE_CREDIT_RISK)
                        .account(accBld2)
                        .user(testUser5.Id);
                uow.commitWork();

                List<ClientTeamOpportunity_Products__c> olstCTOpportunityProd = new List<ClientTeamOpportunity_Products__c> {
                        new ClientTeamOpportunity_Products__c(
                                Custom_Client_Team__c = cctBld1.getRecordId(),
                                Opportunity__c = oppRec.Id
                        ),
                        new ClientTeamOpportunity_Products__c(
                                Custom_Client_Team__c = cctBld1.getRecordId(),
                                Opportunity__c = oppRec.Id
                        )
                };
                insert olstCTOpportunityProd;

                oppRec.Description = 'Test Description';
                update oppRec;
                delete oppRec;
                Test.stopTest();
            }
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }
}