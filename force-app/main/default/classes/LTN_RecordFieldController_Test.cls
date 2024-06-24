@isTest
private class LTN_RecordFieldController_Test {
    private static final String TEST_USER_NAME = 'stdBank@nbac.com';
    private static final String TEST_COMMB_USER_NAME = 'commbstdBank@nbac.com';
    
    private static User usr;
 	private static User commBusr;
    @TestSetup
    private static void prepareData() {

        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();

        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())){
            
            usr = (User)new BLD_USER(uow).userName(TEST_USER_NAME).useCib().syncContact()
                            .setField(User.DefaultCurrencyIsoCode, 'USD').getRecord();
            commBusr = (User)new BLD_USER(uow).userName(TEST_COMMB_USER_NAME).useCommB().syncContact()
                            .setField(User.DefaultCurrencyIsoCode, 'USD').getRecord();
            uow.commitWork();
        }
        Test.stopTest(); 
    }

    private static void getUser(){ 
        usr =  [ SELECT Username  
                        FROM User
                        WHERE UserName =: TEST_USER_NAME LIMIT 1];
    }
    private static void getCommBUser(){
        commBusr =  [ SELECT Username
                        FROM User
                        WHERE UserName =: TEST_COMMB_USER_NAME LIMIT 1];
    }
    testmethod static void shouldThrowNoSObjectSpecifiedException(){
        getUser();
        String errorMessage;
        Test.startTest();
        system.runAs(usr){
            try{
                    LTN_RecordFieldController.getFieldAttributes(null, null);
                }catch(LTN_RecordFieldController.LTN_RecordFieldControllerException ex){
                    errorMessage = ex.getMessage();
                }
        }
        Test.stopTest(); 
        system.assertEquals(LTN_RecordFieldController.SOBJECT_NOT_SPECIFIED, errorMessage);
    }
	@IsTest
	public static void shouldUpdateCheckIfCommBUserHasAccessToGroupNumField() {
        getCommBUser();
        Boolean permEdit;
            Test.startTest();
            	System.runAs(commBusr) {
                permEdit = LTN_RecordFieldController.canEditField('Account', 'Relationship_Group_Number__c');
                }
            Test.stopTest();

        System.assertEquals(false, permEdit);
    }
    testmethod static void shouldThrowNoFieldNameException(){
        getUser();
        String errorMessage;
        Test.startTest();
        system.runAs(usr){
            try{
                    LTN_RecordFieldController.getFieldAttributes(new Account(), null);
                }catch(LTN_RecordFieldController.LTN_RecordFieldControllerException ex){
                    errorMessage = ex.getMessage();
                }
        }
        Test.stopTest(); 
   		system.assertEquals(null, errorMessage); // error message was removed for this condition
    }

    testmethod static void shouldGetFieldDetails(){
        getUser();
        Test.startTest();
        system.runAs(usr){
             Map<String,Object> fieldDetails = LTN_RecordFieldController.getFieldAttributes(new Business_Assessment__c(), 'Account__r.Name');
             system.assertEquals(false, fieldDetails.isEmpty());

             //fieldDetails = LTN_RecordFieldController.getFieldAttributes(new Business_Assessment__c(), 'Milestone__c');
             //system.assertEquals(true, ((List<LTN_RecordFieldController.PicklistValue>)fieldDetails.get('options')).size()>1);

             fieldDetails = LTN_RecordFieldController.getFieldAttributes(new Business_Assessment__c(), 'Amount_Held__c');
             system.assertNotEquals(null, fieldDetails.get('convertedValue'));

             
        }
        Test.stopTest(); 
        
    }
}