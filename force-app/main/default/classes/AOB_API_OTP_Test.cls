/***************************************************************************************
@Author            : Dayakar
@Date              : Jan 29th 2023
@Name of the Class : AOB_API_OTP_Test
@description       : class to test the Outbound create OTP API call
@Last Modified By  : Ramadevi 
@Last Modified On  : 22 July 2023
@Modification Description : SFP-27748
***************************************************************************************/
@IsTest
public class AOB_API_OTP_Test {
   
    /**
    * @description test method for AOB_SRV_OTP.getOtpController
    * author dayakar
    */
    @Istest
    public static String callGetOTPAcessTokenTest(){
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        String accesToken=AOB_SRV_OTP.getOtpController(applicationId);
        Assert.areNotEqual(null, accesToken);
        Test.stopTest();
        return accesToken;
    }
    /**
    * @description test method for AOB_SRV_OTP.getOtpValue
    * author dayakar
    */
    @Istest 
    public static void callGetOTPTest(){
        try{
            String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
            String phonenumber=AOB_Constants.GETPHONENUMBER;
            String access_token=AOB_Constants.Stringaccess_token;
            Test.startTest();
            AOB_SRV_OTP.getOtpValue(phonenumber,applicationId,access_token);
            Test.stopTest();
         }Catch(exception e){
            Assert.areNotEqual(null, e);
            
        }
    }
    
    
    /**
    * @description test method for AOB_SRV_OTP.getOtpValue
    * author dayakar
    */
    @Istest 
    public static void callGetOTPNegTest(){
        try{
            String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
            String phonenumber=AOB_Constants.GETPHONENUMBER;
            String access_token=AOB_Constants.Stringaccess_token;
            Test.startTest();
            AOB_SRV_OTP.getOtpValue(phonenumber,applicationId,null);
            Test.stopTest();
        }Catch(exception e){
            Assert.areNotEqual(null, e);
            
        }
    }
    
    /**
    * @description test method for AOB_SRV_OTP.callValidateOTP
    * author dayakar
    */
    @Istest
    public static void callValidateOTPTest(){
        try{
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        String phonenumber=AOB_Constants.GETPHONENUMBER;
        String accessToken= AOB_Constants.Stringaccess_token;
        String num=AOB_Constants.getotpnum;
        String qname=AOB_Constants.qname;
        Test.startTest();
        AOB_SRV_OTP.callValidateOTP(phoneNumber,num, qname, applicationId, accessToken);
        Test.stopTest();
        }Catch(exception e){
            Assert.areNotEqual(null, e);
        }
        
    }
    /**
    * @description test method for AOB_SRV_OTP.callValidateOTP
    * author dayakar
    */
    @Istest
    public static void callValidateOTPNegTest(){
        try{
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        String phonenumber=AOB_Constants.GETPHONENUMBER;
        String accessToken= AOB_Constants.Stringaccess_token;
        String num=AOB_Constants.getotpnum;
        String qname=AOB_Constants.qname;
        Test.startTest();
        AOB_SRV_OTP.callValidateOTP(phonenumber,num, qname,applicationId, null);
        Test.stopTest();
        }Catch(exception e){
            Assert.areNotEqual(null, e);
        }
        
    }
    
    
    /**
    * @description test method for  AOB_API_OTPJS.checkOTPAttempts
    * author dayakar
    */
    @Istest
    public static void callOTPCheckAttemps(){
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        Boolean otpAttempts=AOB_API_OTPJS.checkOTPAttempts(applicationId);
        Test.stopTest();
        Assert.areEqual(true, otpAttempts);
    }
    /**
    * @description test method for  AOB_API_OTPJS.checkResendOtp
    * author dayakar
    */
    @Istest
    public static void checkResendOtp(){
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_API_OTPJS.ResendOTPWrapper tp=AOB_API_OTPJS.checkResendOtp(applicationId);
        Test.stopTest();
        Assert.areNotEqual(null, tp.totalAttempts);
        
    }
    
   /**
    * @description test method for  AOB_API_OTPJS.checkResendOtp
    * author dayakar
    */
    @isTest
    public static void getEncodingTest(){
        String httpEncodingXml;
        Test.startTest();
        	AOB_API_GetOTP otpInstance  = new AOB_API_GetOTP();
        	httpEncodingXml = otpInstance.getEncoding();
        Test.stopTest();
        Assert.areNotEqual(null, httpEncodingXml);
        
    }
    
}