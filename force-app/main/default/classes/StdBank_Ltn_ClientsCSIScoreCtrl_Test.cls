@isTest
private class StdBank_Ltn_ClientsCSIScoreCtrl_Test {
	
	private static User standardUser {
		get {
			if (standardUser == null) {
				System.runAs(new User(Id = UserInfo.getUserId()))
				{
					standardUser = (User) new BLD_USER().useCib().syncContact().commitWork().getRecord();
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

	private static testmethod void notRatedCIB(){
		Decimal expectedValue = 0;
		Decimal actualValue;
		Map<String, Decimal> name2value;
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount = new BLD_Account(uow).overallCIBCRIRating(expectedValue).useCib();
		new BLD_ClientTeam(uow).account(new BLD_Account(uow).overallCIBCRIRating(expectedValue)).user(standardUser.Id).role(DMN_ClientTeam.ROLE_ANALYST);
		new BLD_ClientTeam(uow).account(bAccount).user(standardUser.Id).role(DMN_ClientTeam.ROLE_ANALYST);
		uow.commitWork();
		Test.startTest();
		System.runAs(standardUser){
			name2value = StdBank_Ltn_ClientsCSIScoreController.getCSIScore(bAccount.getRecordId());
			actualValue = (Decimal)name2value.get('CSIScoreValue');
		}
		Test.stopTest();
		System.assertEquals(expectedValue,actualValue);
	}

	private static testmethod void oneCIB(){
		Decimal expectedValue = 1;
		Decimal actualValue;
		Map<String, Decimal> name2value;
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount = new BLD_Account(uow).overallCIBCRIRating(expectedValue).useCib();
		new BLD_ClientTeam(uow).account(new BLD_Account(uow).overallCIBCRIRating(expectedValue)).user(standardUser.Id).role(DMN_ClientTeam.ROLE_ANALYST);
		new BLD_ClientTeam(uow).account(bAccount).user(standardUser.Id).role(DMN_ClientTeam.ROLE_ANALYST);
		uow.commitWork();
		Test.startTest();
		System.runAs(standardUser){
			name2value = StdBank_Ltn_ClientsCSIScoreController.getCSIScore(bAccount.getRecordId());
			actualValue = (Decimal)name2value.get('CSIScoreValue');
		}
		Test.stopTest();
		System.assertEquals(expectedValue,actualValue);
	}
	private static testmethod void twoCIB(){
		Decimal expectedValue = 2;
		Decimal actualValue;
		Map<String, Decimal> name2value;
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount = new BLD_Account(uow).overallCIBCRIRating(expectedValue).useCib();
		new BLD_ClientTeam(uow).account(new BLD_Account(uow).overallCIBCRIRating(expectedValue)).user(standardUser.Id).role(DMN_ClientTeam.ROLE_ANALYST);
		new BLD_ClientTeam(uow).account(bAccount).user(standardUser.Id).role(DMN_ClientTeam.ROLE_ANALYST);
		uow.commitWork();
		Test.startTest();
		System.runAs(standardUser){
			name2value = StdBank_Ltn_ClientsCSIScoreController.getCSIScore(bAccount.getRecordId());
			actualValue = (Decimal)name2value.get('CSIScoreValue');
		}
		Test.stopTest();
		System.assertEquals(expectedValue,actualValue);
	}
	private static testmethod void threeCIB(){
		Decimal expectedValue = 3;
		Decimal actualValue;
		Map<String, Decimal> name2value;
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount = new BLD_Account(uow).overallCIBCRIRating(expectedValue).useCib();
		new BLD_ClientTeam(uow).account(new BLD_Account(uow).overallCIBCRIRating(expectedValue)).user(standardUser.Id).role(DMN_ClientTeam.ROLE_ANALYST);
		new BLD_ClientTeam(uow).account(bAccount).user(standardUser.Id).role(DMN_ClientTeam.ROLE_ANALYST);
		uow.commitWork();
		Test.startTest();
		System.runAs(standardUser){
			name2value = StdBank_Ltn_ClientsCSIScoreController.getCSIScore(bAccount.getRecordId());
			actualValue = (Decimal)name2value.get('CSIScoreValue');
		}
		Test.stopTest();
		System.assertEquals(expectedValue,actualValue);
	}
	private static testmethod void tenCIB(){
		Decimal expectedValue = 10;
		Decimal actualValue;
		Map<String, Decimal> name2value;
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount = new BLD_Account(uow).overallCIBCRIRating(expectedValue).useCib();
		new BLD_ClientTeam(uow).account(new BLD_Account(uow).overallCIBCRIRating(expectedValue)).user(standardUser.Id).role(DMN_ClientTeam.ROLE_ANALYST);
		new BLD_ClientTeam(uow).account(bAccount).user(standardUser.Id).role(DMN_ClientTeam.ROLE_ANALYST);
		uow.commitWork();
		Test.startTest();
		System.runAs(standardUser){
			name2value = StdBank_Ltn_ClientsCSIScoreController.getCSIScore(bAccount.getRecordId());
			actualValue = (Decimal)name2value.get('CSIScoreValue');
		}
		Test.stopTest();
		System.assertEquals(expectedValue,actualValue);
	}
	private static testmethod void noCIB(){
		Decimal expectedValue = null;
		Decimal actualValue;
		Map<String, Decimal> name2value;
		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
		BLD_Account bAccount = new BLD_Account(uow).useCib();

		new BLD_ClientTeam(uow).account(new BLD_Account(uow).overallCIBCRIRating(expectedValue)).user(standardUser.Id).role(DMN_ClientTeam.ROLE_ANALYST);
		new BLD_ClientTeam(uow).account(bAccount).user(standardUser.Id).role(DMN_ClientTeam.ROLE_ANALYST);
		uow.commitWork();
		Test.startTest();
		System.runAs(standardUser){
			name2value = StdBank_Ltn_ClientsCSIScoreController.getCSIScore(bAccount.getRecordId());
			actualValue = (Decimal)name2value.get('CSIScoreValue');
		}
		Test.stopTest();
		System.assertEquals(expectedValue,actualValue);
	}
	
	
	
}