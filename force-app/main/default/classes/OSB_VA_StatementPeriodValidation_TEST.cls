/**
 *
 * Test class for OSB_VA_StatementPeriodValidation_CTRL
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date March 2021
 */
@IsTest
public with sharing class OSB_VA_StatementPeriodValidation_TEST {

    @IsTest
    public static void testNegativePeriod() {
        OSB_VA_StatementPeriodValidation_CTRL.ValidatePeriodInput input = new OSB_VA_StatementPeriodValidation_CTRL.ValidatePeriodInput();
        input.fromDate = Date.today().addDays(-10);
        input.toDate = Date.today().addDays(-30);
        List<OSB_VA_StatementPeriodValidation_CTRL.ValidatePeriodInput> inputs = new List<OSB_VA_StatementPeriodValidation_CTRL.ValidatePeriodInput>{
                input
        };
        Test.startTest();
        List<OSB_VA_StatementPeriodValidation_CTRL.ValidatePeriodOutput> result = OSB_VA_StatementPeriodValidation_CTRL.validateDates(inputs);
        Test.stopTest();
        System.assertEquals(result.size(), inputs.size());
        System.assertEquals('Your to date if before your from date. Please input dates in correct order', result.get(0).message);
        System.assertEquals(false, result.get(0).isValid);
    }

    @IsTest
    public static void testPeriodOver180Days() {
        OSB_VA_StatementPeriodValidation_CTRL.ValidatePeriodInput input = new OSB_VA_StatementPeriodValidation_CTRL.ValidatePeriodInput();
        input.fromDate = Date.today().addDays(-200);
        input.toDate = Date.today().addDays(-10);
        List<OSB_VA_StatementPeriodValidation_CTRL.ValidatePeriodInput> inputs = new List<OSB_VA_StatementPeriodValidation_CTRL.ValidatePeriodInput>{
                input
        };
        Test.startTest();
        List<OSB_VA_StatementPeriodValidation_CTRL.ValidatePeriodOutput> result = OSB_VA_StatementPeriodValidation_CTRL.validateDates(inputs);
        Test.stopTest();
        System.assertEquals(result.size(), inputs.size());
        System.assertEquals('You are trying to request statement for period of 191 days. The maximal period for which statement can be requested is 180 days. Please choose different time period.', result.get(0).message);
        System.assertEquals(false, result.get(0).isValid);
    }

    @IsTest
    public static void testValidPeriod() {
        OSB_VA_StatementPeriodValidation_CTRL.ValidatePeriodInput input = new OSB_VA_StatementPeriodValidation_CTRL.ValidatePeriodInput();
        input.fromDate = Date.today().addDays(-50);
        input.toDate = Date.today().addDays(-10);
        List<OSB_VA_StatementPeriodValidation_CTRL.ValidatePeriodInput> inputs = new List<OSB_VA_StatementPeriodValidation_CTRL.ValidatePeriodInput>{
                input
        };
        Test.startTest();
        List<OSB_VA_StatementPeriodValidation_CTRL.ValidatePeriodOutput> result = OSB_VA_StatementPeriodValidation_CTRL.validateDates(inputs);
        Test.stopTest();
        System.assertEquals(result.size(), inputs.size());
        System.assertEquals(null, result.get(0).message);
        System.assertEquals(true, result.get(0).isValid);
    }
}