/**
 * @description MallStoreRepresentativesControllerTest
 * @author Maham Hassan
 * @since
 */
@isTest
public class MallStoreRepresentativesControllerTest{
	
    @IsTest
    private static void getContactRecordsTest(){
        Account account = new Account();
        account.Name = 'Web Africa';
        insert account;
        
        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName = 'Contact';
        contact.Email = 'test@gmail.com';
        contact.AccountId = account.Id;
        insert contact;
        Test.startTest();
        MallStoreRepresentativesController.getContactRecords(account.Id);
        try{
         MallStoreRepresentativesController.getContactRecords('0001');
        }catch(Exception e) {
            AuraHandledException aueaEx = MallExceptionUtil.throwAuraException('getContactRecords',e);
            Assert.areEqual(true, aueaEx.getMessage().contains('0001'), 'exception');
        }
        Test.stopTest();
    }
}