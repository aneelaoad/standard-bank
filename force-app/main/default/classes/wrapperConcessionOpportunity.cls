/*************************************************************************
@ Author        : Manoj Gupta
@ Date          : 12th Nov 2016
@ Description   : US:1593 CommB - CMS - 12 - RM Generates Concession Letter
******************************************************************************/
public without sharing class wrapperConcessionOpportunity {

    public String username { get; set; }

    public Concession__c currentRecord{get; set;}
    public wrapperConcessionOpportunity(){
        normalList = true;
        selectedList = false;
       // currentRecord = [SELECT Id, Name, Amount FROM Concession__c WHERE Id = :ApexPages.currentPage().getParameters().get('id')];
     String recId =String.valueof(ApexPages.currentPage().getParameters().get('id')).subString(0,3);

        count = 0;
        fetchData();
    }
    public Date Today { get { return Date.today(); }}
    public boolean normalList{get;set;}
    public boolean selectedList{get;set;}
    public boolean ismerchantacquiring{get;set;}
    public boolean istransactional{get;set;}
    public String Accname{get;set;}
    public decimal Riskgroupnum{get;set;}
    public String oppmanager{get;set;}
    public String oppmanageremail{get;set;}
    public String oppmanagerphone{get;set;}
    public String oppowner{get;set;}
    public String oppownerphone{get;set;}
    public String oppowneremail{get;set;}
    public String Accaddress{get;set;}
    public String AccCIF{get;set;}
    public Integer count{get; set;}
    public String salname{get; set;}
    public String actextname{get; set;}
    
    

    

    
 

    public void countvalue(){
        count = 0;
        system.debug('++++'+wrapperList);
        for(myWrapperClass selectedWrapObj: wrapperList){
            system.debug('selectedWrapObj.selected  ---------'+selectedWrapObj.selected);
            if(selectedWrapObj.selected == true) {
            count++;}}
            
    }

    public void fetchData(){
        
        list<Concession__c> allOpps = new list <Concession__c>();
        Schema.DescribeSObjectResult ac = Schema.SObjectType.Account;
        String AcckeyPrefix = ac.getKeyPrefix(); 
        
        Schema.DescribeSObjectResult op = Schema.SObjectType.Opportunity;
        String OppkeyPrefix = op.getKeyPrefix();
        
        if (String.valueof(ApexPages.currentPage().getParameters().get('id')).subString(0,3) == AcckeyPrefix){
            
            allOpps = [Select name,Risk_Group_Number__c,Initiation_Fee__c,BOL_Transaction_Type__c,Review_Fee__c,Review_Extension_Fee__c,Average_OD_Utilisation__c,Unutilised_Facility_Fee__c,Concession_owner_s_manager__c,Concession_owner_s_manager_email__c,Concession_owner_s_manager_phone__c,Lending_Product_Type__c,Margin_Above_Prime__c,(SELECT Condition_Measure__c,Condition_Product__c,Deadline__c,Value__c FROM Conditions_of_Grant__r),Investment_Product_Type__c,Cash_Acquiring_Channel_Type__c,Interest_To_Client__c,Id,BOL_User_ID__c,Product_Account_Number__c,Maximum_Fee__c,Base_Rate__c,Ad_Valorem__c,Opportunity__c,Status__c,Sub_Status__c,Start_Date__c,End_Date__c,Merchant_Number__c,Transaction_Type__c,Commission_Rate__c,RecordType.DeveloperName,RecordType.Name,Opportunity__r.Account.Name,Opportunity__r.Account.Correspondence_Addr_Line1__c,Opportunity__r.Owner.LastName,Opportunity__r.Owner.FirstName,Opportunity__r.Owner.Phone,Opportunity__r.Owner.Email,Opportunity__r.Account.CIF__c from Concession__c where ((Opportunity__r.AccountId  =: ApexPages.currentPage().getParameters().get('id')) and ((Status__c = 'New' AND Sub_Status__c = 'Pricing Team Approved') )) ];
        }
        else if(String.valueof(ApexPages.currentPage().getParameters().get('id')).subString(0,3) == OppkeyPrefix){
             
             allOpps = [Select name,Risk_Group_Number__c,Initiation_Fee__c,BOL_Transaction_Type__c,Review_Fee__c,Review_Extension_Fee__c,Average_OD_Utilisation__c,Unutilised_Facility_Fee__c,Concession_owner_s_manager__c,Concession_owner_s_manager_email__c,Concession_owner_s_manager_phone__c,Lending_Product_Type__c,Margin_Above_Prime__c,(SELECT Condition_Measure__c,Condition_Product__c,Deadline__c,Value__c FROM Conditions_of_Grant__r),Investment_Product_Type__c,Cash_Acquiring_Channel_Type__c,Interest_To_Client__c,Id,BOL_User_ID__c,Product_Account_Number__c,Maximum_Fee__c,Base_Rate__c,Ad_Valorem__c,Opportunity__c,Status__c,Sub_Status__c,Start_Date__c,End_Date__c,Merchant_Number__c,Transaction_Type__c,Commission_Rate__c,RecordType.DeveloperName,RecordType.Name,Opportunity__r.Account.Name,Opportunity__r.Account.Correspondence_Addr_Line1__c,Opportunity__r.Owner.LastName,Opportunity__r.Owner.FirstName,Opportunity__r.Opportunity_Owner__c,Opportunity__r.Owner.Phone,Opportunity__r.Owner.Email,Opportunity__r.Account.CIF__c from Concession__c where ((Opportunity__c =: ApexPages.currentPage().getParameters().get('id')) and ((Status__c = 'New' AND Sub_Status__c = 'Pricing Team Approved') )) ];
        }
        
     /*  List<Concession__c> allOpps = [Select name,Risk_Group_Number__c,Lending_Product_Type__c,Margin_Above_Prime__c,(SELECT Condition_Measure__c,Condition_Product__c,Deadline__c,Value__c FROM Conditions_of_Grant__r),Investment_Product_Type__c,Cash_Acquiring_Channel_Type__c,Interest_To_Client__c,Id,BOL_User_ID__c,Product_Account_Number__c,Maximum_Fee__c,Base_Rate__c,Ad_Valorem__c,Opportunity__c,Status__c,Sub_Status__c,Start_Date__c,End_Date__c,Merchant_Number__c,Transaction_Type__c,Commission_Rate__c,RecordType.DeveloperName,Opportunity__r.Account.Name,Opportunity__r.Opportunity_Owner__c from Concession__c where Opportunity__c =: ApexPages.currentPage().getParameters().get('id') ];*/
        
        //Parent Id set
        Set<id> parentIdSet = new Set<id>();
        //Create parent Id set 
        for(Concession__c OppertunityRec :allOpps){
            parentIdSet.add(OppertunityRec.Opportunity__c);
        }
        
        //Fetch all associated parents
        List<Opportunity> allAssocaiatedAccounts = [Select name,id from Opportunity where Id IN : parentIdSet];
        
        wrapperList = new list<myWrapperClass>();
        //For loop to set data
        for(Concession__c childRec : allOpps){
            //myWrapperClass wrapRec;
            for(Opportunity parentRec :allAssocaiatedAccounts){
                if(parentRec.Id == childRec.Opportunity__c){
                    myWrapperClass wrapRec = new myWrapperClass();
                    wrapRec.acc = parentRec;
                    wrapRec.opp = childRec;
                    
                    wrapRec.conditionofGrantlist=(wrapRec.opp.Conditions_of_Grant__r);
                    Accname=childRec.Opportunity__r.Account.Name;
                    wrapperList.add(wrapRec);
                    
                }
            }
             
            //Adding Opportunities without account
            if(childRec.Opportunity__c == null){
                    myWrapperClass wrapRec = new myWrapperClass();
                    //wrapRec.acc = null;
                    wrapRec.opp = childRec;
                    wrapperList.add(wrapRec);
            }
         
        } 
    }
    public List<myWrapperClass> selectedWrapperList {get; set;}
    public Set<Id> ConcessionIds{get; set;}
    public Map<Id,Concession__c> Rectype_Concession {get; set;}

    public PageReference ProceedWithSelected(){
        selectedWrapperList = new List<myWrapperClass>();
        
        ConcessionIds = new Set<Id>();
        normalList = false;
        selectedList = true;
       count=0;
        for(myWrapperClass selectedWrapObj: wrapperList){
            system.debug('selectedWrapObj.selected  ---------'+selectedWrapObj.selected);
            if(selectedWrapObj.selected == true) {
            count++;
            selectedWrapperList.add(selectedWrapObj);
            
                    system.debug('selectedWrapperList size ---------'+selectedWrapObj);
                    system.debug('selectedWrapperList size ---------'+selectedWrapObj);
        
        system.debug('ConcessionIds ---------'+ConcessionIds);
            //Rectype_Concession.put(selectedWrapObj.opp.RecordTypeId,selectedWrapObj.opp);
        ConcessionIds.add(selectedWrapObj.opp.RecordTypeId);
        Accname=selectedWrapObj.opp.Opportunity__r.Account.Name;
        Riskgroupnum=selectedWrapObj.opp.Risk_Group_Number__c;
        oppmanager=selectedWrapObj.opp.Concession_owner_s_manager__c;
        oppmanageremail=selectedWrapObj.opp.Concession_owner_s_manager_email__c;
        oppmanagerphone=selectedWrapObj.opp.Concession_owner_s_manager_phone__c;
        oppowner=selectedWrapObj.opp.Opportunity__r.Owner.FirstName + ' '+ selectedWrapObj.opp.Opportunity__r.Owner.LastName ;
        oppownerphone=selectedWrapObj.opp.Opportunity__r.Owner.Phone;
        oppowneremail=selectedWrapObj.opp.Opportunity__r.Owner.Email;
        Accaddress=selectedWrapObj.opp.Opportunity__r.Account.Correspondence_Addr_Line1__c;
        AccCIF=selectedWrapObj.opp.Opportunity__r.Account.CIF__c;


            }
        }
        system.debug('Record count---------'+count);

        system.debug('selectedWrapperList size ---------'+selectedWrapperList.size());
        system.debug('selectedWrapperList ---------'+selectedWrapperList);
        system.debug('ConcessionIds ---------'+ConcessionIds);

        PageReference pageRef = page.concessionletter_pdf;
        pageRef.setRedirect(false);
            return pageRef;
    
        
        
    }

//Wrapper list 
public List<myWrapperClass> wrapperList {get; set;}
//Your wrapper 
public class myWrapperClass{
    public Opportunity acc{get;set;}
    public Concession__c opp{get;set;}
    public Boolean selected {get; set;} 
    public List<Conditions_of_Grant__c> conditionofGrantlist {get; set;}
    public myWrapperClass() { 
         selected = false; 
         conditionofGrantlist = new list <Conditions_of_Grant__c>();
      } 
}

  
    
        public PageReference generateDoc() {
        PageReference doc = Page.concessionletter_pdf;
        doc.getParameters().put('id',ApexPages.currentPage().getParameters().get('id')); 
        doc.setRedirect(false);
        
        Blob b;
         concessionStatusUpdate();
        
        if (Test.isRunningTest()) {
            b = Blob.valueOf('UNIT.TEST');
        } else{
            //b = doc.getContent();
            b = doc.getContentAsPDF();
        }
 
        
        Attachment attachment = new Attachment();
        attachment.body = b;
        attachment.name = 'Concession.pdf';
        attachment.parentId = ApexPages.currentPage().getParameters().get('id');
        insert attachment;
        
        return new Pagereference('/'+ApexPages.currentPage().getParameters().get('id'));
    }
    // This particular method updates sub status to Letter Generated once pdf is generated
    public void concessionStatusUpdate(){
    List<Concession__c> selectedWrapperList = new List<Concession__c>();
        
        normalList = false;
        selectedList = true;
        for(myWrapperClass selectedWrapObj: wrapperList){
            system.debug('selectedWrapObj.selected  ---------'+selectedWrapObj.selected);
            if(selectedWrapObj.selected == true) {
            selectedWrapObj.opp.Sub_Status__c= 'Letter Generated';
            selectedWrapperList.add(selectedWrapObj.opp);
            }
        }
        if (selectedWrapperList.size()>0)
        {
          update selectedWrapperList;      
          }
    }
}