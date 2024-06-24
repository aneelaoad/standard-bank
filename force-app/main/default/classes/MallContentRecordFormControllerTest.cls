@isTest
public with sharing class MallContentRecordFormControllerTest {
    
    @IsTest
    static void testRecordType(){
        
        Id recTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business').getRecordTypeId();
        Test.startTest();
        String recTypeName = MallContentRecordFormController.getRecordTypeName('Account', recTypeId);
        Test.stopTest();
        Assert.areEqual(recTypeName, 'Business', 'Record Type should be Business');
    }
}