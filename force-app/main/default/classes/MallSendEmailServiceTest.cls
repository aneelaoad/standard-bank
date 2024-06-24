/**
 * 
 * @description Test Class for MallSendEmailService
 * @author Maham Hasan
 * @since 
 */
@isTest
public with sharing class MallSendEmailServiceTest {
    
  @IsTest
  public static void sendEmailToContactTest() {     
    User u = [Select Id, Name, Ping_BPGUID__c from USER WHERE ID =: UserInfo.getUserId() LIMIT 1];  
    User portalUser = MallTestDataFactory.createPortalUser(u);
    System.runAs(u) {
      EmailTemplate emailTemplate =new EmailTemplate();
      emailTemplate.Name = 'Tenant Registration Email Notification';
      emailTemplate.DeveloperName = 'Tenant_Registration_Email_Notification';
      emailTemplate.TemplateType= 'Text';
      emailTemplate.FolderId = [select Type from Folder where Type = 'Email' LIMIT 1].id;
      emailTemplate.IsActive = true;
      insert emailTemplate;
      Test.startTest();
      MallSendEmailService.createEmailsForContactsBasedOnEmailTemplate(new List<String> {portalUser.ContactId}, emailTemplate.Name);
      Assert.areEqual('Tenant Registration Email Notification', emailTemplate.Name, 'Expected email name');
      Test.stopTest();
    }       
  }

  @IsTest
  public static void sendEmailToUserTest() {
    User user = [Select Id, Name, Ping_BPGUID__c from USER WHERE ID =: UserInfo.getUserId() LIMIT 1];  
    System.runAs(user) {
      EmailTemplate emailTemplate = new EmailTemplate();
      emailTemplate.Name = 'Tenant Registration Email Notification';
      emailTemplate.DeveloperName = 'Tenant_Registration_Email_Notification';
      emailTemplate.TemplateType= 'Text';
      emailTemplate.IsActive = true;
      emailTemplate.FolderId = [select Type from Folder where Type = 'Email' LIMIT 1].id;
      insert emailTemplate;
      
      MallSendEmailService.createEmailsForUsersBasedOnEmailTemplate(new List<String> {user.Id}, emailTemplate.DeveloperName);
      Assert.areEqual('Tenant_Registration_Email_Notification', emailTemplate.DeveloperName, 'Expected email name');
    }       
  }
}