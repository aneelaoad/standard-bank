/*************************************************************************
    @ Author        : psvestka
    @ Date          : 13. 8. 2015
    @ Description   : Force.com reviewer - Blocker and Critical issues - 20150608.xlsx
****************************************************************************/

@IsTest
private class HierarchyStructure_pageTest {

    @TestSetup
    private static void prepareData() {
        // AccountId doesn't have to be filled for RT 'Client Contact Record Type'

        Contact c1 = new Contact(FirstName = 'Joe', LastName = 'Root', Salutation = 'Mr.',
            RecordTypeId = GlobalCache.getRecordTypeId('Contact', 'Client Contact Record Type'),
            Contact_Category__c = 'Manager',
            Email = 'joe.root@test.com',
            Phone = '123'
        );
        insert c1;

        Contact c2 = new Contact(FirstName = 'A', LastName = 'Child1', Salutation = 'Mr.',
            RecordTypeId = GlobalCache.getRecordTypeId('Contact', 'Client Contact Record Type'),
            Contact_Category__c = 'Staff',
            Email = 'a.child1@test.com',
            Phone = '123',
            ReportsToId = c1.id
        );
        insert c2;

        Contact c3 = new Contact(FirstName = 'A', LastName = 'Child2', Salutation = 'Mr.',
            RecordTypeId = GlobalCache.getRecordTypeId('Contact', 'Client Contact Record Type'),
            Contact_Category__c = 'Staff',
            Email = 'a.child2@test.com',
            Phone = '123',
            ReportsToId = c2.id
        );
        insert c3;
    }

    static testMethod void testGetTopElement() {
        Contact topCon = [SELECT id FROM Contact WHERE Email = 'joe.root@test.com' LIMIT 1];
        Contact leafCon = [SELECT id FROM Contact WHERE Email = 'a.child2@test.com' LIMIT 1];

        HierarchyStructure_page h = new HierarchyStructure_page();
        h.objectName = 'Contact';
        h.hierarchyField ='ReportsToId';

        Test.startTest();

        String foundTopId = h.getTopElement(leafCon.Id);
        system.assertEquals(topCon.Id, foundTopId, 'Return Id is not the root of the hierarchy');

        Test.stopTest();
    }

    static testMethod void testRecursiveCode() {
        Contact leafCon = [SELECT id FROM Contact WHERE Email = 'a.child2@test.com' LIMIT 1];

        HierarchyStructure_page h = new HierarchyStructure_page();
        h.objectName = 'Contact';
        h.hierarchyField ='ReportsToId';
//      h.hierarchyClassifyField = 'CRT_Client_Types__c'; // todo should be used on Accounts

        Test.startTest();

        HierarchyStructure_page.ObjectStructureMap[] m = h.formatObjectStructure(leafCon.Id);

        system.assertEquals(3, m.size(), 'There should be 3 items in the array');

        system.assertEquals('0000', m[0].nodeId);
        system.assertEquals('0000.0000', m[1].nodeId);
        system.assertEquals('0000.0000.0000', m[2].nodeId);

        system.assertEquals('Joe Root', ((Contact)(m[0].theObject)).Name);
        system.assertEquals('A Child1', ((Contact)(m[1].theObject)).Name);
        system.assertEquals('A Child2', ((Contact)(m[2].theObject)).Name);

        Test.stopTest();
    }
}