/****************************************************************************  
* @author       Maham Hassan
* @date         15/03/2022
* @description  Batch class to update DTF Ratio for all the Accounts
*               
****************************************************************************/
public class BCH_CalculateDTFRatio implements Database.Batchable<sObject>{
    
    /**
     *  
     * @description Method to add query for the batch
     * @param bc Batchable Context
     * @return Query for executing DTF Functions. 
     */
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        Id commercialRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(DMN_Account.COMMERCIAL_AFRICA_TYPE).getRecordTypeId();
        Id enterpriseRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get(DMN_Account.ENTERPRISE_AFRICA_TYPE).getRecordTypeId();
        
        String query = 'SELECT Id,DTB_Ratio__c,Total_DTF__c FROM Account where RecordTypeId = \'' + commercialRecordTypeID + '\' OR RecordType.Name = \'' + enterpriseRecordTypeID + '\'';
        return Database.getQueryLocator(query);
    }

    /**
     * 
     * @description Execution of the Accounts to calculate DTB ratio and DTB score. 
     * @param bc Batchable Context 
     * @param scope List of SObjects (Account) for calculating its DTB ratio and DTB score.
     * 
     */
    public void execute(Database.BatchableContext bc, List<sObject> scope){

        Map<Id, Account> theClientsToReCalculate = new Map<Id,Account>();
        
        for (sObject s : scope) {
            theClientsToReCalculate.put(s.Id,(Account)s);
        }
        
       ClientDTFFunctions.recalculateDTF(theClientsToReCalculate);
        
    }    
     
    /**
     * 
     * @description Methods runs after calculating all the DTB ratios.
     * @param bc Batchable Context
     */
    public void finish(Database.BatchableContext bc) {
       
    }
 }