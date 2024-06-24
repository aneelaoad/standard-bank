/*************************************************************************
    @ Author        : psvestka, adapted from best practices
    @ Date          : 12. 8. 2015
    @ Test File     : GlobalCache
    @ Description   : A global utility class for caching data
****************************************************************************/
public with sharing class GlobalCache {

    //maps to hold the record type info
    private static Map<String, Schema.SObjectType> gd;
    private static Map<String, Map<Id, Schema.RecordTypeInfo>> recordTypesById = new Map<String, Map<Id, Schema.RecordTypeInfo>>();
    private static Map<String, Map<String, Schema.RecordTypeInfo>> recordTypesByName = new Map<String, Map<String, Schema.RecordTypeInfo>>();
    private static Map<String, String> profileMap = new Map<String, String>();
    private static Map<String, Id> profileIdMap = new Map<String, Id>();

    /**
    * Function to fill record type map for objects not in cache
    *
    * @param objectName The name of the sObject
    */
    private static void fillMapsForRecordTypeObject(string objectName) {
        if (gd == null) {
            gd = Schema.getGlobalDescribe();
        }
        if (gd.containsKey(objectName)) {
            Schema.DescribeSObjectResult d = gd.get(objectName).getDescribe();

            recordTypesByName.put(objectName, d.getRecordTypeInfosByName());
            recordTypesById.put(objectName, d.getRecordTypeInfosById());
        }
    }

    /**
     * Gives record type id from a given sObject and record type label
     *
     * @param objectName The sObject (label)
     * @param recordTypeName The name of the record type (NOT the API Name)
     * @return <ul>
                    <li>The specified record types id value</li>
                    <li>null if not found</li>
               </ul>
     */
    public static Id getRecordTypeId(String objectName, String recordTypeName) {
        if (!recordTypesByName.containsKey(objectName)) {
            fillMapsForRecordTypeObject(objectName);
        }

        Map<String, Schema.RecordTypeInfo> rtMap = recordTypesByName.get(objectName);
        if (rtMap != null && rtMap.containsKey(recordTypeName)) {
            return rtMap.get(recordTypeName).getRecordTypeId();
        } else {
            return null;
        }
    }

    /**
     * Gives record type name from a given sObject and record type id
     *
     * @param  objectName The sObject (label)
     * @param recordTypeId The id of the record type
     * @return <ul>
                    <li>The specified record types name value (the label NOT the API name)</li>
                    <li>null if not found</li>
               </ul>
     */
    public static String getRecordTypeName(String objectName, Id recordTypeId) {
        if (!recordTypesById.containsKey(objectName)) {
            fillMapsForRecordTypeObject(objectName);
        }

        Map<Id, Schema.RecordTypeInfo> rtMap = recordTypesById.get(objectName);
        if (rtMap != null && rtMap.containsKey(recordTypeId)) {
            return rtMap.get(recordTypeId).getName();
        } else {
            return null;
        }
    }

    /**
     * Get the profileName for the userProfileId
     *
     * @param userProfileId the profile id
     * @return the name of the profile
     */
    public static String getProfileName(String userProfileId) {
        if (!profileMap.containsKey(userProfileId)) {
            Profile p = [SELECT Id, Name FROM Profile WHERE Id = :userProfileId];
            profileMap.put(userProfileId, p.Name);
            profileIdMap.put(p.Name, p.Id);
        }
        return profileMap.get(userProfileId);
    }

    /**
     * Get the userProfileId for the userProfileName
     *
     * @param userProfileName the profile name
     * @return the id of the profileName
     */
    public static String getProfileId(String userProfileName) {
        if (!profileIdMap.containsKey(userProfileName)) {
            Profile p = [SELECT Id, Name FROM Profile WHERE Name = :userProfileName];
            profileIdMap.put(userProfileName, p.Id);
            profileMap.put(p.Id, p.Name);
        }
        return profileIdMap.get(userProfileName);
    }
}