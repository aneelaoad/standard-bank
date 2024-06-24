@isTest
public class StdBank_Ltn_NumberOfClientsCtrlr_Test {

	private static String STD_USER_NAME = 'tester454ew45e@testorg.com';

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
		User stdUser = (User) new BLD_USER(STD_USER_NAME).useSysAdmin().getRecord();

		System.runAs(new User(Id = UserInfo.getUserId())) {
			insert stdUser;
		}

		TEST_DataFactory.insertSettings(new List<Object> {
			TEST_DataFactory.getCcSettings(),
			TEST_DataFactory.getUserProfileIds(),
			TEST_DataFactory.getCstTeamRankings()
		});

        Account ultimateGroupParent = (Account) new BLD_Account().useGroupParent()
			.proposedClientCoordinator(stdUser)
			.commitWork()
			.getRecord();

		fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        for (Integer i = 0; i < 10; i++) {
			new BLD_Account(uow).usePotential()
				.proposedClientCoordinator(stdUser)
				.clientRelationshipHierarchy(DMN_Account.REL_HIERARCHY_IMMEDIATE)
				.parentId(ultimateGroupParent);
        }

        uow.commitWork();

	}

	@isTest static void testGetCount() {
		Map<String, Integer> actualMap;
		Map<String, Integer> expectedMap = new  Map<String, Integer>();
		expectedMap.put(AccountService.RECORD_TYPE_NAME_GROUP_PARENT,0);
		expectedMap.put(AccountService.RECORD_TYPE_NAME_IMMEDIATE_PARENT,0);
		expectedMap.put(AccountService.RECORD_TYPE_NAME_CHILD,0);

		System.runAs(standardUser) {
			Set<Id> teamClientsIds = StdBank_Ltn_ClientsStatisticsController.getMyTeamClients(null);
			AggregateResult[] ars = [
				SELECT RecordType.Name rtName, Count(Id) clientsCount
				FROM Account
				WHERE Id IN : teamClientsIds
				GROUP BY RecordType.Name
			];
			
			for(AggregateResult ar:ars){
				String clientGroup = (String)ar.get('rtName');
	            if(clientGroup!=null)
					expectedMap.put(clientGroup, (Integer)ar.get('clientsCount'));
			}

			Test.startTest();
				actualMap = StdBank_Ltn_NumberOfClientsController.getCountByClientGroup(null);
			Test.stopTest();
		}

		System.assertEquals(expectedMap, actualMap);
	}

}