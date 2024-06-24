/*************************************************************************
    @ Author        : Nitish Kumar
    @ Date          : April 2014
    @ Test File     : ccFailedMappingExceptionReportBatchTest
    @ Description   : Batch Class which sends the exception report of all the clients for which mapping did not happen.
    @ Enhancement   : EN -- 337
    
    @ Audit Trial   : Repeating block for each change to the code
    -----------------------------------------------------------------------------

    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Aug 11, 2015
    @ Modification Description : Force.com reviewer - Blocker and Critical issues - 20150608.xlsx
    
    @ Last Modified By  : Jana Cechova
    @ Last Modified On  : May 11, 2016
    @ Modification Description : Update classes to increase overall Code Coverage - adjusted isTest.running()
***********************************************************************************/

global class  ccFailedMappingExceptionReportBatch  implements Database.Batchable<sObject>{

     //Global Variable
     global String query;
     public Boolean runTestMethod = false;
     public string salesforceAdminId;
     
    
    global ccFailedMappingExceptionReportBatch(){
        User u = [SELECT Id FROM User where name = 'Salesforce Administration' LIMIT 1];
        salesforceAdminId = u.Id;
        
        this.query = 'SELECT Name, CreatedById, CreatedDate,Id,Owner.Name, Tech_CC_CDG_Failed_Mapping__c,Client_Coordinator_from_CDG__c,OwnerId, RecordTypeId, Description FROM Account where CreatedDate = today and CreatedById = :salesforceAdminId';
    
        System.debug('$$$$$$$$$$$$' + query);
    }
    
     //Start method of the batch class
    global Database.QueryLocator start(Database.BatchableContext BC){
        if(runTestMethod){
            query = query + ' ORDER BY createddate DESC LIMIT 200';
        }
        return Database.getQueryLocator(query);
    }
    
     //Execute method of the batch class
    global void execute(Database.BatchableContext BC, List<Account> records){

        String table ;
        Environment_Variable__c env = Environment_Variable__c.getInstance();

        Date today = Date.today();
        
        table = 'Hi Team, <br/><br/> Please note there were some failed Client Coordintor matches on execution of the feed.<br/>See below list of exceptions and correct in SFDC.<br/><br/> ';
        
        table= table + '<table border="1" style="border-collapse:collapse;"><tr><th bgcolor="#B1C3E1">Client Name</th><th bgcolor="#B1C3E1">Client Coordinator in Salesforce</th><th bgcolor="#B1C3E1">Client Coordinator From CDG</th><th bgcolor="#B1C3E1">Reason for Failure</th><th bgcolor="#B1C3E1">Link to record in Salesforce</th>';
        
        for (Account acc : records){
            if(acc.Tech_CC_CDG_Failed_Mapping__c != null && acc.Tech_CC_CDG_Failed_Mapping__c != ''){
             table=table +'<tr>';
             table=table + '<td>' + acc.Name + '</td>';
             table=table + '<td>' + acc.Owner.Name + '</td>';
             if(acc.Client_Coordinator_from_CDG__c != null){
             table=table + '<td>'  + acc.Client_Coordinator_from_CDG__c + '</td>';
             }
             else{
                table=table + '<td>'  + 'Client Coordinator value not provided' + '</td>';
             }
             table=table + '<td>' + acc.Tech_CC_CDG_Failed_Mapping__c + '</td>';
             table=table + '<td><ul style="list-style:none"><li style="list-style:none">'+ env.serverURL__c + '/' + acc.Id + '</li></ul></td>';
             table=table+'</tr>';
            }
        }
        
        table = table + '</table>';
        
        System.debug('############' + table);
        
        table = table + '<br/><br/>Thanks and Regards,<br/>Standard Bank Salesforce Team';
        
        if(Test.isRunningtest() && records[0].Description == 'Test ClientccFailedMappExcept'){
                  env.London_3rd_Line_Support__c ='test.exampleMy@test.example.com';
         }
        
        String onErrorEmail = env.London_3rd_Line_Support__c;
        
        
        String[] toAddresses = new String[] {
            onErrorEmail
            
        };
        
        if(Test.isRunningtest() && records[0].Description == 'Test ClientccFailedMappExcept'){
                  toAddresses.add('test.exampleMy@test.example.com');
         }
        
        
        system.debug(logginglevel.error, 'toAddressesMy' + toAddresses);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(toAddresses);
        email.setHtmlBody(table);
        email.setSubject('CDG to SFDC Client Coordinator Feed: Exception Report ' + System.now().date().format());
        
        system.debug(logginglevel.error, 'email.setToAddresses' + email);
         Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                email
            });
        
    }
    
    //Finish method of the batch class
    global void finish(Database.BatchableContext BC){
        
        AsyncApexJob a = [Select Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email from AsyncApexJob where Id = : BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Environment_Variable__c env = Environment_Variable__c.getInstance();
        String onErrorEmail = env.BatchErrorEmails__c;
        
        if(Test.isRunningtest()){
                  onErrorEmail ='test.exampleMy@test.example.com';
         }
        
        String[] toAddresses = new String[] {
            onErrorEmail
        };
        system.debug(logginglevel.error, 'beforeSetupMail' + toAddresses);
        mail.setToAddresses(toAddresses);
        mail.setSubject('ccFailedMappingExceptionReportBatch  ' + a.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
            ' batches with ' + a.NumberOfErrors + ' failures.');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { 
            mail
        });
        
    } 

}