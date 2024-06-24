/******************************************************************************************
Apex Class Name : SortColumns
Version         : 1.0
Created Date    : 1/16/2011
Created By      : Anil Kumar Pilaka 
 
Description     : This apex class is used to Sort the order of columns that are displayed on 
                  Accounts, Contacts and Opportunites tab on the account hierarchy screen. 
                  This class is invoked when user clicks on 'Order Columns' button on the Hierarchy page. 
                  Columns sort order defined on the page are based on 'Sort Order' field on
                  'Hierarchy Fields' custom setting.

*******************************************************************************************/
public class SortColumns {

  //Variable Declaration
  public boolean errorFlag{get;set;}
  public String objSelected{get;set;}
  public List<wrpHierarchyColumns> orderColumns;
  public Map<String,Double> mapval=new Map<String,Double>();
  
  // This method is used to display the current sort order from the custom settings.
  
  public List<wrpHierarchyColumns> getOrderLst(){
    orderColumns=new List<wrpHierarchyColumns>();    
    List<Hierarchy_Fields__c> hierFlds= Hierarchy_Fields__c.getall().values();
    Map<Double,Hierarchy_Fields__c> mapHierFlds= new Map<Double,Hierarchy_Fields__c>();
    List<Hierarchy_Fields__c> selHierFlds= new List<Hierarchy_Fields__c>();
    
    mapval.put('1',1);
    mapval.put('2',2);
    mapval.put('3',3);
    mapval.put('4',4);
    mapval.put('5',5);
    mapval.put('6',6);
    mapval.put('7',7);
    mapval.put('8',8);
    mapval.put('9',9);
    mapval.put('10',10);
    
    List<Double> lst=new List<Double>();
    
    for(integer i=0;i<hierFlds.size();i++)
     if(hierFlds[i].Object_Name__c==objSelected)
       mapHierFlds.put(hierFlds[i].Sort_Order__c,hierFlds[i]);
   
     lst.addAll(mapHierFlds.keySet()); 
      lst.sort();
     for(Double d:lst)         
       selHierFlds.add(mapHierFlds.get(d));
      
     for(integer j=0;j<selHierFlds.size();j++)  
       orderColumns.add(new wrpHierarchyColumns(selHierFlds[j],selHierFlds.size()));

       return orderColumns;
  }
  
  //Wrapper class to display the table for current sort order list from custom settings.
  public class wrpHierarchyColumns{
    public String Selected{get;set;}
    
    public List<SelectOption> options{get;set;} 
    public Hierarchy_Fields__c hrFlds{get;set;}
    
    public wrpHierarchyColumns(Hierarchy_Fields__c hf,Integer lstSize){
      hrFlds=hf;
      options=new List<SelectOption>();
      for(integer i=1;i<=lstSize;i++)
       options.add(new SelectOption(i.format(),i.format()));
    }
  }
 
   /*
      This method is invoked when user clicks on Save button on the Sort order list section.
      If user selects new sort order on the page, the corresponding custom settings 'Sort Order'
      field is updated with the newly selected value. This helps to display the columns in the
      hierarchy page for accounts, contacts and opportunity with new column ordering.
   */
    public PageReference OrderColumns() {
      Set<String> errCheck=new Set<String>();
      boolean error=false;
      errorFlag=false;
      List<Hierarchy_Fields__c> HierarchyLstToUpdate=new List<Hierarchy_Fields__c>();
      for(wrpHierarchyColumns clm:orderColumns){ 
        if(errCheck.contains(clm.Selected)){
          error=true;
          break;
        }else{
             errCheck.add(clm.Selected);
             Hierarchy_Fields__c hf=new Hierarchy_Fields__c(id=clm.hrFlds.id,Sort_Order__c=mapval.get(clm.Selected));
             HierarchyLstToUpdate.add(hf);
        }
      }    
      
      if(error){
        ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.ERROR,'Select unique Sort Order Columns');
        ApexPages.addMessage(msg);  
        errorFlag=true;
        return null;        
      }else{
        update HierarchyLstToUpdate;
        Pagereference p=new Pagereference('/apex/AccountHierarchy_TabPage?id='+ApexPages.currentPage().getparameters().get('id'));   
        p.setRedirect(true);
        return p;
      }
    }
    
    //This method navigates the user back to the hierarchy page.
    public pagereference Cancel(){
      Pagereference p=new Pagereference('/apex/AccountHierarchy_TabPage?id='+ApexPages.currentPage().getparameters().get('id'));   
      p.setRedirect(true);
      return p;      
    }
}