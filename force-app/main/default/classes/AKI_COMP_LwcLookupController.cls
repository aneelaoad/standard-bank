/**
 *  Class for custom LWC lookup 
 * 
 * @author Vipeen Sarode
 * @date october 2021
 */
public with sharing class AKI_COMP_LwcLookupController {
    /**
     *  This method create insight action based on insight action type
     * 
     * @param   searchKey key which needs to be searched
     *  @param   objectName object in which data needs to be searched
     * 
     * @return Map<string,Id>  map of insight action type and insight action id
     */
    @AuraEnabled(cacheable=true)  
    public static List<sobject> findRecords(String searchKey, String objectName) {  
        String key = '%' + String.escapeSingleQuotes(searchKey) + '%'; 
        String query = 'SELECT Id, Name FROM ' +objectName+ ' WHERE Name LIKE :key LIMIT 6';  
        return Database.query(query);  
    }
}