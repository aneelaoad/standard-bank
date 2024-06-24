/*************************************************************************\
   Created this new class and moved below userstories functionality from Opportunitytriggerutility class
   
    @ Last Modified By  : Petr Roubal
    @ Last Modified on  :  18 Apr 2016
    @ Last Modified Reason  : US-1273 RTB - OM - Game Changers Revenue Fields and Roll up Calculations
    
    @ Last Modified By  : Manoj Gupta
    @ Last Modified on  :  27 June 2016
    @ Last Modified Reason  : US-1391 RTB - OM - Game Changers additional roll up fields
    
  ****************************************************************************/
  
  public without sharing class OpportunityTriggerHelper {  
  
      /*************************************************************************************************
     *  US-1273 RTB - OM - Game Changers Revenue Fields and Roll up Calculations
     *************************************************************************************************/
     public static void calculateRevenueGameChanger(List<Opportunity> newOppList, List<Opportunity> oldOppList){
        system.debug('##### calculateRevenueGameChanger');
        Map<Id, Opportunity> mapListNew = new Map<Id, Opportunity>();
        Map<Id, Opportunity> mapListOld = new Map<Id, Opportunity>();
        
       
        if(newOppList != null) {
            for (Integer i = 0; i < newOppList.size(); i++) {
                // newOppList[i].StageName != oldOppList[i].StageName &&
                if (newOppList[i].StageName == '3 - Closed Won' &&
                        newOppList[i].Game_Changer__c != null) {
                    mapListNew.put(newOppList[i].Game_Changer__c, newOppList[i]);
                    if (newOppList[i].Game_Changer__c != oldOppList[i].Game_Changer__c && oldOppList[i].Game_Changer__c != null) {
                        mapListOld.put(oldOppList[i].Game_Changer__c, oldOppList[i]);
                    }
                } else if (newOppList[i].Game_Changer__c != oldOppList[i].Game_Changer__c && newOppList[i].StageName == '3 - Closed Won') {
                    
                    if (newOppList[i].Game_Changer__c != null) {
                        mapListNew.put(newOppList[i].Game_Changer__c, newOppList[i]);
                    }
                    
                    if (oldOppList[i].Game_Changer__c != null) {
                        mapListOld.put(oldOppList[i].Game_Changer__c, oldOppList[i]);
                    } //newOppList[i].StageName != oldOppList[i].StageName &&
                } else if ( oldOppList[i].StageName == '3 - Closed Won' && oldOppList[i].Game_Changer__c != null) {
                    mapListOld.put(oldOppList[i].Game_Changer__c, oldOppList[i]);
                }
            }
        }
         
        if ((newOppList == null || newOppList.size() == 0) && (oldOppList != null && oldOppList.size() > 0)) {
            for (Integer i = 0; i < oldOppList.size(); i++) {
            
                if (oldOppList[i].Game_Changer__c != null && oldOppList[i].StageName == '3 - Closed Won')
                    mapListOld.put(oldOppList[i].Game_Changer__c, oldOppList[i]);
            }
        }


        
        //recalculate CY Revenue on the Game Changer
        if(mapListNew.size() > 0 || mapListOld.size() > 0) {
            Set<Id> gameChangerId = new Set<Id>();
            if(mapListNew.size() > 0)
                gameChangerId.addAll(mapListNew.keySet());
            if(mapListOld.size() > 0)
                gameChangerId.addAll(mapListOld.keySet());
            List<AggregateResult> lstOppRevs = [Select Game_Changer__c, sum(Current_Year_Revenue_Currency__c) from Opportunity where stagename = '3 - Closed Won' and Game_Changer__c in : gameChangerId group by Game_Changer__c];
            Map<id, AggregateResult> mapOppRevs = new Map<Id, AggregateResult>();
            for(AggregateResult ar : lstOppRevs){
                
                mapOppRevs.put((Id) ar.get('Game_Changer__c'), ar);
            }
            system.debug('##### mapOppRevs => ' + mapOppRevs);
            system.debug('##### User Currency => ' + UserInfo.getDefaultCurrency());

            List<Game_Changer__c> lstGCs = [select Id, Opportunity_Current_Year_Won_Revenue__c, CurrencyIsoCode,Execution__c from Game_Changer__c where Id in :gameChangerId];


            CurrencyConverter converter = new CurrencyConverter();
            for(Game_Changer__c gc : lstGCs){
                
                if(mapOppRevs.containsKey(gc.Id)){
                    gc.Opportunity_Current_Year_Won_Revenue__c = converter.convertCorporateCurrency((Decimal) mapOppRevs.get(gc.Id).get('expr0'), gc.CurrencyIsoCode);
                    gc.Execution__c = converter.convertCorporateCurrency((Decimal) mapOppRevs.get(gc.Id).get('expr0'), gc.CurrencyIsoCode);
                }else{
                    system.debug('##### Opportunity_Current_Year_Won_Revenue__c => 0');
                    gc.Opportunity_Current_Year_Won_Revenue__c = 0;
                    gc.Execution__c = 0;  //US:1391 rolling up Execution field for calculations
                }
            }
           
            update lstGCs;
        }
    }
    
    /*************************************************************************************************
     *  US-1391 RTB - OM - Game Changers additional roll up fields
     *************************************************************************************************/ 
    
        public static void calculateClientsOpptyIdentifiedRevenue(List<Opportunity> newOppList, List<Opportunity> oldOppList){
        system.debug('##### calculateClientsOpptyIdentifiedRevenue');
        Map<Id, Opportunity> mapListNew = new Map<Id, Opportunity>();
        Map<Id, Opportunity> mapListOld = new Map<Id, Opportunity>();
        
       
        if(newOppList != null) {
            for (Integer i = 0; i < newOppList.size(); i++) {
                // newOppList[i].StageName != oldOppList[i].StageName &&
                if ((newOppList[i].StageName == '2 - Develop' || newOppList[i].StageName == '1 - Lead') &&
                        newOppList[i].Game_Changer__c != null) {
                    mapListNew.put(newOppList[i].Game_Changer__c, newOppList[i]);
                    if (newOppList[i].Game_Changer__c != oldOppList[i].Game_Changer__c && oldOppList[i].Game_Changer__c != null) {
                        mapListOld.put(oldOppList[i].Game_Changer__c, oldOppList[i]);
                    }
                } else if (newOppList[i].Game_Changer__c != oldOppList[i].Game_Changer__c && (newOppList[i].StageName == '2 - Develop' || newOppList[i].StageName == '1 - Lead')) {
                    
                    if (newOppList[i].Game_Changer__c != null) {
                        mapListNew.put(newOppList[i].Game_Changer__c, newOppList[i]);
                    }
                    
                    if (oldOppList[i].Game_Changer__c != null) {
                        mapListOld.put(oldOppList[i].Game_Changer__c, oldOppList[i]);
                    } //newOppList[i].StageName != oldOppList[i].StageName &&
                } else if (( oldOppList[i].StageName == '2 - Develop' || oldOppList[i].StageName == '1 - Lead') && oldOppList[i].Game_Changer__c != null) {
                    mapListOld.put(oldOppList[i].Game_Changer__c, oldOppList[i]);
                }
            }
        }
         
        if ((newOppList == null || newOppList.size() == 0) && (oldOppList != null && oldOppList.size() > 0)) {
            for (Integer i = 0; i < oldOppList.size(); i++) {
            
                if (oldOppList[i].Game_Changer__c != null && (oldOppList[i].StageName == '2 - Develop' || oldOppList[i].StageName == '1 - Lead'))
                    mapListOld.put(oldOppList[i].Game_Changer__c, oldOppList[i]);
            }
        }


        
        //recalculate CY Revenue on the Game Changer
        if(mapListNew.size() > 0 || mapListOld.size() > 0) {
            Set<Id> gameChangerId = new Set<Id>();
            if(mapListNew.size() > 0)
                gameChangerId.addAll(mapListNew.keySet());
            if(mapListOld.size() > 0)
                gameChangerId.addAll(mapListOld.keySet());
            List<AggregateResult> lstOppRevs = [Select Game_Changer__c, sum(Current_Year_Revenue_Currency__c) from Opportunity where (stagename = '2 - Develop' OR stagename = '1 - Lead') and Game_Changer__c in : gameChangerId group by Game_Changer__c];
            Map<id, AggregateResult> mapOppRevs = new Map<Id, AggregateResult>();
            for(AggregateResult ar : lstOppRevs){
                
                mapOppRevs.put((Id) ar.get('Game_Changer__c'), ar);
            }
            system.debug('##### mapOppRevs => ' + mapOppRevs);
            system.debug('##### User Currency => ' + UserInfo.getDefaultCurrency());

            List<Game_Changer__c> lstGCs = [select Id, Clients_and_Opportunities_Identified__c, CurrencyIsoCode from Game_Changer__c where Id in :gameChangerId];


            CurrencyConverter converter = new CurrencyConverter();
            for(Game_Changer__c gc : lstGCs){
                
                if(mapOppRevs.containsKey(gc.Id)){
                    gc.Clients_and_Opportunities_Identified__c = converter.convertCorporateCurrency((Decimal) mapOppRevs.get(gc.Id).get('expr0'), gc.CurrencyIsoCode);
                    
                }else{
                    gc.Clients_and_Opportunities_Identified__c = 0;
                    
                }
            }
           
            update lstGCs;
        }
    }

  }