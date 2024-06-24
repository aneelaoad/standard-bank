/***************************************************************************************
@Author            : Narendra Teja
@Date              : May 29th 2023
@Name of the Class : AOB_API_HttpWfrNotify_TEST
@description       : test class for AOB_API_HttpWfrNotify
@Last Modified By  : Ramadevi 
@Last Modified On  : 22 July 2023
@Modification Description : SFP-27748
***************************************************************************************/
@IsTest private class AOB_API_HttpWfrNotify_TEST {
    /**
    * @description Test setup method to insert all Test data
    */
    @TestSetup
    public static void testSetUp(){
        String json='{"PreApplicationResponse":{"businessBPGUID":"1b8728fc-9ef7-1edd-aefc-17357ac8fc7d","businessBPID":"535680206","businessRegisteredName":"NAMAKALI IMPORT AND EXPORT","digitalOfferId":"0045398424","inflightCustomerDataId":"0600048072","initiatorBPGUID":"4554ae9e-08af-00d0-0000-00000ab6f567","initiatorBPID":"0207203881","initiatorDigitalID":null,"processId":"1670244"},"ContractDoucument":[{"documentId":"10EAB586-0000-C81B-A43A-7C39C33BC2AE","documentName":"Terms and Conditions for Business Cheque Accounts","documentCode":"GENTC","itemId":"100"},{"documentId":"10EAB586-0000-CE33-9553-934EA243FFD7","documentName":"Terms and Conditions for Business Marketlink","documentCode":"COTCS","itemId":"500"},{"documentId":"B0EAB586-0000-CC14-8E0E-AB75BC6ED44F","documentName":"Contract","documentCode":"CONTR","itemId":"600"},{"documentId":"B0EAB586-0000-CA16-9F16-125FCB79D35F","documentName":"Contract","documentCode":"CONTR","itemId":"700"},{"documentId":"C0EAB586-0000-C21A-B004-E528BF44FCEE","documentName":"Mandate","documentCode":"MANDT","itemId":"0"}],"Notifications":{"depositInfo":"true","NotifiedMean":"SMS"},"Marketing Consent":{"consentForMarketing":"true","consentForSharing":"true","consentForCrossBorderSharing":"true"},"Company Trading Address":{"AddressType":"Different","StreetName":"sainagar","Complex":"parnandhi petals","city":"LINDLEY","PostalCode":"7890","UnitNumber":"999000","SUBURB":"Sea Point","PROVINCE":"ZAF.LP"},"Company Details":{"TELEPHONE  NUMBER (OPTIONAL)":"0116311776","COUNTRY OF REGISTRATION":"ZA","PREFERRED BRANCH":"2171","INDUSTRY CLASSIFICATION":"91100","NATURE OF THE BUSINESS":"16","EMAIL ADDRESS":"magantimamatha@gmail.com","CELLPHONE":"0694114822"},"Residential Address":{"Street":"133 raga street","UnitNumber":"1011","Complexe":"Africa Estate","city":"SOUTHBROOM","PostalCode":"1233","suburb":"Camps Bay","province":"ZAF.KZN"},"ProcessData":[{"taskName":"Capture Application Data","taskID":"7786161","status":"Received","processTaskDetail":{"wfrStatus":null,"wfrRetryAllowed":null,"wfrFailureReason":null,"ownerBPID":null,"correlationID":"ee5675d6-4076-a923-3047-414d8def3127","callBackURL":""},"parentTaskID":""},{"taskName":"Step: Await IDV Callback","taskID":"7786162","status":"Closed","processTaskDetail":{"wfrStatus":null,"wfrRetryAllowed":null,"wfrFailureReason":null,"ownerBPID":null,"correlationID":"ee5675d6-4076-a923-3047-414d8def3127","callBackURL":""},"parentTaskID":""}],"PreApplication":{"appName":"MYMOBIZ PLUS","pricingOption":"ZMBP","productNumber":"4648","consent":true,"businessName":"NAMAKALI IMPORT AND EXPORT","businessProvince":"ZAF.EC","businessTurnover":"3000000","businessRegistrationNumber":"2021/919981/07","soleShareholder":"true","businessType":"PRIVATE COMPANY","soleOwner":"true","EmailAddress":"magantimamatha@gmail.com","PhoneNumber":"0694114822","IdNum":"6506050094085","Surname":"TRIKAM","Name":"MAYA"},"Personal Details":{"SurnameRelationName":"test","RelationName":"test","RelationType":"03","Related":"true","PublicOfficial":"false","Nationality":"AL"},"Employment Details":{"taxInputs":{"secondTaxNumber":"0123456789","secondCountry":"AF2","firstTaxNumber":"0123456789","firstCountry":"AF1"},"taxCountries":true,"jobTitle":"24","INDUSTRY":"02","TaxResident":"true","Employed":"true"},"Company Financial Details":{"ENTITY CLASSIFICATION":"NFI","MoreLessClassif":"true","FOREIGN TAX RESIDENCY":"true","taxCountries":true,"taxInputs":{"secondTaxNumber":"322222","secondCountry":"AD1","firstReason":"02","firstCountry":"AL1"}},"Card Selection":{"debitCardSelected":false,"chequeCardSelected":true},"Available Bundles":{"4488":true,"ZPOB":true,"ZPSS":true}}';
        User admin = AOB_DAL_TestFactory.createUser(AOB_TestConstants.SYSTEM_ADMINISTRATOR, true);
        String newApp;
        System.runAs(admin){
          newApp  = AOB_DAL_TestFactory.createApplicationRecord(json);
        }  
        Assert.areNotEqual(null, newApp,'Test');
    }

    /**
     * @description Test method for mock result
     */
    @isTest static void testWfrNotify() {
       
        AOB_Application__c aob=[Select Id, AOB_inflightData__c from AOB_Application__c limit 1];
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/v1/wfrNotify/'+aob.Id;
        request.httpMethod = 'PATCH';
        String requestString = '{"wfrStatus":"Verification Passed","wfrMessage":"2022.05.03.16.32.58 Success","wfrErrorCode":"00"}';
        request.requestBody = Blob.valueOf(requestString);
        RestContext.request = new System.RestRequest();
        RestContext.response = new System.RestResponse();
        RestContext.request=request;
        User admin = [Select Id, Username from User limit 1];
        UserRole r = [select id from UserRole limit 1];
        admin.UserRoleId = r.id;
        System.runAs(admin) {
            Test.setMock(HttpCalloutMock.class, new CMN_API_HttpBaseOutboundMock());
            Test.startTest();
            AOB_URL_HttpWfrNotify.updateApplication();  
            AOB_API_HttpWfrNotify.processRequestMock(request); 
             
            AOB_API_HttpWfrNotify.processRequestMockException(request);
           
            Assert.areNotEqual([SELECT Id FROM AOB_Application__c], null, 'Application should not be null');
            Test.stopTest();
        }
    }
    
    /**
     * @description Test method for mock result
     */
    @isTest static void testWfrNotifyMock() {
        
        RestRequest request = new RestRequest();
        String requestString = '{"wfrStatus":"Verification Failed","wfrMessage":"2022.05.03.16.32.58 Failed","wfrErrorCode":"05"}';
        request.requestBody = Blob.valueOf(requestString);
        User admin = [Select Id, Username from User limit 1];
        UserRole r = [select id from UserRole limit 1];
        admin.UserRoleId = r.id;
        System.runAs(admin) {
            Test.startTest();
            AOB_API_HttpWfrNotify.processRequestMock(request);
            AOB_DTO_HttpWfrNotify dt=AOB_DTO_HttpWfrNotify.parse(requestString);
            Assert.areNotEqual([SELECT Id FROM AOB_Application__C], null, 'Application should not be null');
            Assert.areNotEqual(null, dt, 'Test');
            Test.stopTest();
        }
    }
    
    /**
     * @description Test method for negative result
     */
    @isTest static void testWfrNotifyException() {
        
        RestRequest request = new RestRequest();
        String requestString = '{"wfrStatus":"Verification Failed","wfrMessage":"2022.05.03.16.32.58 Failed","wfrErrorCode":"05"}';
        request.requestBody = Blob.valueOf(requestString);
        User admin = [Select Id, Username from User limit 1];
        UserRole r = [select id from UserRole limit 1];
        admin.UserRoleId = r.id;
        System.runAs(admin) {
            Test.startTest();
            AOB_API_HttpWfrNotify.processRequestMockException(request);
            Assert.areNotEqual([SELECT Id FROM AOB_Application__C], null, 'Exception Occurred');
            Test.stopTest();
        }
    }
     /**
     * @description Test method for AOB_API_HttpWfrNotify.callCompleteAOIDV
     */
    @isTest static void testCallWfrNotify() { 
        AOB_Application__c aob=[Select Id, AOB_inflightData__c from AOB_Application__c limit 1];
        Test.startTest();
        AOB_API_HttpWfrNotify.callCompleteAOIDV(aob.id);
        Assert.areNotEqual([SELECT Id FROM AOB_Application__C], null, 'Test');
        Test.stopTest();
    }
}