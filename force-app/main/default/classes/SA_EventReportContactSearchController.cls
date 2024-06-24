/*****************************************************************************************************\
    @ Func Area     : Event Reports; Event Report Attendees; Contacts
    @ Author        : Rudolf Niehaus
    @ Date          : 10/2010
    @ Test File     : None - Test Method in this class
    @ Description   : Controller class for the contact search visualforce page when users add
                        / delete internal and external event attendees
    
    @ Last Modified By  :   Anand Nancharla
    @ Last Modified On  :   17th Aug 2011
    @ Modified Reason   :   Code comments whereever Domain_UserName__c is no longer used.
                            Case C-00000178
                            
    @ Last Modified By: Stephen Moore
    @ Last Modified Date: 26 Oct 2011
    @ Description:  Case#1876: Removal for the 'CRT_Region__c' field (See line 157)
                            
                            
    @ Last Modified By  : Caro Reinecke
    @ Last Modified On  : 30 Dec 2011
    @ Last Modified Reason  : Case#548 Regression Remove redundant fields - removed type__c custom field.
    
    @ Last Modified By  : Wayne Gray
    @ Last Modified On  : 27 March 2012
    @ Last Modified Reason  : C-00004421 Escape special characters.
       
    @ Last Modified By  : Caro Reinecke
    @ Last Modified On  : 12/04/2012
    @ Modified Reason   : Case 4296 Event Report Enhancements - allow for attendee status to be set during record creation.
    
    @ Last Modified By  : Wayne Gray
    @ Last Modified On  : June 2012
    @ Modification Description : Case #6521- Change contact to use TestFatcory
                                  API Version moved from 24 to 25 
    
    @ Last Modified By  : Nikhita Reddy
    @ Last Modified On  : 8 March 2013
    @ Modification Description : Added search optimization and pagination.
                                    Increased coverage of the class.
                                    
    @ Last Modified By  : Nitish Kumar
    @ Last Modified On  : 8 May 2013
    @ Modification Description : EN : 090 :- Changed the search logic to remove inactive contacts  
                                     from the search results 
    
    @ Last Modified By  : Navin Rai
    @ Last Modified On  : 22 August 2013
    @ Modification Description : EN : 231 :- Changed the search logic to include inactive contacts  
                                     in the search results  
                                    
******************************************************************************************************/
public with sharing class SA_EventReportContactSearchController{
    
    
    public String repid = ApexPages.currentPage().getParameters().get('reportid');
    public String contactType = ApexPages.currentPage().getParameters().get('contype');
    public String resultMessage { get; set; }
    public List<ContactWrapper> searchResults {get;set;}
    public String  hostsAdded {get;set;}

    //Variable for showing error message 
     public String blankSearch {get;set;} 
     public Boolean isblankSearchTrue {get; set;}
     public String noSearchResults {get;set;}
     public Boolean isnoSearchResultsTrue {get; set;}
     //variables for search optimization
     public Boolean memberChecked {get; set;}
     public Boolean memberNotChecked {get; set;}
     public String noAttendeeSelected {get;set;}
     public Boolean isnoAttendeeSelectedTrue {get; set;} 
     public String nrSelectedMembers {get;set;}
     
     public List<AccountTeamMember> lstAccTM{get;set;}
     
     
     //variables for pagination code
    @TestVisible private Integer CURRENT_PAGE_SIZE = 100;
    public integer m_pageNumber = 0;
    public integer m_totalRecords = 0;
    private Integer noOfPages {get;set;}
    public List<ContactWrapper> paginatedResults {get;private set;}


    public List<Call_Report_Attendees__c> getAttendees() {
        List<Call_Report_Attendees__c> att = new List<Call_Report_Attendees__c>([Select c.Id,c.Contact_id__c,c.Attendee_Name__c ,Client_Name__c, Title__c, c.Email__c,c.Contact_Type__c From Call_Report_Attendees__c c Where c.Call_Report__c = :repid]);
        return att;
    }      
    
    public string searchText {
        get {
            if (searchText == null) searchText = 'Contact Name';
            return searchText;
        }
        set;
    } 
    
    public string conType{
        get {
           if(contactType != null){
               if(contactType.endsWith('internal')){
                    conType = 'Search for Internal Attendees';
                }else if(contactType.endsWith('external')){
                    conType = 'Search for External Attendees';
                }
           }else{
                conType = 'Search for Internal Attendees';
           }
           
           return conType;
        }
        set;
    } 
 
    public SA_EventReportContactSearchController() {
        //Setting the boolean variables to false
        isblankSearchTrue = false;
        isnoSearchResultsTrue = false;
        isnoAttendeeSelectedTrue = false;
        memberChecked = false; //nik
        memberNotChecked = false;
        paginatedResults = new List<ContactWrapper>();
        searchResults = new List<ContactWrapper>();
    }
    public string styletodisplay {get;set;}
    public PageReference search() {
        styletodisplay = '';
        if (searchResults == null) {
            searchResults = new List<ContactWrapper>();
        } else {
            searchResults.clear();
        }
        
        if(paginatedResults!=null)
        paginatedResults.clear();
        
        String contactRecordType = '';
        
        if(contactType != null){
            if(contactType.endsWith('internal')){
                contactRecordType = 'SA_Bank_Contact_Record_Type';
            }else if(contactType.endsWith('external')){
                contactRecordType = 'SA_Client_Contact_Record_Type';
            }
        }
        
        searchText = searchText .replaceAll('\'','\\\\\'');
        //String qry = 'Select c.Name, c.Id, c.Email,c.Account.Name,c.Title,c.Inactive__c From Contact c Where ((c.Name LIKE \'%' + searchText + '%\') OR (c.Email LIKE \'%' + searchText + '%\')) AND c.RecordType.DeveloperName = \'' + contactRecordType Order By c.Name ASC LIMIT 1000';
        String qry = 'Select c.Name, c.Id, c.Email,c.Account.Name,c.Title,c.Inactive__c From Contact c Where ((c.Name LIKE \'%' + searchText + '%\') OR (c.Email LIKE \'%' + searchText + '%\')) AND c.RecordType.DeveloperName = \'' + contactRecordType + '\' Order By c.Name ASC LIMIT 1000';
        searchText = searchText .replaceAll('\\\\\'','\'');
        if( searchText == '' || searchText == 'Contact Name'){
            blankSearch = ErrorMessages__c.getValues('Blank_Search').Error_String__c ;
            isblankSearchTrue = true;
            isnoSearchResultsTrue = false;
            isnoAttendeeSelectedTrue = false ;
            memberChecked = false;
            memberNotChecked = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,blanksearch));
            styletodisplay = 'border-spacing: 0px; font-family: Arial, Helvetica, sans-serif;font-weight:Bold;font-size:12px;background-color:red;align:left;list-style: none';
            return null;
        }
        else{
            List<Contact> resultlist = new List<Contact>();
            resultlist = Database.query(qry);
            
            if(resultlist.size()==0){
                resultMessage = ErrorMessages__c.getValues('No_search_results').Error_String__c ;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,resultMessage));
                styletodisplay='border-spacing: 0px; font-family: Arial, Helvetica, sans-serif;font-weight:Bold;font-size:12px;background-color:red;align:left;list-style: none';
                return null;
            }
            
                    
            for(Contact c : resultlist){
                
                ContactWrapper cw = new ContactWrapper(c);
               
                searchResults.add(cw);
            }
            
            if (searchResults.size() > 0) {
                resultMessage = '';
                isblankSearchTrue = false;
                
            } else {
                isnoSearchResultsTrue = true;
                isblankSearchTrue = false;
                isnoAttendeeSelectedTrue = false;
                memberChecked = false;
                memberNotChecked = false;
              }
            
         }
         //Calling pagination code
         addPageRecords(1);
         return null;
    }
    
     public List<SelectOption> getYesNoOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Yes','Yes'));
        options.add(new SelectOption('No','No'));
        return options;
    }
    
     public List<SelectOption> getStatusOptions(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Invited','Invited'));
        options.add(new SelectOption('Attended','Attended'));
        options.add(new SelectOption('Declined','Declined'));
        options.add(new SelectOption('No Show','No Show'));
        options.add(new SelectOption('Distribute Only','Distribute Only'));
        return options;
    }
       
  
   
    public PageReference addcon(){
        system.debug('<><><> ' + memberChecked);
        Boolean addContact = true;
        boolean flag = false; //nik
        Boolean addattendeeflag = true; //Navin
        Boolean attendeealreadyexists = false; //Navin
        string inactivecontact;
        string contactalreadyexistsasattendee;
        memberChecked = false;//nik
        List<Call_Report_Attendees__c> exatt = getAttendees();
        Call_Report_Attendees__c[] repattInsert = new Call_Report_Attendees__c[]{};
        
        Integer x=1;
        
        for (ContactWrapper cw : searchResults){
            
            if (cw.checked){
               
               for(Integer q=0;q<exatt.size();q++){
                    if(exatt[q].Contact_id__c == cw.con.Id){
                        addContact = false;
                        attendeealreadyexists = true;                       
                    }
                }
               
               if(addContact){
                    Call_Report_Attendees__c repatt = new Call_Report_Attendees__c();
                    //repatt.Client_Name__c = cw.con.Name;
                    //repatt.Email__c = cw.con.Email;
                    repatt.Call_Report__c = repid;
                    repatt.Contact_id__c = cw.con.Id;
                    repatt.Status__c = cw.status;
                    if(contactType.endsWith('internal')){
                        repatt.Send_Email__c = cw.sendMail;
                    }else if(contactType.endsWith('external')){
                        repatt.Send_Email__c = 'No';
                    }
                    memberChecked = true;
                    if(cw.con.Inactive__c){
                        addattendeeflag = false;
                    }   
                        
                    repattInsert.add(repatt);
               }else{
                   /*if(cw.con.Inactive__c == True){
                        memberChecked = true; // even though it is an inactive contact, this flag should be set. So, that an appropriate error can be shown.
                        addattendeeflag = false;
                        
                        
                        
                    }*/
                    addContact = true;
                    system.debug('addcontact------->' +addContact);
               }
               flag = true;
               system.debug('Flag------->' +flag);
            }
            else{
                 
            }
               x++;
               cw.checked = false; 
               system.debug('memberChecked------->' +memberChecked);
        }
        
        if (!memberChecked && !attendeealreadyexists){
            
            noAttendeeSelected = ErrorMessages__c.getValues('Add_Attendee_to_list').Error_String__c ;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,noAttendeeSelected));
            styletodisplay = 'border-spacing: 0px;font-family: Arial, Helvetica, sans-serif;font-weight:Bold;font-size:12px;background-color:red;list-style: none;';
            memberNotChecked = true;
            memberChecked = false;
            isnoAttendeeSelectedTrue = true ;
            isnoSearchResultsTrue = false ;
            isblankSearchTrue = false;
            
        }
        else if(attendeealreadyexists){
            contactalreadyexistsasattendee = ErrorMessages__c.getValues('Event_Attendee_Exists').Error_String__c ;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,contactalreadyexistsasattendee));
            styletodisplay = 'border-spacing: 0px;font-family: Arial, Helvetica, sans-serif;font-weight:Bold;font-size:12px;background-color:red;list-style: none;';
        }
        else{
            try{
                
                    insert repattInsert;
                    hostsAdded = ErrorMessages__c.getValues('Attendee_Added').Error_String__c ;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,hostsAdded));
                    styletodisplay = 'border-spacing: 0px; font-family: Arial, Helvetica, sans-serif;font-weight:Bold;font-size:12px;background-color:#00FF00;list-style: none';
                    memberNotChecked = false;
                    memberChecked = true; //nik
                    isblankSearchTrue = false;
                    isnoSearchResultsTrue = false;
                    isnoAttendeeSelectedTrue = false ;
                    
                    // this if condition is provided because in case of an inactive contact is selected, it should not be saved but instead an error pertaining to Inactive_Contact is shown
                    if(!addattendeeflag){
                        system.debug('Coming Here------->');
                        inactivecontact = ErrorMessages__c.getValues('Inactive_Contact').Error_String__c ;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,inactivecontact));
                        styletodisplay = 'border-spacing: 0px;font-family: Arial, Helvetica, sans-serif;font-weight:Bold;font-size:12px;background-color:#00FF00;list-style: none;';
                    }
                
            }catch(System.DMLException ex){ 
                System.debug('Add Attendee to selected memeber Exception ' + ex.getMessage());   
            }
        }
        if(flag==false){
            memberChecked=false;
        }
        system.debug('<><><> ' + memberChecked);
        return null;
    }  

    public void addRemoveTeamMember(){
        
    }
    
    /********************************************************************************************************************
        Code for implementing Pagination for the page
     ********************************************************************************************************************/
        /**
        * @description Method where pagination logic takes place
        * @param newPageIndex Takes value of the page size as input
        * @return 
        */
        public void addPageRecords(Integer newPageIndex){
        try{
            //clear deal wrapper list
            paginatedResults.clear();
            
            //set variables
            Transient Integer counter = 0;
            Transient Integer min = 0;
            Transient Integer max = 0;
            
            noOfPages = searchResults.size() / CURRENT_PAGE_SIZE;
            //Set 5 records for each page set
            if (newPageIndex > m_pageNumber) {
                min = m_pageNumber * CURRENT_PAGE_SIZE;
                max = newPageIndex * CURRENT_PAGE_SIZE;
            } else {
                max = newPageIndex * CURRENT_PAGE_SIZE;
                min = max - CURRENT_PAGE_SIZE;
            }
            for(Integer nRec = min; searchResults.size()>nRec; nRec++){
                if(nRec < searchResults.size() && nRec< max){
                    paginatedResults.add(searchResults[nRec]);
                } else{
                    break;
                }
            }
            m_pageNumber = newPageIndex;
            
        //Exception handling
        } catch(System.Exception ex){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An unexpected exception occured. Please contact your System Admin'));
            System.debug('###Exception : '+ ex.getMessage());
            }
        }
        
        /**
        * @description Gets the page Number
        * @param 
        * @return m_pageNumber
        */ 
        public Integer getPageNumber(){
            return m_pageNumber; 
        }
        /**
        * @description Get the total number of records
        * @param 
        * @return searchResults.size()
        */ 
        
        public Integer getTotalRecords(){
            return searchResults.size();
        }
        /**
        * @description Gets the total number of pages
        * @param 
        * @return intTotPage
        */ 
        public Integer getTotalPageNumber(){
            try{
                Integer intTotPage = 0;
                if (!searchResults.isEmpty()){
                    intTotPage = searchResults.size() / CURRENT_PAGE_SIZE;
                    Integer mod = searchResults.size() - (intTotPage * CURRENT_PAGE_SIZE);
                    if (mod > 0){
                        intTotPage += 1;
                    }
                }
                return intTotPage;
            //Exception handling
            } catch(System.Exception ex){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An unexpected exception occured. Please contact your System Admin'));
                System.debug('###Exception : '+ ex.getMessage());
                return null;
            }
        }
         /**
        * @description Boolean method to know if the page is first 
        * @param 
        * @return boolean
        */ 
        public Boolean getFirstStatus() {
            try {
               if (m_pageNumber == 1)
                   return true;
                   else
                   return false;
            }catch(System.Exception ex){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An unexpected exception occured. Please contact your System Admin'));
                System.debug('###Exception : '+ ex.getMessage());
                return null;
            }
        }
        
         /**
        * @description Boolean method to know if the page is last 
        * @param 
        * @return boolean
        */ 
        public Boolean getLastStatus() {
            try {
               if (m_pageNumber == getTotalPageNumber() )
                   return true;
                   else
                   return false;
            }catch(System.Exception ex){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An unexpected exception occured. Please contact your System Admin'));
                System.debug('###Exception : '+ ex.getMessage());
                return null;
            }
        }
        
        /**
        * @description Boolean method to know if the page has a previous value
        * @param 
        * @return boolean
        */ 
        public Boolean getPreviousLinkStatus(){
            return (m_pageNumber > 1);
        }
        /**
        * @description Boolean method to know if the page has a next value
        * @param 
        * @return Boolean
        */ 
        public Boolean getNextLinkStatus(){
            try{
                if (paginatedResults.size() > 0 && ((m_pageNumber * CURRENT_PAGE_SIZE) < searchResults.size())) {
                    return true;
                } else {
                    return false;
                }
            } catch(System.Exception ex){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An unexpected exception occured. Please contact your System Admin'));
                System.debug('###Exception : '+ ex.getMessage());
                return null;
            }
        }
        /**
        * @description Gets the first link for the page
        * @param 
        * @return 
        */ 
        public void firstPage(){
            addPageRecords(1);
        } 
        
        /**
        * @description Gets the last link for the page
        * @param 
        * @return 
        */ 
        public void lastPage(){   
            addPageRecords(getTotalPageNumber());
            system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>'+m_pageNumber);
        }
        /**
        * @description Gets the next link for the page
        * @param 
        * @return 
        */ 
        public void NextLink(){   
            addPageRecords(m_pageNumber + 1);
            system.debug('>>>>>>>>>>>>>>>>>>>>>>>>>'+m_pageNumber);
        }
        /**
        * @description gets the previous link for the page
        * @param 
        * @return 
        */ 
        public void PreviousLink(){
            if(m_pageNumber > 0)
                addPageRecords(m_pageNumber - 1);
        }
        
        /**
     * @author Nikhita Reddy
     * @date  24/03/2013
     * @description Returns the first record number of the current page
     */
    public integer getrecordFrom() {
        system.debug('*****' + CURRENT_PAGE_SIZE + '********' + m_pageNumber);
        if (searchResults.size() == 0) {
            return 0;
        } else {

            if (m_pageNumber == 1) {

                return 1;

            } else {

                return ((CURRENT_PAGE_SIZE * (m_pageNumber-1)) + 1);

            }
        }
    }
    /**
     * @author Nikhita Reddy
     * @date  24/03/2013
     * @description Returns the last record number of the current page 
     */
    public integer getrecordTo() {
        system.debug('>>>>>>>>>>' + noOfPages + '>>>>>>>>>>' + m_pageNumber);
        if (searchResults.size() <= CURRENT_PAGE_SIZE) {

            return searchResults.size();
        } else {

            if (Math.mod(searchResults.size(), CURRENT_PAGE_SIZE) == 0) {

                return (CURRENT_PAGE_SIZE * (m_pageNumber));

            } else {
                if (m_pageNumber != noOfPages + 1 ) {

                    return (CURRENT_PAGE_SIZE * (m_pageNumber));

                } else {

                    return searchResults.size();

                }
            }
        }
    }

    
      /********************************************************************************************************************
          Pagination code end
       ********************************************************************************************************************/
    
     public PageReference done() {
        Pagereference eventReport = new Pagereference ('/' + repid);
        return eventReport;
    }              
    
    //######################## TEST METODS #############################
    static testMethod void testMe(){

        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getEnvironmentVariable(),
            TEST_DataFactory.getCcSettings(),
            TEST_DataFactory.getErrorMessages(),
            TEST_DataFactory.getUserProfileIds()
        });

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        BLD_Account accBld = new BLD_Account(uow).useChild()
            .name(DMN_Account.STANDARD_BANK_EMPLOYEES);
        
        BLD_Contact bankConBld = new BLD_Contact(uow).useBankContact().account(accBld).email('dwadwa@standardbank.co.za');
        BLD_Contact clientConBld = new BLD_Contact(uow).useClientContact().account(accBld).email('dwadwadwa@dwadaw.com');

        Contact bankCon = (Contact) bankConBld.getRecord();
        Contact clientCon = (Contact) clientConBld.getRecord();

        uow.commitWork();

        system.Test.startTest();

        BLD_CallReport crBld1 = new BLD_CallReport(uow)
            .internal()
            .meetingPurpose(DMN_CallReport.CORE_TEAM_MEETING)
            .linkWithParent(accBld)
            .assign(UserInfo.getUserId())
            .addAttendee(
                new BLD_CallReportAttendee(uow)
                    .contact(bankConBld)
            );
        BLD_CallReport crBld2 = new BLD_CallReport(uow)
            .internal()
            .meetingPurpose(DMN_CallReport.CORE_TEAM_MEETING)
            .linkWithParent(accBld)
            .assign(UserInfo.getUserId())
            .addAttendee(
                new BLD_CallReportAttendee(uow)
                    .contact(clientConBld)
            );

        uow.commitWork();
        

        Pagereference p = page.SA_EventReportContactSearch;
        System.Test.setCurrentPage(p);
        
        
        
        //TEST CONTROLLER
        SA_EventReportContactSearchController cont = new SA_EventReportContactSearchController();
        
        //set page parameters values
        p.getParameters().put('reportid', crBld2.getRecordId());
        p.getParameters().put('contype','internal');
        cont.contactType = 'internal';
        cont.repid = crBld2.getRecordId();
        
        //Search for internal attendees
        List<Call_Report_Attendees__c> lstAttendees1 = cont.getAttendees();
        
        //List<Call_Report_Attendees__c> att = cont.getAttendees();
        
        cont.searchText = bankCon.Email;
        
        cont.search();
        
        String testconType = cont.conType;
        
        //check and add contact 
        List<ContactWrapper> cw = cont.searchResults;
        if(cw.size() > 0){
            cw[0].checked = true;
        }
        
        try{
        cont.addcon();
        }
        Catch(Exception ex) {}
        //search for external contacts
        ApexPages.currentPage().getParameters().put('reportid', crBld2.getRecordId());
        ApexPages.currentPage().getParameters().put('contype','external');
        cont.contactType = 'external';
        cont.repid = crBld2.getRecordId();
        cont.searchText = clientCon.Email;
        cont.search();
        
        //check and add contact 
        cw = cont.searchResults;
        if(cw.size() > 0){
            cw[0].checked = true;
        }
        try{
        cont.addcon();
        } Catch (Exception ex) {}
        
        String testconType2 = cont.conType;
        
        try{
        cont.searchText = '';
        cont.search();
        
        system.Test.stopTest();
        
        ApexPages.currentPage().getParameters().put('reportid', crBld2.getRecordId());
        ApexPages.currentPage().getParameters().put('contype','external');
        cont.contactType = 'external';
        cont.repid = crBld2.getRecordId();
        cont.searchText = clientCon.Name;
        cont.search();
        cont.NextLink();
        cont.lastPage();
        cont.PreviousLink();
        cont.firstPage();
        cont.getPageNumber();
        cont.getFirstStatus();
        cont.getLastStatus();
        cont.getPreviousLinkStatus();
        cont.getNextLinkStatus();
        cont.getStatusOptions();
        cont.getYesNoOptions(); 
        
        
        
        cw = cont.searchResults;
        system.assertEquals(cw.size(), cont.getTotalRecords());
        }
        Catch (Exception ex) {}
        
        if(cw.size() > 0){
            cw[0].checked = true;
        }
        try{
        cont.addcon();
        } Catch (Exception ex) {}
        cw = cont.searchResults;
        
        
        try{
        cont.addcon();
        } Catch (Exception ex) {}
        
        try{
            ApexPages.currentPage().getParameters().put('reportid', crBld2.getRecordId());
            ApexPages.currentPage().getParameters().put('contype','external');
            
            cont.contactType = '';
        }catch(Exception e){}
        
        ApexPages.currentPage().getParameters().put('reportid', crBld1.getRecordId());
        ApexPages.currentPage().getParameters().put('contype','external');
        cont.contactType = 'external';
        cont.repid = crBld1.getRecordId();
        
        try{
        cont.searchtext = 'jnnkjnlkjnlkj';
        cont.search();
        }catch(Exception e){}
        
        cont.done(); 
        system.debug(LoggingLevel.ERROR, 'SOQL query usage end test method()  unit test: ' + Limits.getQueries());
        system.debug(LoggingLevel.ERROR, 'DML rows query end test method()  unit test: ' + Limits.getDMLRows());
    } 
}