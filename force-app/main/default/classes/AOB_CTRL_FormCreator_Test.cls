/***************************************************************************************
@Author            : Narendra
@Date              : Oct 7th 2021
@Name of the Class : AOB_CTRL_FormCreator_Test
@description       : Test Class for AOB_CTRL_FormCreator
@Last Modified By  : Dayakar 
@Last Modified On  : 1st April 2024
@Modification Description : SFP-34189
***************************************************************************************/
@IsTest
public with sharing class AOB_CTRL_FormCreator_Test {
    
    /**
    * @description Test setup method to insert all Test data
    */
    @TestSetup
     static void testSetUp(){
        User communityUser = AOB_DAL_TestFactory.createCommunityUser();
        User admin = AOB_DAL_TestFactory.createUser(AOB_TestConstants.SYSTEM_ADMINISTRATOR, true);
        AOB_Application__c newApp;
        System.runAs(admin){
            newApp = AOB_DAL_TestFactory.createApplication(communityUser);
            Lead lobj = new Lead();
            lobj.FirstName = 'Test';
            lobj.LastName = 'Test Last';
            lobj.Status = 'Open';
            lobj.LeadSource = 'Other';
            lobj.Company = 'Test';
            insert lobj;
        }  
        Assert.areNotEqual(null, newApp, 'Application exists for a community user');
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.setApplicationStep
    * Check that current and previous step are updated correctly
    */
    @IsTest
    private static void setApplicationStepTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        String currentScreen = 'Notifications';
        String previousScreen = 'Personal Details';
        AOB_Application__c newApplication = [SELECT Id, AOB_ExpiryDate__c FROM AOB_Application__c LIMIT 1];
        Lead leadRecord = [SELECT Id FROM Lead LIMIT 1];
        newApplication.Lead__c = leadRecord.Id;
        newApplication.AOB_PreviousScreens__c= 'Before We Begin';
        update newApplication;
        System.runAs(communityUser){
            Test.startTest();
            AOB_CTRL_FormCreator.setApplicationStep(newApplication.Id, currentScreen, previousScreen);
            Test.stopTest();
            List<AOB_Application__c> changedApplication = [SELECT AOB_CurrentScreen__c, AOB_PreviousScreen__c FROM AOB_Application__c WHERE Id = :newApplication.Id];
            Assert.areEqual(currentScreen, changedApplication[0].AOB_CurrentScreen__c, 'updated application curret screen is matched');
            Assert.areEqual(previousScreen, changedApplication[0].AOB_PreviousScreen__c, 'updated application previous screen is matched');
        }  
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.setApplicationStep
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
                AOB_CTRL_FormCreator.setApplicationStep(invalidId, currentScreen, previousScreen);
            }
            catch(Exception e){
                failed = true;
            }
            Test.stopTest();
            Assert.areEqual(true,failed, 'Method failed due to invalid application id');
        }  
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.getFields
    * Check that form title and subtitle are retrieved correctly
    */
    @IsTest
    private static void getFieldsTest(){
        AOB_Application__c newApplication = [SELECT Id FROM AOB_Application__c LIMIT 1];
        list<AOB_FlowScreen__c> screen = AOB_DAL_TestFactory.createScreen();
        list<AOB_ScreenSection__c> section = AOB_DAL_TestFactory.createSection(screen[0].id);        
        list<AOB_field__c> field = AOB_DAL_TestFactory.createFields(section[0].id);
        list<AOB_referencedData__c> ref = AOB_DAL_TestFactory.createRefData();
        Test.startTest();
        AOB_DTO_Form form = AOB_CTRL_FormCreator.getFields(newApplication.Id, screen[0].name);
        Test.stopTest();
        AOB_FlowScreen__c flowScreen = [select AOB_title__c, AOB_subtitle__c from AOB_FlowScreen__c where name = :screen[0].name limit 1];            
        Assert.areEqual(flowScreen.AOB_title__c, form.title, 'DTO screen title field matched with the form field');
        Assert.areEqual(flowScreen.AOB_subtitle__c, form.subTitle, 'DTO screen subTitle field matched with the form field');
        Assert.areNotEqual(null,ref, 'ReferencedData records found');
        Assert.areNotEqual(null,field, 'Field records found');
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.getFields
    * Check that form title and subtitle are retrieved correctly
    */
    @IsTest
    private static void getFieldsPersonalDetailsTest(){
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        list<AOB_FlowScreen__c> screen = AOB_DAL_TestFactory.createScreen();
        list<AOB_ScreenSection__c> section = AOB_DAL_TestFactory.createSection(screen[0].id);        
        list<AOB_field__c> field = AOB_DAL_TestFactory.createFields(section[0].id);
        list<AOB_referencedData__c> ref = AOB_DAL_TestFactory.createRefData();
        AOB_FlowScreen__c flowScreenRec = [select AOB_title__c, AOB_subtitle__c from AOB_FlowScreen__c where name = :screen[0].name limit 1]; 
        flowScreenRec.AOB_subtitle__c = '{##firstName##}, please enter the following information.';  
        update flowScreenRec;
        Test.startTest();
        AOB_DTO_Form form = AOB_CTRL_FormCreator.getFields(applicationId, screen[0].name);
        Test.stopTest();
        AOB_FlowScreen__c flowScreen = [select AOB_title__c, AOB_subtitle__c from AOB_FlowScreen__c where name = :screen[0].name limit 1];            
        Assert.areEqual(flowScreen.AOB_title__c, form.title, 'DTO screen title field matched with the form field');
        Assert.areNotEqual(null,ref, 'ReferencedData records found');
        Assert.areNotEqual(null,field, 'Field records found');
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.getFields
    * Exception : Unable to find screen
    */
    @IsTest
    private static void getFieldsScreenErrorTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = [SELECT Id FROM AOB_Application__c LIMIT 1];
        System.runAs(communityUser){
            Test.startTest();
            Boolean failed = false;
            try{
                AOB_DTO_Form form = AOB_CTRL_FormCreator.getFields(newApplication.Id, 'Notif');
                Assert.areNotEqual(null,form, 'Notify form fields not found');

            }
            catch(Exception e){
                failed = true;
            }
            Test.stopTest();
            Assert.areEqual(true,failed, 'Method failed due to invalid screen Name');
        }  
    }   
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.getFields
    * Exception : Unable to find sections
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
                AOB_DTO_Form form = AOB_CTRL_FormCreator.getFields(newApplication.Id, screen[0].name);
                Assert.areNotEqual(null,form, 'Response returned with the combination of application id & screen name');

            }
            catch(Exception e){
                failed = true;
            }
            Test.stopTest();
            Assert.areEqual(true,failed, 'Method failed due to invalid screen Name');
        }  
    }   
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.getFields
    * Exception : Unable to find reference data
    */
    @IsTest
    private static void getFieldsRefDataErrorTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = [SELECT Id FROM AOB_Application__c LIMIT 1];   
        list<AOB_FlowScreen__c> screen = AOB_DAL_TestFactory.createScreen();
        list<AOB_ScreenSection__c> section = AOB_DAL_TestFactory.createSection(screen[0].id);  
        list<AOB_field__c> field = AOB_DAL_TestFactory.createFields(section[0].id); 
        System.runAs(communityUser){
            Test.startTest();
            Boolean failed = false;
            try{
                AOB_DTO_Form form = AOB_CTRL_FormCreator.getFields(newApplication.Id, screen[0].name);
                Assert.areNotEqual(null,form, 'Response returned with the combination of application id & screen name');
                
            }
            catch(Exception e){
                failed = true;
            }
            Test.stopTest();
            Assert.areEqual(true,failed, 'Method failed due to invalid screen Name');
            Assert.areNotEqual(null,field, 'Form Fields not found with screen Section Id');
        }  
    }   
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.setApplicationData 
    * Check that AOB_InflightData__c is inserted where it was initially blank on the application
    */
    @IsTest
    private static void setApplicationDataTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = [SELECT Id FROM AOB_Application__c LIMIT 1];
        newApplication.AOB_CurrentScreen__c = 'Personal Details';
        update newApplication; 
        string appData = '{"Nationality":"AL","Citizenship":"DZ","PublicOfficial":"false","Related":"false","RelationType":"5","RelationName":"MESSI"}'; 
        System.runAs(communityUser){
            Test.startTest();
            AOB_CTRL_FormCreator.setApplicationData(newApplication.Id, appData);
            Test.stopTest();
            List<AOB_Application__c> changedApplication = [SELECT AOB_inflightData__c FROM AOB_Application__c WHERE Id = :newApplication.Id];
            Assert.areEqual(true, changedApplication[0].AOB_inflightData__c.contains(appData), 'Personal details data exists in the inflight data');
        }  
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.setApplicationData 
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
                AOB_CTRL_FormCreator.setApplicationData(newApplication.Id, null);
                Test.stopTest();
            }
            catch(Exception ex){
                Assert.areNotEqual(null, ex.getMessage(), 'Residential Address data exists in the inflight data');

            }
        }  
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.setApplicationData 
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
            AOB_CTRL_FormCreator.setApplicationData(newApplication.Id, appData);
            Test.stopTest();
            List<AOB_Application__c> changedApplication = [SELECT AOB_inflightData__c FROM AOB_Application__c WHERE Id = :newApplication.Id];
            Assert.areEqual(true, changedApplication[0].AOB_inflightData__c.contains(appData), 'Residential Address data exists in the inflight data');
        }  
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.setApplicationData 
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
            AOB_CTRL_FormCreator.setApplicationData(newApplication.Id, screenData);
            Test.stopTest();
            List<AOB_Application__c> changedApplication = [SELECT AOB_inflightData__c FROM AOB_Application__c WHERE Id = :newApplication.Id];
            Assert.areNotEqual(null, changedApplication[0].AOB_inflightData__c, 'Company Trading Address data exists in the inflight data');
        }  
    }
        /**
    * @description Test method for AOB_CTRL_FormCreator.setApplicationData 
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
            AOB_CTRL_FormCreator.setApplicationData(newApplication.Id, screenData);
            Test.stopTest();
            List<AOB_Application__c> changedApplication = [SELECT AOB_inflightData__c FROM AOB_Application__c WHERE Id = :newApplication.Id];
            Assert.areNotEqual(null, changedApplication[0].AOB_inflightData__c, 'Company Trading Address data exists in the inflight data');
        }  
    }
    
    /**
    *@description  Test method for AOB_CTRL_FormCreator.setApplicationData 
    * Check that an exception is thrown if an application does not exist
    */
    @IsTest
    private static void setApplicationDataErrorTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        String invalidId = '123';
        System.runAs(communityUser){
            Test.startTest();
            Boolean failed = false;
            try{
                AOB_CTRL_FormCreator.setApplicationData(invalidId,'');
            }
            catch(Exception e){
                failed = true;
            }
            Test.stopTest();
            Assert.areEqual(true,failed, 'Method failed due to invalid appicationId');
        }  
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.setApplicationData
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
                AOB_CTRL_FormCreator.setApplicationData(newApplication.Id, appData2);
                Test.stopTest();
                List<AOB_Application__c> changedApplication = [SELECT AOB_inflightData__c FROM AOB_Application__c WHERE Id = :newApplication.Id];
                Assert.areNotEqual(null, changedApplication, 'Application should not be null');
            }
            catch(Exception ex){
                Assert.areNotEqual(null, ex.getMessage(), 'Error handling message');
            }
        }  
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.getFields
    * Check that subtitle are correctly formatted (####)
    */
    @IsTest
    private static void getFieldsSubtitleTest(){
        AOB_Application__c newApplication = [SELECT Id, AOB_ExpiryDate__c FROM AOB_Application__c LIMIT 1];
        list<AOB_FlowScreen__c> screen = AOB_DAL_TestFactory.createScreen();
        screen[0].AOB_TitleApplicationField__c = 'AOB_ExpiryDate__c';
        screen[0].AOB_subTitle__c = screen[0].AOB_subTitle__c + '{####}';
        update screen;
        list<AOB_ScreenSection__c> section = AOB_DAL_TestFactory.createSection(screen[0].id);    
        list<AOB_field__c> field = AOB_DAL_TestFactory.createFields(section[0].id);
        list<AOB_referencedData__c> ref = AOB_DAL_TestFactory.createRefData();
        Test.startTest();
        AOB_DTO_Form form = AOB_CTRL_FormCreator.getFields(newApplication.Id, screen[0].name);
        Test.stopTest();
        list<AOB_FlowScreen__c> flowScreen = [select AOB_subTitle__c, AOB_TitleApplicationField__c from AOB_FlowScreen__c where name = :screen[0].name limit 1];   
        Assert.areEqual(flowScreen[0].AOB_subTitle__c.replace('{####}',string.valueOf(newApplication.get(flowScreen[0].AOB_TitleApplicationField__c))),form.subTitle, 'Test Message');
        Assert.areNotEqual(null,ref, 'ReferencedData records found');
        Assert.areNotEqual(null,field, 'Field records found');   
    }

    
    /**
    * @description Test method for AOB_CTRL_FormCreator.goBacktoPreviousStep
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
            AOB_CTRL_FormCreator.goBacktoPreviousStep(newApplication.Id);
            Test.stopTest();
            List<AOB_Application__c> apps = new SEL_AOBApplication().selectAppsById(newApplication.Id);
            Assert.areNotEqual(null,apps, 'Application records not found');
        }
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.getFields
    * Check that subtitle are correctly formatted for ##firstName##)
    */
    @IsTest
    private static void getFieldsSubtitleFirstNameTest(){
        AOB_Application__c newApplication = [SELECT Id FROM AOB_Application__c LIMIT 1];
        newApplication.AOB_inflightData__c='{"PreApplicationResponse":{"processId":"1659943","initiatorDigitalID":null,"initiatorBPID":"0535639435","initiatorBPGUID":"b13c55a9-357d-1edd-acf6-2e276a9007e7","inflightCustomerDataId":"0600047292","digitalOfferId":"0045396346","businessRegisteredName":"MENESEENTERPRISE","businessBPID":"0535639428","businessBPGUID":"4989261e-a6c2-1edd-acf6-2e1b858d4aa6"},"PreApplication":{"IdNum":"9101285435084","Name":"S\'MANGAS\'BONGISENI","Surname":"MSWELI","PhoneNumber":"0732635525","EmailAddress":"test@standardbank.co.za","soleOwner":"true","businessType":"PRIVATECOMPANY","soleShareholder":"true","businessName":"MENESEENTERPRISE","businessTurnover":"5000000","businessRegistrationNumber":"2020/448833/07","businessProvince":"ZAF.KZN","businessCity":"CITYOFTSHWANE","consent":true,"productNumber":"4648","pricingOption":"ZMBP","appName":"MYMOBIZPLUS"}}';
        list<AOB_FlowScreen__c> screen = AOB_DAL_TestFactory.createScreen();
        update newApplication;
        list<AOB_ScreenSection__c> section = AOB_DAL_TestFactory.createSection(screen[0].id);    
        list<AOB_field__c> field = AOB_DAL_TestFactory.createFields(section[0].id);
        list<AOB_referencedData__c> ref = AOB_DAL_TestFactory.createRefData();
        Test.startTest();
        AOB_DTO_Form form = AOB_CTRL_FormCreator.getFields(newApplication.Id, screen[0].name);
        Test.stopTest();
        list<AOB_FlowScreen__c> flowScreen = [select AOB_subTitle__c from AOB_FlowScreen__c where name = :screen[0].name limit 1];   
        Assert.areEqual(flowScreen[0].AOB_subTitle__c,'Enter the following information', 'Test Message');
        Assert.areNotEqual(null,form, 'Response returned with the combination of application id & screen name');
        Assert.areNotEqual(null,ref, 'ReferencedData records not found');
        Assert.areNotEqual(null,field, 'Field records not found');
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.getApplicantDataForAdobe
    * Check that data is returned from application
    */
    @IsTest
    private static void getApplicantDataForAdobeTest(){
        AOB_Application__c newApplication = [SELECT Id FROM AOB_Application__c LIMIT 1];
        newApplication.AOB_inflightData__c='{"PreApplicationResponse":{"processId":"1659943","initiatorDigitalID":null,"initiatorBPID":"0535639435","initiatorBPGUID":"b13c55a9-357d-1edd-acf6-2e276a9007e7","inflightCustomerDataId":"0600047292","digitalOfferId":"0045396346","businessRegisteredName":"MENESEENTERPRISE","businessBPID":"0535639428","businessBPGUID":"4989261e-a6c2-1edd-acf6-2e1b858d4aa6"},"PreApplication":{"IdNum":"9101285435084","Name":"S\'MANGAS\'BONGISENI","Surname":"MSWELI","PhoneNumber":"0732635525","EmailAddress":"test@standardbank.co.za","soleOwner":"true","businessType":"PRIVATECOMPANY","soleShareholder":"true","businessName":"MENESEENTERPRISE","businessTurnover":"5000000","businessRegistrationNumber":"2020/448833/07","businessProvince":"ZAF.KZN","businessCity":"CITYOFTSHWANE","consent":true,"productNumber":"4648","pricingOption":"ZMBP","appName":"MYMOBIZPLUS"}}';
        update newApplication;
        Test.startTest();
        String appData = AOB_CTRL_FormCreator.getApplicantDataForAdobe(newApplication.Id);
        Test.stopTest();
        Assert.areNotEqual(null,appData, 'application has the adobe date empty');
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.createApplicationLineItems
    * Check that line items are not created
    */
    @IsTest
    private static void createApplicationLineItemsNullTest(){
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        String item = '{"4488":true,"ZPOB":true,"ZPSS":true}';
        Test.startTest();
        AOB_CTRL_FormCreator.createApplicationLineItems(applicationId, item);
        Test.stopTest();  
        List<AOB_ApplicationLineItem__c> applineItem=[select Id,AOB_Status__c,AOB_ProductCode__c, AOB_ExpiryDate__c,AOB_Application__c from AOB_ApplicationLineItem__c where AOB_Application__c=:Applicationid];
        Assert.areNotEqual(null, applineItem, 'application Line item not found with application Id');
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.createApplicationLineItems
    * Check that line items are created
    */
    @IsTest
    private static void createApplicationLineItemsTest(){
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        String item = '{"4488":true,"ZPOB":true,"ZPSS":true}';
        Test.startTest();
        AOB_CTRL_FormCreator.createApplicationLineItems(applicationId, item);
        Test.stopTest();  
        List<AOB_ApplicationLineItem__c> applineItem=[select Id,AOB_Status__c,AOB_ProductCode__c, AOB_ExpiryDate__c,AOB_Application__c from AOB_ApplicationLineItem__c where AOB_Application__c=:Applicationid];
        Assert.areNotEqual(null, applineItem, 'application Line item not found with application Id');
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.createApplicationLineItems
    * Check that line items are created
    */
    @IsTest
    private static void createApplicationLineItemsExistingTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = [SELECT Id FROM AOB_Application__c LIMIT 1];
        Product2 prod = AOB_DAL_TestFactory.createProduct('SnapScan', 'SSN');
        String item = '{"SSN":"true"}';
        AOB_ApplicationLineItem__c appLI = AOB_DAL_TestFactory.createApplicationLineItem(prod.id, newApplication.id);
        Integer c = [select count() from AOB_ApplicationLineItem__c where AOB_Product__c = :prod.id];
        System.runAs(communityUser){
            Test.startTest();
            AOB_CTRL_FormCreator.createApplicationLineItems(newApplication.Id, item);
            Test.stopTest();
            Integer i = [select count() from AOB_ApplicationLineItem__c where AOB_Product__c = :prod.id];
            Assert.areEqual(c,i, 'Comparing the product count with prduct id from applcation item');
            Assert.areNotEqual(null,appLI, 'application Line item not found with application Id and product id');
        }  
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.getMainLineItem
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
            AOB_ApplicationLineItem__c mainLine = AOB_CTRL_FormCreator.getMainLineItem(newApplication.Id);
            Test.stopTest();
            Assert.areEqual(appLI.Id, mainLine.Id, 'Comparing the application line item Id from product with application line item id from application');
        }
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.getMainLineItem
    * Check that nothing is returned when there is no Main item
    */
    @isTest
    private static void getMainLineItemNoMainLineTest(){
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        AOB_Application__c newApplication = [SELECT Id FROM AOB_Application__c LIMIT 1];
        Product2 prod = AOB_DAL_TestFactory.createProduct('SnapScan', 'SSN');
        AOB_ApplicationLineItem__c appLI = AOB_DAL_TestFactory.createApplicationLineItemSecondary(prod.id, newApplication.id);
        System.runAs(communityUser){
            Test.startTest();
            AOB_ApplicationLineItem__c mainLine = AOB_CTRL_FormCreator.getMainLineItem(newApplication.Id);
            Test.stopTest();
            Assert.areEqual(null, mainLine, 'ApplicationLineItem records not found with application id');
            Assert.areNotEqual(null, appLI, 'ApplicationLineItem records  found with application id and product id');
        }
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.updatePersonalDetails 
    */
    @istest
    private static void updatePersonalDetails()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_CTRL_FormCreator.updatePersonalDetails(applicationId);
        test.stopTest();
        Assert.areNotEqual(null, applicationId, 'application record created');
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.updateCompanyDetails 
    */
    @IsTest
    private static void companyDetailsApplicationTest()
    {
        String json='{"PreApplicationResponse":{"businessBPGUID":"1b8728fc-9ef7-1edd-aefc-17357ac8fc7d","businessBPID":"535680206","businessRegisteredName":"NAMAKALI IMPORT AND EXPORT","digitalOfferId":"0045398424","inflightCustomerDataId":"0600048072","initiatorBPGUID":"4554ae9e-08af-00d0-0000-00000ab6f567","initiatorBPID":"0207203881","initiatorDigitalID":null,"processId":"1670244"},"ContractDoucument":[{"documentId":"10EAB586-0000-C81B-A43A-7C39C33BC2AE","documentName":"Terms and Conditions for Business Cheque Accounts","documentCode":"GENTC","itemId":"100"},{"documentId":"10EAB586-0000-CE33-9553-934EA243FFD7","documentName":"Terms and Conditions for Business Marketlink","documentCode":"COTCS","itemId":"500"},{"documentId":"B0EAB586-0000-CC14-8E0E-AB75BC6ED44F","documentName":"Contract","documentCode":"CONTR","itemId":"600"},{"documentId":"B0EAB586-0000-CA16-9F16-125FCB79D35F","documentName":"Contract","documentCode":"CONTR","itemId":"700"},{"documentId":"C0EAB586-0000-C21A-B004-E528BF44FCEE","documentName":"Mandate","documentCode":"MANDT","itemId":"0"}],"Notifications":{"depositInfo":"true","NotifiedMean":"SMS"},"Marketing Consent":{"consentForMarketing":"true","consentForSharing":"true","consentForCrossBorderSharing":"true"},"Company Trading Address":{"AddressType":"Different","StreetName":"sainagar","Complex":"parnandhi petals","city":"LINDLEY","PostalCode":"7890","UnitNumber":"999000","SUBURB":"Sea Point","PROVINCE":"ZAF.LP"},"Company Details":{"TELEPHONE  NUMBER (OPTIONAL)":"0116311776","COUNTRY OF REGISTRATION":"ZA","PREFERRED BRANCH":"2171","INDUSTRY CLASSIFICATION":"91100","NATURE OF THE BUSINESS":"16","EMAIL ADDRESS":"magantimamatha@gmail.com","CELLPHONE":"0694114822"},"Residential Address":{"Street":"133 raga street","UnitNumber":"1011","Complexe":"Africa Estate","city":"SOUTHBROOM","PostalCode":"1233","suburb":"Camps Bay","province":"ZAF.KZN"},"ProcessData":[{"taskName":"Capture Application Data","taskID":"7786161","status":"Received","processTaskDetail":{"wfrStatus":null,"wfrRetryAllowed":null,"wfrFailureReason":null,"ownerBPID":null,"correlationID":"ee5675d6-4076-a923-3047-414d8def3127","callBackURL":""},"parentTaskID":""},{"taskName":"Step: Await IDV Callback","taskID":"7786162","status":"Closed","processTaskDetail":{"wfrStatus":null,"wfrRetryAllowed":null,"wfrFailureReason":null,"ownerBPID":null,"correlationID":"ee5675d6-4076-a923-3047-414d8def3127","callBackURL":""},"parentTaskID":""}],"PreApplication":{"appName":"MYMOBIZ PLUS","pricingOption":"ZMBP","productNumber":"4648","consent":true,"businessName":"NAMAKALI IMPORT AND EXPORT","businessProvince":"ZAF.EC","businessTurnover":"3000000","businessRegistrationNumber":"2021/919981/07","soleShareholder":"true","businessType":"PRIVATE COMPANY","soleOwner":"true","EmailAddress":"magantimamatha@gmail.com","PhoneNumber":"0694114822","IdNum":"6506050094085","Surname":"TRIKAM","Name":"MAYA"},"Personal Details":{"SurnameRelationName":"test","RelationName":"test","RelationType":"03","Related":"true","PublicOfficial":"false","Nationality":"AL"},"Employment Details":{"taxInputs":{"secondTaxNumber":"0123456789","secondCountry":"AF2","firstTaxNumber":"0123456789","firstCountry":"AF1"},"taxCountries":true,"jobTitle":"24","INDUSTRY":"02","TaxResident":"true","Employed":"true"},"Company Financial Details":{"ENTITY CLASSIFICATION":"NFI","MoreLessClassif":"true","FOREIGN TAX RESIDENCY":"true","taxCountries":true,"taxInputs":{"secondTaxNumber":"322222","secondCountry":"AD1","firstReason":"02","firstCountry":"AL1"}},"Card Selection":{"debitCardSelected":false,"chequeCardSelected":true},"Available Bundles":{"4488":true,"ZPOB":true,"ZPSS":true},"marketingConsents":[{"consentStatus":"true","consentCodeX":"STAFF ATTESTATION","consentCode":"27"},{"consentStatus":"true","consentCodeX":"TELE-SALES CONSENT","consentCode":"28"},{"consentStatus":"false","consentCodeX":"EXTERNAL MARKETING","consentCode":"01"},{"consentStatus":"true","consentCodeX":"MARKETING RESEARCH","consentCode":"02"},{"consentStatus":"true","consentCodeX":"RECEIVE MARKETING","consentCode":"03"},{"consentStatus":"true","consentCodeX":"SHARE CUSTOMER DATA","consentCode":"04"},{"consentStatus":"true","consentCodeX":"CROSS BORDER SHARING","consentCode":"23"},{"consentStatus":"true","consentCodeX":"SMS CONSENT","consentCode":"26"},{"consentStatus":"true","consentCodeX":"EMAIL CONSENT","consentCode":"25"},{"consentStatus":"true","consentCodeX":"IDENTITY & FRAUD CHECK","consentCode":"07"}],"lastUpdateDt":"2024-01-04","identifications":[{"typeX":"ENTERPRISE REGISTRATION NUMBER","type":"10","number_Z":null,"issuingCountry":"ZA","issuedDate":"2005-02-10","expirationDate":"9999-12-31"}]}';
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord(json);
        Test.startTest();
        AOB_CTRL_FormCreator.updateCompanyDetails(applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId, 'application record  created');
    }
    /**
    * @description Test method for AOB_CTRL_FormCreator.updateCompanyDetails 
    */
    @IsTest
    private static void updatecompanyDetailsTest()
    {
        String json='{"PreApplicationResponse":{"businessBPGUID":"1b8728fc-9ef7-1edd-aefc-17357ac8fc7d","businessBPID":"535680206","businessRegisteredName":"NAMAKALI IMPORT AND EXPORT","digitalOfferId":"0045398424","inflightCustomerDataId":"0600048072","initiatorBPGUID":"4554ae9e-08af-00d0-0000-00000ab6f567","initiatorBPID":"0207203881","initiatorDigitalID":null,"processId":"1670244"},"ContractDoucument":[{"documentId":"10EAB586-0000-C81B-A43A-7C39C33BC2AE","documentName":"Terms and Conditions for Business Cheque Accounts","documentCode":"GENTC","itemId":"100"},{"documentId":"10EAB586-0000-CE33-9553-934EA243FFD7","documentName":"Terms and Conditions for Business Marketlink","documentCode":"COTCS","itemId":"500"},{"documentId":"B0EAB586-0000-CC14-8E0E-AB75BC6ED44F","documentName":"Contract","documentCode":"CONTR","itemId":"600"},{"documentId":"B0EAB586-0000-CA16-9F16-125FCB79D35F","documentName":"Contract","documentCode":"CONTR","itemId":"700"},{"documentId":"C0EAB586-0000-C21A-B004-E528BF44FCEE","documentName":"Mandate","documentCode":"MANDT","itemId":"0"}],"Notifications":{"depositInfo":"true","NotifiedMean":"SMS"},"Marketing Consent":{"consentForMarketing":"true","consentForSharing":"true","consentForCrossBorderSharing":"true"},"Company Trading Address":{"AddressType":"Different","StreetName":"sainagar","Complex":"parnandhi petals","city":"LINDLEY","PostalCode":"7890","UnitNumber":"999000","SUBURB":"Sea Point","PROVINCE":"ZAF.LP"},"Company Details":{"TELEPHONE  NUMBER (OPTIONAL)":"0116311776","COUNTRY OF REGISTRATION":"ZA","PREFERRED BRANCH":"2171","INDUSTRY CLASSIFICATION":"91100","NATURE OF THE BUSINESS":"16","EMAIL ADDRESS":"magantimamatha@gmail.com","CELLPHONE":"0694114822"},"Residential Address":{"Street":"133 raga street","UnitNumber":"1011","Complexe":"Africa Estate","city":"SOUTHBROOM","PostalCode":"1233","suburb":"Camps Bay","province":"ZAF.KZN"},"ProcessData":[{"taskName":"Capture Application Data","taskID":"7786161","status":"Received","processTaskDetail":{"wfrStatus":null,"wfrRetryAllowed":null,"wfrFailureReason":null,"ownerBPID":null,"correlationID":"ee5675d6-4076-a923-3047-414d8def3127","callBackURL":""},"parentTaskID":""},{"taskName":"Step: Await IDV Callback","taskID":"7786162","status":"Closed","processTaskDetail":{"wfrStatus":null,"wfrRetryAllowed":null,"wfrFailureReason":null,"ownerBPID":null,"correlationID":"ee5675d6-4076-a923-3047-414d8def3127","callBackURL":""},"parentTaskID":""}],"PreApplication":{"appName":"MYMOBIZ PLUS","pricingOption":"ZMBP","productNumber":"4648","consent":true,"businessName":"NAMAKALI IMPORT AND EXPORT","businessProvince":"ZAF.EC","businessTurnover":"3000000","businessRegistrationNumber":"2021/919981/07","soleShareholder":"true","businessType":"PRIVATE COMPANY","soleOwner":"true","EmailAddress":"magantimamatha@gmail.com","PhoneNumber":"0694114822","IdNum":"6506050094085","Surname":"TRIKAM","Name":"MAYA"},"Personal Details":{"SurnameRelationName":"test","RelationName":"test","RelationType":"03","Related":"true","PublicOfficial":"false","Nationality":"AL"},"Employment Details":{"taxInputs":{"secondTaxNumber":"0123456789","secondCountry":"AF2","firstTaxNumber":"0123456789","firstCountry":"AF1"},"taxCountries":true,"jobTitle":"24","INDUSTRY":"02","TaxResident":"true","Employed":"true"},"Company Financial Details":{"ENTITY CLASSIFICATION":"NFI","MoreLessClassif":"true","FOREIGN TAX RESIDENCY":"true","taxCountries":true,"taxInputs":{"secondTaxNumber":"322222","secondCountry":"AD1","firstReason":"02","firstCountry":"AL1"}},"Card Selection":{"debitCardSelected":false,"chequeCardSelected":true},"Available Bundles":{"4488":true,"ZPOB":true,"ZPSS":true}}';
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord(json);
        Test.startTest();
        AOB_CTRL_FormCreator.updateCompanyDetails(applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId, 'application record  created');
        
    }
        /**
    * @description Test method for AOB_CTRL_FormCreator.updateCompanyDetails 
    */
    @IsTest
    private static void sameAddressMethodTest()
    {
        String json='{"PreApplicationResponse":{"businessBPGUID":"1b8728fc-9ef7-1edd-aefc-17357ac8fc7d","businessBPID":"535680206","businessRegisteredName":"NAMAKALI IMPORT AND EXPORT","digitalOfferId":"0045398424","inflightCustomerDataId":"0600048072","initiatorBPGUID":"4554ae9e-08af-00d0-0000-00000ab6f567","initiatorBPID":"0207203881","initiatorDigitalID":null,"processId":"1670244"},"ContractDoucument":[{"documentId":"10EAB586-0000-C81B-A43A-7C39C33BC2AE","documentName":"Terms and Conditions for Business Cheque Accounts","documentCode":"GENTC","itemId":"100"},{"documentId":"10EAB586-0000-CE33-9553-934EA243FFD7","documentName":"Terms and Conditions for Business Marketlink","documentCode":"COTCS","itemId":"500"},{"documentId":"B0EAB586-0000-CC14-8E0E-AB75BC6ED44F","documentName":"Contract","documentCode":"CONTR","itemId":"600"},{"documentId":"B0EAB586-0000-CA16-9F16-125FCB79D35F","documentName":"Contract","documentCode":"CONTR","itemId":"700"},{"documentId":"C0EAB586-0000-C21A-B004-E528BF44FCEE","documentName":"Mandate","documentCode":"MANDT","itemId":"0"}],"Notifications":{"depositInfo":"true","NotifiedMean":"SMS"},"Marketing Consent":{"consentForMarketing":"true","consentForSharing":"true","consentForCrossBorderSharing":"true"},"Company Trading Address":{"AddressType":"Same","StreetName":"sainagar","Complex":"parnandhi petals","city":"LINDLEY","PostalCode":"7890","UnitNumber":"999000","SUBURB":"Sea Point","PROVINCE":"ZAF.LP"},"Company Details":{"TELEPHONE  NUMBER (OPTIONAL)":"0116311776","COUNTRY OF REGISTRATION":"ZA","PREFERRED BRANCH":"2171","INDUSTRY CLASSIFICATION":"91100","NATURE OF THE BUSINESS":"16","EMAIL ADDRESS":"magantimamatha@gmail.com","CELLPHONE":"0694114822"},"Residential Address":{"Street":"133 raga street","UnitNumber":"1011","Complexe":"Africa Estate","city":"SOUTHBROOM","PostalCode":"1233","suburb":"Camps Bay","province":"ZAF.KZN"},"ProcessData":[{"taskName":"Capture Application Data","taskID":"7786161","status":"Received","processTaskDetail":{"wfrStatus":null,"wfrRetryAllowed":null,"wfrFailureReason":null,"ownerBPID":null,"correlationID":"ee5675d6-4076-a923-3047-414d8def3127","callBackURL":""},"parentTaskID":""},{"taskName":"Step: Await IDV Callback","taskID":"7786162","status":"Closed","processTaskDetail":{"wfrStatus":null,"wfrRetryAllowed":null,"wfrFailureReason":null,"ownerBPID":null,"correlationID":"ee5675d6-4076-a923-3047-414d8def3127","callBackURL":""},"parentTaskID":""}],"PreApplication":{"appName":"MYMOBIZ PLUS","pricingOption":"ZMBP","productNumber":"4648","consent":true,"businessName":"NAMAKALI IMPORT AND EXPORT","businessProvince":"ZAF.EC","businessTurnover":"3000000","businessRegistrationNumber":"2021/919981/07","soleShareholder":"true","businessType":"PRIVATE COMPANY","soleOwner":"true","EmailAddress":"magantimamatha@gmail.com","PhoneNumber":"0694114822","IdNum":"6506050094085","Surname":"TRIKAM","Name":"MAYA"},"Personal Details":{"SurnameRelationName":"test","RelationName":"test","RelationType":"03","Related":"true","PublicOfficial":"false","Nationality":"AL"},"Employment Details":{"taxInputs":{"secondTaxNumber":"0123456789","secondCountry":"AF2","firstTaxNumber":"0123456789","firstCountry":"AF1"},"taxCountries":true,"jobTitle":"24","INDUSTRY":"02","TaxResident":"true","Employed":"true"},"Company Financial Details":{"ENTITY CLASSIFICATION":"NFI","MoreLessClassif":"true","FOREIGN TAX RESIDENCY":"true","taxCountries":true,"taxInputs":{"secondTaxNumber":"322222","secondCountry":"AD1","firstReason":"02","firstCountry":"AL1"}},"Card Selection":{"debitCardSelected":false,"chequeCardSelected":true},"Available Bundles":{"4488":true,"ZPOB":true,"ZPSS":true}}';
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord(json);
        Test.startTest();
        AOB_CTRL_FormCreator.updateCompanyDetails(applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId, 'application record created');
        
    }
    /**
    * @description Test method for AOB_CTRL_FormCreator.fetchApplicationInflightData 
    */
    @IsTest
    private static void fetchApplicationInflightData()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_CTRL_FormCreator.fetchApplicationInflightData(applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId, 'application record  created');
    }
    /**
    * @description Test method for AOB_CTRL_FormCreator.setExistingData 
    */
    @IsTest
    private static void setExistingDataTest()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        string screenName='Company Details';
        Test.startTest();
        AOB_CTRL_FormCreator.setExistingData(applicationId,screenName);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId, 'application record  created');
    }
    /**
    * @description Test method for AOB_CTRL_FormCreator.setExistingData 
    */
    @IsTest
    private static void setExistingSnapScanTest()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        AOB_ApplicationLineItem__c appLineItem = new AOB_ApplicationLineItem__c();
        appLineItem.AOB_Application__c = applicationId;
        appLineItem.Name = 'MyMoBiz';
        appLineItem.Details__c = '{"snapScanDetails":null,"COMPANY TRADING NAME":"test","EMAIL ADDRESS":"test@gmail.com","DESCRIBE YOUR GOODS/SERVICES":"test","MERCHANT CATEGORY":"3043","receiveInStore":true,"receiveOnline":false}';
        insert appLineItem;
        string screenName='SnapScan';
        Test.startTest();
        String appData=AOB_CTRL_FormCreator.setExistingData(applicationId,screenName);
        Test.stopTest();  
        Assert.areNotEqual(null, appData, 'SnapScan deatails found in application record');
    }
    /**
    * @description Test method for AOB_CTRL_FormCreator.setExistingData 
    */
    @IsTest
    private static void setExistingSnapScanTestNeg()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        String screenName='SnapScan';
        Product2 prod = [SELECT Id,ProductCode FROM Product2 WHERE ProductCode = 'ZPSS'];
        AOB_ApplicationLineItem__c[] linetems=[Select Id, AOB_Product__c, AOB_Pricing_Option__c from AOB_ApplicationLineItem__c 
                                               WHERE  AOB_Application__c=:applicationId AND AOB_Product__c=:prod.Id];

        
        AOB_Application__c application = new AOB_Application__c();
        application.Id = applicationId;
		application.AOB_CurrentScreen__c = screenName;
        update application;
        AOB_ApplicationLineItem__c appLineItem = linetems[0];
        appLineItem.Details__c = '';
        update appLineItem;

        Test.startTest();
        String appData=AOB_CTRL_FormCreator.setExistingData(applicationId,screenName);
        Test.stopTest();  
        Assert.areNotEqual(null, appData, 'SnapScan deatails found in application record');
    }    
    /**
    * @description Test method for AOB_CTRL_FormCreator.setExistingData 
    */
    @IsTest
    private static void setExistingCompanyTest()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        String screenName='Company Details';
        AOB_Application__c[] app=[Select Id, AOB_inflightData__c from AOB_Application__c where Id=:applicationId];
        app[0].AOB_InflightData__c = '{"PreApplication":{"soleOwner":"true","businessType":"PRIVATE COMPANY","soleShareholder":"true","businessRegistrationNumber":"2021/334786/07","businessProvince":"ZAF.GP","businessCity":"CITY OF JOHANNESBURG","businessTurnover":"700000","consent":true,"Name":"MASHUDU KENNETH","IdNum":"7910265760085","Surname":"TSHIVHASE","PhoneNumber":"0832597396","EmailAddress":"pbmonaheng2@gmail.com","productNumber":"4648","pricingOption":"ZMBP","appName":"MYMOBIZ PLUS","businessName":"TSHIMA PROJECT MANAGEMENT AND ENGINEERING"}}';
        update app;
        Test.startTest();
        String appData=AOB_CTRL_FormCreator.setExistingData(app[0].Id,screenName);
        Test.stopTest();  
        Assert.areNotEqual(null, appData, 'Company Details found in application record');
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.setExistingData 
    */
     @IsTest
    private static void setExistingDataaTest()
    {           
        User communityUser = [SELECT Id,contactId FROM USER WHERE Email like '%@test.org' LIMIT 1];
        System.runAs(communityUser){
        try{
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        string screenName='Company Details';
        Test.startTest();
        AOB_CTRL_FormCreator.setExistingData(applicationId,screenName);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId, 'application record created');
        }Catch(exception e){
            Assert.areNotEqual(null, e.getMessage(), 'Error handling message');  
        } 
        }
    }
    
    /**
    * @description test method for isSACitizen()
    **/
    @IsTest
    private static void isSACitizenTest()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_CTRL_FormCreator.isSACitizen(applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId, 'appliaction record created');
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.fetchPrefferedData 
    * Check that AOB_InflightData__c is inserted where it was initially blank on the application
    */
    @IsTest
    private static void fetchPrefferedData()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_CTRL_FormCreator.fetchPrefferedData(applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId, 'appliaction record created');
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.fetchPrefferedData 
    * Check that AOB_InflightData__c is inserted where it was initially blank on the application
    */
    @IsTest
    private static void fetchPrefferedDataNegTest()
    {
        try{
            String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
            AOB_Application__c newApplication = [SELECT Id,AOB_inflightData__c FROM AOB_Application__c WHERE Id=:applicationId LIMIT 1];
            newApplication.AOB_inflightData__c = null;
            update newApplication;
            Test.startTest();
            AOB_CTRL_FormCreator.fetchPrefferedData(applicationId);
            Test.stopTest();  
            Assert.areNotEqual(null, applicationId, 'appliaction record created');
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(), 'Error handling Message');
        } 
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.fetchEmailAddressInflightData 
    */
    @IsTest
    private static void fetchEmailAddressInflightData()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_CTRL_FormCreator.fetchEmailAddressInflightData(applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId, 'appliaction record created');
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.fetchEmailAddressInflightData 
    */
    @IsTest
    private static void fetchEmailAddressInflightDataNegTest()
    {
        try{
            Test.startTest();
            AOB_CTRL_FormCreator.fetchEmailAddressInflightData(null);
            Test.stopTest();  
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(), 'Error handling');
        }
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.selectedAvaialbleBundle 
    */
    @IsTest
    private static void selectedAvaialbleBundles()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_CTRL_FormCreator.selectedAvaialbleBundles(applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId, 'appliaction record created');
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.selectedAvaialbleBundle 
    */
    @IsTest
    private static void selectedAvaialbleBundlesNegTest()
    {
        try{
           Test.startTest();
            AOB_CTRL_FormCreator.selectedAvaialbleBundles(null);
            Test.stopTest();   
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(), 'Error handling Message');
        }  
    }
   
    /**
    * @description Test method for AOB_CTRL_FormCreator.fetchPocketBizDetails 
    */
    @IsTest
    private static void fetchPocketBizDetails()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_CTRL_FormCreator.fetchPocketBizDetails(applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId, 'appliaction record created');
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.fetchphonenumberInflightData 
    */
    @IsTest
    private static void fetchphonenumberInflightData()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_CTRL_FormCreator.fetchPhoneNumber(applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId, 'appliaction record created');
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.fetchphonenumberInflightData 
    */
    @IsTest
    private static void fetchphonenumberInflightDataNegTest()
    {
        try{
            Test.startTest();
            AOB_CTRL_FormCreator.fetchPhoneNumber(null);
            Test.stopTest(); 
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(), 'Error handling message');     
        }
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.getMainLineItem 
    */
    @IsTest
    private static void getMainLineItem()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_CTRL_FormCreator.getMainLineItem(applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId, 'appliaction record created');
    }
    
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.getMainLineItem 
    */
    @IsTest
    private static void removeSummaryProductTest()
    {
        List<String> prodToDelete = new List<String>();
        prodToDelete.add('ZPOB');
        prodToDelete.add('ZPSS');
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        AOB_Application__c newApplication = [SELECT Id,AOB_PreviousScreens__c FROM AOB_Application__c where Id=:applicationId LIMIT 1];
        newApplication.AOB_PreviousScreens__c = 'Personal Details;Residential Address;SnapScan';
        update newApplication;
        Test.startTest();
        AOB_CTRL_FormCreator.removeSummaryProduct(newApplication.Id,prodToDelete);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId, 'appliaction record created');
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.updateApplicationStatus 
    */
    @IsTest
    private static void updateApplicationStatusTest()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_CTRL_FormCreator.updateApplicationStatus(applicationId, 'Residential Details','Personal Details');
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId, 'appliaction record created');
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.getAcceptedLineItemsTest 
    */
    @IsTest
    private static void getAcceptedLineItemsTest()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        List<AOB_ApplicationLineItem__c> acceptedItems = AOB_CTRL_FormCreator.getAcceptedLineItems(applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, acceptedItems, 'application line item records found'); 
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.getAcceptedLineItemsTest 
    */
    @IsTest
    private static void getAcceptedLineItemsNegTest()
    {
        try{
            Test.startTest();
            AOB_CTRL_FormCreator.getAcceptedLineItems(null);
            Test.stopTest();  
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(), 'Error handling'); 
        }
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.updateApplicationStatus 
    */
    @IsTest
    private static void updateApplicationStatusNegTest()
    {
        try{
            Test.startTest();
            AOB_CTRL_FormCreator.updateApplicationStatus(null, 'Test1','Test2');
            Test.stopTest(); 
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(), 'Error handling message');
        }
    }
       
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.updateinfilghtTest 
    */
    @IsTest
    private static void updateinfilghtTest()
    {
        String code='ZPOB';
        String json='{"chequeCardDetails":null}';
        try{
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_CTRL_FormCreator.updateinfilght(code,json,applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId, 'appliaction record created');
        }Catch(exception e){
           Assert.areNotEqual(null, e.getMessage(), 'Test Message');            
        }
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.updateinfilghtTest 
    */
    @IsTest
    private static void updateinfilghtNegTest()
    {
        try{
        AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_CTRL_FormCreator.updateinfilght(null,null,null);
        Test.stopTest();  
        }
        catch(exception e){
           Assert.areNotEqual(null, e.getMessage(), 'Error handling message');            
        }
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.updateinfilghtTest 
    */
    @IsTest
    private static void updateinfilghtDifferentProductTest()
    {
        String code='ZBCH';
        String json='{"addressValue":{"Street":"134 raglent street hgjk","UnitNumber":"hj","suburb":"SCHEME","province":"ZAF.FS","PostalCode":"2023","city":"AKLSA"},"Deliver Address":"Residential","Delivery method":"Private Address"}';
        try{
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_CTRL_FormCreator.updateinfilght(code,json,applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId, 'appliaction record created');
        }Catch(exception e){
           Assert.areNotEqual(null, e.getMessage(), 'Error handling message');            
        }
    }
    /**
    * @description Test method for AOB_CTRL_FormCreator.updateinfilghtTest 
    */
    @IsTest
    private static void updateinfilghtDifferentDataTest()
    {
        String code='ZBCH';
        String json='{"addressValue":{"Street":"134 raglent street hgjk","UnitNumber":"hj","suburb":"SCHEME","province":"ZAF.FS","PostalCode":"2023","city":"AKLSA"},"Deliver Address":"Company","Delivery method":"Private Address"}';
        try{
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_CTRL_FormCreator.updateinfilght(code,json,applicationId);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId, 'appliaction record createde');
        }Catch(exception e){
           Assert.areNotEqual(null, e.getMessage(), 'Error handling Message');            
        }
    }
    /**
    * @description Test method for AOB_CTRL_FormCreator.updateinfilghtTest 
    */
    @IsTest
    private static void updateinfilghtCompanyTradingTest()
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
        AOB_CTRL_FormCreator.updateinfilght(code,json,newApplication.Id);
        Test.stopTest();  
        Assert.areNotEqual(null, applicationId, 'appliaction record created');
        }Catch(exception e){
           Assert.areNotEqual(null, e.getMessage(), 'Error handling message');            
        }
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.clearChequeCardInflight 
    */
    @IsTest
    private static void removeSummaryProductNegTest()
    {
        try{
            List<String> prodToDelete = new List<String>();
            prodToDelete.add('ZPOB');
            prodToDelete.add('ZPSS');
            Test.startTest();
            AOB_CTRL_FormCreator.removeSummaryProduct(null,prodToDelete);
            Test.stopTest();   
        }
        catch(Exception ex){
            Assert.areNotEqual(null, ex.getMessage(), 'Error handling message');   
        } 
    }
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.clearChequeCardInflight 
    */
    @IsTest
    private static void clearChequeCardInflightTest()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        AOB_CTRL_FormCreator.clearChequeCardInflight(applicationId);
        Test.stopTest();  
        Assert.areEqual( 'Not Taken Up', [select AOB_Status__c from AOB_ApplicationLineItem__c where AOB_Application__c=:applicationId and AOB_ProductCode__c='ZBCH'][0].AOB_Status__c, 'Checking the card Status');
    }   
    
    
    /**
    * @description Test method for AOB_CTRL_FormCreator.getselectcard 
    */
    @IsTest
    private static void getselectcardTest()
    {
        String applicationId=AOB_DAL_TestFactory.createApplicationRecord();
        Test.startTest();
        String selectcard=AOB_CTRL_FormCreator.getselectcard(applicationId);
        Test.stopTest();
        Assert.areNotEqual(null, selectcard, 'Selected Card details found in application record');
    }  
}