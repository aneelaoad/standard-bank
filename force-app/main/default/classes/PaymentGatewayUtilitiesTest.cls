@IsTest
private class PaymentGatewayUtilitiesTest {
    @IsTest
    static void convertToMinorUnitsTest() {

        // when: converting 69.55
        String result = PaymentGatewayUtilities.convertAmountToMinorUnits('EUR', 69.55);

        //then: result should be 6955
        System.assertEquals('6955', result);
    }

    @IsTest
    static void convertToMinorUnitsUnknownCurrencyTest() {

        // when: converting 69.55 with unknown or non-existent currency
        String result = PaymentGatewayUtilities.convertAmountToMinorUnits('xxaasda', 69.55);

        //then: should expect default 2 decimal place - result should be 6955
        System.assertEquals('6955', result);
    }

    @IsTest
    static void convertFromMinorUnitsTest() {
        // when: converting from 6955
        Decimal result = PaymentGatewayUtilities.convertMinorUnitsToDecimal('EUR', '6955');

        //then: result should be 69.55
        System.assertEquals(69.55, result);
    }

}