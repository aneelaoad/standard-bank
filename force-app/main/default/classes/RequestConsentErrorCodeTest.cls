/**
 *
 * @author Emmanuel Mulea Nocks(BlueSky)
 * @date June 2020
 * @description test class for RequestConsentErrorCode
 */
@isTest(isParallel=true)
public class RequestConsentErrorCodeTest {
    
    private static final List<Integer> CODES = new List<Integer>{200,204,400,403,401,408,500,503};
        
        @IsTest
        private static void testGetDefinition(){
            String lastErrorMsg;
            String lastErrorDesc;
            
            
            Test.startTest();
            for(Integer x:CODES){
                RequestConsentErrorCode.CallOutErrorWrapper callWrapper = new RequestConsentErrorCode.CallOutErrorWrapper();
                lastErrorMsg =  RequestConsentErrorCode.getDefinition(x);
                lastErrorDesc =RequestConsentErrorCode.getDescription(x);
                callWrapper.httpCode = String.valueOf(x);
                callWrapper.httpMessage = lastErrorMsg;
                callWrapper.moreInformation = lastErrorDesc;
                RequestConsentErrorCode.getcalloutError(callWrapper);
            }
            
            Test.stopTest();
            System.assertEquals('Service Unavailable', lastErrorMsg);
            System.assertNotEquals(null, lastErrorDesc);
        }
    
    @IsTest
    private static void testGetcalloutError(){ 
        CalloutException e = new CalloutException('Service Unavailable');
        HttpResponse res = new HttpResponse();
        res.setStatusCode(503);
        Test.startTest();
        string fullMsg = 'Error Message: '+e.getMessage()+' Error Code: '+res.getStatusCode()+' Code Definition :'+RequestConsentErrorCode.getDefinition(503)+' Code Descriotion:'+
            RequestConsentErrorCode.getDescription(503);
        String errorMsg = RequestConsentErrorCode.getcalloutError(e, res);
        System.assertEquals(fullMsg, errorMsg);
        Test.stopTest();
    }   
    
}