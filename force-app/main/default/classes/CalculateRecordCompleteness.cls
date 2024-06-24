/****************************************************************************  
* @author       Maham Hassan
* @date         15/03/2022
* @description  Record Completeness score is getting calculated. Currently,
*               It is working for Account (Client) object.
* @Test File    CalculateRecordCompletness_TEST   
*
* 2023-08-10    Derek Hughes    Cleanup and refactor while sorting out calculation on Prospect record types
*               
****************************************************************************/
Global class CalculateRecordCompleteness {
    
    // Get the recordcompleteness fields
    global static final Map<String,RecordCompleteness__mdt> recordCompletenessFieldMap = RecordCompleteness__mdt.getAll();
    // Get the recordcompleteness related list items
    global static Map<String,Record_Completeness_Related_Records__mdt> relatedObjectAllRecords = Record_Completeness_Related_Records__mdt.getAll();

    global static Map<String,Record_Completeness_Related_Records__mdt> recordCompletenessRelatedMap = new  Map<String,Record_Completeness_Related_Records__mdt>();

    global static Map<Id,Schema.RecordTypeInfo> recordTypeMap = SEL_Accounts.getRecordTypes();
    
    global static List<Account> updateRecordCompletenessScore( Map< Account, Map< String,Integer > > accountCompletenessMap ){
        
        List<Account> accountsToUpdate = new List<Account>();
        
        for ( Account theAccount : new List<Account>(accountCompletenessMap.KeySet()) ) {
            accountsToUpdate.add(updateRecordCompletenessScore( theAccount, accountCompletenessMap.get(theAccount)));
        }
        return accountsToUpdate;
    }
    
    global static Account updateRecordCompletenessScore( Account theAccount, Map< String,Integer > accountRelatedRecordsMap ) {

        RecordCompleteness accountCompleteInfo = new RecordCompleteness(theAccount.Completeness_Score__c);
        RecordCompleteness newAccountCompleteInfo = getRecordDetailCompletenessScore(theAccount, accountRelatedRecordsMap, accountCompleteInfo);
        if (newAccountCompleteInfo.isDifferent()){
            theAccount.Completeness_Score__c = newAccountCompleteInfo.getCompletedScore();
            theAccount.Missing_Fields__c = newAccountCompleteInfo.getMissingFields();
            theAccount.Missing_Sections__c = newAccountCompleteInfo.getIncompleteSections();
            theAccount.Missing_Related_Records__c = newAccountCompleteInfo.getMissingRelatedRecords();
        }
        return theAccount;
    } 
    
    // Method to get the completeness score of a record
    global static RecordCompleteness getRecordDetailCompletenessScore(sObject theRecord, Map< String,Integer > theRelatedRecords, RecordCompleteness theCompletenessInfo){
        
        for (String relatedRec: relatedObjectAllRecords.keySet()) {
            recordCompletenessRelatedMap.put(relatedObjectAllRecords.get(relatedRec).Object_API_Name__c, relatedObjectAllRecords.get(relatedRec));
        }
        //Get the object Name
        Schema.SObjectType objectType = theRecord.getSObjectType();
        String objectName = String.valueOf(objectType);
        String RTName = recordTypeMap.get((Id) theRecord.get('RecordTypeId')).Name;
        RecordCompleteness completenessInfo = theCompletenessInfo;
        
        List<RecordCompleteness__mdt> activeCompletenessFields = new List<RecordCompleteness__mdt>();
        
        // Find the active fields that should be used to calculate completeness
        for (RecordCompleteness__mdt completenessField : recordCompletenessFieldMap.Values()){
            if (completenessField.isActive__c && (completenessField.Object__c == objectName) ){

                if(completenessField.RecordType__c.contains(RTName)) {
                    activeCompletenessFields.add(completenessField);
                }
            }
        }
        
        // Determine the maximum number of fields
        Integer totalFields = activeCompletenessFields.size();
        completenessInfo.setTotalFields(totalFields);
        Integer completedFieldCount = 0;
        
        Map<String,Schema.SObjectField> mfields = objectType.getDescribe().fields.getMap();
        // Check if the fields have a value
        for (RecordCompleteness__mdt fieldToCheck: activeCompletenessFields) {
            if (!mfields.containsKey(fieldToCheck.Field__c))  {
                
                throw new MyException('INTERNAL ERROR: Invalid field specifieid for record completeness calcualtion: '+FieldToCheck.Field__c);
            }
            if (theRecord.get(fieldToCheck.Field__c) != null ){  
                if(theRecord.get(fieldToCheck.Field__c) == 0.00 && fieldToCheck.Do_Not_Allow_0_Values__c == True) {
                    completenessInfo.addMissingField(fieldToCheck.DeveloperName);
                    completenessInfo.addIncompleteSection(fieldToCheck.Section__c);
                } else {
                    if(fieldToCheck.RecordType__c != null )
                    {
                        if (fieldToCheck.RecordType__c.contains(RTName)) {
                            completenessInfo.addToScore();
                        }
                    }
                }
            } else {
                
                if (fieldToCheck.RecordType__c.contains(RTName)) {
                    completenessInfo.addMissingField(fieldToCheck.DeveloperName);
                    completenessInfo.addIncompleteSection(fieldToCheck.Section__c);
                }
            }
        }
        
        // Check related records
        if (theRelatedRecords != null){
            for (String relatedRecord : theRelatedRecords.keySet()) {
                //Tdb: Client Segment field on Custom Setting determines if Fields should count toward CVCA
                if (recordCompletenessRelatedMap.get(relatedRecord).Record_Type__c.contains(RTName)) {
                    completenessInfo.addToRelatedObjects();
                    if (theRelatedRecords.get(relatedRecord) >= (recordCompletenessRelatedMap.get(relatedRecord)).Record_Limit__c ) { 
                        completenessInfo.addToScore();
                    } else {
                        completenessInfo.addMissingRelatedRecord(recordCompletenessRelatedMap.get(relatedRecord).Related_List_Name__c);
                    }
                } 
            }
        }
        return completenessInfo;
    }
    
    global class RecordCompleteness {
        Decimal score;
        Decimal previousScore;
        String missingFields;
        String missingRelatedRecords;
        String incompleteSections;
        Decimal totalFields;
        Decimal totalRelatedObjects;
        
        RecordCompleteness(Decimal currentScore){
            this.totalRelatedObjects = 0;
            this.totalFields = 0;
            this.score = 0;
            this.missingFields = '';
            this.incompleteSections = '';
            this.missingRelatedRecords = '';
            this.previousScore = currentScore == null ? 0 : currentScore;
        }
        
        Boolean isDifferent(){
            return this.score != this.previousScore;
        }
        
        String addMissingField(String missingField){
            if ( this.missingFields == ''){
                if ( !this.missingFields.containsIgnoreCase(missingField) ) this.missingFields += missingField; 
            } else {
                if ( !this.missingFields.containsIgnoreCase(missingField) ) this.missingFields += '; ' + missingField;
            }
            return this.missingFields;
        }
        
        String addIncompleteSection(String incompleteSection){
            if ( this.incompleteSections == ''){
                if ( !this.incompleteSections.containsIgnoreCase(incompleteSection) ) this.incompleteSections += incompleteSection; 
            } else {
                if ( !this.incompleteSections.containsIgnoreCase(incompleteSection) ) this.incompleteSections += '; ' + incompleteSection;
            }     
            return this.incompleteSections;
        }
        
        String addMissingRelatedRecord(String missingRelatedRecord){
            if ( this.missingRelatedRecords == ''){
                if ( !this.missingRelatedRecords.containsIgnoreCase(missingRelatedRecord) ) this.missingRelatedRecords += missingRelatedRecord; 
            } else {
                if ( !this.missingRelatedRecords.containsIgnoreCase(missingRelatedRecord) ) this.missingRelatedRecords += '; ' + missingRelatedRecord;
            }     
            return this.missingRelatedRecords;
        }
        
        Void addToRelatedObjects(){
            this.totalRelatedObjects++;
        }
        Void addToScore(){
            this.score ++;
        }
        
        Decimal getCompletedScore(){
            Decimal newScore =  this.score != 0 ? (this.score / (this.totalFields + this.totalRelatedObjects))*100 : 0;
            newScore = newScore.setScale(2);
            return newScore;
        }
        
        Void setTotalFields(Decimal totalFields) {
            this.totalFields = totalFields;
        }
        
        String getIncompleteSections() {
            return this.incompleteSections;
        }
        
        String getMissingRelatedRecords() {
            return this.missingRelatedRecords;
        }
        String getMissingFields() {
            return this.missingFields;
        }      
    }

    private class MyException extends Exception{}
}