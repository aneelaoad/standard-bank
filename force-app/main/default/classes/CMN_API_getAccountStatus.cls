/**
 * @description APEX REST inbound endpoint for Account enquiry API and Delete
 * 
 * <p></p>
 * 
 * @author muvhuso.nekhubvi@standardbank.co.za
 *
 * @date October 2022
 */

 @RestResource(urlMapping='/Accounts/v1/*')

 global with sharing class CMN_API_getAccountStatus {
     
     private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CMN_API_getAccountStatus');
     
     private static final String ENQUIRE_STATUS = 'enquire';
     private static final String DELETE_STATUS = 'delete';
     private static final String SUCCESS_STATUS = 'Success';
     private static final String NOTFOUND_STATUS = 'Not Found';
     private static final String NOTELIGIBLE_STATUS = 'Not eligible for deletion';
 
     global class AccountInfo{
         public string externalIdentifier;
         public Date retentionDate;
         public boolean eligibleForDeletion;
         public string results;
     } 
  
    /**
    * @description Will process enquiry results
    * 
    * @param AccountBPStatusRequest
    * @return List<AccountInfo> 
    */
  @HttpPost
  global static List<AccountInfo> getAccountStatus(EnquireRequest AccountBPStatusRequest){
         List<AccountInfo> accInfObjList = new List<AccountInfo>();
         List<Account> accounts = new List<Account>();
         try{
          
         if(!AccountBPStatusRequest.customerInfo.isEmpty()){
             AccountInfo request = new AccountInfo();
             List<Account> parentAccounts = new SEL_Accounts().selectByExternalIdentifier(new Set<String>{AccountBPStatusRequest.customerInfo[0].externalIdentifier});
             set<Id> contactIds = new set<Id>();
 
             if(parentAccounts != null && !parentAccounts.isEmpty()){
                 if(AccountBPStatusRequest.operation == ENQUIRE_STATUS){
                     request.externalIdentifier = parentAccounts[0].ExternalIdentifier__c;
                      request.retentionDate = parentAccounts[0].DR_Retain_Until__c;
                     request.results = SUCCESS_STATUS;
                      if(parentAccounts[0].DR_Retain_Until__c != null && parentAccounts[0].DR_Retain_Until__c <=  system.today()){
                         request.eligibleForDeletion = true;
                      }else{
                         request.eligibleForDeletion = false;
                       }
                 }else if(AccountBPStatusRequest.operation == DELETE_STATUS){ 
                     if(parentAccounts[0].contacts != null && !parentAccounts[0].contacts.isEmpty()) {
                        for(Contact contact : parentAccounts[0].contacts){
                            contactIds.add(contact.Id);
                        }
                     }    
                     
                     List<AccountContactRelation> acrContacts = new SEL_AccountContactRelation().selectByIndirectContactId(contactIds); 
                     if(parentAccounts[0].DR_Retain_Until__c <= system.today()){
                          accounts.add(parentAccounts[0]);
                         request.results = SUCCESS_STATUS;
                     }else{
                         request.results = NOTELIGIBLE_STATUS;
                     }
 
                     if(!acrContacts.isEmpty()){
                         List<Contact> cn = new SEL_Contacts().selectByIdForRegistration(new set<Id>{String.valueOf(acrContacts[0].ContactId)});
                         cn[0].AccountId = acrContacts[0].AccountId;
                         update cn;
                     }
                 }   
             }else{
                 request.results = NOTFOUND_STATUS;
                 request.externalIdentifier = AccountBPStatusRequest.customerInfo[0].externalIdentifier;
             }
              accInfObjList.add(request);
 
          } 
      if(!accounts.isEmpty()){
         doDelete(accounts); 
      } 
      LOGGER.debug('Service Response :' + accInfObjList);       
      return accInfObjList;
             
     }catch(Exception error){
        LOGGER.fatal('CMN_API_getAccountStatus.getAccountStatus' , error);
        throw new AuraHandledException(error.getMessage());     
     }
  } 
    /**
    * @description EnquireRequest class
    */
     
   global class EnquireRequest{
       global string operation;
       global List<CustomerInfo> customerInfo;      
   }
    /**
    * @description account information class
    */
   global class CustomerInfo{
          global string externalIdentifier;  
   }
   
   
   /**
    * @description delete mothod to delete account
    * @param accounts
    */
   public static void doDelete(List<Account> accounts) {
         delete accounts;
     }
     
 }