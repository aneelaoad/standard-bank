/*************************************************************************\
    @ Author        : Abhishek Arya
    @ Date          : Dec, 2010
    @ Test File     : TC_SyncCustStdClientTeamForDeleteCCT.cls
    @ Description   : This Batch class deletes the extra records from the Custom Client Team object 
    @                 keeping it in Synch with the Standard AccountTeamMember object.
    @
    @ Audit Trial   : Repeating block for each change to the code
    @ Last Modified By  :   Anurag Jan
    @ Last Modified On  :   19 May 2011
    @ Last Modified Reason  :   Done the Code review.
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
    
    @ Last Modified By  :   Navin Rai
    @ Last Modified On  :   14/06/2013
    @ Last Modified Reason : EN-101.Changed the code to schedule the Batch class SyncCustClientTeam 
                             Changed the version to 28. 
****************************************************************************/

global class SyncCustStdClientTeamForDeleteCCT implements Schedulable,Database.Batchable<SObject>{
    
    global String query='Select ID From Account order by LastModifiedDate asc';
    
    global Database.QueryLocator start(Database.BatchableContext ctx){
        return Database.getQueryLocator(query);         
      }

    global void execute(SchedulableContext ctx){        
        Database.executeBatch(new SyncCustStdClientTeamForDeleteCCT()); // Start Batch Apex job    
      } 

    global void execute(Database.BatchableContext ctx, List<SObject> records){  
               
        List<Id> AccId=new List<Id>();
        Map<String,AccountTeamMember> accountTeamMembersRecordMap=new Map<String,AccountTeamMember>();
        Map<String,Custom_Client_Team__c> customClientTeamRecordMap=new Map<String,Custom_Client_Team__c>();
        List<String> customClientTeamKeyValue=new List<String>();
        Account acc;
        //List<CSTManyperRegionTeamRoles__c> manyteamrole =[Select Name, ManyPerRegionTeamRoles__c from CSTManyperRegionTeamRoles__c] ;
        for(SObject record : records){                          
           acc = (Account) record;
           AccId.add(acc.Id);
        }
        List<AccountTeamMember> accountTeamMemberRecords=[Select ID,UserId,AccountAccessLevel,TeamMemberRole,AccountId,LastModifiedDate From AccountTeamMember where AccountId in:AccId];
        List<Custom_Client_Team__c> customClientTeamRecords=[Select Id,Team_Member__c,Account__c,AccountUserId__c,Client_Role__c,User_Division__c,Client_Coordinator__c,Client_Coordinator_BM__c from Custom_Client_Team__c where Account__c in:AccId];
        List<Custom_Client_Team__c> customClientTeamRecordsToBeDeleted=new List<Custom_Client_Team__c>();
        
       
            if(customClientTeamRecords.size()>0){
            for(AccountTeamMember atm_obj:accountTeamMemberRecords){
                accountTeamMembersRecordMap.put((String.valueOf(atm_obj.AccountId)).substring(0,15)+'#'+(String.valueOf(atm_obj.UserId)).substring(0,15),atm_obj);
            }
           
            for(Custom_Client_Team__c cct_obj:customClientTeamRecords){
                customClientTeamRecordMap.put((String.valueOf(cct_obj.Account__c)).substring(0,15)+'#'+(String.valueOf(cct_obj.Team_Member__c)).substring(0,15),cct_obj);
                customClientTeamKeyValue.add((String.valueOf(cct_obj.Account__c)).substring(0,15)+'#'+(String.valueOf(cct_obj.Team_Member__c)).substring(0,15));
            }
            
           
                for(String cct_key:customClientTeamKeyValue){
                        if(!accountTeamMembersRecordMap.containsKey(cct_key)){
                          customClientTeamRecordsToBeDeleted.add(customClientTeamRecordMap.get(cct_key));
                        }
                }
                         
                if(customClientTeamRecordsToBeDeleted.size()>0){
                    delete customClientTeamRecordsToBeDeleted;
                }
             
        }

               
    }
    
    global void finish(Database.BatchableContext BC){
        // Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Environment_Variable__c env = Environment_Variable__c.getInstance();
        
        String onErrorEmail = env.BatchErrorEmails__c;
        String[] toAddresses = new String[] {onErrorEmail};
        //String[] toAddresses = new String[] {'balabramham_yadamakanti@mahindrasatyam.com'};
        mail.setToAddresses(toAddresses);
      
        mail.setSubject('Client Team Batch>> SynchCustStdClientTeamforDeleteCCT ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       //JN added to Automactically run the next batch job when this one completes
        //Build the system time of now + 30 seconds to schedule the batch apex.
        Datetime sysTime = System.now();
        sysTime = sysTime.addSeconds(30);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
        system.debug(chron_exp);
        
        //Schedule the next job, and give it the system time so name is unique
        System.schedule('Runs SyncCustClientTeam'+System.Today(),chron_exp,new SyncCustClientTeam ());
        
 
   }
        
}