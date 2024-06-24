/**
 * 2017-10-31
 * Rudolf Niehaus - CloudSmiths
**/
public class invCaseSplitExt {
    
    @AuraEnabled
    public static Case getCase1() {
        Case c1 = new Case();
        c1.Status = 'New';
        return c1;
    }
    
    @AuraEnabled
    public static Case saveCase(Case c, String parentCase) {
        
        //map<String, Schema.RecordTypeInfo> caseRecordTypeMap = Case.sObjectType.getDescribe().getRecordTypeInfosByName();
        
        if(String.isNotBlank(c.Subject)){
            
            Case pc = [Select AccountId, ContactId, RecordTypeId From Case Where Id = :parentCase];
            
            c.ParentId = parentCase;
            //c.RecordTypeId = caseRecordTypeMap.get('TPS Client Child Case').getRecordTypeId();
            c.RecordTypeId = pc.RecordTypeId;
            c.AccountId = pc.AccountId;
            c.ContactId = pc.ContactId;
            
            upsert c;
        
        }
       
        return c;
    }
    
    @AuraEnabled
    public static Boolean getRenderIF(String parentCase) {
        
        Case pc = [Select ParentId From Case Where Id = :parentCase];
        
        if(String.isBlank(pc.ParentId)){
            return false;
        }else{
            return true;
        }
    }
}