/*************************************************************************************************
Class Name          : oppTeamCreationController
Version             : 1.0
Date Created        : 
Function            : This class acts as Controller of Opportunity Team Creation VF page, if we try to create Opportunity Team Members
                      from Opportunity detail page, functionality will populate the existing Opp team mebers along with Client team
                      members on the screen. We have to assign the role to the team member in order to save the Opportunity Team Member
                      record. 
                                                                
Modification Log    :
--------------------------------------------------------------------------------------------------
* Developer              Date                    Description
* ---------------        -----------             ----------------------------------------------
    Shubham               6/2/2014               Initial version of the class.

    @ Last Modified By  : Petr Roubal
    @ Last Modified on  :  February 2016
    @ Last Modified Reason  : EN-0947 CST - dependency between Opp team role and user global area
    
    @ Last Modified By  : Abhishek V
    @ Last Modified on  :  September 2016
    @ Last Modified Reason  : US:1543: Introduced two new methods "saveltng, cancelltng" exclusively referred by "oppTransferPage_lds" for lightning and SF1 navigation
**********************************************************************************************************************/
public class oppTeamCreationController {
    
    //public Opportunity oppConRole {get;set;}
    public String oppId                             {get;set;}
    public String oppName                           {get;set;}
    public List<oppTeamWrapper> lstOppTeamRole      {get;set;}
    public List<OpportunityTeamMember> lstInsertRole{get;set;}
    public List<OpportunityShare> lstOppShare       {get;set;}
    public Opportunity opp {get;set;}
    public List<OpportunityTeamMember> lstExistingOppTeam {get;set;}
    public map<Id,OpportunityTeamMember> mapIdVsTeamRecord {get;set;}
    
    //transfer screen variables
    public Boolean transfer {get;set;}
    public string ownerName {get;set;}
    public Id oldOwnerId {get;set;}
    public String goURL{get;set;}
    /**
    Method Name - oppTeamCreationController()
    Function - Constructor of the class which initializes all the member variables required through out the page.
    Also retrieve Opportunity details and help in populating team members on the page.
    @param controller ApexPages.StandardController
    */
    public oppTeamCreationController(ApexPages.StandardController controller) {
        opp = new Opportunity();
        goURL = '';
        if(ApexPages.currentPage().getParameters().containsKey('oppId'))
        {
            oppId = ApexPages.currentPage().getParameters().get('oppId');
            opp = [SELECT id,name,AccountId, OwnerId, isPrivate, Owner.Name, Owner.User_CIB_Global_Area__c,
                           (SELECT Id, OpportunityId, UserId, TeamMemberRole, OpportunityAccessLevel, IsDeleted, 
                           User_Business_Unit__c, User_CIB_Global_Area__c, User_City__c, User_Country__c, User_Division__c, 
                           User_Franco__c, User_State__c, User_Team__c, IsActive__c from OpportunityTeamMembers)                           
                           FROM Opportunity WHERE id=: oppId];

        }
        
        oppName = opp.name;
        oldOwnerId = opp.OwnerId;
        transfer = false;
        if(ApexPages.currentPage().getParameters().containsKey('transfer')) {
            transfer = true;
        }
        // to set the Owner Name on page message
        if(UserInfo.getUserId()== opp.OwnerId) {
            ownerName = 'you';
        }
        else {
            ownerName = opp.Owner.Name;
        }
        //initialize variables
        lstExistingOppTeam = new List<OpportunityTeamMember>();
        mapIdVsTeamRecord = new map<Id,OpportunityTeamMember>();
        lstOppShare = new List<OpportunityShare>();
        lstInsertRole = new List<OpportunityTeamMember>();
        // populate existing Opportunity Team Members from Opportunity with checkbox checked
        populateOpportunityTeamMembers();
        // populate Client Team Members to be added as Opportunity Team
        populateClientTeamMembers(opp.AccountId);
    }
    /**
    * populate Client TeamMembers
    */
    public void populateOpportunityTeamMembers(){
        lstOppTeamRole = new List<oppTeamWrapper>();
        if(opp.OpportunityTeamMembers!=null && opp.OpportunityTeamMembers.size()>0){
            for(OpportunityTeamMember oppTeamMem : opp.OpportunityTeamMembers){
                lstOppTeamRole.add(new oppTeamWrapper(true,oppTeamMem));
                lstExistingOppTeam.add(oppTeamMem);
                mapIdVsTeamRecord.put(oppTeamMem.userId,oppTeamMem);
            }
        }
    }
    /**
    * populate Client TeamMembers
    * @param accId Id
    */
    public void populateClientTeamMembers(Id accId){
        for(List<Custom_Client_Team__c> cs:[SELECT Id, IsDeleted, Name, Account__c, AccountUserId__c, Account_Owner__c, 
                                            Business_Unit__c, Case_Access__c, Client_Access__c, Client_Role__c, Contact_Access__c, 
                                            Opportunity_Access__c, Team_Member__c, UserProfileId__c, User_Country__c, User_Division__c,                                                 
                                            SourceFlag__c, TeamRoleSortValue__c, Client_Coordinator_BM__c, Client_Coordinator__c,                                               
                                            Team_Member_First_Name__c, Team_Member_Last_Name__c, User_Franco__c from Custom_Client_Team__c where Account__c =:accId]){
         for(Custom_Client_Team__c c:cs){
            OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
            oppTeamMember.OpportunityId = oppId;
            oppTeamMember.UserId = c.Team_Member__c;
            oppTeamMember.TeamMemberRole = c.Client_Role__c;
            String userDiv = c.User_Division__c!=null?c.User_Division__c:'';
            
            if(mapIdVsTeamRecord!=null && !mapIdVsTeamRecord.containsKey(c.Team_Member__c)) {
                lstOppTeamRole.add(new oppTeamWrapper(userDiv, oppTeamMember));
            }
         }
        }
        
        populateList();
    }
    
    
    /**
    Method Name - populateList()
    Function - This method is used to populate new set of records holder for 4 new Opportunity Team Member. It will even show 
    when we already have team roles associated with the opportunity record.
    */
    
    public void populateList()
    {
        for(Integer i =0;i<4;i++)
        {
            OpportunityTeamMember oppT = new OpportunityTeamMember();
            oppT.OpportunityId = oppId;
            lstOppTeamRole.add(new oppTeamWrapper('',oppT));
        }
    }
    
    /**
    Method Name - Save()
    Function - This method will save the Opportunity Team roles record based on the role selected. First of all, it will call the method 
    to validate if all necessary values on screen are added. If validation works fine, then
    this method will update the records if there are any existing ones and also create new ones which have user and team role
    selected.
    @return PageReference
    */
    public PageReference save(){
         
        validateScreenFields();
        
        if(apexpages.hasmessages()) {
            return null;
        }
        try{
            if(transfer) {
                update opp;
            }
            insertRecords();   
        
            PageReference pg = new PageReference('/'+oppId);
            pg.setRedirect(true);
            return pg;
        }
        catch(DMLException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getDMLMessage(0)));
            return null;
        }catch(UpdateException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            return null;
        }
        
    }
    
    /**
    Method Name - Cancel()
    Function - This method will take the navigation control back to the opportunity record without any cahnges to Opportunity Team role records.
    @return PageReference
    */
    public PageReference cancel(){

        PageReference pg = new PageReference('/'+oppId);
        pg.setRedirect(true);
        return pg;
    }
    /**
    * used to update records
    * @return PageReference
    */
    public PageReference saveltng(){
        goURL = '';
        validateScreenFields();
        
        if(apexpages.hasmessages()) {
            return null;
        }
        try{
            if(transfer) {
                update opp;
            }
            insertRecords();   
            goURL = '/'+oppId;
            return null;
        }
        catch(DMLException ex){
            goURL = '';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getDMLMessage(0)));
            return null;
        }catch(UpdateException ex){
            goURL = '';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            return null;
        }
        
    }

    /**
    * cancelltng
    */
    public void cancelltng(){
        goURL = '/'+oppId;
    }

    /**
     *   Method Name - validateScreenFields()
     *   Function - This method will prepare the list to be inserted for Opportunity team records and also do a validation present in screen.
     *   If there are errors, then it will display error on screen.
     *
     */
    public void validateScreenFields()
    {
        Set<Id> setUserId = new Set<Id>();
        for(oppTeamWrapper oppTeam : lstOppTeamRole){
            // check only those records where checkbox is checked
            if(oppTeam.checked){
                if(oppTeam.oppMember.UserId==null) {
                    oppTeam.oppMember.UserId.addError('Please enter a value');
                }
                if(oppTeam.oppMember.TeamMemberRole==null) {
                    oppTeam.oppMember.TeamMemberRole.addError('Please enter a value');
                }
                if(!setUserId.contains(oppTeam.oppMember.UserId)) {
                    setUserId.add(oppTeam.oppMember.UserId);
                }
                else{
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'You can not select same User more than once.');
                    ApexPages.addmessage(myMsg);
                    break;
                }
            }
        }
        
    }

    /**
    * Method Name - insertRecords()
    Function - This method will prepare the list to be inserted for Opportunity team records.
    */
    public void insertRecords(){
        
        lstInsertRole = new List<OpportunityTeamMember>();
        lstOppShare = new List<OpportunityShare>();

        Savepoint sp = Database.setSavepoint();

        //delete the existing Team
        delete lstExistingOppTeam;
        //insert all checked records
        for(oppTeamWrapper oppTeam : lstOppTeamRole){
            if(oppTeam.checked){
                //Add them to Opp Team
                if(oppTeam.oppMember.userId == opp.OwnerId){
                    if(transfer) {
                        User u = [select Id, User_CIB_Global_Area__c from User where Id = :opp.OwnerId];
                        oppTeam.oppMember.TeamMemberRole = u.User_CIB_Global_Area__c == 'BCC' ? 'BCC Product Specialist ' : 'Product Specialist';
                    }
                    
                }else{

                    if(oppTeam.oppMember.userId == oldOwnerId && transfer) {
                        oppTeam.oppMember.OpportunityAccessLevel = 'Edit';
                    }
                }

                lstInsertRole.add(oppTeam.oppMember);
            }
        }

        //Insert Opportunity Team Records

        Database.SaveResult[] srList = Database.insert(lstInsertRole, false);
        for (Database.SaveResult sr : srList) {
            if (!sr.isSuccess()) {
                Database.rollback(sp);
                string errMsg = '';
                for(Database.Error err : sr.getErrors()){
                    errMsg += err.getMessage();
                }
                for(OpportunityTeamMember otm : lstInsertRole){
                    if(otm.Id != null){
                        otm.Id = null;
                    }
                }
                throw new UpdateException(errMsg);
            }
        }
    }
    /**
    *inner class for opp team
    */
    public class oppTeamWrapper {
    
        public Boolean checked                  {get;set;}
        public String userDivision              {get;set;}
        public OpportunityTeamMember oppMember  {get;set;}
        public Boolean existingRecord           {get;set;}
        /**
        * Overloaded construct of inner class
        * @param checked Boolean
        * @param oppM OpportunityTeamMember
        */
        public oppTeamWrapper(Boolean checked, OpportunityTeamMember oppM){
            this.oppMember = new OpportunityTeamMember();
            this.oppMember = oppM.clone(false,true,false,false);
            this.checked = checked;

            if(oppM.User_Division__c!=null) {
                this.userDivision = oppM.User_Division__c;
            }
            else {
                this.userDivision = '';
            }

            this.existingRecord = true;
        }
        /**
        * Overloaded construct of inner class
        * @param userDivision String
        * @param oppMember OpportunityTeamMember
        */
        public oppTeamWrapper(String userDivision, OpportunityTeamMember oppMember){
            this.oppMember = new OpportunityTeamMember();
            this.oppMember = oppMember;
            this.checked = false;
            this.userDivision = userDivision;
        }
    
    }

    public class UpdateException extends Exception{

    }
}