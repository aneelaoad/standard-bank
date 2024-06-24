@IsTest
class SA_batchJob_ISICMapping_Test {

    static User testUser;
    static Account acc;
    static List<Account> dataResult;

    @TestSetup
    static void setup() {
        TEST_DataFactory.generateConfiguration();
        fflib_SObjectUnitOfWork uow;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            testUser = (User) new BLD_USER(uow).useCib().getRecord();
            uow.commitWork();
        }
        System.runAs(testUser) {
            acc = (Account) new BLD_Account()
                            .name(BLD_Account.DEF_NAME)
                            .CIFActiveCode('A')
                            .setField(Account.Industry_Code__c,'65990')
                            .commitWork()
                            .getRecord();
        }
    }

    static void getData() {

    String sIndustryCode = '';
    String sRecordTypeId = GlobalCache.getRecordTypeId('Account', 'Inactive');

    dataResult = [SELECT Id, SA_Industry_Description__c, Industry_Code__c, RecordTypeId
                  FROM Account
                  WHERE Industry_Code__c != :sIndustryCode
                  AND RecordTypeId != :sRecordTypeId];
    }

    @IsTest
    static void shouldExecuteBatch() {
        getData();
        Test.startTest();
        SA_batchJob_ISICMapping sa_batchJob_ISICMapping = new SA_batchJob_ISICMapping();
        Database.executeBatch(sa_batchJob_ISICMapping);
        Test.stopTest();
        System.assertNotEquals(null, dataResult);
    }       
}