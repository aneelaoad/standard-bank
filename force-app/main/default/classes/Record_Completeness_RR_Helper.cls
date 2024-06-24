/****************************************************************************  
* @author       Maham Hassan
* @date         15/03/2022
* @description  Helper class for Record Completeness related list. It is 
*               returning all the related list with there number of records.
* @Test File    CalculateRecordCompletness_TEST   
*               
****************************************************************************/
global class Record_Completeness_RR_Helper{
    
    /**
     * 
     * @description Getting Related Reord for Client which are required for Record Completeness
     * @param AccountIdSet Set of Account Ids
     * @param AccountIdMap Map of Accounts
     * @return Map <Account,Map<String,Integer>> Map of Accounts with the related List map
     */
    global static Map <Account,Map<String,Integer>> getRelatedRecord(Set <Id> AccountIdSet,Map <Id,Account> AccountIdMap){
        
        Map<Account,Map<String,Integer>> mapForCalculationClass = new MAP<Account,Map<String,Integer>>();
        List <sObject> objectRecordList = new List <sObject>();
        MAP <String,List <sObject>> relatedObjectRecordMAP = new MAP<String,List <sObject>>();
        Map<String,Record_Completeness_Related_Records__mdt> relatedObjectAllRecords =  Record_Completeness_Related_Records__mdt.getAll();
        Map <string,string> objectMap = new Map <string,string>();
        Map <String,Integer> relatedObjectCount = new Map <String,Integer>();
        Map<String,Record_Completeness_Related_Records__mdt> relatedObjectMap = new  Map<String,Record_Completeness_Related_Records__mdt>();
        
        Map<Id,Schema.RecordTypeInfo> recordTypeMap = SEL_Accounts.getRecordTypes();

        for (String relatedRec: relatedObjectAllRecords.keySet()) {
            relatedObjectMap.put(relatedObjectAllRecords.get(relatedRec).Object_API_Name__c, relatedObjectAllRecords.get(relatedRec));
            objectMap.put(relatedObjectAllRecords.get(relatedRec).Object_API_Name__c, relatedObjectAllRecords.get(relatedRec).Relationship_Field__c);
        }

        for(Account currentAccRecord: AccountIdMap.values()){
            if(!relatedObjectMap.isEmpty()){
                for(String currentObject:relatedObjectMap.keySet()){
                    if(!relatedObjectCount.containsKey(currentObject))
                        {
                        	relatedObjectCount.put(currentObject,0);
                        }
                }  
                mapForCalculationClass.put(currentAccRecord, relatedObjectCount);
            }
        }
        if(!relatedObjectMap.isEmpty()){
            
            //JN: Get all records using the above criteria
            if(objectMap.size()>0){
                for(String currentObject : objectMap.keySet()){
                    String query ='';
                    IF(relatedObjectMap.get(currentObject).Record_Filter_Criteria__c == null || relatedObjectMap.get(currentObject).Record_Filter_Criteria__c == ''){    
                        query = 'Select Id,'+objectMap.get(currentObject)+' from '+currentObject+' WHERE '+objectMap.get(currentObject)+' in :AccountIdSet';  
                    } else {
                        query = 'Select Id,'+objectMap.get(currentObject)+' from '+currentObject+' WHERE '+objectMap.get(currentObject)+' in :AccountIdSet AND '+relatedObjectMap.get(currentObject).Record_Filter_Criteria__c;                         
                    }
                    List <sObject> returnedRecords = Database.query(query);
                    if(returnedRecords.size()>0){
                        
                        for(sObject currentRecord : returnedRecords){
                            string objectType = String.valueOf(currentRecord.getsObjectType());
                            Id relatedRecordId = AccountIdMap.get(String.valueOf(currentRecord.get(relatedObjectMap.get(objectType).Relationship_Field__c))).Id;
                            if (relatedObjectRecordMAP.get(relatedRecordId) == null) {
                                relatedObjectRecordMAP.put(relatedRecordId,new List<sObject>());
                            }
                            List <sObject> listFromMap = relatedObjectRecordMAP.get(relatedRecordId);
                            listFromMap.add(currentRecord);
                            relatedObjectRecordMAP.put(relatedRecordId,listFromMap);
                            objectRecordList.Add(currentRecord);
                        } 
                    }else{
                        relatedObjectCount.put(currentObject,0);
                    }
                
                }
            }
            //JN: Count records per account add values to map
            if(relatedObjectRecordMAP.size()>0){
                for(String currentAccountId : relatedObjectRecordMAP.keySet()){
                    relatedObjectCount = new Map <String,Integer>();
                    account relatedRecord = AccountIdMap.get(currentAccountId);
                    
                    
                    for(String currentObject:relatedObjectMap.keySet()){
                        String relationshipSegment= relatedObjectMap.get(currentObject).Record_Type__c;
                        //Tdb: Client Segment field on Custom Setting determines if Fields should count toward CVCA
                        if(relationshipSegment.contains(recordTypeMap.get(relatedRecord.recordTypeId).Name))
                        {
                            relatedObjectCount.put(currentObject,0);
                        	mapForCalculationClass.put(AccountIdMap.get(currentAccountId),relatedObjectCount);
                        }
                    }
                    
                    
                    for(sObject currentsObjectRecord : relatedObjectRecordMAP.get(currentAccountId)){
                        String objectName = String.valueOf(currentsObjectRecord.getsObjectType());
                        String relationshipField= relatedObjectMap.get(objectName).Relationship_Field__c;
                        String relationshipSegment= relatedObjectMap.get(objectName).Record_Type__c;
                        //Tdb: Client Segment field on Custom Setting determines if Fields should count toward CVCA
                        if(currentsObjectRecord.get(relationshipField) == currentAccountId && relationshipSegment.contains(recordTypeMap.get(relatedRecord.recordTypeId).Name)) {
                            integer Count = 0;
                                if(relatedObjectCount.get(objectName) != null){
                                    Count = relatedObjectCount.get(objectName);
                                }
                            Count += 1;
                            relatedObjectCount.put(objectName,Count);
                        }                        
                    } 
                     mapForCalculationClass.put(relatedRecord,relatedObjectCount);
                }
            }
        }
        return mapForCalculationClass;
    }

     /**
     * 
     * @description Getting Related Reord for new Client which are required for Record Completeness
     * @param accounts List of Accounts
     * @return Map <Account,Map<String,Integer>> Map of Accounts with the related List map
     */
    global static Map <Account,Map<String,Integer>> createRelatedMapForInsert(List<Account> accounts) {
        
        Map<Account,Map<String,Integer>> relatedListMap = new MAP<Account,Map<String,Integer>>();
        Map<String,Record_Completeness_Related_Records__mdt> relatedObjectAllRecords =  Record_Completeness_Related_Records__mdt.getAll();
        Map<String,Record_Completeness_Related_Records__mdt> relatedObjectMap = new  Map<String,Record_Completeness_Related_Records__mdt>();
        Map <String,Integer> relatedObjectCount = new Map <String,Integer>();

        for (String relatedRec: relatedObjectAllRecords.keySet()) {
            relatedObjectMap.put(relatedObjectAllRecords.get(relatedRec).Object_API_Name__c, relatedObjectAllRecords.get(relatedRec));
        }

        for (Account acc: accounts) {
            for(String currentObject: relatedObjectMap.keySet()){
                if(!relatedObjectCount.containsKey(currentObject)) {
                    relatedObjectCount.put(currentObject,0);
                }
            }
            relatedListMap.put(acc, relatedObjectCount);  
        }
        return relatedListMap;
    }
}