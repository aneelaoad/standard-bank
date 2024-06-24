/**
 * @description Domain class for CMN_Account_Contact_Relationship_Detail__c SObject
 * @author		Emmanuel Mulea(Nocks)
 * @date		March 2022
 */
public inherited sharing class DMN_CMN_AccountContactRelationshipDetail {
    
    private static Map<String,List<CMN_Account_Contact_Relationship_Detail__c>> custRelationsMap;
    private static List<AccountContactRelation> toInsertList;
    private static Map<String,SObject> relationsMap;
    private static Map<String,List<CMN_Account_Contact_Relationship_Detail__c>> newRecordsValidate;
    private static Map<String,List<CMN_Account_Contact_Relationship_Detail__c>> existingRecordsValidate;
    private static Set<Id> clientIds;
    private static Set<Id> contactIds;
    private static final String ERROR_MSG_SAME_ROLE = 'Same role of same contact already exist.';
    private static final String ERROR_MSG = 'An error has ocured,please contact system administrator.';
    private static final String ERROR_MSG_REASSIGN = 'Cannot reassign contacts or accounts.';
    public static final String ACTIVE_STATUS = 'Active';
    public static final String EXPIRED_STATUS = 'Expired';
    public class DMN_CMN_AccountContactRelationshipDetailException extends Exception{}
    /**
     * @description transform list of sobject records into a set of specified field name
     * @param records list of SObject
     * @param field string 
     * @return Set<Id>
     */    
    public static Set<Id> getSetofFieldValue(List<SObject> records,String field){
        Set<Id> listValue = new Set<Id>();
        for(SObject obj: records){
            if(String.isNotBlank((String)obj.get(field))){
                listValue.add((String)obj.get(field));
            }
        }
        return listValue;   
    }
    /**
     * @description transform list of sobject records into a list of specified field name
     * @param records list of SObject
     * @param field string 
     * @return List<Id>
     */    
    public static List<String> getListofFieldValue(List<SObject> records,String field){
        List<String> listValue = new List<String>();
        for(SObject obj: records){
            if(String.isNotBlank((String)obj.get(field))){
                listValue.add((String)obj.get(field));
            }
        }
        return listValue;   
    } 
    /**
     * @description map List of SObject into a composite key accountfield and contactfield
     * @param records list of SObject
     * @param accountField string 
     * @param contactField string 
     * @return Map<String,SObject>
     */       
    public static Map<String,SObject> getMapCompositeKey(List<SObject> records,String accountField,String contactField){
        Map<String,SObject> mappedData = new Map<String,SObject>();
        for(SObject stdCont:records){
            String compositekey = String.valueOf((String)stdCont.get(accountField))+String.valueOf((String)stdCont.get(contactField));
            mappedData.put(compositekey, stdCont);
        }
        
        return mappedData;  
    }
    /**
     * @description This methyod get executed after delete trigger to remove corresponding role in standard ACR 
     * @param records list of SObject 
     */    
    public static void deleteAccountContactRelationship(List<CMN_Account_Contact_Relationship_Detail__c> records){
        
        List<AccountContactRelation> stdAccountContRelationToUpdated = new List<AccountContactRelation>();
        Map<String,SObject> mapStdAcr = new Map<String,SObject>();
        contactIds = new Set<Id>(); 
        String roleString;
        try{
            contactIds = getSetofFieldValue((List<SObject>)records,'Contact__c');
            List<AccountContactRelation> stdAccountContRelation = SEL_AccountContactRelation.newInstance().selectByContactId(contactIds);       
            mapStdAcr = getMapCompositeKey((List<SObject>)stdAccountContRelation,'AccountId','ContactId');
            
            for(CMN_Account_Contact_Relationship_Detail__c contAccountRelation: records){
                String compositekey = String.valueOf(contAccountRelation.Client__c)+String.valueOf(contAccountRelation.Contact__c);
                AccountContactRelation toUpdate = (AccountContactRelation)mapStdAcr.get(compositekey);
                if(toUpdate!=null){
                    toUpdate.Roles = removeRole(toUpdate.Roles,contAccountRelation.Role__c);               
                    stdAccountContRelationToUpdated.add(toUpdate);   
                } 
            }
            
            if(!stdAccountContRelationToUpdated.isEmpty()){
                fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
                uow.registerDirty(stdAccountContRelationToUpdated);
                uow.commitWork();
            }
        }
        catch(Exception ex){
            
            SRV_Logger.newInstance().log(ex, DMN_Log.AREA_RELATEDPARTY, DMN_CMN_AccountContactRelationshipDetail.class.getName());
            throw new DMN_CMN_AccountContactRelationshipDetailException(ERROR_MSG);
        }
    }
   /**
    * @description detects field records changes
    * @param records list of SObject
    * @param field Schema.SObjectField  
    * @return Boolean
    */
    public static Boolean isChanged(SObject record,Schema.SObjectField field){
        return record.get(field)!=Trigger.oldMap.get(record.Id).get(field);    
    }
   
   /**
    * @description updates existing corresponding records standard/custom ACR
    * @param newRecords list of CMN_Account_Contact_Relationship_Detail__c
    * @param oldMap Map of CMN_Account_Contact_Relationship_Detail__c
    */
    public static void updateAccountContactRelationship(List<CMN_Account_Contact_Relationship_Detail__c> newRecords,Map<Id,CMN_Account_Contact_Relationship_Detail__c> oldMap){
        
        List<AccountContactRelation> stdAccountContRelationListToUpdate = new List<AccountContactRelation>();
        Map<String,SObject> mapStdAcr = new Map<String,SObject>();
        String roleString;
        contactIds = new Set<Id>();
        existingRecordsValidate = new  Map<String,List<CMN_Account_Contact_Relationship_Detail__c>>();
        try{
            
            contactIds = getSetofFieldValue((List<SObject>)newRecords,'Contact__c');
            List<AccountContactRelation> stdAccountContRelation = SEL_AccountContactRelation.newInstance().selectByContactId(contactIds);
            
            mapStdAcr = getMapCompositeKey((List<SObject>)stdAccountContRelation,'AccountId','ContactId');
            for(CMN_Account_Contact_Relationship_Detail__c contAccountRelation: newRecords){
                CMN_Account_Contact_Relationship_Detail__c oldRecord  = oldMap.get(contAccountRelation.Id);
                String compositekey = String.valueOf(oldRecord.Client__c)+String.valueOf(oldRecord.Contact__c);
                AccountContactRelation toUpdate = (AccountContactRelation)mapStdAcr.get(compositekey);
                
                if(isChanged(contAccountRelation,Schema.CMN_Account_Contact_Relationship_Detail__c.Client__c) || 
                  isChanged(contAccountRelation,Schema.CMN_Account_Contact_Relationship_Detail__c.Contact__c)){
                   contAccountRelation.addError(ERROR_MSG_REASSIGN);
                   continue;
                }
                if(existingRecordsValidate.get(compositekey)==null){
                    existingRecordsValidate.put(compositekey,new List<CMN_Account_Contact_Relationship_Detail__c>{contAccountRelation});
                }
                else{
                    existingRecordsValidate.put(compositekey,(List<CMN_Account_Contact_Relationship_Detail__c>)existingRecordsValidate.get(compositekey).add(contAccountRelation));
        
                }
                
                if(isChanged(contAccountRelation,Schema.CMN_Account_Contact_Relationship_Detail__c.Role__c) && toUpdate!=null){
                    roleString = removeRole(toUpdate.Roles,oldRecord.Role__c);
                    roleString = String.isBlank(contAccountRelation.Role__c) ? roleString : roleString+';'+contAccountRelation.Role__c; 
                    toUpdate.Roles = roleString;
                } 
                if(isChanged(contAccountRelation,Schema.CMN_Account_Contact_Relationship_Detail__c.Status__c) &&
                    contAccountRelation.Status__c==EXPIRED_STATUS && toUpdate!=null){
                    roleString = removeRole(toUpdate.Roles,contAccountRelation.Role__c);
                    toUpdate.Roles = roleString;
                }                
           
                
            }
           stdAccountContRelationListToUpdate.addAll((List<AccountContactRelation>)mapStdAcr.values());
            if(!stdAccountContRelationListToUpdate.isEmpty()){
                Database.SaveResult[] results = Database.update(stdAccountContRelationListToUpdate, false);
                for (integer i = 0; i < results.size(); i++) {
                    Database.SaveResult sr = results[i]; 
                    if (!sr.isSuccess()) {
                        String uniqueId = String.valueOf(stdAccountContRelationListToUpdate[i].AccountId)+String.valueOf(stdAccountContRelationListToUpdate[i].ContactId);
                        List<CMN_Account_Contact_Relationship_Detail__c> recordsToChek = existingRecordsValidate.get(uniqueId);
                        String errorMessage = 'Unknown error';
                        if (!sr.getErrors().isEmpty()) {
                            errorMessage = sr.getErrors()[0].getMessage();
                        }
                        for(CMN_Account_Contact_Relationship_Detail__c errorRecords: recordsToChek){
                            errorRecords.addError(errorMessage);
                        }
                        SRV_Logger.newInstance().log(errorMessage, DMN_Log.AREA_RELATEDPARTY, DMN_CMN_AccountContactRelationshipDetail.class.getName());
                    }
                }
            }
        }
        catch(Exception ex){
            
            SRV_Logger.newInstance().log(ex, DMN_Log.AREA_RELATEDPARTY, DMN_CMN_AccountContactRelationshipDetail.class.getName());
            throw new DMN_CMN_AccountContactRelationshipDetailException(ex.getMessage() +'  '+ex.getStackTraceString());
        }
    }
    /**
     * @description remove specific string from a multiPickList
     * @param multiPickList string 
     * @param removedValue string 
     * @return String
     */     
    public static String removeRole(String multiPickList,String removedValue){
        
        List<String> stringList;
        Integer index; 
        stringList = multiPickList?.split(';');
        index 	 = stringList?.indexOf(removedValue);
        stringList = stringList!=null?stringList:new List<String>();
        stringList = removeAtIndex(index,stringList);
        
        return String.join(stringList,';');
    }
    /**
     * @description remove an element at specified index
     * @param index Integer 
     * @param dataList list of string 
     * @return List<String>
     */     
    private static List<String> removeAtIndex(Integer index,List<String> dataList){
        
        if(index>=0){
            dataList.remove(index);   
        }
        
        return dataList;
    }
    /**
     * @description create records standard ACR with corresponding info based on CMN_Account_Contact_Relationship_Detail__c
     * @param newRecords list of CMN_Account_Contact_Relationship_Detail__c
     * @param oldRecords list of CMN_Account_Contact_Relationship_Detail__c
     */     
    public static void createAccountContactRelationship(List<CMN_Account_Contact_Relationship_Detail__c> newRecords,List<CMN_Account_Contact_Relationship_Detail__c> oldRecords){
        
        relationsMap = new Map<String,SObject>();
        toInsertList = new List<AccountContactRelation>();
        newRecordsValidate = new  Map<String,List<CMN_Account_Contact_Relationship_Detail__c>>();
        contactIds = new Set<Id>();
        try{
            contactIds = getSetofFieldValue((List<SObject>)newRecords,'Contact__c');
            List<AccountContactRelation> stdAccountContRelation = SEL_AccountContactRelation.newInstance().selectByContactId(contactIds);           
            relationsMap = getMapCompositeKey((List<SObject>)stdAccountContRelation,'AccountId','ContactId');
            insertAccountContactRelation(newRecords);
             
        }
        catch(Exception ex){
            
            SRV_Logger.newInstance().log(ex, DMN_Log.AREA_RELATEDPARTY, DMN_CMN_AccountContactRelationshipDetail.class.getName());
            throw new DMN_CMN_AccountContactRelationshipDetailException(ERROR_MSG);
        }
        
    }
    /**
     * @description insert records standard ACR with corresponding info based on CMN_Account_Contact_Relationship_Detail__c
     * @param newRecords list of CMN_Account_Contact_Relationship_Detail__c
     */     
    private static void insertAccountContactRelation(List<CMN_Account_Contact_Relationship_Detail__c> newRecords){
        
        

        for(CMN_Account_Contact_Relationship_Detail__c contAccountRelation: newRecords){
                     
            String idCombination = String.valueOf(contAccountRelation.Client__c) + String.valueOf(contAccountRelation.Contact__c);
            contAccountRelation.Status__c = ACTIVE_STATUS;
            String uniqueId = String.valueOf(contAccountRelation.Client__c)+String.valueOf(contAccountRelation.Contact__c);
            if(relationsMap.get(idCombination) == null){
                
                AccountContactRelation toInsert = new AccountContactRelation();
                toInsert.AccountId = contAccountRelation.Client__c;
                toInsert.ContactId = contAccountRelation.Contact__c;
                toInsert.Roles = contAccountRelation.Role__c;
                relationsMap.put(idCombination, (SObject)toInsert);
                if(newRecordsValidate.get(uniqueId)==null){
                    newRecordsValidate.put(uniqueId,new List<CMN_Account_Contact_Relationship_Detail__c>{contAccountRelation});
                }
                else{
                    newRecordsValidate.put(uniqueId,(List<CMN_Account_Contact_Relationship_Detail__c>)newRecordsValidate.get(uniqueId).add(contAccountRelation));
        
                }
            }
            else{
                
                AccountContactRelation toInsertArc = (AccountContactRelation)relationsMap.get(idCombination);
                if(!String.isBlank(toInsertArc.Roles) && String.isNotBlank(contAccountRelation.Role__c) &&!toInsertArc.Roles.contains(contAccountRelation.Role__c)){
                    
                    toInsertArc.Roles = String.isBlank(toInsertArc.Roles)?contAccountRelation.Role__c:toInsertArc.Roles +';'+contAccountRelation.Role__c;
                    
                }
                else if(String.isBlank(toInsertArc.Roles) && String.isNotBlank(contAccountRelation.Role__c)){
                    
                    toInsertArc.Roles = contAccountRelation.Role__c;
                    
                }
                relationsMap.put(idCombination, toInsertArc);
                
            }
            
        }
        toInsertList.addAll((List<AccountContactRelation>)relationsMap.values());
        if(!toInsertList.isEmpty()){  

            Database.UpsertResult[] results = Database.upsert(toInsertList, false);
            for (integer i = 0; i < results.size(); i++) {
                Database.UpsertResult sr = results[i]; 
                String uniqueId = String.valueOf(toInsertList[i].AccountId)+String.valueOf(toInsertList[i].ContactId);
                List<CMN_Account_Contact_Relationship_Detail__c> recordsToChek = newRecordsValidate.get(uniqueId);
                if (!sr.isSuccess()) {
                    String errorMessage = 'Unknown error';
                    if (!sr.getErrors().isEmpty()) {
                        errorMessage = sr.getErrors()[0].getMessage();
                    }
                    for(CMN_Account_Contact_Relationship_Detail__c errorRecords: recordsToChek){
                        errorRecords.addError(errorMessage);
                    }
                    SRV_Logger.newInstance().log(errorMessage, DMN_Log.AREA_RELATEDPARTY, DMN_CMN_AccountContactRelationshipDetail.class.getName());
                }
            }
        }
        
    }
}