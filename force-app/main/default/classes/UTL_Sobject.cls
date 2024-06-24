/**
 * Created by akepczynski on 01.03.2018.
 */

public without sharing class UTL_Sobject {

    /**
     * Populates field with specified value on specified SObject and its field
     *
     * @param sObj Type: SObject
     * @param fieldName Type: String
     * @param value type: String
     */
    public static void populateValue(SObject sObj, String fieldName, String value) {
        if (!UTL_Schema.hasField(sObj.getSObjectType(), fieldName)) {
            throw new UTL_SObjectException('No field ' + fieldName + ' on Sobject ' + sObj.getSObjectType().getDescribe().getName());
        }

        Object val = convert(value, UTL_Schema.getField(sObj.getSObjectType(), fieldName));

        sObj.put(fieldName, val);
    }

    /**
     * Returns converted value from specified String, to type of specified field
     *
     * @param value Type: String
     * @param sobjField Type: SObjectField
     *
     * @return Type: Object
     */
    public static Object convert(String value, SObjectField sobjField) {

        if (sobjField.getDescribe().type == Schema.DisplayType.BOOLEAN) {
            return Boolean.valueOf(value);
        } else if (sobjField.getDescribe().type == Schema.DisplayType.DATE) {
            return Date.valueOf(value);
        } else if (sobjField.getDescribe().type == Schema.DisplayType.DATETIME) {
            return Datetime.valueOf(value);
        } else if (sobjField.getDescribe().type == Schema.DisplayType.INTEGER) {
            return Integer.valueOf(value);
        } else if (sobjField.getDescribe().type == Schema.DisplayType.CURRENCY) {
            return Decimal.valueOf(value);
        } else if (sobjField.getDescribe().type == Schema.DisplayType.DOUBLE) {
            return Double.valueOf(value);
        }
        return value;
    }

    /**
     * Returns field value from specified SObject and field path
     *
     * @param sObj Type: SObject
     * @param fieldPath Type: String
     *
     * @return Type: Object
     */
    public static Object readValue(Sobject sObj, String fieldPath) {
        List<String> stepList = fieldPath.split('\\.');
        Integer stepListSize = stepList.size();
        Object fieldValue;

        if (UTL_Schema.isProperPath(sObj.getSObjectType(), fieldPath)) {
            for (Integer i = 0; i < stepListSize; ++i) {
                if (sObj == null) {
                break;
            }
                if (i == stepListSize - 1) {
                fieldValue = sObj.get(stepList[i]);
            } else {
                sObj = sObj.getSObject(stepList[i]);
            }
            }
        }
        return fieldValue;
    }
    
    public static Boolean isEqual(Sobject record, String fieldName, String value ) {
        SObjectField sobjField = UTL_Schema.getField(record.getSObjectType(), fieldName);
        return isEqual(record, sobjField, value );
    }
    
    /**
     * Check if Sobject field has expected value
     *
     * @param record Type: SObject
     * @param sobjField Type: SObjectField
     * @param value Type: String
     *
     * @return Type: Boolean 
     */
    public static Boolean isEqual(Sobject record, SObjectField sobjField, String value ){
        
        Object fieldValue = record.get(sobjField);
        Object convertedValue = convert(value, sobjField);
        
        return fieldValue == convertedValue;
    }
    
    public class UTL_SObjectException extends Exception {
    }
}