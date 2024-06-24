/**
 * @description       : This function will 
 * @author            : Chibuye Kunda
 * @group             : 
 * @last modified on  : 10-14-2021
 * @last modified by  : Chibuye Kunda
**/
public with sharing class AOB_CTRL_ACPicklist {
    /**
    * @description This function will search for potential matches
    * @author Chibuye Kunda | 10-07-2021 
    * @param String label can be one of these values
    * @param String targetValue this is the value user has input
    * @return string 
    **/
    @AuraEnabled
    public static List<AOB_ReferencedData__c> loadData(String targetValue){
        List<AOB_ReferencedData__c> referenceDataList;
        
        String language=AOB_UTILS.getUserLanguage();

        try{
            referenceDataList = [SELECT Id, Name,AOB_Code__c, AOB_ParentCode__c 
                                 FROM AOB_ReferencedData__c
                                 WHERE (AOB_SapField__c=:targetValue AND AOB_Language__c=:language  AND AOB_isActive__c=true)
                                 WITH SECURITY_ENFORCED
                                 ORDER BY Name];
        }
        catch(QueryException exp){
            throw new AuraHandledException(exp.getMessage());      
        }
        
        return referenceDataList;
    }
}