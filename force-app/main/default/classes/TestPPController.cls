/*******************************************************************************************
@description Test class for ProductPotentialController
@ Last Modified By  :   Manoj Gupta       
@ Last Modified On  :   Dec 2015
@ Last Modified Reason  : EN:0838 - Replacing Corporate Banking references to Client Coverage

@ Last Modified By  :   Petr Svestka
@ Last Modified On  :   Jan, 2016
@ Last Modified Reason  : EN-927 - Customizations so that it can be reused for CommB

@ Last Modified By      :   Jana Cechova
@ Last Modified On      :   Dec, 2016
@ Last Modified Reason  :   US-1643/ US-1729: Duplicate Contact Rules 
*******************************************************************************************/
@IsTest
public class TestPPController{

    public static List < Account > olstTestAccount;
    public static List < Contact > olstContact;
    public static List<Key_Client_Contact__c> kccList;

    static void createTestData(){

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_Account accBld = new BLD_Account(uow);

        BLD_Contact conBld = new BLD_Contact(uow).useClientContact()
            .account(accBld)
            .addTeamMember(
                new BLD_ContactTeamMember(uow)
            );

        BLD_KeyClientContact kccBld = new BLD_KeyClientContact(uow)
            .client(accBld)
            .contact(conBld);

        uow.commitWork();

         Client_Plan__c cp = new Client_Plan__c();
         cp.Client_Name__c = accBld.getRecordId();
         insert cp;

        olstTestAccount = new List<Account> {(Account) accBld.getRecord()};
        olstContact = new List<Contact> {(Contact) conBld.getRecord()};
        kccList = new List<Key_Client_Contact__c> {(Key_Client_Contact__c) kccBld.getRecord()};

    }
      
    @IsTest
    static void testPPClass(){
        createTestData();
        Test.startTest();
        try {
            PageReference pageRef = Page.ClientPlan;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', olstTestAccount[0].Id);
            ProductPotentialController con = new ProductPotentialController();
            con.clientHolder = 'Corporate and Investment Banking';
            con.SaveRecord();
            con.EditPotential();
            con.CancelPop();
            con.getPP_RecordsGM();
            con.getPP_RecordsTPS();
            con.getPP_RecordsIB();
            con.getPP_RecordsBB();
            con.getPP_RecordsRE();
            con.getPP_RecordsW();
            con.getOptions();
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void testPPClass1(){
        createTestData();
        Test.startTest();
        try {
            PageReference pageRef = Page.ClientPlan;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('id', olstTestAccount[0].Id);
            ClientContactController con1 = new ClientContactController();
            ApexPages.StandardController stdcontroller = new ApexPages.StandardController(olstTestAccount[0]);
            ClientContactController cc = new ClientContactController(stdcontroller);
            ClientContactController.Wrapper w = new ClientContactController.Wrapper(olstContact[0]);
            w.ischeck = true;
            w.con = olstContact[0];
            ClientContactController.DeleteWrapper dw = new ClientContactController.DeleteWrapper(kccList[0]);
            dw.ischeck = true;
            dw.kcc= kccList[0];
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void shouldAssignVariablesForExtensionController() {
        Account acc = (Account) new BLD_Account()
            .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_BUSINESS)
            .commitWork().getRecord();

        PageReference pageRef = Page.ClientPlanPDF;
        pageRef.getParameters().put('id', acc.Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
        ProductPotentialController ctrl = new ProductPotentialController(new ApexPages.StandardController(new BLD_Account().getRecord()));
        Test.stopTest();

        System.assertEquals(acc.Id, ctrl.clientid);
        System.assertEquals(acc.Primary_Relationship_Holder__c, ctrl.clientHolder);
        System.assertEquals(false, ctrl.showwindow);
    }

    @IsTest
    static void shouldCreateMapProdPotentialForCommBPrh() {
        Account acc = (Account) new BLD_Account()
            .primaryRelationshipHolder(DMN_Account.PRIMARY_REL_HOLDER_COMMB)
            .commitWork().getRecord();

        PageReference pageRef = Page.ClientPlanPDF;
        pageRef.getParameters().put('id', acc.Id);
        Test.setCurrentPage(pageRef);

        Test.startTest();
        ProductPotentialController ctrl = new ProductPotentialController(new ApexPages.StandardController(new BLD_Account().getRecord()));
        Test.stopTest();

        System.assertNotEquals(null, ctrl.map_ProdPotential.get('Payments'));
        System.assertEquals(null, ctrl.map_ProdPotential.get('Global Markets'));
    }

}