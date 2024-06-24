/*****************************************************************************************************\  
    @ Func Area         : PCC__c, Share_Wallet__c, Client (Account)
    @ Last Modified By  : Rudolf Niehaus
    @ Last Modified On  : 20/11/2012
    @ Modification Description : Case#1263: Client Overview Phase 2:
                                    Rename Class from PCCShareWalletTriggerFunctions to ShareWalletTriggerFunctions. rename all PCC_Share_Wallet__c
                                    objects name to Share_Wallet__c.
                                    The reason for the above changes is to rename all classes, triggers and objects to reflect the new client overview 
                                    enhancements. i.e. to move the share of wallet functionality from the PCC object and link it to the Client (Account) object
                                    The word PCC is not relevant in any of the share of wallet naming convention, hence we removed it :-) 
    @ Last Modified By  : Charles Mutsu
    @ Last Modified On  : 12/12/2013
    @ Modification Description : En#215: PCC Re-design:
                                 Add a validation for SOW creation and updation using a unique combination key of Client+Division+FinancialYear 
                                 Update API to version 29
--------------------------------------------------------------------------------------------------------------------------------------
   
******************************************************************************************************/
public with sharing class ShareWalletTriggerFunctions {
    
    public static void handleShareWalletBeforeInsert(List<Share_Wallet__c> newRecs){
           
           Set<Id> shareWalletIds = new Set<Id>();
           Set<String> shareWalletCheck = new Set<String>();     
           List<Share_Wallet__c >  existingShareWallet = new List<Share_Wallet__c>();
            for(Share_Wallet__c newRec : newRecs){
              shareWalletIds.add(newRec.Client__c);
              //Check for the duplicacy of record per validation rule among the New Records.
              if(shareWalletCheck.contains(newRec.Division__c+'#'+newRec.Client__c+'#'+newRec.Financial_Year__c)) {
                    newRec.adderror(newRec.Division__c + ' already exists for this Client for the year '+newRec.Financial_Year__c+'. Please select any other Division to save the record.');
               
              }
              else{
                   shareWalletCheck.add(newRec.Division__c+'#'+newRec.Client__c+'#'+newRec.Financial_Year__c);
              }                 
             } //for loop       
            
            existingShareWallet = [Select Id, Client__c, Division__c, Financial_Year__c from Share_Wallet__c Where Client__c in :shareWalletIds];
            
            //Check if the Division already exists.
            for(Share_Wallet__c newRec : newRecs){
                for(Share_Wallet__c existingRec: existingShareWallet){
                    if(newRec.Division__c == existingRec.Division__c && newRec.Client__c == existingRec.Client__c && newRec.Financial_Year__c == existingRec.Financial_Year__c) {
                        newRec.adderror(newRec.Division__c + ' already exists for this Client for the year '+newRec.Financial_Year__c+'. Please select any other Division to save the record.');
                        Break;
                    }
                
                }
                
            }     
    
        }
        
        
        public static void handleShareWalletBeforeUpdate(Map<Id, Share_Wallet__c> oldMap, Map<Id, Share_Wallet__c> newMap){
           
            Set<Id> shareWalletIds = new Set<Id>();
            Set<String> shareWalletCheck = new Set<String>();     
            List<Share_Wallet__c >  existingShareWallet = new List<Share_Wallet__c>();
           
            for(Share_Wallet__c newRec : newMap.values()){
                shareWalletIds.add(newRec.Client__c);
              //Check for the duplicacy of record per validation rule among the New Records.  
              if(shareWalletCheck.contains(newRec.Division__c+'#'+newRec.Client__c+'#'+newRec.Financial_Year__c)){
                    newRec.adderror(newRec.Division__c + ' already exists for this Client for the year '+newRec.Financial_Year__c+'. Please select any other Division to save the record.');
               }
              else{
                   shareWalletCheck.add(newRec.Division__c+'#'+newRec.Client__c+'#'+newRec.Financial_Year__c);
              }                 
            }        
            
            existingShareWallet = [Select Id, Client__c, Division__c, Financial_Year__c from Share_Wallet__c Where Client__c in :shareWalletIds];

            //Check if the Division already exists.
            for(Share_Wallet__c newRec : newMap.values()){
                for(Share_Wallet__c existingRec : existingShareWallet){
                    if(newRec.Division__c == existingRec.Division__c && newRec.Client__c == existingRec.Client__c && existingRec.Id != newRec.Id && newRec.Financial_Year__c == existingRec.Financial_Year__c) {
                        newRec.adderror(newRec.Division__c + ' already exists for this Client for the year '+newRec.Financial_Year__c+'. Please select any other Division to save the record.');
                        //If the matching condition is found then Break from the loop for the existing record 
                        //and continue for the next.
                        Break;
                    }
                
                }
                
            }
        }
        /* 
           FUNCTION TO Update Currency On Share of Wallet Products based on Share OF Wallet. 
           CALLED  BY TRIGGER ON Share of Wallet Products On After Update
           Developer : Ankit Khandelwal OCT - 16 - 2013
        */
        public static void UpdateCurrencyOnProducts(Map<Id, Share_Wallet__c> oldMap, Map<Id, Share_Wallet__c> newMap){
           List<Share_Wallet__c> SW_lst = [select Id,CurrencyIsoCode,(select Id,CurrencyIsocode from Share_of_Wallet_Products__r) from Share_Wallet__c where Id IN : newmap.keyset()];
           list<Share_of_Wallet_Product__c> swp_lst_update = new list<Share_of_Wallet_Product__c> ();
           for(Share_Wallet__c Sw : SW_lst){
                 if (newmap.get(Sw.Id).currencyIsoCode <> oldMap.get(Sw.Id).currencyIsoCode){
                        for (Share_of_Wallet_Product__c SWP : Sw.Share_of_Wallet_Products__r) {
                              SWP.CurrencyIsoCode = Sw.CurrencyIsoCode;
                               swp_lst_update.add(SWP);  
                          }
                      }     
                   }
                    
                    if(swp_lst_update.size() > 0){
                       Database.SaveResult[] sr  = Database.Update(swp_lst_update,false);
                    }
                 
                 }   
        
        
}