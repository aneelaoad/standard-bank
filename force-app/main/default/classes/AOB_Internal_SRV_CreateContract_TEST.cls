/**
* @description       : SFP-25090 - Test class for AOB_Internal_SRV_CreateContract
* @author            : Tukelo Moseamo
* @group             : StandardBank BCC
* @last modified on  : 07-17-2023
* @last modified by  : Tukelo Moseamo
* Modifications Log
* Ver   Date         Author           Modification
* 1.0   05-12-2023   Tukelo Moseamo   Initial Version
**/
@isTest
public class AOB_Internal_SRV_CreateContract_TEST {
    /**
    * @description string with inflight data
    * @author Tukelo Moseamo | 06-23-2023 
    */
        public static String inflight =  '{"createContractResponse":{"orchestrationHeaderResponse":{"responseTimeStamp":"2023-07-12","responseStatus":{"statusDescription":"Successful",'
            +'"statusCode":"200","severity":"Info","serverStatusCode":"3"},"requestTimeStamp":"2023-07-12","errorResponse":null,"correlationId":"9cc3e68b-0407-4da6-9bca-804ee0180bcf",'
            +'"channelId":"SALESFORCE STAFF-ASSISTED"},"contracts":[{"itemId":"0","documentName":"Mandate","documentId":"B0304C89-0000-CB10-B5DF-65FBB9CD36A0","documentCode":"MANDT"}]}'
            +',"preApplicationResponse":{"applicationResponseDetails":{"digitalOfferID":"0045412110","maintenanceOfferID":"0600050302","processExpiryDate":"2023-07-03","processID":""},'
            +'"cipcRegisteredDetails":{"businessDetails":{"businessBPGUID":"23980269-0e44-1edd-b7b9-ba68146bb941","businessBPID":"0535736197","businessCity":"","businessName":'
            +'"Monica PTY","businessProvince":"","businessRegistrationNumber":"6006180508088","businessStatus":"","businessTurnover":"2000000","businessType":"SOLE PROPRIETORSHIP",'
            +'"entityClassification":"","kycAddress":{"city":"","country":"","district":"","line1":"","line2":"","line3":"","line4":"","postalCode":"","province":""},"soleShareholdingInd"'
            +':false},"directorDetails":[{"assets":null,"authorizedToApply":true,"bpGuid":null,"bpId":"0437256283","cellphoneNumber":"0119884836","citizenship":"","digitalId":null,'
            +'"directorAddress":{"addressLine1":"","addressLine2":"","addressLine3":"","addressLine4":"","cityDistrict":null,"country":"","countyDistrict":"","postalCode":"","province"'
            +':""},"emailAddress":"","employDetails":{"industry":"","jobTitle":"","occupationStatus":""},"firstName":"MZ","grossMonthlyIncome":null,"identificationCountryCode":"ZA",'
            +'"identificationNumber":"6006180508088","identificationType":"","isInitiator":false,"lastName":"NGOMANI","liabilities":null,"loggedInUser":true,"mainApplicant":true,"nationality":'
            +'null,"pipDetails":{"publicOfficial":false,"publicOfficialRelatedDetails":{"name":"","relatedToPublicOfficial":false,"surname":"","typeOfRelationship":""}},"preferredCommunic'
            +'ationMethod":"","relationships":{"relationshipTypeCode":""},"status":"ACTIVE","taxDetails":{"provisionalTaxPayerInd":"","taxNumber":"","taxType":""},"totalMonthlyExpenses":null}]},'
            +'"orchestrationHeaderResponse":{"channelId":"SALESFORCE STAFF-ASSISTED","correlationId":"ecc4bdf0-d770-eefc-f309-9e426a96bfcb","instanceId":"","requestTimeStamp":"2023-06-26",'
            +'"respondToAddress":"A244555","responseStatus":{"serverStatusCode":"3","severity":"Info","statusCode":"200","statusDescription":"Successful"},"responseTimeStamp":"2023-06-26"}}}';
    /**
    * @description positive test  for callStaffAssistContractAPI
    * @author Tukelo Moseamo | 06-23-2023  
    */
    @isTest
    private static void testCallStaffAssistContractAPIPositive() {
        
        Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
        String applicationId = AOB_DAL_TestFactory.createAppWithInflightKey();
        
        Test.startTest();
         AOB_Internal_DTO_CreateContract.DTO_ResponseStatus response = AOB_Internal_SRV_CreateContract.callStaffAssistContractAPI(applicationId);
        Test.stopTest();
        Assert.isNotNull(response, 'callout was made');
    }
    
    /**
    * @description positive test  for callStaffAssistContractAPI
    * @author Tukelo Moseamo | 06-23-2023  
    */
    @isTest
    private static void testCallStaffAssistContractAPIPositive2() {
        
        Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
        String applicationId = AOB_DAL_TestFactory.createAppWithInflightKey();
        AOB_Application__c app = new AOB_Application__c();
        app.Id = applicationId;
        app.AOB_inflightData__c = inflight;
        update app;
        Test.startTest();
         AOB_Internal_DTO_CreateContract.DTO_ResponseStatus response = AOB_Internal_SRV_CreateContract.callStaffAssistContractAPI(applicationId);
        Test.stopTest();
        Assert.isNotNull(response, 'callout was made');
    }
    
    /**
    * @description negative test for callStaffAssistContractAPI
    * @author Tukelo Moseamo | 06-23-2023 
    */
    @isTest
    private static void testCallStaffAssistContractAPINegative() {
        
        Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
        Test.startTest();
        try {
             AOB_Internal_DTO_CreateContract.DTO_ResponseStatus response = AOB_Internal_SRV_CreateContract.callStaffAssistContractAPI(null);
            Assert.areEqual(response, CMN_UTIL_String.EMPTY, 'callout fails and response doesnt get populated');
        }
        catch(Exception ex) {
            Assert.isNotNull(ex.getMessage(), 'error object is not null');
        }        
        Test.stopTest();
    }
    
    /**
    * @description negative test for callStaffAssistContractAPI
    * @author Tukelo Moseamo | 06-23-2023 
    */
    @isTest
    private static void testCallStaffAssistContractAPINegative1() {
        
        Test.startTest();
        try {
             AOB_Internal_DTO_CreateContract.DTO_ResponseStatus response = AOB_Internal_SRV_CreateContract.callStaffAssistContractAPI(null);
            Assert.areEqual(response, CMN_UTIL_String.EMPTY, 'callout fails and response doesnt get populated');
        }
        catch(Exception ex) {
            Assert.isNotNull(ex.getMessage(), 'error message is not null');
        }        
        Test.stopTest();
    }
    
    /**
    * @description test callStaffAssistGetDocumentAPI
    * @author Tukelo Moseamo | 06-23-2023 
    */
    @isTest 
    private static void testCallStaffAssistGetDocumentAPI() {
        Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
        String applicationId = AOB_DAL_TestFactory.createApplicationRecord();
        AOB_Application__c app = new AOB_Application__c();
        app.Id = applicationId;
        app.AOB_inflightData__c = inflight;
        update app;
        Test.startTest();
        String response = AOB_Internal_SRV_CreateContract.callStaffAssistGetDocumentAPI(applicationId, '0');
        Test.stopTest();
        Assert.isNotNull(response, 'response is populated' );
    }
    
    /**
    * @description negative test for callStaffAssistGetDocumentAPI
    * @author Tukelo Moseamo | 06-23-2023 
    */
    @isTest 
    private static void testCallStaffAssistGetDocumentAPINegative() {
        Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
        String applicationId = AOB_DAL_TestFactory.createAppWithContractInflightKey();
        AOB_Application__c app = [SELECT Id,AOB_inflightData__c FROM AOB_Application__c WHERE Id = :applicationId];
        app.AOB_inflightData__c = app.AOB_inflightData__c.replace('\\"', String.escapeSingleQuotes('"'));
        app.AOB_inflightData__c = app.AOB_inflightData__c.replace(':"{', ':{');
        update app;
        Test.startTest();
        try {
            String response = AOB_Internal_SRV_CreateContract.callStaffAssistGetDocumentAPI(null, '0');
        	Assert.areEqual(response, CMN_UTIL_String.EMPTY, 'callout fails and response doesnt get populated');
        }
        catch(Exception ex) {
            Assert.isNotNull(ex.getMessage(), 'error message is populated');
        }    
        
        Test.stopTest();
    }
                        
    /**
    * @description test getDocumentList
    * @author Tukelo Moseamo | 06-23-2023 
    */
    @isTest 
    private static void testGetDocumentList() {
        Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
        String applicationId = AOB_DAL_TestFactory.createApplicationRecord();
        AOB_Application__c app = new AOB_Application__c();
        app.Id = applicationId;
        app.AOB_inflightData__c = inflight;
        update app;
        Test.startTest();
        Map<String, String> response = AOB_Internal_SRV_CreateContract.getDocumentList(applicationId);
        Test.stopTest();
        Assert.areNotEqual(response, null, 'response is not null');
    }                    

}