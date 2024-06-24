@isTest
public class StdBank_Ltn_ClientsCYPipelineCtrlr_Test {

	private static String STD_USER_NAME = 'testdwadwaer@testorg.com';
	private static Integer oppProductCurrentYearFees = 20;

	private static User standardUser {
		get {
			if (standardUser == null) {
				standardUser = [SELECT Id FROM User WHERE Username = :STD_USER_NAME LIMIT 1];
			}
			return standardUser;
		}
	}

	@testSetup
	static void setupData() {
		User stdUser = (User) new BLD_USER(STD_USER_NAME).useCib().getRecord();

		System.runAs(new User(Id = UserInfo.getUserId())) {
			insert stdUser;
		}

		TEST_DataFactory.insertSettings(new List<Object> {
			TEST_DataFactory.getCcSettings(),
			TEST_DataFactory.getUserProfileIds()
		});

		System.runAs(stdUser) {

			fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

	        Account ultimateGroupParent = (Account) new BLD_Account(uow).useGroupParent()
				.proposedClientCoordinator(stdUser)
				.name('ultimateGroupParent' + System.today())
				.getRecord();

			new BLD_Account(uow).useImmediateParent()
				.proposedClientCoordinator(stdUser)
				.name('immediateParent' + System.today());

			new BLD_Account(uow).useChild()
				.proposedClientCoordinator(stdUser)
				.name('child' + System.today());

			uow.commitWork();

	        for(Integer i = 0; i < 6; i++) {
				new BLD_Account(uow).usePotential()
					.proposedClientCoordinator(stdUser)
					.CIF(String.valueOf(i))
					.clientRelationshipHierarchy(DMN_Account.REL_HIERARCHY_IMMEDIATE)
					.parentId(ultimateGroupParent)
					.addOpportunity(
						new BLD_Opportunity(uow)
							.closeDate(System.today())
							.addProduct(
								new BLD_Product(uow)
									.currentYearFees(oppProductCurrentYearFees)
						)
					);
	        }
	    }
	}

	@isTest static void testGetUserIsoCode() {
		String acutalIsoCode;
		String expectedIsoCode;

		System.runAs(standardUser) {
			expectedIsoCode = UserInfo.getDefaultCurrency();

			Test.startTest();
				acutalIsoCode = StdBank_Ltn_ClientsCYPipelineController.getUserIsoCode();
			Test.stopTest();
		} 

		System.assertEquals(expectedIsoCode, acutalIsoCode);
	}

	@isTest static void getHelpTextTest(){

		String nameUGP = 'ultimateGroupParent' + System.Today();
		String nameIP = 'immediateParent' + System.Today();
		String nameCH = 'child' + System.Today();

		Map<String, Account> name2account = new Map<String, Account>();
		Test.startTest();
		for(Account acc : [SELECT Id, Name FROM Account WHERE Name = :nameUGP OR Name = :nameIP OR Name = :nameCH]){
			name2account.put(acc.Name, acc);
		}
		Test.stopTest();

		System.assertEquals('', StdBank_Ltn_ClientsCYPipelineController.getHelpText(null));
		System.assertEquals(Label.Help_Text_Total_CY_Pipeline_UGP_or_IP, StdBank_Ltn_ClientsCYPipelineController.getHelpText(name2account.get(nameUGP).Id));
		System.assertEquals(Label.Help_Text_Total_CY_Pipeline_Child, StdBank_Ltn_ClientsCYPipelineController.getHelpText(name2account.get(nameCH).Id));

	}

}