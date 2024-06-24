/**
 * Controller for aob_cmp_personalDetails component
 * 
 * <p>DPB-1159  DPB-1160</p> 
 * 
 * @author Maryem BOURHI (mbourhi@salesforce.com)
 * 
 * @date Nov 4th 2020
 */
public with sharing class AOB_CTRL_PersonalDetails {
    
    /**
    * @description  method to fetch the picklist values from the refrenced Data Table
    * @param    sapFields  List<String> Object Name
    * @return   Map<String,List<AOB_DTO_SelectOption>>
    */
    @AuraEnabled
    public static Map<String,List<AOB_DTO_SelectOption>> getAllPicklistEntriesCodes(List<String> sapFields){
        try{
            return AOB_Utils.getAllPicklistEntriesCodes(sapFields);
        }
        catch(Exception error)
        {
            throw new AuraHandledException(error.getMessage());
        }
    }
    
}