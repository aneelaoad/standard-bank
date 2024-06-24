/**
 * 
 * @description Test class for SEL_LiveChatTranscripts
 * @author Ankit Kumar
 * @since 
 */
@IsTest
public with sharing class SEL_LiveChatTranscripts_Test {
    /**
     * 
     * @description testLiveChatTranscriptsSelector
     */
    @isTest
    public static void testLiveChatTranscriptsSelector() {
        Test.startTest();
        List<LiveChatTranscript> transcripts = SEL_LiveChatTranscripts.newInstance().selectByChatKeys(new Set<String>{});
        Assert.areEqual(0, transcripts.size(),'0 transcripts created');
        Test.stopTest();
	}
}