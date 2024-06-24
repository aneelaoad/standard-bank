/*************************************************************************\
    @ Author        :     Vaishali Singh
    @ Date          :     19 January 2015
    @description   :     EN-0434: Opportunity Edit Action on SF1
****************************************************************************/
@isTest(SeeAllData=false) 
private class OpportunityEditRedirect_SF1_Ext_Test {

    @IsTest
    static void testConstructor() {
        try {
            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            Opportunity opportunity = (Opportunity) new BLD_Opportunity(uow).getRecord();
            uow.commitWork();
            Test.setCurrentPage(Page.EditOpportunity_SF1);
            ApexPages.currentPage().getParameters().put('Id', opportunity.Id);
            ApexPages.StandardController controller = new ApexPages.StandardController(opportunity);
            new OpportunityEditRedirect_SF1_Ext(controller);
        }
        catch(Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }
}