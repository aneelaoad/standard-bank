/*************************************************************************\
    @ Author        :     Abhishek V
    @ Date          :     08 Mar 2016
    @ Test File     :     UserTriggerUtility_Oppty_Test
    @ Description   :     EN - 1168: Set the Opportunity Owner user fields based on the User Object custom fields when User record is edited.

    @ Last Modified By       :   Petr Roubal
    @ Last Modified On      :   15 Mar 2016
    @ Last Modified Reason  :   EN - 1174: RTB - Compliance: Rename of Opportunity Owner User Fields (APIs) and CIB Global Area
          
    @ Last Modified By       :   Derek Hughes
    @ Last Modified On      :   22 June 2022
    @ Last Modified Reason  :   SFP-14449 - Set new picklist field Opportunity_Country__c in the same way as Opportunity_Owner_Country__c
****************************************************************************/

public without sharing class UserTriggerUtility_Oppty {

    public static void handleUserBeforeUpdateTrigger_Oppty(Map<Id, User> userMap){
              
       List<Opportunity>  OpenOpp_list = new List<Opportunity>();

        OpenOpp_list = [
            SELECT Id, OwnerId, Opportunity_Owner_Business_Unit__c, Opportunity_Owner_Global_Area__c,
                Opportunity_Owner_City__c, Opportunity_Owner_Country__c, Opportunity_Owner_Division__c, Opportunity_Owner_Franco__c,
                Opportunity_Owner_State_Province__c, Opportunity_Owner_Team__c
            FROM Opportunity
            WHERE OwnerId IN :userMap.keySet()
                AND (StageName = :DMN_Opportunity.ST_LEAD
                    OR StageName = :DMN_Opportunity.ST_DEVELOP)
        ];

        for(Opportunity openOpp : OpenOpp_list){
            
            System.debug('Enter into loop');
                    openOpp.Opportunity_Owner_Business_Unit__c = userMap.get(openOpp.OwnerId).Business_Unit__c;
                    openOpp.Opportunity_Owner_Global_Area__c = userMap.get(openOpp.OwnerId).User_CIB_Global_Area__c;
                    openOpp.Opportunity_Owner_City__c = userMap.get(openOpp.OwnerId).User_City__c;
                    openOpp.Opportunity_Owner_Country__c = userMap.get(openOpp.OwnerId).User_Country__c;
                    openOpp.Opportunity_Owner_Division__c = userMap.get(openOpp.OwnerId).User_Division__c;
                    openOpp.Opportunity_Owner_Franco__c = userMap.get(openOpp.OwnerId).User_Franco__c;
                    openOpp.Opportunity_Owner_State_Province__c = userMap.get(openOpp.OwnerId).User_State_Province__c;
                    openOpp.Opportunity_Owner_Team__c = userMap.get(openOpp.OwnerId).User_Team__c;
                    openOpp.Opportunity_Country__c = userMap.get(openOpp.OwnerId).User_Country__c;
           
        }        
        
      try{
        System.debug('#### Attempt User UPDATE now..OpenOpp_list.' + OpenOpp_list);
         update OpenOpp_list;
        System.debug('#### DONE');
        
      }catch(DMLException ex){
        System.debug('#### There was an Error when Synchronizing the Opportunity records with the related User record');
      }  

    }
}