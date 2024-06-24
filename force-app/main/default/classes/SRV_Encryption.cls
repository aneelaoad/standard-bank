/**
 * @description       : SFP-19834 Service class for encryption and decryption
 * @author            : Peter Guest
 * @group             : CloudSmiths
 * @last modified on  : 08-01-2023
 * @last modified by  : Areeba Khan (areeba.khan@standardbank.co.za)

** SAMPLE CLASS USAGE **
String plainText = 'Plain Text Value';
System.debug('plainText: '+plainText);

SRV_Encryption encryptionService = (SRV_Encryption)SRV_Encryption.newInstance().initialise('Partner_Connect');
String encryptedValue = encryptionService.encryptWithManagedIV('Plain Text Value');
System.debug('encryptedValue: '+encryptedValue);

String decryptedValue = encryptionService.decryptWithManagedIV(encryptedValue);
System.debug('decryptedValue: '+decryptedValue);
*/
public with sharing class SRV_Encryption implements IService {
    private Encryption_Key_Setting__mdt setting;
    private String algorithmName;
    private Boolean isUrlSafe;

    /**
     * @description Service class for encryption and decryption
     * @author Peter Guest | 03-05-2023
     * @return IService
     */
    public static IService newInstance() {
        return (IService) ORG_Application.service.newInstance(IService.class);
    }

    /**
     * @description Service class for encryption and decryption
     * @author Peter Guest | 03-05-2023
     * @param settingName
     * @return interface
     */
    public interface IService {
        /**
         * @description Initialize encruption metadata
         * @param settingName
         * @author Peter Guest | 03-05-2023
         * @return IService
         */
        IService initialise(String settingName);

        /**
         * @description Set Algorithm
         * @param algorithmName
         * @author Peter Guest | 03-05-2023
         */
        void setAlgorithm(String algorithmName);

        /**
         * @description Encrypt data
         * @param valueToEncrypt
         * @return String
         * @author Peter Guest | 03-05-2023
         */
        String encryptWithManagedIV(String valueToEncrypt);

        /**
         * @description Decrypt data
         * @param valueToDecrypt
         * @return String
         * @author Peter Guest | 03-05-2023
         */
        String decryptWithManagedIV(String valueToDecrypt);
    }

    /**
     * @description Initialize encruption metadata
     * @param settingName
     * @author Peter Guest | 03-05-2023
     * @return IService
     */
    public IService initialise(String settingName) {
        this.setting = Encryption_Key_Setting__mdt.getInstance(settingName);
        this.algorithmName = 'AES192';
        this.isUrlSafe = true;
        return this;
    }

    /**
     * @description Set Algorithm
     * @param algorithmName
     * @author Peter Guest | 03-05-2023
     */
    public void setAlgorithm(String algorithmName) {
        this.algorithmName = algorithmName;
    }

    /**
     * @description Check if URL safe or not
     * @param isUrlSafe
     * @author Peter Guest | 03-05-2023
     */
    public void setIsUrlSafe(Boolean isUrlSafe) {
        this.isUrlSafe = isUrlSafe;
    }

    /**
     * @description Encrypt data
     * @param valueToEncrypt
     * @return String
     * @author Peter Guest | 03-05-2023
     */
    public String encryptWithManagedIV(String valueToEncrypt) {
        Blob privateKey = EncodingUtil.base64Decode(this.setting.Private_Key__c);
        Blob valueToEncryptBlob = Blob.valueOf(valueToEncrypt);
        Blob encryptedValueBlob = Crypto.encryptWithManagedIV(algorithmName, privateKey, valueToEncryptBlob);
        String encryptedValueString = EncodingUtil.base64Encode(encryptedValueBlob);

        return (isUrlSafe) ? toUrlSafe(encryptedValueString) : encryptedValueString;
    }

    /**
     * @description Decrypt data
     * @param valueToDecrypt
     * @return String
     * @author Peter Guest | 03-05-2023
     */
    public String decryptWithManagedIV(String valueToDecrypt) {
        Blob privateKey = EncodingUtil.base64Decode(this.setting.Private_Key__c);

        if (isUrlSafe) {
            valueToDecrypt = fromUrlSafe(valueToDecrypt);
        }

        Blob valueToDecryptBlob = EncodingUtil.base64Decode(valueToDecrypt);
        Blob decryptedValueBlob = Crypto.decryptWithManagedIV(algorithmName, privateKey, valueToDecryptBlob);
        String decryptedValueString = decryptedValueBlob.toString();

        return decryptedValueString;
    }

    /**
     * @description Update and replace characters from URL
     * @param inputValue
     * @return String
     * @author Peter Guest | 03-05-2023
     *
     */
    private String toUrlSafe(String inputValue) {
        inputValue = inputValue.replace('+', '-');
        inputValue = inputValue.replace('/', '_');
        return inputValue;
    }

    /**
     * @description Update and replace characters from URL
     * @param inputValue
     * @return String
     * @author Peter Guest | 03-05-2023
     *
     */
    private String fromUrlSafe(String inputValue) {
        inputValue = inputValue.replace('-', '+');
        inputValue = inputValue.replace('_', '/');
        return inputValue;
    }
}