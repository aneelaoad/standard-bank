/**
* Test class for OSB_SRB_EncryptionHelper
* <br/>SGRPT-4350
*
* @author Denys Yelchaninov (dyelchaninov@deloittece.com)
* @date March 2021
*/
@isTest
public class OSB_SRV_EncryptionHelper_TEST {
    
    @isTest
    public static void testEncryptionWithKey(){
        String keyCode = 'TEST_KEY';
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[]{OSB_EncryptionKeys__c.SObjectType});
        OSB_EncryptionKeys__c keyEntry = new OSB_EncryptionKeys__c(
            Name = keyCode,
            Value__c = 'z81CCBXananpMkDadZxsiA=='
        );
        uow.registerNew(keyEntry);
        uow.commitWork();

        Test.startTest();
        String encryptedStr = OSB_SRV_EncryptionHelper.encryptString('testStr', keyCode);
        String decryptedStr = OSB_SRV_EncryptionHelper.decryptString(encryptedStr, keyCode);
        Test.stopTest();
        System.assertEquals('testStr', decryptedStr);
    }

    @isTest
    public static void checkSettingInsert(){
        Test.startTest();
        String testKey = EncodingUtil.base64Encode(OSB_SRV_EncryptionHelper.getKey('TEST_KEY'));
        Test.stopTest();
        System.assertEquals(OSB_EncryptionKeys__c.getValues('TEST_KEY').Value__c, testKey);
    }
}