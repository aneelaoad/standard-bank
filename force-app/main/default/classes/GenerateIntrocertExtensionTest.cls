/*************************************************************************
	@ Author 		: psvestka
	@ Date 		    : 13. 6. 2016
	@ Description	: US-1375
****************************************************************************/

@IsTest
public class GenerateIntrocertExtensionTest {

    @TestSetup
    static void prepareData() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getUserProfileIds(),
            TEST_DataFactory.getEnvironmentVariable()
        });
    }
    
    @IsTest
    static void testAttachmentIsGenerated() {

        User userCC;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            userCC = (User) new BLD_USER().useCommB().commitWork().getRecord();
        }
        Account commBAcc;
        
        System.runAs(userCC) {
            commBAcc = (Account) new BLD_Account().useCommB()
                .commitWork()
                .getRecord();

        	PageReference pageRef = Page.GenerateIntrocert;
            pageRef.getParameters().put('id', commBAcc.id);
            Test.setCurrentPage(pageRef);
            
            GenerateIntrocertExtension gie = new GenerateIntrocertExtension(new ApexPages.StandardController(commBAcc));
            
            PageReference returnPR = gie.generateDoc();
            system.assertNotEquals(null, returnPR, 'Returned PageReference should not be null');
            
            system.assertEquals(1, [SELECT COUNT() FROM ContentDocumentLink WHERE LinkedEntityId = :commBAcc.Id], 'Exactly one Attachment should exist');
        }
    }
}