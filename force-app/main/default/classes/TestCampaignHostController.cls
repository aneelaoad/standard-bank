/*****************************************************************************************************\
    @ Author        : Rudolf Niehaus
    @ Date          : 11/2011
    @description   : Case# 1168 : Test class for CampaignHostController.cls
   
    @ Last Modified By  : Wayne Gray
    @ Last Modified On  : June 2012
    @ Last Modified Reason  : Case #6521- Change contact to use TestFatcory    
                               API Version moved from 23 to 25  
                               
    @ Last Modified By  : Nitish Kumar
    @ Last Modified On  : Feb 2013
    @ Last Modified Reason  : EN 12, 15 and 17 - Added Methods to include new methods
                              Added best practices for the test class   
                              Improved code coverage of Class
                              API Version moved from 25 to 27                         
******************************************************************************************************/
@IsTest
public class TestCampaignHostController {
         
        //Static data Member
        public static list < Campaign > olstCampaign;
        public static list < Campaign_Member_Host__c > olstCampaignMemberHost;


    /**
     * @author Nitish Kumar
     * @date 05/02/2013
     * @description Sets up the test data
     */
    static void setupTest() {

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_Account sbAccBld = new BLD_Account(TEST_DataFactory.stdBankEmpAcc, uow);

        BLD_Contact bankConBld = new BLD_Contact(uow).useBankContact().account(sbAccBld);
        new BLD_Contact(uow).useBankContact().account(sbAccBld);
        BLD_Contact clientConBld = new BLD_Contact(uow).useClientContact().account(sbAccBld);

        BLD_Campaign campBld = new BLD_Campaign(uow)
            .addMember(
                new BLD_CampaignMember(uow)
                    .contact(clientConBld)
            );
        olstCampaign = new List<Campaign> {
            (Campaign) campBld.getRecord()
        };

        olstCampaignMemberHost = new List<Campaign_Member_Host__c> {
            (Campaign_Member_Host__c) new BLD_CampaignMemberHost(uow)
                .member(clientConBld)
                .campaign(campBld)
                .addHost(
                    new BLD_CampaignHost(uow)
                        .bankContact(bankConBld)
                )
                .getRecord(),
            (Campaign_Member_Host__c) new BLD_CampaignMemberHost(uow)
                .member(clientConBld)
                .campaign(campBld)
                .addHost(
                    new BLD_CampaignHost(uow)
                        .bankContact(bankConBld)
                )
                .getRecord()
        };

        uow.commitWork();

        insert TEST_DataFactory.getErrorMessages();

      }
    
    
        /**
         * @author Nitish Kumar
         * @date 05/02/2013
         * @description Sets up the test data
         */

        @SuppressWarnings('PMD.NcssMethodCount')
        @IsTest
        static void testController() {

          setupTest();   
        
          Test.startTest();
            try {
                PageReference testPage = Page.CampaignHostAssigner;
                testPage.getParameters().put('campid',olstCampaign[0].Id);
                testPage.getParameters().put('ids',olstCampaignMemberHost[0].Id + '-' + olstCampaignMemberHost[1].Id);

                System.Test.setCurrentPage(testPage);

                CampaignHostsController cont = new CampaignHostsController();
                cont.searchText = '';
                PageReference p1 = cont.search();
                p1 = cont.addHost();
                cont.filterText = '';
                p1 = cont.showRemovableHosts();
                List<CampaigHostsWrapper> hList = cont.removeResults;
                if(hList.size() > 0){
                    hList[0].checked = true;
                }
                p1 = cont.removeHost();
                cont.sendErrorMail('TEST ERRO MAIL');
                p1 = cont.Done();
                PageReference testPage2 = Page.CampaignHostAssigner;
                testPage2.getParameters().put('campid',olstCampaign[0].Id);
                testPage2.getParameters().put('ids','');
                Test.setCurrentPage(testPage2);
                CampaignHostsController cont2 = new CampaignHostsController();
                cont2.searchText = 't';
                PageReference p2 = cont2.search();
                List<ContactWrapper> cList = cont2.getsearchResults();
                cont2.Load();
                Boolean isFirst = cont2.isFirst;
                cont2.first();
                Boolean isNext = cont2.hasNext;
                cont2.next();
                Boolean isPrevious = cont2.hasPrevious;
                cont2.previous();
                Boolean isLast   = cont2.isLast;
                cont2.last();
                cont2.first();

                if(cList.size() > 0){
                    cList[0].checked = true;
                    cList[1].checked = true;
                }
                p2 = cont2.addHost();
                p2 = cont2.showRemovableHosts();
                List<CampaigHostsWrapper> hList2 = cont2.removeResults;
                if(hList2.size() > 0){
                    hList2[0].checked = true;
                }
                p2 = cont2.removeHost();
                PageReference testPage3 = Page.CampaignHostAssigner;
                testPage3.getParameters().put('campid',olstCampaign[0].Id);
                testPage3.getParameters().put('ids',olstCampaignMemberHost[0].Id + '-' + olstCampaignMemberHost[1].Id);
                Test.setCurrentPage(testPage3);
                CampaignHostsController cont3 = new CampaignHostsController();
                cont3.searchText = 't';
                PageReference p3 = cont3.search();
                List<ContactWrapper> cList2 = cont3.getsearchResults();

                if(cList2.size() > 0){
                    cList2[0].checked = true;
                    cList2[1].checked = true;
                }
                p3 = cont3.addHost();
                p3 = cont3.showRemovableHosts();
                List<CampaigHostsWrapper> hList3 = cont3.removeResults;
                if(hList3.size() > 0){
                    hList3[0].checked = true;
                }
                p3 = cont3.removeHost();
                String direction = cont3.getSortDirection();
                cont3.setSortDirection('ASC');
                String sortExpr  = cont3.sortExpression;
                cont3.setSortDirection('');
                String sortExpr2  = cont3.sortExpression;
                String direction2 = cont3.getSortDirection();
                cont3.searchText = 'ttttttttttttttttt';
                PageReference p4 = cont3.search();
                List<ContactWrapper> cList3 = cont3.getsearchResults();
                PageReference p5  = cont3.returnToCampaign();
                PageReference p6  = cont3.getSelectedMembers();
                cont3.filterText = 'DummyFilter';
                p4 = cont3.showRemovableHosts();
            }
            catch (Exception ex) {
                System.assert(false, ex.getMessage());
            }
        Test.stopTest();
    }
}