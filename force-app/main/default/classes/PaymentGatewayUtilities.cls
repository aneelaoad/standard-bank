public with sharing class PaymentGatewayUtilities {
    /**
     * Most payment gateways expect minor units.
     *
     * For example: 25.50 needs to be 2550 if euros
     *
     * This method will handle the conversion and take
     * into account the decimal places for a given
     * currency.
     *
     * The currency needs to be configured in Salesforce
     * otherwise a default value of 2 is returned.
     *
     * @param currencyCode
     * @param value
     *
     * @return
     */
    public static String convertAmountToMinorUnits(String currencyCode, Decimal value) {
        Integer factor = getConversionFactor(currencyCode);

        Integer minorUnitsValue = (Integer) (value * factor);

        return String.valueOf(minorUnitsValue);
    }

    public static Decimal convertMinorUnitsToDecimal(String currencyCode, String value) {
        Integer factor = getConversionFactor(currencyCode);
        Decimal parsedValue = Decimal.valueOf(value);
        Decimal originalValue = (parsedValue / factor).setScale(getDecimalPlaces(currencyCode), RoundingMode.HALF_UP);

        return originalValue;
    }

    private static Integer getConversionFactor(String currencyCode) {
        Integer decimalPlaces = getDecimalPlaces(currencyCode);
        Integer factor = (Integer) Math.pow(10, decimalPlaces);
        return factor;
    }

    private final static Integer DEFAULT_DECIMAL_PLACES = 2;
    private static Integer getDecimalPlaces(String currencyCode) {
        try {
            CurrencyType currencyType = [
                    SELECT DecimalPlaces
                    FROM CurrencyType
                    WHERE IsoCode = :currencyCode
                    LIMIT 1
            ];
            return currencyType.DecimalPlaces;
        } catch (QueryException e) {
            System.debug(LoggingLevel.WARN,
                    String.format('Attempting to find currency decimal places for currency {0} although it was not found: {1}',
                            new Object[] { currencyCode, e.getMessage() })
                    );
            return DEFAULT_DECIMAL_PLACES;
        }
    }
}