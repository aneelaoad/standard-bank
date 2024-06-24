/*************************************************************************
@ Author        : Rinkita Patil
@ Date          : May 2019
@ Description   : US-3886:Angola - Phase 4A | Adding "Search" within the Case Record
*************************************************************************/
public class MergeCaseController {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, List<sObject> ExcludeitemsList,String parentCaseId) {
        SEL_Cases selector = new SEL_Cases();
        List<Case> parentCase = selector.selectByCaseId(parentCaseId);
        Id accRec=parentCase[0].AccountId;
        String closedStatus='Closed';
        String searchKey = '%' + searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();
        List<string> lstExcludeitems = new List<string>();
        for(sObject item : ExcludeitemsList ){
            lstExcludeitems.add(item.id);
        }
        // Query Related case with status is not closed and same account
        String sQuery =  'select CaseNumber,Subject,Status from ' +ObjectName + ' where (CaseNumber LIKE: searchKey OR Subject LIKE: searchKey) AND Id NOT IN : lstExcludeitems AND AccountId = : accRec AND status != :closedStatus AND Id != :parentCaseId and ParentId = null order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }
     @AuraEnabled
    public static List <Case> getRelatedCase(String parentCaseId){
        list<Case> lstCases = new list<Case>();
        SEL_Cases selector = new SEL_Cases();
        List<Case> parentCase = selector.selectByParentCaseId(parentCaseId);
        if(parentCase.size() > 0){
            lstCases = [Select Id, CaseNumber, Subject, Status, Account.Name, Contact.Name, 
                       Origin, Owner.Name, Custody_Sub_Category__c, Custody_Category__c  
                       From Case 
                       Where AccountId = :parentCase[0].AccountId and Status !='Closed' and 
                       Id != :parentCaseId and 
                       ParentId = null  
                       Order by CreatedDate Desc limit 10 ];
        }
        return lstCases;
    }
    @AuraEnabled
    public static Case mergeCase(String newParent, String newChild){
        SEL_Cases selector = new SEL_Cases();
        Case c = selector.mergeCase(newChild);
        c.ParentId = newParent;
        c.Status = 'Duplicate';        
        update c;
        return c; 
    }
    @AuraEnabled
    public static List<Case> mergeMultipleCase(String newParent, List<Sobject> newChildList){
        List<string> newChildListUpdate = new List<string>();
        for(sObject item : newChildList ){
            newChildListUpdate.add(item.id);
        }
        SEL_Cases selector = new SEL_Cases();
        List<case> caseList=selector.mergeMultipleCase(newChildList);
        List<Case> updateCaseList=new List<case>();
        for(Case c:caseList){
            c.ParentId = newParent;
            c.Status = 'Duplicate'; 
            updateCaseList.add(c);
        }
        update updateCaseList;
        return updateCaseList; 
    }
}