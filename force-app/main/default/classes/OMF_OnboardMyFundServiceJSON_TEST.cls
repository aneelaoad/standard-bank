/**
* @description Test class for the OMF_OnboardMyFundServiceJSON apex class
* @author Khushmeet Kaur
* @Apex class OMF_OnboardMyFundServiceJSONTest
*************************************************************************
* @description SFP-38486 - Added test method to test KYC Failure if fund not exist
* @author Aman Kumar
* @date 23rd May, 2024
**/
@IsTest
public class OMF_OnboardMyFundServiceJSON_TEST implements HTTPCalloutMock  {
    
    private static String crmHelpDeskEmail = 'crmhelpdesc@testorg.com';
    private static String gtReqCodeSbsa = DMN_Account.GT_REQ_CODE_PREFIX+'SBSA';
    private static String gtMessageCodeSa = 'SA';
    private static Integer code;
    private static String bodyAsString;
    /**
* @description generate the mock request structure
* @param requestToGenerate The request to be generated
* @return httpResponse The HTTP response which is being created
*/
    public HTTPResponse respond(HTTPRequest request) {
        HTTPResponse response = new HTTPResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody(bodyAsString);
        response.setStatusCode(code);
        return response; 
    }
    
    
    @TestSetup
    static void setupData(){
        Id amRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Child').getRecordTypeId();
        Account assetManager = new Account( 
            RecordTypeId = amRecordTypeId,
            Name='Test Manager',
            CIF__c ='34561' 
        );
        Id fundRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Fund').getRecordTypeId();
        Account fund = new Account(
            RecordTypeId = fundRecordTypeId,
            Name='Test Fund'
        );
        insert assetManager;
        insert fund;
        OMF_ManagedFund__c managedFund = new OMF_ManagedFund__c(
            Fund__c=fund.Id,
            AssetManager__c = assetManager.Id,
            Onboarding_Status__c = 'Document Upload',
            RejectionReason__c = 'was not found in Goldtier'
        );        
        insert managedFund;
        KYC_Status__c status = new KYC_Status__c(
            Client__c = fund.Id,
            ManagedFundID__c = managedFund.Id,
            Status__c = 'Y'
        );
        insert status;
        KYC_Required_Documents__c doc = new KYC_Required_Documents__c(
            KYC_Review_Status__c = status.Id,
            Status__c ='Received',
            Date_Received__c = System.today()
        );
        insert doc;
        Id kycRecordTypeId = Schema.SObjectType.OMF_ManagedFundRules__c.getRecordTypeInfosByName().get('KYC Documents').getRecordTypeId();
        OMF_ManagedFundRules__c rule = new OMF_ManagedFundRules__c(
            RecordTypeId = kycRecordTypeId,
            DocumentRequired__c = 'Investment Management Agreement'
        );
        insert rule;
        
        
        List<SFDCToJSONStructure__c> xmlStructure = new List<SFDCToJSONStructure__c>();
        
        
        xmlStructure.add(new SFDCToJSONStructure__c(Name = 'Request',Object_Name__c = '', Field_Name__c = 'Account', Node_Item_Name__c = '', Node_Name__c = 'Request', Default_Value__c='', Order__c = 1, Message_Code__c = GTMESSAGECODESA));
        xmlStructure.add(new SFDCToJSONStructure__c(Name = 'Action',Object_Name__c = 'Account', Field_Name__c = '', Node_Item_Name__c = '', Node_Name__c = 'process_action', Default_Value__c='Self KYC', Order__c = 5, Message_Code__c = GTMESSAGECODESA));
        xmlStructure.add(new SFDCToJSONStructure__c(Name = 'Operation',Object_Name__c = 'Account', Field_Name__c = '', Node_Item_Name__c = '', Node_Name__c = 'request_type', Default_Value__c='New Managed Fund', Order__c = 5, Message_Code__c = GTMESSAGECODESA));
        xmlStructure.add(new SFDCToJSONStructure__c(Name = 'Account.Id',Object_Name__c = 'Account', Field_Name__c = 'Id', Node_Item_Name__c = '', Node_Name__c = 'salesforce_id', Default_Value__c='', Order__c = 10, Message_Code__c = GTMESSAGECODESA));
        xmlStructure.add(new SFDCToJSONStructure__c(Name = 'Account.Contacts',Object_Name__c = 'Account', Field_Name__c = 'Contacts', Node_Item_Name__c = 'party_requirements', Node_Name__c = 'Cust_Contacts',node_item_child_name__c= 'Cust_Contact', Default_Value__c='', Order__c = 350, Message_Code__c = GTMESSAGECODESA));
        xmlStructure.add(new SFDCToJSONStructure__c(Name = 'Contacts.Phone',Object_Name__c = 'Contacts', Field_Name__c = 'Phone',Node_Name__c = 'Phone_Nume',Node_Item_Name__c = 'party_requirements', Default_Value__c='', Order__c = 60, Message_Code__c = GTMESSAGECODESA));
        xmlStructure.add(new SFDCToJSONStructure__c(Name = 'Contacts.Account.Id',Object_Name__c = 'Contacts', Field_Name__c = 'Account.Id', Node_Name__c = 'AccountId', Default_Value__c='',Node_Item_Name__c = 'party_requirements', Order__c = 70, Message_Code__c = GTMESSAGECODESA));
        xmlStructure.add(new SFDCToJSONStructure__c(Name = 'Account.Custom_Client_Teams__r',Object_Name__c = 'Account', Field_Name__c = 'Custom_Client_Teams__r', node_item_child_name__c = 'Internal_Contact', Node_Name__c = 'Internal_Contacts',Node_Item_Name__c = 'party_requirements', Default_Value__c='', Order__c = 340, Message_Code__c = GTMESSAGECODESA));
        xmlStructure.add(new SFDCToJSONStructure__c(Name = 'Team_Member__r.FirstName',Object_Name__c = 'Custom_Client_Teams__r', Field_Name__c = 'Team_Member__r.FirstName',  Node_Name__c = 'First_Name' ,Node_Item_Name__c = 'party_requirements',Default_Value__c='', Order__c = 10, Message_Code__c = GTMESSAGECODESA));
        xmlStructure.add(new SFDCToJSONStructure__c(Name = 'Account.Client_Coordinator_Name__c',Object_Name__c = 'Account', Field_Name__c = 'Client_Coordinator_Name__c',  Node_Name__c = 'Client_Coordinator_Name__c' ,Node_Item_Name__c = 'party_requirements',Default_Value__c='', Order__c = 110, Message_Code__c = GTMESSAGECODESA));
        xmlStructure.add(new SFDCToJSONStructure__c(Name = 'Account.Client_Coordinator_Division__c',Object_Name__c = 'Account', Field_Name__c = 'Client_Coordinator_Division__c',  Node_Name__c = 'Client_Coordinator_Division__c' ,Node_Item_Name__c = 'party_requirements',Default_Value__c='', Order__c = 130, Message_Code__c = GTMESSAGECODESA));
        xmlStructure.add(new SFDCToJSONStructure__c(Name = 'Account.Fund__r',Object_Name__c = 'Account', Field_Name__c = 'Fund__r', node_item_child_name__c = 'Work_Request_Instruction', Node_Name__c = 'Work_Request_Instruction' ,Node_Item_Name__c = 'party_requirements',Default_Value__c='', Order__c = 12, Message_Code__c = GTMESSAGECODESA));
        
        xmlStructure.add(new SFDCToJSONStructure__c(Name = 'Account.Products',Object_Name__c = 'Account', Field_Name__c = 'Products', node_item_child_name__c = 'Products', Node_Name__c = 'Products' ,Node_Item_Name__c = 'party_requirements',Default_Value__c='', Order__c = 370, Message_Code__c = GTMESSAGECODESA));
        xmlStructure.add(new SFDCToJSONStructure__c(Name = 'Account.Expected_Products',Object_Name__c = 'Account', Field_Name__c = 'Services_Products_Expected_or_currently__c', node_item_child_name__c = '', Node_Name__c = 'Expected_Products' ,Node_Item_Name__c = 'party_requirements',Default_Value__c='', Order__c = 170, Message_Code__c = GTMESSAGECODESA));
        xmlStructure.add(new SFDCToJSONStructure__c(Name = 'Products.Product_Group__c',Object_Name__c = 'Products', Field_Name__c = '', node_item_child_name__c = '', Node_Name__c = 'Product_Group__c' ,Node_Item_Name__c = 'party_requirements',Default_Value__c='To be added later', Order__c = 10, Message_Code__c = GTMESSAGECODESA));
        xmlStructure.add(new SFDCToJSONStructure__c(Name = 'Products.Product_Business_Unit',Object_Name__c = 'Products', Field_Name__c = '', node_item_child_name__c = '', Node_Name__c = 'Product_Business_Unit' ,Node_Item_Name__c = 'party_requirements',Default_Value__c='To be added later', Order__c = 20, Message_Code__c = GTMESSAGECODESA));
        
        
        insert xmlStructure;
        
    }
    
    @isTest 
    static void testClientOnboardingSucceed() {
        
        Account clientForOnboarding = [SELECT Id FROM ACCOUNT WHERE Name = 'Test Fund' LIMIT 1];
        OMF_ManagedFund__c objManagedFund = [SELECT Id FROM OMF_ManagedFund__c WHERE Fund__c =: clientForOnboarding.Id];
        Boolean hasErrors = false;
        
        Map<String, Object> requestJSON = new Map<String, Object>();
        Map<String, Object> requestStatusCode = new Map<String, Object>();
        requestStatusCode.put('Operation', 'New Customer');
        requestStatusCode.put('Success', 'true');
        
        requestJSON.put('RequestStatusCode',requestStatusCode);
        requestJSON.put('version', '1');
        requestJSON.put('request_type', 'New Managed Fund');
        requestJSON.put('process_action', 'Self KYC');
        requestJSON.put('salesforce_id', clientForOnboarding.Id);
        
        bodyAsString = JSON.serialize(requestJSON);
        code = 200;
        Test.setMock(HttpCalloutMock.class, new OMF_OnboardMyFundServiceJSON_Test()); 
        
        
        try{
            (new OMF_API_OnboardMyFundServiceJSON(clientForOnboarding.Id,objManagedFund.Id,GTMESSAGECODESA)).sendRequest();
        }catch(OMF_API_OnboardMyFundServiceJSON.OMF_API_OnboardMyFundServiceJSONException e){
            hasErrors = true;
        }
        assert.areEqual(hasErrors,false,'Record has no errors');
    }
    
    @isTest 
    static void testClientOnboardingFailed() {
        
        Account clientForOnboarding = [SELECT Id FROM ACCOUNT WHERE Name = 'Test Fund' LIMIT 1];
        OMF_ManagedFund__c objManagedFund = [SELECT Id FROM OMF_ManagedFund__c WHERE Fund__c =: clientForOnboarding.Id];
        
        Boolean hasErrors = false;
        
        Map<String, Object> requestJSON = new Map<String, Object>();
        Map<String, Object> requestStatusCode = new Map<String, Object>();
        requestStatusCode.put('Operation', 'New Customer');
        requestStatusCode.put('Success', 'false');
        requestStatusCode.put('ErrorMessage','Error');
        
        requestJSON.put('RequestStatusCode',requestStatusCode);
        requestJSON.put('version', '1');
        requestJSON.put('request_type', 'New Managed Fund');
        requestJSON.put('process_action', 'Self KYC');
        requestJSON.put('salesforce_id', clientForOnboarding.Id);
        
        bodyAsString = JSON.serialize(requestJSON);
        code = 400;
        Test.setMock(HttpCalloutMock.class, new OMF_OnboardMyFundServiceJSON_Test()); 
        
        try{
            (new OMF_API_OnboardMyFundServiceJSON(clientForOnboarding.Id,objManagedFund.Id,GTMESSAGECODESA)).sendRequest();
        }catch(OMF_API_OnboardMyFundServiceJSON.OMF_API_OnboardMyFundServiceJSONException e){
            hasErrors = true;
        }
        assert.areEqual(hasErrors,false,'Record has no errors');
    }
    
    @isTest 
    static void testRequestCode() {
        
        Account clientForOnboarding = [SELECT Id FROM ACCOUNT WHERE Name = 'Test Fund' LIMIT 1];
        OMF_ManagedFund__c objManagedFund = [SELECT Id FROM OMF_ManagedFund__c WHERE Fund__c =: clientForOnboarding.Id];
        
        Boolean hasErrors = false;
        
        Map<String, Object> requestJSON = new Map<String, Object>();
        Map<String, Object> requestStatusCode = new Map<String, Object>();
        requestStatusCode.put('Operation', 'New Customer');
        requestStatusCode.put('Success', 'true');
        requestStatusCode.put('ErrorMessage','Error');
        
        requestJSON.put('RequestStatusCode',requestStatusCode);
        requestJSON.put('version', '1');
        requestJSON.put('request_type', 'New Managed Fund');
        requestJSON.put('process_action', 'Self KYC');
        requestJSON.put('salesforce_id', clientForOnboarding.Id);
        
        bodyAsString = JSON.serialize(requestJSON);
        code = 400;
        Test.setMock(HttpCalloutMock.class, new OMF_OnboardMyFundServiceJSON_Test()); 
        
        try{
            OMF_API_OnboardMyFundServiceJSON.reInitiateKyc(new list<id>{objManagedFund.Id});
        }catch(OMF_API_OnboardMyFundServiceJSON.OMF_API_OnboardMyFundServiceJSONException e){
            hasErrors = true;
        }
        assert.areEqual(hasErrors,false,'Record has errors');
    }
    @isTest 
    static void testCalloutException() {
        
        Account clientForOnboarding = [SELECT Id FROM ACCOUNT WHERE Name = 'Test Fund' LIMIT 1];
        OMF_ManagedFund__c objManagedFund = [SELECT Id FROM OMF_ManagedFund__c WHERE Fund__c =: clientForOnboarding.Id];
        
        Boolean hasErrors = false;
        
        Map<String, Object> requestJSON = new Map<String, Object>();
        Map<String, Object> requestStatusCode = new Map<String, Object>();
        requestStatusCode.put('Operation', 'New Customer');
        
        requestJSON.put('RequestStatusCode',requestStatusCode);
        requestJSON.put('version', '1');
        requestJSON.put('request_type', 'New Managed Fund');
        requestJSON.put('process_action', 'Self KYC');
        requestJSON.put('salesforce_id', clientForOnboarding.Id);
        
        bodyAsString = JSON.serialize(requestJSON);
        code = 400;
        Test.setMock(HttpCalloutMock.class, new OMF_OnboardMyFundServiceJSON_Test()); 
        
        try{
            (new OMF_API_OnboardMyFundServiceJSON(clientForOnboarding.Id,objManagedFund.Id,GTMESSAGECODESA)).sendRequest();
        }catch(OMF_API_OnboardMyFundServiceJSON.OMF_API_OnboardMyFundServiceJSONException e){
            hasErrors = true;
        }
        assert.areEqual(hasErrors,true,'Record has  errors');
    }
    
    @isTest 
    static void testRequestCodeError() {
        
        Account clientForOnboarding = [SELECT Id FROM ACCOUNT WHERE Name = 'Test Fund' LIMIT 1];
        OMF_ManagedFund__c objManagedFund = [SELECT Id FROM OMF_ManagedFund__c WHERE Fund__c =: clientForOnboarding.Id];
        objManagedFund.RejectionReason__c = 'already exists in Goldtier';
        update objManagedFund;
        
        Boolean hasErrors = false;
        
        Map<String, Object> requestJSON = new Map<String, Object>();
        Map<String, Object> requestStatusCode = new Map<String, Object>();
        requestStatusCode.put('Operation', 'New Customer');
        requestStatusCode.put('Success', 'true');
        requestStatusCode.put('ErrorMessage','Error');
        
        requestJSON.put('RequestStatusCode',requestStatusCode);
        requestJSON.put('version', '1');
        requestJSON.put('request_type', 'New Managed Fund');
        requestJSON.put('process_action', 'Self KYC');
        requestJSON.put('salesforce_id', clientForOnboarding.Id);
        
        bodyAsString = JSON.serialize(requestJSON);
        code = 400;
        Test.setMock(HttpCalloutMock.class, new OMF_OnboardMyFundServiceJSON_Test()); 
        
        try{
            (new OMF_API_OnboardMyFundServiceJSON(clientForOnboarding.Id,objManagedFund.Id,GTMESSAGECODESA)).sendRequest();
        }catch(OMF_API_OnboardMyFundServiceJSON.OMF_API_OnboardMyFundServiceJSONException e){
            hasErrors = true;
        }
        assert.areEqual(hasErrors,true,'Record has errors');
    }
    @isTest
    static void testcallPlatformEventForUpdateCIF(){
        OMF_ManagedFund__c omfRecord=[select id,Onboarding_Status__c from OMF_ManagedFund__c limit 1];
        OMF_ManagedFundRecordUpdate__e asyncDmlForOMF = new OMF_ManagedFundRecordUpdate__e();
        asyncDmlForOMF.ManagedFundRecordId__c = omfRecord.Id;
        asyncDmlForOMF.NewOnboardingStatus__c = 'KYC Submission Failed';
        Test.startTest();
        Database.SaveResult result=EventBus.publish(asyncDmlForOMF);
        Test.stopTest();
        OMF_ManagedFund__c omfRecordUpdated=[select id,Onboarding_Status__c from OMF_ManagedFund__c where id=:omfRecord.Id limit 1];
        Assert.areEqual(true,result.isSuccess(),'suucess event');
    }
     /**
    * @description: SFP-38486 - Added test method to test KYC Failure.
    * @author Aman Kumar
    **/
    @isTest 
    static void testFundNotFoundInGoldTier() {
        
        Account clientForOnboarding = [SELECT Id FROM ACCOUNT WHERE Name = 'Test Fund' LIMIT 1];
        OMF_ManagedFund__c objManagedFund = [SELECT Id FROM OMF_ManagedFund__c WHERE Fund__c =: clientForOnboarding.Id];
        
        Boolean hasErrors = false;
        
        Map<String, Object> requestJSON = new Map<String, Object>();
        Map<String, Object> requestStatusCode = new Map<String, Object>();
        requestStatusCode.put('Operation', 'New Customer');
        requestStatusCode.put('Success', 'false');
        requestStatusCode.put('ErrorMessage','was not found in Goldtier');
        
        requestJSON.put('RequestStatusCode',requestStatusCode);
        requestJSON.put('version', '1');
        requestJSON.put('request_type', 'New Managed Fund');
        requestJSON.put('process_action', 'Self KYC');
        requestJSON.put('salesforce_id', clientForOnboarding.Id);
        
        bodyAsString = JSON.serialize(requestJSON);
        code = 400;
        Test.setMock(HttpCalloutMock.class, new OMF_OnboardMyFundServiceJSON_Test()); 
        
        try{
            (new OMF_API_OnboardMyFundServiceJSON(clientForOnboarding.Id,objManagedFund.Id,GTMESSAGECODESA)).sendRequest();
        }catch(OMF_API_OnboardMyFundServiceJSON.OMF_API_OnboardMyFundServiceJSONException e){
            hasErrors = true;
        }
        assert.areEqual(hasErrors,false,'Record has no errors');
    }
    /**
    * @description: Added test method to test KYC Failure Notification.
    * @author Aman Kumar
    **/ 
    @isTest 
    static void testKYCSubmissionFailureNotification() {
        
        Account clientForOnboarding = [SELECT Id FROM ACCOUNT WHERE Name = 'Test Fund' LIMIT 1];
        OMF_ManagedFund__c objManagedFund = [SELECT Id FROM OMF_ManagedFund__c WHERE Fund__c =: clientForOnboarding.Id];
        Boolean hasErrors = false;
        try{
            test.startTest();
            OMF_API_OnboardMyFundServiceJSON.handleKYCAPIFailureNotification(objManagedFund.Id);
            test.stopTest();
        }catch(Exception e){
            hasErrors = true;
        }
        assert.areEqual(hasErrors,false,'Record has no errors');
    }
    
}