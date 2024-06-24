/******************************************************************************************
Apex Class Name : HierarchyComponentController
Version         : 1.0
Created Date    : 1/27/2011 
Description     : This apex class is used to display account hierarchy. This class is invoked when user clicks on 
                  'Account Hierarchy' button on the account detail page. Maximun hierarcy depth is 6
                  a) If the number of records in the hierarchy are less than 200, then hierarchy on the page is displayed as
                     expanded.
                  b) If the number of records in the hierarchy is greater than 200 and less than 1000, then hierarchy on the
                     page is displayed as collapsed.  
                  c) If the number of records in the hierarchy are greater than 1000, then hierarchy on the
                     page is displayed as collapsed with warning message that only 1000 rows can be displayed.   
                     
                  Columns that are displayed on the page are based on 'Hierarchy Fields' custom setting.

*******************************************************************************************/

public without sharing class HierarchyComponentController {

   //Variable Declaration

    private final Integer MAXDEPTH = 6;
    public Integer nodeCount = 1; 
    public static Set<Id> accountIds=new Set<Id>();
    public static List<Hierarchy_Fields__c> ActHierflds=new List<Hierarchy_Fields__c>();
    public static Map<Double,Hierarchy_Fields__c> mapAccHierflds=new Map<Double,Hierarchy_Fields__c>();
    public ID currentAccountId {get;  set;}   
    public static List<Hierarchy_Fields__c> hierFlds;
    public boolean errorMsg{get;set;}
    public static String lb1{get;set;}
    public static String lb2{get;set;}
    public static String lb3{get;set;}
    public static String lb4{get;set;}
    public static String lb5{get;set;}
    public static String lb6{get;set;}
    public static String lb7{get;set;}
    public static String lb8{get;set;}
    public static String lb9{get;set;}
    public static String lb10{get;set;}
    
    public static Map<String,Schema.SObjectField> AccountFieldMap = Schema.sObjectType.Account.Fields.getMap();
    
    // Base query for fetching accounts
    public String qry = 'select id,name,Parent.name,ParentId,owner.name,owner.id, RecordType.Name';
    
    static{
          hierFlds= Hierarchy_Fields__c.getall().values();
          List<Double> lst=new List<Double>();
          for(integer i=0;i<hierFlds.size();i++)
                if(hierFlds[i].Object_Name__c=='Account')
                  mapAccHierflds.put(hierFlds[i].Sort_Order__c,hierFlds[i]);
            
            lst.addall(mapAccHierflds.keySet());
                  lst.sort();
                  for(Double d:lst)
                    ActHierflds.add(mapAccHierflds.get(d));
                    
                    for(integer i=0;i<ActHierflds.size();i++){
            if(ActHierflds[i].Object_Name__c=='Account'){
                    if(i==0)
                    lb1= ActHierflds[i].Field_Label__c;
                    if(i==1) 
                    lb2= ActHierflds[i].Field_Label__c;
                    if(i==2)
                    lb3= ActHierflds[i].Field_Label__c;
                    if(i==3) 
                    lb4= ActHierflds[i].Field_Label__c;
                    if(i==4)
                    lb5= ActHierflds[i].Field_Label__c;
                    if(i==5)
                    lb6= ActHierflds[i].Field_Label__c;
                    if(i==6) 
                    lb7= ActHierflds[i].Field_Label__c;
                    if(i==7)
                    lb8= ActHierflds[i].Field_Label__c;
                    if(i==8)
                    lb9= ActHierflds[i].Field_Label__c;
                    if(i==9) 
                    lb10= ActHierflds[i].Field_Label__c;
            }        
        }
    }
    
    //Constructor
    
    public HierarchyComponentController (){
        errorMsg=true;      
    }
   
    Public void showColumns(){
     errorMsg=false;
   }
   

    // Wrapper
    public class AccountNode{

        public Account account {get; private set;}        
        public List<AccountNode> childAccountsNodes {get;  set;}
        public String htmlID {public get; public set;}
        public String htmlClass {public get; public set;}
        public String f1{get;set;}
        public String f2{get;set;}
        public String f3{get;set;}
        public String f4{get;set;}
        public String f5{get;set;}
        public String f6{get;set;}
        public String f7{get;set;}
        public String f8{get;set;}
        public String f9{get;set;}
        public String f10{get;set;}         
    
           
        // constructor
        public AccountNode(Account account) {        
            this.account        = account;
            childAccountsNodes  = new List<AccountNode>();       
            
       
            for(integer i=0;i<ActHierflds.size();i++) {
                    if(i==0)
                        f1= FormatField(this.account, i);//((''+this.account.get(ActHierflds[i].Name))==''+null?'':(''+this.account.get(ActHierflds[i].Name)));                
                    if(i==1)
                        f2= FormatField(this.account, i);//((''+this.account.get(ActHierflds[i].Name))==''+null?'':(''+this.account.get(ActHierflds[i].Name)));                      
                    if(i==2)
                        f3= FormatField(this.account, i);//((''+this.account.get(ActHierflds[i].Name))==''+null?'':(''+this.account.get(ActHierflds[i].Name)));              
                    if(i==3)
                        f4= FormatField(this.account, i);//((''+this.account.get(ActHierflds[i].Name))==''+null?'':(''+this.account.get(ActHierflds[i].Name)));    
                    if(i==4)
                        f5= FormatField(this.account, i);//((''+this.account.get(ActHierflds[i].Name))==''+null?'':(''+this.account.get(ActHierflds[i].Name)));    
                    if(i==5)
                        f6= FormatField(this.account, i);//((''+this.account.get(ActHierflds[i].Name))==''+null?'':(''+this.account.get(ActHierflds[i].Name)));    
                    if(i==6)
                        f7= FormatField(this.account, i);//((''+this.account.get(ActHierflds[i].Name))==''+null?'':(''+this.account.get(ActHierflds[i].Name)));    
                    if(i==7)
                        f8= FormatField(this.account, i);//((''+this.account.get(ActHierflds[i].Name))==''+null?'':(''+this.account.get(ActHierflds[i].Name)));    
                    if(i==8)
                        f9= FormatField(this.account, i);//((''+this.account.get(ActHierflds[i].Name))==''+null?'':(''+this.account.get(ActHierflds[i].Name)));    
                    if(i==9)
                        f10= FormatField(this.account, i);//((''+this.account.get(ActHierflds[i].Name))==''+null?'':(''+this.account.get(ActHierflds[i].Name)));    
               }
            }
            
            private String FormatField(sObject FormatObject, Integer FieldNumber)
            
            {if(FieldNumber < -1 || FieldNumber >= ActHierflds.size())
                    return '';
                String fName = (ActHierflds[FieldNumber].Name.contains('::'))? ActHierflds[FieldNumber].Name.split('::')[1] : ActHierflds[FieldNumber].Name;
                Schema.DescribeFieldResult FieldResults = AccountFieldMap.get(fName).getDescribe();
                
                
                if(FieldResults.getType() == Schema.DisplayType.Date || FieldResults.getType() == Schema.DisplayType.DateTime){
                    DateTime FomratDate = (DateTime) FormatObject.get(fName); 
                    try {
                        return String.valueOf(FomratDate.format('MM/dd/yyyy'));
                    }
                    catch (System.NullPointerException ex) {
                        return ('');
                    }
                }
                else if(FieldResults.getType() == Schema.DisplayType.Currency)
                {
                
                    String UnformattedCurrency = String.valueOf(FormatObject.get(fName));
                    String FormattedCurrency = (Decimal.valueOf(UnformattedCurrency == null || 
                        UnformattedCurrency.trim() == '' ? '0' : UnformattedCurrency).setScale(2) + 0.001 ).format();
                    
                    return '$' + FormattedCurrency.substring(0, FormattedCurrency.length() - 1);
                }
                else if(FieldResults.getType() == Schema.DisplayType.Double)
                {
                    String UnformattedNumber = String.valueOf(FormatObject.get(fName));
                    
                    String FormattedNumber = (Decimal.valueOf(UnformattedNumber == null || 
                        UnformattedNumber.trim() == '' ? '0' : UnformattedNumber).setScale(2) + 0.001 ).format();
                    
                    return FormattedNumber.substring(0, FormattedNumber.length() - 1);
                }
                else if(FieldResults.getType() == Schema.DisplayType.Boolean)
                    return ((Boolean)FormatObject.get(fName)) ? 'True' : 'False';
                
                return String.valueOf(FormatObject.get(fName));
            }        
    }
   
    // entry point
    public List<AccountNode> accountNodes {
        get{       
            if(accountNodes!=null) {  
              if(accountNodes.size()==1000) { 
                 ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.WARNING,'The hierarchy display is collapsed on large accounts.  Click the + Symbol to expand.  Only the first 1,000 rows of any client hierarchy will display in this interface.  Please contact your support team to obtain hierarchy details on clients with greater than 1,000 locations.');
                 ApexPages.addMessage(msg);          
                 return accountNodes;
               }else                
                 return accountNodes;
            } 
            
            for(Hierarchy_Fields__c hf:ActHierflds){
                System.debug('******************'+hf.name);
                if(!qry.contains(hf.name)){
                    system.debug('### hf.name: '+hf.name);
                    if(hf.name.contains('::')){
                        String strName = hf.name.split('::')[1];
                        if(strName!='Name' && strName !='ParentId' && strName !='Parent.Name' && strName !='Owner.Name')
                        qry += ',' + strName;       
                    }
                    else{
                        system.debug('### inside else hf.name: '+hf.name);
                        if(hf.name!='Name' && hf.name !='ParentId' && hf.name !='Parent.Name' && hf.name !='Owner.Name')
                        qry += ',' + hf.name;
                    }
                }
              
            }  
            
            if(!qry.contains('  from Account where '))
            qry  +=  '  from Account where ';
            System.debug('Query On Account'+qry);

            List<AccountNode> accountNodeList  = new List<AccountNode>(); 
         
            // Get ulimate parent ID
            ID rootId = getRootID(currentAccountId, 0);
            
            //Add the ultimate parent to accountids set
            accountIds.add(rootId);
            
            // Get the account details for that ID and add it to the list
            accountNodeList.add( new AccountNode( Database.query(qry+'Id=:rootId') ));

            // start the recursive process with the root node.
            createChildrenAccountsNodes(accountNodeList);

            // add the right HTML tags for pickup in the VF page
            accountNodes = new List<AccountNode>();  
            serializeAndAddFormat(accountNodeList[0], '');
            
            return accountNodes;      

        } set;
    }
  

    Public ID getRootID( String objId, Integer level ){
        // get parent for this account
        Account a = [Select Id, ParentId From Account where Id = :objId limit 1];

        // if no parent then this is the Ultimate Parent else recurse
        if( a.parentID == NULL || level == MAXDEPTH  )
            return a.ID;
        else 
            return getRootID(a.parentID, level+1);
    }
    

    Public void createChildrenAccountsNodes( List<AccountNode> parentNodes ) {
        // Set of ids of parent accounts
        Set<ID> parentAccountIds = new Set<ID>();
        boolean hasChildren = false;
        // Map from account id to List of children nodes
        Map<ID, List<AccountNode>> childrenAccountsNodesMap =
            new Map<ID, List<AccountNode>>();
        for (AccountNode node : parentNodes) {
            parentAccountIds.add(node.account.id);
            childrenAccountsNodesMap.put(node.account.id, node.childAccountsNodes);
        }
        for (List<Account> childrenAccounts : 
            Database.query( qry+ 'ParentId in :parentAccountIds order by Name limit 500')) {
            
            for (Account childrenAccount : childrenAccounts) {
                //set the boolean variable
                hasChildren = true;
                // Add current account to corresponding List of children nodes
                childrenAccountsNodesMap.get(childrenAccount.ParentId).add(
                        new AccountNode(childrenAccount));
            }
        }
        List<AccountNode> childrenNodeList = new List<AccountNode>();
        if(hasChildren)
        {
            for(List<AccountNode> acctNodeList : childrenAccountsNodesMap.values()){
                    childrenNodeList.addAll(acctNodeList);
                }
                
                // Create lower level of children Accounts' nodes
                for (List<AccountNode> childrenAccountsNodes : childrenAccountsNodesMap.values()) {
                    
                //Add the accountIds to set 
                    for(AccountNode accnts : childrenAccountsNodes) 
                         accountIds.add(accnts.account.Id);
                // Recursive call only if there are children accounts
                if (childrenNodeList.size() > 0 ){
                    createChildrenAccountsNodes(childrenNodeList);
                    //Clear the lists
                    childrenNodeList.clear();
                    childrenAccountsNodesMap.clear();
                    
                }
            }
        } 
    }

    Public void serializeAndAddFormat(AccountNode currentNode, String parentHtmlId){  
        // after root
        if(nodeCount > 1)
            currentNode.htmlClass  = 'child-of-'+parentHtmlId;      

        // add node Id to parent node
        currentNode.htmlID = 'node-'+nodeCount++;  
      
        // add to serialized list
        if(accountNodes.size()<1000)
         accountNodes.add(currentNode);     
       
        System.debug( ' ----- '+ currentNode.Account.name + ' ---- '+ currentNode.htmlClass +' --- ' + currentNode.htmlID + ' --- ' + currentNode.Account.ID );

        if(currentNode.childAccountsNodes.size() == 0)  
            return;       

        // add HTML for children & recurse
        for (AccountNode node : currentNode.childAccountsNodes) 
            serializeAndAddFormat(node, currentNode.htmlID );  
    }  
}