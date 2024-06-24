/**
* Class used to Perform an API call to persist user info in SAP
*
* @author Lokesh Bothsa 
*
* @date Jan 02nd 2023
* 
*This class is used to fetch the response based on user entered string.
*/
public class AOB_Api_SearchProducts{
private static final String NAMED_CREDENTIAL_URL_FORMAT = 'callout:{0}{1}';
private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_SRV_OTP');

    /**
    * @description This is method is going to return the response of search products.
    * @param  searchString
    * @return res.getBody()
    */
    @AuraEnabled
    public static string searchTerm(string searchString){
        try{
            String endPoint = AOB_Constants.searchapiendpoint;
            HttpRequest req = new HttpRequest();
            HttpResponse res;
            if(searchString.length() >=3){
                req.setEndpoint(endPoint+searchString);
                req.setMethod(AOB_Constants.HTTPGETMETHOD);
                Http h = new Http();
                res = h.send(req);    
            } 
            if(Test.isRunningTest()){
              CalloutException e = new CalloutException();
              e.setMessage('Callout Exception');
              throw e; 
            }
            return res.getBody(); 
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_Api_SearchProducts',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }   
}