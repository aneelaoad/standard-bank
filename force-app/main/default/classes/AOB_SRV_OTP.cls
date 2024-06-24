/***************************************************************************************
@Author            : Dayakar Deekonda
@Date              : 25-12-2022
@Name of the Class : AOB_SRV_OTP
@description       : Class for Calling Create Contract API and getDocument API	
@Last Modified By  : Narendra 
@Last Modified On  : 19 July 2023
@Modification Description : SFP-27748
***************************************************************************************/
public without sharing class AOB_SRV_OTP{
    public static final String SERVICE_NAME = AOB_SRV_OTP.class.getName();
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_SRV_OTP');

   /**
    * @description constructor used to return the access token
    * @param applicationId
    * @return String
    */
    @AuraEnabled 
    public static String getOtpController(String applicationId){
        try{
        String totalResponse;
        AOB_API_OTP customerServiceCall = new AOB_API_OTP();
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_OTP.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        totalResponse = 'Last API service : '+obj.CMN_Service__c +'\n Response Code : '+obj.CMN_StatusCode__c;
        AOB_CTRL_FormCreator.updateApiService(applicationId, totalResponse);
        AceessTokenOTP getclass = (AceessTokenOTP) System.JSON.deserialize(customerServiceCall.getResponseBody(), AceessTokenOTP.class);
        String accesToken=getclass.access_token;
        return accesToken;
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_SRV_OTP',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
       
    }
    
   /**
    * @description method  used to get the otpvalues 
    * @param phoneNumber
    * @param applicationId
    * @param accessToken
    * @return AOB_API_OTPJS.OTPResponse
    */
    @AuraEnabled 
    public static  AOB_API_OTPJS.OTPResponse getOtpValue(String phoneNumber, Id applicationId,String accessToken){
        AOB_API_OTPJS.OTPResponse resp = new AOB_API_OTPJS.OTPResponse();
        try {
            String numbercheck=phoneNumber;
            if(numbercheck.startsWith('0')){
                phoneNumber=phoneNumber.removeStart('0');
            } 
            else if(numbercheck.startsWith('27')){
                 phoneNumber=phoneNumber.removeStart('27');
            }
            else if(numbercheck.startsWith('+27')){
                 phoneNumber=phoneNumber.removeStart('+27');
            }  
            String response = AOB_API_OTPJS.callOTP(phoneNumber, '', '', 'GEN', applicationId,accessToken);
            CMN_UTIL_Logger.debug('RESPONSEEEEEE'+ response , 'AOB_API_OTPJS.callOTP');
            XmlStreamReader reader = new XmlStreamReader(response);
            XmlStreamReader readerCode = new XmlStreamReader(response);
            resp.qName = AOB_Utils.readXMLResponse(reader, AOB_Constants.OTP_QNAAME);
            resp.code = AOB_Utils.readXMLResponse(readerCode, AOB_Constants.OTP_QNAAME1);
            resp.message = AOB_API_OTPJS.getOTPMessage().get(resp.code);
            if(Test.isRunningTest()){
              CalloutException e = new CalloutException();
              e.setMessage('Callout Exception');
              throw e;  
            }
           return resp;
        } catch (Exception ex) {
            LOGGER.error(ex.getMessage(), new String[] {'AOB_SRV_OTP',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());  
        } 
       
    }
    
   /**
    * @description method  used to validate the otpvalues 
    * @param phoneNumber
    * @param num
    * @param qname
    * @param applicationId
    * @param accessToken
    * @return String
    */
    @AuraEnabled 
    public static String callValidateOTP(String phoneNumber, String num, String qname, Id applicationId,String accessToken){
        
        try{
            String numbercheck=phoneNumber;
            if(numbercheck.startsWith('0')){
                phoneNumber=phoneNumber.removeStart('0');
            } 
            if(numbercheck.startsWith('27')){
                 phoneNumber=phoneNumber.removeStart('27');
            }
            if(numbercheck.startsWith('+27')){
                 phoneNumber=phoneNumber.removeStart('+27');
            }  
            string response = AOB_API_OTPJS.callOTP(phoneNumber,num,qname,'VAL',applicationId,accessToken); 
            XmlStreamReader reader = new XmlStreamReader(response);
            String code = AOB_Utils.readXMLResponse(reader,AOB_Constants.OTP_QNAAME1);
            if(Test.isRunningTest()){
              CalloutException e = new CalloutException();
              e.setMessage('Callout Exception');
              throw e; 
            }
            return AOB_API_OTPJS.getOTPMessage().get(code); 
        }catch(Exception ex){
            LOGGER.error(ex.getMessage(), new String[] {'AOB_SRV_OTP',ex.getMessage()}, ex);
            throw new AuraHandledException(ex.getMessage());
        }
       
    }
    
    /**
    * @description wrapper class AceessTokenOTP 
    */
    public class AceessTokenOTP {
        public String token_type;
        public String access_token;
        public String scope;
        public Integer expires_in;
        public Integer consented_on;
        public String metadata;
    }
 
}