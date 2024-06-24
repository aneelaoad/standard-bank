/*************************************************************************\
    @ Author        :     Manu Erwin
    @ Date          :     26 Jun 2009
    @ Test File     :     This Class
    @description   :     Allows for the distribution clients to be tested
                          
    @ Last Modified By  : Caro Reinecke
    @ Last Modified On  : 15 August 2011
    @ Last Modified Reason  : Regression - New Role Hierarchy Implementation: Removed role DCM User from the code
    
    @ Last Modified By  : Nitish Kumar
    @ Last Modified On  : March 2013
    @ Last Modified Reason : Updated to use TestDataUtilityClass
                             Updated the API Version to 27
****************************************************************************/ 
@isTest (SeeAllData = false)
public class StdBank_MultiDistClientCreationVfExtTest {

    @IsTest
    public static void testController() {
        User stdUser = (User) new BLD_USER().useCib().getRecord();

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_Account accBld = new BLD_Account(uow).useChild();
        List<Account> lstAcc = new List<Account>();
        for (Integer i = 0; i < 8; i++) {
            lstAcc.add(
                (Account) new BLD_Account(uow).useChild().getRecord()
            );
        }
        System.runAs(stdUser) {
            uow.commitWork();
        }

        BLD_Product prodBld = new BLD_Product(uow)
            .linkToOpp(
                new BLD_Opportunity(uow)
                    .client(accBld)
            );

        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow.commitWork();
        }

        List<SB_Product__c> lstProd = new List<SB_Product__c> {(SB_Product__c) prodBld.getRecord()};
        try {
            PageReference returnPage;
            Test.setCurrentPage(Page.StdBank_MultiDistClientCreation_Vf);
            ApexPages.currentPage().getParameters().put('Id', lstProd[0].Id);
            ApexPages.StandardSetController setCon = new ApexPages.StandardSetController(lstProd);
            StdBank_MultiDistClientCreation_Vf_Ext controller = new StdBank_MultiDistClientCreation_Vf_Ext(setCon);

            List<Distribution_Client__c> lstDC = new List<Distribution_Client__c>();
            for (Integer i = 0; i < 9; i++) {
                lstDC.add(
                        (Distribution_Client__c) new BLD_DistributionClient()
                                .distributionClient(accBld)
                                .product(prodBld)
                                .getRecord()
                );
            }
            system.runAs(new User(Id = UserInfo.getUserId())){
                insert lstDC;
            }
            lstDC[1].Margin_Points__c = 222222;
            lstDC[1].Amount__c = 222222;
            lstDC[1].Distribution_Client__c = lstAcc[1].Id;

            lstDC[2].Margin_Points__c = 333333;
            lstDC[2].Amount__c = 333333;
            lstDC[2].Distribution_Client__c = lstAcc[2].Id;

            controller.DistClients = lstDC;
            returnPage = controller.saveAndMore();
            setCon = new ApexPages.StandardSetController(lstProd);
            controller = new StdBank_MultiDistClientCreation_Vf_Ext(setCon);
            lstDC[3].Margin_Points__c = 777777;
            lstDC[3].Amount__c = 777777;
            lstDC[3].Distribution_Client__c = lstAcc[3].Id;

            lstDC[4].Margin_Points__c = 888888;
            lstDC[4].Amount__c = 888888;
            lstDC[4].Distribution_Client__c = lstAcc[4].Id;

            lstDC[5].Margin_Points__c = 999999;
            lstDC[5].Amount__c = 999999;
            lstDC[5].Distribution_Client__c = lstAcc[5].Id;

            controller.DistClients= lstDC ;
            returnPage = controller.saveAll();

            setCon = new ApexPages.StandardSetController(lstProd);
            controller = new StdBank_MultiDistClientCreation_Vf_Ext(setCon);

            lstDC[6].Margin_Points__c = 111111;
            lstDC[6].Amount__c = 111111;
            lstDC[6].Distribution_Client__c = lstAcc[6].Id;

            lstDC[7].Margin_Points__c = NULL;
            lstDC[7].Distribution_Client__c = lstAcc[7].Id;

            lstDC[8].Margin_Points__c = 333333;
            lstDC[8].Amount__c = 333333;
            controller.DistClients = lstDC;
            returnPage = controller.saveAndMore();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
    }
}