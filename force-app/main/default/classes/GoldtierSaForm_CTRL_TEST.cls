/**
 * Test class for GoldtierSaForm_CTRL
 *
 * @author Bartosz Sliwinski (bsliwinski@deloittece.com)
 * @date December 2020
 */
@IsTest (IsParallel = true)
public with sharing class GoldtierSaForm_CTRL_TEST {

    private static final String TEST_CIF = 'cifTest';

    private static Account accRec {
        get {
            if (accRec == null) {
                accRec = [SELECT Name FROM Account WHERE Name = :BLD_Account.DEF_NAME];
            }
            return accRec;
        }
        set;
    }
    private static Contact conRec {
        get {
            if (conRec == null) {
                conRec = [SELECT Name FROM Contact WHERE Name = 'first last'];
            }
            return conRec;
        }
        set;
    }

    @TestSetup
    static void setupData() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getSbParameters()
        });
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        new BLD_Account(uow)
            .addContact(
                new BLD_Contact(uow)
                    .name('first', 'last')
            );
        uow.commitWork();
    }

    @IsTest
    static void shouldInitializeVariablesFromPageParameters() {
        setCurrentPage();

        Test.startTest();
        GoldtierSaForm_CTRL ctrl = new GoldtierSaForm_CTRL();
        Test.stopTest();

        System.assertEquals(accRec.Id, ctrl.getAccount().Id);
        System.assertEquals(conRec.Id, ctrl.kycId);
        System.assertEquals(conRec.Name, ctrl.kycName);
        System.assertEquals(TEST_CIF, ctrl.cif);
        System.assertEquals(false, ctrl.toSend);
    }

    @IsTest
    static void shouldSetToSendParamToTrueFromPageParameters() {
        setCurrentPage();
        ApexPages.currentPage().getParameters().put('toSend', 'true');

        Test.startTest();
        GoldtierSaForm_CTRL ctrl = new GoldtierSaForm_CTRL();
        Test.stopTest();

        System.assertEquals(true, ctrl.toSend);
    }

    @IsTest
    static void shouldCreateAttachmentAndRedirectToAccountViewPage() {
        setCurrentPage();

        GoldtierSaForm_CTRL ctrl = new GoldtierSaForm_CTRL();

        Test.startTest();
        PageReference result = ctrl.saveAttach();
        System.assertEquals(0, Limits.getEmailInvocations());
        Test.stopTest();

        Attachment attRec = [SELECT ParentId FROM Attachment WHERE Name = :('Goldtier SBSA Origination For_' + accRec.Name + '.pdf')];

        System.assertEquals(accRec.Id, attRec.ParentId);
        System.assertEquals('/' + accRec.Id, result.getUrl());
    }

    @IsTest
    static void shouldSendEmailMessagesAfterSavingAttachment() {
        setCurrentPage();
        ApexPages.currentPage().getParameters().put('toSend', 'true');

        GoldtierSaForm_CTRL ctrl = new GoldtierSaForm_CTRL();

        Test.startTest();
        System.assertEquals(0, Limits.getEmailInvocations());
        PageReference result = ctrl.saveAttach();
        System.assertEquals(1, Limits.getEmailInvocations());
        Test.stopTest();

    }

    private static void setCurrentPage() {
        PageReference pageRef = Page.GoldtierSaForm;
        Map<String, String> parameters = pageRef.getParameters();
        parameters.put('id', accRec.Id);
        parameters.put('kycId', conRec.Id);
        parameters.put('cif', TEST_CIF);
        Test.setCurrentPage(pageRef);
    }

}