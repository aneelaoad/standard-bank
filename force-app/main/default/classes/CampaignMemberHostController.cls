/*****************************************************************************************************\
    @ Func Area     : New Campaigns, New, Update, Deletion of Campaign Members, Member hosts
    @ Author        : Rudolf Niehaus
    @ Date          : 02/2011
    @ Test File     : Test Method TestCampaignMemberHostController.cls
    @ Description   : Case#1168
                      Controller class for the Visualforce pages CampaignMemberHostManager.page. The page is used to 
                      manage the members and hosts related to members. The page also gives a user the ability to
                      remove current members and export all campaign members to Exel.
------------------------------------------------------------------------------------------------------------------------------- 
    @ Func Area     : Campaign, Campaign Member Hosts
    @ Last Modified By: Rudolf Niehaus
    @ Last Modify Date: 03/2012
    @ Description: Case#5276 - Fix the paging logic for records less the 200. Use can now page back                         
---------------------------------------------------------------------------------------------------------------------------------                                       
    @ Last Modified By  :   Stephen Moore
    @ Last Modified On  :    25/04/2012
    @ Modification Description : remove preferred_language__c and replace it with sa_preferred_language__c
                             C-00003926 Delete Preferred Language (See Line No: 203,206,214, 216)
---------------------------------------------------------------------------------------------------------------------------------         
    @ Last Modified By  : Nitish Kumar
    @ Last Modified On  : 31 Jan 2013
    @ Last Modified Reason  :  EN 12 :-
                               Added the error message in a custom setting
                               API version moved from 25 to 27.
                               
    @ Last Modified By  : Tracy Roberts
    @ Last Modified On  : 22 April 2013
    @ Last Modified Reason  :  Case#785 (Campaign error message when adding a host)
                               Add error messages to check for "Remove Member(s) with no Members", "Add Host(s) with no Members",
                               "Remove Host(s) with no Members", "Remove Selected Host(s) with no Host selected", 
                               "Add Selected Host(s) when no host is selected". 
                               Error messages are located in the Error message custom setting under enviromental variables.  
                               
----------------------------------------------------------------------------------------------------------------------------------
   @ Last Modified By  : Sheldon Lazarus
   @ Last Modified on  : 17 July 2014
   @ Last  Modified Reason : Enhancement #EN-0470 (No error message is displayed when user tries to add/remove members host from a locked campaign)
                            Add error message when users tries add or remove hosts from a campaign when a campaign is locked
    
----------------------------------------------------------------------------------------------------------------------------------
   @ Last Modified By  : Andrei Olteanu
   @ Last Modified on  : 08 Jan 2017
   @ Last  Modified Reason : US-1502 Add SLDS styling

----------------------------------------------------------------------------------------------------------------------------------
    @ Last Modified By  : Dzianisik Maksim
    @ Last Modified no  : Sep 2021
    @description        : SFP-6839 Prod-incident, Bank_Contact__c can be null, in this case VF page has to show 'None' in 'CURRENT HOST(S)' column
    
******************************************************************************************************/
@SuppressWarnings('PMD.ExcessivePublicCount')
public class CampaignMemberHostController {

    public String currentId {get;set;}
    public String userPageInfo {get;set;}
    public Boolean clocked{get;set;}
    public Integer limitSize {get;set;}
    public Integer iteration {get;set;}
    public Integer startPageBlock = 0;
    public Integer maxPageBlock = 0;
    public Integer endPageBlock = 0;
    public Boolean memberCountNotice {get;set;}
    public Boolean goBack {get;set;}
    public Boolean goNext {get;set;}
    public Boolean camLocked {get;set;}
    public Transient List<Campaign_Member_Host__c> memhostList;
    public Transient List<Campaign_Member_Host__c> memberCount;
    public List<Campaign_Member_Host__c> pageList;
    public List<CampaigHostsWrapper> memberResults {get;set;}
    public Map<Id,Set<String>> hostMap = new Map<Id,Set<String>>();
    public Map<Id,List<Campaign_Hosts__c>> hostsMap = new Map<Id,List<Campaign_Hosts__c>>();
    private final Campaign cam;
    public String camName {get;set;}
    private String sortDirection = 'ASC';
    private String sortExp = 'name';
    public List<SelectOption> waveOptions;
    public String wave = 'None';
    public Boolean waveFilter = false;
    private String SupportEmailAddress = '';
    private Environment_Variable__c settings = null;
    private Integer STANDARD_PAGE_BLOCK_SIZE = 100;
    
     //Variable for showing error message
    public String blankSearch {get;set;} 
    public Boolean isblankSearchTrue {get; set;}
    public String noSearchResults {get;set;}
    public Boolean isnoSearchResultsTrue {get; set;}
    public String noMemberSelected {get;set;}
    public Boolean isNoMemberSelectedTrue {get;set;}
    
    public Boolean isLightning {get; set;}

    public static String PARAM_NAME_MEMBERS_IDS = 'Ids';
    
    ApexPages.StandardController controller;

    /**
     * @description class constructor
     */
    public CampaignMemberHostController(){
       isNoMemberSelectedTrue = false;
    }

    /**
     * @param controller ApexPages.StandardController
     * @description class constructor
     */
    public CampaignMemberHostController(ApexPages.StandardController controller){
        isLightning = isPageOriginLightning(ApexPages.currentPage().getParameters());
        //Get current campaign information
        this.cam = (Campaign)controller.getRecord();
        this.memberCountNotice = false;
        waveOptions = new List<SelectOption>();
        this.currentId = this.cam.Id;
        camLocked=false;
       
        
        if(this.currentId == null){
            currentId = ApexPages.currentPage().getParameters().get('campId');
        }
        this.iteration = getIteration();
        goBack=false;
        goNext=true;
        
         //Get CRM Production support email address from custom settings in order to email
        //error messages
        this.settings = Environment_Variable__c.getInstance();
        this.SupportEmailAddress = settings.CRM_Production_Support__c;

    }

    /**
     * @param params Map<String, Object>
     * @description unknown
     * @return Boolean
     */
    private Boolean isPageOriginLightning(Map<String, Object> params) {
        if (params.get('sfdcIFrameHost') != null ||
            params.get('sfdcIFrameOrigin') != null ||
            params.get('isdtp') == 'p1') {      
                return true;
            } else {      
                return false;
            }
    }

    /**
     * @return Set<Id>
     * @description unknown
     */
    public Set<Id> PageBlockIds(){
        
        Set<Id> ids = new Set<Id>();
        String buttonType = System.currentPageReference().getParameters().get('button');
        
         //build the full sort expression
        String sortFullExp = sortExpression  + ' ' + sortDirection;

        if(sortFullExp.contains('name')){
            sortFullExp = 'Member__r.FirstName ASC';
        }

        String qry = 'Select Id From Campaign_Member_Host__c Where Campaign__c = \'' + currentId + '\' order by ' + sortFullExp;
        
        if(searchText != ' Member/Client Name'){
            qry = 'Select Id From Campaign_Member_Host__c Where ((Member__r.Name LIKE \'%' + searchText + '%\') OR (Member__r.Account.Name LIKE \'%' + searchText + '%\')) AND Campaign__c = \'' + currentId + '\' order by ' + sortFullExp;
        }
        
        if(waveFilter){
            if(wave.equals('None')){
                wave = '';
            }
            if(wave.equals('All')){
                qry = 'Select Id From Campaign_Member_Host__c Where Campaign__c = \'' + currentId + '\' order by ' + sortFullExp;
            }else{
                qry = 'Select Id From Campaign_Member_Host__c Where Campaign__c = \'' + currentId + '\' and Campaign_Wave__c = \'' + wave + '\' order by ' + sortFullExp;
            }
        }
        
        pageList = Database.query(qry);
        
        //pageList = [Select Id From Campaign_Member_Host__c c Where c.Campaign__c =: currentId AND c.Member__r.Account.Name LIKE : filterText order by c.Member__r.FirstName asc];
        maxPageBlock = pageList.size();

        if(buttonType == null){
            
            startPageBlock=1;
            goBack=false;
            if(maxPageBlock<=STANDARD_PAGE_BLOCK_SIZE){
                endPageBlock=maxPageBlock;
                goNext=false;
           }else{
                endPageBlock=STANDARD_PAGE_BLOCK_SIZE;
                goNext=true;
            }

        }else if(buttonType == 'back'){
            
            if(endPageBlock==maxPageBlock){
                endPageBlock=(startPageBlock-1);
                startPageBlock=(endPageBlock-99);
            }else{
                if(startPageBlock>STANDARD_PAGE_BLOCK_SIZE){
                    startPageBlock-=STANDARD_PAGE_BLOCK_SIZE;
                    endPageBlock-=STANDARD_PAGE_BLOCK_SIZE;
                }
            }

            if(startPageBlock<STANDARD_PAGE_BLOCK_SIZE){
                goBack=false;
            }
            if(maxPageBlock > endPageBlock){
                goNext=true;
            }
            
        }else if(buttonType == 'next'){

            endPageBlock+=STANDARD_PAGE_BLOCK_SIZE;
            startPageBlock+=STANDARD_PAGE_BLOCK_SIZE;
            if(endPageBlock>=maxPageBlock){
                endPageBlock=maxPageBlock;
                goNext=false;
                goBack=true;
            }else{
                goBack=true;
            }
            
        }else if(buttonType == 'last'){
           
            if(maxPageBlock>STANDARD_PAGE_BLOCK_SIZE){
                endPageBlock=maxPageBlock;
                startPageBlock=((maxPageBlock / STANDARD_PAGE_BLOCK_SIZE) * STANDARD_PAGE_BLOCK_SIZE) + 1;
                goNext=false;
                goBack=true;
            }
        }else if(buttonType == 'first'){
            
            startPageBlock=1;
            goBack=false;
            if(maxPageBlock<STANDARD_PAGE_BLOCK_SIZE){
                endPageBlock=maxPageBlock;
                goNext=false;
            }else{
                endPageBlock=STANDARD_PAGE_BLOCK_SIZE;
                goNext=true;
            }
            
        }

        if(pageList.size() > 0){
            for(Integer i=(startPageBlock-1);i<endPageBlock;i++){
                ids.add(pageList[i].id);
            }
        }
        
        userPageInfo = startPageBlock + '-' + endPageBlock + ' of ' + maxPageBlock;

        pageList.clear();
            
        return ids; 
      
      }

    /**
     * @return PageReference
     * @description Load the page the campaign members and their relevant hosts
     */
    public PageReference Load(){

        Set<Id> pageIds = PageBlockIds();
        
        List<Campaign> camp = [Select Id,Name,Lock_Campaign__c From Campaign Where Id =: currentId];
        this.camName = camp[0].Name;

        //build the full sort expression
        String sortFullExp = sortExpression  + ' ' + sortDirection;

        if(sortFullExp.contains('name')){
            sortFullExp = 'Member__r.FirstName ASC';
        }

        String qry = 'Select Id, Campaign_Wave__c, Member_Id__c,Member__c, Member__r.Shirt_Size__c, Member__r.Religion__c, Member__r.sa_Preferred_Language__c, Member__r.Phone, Member__r.Number_of_Children__c, Member__r.MobilePhone, Member__r.Golf_Handicap__c, Member__r.FAIS_Representative__c, Member__r.Disabilities__c, Member__r.Dietary_Requirements__c, Member__r.Contact_Category__c, Member__r.Allergies__c,Member__r.Name,Member__r.FirstName,Member__r.LastName, Member__r.Email, Member__r.Account.Name,Member__r.Title,Member_Status__c,Member__r.User_Division_Sync__c,Member__r.User_Business_Unit_Sync__c From Campaign_Member_Host__c Where Id IN : pageIds AND Campaign__c = \'' + currentId + '\' order by ' + sortFullExp;
        
        if(searchText != ' Member/Client Name'){
            qry = 'Select Id, Campaign_Wave__c, Member_Id__c,Member__c,Member__r.Name, Member__r.Shirt_Size__c, Member__r.Religion__c, Member__r.sa_Preferred_Language__c, Member__r.Phone, Member__r.Number_of_Children__c, Member__r.MobilePhone, Member__r.Golf_Handicap__c, Member__r.FAIS_Representative__c, Member__r.Disabilities__c, Member__r.Dietary_Requirements__c, Member__r.Contact_Category__c, Member__r.Allergies__c,Member__r.FirstName,Member__r.LastName, Member__r.Email, Member__r.Account.Name,Member__r.Title, Member_Status__c,Member__r.User_Division_Sync__c,Member__r.User_Business_Unit_Sync__c From Campaign_Member_Host__c Where ((Member__r.Name LIKE \'%' + searchText + '%\') OR (Member__r.Account.Name LIKE \'%' + searchText + '%\')) AND Id IN : pageIds AND Campaign__c = \'' + currentId + '\' order by ' + sortFullExp;
        }
        
        if(waveFilter){
           if(wave.equals('None')){
                wave = '';
            }
            if(wave.equals('All')){
                qry = 'Select Id, Campaign_Wave__c, Member_Id__c,Member__c, Member__r.Shirt_Size__c, Member__r.Religion__c, Member__r.sa_Preferred_Language__c, Member__r.Phone, Member__r.Number_of_Children__c, Member__r.MobilePhone, Member__r.Golf_Handicap__c, Member__r.FAIS_Representative__c, Member__r.Disabilities__c, Member__r.Dietary_Requirements__c, Member__r.Contact_Category__c, Member__r.Allergies__c,Member__r.Name,Member__r.FirstName,Member__r.LastName, Member__r.Email, Member__r.Account.Name,Member__r.Title,Member_Status__c,Member__r.User_Division_Sync__c,Member__r.User_Business_Unit_Sync__c From Campaign_Member_Host__c Where Id IN : pageIds AND Campaign__c = \'' + currentId + '\' order by ' + sortFullExp;
            }else{
                qry = 'Select Id, Campaign_Wave__c, Member_Id__c,Member__c, Member__r.Shirt_Size__c, Member__r.Religion__c, Member__r.sa_Preferred_Language__c, Member__r.Phone, Member__r.Number_of_Children__c, Member__r.MobilePhone, Member__r.Golf_Handicap__c, Member__r.FAIS_Representative__c, Member__r.Disabilities__c, Member__r.Dietary_Requirements__c, Member__r.Contact_Category__c, Member__r.Allergies__c,Member__r.Name,Member__r.FirstName,Member__r.LastName, Member__r.Email, Member__r.Account.Name,Member__r.Title,Member_Status__c,Member__r.User_Division_Sync__c,Member__r.User_Business_Unit_Sync__c From Campaign_Member_Host__c Where Id IN : pageIds AND Campaign__c = \'' + currentId + '\' and Campaign_Wave__c = \'' + wave + '\'';
            }
        }
        
         if( searchText == ''){
            blankSearch = ErrorMessages__c.getValues('Blank_Search').Error_String__c ;
            isblankSearchTrue = true;
            isnoSearchResultsTrue = false;
            isNoMemberSelectedTrue =  false;
            return null;
        }
         
        else{
        memhostList = Database.query(qry);
        
        if(memhostList.size()>0){
            isblankSearchTrue = false;
            isnoSearchResultsTrue = false;
            isNoMemberSelectedTrue =  false;
        
        Set<Id> memIds = new Set<Id>();
        for(Campaign_Member_Host__c mh : memhostList){
            memIds.add(mh.Id);
        }
                
        SEL_CampaignHosts campaignHostSelectorLayer = new SEL_CampaignHosts();
        List<Campaign_Hosts__c> hostList = campaignHostSelectorLayer.getMemhostList(memIds);
        Id memID = null;
        Set<String> hostNames = new Set<String>();
        List<Campaign_Hosts__c> hostsPerMem = new List<Campaign_Hosts__c>();
        
        for(Campaign_Hosts__c h : hostList){

            if(memID == h.Campaign_Member_Host__c || memID == null){
                hostNames.add(h.Bank_Contact__r.Name);
                hostsPerMem.add(h);
                
                if(hostList.size() == 1){
                    memID = h.Campaign_Member_Host__c;
                    hostMap.put(memID, hostNames);
                    hostsMap.put(memID,hostsPerMem);
                }
            }else{
                
                hostMap.put(memID, hostNames);
                hostsMap.put(memID,hostsPerMem);
                
                hostNames = new Set<String>();
                hostsPerMem = new List<Campaign_Hosts__c>();
                
                hostNames.add(h.Bank_Contact__r.Name);
                hostsPerMem.add(h);
            }
            
            memID = h.Campaign_Member_Host__c;
            
        }
        
        hostMap.put(memID, hostNames);
        hostsMap.put(memID,hostsPerMem);
        
        memberResults = new List<CampaigHostsWrapper>();

        for(Campaign_Member_Host__c h : memhostList){
            
            Set<String> contactNames = new Set<String>();
            List<Campaign_Hosts__c> linkedHosts = new List<Campaign_Hosts__c>();
            
            if(hostMap.containsKey(h.Id)){
                
                contactNames = hostMap.get(h.Id);
                linkedHosts = hostsMap.get(h.Id);
            }else{
                
                contactNames.add('None');
            }

            if (contactNames.contains(null)) {
                Set<String> temp = new Set<String>();
                for(String tempString : contactNames) {
                    if (tempString == null) {
                        temp.add('None');
                    }else {
                        temp.add(tempString);
                    }
                }
                contactNames = temp;
            }
            CampaigHostsWrapper cw = new CampaigHostsWrapper(h,contactNames,linkedHosts);
                
            memberResults.add(cw);
        }

        
        hostMap.clear();
        hostsMap.clear();
        hostNames.clear();
        hostsPerMem.clear();
        
        //waveFilter = false;
         
        return null;
          } 
        
        else{
            noSearchResults =  ErrorMessages__c.getValues('Search_Results_Not_Found').Error_String__c ;
            isblankSearchTrue = false;
            isnoSearchResultsTrue = true;
            isNoMemberSelectedTrue =  false;
            return null;    
            }
      }
    }

    /**
     * @return String
     * @description Get current selected wave value
     */
    public String getWave(){
        return this.wave;
    }

    /**
     * @param wave String
     * @description set wave value
     */
    public void setWave(String wave){
        this.wave = wave;
    } 

    /**
     * @return List<SelectOption>
     * @description Get all the picklist values from the invitation wave field
     */
    public List<SelectOption> getInviteWave() {
        waveOptions = new List<SelectOption>();
        waveOptions.add(new SelectOption('None','None'));
        Schema.DescribeFieldResult fieldResult = CampaignMember.Campaign_Wave__c.getDescribe();
        
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                
           for( Schema.PicklistEntry f : ple)
           {
              waveOptions.add(new SelectOption(f.getLabel(), f.getValue()));
           }       
 
        waveOptions.add(new SelectOption('All','All'));

        return waveOptions;
    }
    
    //Memebers search string
    public string searchText {
        get {
            if (searchText == null) {
                searchText = ' Member/Client Name';
            }
            return searchText;
        }
        set;
    }
    
 
        
    /**
     * @return String
     * @description Get all the id's of selected members so we can pass it to the next page
     */
    public String memberIds() {
        String ids = '';

        for (CampaigHostsWrapper cw : memberResults){
            
            if (cw.checked){
               ids = ids + cw.memhost.Id + '-';
            }
        }
        if(ids.length() > 0){
            ids = ids.substring(0,ids.length()-1);
            isNoMemberSelectedTrue =  false;
            //noMemberSelected  = '';
            isblankSearchTrue = false;
            isnoSearchResultsTrue  = false;
        }
        else
        {
            noMemberSelected = ErrorMessages__c.getValues('No_Host_Selected_ToRemove').Error_String__c ;
            isNoMemberSelectedTrue =  true;  
            isblankSearchTrue = false;
            isnoSearchResultsTrue  = false;
        }

        return ids;

    }

    /**
     * @return PageReference
     * @description Open page where a user can add hosts to selected memebers
     */
    public PageReference ManageHosts(){
        String tempMemberIds = memberIds();
        //validate if campaign is locked
        Campaign locktest = [SELECT Lock_Campaign__c FROM Campaign WHERE ID =: Currentid limit 1];
        if(locktest.Lock_Campaign__c != true){
        Pagereference  assignPage = Page.CampaignHostAssigner;
        if(tempMemberIds.length() > 0)
        {
            assignPage.getParameters().put('campId',currentId);
            if( isNoMemberSelectedTrue != true)
            {
                assignPage.getParameters().put(PARAM_NAME_MEMBERS_IDS,memberIds());
            }
            assignPage.setRedirect(true);
        }
        else
        {
            return null;
        }
        return assignPage;
        }
                       
       else
       {
            camLocked=true;
            return null;
       }
            
        
    }

    /**
     * @return PageReference
     * @description Open page where a user can delete hosts for selected memebers
     */
    public PageReference RemoveHosts(){
        String tempMemberIds = memberIds();
        //validate if campaign is locked
        Campaign lcktest = [SELECT Lock_Campaign__c FROM Campaign WHERE ID =: Currentid limit 1];
        if(lcktest.Lock_Campaign__c != true){
        Pagereference removePage = Page.CampaignHostRemover;
        if(tempMemberIds.length() > 0)
        {
            removePage.getParameters().put('campId',currentId);
            if( isNoMemberSelectedTrue != true)
            {
                removePage.getParameters().put(PARAM_NAME_MEMBERS_IDS,memberIds());
            }
            removePage.setRedirect(true);
        }
        else
        {
            return null;
        }
        
        return removePage;
       }
       else
       {
            camLocked=true;
            return null;
        }
    }

    /**
     * @return Integer
     * @description Open page that will render the Excel doc containing all the members and their linked hosts
     * Only 2500 per page will be exported as a rusult of the heap size Limits in SF
     */
    public Integer getIteration(){
        
        Integer recs = 0;
        Integer loops = 0;
        
        //Loop through member list for this campaign
        //If rec count is <= 2500 records, then construct the ids into a "-" delimited string. if > 2500 pass the ids through
        //to the class ExportMembers in order to export the 2500 records to an Excel file. This will repeat for each 2500 records. 
        memberCount = new List<Campaign_Member_Host__c>([Select Id From Campaign_Member_Host__c Where Campaign__c =: currentId]);
        //memberCount = [Select Id From Campaign_Member_Host__c Where Campaign__c =: currentId];
        
        recs = memberCount.size();
       
        if(recs > 2500){
            loops = (recs / 2500);
        
            if(Math.mod(recs,2500) > 0){
                loops++;
            }
        }else{
            loops=1;
        }
        
        
        return loops;
    }

    /**
     * @param ids String
     * @description unknown
     * @return Pagereference
     */
    public Pagereference ExportMembers(String ids){
        
        Pagereference exportData = Page.CampaignMembersToExcel;
        exportData.getParameters().put(PARAM_NAME_MEMBERS_IDS,ids);
        exportData.getParameters().put('campId',currentId);
     
        return exportData;
        
    }

    /**
     * @description Method that will delete selected members from the campaign
     */
    public void RemoveMembers(){
          String tempMemberIds = memberIds();
        if(tempMemberIds.length() > 0)
        {
        Set<Id> checkedCont = new Set<Id>();
        
        for (CampaigHostsWrapper cw : memberResults){
            
            if (cw.checked){

                checkedCont.add(cw.memhost.Member__c);

            }
        }
        
        List<CampaignMember> delMem = [ select Id from CampaignMember where ContactId IN : checkedCont and CampaignId =: currentId];
        
        //Delete members. The trigger on CampaignMembers will take care if the members in the juction object and the hosts linked to them
        if(delMem.size() > 0){
        try{
            Database.DeleteResult[] sr = Database.delete(delMem, false);
        }catch(System.Dmlexception e){
                //ApexPages.addMessages(e);
                //Campaign is locked and the trigger generated an error. We do not use the Apexpage.addMessages() as this renders plain text
                //which are different from the std error message generated by the rigger.
                camLocked=true;
                System.debug('Deletion of Campain member(s) failed ' + e.getMessage());
                sendErrorMail('Deletion of Campain member(s) failed : CampaignMemberHostController.cls : RemoveMembers()' + e.getMessage());
          }
        }
        
      
            isNoMemberSelectedTrue =  false; 
            isblankSearchTrue = false;
            isnoSearchResultsTrue  = false;
            Load();
        }
        else
        {
            noMemberSelected = ErrorMessages__c.getValues('No_Host_Selected_ToRemove').Error_String__c ;
            isNoMemberSelectedTrue =  true;  
            isblankSearchTrue = false;
            isnoSearchResultsTrue  = false;
                    }
        
    }

    /**
     * @description Filter members based on selected picklist wave value
     */
    public void filterWave(){
        waveFilter = true;
        Load();
    }

    /**
     * @description Update the invitation wave of seleted memebers
     */
    public void updateWave(){
        
        if(!wave.equals('All')){
        
            if(wave.equals('None')){wave='';}
        
            
            Set<Id> memIds = new Set<Id>();
            
            
            for (CampaigHostsWrapper cw : memberResults){
                
                if (cw.checked){
                       
                       memIds.add(cw.memhost.Member__c);
                }
            }

            //Update Campaign wave of the campaign members, the trigger will sync the values to the junction object
           List<CampaignMember> cm = [select Id from CampaignMember where ContactId IN : memIds and CampaignId =: currentId];
            
            for(Integer x=0;x<cm.size();x++){
                cm[x].Campaign_Wave__c = wave;
            }
            if(cm.size() >0){
            try{
                Database.saveresult[] s = Database.update(cm, false);
             }catch(System.Dmlexception e){
                 //Campaign is locked and the trigger generated an error. We do not use the Apex{age.addMessages() as this renders plain text
                //which are different from the std error message generated by the rigger.
                camLocked=true;
                System.debug('Campaign Wave update on Campain Member failed ' + e.getMessage());
                sendErrorMail('Campaign Wave update on Campain Member failed : CampaignMemberHostController.cls : updateWave()' + e.getMessage());
             }
            }    
            Load();
        }
    }

    /**
     * @return PageReference
     * @description unknown
     */
    public PageReference Done() {
        //ApexPages.currentPage().
        Pagereference camp = new Pagereference ('/' + currentId);
        return camp;

        //return null;
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
       if (value == sortExp) {
           sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
       } else {
           sortDirection = 'ASC';
       }
       sortExp = value;
     }
   }

    /**
      * @return String
      * @description unknown
      */
     public String getSortDirection(){
        //if not column is selected 
        if (sortExpression == null || sortExpression == '') {
            return 'ASC';
        } else {
            return sortDirection;
        }
     }

    /**
     * @param value String
     * @description unknown
     */
    public void setSortDirection(String value){
       sortDirection = value;
     }           

    /**
     * @param msg String
     * @description Function that sends an email to the CRM production support
     *              team when an exception was thrown. Email address gets retrived from the
     *              custom settings Environment_Variable__c
     */
    public void sendErrorMail(String msg){ 

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {SupportEmailAddress};
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Apex Error in : ' + UserInfo.getOrganizationName());
        mail.setSubject('Apex Error related to Campaign Members');
        mail.setPlainTextBody('Error in Class: CampaignMemberTriggerFunctions\n' + msg);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    /**
     * @return Pagereference
     * @description unknown
     */
    public Pagereference backToRecordLightning() {
        return new Pagereference('/' + currentId);
    }

}