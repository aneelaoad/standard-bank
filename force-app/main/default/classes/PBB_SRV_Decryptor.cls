/**
 * Service class that decrypts string
 * US-SGPRT-1010
 *
 * Maria Pszonka (mpszonka@deloittece.com)
 * @date August 2020
 */
public with sharing class PBB_SRV_Decryptor {

    public class PBB_SRV_DecryptorException extends Exception {
    }

    /**
     * Service class that decrypts clients BPID provided by IBM Gateway GetCustomers API
     * The IBM Gateway uses authorization token to encrypt BPID field
     * Based on the business requirements:
     * key: token's substring from 50th to 82th character
     * vector: token's substring from 90th to 106th character
     * algorithm: AES256
     *
     * US-SGPRT-1010
     *
     * @param encryptedBPID value provided by IBM Gateway API in response header named "obscuredData"
     * @param token token used for authorization
     * @return decrypted client's BPID
     */
    public static String getBPID(String encryptedBPID, String token) {
        if (token.length() != 308) {
            throw new PBB_SRV_DecryptorException('Invalid token length');
        } 
        String key = token.substring(50, 82);
        String vector = token.substring(90, 106);
        Blob decrypted = Crypto.decrypt('AES256', Blob.valueOf(key), Blob.valueOf(vector), EncodingUtil.base64Decode(encryptedBPID));
        return decrypted.toString();
    }
}