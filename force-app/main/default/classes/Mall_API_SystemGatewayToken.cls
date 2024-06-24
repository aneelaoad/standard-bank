/**
 * 
 * @description Mall_API_SystemGatewayToken
 * @author Ankit Kumar
 * @since 
 */
public class Mall_API_SystemGatewayToken extends AOB_API_RestBaseOutboundPing{
    private static final String SERVICE_NAME = API_Mall_AuthSBAPIGateway.class.getName();
    
    /**
    * @description getGatewayAccessToken
    * @param scope String
    * @return String
    */
    public static String getGatewayAccessToken(String scope)
    {  
        try {
            API_Mall_AuthSBAPIGateway stub = new API_Mall_AuthSBAPIGateway(scope);
            CMN_WebserviceCallQueue__c queueRecord = CMN_DAL_DataFactory.newOutboundWebserviceQueue(API_Mall_AuthSBAPIGateway.SERVICE_NAME);
            stub.process(queueRecord); 
            MALL_AUTH_PingCustomer.DTO_Access dtoAccess = (MALL_AUTH_PingCustomer.DTO_Access) System.JSON.deserialize(stub.getResponseBody(), MALL_AUTH_PingCustomer.DTO_Access.class);
            return (Test.IsRunningTest()) ? Mall_API_SystemGatewayToken.getAccessTokenMock() : dtoAccess.access_token; 
        } catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('Mall_API_SystemGatewayToken.getGatewayAccessToken', e);
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