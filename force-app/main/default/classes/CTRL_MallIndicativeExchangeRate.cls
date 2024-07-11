public with sharing class CTRL_MallIndicativeExchangeRate {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CTRL_MallIndicativeExchangeRate');

    /**
    * @description getCurrencyExchangeRates
    * @param baseCode String
    * @return DTO_IndicativeRatesResponse 
    */
    @AuraEnabled
    public static DTO_IndicativeRatesResponse getCurrencyExchangeRates(String basePair, List<String> searchPairs) {
        try {
            List<String> currencyPairs = new List<String>();
            currencyPairs.add(basePair);
            currencyPairs.addAll(searchPairs);
            API_Mall_GetForeignExchangeRate stub = new API_Mall_GetForeignExchangeRate(currencyPairs);
            CMN_WebserviceCallQueue__c queueRecord = CMN_DAL_DataFactory.newOutboundWebserviceQueue(API_Mall_GetForeignExchangeRate.SERVICE_NAME);
            stub.process(queueRecord); 
            CMN_DAL_SObjectDomain.insertDBObject(queueRecord);
            DTO_IndicativeRatesResponse response = (DTO_IndicativeRatesResponse)  System.JSON.deserialize(stub.getResponseBody(), DTO_IndicativeRatesResponse.class);
            return response;
        } 
        catch(Exception e) {
            LOGGER.error('CTRL_MallIndicativeExchangeRate.getCurrencyExchangeRates', 'currency exchange rate', e);
            throw new AuraHandledException(e.getMessage());        
        }
    }

    public class DTO_IndicativeRatesResponse {
        public List<DTO_Instrumentation> instrumentation;
        public List<DTO_IndicativeRate> indicativeRates;
    }

	public class DTO_Instrumentation {
		public String name;
		public string timestamp;
	}

	public class DTO_IndicativeRate {
		public String currencyPair;	
		public Double bidRate;	
		public Double midRate;	
		public Double askRate;	
		public String lastUpdatedTimestamp;
	}
}