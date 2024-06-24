/*************************************************************************
    @ Author        : psvestka
    @ Date          : Sep 2, 2016
    @ TestClass     : StdBank_Ltn_RecordTypeHelperTest
    @ Description   : US-1500
****************************************************************************/
public class StdBank_Ltn_RecordTypeHelper {
	
    @AuraEnabled
    public static String getRecordTypeIdByLabel(String objectName, String recordTypeLabel) {
        system.assert(!String.isEmpty(objectName));
        system.assert(!String.isEmpty(recordTypeLabel));
		
        String rtId = '';
        
        Schema.SObjectType sot = Schema.getGlobalDescribe().get(objectName);
        if (sot == null) {
            return rtId;
        }
        
        Schema.RecordTypeInfo rti = sot.getDescribe().getRecordTypeInfosByName().get(recordTypeLabel);
        if (rti == null) {
            return rtId;
        }
        
        return rti.getRecordTypeId();
    }
}