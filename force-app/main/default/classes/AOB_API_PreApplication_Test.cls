/**
* @description Test class to test the AOB_API_PreApplication API call
* @author Dayakar Deekonda
* @date Nov 23th 2022
*/
@IsTest
private class AOB_API_PreApplication_Test {
    
    /* @description To setup the List of Webservice Call Queue
    * @return A list of queue items
    */

    @TestSetup
    static void setup() {
        User userRec = AOB_DAL_TestFactory.createCommunityUser();

    }

    private static List<CMN_WebserviceCallQueue__c> setupService() {
        User usr = [SELECT Id,contactId FROM User limit 1];
        CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
            AOB_API_PreApplication.SERVICE_NAME,
            usr.Id
        );
        return new List<CMN_WebserviceCallQueue__c>{ queueItem };
    }
    private static User testUser {
        set;
        get {
            if (testUser == null) {
                testUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
            }
            return testUser;
        }
    }
    /**
	* @description testmethod for getAccessToken
    *
    */
    @IsTest
    static void createPreApp() {
         String json1=' {'+
            '      "consent":true,'+
            '      "businessProvince":"ZAF.FS",'+
            '      "businessRegistrationNumber":"9501126148065",'+
            '      "businessTurnover":"100000",'+
            '      "businessName":"bname",'+
            '      "soleShareholder":"true",'+
            '      "businessType":"CLOSE CORPORATION",'+
            '      "soleOwner":"true",'+
            '      "EmailAddress":"sath@gmail.com",'+
            '      "PhoneNumber":"0876543209",'+
            '      "IdNum":"9501126721146",'+
            '      "Surname":"surname",'+
            '      "Name":"tes"'+
            '}'; 
            AOB_Application__c preAppDataTest = AOB_DAL_TestFactory.createApplication(testUser);
            preAppDataTest.AOB_Status__c ='In Progress';
            preAppDataTest.AOB_inflightData__c=json1;
            preAppDataTest.Name ='appName';
            update preAppDataTest;
            Test.startTest();
            AOB_API_PreApplication service = new AOB_API_PreApplication(json1,preAppDataTest.id);
            AOB_PreapplicationWrapper preappData = (AOB_PreapplicationWrapper)JSON.deserialize(service.jsonBody,AOB_PreapplicationWrapper.class);
            Test.stopTest();
            Assert.areEqual(preappData.applicationDetails.applicationId,preAppDataTest.id);
       
    }

    /**
    * @description Tests to see if the getVerb works as expected
    */
    @IsTest
    static void runPreAppMethods() {

        
         String json3=' {'+
            '      "consent":true,'+
            '      "businessProvince":"ZAF.FS",'+
            '      "businessRegistrationNumber":"9501126148065",'+
            '      "businessTurnover":"100000",'+
            '      "businessName":"bname",'+
            '      "soleShareholder":"true",'+
            '      "businessType":"CLOSE CORPORATION",'+
            '      "soleOwner":"true",'+
            '      "EmailAddress":"sath@gmail.com",'+
            '      "PhoneNumber":"0876543209",'+
            '      "IdNum":"9501126721146",'+
            '      "Surname":"surname",'+
            '      "Name":"tes"'+
            '}'; 
            AOB_Application__c preAppDataTest = AOB_DAL_TestFactory.createApplication(testUser);
            preAppDataTest.AOB_Status__c ='In Progress';
            preAppDataTest.AOB_inflightData__c=json3;
            preAppDataTest.Name ='appName';
            update preAppDataTest;
            Test.startTest();
            AOB_API_PreApplication service = new AOB_API_PreApplication(json3,preAppDataTest.id);
            String verb = service.getVerb();
            string res=service.getResponseBody();
            string res2=service.getBody();
            Boolean triggerObj = service.triggeringObjectRequired();
            Test.stopTest();
            AOB_PreapplicationWrapper preappData = (AOB_PreapplicationWrapper)JSON.deserialize(res2,AOB_PreapplicationWrapper.class);
            Assert.areEqual(verb, 'POST');
            Assert.isTrue(res == '');
            Assert.areEqual(preappData.BusinessDetails.businessRegistrationNumber, '9501126148065');
            Assert.areEqual(triggerObj, false);
       
    }

    /**
    * @description Tests to perform a test for the API Mock
    */
    @IsTest
    static void preAppServiceTest() {
            Test.setMock(HttpCalloutMock.class, new AOB_API_PreApplication.AOB_API_PreApplicationMock()); 
             String json=' {'+
            '      "consent":true,'+
            '      "businessProvince":"ZAF.FS",'+
            '      "businessRegistrationNumber":"9501126148065",'+
            '      "businessTurnover":"100000",'+
            '      "businessName":"bname",'+
            '      "soleShareholder":"true",'+
            '      "businessType":"CLOSE CORPORATION",'+
            '      "soleOwner":"true",'+
            '      "EmailAddress":"sath@gmail.com",'+
            '      "PhoneNumber":"0876543209",'+
            '      "IdNum":"9501126721146",'+
            '      "Surname":"surname",'+
            '      "Name":"tes"'+
            '}'; 
            AOB_API_PreApplication.DTO_Response result;
            AOB_Application__c preAppDataTest = AOB_DAL_TestFactory.createApplication(testUser);
            preAppDataTest.AOB_Status__c ='In Progress';
            preAppDataTest.AOB_inflightData__c=json;
            preAppDataTest.Name ='appName';
            update preAppDataTest;
            Test.startTest();
            AOB_API_PreApplication customerServiceCall = new AOB_API_PreApplication(json,preAppDataTest.id);
            customerServiceCall.process(CMN_DAL_DataFactory.newWebserviceQueue(AOB_API_PreApplication.SERVICE_NAME));
            result = (AOB_API_PreApplication.DTO_Response) customerServiceCall.baseResponseDTO;
            Test.stopTest();
            Assert.areNotEqual(result, null);

    }      
}