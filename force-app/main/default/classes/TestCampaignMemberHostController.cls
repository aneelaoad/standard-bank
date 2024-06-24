/*****************************************************************************************************\
    @ Author        : Rudolf Niehaus
    @ Date          : 11/2011
    @description   : Case# 1168 : Test class for CampaignMemberHostController.cls
   
    @ Last Modified By  : Wayne Gray
    @ Last Modified On  : June 2012
    @ Last Modified Reason  : Case #6521- Change contact to use TestFatcory    
                               API Version moved from 24 to 25 
                               
    @ Last Modified By  : Nitish Kumar
    @ Last Modified On  : Feb 2013
    @ Last Modified Reason  : EN 15 - Adding best practices to the test class
                               Calling the data from TestDataUtilityClass    
                               API Version moved from 25 to 27 
                               
    @ Last Modified By  : Nikhita Reddy
    @ Last Modified On  : 13 March 2013
    @ Last Modified Reason  : Covered CampaignExporterController class and CampaignExportDownloader class   
    
    @ Last Modified By  :   Charles Mutsu    
    @ Last Modified On  :   05-Aug-2013
    @ Description   :       Updated API version from 27 to 28                       
******************************************************************************************************/

@isTest(SeeAllData=False)
public class TestCampaignMemberHostController {
    
        //Static data Member
        public static list < Campaign > olstCampaign;
        public static list < Campaign_Member_Host__c > olstCampaignMemberHost;
        public static list < Campaign_Member_Host__c > olstCampaignMemberHost4;

    @TestSetup
    private static void setupData() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getErrorMessages(),
            TEST_DataFactory.getEnvironmentVariable()
        });
    }

     /**
     * @author Nitish Kumar
     * @date 05/02/2013
     * @description Sets up the test data
     */
    static void setupTest() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_Account sbAccBld = new BLD_Account(TEST_DataFactory.stdBankEmpAcc, uow);

        BLD_Contact bankConBld = new BLD_Contact(uow).useBankContact().account(sbAccBld);
        BLD_Contact clientConBld = new BLD_Contact(uow).useClientContact().account(sbAccBld);

        BLD_Campaign campBld = new BLD_Campaign(uow)
            .addMember(
                new BLD_CampaignMember(uow)
                    .contact(clientConBld)
            )
            .addMemberHost(
                new BLD_CampaignMemberHost(uow).member(clientConBld)
                    .addHost(
                        new BLD_CampaignHost(uow).bankContact(clientConBld)
                    )
            );/*
            .addMemberHost(
                new BLD_CampaignMemberHost(uow).member(clientConBld)
                    .addHost(
                        new BLD_CampaignHost(uow).bankContact(clientConBld)
                    )
            )
            .addMemberHost(
                new BLD_CampaignMemberHost(uow).member(clientConBld)
                    .addHost(
                        new BLD_CampaignHost(uow).bankContact(clientConBld)
                    )
            )
            .addMemberHost(
                new BLD_CampaignMemberHost(uow).member(clientConBld)
                    .addHost(
                        new BLD_CampaignHost(uow).bankContact(clientConBld)
                    )
            );*/
        olstCampaign = new List<Campaign> {
            (Campaign) campBld.getRecord()
        };
        olstCampaignMemberHost = new List<Campaign_Member_Host__c> {
            (Campaign_Member_Host__c) new BLD_CampaignMemberHost(uow)
                .member(clientConBld)
                .campaign(campBld)
                .addHost(
                    new BLD_CampaignHost(uow).bankContact(bankConBld)
                )/*
                .addHost(
                    new BLD_CampaignHost(uow).bankContact(bankConBld)
                )*/
                .getRecord()
        };
        olstCampaignMemberHost4 = new List<Campaign_Member_Host__c> {
            (Campaign_Member_Host__c) new BLD_CampaignMemberHost(uow)
                .member(clientConBld)
                .campaign(campBld)
                .addHost(
                    new BLD_CampaignHost(uow).bankContact(clientConBld)
                )
                .getRecord()
        };

        uow.commitWork();

      }
      
      
      /**
     * @author Nitish Kumar
     * @date 05/02/2013
     * @description Sets up the test data
     */
    static void setupTest2() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_Account sbAccBld = new BLD_Account(TEST_DataFactory.stdBankEmpAcc, uow);

        BLD_Contact bankConBld = new BLD_Contact(uow).useBankContact().account(sbAccBld);
        BLD_Contact clientConBld = new BLD_Contact(uow).useClientContact().account(sbAccBld);

        olstCampaign = new List<Campaign> {
            (Campaign) new BLD_Campaign(uow)
                .addMember(
                    new BLD_CampaignMember(uow)
                        .contact(clientConBld)
                )
                .addMemberHost(
                    new BLD_CampaignMemberHost(uow)
                        .member(clientConBld)
                        .addHost(
                        new BLD_CampaignHost(uow)
                            .bankContact(bankConBld)
                        )
                        .addHost(
                        new BLD_CampaignHost(uow)
                            .bankContact(bankConBld)
                        )
                )
                .getRecord()
        };

        uow.commitWork();

      }
    
    @IsTest
    static void testClass(){
        setupTest2();
        ApexPages.StandardController controller = new ApexPages.StandardController(olstCampaign[0]);
        CampaignMemberHostController cont = new CampaignMemberHostController(controller);
        
        Test.startTest();
        try {
            cont.setWave('1');
            cont.filterWave();
            cont.setWave('2');
            cont.updateWave();
            cont.setWave('None');
            cont.filterWave();
            cont.setWave('All');
            cont.updateWave();
            List<SelectOption> so = cont.getInviteWave();
            String ids = cont.memberIds();
            PageReference p1 = cont.ManageHosts();
            p1 = cont.Load();
            p1 = cont.RemoveHosts();
            p1 = cont.ExportMembers(ids);
            cont.searchText = '';
            p1 = cont.Load();
            cont.searchText = 'Member/Client Name';
            p1 = cont.Load();
            Integer x = cont.getIteration();
            Set<Id> pids = cont.PageBlockIds();
            cont.RemoveMembers();
            cont.getSortDirection();
            cont.setSortDirection('ASC');
            String se = cont.sortExpression;
            cont.sortExpression = 'ASC';
            String testStr = cont.getWave();
            p1 = cont.Done();
            cont.sendErrorMail('TEST ERROR MAIL');
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testClass2(){
        setupTest2();

        ApexPages.StandardController controller1 = new ApexPages.StandardController(olstCampaign[0]);
        CampaignMemberHostController cont1 = new CampaignMemberHostController(controller1);
        Test.startTest();
        try {
            cont1.setWave('1');
            cont1.filterWave();
            cont1.setWave('2');
            cont1.updateWave();

            List<CampaigHostsWrapper > hList = cont1.memberResults ;

            if(hList.size() > 0){
                hList[0].checked = true;
            }

            String testStr2 = cont1.memberIds();

            List<SelectOption> so1 = cont1.getInviteWave();
            String ids1 = cont1.memberIds();

            PageReference testPage2 = Page.CampaignMemberHostManager;

            testPage2.getParameters().put('button','back');

            System.Test.setCurrentPage(testPage2);

            testPage2  =  cont1.Load();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
    }
         
    @IsTest
    static void testClass3(){
        setupTest();
        ApexPages.StandardController controller2 = new ApexPages.StandardController(olstCampaign[0]);
        CampaignMemberHostController cont2 = new CampaignMemberHostController(controller2);
            
        Test.startTest();
        try {
            cont2.setWave('1');
            cont2.filterWave();
            List<SelectOption> so2 = cont2.getInviteWave();
            String ids2 = cont2.memberIds();
            PageReference testPage3 = Page.CampaignMemberHostManager;
            testPage3.getParameters().put('button','next');
            Test.setCurrentPage(testPage3);
            testPage3  =  cont2.Load();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testClass4(){
        setupTest();
        ApexPages.StandardController controller3 = new ApexPages.StandardController(olstCampaign[0]);
        CampaignMemberHostController cont3 = new CampaignMemberHostController(controller3);
        
        Test.startTest();
        try {
            cont3.setWave('1');
            cont3.filterWave();
            List<CampaigHostsWrapper > hList = cont3.memberResults ;
            if(hList.size() > 0){
                hList[0].checked = true;
            }
            cont3.updateWave();
            List<SelectOption> so3 = cont3.getInviteWave();
            String ids3 = cont3.memberIds();
            PageReference testPage4 = Page.CampaignMemberHostManager;
            testPage4.getParameters().put('button','last');
            System.Test.setCurrentPage(testPage4);
            testPage4  =  cont3.Load();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testClass5(){
        setupTest();
        ApexPages.StandardController controller4 = new ApexPages.StandardController(olstCampaign[0]);
        CampaignMemberHostController cont4 = new CampaignMemberHostController(controller4);

        Test.startTest();
        try {

            cont4.setWave('1');
            cont4.filterWave();
            List<SelectOption> so4 = cont4.getInviteWave();
            String ids4 = cont4.memberIds();
            PageReference testPage5 = Page.CampaignMemberHostManager;
            testPage5.getParameters().put('button','first');
            System.Test.setCurrentPage(testPage5);
            testPage5  =  cont4.Load();
            List<CampaigHostsWrapper > hList = cont4.memberResults ;
            if(hList.size() > 0){
                hList[0].checked = true;
            }
            cont4.RemoveMembers();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testExportToExcel(){
        setupTest();
        Test.startTest();
        try {
            Pagereference p = page.CampaignMembersToExcel;
            Test.setCurrentPage(p);
            p.getParameters().put('campId', olstCampaign[0].Id);
            p.getParameters().put('ids', olstCampaignMemberHost[0].Id);
            p.getParameters().put('fileno', '1');
            CampaignExportController cont5 = new CampaignExportController();
            cont5.memhostList  = olstCampaignMemberHost4;
            cont5.LoadExl();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
     }

    @IsTest
    static void testExportDownload(){
            setupTest();
            Test.startTest();
            try {
                Pagereference p = page.CampaignMembersToExcel;
                System.Test.setCurrentPage(p);
                p.getParameters().put('datablock', '1');
                p.getParameters().put('campId', olstCampaign[0].Id);

                p.getParameters().put('ids', olstCampaignMemberHost[0].Id);
                p.getParameters().put('fileno', '1');
                CampaignExportDownloader cont6 = new CampaignExportDownloader();
                cont6.DownloadData();

                p.getParameters().put('datablock', '2');
                p.getParameters().put('campId', olstCampaign[0].Id);
                p.getParameters().put('ids', olstCampaignMemberHost[0].Id);
                p.getParameters().put('fileno', '2');
                cont6.DownloadData();

                p.getParameters().put('datablock', '3');
                p.getParameters().put('campId', olstCampaign[0].Id);
                p.getParameters().put('ids', olstCampaignMemberHost[0].Id);
                p.getParameters().put('fileno', '3');
                cont6.DownloadData();

                p.getParameters().put('datablock', '4');
                p.getParameters().put('campId', olstCampaign[0].Id);
                p.getParameters().put('ids', olstCampaignMemberHost[0].Id);
                p.getParameters().put('fileno', '4');
                cont6.DownloadData();
            }
            catch (Exception ex) {
                System.assert(false, ex.getMessage());
            }
            Test.stopTest();
     }
    
}