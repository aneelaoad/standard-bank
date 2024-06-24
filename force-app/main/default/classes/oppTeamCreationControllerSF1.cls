/*************************************************************************************************
Class Name          : oppTeamCreationController
Version             : 1.0
Date Created        : 
Function            : This class acts as Controller of Opportunity Team Creation VF page specifically used for SF1 mobile app.
                      2015 - sprint 1.1 -EN-0481    
Modification Log    :
--------------------------------------------------------------------------------------------------
* Developer              Date                    Description
* ---------------        -----------             ----------------------------------------------
    Vaishali               8/1/2015               Initial version of the class.
**************************************************************************************************/
public class oppTeamCreationControllerSF1
{
    // getter setters for records and strings
    public Id oppId;
    public String allRoles{get;set;}
    public String allAccess{get;set;}
    public String jsonTM{get;set;}
    
    /*
    Method Name - oppTeamCreationControllerSF1()
    Function - Constructor of the class which initializes all the member variables required through out the page.
    Also retrieve Opportunity details and help in populating team members on the page.
    */
    public oppTeamCreationControllerSF1(ApexPages.StandardController controller)
    {
       oppId = ApexPages.currentPage().getParameters().get('id');
       
       List<Options> lstAllAccess = new List<Options>();
       lstAllAccess.add(new Options('Read Only', 'Read'));
       lstAllAccess.add(new Options('Read/Write', 'Edit'));
       allAccess = JSON.serialize(lstAllAccess);
       
       List<Options> lstAllRoles = new List<Options>();
       lstAllRoles.add(new Options('--none--', ''));
       for(Schema.PicklistEntry entries: OpportunityTeamMember.TeamMemberRole.getDescribe().getPicklistValues()){
           lstAllRoles.add(new Options(entries.getValue(), entries.getLabel()));
       }
       allRoles = JSON.serialize(lstAllRoles);
       
       TeamMember objTM = new TeamMember();
       objTM.oppId = oppId;
       jsonTM = JSON.serialize(objTM);
    }
    
    /*
    Method Name - Save()
    Function - This method will save the Opportunity Team member record and will also create the opportunity share record 
    based on the access given on the add member page.
    Also, it will take care of the security access on adding the team member to the opportunity.
    */
    @RemoteAction
    public static String save(TeamMember objTM){
        
        Boolean boolHasPermission= RoleUtilityOppTeam.checkRoleOppTeam(UserInfo.getUserId(), objTM.oppId);
        Opportunity recOpp= [Select Id, IsPrivate, Name from Opportunity where Id=: objTM.oppId];
        
        try
        {
            if(boolHasPermission==true && recOpp.isPrivate==false) 
            {
                OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
                oppTeamMember.OpportunityId = objTM.oppId;
                oppTeamMember.UserId = objTM.userId;
                oppTeamMember.TeamMemberRole = objTM.memberRole;
                insert oppTeamMember;  
                oppShare(objTM.oppAccess, oppTeamMember);
                return 'Success';
            } 
            else 
            {
                return 'Insufficient Privileges, please contact opportunity owner.';
            }
        }
        catch(DMLException ex){
            return ex.getDMLMessage(0);
        }
    }
    
    /*
    Method Name - oppShare()
    Function - This method creates opportunity share record based on the access given to the opportunity team member
    */
    public static void oppShare(String oppAccess, OpportunityTeamMember oppTeamMember)
    {
        OpportunityShare oppShare = new OpportunityShare();
        if(oppAccess=='Read')
        {
            oppShare.OpportunityAccessLevel= 'Read';  
        }
        else
        {
            oppShare.OpportunityAccessLevel= 'Edit';
        }
        oppShare.OpportunityId = oppTeamMember.OpportunityId;
        oppShare.UserOrGroupId = oppTeamMember.UserId;
        insert oppShare;            
    }
    
    @RemoteAction
    public static List<Options> getUserList(String text) {
        text = text + '%';
        List<Options> optionsL = new List<Options>();
        for(User u:[Select Id, Name from User where IsActive = True AND (Name Like:text OR FirstName Like:text OR LastName Like:text) Order By Name Limit 10]){
            optionsL.add(new Options(u.Name, u.Id));
        }
        return optionsL;
    }
    
    public class Options {
        public String value;
        public String key;
        
        public Options(String value, String key){
            this.value = value;
            this.key = key;
        }
    }
    
    public class TeamMember {
        public String oppId;
        public String oppAccess;
        public String userId;
        public String memberRole;
    }
}