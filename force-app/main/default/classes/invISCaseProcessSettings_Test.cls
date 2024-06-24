/**
 * 2017-11-21
 * Rudolf Niehaus - CloudSmiths
**/
@SuppressWarnings('PMD.ClassNamingConventions')
@isTest
public class invISCaseProcessSettings_Test {
    
    @IsTest
    static void testCaseProcessSettings() {
        map<String, Schema.RecordTypeInfo > mapCaseRecordTypes = Case.sObjectType.getDescribe().getRecordTypeInfosByName();
        Case c = new Case();
        c.Status = 'New';
        c.Subject = 'TEST A';
        c.RecordTypeId = mapCaseRecordTypes.get('TPS Client Case').getRecordTypeId();
        insert c;
        
        Test.startTest();
        try {
            invISCaseProcessSettings inv = new invISCaseProcessSettings();
            String theId = inv.getEntitlementId(c.RecordTypeId, 'Report', 'Cash Forecas');
        }
        catch (Exception ex) {
            System.assert(false, ex.getMessage());
        }
        Test.stopTest();
    }
    
}