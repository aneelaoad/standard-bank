/*************************************************************************\    
    @ Author        :     Shaveen Bageloo    
    @ Date          :     13 Apr 2011    
    @ Test File     :     OptyClosedOwnerDetailUpdate_Test    
    @ Description   :     CASE074                          
                            This trigger will copy the Opportunity Owner's                          
                            details from the USER object.                          
                            This code must fire when the Stage is either                          
                            "6 - Closed Lost" or "5 - Closed Won" and only                           
                            execute once per record.
    @ Last Modified By  :   Shaveen Bageloo
    @ Last Modified On  :   09 Jun 2011
    @ Last Modified Reason  :   Functionality change.  The 7 fields must be
                                updated when the Opportunity Owner changes 
                                and the Stage is CLOSED.  It must also fire
                                when the Stage is set to CLOSED.
                                @ Last Modified By  :   Shaveen Bageloo
    @ Last Modified On  :   09 Jun 2015 
    @ Last Modified Reason  :   Functionality change.EN-0619 Field included to update Closed Opportunity Owner Franco
    
    @Last Modified By       :   Abhishek V
    @ Last Modified On      :   07 Mar 2016
    @ Last Modified Reason  :   EN - 1168: Modified code to include scenarios for open opportunities as well.

    @Last Modified By       :   Petr Roubal
    @ Last Modified On      :   15 Mar 2016
    @ Last Modified Reason  :   EN - 1174: RTB - Compliance: Rename of Opportunity Owner User Fields (APIs) and CIB Global Area
  
    @ Last Modified By       :   Derek Hughes
    @ Last Modified On      :   22 June 2022
    @ Last Modified Reason  :   SFP-14449 - Set new picklist field Opportunity_Country__c in the same way as Opportunity_Owner_Country__c
****************************************************************************/

public class OptyClosedOwnerDetailUpdate{

    List<Opportunity> optysToBeUpdated = new List<Opportunity>{};
    List<Id> ownerIds = new List<Id>{};
    
    //This method is being called from the TRIGGER class that has records to be CREATED.
    public List<Opportunity> copyOppOwnerDetails(List <Opportunity> optyTriggerNew) {
    
        System.Debug('## >>> copyOppOwnerDetails <<< run by ' + UserInfo.getName());
        System.debug('##:getDMLRows/getLimitDMLRows: ' + Limits.getDMLRows() +'/'+ Limits.getLimitDMLRows());        
        System.debug('##### START: CASE740 - Update Opportunity fields with Opportunity Owners User Details : START #####');  
        System.debug('##### CREATE OPPORTUNITY #####');   

        for (Opportunity optyTriggerNewRec : optyTriggerNew) {
              
            System.debug('## Checking: Opportunity Record is (EN - 1168)Open/Closed ##');                    
            if ((optyTriggerNewRec.StageName == '1 - Lead') || (optyTriggerNewRec.StageName == '2 - Develop') ||(optyTriggerNewRec.StageName == '3 - Closed Won')  || (optyTriggerNewRec.StageName == '4 - Closed Lost') || (optyTriggerNewRec.StageName == 'Cancel'))
            {
                System.debug('## TRUE: Opportunity Record is Open/Closed##'); 
                optysToBeUpdated.add(optyTriggerNewRec);
                ownerIds.add(optyTriggerNewRec.OwnerId);   
            } 
        }
            
        return UpdateOptys(optysToBeUpdated);
   }    
   
  //This method is being called from the TRIGGER class that has records to be UPDATED.    
    public List<Opportunity> copyOppOwnerDetails(List <Opportunity> optyTriggerNew, Map<Id, Opportunity> optyTriggerOldMap) {
    
        System.Debug('## >>> copyOppOwnerDetails <<< run by ' + UserInfo.getName());
        System.debug('##:getDMLRows/getLimitDMLRows: ' + Limits.getDMLRows() +'/'+ Limits.getLimitDMLRows());        
        System.debug('##### START: CASE740 - Update Opportunity fields with Opportunity Owners User Details : START #####');  
        System.debug('##### UPDATE OPPORTUNITY #####');                 
        
            for (Opportunity optyTriggerNewRec : optyTriggerNew) {
                         
                if (optyTriggerOldMap.containsKey(optyTriggerNewRec.Id)) {
                
                    System.debug('## Opportunity New Record = Opportunity Old Record ##');
                    
                    //EN - 1168:Opportunity Stage was changed and it is changed from any value to Lead/Develop
                    if((optyTriggerOldMap.get(optyTriggerNewRec.Id).StageName != optyTriggerNewRec.StageName) && (optyTriggerNewRec.StageName == '1 - Lead' || optyTriggerNewRec.StageName == '2 - Develop'))
                    {
                        System.debug('## TRUE: Opportunity Record was CLOSED/OPEN and changed to LEAD/DEVELOP ##'); 
                        optysToBeUpdated.add(optyTriggerNewRec);
                        ownerIds.add(optyTriggerNewRec.OwnerId);
                    } 
                    
                    System.debug('## Checking: Opportunity Record was (EN - 1168)OPEN and changed to CLOSED ##');                    
                    if (((optyTriggerOldMap.get(optyTriggerNewRec.Id).StageName == '1 - Lead') || (optyTriggerOldMap.get(optyTriggerNewRec.Id).StageName == '2 - Develop')) &&
                        ((optyTriggerNewRec.StageName == '3 - Closed Won') || (optyTriggerNewRec.StageName == '4 - Closed Lost') || (optyTriggerNewRec.StageName == 'Cancel')))
                    {
                        System.debug('## TRUE: Opportunity Record was OPEN and changed to CLOSED ##'); 
                        optysToBeUpdated.add(optyTriggerNewRec);
                        ownerIds.add(optyTriggerNewRec.OwnerId);
                        
                    } 
                    
                    System.debug('## Checking: Opportunity Record is (EN - 1168)OPEN/CLOSED and OWNER has changed ##');                    
                    if (optyTriggerOldMap.get(optyTriggerNewRec.Id).OwnerId <> optyTriggerNewRec.OwnerId)
                    {
                        System.debug('## TRUE: Opportunity Record is OPEN/CLOSED and OWNER has changed ##');
                        optysToBeUpdated.add(optyTriggerNewRec);  
                        ownerIds.add(optyTriggerNewRec.OwnerId);                   
                    }
                    
                }
            }       
            
            
        return UpdateOptys(optysToBeUpdated);
   }   
    
   public List<Opportunity> UpdateOptys(List <Opportunity> optysToBeUpdated) {

        System.debug('## Opportunities to be updated : ' + optysToBeUpdated.size());   

        if (optysToBeUpdated.size() > 0) {
           
            System.debug('## Populating Closed Opportunity Owner"s Details... ##');  
            
            List<User> optyOwnersDetails = new List<User>
                                                    ([Select 
                                                      Id,
                                                      Name,
                                                      Business_Unit__c,
                                                      User_CIB_Global_Area__c,
                                                      User_City__c,
                                                      User_Country__c,
                                                      User_Division__c,
                                                      UserEmail__c,
                                                      User_State_Province__c,
                                                      User_Team__c,
                                                      User_Franco__c
                                                      from User
                                                      where Id IN :ownerIds]);    
    
    
            for (Opportunity optyToBeUpdated : optysToBeUpdated) {
            
                for (User optyOwnerDetailsRec : optyOwnersDetails) {
                
                    if (optyToBeUpdated.OwnerId == optyOwnerDetailsRec.Id) {
                        
            
                        System.debug('## Updating Opportunity fields ##'); 
                                                
                        optyToBeUpdated.Opportunity_Owner_Business_Unit__c = optyOwnerDetailsRec.Business_Unit__c;
                        optyToBeUpdated.Opportunity_Owner_Global_Area__c = optyOwnerDetailsRec.User_CIB_Global_Area__c;
                        optyToBeUpdated.Opportunity_Owner_City__c = optyOwnerDetailsRec.User_City__c;
                        optyToBeUpdated.Opportunity_Owner_Country__c = optyOwnerDetailsRec.User_Country__c;
                        optyToBeUpdated.Opportunity_Owner_Division__c = optyOwnerDetailsRec.User_Division__c;
                        optyToBeUpdated.Opportunity_Owner_State_Province__c = optyOwnerDetailsRec.User_State_Province__c;
                        optyToBeUpdated.Opportunity_Owner_Team__c = optyOwnerDetailsRec.User_Team__c;
                        optyToBeUpdated.Opportunity_Owner_Franco__c = optyOwnerDetailsRec.User_Franco__c;
                        optyToBeUpdated.Opportunity_Country__c = optyOwnerDetailsRec.User_Country__c;
                        
                        System.debug('## Opportunity fields updated ##');  
                            
                    }
                }
            }
                                                    
            System.debug('## Updating done. ##');
        }   
        
        System.debug('##### END: CASE740 - Update Opportunity fields with Opportunity Owners User Details : START #####');          
        return optysToBeUpdated;                   
   }
   
}