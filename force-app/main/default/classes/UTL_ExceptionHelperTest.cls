@IsTest
public with sharing class UTL_ExceptionHelperTest {
    @IsTest
    public static void throwDMLExceptionFullMessage(){
        try{
            Account acc = new Account();
            insert acc;
        } catch (DmlException de) {
            String testException = UTL_ExceptionHelper.throwDMLException(de, false, 'insert', 'Account');
        }
    }
    @IsTest
    public static void throwDMLExceptionSmallMessage(){
        try{
            Account acc = new Account();
            insert acc;
        } catch (DmlException de) {
            String testException = UTL_ExceptionHelper.throwDMLException(de, false, null, null);
        }
    }
}