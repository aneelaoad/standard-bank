/**
* ACTION   DATE        OWNER         COMMENT
* Created  20-01-2023  Dayakar Deekonda  Test class to test to get the System token in place of ping token for the guest users
* Updated  20-01-2023  Dayakar Deekonda		     
*/
@IsTest
public class AOB_API_SystemToken_Test extends CMN_API_HttpBaseOutboundMock{
    public static String accessToken = 'eyJhbGciOiJSUzI1NiIsImtpZCI6ImRpZC0yIiwicGkuYXRtIjoiOGlraSJ9.eyJzY3AiOlsib3BlbmlkIiwicHJvZmlsZSIsImVtYWlsIl0sImNsaWVudF9pZCI6ImZhYWQ5YWNjLTU4NGEtNDkzZC04YzhhLWQ0YjNkNjhmMjY5YyIsImlzcyI6Imh0dHBzOi8vZW50ZXJwcmlzZXN0c3NpdC5zdGFuZGFyZGJhbmsuY28uemEiLCJqdGkiOiJpNzhvU25ENlhZandSU2hHZ2pWSzU1Iiwic3ViIjoiZGF5YWthckAxMjMiLCJkaWdpbWUiOmZhbHNlLCJuYmYiOjE2Njg5NDY4MTEsImFtciI6InB3ZCIsImlkIjoiM2UzNzJjYjctYmVhNC00YzFiLWFkYjMtMTQ5ZmE3ZjY3ZGE0IiwiaWF0IjoxNjY4OTQ2ODExLCJleHAiOjE2Njg5NDcxMTF9.LrHYLaXf6Gi8eVLPA2AEhTWwrQm7DJ8o-PE7i6FQH9dgOUUPjGWUGZnYhruRkR9RzKJpu9K2D6fvLf854XIgFK6yDT6Cg8XBh_mJuwyPd5egUWt6jWM9bVDLQwsnJ8dmWDqTd0NvTvFZPS2yxT898Wd_7u0lctL5bDnZNcnWmmic_t5l-SsMC5g8-KqghyFpmfXPKw-qnuBlFlBScNgp66_dQpwFWa5JEoWm3xksQyd749Y3BzGQE0iq00chZUNWli1uLeHMxw9ZjVgdBTDT87CHE0CfbO-pf-RJWluFkQje3XWqyeZdcC6Joma3sALUZDbaA-gFs7-fxWyWGm97OA';
    /**
    * ACTION   DATE        OWNER         COMMENT
    * Created  20-01-2023  Dayakar Deekonda  Test class to test to get the System token in place of ping token for the guest users
    * Updated  20-01-2023  Dayakar Deekonda		     
    */
    @IsTest
    static  void testParse(){

            Test.setMock(HttpCalloutMock.class, new AOB_API_PreApplication.AOB_API_SystemTokenMock());             
            Test.startTest();
                String token = AOB_API_SystemToken.AOB_API_SystemToken();
                Assert.areEqual(accessToken, token);
            Test.stopTest();    

        
    }
}