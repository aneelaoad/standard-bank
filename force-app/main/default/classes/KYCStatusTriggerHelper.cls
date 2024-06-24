/* @Class Name   : KYCStatusTriggerHelper
 * @Description  : Helper class for KYC Status Trigger
 * @Created By   : Vishnu Teja V
 * @Created On   : 21 April 2015
 * @Modification Log:  
 * --------------------------------------------------------------------------------------------------
 * @Developer                Date                   Description
 * --------------------------------------------------------------------------------------------------
 * @Vishnu Teja V         21 April 2015     Created- EN 694 : To assign a task to the Escalated to Business User
 
  /* 
   *    @Last Modified By  :   Abhishek V        
   *    @Last Modified On  :   Feb 2016
   *    @Last Modified Reason  : EN-1037, Removed the code which creates task when Escalated to business field is filled or changed during insert/update
     
  
 * ---------------------------------------------------------------------------------------------------
*/

public with sharing class KYCStatusTriggerHelper {
  
    /**
         * @author :- Petr Roubal
         * @date  :-  August 2015 
         * @description :- EN-738, Onboarding: Integration back from CIF into SF 
         * @param :- list<KYC_Status__c> : which contains list of KYC_Status__c
    */
    
    public static void validateKYCEntityCode(list<KYC_Status__c> lstOfKYCStatus){
      
      set<string> allowedKYC = new set<string>{'SBMU', 'SALL', 'SBHK', 'LIB'};
      list<Account> lstClts = new List<Account>();
      list<Id> clientIds = new list<id>();
    
    // get clients from list of KYC statuses
    for(KYC_Status__c newKYC : lstOfKYCStatus){
      clientIds.add(newKYC.Client__c);
    }
    system.debug('##### clientIds = ' + clientIds);
    list<Account> clients = [select id, Name, Without_SF_Id__c from Account where Id IN :clientIds and Without_SF_Id__c = true];
    map<Id, Account> clientsMap = new map<Id, Account>();     
    if(clients.size() > 0){
      clientsMap = new map<Id, Account>(clients); 
    }

    // check if client is 'Without SF ID'
    for(KYC_Status__c KYCstatus : lstOfKYCStatus){
      system.debug('##### clientsMap: ' + clientsMap);
      system.debug('##### sKYCstatus.Client__c' + KYCstatus.Client__c);
      if(clientsMap.containsKey(KYCstatus.Client__c)){ 
        if(!allowedKYC.contains(KYCstatus.Entity_Code__c)){
          // select KYC to delete on true
          system.debug('##### set To_delete__c on true');
          KYCstatus.To_delete__c = true;
        }else{
          //update status 'Without SF ID on false;
          system.debug('##### set Without_SF_Id__c on false');
          Account acc =  clientsMap.get(KYCstatus.Client__c);
          acc.Without_SF_Id__c = false;
          lstClts.add(acc);
        }
      }
    }
    if(lstClts.size() > 0){
      update lstClts;
    }
    }
    
    public static void caseEmailsAndDelete(map<Id,Id> mapClientIdToKYCStatus){
      Account[] lstAcc = [select Id, Name, CIF__c, OwnerId, Client_Coordinator_from_CDG__c from Account where Id in :mapClientIdToKYCStatus.keySet()];
        map<Account, Case> mapNewCase = new map<Account, Case>();
        for(Account acc : lstAcc){
          mapNewCase.put(acc, createCase(acc));
          sendEmailToCDG(acc);
        }
        // create cases
        system.debug('##### cases: ' + mapNewCase.values());
        insert mapNewCase.values();
        // send notification to cc
        for(Account acc : mapNewCase.keySet()){
          sendEmailToCC(acc, mapNewCase.get(acc));
        }
        // delete clients
        deleteCliens(mapClientIdToKYCStatus.keySet());
    }
    

  private static void deleteCliens(Set<Id> lstAccIds){
        DMN_Account.removeMarkedClients(lstAccIds);     
  }
  
  private static Case createCase(Account account){
        
        // Case Details:
    // Subject - 'New CIF Client Rejection'
    // Description -
    //   Client name
    //   CIF Number
    //   KYC Location Checked

    
        CaseConfiguration__c cc = CaseConfiguration__c.getValues('CaseKYCConfiguration');
        
        Case c = new Case();
        c.Subject = 'New CIF Client Rejection';
        c.Description =  'Client name :' + account.Name + '\n CIF Number :' + account.CIF__c + '\n KYC Location Checked';
        c.RecordTypeId = (Id) cc.RecordTypeId__c;
        c.Main_Category__c = cc.MainCategory__c;
        c.Sub_Category__c = cc.SubCategory__c;
        c.OwnerId = (Id) cc.OwnerId__c;
        c.Origin = cc.CaseOrigin__c;
        c.Priority = cc.CasePriority__c;
        c.ContactId = (Id) cc.ContactId__c;
        
        return c;           
    }
    
    private static void sendEmailToCC(Account acc, Case c){
      
      Case cFromDB=[select id, CaseNumber from Case where id=:c.id]; 
            
      EmailTemplate et=[Select id,subject,htmlvalue,body from EmailTemplate where developername='CIF_Client_Rejection_Notify_CC'];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            
        String subject = et.Subject; 
        subject=subject.replace('{!Account.Name}', acc.Name != null ? acc.Name : '');
        subject=subject.replace('{!Case.Number}', cFromDB.CaseNumber != null ? cFromDB.CaseNumber : '');

        String htmlBody = et.HtmlValue;
        htmlBody = htmlBody.replace('{!Account.Name}', acc.Name != null ? acc.Name : '');
        htmlBody = htmlBody.replace('{!Case.Number}', cFromDB.CaseNumber != null ? cFromDB.CaseNumber : '');
        htmlBody = htmlBody.replace('{!$Setup.Environment_Variable__c.serverURL__c}',Label.Server_Url);
        htmlBody = htmlBody.replace('{!Case.Id}', cFromDB.Id != null ? cFromDB.Id : '');
                        
        Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
        singleMail.setSaveAsActivity(false);
        singleMail.setSubject(subject);
        singleMail.setHtmlBody(htmlBody);
            
        singleMail.setTargetObjectId(acc.OwnerId);
        emails.add(singleMail);
            
        Messaging.sendEmail(emails);
        system.debug('###### Email CIF_Client_Rejection_Notify_CC was sent to ' + acc.OwnerId);
    }
    
    private static void sendEmailToCDG(Account acc){
        
        EmailTemplate et=[Select id,subject,htmlvalue,body from EmailTemplate where developername='New_KYC_Rejection'];
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        String subject = et.Subject; 
        String htmlBody = et.HtmlValue;
        htmlBody = htmlBody.replace('{!Account.Name}', acc.Name != null ? acc.Name : '');
        htmlBody = htmlBody.replace('{!Account.CIF__c}',acc.CIF__c != null ? acc.CIF__c : '');             
        
        Messaging.SingleEmailMessage singleMail = new Messaging.SingleEmailMessage();
        singleMail.setSaveAsActivity(false);
        singleMail.setSubject(subject);
        singleMail.setHtmlBody(htmlBody);
        
        String emailCDG = EmailAddress__c.getValues('CDG Data Mailbox').Email__c;
        String emailCRM = EmailAddress__c.getValues('CRM Data Mailbox').Email__c;
        List<string>usersTo = new List<string>(); 
        usersTo.add(emailCDG);
        usersTo.add(emailCRM);
        
        singleMail.setToAddresses(usersTo);
        emails.add(singleMail);
        
        Messaging.sendEmail(emails);
        system.debug('###### Email New_KYC_Rejection was sent to ' + usersTo);
    } 
        

}