/**
  @description It will test the ACM_SendEmailToUser class 
  @className ACM_SendEmailToUserTest  
  @Author - Purna Unnagiri
  @email 	purna.unnagiri@standardbank.co.za
  @company  Standardbank    
  @date  Feb 17, 2022
**/
@isTest
public class ACM_SendEmailToUserTest {
    
    /**
     * @description Helper method to instantiate the handler sendEmailToUser
     **/     
    static testMethod void testSendEmailToUser() {

        Test.startTest();
		Case c = new Case();
        c.RecordtypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Cross_Border_CoE_Closed_Record_Type').getRecordTypeId();
        c.Subject = 'Test';
        c.Case_type__c = 'APICentral';
        c.Origin = 'Client Email';
        insert c;
        
		String caseCreationTemplateInternal = ACM_GeneralSettings__mdt.getInstance('ACM_CaseCreationTemplateInternal').Value__c;
		String orgWideEmailInfo = ACM_GeneralSettings__mdt.getInstance('ACM_SubscriptionOrgWideEmailAddress').Value__c;
		EmailTemplate emailTemplateInfo = [SELECT Id, Name, DeveloperName FROM EmailTemplate WHERE DeveloperName = :caseCreationTemplateInternal limit 1];
		
		OrgWideEmailAddress OrgWideEmailAddressInfo = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress where Address=:orgWideEmailInfo limit 1];
		
		List<ACM_SendEmailToUser.InputParameters> inputParamsList = new List<ACM_SendEmailToUser.InputParameters>();                
        for(Integer i=1; i<=20; i++){
            ACM_SendEmailToUser.InputParameters inputParams = new ACM_SendEmailToUser.InputParameters();                    
            inputParams.emailTemplateId = emailTemplateInfo.Id;
            inputParams.userId = USerInfo.getUserId();
            inputParams.whatId = c.Id;
            inputParams.orgWideEmailAddressId = OrgWideEmailAddressInfo.Id;
            inputParamsList.add(inputParams);
        }
        ACM_SendEmailToUser.sendEmailToUser(inputParamsList);
        Integer invocations = Limits.getEmailInvocations();        
        Test.stopTest();    
        Assert.areEqual(emailTemplateInfo.DeveloperName, caseCreationTemplateInternal);
		Assert.areEqual(OrgWideEmailAddressInfo.Address, orgWideEmailInfo);
        Assert.areEqual(1, invocations, 'Email has sent');
        Assert.isTrue(invocations <= Limits.getLimitEmailInvocations(), 'Total number of sendEmai methods allowed 10 only');

    }
}