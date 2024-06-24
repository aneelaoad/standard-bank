/*************************************************************************\
    @ Author        : Anurag Jain
    @ Date          : April, 2011
    @ Test File     : TC_SA_AddCustomClientTeam
    @ Description   : Controller class to cater to the Save and Replace functionality of 
    @                 Custom Client Team through UI.
    @
    @ Audit Trial   : Repeating block for each change to the code
    @ Last Modified By  :   Y.Balabramham
    @ Last Modified On  :   4/11/2011
    @ Last Modified Reason  : Case - 1845 , Getting the team role rankings and many per region 
                              team roles form custom setting adding into custom object. Modified the 
                              Validation rules based on our requirment.   
                              
    @ Last Modified By  :   Nitish Kumar     
    @ Last Modified On  :   14 Feb 2013
    @ Last Modified Reason  : EN-96 
                              API Version moved from 20 to 27 
                              
    @ Last Modified By  :   Nitish Kumar
    @ Last Modified On  :   09 May 2013
    @ Last Modified Reason  :   EN 160 :- Giving additional privilages to Admin profiles.
    
    @ Last Modified By  :   Nitish Kumar        
    @ Last Modified On  :   August 2013
    @ Last Modified Reason  : EN-212 , Custom Client Team Issues
                              Updated the API Version to 28

    @ Last Modified By  :   Petr Svestka
    @ Last Modified On  :   November 2015
    @ Last Modified Reason  : EN-910: adding a logic around CC, CCBM and enforcing access levels for CB team roles
    
    @ Last Modified By  :   Abhishek Vaideeswaran
    @ Last Modified On  :   07/12/2015
    @ Last Modified Reason  : EN - 958 - Included a validation to avoid addition of Core Team Members for CIF Target Client by CC/CCBM
    
    @ Last Modified By  :   Manoj Gupta       
    @ Last Modified On  :   Jan 2016
    @ Last Modified Reason  : EN:0967 - Replacing 'CB Relationship Manager' and 'CB Portfolio Manager' with ' Relationship Manager' and ' Portfolio Manager'

    @ Last Modified By  :   Petr Svestka
    @ Last Modified On  :   January 2016
    @ Last Modified Reason  : EN-966: changes around ' Portfolio Manager'

    @ Last Modified By  :   Petr Roubal
    @ Last Modified On  :   January 2016
    @ Last Modified Reason  : EN-945: CST - dependency between CST team role and user global area
    
    @ Last Modified By  :   Abhishek Vaideeswaran
    @ Last Modified On  :   Feb 2016
    @ Last Modified Reason  : EN - 1097 - Included a validation to avoid addition of Core Team Members for CIF Target Client for Ultimate Group Parent/Immediate parent record type with CIF__C not null by CC/CCBM
    
    @ Last Modified By  :   Jana Cechova
    @ Last Modified On  :   Apr 2016
    @ Last Modified Reason  : DEF-001770: Do not automatically check CC check box when CommB role are selected.
    
    @ Last Modified By  :   Abhishek V
    @ Last Modified On  :   Sep 2016
    @ Last Modified Reason  : US: 1528: Introduced Islightning check for navigation in lightning

    
****************************************************************************/

public with sharing class SA_AddCustomClientTeam {

    /**  Global Variables ***/
    public String TeamMember{get; set;}    
    public Custom_Client_Team__c CCTObj {get; set;}
    Public String theId;
    Public String clientName {get;set;}
    Public String OwnerId ;
    Public List<Custom_client_Team__c> lstCCtObj = new List<Custom_client_team__c>();
    Public Boolean disableReplaceBtn{get; set;}
    Public Boolean AdminFlag{get; set;}
    Public Boolean ccorbmcoreinsert{get; set;}
    Public Boolean corerole{get; set;}
    Public Boolean SameUsrError; 
    Public Boolean SaveNewFlag;
    public Boolean renderInsufficientPrivelegesBlock {get; set;}
    private final Boolean isLightning;
    
    Public class VRException extends Exception {}   
          
    Public List<UserProfileId__c> userprf=[Select Name, UserProfileId__c from UserProfileId__c 
                                           where Name in ('UserProfileId','Business Administrator',
                                                          'SA_Business_Administrator','SA_System_Administrator','System Administrator - Premier Support')]; 
                                                          
    Public List<Profile> adminProfiles = [Select Name , Id from Profile Where Name in ('Api User','Business Administrator', 'System Administrator')];
    Set<Id> adminIds = new Set<Id>() ;
 
   
    Public List<CSTManyperRegionTeamRoles__c> lstManyteamrole =[Select Name from CSTManyperRegionTeamRoles__c] ;
                                            
   
    /*** Constructor ***/
    public SA_AddCustomClientTeam() {    
        //CCTObj = (Custom_Client_Team__c)controller.getRecord();
        this.isLightning = isPageOriginLightning(ApexPages.currentPage().getParameters());
        CCTObj = new Custom_Client_Team__c();
        theId = ApexPages.currentPage().getParameters().get('id'); 
        clientName = ApexPages.currentPage().getParameters().get('Name');   
        CCTObj.Account__c = theId;
        AdminFlag=False;
        ccorbmcoreinsert = false;
        corerole = false;
        renderInsufficientPrivelegesBlock= false;
        String CurrUsrProfile = userinfo.getprofileid().substring(0,15);
        
        OwnerId = ApexPages.currentPage().getParameters().get('Owner');
             
        for ( Profile pro : adminProfiles){
            adminIds.add(pro.Id);
        }
        
                
        for(UserProfileId__c usr :userprf) {
            if(usr.UserProfileId__c.substring(0, 15) == CurrUsrProfile ){
                AdminFlag=True;
                renderInsufficientPrivelegesBlock= true;
                break;
              }  
         }
         
        if(AdminFlag==false){
        List<Custom_Client_Team__c> clientTeam = [SELECT  Id, Team_Member__c, Account__r.CIB_Target_Client__c FROM Custom_Client_Team__c where Account__c=:theId AND (((Client_Coordinator__c = true or Client_Coordinator_BM__c = true) AND Team_Member__c=:UserInfo.getUserId()))];
        if(clientTeam!=null && clientTeam.size()>0)
        renderInsufficientPrivelegesBlock= true;
        }
        disableReplaceBtn=True;
        SameUsrError=False;
     }
   
   public Boolean getIsLightning() {
        return this.isLightning;
    }

    public Boolean getIsClassic() {
        return !this.isLightning;
    }
    
    private Boolean isPageOriginLightning(Map<String, Object> params) {
        if (params.get('sfdcIFrameHost') != null ||
            params.get('sfdcIFrameOrigin') != null ||
            params.get('isdtp') == 'p1') {      
                return true;
            } else {      
                return false;
            }
    }
      
    /*** Save Record- Action called on the click of Save Button  ***/          
    public PageReference SaveRec() {
        ccorbmcoreinsert = false;
        corerole = false;
        Map < String, Schema.RecordTypeInfo > mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        Id UGPRecordTypeId = mapAccountRecordTypes.get('Ultimate Group Parent').getRecordTypeId(); 
        Id IPRecordTypeId = mapAccountRecordTypes.get('Immediate Parent').getRecordTypeId();
      
        if(String.isBlank(Cctobj.Client_Role__c)){
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.Error, 
                    'Please enter the Team Role.'));
            return null;
        }
      
        if(Cctobj.Client_Coordinator__c && Cctobj.Client_Coordinator_BM__c){ 
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.Error,
                                    'CC and CC BM cannot be the same user')); 

            return null;
        }

        //EN - 958 - Added logic to avoid addition of Core members on CST for UGP Target Client for users other than System Admin/Business Admin
        //EN - 1097 - Added logic to avoid addition of Core members on CST for UGP/Immediate Parent Target Client with CIF__C for users other than System Admin/Business Admin
        if(!AdminFlag && renderInsufficientPrivelegesBlock){
            Account accdetails = [  SELECT ID, CIB_Target_Client__c, CIF__c, RecordTypeId 
                                    FROM Account 
                                    WHERE Id = :theID];
            List<CST_Core_Roles__c> corelst = CST_Core_Roles__c.getall().values();
            for(CST_Core_Roles__c crrec: corelst){
                if(Cctobj.Client_Role__c == crrec.Value__c){
                    corerole = true;
                }
            }
            if((corerole || (Cctobj.Client_Coordinator__c)) 
                && (!String.isBlank(accdetails.CIF__c)) 
                && (accdetails.CIB_Target_Client__c) 
                && (accdetails.RecordTypeId == UGPRecordTypeId 
                    || accdetails.RecordTypeId == IPRecordTypeId)){
                ccorbmcoreinsert = true;
            }
        }
    
        if(ccorbmcoreinsert){
            ApexPages.addMessage(
                new ApexPages.Message(  ApexPages.Severity.Error, 
                                        Label.CoreRoleInsertDeleteError)); 

            return null;
        }

        disableReplaceBtn = true ;
        sameUsrError = false;
        lstCCtObj.clear();     

        /** Source Flag foeld in the Custom Client Team obj4ect signifies whether the operation been 
        performed on the record is through the API or Browser. Accordingly it helps in framing the business logic ***/   
        CCTObj.SourceFlag__c = DMN_ClientTeam.SOURCE_FLAG_STANDARD_MODE;

        
        // EN-910 enforce CC and CCBM for these Commercial Banking team roles
        /*  if (CCTObj.client_Role__c == 'CommB Relationship Manager') {
       
                CCTObj.client_Coordinator__c = true;
            } else{
                CCTObj.client_Coordinator__c = false;
            }
        */ // remove this functionality based on DEF-001770: Do not automatically check CC check box when CommB role are selected
       
        if(!AdminFlag) {
            CCTObj.Case_Access__c = 'Read Only';
            CCTObj.Contact_Access__c = 'Read/Write';
            CCTObj.Opportunity_Access__c = 'Private';
            CCTObj.Client_Access__c = 'Read/Write';
        }
        lstCCtObj.add(CCTObj);
       
       
        /*Fetching the team role ranking list from TeamRoleRanking object from
        custom settings and Creating Map with the values.*/
       
        CSTTeamRoleRanking__c CSTTEAMRanking = CSTTeamRoleRanking__c.getInstance(); 
        List<CSTTeamRoleRanking__c> rankingList = CSTTeamRoleRanking__c.getall().values();
        System.debug('------rankingList-----'+rankingList);
        Map<String,String> RankMap = new Map<String,String>();
         
        for (CSTTeamRoleRanking__c rank : rankingList){
            RankMap.put(rank.Name,rank.CSTTeamRoleRanking__c);
        }
         
        /*Adding team role ranking values to Selected team roles  
           IF selected team role is Core Team role we will add a rank 1-8 else adding ‘_’ on sort filed.
        */
        
        if(RankMap.containsKey(CCTObj.Client_Role__c)){ 
            CCTObj.TeamRoleSortValue__c =RankMap.get(CCTObj.Client_Role__c);   
        }
        else{
            CCTObj.TeamRoleSortValue__c ='_';
        }
       
        /*Fetching the Many per region team role list from ManyperregionTeamRole object from
        custom settings and Creating Map with the values.*/
        
        Map <String,String> roleMap = new Map<String,String>();
        for(CSTManyperRegionTeamRoles__c myrole :lstManyteamrole) {
            roleMap.put(myrole.Name, myrole.Name);
        }
   
        User usrobj = [ SELECT Id,Name, Business_unit__c, User_Division__c, User_Country__c, User_city__c 
                        FROM User 
                        WHERE Id = :CCTObj.Team_Member__c 
                        LIMIT 1];

        List<Custom_Client_Team__c> lstCctToInsert          = new List<Custom_Client_Team__c>();
        Set<Id> accIds                                      = new Set<Id>();

        Map<String,Custom_Client_Team__c> cctMap            = new Map<String,Custom_Client_Team__c>();
        Map<String,Custom_Client_Team__c> cctTeamRoleMap    = new Map<String,Custom_Client_Team__c>();
        Map<String,Custom_Client_Team__c> cctAsCCMap        = new Map<String,Custom_Client_Team__c>();
        Map<String,Custom_Client_Team__c> cctAsCCBMMap      = new Map<String,Custom_Client_Team__c>();
      
        for(Custom_Client_Team__c Cct:lstCCTObj){     
            AccIds.add(Cct.Account__c);
        } //end of for loop
      
        /***  Prepare the Maps to be used for applying the Validation rules against the existing records in the object  ****/     
        for(List<Custom_Client_Team__c> cs:[SELECT  Account__c,Team_Member__c,Team_Member__r.Name,
                                                    Business_Unit__c,User_Division__c, Client_Coordinator_BM__c,
                                                    Client_Role__c,Client_Coordinator__c, User_Country__c
                                            FROM Custom_Client_Team__c 
                                            WHERE Account__c in:AccIds]){
            for(Custom_Client_Team__c c:cs){
                CctMap.put(c.Account__c+'#'+c.Team_Member__c,c);
             
                // CctTeamRoleMap.put(c.Client_Role__c+'#'+c.User_Country__c+'#'+c.Account__c,c);
                //KB:Added for Role per CIF
                CctTeamRoleMap.put(c.Client_Role__c+'#'+c.Account__c,c);
                // CctTeamRoleMap_BU.put(c.Client_Role__c+'#'+c.User_Division__c+'#'+c.Business_Unit__c+'#'+c.User_Country__c+'#'+c.Account__c,c);
                if(c.Client_Coordinator__c){
                    CctAsCCMap.put(c.Account__c , c);
                }
            
                if(c.Client_Coordinator_BM__c){
                    CctAsCCBMMap.put(c.Account__c , c);
                }
            } //end of for loop 02
        }  // end of for loop 01
     
     
        /***   To check for the duplicate entries for the new records against the existing records per validation rules  
        (FIFO process is applied to remove duplicates) ****/      
        for(Custom_Client_Team__c Cct:lstCCTObj){
            String useradded = cct.Team_Member__c;

            if(Cct.Account_Owner__c == UserInfo.getUserId()){
                ApexPages.addMessage(
                    new ApexPages.Message(ApexPages.Severity.INFO, 'Insufficient Access'));

                return null;
            }

            if(CctMap.containskey(Cct.Account__c+'#'+Cct.Team_Member__c)){  
                SameUsrError = true;
                ApexPages.addMessage(
                    new ApexPages.Message(ApexPages.Severity.Error, 
                            'User<B> '+ CctMap.get(Cct.Account__c+'#'+Cct.Team_Member__c).Team_Member__r.Name 
                            + ' </B>already exists in the Client Team as a <B>' 
                            + CctMap.get(Cct.Account__c+'#'+Cct.Team_Member__c).Client_Role__c 
                            + '</B><BR><LI>Use the Delete Selected button on the Client Team to Delete <B>'
                            + CctMap.get(Cct.Account__c+'#'+Cct.Team_Member__c).Team_Member__r.Name 
                            +' </B>and then Add New to add a new user to the Team Role.'));

                return null;
            }
      
            /***   To check for  allow the many per region team roles for the new records against 
            the existing records per validation rules  on CST Phase(3) Requirement. ***/
      
            else if(!roleMap.containsKey(Cct.Client_Role__c) 
                    && (CctTeamRoleMap.containskey(Cct.Client_Role__c+'#'+Cct.Account__c)) 
                    && !Cct.Client_Coordinator__c 
                    && !Cct.Client_Coordinator_BM__c 
                    && !adminIds.contains(UserInfo.getProfileId())){
                
                Custom_Client_Team__c CctValue = CctTeamRoleMap.get(Cct.Client_Role__c+'#'+Cct.Account__c);
           
                /* NK
                disableReplaceBtn=False;
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Error, 'There is already a Team Member <b> '+CctValue.Team_Member__r.Name+' </b>with the same Team Role <b>'+CctValue.Client_Role__c+'</b> on the Client Team:<BR><LI>Please select an alternative Team Role to Add the Team Member to the Client Team OR <BR><LI>Click the Replace button to replace the Team Member currently on the Client Team with the new Team Member.');
                */
                ApexPages.addMessage(
                    new ApexPages.Message(ApexPages.Severity.Error, 
                            'There is already a Team Member <b> '+ CctValue.Team_Member__r.Name 
                            + ' </b>with the same Team Role <b>'+ CctValue.Client_Role__c 
                            + ' </b> on the Client Team:<BR><LI>If this Team Member is the CC / CC BM' 
                            + ' and an update needs to be made, please contact your administrator to facilitate' 
                            + ' this request for you. <BR><LI>If this Team Member is not the CC / CC BM,' 
                            + ' and you have access to do so, please remove the existing Team Member before' 
                            + ' adding a new Team Member in the same Team Role.'));

                return null; 
            }
     
            else if(!roleMap.containsKey(Cct.Client_Role__c) 
                        && (CctTeamRoleMap.containskey(Cct.Client_Role__c+'#'+Cct.Account__c)) 
                    && !Cct.Client_Coordinator__c 
                    && !Cct.Client_Coordinator_BM__c 
                    && adminIds.contains(UserInfo.getProfileId())){

                Custom_Client_Team__c CctValue = CctTeamRoleMap.get(Cct.Client_Role__c+'#'+Cct.Account__c);
                disableReplaceBtn = false;
                ApexPages.addMessage(
                    new ApexPages.Message(ApexPages.Severity.Error, 
                            'There is already a Team Member <b> '+CctValue.Team_Member__r.Name 
                            +' </b>with the same Team Role <b>'+CctValue.Client_Role__c 
                            +'</b> on the Client Team:<BR><LI>Please select an alternative Team Role ' 
                            + ' to Add the Team Member to the Client Team OR <BR><LI>Click the Replace ' 
                            + ' button to replace the Team Member currently on the Client Team with' 
                            + ' the new Team Member.'));
                return null;
            }
      
            else if(adminIds.contains(UserInfo.getProfileId())){
                if(!CctAsCCMap.Values().isEmpty()){
                    if( CctAsCCMap.get(Cct.Account__c).Client_Coordinator__c 
                        && Cct.Client_Coordinator__c 
                        && (!roleMap.containsKey(Cct.Client_Role__c) 
                            && (CctTeamRoleMap.containskey(Cct.Client_Role__c+'#'+Cct.Account__c)))){
                        
                        Custom_Client_Team__c CctAsCC = CctAsCCMap.get(Cct.Account__c);
                        system.debug('----Cct------'+Cct);
                        disableReplaceBtn = false;
                        //  ApexPages.Message ccMsg = new ApexPages.Message(ApexPages.Severity.Error, 'There is already a Team Member <b> '+CctTeamRoleMap.get(Cct.Client_Role__c+'#'+Cct.Account__c).Team_Member__r.Name+' </b>with the same Team Role <b>'+CctTeamRoleMap.get(Cct.Client_Role__c+'#'+Cct.Account__c).Client_Role__c+'</b> on the Client Team:<BR><LI>Please select an alternative Team Role to Add the Team Member to the Client Team OR <BR><LI>Click the Replace button to replace the Team Member currently on the Client Team with the new Team Member.<BR>' + '<b>' + CctAsCC.Team_Member__r.Name+ ' </b> also already exists as the Client Coordinator (CC) on the Client Team. Do you want to replace this person with <b>' + usrobj.Name + ' </b> as the Client Coordinator (CC)?' );
                        ApexPages.addMessage( 
                            new ApexPages.Message(ApexPages.Severity.Error, 
                                    '<b>' + CctTeamRoleMap.get(Cct.Client_Role__c+'#'
                                    + Cct.Account__c).Team_Member__r.Name 
                                    + ' </b>already exists as a Team Member with the same Team Role <b>' 
                                    + CctTeamRoleMap.get(Cct.Client_Role__c+'#'+Cct.Account__c).Client_Role__c 
                                    + '</b> on the Client Team.<BR> <b>' + CctAsCC.Team_Member__r.Name 
                                    + ' </b> also already exists as the Client Coordinator (CC) on the Client Team.' 
                                    + ' <LI>Please select an alternative Team Role to Add the Team Member' 
                                    + ' as the Client Coordinator to the Client Team OR <BR><LI>Click the Replace' 
                                    + ' button to replace the Team Member currently on the Client Team' 
                                    + ' with the new Team Member as the Client Coordinator.<BR>'  ));
      
                            return null;
                    }
        
                    if(CctAsCCMap.get(Cct.Account__c).Client_Coordinator__c && Cct.Client_Coordinator__c){
                        Custom_Client_Team__c CctAsCC = CctAsCCMap.get(Cct.Account__c);
                        system.debug('----Cct------'+Cct);
                        disableReplaceBtn=false;
                        ApexPages.addMessage(
                            new ApexPages.Message(ApexPages.Severity.Error,
                                    '<b>' + CctAsCC.Team_Member__r.Name + ' </b> already exists as the Client Coordinator'
                                    + ' (CC) on the Client Team. Do you want to replace this person with <b>' 
                                    + usrobj.Name + ' </b> as the Client Coordinator (CC)?' ));

                        return null;
                    }
                }          
        
                if(!CctAsCCBMMap.Values().isEmpty()){
                    if( CctAsCCBMMap.get(Cct.Account__c).Client_Coordinator_BM__c 
                        && Cct.Client_Coordinator_BM__c 
                        && (!roleMap.containsKey(Cct.Client_Role__c) 
                            && (CctTeamRoleMap.containskey(Cct.Client_Role__c+'#'+Cct.Account__c)))){
                        Custom_Client_Team__c CctAsCCBM = CctAsCCBMMap.get(Cct.Account__c);
                        system.debug('----Cct------'+Cct);
                        disableReplaceBtn = false;
                        //  ApexPages.Message ccBMMsg = new ApexPages.Message(ApexPages.Severity.Error, 'There is already a Team Member <b> '+CctTeamRoleMap.get(Cct.Client_Role__c+'#'+Cct.Account__c).Team_Member__r.Name+' </b>with the same Team Role <b>'+CctTeamRoleMap.get(Cct.Client_Role__c+'#'+Cct.Account__c).Client_Role__c+'</b> on the Client Team:<BR><LI>Please select an alternative Team Role to Add the Team Member to the Client Team OR <BR><LI>Click the Replace button to replace the Team Member currently on the Client Team with the new Team Member.<BR>' + '<b>' + CctAsCCBM.Team_Member__r.Name+ ' </b> also already exists as the Client Coordinator BM (CCBM) on the Client Team. Do you want to replace this person with <b>' + usrobj.Name + ' </b> as the Client Coordinator BM (CCBM)?' );
                        ApexPages.addMessage( 
                            new ApexPages.Message(ApexPages.Severity.Error, 
                                    '<b>' + CctTeamRoleMap.get(Cct.Client_Role__c+'#'+ Cct.Account__c).Team_Member__r.Name 
                                    + ' </b>already exists as a Team Member with the same Team Role <b>' 
                                    + CctTeamRoleMap.get(Cct.Client_Role__c+'#'+Cct.Account__c).Client_Role__c 
                                    + '</b> on the Client Team.<BR> <b>' + CctAsCCBM.Team_Member__r.Name 
                                    + ' </b> also already exists as the Client Coordinator BM (CCBM) on the Client Team.' 
                                    + ' <LI>Please select an alternative Team Role to Add the Team Member as the Client Coordinator'
                                    + ' BM (CCBM) to the Client Team OR <BR><LI>Click the Replace button to replace the Team Member'
                                    + ' currently on the Client Team with the new Team Member as the Client Coordinator BM (CCBM).<BR>'));
                        return null;
                    }
          
                    if(CctAsCCBMMap.get(Cct.Account__c).Client_Coordinator_BM__c && Cct.Client_Coordinator_BM__c){
                        Custom_Client_Team__c CctAsCCBM = CctAsCCBMMap.get(Cct.Account__c);
                        system.debug('----Cct------'+Cct);
                        disableReplaceBtn=False;
                        ApexPages.addMessage(
                            new ApexPages.Message(ApexPages.Severity.Error,
                                    '<b>' + CctAsCCBM.Team_Member__r.Name
                                    + ' </b> already exists as the Client Coordinator BM (CCBM) on the Client Team.'
                                    + ' Do you want to replace this person with <b>' + usrobj.Name 
                                    + ' </b> as the Client Coordinator BM (CCBM)?'));
                   
                        return null; 
                    }
                }
            }  
        } //end of For loop
     
        if(disableReplaceBtn && !SameUsrError) {
            //JN added to display Validation on Page
            try{
                if(CCTObj.Client_Coordinator__c ){//Check If Record is Flagged as CC then Update Client Access
                    CCTObj.Client_Access__c = 'Full Access';
                    CCTObj.Opportunity_Access__c = 'Read/Write';
                    CCTObj.TeamRoleSortValue__c = '01';
                }
                lstCctToInsert.add(CCTObj);

                if(!lstCctToInsert.isEmpty()){
                    insert lstCctToInsert;
                }
            }
            catch(Exception e){
                ApexPages.addMessages(e);
                return null;
            }

            return new PageReference('/' + theId);
        }
        else {
            SameUsrError = false;
            return null;
        }            
    }  

  /*** SaveNew- Action called on the click of Save & New Button ***/   
   Public pagereference SaveNew() {
       SaveNewFlag = True;
       PageReference Pg = SaveRec();
       if (pg == null) {
          return pg;
        } 
       PageReference pageRef;
       if(isLightning){
           pageRef = page.SA_AddCustomClient_UserView_lds;
       }else{
           pageRef = page.SA_AddCustomClient_UserView;
       }
       pageRef.getParameters().put('id',theId);
       pageRef.getParameters().put('Owner' ,OwnerId);
       pageRef.setredirect(true);
       return pageRef;
     }      

   Public pagereference Cancel() {
       PageReference pageRef = new PageReference('/' + theId); 
       return pageRef;
     }      



  /*** ReplaceRec - Action called on the click of Replace Button ***/   
    public pagereference ReplaceRec() {
    
        List<Custom_Client_Team__c> lstCctToReplace =new List<Custom_Client_Team__c>();
    
        if(Cctobj.Client_Coordinator__c&& Cctobj.Client_Coordinator_BM__c){ 
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.Error,'CC and CC BM cannot be the same user')); 
            return null;
        } 
    
        if(String.isBlank(Cctobj.Client_Role__c)){
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.Error, 'Please enter the Team Role.'));
            return null;
        }
      
       CCTObj.SourceFlag__c = DMN_ClientTeam.SOURCE_FLAG_REPLACE_MODE;

        if(!AdminFlag) {
            CCTObj.Case_Access__c           = 'Read Only';
            CCTObj.Contact_Access__c        = 'Read/Write';
            CCTObj.Opportunity_Access__c    = 'Private';
            CCTObj.Client_Access__c         = 'Read/Write';
        }
       
        try{
            if(CCTObj.Client_Coordinator__c){//Check If Record is Flagged as CC then Update Client Access
                CCTObj.Client_Access__c         = 'Full Access';
                CCTObj.Opportunity_Access__c    = 'Read/Write';
                CCTObj.TeamRoleSortValue__c     = '01';
            } 
            lstCctToReplace.add(CCTObj);
            
            /* Commented by Nitish (Validation no longer in Place)
             List<Custom_Client_Team__c> lstCustClientTeam = [select id  from Custom_Client_Team__c where Account__c =: CCTObj.Account__c AND Client_Role__c =: CCTObj.Client_Role__c AND Client_Coordinator__c = true];
            system.debug('lstCustClientTeam ==== ' + lstCustClientTeam.size());
            if(lstCustClientTeam.size()>0 && !adminIds.contains(UserInfo.getProfileId())){
             ApexPages.Message myCC_ReplaceMsg = new ApexPages.Message(ApexPages.Severity.Error, ErrorMessages__c.getValues('CC_ReplaceValidation').Error_String__c);
             ApexPages.addMessage(myCC_ReplaceMsg);
            return null;
             }else{
            */
            if(!lstCctToReplace.isEmpty()){
                insert lstCctToReplace;
            }
          //   }
        }
        catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,e.getMessage()));
            return null;
        }
       
       PageReference pageRef = new PageReference('/' + theId); 
       return pageRef;
     }      
     
    public PageReference back(){
        return new PageReference('/'+theId);
    }      
}