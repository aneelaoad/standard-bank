/*****************************************************************************************************\
@ Author        : Maham Hassan
@ Date          : Feb 2022 
@ Test File     : Account360_Vf_Ext_Test.cls
@ Description   : Migrated code base from pbbar Org, Extension class for Customer Plan

@ Last Modified By  : Mabhedle Tonga    
@ Last Modified On  : 2015-10-20
@ Modification Description :  Updated class to cater for custom fields and  objects

@ Last Modified By  : Mabhedle Tonga 
@ Last Modified On  : 2015-12-09
@ Modification Description : removed reference to team members  

@ Last Modified By  : Mabhedle Tonga 
@ Last Modified On  : 2017-04-19
@ Modification Description : Add UGX, EBITDA calculation and Risk related list

@ Last Modified By  : Tracy de Bruin 
@ Last Modified On  : 2017-05-05
@ Modification Description : Add check for null values for EBITDA and return 0.00
							 Remove Opportunities, Risk and Account Team

@ Last Modified By  : Maham Hassan    
@ Last Modified On  : 2022-02-16
@ Modification Description :  Added Best Practices, Added SOQL Return statements and 
							  SOQL for loops to use efficient chunking with calls
							  to the query and queryMore methods of the SOAP API.

******************************************************************************************************/
/**
 * 
 * @description Extenstion class for Account 360 and Account 360 PDF Visualforce Pages.
 */
public with sharing class Account360_Vf_Ext {
    private final Account acc;  
    public X360_Account_Overview__c[] x360Accounts = new X360_Account_Overview__c[1];
    
    public Id currentAccId;
    public Id currentUserId;

    public Set<Id> accountIdSet = new Set<Id>();
    
    //Helper classes
    public List<FinancialAccountSelection> financialAccountResults {get;set;}
    public List<CaseSelection> caseResults {get;set;}
    public List<TaskSelection> taskResults {get;set;}
    public List<OpportunitySelection> oppResults{get;set;}
    public List<AccountRelationshipSelection> accRelResults{get;set;}
    public List<AccountContactRelationshipSelection> accContactRelResults {get;set;}
    
    //List to return only seleted objetcs for PDF printing
    public List<Case> casePdfResults {get;set;}
    public List<Task> taskPdfResults {get;set;}
    public List<finserv__FinancialAccount__c> financialAccountPdfResults{get;set;}
    public List<Opportunity> oppPdfResults{get;set;}
    public List<FinServ__AccountAccountRelation__c> accRelPdfResults{get;set;}
    public List<CMN_Account_Contact_Relationship_Detail__c> accRelContactPdfResults {get;set;}
    
    public String userCurr{get;set;}
    public String userLang{get;set;}
    
    //Variables to keep track of and handle the amount of records selected per section
    public integer countOpp = 0;
    public integer countfinancialAccount = 0;
    public integer countCase = 0;
    public integer countTask = 0;
    public integer countAccRel = 0;
    public integer countAccContactRel = 0;
    
    /**
     * 
     * @description Controller for Account360_VF and Account360PDF_VF
     * @param controller 
     */
    public Account360_Vf_Ext(ApexPages.StandardController controller){
        List<String> fields = new List<String>();
        if(!Test.isRunningTest())
        {
            controller.addFields(fields);
        }
        this.acc = (Account)controller.getRecord();
        this.currentAccId = this.acc.Id;
        this.currentUserId = UserInfo.getUserId();
        
       
        this.x360Accounts = new SEL_X360_Customer_Plan().selectX360ByAccounts(this.currentAccId);
        
        if(x360Accounts.isEmpty()){
            X360_Account_Overview__c new360 = new X360_Account_Overview__c();
            new360.AccountId__c = currentAccId;
            new360.OwnerId = currentUserId;
            
            this.x360Accounts.add(new360);
        }
        accountIdSet.add(this.currentAccId);
        //get user info currency. Since API version > 22 the method getDefaultCurrency() will return the ISO code for both
        //enabled and non-enabled multi-currency organizations
        userCurr = UserInfo.getDefaultCurrency();
    }
  
    /**
     * 
     * @description Return list of all the opportunities using Opportunity Selection class which are related to selected Account
     * @return  Return list of Opportunity Helper class
     */
    public List<OpportunitySelection> getOpportunities() {

        if (oppResults == null) {
            oppResults = new List<OpportunitySelection>();
        } else {
            oppResults.clear();
        }

        Set<Id> selectedOppIds = new Set<Id>();
        
        if(x360Accounts[0].Opportunity_Selection__c != null){
            
            String[] oppIds = x360Accounts[0].Opportunity_Selection__c.split(',');
            
            for(Integer x=0;x<oppIds.size();x++){
                selectedOppIds.add(Id.valueOf(oppIds[x]));
            }
        }
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities = new SEL_Opportunities().selectByAccountIds(accountIdSet);
        
        for (Opportunity opp : opportunities) {
            OpportunitySelection os = new OpportunitySelection(opp);
            if (selectedOppIds.contains(opp.Id)) {
                os.checked = true;
                ++countOpp;
            } else {
                os.checked = false;
            }
            oppResults.add(os);
        }
        
        
        return oppResults;
    }

    /**
     * @description Returns list of Opportunities which are selected in Customer Plan
     * @return  List of Opportunities
     */
    public List<Opportunity> getSelectedOpportunities() {

        if (oppPdfResults == null) {
            oppPdfResults = new List<Opportunity>();
        } else {
            oppPdfResults.clear();
        }

        Set<Id> selectedOppIds = new Set<Id>();
        
        if(x360Accounts[0].Opportunity_Selection__c != null){
            
            String[] oppIds = x360Accounts[0].Opportunity_Selection__c.split(',');
            
            for(Integer x=0;x<oppIds.size();x++){
                selectedOppIds.add(Id.valueOf(oppIds[x]));
            }
        }
        oppPdfResults = new SEL_Opportunities().selectByIds(selectedOppIds);
            
        return oppPdfResults;
    }

    /**
     * @description Return list of all the Account-Account Relationships using AccountRelationshipSelection
     *              class which are related to selected Account
     * @return  Return list of Account-Account Relationships Helper class
     */
    public List<AccountRelationshipSelection> getAccountRelationships() {

        if (accRelResults == null) {
            accRelResults = new List<AccountRelationshipSelection>();
        } else {
            accRelResults.clear();
        }

        Set<Id> selectedAccAccIds = new Set<Id>();
        
        if(x360Accounts[0].Account_Relationship_Selection__c != null){
            
            String[] accIds = x360Accounts[0].Account_Relationship_Selection__c.split(',');
            
            for(Integer x=0;x<accIds.size();x++){
                selectedAccAccIds.add(Id.valueOf(accIds[x]));
            }
        }

        List<FinServ__AccountAccountRelation__c> accAccRelationships =  new List<FinServ__AccountAccountRelation__c>();
        accAccRelationships = new SEL_Finserv_AccountAccountRelation().selectByAccountIds(accountIdSet);
        
        for (FinServ__AccountAccountRelation__c acc : accAccRelationships) {
            AccountRelationshipSelection accRelSel = new AccountRelationshipSelection(acc);
            if (selectedAccAccIds.contains(acc.Id)) {
                accRelSel.checked = true;
                ++countAccRel;
            } else {
                accRelSel.checked = false;
            }
            accRelResults.add(accRelSel);
        }
        
        System.debug('Account-Account List: ' + accRelResults);
        return accRelResults;
    }

     /**
     * @description Returns list of Account-Account Relationships which are selected in Customer Plan
     * @return  List of Account-Account Relationships
     */
    public List<FinServ__AccountAccountRelation__c> getSelectedAccountRelationships() {

        if (accRelPdfResults == null) {
            accRelPdfResults = new List<FinServ__AccountAccountRelation__c>();
        } else {
            accRelPdfResults.clear();
        }

        Set<Id> selectedAccAccIds = new Set<Id>();
        
        if(x360Accounts[0].Account_Relationship_Selection__c != null){
            
            String[] accIds = x360Accounts[0].Account_Relationship_Selection__c.split(',');
            
            for(Integer x=0;x<accIds.size();x++){
                selectedAccAccIds.add(Id.valueOf(accIds[x]));
            }
        }
        accRelPdfResults = new SEL_Finserv_AccountAccountRelation().selectByIds(selectedAccAccIds);
        return accRelPdfResults;
    }

     /**
     * @description Return list of all the Account-Contact Relationships using AccountContactRelationshipSelection
     *              class which are related to selected Account
     * @return  Return list of Account-Contact Relationships Helper class
     */
    public List<AccountContactRelationshipSelection> getAccountContactRelationships() {

        if (accContactRelResults == null) {
            accContactRelResults = new List<AccountContactRelationshipSelection>();
        } else {
            accContactRelResults.clear();
        }

        Set<Id> selectedAccIds = new Set<Id>();
        
        if(x360Accounts[0].Account_Contact_Selection__c != null){
            
            String[] accIds = x360Accounts[0].Account_Contact_Selection__c.split(',');
            
            for(Integer x=0;x<accIds.size();x++){
                selectedAccIds.add(Id.valueOf(accIds[x]));
            }
        }

        List<CMN_Account_Contact_Relationship_Detail__c> accountContactRelationships = new List<CMN_Account_Contact_Relationship_Detail__c>();
        accountContactRelationships = new SEL_CMN_AccountContactRelationshipDetail().selectByAccountIds(accountIdSet);
        System.debug('Account Contact:  ' + accountContactRelationships);

        for (CMN_Account_Contact_Relationship_Detail__c acc : accountContactRelationships) {
            AccountContactRelationshipSelection accRelSel = new AccountContactRelationshipSelection(acc);
            if (selectedAccIds.contains(acc.Id)) {
                accRelSel.checked = true;
                ++countAccContactRel;
            } else {
                accRelSel.checked = false;
            }
            accContactRelResults.add(accRelSel);
        }
        
        
        return accContactRelResults;
    }

     /**
     * @description Returns list of Account-Contact Relationships which are selected in Customer Plan
     * @return  List of Account-Contact Relationships
     */
    public List<CMN_Account_Contact_Relationship_Detail__c> getSelectedAccountContactRelationships() {

        if (accRelContactPdfResults == null) {
            accRelContactPdfResults = new List<CMN_Account_Contact_Relationship_Detail__c>();
        } else {
            accRelContactPdfResults.clear();
        }

        Set<Id> selectedAccIds = new Set<Id>();
        
        if(x360Accounts[0].Account_Contact_Selection__c != null){
            
            String[] accIds = x360Accounts[0].Account_Contact_Selection__c.split(',');
            
            for(Integer x=0;x<accIds.size();x++){
                selectedAccIds.add(Id.valueOf(accIds[x]));
            }
        }
        accRelContactPdfResults = new SEL_CMN_AccountContactRelationshipDetail().selectByIds(selectedAccIds);
        return accRelContactPdfResults;
    }

    /**
     * @description Return list of all the Cases using CaseSelection
     *              class which are related to selected Account
     * @return  Return list of Cases Helper class
     */
    public List<CaseSelection> getCases(){
        
        
        if (caseResults == null) {
            caseResults = new List<CaseSelection>();
        }else {
            caseResults.clear();
        }
        
        Set<Id> selectedCaseIds = new Set<Id>();
        
        if(x360Accounts[0].Case_Selection__c != null){
            
            String[] caseIds = x360Accounts[0].Case_Selection__c.split(',');
            
            for(Integer x=0;x<caseIds.size();x++){
                selectedCaseIds.add(Id.valueOf(caseIds[x]));
            }
        }
        
        List<Case> cases = new List<Case>();
        cases = new SEL_Cases().selectCasesByAccountIds(accountIdSet);

        
        for (Case objCase: cases) {
            if (selectedCaseIds.contains(objCase.Id) && objCase.Status != 'Closed') {
                CaseSelection ca = new CaseSelection(objCase);
                ca.checked = true;
                ++countCase;        
                caseResults.add(ca);
            }
            if (!selectedCaseIds.contains(objCase.Id) && objCase.Status != 'Closed' && (objCase.AccountId == currentAccId || objCase.Account.ParentId == currentAccId)) {
                CaseSelection ca = new CaseSelection(objCase);
                ca.checked = false;
                caseResults.add(ca);
            }
        }

        return caseResults;
    }
 
    /**
     * @description Returns list of Cases which are selected in Customer Plan
     * @return  List of Cases
     */
     public List<Case> getSelectedCases(){
        
        if (casePdfResults == null) {
            casePdfResults = new List<Case>();
        }else {
            casePdfResults.clear();
        }
        
        Set<Id> selectedCaseIds = new Set<Id>();
        
        if(x360Accounts[0].Case_Selection__c != null){
            
            String[] caseIds = x360Accounts[0].Case_Selection__c.split(',');
            
            for(Integer x=0;x<caseIds.size();x++){
                selectedCaseIds.add(Id.valueOf(caseIds[x]));
            }
        }

        
        casePdfResults = new SEL_Cases().selectCasesByids(selectedCaseIds);
        
        return casePdfResults; 
    }

     /**
     * @description Return list of all the Financial Account using FinancialAccountSelection
     *              class which are related to selected Account
     * @return  Return list of Financial Account Helper class
     */
    public List<FinancialAccountSelection> getFinancialAccounts(){
        
        
        if (financialAccountResults == null) {
            financialAccountResults = new List<FinancialAccountSelection>();
        }else {
            financialAccountResults.clear();
        }
        
        Set<Id> selectedfinancialAccountIds = new Set<Id>();
        
        if(x360Accounts[0].Facility_Selection__c != null){
            
            String[] financialAccountIds = x360Accounts[0].Facility_Selection__c.split(',');
            
            for(Integer x=0;x<financialAccountIds.size();x++){
                selectedfinancialAccountIds.add(Id.valueOf(financialAccountIds[x]));
            }
        }

        List<finserv__FinancialAccount__c> financialAccounts = new List<finserv__FinancialAccount__c>();
        financialAccounts = new SEL_Finserv_FinancialAccount().selectByAccountIds(accountIdSet);

        for(finserv__FinancialAccount__c financialAccount:  financialAccounts) {
            FinancialAccountSelection ca = new FinancialAccountSelection(financialAccount);
            if (selectedfinancialAccountIds.contains(financialAccount.Id)) {
                ca.checked = true;
                ++countFinancialAccount;            
            } else {
                ca.checked = false;
            }
            financialAccountResults.add(ca);
        }
        return financialAccountResults;
    }

    /**
     * @description Returns list of Financial Accounts which are selected in Customer Plan
     * @return  List of Financial Accounts
     */
    public List<finserv__FinancialAccount__c> getSelectedFinancialAccount(){
        
        if (financialAccountPdfResults == null) {
            financialAccountPdfResults = new List<finserv__FinancialAccount__c>();
        }else {
            financialAccountPdfResults.clear();
        }
        
        Set<Id> selectedfinancialAccountIds = new Set<Id>();
        
        if(x360Accounts[0].Facility_Selection__c != null){
            
            String[] financialAccountIds = x360Accounts[0].Facility_Selection__c.split(',');
            
            for(Integer x=0;x<financialAccountIds.size();x++){
                selectedfinancialAccountIds.add(Id.valueOf(financialAccountIds[x]));
            }
        }
        
        financialAccountPdfResults = new SEL_Finserv_FinancialAccount().selectByIds(selectedfinancialAccountIds);
        return financialAccountPdfResults; 
    }
    
    /**
     * @description Return list of all the tasks using TaskSelection
     *              class which are related to selected Account
     * @return  Return list of tasks Account Helper class
     */
    public List<TaskSelection> getTasks(){
        
        if (taskResults == null) {
            taskResults = new List<TaskSelection>();
        }else {
            taskResults.clear();
        }
        
        Set<Id> selectedTaskIds = new Set<Id>();
        
        if(x360Accounts[0].Task_Selection__c != null){
            
            String[] taskIds = x360Accounts[0].Task_Selection__c.split(',');
            
            for(Integer x=0;x<taskIds.size();x++){
                selectedTaskIds.add(Id.valueOf(taskIds[x]));
            }
        }


        List<Task> tasks = new SEL_Tasks().selectByAccountIds(accountIdSet);
        
        for (Task task: tasks) {
            TaskSelection tsk = new TaskSelection(task);
            if (task.IsClosed == false) {
                if (selectedTaskIds.contains(task.Id)) {
                    tsk.checked = true;
                    ++countTask;  
                } else {
                    tsk.checked = false;
                }
                taskResults.add(tsk);
            }
        }
        return taskResults;
        
    }
    
    /**
     * @description Returns list of Tasks which are selected in Customer Plan
     * @return  List of tasks
     */
    public List<Task> getSelectedTasks(){
        
        if (taskPdfResults == null) {
            taskPdfResults = new List<Task>();
        }else {
            taskPdfResults.clear();
        }
        
        Set<Id> selectedTaskIds = new Set<Id>();
        
        if(x360Accounts[0].Task_Selection__c != null){
            
            String[] taskIds = x360Accounts[0].Task_Selection__c.split(',');
            
            for(Integer x=0;x<taskIds.size();x++){
                selectedTaskIds.add(Id.valueOf(taskIds[x]));
            }
        }
        
        taskPdfResults = new SEL_Tasks().selectByIds(selectedTaskIds);
        return taskPdfResults;
    }
    
    /**
     * 
     * @description Returns the count of selected Tasks
     * @return  Returns the count of selected Tasks
     */
    public Integer getCountTask(){
        return countTask;
    }

    /**
     * 
     * @description Returns the count of selected Financial Accounts
     * @return  Returns the count of selected Financial Accounts
     */
    public Integer getCountFinancialAccount()
    {
        return countfinancialAccount;
    }

    /**
     * 
     * @description Returns the count of selected Opportunities
     * @return  Returns the count of selected Opportunities
     */
    public Integer getCountOpp(){
        return countOpp;
    }
    /**
     * 
     * @description Returns the count of selected Cases
     * @return  Returns the count of selected Cases
     */
    public Integer getCountCase(){
        return countCase;
    }
    /**
     * 
     * @description Returns the count of selected Account-Account Relationships 
     * @return  Returns the count of selected Account-Account Relationships
     */
    public Integer getCountAccRel(){
        return countAccRel;
    }
    /**
     * 
     * @description Returns the count of selected Account-Contact Relationships 
     * @return  Returns the count of selected Account-Contact Relationships
     */
    public Integer getCountAccContactRel(){
        return countAccContactRel;
    }
    
    /**
     * @description Save Customer Plan on X360_Account_Overview__c 
     * @return PageReference of the Account 360 page.
     */
    public PageReference save360() { 
        saveTaskSelections();
        saveCaseSelection();
        saveFinancialAccountSelections();
        saveOpportunitySelections();
        saveAccountRelSelections();
        saveAccountContactRelSelections();
        
        try{
            this.x360Accounts[0].Name = this.acc.Name + '-' + (this.x360Accounts[0].CreatedDate != null ? this.x360Accounts[0].CreatedDate.format() : System.today().format());
            upsert x360Accounts Id;
            
        }catch(System.DMLException ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
        }     
        
        
        PageReference p = ApexPages.currentPage();
        p.setRedirect(true);
        return p;
    }
    
    /**
     * @description This method to save all the financial accounts on the X360_Account_Overview__c
     */
    private void saveFinancialAccountSelections() {

        if (financialAccountResults != null)  {
            String financialAccIdSelected = '';
        
            for (FinancialAccountSelection finAcc : financialAccountResults){
                if (finAcc.checked){
                    financialAccIdSelected = financialAccIdSelected + ',' + finAcc.finAcc.Id;
                }  
            }
            
            if(financialAccIdSelected.startsWith(',')){
                financialAccIdSelected = financialAccIdSelected.substring(1,financialAccIdSelected.length());
            }
            
            x360Accounts[0].Facility_Selection__c = financialAccIdSelected;      
        }
    }

    /**
     * @description This method to save all the opportunities on the X360_Account_Overview__c
     */
    private void saveOpportunitySelections() {
        
        if (oppResults != null) {
            String opportunityIdSelected = '';
        
            for (OpportunitySelection opp : oppResults){
                if (opp.checked){
                    opportunityIdSelected = opportunityIdSelected + ',' + opp.opp.Id;
                }  
            }
            
            if(OpportunityIdSelected.startsWith(',')){
                opportunityIdSelected = opportunityIdSelected.substring(1,opportunityIdSelected.length());
            }
            
            x360Accounts[0].Opportunity_Selection__c = opportunityIdSelected; 
        }

    }

    /**
     * @description This method to save all the Account-Account relationships on the X360_Account_Overview__c
     */
    private void saveAccountRelSelections() {
        
        if (accRelResults != null) {
            String accountRelIdSelected = '';
        
            for (AccountRelationshipSelection accRel : accRelResults){
                if (accRel.checked){
                    System.debug('Account-Account Relation: '  + accRel);
                    accountRelIdSelected = accountRelIdSelected + ',' + accRel.acc.Id;
                }  
            }
            
            if(accountRelIdSelected.startsWith(',')){
                accountRelIdSelected = accountRelIdSelected.substring(1,accountRelIdSelected.length());
            }
            
            x360Accounts[0].Account_Relationship_Selection__c = accountRelIdSelected;
        }        
    }

    /** 
     * @description This method to save all the Account-Contact relationships on the X360_Account_Overview__c
     */
    private void saveAccountContactRelSelections() {

        if (accContactRelResults != null) {
            String accountRelIdSelected = '';
        
            for (AccountContactRelationshipSelection accRel : accContactRelResults){
                if (accRel.checked){
                    accountRelIdSelected = accountRelIdSelected + ',' + accRel.acc.Id;
                }  
            }
            
            if(accountRelIdSelected.startsWith(',')){
                accountRelIdSelected = accountRelIdSelected.substring(1,accountRelIdSelected.length());
            }
            
            x360Accounts[0].Account_Contact_Selection__c = accountRelIdSelected;
        }        
    }
    
    /**
     *  @description This method to save all the cases on the X360_Account_Overview__c
     */
    private void saveCaseSelection(){
        
        if (caseResults != null) {
            String caseIdSelected = '';
        
            for (CaseSelection c : caseResults){
                if (c.checked){
                    caseIdSelected = caseIdSelected + ',' + c.ca.Id;
                }  
            }
            
            if(caseIdSelected.startsWith(',')){
                caseIdSelected = caseIdSelected.substring(1,caseIdSelected.length());
            }
            
            x360Accounts[0].Case_Selection__c = caseIdSelected;    
        }
    }

    /**
     *  @description This method to save all the tasks on the X360_Account_Overview__c
    */
    private void saveTaskSelections() {
        
        if (taskResults != null) {
            String taskIdSelected = '';
        
            for (TaskSelection t : taskResults){
                if (t.checked){
                    taskIdSelected = taskIdSelected + ',' + t.tsk.Id;
                }  
            }
            
            if(taskIdSelected.startsWith(',')){
                taskIdSelected = taskIdSelected.substring(1,taskIdSelected.length());
            }
            
            x360Accounts[0].Task_Selection__c = taskIdSelected;    
        }
    }
    
    /**
     * @description Creating a pdf attachment for Customer Plan and saving it as attachment record. 
     */
    public void attach360PDF(){
        
        //Render PDF and attched to CAM object.
        Blob pdfBlob;
        PageReference pdfpage = Page.Account360PDF_Vf;
        
        if(Test.isRunningTest()){
            pdfBlob = Blob.valueOf('TEST BLOB');
        }else{
            pdfBlob = pdfpage.getContent();
        }
        
        //get all attachments for this 360 object
        List<Attachment> atList = new List<Attachment>();
        atList = [Select Name from Attachment Where parentId =: x360Accounts[0].Id order by CreatedDate asc];
        
        String vnum = '1';
        String x360Attname;
        
        for(Attachment att : atList){
            String attname = att.Name;
            //only get 360 overview PDF attachments, ignore any other attachment
            if((attname.contains('~360VIEW-')) && (attname.endsWith('.pdf'))){    
                x360Attname = att.Name;
            }
        }
        
        //This should be the most resent 360 attachment and we need to increment the version number by 1
        //If 'pdfattname' = null then there are no 360 attachments and the version number will be 1
        if(x360Attname != null){
            String[] currVer = x360Attname.split('~');
            Integer x = Integer.valueOf(currVer[1]);
            x = ++x;
            vnum = String.valueOf(x);
        }
        
        //Add new attachment to the CAM object
        Attachment a = new Attachment(parentId = x360Accounts[0].AccountId__c, name = 'Ver~' + vnum + '~360VIEW-' + currentAccId + '-' + System.Today() + '.pdf', body = pdfBlob);
        
        try{
            insert a;  
        }catch(DMLException ex){
            System.debug(LoggingLevel.ERROR, ex.getMessage());
        }
    }
    
    /**
     * @description Helper Class for Cases
     */
    public class CaseSelection {
        
        public Boolean checked{ get; set; }
        public Case ca { get; set; }
        
        /**
         * 
         * @description Constructor for storing List of Case with new Case record
         */
        public CaseSelection(){
            ca = new Case();
            checked = false;
        }

        /**
         * 
         * @description Constructor for storing List of Case with Case record
         * @param c Case record
         */
        public CaseSelection(Case c){
            ca = c;
            checked = false;
        }   
    }
    
    /**
     * @description Helper Class for Tasks
     */
    public class TaskSelection {
        
        public Boolean checked{ get; set;}
        public Task tsk { get; set; }
        
        /**
         * 
         * @description Constructor for storing List of Task with new Task record
         */
        public TaskSelection(){
            tsk = new Task();
            checked = false;
        }

        /**
         * 
         * @description Constructor for storing List of Financial Account with Financial Account record
         * @param task task record
         */
        public TaskSelection(Task task){
            tsk = task;
            checked = false;
        }
    } 
    
    /**
     * @description Helper Class for Financial Accounts
     */
    public class FinancialAccountSelection {
        
        public Boolean checked{ get; set;}
        public finserv__FinancialAccount__c finAcc { get; set; }
        
        /**
         * 
         * @description Constructor for storing List of Financial Account with new Financial Account record
         */
        public FinancialAccountSelection(){
            finAcc = new finserv__FinancialAccount__c();
            checked = false;
        }

        /**
         * 
         * @description Constructor for storing List of Financial Account with the Financial Account record
         * @param finAccount 
         */
        public FinancialAccountSelection(finserv__FinancialAccount__c finAccount){
            finAcc = finAccount;
            checked = false;
        }
    } 
    
    /**
     * 
     * @description Helper Class for Opportunities
     */
    public class OpportunitySelection {
        
        public Boolean checked {get; set;}
        public Opportunity opp {get; set;}

        /**
         * 
         * @description Constructor for storing List of Opportunities with new Opportunity
         */
        public OpportunitySelection(){
            opp = new Opportunity();
            checked = false;
        }
         /**
         * 
         * @description Constructor for storing List of Opportunities with the Opportunity record
         * @param opportunity Opportunity record
         */
        public OpportunitySelection(Opportunity opportunity){
            opp = opportunity;
            checked = false;
        } 

    }

    /**
     *  
     * @description Helper Class for Account-Account Relationships
     */
    public class AccountRelationshipSelection {
     
        public Boolean checked {get; set;}
        public FinServ__AccountAccountRelation__c acc {get; set;}

        /**
         * 
         * @description Constructor for storing List of Account-Account Relationships with new Account-Account Relationship
         */
        public AccountRelationshipSelection(){
            acc = new FinServ__AccountAccountRelation__c();
            checked = false;
        }
         /**
         * 
         * @description Constructor for storing List of Account-Account Relationships with Account-Account Relationship
         * @param accAccRel Account-Account Relationship record
         */
        public AccountRelationshipSelection(FinServ__AccountAccountRelation__c accAccRel){
            acc = accAccRel;
            checked = false;
        } 
    }

    /**
     * 
     * @description Helper Class for Account-Contact Relationships
     */
    public class AccountContactRelationshipSelection {

        public Boolean checked {get; set;}
        public CMN_Account_Contact_Relationship_Detail__c acc {get; set;}

        /**
         * 
         * @description Constructor for storing List of Account-Contact Relationships with new Account-Contact Relationship
         */
        public AccountContactRelationshipSelection(){
            acc = new CMN_Account_Contact_Relationship_Detail__c();
            checked = false;
        }
        /**
         * 
         * @description Constructor for storing List of Account-Contact Relationships with Account-Contact Relationship
         * @param accCon CMN Account-Contact Relationship record
         */
        public AccountContactRelationshipSelection(CMN_Account_Contact_Relationship_Detail__c accCon){
            acc = accCon;
            checked = false;
        } 
    }

}