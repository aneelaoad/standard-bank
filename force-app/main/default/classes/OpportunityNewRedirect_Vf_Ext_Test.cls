/*************************************************************************\
    @ Author        :     Shubham Khilauria
    @ Date          :     26 May 2014
    @description   :     EN-386: Override New Opportunity button to land on Lead Opportunity Page
    
    @ Author        :     Vishnu Vundavalli 
    @ Date          :     29 April 2015
    @ Description   :     EN-713: Include new parameters in the URL for prepopulating the Primary Event Report Source
    
    @ Author        :     Abhishek V
    @ Date          :     01 Sep 2016
    @ Description   :     US-1425: Removed page reference
    
    @ Author        :     Abhishek V
    @ Date          :     08 Dec 2016
    @ Description   :     US-1558: Test campaign functionality
****************************************************************************/
@isTest(SeeAllData=false) 
private class OpportunityNewRedirect_Vf_Ext_Test{

    @IsTest
    static void testRedirect() {
        Test.startTest();
        Opportunity opp = new Opportunity();
        User testUser = (User) new BLD_USER().useCib().getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testUser;
        }
        Campaign campRec = (Campaign) new BLD_Campaign().commitWork().getRecord();
        System.runAs(testUser) {
            Test.setCurrentPage(Page.OpportunityNewRedirect_Vf);
            ApexPages.currentPage().getParameters().put('retURL', 'testURL');
            ApexPages.currentPage().getParameters().put('save_new', 'saveNewURL');
            ApexPages.currentPage().getParameters().put(label.PrimaryEventReportCustomFieldId, 'Test Event Report');
            ApexPages.currentPage().getParameters().put(label.PrimaryEventReportCustomFieldId + '_lkid', '12345678901234');
            ApexPages.currentPage().getParameters().put('accId', '12345678901234');
            ApexPages.currentPage().getParameters().put('conId', '12345678901234');
            ApexPages.currentPage().getParameters().put('campid', campRec.Id);
            ApexPages.currentPage().getParameters().put('opp4', 'Account Name');
            ApexPages.currentPage().getParameters().put(Label.Cross_Sell_Opportunity, 'Opportunity Name');
            ApexPages.currentPage().getParameters().put(Label.Cross_Sell_Opportunity+'_lkId', '12345678901234');
            ApexPages.currentPage().getParameters().put(Label.GameChangerCustomFieldId , 'Test Game Changer');
            ApexPages.currentPage().getParameters().put(Label.GameChangerCustomFieldId +'_lkId', '12345678901234');
            ApexPages.currentPage().getParameters().put('opp11', '1 - Lead');    
            ApexPages.currentPage().getParameters().put(Label.GameChangerLeadSourceId, 'Cross Sell'); 
            ApexPages.currentPage().getParameters().put('opp14', 'Desc');
            ApexPages.currentPage().getParameters().put(Label.GameChangerCommentsId, 'Comments');
            try {
                ApexPages.StandardController controller = new ApexPages.StandardController(opp);
                OpportunityNewRedirect_Vf_Ext controllerExtension = new OpportunityNewRedirect_Vf_Ext(controller);
                controllerExtension.redirect();
            }
            catch (Exception ex) {
                System.assert(false);
            }
        }
        Test.StopTest();
    }
}