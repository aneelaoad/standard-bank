/***
  	@ Func Area     	:  IB
  	@ Author        	:  Wayne Solomon
  	@ Modified Date    	:  19 Feb 2020
  	@ User Story    	:  US-4504 -- DM NBAC: SPV PDF copy at Supported and Submitted milestone - Read Only
  	@description 	    :  Updated test class for attachNBACPdf
***/
@SuppressWarnings('PMD.ClassNamingConventions')
@IsTest
public class attachNBACPdf_Test {
private static final String
	TEST_USER_NAME = 'triggerstdBank@nbacPDF.com';

	private static User standardUser {
		get {
			if (standardUser == null) {

				standardUser = [SELECT id FROM User WHERE UserName = :TEST_USER_NAME];

			}
			return standardUser;
		}
		Set;
	}

	@TestSetup
	private static void createCommitData() {
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		User owner;
		System.runAs(new User(Id = UserInfo.getUserId())) {

			owner = (USER) new BLD_USER().userName(TEST_USER_NAME).useCib().syncContact().getRecord();
			uow.commitWork();
		}

		BLD_Account bAccount = new BLD_Account(uow)
		.name('acc0')
		.useGroupParent()
		;

		BLD_BusinessAssessment bAssessment = new BLD_BusinessAssessment(uow);
		bAssessment.client(bAccount);
        
		System.runAs(owner) {
			uow.commitWork();
		}

	}

	@IsTest
	private static void testPDFAttachment() {

        Business_Assessment__c assessment = [SELECT Account__r.Name,Id,Milestone__c,RecordType.DeveloperName From Business_Assessment__c];
        ApexPages.StandardController controller;
        attachNBACPdf nbacPDFattachment;

        controller = new ApexPages.StandardController(assessment);
        nbacPDFattachment = new attachNBACPdf(controller);
        
        Test.startTest(); 
		System.runAs(standardUser) {
            try{
            	nbacPDFattachment.attachPDF();    
            }catch(Exception ex){
                System.assert(false, ex.getMessage());
            }
		}
		Test.stopTest();
	}
}