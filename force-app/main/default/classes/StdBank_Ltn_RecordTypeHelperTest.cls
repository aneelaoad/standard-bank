/*************************************************************************
    @ Author        : psvestka
    @ Date          : Sep 2, 2016
    @ Description   : US-1500
****************************************************************************/

@IsTest
public class StdBank_Ltn_RecordTypeHelperTest {
	
    private static final String EMPTY_STRING = '';
    
    @IsTest
    static void testProspect() {
        final Map<String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    	final Id prospectRecTypeId = mapAccountRecordTypes.get('Prospect').getRecordTypeId();
    	
        system.assertEquals(prospectRecTypeId, StdBank_Ltn_RecordTypeHelper.getRecordTypeIdByLabel('Account', 'Prospect'));
    }
    
    @IsTest
    static void testUnknownObject() {
        system.assertEquals(EMPTY_STRING, StdBank_Ltn_RecordTypeHelper.getRecordTypeIdByLabel('reghqworughoqw', 'doesn\'t matter'));
    }
    
    @IsTest
    static void testUnknownRtLabel() {
        system.assertEquals(EMPTY_STRING, StdBank_Ltn_RecordTypeHelper.getRecordTypeIdByLabel('Account', 'This Does Not Exist'));
    }
}