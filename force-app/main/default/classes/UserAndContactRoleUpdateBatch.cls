/* @Class Name   : UserAndContactRoleUpdateBatch
 * @Description  : Batch class for updating the Corresponding CST Role and 
                   Corresponding Contact Role on Event Report Attendee object to sync data
 * @Created By   : Vishnu Teja V
 * @Created On   : 23 March 2015
 * @Modification Log:  
 * --------------------------------------------------------------------------------------------------
 * @Developer                Date                   Description
 * --------------------------------------------------------------------------------------------------
 * @Vishnu Teja V         23 March 2015               Created
 * @Vishnu Teja V          9 April 2015      Modified the logic to include event reports which have end date as today
 * @Vishnu Teja V         13 April 2015      Modified the logic to suit defect 1157
 * ---------------------------------------------------------------------------------------------------
*/
global class UserAndContactRoleUpdateBatch implements Database.Batchable<sObject>{
    //global String query;
    
    String qryStr = 'select id,ERABatchUpdateRequired__c ' 
                    + ' from Account '
                    + ' where ERABatchUpdateRequired__c = true ';

    //Start method of the batch class
    global Database.QueryLocator start(Database.BatchableContext BC){ 
        return Database.getQueryLocator(qryStr);
    }
    
    
    //Execute method of the batch class
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        map<Id,map<Id,Custom_Client_Team__c>> mapAccIdmapUserConSyncIdCST = new map<Id,map<Id,Custom_Client_Team__c>>();
        List<Account> lstAccToUpdateERABatchUpdateReqToFalse = new list<Account>();
        set<Id> setCallRepIds = new set<Id>();
        map<Id,Call_Report_Attendees__c> mapIdERAToUpdate = new map<Id,Call_Report_Attendees__c>();
        
        /*new code for Defect 1157 */
        set<Id> changedAccIds = new set<Id>();
        for(sObject s : scope){
            Account client = (Account)s;
            changedAccIds.add(client.id);
        }
        
        list<Custom_Client_Team__c> lstCSTs = new list<Custom_Client_Team__c>();
        list<Call_Report__c> lstCallReps = new list<Call_Report__c>();
        
        lstCSTs = [select id,Team_Member__c,Team_Member__r.Contact_Sync_ID__c,Client_Role__c from Custom_Client_Team__c where Account__c IN: changedAccIds];
        lstCallReps = [select id,Relate_to_Client__c,End__c from Call_Report__c where Relate_to_Client__c IN: changedAccIds];
        
        /*new code end */
        
        for(sObject s : scope){
            Account client = (Account)s;
            
            for(Custom_Client_Team__c cst : lstCSTs){
                if(mapAccIdmapUserConSyncIdCST.containskey(client.id)){
                    mapAccIdmapUserConSyncIdCST.get(client.id).put((Id)cst.Team_Member__r.Contact_Sync_ID__c,cst);
                }else{
                    map<Id,Custom_Client_Team__c> mapUserConSyncIdCST = new map<Id,Custom_Client_Team__c>();
                    mapUserConSyncIdCST.put((Id)cst.Team_Member__r.Contact_Sync_ID__c,cst);
                    
                    mapAccIdmapUserConSyncIdCST.put(client.id,mapUserConSyncIdCST);
                }
            }
                        
            for(Call_Report__c er : lstCallReps){
                //@vishnu(4/9/15) : To involve the event reports that have end date as today also
                if(er.End__c.date() >= date.today() ){
                    setCallRepIds.add(er.id);
                }
            }
            client.ERABatchUpdateRequired__c = false;
            lstAccToUpdateERABatchUpdateReqToFalse.add(client);
        }
        
        for(Call_Report__c changedER : [select id,Relate_to_Client__c,
                                        (select id,Contact_Category__c,Client_Team_Role__c,Call_Report__c,Contact_id__c from Call_Report_Attendeess__r) 
                                        from Call_Report__c 
                                        where id IN: setCallRepIds]){
                                            
            for(Call_Report_Attendees__c era : changedER.Call_Report_Attendeess__r){
                if(mapAccIdmapUserConSyncIdCST.containsKey(changedER.Relate_to_Client__c)){
                    if(mapAccIdmapUserConSyncIdCST.get(changedER.Relate_to_Client__c).containsKey(era.Contact_id__c)){
                        if(era.Client_Team_Role__c != mapAccIdmapUserConSyncIdCST.get(changedER.Relate_to_Client__c).get(era.Contact_id__c).Client_Role__c){
                            era.Client_Team_Role__c = mapAccIdmapUserConSyncIdCST.get(changedER.Relate_to_Client__c).get(era.Contact_id__c).Client_Role__c;
                        }
                    }else{
                        era.Client_Team_Role__c = '';
                    }
                    mapIdERAToUpdate.put(era.id,era);
                }
            }
        }   
        if(!mapIdERAToUpdate.keyset().isEmpty()){
            try{
            update mapIdERAToUpdate.values();
            update lstAccToUpdateERABatchUpdateReqToFalse ;
            }catch(Exception e){
                system.debug('>>>> exception while running the batch : ' + e.getMessage());
            }
        }  
        
    }
    
    //Finish method of the batch class
    global void finish(Database.BatchableContext BC){
    }
}