/**
 * 
 * @description Mall_API_SystemGatewayToken
 * @author Ankit Kumar
 * @since 
 */
public class MALL_AUTH_SbsaAPIGateway extends AOB_API_RestBaseOutboundPing{
    private static final String SERVICE_NAME = API_Mall_SbsaAPIGateway.class.getName();
    
    /**
    * @description getGatewayAccessToken
    * @param scope String
    * @return String
    */
    public static String getGatewayAccessToken(String scope)
    {  
        try {
            API_Mall_SbsaAPIGateway stub = new API_Mall_SbsaAPIGateway(scope);
            CMN_WebserviceCallQueue__c queueRecord = CMN_DAL_DataFactory.newOutboundWebserviceQueue(API_Mall_SbsaAPIGateway.SERVICE_NAME);
            stub.process(queueRecord); 
            CMN_DAL_SObjectDomain.insertDBObject(queueRecord);
            MALL_AUTH_PingCustomer.DTO_Access dtoAccess = (MALL_AUTH_PingCustomer.DTO_Access) System.JSON.deserialize(stub.getResponseBody(), MALL_AUTH_PingCustomer.DTO_Access.class);
            return (Test.IsRunningTest()) ? MALL_AUTH_SbsaAPIGateway.getAccessTokenMock() : dtoAccess.access_token; 
        } catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('MALL_AUTH_SbsaAPIGateway.getGatewayAccessToken', e);
        }
    }
    
    /**
    * 
    * @description getAccessTokenMock
    * @return String 
    */
    @TestVisible
    private static String getAccessTokenMock() {
        return MALL_OAuth_Util.generateRandomString(15);
    }
}