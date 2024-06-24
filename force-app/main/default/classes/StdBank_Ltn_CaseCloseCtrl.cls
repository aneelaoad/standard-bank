/**
* @author Michal Lipinski milipinski@deloittece.com
* @description Controller for CaseClose LTNG component
* @testFile StdBank_LtnCaseClose_Test
*/ 
public with sharing class StdBank_Ltn_CaseCloseCtrl {
    /**
    * @description Get context case record
    * @param contextId Id of Context case
    * @return Context Case record
    */ 
    @AuraEnabled
    public static Case getRecord(Id contextId) {
        Case contextRecord = [Select id, Status,CaseNumber, Next_Steps__c, Resolution_Comment__c, RecordType.DeveloperName, Resolved_By__c from Case WHERE id = : contextId];
       contextRecord.Status = DMN_Case.STATUS_CLOSED;
       return contextRecord;
    }

    /**
    * @description Save case record
    * @param caseRecord case to be saved
    * @return true is success, false if not
    */ 
    @AuraEnabled
    public static void saveRecord(Case caseRecord) {     
            update caseRecord; 
    }

    /**
    * @description Provide close statues
    * @return List of DTO_SelectOption objects with all close type statuses on Case object
    */ 
    @AuraEnabled
    public static List<DTO_SelectOption> getStatuses(){ 
      List<DTO_SelectOption> options =  DTO_SelectOption.convert(DMN_Case.getCloseStatus());      
      for(Integer i = 0 ; i < options.size(); i++){
        if(options[i].label == DMN_Case.STATUS_REQUEST_COMPLETED){
          options.remove(i);
        }
      }
      return options;
    }

}