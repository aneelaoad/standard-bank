/**
* @description Test class for AOB_CTRL_FindApplications
* @author Devi 
* @ author Dayakar -- PreApplication API Call
* @date Nov 25th 2021  
*/
@IsTest
public class AOB_CTRL_FindApplications_Test 
{
    @TestSetup
    static void setupData() {
        User userRec = AOB_DAL_TestFactory.createCommunityUser();

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
	 * @description Test method for AOB_CTRL_FindApplications.createLeadWithApplication
	 */
    @IsTest
    public static void findApplicationTest()
    {
        String leadCustId = AOB_DAL_TestFactory.createLeadWithApplication();
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
            '      "Name":"tes",'+
            '      "productNumber":"4648"'+
            '}'; 
        
        Test.startTest();
        String appData = AOB_CTRL_FindApplications.findApplication(leadCustId,json);
        Assert.areNotEqual(null,appData,'Test Message');
        Test.stopTest();
    }

    /**
	 * @description Test negative method for AOB_CTRL_FindApplications.findApplication
	 */
    @IsTest
    public static void findApplicationTestNegative()
    {
        String leadCustId = AOB_DAL_TestFactory.createLeadWithApplication();
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
            '      "Name":"tes",'+
            '      "productNumber":"4648",'+
            '      "pricingOption":"ZMMB"'+
            '}'; 
        List<AOB_ApplicationLineItem__c> appLineItems = [select id, AOB_Application__c from AOB_ApplicationLineItem__c ];
        appLineItems[0].AOB_Pricing_Option__c = 'ZMMB';
        update appLineItems;
        List<AOB_Application__c> apps = [select id, AOB_Registration_Number__c from AOB_Application__c];
        apps[0].AOB_Registration_Number__c = '9501126148065';
        apps[0].AOB_inflightData__c = json;
        update apps;
        Test.startTest();
        String appData = AOB_CTRL_FindApplications.findApplication(leadCustId,json);
        Assert.areNotEqual(null,appData,'Test Message');
        Test.stopTest();
    }

    /**
	 * @description Test negative method for AOB_CTRL_FindApplications.findApplication
	 */
    @IsTest
    public static void findApplicationTestNeg()
    {
        try{
            Test.startTest();
            AOB_CTRL_FindApplications.findApplication(null,null);
            Test.stopTest();
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(), 'Test Message');
        }
        
        
    }
    /**
	 * @description Test negative method for AOB_CTRL_FindApplications.createLead
	 */
    @IsTest
    public static void createLeadNegTest()
    {
        try{
            Test.startTest();
            AOB_CTRL_FindApplications.createLead(null);
            Test.stopTest();
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(), 'Test Message');
        }
    }
    
    /**
	 * @description Test negative method for AOB_CTRL_FindApplications.createApplication
	 */
    @IsTest
    public static void createApplicationNegTest()
    {
        try{
            Test.startTest();
            AOB_CTRL_FindApplications.createApplication(null,null);
            Test.stopTest();
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(), 'Test Message');
        }
    }
    /**
	 * @description Test negative method for AOB_CTRL_FindApplications.callPreApplicationNegTest
	 */
    @IsTest
    public static void callPreApplicationNegTest()
    {
        try{
            Test.startTest();
            AOB_CTRL_FindApplications.callPreApplication(null,null);
            Test.stopTest();
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(), 'Test Message');
        }
    }

    
    /**
	 * @description Test method for AOB_CTRL_FindApplications.isDILinkedToBPID
	 */
    @IsTest
    public static void isDILinkedToBPIDTest()
    {
        String appId =  AOB_DAL_TestFactory.createAppWithInflightKey();
        Test.startTest();
        String inflightData = AOB_CTRL_FindApplications.isDILinkedToBPID(appId);
        Assert.areNotEqual(null,inflightData,'Test Message');
        Test.stopTest();
        
    }    
    
    
     /**
	 * @description Test method for AOB_CTRL_FindApplications.isDILinkedToBPID
	 */
    @IsTest
    public static void updatePreAppStageTest()
    {
        String appId =  AOB_DAL_TestFactory.createAppWithInflightKey();
        Test.startTest();
        AOB_CTRL_FindApplications.updatePreAppStage(appId,'PreApplication Submitted');
        Assert.areNotEqual(null,appId,'Test Message');
        Test.stopTest();
        
    }    

    
     /**
	 * @description Test method for AOB_CTRL_FindApplications.findApplication
	 */
    @IsTest
    public static void incrementRetryApplicationTest()
    {
        String appId =  AOB_DAL_TestFactory.createAppWithInflightKey();
        Test.startTest();
        Decimal retryCounter = AOB_CTRL_FindApplications.incrementRetryApplication(appId);
        Assert.areNotEqual(5,retryCounter,'Test Message');
        Test.stopTest();
    }
    
    /**
	 * @description Test method for AOB_CTRL_FindApplications.callPreApplication
	 */
    @IsTest
    public static void callPreApplication()
    {
            Test.setMock(HttpCalloutMock.class, new AOB_API_PreApplication.AOB_API_PreApplicationMock()); 
            String appId =  AOB_DAL_TestFactory.createAppWithInflightKey();
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
                '      "Name":"tes",'+
                '      "productNumber":"4648"'+
                '}'; 
            AOB_Application__c preAppDataTest = AOB_DAL_TestFactory.createApplicationWithLineItems(testUser);
            preAppDataTest.AOB_Status__c ='In Progress';
            preAppDataTest.AOB_inflightData__c=json;
            preAppDataTest.Name ='appName';
            update preAppDataTest;
            Test.startTest();
            String responseCode = AOB_CTRL_FindApplications.callPreApplication(json,preAppDataTest.Id);
            Assert.areEqual('{"responseDesc":"Pre Application successfully executed","responseCode":"52000"}',responseCode,'Test Message');
            Assert.areNotEqual(null,responseCode,'Test Message');
            Assert.areNotEqual(null,appId,'Test Message');
            Test.stopTest();

    }
    /**
	 * @description Test method for CMN_WebserviceCallQueue__c setup
	 * @return List<CMN_WebserviceCallQueue__c>
	 */
    private static List<CMN_WebserviceCallQueue__c> setup() {
        
        CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue(
            AOB_API_PreApplication.SERVICE_NAME,
            UserInfo.getUserId()
        );
        
        return new List<CMN_WebserviceCallQueue__c>{ queueItem };
    }
    
}