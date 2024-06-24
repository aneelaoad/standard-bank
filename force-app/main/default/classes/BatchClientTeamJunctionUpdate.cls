/*************************************************************************
    @ Author        : Anurag Jain
    @ Date      : 14 Mar, 2011
    @ Test File     : TC_BatchClientTeamJunctionUpdate
    @ Description   : Batch Class to execute the logic for updating  / Inserting the Junction Object (ClientTeamOpportunity&Products) 
    @               in an event of Insert on Custom Client Team Object
    @
@ Audit Trial   : Repeating block for each change to the code
    @ Last Modified By  :   Anurag Jain
    @ Last Modified On  :   14 Mar, 2011
    @ Last Modified Reason  :   
****************************************************************************/

global class BatchClientTeamJunctionUpdate implements database.batchable<sObject> {
    
    global List<Id> accountIdsOnCustomClientTeam=new List<Id>();  
    global List<Id> oppIds=new List<Id>();
    global List<Id> customClientTeamIds = new List<Id>();
    global List<SB_Product__c> prod_to_add_list=new List<SB_Product__c>(); 
    global List<Opportunity> oppList=new List<Opportunity>();
    global List<custom_client_team__c> lstCCT = new List<custom_client_team__c>();
    global Opportunity opportunityRecord;
    global ClientTeamOpportunity_Products__c objCTOP;
    global string query;
    global Boolean varIsDel;
    
    global Map<Id,List<SB_Product__c>> prodOppMap=new Map<Id,List<SB_Product__c>>();
    global List<SB_Product__c> prod_list=new List<SB_Product__c>();
    global List<Custom_Client_Team__c> cct_listNew=new List<Custom_Client_Team__c>();       
    global List<ClientTeamOpportunity_Products__c> ctopListToBeDeleted=new List<ClientTeamOpportunity_Products__c>();
    global List<ClientTeamOpportunity_Products__c> ctopListToBeInserted=new List<ClientTeamOpportunity_Products__c>();
    
    //Constructor
    global BatchClientTeamJunctionUpdate (List<Custom_Client_Team__c> argCCT, Boolean isDel) {
        varIsDel = isDel;
        lstCCT = argCCT;    
        for(Custom_Client_Team__c cct:lstCCT){
                customClientTeamIds.add(cct.Id);                
                accountIdsOnCustomClientTeam.add(cct.Account__c);            
            }   
        if(accountIdsOnCustomClientTeam.size() > 0 && !varIsDel) {
            query = 'select Id,AccountId from Opportunity where AccountId in:accountIdsOnCustomClientTeam';
          } 
        else if (customClientTeamIds.size() >0 && varIsDel) {
            query = 'Select Id,Opportunity__c,Custom_Client_Team__c from ClientTeamOpportunity_Products__c where Custom_Client_Team__c in :customClientTeamIds OR ClientTeamId__c in :customClientTeamIds';
          }     
        }

    //Constructor - overloaded. This signature is used for Object creation when we want to distinctively call the ProcessExecute method
    global BatchClientTeamJunctionUpdate () {   
        }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);   
        }
        
    
    global void execute(Database.BatchableContext BC, List<sObject> records){           
        processExecute(records,True,varIsDel);       
    }   
        
/********************************************************************************************************/      
    
    global void processExecute(List<sObject> records, Boolean argBatchExecute, Boolean argIsDel) {
    
      if (argIsDel) {
            for(SObject record : records){ 
                ctopListToBeDeleted.add((ClientTeamOpportunity_Products__c) record);            
                }       //end of for loop
            Delete ctopListToBeDeleted;         
         } //end of if
        
      else {    
        //Create a list of Opportunities associated via Account for the effected Client Team Member
        for(SObject record : records){ 
            opportunityRecord = (Opportunity) record;
            OppList.add(opportunityRecord);
            oppIds.add(opportunityRecord.Id);
            }       //end of for loop
            

       Map<Id,List<Opportunity>> cctOppMap=new Map<Id,List<Opportunity>>();
       List<Opportunity> opp_listNew=new List<Opportunity>();       
    
     If (lstCCT.size()>0 && oppList.size()>0) {
        for(Custom_Client_Team__c cct_obj:lstCCT){
           opp_listNew=new List<Opportunity>();        
           for(Opportunity opp:oppList){
               if(opp.AccountId == cct_obj.Account__c){
                   opp_listNew.add(opp);
                 }    
              }
           If (opp_listNew.size()>0) {
               cctOppMap.put(cct_obj.Id,opp_listNew);
            }
        }   
    }
        
        /***  Select all the Products associated with the Opportunities as found above and 
              prepare a Map of Opportunity Id as a key and a list of associated Products as value.    ***/        
        if(oppIds.size()>0){
          prod_to_add_list=[select Id,Opportunity__c from SB_Product__c where Opportunity__c in:oppIds];          
           for(Id opId:oppIds){
               prod_list=new List<SB_Product__c>(); 
               for(SB_Product__c sp:prod_to_add_list){                   
                   if(opId == sp.Opportunity__c)                                           
                       prod_list.add(sp);                       
                    }   //end of for
               prodOppMap.put(opId,prod_list); 
               }            //end of for

            for(Custom_Client_Team__c cct_to_add:lstCCT){       //for loop 1
               if(cctOppMap.containsKey(cct_to_add.Id))                
                   for(Opportunity opp_to_add:cctOppMap.get(cct_to_add.Id)){                    //for loop 2
                       for(SB_Product__c prod_to_add: prodOppMap.get(opp_to_add.Id)){       //for loop 3           
                           ClientTeamOpportunity_Products__c ctop=new ClientTeamOpportunity_Products__c(Product__c=prod_to_add.Id,Opportunity__c=opp_to_add.Id,Custom_Client_Team__c=cct_to_add.Id,ClientTeamId__c=cct_to_add.Id);                            
                           ctopListToBeInserted.add(ctop);
                            }       //end of for loop 3
                         }          // end of for loop 2
                }               // end of for loop 1
            }                   //end of if(oppIds.size()>0)

        Insert ctopListToBeInserted;        
      }
    }
    
    
    global void finish(Database.BatchableContext BC){

        AsyncApexJob varApexJob = [Select Id, Status, NumberOfErrors, JobItemsProcessed,TotalJobItems, 
                                   CreatedBy.Email from AsyncApexJob where Id =:BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        Environment_Variable__c env = Environment_Variable__c.getInstance();
        String onErrorEmail = env.BatchErrorEmails__c;
        String[] toAddresses = new String[] {onErrorEmail};

        mail.setToAddresses(toAddresses);
        mail.setSubject('Client Team >> BatchClientTeamJunctionUpdate ' + varApexJob.Status);
        mail.setPlainTextBody('The batch Apex job processed ' + varApexJob.TotalJobItems + ' batches with '+ varApexJob.NumberOfErrors + ' failures.');
        if (varApexJob.TotalJobItems > 0) {
        //    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
         }
        }

}