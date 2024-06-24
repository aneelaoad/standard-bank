/*****************************************************************************************************************************************************************************************************************
    @ Author        : Nitish Kumar
    @ Date          : 21-Sept-2013
    @ Test File     : TestClientPlanClass
    @ Description   : Client Plan Phase 1
    Test CI Sheldon	   
                     
                      The controller class for Client Plan and Client Plan PDF page.The controller class gathers information / data for a 
                      specific client from veriouse sourses. This data are then rendeder as a one pager PDF document. 
                      These are the following Inclusions of functionality in Client Plan :
                      - Attach documents from the Client Plan.
                      - Generate PDF document from the Client Plan.
                      - Enforce data that has been marked as required.
                      - The ability to change the currency between ZAR & USD on the Client Plan.
                      - The requirement to have pictures and attachments only where requested.
                      - Ability to roll out Client Plans to a selected number of clients for the pilot phase.
                      
                      The following sections and their sub-sections will be pushed from the Client page or detail related to the Client page:
                        o Client Description
                        o Client Strategy
                        o Client Contacts
                        o Current Relationship
                        o Client Services Team
                        o Key Tasks
                        o Client Engagement and Entertainment
                        o CIB Strategy
                        o Client and Subsidiary Pipelines
                        o Client Key Financial Data
                        o Key Indicators (Financial Analysis)
                        o Credit Lines
                        o Nature of Relationship (Tick box only)
                        o Client Wallet via Share of Wallet
                        
                        Users will have the ability to create from the Client Plan the following:
                        o Product Potential
                        o Client and Subsidiary Pipelines
                        o Key Tasks
  
    @ Enhancement   : EN -- 240 
    
    @ Last Modified By  : Nitish Kumar
    @ Last Modified On  : 04 Dec 2013
    @ Modification Description : EN-0263 : Strategic client planning - phase 2
    
    @ Last Modified By  : Prabhanshu Agrawal
    @ Last Modified On  : Jan 2015
    @ Modification Description : EN-590 : Client Plan Access to Role Hierarchy and Sector Manager

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Aug 11, 2015
    @ Modification Description : Force.com reviewer - Blocker and Critical issues - 20150608.xlsx

    @ Last Modified By  : Vishnu Vundavalli
    @ Last Modified On  : August 2015
    @ Modification Description : EN - 0791 : Renaming of New Personal and Business Banking Entity (Africa Only) to Potential Client and hence removing the reference

    @ Last Modified By  : Abhishek Vaideeswaran
    @ Last Modified On  : August 2015
    @ Modification Description : EN - 792 : Renaming of New Corporate and Investment Banking Entity (Africa) to Potential (CIF) and
                                            New Corporate and Investment Banking Entity (South Africa / International) to Potential (Goldtier)
                                            and hence removing the reference

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Oct 27, 2015
    @ Modification Description : EN-692 : Overall rating should be taken from the client record

    @ Last Modified By  : Petr Roubal
    @ Last Modified On  : Nov 24, 2015
    @ Modification Description : EN-939 : CSI - Client Plan PDF and Attach version

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Dec 11, 2015
    @ Modification Description : EN-928 : Added fetching of required fields (Commercial Banking Client Plan only)

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Dec 14, 2015
    @ Modification Description : EN-964 : Added sums for Opps (Commercial Banking Client Plan only)
    
    @ Last Modified By  : Abhishek V
    @ Last Modified On  : Jan 2016
    @ Modification Description : EN-686 : Client Plan Access to CIBROA CC South & Central Africa Mgt Public Group based on Client Reporting Franco

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Mar 1, 2016
    @ Modification Description : US-1177 : adjusting logic using ProductSubsets__c
    
    @ Last Modified By  : Jana Cechova
    @ Last Modified On  : Apr 14, 2016
    @ Modification Description : US-1282 : adjusting logic for CommB/CIB - Display appropriate error message when accessing unauthorized Client Plan the first time
    
    @ Last Modified By  : Andrei Olteanu
    @ Last Modified Date : Oct 25, 2016
    @ Modification Description : RI-0117 : Client Plan CurrencyISOCode not sent to other components, because record didn't exist in db
    
    @ Last Modified By  : Abhishek V
    @ Last Modified Date : Nov 08, 2016
    @ Modification Description : US - 1662 : Task Lightning fix

    @ Last Modified By  : Marko Dvečko
    @ Last Modified Date : March 13, 2017
    @ Modification Description : Adding new pdf template for attaching CommB client plan
    
******************************************************************************************************************************************************************************************************************/
/**
* @LastModifiedBy Emmanuel Mulea Nocks(BlueSky)
* @date Oct 2021
* @description add Business Banking PRH where commB is included and fix static code analysis
*/
global with sharing virtual class ClientPlanClass {

    private static Map<String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    private static Id prospectRecTypeId = mapAccountRecordTypes.get('Prospect').getRecordTypeId();
    private static Id potentialcifRecTypeId = mapAccountRecordTypes.get('Potential (CIF)').getRecordTypeId();
    private static Id potentialgtRecTypeId = mapAccountRecordTypes.get('Potential (Goldtier)').getRecordTypeId();
    private static Id potentialClientRTId = mapAccountRecordTypes.get('Potential Client').getRecordTypeId();
    private static Id commBClientRTId = mapAccountRecordTypes.get('Commercial Banking Client').getRecordTypeId();
    
    public Static ID ldstaskId{get; set;}
    public static boolean islightning{
        get{return ApexPages.currentPage().getParameters().get('Lightning') == 'True';}
        set;
    }
    public String ltngNewOppAddress {
        get{
            if (ltngNewOppAddress == null) {
                JSONGenerator generator = JSON.createGenerator(false);
                generator.writeStartObject();
                    generator.writeStringField('componentDef', 'c:Modal');
                    generator.writeFieldName('attributes');
                    generator.writeStartObject();
                        generator.writeStringField('component', 'c:NewOpportunity');
                        generator.writeFieldName('attributes');
                        generator.writeStartObject();
                            generator.writeStringField('recordId', currentId);
                            generator.writeStringField('sObjectName', 'Account');
                            generator.writeBooleanField('isQuickAction', false);
                generator.close();

                Blob base64Component = Blob.valueOf(generator.getAsString());
                ltngNewOppAddress = '/one/one.app?source=aloha#' + EncodingUtil.base64Encode(base64Component);
            }
            return ltngNewOppAddress;
        }
        private set;
    }

    // Standard Account Object
    private final Account acct;
    public Account accRecord{get; set;}
   // public Client_Plan__c cPlan{get;set;}
    //Global variables

    public String currentId; // Stores the Account Id
    public String currentUserId; // Stores the running user Id
    public string PRH;
    public Boolean isSubmitted;
    public Boolean isError; 
    public Boolean showingSaved;
    public Boolean showApprBtn{get;set;}
    public Boolean showApprFields{get;set;}
    public Boolean showApprStatus{get;set;}
    public Boolean enableApprButton{get;set;}
    public Client_Plan__c sObjClientPlan{get;set;}
    public Boolean canSubmitForApproval{get;set;}
    public List<ProcessInstance> lstProInstance{get;set;}
    public ProcessNode nodeStep{get;set;}
    public List<ProcessInstance> lstProcessInstance;
    public List < Client_Plan__c > clientPlanlst;
    public List<Id> newWorkItemIds{get;set;}
    public Boolean showError{get;set;}
    public boolean isInsertedClientPlan = false; // // US-1282 : adjusting logic for CommB/CIB - Display appropriate error message

    //component controller for exchange data between this controler and CsiComponentController
    public CsiComponentController csiComponentController { get; set; }
    /**
    * set Component Controller
    * @param compController
    */
    public void setComponentController(CsiComponentController compController) {
        csiComponentController = compController;
    }
    /**
    * Get client plan
    * @return ClientPlanClass
    */
    public ClientPlanClass getClientPlan(){
        return this; 
    }

    //private  List<Custom_Client_Team__c> CTList;

    public Boolean renderSelectedUGP { get { return (cwUGP != null && cwUGP.csi_client_name != null && cwUGP.csi_selected); } private set; }
    public Boolean renderImP { get { return cwsImPMap != null && cwsImPMap.size() > 0; } private set;}
    public Boolean renderChild { get { return cwsChildMap != null && cwsChildMap.size() > 0; } private set;}

    public CsiComponentController.CsiWrapper cwUGP{
        get{
            if(csiComponentController == null){
                //initialization for ClientPlanPDF
                csiComponentController = new CsiComponentController(currentId, this);
            }

            return csiComponentController.cwUGP;

        }
        private set;
    }

    public Map<Id, CsiComponentController.CsiWrapper> cwsImPMap{
        get{
            if(csiComponentController == null){
                //initialization for ClientPlanPDF 
                csiComponentController = new CsiComponentController(currentId, this);
            }
            Map<Id, CsiComponentController.CsiWrapper> selectedValues = new Map<Id, CsiComponentController.CsiWrapper>();
            for(CsiComponentController.CsiWrapper orgValue:  csiComponentController.cwsImPMap.values()){
                if(orgValue.csi_selected){
                    selectedValues.put(orgValue.csi_id, orgValue);
                }
            }
            return selectedValues;

        }
        private set;
    }

    public Map<Id, CsiComponentController.CsiWrapper> cwsChildMap{
        get{
            if(csiComponentController == null){
                //initialization for ClientPlanPDF
                csiComponentController = new CsiComponentController(currentId, this);
            }
            Map<Id, CsiComponentController.CsiWrapper> selectedValues = new Map<Id, CsiComponentController.CsiWrapper>();
            for(CsiComponentController.CsiWrapper orgValue:  csiComponentController.cwsChildMap.values()){
                if(orgValue.csi_selected){
                    selectedValues.put(orgValue.csi_id, orgValue);
                }
            }
            return selectedValues;

        }
        private set;

    }
   
    // Stores the Selected picklist value of Nature of Relationship
    public String selectedVal {
        get;
        set;
    } 
   
   // Stores all the names of Product for an open Opportunity
    public Map < Id, String > OppGPPMap {
        get;
        set;
    } 
    
    // Stores all the names of Product for a closed Opportunity
    public Map < Id, String > WonLostOppGPPMap {
        get;
        set;
    } 

    public String ISO = ''; // Stores the Currency ISO code of Client Plan Object
    
    // Stores the last modified date of Client plan object
    public date lastModifiedDate {
        get;
        set;
    } 
    
    //Stores the client name
    public String ClientName {
        get;
        set;
    } 
    
    // Stores the Client Plan name for an Account
    public String ClientPlanName {
        get;
        set;
    } 

    public String cPlanCurrency = 'South African Rand'; // Default Currency picklist value 
    public String cPlanCurrencyTop = 'South African Rand'; // Default Currency picklist value
    
    public List<CPTeamSelection> teamResults {get;set;}
    public List<CPTeamSelection> teamResultsCC {get;set;}
    public List<CPTeamSelection> teamResultsNotCC {get;set;}
    public List<CPTaskSelection> taskResults {get;set;}
    
    
  
   // List of Wrapper object for open Opportunity
    public List < cPlanOpportunity > oppResults {
        get;
        set;
    } 
    
    // List of Wrapper object for closed Opportunity
    public list < cPlanWonLostOpp > wonLostoppResults {
        get;
        set;
    } 
    
    public boolean clientPlanAccess {
        get;
        set;
    }
    
    public String clientPlanId {
        get;
        set;
    }
     public String clientPrimaryRelationshipHolder {
        get;
        set;
    }

    public String recordTypeId { get; private set; }

    public boolean hideProspect {
        get {
            if (recordTypeId == null) {
                return false;
            }
            if (new Set<Id>{prospectRecTypeId, potentialcifRecTypeId, potentialgtRecTypeId, potentialClientRTId}.contains(recordTypeId)) {
                return true;
            }
            return false;
        }
        set;
    }

    public Decimal overallRating { get; private set; }
    public String overallRatingIndicatorImageTag { get; private set; }
    public String surveyYear { get; private set; }

    /**
     Converts an image tag to name of the image file.
     Example, from:
     <img src="/resource/CamProducts/green-small.png" alt="status color" border="0"/>
     returns green-small.png
     */
    public String overallRatingIndicator {
        get {
            if (overallRatingIndicatorImageTag == null || overallRatingIndicatorImageTag == '') {
                return 'empty';
            }
            system.debug('#### overallRating=' + overallRatingIndicatorImageTag);

            Integer srcStarts = overallRatingIndicatorImageTag.indexOf('"') + 1;
            Integer srcEnds = overallRatingIndicatorImageTag.indexOf('"', srcStarts);

            String url = overallRatingIndicatorImageTag.substring(srcStarts, srcEnds);

            Integer lastSlashStarts = url.lastIndexOfIgnoreCase('/') + 1;
            Integer endOfString = url.length();

            return url.substring(lastSlashStarts, endOfString);
        }
        private set;
    }

    public Map < String, Double > RateMap = new Map < String, Double > (); // Map for storing Currency code as key and rate of conversion as value
    public List < CurrencyType > CurrTable = new List < CurrencyType > (); //List of object used in Currency conversion

    //Storing the Client Plan Object 
    public Client_Plan__c[] cPlan = new Client_Plan__c[1];
    
    public Boolean disableEdit {get;set;}

    // Constructor
    /**
    * Creating constructor
    @param controller
    */
    Public ClientPlanClass(ApexPages.StandardController controller) {
        if (!Test.isRunningTest()) {
            //Adding these fields to avoid additional SOQL query.
            controller.addFields(new List < String > {
                'name', 'CurrencyIsoCode', 'Nature_of_Relationship__c',
                'Overall_CIB_CSI_Rating_Number__c', 'Overall_CIB_CSI_Rating_Indicator__c', 'RecordTypeId', 'Survey_Year__c',
                'Primary_Relationship_Holder__c', 'Commercial_Tier__c', 'Portfolio_Type__c', 'Market_Segments__c'
            });
        }

        //Setting the public variables       
        this.acct = (Account) controller.getRecord();
        this.currentId = this.acct.Id;
        this.PRH = this.acct.Primary_Relationship_Holder__c;
        this.currentUserId = UserInfo.getUserId();
        this.ClientName = this.acct.Name;
        this.selectedVal = this.acct.Nature_of_Relationship__c;
        this.cPlan = [Select Id, LastModifiedDate, CurrencyIsoCode,Task_Selection__c ,Opportunity_Selection__c,Team_Selection__c, CSI_Selection__c, Name, Client_Name__c,Client_Plan_Status__c from Client_Plan__c where Client_Name__c = : currentId order By LastModifiedDate desc limit 1];
        if (!cPlan.isEmpty()){
         clientPlanId = cPlan[0].Id ;
         ClientPlanName = cPlan[0].Name ;
         lastModifiedDate = date.newinstance(cPlan[0].LastModifiedDate.year(), cPlan[0].LastModifiedDate.month(), cPlan[0].LastModifiedDate.day());
        }
        
        disableEdit= false;
        showApprBtn = false;
        showApprFields=false;
        enableApprButton=false;
        showError = false;
        hideProspect = false;

        this.recordTypeId = this.acct.recordTypeId;
        this.overallRating = this.acct.Overall_CIB_CSI_Rating_Number__c;
        this.overallRatingIndicatorImageTag = this.acct.Overall_CIB_CSI_Rating_Indicator__c;
        this.surveyYear = this.acct.survey_year__c;

        //Get the currency conversion rates
        snapCurrencyTable();
        
        Apexpages.currentPage().getHeaders().put('X-UA-Compatible', 'IE=edge');
        
        this.clientPrimaryRelationshipHolder = this.acct.Primary_Relationship_Holder__c;

    } 

    /**
    * Creating constructor that sets necessary values for check permission functionality, so that the class can be used in Visualforce Components and Pages without having
    having a standard controller
    @param clientId
    */
    public ClientPlanClass(Id clientId) {

        this.currentId = clientId;
        this.currentUserId = UserInfo.getUserId();
        this.cPlan = [Select Id from Client_Plan__c where Client_Name__c = : currentId order By LastModifiedDate desc limit 1];
        if (!cPlan.isEmpty()){
         clientPlanId = cPlan[0].Id ;
        }
        
        disableEdit= false;
    }
        
     //Check Current UserRole to Control Access to the Client Plan
      public Boolean checkPermission { get {
          // US-1282 : adjusting logic for CommB/CIB - Display appropriate error message
          Schema.DescribeSObjectResult d =
                  Client_Plan__c.sObjectType.getDescribe();
          list<userRecordAccess> lstEditAccess = [SELECT recordId, hasEditAccess from userRecordAccess WHERE recordId = :currentId AND UserId = :currentUserId];

          if (clientPlanId == null && (!d.iscreateable() || (lstEditAccess.size() > 0 && lstEditAccess[0].hasEditAccess != true))) {
              return false;
          }

          List<Id> teamMembersIds = new List<Id>();

          for (AccountShare acctShare : [SELECT Id from AccountShare WHERE AccountAccessLevel = 'Edit' AND AccountId = :currentId AND RowCause = 'Manual' AND UserOrGroupId = :currentUserId]) {
              return true;
          }
          for (AccountTeamMember teamMember : [Select UserId From AccountTeamMember Where AccountId = :currentId]) {
              if (userInfo.getUserId() == teamMember.UserId) {
                  return true;
              }
          }

          //Get current user Profile
          List<Profile> p = [Select Name From Profile Where Id = :UserInfo.getProfileId()];

          if (p.size() > 0) {
              if ((p[0].Name == 'System Administrator') || (p[0].Name == 'Business Administrator')) {
                  return true;
              }
          }

          list<PermissionSetAssignment> pset = [SELECT Id,Assignee.Id, Assignee.Name, PermissionSet.Name FROM PermissionSetAssignment WHERE PermissionSet.Name = 'Client_Plan_Access'];

          Set<Id> userSet = new Set<Id>();

          for (PermissionSetAssignment ps : pset) {
              userSet.add(ps.AssigneeId) ;
          }


          if (userSet.contains(currentUserId)) {
              disableEdit = true ;
              return true ;
          }

          if (check_Permission_for_role_hierarchy()) {
              return true;
          }
        if(check_Permission_for_sector_manager()) {
            return true;
        }
            
        if(check_Permission_for_client_reporting_franco()){
            return true;
        }
          
        return false;
        }  private set;
    } 
    
    /******************************************************************************************************
             * @author :- Prabhanshu Agrawal
             * @date  :-  Jan -2015
             * @description :- method which checks for the role hierarchy permission according to En - 590
             * @param :- N/A
             * @return :- Boolean
    *******************************************************************************************************/
    public Boolean check_Permission_for_role_hierarchy() {
        
        //list to hold the CST memeber
        list<Custom_Client_Team__c> clientTeam = new list<Custom_Client_Team__c>();
        //list to hold the Id of cc and ccbm
        list<Id> ccCcbm = new list<Id>();

        clientTeam = [SELECT
            Team_Member__r.Name,
            Team_Member__r.Id,
            Client_Role__c,
            Client_Coordinator__c,
            Client_Coordinator_BM__c
            FROM Custom_Client_Team__c
            Where Account__c = : currentId
            ORDER BY TeamRoleSortValue__c ASC
            LIMIT 500
        ];
        
        for(Custom_Client_Team__c c : clientTeam){
            if(c.Client_Coordinator__c) {
                ccCcbm.add(c.Team_Member__r.Id);
            }
            else if(c.Client_Coordinator_BM__c) {
                ccCcbm.add(c.Team_Member__r.Id);
            }
        }
        
        //call to the function which checks if logged in user is up the role hierarchy in the list of user
        return RoleUtility.isManagerOfUsers(ccCcbm, UserInfo.getUserId());
    }    

    /******************************************************************************************************
             * @author :- Prabhanshu Agrawal
             * @date  :-  Jan -2015
             * @description :- method which checks for the sector manager permission according to En - 590
             * @param :- N/A
             * @return :- Boolean
    *******************************************************************************************************/
    public Boolean check_Permission_for_sector_manager() {
        
        //map to store the custom settings which maps sub sector to the public group
        Map<String, Sub_Sector_to_Public_Group__c> subsectorgroupmap = Sub_Sector_to_Public_Group__c.getAll();
        //map to store the Group Name to its Id
        Map<String, Id> groupmap = new Map<String, Id>();
        //list to hold the list of group Id
        list<Id> groupIdlst = new list<Id>();
        //lsit to store the members of group
        list<GroupMember> groupmemb = new list<GroupMember>();

        Account client = [Select Id, Name, Client_Sector__c, Client_Sub_Sector__c from Account where Id =: currentId];
        
        for(Group g : [Select Id, Name from Group]) {
            groupmap.put(g.Name, g.Id);
        }
        
        for(Sub_Sector_to_Public_Group__c sect : subsectorgroupmap.values()){
            if(sect.Sub_Sector__c == client.Client_Sub_Sector__c) {
                groupIdlst.add(groupmap.get(sect.Sub_Sector_s_Public_Group__c));
            }
        }       
        
        groupmemb = [Select GroupId, UserOrGroupId from GroupMember where GroupId IN : groupIdlst];
        
        //if the logged in User is in the public group than grant access to the user
        for(GroupMember gm : groupmemb){
            if(UserInfo.getUserId() == gm.UserOrGroupId){
                return true;
            }   
        }
        
        return false;
    }

    /******************************************************************************************************
             * @author :- Abhishek V
             * @date  :-  Feb - 2016
             * @description :- method which checks for the Client Reporting Franco permission according to En - 686
             * @param :- N/A
             * @return :- Boolean
    *******************************************************************************************************/
    public Boolean check_Permission_for_client_reporting_franco() {
        
        //map to store the custom settings which maps sub sector to the public group
        Map<String, Reporting_Franco_to_Public_Group__c> francogroupmap = Reporting_Franco_to_Public_Group__c.getAll();
        //map to store the Group Name to its Id
        Map<String, Id> groupmap = new Map<String, Id>();
        //list to hold the list of group Id
        list<Id> groupIdlst = new list<Id>();
        //lsit to store the members of group
        list<GroupMember> groupmemb = new list<GroupMember>();

        Account client = [Select Id, Name, Client_Franco__c from Account where Id =: currentId];
        
        for(Group g : [Select Id, Name from Group]) {
            groupmap.put(g.Name, g.Id);
        }
        
        for(Reporting_Franco_to_Public_Group__c fran : francogroupmap.values()){
            if(fran.Client_Reporting_Franco__c == client.Client_Franco__c) {
                groupIdlst.add(groupmap.get(fran.Public_Group_Name__c));
            }
        }       
        
        groupmemb = [Select GroupId, UserOrGroupId from GroupMember where GroupId IN : groupIdlst];
        
        //if the logged in User is in the public group than grant access to the user
        for(GroupMember gm : groupmemb){
            if(UserInfo.getUserId() == gm.UserOrGroupId){
                return true;
            }   
        }
        
        return false;
    }

    /**
    * Creating default constructor so that the class can be used in Visualforce Components and Pages without having having a standard controller
    */
    public ClientPlanClass() {}

    /**
             * @author :- Nitish Kumar
             * @date  :-  Sept -2013
             * @description :- Public void method which creates the Client Plan record when the user clicks on the Client Plan button for the first time.
                               It also creates the Product potential object records.The default selection of Product potential records are selected as 
                               not on track.
             * @param :- N/A
             * @return :- Void
       */
    public PageReference checkClientPlan() {

        //local variables for storing Client plan list.
        list < Client_Plan__c > cpList = new list < Client_Plan__c > ();
       // clientPlanlst = new list < Client_Plan__c > ();

        //local variable for storing Product Potential list.
        List < Product_Potential__c > prodPotentialList = new List < Product_Potential__c > ();
        List < Product_Potential__c > prodPotentialListToDelete = new List < Product_Potential__c > ();

        //Getting the custom setting record in a map
        Map < string, ProductSubsets__c > prodSubsetMap = new Map < string, ProductSubsets__c > ();
        for (ProductSubsets__c ps: ProductSubsets__c.getall().values()) {
            prodSubsetMap.put(ps.parent_product__c + '#' + ps.product_division__c, ps);
        }

        //Variable which stores the Account Id
        Id clientid = ApexPages.currentPage().getParameters().get('id');


        try {
            clientPlanlst = [Select Id, LastModifiedDate, Client_Plan_Views__c, CurrencyIsoCode, Name from Client_Plan__c where Client_Name__c = : currentId order By LastModifiedDate desc limit 1];
        }
        Catch(Exception ex) {}

        //Checking the list size. If there are no Client Plan records , create the Client Plan record.
        If(clientPlanlst.size() == 0) {

            lastModifiedDate = date.today();
            ClientPlanName = ClientName + ' Plan';

            Client_Plan__c cp = new Client_Plan__c();
            cp.Client_Name__c = currentId;
            cp.CurrencyIsoCode = 'ZAR';
            cp.Name = ClientName + ' Plan';
            cp.Client_Plan_Views__c = 1;
            cpList.add(cp);
            
            // US-1282 : adjusting logic for CommB/CIB - Display appropriate error message
            Schema.DescribeSObjectResult d = 
            Client_Plan__c.sObjectType.getDescribe();
            Database.saveresult[] s;
            if( d.iscreateable()){  
                s = Database.insert(cpList, false);
                clientPlanId = cpList[0].Id;
                isInsertedClientPlan = true;
            }
        }

        //If the client plan records already exists get the last modified date from the client plan record.
        else {
                clientPlanlst[0].Name = ClientName + ' Plan';
                if(clientPlanlst[0].Client_Plan_Views__c == NULL){
                clientPlanlst[0].Client_Plan_Views__c = 0;
                }
                clientPlanlst[0].Client_Plan_Views__c += 1;
                try{
                        
                Update clientPlanlst[0] ;
                }
                Catch (Exception ex){}
            
            lastModifiedDate = date.newinstance(clientPlanlst[0].LastModifiedDate.year(), clientPlanlst[0].LastModifiedDate.month(), clientPlanlst[0].LastModifiedDate.day());
            ClientPlanName = ClientName + ' Plan';
        }
        
        if(isInsertedClientPlan){ // US-1282 : adjusting logic for CommB/CIB - Display appropriate error message
                acct.ApprovalProcessId__c = clientPlanId;
            try{
                update acct;
            }
            catch(exception e){
                
            }
        }

        /*******************Product Potential Logic******************************/

        prodPotentialList = [SELECT Client__c, Product_Division__c, Product_Potential__c, Product_Subset__c
            FROM Product_Potential__c
            WHERE Client__c = : clientid
            Order BY Product_Subset__c];
                Map<String, Product_Potential__c> mpProdPot = new Map<String, Product_Potential__c>();
        //Checking the list size                      
        if (prodPotentialList.isEmpty()) {
            for (ProductSubsets__c ps: prodSubsetMap.Values()) {
                Product_Potential__c ppRec = new Product_Potential__c();
                ppRec.Client__c = clientid;
                ppRec.Product_Division__c = ps.Product_Division__c;
                ppRec.Product_Subset__c = ps.parent_product__c;
                prodPotentialList.add(ppRec);
            }
        }else{
                
                for(Product_Potential__c pp: prodPotentialList){
                        mpProdPot.put(pp.Product_Subset__c + '#' + pp.Product_Division__c,pp);
                        if(!prodSubsetMap.containsKey(pp.Product_Subset__c + '#' + pp.Product_Division__c)){
                                        prodPotentialListToDelete.add(pp);
                    }
                }
                if(!mpProdPot.keySet().containsAll(prodSubsetMap.keySet())){
                        for(ProductSubsets__c ps: prodSubsetMap.Values()){
                                if(!mpProdPot.containsKey(ps.parent_product__c + '#' + ps.product_division__c)){
                                        Product_Potential__c ppRec = new Product_Potential__c();
                                        ppRec.Client__c = clientid;
                                        ppRec.Product_Division__c = ps.Product_Division__c;
                                        ppRec.Product_Subset__c = ps.parent_product__c;
                                        prodPotentialList.add(ppRec);
                                }
                     }
                } 
        }
        try {
                if(prodPotentialList.size()>0) {
                    upsert prodPotentialList;
                }
                if(prodPotentialListToDelete.size()>0) {
                    delete prodPotentialListToDelete;
                }
        } catch (DmlException e) {
            system.debug('Error in Upserting the initial records in Product_Potential__c in ProductPotential class');
        }
        
        if(isInsertedClientPlan) {
            String returnUrl = '/apex/ClientPlan';
            if(acct.Primary_Relationship_Holder__c == DMN_Account.PRIMARY_REL_HOLDER_COMMB ||
                    acct.Primary_Relationship_Holder__c == DMN_Account.PRIMARY_REL_HOLDER_BUSINESS) {
                returnUrl += 'CommB';
            }
            returnUrl += '?scontrolCaching=1&id=' + acct.Id;
            return new PageReference(returnUrl);
        }
        showApprovalButton();
        return null;
        /********************End of Product Potential Logic**************************/
    }


    /**
     * @author :- Nitish Kumar
     * @date  :-  Sept -2013
     * @description :- Public list method which gets the Client team records to be shown on Client Plan page
     * @param :- N/A
     * @return :- List of Custom_Client_Team__c
     */
    public List < CPTeamSelection > getClientTeam() {
        
      if (teamResults == null) {
            teamResults = new List<CPTeamSelection>();
        }else {
            teamResults.clear();
        }
        
         Set<Id> selectedTeamIds = new Set<Id>();
             
           if (!cPlan.isEmpty()){
            if(cPlan[0].Team_Selection__c != null){
                
                String[] teamIds = cPlan[0].Team_Selection__c.split(',');
                
                for(Integer x=0;x<teamIds.size();x++){
                selectedTeamIds.add(Id.valueOf(teamIds[x]));
                }
             }
            }

        Custom_Client_Team__c[] clientTeam = [SELECT
            Team_Member__r.Name,
            Team_Member__r.Id,
            Client_Role__c,
            Client_Coordinator__c,
            Client_Coordinator_BM__c,
            User_Division__c,
            User_Country__c
            FROM Custom_Client_Team__c
            Where Account__c = : currentId and
            Id IN : selectedTeamIds 
            ORDER BY TeamRoleSortValue__c ASC
            LIMIT 500
        ];
        
         for(Custom_Client_Team__c t : clientTeam){
            
            CPTeamSelection tm = new CPTeamSelection(t);
            tm.checked = true;  
            teamResults.add(tm);
          }
          
           Custom_Client_Team__c[] clientTeamNotSelected = [SELECT
            Team_Member__r.Name,
            Team_Member__r.Id,
            Client_Role__c,
            Client_Coordinator__c,
            Client_Coordinator_BM__c,
            User_Division__c,
            User_Country__c
            FROM Custom_Client_Team__c
            Where Account__c = : currentId and
            Id NOT IN : selectedTeamIds 
            ORDER BY TeamRoleSortValue__c ASC
            LIMIT 500
        ];
        
         for(Custom_Client_Team__c t : clientTeamNotSelected){
            
            CPTeamSelection tm = new CPTeamSelection(t);
            tm.checked = false;
            teamResults.add(tm);
        }

        return teamResults;

    }
    /**
    * get Csi Selecton
    * @return List<Id>
    */
    public List<Id> getCsiSelecton(){



        List<id> csiSelectedRecords = new List<Id>();

        if (!cPlan.isEmpty()){
            if(cPlan[0].CSI_Selection__c != null){

                String[] csiIds = cPlan[0].CSI_Selection__c.split(',');

                for(Integer x=0; x<csiIds.size(); x++){
                    csiSelectedRecords.add(Id.valueOf(csiIds[x]));
                }
            }
        }

        return csiSelectedRecords;
    }
    /**
    * save Team Selections
    */
    public void saveTeamSelections(){
            
            String teamIdSelected = '';
            
            for (CPTeamSelection tm : teamResults){
                if (tm.checked){
                    teamIdSelected = teamIdSelected + ',' + tm.team.Id;
                }  
            }
           
            if(teamIdSelected.startsWith(',')){
                teamIdSelected = teamIdSelected.substring(1,teamIdSelected.length());
            }
           
            if (!cPlan.isEmpty()){
            cPlan[0].Team_Selection__c = teamIdSelected;
            }
                
    }

    /**
     * @author :- Petr Roubal
     * @date  :-  Nov 2015
     * @description :- Public method which gets the CSI record to be shown on Client Plan Pdf page
     * @param :- N/A
     */
    public void saveCsiSelection(){
        if (csiComponentController == null) {
            return;
        }

        List<Id> idSelectedRecords = csiComponentController.saveSelectedCSI();

        String csiIdSelected = '';

        for (integer i=0; i < idSelectedRecords.size(); i++){
            csiIdSelected += idSelectedRecords[i];
            csiIdSelected += (i ==  idSelectedRecords.size()-1) ?  + '' :  + ',';
        }
        system.debug('##### cPlan[0] ' + cPlan[0] + ' csiIdSelected='+csiIdSelected );
        if (!cPlan.isEmpty()){
            cPlan[0].CSI_Selection__c = csiIdSelected;
        }

    }
    
              /**
             * @author :- Nitish Kumar
             * @date  :-  Oct -2013
             * @description :- Public list method which gets the CC record to be shown on Client Plan Pdf page
             * @param :- N/A
             * @return :- List of Custom_Client_Team__c
             */
            public List < Custom_Client_Team__c > getClientTeamCC() {
            
           
           Set<Id> selectedCCId = new Set<Id>();
             
           if (!cPlan.isEmpty()){
            if(cPlan[0].Team_Selection__c != null){
                
                String[] teamIds = cPlan[0].Team_Selection__c.split(',');
                
                for(Integer x=0;x<teamIds.size();x++){
                selectedCCId.add(Id.valueOf(teamIds[x]));
                }
             }
            }
             
                Custom_Client_Team__c[] clientTeamCC = [SELECT
                    Team_Member__r.Name,
                    Team_Member__r.Id,
                    Client_Role__c,
                    Client_Coordinator__c,
                    Client_Coordinator_BM__c,
                    User_Division__c,
                    User_Country__c
                    FROM Custom_Client_Team__c
                    Where Account__c = : currentId
                    AND Client_Coordinator__c = true
                    AND Id IN : selectedCCId 
                    ORDER BY TeamRoleSortValue__c ASC
                    LIMIT 500
                ];
               
              
                return clientTeamCC;
        
            }
    
              /**
             * @author :- Nitish Kumar
             * @date  :-  Oct -2013
             * @description :- Public list method which gets the non CC record to be shown on Client Plan Pdf page
             * @param :- N/A
             * @return :- List of Custom_Client_Team__c
             */
            public List < Custom_Client_Team__c > getClientTeamNotCC() {
            
           
            Set<Id> selectedCCId = new Set<Id>();
             
           if (!cPlan.isEmpty()){
            if(cPlan[0].Team_Selection__c != null){
                
                String[] teamIds = cPlan[0].Team_Selection__c.split(',');
                
                for(Integer x=0;x<teamIds.size();x++){
                selectedCCId.add(Id.valueOf(teamIds[x]));
                }
             }
            }
        
                Custom_Client_Team__c[] clientTeamnotCC = [SELECT
                    Team_Member__r.Name,
                    Team_Member__r.Id,
                    Client_Role__c,
                    Client_Coordinator__c,
                    Client_Coordinator_BM__c,
                    User_Division__c,
                    User_Country__c
                    FROM Custom_Client_Team__c
                    Where Account__c = : currentId
                    AND Client_Coordinator__c = false
                    AND Id IN : selectedCCId 
                    ORDER BY TeamRoleSortValue__c ASC
                    LIMIT 500
                ];
        
                return clientTeamnotCC;
        
            }


    /**
             * @author :- Nitish Kumar
             * @date  :-  Oct -2013
             * @description :- Public date method which gets and sets the Snapshote date to be shown on GLobal Client Revenue section of
                               Client Plan page.
             * @param :- N/A
             * @return :- Date Snapshot_Date__c
       */
    public date snapshotDate {
        get {
            try {
                if (currentId != null || currentId != '') {
                    AggregateResult[] theSnapshotDate = ([SELECT
                        Max(Snapshot_Date__c) SnapshotDate
                        FROM
                        Global_Client_Revenue__c
                        WHERE
                        Client__c = : currentId
                        AND RecordType.Name = 'Current & Previous Year'
                    ]);
                    return (Date) theSnapshotDate[0].get('SnapshotDate');
                }
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + ' thrown in: ' + e.getStackTraceString()));
            }
            return Date.today();
        }
        private set;
    } {
        snapshotDate = Date.today();
    }
    
        public date snapshotDateCreditLine {
        get {
            try {
                if (currentId != null || currentId != '') {
                    AggregateResult[] theSnapshotDate = ([SELECT
                        Max(Snapshot_Date__c) SnapshotDate
                        FROM
                        Credit_Line__c
                        WHERE
                        Client_Name__c = : currentId
                        ]);
                    return (Date) theSnapshotDate[0].get('SnapshotDate');
                }
            } catch (Exception e) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage() + ' thrown in: ' + e.getStackTraceString()));
            }
            return Date.today();
        }
        private set;
    } {
        snapshotDateCreditLine = Date.today();
    }

    public Decimal openOppCYRevSum { get; private set; } {
        openOppCYRevSum = 0.0;
    }

    public Decimal openOppTotalRevSum { get; private set; } {
        openOppTotalRevSum = 0.0;
    }

    public Decimal closedOppCYRevSum { get; private set; } {
        closedOppCYRevSum = 0.0;
    }

    public Decimal closedOppTotalRevSum { get; private set; } {
        closedOppTotalRevSum = 0.0;
    }

    /**
             * @author :- Nitish Kumar
             * @date  :-  Sept -2013
             * @description :- Public list method which gets the open Opportunity records to be shown on Client Plan page.
                               Also does the currency conversion of Currency fields based on the currency selected on Client plan.
             * @param :- N/A
             * @return :- List of cPlanOpportunity (Wrapper Object for open Opportunities)
       */
    public List < cPlanOpportunity > getOpportunitylst() {
         if(!isInsertedClientPlan && clientPlanId == null){  // US-1282 : adjusting logic for CommB/CIB - Display appropriate error message
            return null;
         }

        //Calling the Currency convertor method
        currencyConverter converter = new currencyConverter();

        //local variables used in currency conversion
        Decimal trev = 0.0;
        Decimal rev = 0.0;
        Decimal revcurr = 0.0;

        //local variables used for getting the names of all the Grand parent product for an open Opportunity
        Set < Id > opportunityIdSet = new Set < Id > ();
        Set < Id > noSelectionOpportunityIdSet = new Set < Id > ();
        OppGPPMap = new Map < Id, String > ();

        openOppCYRevSum = 0.0;
        openOppTotalRevSum = 0.0;

        //Checking the list of Wrapper object for open Opportunity
        if (oppResults == null) {
            oppResults = new List < cPlanOpportunity > ();
        }
        
        Set<Id> selectedOppIds = new Set<Id>();
        
        if (!cPlan.isEmpty()){
         if(cPlan[0].Opportunity_Selection__c != null){
            
            String[] oppIds = cPlan[0].Opportunity_Selection__c.split(',');
            
            for(Integer x=0;x<oppIds.size();x++){
                selectedOppIds.add(Id.valueOf(oppIds[x]));
            }
          }
        } 

        // Selected Opportunity Section
        
        Opportunity[] opportunitylst = [Select Name, Owner.Name, Account.ParentId, Probability, ExpectedRevenue,
            Current_Year_Revenue_Num__c, AccountId, Account.name, Account.Owner.Name,
            Account.CRT_Client_Types__c, Account.CIF__c, StageName, Current_Year_Revenue_Currency__c,
            Priority__c, Opportunity_Sector__c, CloseDate, Amount, Short_Summary__c, OwnerId, Opportunity_Owner_Lookup__r.Name,
            Actual_Close_Date__c, CurrencyIsoCode, Type, Current_Year_Revenue__c, Total_Revenue_Num__c
            From Opportunity where(Account.Id = : currentId OR Account.ParentId = : currentId OR Account.Group_Parent__c = : currentId)
            AND(IsClosed = False AND StageName NOT IN('4 - Closed Lost', 'Closed Lost', 'Closed Won', '3 - Closed Won','Cancel'))
            And Id In : selectedOppIds
            order by probability desc , ExpectedRevenue desc nulls last limit 500
        ];

        //Storing the Opportunity Id in the set                                      
        for (Opportunity opp: opportunitylst) {
            opportunityIdSet.add(opp.Id);
        }

        //Soql query for getting all the GPP for open opportunities                                        
        SB_Product__c[] productlst = [Select Id, Name, Opportunity__c,Opportunity__r.Id, Grand_Parent_Product__c from SB_Product__c Where Opportunity__c = : opportunityIdSet Order by Opportunity__c asc];
        

        //Storing the Opporunity Id as key and the Product names(seperated by comma) as value.
                 
            
            for (Opportunity opp2 : opportunitylst){
                
               String strGPP = '';
              
                 for (SB_Product__c prod: productlst) {
                    If (prod.Opportunity__c == opp2.Id){
                    if (strGPP == '') {
                        strGPP = prod.Grand_Parent_Product__c;
                    }
                    else {
                        strGPP = strGPP + ',' + prod.Grand_Parent_Product__c;
                    }
                    }
                 }
                  OppGPPMap.put(opp2.Id, strGPP);
               
               
        }

       // Populating the list of Opportunity wrapper object which stores the converted cuurency values
        for (Opportunity o: opportunitylst) {
            
            if (!cPlan.isEmpty()){
            cPlanOpportunity cp = new cPlanOpportunity(o);
            cp.checked = true;
            trev = converter.convert(Double.valueOf(o.ExpectedRevenue), String.valueOf(o.CurrencyIsoCode), RateMap, cPlan[0].CurrencyIsoCode);
            cp.totalRev = trev.divide(1000, 2);
            rev = converter.convert(Double.valueOf(o.Current_Year_Revenue__c), String.valueOf(o.CurrencyIsoCode), RateMap, cPlan[0].CurrencyIsoCode);
            cp.currentRev = rev.divide(1000, 2);
            revcurr = converter.convert(Double.valueOf(o.Current_Year_Revenue_Currency__c), String.valueOf(o.CurrencyIsoCode), RateMap, cPlan[0].CurrencyIsoCode);
            cp.currentRevcurr = revcurr.divide(1000, 2);

            openOppCYRevSum += cp.currentRev;
            openOppTotalRevSum += cp.totalRev;

            oppResults.add(cp);
            }
            else{
            cPlanOpportunity cp = new cPlanOpportunity(o);
            cp.checked = true ;
            trev = converter.convert(Double.valueOf(o.ExpectedRevenue), String.valueOf(o.CurrencyIsoCode), RateMap, 'ZAR');
            cp.totalRev = trev.divide(1000, 2);
            rev = converter.convert(Double.valueOf(o.Current_Year_Revenue__c), String.valueOf(o.CurrencyIsoCode), RateMap, 'ZAR');
            cp.currentRev = rev.divide(1000, 2);
            revcurr = converter.convert(Double.valueOf(o.Current_Year_Revenue_Currency__c), String.valueOf(o.CurrencyIsoCode), RateMap, 'ZAR');
            cp.currentRevcurr = revcurr.divide(1000, 2);

            openOppCYRevSum += cp.currentRev;
            openOppTotalRevSum += cp.totalRev;

            oppResults.add(cp);
             
           }
        }
        
        // Not selected Opportunity Section
        
         Opportunity[] noSelectionOpportunitylst = [Select Name, Owner.Name, Account.ParentId, Probability, ExpectedRevenue,
            Current_Year_Revenue_Num__c, AccountId, Account.name, Account.Owner.Name,
            Account.CRT_Client_Types__c, Account.CIF__c, StageName, Current_Year_Revenue_Currency__c,
            Priority__c, Opportunity_Sector__c, CloseDate, Amount, Short_Summary__c, OwnerId, Opportunity_Owner_Lookup__r.Name,
            Actual_Close_Date__c, CurrencyIsoCode, Type, Current_Year_Revenue__c, Total_Revenue_Num__c
            From Opportunity where(Account.Id = : currentId OR Account.ParentId = : currentId OR Account.Group_Parent__c = : currentId)
            AND(IsClosed = False AND StageName NOT IN('4 - Closed Lost', 'Closed Lost', 'Closed Won', '3 - Closed Won','Cancel'))
            And Id Not IN : selectedOppIds
            order by probability desc , ExpectedRevenue desc nulls last limit 500
        ];

        //Storing the Opportunity Id in the set                                      
        for (Opportunity opp: noSelectionOpportunitylst) {
            noSelectionOpportunityIdSet.add(opp.Id);
        }

        //Soql query for getting all the GPP for open opportunities                                        
        SB_Product__c[] productlst2 = [Select Id, Name, Opportunity__c,Opportunity__r.Id, Grand_Parent_Product__c from SB_Product__c Where Opportunity__c = : noSelectionOpportunityIdSet Order by Opportunity__c asc];
        

        //Storing the Opporunity Id as key and the Product names(seperated by comma) as value.
                 
            
            for (Opportunity opp2 : noSelectionOpportunitylst){
                
               String strGPP = '';
              
                 for (SB_Product__c prod: productlst2) {
                    If (prod.Opportunity__c == opp2.Id){
                    if (strGPP == '') {
                        strGPP = prod.Grand_Parent_Product__c;
                    }
                    else {
                        strGPP = strGPP + ',' + prod.Grand_Parent_Product__c;
                    }
                    }
                 }
                  OppGPPMap.put(opp2.Id, strGPP);
               
               
        }

       // Populating the list of Opportunity wrapper object which stores the converted cuurency values
        for (Opportunity o: noSelectionOpportunitylst) {
           
            if (!cPlan.isEmpty()){
            cPlanOpportunity cp = new cPlanOpportunity(o);
            cp.checked = false ;
            trev = converter.convert(Double.valueOf(o.ExpectedRevenue), String.valueOf(o.CurrencyIsoCode), RateMap, cPlan[0].CurrencyIsoCode);
            cp.totalRev = trev.divide(1000, 2);
            rev = converter.convert(Double.valueOf(o.Current_Year_Revenue__c), String.valueOf(o.CurrencyIsoCode), RateMap, cPlan[0].CurrencyIsoCode);
            cp.currentRev = rev.divide(1000, 2);
            revcurr = converter.convert(Double.valueOf(o.Current_Year_Revenue_Currency__c), String.valueOf(o.CurrencyIsoCode), RateMap, cPlan[0].CurrencyIsoCode);
            cp.currentRevcurr = revcurr.divide(1000, 2);

            openOppCYRevSum += cp.currentRev;
            openOppTotalRevSum += cp.totalRev;

            oppResults.add(cp);
            }
            else{
            cPlanOpportunity cp = new cPlanOpportunity(o);
            cp.checked = false ;
            trev = converter.convert(Double.valueOf(o.ExpectedRevenue), String.valueOf(o.CurrencyIsoCode), RateMap, 'ZAR');
            cp.totalRev = trev.divide(1000, 2);
            rev = converter.convert(Double.valueOf(o.Current_Year_Revenue__c), String.valueOf(o.CurrencyIsoCode), RateMap, 'ZAR');
            cp.currentRev = rev.divide(1000, 2);
            revcurr = converter.convert(Double.valueOf(o.Current_Year_Revenue_Currency__c), String.valueOf(o.CurrencyIsoCode), RateMap, 'ZAR');
            cp.currentRevcurr = revcurr.divide(1000, 2);

            openOppCYRevSum += cp.currentRev;
            openOppTotalRevSum += cp.totalRev;

            oppResults.add(cp);
             
           }
        }
        

        return oppResults;

    }
    /**
    * get Selected Opportunity List
    * @return List < cPlanOpportunity >
    */
      public List < cPlanOpportunity > getSelectedOpportunitylst() {
                 if(!isInsertedClientPlan && clientPlanId == null){ // US-1282 : adjusting logic for CommB/CIB - Display appropriate error message
                    return null;
                }
        
                 //Calling the Currency convertor method
                currencyConverter converter = new currencyConverter();
        
                //local variables used in currency conversion
                Decimal trev = 0.0;
                Decimal rev = 0.0;
                Decimal revcurr = 0.0;
        
                //local variables used for getting the names of all the Grand parent product for an open Opportunity
                Set < Id > opportunityIdSet = new Set < Id > ();
                Set < Id > noSelectionOpportunityIdSet = new Set < Id > ();
                OppGPPMap = new Map < Id, String > ();
        
                //Checking the list of Wrapper object for open Opportunity
                if (oppResults == null) {
                    oppResults = new List < cPlanOpportunity > ();
                }
                
                Set<Id> selectedOppIds = new Set<Id>();
                
                if (!cPlan.isEmpty()){
                 if(cPlan[0].Opportunity_Selection__c != null){
                    
                    String[] oppIds = cPlan[0].Opportunity_Selection__c.split(',');
                    
                    for(Integer x=0;x<oppIds.size();x++){
                        selectedOppIds.add(Id.valueOf(oppIds[x]));
                    }
                  }
                } 
        
                // Selected Opportunity Section
                
                Opportunity[] opportunitylst = [Select Name, Owner.Name, Account.ParentId, Probability, ExpectedRevenue,
                    Current_Year_Revenue_Num__c, AccountId, Account.name, Account.Owner.Name,
                    Account.CRT_Client_Types__c, Account.CIF__c, StageName, Current_Year_Revenue_Currency__c,
                    Priority__c, Opportunity_Sector__c, CloseDate, Amount, Short_Summary__c, OwnerId, Opportunity_Owner_Lookup__r.Name,
                    Actual_Close_Date__c, CurrencyIsoCode, Type, Current_Year_Revenue__c, Total_Revenue_Num__c
                    From Opportunity where(Account.Id = : currentId OR Account.ParentId = : currentId OR Account.Group_Parent__c = : currentId)
                    AND(IsClosed = False AND StageName NOT IN('4 - Closed Lost', 'Closed Lost', 'Closed Won', '3 - Closed Won','Cancel'))
                    And Id In : selectedOppIds
                    order by probability desc , ExpectedRevenue desc nulls last limit 500
                ];
        
                //Storing the Opportunity Id in the set                                      
                for (Opportunity opp: opportunitylst) {
                    opportunityIdSet.add(opp.Id);
                }
        
                //Soql query for getting all the GPP for open opportunities                                        
                SB_Product__c[] productlst = [Select Id, Name, Opportunity__c,Opportunity__r.Id, Grand_Parent_Product__c from SB_Product__c Where Opportunity__c = : opportunityIdSet Order by Opportunity__c asc];
                
        
                //Storing the Opporunity Id as key and the Product names(seperated by comma) as value.
                         
                    
                    for (Opportunity opp2 : opportunitylst){
                        
                       String strGPP = '';
                      
                         for (SB_Product__c prod: productlst) {
                            If (prod.Opportunity__c == opp2.Id){
                            if (strGPP == '') {
                                strGPP = prod.Grand_Parent_Product__c;
                            }
                            else {
                                strGPP = strGPP + ',' + prod.Grand_Parent_Product__c;
                            }
                            }
                         }
                          OppGPPMap.put(opp2.Id, strGPP);
                       
                       
                }
        
               // Populating the list of Opportunity wrapper object which stores the converted cuurency values
                for (Opportunity o: opportunitylst) {
                    
                    if (!cPlan.isEmpty()){
                    cPlanOpportunity cp = new cPlanOpportunity(o);
                    cp.checked = true;
                    trev = converter.convert(Double.valueOf(o.ExpectedRevenue), String.valueOf(o.CurrencyIsoCode), RateMap, cPlan[0].CurrencyIsoCode);
                    cp.totalRev = trev.divide(1000, 2);
                    rev = converter.convert(Double.valueOf(o.Current_Year_Revenue__c), String.valueOf(o.CurrencyIsoCode), RateMap, cPlan[0].CurrencyIsoCode);
                    cp.currentRev = rev.divide(1000, 2);
                    revcurr = converter.convert(Double.valueOf(o.Current_Year_Revenue_Currency__c), String.valueOf(o.CurrencyIsoCode), RateMap, cPlan[0].CurrencyIsoCode);
                    cp.currentRevcurr = revcurr.divide(1000, 2);
        
                    oppResults.add(cp);
                    }
                    else{
                    cPlanOpportunity cp = new cPlanOpportunity(o);
                    cp.checked = true ;
                    trev = converter.convert(Double.valueOf(o.ExpectedRevenue), String.valueOf(o.CurrencyIsoCode), RateMap, 'ZAR');
                    cp.totalRev = trev.divide(1000, 2);
                    rev = converter.convert(Double.valueOf(o.Current_Year_Revenue__c), String.valueOf(o.CurrencyIsoCode), RateMap, 'ZAR');
                    cp.currentRev = rev.divide(1000, 2);
                    revcurr = converter.convert(Double.valueOf(o.Current_Year_Revenue_Currency__c), String.valueOf(o.CurrencyIsoCode), RateMap, 'ZAR');
                    cp.currentRevcurr = revcurr.divide(1000, 2);
        
                    oppResults.add(cp);
                     
                   }
                }
        
          return oppResults ;
        
        
      }
        /**
        * save Opportunity Selections
        */
            public void saveOpportunitySelections() {
        
                
            String oppIdSelected = '';
            
                    for (cPlanOpportunity o : oppResults){
                    if (o.checked){
                        oppIdSelected = oppIdSelected + ',' + o.opp.Id;
                    }  
                }
            
            
            
             for (cPlanWonLostOpp o : wonLostoppResults){
                if (o.checked){
                    oppIdSelected = oppIdSelected + ',' + o.wonLostOpp.Id;
                }  
            }
           
            if(oppIdSelected.startsWith(',')){
                oppIdSelected = oppIdSelected.substring(1,oppIdSelected.length());
            }
            
            if(!cPlan.isEmpty()){
            cPlan[0].Opportunity_Selection__c = oppIdSelected;
            }
         }


    /**
             * @author :- Nitish Kumar
             * @date  :-  Sept -2013
             * @description :- Public list method which gets the closed Opportunity records to be shown on Client Plan page.
                               Also does the currency conversion of Currency fields based on the currency selected on Client plan.
             * @param :- N/A
             * @return :- List of cPlanWonLostOpp (Wrapper Object for closed Opportunities)
    **/

    public List < cPlanWonLostOpp > getWonLostOpportunitylst() {
        if(!isInsertedClientPlan && clientPlanId == null){ // US-1282 : adjusting logic for CommB/CIB - Display appropriate error message
            return null;
         }
        //Calling the Currency convertor method
        currencyConverter converter = new currencyConverter();

        //local variables used for currency conversion
        Decimal trev = 0.0;
        Decimal rev = 0.0;
        
        //local variables used for getting the names of all the Grand parent product for an open Opportunity
        Set < Id > wonLostOpportunityIdSet = new Set < Id > ();
        Set < Id > noSelectionWonLostOpportunityIdSet = new Set < Id > ();
        WonLostOppGPPMap = new Map < Id, String > ();
        set < String > wonLostgPPSet = new Set < String > ();

        closedOppCYRevSum = 0.0;
        closedOppTotalRevSum = 0.0;

        //Checking the list of Wrapper object for closed Opportunity
        if (wonLostoppResults == null) {
            wonLostoppResults = new List < cPlanWonLostOpp > ();
        }
        
        Set<Id> selectedWonLostOppIds = new Set<Id>();
        
        if (!cPlan.isEmpty()){
         if(cPlan[0].Opportunity_Selection__c != null){
            
            String[] oppIds = cPlan[0].Opportunity_Selection__c.split(',');
            
            for(Integer x=0;x<oppIds.size();x++){
                selectedWonLostOppIds.add(Id.valueOf(oppIds[x]));
            }
          }
        } 
        
        
        // Selected Won Lost Opportunity Section

        Opportunity[] wonLostOpportunitylst = [Select Name, Owner.Name, Account.ParentId, Probability, ExpectedRevenue,
            Current_Year_Revenue_Num__c, AccountId, Account.name, Account.Owner.Name,
            Account.CRT_Client_Types__c, Account.CIF__c, StageName, Current_Year_Revenue_Currency__c,
            Priority__c, Opportunity_Sector__c, CloseDate, Amount, Short_Summary__c, OwnerId, Opportunity_Owner_Lookup__r.Name,
            Actual_Close_Date__c, CurrencyIsoCode, Type, Current_Year_Revenue__c, Total_Revenue_Num__c, ReasonForWinLossPickList__c
            From Opportunity where(Account.Id = : currentId OR Account.ParentId = : currentId OR Account.Group_Parent__c = : currentId)
            AND(IsClosed = TRUE AND StageName IN('4 - Closed Lost', 'Closed Lost', 'Closed Won', '3 - Closed Won')) AND 
            (CloseDate = LAST_N_DAYS:180) And Id IN : selectedWonLostOppIds
            order by StageName asc ,Amount desc nulls last limit 500
        ];
        
        
        //Storing the Opportunity Id in the set                                        
        for (Opportunity opp: wonLostOpportunitylst) {
            wonLostOpportunityIdSet.add(opp.Id);
        }

        //Soql query for getting all the GPP for closed opportunities                                         
        SB_Product__c[] wonProductlst = [Select Id, Name, Opportunity__c, Grand_Parent_Product__c from SB_Product__c Where Opportunity__c = : wonLostOpportunityIdSet];


        //Storing the Opporunity Id as key and the Product names(seperated by comma) as value.                                       
        for (Opportunity wonopp: wonLostOpportunitylst) {

            String strGPP = '';

            for (SB_Product__c prod: wonProductlst) {
                      if(prod.Opportunity__c == wonopp.Id){
                        if (strGPP == '') {
                            strGPP = prod.Grand_Parent_Product__c;
                        } else {
                            strGPP = strGPP + ',' + prod.Grand_Parent_Product__c;
                        }
                     }
                }
            WonLostOppGPPMap.put(wonopp.Id, strGPP);
        }

        // Populating the list of Opportunity wrapper object which stores the converted cuurency values
        for (Opportunity op: wonLostOpportunitylst) {
            
            if (!cPlan.isEmpty()){
            cPlanWonLostOpp cp = new cPlanWonLostOpp(op);
            cp.checked = true ;
            trev = converter.convert(Double.valueOf(op.Amount), String.valueOf(op.CurrencyIsoCode), RateMap, cPlan[0].CurrencyIsoCode);
            cp.wonLosttotalRev = trev.divide(1000, 2);
            rev = converter.convert(Double.valueOf(op.Current_Year_Revenue_Currency__c), String.valueOf(op.CurrencyIsoCode), RateMap, cPlan[0].CurrencyIsoCode);
            cp.wonLostcurrrev = rev.divide(1000, 2);

            closedOppCYRevSum += cp.wonLostcurrrev;
            closedOppTotalRevSum += cp.wonLosttotalRev;

            wonLostoppResults.add(cp);
           }
           else{
                        cPlanWonLostOpp cp = new cPlanWonLostOpp(op);
                        cp.checked = true ;
                    trev = converter.convert(Double.valueOf(op.Amount), String.valueOf(op.CurrencyIsoCode), RateMap, 'ZAR');
                    cp.wonLosttotalRev = trev.divide(1000, 2);
                    rev = converter.convert(Double.valueOf(op.Current_Year_Revenue_Currency__c), String.valueOf(op.CurrencyIsoCode), RateMap, 'ZAR');
                    cp.wonLostcurrrev = rev.divide(1000, 2);

                    closedOppCYRevSum += cp.wonLostcurrrev;
                    closedOppTotalRevSum += cp.wonLosttotalRev;
        
                    wonLostoppResults.add(cp);
           }
            
        }
        
         //Not Selected Won Lost Opportunity Section

        Opportunity[] wonLostOpportunitylstnoSelection = [Select Name, Owner.Name, Account.ParentId, Probability, ExpectedRevenue,
            Current_Year_Revenue_Num__c, AccountId, Account.name, Account.Owner.Name,
            Account.CRT_Client_Types__c, Account.CIF__c, StageName, Current_Year_Revenue_Currency__c,
            Priority__c, Opportunity_Sector__c, CloseDate, Amount, Short_Summary__c, OwnerId, Opportunity_Owner_Lookup__r.Name,
            Actual_Close_Date__c, CurrencyIsoCode, Type, Current_Year_Revenue__c, Total_Revenue_Num__c, ReasonForWinLossPickList__c
            From Opportunity where(Account.Id = : currentId OR Account.ParentId = : currentId OR Account.Group_Parent__c = : currentId)
            AND(IsClosed = TRUE AND StageName IN('4 - Closed Lost', 'Closed Lost', 'Closed Won', '3 - Closed Won')) AND 
            (CloseDate = LAST_N_DAYS:180) And Id Not IN : selectedWonLostOppIds
            order by StageName asc ,Amount desc nulls last limit 500
        ];
        
        
        //Storing the Opportunity Id in the set                                        
        for (Opportunity opp: wonLostOpportunitylstnoSelection) {
            noSelectionWonLostOpportunityIdSet.add(opp.Id);
        }

        //Soql query for getting all the GPP for closed opportunities                                         
        SB_Product__c[] wonProductlst2 = [Select Id, Name, Opportunity__c, Grand_Parent_Product__c from SB_Product__c Where Opportunity__c = : noSelectionWonLostOpportunityIdSet];


        //Storing the Opporunity Id as key and the Product names(seperated by comma) as value.                                       
        for (Opportunity wonopp: wonLostOpportunitylstnoSelection) {

            String strGPP = '';

            for (SB_Product__c prod: wonProductlst2) {
                      if(prod.Opportunity__c == wonopp.Id){
                        if (strGPP == '') {
                            strGPP = prod.Grand_Parent_Product__c;
                        } else {
                            strGPP = strGPP + ',' + prod.Grand_Parent_Product__c;
                        }
                     }
                }
            WonLostOppGPPMap.put(wonopp.Id, strGPP);
        }

        // Populating the list of Opportunity wrapper object which stores the converted cuurency values
        for (Opportunity op: wonLostOpportunitylstnoSelection) {
            
            if (!cPlan.isEmpty()){
            cPlanWonLostOpp cp = new cPlanWonLostOpp(op);
            cp.checked = false ;
            trev = converter.convert(Double.valueOf(op.Amount), String.valueOf(op.CurrencyIsoCode), RateMap, cPlan[0].CurrencyIsoCode);
            cp.wonLosttotalRev = trev.divide(1000, 2);
            rev = converter.convert(Double.valueOf(op.Current_Year_Revenue_Currency__c), String.valueOf(op.CurrencyIsoCode), RateMap, cPlan[0].CurrencyIsoCode);
            cp.wonLostcurrrev = rev.divide(1000, 2);

            closedOppCYRevSum += cp.wonLostcurrrev;
            closedOppTotalRevSum += cp.wonLosttotalRev;

            wonLostoppResults.add(cp);
           }
           else{
                        cPlanWonLostOpp cp = new cPlanWonLostOpp(op);
                        cp.checked = false ;
                    trev = converter.convert(Double.valueOf(op.Amount), String.valueOf(op.CurrencyIsoCode), RateMap, 'ZAR');
                    cp.wonLosttotalRev = trev.divide(1000, 2);
                    rev = converter.convert(Double.valueOf(op.Current_Year_Revenue_Currency__c), String.valueOf(op.CurrencyIsoCode), RateMap, 'ZAR');
                    cp.wonLostcurrrev = rev.divide(1000, 2);

                    closedOppCYRevSum += cp.wonLostcurrrev;
                    closedOppTotalRevSum += cp.wonLosttotalRev;

                    wonLostoppResults.add(cp);
           }
            
        }
       
        return wonLostoppResults;

    }

    /**
    * get Selected WonLost Opportunity List
    * @return List < cPlanWonLostOpp >
    */
    public List < cPlanWonLostOpp > getSelectedWonLostOpportunitylst() {
        if(!isInsertedClientPlan && clientPlanId == null){ // US-1282 : adjusting logic for CommB/CIB - Display appropriate error message
            return null;
         }
        //Calling the Currency convertor method
        currencyConverter converter = new currencyConverter();

        //local variables used for currency conversion
        Decimal trev = 0.0;
        Decimal rev = 0.0;
        
        //local variables used for getting the names of all the Grand parent product for an open Opportunity
        Set < Id > wonLostOpportunityIdSet = new Set < Id > ();
        Set < Id > noSelectionWonLostOpportunityIdSet = new Set < Id > ();
        WonLostOppGPPMap = new Map < Id, String > ();
        set < String > wonLostgPPSet = new Set < String > ();

        //Checking the list of Wrapper object for closed Opportunity
        if (wonLostoppResults == null) {
            wonLostoppResults = new List < cPlanWonLostOpp > ();
        }
        
        Set<Id> selectedWonLostOppIds = new Set<Id>();
        
        if (!cPlan.isEmpty()){
         if(cPlan[0].Opportunity_Selection__c != null){
            
            String[] oppIds = cPlan[0].Opportunity_Selection__c.split(',');
            
            for(Integer x=0;x<oppIds.size();x++){
                selectedWonLostOppIds.add(Id.valueOf(oppIds[x]));
            }
          }
        } 
        
        
        // Selected Won Lost Opportunity Section

        Opportunity[] wonLostOpportunitylst = [Select Name, Owner.Name, Account.ParentId, Probability, ExpectedRevenue,
            Current_Year_Revenue_Num__c, AccountId, Account.name, Account.Owner.Name,
            Account.CRT_Client_Types__c, Account.CIF__c, StageName, Current_Year_Revenue_Currency__c,
            Priority__c, Opportunity_Sector__c, CloseDate, Amount, Short_Summary__c, OwnerId, Opportunity_Owner_Lookup__r.Name,
            Actual_Close_Date__c, CurrencyIsoCode, Type, Current_Year_Revenue__c, Total_Revenue_Num__c, ReasonForWinLossPickList__c
            From Opportunity where(Account.Id = : currentId OR Account.ParentId = : currentId OR Account.Group_Parent__c = : currentId)
            AND(IsClosed = TRUE AND StageName IN('4 - Closed Lost', 'Closed Lost', 'Closed Won', '3 - Closed Won')) AND 
            (CloseDate = LAST_N_DAYS:180) And Id IN : selectedWonLostOppIds
            order by StageName asc ,Amount desc nulls last limit 500
        ];
        
        
        //Storing the Opportunity Id in the set                                        
        for (Opportunity opp: wonLostOpportunitylst) {
            wonLostOpportunityIdSet.add(opp.Id);
        }

        //Soql query for getting all the GPP for closed opportunities                                         
        SB_Product__c[] wonProductlst = [Select Id, Name, Opportunity__c, Grand_Parent_Product__c from SB_Product__c Where Opportunity__c = : wonLostOpportunityIdSet];


        //Storing the Opporunity Id as key and the Product names(seperated by comma) as value.                                       
        for (Opportunity wonopp: wonLostOpportunitylst) {

            String strGPP = '';

            for (SB_Product__c prod: wonProductlst) {
                      if(prod.Opportunity__c == wonopp.Id){
                        if (strGPP == '') {
                            strGPP = prod.Grand_Parent_Product__c;
                        } else {
                            strGPP = strGPP + ',' + prod.Grand_Parent_Product__c;
                        }
                     }
                }
            WonLostOppGPPMap.put(wonopp.Id, strGPP);
        }

        // Populating the list of Opportunity wrapper object which stores the converted cuurency values
        for (Opportunity op: wonLostOpportunitylst) {
            
            if (!cPlan.isEmpty()){
            cPlanWonLostOpp cp = new cPlanWonLostOpp(op);
            cp.checked = true ;
            trev = converter.convert(Double.valueOf(op.Amount), String.valueOf(op.CurrencyIsoCode), RateMap, cPlan[0].CurrencyIsoCode);
            cp.wonLosttotalRev = trev.divide(1000, 2);
            rev = converter.convert(Double.valueOf(op.Current_Year_Revenue_Currency__c), String.valueOf(op.CurrencyIsoCode), RateMap, cPlan[0].CurrencyIsoCode);
            cp.wonLostcurrrev = rev.divide(1000, 2);

            wonLostoppResults.add(cp);
           }
           else{
                        cPlanWonLostOpp cp = new cPlanWonLostOpp(op);
                        cp.checked = true ;
                    trev = converter.convert(Double.valueOf(op.Amount), String.valueOf(op.CurrencyIsoCode), RateMap, 'ZAR');
                    cp.wonLosttotalRev = trev.divide(1000, 2);
                    rev = converter.convert(Double.valueOf(op.Current_Year_Revenue_Currency__c), String.valueOf(op.CurrencyIsoCode), RateMap, 'ZAR');
                    cp.wonLostcurrrev = rev.divide(1000, 2);
        
                    wonLostoppResults.add(cp);
           }
            
        }
        
        return wonLostoppResults ;
        
    }
    

    /**
     * @author :- Anusha
     * @date  :-  Sept -2013
     * @description :- Public list method which gets all the picklist values from the nature of Relationship field.
     * @param :- N/A
     * @return :- List of options.
     **/
    public List < SelectOption > getPicklistValues() {

        //new list for holding all of the picklist options        
        List < SelectOption > options = new List < SelectOption > ();

        //From the Object Api name retrieving the SObject
        Schema.DescribeFieldResult fieldResult = Account.Nature_of_Relationship__c.getDescribe();

        List < Schema.PicklistEntry > pickList = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry plistEntry: pickList) { //for all values in the picklist list
            options.add(new SelectOption(plistEntry.getValue(), plistEntry.getValue()));

        }

        return options; // returns the picklist options

    }

    /**
     * @author :- Nitish Kumar
     * @date  :-  Oct -2013
     * @description :- Public list method which gets all the picklist values from the nature of Relationship field.
     * @param :- N/A
     * @return :- List of String.
     **/
    public list < String > getRelationship() {

        list < String > strlst = new list < String > ();

        //From the Object Api name retrieving the SObject
        Schema.DescribeFieldResult fieldResult = Account.Nature_of_Relationship__c.getDescribe();

        List < Schema.PicklistEntry > pickList = fieldResult.getPicklistValues();

        for (Schema.PicklistEntry plistEntry: pickList) { //for all values in the picklist list
            strlst.add(plistEntry.getValue());
        }

        return strlst;

    }

    /**
     * @author :- Nitish Kumar
     * @date  :-  Sept -2013
     * @description :- Public list method which gets all Tasks of account and its subsidiary.
     * @param :- N/A
     * @return :- List of Task.
     **/

    public list < CPTaskSelection > getTasks() {
        
         if (taskResults == null) {
            taskResults = new List<CPTaskSelection>();
           }else {
            taskResults.clear();
         }
        
        Set<Id> selectedTaskIds = new Set<Id>();
        
        if (!cPlan.isEmpty()){
        if(cPlan[0].Task_Selection__c != null){
            
            String[] taskIds = cPlan[0].Task_Selection__c.split(',');
            
            for(Integer x=0;x<taskIds.size();x++){
                selectedTaskIds.add(Id.valueOf(taskIds[x]));
             }
           } 
         }
         
         

        Task[] highPriorityselectedTasks = [Select Who.Name, WhoId, Type, Subject, Status, Priority, Account.Name,
            Owner.Name, OwnerId, IsClosed, Id, ActivityDate, AccountId
            From Task Where IsClosed = false
            AND(Account.Id = : currentId OR Account.ParentId = : currentId OR Account.Group_Parent__c = : currentId)
            and Id IN : selectedTaskIds
            order by  ActivityDate asc limit 500
        ];
        
        for(Task t : highPriorityselectedTasks){
            
            CPTaskSelection tsk = new CPTaskSelection(t);
            tsk.checked = true;
            taskResults.add(tsk);
        }
        
         Task[] highPrioritynotselectedTasks = [Select Who.Name, WhoId, Type, Subject, Status, Priority, Account.Name,
            Owner.Name, OwnerId, IsClosed, Id, ActivityDate, AccountId
            From Task Where IsClosed = false
            AND(Account.Id = : currentId OR Account.ParentId = : currentId OR Account.Group_Parent__c = : currentId)
            and Id NOT IN : selectedTaskIds
            order by  ActivityDate asc limit 500
        ];
        
         for(Task t : highPrioritynotselectedTasks){
            
            CPTaskSelection tsk = new CPTaskSelection(t);
            tsk.checked = false;
            taskResults.add(tsk);
        }
        
       return taskResults;

    }

    /**
    * get selected tasks
    * @return list < Task >
    */
     public list < Task > getSelectedTasks() {
        
         Set<Id> selectedTaskIds = new Set<Id>();
        
        if (!cPlan.isEmpty()){
        if(cPlan[0].Task_Selection__c != null){
            
            String[] taskIds = cPlan[0].Task_Selection__c.split(',');
            
            for(Integer x=0;x<taskIds.size();x++){
                selectedTaskIds.add(Id.valueOf(taskIds[x]));
             }
           } 
         }
         
         Task[] highPriorityselectedTasks = [Select Who.Name, WhoId, Type, Subject, Status, Priority, Account.Name,
            Owner.Name, OwnerId, IsClosed, Id, ActivityDate, AccountId
            From Task Where IsClosed = false
            AND(Account.Id = : currentId OR Account.ParentId = : currentId OR Account.Group_Parent__c = : currentId)
            and Id IN : selectedTaskIds
            order by  ActivityDate asc limit 500
        ];
        
        return highPriorityselectedTasks ;
        
        
     }
    /**
    * save Task Selections
    */
     public void saveTaskSelections() {
        
                
            String taskIdSelected = '';
            for (CPTaskSelection t : taskResults){
                if (t.checked){
                    taskIdSelected = taskIdSelected + ',' + t.tsk.Id;
                }  
            }
           
            if(taskIdSelected.startsWith(',')){
                taskIdSelected = taskIdSelected.substring(1,taskIdSelected.length());
            }
            
            if(!cPlan.isEmpty()){
            cPlan[0].Task_Selection__c = taskIdSelected;
            }
    }


    /**
     * @author :- Nitish Kumar
     * @date  :-  Oct -2013
     * @description :- Public String method which gets the Client Plan currency Iso code.
     * @param :- N/A
     * @return :- String
     **/
    public String getcPlanCurrency() {
          if (!cPlan.isEmpty()){
        return cPlan[0].CurrencyIsoCode;
        }
        else {
                return 'ZAR' ;
        }
    }
    
     /**
     * @author :- Nitish Kumar
     * @date  :-  Oct -2013
     * @description :- Public String method which gets the Client Plan currency Iso code.
     * @param :- N/A
     * @return :- String
     **/
    public String getcPlanCurrencyTop() {
          if (!cPlan.isEmpty()){
        return cPlan[0].CurrencyIsoCode;
        }
        else {
                return 'ZAR' ;
        }
    }
    
   
    
     /**
     * @author :- Nitish Kumar
     * @date  :-  Oct -2013
     * @description :- Public map<String,String> method which stores Division full name as Key and Short name as Value
     * @param :- N/A
     * @return :- String
     **/
     
      public map<String,String> getDivisionMap() {
         
          // Map which stores Division full name as Key and Short name as Value
          map <String,String> mapDivision = new Map < String, String > ();
          
           mapDivision.put('Global Markets' , 'GM ');
           mapDivision.put('Investment Banking' , 'IB ');
           mapDivision.put('Real Estate' , 'RE ');
           mapDivision.put('Transactional Products and Services' , 'TPS ');
         
         return mapDivision;
         
      }
     
    /**
     * @author :- Nitish Kumar
     * @date  :-  Oct -2013
     * @description :- Public String method which sets the Client Plan currency Iso code.
     * @param iso
     **/
    public void setcPlanCurrency(String iso) {
        
          if (!cPlan.isEmpty()) {
              cPlanCurrency = iso;
          }
    }
    
      /**
     * @author :- Nitish Kumar
     * @date  :-  Oct -2013
     * @description :- Public String method which sets the Client Plan currency Iso code.
     * @param iso
     **/
    public void setcPlanCurrencyTop(String iso) {
          if (!cPlan.isEmpty()) {
              cPlanCurrencyTop = iso;
          }
    }
    
  
    /**
     * @author :- Nitish Kumar
     * @date  :-  Sept -2013
     * @description :- Public list method which builds and returns the list of Options of Currency (ZAR and USD) .
     * @param :- N/A
     * @return :- List of options.
     **/
    public List < SelectOption > getCurrencies() {
        List < SelectOption > currencies = new List < SelectOption > ();
        currencies.add(new SelectOption('USD', 'U.S. Dollar'));
        currencies.add(new SelectOption('ZAR', 'South African Rand'));
        return currencies;
    }
    
    
    
     /**
     * @author :- Nitish Kumar
     * @date  :-  Oct -2013
     * @description :- Public pagerefrence method which refreshes the Client Plan page .
     * @param :- N/A
     * @return :- Pagereference
     **/
    public PageReference refreshPage() {
        
        try{

            if(!cPlan.isEmpty()){
                cPlan[0].CurrencyIsoCode = cPlanCurrency;
                saveTeamSelections();
                saveTaskSelections();
                saveOpportunitySelections();
                saveCsiSelection();
                update this.cPlan[0];
                
                }
               }catch(System.DMLException ex){
                    System.debug('$$$$$$$$$$$$$$' + ex);
              }     

        //Redirecting back to Client Plan page.
        PageReference p = ApexPages.currentPage();
        p.setRedirect(true);
        p.getParameters().put('id', currentId);
        return p;

    }
    
       /**
     * @author :- Nitish Kumar
     * @date  :-  Oct -2013
     * @description :- Public pagerefrence method which refreshes the Client Plan page .
     * @param :- N/A
     * @return :- Pagereference
     **/
    public PageReference refreshPage1() {
        
        try{
            
            if(!cPlan.isEmpty()){
                cPlan[0].CurrencyIsoCode = cPlanCurrencyTop;
                saveTeamSelections();
                saveTaskSelections();
                saveOpportunitySelections();
                saveCsiSelection();
            update this.cPlan[0];
                }
                }catch(System.DMLException ex){
                    System.debug('$$$$$$$$$$$$$$' + ex);
                }     

        //Redirecting back to Client Plan page.
        PageReference p = ApexPages.currentPage();
        p.setRedirect(true);
        p.getParameters().put('id', currentId);
        return p;

    }

    /**
     * @author :- Nitish Kumar
     * @date  :-  Oct -2013
     * @description :- Public String method which gets the Client Plan currency Iso code.
     * @param :- N/A
     * @return :- String
     **/
    public String getISO() {
          if (!cPlan.isEmpty()) {
              this.ISO = cPlan[0].CurrencyIsoCode;
          }
        return this.ISO;
    }
  

    /**
     * @author :- Nitish Kumar
     * @date  :-  Oct -2013
     * @description :- Public inner class for creating open opportunity wrapper object.
     * @param :- N/A
     * @return :- null
     **/

    //Wrapper Object for Open Opportunity
    public class cPlanOpportunity {

        public Opportunity opp {
            get;
            set;
        }
        public Decimal totalRev {
            get;
            set;
        }
        public Decimal currentRevcurr {
            get;
            set;
        }
        public Decimal currentRev {
            get;
            set;
        }
        
       public Boolean checked{ get; set; }
        /**
        * Constructor for inner class
        */
        public cPlanOpportunity() {
            opp = new Opportunity();
            checked = false;
        }
        /**
        * Constructor for inner class
        * @param o
        */
        public cPlanOpportunity(Opportunity o) {
            opp = o;
             checked = false;
        }
    }
        /**
        * @description :- Public inner class for Team Selection.
        **/
    //Team members
       public class CPTeamSelection {
        public Boolean checked{ get; set; }
        public Custom_Client_Team__c team { get; set; }
        /**
        * Constructor for inner class
        */
        public CPTeamSelection(){
            team = new Custom_Client_Team__c();
            checked = false;
        }
        /**
        * Overloaded Constructor for inner class
        * @param t
        */
        public CPTeamSelection(Custom_Client_Team__c t){
            team = t;
            checked = false;
        }
        
        
     }
    /**
     * @description :- Public inner class for Task Selection.
     **/
     //Team members 
     public class CPTaskSelection  {
        
        public Boolean checked{ get; set;}
        public Task tsk { get; set; }
         /**
        * Constructor for inner class
        */
        public CPTaskSelection(){
            tsk = new Task();
            checked = false;
        }
        /**
        * overloaded constructor for inner class
        * @param t
        */
        public CPTaskSelection(Task t){
            tsk = t;
            checked = false;
        }
       
     }

    /**
     * @author :- Nitish Kumar
     * @date  :-  Oct -2013
     * @description :- Public inner class for creating closed opportunity wrapper object.
     * @param :- N/A
     * @return :- null
     **/

    //Wrapper Object for Closed Opportunity
    public class cPlanWonLostOpp {

        public Opportunity wonLostOpp {
            get;
            set;
        }
        public Decimal wonLosttotalRev {
            get;
            set;
        }
        public Decimal wonLostcurrrev {
            get;
            set;
        }
        
        public Boolean checked{ get; set; }
        /**
        *  Client Plan won lost opp
        */
        public cPlanWonLostOpp() {
            wonLostOpp = new Opportunity();
            checked    = false ;
        }
        /**
        * Client Plan won lost opp
        * @param op
        */
        public cPlanWonLostOpp(Opportunity op) {
            wonLostOpp = op;
            checked    = false ;
        }

    }

    /**
     * @author :- Nitish Kumar
     * @date  :-  Oct -2013
     * @description :- Public inner class used for Currency conversion calculation(CURRENCY CONVERSION CLASS).
     **/

    public class currencyConverter {
        /**
        * Constructor
        */
        public currencyConverter() {}
        /**
        * Currency conversion calculation
        * @param val
        * @param oldCurr
        * @param rateMap
        * @param newCurr
        * @return Decimal
        */
        public Decimal convert(Decimal val, String oldCurr, Map < String, Double > rateMap, String newCurr) {
            //NOTE ON CALCULATION:
            //(current curr / current rate) = USD(1:1) 
            //(USD * new rate) = new curr value
            

            // No point in trying to convert a null.
            if (val == null) {
                return 0;
            }
            Decimal displayVal;


            if ((oldCurr != newCurr) || (val != 0)) {

                Double oldrate = rateMap.get(oldCurr);
                Decimal usdval = (val / oldrate);
                Double newrate = rateMap.get(newCurr);

                displayVal = (usdval * newrate);

            } else {
                displayVal = val;
            }
            return displayVal;
        }

    }

    /**
     * @author :- Nitish Kumar
     * @date  :-  Oct -2013
     * @description :- Public void method used for storing latest currency conversion rates in RateMap.
     * @param :- N/A
     **/
    //Method that pulls the latest currency conversion rates.
    public void snapCurrencyTable() {

        this.CurrTable = [Select cur.IsoCode, cur.ConversionRate From CurrencyType cur LIMIT 300];

        for (CurrencyType c: CurrTable) {
            RateMap.put(c.IsoCode, c.ConversionRate);
        }
    }

    /**
     * @author :- Nitish Kumar
     * @date  :-  Oct -2013
     * @description :- Public void method which stores the attachment in the Account related list of Notes and Attachment.
     * @param :- N/A
     * @return :- null
     **/
    //Method that attache the current version of the Client Plan record as PDF to notes & attachments
    public Pagereference attachClientPlan() {
        //Render PDF and attched to Client Plan object.

        Blob pdfBlob;
        PageReference cPlanpage = Page.ClientPlanPDF;
        if (this.acct.RecordTypeId == commBClientRTId) {
            cPlanpage = Page.ClientPlanCommBPDF;
        } 
        cPlanpage.getParameters().put('id', currentId);
        String contentUrl = cPlanpage.getUrl();
        list<CAM_Selection__c> lstCAMOverview = new list<CAM_Selection__c>();
        
        lstCAMOverview = [Select Id , Name from  CAM_Selection__c Where Client_Id__c =: currentId AND OwnerId =: currentUserId limit 1] ;
        
        if(lstCAMOverview.isEmpty()){
                CAM_Selection__c caM = new CAM_Selection__c();
                caM.Client_Id__c = currentId;
                caM.OwnerId = currentUserId;
                
                insert caM ;
        }
        
        if(lstCAMOverview.isEmpty()){
          lstCAMOverview = [Select Id , Name from  CAM_Selection__c Where Client_Id__c =: currentId AND OwnerId =: currentUserId limit 1] ;
        }
        


        if (Test.isRunningTest()) {
            pdfBlob = Blob.valueOf('TEST BLOB');
        } else {
            pdfBlob = cPlanpage.getContentAsPDF();
        }
        Datetime cDT = System.today();
        String longDate = cDT.format('yyyy-MM-dd');

        ContentDocumentLink documentLink;
        Boolean newFile = false;
        try{
            documentLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :lstCAMOverview[0].Id LIMIT 1];
        } catch (QueryException queryException) {
            if (queryException.getMessage().equals('List has no rows for assignment to SObject')) {
                newFile = true;
            }
        }

        if (newFile) { // create the first version of the file
            String title = 'Client Plan ' + longDate + ' ' + ClientName + ' ' + 'V-' + 1 + '.pdf';
            ContentVersion contentVersion = new ContentVersion(Title = title, PathOnClient = title, VersionData = pdfBlob);
            insert contentVersion;

            Id contentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id].ContentDocumentId;

            ContentDocumentLink contentDocumentLink = new ContentDocumentLink(LinkedEntityId = lstCAMOverview[0].Id, ContentDocumentId = contentDocumentId,
                ShareType = 'I');
            Database.SaveResult s = Database.insert(contentDocumentLink, false);

        } else {
            Id contentDocumentId = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :lstCAMOverview[0].Id].ContentDocumentId;

            ContentVersion contentVersion = [SELECT Title, VersionNumber, PathOnClient FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId ORDER BY VersionNumber DESC LIMIT 1];
            Integer vnum = Integer.valueOf(contentVersion.VersionNumber) + 1;

            String newTitle = 'Client Plan ' + longDate + ' ' + ClientName + ' ' + 'V-' + vnum + '.pdf';
            ContentVersion newContentVersion = new ContentVersion(Title = newTitle, PathOnClient = newTitle,
                ContentDocumentId = contentDocumentId, VersionData = pdfBlob);
            insert newContentVersion;

        }
        update lstCAMOverview[0];

        //Redirecting back to Client Plan page.
        PageReference p = ApexPages.currentPage();
        p.setRedirect(true);
        p.getParameters().put('id', currentId);
        return p;

    }

    /******************************************************************************************************
             * @author :- Vaishali Singh
             * @date  :-  Mar -2015
             * @description :- method which checks the visibility of approval fields and  submit for approval button En - 0632
    *******************************************************************************************************/

        public void showApprovalButton()
        {
           try {
           sObjClientPlan = [Select id,name,Client_Name__c, Client_Plan_Status__c from Client_Plan__c where Client_Name__c=:acct.id ORDER BY CreatedDate DESC]; 
           lstProInstance = [SELECT Id, ProcessDefinitionID,(Select StepStatus,StepNodeId, OriginalActor.Name,ActorId, Actor.Name, Comments,
                                    CreatedDate, CreatedById,CreatedBy.Name FROM Steps where StepStatus=:'Approved' ORDER BY CreatedDate DESC) FROM ProcessInstance
                                    WHERE TargetObjectId =:sObjClientPlan.Id ORDER BY CreatedDate DESC LIMIT 1];
            Account acc = [Select id, recordtypeid from Account where id=:acct.id];
            Recordtype rctype= [Select id,name from RecordType where SObjectType='Account' and id=:acc.recordtypeid];
            if(rctype.Name=='Immediate Parent' || rctype.Name=='Ultimate Group Parent' || rctype.Name=='Child')
            {
                showApprBtn= true;
                
            }
            if(rctype.Name=='Immediate Parent' || rctype.Name=='Ultimate Group Parent' || rctype.Name=='Child')
            {
                showApprFields= true;
                
            }
            if((rctype.Name=='Immediate Parent' || rctype.Name=='Ultimate Group Parent' || rctype.Name=='Child') && lstProInstance.size()>0 )
            {
                showApprStatus= true;
                
            }
            if(sObjClientPlan.Client_Plan_Status__c=='Submitted For Approval'){
                enableApprButton= true;
            }
           } catch (Exception e){
               showApprBtn= false;
               showApprFields= false;
               showApprStatus= false;
               enableApprButton= false;
           }
        }
 

     /**
     * @author :- Vaishali Singh
     * @date  :-  Mar -2015
     * @description :- The method does the initial operation of submit for approval EN-0632.
     * @param :- N/A
     * @return :- pagereference
     **/
     
     
       public PageReference submitForApproval()
       {
           try {
           List<Custom_Client_Team__c> cTList = [SELECT Account__c,Case_Access__c,Client_Coordinator_BM__c,Client_Coordinator__c,Client_Role__c,Name,Team_Member__c
                                            FROM Custom_Client_Team__c where Account__c=:acct.id and (Client_Coordinator_BM__c= true OR Client_Coordinator__c = true) and (Team_Member__c=: UserInfo.getUserId())];
           if(cTList.size()==0){
                showError = true;
                return null;
           }
            if(sObjClientPlan.Client_Plan_Status__c=='To Be Reviewed' || sObjClientPlan.Client_Plan_Status__c=='Approved')
            {
                sObjClientPlan.Can_be_Submitted__c= true;
                    update sObjClientPlan;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Client Plan Submitted Successfully for Approval'));
                    isSubmitted = true;
            }
            PageReference pgrf= new PageReference('/apex/ClientPlan?id='+currentId+'&Lightning='+islightning);
            pgrf.setRedirect(true);
            return pgrf; 
            
           } catch(Exception e) {
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
           }
            return null;   
      }
      
    /**
     * @author :- Vaishali Singh
     * @date  :-  Mar -2015
     * @description :- The method return ProcessInstances for Approval history EN-0632.
     * @param :- N/A
     * @return :- List- ProcessInstance
     **/
    public List<ProcessInstance> getAllApprovalStep() {
        
        return [SELECT Id, ProcessDefinitionID,   (Select StepStatus, StepNodeId, OriginalActor.Name, ActorId, Actor.Name, Comments,
                                                                CreatedDate, CreatedById,CreatedBy.Name FROM Steps
                                                                where StepStatus='Approved' OR StepStatus='Started' OR StepStatus='Rejected' ORDER BY CreatedDate DESC
                                                                ) FROM ProcessInstance WHERE TargetObjectId =:sObjClientPlan.Id ORDER BY CreatedDate DESC]; 
    }
    
}