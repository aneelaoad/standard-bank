/*************************************************************************\
    @ Author        :     Manu Erwin
    @ Date          :     2009/04
    @ Test File     :     This Class
    @description   :     Allows for multi cashflow entries to be tested
                          
    @ Last Modified By  : Caro Reinecke
    @ Last Modified On  : 15 August 2011
    @ Last Modified Reason  : Regression - New Role Hierarchy Implementation: Removed role "DCM User"
    
    @ Last Modified By      : Nikhita Reddy
    @ Last Modified On      : 25 Feb 2013
    @ Last Modified Reason  : Added test data from the utility class, increased coverage and added best practices.
                              Moved API version from 15 to 27. 
                              
    @ Last Modified By  :   Charles Mutsu    
    @ Last Modified On  :   05-Aug-2013
    @ Description   :       Updated API version from 27 to 28        
****************************************************************************/
@isTest(SeeAllData = false)
public class StdBank_MultiCashflowCreation_VfExt_Test {
    
    @IsTest
    public static void multiCashflowCreationVfExtest() {
        User user01 = (User) new BLD_USER().useCib().getRecord();
        system.runAs(new User(Id = UserInfo.getUserId())){
        	 insert user01;
        }
                
        PageReference returnPage;

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_Account accBld = new BLD_Account(uow).useChild();
        System.runAs(user01) {
            uow.commitWork();
        }

        BLD_Product prodBld = new BLD_Product(uow)
            .linkToOpp(
                new BLD_Opportunity(uow)
                    .ownerId(user01.Id)
                    .client(accBld)
            );

        uow.commitWork();

        List<SB_Product__c> lstProd = new List<SB_Product__c> {(SB_Product__c) prodBld.getRecord()};

        Test.setCurrentPage(Page.StdBank_MultiCashflowCreation_Vf);
        ApexPages.currentPage().getParameters().put('Id', lstProd[0].Id);

        ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(lstProd);
        StdBank_MultiCashflowCreation_Vf_Ext controller = new StdBank_MultiCashflowCreation_Vf_Ext(setCon);

        List<Cashflow__c> lstCF = new List<Cashflow__c> {
            (Cashflow__c) new BLD_Cashflow()
                .product(prodBld)
                .getRecord()
        };
        insert lstCF;
        returnPage = controller.saveAndMore();
        setCon = new ApexPages.StandardSetController(lstProd);
        controller = new StdBank_MultiCashflowCreation_Vf_Ext(setCon);
        for( Cashflow__c cashflow : lstCF){
        cashflow.Cashflow__c = 20000;
        }
        update lstCF;
        returnPage = controller.saveAll();
        setCon = new ApexPages.StandardSetController(lstProd);
        controller = new StdBank_MultiCashflowCreation_Vf_Ext(setCon);
         controller.cashflows = new List<Cashflow__c> {(Cashflow__c) new BLD_Cashflow().product(prodBld).getRecord()};
         List<Cashflow__c> listControllerCashflows = new List<Cashflow__c> {(Cashflow__c) new BLD_Cashflow().product(prodBld).getRecord()};
        for(integer i = 0; i < listControllerCashflows.size(); i++){
            for( Cashflow__c cashflow : listControllerCashflows){
                cashflow.Cashflow__c = 22222 + i;
                cashflow.Date__c = Date.today();
            }   
        }        
        
        //update listControllerCashflows;
        controller.cashflows = listControllerCashflows;
        
        for( Cashflow__c cashflow : lstCF){
        cashflow.Cashflow__c = 30000;
        cashflow.Date__c = Date.today() + 5 ;
        }
        update lstCF;
        returnPage = controller.saveAndMore();
        Boolean isExceptionThrown = false;
        try{
            for(Cashflow__c cashflow : lstCF){
            cashflow.Date__c = NULL ;
            }   
            update lstCF;
        }
        catch(Exception e){
            isExceptionThrown = true;
        }
        returnPage = controller.saveAndMore();
        System.assert(isExceptionThrown);
    }

}