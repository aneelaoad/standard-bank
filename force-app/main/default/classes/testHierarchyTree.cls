/*****************************************************************************************************\
    @ Author        : Caro Reinecke
    @ Date          : 23/11/2012 
    @ Test File     : 
    @ Description   :Test Ownership update of imported Client Value Records
        
    @ Last Modified By  : Charles Mutsu
    @ Last Modified On  : 28/02/2013  
    @ Last Modified Reason  : Implemented TestDataUtilityClass for generating Test Data
                  Changed the version from 20 to 27.

    @ Last Modified By    :   Petr Svestka
   @ Last Modified On    :   September 7, 2015
  @ Last Modified Reason  :   fixed account hierarchy to pass VR

******************************************************************************************************/
@isTest(SeeAllData = false)

private class testHierarchyTree {

    // Get Account Record type Map
    public static Map < String, Schema.RecordTypeInfo > mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    // Get the record type id of from the Map based on the Name
    public static Id prospectRecTypeId = mapAccountRecordTypes.get('Child').getRecordTypeId();
    public static Id immParentRecTypeId = mapAccountRecordTypes.get('Immediate Parent').getRecordTypeId();

    public static List < Account > olstTestAccount;

    static testMethod void testHierarchyTree() {

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        Account ultParent = (Account) new BLD_Account(uow).useGroupParent().getRecord();
        Account immParent = (Account) new BLD_Account(uow).getRecord();
        Account prospect = (Account) new BLD_Account(uow).getRecord();
        uow.commitWork();

        olstTestAccount = new List<Account> {
            ultParent,
            immParent,
            prospect
        };

        olstTestAccount[1].RecordTypeId = immParentRecTypeId;
     //   olstTestAccount[1].Name = 'Middle Account';
        olstTestAccount[1].ParentId = olstTestAccount[0].Id;
        olstTestAccount[1].Client_Relationship_Hierarchy__c = 'Child';

      //  olstTestAccount[2].Name = 'Bottom Account';
        olstTestAccount[2].ParentId = olstTestAccount[1].Id;
        olstTestAccount[2].Client_Relationship_Hierarchy__c = 'Child';
        update olstTestAccount;

        test.startTest();

        PageReference SharedCalPag = Page.SharedCalendar;
        Test.setCurrentPage(SharedCalPag);
        ApexPages.currentPage().getParameters().put('recordId', (String) olstTestAccount[0].get('id'));
        ApexPages.currentPage().getParameters().put('calType', 'Client');

        // Instanciate Controller
        HierarchyStructure_page controller = new HierarchyStructure_page();

        // Call Methodes for top account
        controller.currentId = null;
        controller.hierarchyField = 'ParentId';
        controller.hierarchyClassifyField = 'CRT_Client_Types__c';
        controller.objectName = 'Account';

        HierarchyStructure_page.ObjectStructureMap[] smt1 = new HierarchyStructure_page.ObjectStructureMap[] {};
        smt1 = controller.getObjectStructure();
        //System.Assert( smt1.size() > 0, 'Test failed at Top account, no Id' );

        controller.currentId = (String) olstTestAccount[0].get('id');
        controller.fetchChildren();
        controller.fetchChildren(controller.currentId);
        controller.getHierarchyChildren(controller.currentId);
        System.Assert(controller.currentId != null, 'Test failed at Top account, no Id');
        System.debug('@###@ - ' + controller.currentId);
        HierarchyStructure_page.ObjectStructureMap[] smt2 = new HierarchyStructure_page.ObjectStructureMap[] {};
        smt2 = controller.getObjectStructure();
        System.Assert(smt2.size() > 0, 'Test failed at Top account, with Id: ' + smt2.size());

        //Call ObjectStructureMap methodes
        smt2[0].setnodeId('1234567890');
        smt2[0].setlevelFlag(true);
        smt2[0].setlcloseFlag(false);
        smt2[0].setnodeType('parent');
        smt2[0].setcurrentNode(false);
        smt2[0].setnodeIcon('Prospect');
        smt2[0].setobject(olstTestAccount[0]);

        String nodeId = smt2[0].getnodeId();
        Boolean[] levelFlag = smt2[0].getlevelFlag();
        Boolean[] closeFlag = smt2[0].getcloseFlag();
        String nodeType = smt2[0].getnodeType();
        String nodeIcon = smt2[0].getnodeIcon();
        Boolean currentName = smt2[0].getcurrentNode();
        sObject smbAccount = smt2[0].getobject();

        // Call Methodes for middle account
        controller.currentId = (String) olstTestAccount[1].get('id');
        HierarchyStructure_page.ObjectStructureMap[] smm = new HierarchyStructure_page.ObjectStructureMap[] {};
        smm = controller.getObjectStructure();
        System.Assert(smm.size() > 0, 'Test failed at middle account');
        controller.getChildrenByRecordId((String) olstTestAccount[1].get('id'));
        controller.getChildrenByNodeId(nodeId);
        // Call Methodes for bottom account
        controller.currentId = (String) olstTestAccount[2].get('id');
        HierarchyStructure_page.ObjectStructureMap[] smb = new HierarchyStructure_page.ObjectStructureMap[] {};
        smb = controller.getObjectStructure();
        System.Assert(smb.size() > 0, 'Test failed at top account');



        test.stopTest();
    }
}