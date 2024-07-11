/***************************************************************************************
* @Name of the Class     :ZAF_CTRL_StandardPricingLetter
* @description          : Class for sending an email to the client related contact with Client Pricing Letter PDF attachment
* @Author                :Pradeep Kota  
* @Created Date          :18th Jan 2024
/***************************************************************************************
*@Last Modified By  : Pradeep Kota  
*@Last Modified On  : 06 Mar 2024
*@Modification Description : SFP-30097
***************************************************************************************/
public class ZAF_CTRL_StandardPricingLetter {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ZAF_CTRL_SendClientPricingLetter');
    /**
* @description gets a String
* @param recordId 
* @return List<contact> 
*/
    @AuraEnabled(cacheable = true)
    public static List<contact> sendEmailToController(Id recordId){
        try{
            return new SEL_Contacts().selectContactByContactRole(recordId);
        }catch(Exception e){
            LOGGER.error('Any error message'+e);
            return null;
        }   
    }
     /**
     * @description method to fetch the Pricing Arrangements
     * @param recordId 
     * @return Boolean
    **/
    @AuraEnabled(cacheable=true)
    public static Boolean getThePricingArrangement(string recordId){
          list<zafin_rrp__Negotiated_Pricing__c>   zafinNegotiatiedPricing= new SEL_ZafinNegotiatedPricing().selectZafinNegotiationPricingById(recordId);
        if(zafinNegotiatiedPricing.size() >0){
            return true;
        }else{
            return false;
        }
    }
    /**
* @description gets a String
* @param recordId 
* @param customEmail 
* @param adhoc 
* @param bank 
* @return string 
*/
    @AuraEnabled(cacheable = true)
    public static string sendCustomEmail(Id recordId ,List<string> customEmail,string adhoc,string bank){
        List<EmailTemplate> emailTemplate;
        Account acc= new SEL_Accounts().selectByAccountId(recordId);
        Id fromEmail = new SEL_OrgWideEmailAddress().selectByDisplayName(ZAF_CTRL_ClientPricingLetterConstants.ZAFIN_PRICING_AND_BILLING).Id;
        List<contact> conList = new List<contact>();
                 List<Messaging.SingleEmailMessage> singleMailList = new List<Messaging.SingleEmailMessage>();
        for(string checkedEmails:customEmail){
            contact con = new SEL_Contacts().selectContactByEmail(recordId,checkedEmails);
            if(string.valueOf(con) != ''){
                conList.add(con);
            }
        }
        if(!string.isEmpty(bank)){
            if(bank ==ZAF_CTRL_ClientPricingLetterConstants.ZAFIN_CORPORATE){
                emailTemplate = new SEL_EmailTemplate().selectByName(ZAF_CTRL_ClientPricingLetterConstants.ZAFIN_CORPORATE_LETTER);
            }else{
                emailTemplate = new SEL_EmailTemplate().selectByName(ZAF_CTRL_ClientPricingLetterConstants.ZAF_BANK_SECTOR);
            }       
        }else{
            emailTemplate = new SEL_EmailTemplate().selectByName(ZAF_CTRL_ClientPricingLetterConstants.ZAFIN_MONTHLY_ENVIRONMENT_LETTER);
        }
        PageReference pdf = Page.ZAF_ClientPricingLetterVFPage;
        pdf.getParameters().put('Id',recordId);
        Boolean hasRequiredPermissionSet = [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSet.Name = 'CIB_TxB_SA_Pricing_Capturer' AND AssigneeId = :UserInfo.getUserId()] > 0;
        for(contact conEmail:conList){
            pdf.getParameters().put('email',conEmail.Email);
            Blob body;                
            try{
                body = pdf.getContent();
            }catch(VisualforceException e){
                LOGGER.error('Any error message'+e);
                body=Blob.valueOf('error');
            }   
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setContentType('application/pdf');
            attach.setFileName(acc.CIF__c+' - '+ acc.Name + '.pdf');
            attach.setInline(false);
            attach.Body = body;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateID(emailTemplate[0].Id);
            mail.setOrgWideEmailAddressId(fromEmail);  
            mail.setUseSignature(false);
            mail.setToAddresses(new String[] { conEmail.Email });
            mail.setSubject(ZAF_CTRL_ClientPricingLetterConstants.ZAFIN_2023_ANNUAL_PRICE_REVIEW+acc.Name);
            if (hasRequiredPermissionSet) {
                mail.setCcAddresses(new List<String>{UserInfo.getUserEmail()});
            } 
            String htmlBody = emailTemplate[0].HtmlValue;
            htmlBody = htmlBody.replace(string.valueOf('{Party_First_Name}'),conEmail.FirstName);
            mail.setHtmlBody(htmlBody);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
            singleMailList.add(mail);
        }
                Messaging.sendEmail(singleMailList);
                return 'success';
    }
    /**
* @description gets a String
* @param recordId
* @param customEmail
* @param adhoc 
* @param bank 
* @return string 
*/
    @AuraEnabled(cacheable = true)
    public static string sendFullStandardCustomEmail(Id recordId ,List<string> customEmail,string adhoc,string bank){
        List<EmailTemplate> emailTemplate;
                Account acc= new SEL_Accounts().selectByAccountId(recordId);
        Id fromEmail = new SEL_OrgWideEmailAddress().selectByDisplayName(ZAF_CTRL_ClientPricingLetterConstants.ZAFIN_PRICING_AND_BILLING).Id;
        List<contact> conList = new List<contact>();
        List<Messaging.SingleEmailMessage> singleMailList = new List<Messaging.SingleEmailMessage>();
        for(string checkedEmails:customEmail){
            contact con = new SEL_Contacts().selectContactByEmail(recordId,checkedEmails);
            if(string.valueOf(con) != ''){
                conList.add(con);
            }
        }
        if(!string.isEmpty(bank)){
            if(bank ==ZAF_CTRL_ClientPricingLetterConstants.ZAFIN_CORPORATE){
                emailTemplate = new SEL_EmailTemplate().selectByName(ZAF_CTRL_ClientPricingLetterConstants.ZAFIN_CORPORATE_LETTER);
            }else{
                emailTemplate = new SEL_EmailTemplate().selectByName(ZAF_CTRL_ClientPricingLetterConstants.ZAF_BANK_SECTOR);
            }
            
        }else{
            emailTemplate = new SEL_EmailTemplate().selectByName(ZAF_CTRL_ClientPricingLetterConstants.ZAFIN_MONTHLY_ENVIRONMENT_LETTER);
        }
        PageReference pdf = Page.ZAF_FullStandardPricingLetterVFPage;
        Boolean hasRequiredPermissionSet = [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSet.Name = 'CIB_TxB_SA_Pricing_Capturer' AND AssigneeId = :UserInfo.getUserId()] > 0;
        for(contact conEmail:conList){
            pdf.getParameters().put('email',conEmail.Email);
            Blob body;                
            try{
                body = pdf.getContent();
            }catch(VisualforceException e){
                LOGGER.error('Any error message'+e);
                body=Blob.valueOf('error');
            }   
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setContentType('application/pdf');
            attach.setFileName(ZAF_CTRL_ClientPricingLetterConstants.ZAF_STANDARD_PRICING);
            attach.setInline(false);
            attach.Body = body;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateID(emailTemplate[0].Id);
            mail.setOrgWideEmailAddressId(fromEmail);  
            mail.setUseSignature(false);
            mail.setToAddresses(new String[] { conEmail.Email });
            mail.setSubject(ZAF_CTRL_ClientPricingLetterConstants.ZAFIN_2023_ANNUAL_PRICE_REVIEW+acc.Name);
            if (hasRequiredPermissionSet) {
                mail.setCcAddresses(new List<String>{UserInfo.getUserEmail()});
            } 
            String htmlBody = emailTemplate[0].HtmlValue;
            htmlBody = htmlBody.replace(string.valueOf('{Party_First_Name}'),conEmail.FirstName);
            mail.setHtmlBody(htmlBody);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
            singleMailList.add(mail);
        } 
        Messaging.sendEmail(singleMailList);
        return 'success';
    }
 /**
* @description gets a String
* @param recordId 
* @param customEmail 
* @param adhoc 
* @param bank 
* @return string 
*/
    @AuraEnabled(cacheable = true)
    public static string sendSpecificStandardCustomEmail(Id recordId ,List<string> customEmail,string adhoc,string bank){
        List<EmailTemplate> emailTemplate;
        Account acc= new SEL_Accounts().selectByAccountId(recordId);
        Id fromEmail = new SEL_OrgWideEmailAddress().selectByDisplayName(ZAF_CTRL_ClientPricingLetterConstants.ZAFIN_PRICING_AND_BILLING).Id;
        List<contact> conList = new List<contact>();
        List<Messaging.SingleEmailMessage> singleMailList = new List<Messaging.SingleEmailMessage>();
        for(string checkedEmails:customEmail){
            contact con = new SEL_Contacts().selectContactByEmail(recordId,checkedEmails);
            if(string.valueOf(con) != ''){
                conList.add(con);
            }
        }
        if(!string.isEmpty(bank)){
            if(bank ==ZAF_CTRL_ClientPricingLetterConstants.ZAFIN_CORPORATE){
                emailTemplate = new SEL_EmailTemplate().selectByName(ZAF_CTRL_ClientPricingLetterConstants.ZAFIN_CORPORATE_LETTER);
            }else{
                emailTemplate = new SEL_EmailTemplate().selectByName(ZAF_CTRL_ClientPricingLetterConstants.ZAF_BANK_SECTOR);
            }       
        }else{
            emailTemplate = new SEL_EmailTemplate().selectByName(ZAF_CTRL_ClientPricingLetterConstants.ZAFIN_MONTHLY_ENVIRONMENT_LETTER);
        }
        PageReference pdf = Page.ZAF_FullStandardPricingLetterVFPage;
        pdf.getParameters().put('Id',recordId);
        Boolean hasRequiredPermissionSet = [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSet.Name = 'CIB_TxB_SA_Pricing_Capturer' AND AssigneeId = :UserInfo.getUserId()] > 0;
        for(contact conEmail:conList){
            pdf.getParameters().put('email',conEmail.Email);
            Blob body;                
            try{
                body = pdf.getContent();
            }catch(VisualforceException e){
                LOGGER.error('Any error message'+e);
                body=Blob.valueOf('error');
            }   
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.setContentType('application/pdf');
            attach.setFileName(acc.CIF__c+' - '+ acc.Name + '.pdf');
            attach.setInline(false);
            attach.Body = body;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateID(emailTemplate[0].Id);
            mail.setOrgWideEmailAddressId(fromEmail);  
            mail.setUseSignature(false);
            mail.setToAddresses(new String[] { conEmail.Email });
            mail.setSubject(ZAF_CTRL_ClientPricingLetterConstants.ZAFIN_2023_ANNUAL_PRICE_REVIEW+acc.Name);
            if (hasRequiredPermissionSet) {
                mail.setCcAddresses(new List<String>{UserInfo.getUserEmail()});
            } 
            String htmlBody = emailTemplate[0].HtmlValue;
            htmlBody = htmlBody.replace(string.valueOf('{Party_First_Name}'),conEmail.FirstName);
            mail.setHtmlBody(htmlBody);
            mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
            singleMailList.add(mail);
        } 
        Messaging.sendEmail(singleMailList);
        return 'success';
    }
}