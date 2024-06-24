/*****************************************************************************************************\
    @ Func Area     : Campaigns, Members Hosts
    @ Author        : Rudolf Niehaus
    @ Date          : 06/09/2012
    @ Test File     : Test Method CampaignHostsTrigger_Test
    @ Description   : Case#6220
                      The fuction add and subtract hosts from the number_of_hosts__c field on the related Campaign.
                      The reason for this is to use this field for reporting purposes as business wants to
                      see how many hosts there is per Campain.
                      
                      Updated the class to version 27
                                       
******************************************************************************************************/
public class CampaignHostsTriggerFunctions {
@future
    public static void recalculateHostCount(set<Id> cIds){
        set<Id> hostIds = new set<Id>();    
        map<Id, Campaign> campHostCountMap = new map<Id,Campaign>([Select c.Id, c.Number_of_Hosts__c From Campaign c where c.Id IN : cIds]);
        
        Id campid = null;
        for(Campaign_Hosts__c host : [Select Campaign_Member_Host__r.Campaign__c, Campaign_Member_Host__c, Bank_Contact__c From Campaign_Hosts__c 
                                        where Campaign_Member_Host__r.Campaign__c IN : cIds order by Campaign_Member_Host__r.Campaign__c asc]){
                                            
            if(host.Campaign_Member_Host__r.Campaign__c == campid || campid == null){
                hostIDs.add(host.Bank_Contact__c);
            }else{
                campHostCountMap.get(campid).Number_of_Hosts__c = hostIds.size();

                hostIds.clear();
                
                hostIds.add(host.Bank_Contact__c);
                
            }
            
            campid = host.Campaign_Member_Host__r.Campaign__c;
        }

        //update last campaign map record
        if(campid==null){//this means there was no hosts for any of the campaigns, update all to 0
            for(Id x : cIds){
                campHostCountMap.get(x).Number_of_Hosts__c = hostIds.size();
            }
        }else{
            campHostCountMap.get(campid).Number_of_Hosts__c = hostIds.size();
        }
        
        try{
            if (campHostCountMap.values().size() > 0) {
                    Database.saveresult[] s = Database.update(campHostCountMap.values(), false);
                }
            //update campHostCountMap.values();
        }catch(System.DMLException e){
            System.debug('The "Number of Hosts" field on the campaign could not be updated. Please contact your system admin');
        }   
            
    }
}