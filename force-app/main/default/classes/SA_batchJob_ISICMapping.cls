/****************************************************************************
    @ Last Modified By  : Petr Svestka
    @ Last Modified On  : Aug 11, 2015
    @ Modification Description : Force.com reviewer - Blocker and Critical issues - 20150608.xlsx
****************************************************************************/
global class SA_batchJob_ISICMapping implements Database.Batchable<SObject>{

    private String sIndustryCode = '';
    private String sRecordTypeId = GlobalCache.getRecordTypeId('Account', 'Inactive');
    public String query = 'Select Id,SA_Industry_Description__c,Industry_Code__c From Account Where Industry_Code__c <> :sIndustryCode and RecordTypeId <> :sRecordTypeId';

    global database.querylocator start(Database.BatchableContext bc){          
      return Database.getQueryLocator(query);                 
    }
        
    global void execute(Database.BatchableContext bc, sObject[] objects) {
//      Declare variables
        Map<String,String> lookupSICMap = new Map<String,String>();
        List<Account> accountsToUpdate = new List<Account>{};
        String ISICDescription = '';

        Set<String> codes = new Set<String>();
        for (Account a: (Account[]) objects) {
            codes.add(a.Industry_Code__c);
        }

//      Fill map with ISIC information
/*       for (SA_Industry_Mapping__c lookupInstance : [Select SA_5Digit_ISIC_Desc__c, SA_5Digit_ISIC_Code__c from SA_Industry_Mapping__c WHERE SA_5Digit_ISIC_Code__c IN :codes]) {
           lookupSICMap.put(lookupInstance.SA_5Digit_ISIC_Code__c, lookupInstance.SA_5Digit_ISIC_Desc__c);
           
        } */

//      Get correct description from ISIC map
        for (sObject s : objects) {
            Account a = (Account)s;
            ISICDescription = lookupSICMap.get(a.Industry_Code__c);
            
        /*   //  Update Account ISIC description with correct value  
           if (ISICDescription == null) {
              a.SA_Industry_Description__c = 'Missing ISIC mapping';  
             accountsToUpdate.add(a);                          
         } else 
   */
        /*     if ((a.SA_Industry_Description__c != ISICDescription) && (ISICDescription != null)) {
                a.SA_Industry_Description__c = ISICDescription;
                accountsToUpdate.add(a);                 
             }
           */     
             //    accountsToUpdate.add(a);                                       
         }
         
        update accountsToUpdate;
        
    }
    
    global void finish(Database.BatchableContext bc)  {

    }

    }