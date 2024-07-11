/***************************************************************************************
* @Name of the Class     :ZAF_CTRL_SendClientPricingLetter
* @description          : Class for sending an email to the client related contact with Client Pricing Letter PDF attachment
* @Author                :Pradeep Kota  
* @Created Date          : 07 Mar 2024
/***************************************************************************************
*@Last Modified By  : Pradeep Kota  
*@Last Modified On  : 11 Mar 2024
*@Modification Description : SFP-30098
***************************************************************************************/
public class ZAF_CTRL_SendClientPricingLetter {
	private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('ZAF_CTRL_SendClientPricingLetter');
    /**
    * @description gets a String
    * @param recordId - Id
    * @return string 
    */
    @AuraEnabled(cacheable = true)
    public static List<contact> sendEmailToController(Id recordId){
        try{
        List<zafin_rrp__Negotiated_Pricing__c> pricingAccount = new SEL_ZafinNegotiatedPricing().selectZafinNegotiationPricingByRecordId(recordId);
        Id clientAccount =   pricingAccount[0].zafin_rrp__Reporting_Customer__c;
        return new SEL_Contacts().selectContactByContactRole(clientAccount);
        }catch(Exception e){
          LOGGER.error('Any error message'+e);
         return null;
        }   
    }
    /**
    * @description gets a String
    * @param recordId - Id
    * @param customEmail - EmailId from LWC component and sending an email
    * @return string 
    */
    @AuraEnabled(cacheable = true)
    public static string sendCustomEmail(Id recordId ,List<string> customEmail){
    Id fromEmail = new SEL_OrgWideEmailAddress().selectByDisplayName(ZAF_CTRL_ClientPricingLetterConstants.ZAFIN_PRICING_AND_BILLING).Id;
        zafin_rrp__Negotiated_Pricing__c pricingArrangement = new SEL_ZafinNegotiatedPricing().selectZafinNegotiationByRecordId(recordId) ; 
        String clientName=pricingArrangement.zafin_rrp__Reporting_Customer__r.Name;
        String cifNumber= pricingArrangement.zafin_rrp__Reporting_Customer__r.CIF__c;
        Id clientID =pricingArrangement.zafin_rrp__Reporting_Customer__c;
         List<contact> conList = new List<contact>();
         List<Messaging.SingleEmailMessage> singleMailList = new List<Messaging.SingleEmailMessage>();
        for(string checkedEmails:customEmail){
        contact selectedContact = new SEL_Contacts().selectContactByEmail(clientID,checkedEmails);
            if(string.valueOf(selectedContact) != ''){
                conList.add(selectedContact);
            }
        }
        List<EmailTemplate> emailTemplate = new SEL_EmailTemplate().selectByName(ZAF_CTRL_ClientPricingLetterConstants.ZAFIN_MONTHLY_ENVIRONMENT_LETTER);
       PageReference pdf = Page.ZAF_GeneratePricingLetterVFPage;
        pdf.getParameters().put('Id',recordId);
        Boolean hasRequiredPermissionSet = [SELECT COUNT() FROM PermissionSetAssignment WHERE PermissionSet.Name = 'CIB_TxB_SA_Pricing_Capturer' AND AssigneeId = :UserInfo.getUserId()] > 0;
        for(contact conEmail:conList){
        Blob pdfBlob;                
        pdf.getParameters().put('email',conEmail.Email);
        try{
            pdfBlob = pdf.getContent();
        }catch(VisualforceException e){
            LOGGER.error('Any error message'+e);
            pdfBlob=Blob.valueOf('Some text');
        }   
           
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        attach.setContentType('application/pdf');
        attach.setFileName(CIFNumber+' - '+ clientName + '.pdf');
        attach.setInline(false);
        attach.Body = pdfBlob;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateID(emailTemplate[0].Id);
        mail.setOrgWideEmailAddressId(fromEmail);  
            mail.setTargetObjectId(conEmail.id);
       mail.setSaveAsActivity(false);
        mail.setUseSignature(false);
      //  mail.setToAddresses(new String[] { conEmail.Email });
        mail.setSubject(ZAF_CTRL_ClientPricingLetterConstants.ZAFIN_2023_ANNUAL_PRICE_REVIEW + clientName);
        if (hasRequiredPermissionSet) {
            mail.setCcAddresses(new List<String>{UserInfo.getUserEmail()});
        } 
        String htmlBody = emailTemplate[0].HtmlValue;
        htmlBody = htmlBody.replace(string.valueOf('{Party_First_Name}'),conEmail.FirstName);
        mail.setHtmlBody(htmlBody);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
        singleMailList.add(mail);
        } 
        Messaging.sendEmail(singleMailList,false);
         return 'success';
    }
}