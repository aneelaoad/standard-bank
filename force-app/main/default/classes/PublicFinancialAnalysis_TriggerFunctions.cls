/**
    @ Author                   : Charles Mutsu
    @ Date                     : 03/05/2014
    @ Description              : Assigns recordtype to Spreadpac Feed, manages PFA records without duplicates
                      Trigger  : PublicFinancialAnalysis_Trigger
                      TestClass: PublicFinancialAnalysis_Trigger_Test
 */
public with sharing class PublicFinancialAnalysis_TriggerFunctions {
    
    public static Map < String, Schema.RecordTypeInfo > mapPFARecordTypes = Client_Financial_Analysis__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Id spreadPacRecordTypeId = mapPFARecordTypes.get('Spreadpac Feed').getRecordTypeId();
    
    public static void insertPfaRecords(List<Client_Financial_Analysis__c> lstPfa){
        
       Set<Id> PfaIdSet = new Set<Id>();
        Map<Id,Client_Financial_Analysis__c> AccountPfaMap = new Map<Id,Client_Financial_Analysis__c>();
        List<Client_Financial_Analysis__c> lstToDeletePfa = new List<Client_Financial_Analysis__c>();
        
        for(Client_Financial_Analysis__c pfa:lstPfa){
            if(pfa.Statement_Date__c != NULL){
                AccountPfaMap.put(pfa.Client_Name__c, pfa);
                PfaIdSet.add(pfa.Id);
            }
            if(pfa.Spreadpac__c){
                pfa.RecordTypeId = spreadPacRecordTypeId;
            }       
        }
        
        for(Client_Financial_Analysis__c opfa: [Select Id, Client_Name__c, Statement_Date__c, Spreadpac__c from Client_Financial_Analysis__c where Client_Name__c IN:AccountPfaMap.keySet() AND Id NOT IN:PfaIdSet]){
            if(opfa.Statement_Date__c.year() != NULL && AccountPfaMap.containsKey(opfa.Client_Name__c)){
                if(opfa.Statement_Date__c.year() == AccountPfaMap.get(opfa.Client_Name__c).Statement_Date__c.year() && AccountPfaMap.get(opfa.Client_Name__c).Spreadpac__c){
                    lstToDeletePfa.add(opfa);
                }else if(opfa.Statement_Date__c.year() == AccountPfaMap.get(opfa.Client_Name__c).Statement_Date__c.year() && opfa.Spreadpac__c && !AccountPfaMap.get(opfa.Client_Name__c).Spreadpac__c){
                    AccountPfaMap.get(opfa.Client_Name__c).addError('There can only be one public financial analysis record for the same year');        
                }else if(opfa.Statement_Date__c.year() == AccountPfaMap.get(opfa.Client_Name__c).Statement_Date__c.year() && !opfa.Spreadpac__c && !AccountPfaMap.get(opfa.Client_Name__c).Spreadpac__c){
                    AccountPfaMap.get(opfa.Client_Name__c).addError('There can only be one public financial analysis record for the same year. Please edit existing year\'s record if changes are required and the public financial analysis has been manually captured');  
                }
            } 
        } 
        if(lstToDeletePfa.size()>0)
        delete lstToDeletePfa;  
    } 
}