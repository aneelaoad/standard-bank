/*************************************************************************
    @ Author        : Nitish Kumar
    @ Date          : April 2014
    @ Test File     : 
    @ Description   : Batch Class which created the Global Client Revenue sharing record 
    @ Enhancement   : EN -- 380
    
    @ Audit Trial   : Repeating block for each change to the code
    -----------------------------------------------------------------------------
***********************************************************************************/


global class gCRApexSharingBatch implements Database.Batchable<sObject> {
    
     //Global Variable
     global String query;
     
     global gCRApexSharingBatch(){
        this.query = 'Select Client__c, Client_CIF_Number__c from Global_Client_Revenue__c';
     }
    
    
    //Start method of the batch class
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    
     //Execute method of the batch class
    global void execute(Database.BatchableContext BC, List<Global_Client_Revenue__c> records){
        
        Set<Id> accountSet = new Set<Id>();
        list<Global_Client_Revenue__Share> gcrSharelst = new list<Global_Client_Revenue__Share>();
        
        for (Global_Client_Revenue__c gCR : records){
             accountSet.add(gCR.Client__c);
        }
        
        list<Custom_Client_Team__c> lstCstTeam = [Select Id, Team_Member__c, Account__c from Custom_Client_Team__c where Account__c =: accountSet];
        
        //Creating the Sharing record for Global Client Revenue
        for(Custom_Client_Team__c cct: lstCstTeam){
          
          for (Global_Client_Revenue__c gCR : records){
              If(gCR.Client__c == cct.Account__c) {
                Global_Client_Revenue__Share gcrShare = new Global_Client_Revenue__Share();
                gcrShare.UserOrGroupId = cct.Team_Member__c;
                gcrShare.RowCause      =  'Manual';
                gcrShare.ParentId      = gCR.Id ;
                gcrShare.AccessLevel   = 'Read'; // Read Access to the Users
                gcrSharelst.add(gcrShare);
              }
            
         }
        }
        
        //Insert for creating the sharing record
         if(gcrSharelst.size() > 0){
         Database.saveresult[] sr = Database.insert(gcrSharelst, False);
         }
        
    }
    
     //Finish method of the batch class
    global void finish(Database.BatchableContext BC){
        
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = : BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Environment_Variable__c env = Environment_Variable__c.getInstance();
        String onErrorEmail = env.BatchErrorEmails__c;
        String[] toAddresses = new String[] {
            onErrorEmail
        };
        mail.setToAddresses(toAddresses);
        mail.setSubject('gCRApexSharingBatch  ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
            ' batches with ' + a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { 
            mail
        });
        
    }

}