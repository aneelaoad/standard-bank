/**
* Class that helps with encrypting and decrypting data
* <br/>SGPRT-4350
*
* @author Denys Yelchaninov (dyelchaninov@deloittece.com)
* @date March 2021
*/
public inherited sharing class OSB_SRV_EncryptionHelper {

    private static final string ENCR_ALGORITHM = 'AES128';
    private static final string OSB_MAIL_ENCRKEY = 'EMAIL_ENCR';

    /**
    * Generate new key and create custom setting entry with it's value if there is no key defined in org
    * <br/>SGPRT-4350
    * @param keyCode string that represents key literal
    * @return Blob blob value of newly generated encryption key
    */
    @TestVisible
    private static Blob getKey(String keyCode){

        Blob key = OSB_EncryptionKeys__c.getValues(keyCode) == null ? null : EncodingUtil.base64Decode(OSB_EncryptionKeys__c.getValues(keyCode).Value__c);
        if(key == null)
        {
            key = Crypto.generateAesKey(128);
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[]{OSB_EncryptionKeys__c.SObjectType});
            OSB_EncryptionKeys__c keyEntry = new OSB_EncryptionKeys__c(
                Name = keyCode,
                Value__c = EncodingUtil.base64Encode(key)
            );
            uow.registerNew(keyEntry);
            uow.commitWork();
        }

        return key;
    }

    /**
    * Encrypts string using specified key
    * <br/>SGPRT-4350
    *
    * @param source string that needs to be encrypted
    * @param keyCode string that represents key literal
    * @return String encrypted string
    */
    public static String encryptString(String source, String keyCode){
        Blob key = getKey(keyCode);
        Blob data = Blob.valueOf(source);
        Blob encrypted = Crypto.encryptWithManagedIV(ENCR_ALGORITHM, key, data);

        return EncodingUtil.base64Encode(encrypted);
    }
    
    /**
    * Decrypts string using specified key
    * <br/>SGPRT-4350
    *
    * @param encrypted64 encrypted string that needs to be decrypted
    * @param keyCode string that represents key literal
    * @return String decrypted string value
    */
    public static String decryptString(String encrypted64, String keyCode){
        Blob key = getKey(keyCode);
        Blob dest = EncodingUtil.base64Decode(encrypted64);
        Blob decrypted = Crypto.decryptWithManagedIv(ENCR_ALGORITHM, key, dest);

        return decrypted.toString();
    }

}