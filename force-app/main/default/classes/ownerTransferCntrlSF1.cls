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
public class ownerTransferCntrlSF1
{
    // getter setters for records and strings
    public Id oppId{get;set;}
    public String oppOwner{get;set;}
    public String jsonOpp{get;set;}
    /*
    Method Name - oppTeamCreationControllerSF1()
    Function - Constructor of the class which initializes all the member variables required through out the page.
    Also retrieve Opportunity details and help in populating team members on the page.
    */
    public ownerTransferCntrlSF1(ApexPages.StandardController controller)
    {
       oppId = ApexPages.currentPage().getParameters().get('id');
      @TestVisible oppWrapper objOpp = new oppWrapper();
       objOpp.oppId = oppId;
       jsonOpp= JSON.serialize(objOpp);
    }
    
    /*
    Method Name - Save()
    Function - This method will save the opportunity record with the new owner if the user is above in the role hierarchy or will throw an error.
    */
    @RemoteAction
    public static String save(oppWrapper objOpp){
        
        system.debug(objOpp);
        
        Boolean boolHasPermission= RoleUtilityOppTeam.checkRoleOppTeam(UserInfo.getUserId(), objOpp.oppId);
        Opportunity recOpp= [Select Id, IsPrivate,OwnerId, Name from Opportunity where Id=: objOpp.oppId];
        String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        system.debug('@@ boolHasPermission @@'+boolHasPermission);
        try
        {
            if((boolHasPermission==false || (recOpp.isPrivate==true && recOpp.OwnerId== userinfo.getProfileId())) && (profileName!='Business Administrator' && profileName!='System Administrator')) 
            {
                return 'Insufficient Privileges, please contact opportunity owner.';
            } 
            else
            {
                system.debug('@@@@@@@@@@@');
                recOpp.OwnerId = objOpp.oppOwner;
                update recOpp;
                system.debug('@@ recOpp @@'+recOpp);
                return 'Success';
            }
          
        }
        catch(DMLException ex){
            return ex.getDMLMessage(0);
        }
    }
    
    @RemoteAction
    public static List<Options> getUserList(String text) {
        text = text + '%';
      @TestVisible  List<Options> optionsL = new List<Options>();
        for(User u:[Select Id, Name from User where IsActive = True AND (Name Like:text OR FirstName Like:text OR LastName Like:text) Order By Name Limit 10]){
            optionsL.add(new Options(u.Name, u.Id));
        }
        return optionsL;
    }
    
  @TestVisible  public class Options {
        public String value;
        public String key;
        
        public Options(String value, String key){
            this.value = value;
            this.key = key;
        }
    }
    
   @TestVisible public class oppWrapper {
        public String oppId;
        public String oppOwner;
    }
}