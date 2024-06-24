/*****************************************************************************************************\
    @ Func Area     : Draw_Down_Profile__c
    @ Author        : Rudolf Niehaus
    @ Date          : 03/07/2012
    @ Test File     : Test Method DrawDownProfile_Vf_Ext_Test
    @ Description   : Case#141: Each draw down profile record per related product has a sequence number. 
                                The number must be in sequence with the draw date of the list of records. 
                                When a user delete, update or insert a record then the sequence numbering 
                                must be adjusted accordingly.

                                NOTE: 
                                The helper class DrawDownProfileTrigger_HelperClass is used to make sure we do not
                                end up in a endless loop when updating the records in the trigger functions class
    -------------------------------------------------------------------------------------
    @ Func Area         : Draw_Down_Profile__c
    @ Last Modified By  : Rudolf Niehaus 
    @ Last Modified On  : 16/07/2012
    @ Modification Description : New method: validateDrawDate(list<Draw_Down_Profile__c> lst, set<Date> drawDate) 
                                 Related Draw Down Profile Draw dates cannot be on the same day.
******************************************************************************************************/

public with sharing class DrawDownProfileTriggerFunctions_Class {
   
    /** @description
    * The number must be in sequence with the draw date of the list of records.
    * @param pid
    */
    public static void reorderSequenceNumbers(Id pid){
        Id productId = pid;
        //SFP-16242 - Added Product__r.Product_Division__c,Product__r.RecordtypeId in query for ERS calculation
        list<Draw_Down_Profile__c> reorder = [Select Draw_Down_Number__c,Product__r.Product_Division__c,Product__r.RecordtypeId from Draw_Down_Profile__c where Product__c =: productId
                                              order by Draw_Date__c asc];
        
        Integer x = 1;
        list<Draw_Down_Profile__c> reorderUpdate = new list<Draw_Down_Profile__c>();
        
        for(Draw_Down_Profile__c dd : reorder){
            dd.Draw_Down_Number__c = x;
            
            reorderUpdate.add(dd);
            x++;
        }
        
        try {
          DrawDownProfileTrigger_HelperClass.setEventFired();   
          update reorderUpdate;
          //SFP-16242: ERS calculation modification
          Id LDProductRecordtypeID = Schema.SObjectType.SB_Product__c.getRecordTypeInfosByName().get('Lending and Commitments').getRecordTypeId();
            if(!reorder.isEmpty() && reorder[0].Product__r.Product_Division__c == 'Investment Banking' 
               && reorder[0].Product__r.RecordtypeId == LDProductRecordtypeID){
                Set<Id> productIds = new Set<Id>();
                productIds.add(productId);
                List<SB_Product__c> products = [SELECT ID, Opportunity__c,Opportunity__r.Actual_Close_Date__c,
                                                Opportunity__r.StageName,Opportunity__r.CloseDate,
                                                Product_Division__c,Earliest_Draw_Date_Rollup__c,Term_Tenor__c,
                                                Total_Margin__c,Total_Fees__c,Finance_Approved_Fee_Recognition__c,RecordTypeId,
                                                Current_Year_Margin__c, Current_Year_Fees__c,RecordType.Name
                                                FROM SB_Product__c WHERE ID =: productId];
                
                DMN_SB_Product.createEstimatedRevenueSchedule(productIds);
                DMN_SB_Product.calculateCYFeesAndMargin(products, null);
                update products;
            }
          //SFP-16242: End of Modifications
        } catch (DMLException ex) {
            System.debug('## Sorting Update NOT successful: ' + ex.getMessage());
        }
    
    }
    
}