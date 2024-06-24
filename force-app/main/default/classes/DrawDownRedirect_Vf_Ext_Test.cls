@isTest
public with sharing class DrawDownRedirect_Vf_Ext_Test {
    private static final String USER_NAME = 'DrawDownRedirect_Vf_Ext_Test@example.com';
    private static User testUser {
        get {
            if (testUser == null) {
                testUser = [SELECT Id FROM User WHERE Username = :USER_NAME];
            }
            return testUser;
        }
        set;
    }

    @TestSetup
    static void setup() {

        new BLD_USER(USER_NAME).useCib().commitWork();

        System.runAs(testUser) {
            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            BLD_Product prodBld = new BLD_Product(uow)
                .linkToOpp(new BLD_Opportunity(uow));

            for (Integer i = 0; i < 5; i++) {
                new BLD_DrawDownProfile(uow).linkToProduct(prodBld);
            }
            uow.commitWork();
        }
    }

    @IsTest
    static void shouldInitializeController() {
        Draw_Down_Profile__c ddProfile = [SELECT Id, Product__c FROM Draw_Down_Profile__c LIMIT 1];
      
        Test.setCurrentPage(Page.DrawDownRedirect_Vf);        
        ApexPages.currentPage().getParameters().put('id', ddProfile.Product__c);
        DrawDownRedirect_Vf_Ext drawDownRedirect_Vf_Ext;

        Test.startTest();

        ApexPages.StandardController controller;

        System.runAs(testUser) {
        controller = new ApexPages.StandardController(ddProfile);
        drawDownRedirect_Vf_Ext = new DrawDownRedirect_Vf_Ext(controller);    
        drawDownRedirect_Vf_Ext.redirect();
        }     

        Id currentPageId = ApexPages.currentPage().getParameters().get('id');

        System.assertEquals(currentPageId, ddProfile.Product__c);

        Test.stopTest();
    }

}