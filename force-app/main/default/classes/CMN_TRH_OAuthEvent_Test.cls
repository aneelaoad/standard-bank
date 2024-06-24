@IsTest
public class CMN_TRH_OAuthEvent_Test {
    @IsTest
	public static void afterInsertTest()
	{
		CMN_OAuthEvent__e event = new CMN_OAuthEvent__e();
        event.CMN_EventType__c = 'CodeVerifierInsert';
        event.CMN_CodeVerifier__c = 'codeVerifier';
        event.CMN_CodeVerifierKey__c = 'codeVerifierKey';
		System.debug('CMN_SRV_OAuth**publishCodeVerifierInsert**event: ' + event);
        CMN_SRV_OAuth.publishOAuthEvent(event);
	}
}