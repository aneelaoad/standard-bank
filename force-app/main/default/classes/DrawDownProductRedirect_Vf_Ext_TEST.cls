/**
 * Test class for DrawDownProductRedirect_Vf_Ext
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date December 2020
 */
@IsTest (IsParallel = true)
private with sharing class DrawDownProductRedirect_Vf_Ext_TEST {

    private static SB_Product__c prodRec {
        get {
            if (prodRec == null) {
                prodRec = [SELECT Id FROM SB_Product__c];
            }
            return prodRec;
        }
        set;
    }

    @TestSetup
    static void setupData() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getEnvironmentVariable()
        });

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Product(uow)
            .linkToOpp(
                new BLD_Opportunity(uow)
            )
            .addDrawDownProfile(
                new BLD_DrawDownProfile(uow)
            );
        uow.commitWork();
    }

    @IsTest
    static void shouldInitializeVariables() {
        Test.startTest();
        DrawDownProductRedirect_Vf_Ext ctrl = new DrawDownProductRedirect_Vf_Ext(new ApexPages.StandardController(prodRec));
        Test.stopTest();

        System.assertEquals(1, ctrl.lstProduct.size());
        System.assertEquals(prodRec.Id, ctrl.lstProduct[0].Id);
        System.assertEquals(1, ctrl.lstDrawDown.size());
        System.assertEquals(0, ctrl.newProduct);
    }

    @IsTest
    static void shouldRecognizeProductCreationProcess() {
        PageReference pageRef = Page.DrawDownProductRedirect_Vf;
        pageRef.getHeaders().put('Referer', Environment_Variable__c.getInstance().serverURL__c + '/a0g/e');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        DrawDownProductRedirect_Vf_Ext ctrl = new DrawDownProductRedirect_Vf_Ext(new ApexPages.StandardController(prodRec));
        Test.stopTest();

        System.assertEquals(1, ctrl.newProduct);
    }

    @IsTest
    static void shouldRedirectToProductViewBecauseDrawDownsExist() {
        PageReference pageRef = Page.DrawDownProductRedirect_Vf;
        Test.setCurrentPage(pageRef);

        DrawDownProductRedirect_Vf_Ext ctrl = new DrawDownProductRedirect_Vf_Ext(new ApexPages.StandardController(prodRec));

        Test.startTest();
        PageReference result = ctrl.redirect();
        Test.stopTest();

        System.assertEquals('/' + prodRec.Id + '?nooverride=1', result.getUrl());
    }

    @IsTest
    static void shouldRedirectToDrawDownCreationBecauseNoDrawDowns() {
        delete [SELECT Id FROM Draw_Down_Profile__c];

        PageReference pageRef = Page.DrawDownProductRedirect_Vf;
        Test.setCurrentPage(pageRef);

        DrawDownProductRedirect_Vf_Ext ctrl = new DrawDownProductRedirect_Vf_Ext(new ApexPages.StandardController(prodRec));

        Test.startTest();
        PageReference result = ctrl.redirect();
        Test.stopTest();

        System.assertEquals('/apex/DrawDownProfile_Vf?Id=' + prodRec.Id + '&recs=0', result.getUrl());
    }

    @IsTest
    static void shouldRedirectToProductViewBecauseRtNotInEnvironmentVariable() {
        prodRec.RecordTypeId = UTL_RecordType.getRecordTypeId(DMN_SB_Product.OBJ_NAME, DMN_SB_Product.RT_COMMB_LENDING);
        prodRec.Current_Year_CommB_Revenue__c = 2;
        prodRec.total_revenue_amount__c = 2;
        prodRec.Total_Fees__c = 3;
        update prodRec;
        prodRec = null;

        PageReference pageRef = Page.DrawDownProductRedirect_Vf;
        Test.setCurrentPage(pageRef);

        DrawDownProductRedirect_Vf_Ext ctrl = new DrawDownProductRedirect_Vf_Ext(new ApexPages.StandardController(prodRec));

        Test.startTest();
        PageReference result = ctrl.redirect();
        Test.stopTest();

        System.assertEquals('/' + prodRec.Id + '?nooverride=1', result.getUrl());
    }

}