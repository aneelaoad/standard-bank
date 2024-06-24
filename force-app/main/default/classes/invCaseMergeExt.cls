/**
 * 2017-11-02
 * Rudolf Niehaus - CloudSmiths
**/
public class invCaseMergeExt {
    
    @AuraEnabled
    public static list<Case> getRelatedCase(String parentCaseId){
        
        list<Case> lstCases = new list<Case>();
        list<Case> parentCase = [Select AccountId From Case Where Id = :parentCaseId];
        
        if(parentCase.size() > 0){
           lstCases = [Select Id, CaseNumber, Subject, Status, Account.Name, Contact.Name, 
                       Origin, Owner.Name, Custody_Sub_Category__c, Custody_Category__c  
                       From Case 
                       Where AccountId = :parentCase[0].AccountId and isClosed = false and 
                       Id != :parentCaseId and 
                       ParentId = null  
                       Order by CreatedDate Desc limit 10 ];
        }
        
        return lstCases;
    }
    
    @AuraEnabled
    public static Case mergeCase(String newParent, String newChild){
        
        Case c = [Select ParentId From Case Where Id = :newChild];
        
        c.ParentId = newParent;
        c.Status = 'Duplicate';        
        update c;
        return c; 
    }
}