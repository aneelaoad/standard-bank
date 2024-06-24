/**
* @description Testing the MallDocumentResponse
* @see MallDocumentResponse
* @author Ankit Kumar
* @date Oct 20th 2023
*/
@IsTest(SeeAllData=false)
public class MallDocumentResponseTest {

    @IsTest
    public static void testDocumentResponse() {
        Test.startTest();
        MallDocumentResponse response = new MallDocumentResponse();
        MallDocumentResponse responseCopy = MallDocumentResponse.parse(System.JSON.serialize(response));

        Assert.isTrue(response != NULL, 'Response not null');
        Assert.isTrue(responseCopy != NULL, 'Response copy not null');
        MallDocumentResponse.parse(JSON.serialize(getAccListReponse()));
        Test.stopTest();
    }

    /**
     * 
     * @description getAccListReponse
     * @return MallDocumentResponse
     */
    public static MallDocumentResponse getAccListReponse() {
        MallDocumentResponse accountResponse = new MallDocumentResponse();
        return accountResponse;
    }
}