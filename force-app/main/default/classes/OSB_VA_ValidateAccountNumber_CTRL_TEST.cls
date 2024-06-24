/**
 *
 * Test class for OSB_VA_ValidateAccountNumber_CTRL
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date March 2021
 */
@IsTest
public with sharing class OSB_VA_ValidateAccountNumber_CTRL_TEST {

    @IsTest
    public static void testInvalidAccountNumber() {
        List<String> accountNumbers = new List<String>{
                '1234'
        };
        Test.startTest();
        List<Boolean> result = OSB_VA_ValidateAccountNumber_CTRL.validateAccountNumber(accountNumbers);
        Test.stopTest();
        System.assertEquals(accountNumbers.size(), result.size());
        System.assertEquals(false, result.get(0));
    }

    @IsTest
    public static void testValidAccountNumber() {
        List<String> accountNumbers = new List<String>{
                '1234567890123'
        };
        Test.startTest();
        List<Boolean> result = OSB_VA_ValidateAccountNumber_CTRL.validateAccountNumber(accountNumbers);
        Test.stopTest();
        System.assertEquals(accountNumbers.size(), result.size());
        System.assertEquals(true, result.get(0));
    }
}