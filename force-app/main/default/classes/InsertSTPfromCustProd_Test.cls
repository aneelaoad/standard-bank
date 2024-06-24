/*************************************************************************\
                               
    @ Last Modified By  : Jorel Naidoo
    @ Last Modified On  : August 2012
    @ Modification Description : CR #7027 - Update Test Class Effected by the validation rules: 
                                 Populate_One_Total_Value & Populate_One_Current_Year_Value on SB_Product__c Object.
                                 Updated to use the TestFactoryUtils class
                                 API Version moved from 20 to 25 
    @                          
    @ Last Modified By  :   Navin Rai
    @ Last Modified On  :   14/06/2013
    @ Last Modified Reason  : EN-101.Reverted to standard OpportunityTeamMember.Hence,removed 
    @                         Custom_sales_Team functinality.
    @                         Changed the version to 28.  
    
    @ Last Modified By          : Nitish Kumar
    @ Last Modified Date        : July,2013
    @ Last Modified Reason      : Added test data and increasd coverage. 
    
    @ Last Modified By  : Abhishek V
    @ Last Modified On  : July 5, 2016
    @ Modification Description : Combined individual user insert statement to list in method testinsertSTPfromCustProd and introduced Test.startTest and stopTest to avoid SOQL 101.   
    @description  Test class for insertSTPfromCustProd
****************************************************************************/

@IsTest
private class InsertSTPfromCustProd_Test {    

    @IsTest
    static void testinsertSTPfromCustProd() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        User us = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        User admUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())) {
          uow.commitWork();
        }

        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getEnvironmentVariable(),
            TEST_DataFactory.getCcSettings(),
            TEST_DataFactory.getCstTeamRankings(),
            TEST_DataFactory.getCSTManyPerRegionTeamRoles(),
            TEST_DataFactory.getUserProfileIds()
        });

        Boolean isExceptionThrown = false;
        System.runAs(us) {

            Account acc = (Account) new BLD_Account(uow)
                .addClientTeam(
                    new BLD_ClientTeam(uow)
                        .role(DMN_ClientTeam.ROLE_CREDIT_RISK)
                        .user(admUser.Id)
                )
                .getRecord();
            uow.commitWork();

        Test.startTest();
        try {
            String gppCommodities = 'Commodities';

            BLD_Product normalProdBld = new BLD_Product(uow)
                    .useAdvisory()
                    .grandParentProduct(gppCommodities);
            new BLD_Opportunity(uow)
                    .linkAccountId(acc.Id)
                    .stage(DMN_Opportunity.ST_DEVELOP)
                    .addProduct(normalProdBld)
                    .getRecord();

            new BLD_Opportunity(uow)
                    .linkAccountId(acc.Id)
                    .stage(DMN_Opportunity.ST_DEVELOP)
                    .isPrivate(true)
                    .addProduct(
                    new BLD_Product(uow)
                            .useAdvisory()
                            .grandParentProduct(gppCommodities)
            )
                    .getRecord();
            uow.commitWork();
            delete normalProdBld.getRecord();
        }
        catch(Exception ex) {
            isExceptionThrown = true;
        }
        Test.stopTest();
        }
        System.assert(!isExceptionThrown);
    }
}