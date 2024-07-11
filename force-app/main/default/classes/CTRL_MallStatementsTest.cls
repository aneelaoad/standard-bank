@isTest
public class CTRL_MallStatementsTest {

    @isTest
    static void testGetStatements() {
        // JSON mockup response
        String jsonResponse = '{ "resultSet": [ { "description": "Description 0", "label": "statement 0", "uid": "UID0" }, { "description": "Description 1", "label": "statement 1", "uid": "UID1" }, { "description": "Description 2", "label": "statement 2", "uid": "UID2" } ] }';

        // Deserialize the JSON response into MallDocumentResponse
        MallDocumentResponse mockResponse = (MallDocumentResponse) JSON.deserialize(jsonResponse, MallDocumentResponse.class);
		 System.debug('mockResponse: '+mockResponse);
        
        // Mock the CTRL_MallDocumentManagement.getCustomerPreviousStatementsByAccountNumbers method
        Test.setMock(System.StubProvider.class, new MockCTRL_MallDocumentManagement(mockResponse));
        
        List<CTRL_MallStatements.Statement> statements = CTRL_MallStatements.getStatements();
     // List<MallStatementsCtrl.Statement> statements = mockResponse.resultSet;

        System.debug('statements: '+statements);
        // Assertions
        System.assertEquals(3, statements.size(), 'The size of statements list should be 3');
        System.assertEquals('Description 0', statements[0].title, 'The title of the first statement should match');
        System.assertEquals('Label 0', statements[0].strDate, 'The strDate of the first statement should match');
        System.assertEquals('UID0', statements[0].uid, 'The uid of the first statement should match');
    }
    
    // Mock class to simulate the behavior of CTRL_MallDocumentManagement
    private class MockCTRL_MallDocumentManagement implements System.StubProvider {
        private MallDocumentResponse mockResponse;
        
        public MockCTRL_MallDocumentManagement(MallDocumentResponse mockResponse) {
            this.mockResponse = mockResponse;
        }
        
        public Object handleMethodCall(Object stubbedObject, String methodName, System.Type returnType, List<System.Type> paramTypes, List<String> paramNames, List<Object> paramValues) {
            if (methodName == 'getCustomerPreviousStatementsByAccountNumbers') {
                return mockResponse;
            }
            return null;
        }
    }
    @isTest
       static void testStatementInitialization() {
           // Create an instance of the Statement class
           String title = 'Sample Title';
           String strDate = '2024-06-24';
           String uid = 'UID12345';
           CTRL_MallStatements.Statement statement = new CTRL_MallStatements.Statement(title, strDate, uid);
   
           // Assertions to check if the properties are correctly initialized
           System.assertEquals(title, statement.title, 'Title should match the initialized value');
           System.assertEquals(strDate, statement.strDate, 'Date should match the initialized value');
           System.assertEquals(uid, statement.uid, 'UID should match the initialized value');
       }   
}