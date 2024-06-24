/*************************************************************************
@ Author        : Rinkita Patil
@ Date          : April 2019
@ Description   : US-3664:Case Closure process server side controller
*************************************************************************/
public with sharing class Angola_CloseCaseController {
    
    @AuraEnabled
    public static Case getRecord(Id caseId) {
        SEL_Cases selector = new SEL_Cases();
        List<Case> caseRecord = selector.selectByCaseId(caseId);
        return caseRecord[0];
    } 
    
    @AuraEnabled
    public static void saveRecord(Case caseRecordUpdate, Contact selectedRecord) { 
        caseRecordUpdate.Status = 'Closed';
        if(selectedRecord !=null){
            caseRecordUpdate.Resolved_By__c= selectedRecord.id;
        }
        update caseRecordUpdate; 
    }
    
    @AuraEnabled
    public static List<Angola_StatusPicklistController> getStatuses(){ 
        List<Angola_StatusPicklistController> options =  Angola_StatusPicklistController.convert(Angola_StatusPicklistController.getCloseStatus());      
        return options;
    }
    
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
        String searchKey = searchKeyWord + '%';
        List < sObject > returnList = new List < sObject > ();
        String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate ASC limit 5';
        List < sObject > lstOfRecords = Database.query(sQuery);
        for (sObject obj: lstOfRecords) {
            
            returnList.add(obj);
        }
        return returnList;
    }
    
}