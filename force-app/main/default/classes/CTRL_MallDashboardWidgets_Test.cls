/**
* 
* @description CTRL_MallDashboardWidgets_Test
* @author Ankit Kumar
* @since  
*/
@IsTest
private with sharing class CTRL_MallDashboardWidgets_Test {
    @IsTest
    static void getLocationTimeTest(){
        Test.setMock(HttpCalloutMock.class, new API_Mall_GetWorldTime.API_Mall_GetWorldTimeMock());
        Test.startTest();
        CTRL_MallDashboardWidgets.ResponseWrapper response = CTRL_MallDashboardWidgets.getLocationTime('Kolkata,India');
        Test.stopTest();
        Assert.isTrue(response != NULL, 'response should not be NULL');
    }

    @IsTest
    static void getWeatherTest(){
        Test.setMock(HttpCalloutMock.class, new API_Mall_GetWeather.API_Mall_GetWeatherMock());
        Test.startTest();
        CTRL_MallDashboardWidgets.ResponseWrapper  response = CTRL_MallDashboardWidgets.getWeather('82.049,-30.098');
        Test.stopTest();
        Assert.isTrue(response != NULL, 'response should not be NULL');
    }

    @IsTest
    static void getCurrencyExchangeRatesTest(){
        Test.setMock(HttpCalloutMock.class, new API_Mall_GetForeignExchangeRate.API_Mall_GetForeignExchangeRateMock());
        Test.startTest();
        CTRL_MallDashboardWidgets.ResponseWrapper  response = CTRL_MallDashboardWidgets.getCurrencyExchangeRates('ZAR');
        Test.stopTest();
        Assert.isTrue(response != NULL, 'response should not be NULL');
    }

    @IsTest
    static void getNewsTest(){
        Test.setMock(HttpCalloutMock.class, new API_Mall_GetNews.API_Mall_GetNewsMock());
        Test.startTest();
        CTRL_MallDashboardWidgets.ResponseWrapper  response = CTRL_MallDashboardWidgets.getNews('India', 'Business', NULL);
        Test.stopTest();
        Assert.isTrue(response != NULL, 'response should not be NULL');
    }
}