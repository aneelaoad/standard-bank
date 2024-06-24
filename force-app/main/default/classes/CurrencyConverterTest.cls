/*************************************************************************
	@ Author 		: psvestka
	@ Date 		    : Jan 2016
	@ Description	: EN-927
****************************************************************************/

@IsTest
private class CurrencyConverterTest {

	static testMethod void testBehavior() {

		CurrencyConverter conv = new CurrencyConverter();

		// reset the rates to values expected in the test
		conv.corporateIsoCode = 'USD';
		conv.rateMap = new Map<String, Decimal> { 'EUR' => 0.896500
												 ,'USD' => 1.0
												 ,'ZAR' => 13.789400};

		system.assertEquals(13789.4, conv.convertCorporateCurrency(1000, 'ZAR'));

		system.assertEquals(15381, Math.round(conv.convertCurrency(1000, 'EUR', 'ZAR')));
    }
}