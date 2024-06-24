/**
 * 
 * @description Test Class for MallExceptionUtil
 * @author Ankit Kumar
 * @since 
 */
@IsTest
private with sharing class MallExceptionUtil_Test {
    @isTest
    private static void testAuraException() {
        try {
            Contact contact = new Contact();
            insert contact;
        } catch (Exception e ) {
            MallExceptionUtil.throwAuraException('Test Exception', e);
            Assert.isTrue(e != NULL, 'Exception should not be null');
        }
    }
}