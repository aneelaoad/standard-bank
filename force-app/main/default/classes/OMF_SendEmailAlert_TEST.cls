/*************************************************************************
Author        : Naveen B
Date          : 06-01-2023
Description   : Test class code coverage for OMF_SendEmailAlert
*************************************************************************/
@IsTest
public class OMF_SendEmailAlert_TEST {
    @TestSetup
    static void setupTestData(){
        // Set up test data
        Id amRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Child').getRecordTypeId();
        Account assetManager = new Account(
            RecordTypeId = amRecordTypeId,
            Name='Test Manager',
            CIF__c ='34561' 
        );
        Id fundRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Fund').getRecordTypeId();
        Account fund = new Account(
            RecordTypeId = fundRecordTypeId,
            Name='Test Fund',
            CIF__c = '12341'
        );
        insert assetManager;
        insert fund;
        OMF_ManagedFund__c managedFund = new OMF_ManagedFund__c(
            Fund__c=fund.Id,
            AssetManager__c = assetManager.Id
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
        OMF_FundToAgreement__c agreement = new OMF_FundToAgreement__c(
            ManagedFundID__c = managedFund.Id);
        insert agreement;
    }
    
    @isTest static void sendRejectionEmailTest() {
        // call the method to be tested
        Test.startTest();
        List<OMF_ManagedFund__c> lstManagedFunds = [SELECT Id FROM OMF_ManagedFund__c LIMIT 1];
        if(!lstManagedFunds.isEmpty()){   
            EmailTemplate emailTempID = [SELECT id FROM EmailTemplate WHERE developerName = 'OMF_KYCRejected'];
            String tempID=(String)emailTempID.id;
            OMF_SendEmailAlert alert = new OMF_SendEmailAlert();
            alert.sendRejectionEmailsendRejectionEmailsendRejectionEmail(lstManagedFunds[0].Id, tempID);
            System.assertEquals(1, Limits.getEmailInvocations(), 'Email should be sent once.');
        }
        
        Test.stopTest();
    }
}