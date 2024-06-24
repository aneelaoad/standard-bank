/*****************************************************************************************************\
    @ Author        : Rudolf Niehaus
    @ Date          : 11/2011
    @description   : Case# 1168 : Test class for CampaignMemberHostAssignerController.cls
    
    @ Last Modified By  : Wayne Gray
    @ Last Modified On  : June 2012
    @ Last Modified Reason  :  Case #6521- Change contact to use TestFatcory    
                               API Version moved from 23 to 25   
                               
    @ Last Modified By  : Nitish Kumar
    @ Last Modified On  : Feb 2013
    @ Last Modified Reason  : EN 12, 15 and 17 - Added Methods to include new methods
                              Added best practices for the test class 
                              Improved Overall Code Coverage for the CampaignHostController class
                              API Version moved from 25 to 27 
                              
    @ Last Modified By  : Nitish Kumar
    @ Last Modified On  : July 2013
    @ Last Modified Reason  : EN 217- Improved Overall Code Coverage for the CampaignHostController class
                              Updated the API Version to 28
******************************************************************************************************/

@isTest(SeeAllData =False)

public class TestCampaignMemberHostAssignerController {

        //Static data Member
        public static list < Contact > olstContact;
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

        BLD_Contact bankConBld = new BLD_Contact(uow).useBankContact().account(sbAccBld)
            .name(UserInfo.getFirstName(), UserInfo.getLastName());
        olstContact = new List<Contact> {(Contact) bankConBld.getRecord()};
        BLD_Contact clientConBld = new BLD_Contact(uow).useClientContact().account(sbAccBld);

        BLD_Campaign campBld = new BLD_Campaign(uow)
            .addMember(
                new BLD_CampaignMember(uow).contact(bankConBld)
            )
            .addMember(
                new BLD_CampaignMember(uow).contact(clientConBld)
            );
        olstCampaign = new List<Campaign> {
            (Campaign) campBld.getRecord()
        };

        BLD_CampaignMemberHost campMemHostBld = new BLD_CampaignMemberHost(uow)
            .member(clientConBld)
            .campaign(campBld)
            .addHost(
                new BLD_CampaignHost(uow).bankContact(bankConBld)
            )
            .addHost(
                new BLD_CampaignHost(uow).bankContact(bankConBld)
            )
            .addHost(
                new BLD_CampaignHost(uow).bankContact(clientConBld)
            );
        olstCampaignMemberHost = new List<Campaign_Member_Host__c> {
            (Campaign_Member_Host__c) campMemHostBld.getRecord()
        };

        uow.commitWork();

        insert TEST_DataFactory.getErrorMessages();

      }
    
    @IsTest
    static void testController(){
            
        setupTest();  
        
        Test.startTest();
        try {
            PageReference testPage = Page.CampaignMemberHostAssigner;
            testPage.getParameters().put('retURL','http://www.testme.com');
            Test.setCurrentPage(testPage);
            ApexPages.Standardsetcontroller controller = new ApexPages.Standardsetcontroller(olstContact);

            CampaignMemberHostAssignerController cont = new CampaignMemberHostAssignerController(controller);

            cont.campId = olstCampaign[0].Name;
            cont.fetchLabels();
            List<SelectOption> s = cont.getCheckBox();
            List<SelectOption> r = cont.getRadioSelect();
            cont.setRadio('nooverride');
            cont.setStatus('Sent');
            cont.setUserHost(true);


            cont.getDisableThis();
            cont.getLockThis();
            cont.getlookupCamp();
            cont.getNewMemCount();
            cont.getRadio();
            cont.getStatus();
            cont.getUpdateMemCount();
            cont.getUserHost();

            String memberIdtest = cont.memberIds(olstCampaignMemberHost);

            PageReference p1 = cont.Previous();
            p1 = cont.AddCamp();
            p1 = cont.AddCampPlusMember();

            cont.setRadio('override');
            cont.setStatus('Sent');
            cont.setUserHost(false);
            p1 = cont.AddCamp();

            p1 = cont.Previous();
            p1 = cont.Done();
            p1 = cont.Cancel();

            Pagereference testPage2 = Page.CampaignMemberAddingComplete;
            testPage2.getParameters().put('campname',olstCampaign[0].Name);
            System.Test.setCurrentPage(testPage2);

            CampaignMemberHostAssignerController cont3 = new CampaignMemberHostAssignerController(controller);

            cont3.fetchLabels();


            CampaignMemberHostAssignerController cont2 = new CampaignMemberHostAssignerController();

            cont.sendErrorMail('TEST ERROR MSG');
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
       Test.stopTest();
    }
    
    @IsTest
    static void testController2(){
        setupTest();
        Test.startTest();
        try {
            PageReference testPage = Page.CampaignMemberHostAssigner;
            testPage.getParameters().put('retURL','http://www.testme.com');
            Test.setCurrentPage(testPage);
            ApexPages.Standardsetcontroller controller = new ApexPages.Standardsetcontroller(olstContact);
            CampaignMemberHostAssignerController cont = new CampaignMemberHostAssignerController(controller);
            cont.campId = olstCampaign[0].Name;
            cont.fetchLabels();
            List<SelectOption> s = cont.getCheckBox();
            List<SelectOption> r = cont.getRadioSelect();
            cont.setRadio('override');
            cont.setStatus('Sent');
            cont.setUserHost(false);
            cont.getDisableThis();
            cont.getLockThis();
            cont.getlookupCamp();
            cont.getNewMemCount();
            cont.getRadio();
            cont.getStatus();
            cont.getUpdateMemCount();
            cont.getUserHost();

            String memberIdtest = cont.memberIds(olstCampaignMemberHost);
            PageReference p1 = cont.Previous();
            p1 = cont.AddCamp();
            p1 = cont.AddCampPlusMember();
            p1 = cont.AddCamp();
            p1 = cont.Previous();
            p1 = cont.Done();
            p1 = cont.Cancel();
            Pagereference testPage2 = Page.CampaignMemberAddingComplete;
            testPage2.getParameters().put('campname',olstCampaign[0].Name);
            Test.setCurrentPage(testPage2);
            CampaignMemberHostAssignerController cont3 = new CampaignMemberHostAssignerController(controller);
            cont3.fetchLabels();
            CampaignMemberHostAssignerController cont2 = new CampaignMemberHostAssignerController();
            cont.sendErrorMail('TEST ERROR MSG');
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
       Test.stopTest();
    }
}