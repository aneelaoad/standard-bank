/**
 * Test class for the visualforce controller class DrawDownProfileMassActions_Vf_Ext
 *
 * @author		Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date		February 2020
 */
@IsTest
private class DrawDownProfileMassActions_Vf_Ext_TEST {

    private static final String USER_NAME = 'dwadw3dwae3wwadwa@example.com';
    private static User cibUser {
        get {
            if (cibUser == null) {
                cibUser = [SELECT Id FROM User WHERE Username = :USER_NAME];
            }
            return cibUser;
        }
        set;
    }

    @TestSetup
    static void setup() {

        new BLD_USER(USER_NAME).useCib().commitWork();

        Environment_Variable__c envVariable = TEST_DataFactory.getEnvironmentVariable();
        insert envVariable;

        System.runAs(cibUser) {
            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            BLD_Product prodBld = new BLD_Product(uow)
                .linkToOpp(new BLD_Opportunity(uow));

            for (Integer i = 0; i < 5; i++) {
                new BLD_DrawDownProfile(uow)
                    .linkToProduct(prodBld)
                    .drawDate(BLD_Opportunity.DEF_CLOSED.addDays(i + 10))
                    .funding(i * 100);
            }

            uow.commitWork();
        }
    }

    @IsTest
    static void shouldInitializeControllerForSingleDdProfile() {
        List<Draw_Down_Profile__c> ddProfiles = [SELECT Id FROM Draw_Down_Profile__c LIMIT 1];
        SB_Product__c product = [SELECT Opportunity__c FROM SB_Product__c];

        PageReference pageRef = Page.DrawDownProfileMassEdit_Vf;
        pageRef.getParameters().put('id', product.Id);
        pageRef.getParameters().put('drawid', ddProfiles[0].Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
        DrawDownProfileMassActions_Vf_Ext setCtrlr;
        System.runAs(cibUser) {
            setCtrlr = new DrawDownProfileMassActions_Vf_Ext(new ApexPages.StandardSetController(ddProfiles));
        }
        Test.stopTest();

        System.assertEquals(1, setCtrlr.selectedRecords.size());
        System.assertEquals(false, setCtrlr.renderBlock);
        System.assertEquals(product.Opportunity__c, setCtrlr.relatedOpportunity[0].Id);
    }

    @IsTest
    static void shouldInitializeControllerForSelected() {
        List<Draw_Down_Profile__c> ddProfiles = [SELECT Id FROM Draw_Down_Profile__c];
        SB_Product__c product = [SELECT Opportunity__c FROM SB_Product__c];

        PageReference pageRef = Page.DrawDownProfileMassEdit_Vf;
        pageRef.getParameters().put('id', product.Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
        DrawDownProfileMassActions_Vf_Ext setCtrlr;
        System.runAs(cibUser) {
            setCtrlr = new DrawDownProfileMassActions_Vf_Ext(new ApexPages.StandardSetController(ddProfiles));
        }
        Test.stopTest();

        System.assertEquals(setCtrlr.selectedRecords.size(), setCtrlr.allRecords.size());
    }

    @IsTest
    static void shouldValidateClosedOpportunity() {
        List<Draw_Down_Profile__c> ddProfiles = [SELECT Id FROM Draw_Down_Profile__c];
        Opportunity opp = [SELECT Id FROM Opportunity];
        opp.CloseDate = System.today().addDays(-2);
        update opp;
        SB_Product__c product = [SELECT Id FROM SB_Product__c];

        PageReference pageRef = Page.DrawDownProfileMassEdit_Vf;
        pageRef.getParameters().put('id', product.Id);
        pageRef.getParameters().put('drawid', ddProfiles[0].Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
        DrawDownProfileMassActions_Vf_Ext setCtrlr;
        System.runAs(cibUser) {
            setCtrlr = new DrawDownProfileMassActions_Vf_Ext(new ApexPages.StandardSetController(ddProfiles));
        }
        Test.stopTest();

        System.assertEquals(true, setCtrlr.renderBlock);
        System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
    }

    @IsTest
    static void shouldValidateEarliestDrawDateAgainstOppCloseDate() {
        List<Draw_Down_Profile__c> ddProfiles = [SELECT Id FROM Draw_Down_Profile__c];
        SB_Product__c product = [SELECT Opportunity__r.CloseDate FROM SB_Product__c];
        ddProfiles[0].Draw_Date__c = product.Opportunity__r.CloseDate.addDays(-2);
        ddProfiles[0].Funding_Required__c = 500;
        update ddProfiles[0];

        PageReference pageRef = Page.DrawDownProfileMassEdit_Vf;
        pageRef.getParameters().put('id', product.Id);
        pageRef.getParameters().put('drawid', ddProfiles[0].Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
        DrawDownProfileMassActions_Vf_Ext setCtrlr;
        System.runAs(cibUser) {
            setCtrlr = new DrawDownProfileMassActions_Vf_Ext(new ApexPages.StandardSetController(ddProfiles));
        }
        Test.stopTest();

        System.assertEquals(true, setCtrlr.renderBlock);
        System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
    }

    @IsTest
    static void shouldSaveDdProfilesAndOpportunity() {
        List<Draw_Down_Profile__c> ddProfiles = [SELECT Id FROM Draw_Down_Profile__c];
        SB_Product__c product = [SELECT Opportunity__c FROM SB_Product__c];

        PageReference pageRef = Page.DrawDownProfileMassEdit_Vf;
        pageRef.getParameters().put('id', product.Id);
        pageRef.getParameters().put('drawid', ddProfiles[0].Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
        DrawDownProfileMassActions_Vf_Ext setCtrlr;
        PageReference savePageRef;
        Draw_Down_Profile__c testDrawDownProfile;
        Date newDrawDate;
        System.runAs(cibUser) {
            setCtrlr = new DrawDownProfileMassActions_Vf_Ext(new ApexPages.StandardSetController(ddProfiles));
            testDrawDownProfile = setCtrlr.allRecords[0];
            newDrawDate = testDrawDownProfile.Draw_Date__c.addDays(10);
            testDrawDownProfile.Draw_Date__c = newDrawDate;
            testDrawDownProfile.Funding_Required__c = 500;
            setCtrlr.relatedOpportunity[0].CloseDate = System.today().addDays(5);
            savePageRef = setCtrlr.saveAll();
        }
        Test.stopTest();

        System.assertEquals(newDrawDate, [SELECT Draw_Date__c FROM Draw_Down_Profile__c WHERE Id = :testDrawDownProfile.Id].Draw_Date__c);
        System.assertEquals(System.today().addDays(5), [SELECT CloseDate FROM Opportunity].CloseDate);
        System.assertEquals('/' + product.Opportunity__c, savePageRef.getUrl());
    }

    @IsTest
    static void shouldNotSaveAnythingBecauseCloseDateAfterDrawDate() {
        List<Draw_Down_Profile__c> ddProfiles = [SELECT Id FROM Draw_Down_Profile__c];
        SB_Product__c product = [SELECT Opportunity__c FROM SB_Product__c];

        PageReference pageRef = Page.DrawDownProfileMassEdit_Vf;
        pageRef.getParameters().put('id', product.Id);
        pageRef.getParameters().put('drawid', ddProfiles[0].Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
        DrawDownProfileMassActions_Vf_Ext setCtrlr;
        PageReference savePageRef;
        Draw_Down_Profile__c testDrawDownProfile;
        Date newDrawDate;
        System.runAs(cibUser) {
            setCtrlr = new DrawDownProfileMassActions_Vf_Ext(new ApexPages.StandardSetController(ddProfiles));
            testDrawDownProfile = setCtrlr.allRecords[0];
            newDrawDate = testDrawDownProfile.Draw_Date__c.addDays(10);
            testDrawDownProfile.Draw_Date__c = newDrawDate;
            testDrawDownProfile.Funding_Required__c = 500;
            setCtrlr.relatedOpportunity[0].CloseDate = System.today().addDays(30);
            savePageRef = setCtrlr.saveAll();
        }
        Test.stopTest();

        System.assertNotEquals(newDrawDate, [SELECT Draw_Date__c FROM Draw_Down_Profile__c WHERE Id = :testDrawDownProfile.Id].Draw_Date__c);
        System.assertEquals(BLD_Opportunity.DEF_CLOSED, [SELECT CloseDate FROM Opportunity].CloseDate);
        System.assertEquals(null, savePageRef);
    }

    @IsTest
    static void shouldNotSaveAnythingBecauseCloseDateBeforeTodayAndOppNotClosed() {
        List<Draw_Down_Profile__c> ddProfiles = [SELECT Id FROM Draw_Down_Profile__c];
        SB_Product__c product = [SELECT Opportunity__c FROM SB_Product__c];

        PageReference pageRef = Page.DrawDownProfileMassEdit_Vf;
        pageRef.getParameters().put('id', product.Id);
        pageRef.getParameters().put('drawid', ddProfiles[0].Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
        DrawDownProfileMassActions_Vf_Ext setCtrlr;
        PageReference savePageRef;
        Draw_Down_Profile__c testDrawDownProfile;
        Date newDrawDate;
        System.runAs(cibUser) {
            setCtrlr = new DrawDownProfileMassActions_Vf_Ext(new ApexPages.StandardSetController(ddProfiles));
            testDrawDownProfile = setCtrlr.allRecords[0];
            newDrawDate = testDrawDownProfile.Draw_Date__c.addDays(10);
            setCtrlr.relatedOpportunity[0].CloseDate = System.today().addDays(-10);
            savePageRef = setCtrlr.saveAll();
        }
        Test.stopTest();

        System.assertNotEquals(newDrawDate, [SELECT Draw_Date__c FROM Draw_Down_Profile__c WHERE Id = :testDrawDownProfile.Id].Draw_Date__c);
        System.assertEquals(BLD_Opportunity.DEF_CLOSED, [SELECT CloseDate FROM Opportunity].CloseDate);
        System.assertEquals(null, savePageRef);
    }

    @IsTest
    static void shouldFailOnUpdateOppCloseDateBecauseItCannotBeNull() {
        List<Draw_Down_Profile__c> ddProfiles = [SELECT Id FROM Draw_Down_Profile__c];
        SB_Product__c product = [SELECT Opportunity__c FROM SB_Product__c];

        PageReference pageRef = Page.DrawDownProfileMassEdit_Vf;
        pageRef.getParameters().put('id', product.Id);
        pageRef.getParameters().put('drawid', ddProfiles[0].Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
        DrawDownProfileMassActions_Vf_Ext setCtrlr;
        System.runAs(cibUser) {
            setCtrlr = new DrawDownProfileMassActions_Vf_Ext(new ApexPages.StandardSetController(ddProfiles));
            setCtrlr.relatedOpportunity[0].CloseDate = null;
            setCtrlr.saveAll();
        }
        Test.stopTest();

        System.assertNotEquals(null, [SELECT CloseDate FROM Opportunity].CloseDate);
    }

    @IsTest
    static void shouldDeleteAll() {
        List<Draw_Down_Profile__c> ddProfiles = [SELECT Id FROM Draw_Down_Profile__c LIMIT 1];
        SB_Product__c product = [SELECT Opportunity__c FROM SB_Product__c];

        PageReference pageRef = Page.DrawDownProfileMassEdit_Vf;
        pageRef.getParameters().put('id', product.Id);
        pageRef.getParameters().put('drawid', ddProfiles[0].Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
        DrawDownProfileMassActions_Vf_Ext setCtrlr;
        System.runAs(cibUser) {
            setCtrlr = new DrawDownProfileMassActions_Vf_Ext(new ApexPages.StandardSetController(ddProfiles));
            setCtrlr.deleteAll();
        }
        Test.stopTest();

        System.assertEquals(0, [SELECT COUNT() FROM Draw_Down_Profile__c WHERE Id IN :ddProfiles]);
    }

    @IsTest
    static void shouldAddRow() {
        List<Draw_Down_Profile__c> ddProfiles = [SELECT Id FROM Draw_Down_Profile__c LIMIT 1];
        SB_Product__c product = [SELECT Opportunity__c FROM SB_Product__c];

        PageReference pageRef = Page.DrawDownProfileMassEdit_Vf;
        pageRef.getParameters().put('id', product.Id);
        pageRef.getParameters().put('drawid', ddProfiles[0].Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
        DrawDownProfileMassActions_Vf_Ext setCtrlr;
        System.runAs(cibUser) {
            setCtrlr = new DrawDownProfileMassActions_Vf_Ext(new ApexPages.StandardSetController(ddProfiles));
            setCtrlr.addRow();
        }
        Test.stopTest();

        System.assertEquals(ddProfiles.size() + 1, setCtrlr.allRecords.size());
    }

    @IsTest
    static void shouldRemoveRow() {
        List<Draw_Down_Profile__c> ddProfiles = [SELECT Id FROM Draw_Down_Profile__c LIMIT 1];
        SB_Product__c product = [SELECT Opportunity__c FROM SB_Product__c];

        PageReference pageRef = Page.DrawDownProfileMassEdit_Vf;
        pageRef.getParameters().put('id', product.Id);
        pageRef.getParameters().put('drawid', ddProfiles[0].Id);
        pageRef.getParameters().put('rowToRemove', '0');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        DrawDownProfileMassActions_Vf_Ext setCtrlr;
        System.runAs(cibUser) {
            setCtrlr = new DrawDownProfileMassActions_Vf_Ext(new ApexPages.StandardSetController(ddProfiles));
            setCtrlr.removeRow();
        }
        Test.stopTest();

        System.assertEquals(ddProfiles.size() - 1, setCtrlr.allRecords.size());
    }

}