/****************************************************************************  
* @author       Maham Hassan
* @date         15/03/2022
* @description  It is calculating DTF(DTB) ratio on the client record. Based 
*               on product groups of each Financial Account

    2022-05-31 Confirmed requirements from Simone Breytenbach
    
    There are 10 DTB groups/needs. The formula will need to count how many of these groups you are offering a client. 
    as a matter of interest, an RM has a target of around 6/10, i.e. 0.60 average they need to achieve. 
    If you open 3 current accounts, it's still just 1 need you've met (Business Current Accounts) 
    ere are the 10 groups:. Hope it helps.

    1.Business Current Accounts
    2.Bancassurance
    3.Card Acquiring
    4.Structured Working Capital Finance (SWCF)
    5.Trade
    6.Savings and Investments
    7.Global Markets
    8.Vehicle and Asset Finance (VAF)
    9.Loans
    10.Digital (e.g. Business Online, EOL, Nomanini)
*               
****************************************************************************/
public with sharing class ClientDTFFunctions {
        
    /**
    * @description Determine the total number of DTF Groups as defined in the Product Group Custom Section.
    * @return  Number of DTF Product groups 
    */
    public static integer getTotalDTFGroups(){
        
        Schema.DescribeFieldResult fieldResult = Product2.Product_Group__c.getDescribe();
        List<Schema.PicklistEntry> groups = fieldResult.getPicklistValues();
            
        Set<String> allGroups = new Set<String>();
        for (Schema.PicklistEntry productGroup : groups) {
            allGroups.add(productGroup.getValue());
        }
        allGroups.remove('Other');
        allGroups.remove('Personal Markets');
        allGroups.remove('Corporate Card');

        Integer totalDTFGroups = allGroups.size();
        return totalDTFGroups;
    }
        
    /**
     * 
     * @description Recalculate the DTF Ratio for all commercial clients
     */
    public static void recalculateAllDTFRatios(){
        BCH_CalculateDTFRatio batch = new BCH_CalculateDTFRatio();
        Database.executeBatch( batch );
    }
        
    /**
     * 
     * @description Recalculate the DTF Ratio for a specific set of clients
     * @param clientList List of Clients for DTF calculation
     */
    public static void recalculateDTFforClients(Set<Id> clientList){
        Map<Id, Account> theClientsToReCalculate = new Map<Id,Account>(new SEL_Accounts().selectById(clientList));  
        ClientDTFFunctions.recalculateDTF(theClientsToReCalculate);
    }
    
    /**
     * 
     * @description Calculations of DTF based on Client List 
     * @param theClientsToReCalculate Client List
     */
    public static void recalculateDTF(Map<Id, Account> theClientsToReCalculate) {
         
        Integer totalDTFGroups = ClientDTFFunctions.getTotalDTFGroups();
           
        List<AggregateResult> theAggregateResults = new List<AggregateResult>([
            SELECT FinServ__PrimaryOwner__c, COUNT_DISTINCT(FinServ__ProductName__r.Product_Group__c) totalDTF 
            FROM finserv__FinancialAccount__c 
            WHERE FinServ__PrimaryOwner__c IN :theClientsToReCalculate.keySet() 
                AND Held__c = 'Yes' 
                AND FinServ__ProductName__r.Product_Group__c NOT IN ('Other', 'Personal Markets', 'Not Defined', 'Corporate Card') 
            GROUP BY FinServ__PrimaryOwner__c]);

        for (AggregateResult theAggregateResult : theAggregateResults) {
            Account theClientToRecalculate = theClientsToReCalculate.get((Id)theAggregateResult.get('FinServ__PrimaryOwner__c'));
            theClientToRecalculate.Total_DTF__c = (Integer)theAggregateResult.get('totalDTF');
            theClientToRecalculate.DTB_Ratio__c = theClientToRecalculate.Total_DTF__c/totalDTFGroups;
            theClientsToReCalculate.put((Id)theAggregateResult.get('FinServ__PrimaryOwner__c'),theClientToRecalculate);
        }
        
        if (theClientsToReCalculate.values().size() > 0) {
            Database.update(theClientsToReCalculate.values(),false);
        }
        
    }
}