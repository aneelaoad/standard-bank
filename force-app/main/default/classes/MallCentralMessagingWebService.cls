/**
 * 
 * @description MallCentralMessagingWebService
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallCentralMessagingWebService {    
    /**
     * 
     * @description CMSSMSRequest
     */
    public class CMSSMSRequest {
        public String senderAddress;
        public String content;
        public String reciepientAddress;
    }

    /**
     * 
     * @description sendSMSToCustomer
     * @param requestBodyObject CMSSMSRequest
     * @return  `Boolean`
     */
    public static Boolean sendSMSToCustomer(CMSSMSRequest requestBodyObject) {
        try {
            API_Mall_CentalMessagingService stub = new API_Mall_CentalMessagingService(requestBodyObject);
            CMN_WebserviceCallQueue__c queueRecord = CMN_DAL_DataFactory.newOutboundWebserviceQueue(API_Mall_CentalMessagingService.SERVICE_NAME);
            stub.process(queueRecord); 
            return (stub.getStatusCode() == 200 ? true : false);
        } catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('MallCentralMessagingWebService.sendSMSToCustomer', e);
        }
    }
}