/*****************************************************************************************************\
    @ Func Area     : Addition, Deletion of Members Hosts
    @ Author        : Rudolf Niehaus
    @ Date          : 11/2011
    @ Test File     : Test Method TestCampaignHostController.cls
    @ Description   : Case#1168
                      Controller class for the Visualforce pages CampaignHostAssigner.page. The page is used to
                      add and remove hosts from campaign members
                      
    @ Last Modified By  : Wayne Gray
    @ Last Modified On  : June 2012
    @ Last Modified Reason  :  Case #6521- Change contact to use TestFatcory    
                               API Version moved from 24 to 25           

    @ Last Modified By  : Charles Mutsu
    @ Last Modified On  : Jan 2013
    @ Last Modified Reason  :  Refactoring, avoid using dummy id for querying a list of members   
                               API Version moved from 25 to 27 
                               
    @ Last Modified By  : Nitish Kumar
    @ Last Modified On  : 24 Jan 2013
    @ Last Modified Reason  :  EN 15 and 17 :-
                               Adding Sorting functionality , pagination functionality , showing user friendly messages
                               on CampaignHostAssignerPage.
                               API version moved from 25 to 27.        
                               
    @ Last Modified By  : Tracy Roberts
    @ Last Modified On  : 22 April 2013
    @ Last Modified Reason  :  Case#785 (Campaign error message when adding a host)
                               Add error messages to check for "Remove Member(s) with no Members", "Add Host(s) with no Members",
                               "Remove Host(s) with no Members", "Remove Selected Host(s) with no Host selected", 
                               "Add Selected Host(s) when no host is selected". 
                               Error messages are located in the Error message custom setting under enviromental variables.                                                
******************************************************************************************************/ 

public class CampaignHostsController {
      
    
    private List<ContactWrapper> searchResults {get;set;}
    public List<CampaigHostsWrapper> removeResults {get;set;}
    public String memIds='';
    public String campId {get;set;}
    public Campaign campaign {get;set;}
    public String campName {get;set;}
    public List<String> members = new List<String>();
    public String nrSelectedMembers {get;set;}
    public String noMembersSelected {get;set;}
    public String  hostsAdded {get;set;}
    public Boolean styleSwapA {get; set;}
    public Boolean styleSwapB {get; set;}
    public Boolean styleSwapC {get; set;}
    public Boolean memberNotChecked {get; set;}
    public Boolean memberAvailable {get; set;}
    public Boolean memberChecked {get; set;}
    public Boolean noHosts {get; set;}
    private String SupportEmailAddress = '';
    private Environment_Variable__c settings = null;
   
    
    //Variables Created for Sorting and Pagination functionality
    
     // Map which stores id as Key and Value as wrapper object of Contact
     public  map<Id, ContactWrapper> mapForPagination = new map<Id, ContactWrapper>();
      
     public Integer iTotalRecordCount {get;set;} // Variable to get the total count of record
     public Transient list<Contact> totalresults {get; set ;} // Variable to get the total count of record
     private  list<Contact> lstFilteredSearchResults {get; set ;}
     public Integer pageSize {get;set;} // Number of Records any page has
     private Integer noOfPages {get;set;} // Variable to count No of pages
     public Integer pageNumber {get;set;} // Variable showing Page Number
     public String qry {get;set;} // String Query to hold variable 
     public String userPageInfo {get;set;}
    
     //Variable for showing error message
     public String blankSearch {get;set;} 
     public Boolean isblankSearchTrue {get; set;}
     public String noSearchResults {get;set;}
     public Boolean isnoSearchResultsTrue {get; set;}
     public String noHostsSelected {get;set;}
     public Boolean isnoHostsSelectedTrue {get; set;} 
     
    
    //Variables for sorting functionality  
     private String sortDirection = 'ASC';
     private String sortExp = 'name';
   
    
    //Class constructor
    public CampaignHostsController(){
        memIds = ApexPages.currentPage().getParameters().get(CampaignMemberHostController.PARAM_NAME_MEMBERS_IDS);
        System.debug('Selected Member Ids = ' + memIds);
        campId = ApexPages.currentPage().getParameters().get('campid');
        System.debug('Current Campaign Id = ' + campId);
        campaign = [Select id, Name From Campaign Where Id =: campId];
       // campName = [Select Name From Campaign Where Id =: campId].Name;
         campName     = campaign.Name ;
        
        //Setting the boolean variables to false
        memberChecked = false;
        memberAvailable = false;
        
        //Check if any members was selected on the previous page
        if(memIds.length() > 0){
            //Adding hosts from the std campaign member page, else it was from the VF page CampaignHostAssigner 
            if(memIds.contains('-memberpage')){
                String[] contactID = memIds.split('-');
                String memberHostId = [Select Id From Campaign_Member_Host__c Where Member__c =: contactID[0] AND Campaign__c =: campId limit 1].Id;
                members.add(memberHostId);
                memberNotChecked = false;
            }else{
                members = memIds.split('-');
                memberNotChecked = false;
              }
            
            nrSelectedMembers = String.valueOf(members.size());
            nrSelectedMembers = nrSelectedMembers + ' Member(s) Selected';
            styleSwapA = true;
            styleSwapB = false;
            styleSwapC = false;
            isblankSearchTrue = false;
            isnoSearchResultsTrue = false;
            isnoHostsSelectedTrue = false ;
            
        }else{
            memberNotChecked = true;
            noMembersSelected = '0 Members Selected';
            styleSwapC = true;
            styleSwapA = false;
            styleSwapB = false;
            isblankSearchTrue = false;
            isnoSearchResultsTrue = false;
            isnoHostsSelectedTrue = false ;
            
        }
        
        //Get CRM Production support email address from custom settings in order to email
        //error messages
        this.settings = Environment_Variable__c.getInstance();
        this.SupportEmailAddress = settings.CRM_Production_Support__c;
        
    }
    
    //String method whicj sets the default value of the Input text box as 'Contact Name' when user comes to this page
    public string searchText {
        get {
            if (searchText == null) searchText = 'Contact Name';
            return searchText;
        }
        set;
     }
     
     
     // Method to set the apex controller  
     public ApexPages.StandardSetController con { 
        get {           
            return con;            
            }  
          set;    
        }
    
        
    //Search for hosts (Bank contacts)
    public PageReference search() {
        
        //Clear the map if its not null
        if(mapForPagination != null)
            mapForPagination.clear();
 
        if (searchResults == null) {
            searchResults = new List<ContactWrapper>();
         }  else {
            searchResults.clear();
         }
        
         if(searchText == null || searchText == ''){
            blankSearch = ErrorMessages__c.getValues('Blank_Search').Error_String__c ;
            memberAvailable = false;
            isblankSearchTrue = true;
            isnoSearchResultsTrue = false;
            isnoHostsSelectedTrue = false ;
            styleSwapB = false;
            styleSwapA = false;
            styleSwapC = false;
            return null;
        }
        
        else{
        String contactRecordType = 'SA_Bank_Contact_Record_Type';
        
        qry = 'Select c.Name, c.Id, c.Email,c.Account.Name,c.Title, c.User_Division_Sync__c ,c.User_Business_Unit_Sync__c From Contact c Where  ';
        
        // Append filter criteria
         qry = qry + '(c.Name LIKE \'%' + searchText + '%\') AND c.Inactive__c = FALSE AND c.RecordType.DeveloperName = \'' + contactRecordType + '\' ';
         
        //Initializing the Variables
           iTotalRecordCount = null;
           totalresults      = null;
           pageSize          = 100 ;
       
       totalResults = new List<Contact>();
       
       totalResults = Database.query(qry + ' Limit 1000' );
       
       //Getting Count of total records of Contact
        iTotalRecordCount = totalResults.size();
       
        pageNumber = 0; // Setting the Page Number of first page
        noOfPages = iTotalRecordCount/pageSize; // Counting total number of pages
        
        // Increasing the Number of pages by 1 if the total records leave a remainder after division from pagesize 
          if (Math.mod(iTotalRecordCount, pageSize) > 0)
             noOfPages++;
             
          lstFilteredSearchResults = new list<Contact>();
          
          lstFilteredSearchResults = Database.query(qry + ' Order By c.Name Limit '  + pageSize);
        
        for(Contact c : lstFilteredSearchResults ){
            
           mapForPagination.put(c.id,new ContactWrapper(c));
           memberAvailable = true;
          } 
          
          if(iTotalRecordCount == 0)
           memberAvailable = false;
           
           con = new ApexPages.StandardSetController(lstFilteredSearchResults);
             
           con.setPageSize(pageSize); 
    
            userPageInfo =  String.valueOf(pageNumber + 1) + '-' + String.valueOf(pageSize*(pageNumber + 1)) + ' of ' + iTotalRecordCount;
          
        
            if(memberAvailable == false){
                noSearchResults = ErrorMessages__c.getValues('Search_Results_Not_Found').Error_String__c ;
                isnoSearchResultsTrue = true ;
                isblankSearchTrue = false;
                isnoHostsSelectedTrue = false;
                styleSwapB = false;
                styleSwapA = false;
                styleSwapC = false;
                return null;
            }
            
            else{
                isblankSearchTrue = false;
                isnoSearchResultsTrue = false;
                isnoHostsSelectedTrue = false ;
                styleSwapB = false;
                styleSwapA = true;
                styleSwapC = false;
            }
        
           return null;
       }
    }   
    
    
        /**
         * @author Nitish Kumar
         * @date 24/01/2013
         * @description Method created which sorts the table 
         */   
       public void Load()
            {
              //Clear the map if its not null
              if(mapForPagination != null)
               mapForPagination.clear();
            
             // Clearing the list 
             lstFilteredSearchResults.clear();
            
             //Setting the Offset according to the Page number and Page size
             Integer offset = pageNumber * pageSize;
             
              //build the full sort expression
               String sortFullExp = sortExpression  + ' ' + sortDirection;
                
             // Query with the limit and Offset set accoding to Page Number and Offset
                try{
                    lstFilteredSearchResults = Database.query(qry + 'Order By ' + sortFullExp +' Limit ' + pageSize + ' Offset ' + offset);
                    
                  }
                catch(Exception e){
                    ApexPages.addMessages(e);
                 } 
                
                //Populating the Map
               for(Contact c : lstFilteredSearchResults) {
                mapForPagination.put(c.id,new ContactWrapper(c));
                }
                
              userPageInfo =  String.valueOf((pageNumber*(pageSize*1))+ 1) + '-' + String.valueOf(pageSize*(pageNumber + 1)) + ' of ' + iTotalRecordCount;
                
              con = new ApexPages.StandardSetController(lstFilteredSearchResults);
              con.setPageSize(pageSize);
              
            }
    
    /**
     * @author Nitish Kumar
     * @date 27/07/2012
     * @description Query the records with the limit of page limit according to offset set
     */   
       private void queryContact()
            {
                
            if(mapForPagination != null)
               mapForPagination.clear();
            
             // Clearing the list 
             lstFilteredSearchResults.clear();
            
             //Setting the Offset according to the Page number and Page size
             Integer offset = pageNumber * pageSize;
             
              //build the full sort expression

                System.debug('&&&&&&&&&&&&' + qry + ' Order By c.Name ASC Limit ' + pageSize + ' Offset ' + offset);
             // Query with the limit and Offset set accoding to Page Number and Offset
                try{
                    lstFilteredSearchResults = Database.query(qry + 'Order By c.Name Limit ' + pageSize + ' Offset ' + offset);
                    
                  }
                catch(Exception e){
                    ApexPages.addMessages(e);
                } 
                
                //Populating the Map
               for(Contact c : lstFilteredSearchResults) {
                mapForPagination.put(c.id,new ContactWrapper(c));
                }
                
               userPageInfo =  String.valueOf((pageNumber*(pageSize*1))+ 1) + '-' + String.valueOf(pageSize*(pageNumber + 1)) + ' of ' + iTotalRecordCount;
                
              con = new ApexPages.StandardSetController(lstFilteredSearchResults);
              con.setPageSize(pageSize);
        }
    
    
    public List<ContactWrapper> getsearchResults()
    {   
        
        //lstPaginatedResults.clear();
        List<ContactWrapper> lstPaginatedResults = new List<ContactWrapper>();
        if(con != null && (con.getRecords()).size() > 0) {
            for(sObject p : con.getRecords())
                lstPaginatedResults.add(mapForPagination.get(p.id));
            return lstPaginatedResults;
        }
        else
            return null; 
    }
    
        //SORTING CLASSES
        public String sortExpression{
         get
         {
            return sortExp;
         }
         set
         {
           //if the column is clicked on then switch between Ascending and Descending modes
           if (value == sortExp)
             sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
           else
             sortDirection = 'ASC';
           sortExp = value;
         }
       }
    
     
         public String getSortDirection(){
            //if not column is selected 
            if (sortExpression == null || sortExpression == '')
              return 'ASC';
            else
             return sortDirection;
         }
        
         public void setSortDirection(String value){  
           sortDirection = value;
         }           
        
      
    //Add hosts to the selected campaign members
    public PageReference addHost(){


        List<Campaign_Member_Host__c> memberList = [Select Id From Campaign_Member_Host__c Where Id IN : members];
        List<Campaign_Hosts__c> hostList = new List<Campaign_Hosts__c>();
        
        for (ContactWrapper cw : mapForPagination.values()){
            
            if (cw.checked){
                for(Integer x=0;x<memberList.size();x++){
                    Campaign_Hosts__c h = new Campaign_Hosts__c();
                    h.Bank_Contact__c = cw.con.Id;
                    h.Host_Id__c = memberList[x].Id + '' + cw.con.Id;
                    h.Campaign_Member_Host__c = memberList[x].Id;
                    memberChecked = true;
                    hostList.add(h);    
               }
            }
               cw.checked = false; 
        }
        
        if (!memberChecked){
            noHostsSelected = ErrorMessages__c.getValues('Select_Host').Error_String__c ;
            isnoHostsSelectedTrue = true ;
            isnoSearchResultsTrue = false ;
            isblankSearchTrue = false;
            styleSwapB = false;
            styleSwapA = false;
            styleSwapC = false;
        }
        
        else{
          try{
            upsert hostList Host_Id__c;
            hostsAdded = 'Host(s) added successfully';
            styleSwapB = true;
            styleSwapA = false;
            styleSwapC = false;
            isblankSearchTrue = false;
            isnoSearchResultsTrue = false;
            isnoHostsSelectedTrue = false;
            memberChecked = false;
            
        }catch(System.DMLException ex){
            System.debug('Add Host to selected memeber Exception ' + ex.getMessage());
          }
        } 
        return null;
    } 
    
    //Delete hosts from the selected campaign members
    public PageReference removeHost(){

        Set<Id> hostID = new Set<Id>();

        for (CampaigHostsWrapper ch : removeResults){
            
            if (ch.checked){
                hostID.add(ch.host.Bank_Contact__c);
            }
            
            ch.checked = false; 
        }
            
        List<Campaign_Hosts__c> hostList = [Select Id From Campaign_Hosts__c Where Bank_Contact__c IN : hostID AND Campaign_Member_Host__c IN : members];
        
        if(hostList.size() > 0){
            try{
                Database.DeleteResult[] sr = Database.delete(hostList, false);
                hostsAdded = 'Host(s) removed successfully';
                styleSwapB = true;
                styleSwapA = false;
                styleSwapC = false;
                isnoHostsSelectedTrue = false ;
                isnoSearchResultsTrue = false ;
                
            }catch(System.DMLException ex){
                System.debug('Remove Host from selected memeber Exception ' + ex.getMessage());
                sendErrorMail('Remove Host from selected memeber Exception : CampaignHostsController.cls : removeHost()' + ex.getMessage());
            }
        }
        
        else{
            noHostsSelected = ErrorMessages__c.getValues('Select_Host').Error_String__c ;
            isnoHostsSelectedTrue = true ;
            isnoSearchResultsTrue = false ;
            styleSwapB = false;
            styleSwapA = false;
            styleSwapC = false;
        }

        return null;
    } 
    
    //Search filter text
    public string filterText {
        get {
            if (filterText == null) filterText = '';
            return filterText;
        }
        set;
    }
    
    //The method shows all the current hosts for all seletced members to give the user the ability to select which hosts he wants to remove from
    //all selected memebers
    public PageReference showRemovableHosts() {
 
        if (removeResults == null) {
            removeResults = new List<CampaigHostsWrapper>();
        } else {
            removeResults.clear();
        }
        
        if(filterText.equals('')){
            filterText = '%%';   
        }else{
            filterText = '%' + filterText + '%';
        }
        
        if(members.size() > 0){
            //members.add('a08P0000001DUMMYID');
        

        List<Campaign_Hosts__c> allhosts = [Select c.Id, c.Campaign_Member_Host__c, c.Bank_Contact__r.User_Division_Sync__c, 
                                            c.Bank_Contact__r.User_Business_Unit_Sync__c, c.Bank_Contact__r.Title, c.Bank_Contact__r.Email, 
                                            c.Bank_Contact__r.Name, c.Bank_Contact__c 
                                            From Campaign_Hosts__c c 
                                            Where c.Campaign_Member_Host__c IN : members AND c.Bank_Contact__r.Name LIKE : filterText order by Bank_Contact__r.Name asc];
        
        Id check;
        
        if(allhosts.size() > 0){
          isblankSearchTrue = false;
          isnoSearchResultsTrue = false;
          isnoHostsSelectedTrue = false ;
          memberAvailable = true;
          styleSwapB = false;
          styleSwapA = true;
          styleSwapC = false;
        }
        
        else{
            noSearchResults = ErrorMessages__c.getValues('Search_Results_Not_Found').Error_String__c ;
            isnoSearchResultsTrue = true ;
            isblankSearchTrue = false;
            isnoHostsSelectedTrue = false;
            memberAvailable = false;
            styleSwapB = false;
            styleSwapA = false;
            styleSwapC = false;
        }
        
        for(Campaign_Hosts__c h : allhosts){
            
            if(check != h.Bank_Contact__c){
                CampaigHostsWrapper ch = new CampaigHostsWrapper(h);
               
                removeResults.add(ch);
            }
            check = h.Bank_Contact__c;
        }
        }
        
        if(removeResults.size() > 0){
            noHosts = false;
        }else{
            noHosts = true;
        }
        
        filterText = '';
        
        return null;
    }   
    
    public PageReference getSelectedMembers(){
        return null;
    }
    
    //Done page
    public PageReference Done() {
        Pagereference managePage = Page.CampaignMemberHostManager;
        managePage.getParameters().put('campId',campId);
        return managePage;
    }
    
     //CampaignPage
    public PageReference returnToCampaign() {
        PageReference camPage = new ApexPages.StandardController(campaign).view();
        camPage.setRedirect(true);
        return camPage;
    }
    
    
       /**
         * @author Nitish Kumar
         * @date 24/01/2013
         * @description indicates whether there are more records after the current page set.
         */   
        public Boolean isFirst {
            get {
               if (pageNumber == 0)
                   return true;
                   else
                   return false;
            }
            set;
        }
        
        
        /**
         * @author Nitish Kumar
         * @date  24/01/2013
         * @description indicates whether there are more records after the last page.
         */   
        public Boolean isLast {
            get {
               if (pageNumber == noOfPages)
                   return true;
                   else
                   return false;
            }
            set;
        }
    
        /**
         * @author Nitish Kumar
         * @date  24/01/2013
         * @description indicates whether there are more records after the current page set.
         */   
        public Boolean hasNext {
            get {
               if (pageNumber < (noOfPages-1))
                   return true;
                   else
                   return false;
            }
            set;
        }
     
     
        /**
         * @author Nitish Kumar
         * @date  24/01/2013
         * @description indicates whether there are more records before the current page set.
         */ 
        public Boolean hasPrevious {
            get {
                if (pageNumber > 0)
                   return true;
                   else
                   return false;
            }
            set;
        }
     
        
     
        /**
         * @author Nitish Kumar
         * @date  24/01/2013
         * @description Returns first page of records
         */ 
        public void first() {
            pageNumber = 0;
            queryContact(); 
        }
     
        /**
         * @author Nitish Kumar
         * @date  24/01/2013
         * @description Returns last page of records
         */ 
        public void last() {
            pageNumber = noOfPages-1 ;
            queryContact();
        }
     
        /**
         * @author Nitish Kumar
         * @date  24/01/2013
         * @description Returns previous page of records
         */ 
        public void previous() {
             pageNumber--;
             queryContact();
        }
     
        /**
         * @author Nitish Kumar
         * @date  24/01/2013
         * @description Returns next page of records
         */ 
        public void next() {
           pageNumber++; 
             queryContact();
        }
    
    //Function that sends an email to the CRM production support
    //team when an exception was thrown. Email address gets retrived from the 
    //custom settings Environment_Variable__c                   
    public void sendErrorMail(String msg){ 

        if (SupportEmailAddress == null)
        {
            SupportEmailAddress = 'test@test.co.za';
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {SupportEmailAddress};
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Apex Error in : ' + UserInfo.getOrganizationName());
        mail.setSubject('Apex Error related to Campaign Hosts');
        mail.setPlainTextBody('Error in Class: CampaignHostsController\n' + msg);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
                       
}