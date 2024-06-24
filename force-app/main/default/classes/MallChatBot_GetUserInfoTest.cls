@IsTest
private class MallChatBot_GetUserInfoTest {
	
    @IsTest
    public static void getSnapInsPrechatDataTest(){
        User userRec = [Select Id, Name, Ping_BPGUID__c from USER WHERE ID =: UserInfo.getUserId() LIMIT 1];  
        User portalUser = MallTestDataFactory.createPortalUser(userRec);
        System.runAs(portalUser) {
            MallChatBot_GetUserInfo.PrechatInput  inputParameters = new   MallChatBot_GetUserInfo.PrechatInput();
            LiveChatVisitor lcv = new LiveChatVisitor();
            insert lcv;
         
            LiveChatTranscript transcript = new LiveChatTranscript();
            transcript.ContactId = portalUser.ContactId;
            transcript.LiveChatVisitorId = lcv.Id;
            transcript.Chatkey = CMN_DAL_SObjectDomain.generateRandomName();
            insert transcript;
            inputParameters.sChatkey = transcript.ChatKey;
            	
            List<MallChatBot_GetUserInfo.PrechatOutput> result =  MallChatBot_GetUserInfo.getSnapInsPrechatData(new List<MallChatBot_GetUserInfo.PrechatInput> {inputParameters});
  			Assert.areEqual(portalUser.FirstName, result[0].sFirstName, 'should be equal');
            try {
                result =  MallChatBot_GetUserInfo.getSnapInsPrechatData(NULL);
            } catch(Exception e) {
               Assert.isTrue(e != NULL, 'Exception should not be null');
            }
        }
    }
    
}