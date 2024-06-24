@isTest
private class Ltn_FieldSetController_Test {

	private static final String 
		TEST_USER_NAME          = 'stdBank@nbac.com',
		DEF_ACC_NAME            = 'Def Name for Acc';
	
	private static User usr;

	@TestSetup
	private static void prepareData() {

		TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        System.runAs(new User(Id = UserInfo.getUserId())){
            
            usr = (User)new BLD_USER(uow).userName(TEST_USER_NAME).useCib().syncContact().getRecord();
            uow.commitWork();

        }
		System.runAs(usr){
			Business_Assessment__c assessment = new Business_Assessment__c();
			insert(assessment);
		}


		Test.startTest();
        Test.stopTest();
	}

	private static void getUser(){ 
        usr =  [ SELECT Username  
                        FROM User
                        WHERE UserName =: TEST_USER_NAME LIMIT 1];
	}
	
	@isTest static void shouldThrowRecordIdNotSpecifiedException() {
		getUser();
		String errorMessage;
		test.startTest();
		System.runAs(usr){
			try{
				Ltn_FieldSetController.getFields(null, null);
				}catch(Ltn_FieldSetController.Ltn_FieldSetControllerException ex){
					errorMessage = ex.getMessage();
				}
		}
		test.stopTest();

		system.assertEquals(Ltn_FieldSetController.RECORDID_NOT_SPECIFIED, errorMessage);
	}

	@isTest static void shouldThrowFiedSetNotSpecifiedException() {
		getUser();
		String errorMessage;
		test.startTest();

		System.runAs(usr){
			Business_Assessment__c assessment = [SELECT Id FROM Business_Assessment__c LIMIT 1];
			try{
				Ltn_FieldSetController.getFields(assessment.Id, null);
			}catch(Ltn_FieldSetController.Ltn_FieldSetControllerException ex){
				errorMessage = ex.getMessage();
			}
		}
		test.stopTest();

		system.assertEquals(Ltn_FieldSetController.FIELDSET_NAME_NOT_SPECIFIED, errorMessage);
	}
	
	@isTest static void shouldGetListOfFields() {
		getUser();
		Map<String, Object> fieldSet;
		test.startTest();

		System.runAs(usr){

			List<Business_Assessment__c> assessment = [SELECT Id FROM Business_Assessment__c ];
			fieldSet = Ltn_FieldSetController.getFields(assessment[0].Id, 'Name, Id ');
			system.assertEquals(3, fieldSet.size());

			fieldSet = Ltn_FieldSetController.getFields(assessment[0].Id, 'BA_HighlightPanelFields');
			system.assertEquals(false, fieldSet.isEmpty());
		}
		test.stopTest();

		
	}
	
}