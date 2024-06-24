/****************************************************************************  
* @author       Maham Hassan
* @date         15/03/2022
* @description  Domain class for financial Account Trigger.
*               Trigger Handler for Financial Accounts. It is calculating 
*               DTF(DTB) ratio on the client record.
*               
****************************************************************************/
public with sharing class DMN_finserv_FinancialAccount {
    
    /**
     * @description Calculating the DTF Ratio for Primary Account
     * @param financialAccounts 
     */
    public static void calculateDTFRatio (List<finserv__FinancialAccount__c> financialAccounts) {
        
        Set<Id> clientList = new Set<Id>();
        
        for (finserv__FinancialAccount__c finAccount : financialAccounts) {
            clientList.add(finAccount.FinServ__PrimaryOwner__c);
        }
        
        ClientDTFFunctions.recalculateDTFforClients(clientList);
        
    }
}