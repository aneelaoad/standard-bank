/**
 * Generic class with invocable method (That is invoked form the Case Resolution Notification and Case Closure Notification process builders).
 * The invocable method uses variables received to send out an email and save as an activity in feed
 * <br/>SGPRT-1497
 *
 * @author Suveer Mohunlal (suveer.mohunlal@standardbank.co.za)
 * @date August 2020
 */
global class SendServiceCaseEmail {
    
    global class InvokeSendEmail {
        
        //Required for SPGRT-1175//
        
        @InvocableVariable(label='Related To ID' description='' required=false)
        global Id RelatedToId;      

        @InvocableVariable(label='Contact ID' description='Required if you use an email template' required=false)
        global Id ContactId;
        
        @InvocableVariable(label='Template Unique Name' description='API Name -- Contact required if you use this' required=false)
        global String EmailTemplateName;
        
        global Id EmailTemplateId;

        @InvocableVariable(label='From - Org Wide Email Address' description='' required=false)
        global String OrgWideEmailAddress;
    }
    
    /**
     * Sends out an email based on the variables received and saves as an Activity in feed 
     * 
     * @param requests variables that are passed through from the Process Builder
     */
    @InvocableMethod(label='Send Email')
    global static void sendEmail (List<InvokeSendEmail> requests) {
        
        Messaging.SingleEmailMessage[] mails = new List<Messaging.SingleEmailMessage>();
        Set<String> emailTemplateNames = new Set<String>();
        Set<String> contactIds = new Set<String>();
        Set<String> orgWideEmailAddresses = new Set<String>();
        Id fromAddressOrgWideId;
    
        
        for (InvokeSendEmail request : requests) {
            if (String.isNotBlank(request.EmailTemplateName)) {
                emailTemplateNames.add(request.EmailTemplateName);
            }
            if (String.isNotBlank(request.ContactId)) {
                contactIds.add(request.ContactId);
            }
            if (String.isNotBlank(request.OrgWideEmailAddress)) {
                orgWideEmailAddresses.add(request.OrgWideEmailAddress);
            }
        }
        
        Map<String, String> emailTemplateIdsByName = new Map<String, String>();
        
        if (!emailTemplateNames.isEmpty()) {

            for (EmailTemplate template : [SELECT Id, Name, DeveloperName From EmailTemplate WHERE (DeveloperName IN: emailTemplateNames OR Name IN: emailTemplateNames)]) {
                emailTemplateIdsByName.put(template.Name, template.Id);
                emailTemplateIdsByName.put(template.DeveloperName, template.Id);
            }
        }
        
        Map<String, String> contactOrLeadEmailsById = new Map<String, String>();
        
        if (!contactIds.isEmpty()) {

            for (Contact theContact : [SELECT Id, Email From Contact WHERE Id IN: contactIds]) {
                contactOrLeadEmailsById.put(theContact.Id, theContact.Email);
            }

        }
        
        if (!orgWideEmailAddresses.isEmpty()) {
            List<OrgWideEmailAddress> owea = [select Id from OrgWideEmailAddress where Address = :orgWideEmailAddresses LIMIT 1];
			if ( owea.size() > 0 ) {
    			fromAddressOrgWideId=(owea.get(0).Id);
			}
        
        }
        
        
        for (InvokeSendEmail request : requests) {

            try {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                request.EmailTemplateId = emailTemplateIdsByName.get(request.EmailTemplateName);
                mail.setTemplateId(request.EmailTemplateId);
                
                if (String.isNotBlank(request.RelatedToId)) mail.setWhatId(request.RelatedToId);
                
                mail.setTargetObjectId(request.ContactId);
                mail.SaveAsActivity = true;
                mail.setUseSignature(false); 
                mail.setOrgWideEmailAddressId(fromAddressOrgWideId);
                mails.add(mail);
                mails.add(new Messaging.SingleEmailMessage());
            }catch (Exception ex){
                SRV_Logger.newInstance().log(ex, DMN_Log.AREA_SERVICECLOUD, SendServiceCaseEmail.class.getName());
            }
        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(mails, false);       
    }    
}