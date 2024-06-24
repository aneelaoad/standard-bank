/**
 * @description MallContentRecordFormController
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallContentRecordFormController {

    /**
     * @description getRecordTypeName
     * @param objectAPIName String
     * @param recordTypeId String
     * @return String 
     */
    @AuraEnabled
    public static String getRecordTypeName(String objectAPIName,String recordTypeId){
        return Schema.getGlobalDescribe().get(objectAPIName).getDescribe().getRecordTypeInfosById().get(recordTypeId).getName();
    }
}