@isTest
public with sharing class AOB_UtilsTest {
    
    /**
* @description Test setup method to insert all Test data   
*/
    @TestSetup
    public static void testSetUp(){
        User communityUser = AOB_DAL_TestFactory.createCommunityUser();
    }
    
    /**
* Test method for AOB_Utils.formatDate
* Test formatting of date time e.g. 2022-01-01 01:01:01
*/
    @IsTest
    private static void formatDate1_Test(){        
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        
        DateTime DT = system.today();
        String datTime = string.valueOf(dt);
        String str = dt.day() + ' ' + dt.format('MMMMM') + ' ' + dt.year();
        
        System.runAs(communityUser){
            Test.startTest();
            String dateStr = AOB_Utils.formatDate(datTime);
            Test.stopTest();
            Assert.areEqual(str,dateStr);
        }  
    }
    
    /**
* Test method for AOB_Utils.formatDate
* Test formatting of date time e.g. 2022-01-01T01:01:01
*/
    @IsTest
    private static void formatDate2_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        
        DateTime DT = system.today();
        String datTime = string.valueOf(dt);
        datTime = datTime.replace(' ', 'T');
        String str = dt.day() + ' ' + dt.format('MMMMM') + ' ' + dt.year();
        
        System.runAs(communityUser){
            Test.startTest();
            String dateStr = AOB_Utils.formatDate(datTime);
            Test.stopTest();
            Assert.areEqual(str,dateStr);
        }  
    }
    
    /**
* Test method for AOB_Utils.formatDate
* Test formatting of date time e.g. 2022-01-01 01:01:01. (period at the end)
*/
    @IsTest
    private static void formatDate3_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        
        DateTime DT = system.today();
        String datTime = string.valueOf(dt) + '.';
        String str = dt.day() + ' ' + dt.format('MMMMM') + ' ' + dt.year();
        
        System.runAs(communityUser){
            Test.startTest();
            String dateStr = AOB_Utils.formatDate(datTime);
            Test.stopTest();
            Assert.areEqual(str,dateStr);
        }  
    }
    
    /**
* Test method for AOB_Utils.remainingDays
*/
    @IsTest
    private static void remainingDays_Test(){
        String datTime = '2021-12-01 09:09:09';
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        
        System.runAs(communityUser){
            Test.startTest();
            integer daysBtwn = AOB_Utils.remainingDays(datTime);
            Test.stopTest();
            Assert.areNotEqual(0,daysBtwn,'remaining  days not 0');
        }  
    }
    
    /**
* Test method for AOB_Utils.generateGuid & AOB_Utils.formatGUID
*/
    @IsTest
    private static void generateGUID_Test(){      
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        
        System.runAs(communityUser){
            Test.startTest();
            String guid = AOB_Utils.generateGUID();
            String fGuid = AOB_Utils.formatGUID(guid);
            Test.stopTest();
            Assert.areEqual(guid.ToLowercase(),fGUID);
        }  
    }
    
    /**
* Test method for AOB_Utils.getApplicationsMap
*/
    @IsTest
    private static void getApplicationsMap_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = AOB_DAL_TestFactory.createApplication(communityUser);
        
        list<CMN_WebserviceCallQueue__c> queue = new list<CMN_WebserviceCallQueue__c>{new CMN_WebserviceCallQueue__c
            (CMN_Service__c='XXXX', CMN_TriggeringObjectId__c=newApplication.id)};
                insert queue;
        
        System.runAs(communityUser){
            Test.startTest();
            Map<Id, AOB_Application__c> apps = AOB_Utils.getApplicationsMap(queue);
            Test.stopTest();
            Assert.areEqual(true,apps.containsKey(newApplication.id));
        }  
    }
    
    /**
* Test method for AOB_Utils.getBusinessSegmentRecordTypeByLabel
*/
    @IsTest
    private static void getBusinessSegmentRecordTypeByDevNameTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        System.runAs(communityUser){
            Test.startTest();
            string label = 'Enterprise';
            AOB_BusinessSegment__mdt mdt = AOB_Utils.getBusinessSegmentRecordTypeByLabel(label);
            Test.stopTest();
            Assert.areNotEqual(null,mdt,'Business Segment successfully retrieved');
        }  
    }
    
    /**
* Test method for AOB_Utils.parseJWT
* the parsed JWT must be not be empty
*/
    @IsTest
    private static void parseJWT_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        String jwt = 'eyJraWQiOiJraWQzNDU2NzgiLCJhbGciOiJSUzI1NiJ9.eyJqdGkiOiI3N2I1ZGFhNS0xY2E1LTQ1YWYtYmRkZi03N2UxMTZhYTBmOWYiLCJpc3MiOiJodHRwczovL2FwaWdzYS5zdGFuZGFyZGJhbmsuY28uemEiLCJzdWIiOiJTQTAwMDI3M0B6YS5zYmljZGlyZWN0b3J5LmNvbSIsImF1ZCI6Imh0dHBzOi8vZXNiZHB1LnN0YW5kYXJkYmFuay5jby56YSIsImV4cCI6MTY0MjQ5NzA3MywiaWF0IjoxNjQyNDkzNDczLCJhdXRoLXRpbWUiOjE2NDI0OTM0NzEsIlBVQkxJQy1DTEFJTVMiOnsidXNlci1pZCI6IkM4MzkzODMifX0.hhIQgUHG5zEGCwGfeOcZY39oONxa5gaTn-63UQEPTeyCD_3skcgxwkSJj63gmW95ckKFPr72tkzVrHmDBmJO8evn5I5ZOn674m46v6c8eBbpzDZA0UZdmTtVjKk0EKEXaQ0go6xJ5Wj5Q5BDHxXCe3qjs-JcO5JOIBF-xdbYKwH2y0G6d6qd2xDF7i_8ku_QprEx3i0rU3MwW4bfKJUQ9NhoAj4TWwueZT-PWtkLNBiK8vfrzFgZ28na7p4WNgZZgss3QD1Oz-qW0YzcENp35cg6g9ZSI7-XyvEvt7WcXmhl5VB8dB53ALhyt3ljq_2t1RKkVgJPJB1cm2ceaEP5qA';
        System.runAs(communityUser){
            Test.startTest();
            String str = AOB_Utils.parseJWT(jwt);
            Test.stopTest();
            Assert.areNotEqual(null,str,'successful-parsed JWT not empty');
        }  
    }
    
    /**
* Test method for AOB_Utils.parseJWT
* the parsed JWT must be empty (exception testing)
*/
    @IsTest
    private static void parseJWTEmpty_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        System.runAs(communityUser){
            Test.startTest();
            String str = AOB_Utils.parseJWT('');
            Test.stopTest();
            Assert.areEqual('',str);
        }  
    }
    
    /**
* Test method for AOB_Utils.getObjectUrl
* get URL of newly created object
*/
    @IsTest
    private static void getObjectUrl_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = AOB_DAL_TestFactory.createApplication(communityUser);
        
        System.runAs(communityUser){
            Test.startTest();
            String str = AOB_Utils.getObjectUrl(newApplication);
            Test.stopTest();
            Assert.areEqual(true,str.contains(newApplication.id));
        }  
    }
    
    /**
* Test method for getOnboardingSettings - check null link is returned
*/
    @IsTest
    private static void getOnboardingSettings_Test(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        
        System.runAs(communityUser){
            Test.startTest();
            boolean fail = false;
            try{
                AOB_OnboardingSetting__mdt settings = AOB_Utils.getOnboardingSettings(null);
            } 
            catch(Exception e){
                fail = true;
            }
            Test.stopTest();
            Assert.areEqual(true,fail);
        }  
    }
    
    /**
* Test method for getAllPicklistEntriesCodes
* Check that picklist entries are retrieved
*/
    @IsTest
    private static void getAllPicklistEntriesCodes_Test(){
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            AOB_ReferencedData__c record1 = new AOB_ReferencedData__c(AOB_Code__c ='test1', Name='testName1', AOB_isActive__c= TRUE, AOB_SAPField__c='PMIFP_RLTNP', AOB_Language__c='en_US');
            insert record1;
            AOB_ReferencedData__c record2 = new AOB_ReferencedData__c(AOB_Code__c ='test2', Name='testName2', AOB_isActive__c= TRUE, AOB_SAPField__c='PMIFP_RLTNP', AOB_Language__c='en_US');
            insert record2;
            List<String> sapFields = new List<String>();
            sapFields.add('PMIFP_RLTNP');
            Test.startTest();
            Map<String, List<AOB_DTO_SelectOption>> entries = AOB_Utils.getAllPicklistEntriesCodes(sapFields);
            Test.stopTest();
            Assert.areNotEqual(entries, null,'Test pass');
       }
    }
    
    /**
* Test method for getAllPicklistEntriesCodes
* Exception - fields are empty
*/
    @IsTest
    private static void getAllPicklistEntriesCodesEmpty_Test(){      
        list<String> mriTables = new List<String>();
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        System.runAs(communityUser){
            Test.startTest();
            Map<String, List<AOB_DTO_SelectOption>> pickLists = new Map<String, List<AOB_DTO_SelectOption>>();
            try{
                pickLists = AOB_Utils.getAllPicklistEntriesCodes(mriTables);
            }
            catch(exception e){
                Assert.areEqual(true, pickLists.isEmpty());
            }
            Test.stopTest(); 
        }  
    }
    
    /**
* Test method for getAllPicklistEntriesCodes
* Reference data is empty
*/
    @IsTest
    private static void getAllPicklistEntriesCodesError_Test(){      
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        
        list<AOB_FlowScreen__c> screen = AOB_DAL_TestFactory.createScreen();
        list<AOB_ScreenSection__c> section = AOB_DAL_TestFactory.createSection(screen[0].id);        
        list<AOB_field__c> field = AOB_DAL_TestFactory.createFields(section[0].id);
        
        List<String> mriTables=new List<String>();
        for(AOB_Field__c  fld: field){
            mriTables.add(fld.AOB_MRITable__c );
        }
        
        System.runAs(communityUser){
            Test.startTest();
            boolean failed = false;
            try{
                Map<String, List<AOB_DTO_SelectOption>> pickLists = AOB_Utils.getAllPicklistEntriesCodes(mriTables);
            }
            catch(exception e){
                failed = true;
            }
            Test.stopTest(); 
            Assert.areEqual(true, failed);
        }  
    }
    
    
    /**
     * @description  This method is used to test readXMLResponse
     */
    @isTest
    private static void getreadXMLResponseTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            String validResponse = '<?xml version="1.0" encoding="UTF-8"?><SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ver="http://www.VERSIONR.VBOTPBRI.Request.com" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><SOAP-ENV:Body><VERSIONROperationResponse xmlns="http://www.VERSIONR.VBOTPBRI.Response.com"><vers_v_version_data><vers_v_trancode>VBOB</vers_v_trancode><vers_v_version>5</vers_v_version><vers_v_token></vers_v_token><vers_v_cardno>0</vers_v_cardno><vers_v_channel_id>MAPP</vers_v_channel_id><vers_v_user_id>0026</vers_v_user_id><vers_v_user_ibt>4586</vers_v_user_ibt><vers_v_response_code>2001</vers_v_response_code><vers_v_digital_uid> </vers_v_digital_uid></vers_v_version_data><otp_data><otp_function_id>VAL</otp_function_id><otp_otp>13182</otp_otp><otp_delivery_type>E</otp_delivery_type><otp_country_code>27     </otp_country_code><otp_cell_no></otp_cell_no><otp_email_address>test@standardbank.co.za </otp_email_address><otp_qname>MAPPOTP020010885</otp_qname><otp_msg_type>SIGNCD</otp_msg_type><otp_msg_content>Credit Card                                                                                                                                                                                                                                                                                                                   </otp_msg_content></otp_data></VERSIONROperationResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>';
            XmlStreamReader reader = new XmlStreamReader(validResponse);
            String sxmltag = 'vers_v_response_code';
            Test.startTest();
            string response = AOB_Utils.readXMLResponse(reader, sxmltag);
            Test.stopTest();
            Assert.areNotEqual(response, null,'Test pass');
        }
    }

     /**
     * @description  This method is used to test getFreshAccessToken
     */
    @isTest
    private static void getFreshAccessTokenTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
			String token=AOB_Utils.getFreshAccessToken();
            Test.stopTest();
            Assert.areNotEqual(token, null,'Test pass');
        }
    }
     /**
     * @description  This method is used to test getFreshAccessToken
     */
    @isTest
    private static void getAccessTokenTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
			String token=AOB_Utils.getAccessToken();
            Test.stopTest();
            Assert.areNotEqual(token, null,'Test pass');
        }
    }

    /**
     * @description  This method is used to test get app settings by category
     */
    @isTest
    private static void getAppSettingByCategoryTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            //List<AOB_AppSettings__mdt> appSettings = AOB_DAL_TestFactory.loadAppSettings(AOB_Constants.PING);
            Test.startTest();
            Map<String, String> settings = AOB_Utils.getAppSettingByCategory(AOB_Constants.PING);
            Test.stopTest();
            Assert.areNotEqual(settings, null,'Test pass');
        }
    }

    /**
     * @description  This method is used to test get app settings by Label
     */
    @isTest
    private static void getAppSettingByLabelTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            //List<AOB_AppSettings__mdt> appSettings = AOB_DAL_TestFactory.loadAppSettings(AOB_Constants.PING);
            Test.startTest();
            String setting = AOB_Utils.getAppSettingByLabel(AOB_Constants.PING_ID);
            Test.stopTest();
            Assert.areNotEqual(setting, null,'Test pass');
        }
    }

     /**
     * @description  This method is used to test isUserExistingToBankTest
     */
    @IsTest
    private static void isUserExistingToBankTest() {
        Test.startTest();
        Boolean returnValue = AOB_Utils.isUserExistingToBank();
         Test.stopTest();
         Assert.areEqual(returnValue, true,'Test pass');

    }

    /**
     * @description  This method is used to test getWebServiceSettingsByName
     */
    @isTest
    private static void getWebServiceSettingsByNameTest(){
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            //AOB_Application__c app1 = [SELECT id FROM AOB_Application__c];
            CMN_WebserviceSetting__mdt result = AOB_Utils.getWebServiceSettingsByName('AOB_API_PreApplication');
            Test.stopTest();
            Assert.areNotEqual(result, null,'Test pass');
        }
    }

     /**
     * @description This method is used to test getWFRError
     */
    @isTest
    private static void getWFRErrorTest() {
        User communityUser = [SELECT Id FROM USER LIMIT 1];
        System.runAs(communityUser) {
            Test.startTest();
            AOB_WFR_Error__mdt wfrError = AOB_Utils.getWFRError('1');
            Test.stopTest();
            Assert.areNotEqual(wfrError,null,'Test pass');
        }
    }


    /**
     * @description This method is used to test getWFRError
     */
    @isTest
    private static void getUserLanguagetest() {
            Test.startTest();
            String retValue = AOB_Utils.getUserLanguage();
            Test.stopTest();
            Assert.areNotEqual(retValue,null,'Test pass');
        
    }
     

    
}