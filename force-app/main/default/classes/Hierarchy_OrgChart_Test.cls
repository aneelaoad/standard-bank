/********************************************************************************************************************
        @author         :     Abhishek Vaideeswaran
        @date           :     02/02/2016
        @name           :     Hierarchy_OrgChart_Test
        @Description    :     Test method for the Hierarchy_OrgChart class. EN - 1045 - Modified all test data which were created individually to refer to TestDataUtility Class which was created exclusively for test data creation.
        
*********************************************************************************************************************/

@isTest
private class Hierarchy_OrgChart_Test {

    static testMethod void HierarchyUnitTest() {
    
          User u = (User) new BLD_USER().useSysAdmin().getRecord();

          System.runAs(u) {
              List<Account> acclst = new List<Account>();
              fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
              for (Integer i = 0; i < 5; i++) {
                  acclst.add((Account) new BLD_Account(uow).useChild().getRecord());
              }
              uow.commitWork();
            
            acclst[1].Parentid = acclst[0].id;
            acclst[2].Parentid = acclst[1].id;
            acclst[3].Parentid = acclst[2].id;
            acclst[4].Parentid = acclst[3].id;
            update acclst;
            
            PageReference pageRef = Page.Hierarchy_OrgChart;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('Id', acclst[1].id);
            
            Hierarchy_OrgChart controller = new Hierarchy_OrgChart();
            //Check if the chart is generated correctly
            system.assert(controller.hierarchyDataString!=null);
            
            controller.selectedAccountId = acclst[1].id+':'+acclst[2].id+':'+'Parent';
            controller.loadmore();
            controller.collapseNode();
            controller.expandAll();
        }
    }
}