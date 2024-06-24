@isTest
public class StdBank_Ltn_ClientsCROCCtrl_Test {

	private static User standardUser {
		get {
			if (standardUser == null) {
				System.runAs(new User(Id = UserInfo.getUserId()))
				{
					standardUser = (User) new BLD_USER().useCommB().syncContact().commitWork().getRecord();
				}
			}
			return standardUser;
		}
		Set;
	}
	@TestSetup
	private static void setup() {
		insert TEST_DataFactory.getUserProfileIds();
	}

	private static testmethod void crocWithoutContext() {
		Boolean withoutException = true;
		String crocValue;
		System.runAs(standardUser) {
			Test.startTest();
			try {
				crocValue = StdBank_Ltn_ClientsCROCController.getCROC(null);
			}
			catch(Exception e) {
				withoutException = false;
			}
			Test.stopTest();
		}
		System.assert(withoutException);
		System.assertNotEquals(null, crocValue);
		System.assertNotEquals(String.valueOf(0), crocValue);		
	}

	private static testmethod void oneClientOneRevenueFilled(){
		Decimal crocValue = 40.00;

		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount = new BLD_Account(uow);
		BLD_ClientCapitalAndRevenue bCliCapRev = new BLD_ClientCapitalAndRevenue(uow);
		bCliCapRev.client(bAccount);
		bCliCapRev.CROCZAR(crocValue);

		uow.commitWork();
		Boolean withoutException = true;
		String expectedValue= String.valueOf(crocValue);
		String actualValue;

		System.runAs(standardUser) {
			Test.startTest();
			try {
				actualValue = StdBank_Ltn_ClientsCROCController.getCROC(bAccount.getRecordId());
			}
			catch(Exception e) {
				withoutException = false;
			}
			Test.stopTest();
		}
		
		System.assert(withoutException);
		System.assertNotEquals(null, actualValue);
		System.assertEquals(expectedValue,actualValue);
	
	}

	private static testmethod void clientWithoutRecenue(){
		Decimal crocValue = 40;

		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount = new BLD_Account(uow);
		BLD_ClientCapitalAndRevenue bCliCapRev = new BLD_ClientCapitalAndRevenue(uow);
		bCliCapRev.client(new BLD_Account(uow));
		bCliCapRev.CROCZAR(crocValue);

		uow.commitWork();
		Boolean withoutException = true;
		String unExpectedValue= String.valueOf(crocValue);
		String actualValue;

		System.runAs(standardUser) {
			Test.startTest();
			try {
				actualValue = StdBank_Ltn_ClientsCROCController.getCROC(bAccount.getRecordId());
			}
			catch(Exception e) {
				withoutException = false;
			}
			Test.stopTest();
		}
		
		System.assert(withoutException);
		System.assertNotEquals(null, actualValue);
		System.assert(String.isBlank(actualValue));
		System.assertNotEquals(unExpectedValue,actualValue);
	
	}

}