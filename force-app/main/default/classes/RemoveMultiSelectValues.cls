/**
 * @description Class for removal of expired roles on the AccountContactRelation object
 * @author		Sipho Mbulawa
 * @date		March 2022
 */
global class RemoveMultiSelectValues implements Database.Batchable<sObject>{
    private static final String ERROR_MSG = 'An error has ocured,please contact system administrator.';
    public class RemoveMultiSelectValuesException extends Exception{}
    public String queryString;
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Date currentDate = Date.today();
        String activeStatus = DMN_CMN_AccountContactRelationshipDetail.ACTIVE_STATUS;
        this.queryString = 'SELECT Id,Status__c,Client__c,Contact__c,Role__c FROM CMN_Account_Contact_Relationship_Detail__c WHERE Valid_To__c<:currentDate AND Status__c=:activeStatus';
        return Database.getQueryLocator(this.queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<CMN_Account_Contact_Relationship_Detail__c> cmnAccountContactRelation){
        
        for(CMN_Account_Contact_Relationship_Detail__c acr:cmnAccountContactRelation){
            acr.Status__c = DMN_CMN_AccountContactRelationshipDetail.EXPIRED_STATUS;
        }
        update cmnAccountContactRelation;
        
    }
    
    global void finish(Database.BatchableContext BC){}
   /**
    * @description This is to remove a pick list value from the Account Contact Relationship role field
    * 
    */    
    @InvocableMethod(label='Remove MultiSelect Value' description='This is to remove a pick list value from the Account Contact Relationship role field')
    public static void callRemoveMultiSelectValuesBatch(){

        RemoveMultiSelectValues bt = new RemoveMultiSelectValues();
        Database.executeBatch (bt,5000);
    }
}