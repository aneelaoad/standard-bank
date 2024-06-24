/*************************************************************************\
    @ Author        : Abhishek Arya/Anurag Jain
    @ Date          : Dec, 2010
    @ Test File     : TC_SyncCustClientTeamforDelete.cls
    @ Description   : This Batch class checks the Standard Account Team Member object and 
    @                 removes any duplicate record after applying the validation rules in LIFO pattern 
    @
    @ Audit Trial   : Repeating block for each change to the code
    @ Last Modified By  :   Anurag Jan
    @ Last Modified On  :   05 March 2011
    @ Last Modified Reason  :   Change from LIFO to FIFO
    @
    @ Audit Trial   : Repeating block for each change to the code
    @ Last Modified By  :   Y.Balabramham
    @ Last Modified On  :   4/11/2011
    @ Last Modified Reason  : Case - 1845 , Getting the team role rankings and many per region 
                              team roles form custom setting adding into custom object.Modified the 
                              Validation rules based on our requirment. And also removing duplicate records 
                              from custom client team object if any (force entry) (case:2719)
 
    @ Last Modified By  :   Jorel Naidoo        
    @ Last Modified On  :   06 November 2012
    @ Last Modified Reason  : Case - 8165 , Added code to allow for sequential execution on batch jobs.
    
    @ Last Modified By  :   Krishna Bhagavan        
    @ Last Modified On  :   14 Feb 2013
    @ Last Modified Reason  : EN-96 , Changed the code for removing per Country CIF Validation.
                              API Version moved from 20 to 27
                              
    @ Last Modified By  :   Nitish Kumar        
    @ Last Modified On  :   August 2013
    @ Last Modified Reason  : EN-212 , Custom Client Team Issues
                              Updated the API Version to 28
****************************************************************************/


global class SyncCustClientTeamforDelete implements Schedulable, Database.Batchable<SObject>{

     global void execute(SchedulableContext ctx){        
        
        // Start Batch Apex job        
        Database.executeBatch(new SyncCustClientTeamforDelete(),50);    
       } 
     
    Global String query='Select ID From Account';
  
    global Database.QueryLocator start(Database.BatchableContext ctx){    
        // Select all records from OTM
        return Database.getQueryLocator(query);         
    }

    global void execute(Database.BatchableContext ctx, List<SObject> records){
    
        List<AccountTeamMember> atm_list_tocheck_dup=new List<AccountTeamMember>();
        List<Id> AccId=new List<Id>();
        Set<String> atm_set=new Set<String>();
        Account acc;
        //String strVRDivCriteria = 'Global Markets';

        for(SObject record : records){                                      
            acc = (Account) record;           
            AccId.add(acc.Id);       
          } 
        
        
        // To get the ids to update records after duplicate removal
  
        Set<String> cctm_set_update=new Set<String>();
        List<Custom_Client_Team__c> cctm_list_tocheck_dup_update=new List<Custom_Client_Team__c>();
        
               
        List<Custom_Client_Team__c> cctm_all_update=[Select ID,Account__c,Team_Member__c From Custom_Client_Team__c where Account__c in:AccId order by ID asc];
        if(cctm_all_update.size()>0){
            for(Custom_Client_Team__c cctm_obj_update:cctm_all_Update){
                if(cctm_set_update.contains((String.valueOf(cctm_obj_update.Account__c)).substring(0,15)+'#'+cctm_obj_update.Team_Member__c)){ 
                    cctm_list_tocheck_dup_update.add(cctm_obj_update); 
                    
                }else{
                    cctm_set_update.add((String.valueOf(cctm_obj_update.Account__c)).substring(0,15)+'#'+cctm_obj_update.Team_Member__c); 
                    
                } 
            }   
                             
            
        }
        
        // Deleting duplicate records from custom client team object if any and updating the remaining record to complete the process.
        
        Set<String> cctm_set=new Set<String>();
        List<Custom_Client_Team__c> cctm_list_tocheck_dup=new List<Custom_Client_Team__c>(); 
                
        List<Custom_Client_Team__c> cctm_all=[Select ID,Account__c,Team_Member__c From Custom_Client_Team__c where Account__c in:AccId order by ID desc];
        if(cctm_all.size()>0){
            for(Custom_Client_Team__c cctm_obj:cctm_all){
                if(cctm_set.contains((String.valueOf(cctm_obj.Account__c)).substring(0,15)+'#'+cctm_obj.Team_Member__c)){ 
                    cctm_list_tocheck_dup.add(cctm_obj); 
                    
                }else{
                    cctm_set.add((String.valueOf(cctm_obj.Account__c)).substring(0,15)+'#'+cctm_obj.Team_Member__c); 
                    
                } 
            }   
            
            if(cctm_list_tocheck_dup.size()>0){
        
                database.delete(cctm_list_tocheck_dup,false);
                database.update(cctm_list_tocheck_dup_update,false);
                
            }
            
            
        }

        
          
          
          /***Fetching the Many per region team role list from ManyperregionTeamRole object from
          custom settings and Creating Map with the values.***/

        List<CSTManyperRegionTeamRoles__c> manyteamrole =[Select Name from CSTManyperRegionTeamRoles__c] ;
        Map <String,String> roleMap = new Map<String,String>();
        for(CSTManyperRegionTeamRoles__c myrole :manyteamrole) {
            roleMap.put(myrole.Name, myrole.Name);
        }
    
        //Records from AccountTeamMember are extracted in Desc order to imply the FIFO pattern.
        List<AccountTeamMember> atm_all=[Select ID,UserId,User.Country,AccountAccessLevel,TeamMemberRole,AccountId,CreatedDate,LastModifiedDate From AccountTeamMember where AccountId in:AccId order by CreatedDate desc];
            /***   To check for  allow the many per region team roles for the new records against 
                        the existing records per validation rules  if selected team role contatins rolemap on CST Phase(3) Requirement. ***/ 
                
        for(AccountTeamMember atm_obj:atm_all){            
         if(!roleMap.containsKey(atm_obj.TeamMemberRole) ){
            if(atm_set.contains((String.valueOf(atm_obj.AccountId)).substring(0,15)+'#'+atm_obj.TeamMemberRole)){                
                atm_list_tocheck_dup.add(atm_obj);                
            }else{
                atm_set.add((String.valueOf(atm_obj.AccountId)).substring(0,15)+'#'+atm_obj.TeamMemberRole);                
            }
         }                 
       }       
           
        if(atm_list_tocheck_dup.size()>0){
            database.delete(atm_list_tocheck_dup,false);
        }
              
    }    
    global void finish(Database.BatchableContext BC){
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Environment_Variable__c env = Environment_Variable__c.getInstance();
        String onErrorEmail = env.BatchErrorEmails__c;
        String[] toAddresses = new String[] {onErrorEmail};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Client Team Batch>> SynchCustClientTeamforDelete ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
        ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        //JN added to Automactically run the next batch job when this one completes
        //Build the system time of now + 30 seconds to schedule the batch apex.
        Datetime sysTime = System.now();
        sysTime = sysTime.addSeconds(30);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        system.debug(chron_exp);
        
        //Schedule the next job, and give it the system time so name is unique
        System.schedule('Runs SyncCustStdClientTeamForDeleteCCT'+System.Today(),chron_exp,new SyncCustStdClientTeamForDeleteCCT ());
   }    
}