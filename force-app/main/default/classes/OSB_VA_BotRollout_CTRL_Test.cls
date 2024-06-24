/**
 *
 * Test class for OSB_VA_BotRollout_CTRL
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date February 2021
 */
@IsTest
public with sharing class OSB_VA_BotRollout_CTRL_Test {

    @TestSetup
    static void setupMethod() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Contact conBld = new BLD_Contact(uow)
                .name('Test', 'Name1')
                .email('testemail1@random.com')
                .operatingCountry('Mauritius');
        BLD_Contact conBld1 = new BLD_Contact(uow)
                .name('Test', 'Name2')
                .email('testemail2@random.com')
                .operatingCountry('Angola');
        BLD_Contact conBld2 = new BLD_Contact(uow)
                .name('Test', 'Name3')
                .email('testemail3@random.com');
        uow.commitWork();
    }

    @IsTest
    public static void shouldReturnFalseForNullContactId(){
        List<String> contactIds = new List<String>();
        contactIds.add(null);

        Test.startTest();
        List<Boolean> result = OSB_VA_BotRollout_CTRL.isVAEnabledForContactCountry(contactIds);
        Test.stopTest();
        System.assertEquals(1, result.size());
        System.assertEquals(false, result.get(0));
    }

    @IsTest
    public static void shouldReturnFalseWhenNoRollOutForContactCountry(){
        List<String> contactIds = new List<String>();
        Contact con = [SELECT Id FROM Contact WHERE Name = 'Test Name2'];
        contactIds.add(con.Id);

        Test.startTest();
        List<Boolean> result = OSB_VA_BotRollout_CTRL.isVAEnabledForContactCountry(contactIds);
        Test.stopTest();
        System.assertEquals(1, result.size());
        System.assertEquals(false, result.get(0));
    }

    @IsTest
    public static void shouldReturnFalseWhenOperatingCountryIsNull(){
        List<String> contactIds = new List<String>();
        Contact con = [SELECT Id FROM Contact WHERE Name = 'Test Name3'];
        contactIds.add(con.Id);

        Test.startTest();
        List<Boolean> result = OSB_VA_BotRollout_CTRL.isVAEnabledForContactCountry(contactIds);
        Test.stopTest();
        System.assertEquals(1, result.size());
        System.assertEquals(false, result.get(0));
    }

    @IsTest
    public static void shouldReturnTrueWhenThereIsRollOutForContactCountry(){
        List<String> contactIds = new List<String>();
        Contact con = [SELECT Id FROM Contact WHERE Name = 'Test Name1'];
        contactIds.add(con.Id);

        Test.startTest();
        List<Boolean> result = OSB_VA_BotRollout_CTRL.isVAEnabledForContactCountry(contactIds);
        Test.stopTest();
        System.assertEquals(1, result.size());
        System.assertEquals(true, result.get(0));
    }
}