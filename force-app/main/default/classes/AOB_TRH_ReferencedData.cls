/*
*   @ Author            :  Gill Lumley
*   @ Date              :  19 February 2023
*   @ User Story        :  SFP-8703, SFP-8958 
*   @ Description       :  Trigger handler class for referenced data object
*/
public class AOB_TRH_ReferencedData {
    
    public static void beforeInsertHandler(List<AOB_ReferencedData__c> newRecords){
        AOB_CTRL_ReferencedData.deactivateRecords(newRecords);
    }
      
    public static void beforeUpdateHandler(List<AOB_ReferencedData__c> newRecords){
        AOB_CTRL_ReferencedData.deactivateRecords(newRecords);
    }
    
}