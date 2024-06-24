/*************************************************************************\
@ Author        :     Raja Kumar
@ Date          :     23rd Sept 2022
@ Description   :     SFP-12913 : Create New Case using custom email handler

This test class covers following classes for custom inbound email handler.
*CustomInboundEmailHandlerHelper
****************************************************************************
@ Author        :     Raja Kumar
@ Date          :     23rd March 2023
@ Change 		:	  Updated to handle bounced email issue and feild limit issue for description feild on case
****************************************************************************/
@isTest(SeeAllData=false)
public class CustomInboundEmailHandlerHelperTest {
    
    //test create case for existing contact
    @isTest static void testWithExistingContact(){
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        CustomInboundEmailHandlerHelper CustomInboundEmailHandlerHelperObj=new CustomInboundEmailHandlerHelper();
        
        User testUser1 = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        uow.commitWork();
        
        System.runAs(testUser1) {
            BLD_Account accBld = new BLD_Account(uow).useChild()
                .name(DMN_Account.STANDARD_BANK_EMPLOYEES);
            BLD_Contact conBld = new BLD_Contact(uow).useBankContact()
                .email('testEmail@test.com')
                .account(accBld);
            uow.commitWork();
            
            //insert Entitlemnt for default case
            Entitlement entRec=new Entitlement(name='FR240mins : Mon - Fri (8h00 - 17h00)',accountid=accBld.getRecordId());
            insert entRec;
            
            Case caseRec = new Case(Origin='client email', Subject='Auto Response test');
            insert caseRec;
            EmailMessage emailMessagerec=new EmailMessage(parentid=caseRec.id,subject='Test',ThreadIdentifier='<Test1>');
            insert emailMessagerec;
            //insert FOlder for email template
            Folder testFolder=[select id from Folder where name ='all' limit 1];
            //insert EmailTemplate
            EmailTemplate testEmailTemplate = new EmailTemplate (developerName = 'TestAutoResPonse', FolderId=testFolder.id, TemplateType= 'Text', Name = 'test',isActive=true);
            insert testEmailTemplate;
            
            //insert Queue to assign
            Group testGroup = new Group(Name='testAssignedQueue', type='Queue');
            insert testGroup;
            
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SobjectType = 'Case');
            insert testQueue;
            
            //initialize email 
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            email.toAddresses=new String[]{'testToAddress@test.com'};
            email.messageid='<Test1>';
            email.references=null;
            email.subject = 'Create Case';
            email.fromAddress = 'testEmail@test.com';
            email.fromName = 'Test Name';
            email.plainTextBody = 'email body';
            email.htmlBody='<p>email body TestBlock</p>';
            CustomInboundEmailHandlerHelperObj.setInboundEmail(email);
            
            //initilize email message Rec
            email_action__c emailActionRec=new email_action__c();
            emailActionRec.Name='Test Email Action';
            emailActionRec.Exchange_Mailbox__c='testToAddress@test.com';
            emailActionRec.Auto_Response_Email_Template_Name__c='TestAutoResPonse';
            emailActionRec.Case_Record_Type__c='Cross Border CoE Record Type';
            emailActionRec.Case_Priority__c='High';
            emailActionRec.Assigned_to_Queue__c='testAssignedQueue';
            emailActionRec.Action__c='Standard';
            emailActionRec.Sequence__c=0;
            insert emailActionRec;
            CustomInboundEmailHandlerHelperObj.setEmailActionRec(emailActionRec);
            String caseid=CustomInboundEmailHandlerHelperObj.createCaseRecord();
            
            //check ThreadIdExists function
            boolean result1=CustomInboundEmailHandlerHelperObj.ThreadIdExists('<Test2>');
            caseRec.status='spam';
            update caseRec;
            boolean result2=CustomInboundEmailHandlerHelperObj.ThreadIdExists('<Test1>');
            String parentID=CustomInboundEmailHandlerHelperObj.getParetentCaseId();
            
            //set contact to bounced.
            Contact con=[select id,name,EmailBouncedDate,EmailBouncedReason,isEmailBounced from contact where id= :conBld.getRecordId() limit 1];
            con.EmailBouncedDate=date.newInstance(2023, 09, 23);
            con.EmailBouncedReason='Email is set to bounced';
            update con;
            String caseid4=CustomInboundEmailHandlerHelperObj.createCaseRecord();
            Assert.areEqual(caseid!=null,true);
			Assert.areEqual(result2,true);
        }
        
        
    }
    
    //test create case for non-isting contact
    @isTest static void testWithNonExistingContact(){
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        CustomInboundEmailHandlerHelper CustomInboundEmailHandlerHelperObj=new CustomInboundEmailHandlerHelper();
        
        User testUser1 = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        uow.commitWork();
        
        System.runAs(testUser1) {
            BLD_Account accBld = new BLD_Account(uow).useChild()
                .name(DMN_Account.STANDARD_BANK_EMPLOYEES);
            BLD_Contact conBld = new BLD_Contact(uow).useBankContact()
                .email('testEmail2@test.com')
                .account(accBld);
            uow.commitWork();
            
            //insert Entitlemnt for default case
            Entitlement entRec=new Entitlement(name='FR240mins : Mon - Fri (8h00 - 17h00)',accountid=accBld.getRecordId());
            insert entRec;
            
            //insert FOlder for email template
            Folder testFolder=[select id from Folder where name ='all' limit 1];
            //insert EmailTemplate
            EmailTemplate testEmailTemplate = new EmailTemplate (developerName = 'TestAutoResPonse', FolderId=testFolder.id, TemplateType= 'Text', Name = 'test',subject='{!Case.Subject} : {!Case.CaseNumber}',HtmlValue='<p>html Value {!Case.Contact} {!Case.CaseNumber} </p>',Body='plain Value {!Case.Contact} {!Case.CaseNumber}',isActive=true);
            insert testEmailTemplate;
            
            //initialize email 
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            email.toAddresses=new String[]{'testToAddress@test.com'};
                email.messageid='<Test1>';
            email.references=null;
            email.subject = 'Create Case';
            email.fromAddress = 'testEmail@test.com';
            email.fromName = 'Test Name';
            email.plainTextBody = 'email body';
            email.htmlBody='<p>email body TestBlock</p>';
            CustomInboundEmailHandlerHelperObj.setInboundEmail(email);
            
            //initilize email message Rec
            email_action__c emailActionRec=new email_action__c();
            emailActionRec.Name='Test Email Action';
            emailActionRec.Exchange_Mailbox__c='testToAddress@test.com';
            emailActionRec.Auto_Response_Email_Template_Name__c='TestAutoResPonse';
            emailActionRec.Case_Record_Type__c='Cross Border CoE Record Type';
            emailActionRec.Case_Priority__c='High';
            emailActionRec.Assigned_to_Queue__c='testAssignedQueue';
            emailActionRec.Action__c='Standard';
            emailActionRec.Sequence__c=0;
            insert emailActionRec;
            CustomInboundEmailHandlerHelperObj.setEmailActionRec(emailActionRec);
            String caseid=CustomInboundEmailHandlerHelperObj.createCaseRecord();
            //check for spam case
            CustomInboundEmailHandlerHelperObj.spamCase=true;
            String caseid2=CustomInboundEmailHandlerHelperObj.createCaseRecord();            
            //check for fake contact email
            email.fromAddress='testEmail@test.com.fake.fake';
            CustomInboundEmailHandlerHelperObj.setInboundEmail(email);
            String caseid3=CustomInboundEmailHandlerHelperObj.createCaseRecord();
            Assert.areEqual(caseid2!=null,true);
            Assert.areEqual(caseid3==null,true);
            Assert.areEqual(caseid!=null,true);
            
        }
        
        
    }
    
    
    //test create email Message rec with references = null
    @isTest static void testCreateEmailMessageRecord(){
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        CustomInboundEmailHandlerHelper CustomInboundEmailHandlerHelperObj=new CustomInboundEmailHandlerHelper();
        
        User testUser1 = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        uow.commitWork();
        
        System.runAs(testUser1) {
            BLD_Account accBld = new BLD_Account(uow).useChild()
                .name(DMN_Account.STANDARD_BANK_EMPLOYEES);
            BLD_Contact conBld = new BLD_Contact(uow).useBankContact()
                .email('testEmail2@test.com')
                .account(accBld);
            BLD_Case caseBld = new BLD_Case(uow).useUserCase()
                .account(accBld)
                .contact(conBld);
            uow.commitWork();
            
            //Text Attachment
            Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
            attachmenttext.body = 'my attachment text';
            attachmenttext.fileName = 'textfiletwo.txt';
            attachmenttext.mimeTypeSubType = 'texttwo/plain';
            
            // Binary Attachment
            Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
            attachment.body = blob.valueOf('my attachment binary');
            attachment.fileName = 'textfileone.txt';
            attachment.mimeTypeSubType = 'text/plain';
            
            //initialize email with references 
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            email.toAddresses=new String[]{'testToAddress@test.com'};
                email.ccAddresses=new String[]{'testccAddress@test.com'};
                    email.messageid='<Test56>';
            email.references=new String[]{'Test1','Test56'};
                email.subject = 'Create Case';
            email.fromAddress = 'testEmail@test.com';
            email.fromName = 'Test Name';
            email.plainTextBody = 'email body';
            email.htmlBody='<p>email body TestBlock</p>';
            email.textAttachments = new Messaging.inboundEmail.TextAttachment[] {attachmenttext};
                email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {attachment};
                    CustomInboundEmailHandlerHelperObj.setInboundEmail(email);
            String emailMessageId=CustomInboundEmailHandlerHelperObj.createEmailMessageRecord(caseBld.getRecordId());
            system.Assert(emailMessageId!=null,true);
            
            
            //initialize email without references 
            Messaging.InboundEmail email2 = new Messaging.InboundEmail() ;
            email2.toAddresses=new String[]{'testToAddress@test.com'};
                email2.ccAddresses=new String[]{'testccAddress@test.com'};
                    email2.messageid='<Test56>';
            email2.references=null;
            email2.subject = 'Create Case';
            email2.fromAddress = 'testEmail@test.com';
            email2.fromName = 'Test Name';
            email2.plainTextBody = 'email body';
            email2.htmlBody='<p>email body TestBlock</p>';
            email2.textAttachments = new Messaging.inboundEmail.TextAttachment[] {attachmenttext};
                email2.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {attachment};
                    CustomInboundEmailHandlerHelperObj.setInboundEmail(email2);
            String emailMessageId2=CustomInboundEmailHandlerHelperObj.createEmailMessageRecord(caseBld.getRecordId());
            Assert.areEqual(emailMessageId2!=null,true);
            
        }
        
        
    }
    
    
}