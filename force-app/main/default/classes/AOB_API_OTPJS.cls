/***************************************************************************************
@Author            : Dayakar
@Date              : 25-12-2022
@Name of the Class : AOB_SRV_GetDigital
@description       : Class for Get OTP and validate OTP API	
@Last Modified By  : Narendra 
@Last Modified On  : 19 July 2023
@Modification Description : SFP-27748
***************************************************************************************/
public without sharing class AOB_API_OTPJS {

    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('AOB_CTRL_FormCreator');
    
    public static final String SERVICE_NAME = AOB_API_OTPJS.class.getName();
    public static final String ERR_2001 = 'Technical error. Please try again later';
    public static final String ERR_1001 = 'Invalid OTP';
    public static final String ERR_1021 = 'OTP regenerated after 3 invalid attempts';
    public static final String ERR_1022 = 'for generate - invalid delivery type for the others not error - returned after 3rd incorrect OTP entered and new one sent';
    public static final String ERR_1023 = 'Your OTP has expired and a new one has been sent';
    public static final String ERR_1025 = 'NO OTP SPECIFIED VALIDATE FUNCTION.';
    public static final String ERR_1026 = 'You have Exceeded the number of attempts you can enter your OTP. Please contact your branch.';
    public static final String ERR_1030 = 'NO QNAME SPECIFIED VALIDATE*DELETE FUNCTION';
    public static final String ERR_1040 = 'INVALID MESSAGE TYPE SPECIFIED';
    public static final String ERR_2042 = 'INVALID FUNCTION SPECIFIED';
    public static final String ERR_4001 = 'INVALID CARD NUMBER SPECIFIED';
    public static final String ERR_7666 = 'There is a possible security issue with your profile. Please call us on 0800 222 050 (South Africa) or +27 10 249 0070 (International) to confirm your details.';

    /**
    * @description callOTP
    * @param cellPhone
    * @param num
    * @param qName
    * @param function 
    * @param applicationId
    * @param accessToken
    * @return string
    */
    public static string callOTP(
        String cellPhone,
        String num,
        String qName,
        String function,
        Id applicationId,
        String accessToken
    ){
        
        AOB_API_GetOTP customerServiceCall = new AOB_API_GetOTP();  
        String productCat = 'Business Account';
        String code = '27';
        String totalResponse;
        String otpResponseCode;
        String otpResponseMessage;
        
        customerServiceCall.jsonBody = customerServiceCall.jsonBody.replace(
            '{OTP_FUNCTION_NAME}',
            function
        );
        customerServiceCall.jsonBody = customerServiceCall.jsonBody.replace(
            '{OTP_DELIVERY_TYPE}',
            'S'
        );
        customerServiceCall.jsonBody = customerServiceCall.jsonBody.replace(
            '{OTP_CONTRY_CODE}',
            code
        );
        customerServiceCall.jsonBody = customerServiceCall.jsonBody.replace(
            '{OTP_CELL_NO}',
            cellPhone
        );
        customerServiceCall.jsonBody = customerServiceCall.jsonBody.replace(
            '{OTP_OTP}',
            num
        );
        customerServiceCall.jsonBody = customerServiceCall.jsonBody.replace(
            '{OTP_QNAME}',
            qName
        );
        customerServiceCall.jsonBody = customerServiceCall.jsonBody.replace(
            '{OTP_EMAIL}',
            ''
        );
        customerServiceCall.jsonBody = customerServiceCall.jsonBody.replace(
            '{OTP_CONTENT}',
            productCat
        );
        
        customerServiceCall.accessToken=accessToken;
        CMN_WebserviceCallQueue__c obj=CMN_DAL_DataFactory.newOutboundWebserviceQueue(AOB_API_GetOTP.SERVICE_NAME);
        customerServiceCall.process(obj);
        insert obj;
        String result = customerServiceCall.responseBody;
        XmlStreamReader readerCode = new XmlStreamReader(result);
        otpResponseCode = AOB_Utils.readXMLResponse(readerCode, AOB_Constants.OTP_QNAAME1);
        otpResponseMessage = getOTPMessage().get(otpResponseCode);
        totalResponse = 'Last API service : '+obj.CMN_Service__c +'\n Response Code : '+obj.CMN_StatusCode__c+'\n OTP Response Code : '+otpResponseCode+'\n OTP Response Message : '+otpResponseMessage;
        AOB_CTRL_FormCreator.updateApiService(applicationId, totalResponse);       
        return result;        
    } 

    /**
    * @description getOTPMessage
    * @return Map<String, String>
    */
    public static Map<String, String> getOTPMessage() {
        Map<String, String> otpMap = new Map<String, String>();
        otpMap.put('0000', 'OK');
        otpMap.put('2001', ERR_2001);
        otpMap.put('1001', ERR_1001);
        otpMap.put('1021', ERR_1021);
        otpMap.put('1022', ERR_1022);
        otpMap.put('1023', ERR_1023);
        otpMap.put('1025', ERR_1025);
        otpMap.put('1026', ERR_1026);
        otpMap.put('1030', ERR_1030);
        otpMap.put('1040', ERR_1040);
        otpMap.put('2042', ERR_2042);
        otpMap.put('4001', ERR_4001);
        otpMap.put('7666', ERR_7666);
        return otpMap;
    }

     /**
    * @description Method used to check if the user exceeded the number of attempts to resend otp
    * @param applicationId
    * @return ResendOTPWrapper
    */
    @AuraEnabled
    public static ResendOTPWrapper checkResendOtp(Id applicationId) {
        final String attemptsToResendOTP = 'Attempts_To_Resend_Otp';
        
        ResendOTPWrapper rsotp= new ResendOTPWrapper();        
        AOB_Application__c applicationFromDB = [
            SELECT Id, AOB_TECH_OTPAttempts__c
            FROM AOB_Application__c
            WHERE Id = :applicationId
        ];
        final List<AOB_AppSettings__mdt> techSettings = [
            SELECT MasterLabel, AOB_Value__c
            FROM AOB_AppSettings__mdt
            WHERE DeveloperName = :attemptsToResendOTP
        ];
        if (applicationFromDB.AOB_TECH_OTPAttempts__c ==Integer.valueOf(techSettings[0].AOB_Value__c)) {
            
            rsotp.status=true;
            rsotp.totalAttempts=Integer.valueOf(techSettings[0].AOB_Value__c);
            rsotp.userAttempts=Integer.valueOf(applicationFromDB.AOB_TECH_OTPAttempts__c);
            return rsotp;
        }else{
            
            applicationFromDB.AOB_TECH_OTPAttempts__c=applicationFromDB.AOB_TECH_OTPAttempts__c+1;
            Update applicationFromDB;
            rsotp.status=false;
            rsotp.totalAttempts=Integer.valueOf(techSettings[0].AOB_Value__c);
            rsotp.userAttempts=Integer.valueOf(applicationFromDB.AOB_TECH_OTPAttempts__c);
            return rsotp;
        }
        
        
      
    }
           
    /** 
     * @description Method used to check if the user can call OTP API to validate OTP
     * @param applicationId
     * @return Boolean
    */
    public static Boolean checkOTPAttempts(Id applicationId) {
        final String maxAttempts = 'Max_Attempts';
        AOB_Application__c aoblist=[select id ,AOB_TECH_OTPAttempts__c from AOB_Application__c where id=:applicationId];
        final List<AOB_AppSettings__mdt> techSettings = [
            SELECT MasterLabel, AOB_Value__c
            FROM AOB_AppSettings__mdt
            WHERE DeveloperName = :maxAttempts
        ];
        if(aoblist.AOB_TECH_OTPAttempts__c < Decimal.valueOf(techSettings[0].AOB_Value__c)){
            aoblist.AOB_TECH_OTPAttempts__c=aoblist.AOB_TECH_OTPAttempts__c+1;
            Update aoblist;
            return true;
        }
        return false;
    }
    
   
   /**  
    * @description Wrapper class for OTPResponse
    */
    public class OTPResponse {
        /**
        * @description code
        * @return String
        */
        @AuraEnabled
        public String code {get;set;}
        /**
        * @description qName
        * @return String
        */
        @AuraEnabled
        public String qName {get;set;}
        /**
        * @description message
        * @return String
        */
        @AuraEnabled
        public String message {get;set;}
    }
    
    /**
    * @description Hello World
    */
    public class ResendOTPWrapper{
        /**
        * @description status
        * @return Boolean
        */
        @AuraEnabled
        public Boolean status {get;set;}
        /**
        * @description totalAttempts
        * @return Integer
        */
        @AuraEnabled
        public Integer totalAttempts {get;set;}
        /**
        * @description userAttempts
        * @return Integer
        */
        @AuraEnabled
        public Integer  userAttempts {get;set;}
    }
    
}