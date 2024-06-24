/***
    @ Func Area         : Email Sending
    @ Author            : Artur Kępczynski 
    @ Date              : 08.2017  
    @ Specification     : Main class to manage sending emails.
***/
public without sharing class SRV_Email {
	
	public static void sendRejectionCifClient(Set<Id> accountsIds){
		Id templateId = UTL_EmailTemplate.getTemplateId(DCN_EmailTemplate.CIF_CLIENT_REJECTION);
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
		Set<String> emailAddresses = new Set<String>{
				EmailAddress__c.getValues(DCN_CustomSetting.CDG_MAILBOX).Email__c,
				EmailAddress__c.getValues(DCN_CustomSetting.CRM_MAILBOX).Email__c};  

		for(Id accountId : accountsIds){
			emails.add(UTL_Email.createEmails(templateId, accountId, emailAddresses));
		}

		Messaging.sendEmail(emails);
	}

	public static void sendOnboardingSubsectorChange(Account[] accounts){
		Id templateId = UTL_EmailTemplate.getTemplateId(DCN_EmailTemplate.ONBOARDING_SECTOR_CHANGE);
        Messaging.SingleEmailMessage[] emails = new Messaging.SingleEmailMessage[]{};
		List<Id> ccIds = new List<Id>();
		for(Account acc: accounts) {
			ccIds.add(acc.Client_Co_ordinator__c);
		}
		UTL_User.getCachedUsers(ccIds);
        for(Account acc : accounts){
        	emails.add(UTL_Email.createEmails(templateId, acc.Id, UTL_User.getCachedUser(acc.Client_Co_ordinator__c).Contact_Sync_ID__c));
        }
        Messaging.sendEmail(emails);
	}
}