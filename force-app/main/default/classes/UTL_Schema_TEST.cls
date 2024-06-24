/**
 * Test class for UTL_Schema
 *
 * @author		Youssef Ibrahim (yibrahim@deloittece.com)
 * @date		JANUARY 2021
*/
@IsTest
private class UTL_Schema_TEST {

    private static final String ACCOUNT = 'Account';
    private static final String PROPER_PATH = 'Account.Name';
    private static final String WRONG_PATH = 'Accountaaa.Name';
    private static final String WRONG_PATH_FIELD = 'Account.ASdfas';
    private static final String WRONG = 'wrong';
    private static final String NAME = 'Name';
    private static final String CONTACTS = 'Contacts';
    private static final String CONTACT = 'Contact';
    private static final String LAST_MODIFIED_BY = 'LastModifiedById';


    @IsTest
    static void shouldReturnSObjectType(){
        Test.startTest();
        SObjectType sObjectType = UTL_Schema.getSobjectType(ACCOUNT);
        Test.stopTest();
        System.assertEquals(Schema.Account.SObjectType, sObjectType);
    }

    @IsTest
    static void shouldReturnFieldMap(){
        Map<String, SObjectField> fieldMap = new Map<String, SObjectField>();
        Test.startTest();
        fieldMap = UTL_Schema.getFields(Schema.Account.SObjectType);
        Test.stopTest();
        System.assert(!fieldMap.isEmpty());
    }

    @IsTest
    static void shouldReturnTrueHasField(){
        Boolean hasField;
        Test.startTest();
        hasField = UTL_Schema.hasField(Schema.Account.SObjectType, NAME);
        Test.stopTest();
        System.assertEquals(true, hasField);
    }

    @IsTest
    static void shouldReturnSObjectField(){
        SObjectField field;
        Test.startTest();
        field  = UTL_Schema.getField(Schema.Account.SObjectType, NAME);
        Test.stopTest();
        System.assertEquals(Schema.Account.SObjectType.getDescribe().fields.getMap().get(NAME), field);
    }

    @IsTest
    static void shouldReturnParentType(){
        SObjectType[] sObjectTypes;
        Test.startTest();
        sObjectTypes = UTL_Schema.getParentType(Schema.Account.SObjectType, LAST_MODIFIED_BY);
        Test.stopTest();
        System.assertEquals(Schema.User.SObjectType,sObjectTypes.get(0));
    }

    @IsTest
    static void shouldReturnChildRelationship(){
        ChildRelationship relationship;
        Test.startTest();
        relationship = UTL_Schema.getRelationshipByName(Schema.Account.SObjectType, CONTACTS);
        Test.stopTest();
        System.assertEquals(Schema.Contact.SObjectType, relationship.getChildSObject());
    }

    @IsTest
    static void shouldReturnNullChildRelationship(){
        ChildRelationship relationship;
        Test.startTest();
        relationship = UTL_Schema.getRelationshipByName(Schema.Account.SObjectType, WRONG);
        Test.stopTest();
        System.assertEquals(null, relationship);
    }

    @IsTest
    static void shouldThrowNoPickListValuesException(){
        Test.startTest();
        SelectOption[] options = UTL_Schema.fetchOptions(Schema.Account.SObjectType.getDescribe().fields.getMap().get(NAME));
        Test.stopTest();
        System.assert(options.isEmpty());
    }

    @IsTest
    static void shouldReturnTrueIfProperPath(){
        Test.startTest();
        Boolean result = UTL_Schema.isProperPath(Schema.Contact.SObjectType, PROPER_PATH);
        Test.stopTest();
        System.assertEquals(true, result);
    }

    @IsTest
    static void shouldReturnTrueIfProperPathFromStringType(){
        Test.startTest();
        Boolean result = UTL_Schema.isProperPath(CONTACT, PROPER_PATH);
        Test.stopTest();
        System.assertEquals(true, result);
    }

}