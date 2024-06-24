/*************************************************************************
	@ Author 		: psvestka
	@ Date 		    : 11. 1. 2016
	@ Test File 	: CurrencyConverterTest
	@ Description	: EN-927 needs to convert currencies, let's have a reusable class for that
****************************************************************************/

global with sharing class CurrencyConverter {
	@TestVisible
	private String corporateIsoCode;

	@TestVisible
	private Map<String, Decimal> rateMap = new Map<String, Decimal>();

	public CurrencyConverter() {
		snapCurrencyTable();
	}

	private void snapCurrencyTable() {
		List<CurrencyType> currTable = [SELECT isCorporate, isoCode, conversionRate FROM CurrencyType where isCorporate = true];
		if (currTable.size() > 0) {
			corporateIsoCode = currTable[0].isoCode;
		}

		List<DatedConversionRate> datedConversionRates = [SELECT Id, IsoCode, ConversionRate From DatedConversionRate where NextStartDate > TODAY];

		for (DatedConversionRate dcr: datedConversionRates) {

			rateMap.put(dcr.isoCode, dcr.conversionRate);
		}


	}

	public Decimal convertCurrency(Decimal val, String fromCurr, String toCurr) {
		//NOTE ON CALCULATION:
		//(current curr / current rate) = USD(1:1)
		//(USD * new rate) = new curr value
		if (val == null || String.isEmpty(fromCurr) || String.isEmpty(toCurr)) {
			system.debug('#### convertCurrency(): some arguments are empty');
			return 0.0;
		}

		Decimal displayVal;
		if ((fromCurr != toCurr) || (val != 0)) {
			Decimal oldrate = rateMap.get(fromCurr);
			system.debug('##### oldRate = ' + oldrate);
			Decimal usdval = (val / oldrate);
			Decimal newrate = rateMap.get(toCurr);
			system.debug('##### newRate = ' + newrate);

			displayVal = (usdval * newrate);
		} else {
			displayVal = val;
		}

		return displayVal;
	}

	public Decimal convertCorporateCurrency(Decimal val, String toCurr) {
		return convertCurrency(val, corporateIsoCode, toCurr);
	}
}