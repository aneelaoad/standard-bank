/**
 * ACTION   DATE        OWNER         COMMENT
 * Created  20-01-2023  Dayakar Deekonda   Created to get the System token in place of ping token for the guest users
 * Updated  20-01-2023  Dayakar Deekonda             
*/
public class AOB_API_SystemToken extends AOB_API_RestBaseOutboundPing{
    
    /*
    * @description creates a mock response for http calls
    * @param  request
    * @param response
    */
    public static final String SERVICE_NAME = AOB_API_SystemToken.class.getName();
    public static String AOB_API_SystemToken()
    {   
        CMN_WebserviceSetting__mdt setting=[select id, CMN_ApiKey__c, CMN_ClientID__c, CMN_Client_Secret__c, CMN_Path__c, DeveloperName from CMN_WebserviceSetting__mdt where DeveloperName=:SERVICE_NAME];
        Http h  = new Http();
        HttpRequest req  = new HttpRequest();

        req.setEndpoint( setting.CMN_Path__c );
        req.setMethod(AOB_Constants.API_METHOD_POST);
        req.setHeader(AOB_Constants.API_CONTENT_TYPE, AOB_Constants.API_CONTENTTYPE_URL);
        
         String  payload=AOB_Constants.GRANT_TYPE+EncodingUtil.urlEncode(AOB_Constants.CLIENT_CREDENTIALS,AOB_Constants.UTF8)+ AOB_Constants.CLIENTID + EncodingUtil.urlEncode(setting.CMN_ClientID__c,AOB_Constants.UTF8)+AOB_Constants.CODEVERIFIER+EncodingUtil.urlEncode(setting.CMN_ApiKey__c,AOB_Constants.UTF8)+AOB_Constants.CLIENTSECRET+EncodingUtil.urlEncode(setting.CMN_Client_Secret__c,AOB_Constants.UTF8);
        req.setBody(payload);
        HttpResponse res = h.send(req); 
        AOB_GetAccessToken getclass = (AOB_GetAccessToken) System.JSON.deserialize(res.getBody(), AOB_GetAccessToken.class); 
        return  getclass.access_token;  
    } 

}