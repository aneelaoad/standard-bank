/**
* 
* @description CTRL_MallDashboardWidgets
* @author Ankit Kumar
* @since  
*/
public class CTRL_MallDashboardWidgets {
    
    /**
    * @description getLocationTime
    * @param location String
    * @return ResponseWrapper 
    */
    @AuraEnabled(cacheable=true)
    public static ResponseWrapper getLocationTime(String location) {
        try {
            API_Mall_GetWorldTime stub = new API_Mall_GetWorldTime(location);
            CMN_WebserviceCallQueue__c queueRecord = CMN_DAL_DataFactory.newOutboundWebserviceQueue(API_Mall_GetWorldTime.SERVICE_NAME);
            stub.process(queueRecord); 
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(stub.getResponseBody());
            ResponseWrapper wrapperObj = new ResponseWrapper();
            wrapperObj.statusCode = stub.getStatusCode();
            wrapperObj.message = response;
            return wrapperObj;
        } catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('CTRL_MallDashboardWidgets.getLocationTime', e);
        }
    }

    /**
    * @description getWeather
    * @param location String
    * @return ResponseWrapper 
    */
    @AuraEnabled(cacheable=true)
    public static ResponseWrapper getWeather(String location) {
        try {
            API_Mall_GetWeather stub = new API_Mall_GetWeather(location);
            CMN_WebserviceCallQueue__c queueRecord = CMN_DAL_DataFactory.newOutboundWebserviceQueue(API_Mall_GetWeather.SERVICE_NAME);
            stub.process(queueRecord); 
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(stub.getResponseBody());
            ResponseWrapper wrapperObj = new ResponseWrapper();
            wrapperObj.statusCode = stub.getStatusCode();
            wrapperObj.message = response;
            return wrapperObj;
        } catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('CTRL_MallDashboardWidgets.getWeather', e);
        }
    }

    /**
    * @description getCurrencyExchangeRates
    * @param baseCode String
    * @return ResponseWrapper 
    */
    @AuraEnabled(cacheable=true)
    public static ResponseWrapper getCurrencyExchangeRates(String baseCode) {
        try{
            API_Mall_GetForeignExchangeRate stub = new API_Mall_GetForeignExchangeRate(baseCode);
            CMN_WebserviceCallQueue__c queueRecord = CMN_DAL_DataFactory.newOutboundWebserviceQueue(API_Mall_GetForeignExchangeRate.SERVICE_NAME);
            stub.process(queueRecord); 
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(stub.getResponseBody());
            ResponseWrapper wrapperObj = new ResponseWrapper();
            wrapperObj.statusCode = stub.getStatusCode();
            wrapperObj.message = response;
            return wrapperObj;
        }
        catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('CTRL_MallDashboardWidgets.getCurrencyExchangeRates', e);
        }
    }

    /**
    * @description getNews
    * @param country String
    * @param category String
    * @param sources String
    * @return ResponseWrapper 
    */
    @AuraEnabled(cacheable=true)
    public static ResponseWrapper getNews(String country,String category, String sources){
        try {
            API_Mall_GetNews stub = new API_Mall_GetNews(country, category, sources);
            CMN_WebserviceCallQueue__c queueRecord = CMN_DAL_DataFactory.newOutboundWebserviceQueue(API_Mall_GetNews.SERVICE_NAME);
            stub.process(queueRecord); 
            Map<String, Object> response = (Map<String, Object>) JSON.deserializeUntyped(stub.getResponseBody());
            ResponseWrapper wrapperObj = new ResponseWrapper();
            wrapperObj.statusCode = stub.getStatusCode();
            wrapperObj.message = response;
            return wrapperObj;
        } catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('CTRL_MallDashboardWidgets.getNews', e);
        }
    }
    
    /**
    * 
    * @description ResponseWrapper 
    */
    public class ResponseWrapper {
        /**
        * 
        * @description http response status code  
        */
        @AuraEnabled
        public integer statusCode{get;set;}
        /**
        * 
        * @description http response body 
        */
        @AuraEnabled
        public Map<string,Object> message{get;set;}
    }
    
}