public without sharing class UTL_RecordType {
    
    private static Map<String, Id> devName2Id {
        get {
            if (devName2Id == null) {
                devName2Id = new Map<String, Id>();
            }
            return devName2Id;
        }
        set;
    }
    private static Map<Id, String> id2DevName {
        get {
            if (id2DevName == null) {
                id2DevName = new Map<Id, String>();
            }
            return id2DevName;
        }
        set;
    }
    private static Map<Id, String> id2Label {
        get {
            if (id2Label == null) {
                id2Label = new Map<Id, String>();
            }
            return id2Label;
        }
        set;
    }
    private static Set<String> cachedObjects {
        get {
            if (cachedObjects == null) {
                cachedObjects = new Set<String>();
            }
            return cachedObjects;
        }
        set;
    }
    
    public static String getRecordTypeId(String objectName, String recordTypeDevName) {

        collectRecordTypes(objectName);

        if (!devName2Id.containsKey(objectName + '.' + recordTypeDevName)) {
            throw new UTL_RecordTypeException('There is no record type on object: ' + objectName + ' with name: ' + recordTypeDevName);
        }
        return devName2Id.get(objectName + '.' + recordTypeDevName);
    }
    
    public static String getRecordTypeName(String objectName, String recordTypeId) {
        collectRecordTypes(objectName);
        
        if (!id2DevName.containsKey(recordTypeId)) {
            throw new UTL_RecordTypeException('There is no record type with Id: ' + recordTypeId);
        }
        
        return id2DevName.get(recordTypeId);
    }
    
    public static String getRecordTypeLabel(String objectName, String recordTypeDevName) {
        collectRecordTypes(objectName);
        
        if (!id2Label.containsKey(objectName + '.' + recordTypeDevName)) {
            throw new UTL_RecordTypeException('There is no record type on object: ' + objectName + ' with name: ' + recordTypeDevName);
        }
        
        return id2Label.get(objectName + '.' + recordTypeDevName);
    }
    
    private static void collectRecordTypes(String keyString) {
        
        if (cachedObjects.contains(keyString) || (keyString instanceOf Id && id2DevName.containsKey(keyString))) {
            return;
        }

        if (keyString != null) {
            cacheRts(UTL_Schema.getSobjectType(keyString));
        }
        else {
            SObjectType[] sTypes = Schema.getGlobalDescribe().values();
            for (Integer i = 0, j = sTypes.size(); i < j; i++) {
                cacheRts(sTypes[i]);
                if (id2DevName.containsKey(keyString)) {
                    break;
                }
            }
        }
    }
    
    private static void cacheRts(SObjectType sType) {
        
        String sObjType = sType.getDescribe().getName();
        
        if (cachedObjects.contains(sObjType)) {
            return;
        }
        
        Schema.RecordTypeInfo[] rtInfos = sType.getDescribe().getRecordTypeInfos();
        for (Integer i = 0, j = rtInfos.size(); i < j; i++) {
            Schema.RecordTypeInfo rti = rtInfos[i];
            String rtId = rti.getRecordTypeId() ;
            String rtDevName = rti.getDeveloperName();
            
            id2DevName.put(rtId, rtDevName);
            devName2Id.put(sObjType + '.' + rtDevName, rtId);
            id2Label.put(rtId, rti.getName());
        }
        cachedObjects.add(sObjType);
    }
    
    public class UTL_RecordTypeException extends Exception {
    }
}