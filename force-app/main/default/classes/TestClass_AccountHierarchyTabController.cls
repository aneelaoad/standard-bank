@isTest
private Class TestClass_AccountHierarchyTabController{

    public static TestMethod void accoutHierarchyTest(){
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_Account accBld = new BLD_Account(uow).useChild()
            .cibTarget(false);

        uow.commitWork();

        for (Integer i = 0; i < 4; i++) {
            new BLD_Account(uow).useChild()
                .parentId((Account) accBld.getRecord())
                .cibTarget(false);
            new BLD_Contact(uow).useClientContact()
                .account(accBld);
            new BLD_Opportunity(uow)
                .client(accBld);
        }

        new BLD_Contact(uow).useClientContact()
            .account(accBld)
            .roleAtClient(DMN_Contact.RAC_PRIMARY_SURVEY_CONTACT + ';' + DMN_Contact.RAC_KYC_CONTACT);
        new BLD_Opportunity(uow)
            .client(accBld)
            .stage(DMN_Opportunity.ST_LEAD);

        uow.commitWork();

        List<Hierarchy_Fields__c> cstSetLst=new List<Hierarchy_Fields__c>();
        List<Hierarchy_Fields__c> toDel=new List<Hierarchy_Fields__c>();
        for(integer i=0;i<30;i++){
           String lb='',nm='',obj='';
           
           if(i==0){
             lb='CIF Number';
             nm='CIF__c';
           }else if(i==1){
             lb='Client Sector';
             nm='Client_Sector__c';         
           }else if(i==2){
             lb='Client Sub-Sector';
             nm='Client_Sub_Sector__c';         
           }else if(i==3){
             lb='Account Source';
             nm='AccountSource';         
           }else if(i==4){
             lb='Annual Revenue';
             nm='AnnualRevenue';         
           }else if(i==5){
             lb='Employees';
             nm='NumberOfEmployees';         
           }else if(i==6){
             lb='Rating';
             nm='Rating';         
           }else if(i==7){
             lb='CIF Number Allocated Date';
             nm='CIF_Number_Allocated_date__c';         
           }else if(i==8){
             lb='Website';
             nm='Website';         
           }else if(i==9){
             lb='CIB Target Client';
             nm='CIB_Target_Client__c';         
           }else if(i==10){
             lb='Mobile';
             nm='MobilePhone';   
           }else if(i==11){
             lb='Title';
             nm='Title';                 
           }else if(i==12){
             lb='Fax';
             nm='Fax';         
           }else if(i==13){
             lb='Birthdate';
             nm='Birthdate';         
           }else if(i==14){
             lb='Department';
             nm='Department';         
           }else if(i==15){
             lb='Description';
             nm='Description';         
           }else if(i==16){
             lb='Do Not Call';
             nm='DoNotCall';         
           }else if(i==17){
             lb='Home Phone';
             nm='HomePhone';         
           }else if(i==18){
             lb='Lead Source';
             nm='LeadSource';         
           }else if(i==19){
             lb='Mailing Address';
             nm='MailingAddress';         
           }else if(i==20){
             lb='Type';
             nm='Type';         
           }else if(i==21){
             lb='Probability';
             nm='Probability';         
           }else if(i==22){
             lb='IsPrivate';
             nm='IsPrivate';         
           }else if(i==23){
             lb='Amount';
             nm='Amount';         
           }else if(i==24){
             lb='Reason Won / Lost Comments';
             nm='Reason_Won_Lost_Comments__c';         
           }else if(i==25){
             lb='Next Step';
             nm='NextStep';         
           }else if(i==26){
             lb='Quantity';
             nm='TotalOpportunityQuantity';         
           }else if(i==27){
             lb='Actual Close Date';
             nm='Actual_Close_Date__c';         
           }else if(i==28){
             lb='Competitor';
             nm='Competitor__c';         
           }else if(i==29){
             lb='Reason Won / Lost';
             nm='ReasonForWinLossPickList__c';         
           }
           
            
            if(i<10)
             obj='Account';
            else if(i<20)
             obj='Contact'; 
            else 
             obj='Opportunity'; 
             
            Hierarchy_Fields__c hf=new Hierarchy_Fields__c(Name=nm,Object_Name__c=obj,Field_Label__c=lb,Sort_Order__c=i);
            cstSetLst.add(hf);       
        }
        toDel=[select id from Hierarchy_Fields__c];
        delete toDel;
        Database.saveResult[] sr=Database.insert(cstSetLst,true); 
          
        ApexPages.StandardController cont=new ApexPages.StandardController((Account) accBld.getRecord());
        Pagereference p = Page.AccountHierarchy_TabPage;
        Test.setcurrentpage(p);
        ApexPages.currentPage().getParameters().put('id', accBld.getRecordId());
        AccountHierarchyTabController tabCont=new AccountHierarchyTabController(cont);    
        tabCont.getItems();
        tabCont.getItemsopp();
        tabCont.AccIds.add(accBld.getRecordId());
        tabCont.getwrpConLst();
        System.assertEquals(tabCont.wrpConLst.size(),5);
        tabCont.retfiltcontact();
        tabCont.setsearchTextcon('Primary Survey Contact');
        tabCont.retfiltcontact();
        System.assertEquals(tabCont.wrpConLst.size(),1);
        tabCont.getwrpOppLst(); 
        System.assertEquals(tabCont.wrpOppLst.size(),5);
        tabCont.retfiltopp();
        tabCont.setsearchTextopp('1 - Lead');
        tabCont.retfiltopp();  
        System.assertEquals(tabCont.wrpOppLst.size(),1);
        tabCont.sortTable();
        tabCont.sortOppTable();
        //tabCont.next();
       // tabCont.previous();
        tabCont.showComponent();
        System.assertEquals(tabCont.showcomponent,True);
        tabCont.getsearchTextcon();
        tabCont.getsearchTextopp();
        
        // HierarchyComponentController Methods
       HierarchyComponentController hierComp=new HierarchyComponentController();
       
        hierComp.accountNodes=null;
        hierComp.showColumns();
        hierComp.currentAccountId = accBld.getRecordId();
        HierarchyComponentController.AccountNode hierNode = new HierarchyComponentController.AccountNode((Account) accBld.getRecord());
        List<HierarchyComponentController.AccountNode> listnode;
        hierComp.accountNodes=listnode;
        listnode=new List<HierarchyComponentController.AccountNode>();
      
        listnode.add(hierNode);
        List<HierarchyComponentController.AccountNode> nodeslist= hierComp.accountNodes;
        hierComp.createChildrenAccountsNodes( listnode);
        hierComp.serializeAndAddFormat(hierNode,' ');
        System.assertNotEquals(hierComp.accountNodes.size(),Null);
        //SortColumns Class Methods
        
        SortColumns sc=new SortColumns();
        sc.objSelected='Account';
        sc.getOrderLst();
        sc.OrderColumns();
        sc.Cancel();
      }
    
}