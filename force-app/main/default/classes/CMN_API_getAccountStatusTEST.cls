@IsTest
public class CMN_API_getAccountStatusTEST { 
      
    @IsTest
	private static void getAccountStatusEnquire()
    {   
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Account testAccount = new BLD_Account(uow);
        testAccount.CIF('530437495')
                    .setField(Account.Name, 'dwadawdawdfdfewafdea')
                    .setField(Account.ExternalIdentifier__c, 'ZA10111')
                    .setField(Account.DR_Retain_Until__c, Date.today())                            
                    .setField(Account.BillingCountry, 'South Africa')
                    .setField(Account.Industry_Code__c,'65990')
                    .setField(Account.Primary_Relationship_Holder__c, 'Commercial Banking')
                    .setField(Account.CIF_Client_Type__c, 'R');
        uow.commitWork();      
        //}
        CMN_API_getAccountStatus.EnquireRequest accountBPStatusRequest = new CMN_API_getAccountStatus.EnquireRequest();
        accountBPStatusRequest.operation = 'enquire';
        CMN_API_getAccountStatus.CustomerInfo customerInfos = new CMN_API_getAccountStatus.CustomerInfo();
        
        customerInfos.externalIdentifier = 'ZA10111';
        accountBPStatusRequest.customerInfo = new List<CMN_API_getAccountStatus.CustomerInfo>();
        accountBPStatusRequest.customerInfo.add(customerInfos);
        
		List<CMN_API_getAccountStatus.AccountInfo> accInfObjList = new List<CMN_API_getAccountStatus.AccountInfo>();
		Test.startTest();
         accInfObjList = CMN_API_getAccountStatus.getAccountStatus(accountBPStatusRequest);
         Assert.areEqual('Success', accInfObjList[0].results, 'Success');
		Test.stopTest();
   
     }
    
     @IsTest
	private static void getAccountStatusDelete()
    {
        
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Account testAccount = new BLD_Account(uow);
        testAccount.CIF('530437495')
                    .setField(Account.Name, 'dwadawdawdfdfewafdea')
                    .setField(Account.ExternalIdentifier__c, 'ZA10222')
                    .setField(Account.BillingCountry, 'South Africa')
                    .setField(Account.DR_Retain_Until__c, Date.today())                            
                    .setField(Account.Industry_Code__c,'65990')
                    .setField(Account.Primary_Relationship_Holder__c, 'Commercial Banking')
                    .setField(Account.CIF_Client_Type__c, 'R');
        uow.commitWork();
        
         
        CMN_API_getAccountStatus.EnquireRequest accountBPStatusRequest = new CMN_API_getAccountStatus.EnquireRequest();
        accountBPStatusRequest.operation = 'delete';
        CMN_API_getAccountStatus.CustomerInfo customerInfos = new CMN_API_getAccountStatus.CustomerInfo();
        
        customerInfos.externalIdentifier = 'ZA10222';
        accountBPStatusRequest.customerInfo = new List<CMN_API_getAccountStatus.CustomerInfo>();
        accountBPStatusRequest.customerInfo.add(customerInfos);
        
		List<CMN_API_getAccountStatus.AccountInfo> accInfObjList = new List<CMN_API_getAccountStatus.AccountInfo>();
		Test.startTest();
         accInfObjList = CMN_API_getAccountStatus.getAccountStatus(accountBPStatusRequest);
         Assert.areEqual('Success', accInfObjList[0].results, 'Success');
		Test.stopTest();
         
    }
    
    @IsTest
	private static void getAccountNotFound()
    {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Account testAccount = new BLD_Account(uow);
        testAccount.CIF('530437495')
                    .setField(Account.Name, 'dwadawdawdfdfewafdea')
                    .setField(Account.ExternalIdentifier__c, 'ZA10222')
                    .setField(Account.BillingCountry, 'South Africa')
                    .setField(Account.DR_Retain_Until__c, Date.today())                            
                    .setField(Account.Industry_Code__c,'65990')
                    .setField(Account.Primary_Relationship_Holder__c, 'Commercial Banking')
                    .setField(Account.CIF_Client_Type__c, 'R');
        uow.commitWork();      
      
        CMN_API_getAccountStatus.EnquireRequest accountBPStatusRequest = new CMN_API_getAccountStatus.EnquireRequest();
        accountBPStatusRequest.operation = 'enquire';
        CMN_API_getAccountStatus.CustomerInfo customerInfos = new CMN_API_getAccountStatus.CustomerInfo();
        
        customerInfos.externalIdentifier = 'ZA10225';
        accountBPStatusRequest.customerInfo = new List<CMN_API_getAccountStatus.CustomerInfo>();
        accountBPStatusRequest.customerInfo.add(customerInfos);
        
		List<CMN_API_getAccountStatus.AccountInfo> accInfObjList = new List<CMN_API_getAccountStatus.AccountInfo>();
		Test.startTest();
         accInfObjList = CMN_API_getAccountStatus.getAccountStatus(accountBPStatusRequest);
         Assert.areEqual('Not Found', accInfObjList[0].results, 'Success');
		Test.stopTest();
         
    }   
    
    @IsTest
	private static void getAccountNotEligiblefordeletion()
    {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Account testAccount = new BLD_Account(uow);
        testAccount.CIF('530437495')
                    .setField(Account.Name, 'dwadawdawdfdfewafdea')
                    .setField(Account.ExternalIdentifier__c, 'ZA10226')
                    .setField(Account.BillingCountry, 'South Africa')
                    .setField(Account.DR_Retain_Until__c, Date.today().addyears(5))                            
                    .setField(Account.Industry_Code__c,'65990')
                    .setField(Account.Primary_Relationship_Holder__c, 'Commercial Banking')
                    .setField(Account.CIF_Client_Type__c, 'R');
        uow.commitWork();      
      
        CMN_API_getAccountStatus.EnquireRequest accountBPStatusRequest = new CMN_API_getAccountStatus.EnquireRequest();
        accountBPStatusRequest.operation = 'enquire';
        CMN_API_getAccountStatus.CustomerInfo customerInfos = new CMN_API_getAccountStatus.CustomerInfo();
        
        customerInfos.externalIdentifier = 'ZA10226';
        accountBPStatusRequest.customerInfo = new List<CMN_API_getAccountStatus.CustomerInfo>();
        accountBPStatusRequest.customerInfo.add(customerInfos);
        
		List<CMN_API_getAccountStatus.AccountInfo> accInfObjList = new List<CMN_API_getAccountStatus.AccountInfo>();
		Test.startTest();
         accInfObjList = CMN_API_getAccountStatus.getAccountStatus(accountBPStatusRequest);
         Assert.areEqual('Success', accInfObjList[0].results, 'Success');
		Test.stopTest();
         
    } 
    
     @IsTest
	private static void getAccountNotEligiblefordeletionv1()
    {
        Account acc = new Account();
        acc.Name = 'dwadawdawdfdfewafdeayyy';
        acc.ExternalIdentifier__c = 'ZA10777';
        acc.DR_Retain_Until__c = Date.today().addyears(5);
        insert acc;

        Contact con = new Contact();
        con.LastName = 'POPIA Test';
        con.AccountId = acc.Id;
        insert con;
      
        CMN_API_getAccountStatus.EnquireRequest accountBPStatusRequest = new CMN_API_getAccountStatus.EnquireRequest();
        accountBPStatusRequest.operation = 'delete';
        CMN_API_getAccountStatus.CustomerInfo customerInfos = new CMN_API_getAccountStatus.CustomerInfo();
        
        customerInfos.externalIdentifier = 'ZA10777';
        accountBPStatusRequest.customerInfo = new List<CMN_API_getAccountStatus.CustomerInfo>();
        accountBPStatusRequest.customerInfo.add(customerInfos);
        
		List<CMN_API_getAccountStatus.AccountInfo> accInfObjList = new List<CMN_API_getAccountStatus.AccountInfo>();
		Test.startTest();
         accInfObjList = CMN_API_getAccountStatus.getAccountStatus(accountBPStatusRequest);
         Assert.areEqual('Not eligible for deletion', accInfObjList[0].results, 'Success');
		Test.stopTest();
         
    }   
}