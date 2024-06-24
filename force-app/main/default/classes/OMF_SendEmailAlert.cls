/*
    @Author         :   Manisha
    @Create Date    :   08-11-2022
    @Purpose        :   Class for Sending Emails for Managed Fund
    @JIRA Tickets   :   SFP-18381
*/
public without sharing class OMF_SendEmailAlert {
    public void sendRejectionEmailsendRejectionEmailsendRejectionEmail(String str_recordId, String str_templateId) {
        //Fetch List of records for OMF_ManagedFund__c
        List<OMF_ManagedFund__c>  list_managedFund=[select id, CreatedById from OMF_ManagedFund__c where id =: str_recordId LIMIT 1]; 
        String str_userId=(string)list_managedFund[0].CreatedById;
        String str_whatId= str_recordId;
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(str_templateId, str_userId, str_whatId);
        List<String> list_user=new List<String>();
        List<User> list_reciepientAddress  = [select id, email from user where id=:str_userId LIMIT 1];
        list_user.add(list_reciepientAddress[0].email);
        mail.setTargetObjectId(list_reciepientAddress[0].id);        
        mail.setSaveAsActivity(false);
        mail.setToAddresses(list_user);
        String emailSubject = mail.getSubject();
        String emailTextBody = mail.getPlainTextBody();
        mail.setSubject(emailSubject);
        mail.setPlainTextBody(emailTextBody);     
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}