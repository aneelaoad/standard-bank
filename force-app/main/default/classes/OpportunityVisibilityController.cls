/*************************************************************************
    @ Author        : Abhishek Vaideeswaran
    @ Date          : November 2015
    @ Test File     : OpportunityVisibilityController_Test
    @ Description   : Controller used to display Opportunity Team members and Sharing information 
    @ Enhancement   : EN-0956
                                                                                  
    @ Author        : Andrei Olteanu
    @ Date          : November 29 2016
    @ Description   : US-1497 add Lightning styling flag
    
*************************************************************************/

public class OpportunityVisibilityController{
    private final Opportunity oppt;
    public String TeamMemberListEmpty{get;set;}
    public Boolean IsTeamMemberEmpty{get;set;}
    public Boolean isLightning {get;set;}
    public String ShareListEmpty{get;set;}
    public Boolean IsShareListEmpty{get;set;}
    public List<OpportunityTeamMember> otmlst{get;set;}
    public List<OpportunityShare> oslst{get;set;}
    public List<OpportunityShare> oslstusr{get;set;}
    public List<OpportunityShare> oslstgrp{get;set;}
    public List<OpportunityShare> oslstroles{get;set;}
    public List<ID> groupIDforroles{get;set;}
    public List<ID> userIDfordiv{get;set;}
    public List<Group> rolelst{get;set;}
    public List<ShareWrapper> sharewrapperlist{get;set;}
    
    public OpportunityVisibilityController(ApexPages.StandardController controller){
        this.oppt = (Opportunity) controller.getRecord();
        IsTeamMemberEmpty = false;
        IsShareListEmpty = false;
        fetchoppotunityteammembers();
        oslstusr = new List<OpportunityShare>();
        oslstgrp = new List<OpportunityShare>();
        oslstroles = new List<OpportunityShare>();
        sharewrapperlist = new List<ShareWrapper>();
        groupIDforroles = new List<ID>();
        userIDfordiv = new List<ID>();
        fetchopportunityshare();
        if(ApexPages.currentPage().getParameters().get('uiTheme') != null) {
            if(ApexPages.currentPage().getParameters().get('uiTheme') == 'Theme4d') {
                isLightning = true;
            } else {
                isLightning = false;
            }
        }
    }
    private void fetchoppotunityteammembers(){
        if(oppt.ID != Null){
            otmlst = [Select ID, Name, OpportunityAccessLevel, TeamMemberRole, User_Division__c from OpportunityTeamMember where OpportunityId = :oppt.ID];    
        }
        if(otmlst.IsEmpty()){
            IsTeamMemberEmpty = True;
            TeamMemberListEmpty = ErrorMessages__c.getValues('OppTeamMemberEmptyMessage').Error_String__c; 
        }
    }
    private void fetchopportunityshare(){
        if(oppt.ID != Null){
            oslst = [Select ID,UserOrGroupId,UserOrGroup.Name,UserOrGroup.Profile.Name, RowCause, OpportunityAccessLevel from OpportunityShare where OpportunityId = :oppt.ID and Rowcause != 'Team'];    
        }
        if(oslst.IsEmpty()){
            IsShareListEmpty = True;
            ShareListEmpty = ErrorMessages__c.getValues('OppSharingundefined').Error_String__c;
            return; 
        }
        
        for(OpportunityShare osrec: oslst){
            if(osrec.UserOrGroup.Name != null){
                if(osrec.UserOrGroup.Profile.Name != null){
                    oslstusr.add(osrec);
                    userIDfordiv.add(osrec.UserOrGroupID);
                }
                else{
                    oslstgrp.add(osrec);
                }
            }
            else{
                oslstroles.add(osrec);
                groupIDforroles.add(osrec.UserOrGroupId);
            }
        }
        
        if(!oslstroles.IsEmpty()){
            rolelst = [Select ID, RelatedID, Related.Name,Type from Group where ID in : groupIDforroles and (Type = 'Role' or Type = 'RoleAndSubordinates')];
        }
        
        
        if(!oslstusr.IsEmpty()){
            List<User> usdivdetails = [Select ID, User_Division__c from User where ID in :userIDfordiv];
            for(OpportunityShare osusrgrprec: oslstusr){
                for(User urec: usdivdetails){
                    if(urec.ID == osusrgrprec.UserOrGroupId){
                        sharewrapperlist.add(new ShareWrapper('User: '+osusrgrprec.UserOrGroup.Name, osusrgrprec.UserOrGroupId, urec.User_Division__c, osusrgrprec.Rowcause, osusrgrprec));
                    }
                }
            }
        }
        
        if(!oslstgrp.IsEmpty()){
            for(OpportunityShare osusrgrprec: oslstgrp){
                sharewrapperlist.add(new ShareWrapper('Group: '+osusrgrprec.UserOrGroup.Name, osusrgrprec.UserOrGroupId,'', osusrgrprec.Rowcause, osusrgrprec));
            }
        }
        
        if(!oslstroles.IsEmpty()){
            for(OpportunityShare osrolerec : oslstroles){
                for(Group rolegrprec : rolelst ){
                    if(rolegrprec.ID == osrolerec.UserOrGroupId){
                        sharewrapperlist.add(new ShareWrapper(rolegrprec.Type+': '+rolegrprec.Related.Name, rolegrprec.RelatedID,'', osrolerec.Rowcause, osrolerec));
                    }
                }
            }
        }
        for(ShareWrapper shwrrec: sharewrapperlist){
            if(shwrrec.Reason == 'Owner'){
                shwrrec.Reason = 'Opportunity Owner';
            }
            else if(shwrrec.Reason == 'Rule'){
                shwrrec.Reason = 'Opportunity Sharing Rule';
            }
            else if(shwrrec.Reason == 'ImplicitChild'){
                shwrrec.Reason = 'Client Sharing Rule';
            }
        }
    }
    
    public Pagereference backFromLightning() {
        return new PageReference('/' + oppt.Id);
    }
    
    public class ShareWrapper{
        public String Name{get;set;}
        public ID recID{get;set;}
        public String UserDivision{get;set;}
        public String Reason{get;set;}
        public OpportunityShare oppsharerec{get;set;}
        public ShareWrapper(String namearg, ID idarg, String ud, String rsn, OpportunityShare recshare){
            Name = namearg;
            recID = idarg;
            UserDivision = ud;
            Reason = rsn;
            oppsharerec = recshare;
        }
    }
}