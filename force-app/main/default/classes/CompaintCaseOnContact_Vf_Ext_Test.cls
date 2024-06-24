/************************************************************************
* @author       Manoj Gupta 
* @date         Apr -2017
* @description  Test class for CompaintCaseOnContact_Vf_Ext-US-1794
 
************************************************************************/
@IsTest
private class CompaintCaseOnContact_Vf_Ext_Test{
   
    @IsTest
    static void comCaseOnContactVfExtTest() {
        User testUser = (User) new BLD_USER().useCib()
            .division(DMN_User.GM_DIVISION)
            .businessUnit(DMN_User.BU_CRM_IT)
            .cibGlobalArea(DMN_User.CIB_GA_CIBSA)
            .getRecord();
        testUser.Force_Owner_to_Add_Opportunity_Product__c = true;
        insert testUser;

        System.runAs(testUser) {
            ApexPages.currentPage().getParameters().put('retURL', 'testURL');
            ApexPages.currentPage().getParameters().put('save_new', 'saveNewURL');
            ApexPages.currentPage().getParameters().put('cas4_lkid', '12345678901234');
            ApexPages.currentPage().getParameters().put('cas3_lkid', '12345678901234');
            ApexPages.currentPage().getParameters().put('cas5', 'Complaint');
            ApexPages.currentPage().getParameters().put('cas14', 'Client Complaint');
            ApexPages.StandardController controller = new ApexPages.StandardController(new Case());
            CompaintCaseOnContact_Vf_Ext compaintCaseOnContact = new CompaintCaseOnContact_Vf_Ext(controller);
            Test.setCurrentPage(Page.CompaintCaseOnContact_Vf_Ext);
            Test.startTest();
            compaintCaseOnContact.redirect();
            Test.StopTest();
            System.assertNotEquals(null, compaintCaseOnContact.urlStrSF1);
        }
    }
}