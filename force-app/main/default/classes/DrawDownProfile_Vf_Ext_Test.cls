/**
 * Test class for visualforce controller class DrawDownProfile_Vf_Ext
 *
 * @author  Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date    February 2020
 */
@IsTest
private class DrawDownProfile_Vf_Ext_Test {

    private static final String USER_NAME = '3iu432890ujiojsdur89043u@example.com';
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
                new BLD_DrawDownProfile(uow).linkToProduct(prodBld);
            }

            uow.commitWork();
        }
    }

    @IsTest
    static void shouldInitializeController() {
        List<Draw_Down_Profile__c> ddProfiles = [SELECT Id FROM Draw_Down_Profile__c];
        SB_Product__c product = [SELECT Opportunity__c FROM SB_Product__c];

        PageReference pageRef = Page.DrawDownProfile_Vf;
        pageRef.getParameters().put('id', product.Id);
        pageRef.getParameters().put('recs', '-1');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        DrawDownProfile_Vf_Ext setCtrlr;
        System.runAs(cibUser) {
            setCtrlr = new DrawDownProfile_Vf_Ext(new ApexPages.StandardSetController(ddProfiles));
        }
        Test.stopTest();

        System.assertEquals(ddProfiles.size(), setCtrlr.drawDowns.size());
        System.assertEquals(false, setCtrlr.renderBlock);
        System.assertEquals(product.Opportunity__c, setCtrlr.relatedOpportunity[0].Id);
    }

    @IsTest
    static void shouldCreateNewDrawDownProfiles() {
        delete [SELECT Id FROM Draw_Down_Profile__c];
        SB_Product__c product = [SELECT Id FROM SB_Product__c];

        PageReference pageRef = Page.DrawDownProfile_Vf;
        pageRef.getParameters().put('id', product.Id);
        pageRef.getParameters().put('recs', '-1');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        DrawDownProfile_Vf_Ext setCtrlr;
        System.runAs(cibUser) {
            setCtrlr = new DrawDownProfile_Vf_Ext(new ApexPages.StandardSetController(new List<Draw_Down_Profile__c>()));
        }
        Test.stopTest();

        System.assertEquals(DrawDownProfile_Vf_Ext.intNUMBER_OF_ROWS, setCtrlr.drawDowns.size());
        System.assertEquals(null, setCtrlr.drawDowns[0].Id);
    }

    @IsTest
    static void shouldValidateClosedOpportunity() {
        List<Draw_Down_Profile__c> ddProfiles = [SELECT Id FROM Draw_Down_Profile__c];
        Opportunity opp = [SELECT Id FROM Opportunity];
        opp.CloseDate = System.today().addDays(-2);
        update opp;
        SB_Product__c product = [SELECT Id FROM SB_Product__c];

        PageReference pageRef = Page.DrawDownProfile_Vf;
        pageRef.getParameters().put('id', product.Id);
        pageRef.getParameters().put('recs', '-1');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        DrawDownProfile_Vf_Ext setCtrlr;
        System.runAs(cibUser) {
            setCtrlr = new DrawDownProfile_Vf_Ext(new ApexPages.StandardSetController(ddProfiles));
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

        PageReference pageRef = Page.DrawDownProfile_Vf;
        pageRef.getParameters().put('id', product.Id);
        pageRef.getParameters().put('recs', '-1');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        DrawDownProfile_Vf_Ext setCtrlr;
        System.runAs(cibUser) {
            setCtrlr = new DrawDownProfile_Vf_Ext(new ApexPages.StandardSetController(ddProfiles));
        }
        Test.stopTest();

        System.assertEquals(true, setCtrlr.renderBlock);
        System.assert(ApexPages.hasMessages(ApexPages.Severity.ERROR));
    }

    @IsTest
    static void shouldSaveDdProfiles() {
        List<Draw_Down_Profile__c> ddProfiles = [SELECT Id FROM Draw_Down_Profile__c];
        SB_Product__c product = [SELECT Opportunity__c FROM SB_Product__c];

        PageReference pageRef = Page.DrawDownProfile_Vf;
        pageRef.getParameters().put('id', product.Id);
        pageRef.getParameters().put('recs', '-1');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        DrawDownProfile_Vf_Ext setCtrlr;
        PageReference savePageRef;
        Draw_Down_Profile__c testDrawDownProfile;
        Date newDrawDate = System.today().addDays(10);
        System.runAs(cibUser) {
            setCtrlr = new DrawDownProfile_Vf_Ext(new ApexPages.StandardSetController(ddProfiles));
            testDrawDownProfile = setCtrlr.drawDowns[0];
            testDrawDownProfile.Draw_Date__c = newDrawDate;
            testDrawDownProfile.Funding_Required__c = 500;
            savePageRef = setCtrlr.saveAll();
        }
        Test.stopTest();

        System.assertEquals(newDrawDate, [SELECT Draw_Date__c FROM Draw_Down_Profile__c WHERE Id = :testDrawDownProfile.Id].Draw_Date__c);
        System.assertEquals('/' + product.Opportunity__c, savePageRef.getUrl());
    }

    @IsTest
    static void shouldNotSaveDdProfilesBecauseDrawDateEarlierThanOppCloseDate() {
        List<Draw_Down_Profile__c> ddProfiles = [SELECT Id FROM Draw_Down_Profile__c];
        SB_Product__c product = [SELECT Id FROM SB_Product__c];

        PageReference pageRef = Page.DrawDownProfile_Vf;
        pageRef.getParameters().put('id', product.Id);
        pageRef.getParameters().put('recs', '-1');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        DrawDownProfile_Vf_Ext setCtrlr;
        Draw_Down_Profile__c testDrawDownProfile;
        System.runAs(cibUser) {
            setCtrlr = new DrawDownProfile_Vf_Ext(new ApexPages.StandardSetController(ddProfiles));
            testDrawDownProfile = setCtrlr.drawDowns[0];
            testDrawDownProfile.Draw_Date__c = BLD_Opportunity.DEF_CLOSED.addDays(-2);
            testDrawDownProfile.Funding_Required__c = 500;
            setCtrlr.saveAll();
        }
        Test.stopTest();

        System.assertEquals(true, setCtrlr.renderBlock);
        System.assertEquals(null, [SELECT Draw_Date__c FROM Draw_Down_Profile__c WHERE Id = :testDrawDownProfile.Id].Draw_Date__c);
    }

    @IsTest
    static void shouldUpdateOppCloseDate() {
        List<Draw_Down_Profile__c> ddProfiles = [SELECT Id FROM Draw_Down_Profile__c];
        SB_Product__c product = [SELECT Opportunity__c FROM SB_Product__c];

        PageReference pageRef = Page.DrawDownProfile_Vf;
        pageRef.getParameters().put('id', product.Id);
        pageRef.getParameters().put('recs', '-1');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        DrawDownProfile_Vf_Ext setCtrlr;
        PageReference savePageRef;
        System.runAs(cibUser) {
            setCtrlr = new DrawDownProfile_Vf_Ext(new ApexPages.StandardSetController(ddProfiles));
            setCtrlr.relatedOpportunity[0].CloseDate = System.today().addDays(5);
            savePageRef = setCtrlr.saveAll();
        }
        Test.stopTest();

        System.assertEquals(System.today().addDays(5), [SELECT CloseDate FROM Opportunity].CloseDate);
        System.assertEquals('/' + product.Opportunity__c, savePageRef.getUrl());
    }

    @IsTest
    static void shouldFailOnUpdateOppCloseDateBecauseItCannotBeNull() {
        List<Draw_Down_Profile__c> ddProfiles = [SELECT Id FROM Draw_Down_Profile__c];
        SB_Product__c product = [SELECT Opportunity__c FROM SB_Product__c];

        PageReference pageRef = Page.DrawDownProfile_Vf;
        pageRef.getParameters().put('id', product.Id);
        pageRef.getParameters().put('recs', '-1');
        Test.setCurrentPage(pageRef);

        Test.startTest();
        DrawDownProfile_Vf_Ext setCtrlr;
        System.runAs(cibUser) {
            setCtrlr = new DrawDownProfile_Vf_Ext(new ApexPages.StandardSetController(ddProfiles));
            setCtrlr.relatedOpportunity[0].CloseDate = null;
            setCtrlr.saveAll();
        }
        Test.stopTest();

        System.assertEquals(true, setCtrlr.renderBlock);
        System.assertNotEquals(null, [SELECT CloseDate FROM Opportunity].CloseDate);
    }

    @IsTest
    static void shouldParseDrawDownsWithoutChanges() {
        List<Draw_Down_Profile__c> ddProfiles = [SELECT Id FROM Draw_Down_Profile__c];
        SB_Product__c product = [SELECT Opportunity__c FROM SB_Product__c];

        PageReference pageRef = Page.DrawDownProfile_Vf;
        pageRef.getParameters().put('id', product.Id);
        pageRef.getParameters().put('recs', '-1');
        System.Test.setCurrentPage(pageRef);

        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeStringField('sObjectType', 'Draw_Down_Profile__c');
        gen.writeStringField('Draw_Date__c', '2018/12/31');
        gen.writeStringField('Funding_Required__c', '5226004.51');
        gen.writeEndObject();
        gen.writeEndArray();
        String jsonPastedDrawdowns = gen.getAsString();

        Test.startTest();
        DrawDownProfile_Vf_Ext setCtrlr;
        System.runAs(cibUser) {
            setCtrlr = new DrawDownProfile_Vf_Ext(new ApexPages.StandardSetController(ddProfiles));
            setCtrlr.jsonPastedDrawdowns = jsonPastedDrawdowns;
            setCtrlr.parsePastedDrawdowns();
        }
        Test.stopTest();

        System.assertEquals('[{"sObjectType":"Draw_Down_Profile__c","Draw_Date__c":"2018/12/31","Funding_Required__c":"5226004.51"}]', setCtrlr.jsonPastedDrawdowns);

    }
}