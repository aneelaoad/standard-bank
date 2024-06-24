/******************************************************************************************************************************
* Name        - PickListMultiSelect
* Description - This Controller describes the field of SObject and populates
                selectlist accordingly.
* Modification Log :
* ---------------------------------------------------------------------------
* Developer                   Date                   Description
* ---------------------------------------------------------------------------
* Pragya                       01/05/2011             Created
*******************************************************************************************************************************/
public class PickListMultiSelect{
   
//Declare Variables
public boolean showOrderSort{get;set;}
public boolean errorMsg{get;set;}
public String Msg{get;set;}
public List<String>FieldsSelected = new List<String>();
public List<String>FieldsRemoved = new List<String>();
public Map<String,String> FieldsAvbltemp = new Map<String,String>();
public Map<String,String> FieldLblNm= new Map<String,String>();
public List<String> remainingFields = new List<String>();
public List<String> FieldsAvbl = new List<String>();
public List<String> Selected = new List<String>(); //collection that holds all selected Fields
Public String obj;
private Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
public String arrange = 'None';
//constructor
Public PickListMultiSelect(){
    if(ObjectSelected == Null)
        ObjectSelected = 'Account';
   
    List<Hierarchy_Fields__c> settings = [Select Name,Field_Label__c from Hierarchy_Fields__c where Object_Name__c=:ObjectSelected];
    for(Hierarchy_Fields__c hFields:settings)
       Selected.add(hFields.Field_Label__c);    
    AssignPickListValues();
    errorMsg=false;
    Msg='';
}
Public void describeObject()
{
    Selected.clear();
    List<Hierarchy_Fields__c> settings = [Select Name,Field_Label__c from Hierarchy_Fields__c where Object_Name__c=:ObjectSelected];
    System.debug('*****ObjectSelected******'+ObjectSelected);
    for(Hierarchy_Fields__c hFields:settings)
        Selected.add(hFields.Field_Label__c);
    AssignPickListValues();
}
public void AssignPickListValues()
{
// Get the picklist Values
       // try{
            FieldsAvbltemp.clear();
            FieldsAvbl.clear();
            System.debug('*****ObjectSelectedhelp******'+ObjectSelected);
            Map <String, Schema.SObjectField> fieldMap =schemaMap.get(ObjectSelected).getDescribe().fields.getMap();
            
            system.debug('#### fieldMap: '+fieldMap.size());
            for(Schema.SObjectField sfield : fieldMap.Values()){
                schema.describefieldresult dfield =sfield.getDescribe();  
                System.debug('*****yash******'+dfield);
            }
            for(Schema.SObjectField sfield : fieldMap.Values()){
              schema.describefieldresult dfield =sfield.getDescribe();         
              FieldLblNm.put(dfield.Label,dfield.Name); 
              if (dfield.Label!='Account Id') {
              FieldsAvbl.add(dfield.Label);
              }   
              else{
                  system.debug('### dfield.Label: '+dfield.Label);
              }
                        
            }  
            system.debug('#### FieldsAvbl: '+FieldsAvbl.size());
           /* for(String s : schemaMap.get(ObjectSelected).getDescribe().fields.getMap().keyset())//Describe fields of the Sobject
              {
                FieldsAvbltemp.put(s,s);  
                FieldsAvbl.add(s);
              
            
        }catch(Exception e)
        {
           ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
           ApexPages.addMessage(myMsg);
        }*/
} 
 public List<SelectOption> getAvblFields() {
        List<SelectOption> options = new List<SelectOption>();
        remainingFields.clear();
        for( String s : FieldsAvbl)
        {
            FieldsAvbltemp.put(s,s);
        }
        
        if(Selected.size() == 0) //Initial Load
        {
                for(String s : FieldsAvbl)
                {
                   System.debug(s);
                    options.add(new SelectOption(s,s)); // Add the picklist values
                }
        
        }
        else
        {
                 for(String s : Selected)
                 {
                      if(FieldsAvbltemp.get(s) != Null) 
                          FieldsAvbltemp.remove(s);         
                 }
                for(String key : FieldsAvbltemp.keyset())
                    remainingFields.add(FieldsAvbltemp.get(key));
                remainingFields.sort();
                for(String s : remainingFields)
                {
                 options.add(new selectOption(s,s));
                }
              
        }
        system.debug('#### options: '+options.size());
        return options;
    }   
    
    public List<SelectOption> getFieldsInSelectList() 
    {
        List<SelectOption> options = new List<SelectOption>();
        if(arrange == 'None')
            Selected.sort();
        for(String selectedVals : Selected)
        {
            for(String s : FieldsAvbl)
            {
                if(selectedVals == s)
                {
                    options.add(new SelectOption(s,s)); // Add the picklist values
                    break;
                }
            }
        }
        return options;
    }
   
    public void removeFields() // removes selected Fields from the list
    {
         for(String s : FieldsRemoved)
          {
             for(Integer i=0;i<Selected.size();i++)
             {
                 if(Selected[i] == s)
                 {
                     Selected.remove(i);
                     break;
                 }
              }
          }
          
                           
    }
    public void addFields() //Adds Fields to existing selected Fields
    {
      for(String s : FieldsSelected)            
         Selected.add(s);
    }
    
   /* public void arrangeOnTop() // Moves the selected field to top
    {
        arrange = 'Top';
        List<String> arrangedList = new List<String> ();
        for(String s:FieldsRemoved)
        {
            for(Integer i=0;i<Selected.size();i++)
            {
                 if(s == Selected[i])
                 {
                     for(Integer k = 0;k<=i;k++)
                     {
                         if(k == 0)
                             arrangedList[k] = s;
                         else
                             arrangedList[k] = Selected[k];             
                     }
                 }
            }    
        }
        system.debug('############'+arrangedList);
        system.debug('************'+Selected);
    }*/
    
    public List<String> getFieldsSelected(){ return FieldsSelected ;}//this method maintains the selected items in Available list.
    public void setFieldsSelected(List<String> FieldsSelected){ this.FieldsSelected  = FieldsSelected ;}
    
    public List<String> getremoveList(){ return FieldsRemoved;}// this method maintains the selected items in removal list
    public void setremoveList(List<String> FieldsRemoved){this.FieldsRemoved = FieldsRemoved;}
    
    Public String ObjectSelected{get;set;}
    public List<SelectOption> getAvblobjects() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('Account','Account')); // Add the picklist values
            options.add(new SelectOption('Contact','Contact')); // Add the picklist values
            options.add(new SelectOption('Opportunity','Opportunity')); // Add the picklist values
            return options;
    }
    
    /*This method creates records in the custom setting 'Hierarchy fields' based on the object selected on the page.
     These creates records based on Field Selected on the page. User can save up to 10 custom columns on the page.
    */
    public PageReference SaveHierarchyColumns() 
    {
        system.debug('$$$$$$$$'+Selected);
        //arrangeOnTop();
        if(Selected.size()>10){
            Msg='Select only 10 Columns for display.';
            errorMsg=true;         
            return null;
        }else{
        
            //Delete records from custom setting 
            boolean containsName = false;
            List<Hierarchy_Fields__c> settings = [Select Name from Hierarchy_Fields__c where Object_Name__c=:ObjectSelected];
            //Delete settings
            if(settings.size() > 0)
                delete settings;
            // Insert custom settings
            settings.clear();
            Integer i=1;
            for(String s:Selected){
                if(FieldLblNm.get(s).length()<=38){
                    Hierarchy_Fields__c newRecord = new Hierarchy_Fields__c();
                    newRecord.Name = ObjectSelected+'::'+FieldLblNm.get(s);
                    newRecord.Object_Name__c = ObjectSelected;      
                    newRecord.Field_Label__c=s; 
                    newRecord.Sort_Order__c=i; 
                    i++;      
                    settings.add(newRecord);
                }  
            }
            if(settings.size()>0){
                insert settings;
                showOrderSort=true;
             }   
           return null;
        }  
    }
    
  
    public pagereference back(){      
      Pagereference p=new Pagereference('/apex/AccountHierarchy_TabPage?id='+ApexPages.currentPage().getparameters().get('id'));   
      p.setRedirect(true);
      return p;      
    }
          
}