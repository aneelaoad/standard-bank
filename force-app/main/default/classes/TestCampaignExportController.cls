/*****************************************************************************************************\
    @ Author        : Raja Kumar
    @ Date          : 10/2023
    @description   :  Test class for CampaignExportController.cls
******************************************************************************************************/

@isTest(SeeAllData=False)
public class TestCampaignExportController {
    
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
     * @author Raja Kumar
     * @date 11/10/2023
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
            );
        olstCampaign = new List<Campaign> {
            (Campaign) campBld.getRecord()
        };
        olstCampaignMemberHost = new List<Campaign_Member_Host__c> {
            (Campaign_Member_Host__c) new BLD_CampaignMemberHost(uow)
                .member(clientConBld)
                .campaign(campBld)
                .addHost(
                    new BLD_CampaignHost(uow).bankContact(bankConBld)
                )
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
     * @author Raja Kumar
     * @date 11/10/2023
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
    static void testExportToExcel(){
        setupTest();
        Pagereference p = page.CampaignMembersToExcel;
        Test.setCurrentPage(p);
        p.getParameters().put('campId', olstCampaign[0].Id);
        p.getParameters().put('ids', olstCampaignMemberHost[0].Id);
        p.getParameters().put('fileno', '1');
        CampaignExportController cont5 = new CampaignExportController();
        cont5.memhostList  = olstCampaignMemberHost4;
        cont5.LoadExl();
        Assert.isTrue(cont5.hostColumnHeaders.contains('HOST NAME 1'),'Host Name Header column is present');
        Assert.isTrue(cont5.hostColumnHeaders.contains('HOST SURNAME 1'),'Host Surname Header column is present');
        Assert.isTrue(cont5.hostColumnHeaders.contains('HOST EMAIL 1'),'Host Email Header column is present');
        Assert.isTrue(cont5.hostColumnHeaders.contains('HOST DIVISION'),'Host Division Header column is present');
        Assert.isTrue(cont5.hostColumnHeaders.contains('BUSINESS UNIT'),'Business Unit Header column is present');
        
     }
    
}