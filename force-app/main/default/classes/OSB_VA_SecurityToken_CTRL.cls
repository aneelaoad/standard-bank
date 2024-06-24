/**
 *
 * Controller class with logic invoked from the OneHub chat bot
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date February 2021
 */
public with sharing class OSB_VA_SecurityToken_CTRL {

    /**
     * Invocable method, bulkified version of generateBotUserToken
     *
     * @param keysToSign list of strings to sign
     *
     * @return list of string, signed tokens
     */
    @InvocableMethod(label='Generate Bot User Token')
    public static List<String> generateBotUserTokens(List<String> keysToSign) {
        List<String> result = new List<String>();
        for (String keyToSign : keysToSign) {
            result.add(OSB_SRV_BotPaymentTrackingHandler.generateBotUserToken(keyToSign));
        }
        return result;
    }
}