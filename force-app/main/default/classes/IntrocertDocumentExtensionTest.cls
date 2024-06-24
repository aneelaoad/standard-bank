/*************************************************************************
	@ Author 		: psvestka
	@ Date 		    : 11. 6. 2016
	@ Description	: US-1375
****************************************************************************/

@IsTest
public class IntrocertDocumentExtensionTest {

    @TestSetup
    static void prepareData() {
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getUserProfileIds(),
            TEST_DataFactory.getEnvironmentVariable()
        });
    }
    
    @IsTest
    static void testFindPod() {
        String url1 = 'https' + '://' + 'cs87' + '.salesforce.com';
        String url2 = 'https' + '://c.' + 'cs87' + '.visual.force.com';
        List<String> inputHostsCs = new List<String> {
            url1, url2
        };
        String url3 = 'https' + '://' + 'emea' + '.salesforce.com';
        String url4 = 'https' + '://c.' + 'emea' + '.visual.force.com';
        List<String> inputHostsEmea = new List<String> {
            url3, url4
        };

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
            
            IntrocertDocumentExtension ide = new IntrocertDocumentExtension(new ApexPages.StandardController(commBAcc));
                for (String host: inputHostsCs) {
                system.assertEquals('cs87', ide.findPod(host));
            }
            
            for (String host: inputHostsEmea) {
                system.assertEquals('emea', ide.findPod(host));
            }
        }
    }
}