/***************************************************************
@ Author     : Rudolf Niehaus - CloudSmiths
@ Date       : 2017-11-16
@ Description: Interface class to the Custom meta data type 
"IS Case Process Setting", to be used for IS
Cases to link the correct entitelment and other 
support process settings.
----------------------------------------------------------------
UPDATES:
----------------------------------------------------------------
@ Last Update: Date: Name - Desc
@ Last Update: Date: Name - Desc
----------------------------------------------------------------
***************************************************************/
public class invISCaseProcessSettings {
    
    private list<IS_Case_Process_Setting__mdt> mdtSettings = new list<IS_Case_Process_Setting__mdt>();
    private map<String, IS_Case_Process_Setting__mdt> mapCaseSettings = new map<String, IS_Case_Process_Setting__mdt>();
    private set<String> entNames = new set<String>();
    private map<String, Id> mapEntitelments = new map<String, Id>();
    private  Map<ID, Schema.RecordTypeInfo> caseRecordTypeMap = new Map<ID, Schema.RecordTypeInfo>();
    
    public invISCaseProcessSettings(){
        
        //built meta data map
        for(IS_Case_Process_Setting__mdt mdt :[Select DeveloperName, EntitlementName__c, CaseRecordType__c, CustodyCategory__c, CustodySubCategory__c 
                                               From IS_Case_Process_Setting__mdt 
                                               Where Active__c = true]){
            //built map                                      
           String key = mdt.CaseRecordType__c;
           if(String.isNotBlank(mdt.CustodyCategory__c) && String.isNotBlank(mdt.CustodySubCategory__c)){
               key = key + mdt.CustodyCategory__c + mdt.CustodySubCategory__c;                                        
           }else{
               if(mdt.DeveloperName == 'Default'){
                   key = 'Default';
               }
           }
           System.debug('Key=' + key + '-Value=' + mdt.DeveloperName);                                        
           mapCaseSettings.put(key, mdt);     
           entNames.add(mdt.EntitlementName__c);                   
       }
       
       //built entitelment map 
        for(Entitlement ent :[Select Id, Name From Entitlement Where Name IN :entNames]){
            mapEntitelments.put(ent.Name, ent.Id);
        }
        //built record type id/name map
        caseRecordTypeMap = Schema.SObjectType.Case.getRecordTypeInfosById();
    }
    
    private String getRecordTypeName(String recordTypeId){
        return caseRecordTypeMap.get(recordTypeId).getName();
    }
    
    public String getEntitlementId(String CaseRecordTypeId, String CustodyCategory, String CustodySubCategory){
        
        String CaseRecordTypeName = getRecordTypeName(CaseRecordTypeId);
      
        if(String.isNotBlank(CaseRecordTypeName) && String.isNotBlank(CustodyCategory) && String.isNotBlank(CustodySubCategory)){
            
            String key = CaseRecordTypeName + CustodyCategory + CustodySubCategory;
            
            if(mapCaseSettings.containsKey(key)){
                 mdtSettings.add(mapCaseSettings.get(key));
            }
        }else{
            //getting the default
            if(mapCaseSettings.containsKey('Default')){
                 System.debug(mapCaseSettings.get('Default')); 
               mdtSettings.add(mapCaseSettings.get('Default'));
            }
        }
        
        
        if((mdtSettings.size() > 0) && (mapEntitelments.size() > 0)){
            
            if(mapEntitelments.containsKey(mdtSettings[0].EntitlementName__c)){
                return mapEntitelments.get(mdtSettings[0].EntitlementName__c);
            }else{
                return ''; 
            }            
        }else{
            return '';
        }
    }
}