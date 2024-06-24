/*************************************************************************\
    @ Author        : Abhishek Arya
    @ Date          : Dec, 2010
    @ Test File     : TC_SyncCustClientTeam.cls
    @ Description   : Insertion and Updation of records in Custom client Team object from Standard Account Team member object.
    @
    @ Audit Trial   : Repeating block for each change to the code
    @ Last Modified By  :   Anurag Jain
    @ Last Modified On  :   07March2011
    @ Last Modified Reason  :   Added comments, indundation, change of global query string(for LIFO to FIFO)
    @
    @ Audit Trial   : Repeating block for each change to the code
    @ Last Modified By  :   Y.Balabramham
    @ Last Modified On  :   4/11/2011
    @ Last Modified Reason  : Case - 1845 , Getting the team role rankings and many per region 
                              team roles form custom setting adding into custom object.Modified the 
                              Validation rules based on our requirment.
        
    @ Last Modified By  :   Jorel Naidoo        
    @ Last Modified On  :   06 November 2012
    @ Last Modified Reason  : Case - 8165 , Added code to allow for sequential execution on batch jobs.
    
    @ Last Modified By  :   Krishna Bhagavan        
    @ Last Modified On  :   14 Feb 2013
    @ Last Modified Reason  : EN-96 , Changed code to remove country per CIF validation.
                              API Version moved from 20 to 27
                              
    @ Last Modified By  :   Ankit Khandelwal        
    @ Last Modified On  :    16 June 2013
    @ Last Modified Reason  : EN-166 , Batch optimized . Earlier , Custom Client Queried based on the AccountUserId__c, which a Non-indexed formula field.
                              logic has been changed to get related Custom Client Team Member.
                              Updated the API Version to 28
                              
    @ Last Modified By  :   Nitish Kumar        
    @ Last Modified On  :   August 2013
    @ Last Modified Reason  : EN-212 , Custom Client Team Issues
    
    
    @ Last Modified By  :   Manoj Gupta       
    @ Last Modified On  :   Dec 2015
    @ Last Modified Reason  : EN:0838 - Replacing Corporate Banking references to Client Coverage

    @ Last Modified By  :   Petr Svestka
    @ Last Modified On  :   Apr 27 2016
    @ Last Modified Reason  : US-1257 - Removing granting of RW access to Opp for Client Coverage user division.
****************************************************************************/


global class SyncCustClientTeam implements Schedulable, Database.Batchable<SObject>{
    
    //EN-166: Navin; Changes start
    global string query;
    Public Datetime dt; 
     //EN-166: Navin; Changes End 
    
    global void execute(SchedulableContext ctx){        
        // Start Batch Apex job        
       Database.executeBatch(new SyncCustClientTeam(),20);   
    }  
    
      Public SyncCustClientTeam(){
             query='SELECT ID,UserId,AccountAccessLevel,TeamMemberRole,AccountId,LastModifiedDate,User.Country FROM AccountTeamMember where user.isactive=true order by createdDate desc';
           }
    //Constructor End   
    
    global Database.QueryLocator start(Database.BatchableContext ctx){    
        return Database.getQueryLocator(query);         
    }
    
    public String accessLevelvalue(String a){
            String strAccessLevel;
            if(a=='Edit' || a=='All'){
                strAccessLevel='Read/Write';
            }
            else if(a=='Read'){
                strAccessLevel='Read Only';
            }
            else if(a=='None'){
                strAccessLevel='Private';
            }
            return strAccessLevel;        
       }
    
    
    global void execute(Database.BatchableContext ctx, List<SObject> records){  
               

        Map<String,String> AccUserId_map=new Map<String,String>();
        Map<String,AccountTeamMember> atm_map=new Map<String,AccountTeamMember>();
        Map<String,AccountShare> accshare_map=new Map<String,AccountShare>();
        List<AccountTeamMember> atmList=new List<AccountTeamMember>();
        List<String> AccUserId_list_forupdate=new List<String>();
        List<Custom_Client_Team__c> cct_list=new List<Custom_Client_Team__c>();        
        Set<String> atm_set_dupcheck=new Set<String>();        
        AccountTeamMember atm;  
        List<CSTManyperRegionTeamRoles__c> manyteamrole =[Select Name from CSTManyperRegionTeamRoles__c] ;       
        system.debug ('-----------Recrods--------------'+ records); 
        
        // Define Set to contain all the related account of a Account Team member.
            Set <Id> Acc_id = New Set <Id> ();
        
        for(SObject record : records){                          
            atm = (AccountTeamMember) record; 
            atmList.add(atm);
            AccUserId_map.put((String.valueOf(atm.AccountId)).substring(0,15)+'#'+(String.valueOf(atm.UserId)).substring(0,15),atm.AccountId); 
           // Stroing all the Account in set
              Acc_id.add(atm.AccountId);                           
        }
        List<AccountShare> AccShare=[select Id, AccountId,AccountAccessLevel,CaseAccessLevel,ContactAccessLevel,OpportunityAccessLevel,UserorGroupId from AccountShare where AccountId in:AccUserId_map.values() and (RowCause='Team' OR Rowcause = 'Manual'  OR RowCause='Owner') ];
        if(AccShare.size()>0){
            for(AccountShare ashare_obj:AccShare){
                accshare_map.put((String.valueOf(ashare_obj.AccountId)).substring(0,15)+'#'+(String.valueOf(ashare_obj.UserorGroupId)).substring(0,15),ashare_obj);    
            }
        }        
         
       
       
       // Fetching all the existing custom client Team member. If Custom client team already exists, then we do not create it. 
            set <String> existing_cct = new set <String> ();
            List<Custom_Client_Team__c> cct_upd = new List<Custom_Client_Team__c> ();
        
        // Removing the query on Non-Indexing field.Fetching all Custom Client Team
        if(atmList.size()>0 && AccShare.size()>0) {
            for ( Custom_Client_Team__c ext_cct :  [ SELECT Account_Owner__c, AccountUserId__c, Client_Coordinator__c, Client_Coordinator_BM__c, Case_Access__c,
                                                         Account__c, Client_Access__c, Name, Contact_Access__c,  Opportunity_Access__c, Id, RecordTypeId, TeamRoleSortValue__c, 
                                                         SourceFlag__c, SystemModstamp, Team_Member__c, Team_Member_First_Name__c, Team_Member_Last_Name__c, Client_Role__c, 
                                                         Business_Unit__c, User_Country__c, User_Division__c, User_Division_Coordinator_Key__c, User_Franco__c, UserProfileId__c
                                                         FROM Custom_Client_Team__c where Account__c IN :Acc_Id] ){
                                                         
                //system.debug('----' + String.Valueof (ext_cct.Team_Member__c).substring(0,2));
                // Adding the set of the existing custom client team...
                    if (ext_cct.Team_Member__c!= null){
                            existing_cct.add (ext_cct.AccountUserId__c);
                            cct_upd.add(ext_cct);
                    }       
              }
           }
        system.debug('-----cct_upd---------' + cct_upd);   
        system.debug('---Existing Custom Client-----' + existing_cct); 
        //String strVRDivCriteria = 'Global Markets';
       /*** Fetching the team role ranking list from TeamRoleRanking object from
          custom settings and Creating Map with the values.***/
       
        CSTTeamRoleRanking__c CSTTEAMRanking = CSTTeamRoleRanking__c.getInstance(); 
        List < CSTTeamRoleRanking__c> rankingList = CSTTeamRoleRanking__c.getall().values();
        
        Map <String,String> RankMap = new Map<String,String>();
        for (CSTTeamRoleRanking__c rank : rankingList){
            RankMap.put(rank.Name,rank.CSTTeamRoleRanking__c);
        }
        
        /***Fetching the Many per region team role list from ManyperregionTeamRole object from
          custom settings and Creating Map with the values.***/
        
   
        Map <String,String> roleMap = new Map<String,String>();
        for(CSTManyperRegionTeamRoles__c myrole :manyteamrole) {
            roleMap.put(myrole.Name, myrole.Name);
        }
        
        
        if(atmList.size()>0 && AccShare.size()>0){
            for(AccountTeamMember atm_obj:atmList){
                /***   To check for  allow the many per region team roles for the new records against 
                        the existing records per validation rules  if selected team role contatins rolemap on CST Phase(3) Requirement. ***/ 
                system.debug ('---Id-- ' + atm_obj.id);
                system.debug ('----Role map--- ' + atm_obj.TeamMemberRole); 
               if (! existing_cct.contains((String.valueOf(atm_obj.AccountId)).substring(0,15)+'#'+(String.valueOf(atm_obj.UserId)).substring(0,15))) 
                  {
                        
                    if (!roleMap.containsKey(atm_obj.TeamMemberRole)){ 
                        if(!atm_set_dupcheck.contains((String.valueOf(atm_obj.AccountId)).substring(0,15)+'#'+atm_obj.TeamMemberRole)
                        && accshare_map.get((String.valueOf(atm_obj.AccountId)).substring(0,15)+'#'+(String.valueOf(atm_obj.UserId)).substring(0,15)) != null){
                                       Custom_Client_Team__c cct_obj=new Custom_Client_Team__c(
                                                                                               Account__c=atm_obj.AccountId,
                                                                                               Team_Member__c=atm_obj.UserId,
                                                                                               Client_Role__c=atm_obj.TeamMemberRole,
                                                                                               //Giving the default access to the record getting created
                                                                                                 Client_Access__c = 'Read/Write',
                                                                                                 Case_Access__c = 'Read Only' ,
                                                                                                 Contact_Access__c = 'Read/Write',
                                                                                                 Opportunity_Access__c = 'Private'
                                                                                             );             
                                       /***Adding team role ranking values to Selected team roles  
                                               IF selected team role is Core Team role we will add a rank 1-8 else adding ‘_’ on sort filed.
                                             ***/
                                        
                                             
                                       system.debug('----cct Obj-----------' + cct_obj);
                                       if(RankMap.containsKey(cct_obj.Client_Role__c)){
                                            cct_obj.TeamRoleSortValue__c = (Integer.valueof(RankMap.get(cct_obj.Client_Role__c)) < 10) ? '0' + String.valueof(RankMap.get(cct_obj.Client_Role__c)) : String.valueof(cct_obj.Client_Role__c);
                                            //RankMap.get(cct_obj.Client_Role__c);
                                        }else{
                                            cct_obj.TeamRoleSortValue__c ='_';
                                         }
                                       cct_list.add(cct_obj);                                                 
                                       atm_set_dupcheck.add((String.valueOf(atm_obj.AccountId)).substring(0,15)+'#'+atm_obj.TeamMemberRole);
                        }else{
                            atm_set_dupcheck.add((String.valueOf(atm_obj.AccountId)).substring(0,15)+'#'+atm_obj.TeamMemberRole);
                        }
                    }else{
                        
                            if(accshare_map.get((String.valueOf(atm_obj.AccountId)).substring(0,15)+'#'+(String.valueOf(atm_obj.UserId)).substring(0,15)) != NULL){
                                       Custom_Client_Team__c cct_obj=new Custom_Client_Team__c(Account__c=atm_obj.AccountId,
                                                                                                Team_Member__c=atm_obj.UserId,
                                                                                                Client_Role__c=atm_obj.TeamMemberRole,
                                                                                                Client_Access__c=accessLevelvalue(accshare_map.get((String.valueOf(atm_obj.AccountId)).substring(0,15)+'#'+(String.valueOf(atm_obj.UserId)).substring(0,15)).AccountAccessLevel),
                                                                                                Case_Access__c=accessLevelvalue(accshare_map.get((String.valueOf(atm_obj.AccountId)).substring(0,15)+'#'+(String.valueOf(atm_obj.UserId)).substring(0,15)).CaseAccessLevel),
                                                                                                Contact_Access__c=accessLevelvalue(accshare_map.get((String.valueOf(atm_obj.AccountId)).substring(0,15)+'#'+(String.valueOf(atm_obj.UserId)).substring(0,15)).ContactAccessLevel),
                                                                                                Opportunity_Access__c=accessLevelvalue(accshare_map.get((String.valueOf(atm_obj.AccountId)).substring(0,15)+'#'+(String.valueOf(atm_obj.UserId)).substring(0,15)).OpportunityAccessLevel));             
                                       
                                       if(RankMap.containsKey(cct_obj.Client_Role__c)){
                                            cct_obj.TeamRoleSortValue__c = (Integer.valueof(RankMap.get(cct_obj.Client_Role__c)) < 10) ? '0' + String.valueof(RankMap.get(cct_obj.Client_Role__c)) : String.valueof(cct_obj.Client_Role__c);
                                            // RankMap.get(cct_obj.Client_Role__c);
                                        }else{
                                            cct_obj.TeamRoleSortValue__c ='_';
                                         }
                                       cct_list.add(cct_obj);                                                 
                                      
                        }else{
                            
                        }                
                    }                     
                }
                AccUserId_list_forupdate.add((String.valueOf(atm_obj.AccountId)).substring(0,15)+'#'+(String.valueOf(atm_obj.UserId)).substring(0,15));
                atm_map.put((String.valueOf(atm_obj.AccountId)).substring(0,15)+'#'+(String.valueOf(atm_obj.UserId)).substring(0,15),atm_obj);
            }
         }
        
         system.debug('---AccUserId_list_forupdate----' + AccUserId_list_forupdate);
         system.debug('---cct_list---' + cct_list);
         if(cct_list.size()>0){        
             database.insert(cct_list,false);  
            // insert cct_list;           
         }
        
        /* Below Logic has been commented for EN - 166. Below we were querying a Non Index , so Batch is long time to execute.*/
        //  if(AccUserId_list_forupdate.size()>0){
           // List<Custom_Client_Team__c> cct_upd=[Select Id,Team_Member__c,Account__c,AccountUserId__c,Client_Access__c,Case_Access__c,Contact_Access__c,Opportunity_Access__c,Client_Role__c,User_Division__c,User_Country__c from Custom_Client_Team__c where AccountUserId__c in:AccUserId_list_forupdate];
            
           List<Custom_Client_Team__c> cct_upd_final = new List<Custom_Client_Team__c> ();
            if(cct_upd.size()>0){
                
                for(Custom_Client_Team__c cct_obj_to_up:cct_upd){
                    if(accshare_map.get(cct_obj_to_up.AccountUserId__c)!=null && atm_map.get(cct_obj_to_up.AccountUserId__c) != null){
                        
                       If ( cct_obj_to_up.Client_Role__c <> atm_map.get(cct_obj_to_up.AccountUserId__c).TeamMemberRole ) {
                         
                            if (cct_obj_to_up.Client_Role__c <> atm_map.get(cct_obj_to_up.AccountUserId__c).TeamMemberRole) {
                                    cct_obj_to_up.Client_Role__c=atm_map.get(cct_obj_to_up.AccountUserId__c).TeamMemberRole;
                            }

                       }
                        
                        if (cct_obj_to_up.Opportunity_Access__c <> accessLevelvalue(accshare_map.get((String.valueOf(cct_obj_to_up.Account__c)).substring(0,15)+'#'+(String.valueOf(cct_obj_to_up.Team_Member__c)).substring(0,15)).OpportunityAccessLevel))    {
                                cct_obj_to_up.Opportunity_Access__c=accessLevelvalue(accshare_map.get((String.valueOf(cct_obj_to_up.Account__c)).substring(0,15)+'#'+(String.valueOf(cct_obj_to_up.Team_Member__c)).substring(0,15)).OpportunityAccessLevel);
                             }
                        
                        if (cct_obj_to_up.Contact_Access__c <> accessLevelvalue(accshare_map.get((String.valueOf(cct_obj_to_up.Account__c)).substring(0,15)+'#'+(String.valueOf(cct_obj_to_up.Team_Member__c)).substring(0,15)).ContactAccessLevel))    {
                                cct_obj_to_up.Contact_Access__c=accessLevelvalue(accshare_map.get((String.valueOf(cct_obj_to_up.Account__c)).substring(0,15)+'#'+(String.valueOf(cct_obj_to_up.Team_Member__c)).substring(0,15)).ContactAccessLevel);
                             }
                             
                        if (cct_obj_to_up.Case_Access__c <> accessLevelvalue(accshare_map.get((String.valueOf(cct_obj_to_up.Account__c)).substring(0,15)+'#'+(String.valueOf(cct_obj_to_up.Team_Member__c)).substring(0,15)).CaseAccessLevel))  {
                                cct_obj_to_up.Case_Access__c =accessLevelvalue(accshare_map.get((String.valueOf(cct_obj_to_up.Account__c)).substring(0,15)+'#'+(String.valueOf(cct_obj_to_up.Team_Member__c)).substring(0,15)).CaseAccessLevel);
                             }
                        
                        
                        If ( cct_obj_to_up.Client_Coordinator__c != true && cct_obj_to_up.Client_Coordinator_BM__c != true){
                            //Giving the default access to the record getting created
                             if (cct_obj_to_up.Client_Access__c <> 'Read/Write')    {
                              cct_obj_to_up.Client_Access__c = 'Read/Write';
                             }
                          }
                          
                        If ( cct_obj_to_up.Client_Coordinator__c == true || cct_obj_to_up.Client_Coordinator_BM__c == true){
                            //Giving the default access to the record getting created
                            String expectedOpportunityPermission = 'Private';
                            if(cct_obj_to_up.User_Division_Coordinator_Key__c == 'CC Client Coverage' || cct_obj_to_up.User_Division_Coordinator_Key__c == 'CCBM Client Coverage')  {
                                expectedOpportunityPermission = 'Read Only';
                            }
                             if (cct_obj_to_up.Client_Access__c <> 'Full Access')   {
                              cct_obj_to_up.Client_Access__c = 'Full Access';
                             }
                             
                             if (cct_obj_to_up.Opportunity_Access__c <> expectedOpportunityPermission)   {
                              cct_obj_to_up.Opportunity_Access__c = expectedOpportunityPermission;
                             }
                           }
                           
                           If ( cct_obj_to_up.Client_Coordinator__c == false && cct_obj_to_up.Client_Coordinator_BM__c == false){
                              cct_obj_to_up.Opportunity_Access__c = 'Private';
                           }
                          
                        cct_upd_final.add(cct_obj_to_up);
                    }
                }
                system.debug('--ohhk---' + cct_upd_final);
                if(cct_upd.size()>0)
                  database.update(cct_upd_final,false);
             
            }             
        system.debug('In execute End------------->');
     }
     global void finish(Database.BatchableContext BC){
        // Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
       
        //EN-166: Navin; Change starts
        // added CompletedDate field for updating the custom setting SyncCustClientTeam_Job_EndTime
         AsyncApexJob a = [Select Id, ApexClassID, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email,CompletedDate from AsyncApexJob where Id =:BC.getJobId()];
        //EN-166: Navin; Change Ends
        
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Environment_Variable__c env = Environment_Variable__c.getInstance();
        String onErrorEmail = env.BatchErrorEmails__c;
        String[] toAddresses = new String[] {onErrorEmail};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Client Team Batch>> SynchCustClientTeam ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
     }
}