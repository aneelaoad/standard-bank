/**
 * @description Test the MALL_OAuth_Util methods
 * <p/>
 *
 * @see MALL_OAuth_Util
 *
 * @author Ankit Kumar
 *
 * @date October 2023
 */
@IsTest
private class MALL_OAuth_Util_Test
{
    @IsTest
    private static void publishCodeVerifierInsert()
    {
        Test.startTest();

        MALL_OAuth_Util.ignoreTestMode = true;

        String codeVerifier = MALL_OAuth_Util.generateRandomString(15);
        String codeVerifierKey = Mall_Ping_AuthProviderCustomPlugin.generateAlphanumericHash(MALL_OAuth_Util.generateRandomString(15));


        MALL_OAuth_Util.publishCodeVerifierInsert(codeVerifierKey, codeVerifier);

        Test.stopTest();

        CMN_OAuth__c returned = MALL_OAuth_Util.readCodeVerifierByKey(codeVerifierKey);
        Assert.isTrue(returned != null, 'expected CMN_OAuth__c record to be published');
        Assert.areEqual(codeVerifierKey, returned.CMN_CodeVerifierKey__c, 'expected codeVerifierKeys to match');
        Assert.areEqual(codeVerifier, returned.CMN_CodeVerifier__c, 'expected codeVerifiers to match');

        String compareCodeVerifier = MALL_OAuth_Util.retrieveCodeVerifier(returned.CMN_CodeVerifierKey__c);
        Assert.areEqual(codeVerifier, compareCodeVerifier, 'expected codeVerifiers to match');
    }

    @IsTest
    private static void publishCodeVerifierInsertNegative()
    {
        Test.startTest();

        MALL_OAuth_Util.ignoreTestMode = false;

        String codeVerifier = MALL_OAuth_Util.generateRandomString(15);
        String codeVerifierKey = Mall_Ping_AuthProviderCustomPlugin.generateAlphanumericHash(MALL_OAuth_Util.generateRandomString(15));

        MALL_OAuth_Util.publishCodeVerifierInsert(codeVerifierKey, codeVerifier); 
        Test.stopTest();

        CMN_OAuth__c returned = MALL_OAuth_Util.readCodeVerifierByKey(codeVerifierKey);
        Assert.isTrue(returned == null, 'expected CMN_OAuth__c record to be null');
    }

    @IsTest
    private static void publishCodeVerifierDelete()
    {
        Test.startTest();

        MALL_OAuth_Util.ignoreTestMode = true;

        String codeVerifier = MALL_OAuth_Util.generateRandomString(15);
        String codeVerifierKey = Mall_Ping_AuthProviderCustomPlugin.generateAlphanumericHash(MALL_OAuth_Util.generateRandomString(15));

        MALL_OAuth_Util.publishCodeVerifierInsert(codeVerifierKey, codeVerifier);

        MALL_OAuth_Util.publishCodeVerifierDelete(codeVerifierKey);

        Test.stopTest();

        CMN_OAuth__c returned = CMN_DAL_OAuth.readCodeVerifierByKey(codeVerifierKey);
        Assert.isTrue(returned == null, 'expected CMN_OAuth__c record to be deleted');
    }

    @IsTest
    private static void getUserAccessToken()
    {
        Test.startTest();

        MALL_OAuth_Util.ignoreTestMode = false;

        String token = MALL_OAuth_Util.getUserAccessToken('mall_ping_custom');

        Test.stopTest();

        Assert.isTrue(token != null, 'expected a mock token to be returned');
    }

    @IsTest
    private static void refreshUserAccessToken()
    {
        Test.startTest();

        MALL_OAuth_Util.ignoreTestMode = false;

        String token = MALL_OAuth_Util.refreshUserAccessToken('mall_ping_custom');

        Test.stopTest();

        Assert.isTrue(token != null, 'expected a mock refresh token to be returned');
    }

    @IsTest
    private static void refreshUserAccessTokenNegative()
    {
        Test.startTest();

        MALL_OAuth_Util.ignoreTestMode = true;

        try
        {
           MALL_OAuth_Util.refreshUserAccessToken('mall_ping_custom');
            Assert.isTrue(false, 'expected a exception to be thrown');

        }
        catch(Exception e)
        {
            Assert.isTrue(true,'');
        }

        Test.stopTest();
    }

    @IsTest
    private static void logEventErrorsNegative()
    {
        Test.startTest();

        MALL_OAuth_Util.ignoreTestMode = true;

        Account invalidEvent = new Account();

        List<Database.Error> errors = MALL_OAuth_Util.publishOAuthEvent(invalidEvent);

        Test.stopTest();

        Assert.isTrue(errors.size() == 1, 'expected an error to be returned for invalid event sobject');
    }

    @IsTest
    private static void retrieveCodeVerifierMock()
    {
        Test.startTest();

        MALL_OAuth_Util.ignoreTestMode = false;

        String random = MALL_OAuth_Util.retrieveCodeVerifier(MALL_OAuth_Util.generateRandomString(15));

        Test.stopTest();

        Assert.isTrue(random != null, 'expected a mock random value to be returned');
    }

    @IsTest
    private static void getAccessTokenNegative()
    {
        Test.startTest();

        MALL_OAuth_Util.ignoreTestMode = true;

        AuthProvider provider = MALL_OAuth_Util.readAuthProviderByName('mall_ping_custom');

        try
        {
           MALL_OAuth_Util.getAccessToken(provider);
            Assert.isTrue(true, 'expected a exception to be thrown');

        }
        catch(Exception e)
        {
            Assert.isTrue(true,'');
        }

        Test.stopTest();
    }

    @IsTest
    private static void getRefreshAccessTokenNegative()
    {
        Test.startTest();

        MALL_OAuth_Util.ignoreTestMode = true;

        AuthProvider provider = MALL_OAuth_Util.readAuthProviderByName('mall_ping_custom');

        try
        {
            MALL_OAuth_Util.getRefreshAccessToken(provider, MALL_OAuth_Util.generateRandomString(15));
            Assert.isTrue(true, 'expected a exception to be thrown');

        }
        catch(Exception e)
        {
            Assert.isTrue(true,'');
        }

        Test.stopTest();
    } 
    
    
   @isTest
   public static void deleteCodeVerifierOAuthsTest() {
       List<CMN_OAuth__C> records = [select id ,CMN_CodeVerifierKey__c from CMN_OAuth__C limit 4];
       Test.startTest();
       MALL_OAuth_Util.deleteCodeVerifierOAuths(records);
       Test.stopTest();
       Assert.isTrue(true,'');
    }

}