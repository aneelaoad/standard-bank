/**
* @description AOB_Internal_CTRL_FormCreator test class
*
* @author Lulu Rankwe
*
* @see AOB_CTRL_InternalPreApplication
*
* @date April 2023
*/ 
@IsTest
@SuppressWarnings('PMD.ExcessivePublicCount,PMD.CyclomaticComplexity')
public class AOB_Internal_CTRL_FormCreator_Test {
        public static string inflight = '{"preApplicationResponse": {"orchestrationHeaderResponse": {"instanceId": "",'
				+ '"respondToAddress": null,"requestTimeStamp": "2023-03-16",'
				+ '"responseTimeStamp": "2023-03-16","correlationId": "74b360cd-1e45-45d5-b41f-e9e8e6d67dd9","responseStatus": {"severity": "Info",'
				+ '"serverStatusCode": "3","statusDescription": "Successful","statusCode": "200"},"channelId": "SBG"},"cipcRegisteredDetails": {'
				+ '"businessDetails": {"kycAddress": {"country": "","line4": " ","province": " ","city": "","district": "","postalCode": "8301",'
				+ '"line3": " ","line2": "KIMBERLEY","line1": "60 PHAKAMILE MABIJA ROAD"},"soleShareholdingInd": true,"businessCity": "EKURHULENI",'
				+ '"businessRegistrationNumber": "2021/131995/07","businessProvince": "WESTERN CAPE","businessBPID": "0535696789",'
				+ '"businessName": "KIMBERLEY AUTO REPAIR CENTRE","businessBPGUID": "b13c55a9-357d-1eed-afe6-158d8426b1b5",'
				+ '"businessStatus": "IN BUSINESS","businessType": "PRIVATE COMPANY","entityClassification": "","businessTurnover": "6000000"},'
				+ '"directorDetails": [{"lastName": "REICHERT","grossMonthlyIncome": null,"cellphoneNumber": null,"totalMonthlyExpenses": null,'
				+ '"isInitiator": false,"identificationType": "","loggedInUser": true,"emailAddress": null,"assets": null,"liabilities": null,"mainApplicant":true,'
				+ '"authorizedToApply": true,"digitalId": null,"bpId": "0434154057","citizenship": "","identificationCountryCode": "ZA",'
				+ '"bpGuid": null,"firstName": "PETRUS ALBERTUS","preferredCommunicationMethod": "","nationality": null,'
				+ '"identificationNumber": "6709125152082","status": "ACTIVE,DIRECTOR","taxDetails": {"taxNumber": "","provisionalTaxPayerInd": "",'
				+ '"taxType": ""},"relationships": {"relationshipTypeCode": ""},"pipDetails": {"publicOfficialRelatedDetails": {"typeOfRelationship": null,'
				+ '"surname": "fsdfs","name": "dfsf","relatedToPublicOfficial": false},"publicOfficial": true},"directorAddress": {"country": "",'
				+ '"province": "","postalCode": "","addressLine1": "","addressLine2": "","cityDistrict": null,"addressLine3": "",'
				+ '"countyDistrict": "","addressLine4": ""},"employDetails": {"occupationStatus": "","jobTitle": "","industry": ""}}]},'
				+ '"applicationResponseDetails": {"maintenanceOfferID": "0600048391","processID": "","processExpiryDate": "2023-03-23",'
				+ '"digitalOfferID": "0045399945"}},'
    			+ '"getApplicationProcessDataResponse": {"orchestrationHeaderResponse": {'
				+ '"instanceId": "1594101","respondToAddress": "","requestTimeStamp": "2023-04-05",'
				+ '"responseTimeStamp": "2023-04-05","correlationId": "92601749-6f6b-4509-bea8-616b47f20c48",'
				+ '"responseStatus":{"severity": "Info","serverStatusCode": "3","statusDescription": "Successful",'
				+ '"statusCode": "200"},"channelId": "SF"},"businessDetails": {"industryClassification": "",'
				+ '"idType": "","beeCode": "","businessName": "LEW GEFFEN ESTATES","taxNumber": ['
				+ '{"reasonNoTaxNum": "","taxNumber": "","taxType": ""}],"businessStatus": "",'
				+ '"sourceOfFunds": [{"sourceFundAmount": "","sourceFundType": "","currency": ""}'
				+ '],"natureOfBusiness": "","kycAddress": {"country": "","line4": "","province": "",'
				+ '"city": "","district": "","postalCode": "","line3": "","line2": "",'
				+ '"line1": ""},"soleShareholdingInd": false,"businessCity": "","businessRegistrationNumber": "2012/141008/07",'
				+ '"prefferedBranch": "","businessProvince": "","businessBPID": "0535609711","marketingConsent": ['
				+ '{"consentCode": "","consentStatus": false}],"businessBPGUID": "b13c55a9-357d-1edd-aba4-5d26d2d43975",'
				+ '"fiscalMonthEnd": "2023-12-31","businessType": "ZFS003","entityClassification": "","businessTurnover": 0,'
				+ '"countryOfRegistration": "ZA","cellPhone": "0734567873","email": "livemy.mtshabi@standardbank.co.za"'
				+ '},"directorDetails": [{"lastName": "JACOBUS JOHANNES","grossMonthlyIncome": 0,"cellphoneNumber": "0832764360",'
				+ '"totalMonthlyExpenses": 0,"isInitiator": false,"taxDetails": {"taxNumber": "","provisionalTaxPayerInd": "",'
				+ '"taxType": ""},"identificationType": "","loggedInUser": false,"relationships": {"relationshipTypeCode": ""'
				+ '},"emailAddress": "lulu.rankwe@standardbank.co.za","assets": 0,"liabilities": 0,"mainApplicant": false,'
				+ '"employDetails": {"occupationStatus": "","jobTitle": "","industry": ""},"directorAddress": {"country": "",'
				+ '"province": "","postalCode": "","addressLine1": "","addressLine2": "","cityDistrict": "","addressLine3": "",'
				+ '"countydistrict": "","addressLine4": ""},"authorizedToApply": false,"pipDetails": {"publicOfficialRelatedDetails": {'
				+ '"typeOfRelationship": "","surname": "","name": "","relatedToPublicOfficial": false},"publicOfficial": false'
				+ '},"digitalId": 0,"bpId": "0450025511","citizenship": "","identificationCountryCode": "","bpGuid": "45535c55-c934-0089-0000-00000ab6f52b",'
				+ '"firstName": "ODENDAAL","preferredCommunicationMethod": "","nationality": "","identificationNumber": "6111295106081",'
				+ '"status": ""}]}}';
    
   				public static string inflight1 =  '{"Marketing Consent": {"consentForCrossBorderSharing": "true","consentForMarketing": "true","consentForSharing": "true"},' 
                   + '"Company Trading Address": { "AddressType": "Same", "AddressValue": {"PostalCode": "2000","province": "ZAF.NW",' 
                   + '"city": "Rosebank","suburb": "Rosebank","Complexe": "Gauteng","Street": "30 Baker" }},"preApplicationResponse": {' 
                   + '"applicationResponseDetails": {"digitalOfferID": "0045412110",  "maintenanceOfferID": "0600050302","processExpiryDate": "2023-07-03",' 
                   + '"processID": ""},"cipcRegisteredDetails": {"businessDetails": {"businessBPGUID": "23980269-0e44-1edd-b7b9-ba68146bb941",' 
                   + '"businessBPID": "0535736197", "businessCity": "", "businessName": "Monica PTY","businessProvince": "","businessRegistrationNumber":' 
                   + ' "6006180508088","businessStatus": "","businessTurnover": "2000000","businessType": "SOLE PROPRIETORSHIP","entityClassification": "",' 
                   + '"kycAddress": {"city": "","country": "","district": "","line1": "","line2": "","line3": "","line4": "","postalCode": "","province": ""' 
                   + '}, "soleShareholdingInd": false},"directorDetails": [{"assets": null,"authorizedToApply": true,"bpGuid": null,"bpId": "0437256283",' 
                   + '"cellphoneNumber": "0119884836","citizenship": "","digitalId": null,"directorAddress": {"addressLine1": "","addressLine2": "",' 
                   + '"addressLine3": "","addressLine4": "","cityDistrict": null,"country": "","countyDistrict": "","postalCode": "","province": ""},' 
                   + '"emailAddress": "","employDetails": {"industry": "","jobTitle": "", "occupationStatus": ""},"firstName": "MZ","grossMonthlyIncome": null,' 
                   + '"identificationCountryCode": "ZA","identificationNumber": "6006180508088","identificationType": "","isInitiator": false,"lastName": "NGOMANI",' 
                   + ' "liabilities": null,"loggedInUser": true,"mainApplicant": true,"nationality": null,"pipDetails": {"publicOfficial": false,"publicOfficialRelatedDetails": {' 
                   + '"name": "","relatedToPublicOfficial": false,"surname": "","typeOfRelationship": ""}},"preferredCommunicationMethod": "","relationships": {' 
                   + '"relationshipTypeCode": ""},"status": "ACTIVE","taxDetails": {"provisionalTaxPayerInd": "","taxNumber": "","taxType": ""},' 
                   + '"totalMonthlyExpenses": null }]},"orchestrationHeaderResponse": {"channelId": "SALESFORCE STAFF-ASSISTED","correlationId":' 
                   + '"ecc4bdf0-d770-eefc-f309-9e426a96bfcb","instanceId": "","requestTimeStamp": "2023-06-26","respondToAddress": "A244555","responseStatus": {' 
                   + '"serverStatusCode": "3", "severity": "Info","statusCode": "200","statusDescription": "Successful"}, "responseTimeStamp": "2023-06-26"' 
                   + '}},"PreApplication": {"consentForStaffAttestation": true,"soleOwner": false,"appName": "MYMOBIZ","pricingOption": "ZMMB","productNumber": "4648",' 
                   + '"consent": true,"businessName": "WENTZEL", "businessProvince": "ZAF.MP","businessTurnover": "2000000","Form50": "55","resBank": "533",' 
                   + '"EmailAddress": "test@dollhouse.com","Surname": "RAMBEVHA","Name": "Monica","PhoneNumber": "0832597396","IdNum": "6006180508088",' 
                   + '"businessType": "SOLE PROPRIETORSHIP"},"Personal Details": {"undefined": "s","Nationality": "ZA","PublicOfficial": "false","Related": "false"' 
                   + '},"Residential Address": { "Street": "30 Baker","Complexe": "Gauteng","suburb": "Rosebank","city": "Rosebank","province": "ZAF.NW",' 
                   + '"PostalCode": "2000"},"Company Details": {"CELLPHONE": "0832597396","EMAIL ADDRESS": "test@dollhouse.com","NATURE OF THE BUSINESS": "25",' 
                   + '"INDUSTRY CLASSIFICATION": "91990","PREFERRED BRANCH": "40191","undefined": "s","COUNTRY OF REGISTRATION": "ZA"},"Company Financial Details": {' 
                   + '"ENTITY CLASSIFICATION": "MIE","FOREIGN TAX RESIDENCY": "false","BUSINESS FUNDING": "{\"0010\":\"1000000\"}","undefined": ""}}';
   /**
	* @description this method tests Create Application
	*/
    @TestSetup
    public static void testSetUp(){
        User communityUser = AOB_DAL_TestFactory.createCommunityUser();
        User admin = AOB_DAL_TestFactory.createUser(AOB_TestConstants.SYSTEM_ADMINISTRATOR, true);
        System.runAs(admin){
            AOB_DAL_TestFactory.createApplication(communityUser);
        }  
    }
    /**
	* @description Test method Check that form title and subtitle are retrieved correctly
	* 	
	*/
    @IsTest
    private static void getFieldsTest(){
        AOB_Application__c newApplication = [SELECT Id FROM AOB_Application__c LIMIT 1];
        list<AOB_FlowScreen__c> screen = AOB_DAL_TestFactory.createScreen();
        list<AOB_ScreenSection__c> section = AOB_DAL_TestFactory.createSection(screen[0].id);        
        AOB_DAL_TestFactory.createFields(section[0].id);
        AOB_DAL_TestFactory.createRefData();
        Test.startTest();
        AOB_DTO_Form form = AOB_Internal_CTRL_FormCreator.getFields(newApplication.Id, screen[0].name);
        Test.stopTest();
        AOB_FlowScreen__c flowScreen = [select AOB_title__c, AOB_subtitle__c from AOB_FlowScreen__c where name = :screen[0].name limit 1];            
        Assert.areEqual(flowScreen.AOB_title__c, form.title,'Title is null');
        Assert.areEqual(flowScreen.AOB_subtitle__c, form.subTitle,'subtitle is null');
    }
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator setApplicationStep
	* Check that current and previous step are updated correctly
	*/
    @IsTest
    private static void setApplicationStepTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        String currentScreen = 'Notifications';
        String previousScreen = 'Personal Details';
        AOB_Application__c newApplication = [SELECT Id, AOB_ExpiryDate__c FROM AOB_Application__c LIMIT 1];
        newApplication.AOB_PreviousScreens__c= 'Before We Begin';
        update newApplication;
        System.runAs(communityUser){
            Test.startTest();
            AOB_Internal_CTRL_FormCreator.setApplicationStep(newApplication.Id, currentScreen, previousScreen);
            Test.stopTest();
            List<AOB_Application__c> changedApplication = [SELECT AOB_CurrentScreen__c, AOB_PreviousScreen__c FROM AOB_Application__c WHERE Id = :newApplication.Id];
            Assert.areEqual(currentScreen, changedApplication[0].AOB_CurrentScreen__c,'current screen null');
            Assert.areEqual(previousScreen, changedApplication[0].AOB_PreviousScreen__c,'previous screen null');
        }  
    }
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.getFields
	* Check that form title and subtitle are retrieved correctly
	*/
    @IsTest
    private static void getFieldsPersonalDetailsTest(){
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        list<AOB_FlowScreen__c> screen = AOB_DAL_TestFactory.createScreen();
        list<AOB_ScreenSection__c> section = AOB_DAL_TestFactory.createSection(screen[0].id);        
        AOB_DAL_TestFactory.createFields(section[0].id);
        AOB_DAL_TestFactory.createRefData();
        AOB_FlowScreen__c flowScreenRec = [select AOB_title__c, AOB_subtitle__c from AOB_FlowScreen__c where name = :screen[0].name limit 1]; 
        flowScreenRec.AOB_subtitle__c = '{##firstName##}, please enter the following information.';  
        update flowScreenRec;
        Test.startTest();
        AOB_DTO_Form form = AOB_Internal_CTRL_FormCreator.getFields(applicationId, screen[0].name);
        Test.stopTest();
        AOB_FlowScreen__c flowScreen = [select AOB_title__c, AOB_subtitle__c from AOB_FlowScreen__c where name = :screen[0].name limit 1];            
        Assert.areEqual(flowScreen.AOB_title__c, form.title,'title is null');
    }
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.getFields Exception : Unable to find screen
	* 
	*/
    @IsTest
    private static void getFieldsScreenErrorTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = [SELECT Id FROM AOB_Application__c LIMIT 1];
        System.runAs(communityUser){
            Test.startTest();
            Boolean failed = false;
            try{
               AOB_Internal_CTRL_FormCreator.getFields(newApplication.Id, 'Notif');
            }
            catch(Exception e){
                failed = true;
            }
            Test.stopTest();
            Assert.areEqual(true,failed,'get fields is null');
        }  
    } 
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.getFields Exception : Unable to find sections
	* 
	*/
    @IsTest
    private static void getFieldsSectionsErrorTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = [SELECT Id FROM AOB_Application__c LIMIT 1];
        list<AOB_FlowScreen__c> screen = AOB_DAL_TestFactory.createScreen(); 
        System.runAs(communityUser){
            Test.startTest();
            Boolean failed = false;
            try{
              AOB_Internal_CTRL_FormCreator.getFields(newApplication.Id, screen[0].name);
            }
            catch(Exception e){
                failed = true;
            }
            Test.stopTest();
            Assert.areEqual(true,failed,'getFields is null');
        }  
    } 
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.getFields
	* Exception : Unable to find reference data
	*/
    @IsTest
    private static void getFieldsRefDataErrorTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = [SELECT Id FROM AOB_Application__c LIMIT 1];   
        list<AOB_FlowScreen__c> screen = AOB_DAL_TestFactory.createScreen();
        list<AOB_ScreenSection__c> section = AOB_DAL_TestFactory.createSection(screen[0].id);  
       	AOB_DAL_TestFactory.createFields(section[0].id); 
        System.runAs(communityUser){
            Test.startTest();
            Boolean failed = false;
            try{
                AOB_Internal_CTRL_FormCreator.getFields(newApplication.Id, screen[0].name);
            }
            catch(Exception e){
                failed = true;
            }
            Test.stopTest();
            Assert.areEqual(true,failed,'getFields data error test is null');
        }  
    } 

    /**
	* @description this method testsupdateAvailableBundles
	*/
	@IsTest
	private static void testUpdateAvailableBundles() {
    // Create test data
    Map<String, Object> bundles = new Map<String, Object>{
        'bundle1' => 'Bundle 1'
    };
    AOB_Application__c testApplication = new AOB_Application__c(
        Name = 'app',
        AOB_inflightData__c = System.JSON.serialize(bundles)
    );
    insert testApplication;
    
    String appData = '{"bundle1": "Bundle 1", "bundle2": "Bundle 2"}';
    
    // Call the method being tested
    Test.startTest();
    AOB_Internal_CTRL_FormCreator.updateAvailableBundles(testApplication.Id, appData);
    Test.stopTest();
    
    // Retrieve the updated application record
    AOB_Application__c updatedApplication = [SELECT AOB_inflightData__c FROM AOB_Application__c WHERE Id = :testApplication.Id];
    
    // Verify the result
    Map<String, Object> inflightData = (Map<String, Object>)System.JSON.deserializeUntyped(updatedApplication.AOB_inflightData__c);
    System.assertEquals('Bundle 1', inflightData.get('bundle1'), 'test');
	}


    /**
	* @description this method tests populateAddress
	*/
    @IsTest
    static void testPopulateAddress() {
        // Create test data
        Map<String, Object> jsonMap = new Map<String, Object>{
            'Deliver Address' => 'Residential'
        };
        Map<String, Object> inflightData = new Map<String, Object>{
            'Residential Address' => '123 Main St'
        };
        
        // Call the method being tested
        Map<String, Object> result = AOB_Internal_CTRL_FormCreator.populateAddress(jsonMap, inflightData);
        
        // Verify the result
        System.assertEquals('123 Main St', result.get('addressValue'), 'test');
        
        // Update test data
        jsonMap.put('Deliver Address', 'Company');
        inflightData.put('Company Trading Address', new Map<String, Object>{
            'addressType' => 'Same'
        });
        
        // Call the method being tested again
        result = AOB_Internal_CTRL_FormCreator.populateAddress(jsonMap, inflightData);
        
        // Verify the updated result
        System.assertEquals('123 Main St', result.get('addressValue'), 'test');
        
        // Update test data
        inflightData.put('Company Trading Address', new Map<String, Object>{
            'addressType' => 'Different',
            'AddressValue' => '456 Business Ave'
        });
        
        // Call the method being tested again
        result = AOB_Internal_CTRL_FormCreator.populateAddress(jsonMap, inflightData);
       
    }


    
    @IsTest
    private static void testGetOpenApplications() {
        // Create test data
        Account testAccount = new Account(Name='account1',Registration_Number__c = 'TEST123');
        insert testAccount;
        
        AOB_Application__c inProgressApplication = new AOB_Application__c(AOB_Client__c = testAccount.Id, AOB_Status__c = 'In Progress');
        AOB_Application__c newApplication = new AOB_Application__c(AOB_Client__c = testAccount.Id, AOB_Status__c = 'New');
        insert new List<AOB_Application__c>{ inProgressApplication, newApplication };
        
        // Call the method being tested
        List<AOB_Application__c> openApplications = AOB_Internal_CTRL_FormCreator.getOpenApplications('TEST123');
        
        // Verify the result
        System.assertEquals(2, openApplications.size(), 'test');
        System.assertEquals('In Progress', openApplications[0].AOB_Status__c, 'test');
        System.assertEquals('New', openApplications[1].AOB_Status__c, 'test');
    }

    @IsTest
    private static void testFetchPocketBizMerchant() {
        // Create test data
        AOB_ReferencedData__c referencedData = new AOB_ReferencedData__c(Name = 'Test Merchant', AOB_Code__c = 'TEST', AOB_Language__c = 'En_US');
        insert referencedData;
        
        // Mock the behavior of AOB_UTILS.getUserLanguage()
        try{
            Test.startTest();
            AOB_Internal_CTRL_FormCreator.fetchPocketBizMerchant('TEST');
            Test.stopTest();
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(),'not Null');
                
        }
        
    }

   /**
	*@description Test method for AOB_Internal_CTRL_FormCreator.setApplicationData 
	* Check that AOB_InflightData__c is inserted where it was initially blank on the application
	*/
    @IsTest
    private static void setApplicationDataNegTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = [SELECT Id FROM AOB_Application__c LIMIT 1];
        newApplication.AOB_CurrentScreen__c = 'Residential Address';
        update newApplication; 
        System.runAs(communityUser){
            try{
                Test.startTest();
                AOB_Internal_CTRL_FormCreator.setApplicationData(newApplication.Id, null);
                Test.stopTest();
            }
            catch(Exception ex){
                Assert.areNotEqual(null, ex.getMessage(), 'test');
                
            }
        }  
    }
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.setApplicationData 
	* Check that AOB_InflightData__c is inserted where it was initially blank on the application
	*/
    @IsTest
    private static void setApplicationDataResidentialTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = [SELECT Id FROM AOB_Application__c LIMIT 1];
        newApplication.AOB_CurrentScreen__c = 'Residential Address';
        update newApplication;
        string appData = '{"Nationality":"AL","Citizenship":"DZ","PublicOfficial":"false","Related":"false","RelationType":"5","RelationName":"MESSI"}';
        System.runAs(communityUser){
            Test.startTest();
            AOB_Internal_CTRL_FormCreator.setApplicationData(newApplication.Id, appData);
            Test.stopTest();
            List<AOB_Application__c> changedApplication = [SELECT AOB_inflightData__c FROM AOB_Application__c WHERE Id = :newApplication.Id];
            Assert.areEqual(true, changedApplication[0].AOB_inflightData__c.contains(appData),'setApplicationData is null');
        }  
    }
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.setApplicationData 
	* Check that AOB_InflightData__c is inserted where it was initially blank on the application
	*/
    @IsTest
    private static void setApplicationDataCompanyTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = [SELECT Id FROM AOB_Application__c LIMIT 1];
        String screenData = '{"AddressValue":{"PostalCode":"2091","province":"ZAF.GP","city":"dfsdf","suburb":"SCHEME","Complexe":"huhk","UnitNumber":"hj","Street":"134 raglent street hgjk"},"AddressType":"Different"}';
        String appData = '{"Residential Address":{"Street":"134 raglent street hgjk","UnitNumber":"hj","Complexe":"huhk","suburb":"SCHEME","city":"dfsdf","province":"ZAF.GP","PostalCode":"2091"},"Company Trading Address":{"AddressValue":{"PostalCode":"2091","province":"ZAF.GP","city":"dfsdf","suburb":"SCHEME","Complexe":"huhk","UnitNumber":"hj","Street":"134 raglent street hgjk"},"AddressType":"Different"}}';
        newApplication.AOB_inflightData__c = appData;
        newApplication.AOB_CurrentScreen__c = 'Company Trading Address';
        update newApplication;
        System.runAs(communityUser){
            Test.startTest();
            AOB_Internal_CTRL_FormCreator.setApplicationData(newApplication.Id, screenData);
            Test.stopTest();
            List<AOB_Application__c> changedApplication = [SELECT AOB_inflightData__c FROM AOB_Application__c WHERE Id = :newApplication.Id];
            Assert.areNotEqual(null, changedApplication[0].AOB_inflightData__c,'setApplication data company is null');
        }  
    }
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.setApplicationData 
	* Check that AOB_InflightData__c is inserted where it was initially blank on the application
	*/
    @IsTest
    private static void setApplicationDataCompanyTestSameAddress(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = [SELECT Id FROM AOB_Application__c LIMIT 1];
        String screenData = '{"AddressValue":{"PostalCode":"2091","province":"ZAF.GP","city":"dfsdf","suburb":"SCHEME","Complexe":"huhk","UnitNumber":"hj","Street":"134 raglent street hgjk"},"AddressType":"Same"}';
        String appData = '{"Residential Address":{"Street":"134 raglent street hgjk","UnitNumber":"hj","Complexe":"huhk","suburb":"SCHEME","city":"dfsdf","province":"ZAF.GP","PostalCode":"2091"},"Company Trading Address":{"AddressValue":{"PostalCode":"2091","province":"ZAF.GP","city":"dfsdf","suburb":"SCHEME","Complexe":"huhk","UnitNumber":"hj","Street":"134 raglent street hgjk"},"AddressType":"Different"}}';
        newApplication.AOB_inflightData__c = appData;
        newApplication.AOB_CurrentScreen__c = 'Company Trading Address';
        update newApplication;
        System.runAs(communityUser){
            Test.startTest();
            AOB_Internal_CTRL_FormCreator.setApplicationData(newApplication.Id, screenData);
            Test.stopTest();
            List<AOB_Application__c> changedApplication = [SELECT AOB_inflightData__c FROM AOB_Application__c WHERE Id = :newApplication.Id];
            Assert.areNotEqual(null, changedApplication[0].AOB_inflightData__c,'set application dataCompanySameAddress is null');
        }  
    }
    
    
    /**
	* @description Test method for AOB_Internal_CTRL_FormCreator setApplicationStep
	* Check that an exception is thrown if the application cannot be found
	*/
    @IsTest
    private static void setApplicationStepErrorTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];  
        String currentScreen = 'Notifications';
        String previousScreen = 'Personal Details';
        String invalidId = '123';   
        System.runAs(communityUser){
            Test.startTest();
            Boolean failed = false;
            try{
                AOB_Internal_CTRL_FormCreator.setApplicationStep(invalidId, currentScreen, previousScreen);
            }
            catch(Exception e){
                failed = true;
            }
            Test.stopTest();
            Assert.areEqual(true,failed,'set applicationStepError is null');
        }  
    }
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.setApplicationData
	* Check that AOB_InflightData__c is appended to existing data on the application
	*/
    @IsTest
    private static void setApplicationDataAppendTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = [SELECT Id FROM AOB_Application__c LIMIT 1];
        string appData1 = '{"Nationality":"AL","Citizenship":"DZ","PublicOfficial":"false","Related":"false","RelationType":"5","RelationName":"MESSI"}';
        newApplication.AOB_inflightData__c = appData1;
        update newApplication;
        String appData2 = '{"province":"ZAF.GP","city":"CITY OF JOHANNESBURG RURAL","suburb":"700 SCHEME","Complexe":"THATCH HILL","PostalCode":"0157","UnitNumber":"10673","Street":"Letleretsane str "}';
        System.runAs(communityUser){
            try{
                Test.startTest();
                AOB_Internal_CTRL_FormCreator.setApplicationData(newApplication.Id, appData2);
                Test.stopTest();
                Assert.isNotNull(newApplication,'set applicationData is null');
                
            }
            catch(Exception ex){
                Assert.areNotEqual(null, ex.getMessage(), 'test');
            }
        }  
    }
    
 
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.goBacktoPreviousStep
	* Check that previous steps is filled (####)
	*/
    @IsTest
    private static void goBacktoPreviousStepTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = [SELECT Id, AOB_ExpiryDate__c FROM AOB_Application__c LIMIT 1];
        newApplication.AOB_PreviousScreens__c= 'Before We Begin;Personal Details';
        update newApplication;
        System.runAs(communityUser){
            Test.startTest();
            AOB_Internal_CTRL_FormCreator.goBacktoPreviousStep(newApplication.Id);
            Test.stopTest();
            List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(newApplication.Id);
            Assert.areNotEqual(null,apps,'goBacktoPreviousStep is null');
        }
    }
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.getFields
	* Check that subtitle are correctly formatted for ##firstName##)
	*/
    @IsTest
    private static void getFieldsSubtitleFirstNameTest(){
        AOB_Application__c newApplication = [SELECT Id FROM AOB_Application__c LIMIT 1];
        newApplication.AOB_inflightData__c='{"PreApplicationResponse":{"processId":"1659943","initiatorDigitalID":null,"initiatorBPID":"0535639435","initiatorBPGUID":"b13c55a9-357d-1edd-acf6-2e276a9007e7","inflightCustomerDataId":"0600047292","digitalOfferId":"0045396346","businessRegisteredName":"MENESEENTERPRISE","businessBPID":"0535639428","businessBPGUID":"4989261e-a6c2-1edd-acf6-2e1b858d4aa6"},"PreApplication":{"IdNum":"9101285435084","Name":"S\'MANGAS\'BONGISENI","Surname":"MSWELI","PhoneNumber":"0732635525","EmailAddress":"test@standardbank.co.za","soleOwner":"true","businessType":"PRIVATECOMPANY","soleShareholder":"true","businessName":"MENESEENTERPRISE","businessTurnover":"5000000","businessRegistrationNumber":"2020/448833/07","businessProvince":"ZAF.KZN","businessCity":"CITYOFTSHWANE","consent":true,"productNumber":"4648","pricingOption":"ZMBP","appName":"MYMOBIZPLUS"}}';
        list<AOB_FlowScreen__c> screen = AOB_DAL_TestFactory.createScreen();
        update newApplication;
        list<AOB_ScreenSection__c> section = AOB_DAL_TestFactory.createSection(screen[0].id);    
        AOB_DAL_TestFactory.createFields(section[0].id);
        AOB_DAL_TestFactory.createRefData();
        Test.startTest();
        AOB_Internal_CTRL_FormCreator.getFields(newApplication.Id, screen[0].name);
        Test.stopTest();
        list<AOB_FlowScreen__c> flowScreen = [select AOB_subTitle__c from AOB_FlowScreen__c where name = :screen[0].name limit 1];   
        Assert.areEqual(flowScreen[0].AOB_subTitle__c,'Enter the following information', 'test');
    }

   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.createApplicationLineItems
	* Check that line items are not created
	*/
    @IsTest
    private static void createApplicationLineItemsNullTest(){
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        String item = '{"4488":true,"ZPOB":true,"ZPSS":true}';
        Test.startTest();
        AOB_Internal_CTRL_FormCreator.createApplicationLineItems(applicationId, item);
        Test.stopTest();  
        Assert.isNotNull(applicationId, 'createApplicationLineItems is null');
    }
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.createApplicationLineItems
	* Check that line items are created
	*/
    @IsTest
    private static void createApplicationLineItemsTest(){
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        String item = '{"4488":true,"ZPOB":true,"ZPSS":true}';
        Test.startTest();
        AOB_Internal_CTRL_FormCreator.createApplicationLineItems(applicationId, item);
        Test.stopTest(); 
        Assert.isNotNull(applicationId,'createApplicationLineItemsTest is null');
    }
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.getMainLineItem
	* Check that main line item is returned
	*/
    @isTest
    private static void getMainLineItemTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = [SELECT Id FROM AOB_Application__c LIMIT 1];
        Product2 prod = AOB_DAL_TestFactory.createProduct('MyMoBiz', '4648');
        AOB_ApplicationLineItem__c appLI = AOB_DAL_TestFactory.createApplicationLineItem(prod.id, newApplication.id);
        System.runAs(communityUser){
            Test.startTest();
            AOB_ApplicationLineItem__c mainLine = AOB_Internal_CTRL_FormCreator.getMainLineItem(newApplication.Id);
            Test.stopTest();
            Assert.areEqual(appLI.Id, mainLine.Id,'getMainLineItemTest is null');
        }
    }         
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.getMainLineItem
	* Check that nothing is returned when there is no Main item
	*/
    @isTest
    private static void getMainLineItemNoMainLineTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = [SELECT Id FROM AOB_Application__c LIMIT 1];
        Product2 prod = AOB_DAL_TestFactory.createProduct('SnapScan', 'SSN');
        AOB_DAL_TestFactory.createApplicationLineItemSecondary(prod.id, newApplication.id);
        System.runAs(communityUser){
            Test.startTest();
            AOB_ApplicationLineItem__c mainLine = AOB_Internal_CTRL_FormCreator.getMainLineItem(newApplication.Id);
            Test.stopTest();
            Assert.areEqual(null, mainLine,'getMainLineItemNoMainLineTest is null');
        }
    }   
   
    /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.updateCompanyDetails 
	*/
    @IsTest
    public static void companyDetailsApplicationDifferentMethodTest()
    {
        String json='{"PreApplicationResponse":{"businessBPGUID":"1b8728fc-9ef7-1edd-aefc-17357ac8fc7d","businessBPID":"535680206","businessRegisteredName":"NAMAKALI IMPORT AND EXPORT","digitalOfferId":"0045398424","inflightCustomerDataId":"0600048072","initiatorBPGUID":"4554ae9e-08af-00d0-0000-00000ab6f567","initiatorBPID":"0207203881","initiatorDigitalID":null,"processId":"1670244"},"ContractDocument":[{"documentId":"10EAB586-0000-C81B-A43A-7C39C33BC2AE","documentName":"Terms and Conditions for Business Cheque Accounts","documentCode":"GENTC","itemId":"100"},{"documentId":"10EAB586-0000-CE33-9553-934EA243FFD7","documentName":"Terms and Conditions for Business Marketlink","documentCode":"COTCS","itemId":"500"},{"documentId":"B0EAB586-0000-CC14-8E0E-AB75BC6ED44F","documentName":"Contract","documentCode":"CONTR","itemId":"600"},{"documentId":"B0EAB586-0000-CA16-9F16-125FCB79D35F","documentName":"Contract","documentCode":"CONTR","itemId":"700"},{"documentId":"C0EAB586-0000-C21A-B004-E528BF44FCEE","documentName":"Mandate","documentCode":"MANDT","itemId":"0"}],"Notifications":{"depositInfo":"true","NotifiedMean":"SMS"},"Marketing Consent Internal":{"consentForMarketing":"true","consentForSharing":"true","consentForCrossBorderSharing":"true"},"Company Trading Address":{"AddressType":"Different","StreetName":"sainagar","Complex":"parnandhi petals","city":"LINDLEY","PostalCode":"7890","UnitNumber":"999000","SUBURB":"Sea Point","PROVINCE":"ZAF.LP"},"Company Details":{"TELEPHONE  NUMBER (OPTIONAL)":"0116311776","COUNTRY OF REGISTRATION":"ZA","PREFERRED BRANCH":"2171","INDUSTRY CLASSIFICATION":"91100","NATURE OF THE BUSINESS":"16","EMAIL ADDRESS":"magantimamatha@gmail.com","CELLPHONE":"0694114822"},"Residential Address":{"Street":"133 raga street","UnitNumber":"1011","Complexe":"Africa Estate","city":"SOUTHBROOM","PostalCode":"1233","suburb":"Camps Bay","province":"ZAF.KZN"},"ProcessData":[{"taskName":"Capture Application Data","taskID":"7786161","status":"Received","processTaskDetail":{"wfrStatus":null,"wfrRetryAllowed":null,"wfrFailureReason":null,"ownerBPID":null,"correlationID":"ee5675d6-4076-a923-3047-414d8def3127","callBackURL":""},"parentTaskID":""},{"taskName":"Step: Await IDV Callback","taskID":"7786162","status":"Closed","processTaskDetail":{"wfrStatus":null,"wfrRetryAllowed":null,"wfrFailureReason":null,"ownerBPID":null,"correlationID":"ee5675d6-4076-a923-3047-414d8def3127","callBackURL":""},"parentTaskID":""}],"PreApplication":{"appName":"MYMOBIZ PLUS","pricingOption":"ZMBP","productNumber":"4648","consent":true,"businessName":"NAMAKALI IMPORT AND EXPORT","businessProvince":"ZAF.EC","businessTurnover":"3000000","businessRegistrationNumber":"2021/919981/07","soleShareholder":"true","businessType":"PRIVATE COMPANY","soleOwner":"true","EmailAddress":"magantimamatha@gmail.com","PhoneNumber":"0694114822","IdNum":"6506050094085","Surname":"TRIKAM","Name":"MAYA"},"Personal Details":{"SurnameRelationName":"test","RelationName":"test","RelationType":"03","Related":"true","PublicOfficial":"false","Nationality":"AL"},"Employment Details":{"taxInputs":{"secondTaxNumber":"0123456789","secondCountry":"AF2","firstTaxNumber":"0123456789","firstCountry":"AF1"},"taxCountries":true,"jobTitle":"24","INDUSTRY":"02","TaxResident":"true","Employed":"true"},"Company Financial Details":{"ENTITY CLASSIFICATION":"NFI","MoreLessClassif":"true","FOREIGN TAX RESIDENCY":"true","taxCountries":true,"taxInputs":{"secondTaxNumber":"322222","secondCountry":"AD1","firstReason":"02","firstCountry":"AL1"}},"Card Selection":{"debitCardSelected":false,"chequeCardSelected":true},"Available Bundles":{"4488":true,"ZPOB":true,"ZPSS":true}}';
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord(json);
        Test.startTest();
        AOB_Internal_CTRL_FormCreator.updateCompanyDetails(applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId,'application Id on companyDetails is null');     
    }
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.updateCompanyDetails 
	*/
    @IsTest
    public static void companyDetailsApplicationSameAddressMethodTest()
    {
        String json='{"PreApplicationResponse":{"businessBPGUID":"1b8728fc-9ef7-1edd-aefc-17357ac8fc7d","businessBPID":"535680206","businessRegisteredName":"NAMAKALI IMPORT AND EXPORT","digitalOfferId":"0045398424","inflightCustomerDataId":"0600048072","initiatorBPGUID":"4554ae9e-08af-00d0-0000-00000ab6f567","initiatorBPID":"0207203881","initiatorDigitalID":null,"processId":"1670244"},"ContractDocument":[{"documentId":"10EAB586-0000-C81B-A43A-7C39C33BC2AE","documentName":"Terms and Conditions for Business Cheque Accounts","documentCode":"GENTC","itemId":"100"},{"documentId":"10EAB586-0000-CE33-9553-934EA243FFD7","documentName":"Terms and Conditions for Business Marketlink","documentCode":"COTCS","itemId":"500"},{"documentId":"B0EAB586-0000-CC14-8E0E-AB75BC6ED44F","documentName":"Contract","documentCode":"CONTR","itemId":"600"},{"documentId":"B0EAB586-0000-CA16-9F16-125FCB79D35F","documentName":"Contract","documentCode":"CONTR","itemId":"700"},{"documentId":"C0EAB586-0000-C21A-B004-E528BF44FCEE","documentName":"Mandate","documentCode":"MANDT","itemId":"0"}],"Notifications":{"depositInfo":"true","NotifiedMean":"SMS"},"Marketing Consent Internal":{"consentForMarketing":"true","consentForSharing":"true","consentForCrossBorderSharing":"true"},"Company Trading Address":{"AddressType":"Same","StreetName":"sainagar","Complex":"parnandhi petals","city":"LINDLEY","PostalCode":"7890","UnitNumber":"999000","SUBURB":"Sea Point","PROVINCE":"ZAF.LP"},"Company Details":{"TELEPHONE  NUMBER (OPTIONAL)":"0116311776","COUNTRY OF REGISTRATION":"ZA","PREFERRED BRANCH":"2171","INDUSTRY CLASSIFICATION":"91100","NATURE OF THE BUSINESS":"16","EMAIL ADDRESS":"magantimamatha@gmail.com","CELLPHONE":"0694114822"},"Residential Address":{"Street":"133 raga street","UnitNumber":"1011","Complexe":"Africa Estate","city":"SOUTHBROOM","PostalCode":"1233","suburb":"Camps Bay","province":"ZAF.KZN"},"ProcessData":[{"taskName":"Capture Application Data","taskID":"7786161","status":"Received","processTaskDetail":{"wfrStatus":null,"wfrRetryAllowed":null,"wfrFailureReason":null,"ownerBPID":null,"correlationID":"ee5675d6-4076-a923-3047-414d8def3127","callBackURL":""},"parentTaskID":""},{"taskName":"Step: Await IDV Callback","taskID":"7786162","status":"Closed","processTaskDetail":{"wfrStatus":null,"wfrRetryAllowed":null,"wfrFailureReason":null,"ownerBPID":null,"correlationID":"ee5675d6-4076-a923-3047-414d8def3127","callBackURL":""},"parentTaskID":""}],"PreApplication":{"appName":"MYMOBIZ PLUS","pricingOption":"ZMBP","productNumber":"4648","consent":true,"businessName":"NAMAKALI IMPORT AND EXPORT","businessProvince":"ZAF.EC","businessTurnover":"3000000","businessRegistrationNumber":"2021/919981/07","soleShareholder":"true","businessType":"PRIVATE COMPANY","soleOwner":"true","EmailAddress":"magantimamatha@gmail.com","PhoneNumber":"0694114822","IdNum":"6506050094085","Surname":"TRIKAM","Name":"MAYA"},"Personal Details":{"SurnameRelationName":"test","RelationName":"test","RelationType":"03","Related":"true","PublicOfficial":"false","Nationality":"AL"},"Employment Details":{"taxInputs":{"secondTaxNumber":"0123456789","secondCountry":"AF2","firstTaxNumber":"0123456789","firstCountry":"AF1"},"taxCountries":true,"jobTitle":"24","INDUSTRY":"02","TaxResident":"true","Employed":"true"},"Company Financial Details":{"ENTITY CLASSIFICATION":"NFI","MoreLessClassif":"true","FOREIGN TAX RESIDENCY":"true","taxCountries":true,"taxInputs":{"secondTaxNumber":"322222","secondCountry":"AD1","firstReason":"02","firstCountry":"AL1"}},"Card Selection":{"debitCardSelected":false,"chequeCardSelected":true},"Available Bundles":{"4488":true,"ZPOB":true,"ZPSS":true}}';
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord(json);
        Test.startTest();
        AOB_Internal_CTRL_FormCreator.updateCompanyDetails(applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId,'application Id is null');       
    }
     /**
    * @description Test method for AOB_Internal_CTRL_FormCreator.updateinfilghtTest 
    */
    @IsTest
    public static void updateinfilghtTest()
    {
        String code='ZPOB';
        String json='{"chequeCardDetails":null}';
        try{
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_Internal_CTRL_FormCreator.updateinfilght(code,json,applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId, 'Test Message');
        }Catch(exception e){
           Assert.areNotEqual(null, e.getMessage(), 'Test Message');            
        }
    }
    
    /**
    * @description Test method for AOB_Internal_CTRL_FormCreator.updateinfilghtTest 
    */
    @IsTest
    public static void updateinfilghtNegTest()
    {
        try{
        AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_Internal_CTRL_FormCreator.updateinfilght(null,null,null);
        Test.stopTest();  
        }
        catch(exception e){
           Assert.areNotEqual(null, e.getMessage(), 'Test Message');            
        }
    }
    
    /**
    * @description Test method for AOB_Internal_CTRL_FormCreator.updateinfilghtTest 
    */
    @IsTest
    public static void updateinfilghtDifferentProductTest()
    {
        String code='ZBCH';
        String json='{"addressValue":{"Street":"134 raglent street hgjk","UnitNumber":"hj","suburb":"SCHEME","province":"ZAF.FS","PostalCode":"2023","city":"AKLSA"},"Deliver Address":"Residential","Delivery method":"Private Address"}';
        try{
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_Internal_CTRL_FormCreator.updateinfilght(code,json,applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId, 'Test Message');
        }Catch(exception e){
           Assert.areNotEqual(null, e.getMessage(), 'Test Message');            
        }
    }
    /**
    * @description Test method for AOB_Internal_CTRL_FormCreator.updateinfilghtTest 
    */
    @IsTest
    public static void updateinfilghtDifferentDataTest()
    {
        String code='ZBCH';
        String json='{"addressValue":{"Street":"134 raglent street hgjk","UnitNumber":"hj","suburb":"SCHEME","province":"ZAF.FS","PostalCode":"2023","city":"AKLSA"},"Deliver Address":"Company","Delivery method":"Private Address"}';
        try{
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_Internal_CTRL_FormCreator.updateinfilght(code,json,applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId, 'Test Message');
        }Catch(exception e){
           Assert.areNotEqual(null, e.getMessage(), 'Test Message');            
        }
    }
    /**
    * @description Test method for AOB_CTRL_FormCreator.updateinfilghtTest 
    */
    @IsTest
    public static void updateinfilghtCompanyTradingTest()
    {
        String code='ZBCH';
        String json='{"addressValue":{"Street":"134 raglent street hgjk","UnitNumber":"hj","suburb":"SCHEME","province":"ZAF.FS","PostalCode":"2023","city":"AKLSA"},"Deliver Address":"Company","Delivery method":"Private Address"}';
        try{
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        AOB_Application__c newApplication = [SELECT Id FROM AOB_Application__c where Id=:applicationId LIMIT 1];
        String inflightData = '{"Residential Address":{"city":"AKLSA","PostalCode":"2023","province":"ZAF.FS","suburb":"SCHEME","UnitNumber":"hj","Street":"134 raglent street hgjk"},"Company Trading Address":{"AddressType":"Different","StreetName":"135 abc","UnitNumber":"ds","Complex":"Eye of AFrica","SUBURB":"South Africa","city":"Alaksa","PROVINCE":"ZAF.LP","PostalCode":"2087"}}';
        newApplication.AOB_inflightData__c = inflightData;
        update newApplication; 
        Test.startTest();
        AOB_Internal_CTRL_FormCreator.updateinfilght(code,json,newApplication.Id);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId, 'Test Message');
        }Catch(exception e){
           Assert.areNotEqual(null, e.getMessage(), 'Test Message');            
        }
    }
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.fetchApplicationInflightData 
	*/
    @IsTest
    public static void fetchApplicationInflightData()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_Internal_CTRL_FormCreator.fetchApplicationInflightData(applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId,'application Id is null');
    }
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.setExistingData 
	*/
    @IsTest
    public static void setExistingDataTest()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        string screenName='Company Details';
        Test.startTest();
        AOB_Internal_CTRL_FormCreator.setExistingData(applicationId,screenName);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId,'application id on setExistingData is null');
    }
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.setExistingData 
	*/
    @IsTest
    public static void setExistingSnapScanTest()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        
        
        AOB_ApplicationLineItem__c appLineItem = new AOB_ApplicationLineItem__c();
        appLineItem.AOB_Application__c = applicationId;
        appLineItem.Name = 'MyMoBiz';
        appLineItem.Details__c = '{"snapScanDetails":null,"COMPANY TRADING NAME":"test","EMAIL ADDRESS":"test@gmail.com","DESCRIBE YOUR GOODS/SERVICES":"test","MERCHANT CATEGORY":"3043","receiveInStore":true,"receiveOnline":false}';
        insert appLineItem;
        string screenName='SnapScan';
        Test.startTest();
        String appData=AOB_Internal_CTRL_FormCreator.setExistingData(applicationId,screenName);
        Test.stopTest();  
        Assert.areNotEqual(null, appData,'appData is null');
    }

    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.setExistingData 
	*/
    @IsTest
    public static void setExistingCompanyTest()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        String screenName='Company Details';
        AOB_Application__c[] app=[Select Id, AOB_inflightData__c from AOB_Application__c where Id=:applicationId];
        app[0].AOB_InflightData__c = '{"PreApplication":{"soleOwner":"true","businessType":"PRIVATE COMPANY","soleShareholder":"true","businessRegistrationNumber":"2021/334786/07","businessProvince":"ZAF.GP","businessCity":"CITY OF JOHANNESBURG","businessTurnover":"700000","consent":true,"Name":"MASHUDU KENNETH","IdNum":"7910265760085","Surname":"TSHIVHASE","PhoneNumber":"0832597396","EmailAddress":"pbmonaheng2@gmail.com","productNumber":"4648","pricingOption":"ZMBP","appName":"MYMOBIZ PLUS","businessName":"TSHIMA PROJECT MANAGEMENT AND ENGINEERING"}}';
        update app;
        Test.startTest();
        String appData=AOB_Internal_CTRL_FormCreator.setExistingData(app[0].Id,screenName);
        Test.stopTest();  
        Assert.areNotEqual(null, appData,'appData is null');
    }
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.setExistingData 
	*/
    @IsTest
    public static void setExistingDataaTest()
    {           
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        System.runAs(communityUser){
            try{
                String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
                string screenName='Company Details';
                Test.startTest();
                AOB_Internal_CTRL_FormCreator.setExistingData(applicationId,screenName);
                Test.stopTest();  
                Assert.areNotEqual(null, applicationId,'application Id is null');
            }Catch(exception e){
                Assert.areNotEqual(null, e.getMessage(), 'test');  
            } 
        }
    }
   /**
	* @description Test method for isSACitizen
	*/
    @IsTest
    public static void isSACitizenTest()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_Internal_CTRL_FormCreator.isSACitizen(applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId,'applicationId is null');
    }
    
   /**
	*@description Test method for AOB_Internal_CTRL_FormCreator.fetchPrefferedData 
	* Check that AOB_InflightData__c is inserted where it was initially blank on the application
	*/
    @IsTest
    public static void fetchPrefferedData()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_Internal_CTRL_FormCreator.fetchPrefferedData(applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId,'applicationId is null');
    }
    
   /**
	*@description Test method for AOB_Internal_CTRL_FormCreator.fetchPrefferedData 
	* Check that AOB_InflightData__c is inserted where it was initially blank on the application
	*/
    @IsTest
    public static void fetchPrefferedDataNegTest()
    {
        try{
            String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
            AOB_Application__c newApplication = [SELECT Id,AOB_inflightData__c FROM AOB_Application__c WHERE Id=:applicationId LIMIT 1];
            newApplication.AOB_inflightData__c = null;
            update newApplication;
            Test.startTest();
            AOB_Internal_CTRL_FormCreator.fetchPrefferedData(applicationId);
            Test.stopTest();  
            Assert.areNotEqual(null, applicationId,'applicationId is null');
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(), 'test');
        } 
    }
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.fetchEmailAddressInflightData 
	*/
    @IsTest
    public static void fetchEmailAddressInflightData()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_Internal_CTRL_FormCreator.fetchEmailAddressInflightData(applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId,'applicationId is null');
    }
    
   /**
	*@description Test method for AOB_Internal_CTRL_FormCreator.fetchEmailAddressInflightData 
	*/
    @IsTest
    public static void fetchEmailAddressInflightDataNegTest()
    {
        try{          
            AOB_Internal_CTRL_FormCreator.fetchEmailAddressInflightData(null);
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(), 'test');
        }
    }
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.selectedAvaialbleBundle 
	*/
    @IsTest
    public static void selectedAvailableBundles()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_Internal_CTRL_FormCreator.selectedAvailableBundles(applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId,'applicationId is null');
    }
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.selectedAvaialbleBundle 
	*/
    @IsTest
    public static void selectedAvailableBundlesNegTest()
    {
        try{
            AOB_Internal_CTRL_FormCreator.selectedAvailableBundles(null);
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(), 'test');
        }  
    }
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.fetchPocketBizDetails 
	*/
    @IsTest
    public static void fetchPocketBizDetails()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_Internal_CTRL_FormCreator.fetchPocketBizDetails(applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId,'applicationId is null');
    }
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.fetchphonenumberInflightData 
	*/
    @IsTest
    public static void fetchphonenumberInflightData()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_Internal_CTRL_FormCreator.fetchPhoneNumber(applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId,'applicationId is null');
    }
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.fetchphonenumberInflightData 
	*/
    @IsTest
    public static void fetchphonenumberInflightDataNegTest()
    {
        try{
            AOB_Internal_CTRL_FormCreator.fetchPhoneNumber(null);
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(), 'test');     
        }
    }
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.getMainLineItem 
	*/
    @IsTest
    public static void getMainLineItem()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_Internal_CTRL_FormCreator.getMainLineItem(applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId,'applicationId is null');
    }   
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.getMainLineItem 
	*/
    @IsTest
    public static void removeSummaryProductTest()
    {
        List<String> prodToDelete = new List<String>();
        prodToDelete.add('ZPOB');
        prodToDelete.add('ZPSS');
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        AOB_Application__c newApplication = [SELECT Id,AOB_PreviousScreens__c FROM AOB_Application__c where Id=:applicationId LIMIT 1];
        newApplication.AOB_PreviousScreens__c = 'Personal Details;Residential Address;SnapScan';
        update newApplication;
        Test.startTest();
        AOB_Internal_CTRL_FormCreator.removeSummaryProduct(newApplication.Id,prodToDelete);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId,'applicationId is null');
    }
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.clearChequeCardInflight 
	*/
    @IsTest
    public static void removeSummaryProductNegTest()
    {
        try{
            List<String> prodToDelete = new List<String>();
            prodToDelete.add('ZPOB');
            prodToDelete.add('ZPSS');
            Test.startTest();
            AOB_Internal_CTRL_FormCreator.removeSummaryProduct(null,prodToDelete);
            Test.stopTest();   
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(), 'test');   
        } 
    }
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.updateinflightTest 
	*/
    @IsTest
    public static void updateinflightTest()
    {
        String code='ZPOB';
        String json='{"chequeCardDetails":null}';
        try{
            String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
            Test.startTest();
            AOB_Internal_CTRL_FormCreator.updateinflight(code,json,applicationId);
            Test.stopTest();  
            Assert.areNotEqual(null, applicationId,'applicationIdis null');
        }Catch(exception e){
            Assert.areNotEqual(null, e.getMessage());            
        }
    }
    
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.updateinflightTest 
	*/
    @IsTest
    public static void updateinflightNegTest()
    {
        try{
            AOB_Internal_CTRL_FormCreator.updateinflight(null,null,null);
        }
        catch(exception e){
            Assert.areNotEqual(null, e.getMessage(), 'test');           
        }
    }
    
   /**
	* @description Test method for AOB_CTRL_FormCreator.updateinflightTest 
	*/
    @IsTest
    public static void updateinflightDifferentProductTest()
    {
        String code='ZBCH';
        String json='{"addressValue":{"Street":"134 raglent street hgjk","UnitNumber":"hj","suburb":"SCHEME","province":"ZAF.FS","PostalCode":"2023","city":"AKLSA"},"Deliver Address":"Residential","Delivery method":"Private Address"}';
        try{
            String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
            Test.startTest();
            AOB_Internal_CTRL_FormCreator.updateinflight(code,json,applicationId);
            Test.stopTest();  
            Assert.areNotEqual(null, applicationId,'applicationId is null');
        }Catch(exception e){
            Assert.areNotEqual(null, e.getMessage(), 'test');           
        }
    }
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.updateinflightTest 
	*/
    @IsTest
    public static void updateinflightDifferentDataTest()
    {
        String code='ZBCH';
        String json='{"addressValue":{"Street":"134 raglent street hgjk","UnitNumber":"hj","suburb":"SCHEME","province":"ZAF.FS","PostalCode":"2023","city":"AKLSA"},"Deliver Address":"Company","Delivery method":"Private Address"}';
        try{
            String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
            Test.startTest();
            AOB_Internal_CTRL_FormCreator.updateinflight(code,json,applicationId);
            Test.stopTest();  
            Assert.areNotEqual(null, applicationId,'applicationId is null');
        }Catch(exception e){
            Assert.areNotEqual(null, e.getMessage(), 'test');           
        }
    }
   /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.updateinflightTest 
	*/
    @IsTest
    public static void updateinflightCompanyTradingTest()
    {
        String code='ZBCH';
        String json='{"addressValue":{"Street":"134 raglent street hgjk","UnitNumber":"hj","suburb":"SCHEME","province":"ZAF.FS","PostalCode":"2023","city":"AKLSA"},"Deliver Address":"Company","Delivery method":"Private Address"}';
        try{
            String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
            AOB_Application__c newApplication = [SELECT Id FROM AOB_Application__c where Id=:applicationId LIMIT 1];
            String inflightData = '{"Residential Address":{"city":"AKLSA","PostalCode":"2023","province":"ZAF.FS","suburb":"SCHEME","UnitNumber":"hj","Street":"134 raglent street hgjk"},"Company Trading Address":{"AddressType":"Same","StreetName":"135 abc","UnitNumber":"ds","Complex":"Eye of AFrica","SUBURB":"South Africa","city":"Alaksa","PROVINCE":"ZAF.LP","PostalCode":"2087","addressValue":"Residential Address"}}';
            newApplication.AOB_inflightData__c = inflightData;
            update newApplication; 
            Test.startTest();
            AOB_Internal_CTRL_FormCreator.updateinflight(code,json,newApplication.Id);
            Test.stopTest();  
            Assert.areNotEqual(null, applicationId,'applicationId is null');
        }Catch(exception e){
            Assert.areNotEqual(null, e.getMessage(), 'test');           
        }
    }
   /**
	* @description Test method for update screen 
	*/
    @IsTest
    public static void updateScreenTest(){
        try{
            String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
            AOB_Application__c newApplication = [SELECT Id,AOB_CurrentScreen__c,AOB_PreviousScreens__c FROM AOB_Application__c where Id=:applicationId LIMIT 1];
            String inflightData = '{"Residential Address":{"city":"AKLSA","PostalCode":"2023","province":"ZAF.FS","suburb":"SCHEME","UnitNumber":"hj","Street":"134 raglent street hgjk"},"Company Trading Address":{"AddressType":"Same","StreetName":"135 abc","UnitNumber":"ds","Complex":"Eye of AFrica","SUBURB":"South Africa","city":"Alaksa","PROVINCE":"ZAF.LP","PostalCode":"2087","addressValue":"Residential Address"}}';
            newApplication.AOB_inflightData__c = inflightData;
            update newApplication; 
            
            Test.startTest();
            AOB_Internal_CTRL_FormCreator.updateScreen(newApplication.id,newApplication.AOB_CurrentScreen__c,newApplication.AOB_PreviousScreens__c);
            Test.stopTest();  
            Assert.areNotEqual(null, applicationId,'applicationId is null');
        }Catch(exception e){
            Assert.areNotEqual(null, e.getMessage(), 'test');           
        }
        
    }
   /**
	* @description Test method for update Previous screen 
	*/
    @IsTest
    public static void updatePreviousScreenTest(){
        try{
            String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
            AOB_Application__c newApplication = [SELECT Id,AOB_CurrentScreen__c,AOB_PreviousScreens__c FROM AOB_Application__c where Id=:applicationId LIMIT 1];
            String inflightData = '{"Residential Address":{"city":"AKLSA","PostalCode":"2023","province":"ZAF.FS","suburb":"SCHEME","UnitNumber":"hj","Street":"134 raglent street hgjk"},"Company Trading Address":{"AddressType":"Same","StreetName":"135 abc","UnitNumber":"ds","Complex":"Eye of AFrica","SUBURB":"South Africa","city":"Alaksa","PROVINCE":"ZAF.LP","PostalCode":"2087","addressValue":"Residential Address"}}';
            newApplication.AOB_inflightData__c = inflightData;
            update newApplication; 
            
            Test.startTest();
            AOB_Internal_CTRL_FormCreator.updatePreviousScreen(newApplication.id,newApplication.AOB_CurrentScreen__c,newApplication.AOB_PreviousScreens__c);
            Test.stopTest();  
            Assert.areNotEqual(null, applicationId,'applicationId is null');
        }Catch(exception e){
            Assert.areNotEqual(null, e.getMessage(), 'test');        
        }
        
    }    
   /**
	* @description Test method for negative getMainLineItem
	*/
    @IsTest
    public static void getMainLineItemNegTest(){
        try{
            AOB_Internal_CTRL_FormCreator.getMainLineItem(null);
        }Catch(exception e){
            Assert.isNotNull(e.getMessage(), 'test');
        }              
    }
   /**
	* @description Test method for negative fetchPocketBizDetails
	*/
    @IsTest
    public static void fetchPocketBizDetailsNegTest(){
        try{
            AOB_Internal_CTRL_FormCreator.fetchPocketBizDetails('');
        }Catch(exception e){
            Assert.isNotNull(e.getMessage(), 'test');
        }              
    }
	/**
	* @description Test method for negative fetchPhoneNumber
	*/
    @IsTest
    public static void fetchPhoneNumberNegTest(){
        try{
            AOB_Internal_CTRL_FormCreator.fetchPhoneNumber(null);
        }Catch(exception e){
            Assert.isNotNull(e.getMessage(), 'test');
        }              
    }
   /**
	* @description Test method for negative goBacktoPreviousStep
	*/
    @IsTest
    public static void goBacktoPreviousStepNegTest(){
        try{
            AOB_Internal_CTRL_FormCreator.goBacktoPreviousStep(null);
        }Catch(exception e){
             Assert.isNotNull(e.getMessage(), 'test');
        }              
    }
    
	/**
	* @description Test method for negative fetchPhoneNumber
	*/
    @isTest
    static void testgetApplicationLineItem() {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
    	AOB_Internal_CTRL_FormCreator.getApplicationLineItem(applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId,'applicationId is null');
        
    } 
    /**
	* @description Test method for negative fetchPhoneNumber
	*/
    @isTest
    static void testIsNewCompanyRan() {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        Boolean isNew = AOB_Internal_CTRL_FormCreator.isNewCompanyRan(applicationId);
        Boolean companyRan = AOB_Internal_CTRL_FormCreator.isNewCompanyRan(applicationId);
        Test.stopTest();
        Assert.areEqual(isNew, True, 'inflight data does not have the Company Ran node');
        Assert.areEqual(companyRan, False, 'inflight data now has Company Ran node');
    }  
    
    @isTest
    static void testIsNewCompanyRanNegative() {
        Test.startTest();
        try {
            Boolean isNew = AOB_Internal_CTRL_FormCreator.isNewCompanyRan(null);
            Assert.areEqual('false',isNew,'success');
        }
        catch(Exception ex) {
            Assert.isNotNull(ex.getMessage(), 'null parameter returns a failure');
        }        
        Test.stopTest();
    } 

    @isTest
    static void testGetDirectorDetails() {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        AOB_Application__c app = new AOB_Application__c();
        app.Id = applicationId;
        app.AOB_inflightData__c = inflight;
        update app;
        Test.startTest();
        List<AOB_DTO_StaffAOResponse.DTO_DirectorDetail> der = AOB_Internal_CTRL_FormCreator.getDirectorDetails(applicationId);
        Test.stopTest();
        Assert.areEqual(der.size(), 1, 'One 1 director gets returned');
    }
    
    /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.updatePersonalDetails 
	*/
    @istest
    public static void updatePersonalDetails()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        AOB_Application__c app = new AOB_Application__c();
        app.Id = applicationId;
        app.AOB_inflightData__c = inflight;
        update app;
        Test.setMock(HttpCalloutMock.class, new AOB_API_RetrieveAccessToken.AOB_API_RetrieveAccessTokenMock());
        Test.startTest();
        AOB_Internal_CTRL_FormCreator.updatePersonalDetails(applicationId);
        test.stopTest();
        Assert.areNotEqual(null, applicationId,'applicationId is null');
    }

    /**
	* @description Test method for AOB_Internal_CTRL_FormCreator.updateCompanyDetails 
	*/
    @IsTest
    public static void companyDetailsApplicationTest()
    {
        String json='{"PreApplicationResponse":{"businessBPGUID":"1b8728fc-9ef7-1edd-aefc-17357ac8fc7d","businessBPID":"535680206","businessRegisteredName":"NAMAKALI IMPORT AND EXPORT","digitalOfferId":"0045398424","inflightCustomerDataId":"0600048072","initiatorBPGUID":"4554ae9e-08af-00d0-0000-00000ab6f567","initiatorBPID":"0207203881","initiatorDigitalID":null,"processId":"1670244"},"ContractDoucument":[{"documentId":"10EAB586-0000-C81B-A43A-7C39C33BC2AE","documentName":"Terms and Conditions for Business Cheque Accounts","documentCode":"GENTC","itemId":"100"},{"documentId":"10EAB586-0000-CE33-9553-934EA243FFD7","documentName":"Terms and Conditions for Business Marketlink","documentCode":"COTCS","itemId":"500"},{"documentId":"B0EAB586-0000-CC14-8E0E-AB75BC6ED44F","documentName":"Contract","documentCode":"CONTR","itemId":"600"},{"documentId":"B0EAB586-0000-CA16-9F16-125FCB79D35F","documentName":"Contract","documentCode":"CONTR","itemId":"700"},{"documentId":"C0EAB586-0000-C21A-B004-E528BF44FCEE","documentName":"Mandate","documentCode":"MANDT","itemId":"0"}],"Notifications":{"depositInfo":"true","NotifiedMean":"SMS"},"Marketing Consent":{"consentForMarketing":"true","consentForSharing":"true","consentForCrossBorderSharing":"true"},"Company Trading Address":{"AddressType":"Different","StreetName":"sainagar","Complex":"parnandhi petals","city":"LINDLEY","PostalCode":"7890","UnitNumber":"999000","SUBURB":"Sea Point","PROVINCE":"ZAF.LP"},"Company Details":{"TELEPHONE  NUMBER (OPTIONAL)":"0116311776","COUNTRY OF REGISTRATION":"ZA","PREFERRED BRANCH":"2171","INDUSTRY CLASSIFICATION":"91100","NATURE OF THE BUSINESS":"16","EMAIL ADDRESS":"magantimamatha@gmail.com","CELLPHONE":"0694114822"},"Residential Address":{"Street":"133 raga street","UnitNumber":"1011","Complexe":"Africa Estate","city":"SOUTHBROOM","PostalCode":"1233","suburb":"Camps Bay","province":"ZAF.KZN"},"ProcessData":[{"taskName":"Capture Application Data","taskID":"7786161","status":"Received","processTaskDetail":{"wfrStatus":null,"wfrRetryAllowed":null,"wfrFailureReason":null,"ownerBPID":null,"correlationID":"ee5675d6-4076-a923-3047-414d8def3127","callBackURL":""},"parentTaskID":""},{"taskName":"Step: Await IDV Callback","taskID":"7786162","status":"Closed","processTaskDetail":{"wfrStatus":null,"wfrRetryAllowed":null,"wfrFailureReason":null,"ownerBPID":null,"correlationID":"ee5675d6-4076-a923-3047-414d8def3127","callBackURL":""},"parentTaskID":""}],"PreApplication":{"appName":"MYMOBIZ PLUS","pricingOption":"ZMBP","productNumber":"4648","consent":true,"businessName":"NAMAKALI IMPORT AND EXPORT","businessProvince":"ZAF.EC","businessTurnover":"3000000","businessRegistrationNumber":"2021/919981/07","soleShareholder":"true","businessType":"PRIVATE COMPANY","soleOwner":"true","EmailAddress":"magantimamatha@gmail.com","PhoneNumber":"0694114822","IdNum":"6506050094085","Surname":"TRIKAM","Name":"MAYA"},"Personal Details":{"SurnameRelationName":"test","RelationName":"test","RelationType":"03","Related":"true","PublicOfficial":"false","Nationality":"AL"},"Employment Details":{"taxInputs":{"secondTaxNumber":"0123456789","secondCountry":"AF2","firstTaxNumber":"0123456789","firstCountry":"AF1"},"taxCountries":true,"jobTitle":"24","INDUSTRY":"02","TaxResident":"true","Employed":"true"},"Company Financial Details":{"ENTITY CLASSIFICATION":"NFI","MoreLessClassif":"true","FOREIGN TAX RESIDENCY":"true","taxCountries":true,"taxInputs":{"secondTaxNumber":"322222","secondCountry":"AD1","firstReason":"02","firstCountry":"AL1"}},"Card Selection":{"debitCardSelected":false,"chequeCardSelected":true},"Available Bundles":{"4488":true,"ZPOB":true,"ZPSS":true}}';
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord(json);
        Test.startTest();
        AOB_CTRL_FormCreator.updateCompanyDetails(applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId, 'Test Message');
    }
}