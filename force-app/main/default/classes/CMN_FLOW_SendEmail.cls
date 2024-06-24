/**
 * @description An class with an invokable method that will allow sending an email from a Flow where its required that the email is logged as an activity
 * otherwise we would just use an email alert
 *
 * @author Accenture
 *
 * @date March 2021
 */
public inherited sharing class CMN_FLOW_SendEmail
{
    /**
     * @description Sends out an email based on the variables received and saves as an Activity in feed
     *
     * @param dtoEmails A list of variables to be used to craft emails
     *
     * @return A list indicating if the send email was successful and if not what the error was
     */
    @InvocableMethod(Label='Send Email and Log an Activity' Description='Will use the SingleEmailMessage class to send an email with a template and ensure activity is logged')
    public static List<DTO_SendEmailResponse> sendEmail(List<DTO_SendEmailRequest> dtoEmails)
    {
        Set<String> templateNames = new Set<String>();
        Set<String> orgWideEmailAddresses = new Set<String>();

        //Collate all the template names and Org wide emails as we need to query their Ids
        for(DTO_SendEmailRequest dtoEmail : dtoEmails)
        {
            templateNames.add(dtoEmail.templateUniqueName);
            orgWideEmailAddresses.add(dtoEmail.orgWideEmailAddress);
        }

        //Retrieve all the Ids for the template names and org Wide email address, make available in maps for easy query
        List<EmailTemplate> emailTemplates = CMN_DAL_EmailTemplate.findByName(templateNames);
        List<OrgWideEmailAddress> orgWideAddresses = CMN_DAL_OrgWideEmailAddress.findByName(orgWideEmailAddresses);
        Map<String, SObject> templateMap = CMN_UTIL_System.convertListToSingleStringMap(emailTemplates, CMN_DAL_EmailTemplate.FIELD_DEVELOPER_NAME);
        Map<String, SObject> orgWideEmailMap = CMN_UTIL_System.convertListToSingleStringMap(orgWideAddresses, CMN_DAL_OrgWideEmailAddress.FIELD_ADDRESS);

        List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();

        for(DTO_SendEmailRequest dtoEmail : dtoEmails)
        {   
            Messaging.SingleEmailMessage newMail = Messaging.renderStoredEmailTemplate(templateMap.get(dtoEmail.templateUniqueName)?.Id, null, dtoEmail.whatId, Messaging.AttachmentRetrievalOption.METADATA_ONLY);
            newMail.setToAddresses(new List<String> {dtoEmail.toAddress});
            newMail.setCcAddresses(dtoEmail.ccAddress);
            newMail.setOrgWideEmailAddressId(orgWideEmailMap.get(dtoEmail.orgWideEmailAddress)?.Id);
            newMail.setSaveAsActivity(true);

            if(dtoEmail.fileIds != null)
            {
                newMail.setEntityAttachments(dtoEmail.fileIds);
            }

            mailsToSend.add(newMail);
        }

        List<Messaging.SendEmailResult> sendEmailResults = Messaging.sendEmail(mailsToSend, false);

        List<DTO_SendEmailResponse> dtoResponses = new List<DTO_SendEmailResponse>();

        //In the event errors did occur for some emails, ensure these are logged for debugging purposes
        for(Messaging.SendEmailResult sendEmailResult : sendEmailResults)
        {
            DTO_SendEmailResponse dtoResponse = new DTO_SendEmailResponse();
            dtoResponse.success = sendEmailResult.success;

            if(!sendEmailResult.success)
            {
                String errors = CMN_UTIL_String.EMPTY;

                for(Messaging.SendEmailError sendEmailError : sendEmailResult.errors)
                {
                    errors = String.isBlank(errors) ? errors + sendEmailError.message : errors + CMN_UTIL_String.LF + sendEmailError.message;
                    dtoResponse.errors = errors;

                    CMN_UTIL_Logger.error(sendEmailError.message, 'CMN_FLOW_SendEmail/sendEmail');
                }
            }

            dtoResponses.add(dtoResponse);
        }

        return dtoResponses;

    }

    /**
     * @description DTO to initiate a send email request
     */
    public class DTO_SendEmailRequest
    {
        /**
         * @description A list of email addresses or object IDs of the contacts, leads, and users you’re sending the email to.  The maximum size for this field is 4,000 bytes. The maximum total of toAddresses, ccAddresses, and bccAddresses per email is 150.
         * All recipients in these three fields count against the limit for email sent using Apex or the API.
         */
        @InvocableVariable(Label='To Address' Description='The ID of the contact, lead, or user to which the email will be sent. The ID you specify sets the context and ensures that merge fields in the template contain the correct data. If no ID is available send the email address of the recipient' Required=false)
        public String toAddress;

        @InvocableVariable(Label='CC Address' Description='The ID of the contact, lead, or user to which the email will be sent in cc.' Required=false)
        public List<String> ccAddress;

        @InvocableVariable(Label='Template Unique Name' Description='The unique name of the template that will be used to generate the email' Required=true)
        public String templateUniqueName;

        @InvocableVariable(Label='Org Wide Email Address' Description='Will define the org wide email address to use as the from for the email' Required=true)
        public String orgWideEmailAddress;

        /**
         * @description if you specify a contact for the targetObjectId field, you can specify an optional whatId as well. This helps to further ensure that merge fields in the template contain the correct data.
         * <p/>
         * The value must be one of the following types:
         * Account
         * Asset
         * Campaign
         * Case
         * Contract
         * Opportunity
         * Order
         * Product
         * Solution
         * Custom
         */
        @InvocableVariable(Label='Related To ID' Description='An Object Id that can be related the email' Required=true)
        public Id whatId;

        @InvocableVariable(Label='List of Attachment Identifiers' Description='List of Attachment Identifiers to add Files as attachments to the email' Required=false)
        public List<Id> fileIds;
    }

    public class DTO_SendEmailResponse
    {
        @InvocableVariable(Label='Send Successful' Description='Indicates whether the email was successfully submitted for delivery (true) or not (false). Even if isSuccess is true, it does not mean the intended recipients received the email, as there could have been a problem with the email address or it could have bounced or been blocked by a spam blocker.' Required=true)
        public Boolean success;
        @InvocableVariable(Label='Errors' Description='A List of errors encountered when attempting to do the send email' Required=false)
        public String errors;
    }
}