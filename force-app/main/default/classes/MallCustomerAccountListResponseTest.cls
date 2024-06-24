/**
* @description Testing the MallCustomerAccountListResponse
* @see MallCustomerAccountListResponse
* @author Ankit Kumar
* @date Oct 20th 2023
*/
@IsTest(SeeAllData=false)
public class MallCustomerAccountListResponseTest {

    @IsTest
    public static void testDocumentResponse() {
        Test.startTest();
        MallCustomerAccountListResponse response = new MallCustomerAccountListResponse();
        Assert.isTrue(response != NULL, 'Response not null');
        MallCustomerAccountListResponse.parse(JSON.serialize(getCustomerDetails()));
        Test.stopTest();
    }
    
    /**
     * @description getCustomerDetails
	 * @return MallCustomerAccountListResponse
     */
    public static MallCustomerAccountListResponse getCustomerDetails() {
        MallCustomerAccountListResponse customerDetailResponse = new MallCustomerAccountListResponse();
        MallCustomerAccountListResponse.CustomerAccountListDetails customerDetails = new MallCustomerAccountListResponse.CustomerAccountListDetails();
        customerDetails.accountCloseDate = '2012-04-23T18:25:43.511Z';	
		customerDetails.accountClosedDate = '2012-04-23T18:25:43.511Z';
        customerDetailResponse.customerAccountListDetails = new List<MallCustomerAccountListResponse.CustomerAccountListDetails> {customerDetails};
        return customerDetailResponse;
    }
}