@isTest
public class CMN_DAL_DataFactory_Test {
    
    @isTest
    public static void Test_disableAPI(){ 
        
        Test.startTest();
        CMN_DAL_DataFactory.disableAPI('TestAPIName');
        Test.stopTest();  
    }
    
    @isTest
    public static void Test_newSpcUsersToEnable(){
        Test.startTest();
        CMN_SPC_UsersToEnable__c newUsersToEnable = CMN_DAL_DataFactory.newSpcUsersToEnable('TestUser', 'profileName', 'userName'); // to be edited
        Test.stopTest(); 
    }
    
    @isTest
    public static void Test_disableTrigger(){
        Test.startTest();
        CMN_DAL_DataFactory.disableTrigger('testTriggerName');
        Test.stopTest(); 
    }
    
    @isTest
    public static void Test_newUser(){
        Test.startTest();
        CMN_DAL_DataFactory.newUser(DMN_Profile.PERSONAL_BUSINESS_BANKING_CUSTOM_STD_USER_MOBILE); //to be edited
        Test.stopTest(); 
    }
    
   @isTest
    public static void Test_newAccount(){
        Test.startTest();
        Account newAccount = CMN_DAL_DataFactory.newAccount();
        Test.stopTest();
    }
    
    @isTest
    public static void Test_insertAccount(){
        Test.startTest();
        Account newAccount = CMN_DAL_DataFactory.insertAccount();
        Test.stopTest();
    }
    
    @isTest
    public static void Test_newContact(){
        Test.startTest();
        Contact newContact = CMN_DAL_DataFactory.newContact();
        Test.stopTest();
    }
    
    @isTest
    public static void Test_newInboundEmail(){
        Test.startTest();
        Messaging.InboundEmail newEmail = CMN_DAL_DataFactory.newInboundEmail();
        Test.stopTest();
    }
    
    @isTest 
    public static void Test_newJobScheduler(){
        Test.startTest();
        CMN_JobScheduler__c scheduler = CMN_DAL_DataFactory.newJobScheduler('Schedule_SA_batchJob_ISICMapping');
        Test.stopTest();
    }
    
    @isTest
    public static void Test_insertJobScheduler(){
        Test.startTest();
        CMN_JobScheduler__c scheduler = CMN_DAL_DataFactory.insertJobScheduler('Schedule_SA_batchJob_ISICMapping');
        Test.stopTest();
    }
    
    @isTest
    public static void Test_newWebserviceQueue(){
        Test.startTest();
        CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newWebserviceQueue('TestserviceName');
        Test.stopTest();
    }
    
    @isTest
    public static void Test_newInboundWebserviceQueue(){
        try{Test.startTest();
        CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newInboundWebserviceQueue('InboundTestServiceName');
      
        Test.stopTest();
           }catch(exception e)
           {
}
        
    }
    
    /*@isTest
    public static void Test_newOutboundWebserviceQueue(){
        Test.startTest();
        CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue('OutboundTestServiceName');
        Test.stopTest();
    }*/
    
    @isTest
    public static void Test_newInboundEnvelope(){
        Test.startTest();
        Messaging.InboundEnvelope newEnvelope = CMN_DAL_DataFactory.newInboundEnvelope();
        Test.stopTest();
    }
    
    @isTest
    public static void Test_createFeatureSwitch(){
        Account testAccount = TEST_DataFactory.stdBankEmpAcc;
        Contact testCont = new Contact(FirstName = DMN_Contact.CDG_REF_FIRSTNAME,
    								   LastName = DMN_Contact.CDG_REF_LASTNAME,
                                       Email = DMN_Contact.CDG_REF_EMAIL,
                                       AccountId = testAccount.Id,
                                       RecordTypeId = UTL_RecordType.getRecordTypeId(DMN_Contact.OBJ_NAME, DMN_Contact.RTD_BANK));
        Test.startTest();
        CMN_DAL_DataFactory.createFeatureSwitch(testCont.id);
        Test.stopTest();
    }
    
    @isTest
    public static void Test_newContentVersion(){
        Account testAccount = TEST_DataFactory.stdBankEmpAcc;
        Test.startTest();
        ContentVersion newContentVersion = CMN_DAL_DataFactory.newContentVersion(testAccount.id, 'TestFileName', Blob.valueOf('TestBlob'));
        Test.stopTest();
    }
    
    @isTest
    public static void Test_newCase(){
        Account testAccount = TEST_DataFactory.stdBankEmpAcc;
        Contact testCont = new Contact(FirstName = DMN_Contact.CDG_REF_FIRSTNAME,
    								   LastName = DMN_Contact.CDG_REF_LASTNAME,
                                       Email = DMN_Contact.CDG_REF_EMAIL,
                                       AccountId = testAccount.Id,
                                       RecordTypeId = UTL_RecordType.getRecordTypeId(DMN_Contact.OBJ_NAME, DMN_Contact.RTD_BANK));
        Test.startTest();
        CMN_DAL_DataFactory.newCase(testCont.id);
        Test.stopTest();
    }
    
    @isTest
    public static void Test_newOutboundWebserviceQueue2(){
        Account testAccount = TEST_DataFactory.stdBankEmpAcc;
        Test.startTest();
        CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue('TestServiceName',testAccount.id);
        Test.stopTest();
    }
    
    @isTest
    public static void Test_newContentVersionsFromBinaryAttachments(){
        Account testAccount = TEST_DataFactory.stdBankEmpAcc;
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.fileName = 'TestName';
        attachment.body = Blob.valueOf('TestBlob');
        
        Test.startTest();
        CMN_WebserviceCallQueue__c queueItem = CMN_DAL_DataFactory.newOutboundWebserviceQueue('TestserviceName');
        Test.stopTest();
    }
    
}