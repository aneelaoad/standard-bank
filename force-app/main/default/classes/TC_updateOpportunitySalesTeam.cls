/***************************************************************************
    @author       Amjad Khan
    @date         05/11/2011
    @description  test class for updateOpportunitySalesTeam

    @ Audit Trial   : Repeating block for each change to the code
    -----------------------------------------------------------------------------
    @ Last Modified By  :  Caro Reinecke  
    @ Last Modified On  :   28/05/2012
    @ Last Modified Reason  : 
    
    -----------------------------------------------------------------------------
    @ Last Modified By  :  Krishna Bhagavan  
    @ Last Modified On  :   28/01/2013
    @ Last Modified Reason  : Refactor & standardize the code
                              Changed the version from 20 to 27
    ------------------------------------------------------------------------------
    @                          
    @ Last Modified By  :   Navin Rai
    @ Last Modified On  :   14/06/2013
    @ Last Modified Reason  : EN-101.Reverted to standard OpportunityTeamMember.Hence,removed 
    @                         Custom_sales_Team functinality.
    @                         Changed the version to 28. 
    
    @ Last Modified By  :   Nitish Kumar    
    @ Last Modified On  :   August,2013
    @ Description         :  Added Custom Setting Data                         
****************************************************************************/
@isTest(SeeAllData = False)

private class TC_updateOpportunitySalesTeam {

    static testMethod void testupdateOpportunitySalesTeam() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getUserProfileIds(),
            TEST_DataFactory.getCcSettings()
        });

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        for (Integer i = 0; i < 20; i++) {
            new BLD_Account(uow)
                .addOpportunity(new BLD_Opportunity(uow));
        }
        try {
            uow.commitWork();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }
}