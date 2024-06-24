@IsTest
private class MallStoreCasesControllerTest {


    @IsTest
    private static void getCaseRecordsTestWithAccount() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        Case cs = new Case();
        cs.Status = 'New';
        cs.Origin = 'Web';
        cs.AccountId = acc.Id;
        insert cs;

        List<Case> result =  MallStoreCasesController.getCaseRecords(acc.Id);
        Assert.areEqual(1, result.size(), 'Expected Case');
    }
    
    @IsTest
    private static void getCaseRecordsTestWithoutAccount(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        List<Case> result =  MallStoreCasesController.getCaseRecords(acc.Id);
        Assert.areEqual(0, result.size(), 'Expected Case');
        try {
            String invalidIdString = '001';
            result =  MallStoreCasesController.getCaseRecords(invalidIdString);
        } catch(Exception e) {
            Assert.isTrue(e != NULL, 'Exception should not be null');
        }
	}
}