/**
 * @description This class will merge the duplicate Cases
 * SFP-7989 
 *
 * @author Tshifhiwa Muavha
 * @date October 2021
 */
public with sharing class CaseMergeController {
    @AuraEnabled
/**
 * @description This method will fetch the Cases
 * SFP-7989 
 * @param searchKeyWord case number
 * @param objectName case object
 * @param excludeitemsList case list to exclude
 * @param parentCaseId parent case Id
 * @return list of cases
 */
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String objectName, List<sObject> excludeItemsList, String parentCaseId) {
        SEL_Cases selector = new SEL_Cases();
        List<Case> parentCase = selector.selectByCaseId(parentCaseId);
        Id accRec=parentCase[0].AccountId;
        String closedStatus='Closed';
        String searchKey = '%' + searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();
        List<string> lstExcludeitems = new List<string>();
        for(sObject item : excludeItemsList ){
		lstExcludeitems.add(item.id);
        }
        // Query Related case with status is not closed and same account
        String sQuery =  'select CaseNumber,Subject,Status from ' +ObjectName+ ' where (CaseNumber LIKE: searchKey OR Subject LIKE: searchKey) AND Id NOT IN : lstExcludeitems AND AccountId = : accRec AND status != :closedStatus AND Id != :parentCaseId and ParentId = null order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }


    @AuraEnabled
/**
 * @description This method will fetch the Cases based on parent case Id
 * SFP-7989 
 *
 * @param parentCaseId parent case Id
 * @return list of cases
 */
    public static List <Case> getRelatedCase(String parentCaseId){
        list<Case> lstCases = new list<Case>();
        SEL_Cases selector = new SEL_Cases();
        List<Case> parentCase = selector.selectByParentCaseId(parentCaseId);
       if(parentCase.size() > 0){
            lstCases = selector.selectCasesByCondition(parentCase[0].accountId, parentCase[0].Subject, parentCaseId);
        }
        return lstCases;
    }


    @AuraEnabled
/**
 * @description This class will fetch the Cases
 * SFP-7989 
 *
 * @param newParent case Id of parent case
 * @param newChild case Id of child case
 * @return Merged cases
 */
    public static Case mergeCase(String newParent, String newChild){
        SEL_Cases selector = new SEL_Cases();
        Case c = selector.mergeCase(newChild);
        c.ParentId = newParent;
        c.Status = 'Duplicate';        
        update c;
        return c; 
    }

    @AuraEnabled
/**
 * @description This method will fetch the Cases
 * SFP-7989 
 *
 * @param newParent case Id of parent case
 * @param newChildList list of child case
 * @return Merged cases
 */
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