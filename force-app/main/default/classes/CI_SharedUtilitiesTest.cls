@isTest
public with sharing class CI_SharedUtilitiesTest {

    public static testMethod void CSIDescriptionTest(){
        List<String> texts = new List<String>{'Not Rated', '6', '7', '9'};
        CI_SharedUtilities ciSharedUtilities = new CI_SharedUtilities();
        System.assertEquals('Not Rated', ciSharedUtilities.CSIDescription(texts[0]));
        System.assertEquals('At Risk', ciSharedUtilities.CSIDescription(texts[1]));
        System.assertEquals('Indifferent', ciSharedUtilities.CSIDescription(texts[2]));
        System.assertEquals('Satisfied', ciSharedUtilities.CSIDescription(texts[3]));
    }

    public static testMethod void isStringNumericTest(){
        List<String> stringsToTest = new List<String>{'5', 'a'};
        CI_SharedUtilities ciSharedUtilities = new CI_SharedUtilities();
        System.assertEquals(true, ciSharedUtilities.isStringNumeric(stringsToTest[0]));
        System.assertEquals(false, ciSharedUtilities.isStringNumeric(stringsToTest[1]));
    }

    public static testMethod void calculatePercentVarianceTest(){
        CI_SharedUtilities ciSharedUtilities = new CI_SharedUtilities();
        System.assertEquals(null, ciSharedUtilities.calculatePercentVariance('test', 'test'));
        System.assertEquals('50.0', ciSharedUtilities.calculatePercentVariance('200', '300'));
        System.assertEquals('-50.0', ciSharedUtilities.calculatePercentVariance('400', '200'));
        System.assertEquals(null, ciSharedUtilities.calculatePercentVariance('0', '0'));
    }

    public static testMethod void joinTest(){
        List<String> values = new List<String>{'1', '2', '3'};
        CI_SharedUtilities ciSharedUtilities = new CI_SharedUtilities();
        System.assertEquals('1+2+3', ciSharedUtilities.join(values, '+'));
        System.assertEquals(null, ciSharedUtilities.join(null, '+'));
    }

    public static testMethod void getAggregateResultByValueTest(){
        List<AggregateResult> results1 = new List<AggregateResult>();
        CI_SharedUtilities ciSharedUtilities = new CI_SharedUtilities();
        System.assertEquals(null, ciSharedUtilities.getAggregateResultByValue('test', 'test', results1));
    }

    public static testMethod void convertTest(){
        CI_SharedUtilities.CurrencyConverter converter = new CI_SharedUtilities.CurrencyConverter();

        String oldCurr = 'USD';
        String newCurr = 'ZAR';
        Decimal input = 100.0;
        Double oldrate = converter.RateMap.get(oldCurr);
        Decimal usdval = (input / oldrate);
        Double newrate = converter.RateMap.get(newCurr);
        Decimal result = usdval*newrate;

        System.assertEquals(0, converter.convert(null, oldCurr, newCurr));
        System.assertEquals(result, converter.convert(input, oldCurr, newCurr));
        System.assertEquals(0, converter.convert(0, oldCurr, oldCurr));
    }
}