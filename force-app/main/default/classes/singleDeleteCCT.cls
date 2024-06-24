/*************************************************************************\
    @ Author        : Abhishek Arya
    @ Date          : Dec, 2010
    @ Test File     : TC_SingleDeleteCCT.cls
    @ Description   : VF controller extension to cater to the Delete functionality of 3
    @                 Client Team Member when a single record is chosen to be deleted from the UI    
    @
    @ Audit Trial   : Repeating block for each change to the code
    @ Last Modified By  :   Anurag Jain
    @ Last Modified On  :   22March2011
    @ Last Modified Reason  :   Code comments, formatting, code optimization
    @                          
    @ Last Modified By  :   Navin Rai
    @ Last Modified On  :   14/06/2013
    @ Last Modified Reason  : EN-101.Reverted to standard OpportunityTeamMember.Hence,removed 
    @                         Custom_sales_Team functinality.
    @                         Changed the version to 28.
    @
    @ Last Modified By  :   Revashlin Iyman
    @ Last Modified On  :   03/09/2014
    @ Last Modified Reason  : C-00001150 - Removing user from CST list does not remove them from opportunity team when that option is enabled
    @                         The code was removed instead of updated to point and removed Team Members from the Standard Opportunity Team
    @                         Added Select statement to get members from the standard OppTeam and uncommented the variables and delete call
    
    @ Last Modified By  :   Abhishek Vaideeswaran
    @ Last Modified On  :   07/12/2015
    @ Last Modified Reason  : EN - 958 - Included a validation to avoid deletion of Core Team Members for CIF Target Client by CC/CCBM
    
    @ Last Modified By  :   Abhishek Vaideeswaran
    @ Last Modified On  :   Feb 2016
    @ Last Modified Reason  : EN - 1097 - Included a validation to avoid deletion of Core Team Members for CIF Target Client for Ultimate Group Parent/Immediate parent record type with CIF__C not null by CC/CCBM
    
    @ Last Modified By  :   Jana Cechova
    @ Last Modified On  :   Apr 2016
    @ Last Modified Reason  : US-1223 - CST - Show error message immediately change functionaly for error message which will be shown after click on the custom batton 'Delete Selected'
****************************************************************************/

public class singleDeleteCCT{

    List<ID> IdArray = new List<ID>();
    Set<Id> SetIDArray = new Set<ID>();
    List<Id> AccIds1= new List<Id>();
    List<Custom_Client_Team__c> cct_list1=new List<Custom_Client_Team__c>();
    Boolean bool;
    public Boolean corememberpresent {get;set;}
    public Boolean hasCctIds{get; set;} 
    
    /* Definition for constructor singleDeleteCCT */
    public singleDeleteCCT() {
        corememberpresent = false;  
    }

    public singleDeleteCCT(ApexPages.StandardSetController controller) {
        System.debug('controller ' + controller);
        if(controller != null &&controller.getSelected() != null){
            for(SObject rec : controller.getSelected()){
                IdArray.add((String)rec.get('id'));
            }

            String recordId = ApexPages.currentPage().getParameters().get('id');

            if(IdArray.isEmpty() 
                && String.isNotBlank(recordId) 
                && ((Id)recordId).getSobjectType() == Custom_Client_Team__c.SobjectType){
                IdArray.add(ApexPages.currentPage().getParameters().get('id'));
            }

            init(); 
        }
        
    }
    
    /*** Constructor ***/   
    public singleDeleteCCT(ApexPages.StandardController controller) {  
        if(controller != null){
            IdArray.add(controller.getId());
            init();
        }
    } 

    private void init(){
        corememberpresent = false;
        hasCctIds = true;

        SetIdArray.AddAll(IdArray);
        IdArray.clear();
        IdArray.AddAll(SetIdArray);

        System.debug('IdArray ' + IdArray);

        if(IdArray.isEmpty()){
            hasCctIds = false;
            String errorMessage = 'You have to choose at least one record to Delete.';
            if(getisLightnigUser() && String.isNotBlank(ApexPages.currentPage().getParameters().get('id'))){
                errorMessage += ' Please click on the following link to select and delete client team members';
                errorMessage += ' <a href="/one/one.app#/sObject/' 
                                    + ApexPages.currentPage().getParameters().get('id')
                                    + '/rlName/Custom_Client_Teams__r/view">Client Team View</a>';
            }
            ApexPages.addmessage(new ApexPages.Message(ApexPages.Severity.Error, errorMessage));
            return;
        }
          
        cct_list1=[select Id,Team_Member__c,Account__c from Custom_Client_Team__c where Id in :IdArray];
   
        for(Custom_Client_Team__c cct_obj:cct_list1){    
            AccIds1.add(cct_obj.Account__c);
        } 
    }

    public void setcheckboxValue1(Boolean b){
        bool=b;
     }
     
    public Boolean getcheckboxValue1(){
        return bool;
     } 

    public PageReference back(){  
        String returnUrl;

        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('retURL'))){
            returnUrl = ApexPages.currentPage().getParameters().get('retURL');
        }
        if(String.isNotBlank(ApexPages.currentPage().getParameters().get('id'))){
            returnUrl = ApexPages.currentPage().getParameters().get('id');
        }
        else if(!AccIds1.isEmpty()){
            returnUrl = AccIds1.get(0);
        }
        else{
            returnUrl = '001';
        }
        return new PageReference('/'+ returnUrl);
    }
  
  /* This method contains original functionality for check acces to delete CST Member/s if user is redirected to the Opportunity Team Member removal screen  */
   public PageReference deleteSinglecct(){

       // called method canDeleteCSTmember where input parameters are ids from CST Members which should be deleted
        innerCanDelete canDelete = canDeleteCSTmember(SetIDArray);
        
        if(canDelete.msg !='ok'){ // if msg from CheckDelCustomClientTeam.cls not equals ok than will be shown msg from canDelete()
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.FATAL, canDelete.msg);
            ApexPages.addMessage(msg);
            return null; 
        }
        try{
            if(canDelete.cct_list.size()>0 && ((canDelete.acc_list[0].OwnerId==UserInfo.getUserId()) || canDelete.Userflag1==true)) {
                delete canDelete.cct_list; // selected CST member/s will be deleted
            }   
            if(canDelete.cst_list.size()>0) {
                delete canDelete.cst_list; // selected CST member/s will be deleted
            }
        }
        catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.FATAL, ex.getMessage()));
        } 
   
       if(canDelete.AccIds.size()>0) {
            return new PageReference('/'+canDelete.AccIds.get(0));
        }else{
            return null;
           }
     }   
    
     /* This inner class contains set variables from method canDeleteCSTmember()  */
     public class innerCanDelete{ 
            string msg {get;set;} 
            List<Custom_Client_Team__c> cct_list {get;set;} 
            List<OpportunityTeamMember> cst_list {get;set;} 
            List<Id> AccIds {get;set;} 
            List<Account> acc_list {get;set;} 
            boolean Userflag1 {get;set;} 
            
    }
    
    /* This class contains inner class and logic for access to delete CST member/s */
    public innerCanDelete canDeleteCSTmember(Set<Id> setIDArray){ 
        
     Map < String, Schema.RecordTypeInfo > mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
       Id UGPRecordTypeId = mapAccountRecordTypes.get('Ultimate Group Parent').getRecordTypeId();
       Id IPRecordTypeId = mapAccountRecordTypes.get('Immediate Parent').getRecordTypeId();
       
       List<Custom_Client_Team__c> cct_list=new List<Custom_Client_Team__c>();
       List<OpportunityTeamMember> cst_list=new List<OpportunityTeamMember>();
       Set<Id> TeamMemIds= new Set<Id>();
       List<Id> AccIds= new List<Id>();
       Boolean Userflag1=false, cCPresent = false, goAhead = false;
           
       cct_list=[select Id,Team_Member__c,Account__c, Account__r.CIB_Target_Client__c, Account__r.CIF__c, Account__r.RecordTypeId , Core__c, Client_Coordinator__c from Custom_Client_Team__c where Id in :SetIDArray];
   
       for(Custom_Client_Team__c cct_obj:cct_list){
            TeamMemIds.add(cct_obj.Team_Member__c);    
            AccIds.add(cct_obj.Account__c);
            //Added extra logic to filter deletion of CC from CST
            if(cct_obj.Client_Coordinator__c){
                cCPresent = true;
            }
            if((!string.isBlank(cct_obj.Account__r.CIF__c)) && cct_obj.Account__r.CIB_Target_Client__c && cct_obj.Core__c && (cct_obj.Account__r.RecordTypeID == UGPRecordTypeId || cct_obj.Account__r.RecordTypeID == IPRecordTypeId)){
                corememberpresent = True;
            }
        } 
   
       if(bool==TRUE) {
            List<Opportunity> opplist=[select Id from Opportunity where AccountId=:AccIds and (StageName=:'1 - Lead' OR StageName=:'2 - Develop')];
            cst_list=[select Id, UserId, OpportunityId from OpportunityTeamMember where OpportunityId in:opplist and UserId in:TeamMemIds];
       }
       
       List<Account> acc_list=[select Id,OwnerId from Account where Id=:AccIds];
       List<UserProfileId__c> userprf1=[Select Name, UserProfileId__c from UserProfileId__c where UserProfileId__c=:UserInfo.getProfileId().substring(0,15)]; 
      
       for(Custom_Client_Team__c ccT : [SELECT  Id,Account__r.OwnerId, Account__c,Team_Member__c,Client_Coordinator__c,Client_Coordinator_BM__c FROM Custom_Client_Team__c where Account__c=:acc_list[0].Id]){ 
       if(ccT.Team_Member__c==UserInfo.getUserId() && ccT.Client_Coordinator__c){
            if(!corememberpresent){
                goAhead = true;
            }else{
                goAhead = false;
            }
        }
        if(ccT.Team_Member__c==UserInfo.getUserId() && ccT.Client_Coordinator_BM__c){
            if(ccPresent || corememberpresent){
                goAhead = false;
            }else{
                goAhead = true;
            }
        }
        if(cCT.Account__r.OwnerId == UserInfo.getUserId()){
            if(!corememberpresent){
                goAhead = true;
            }else{
                goAhead = false;
            }
        }
       }
       if(userprf1.size()>0 || goAhead) {
            Userflag1=true;    
        }

       string returnmessage = 'ok';
       if((acc_list.size()>0) && (Userflag1!=true ) || (TeamMemIds!=null && TeamMemIds.contains(UserInfo.getUserId()))){
            if(corememberpresent){
                returnmessage = Label.CoreRoleInsertDeleteError;
            }
            else if(ccPresent && goAhead){
                returnmessage = 'Insufficient Privileges- You do not have the level of access necessary to perform the operation you requested. Please contact your administrator if access is necessary.';
                           
            }else{
                returnmessage = 'Insufficient Privileges- You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.';
            }
        }
        
        
        innerCanDelete instCanDelete = new innerCanDelete();
        instCanDelete.msg = returnmessage;
        instCanDelete.cct_list = cct_list;
        instCanDelete.cst_list = cst_list;
        instCanDelete.AccIds = AccIds;
        instCanDelete.acc_list = acc_list;
        instCanDelete.Userflag1 = Userflag1;
        
        return instCanDelete;   
    }
    
    /* returns msg if user has priviledges to delete CST member/s based on result from canDeleteCSTmember logic where input parameters are Ids CST member/s which should be deleted.  */
    public String doesUserHasPrivilges(Set<Id> setIDArray) {
        innerCanDelete canDelete = canDeleteCSTmember(setIDArray);
        return canDelete.msg;
    }

    public Boolean getisLightnigUser(){
        return UTL_User.isLightnigUser();
    }

    public Boolean gethasMessage(){
        return ApexPages.hasMessages();
    }
}