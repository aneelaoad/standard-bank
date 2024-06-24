/*************************************************************************\
@ Author        :     Raja Kumar
@ Date          :     23rd Sept 2022
@ Test File     :     CustomInboundEmailHandlerHelperTest
@ Description   :     SFP-12913 : Create New Case using custom email handler
creating this custom inbound email handler to replicate standard Email-to-case functionality and 
to add features not catered by standard email-to-case such as creating a new when when a mail is 
received for a closed case and creating case with spam status for recall emails.
****************************************************************************
@ Author        :     Raja Kumar
@ Date          :     23rd March 2023
@ Change 		:	  Updated to handle bounced email issue and feild limit issue for description feild on case
Updated the code to use selector classes when required.

Last Updated 	:    11 Oct 2023
Change 			:	 Changed "newEmailMessageRec.TextBody=inboundEmail.plainTextBody;" to "newEmailMessageRec.TextBody=inboundEmail.plainTextBody.left(Schema.SObjectType.EmailMessage.fields.TextBody.getLength());"  
****************************************************************************/
public class CustomInboundEmailHandlerHelper {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CustomInboundEmailHandlerHelper');
    
    //Feilds needed for case creation 
    Messaging.InboundEmail inboundEmail=new Messaging.InboundEmail();
    Email_Action__c EmailActionRec=new Email_Action__c();
    public Boolean spamCase=false;
    String parentCaseId='';
    public boolean isClosedCase=false;
    
    //set email object for this class
    public void setInboundEmail(Messaging.InboundEmail email){
        this.inboundEmail=email;
    }
    
    //set email action record for this class
    public void setEmailActionRec(Email_Action__c EmailActionRec){
        this.EmailActionRec=EmailActionRec;
    }
    
    //set parent case id 
    void setParentCaseId(String id){
        this.parentCaseId=id;
    }
    
    // return parent case id 
    public string getParetentCaseId(){
        return this.parentCaseId;
    }
    
    //check Thread ID for inbound email 
    public boolean ThreadIdExists(String threadID){
        list<EmailMessage> emailMessgaeObj=new list<EmailMessage>();
        isClosedCase=false;
        emailMessgaeObj = SEL_EmailMessages.newInstance().selectByThreadIdentifier(new set<string>{threadID});
        If(emailMessgaeObj.size()!=0){
            setParentCaseId(emailMessgaeObj[0].ParentId);
            
            if(emailMessgaeObj[0].Parent.Status=='closed'||emailMessgaeObj[0].Parent.Status=='spam'||emailMessgaeObj[0].Parent.Status=='Duplicate') {
                isClosedCase=true;
            }return true;
        }return false;
    }
    
    //create email message object and handle attachments
    public string createEmailMessageRecord(String caseId){
        EmailMessage newEmailMessageRec=new EmailMessage();
        try{
            String toAddressList='';
            If(inboundEmail.toAddresses!=null){
                for(String toAddress:inboundEmail.toAddresses){
                    toAddressList=toAddressList+','+toAddress;
                }
            }
            String ccAddressList='';
            if(inboundEmail.ccAddresses!=null){
                for(String ccAddress:inboundEmail.ccAddresses){
                    ccAddressList=ccAddressList+','+ccAddress;
                }
            }
            newEmailMessageRec.ParentId=caseId;
            newEmailMessageRec.Subject=inboundEmail.subject;
            newEmailMessageRec.FromAddress=inboundEmail.fromAddress;
            newEmailMessageRec.FromName=inboundEmail.fromName;
            newEmailMessageRec.ToAddress=toAddressList;
            newEmailMessageRec.CcAddress=ccAddressList;
            newEmailMessageRec.TextBody=inboundEmail.plainTextBody.left(Schema.SObjectType.EmailMessage.fields.TextBody.getLength());
            newEmailMessageRec.HtmlBody=inboundEmail.htmlBody.left(Schema.SObjectType.EmailMessage.fields.HtmlBody.getLength());
            newEmailMessageRec.Incoming=true;
            newEmailMessageRec.MessageIdentifier=inboundEmail.messageid;
            if(inboundEmail.references==null){
                newEmailMessageRec.ThreadIdentifier=inboundEmail.messageid;
            }else{
                newEmailMessageRec.ThreadIdentifier=inboundEmail.references[0];
            }
            insert newEmailMessageRec;
            // add attachments to EmailMessage
            LOGGER.debug( 'Adding attachments' );
            Map<String, Attachment> attachmentsMap = buildAttachments( inboundEmail, newEmailMessageRec.id );
            if ( attachmentsMap.size() > 0 ) {
                insert attachmentsMap.values();
            }
            // Parse email body and replace references to "cid" content ids
            // with attachment file urls so render when email message viewed in salesforce.
            String attachmentDownloadURL = '/servlet/servlet.FileDownload?file=';
            for ( String contentId : attachmentsMap.keySet() ) {
                String cid = contentId.replace( '<', '' ).replace( '>', '' );
                String url = attachmentDownloadURL + String.valueOf( attachmentsMap.get( contentId ).id ).left( 15 );
                newEmailMessageRec.textBody = newEmailMessageRec.textBody.replaceAll( 'cid:' + cid, url );
                newEmailMessageRec.htmlBody = newEmailMessageRec.htmlBody.replaceAll( 'cid:' + cid, url );
            }
            update newEmailMessageRec;//so that it loads image in the feed
            return newEmailMessageRec.id;
        }
        catch (Exception e) {
            LOGGER.error('Exception logged while inserting emailMessage record: ',e);
        }
        return null;
    }
    //get contact id and account id
    Contact getContactId(string contactEmail){
        list<contact> caseContact=SEL_Contacts.newInstance().selectByEmail(new set<string>{contactEmail});
        if(caseContact.size()!=0){
            return caseContact[0];
        }else{
            return null;
        }
    }
    //get org wide email address id 
    string getOrgWideEmailId(String orgWideEmail) {
        list<OrgWideEmailAddress> orgEmail=SEL_OrgWideEmailAddress.newInstance().selectByAddress(orgWideEmail);
        if(orgEmail.size()!=0){
            return orgEmail[0].Id;
        }else{
            return null;
        }
    }
    //get case record type id
    string getCaseRecordType(String recordTypeName){
        String devName=recordTypeName.replace(' ','_');
        String caseRecordTypeID=UTL_RecordType.getRecordTypeId('Case',devName);
        if(caseRecordTypeID!=null){
            return caseRecordTypeID;
        }else{
            return null;
        }
    }
    //get auto response email template id
    EmailTemplate getEmailTemplateId(String emailTemplateDeveloperName){
        List<EmailTemplate> emailTemplateRec=SEL_EmailTemplate.newInstance().selectByDeveloperName(emailTemplateDeveloperName);
        if(emailTemplateRec.size()!=0){
            return emailTemplateRec[0];
        }else{
            return null;
        }
    }
    //get getCaseOwnerQueue 
    string getCaseOwnerQueue(String caseOwnerQueueName){
        //Group queueToAssign=[SELECT Id from Group WHERE Type = 'Queue' AND DeveloperName = :caseOwnerQueueName];
        List<group> queueToAssign=SEL_Group.newInstance().selectByTypeAndDeveloperName('Queue',caseOwnerQueueName);
        if(queueToAssign.size()!=0){
            return queueToAssign[0].Id;
        }else{
            return UserInfo.getUserId();
        }
    }
    //send Auto response email
    void sendAutoResponse(Case newCaseRec,String caseContactID){
        List<case> newCreatedCase = SEL_Cases.newInstance().selectByCaseId(newCaseRec.id);
        Messaging.SingleEmailMessage sendEmail = new Messaging.SingleEmailMessage();
        String[] toAddreddOfAutoResponse=new list<String>();
        toAddreddOfAutoResponse.add(inboundEmail.fromAddress);
        EmailTemplate  EmailTemplateRec=getEmailTemplateId(EmailActionRec.Auto_Response_Email_Template_Name__c);   
        String orgWideEmailId=getOrgWideEmailId(newCreatedCase[0].Email_Address__c);
        if(orgWideEmailId!=null){
            sendEmail.setOrgWideEmailAddressId(orgWideEmailId);   
        }
        //check if contact exists or not
        if(caseContactID!=null){
            sendEmail.setTemplateId(EmailTemplateRec.id);
            sendEmail.setTargetObjectId(caseContactID);
        }else{
            //this code will not execute for existing contacts in Salesforce
            //if contact do not exists send the auto response by copying from system
            //case is retrived to get case number for mergr feilds for auto responsed sent to non-existing salesforce contacts
            
            String subject = EmailTemplateRec.Subject;
            subject = subject.replace('{!Case.Subject}',newCreatedCase[0].Subject);
            subject = subject.replace('{!Case.CaseNumber}',newCreatedCase[0].CaseNumber);
            String htmlBody = EmailTemplateRec.HtmlValue;
            htmlBody = htmlBody.replace('{!Case.Contact}',inboundEmail.fromName);
            htmlBody = htmlBody.replace('{!Case.CaseNumber}',newCreatedCase[0].CaseNumber);
            htmlBody = htmlBody.replace('{!Case.Subject}',newCreatedCase[0].Subject);
            htmlBody = htmlBody.replace('{!Case.CreatedDate}',string.valueof(newCreatedCase[0].createddate.date()));
            String plainBody = EmailTemplateRec.Body;
            plainBody = plainBody.replace('{!Case.Contact}',inboundEmail.fromName);
            plainBody = plainBody.replace('{!Case.CaseNumber}',newCreatedCase[0].CaseNumber);
            plainBody = plainBody.replace('{!Case.Subject}',newCreatedCase[0].Subject);
            plainBody = plainBody.replace('{!Case.CreatedDate}',string.valueof(newCreatedCase[0].createddate.date()));
            sendEmail.setSubject(subject);
            sendEmail.setHtmlBody(htmlBody);
            sendEmail.setPlainTextBody(plainBody);
            sendEmail.setToAddresses(toAddreddOfAutoResponse);
        }
        sendEmail.setWhatId(newCaseRec.id);
        for (Messaging.SendEmailResult result :Messaging.sendEmail(new Messaging.SingleEmailMessage[] {sendEmail})){
            if (result.isSuccess()) {
                LOGGER.debug('Auto response sent');
            }  
        }
    }
    //create a new case
    public String createCaseRecord(){
        Case newCaseRec=new Case();
        try{
            if(spamCase ||(inboundEmail.subject.startsWithIgnoreCase('Automatic reply:')) ){
                newCaseRec.Status='spam';
            }
            newCaseRec.Subject=inboundEmail.subject.left(Schema.SObjectType.Case.fields.Subject.getLength());
            Contact caseContact=getContactId(inboundEmail.fromAddress);
            if(caseContact!=null){
                newCaseRec.ContactId=caseContact.id;
                newCaseRec.AccountId=caseContact.accountId;
            }
            newCaseRec.Description=inboundEmail.plainTextBody.left(Schema.SObjectType.Case.fields.Description.getLength());
            newCaseRec.Origin='Client email';
            newCaseRec.SuppliedEmail=inboundEmail.fromAddress;
            newCaseRec.SuppliedName=inboundEmail.fromName;
            newCaseRec.RecordTypeId=getCaseRecordType(EmailActionRec.Case_Record_Type__c);
            newCaseRec.OwnerId=getCaseOwnerQueue(EmailActionRec.Assigned_to_Queue__c);
            insert newCaseRec;
            if(newCaseRec.Status!='spam'){
                if(caseContact!=null){
                    sendAutoResponse(newCaseRec,String.valueOf(caseContact.id));// send auto response for existing contact
                }else{
                    sendAutoResponse(newCaseRec,null);// send auto response for non-existing contact in salesforce
                }
            }
            return newCaseRec.id;//return newly created  case id
        }catch(Exception e){
            if(newCaseRec.id!=null){
                return newCaseRec.id;
            }else{
                LOGGER.error('Exception logged while inserting case record: ',e);
                return null;
            }
        }
    }
    //getHeader value funstion
    private String getHeaderValue( List<Messaging.InboundEmail.Header> headers, String name ) {
        String value = null;
        if ( headers != null ) {
            for ( Messaging.InboundEmail.Header header : headers ) {
                if ( header.name == name ) {
                    value = header.value;
                    break;
                }
            }
        }
        return value;
    }
    //handle attachments
    public Map<String, Attachment> buildAttachments( Messaging.InboundEmail email, String parentId ) {
        Map<String, Attachment> attachmentsMap = new Map<String, Attachment>();
        // if attachment does not have Content-ID header
        // then we'll use this to generate a unique map key instead
        Integer noHeaderCount = 0;
        if ( email.binaryAttachments != null ) {
            for ( Messaging.InboundEmail.BinaryAttachment binaryAttachment : email.binaryAttachments ) {
                String contentId = getHeaderValue( binaryAttachment.headers, 'Content-ID' );
                if ( String.isBlank( contentId ) ) {
                    contentId = 'no-content-id-header-' + noHeaderCount++;
                }
                attachmentsMap.put( contentId, new Attachment(
                    name = binaryAttachment.fileName,
                    body = binaryAttachment.body,
                    contentType = binaryAttachment.mimeTypeSubType,
                    parentId = parentId
                ));
            }
        }
        if ( email.textAttachments != null ) {
            for ( Messaging.InboundEmail.TextAttachment textAttachment : email.textAttachments ) {
                String contentId = getHeaderValue( textAttachment.headers, 'Content-ID' );
                if ( String.isBlank( contentId ) ) {
                    contentId = 'no-content-id-header-' + noHeaderCount++;
                }
                attachmentsMap.put( contentId, new Attachment(
                    name = textAttachment.fileName,
                    body = Blob.valueOf( textAttachment.body ),
                    contentType = textAttachment.mimeTypeSubType,
                    parentId = parentId
                ));
            }
        }
        return attachmentsMap;
    }
}