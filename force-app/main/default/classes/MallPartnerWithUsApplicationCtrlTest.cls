@isTest
public class MallPartnerWithUsApplicationCtrlTest{
	
    @IsTest
    private static void getUserRecordTest(){
        String userId = userInfo.getUserId();
        Test.startTest();
        MallPartnerWithUsApplicationCtrl.getUserRecord(userId);
        try{
            MallPartnerWithUsApplicationCtrl.getUserRecord('0001');
        }catch(Exception e) {
            AuraHandledException aueaEx = MallPartnerWithUsApplicationCtrl.throwAuraException('getUserRecord',e);
            Assert.areEqual(true, aueaEx.getMessage().contains('0001'), 'exception');
        }
        Test.stopTest();
    }
    
    @IsTest
    private static void createCaseRecordTest(){
        Account account = new Account();
        account.Name = 'Web Africa';
        Id devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
		account.RecordTypeId = devRecordTypeId;
        insert account;
        
        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName = 'Contact';
        contact.Email = 'test@gmail.com';
        contact.AccountId = account.Id;
        insert contact;

        Case caseRecord = new Case();
        caseRecord.Subject = 'Store onboarding application form';
        caseRecord.ContactId = contact.Id;
        caseRecord.Description = 'Store onboarding application form';
   
        Test.startTest();
        Test.SetMock(HttpCallOutMock.class, new CreateContactRestAPIMock());
        string result=MallPartnerWithUsApplicationCtrl.createCaseRecord(caseRecord);
        string expectedResult='00000003';
        Assert.areEqual(result, expectedResult,'Mock response should be same');
        result=MallPartnerWithUsApplicationCtrl.createCaseRecord(new Case());
        Test.stopTest();
    }
    
    public class CreateContactRestAPIMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"id": "00000003","FirstName":"Test","LastName":"Test"}');
            response.setStatusCode(201);
            return response;
        }
    }
}