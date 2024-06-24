/*************************************************************************\
@ Author        :     Raja Kumar
@ Date          :     23rd Sept 2022
@ Description   :     SFP-12913 : Create New Case using custom email handler

This test class covers following classes for custom inbound email handler.
*CustomEmailToCaseHandler
****************************************************************************/
@isTest(SeeAllData=false)
public class CustomEmailToCaseHandlerTest {
    @isTest static void testRuleEngine(){
        CustomEmailToCaseHandler customEmailToCaseHandlerObj=new CustomEmailToCaseHandler();
        Case caseRec = new Case(Origin='client email', Subject='Auto Response test');
            insert caseRec;
            EmailMessage emailMessagerec=new EmailMessage(parentid=caseRec.id,subject='Test',ThreadIdentifier='Test1');
            insert emailMessagerec;
        
        //insert email action records action standard
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
        
        //check recall email
        Messaging.InboundEmail email4 = new Messaging.InboundEmail() ;
        email4.ccAddresses=new String[]{'testToyAddress@test.com'};
        email4.toAddresses=new String[]{'testToAddress@test.com'};
        email4.messageid='Test56';
        email4.references=new String[]{'Test1','Test56'};
        email4.subject = 'recall: Create Case';
        email4.htmlBody='<p>email body</p>';
        email4.fromName = 'Test Name';
        email4.fromAddress = 'testEmail@test.com';
        email4.plainTextBody = 'email body';
        CustomEmailToCaseHandler customEmailToCaseHandlerObj1=new CustomEmailToCaseHandler();
        customEmailToCaseHandlerObj1.ruleEngine(email4,'testToAddress@test.com');
        
        //test standard action with null references
        Messaging.InboundEmail email5 = new Messaging.InboundEmail() ;
        email5.ccAddresses=new String[]{'testToyAddress@test.com'};
        email5.toAddresses=new String[]{'testToAddress@test.com'};
        email5.messageid='<Test4>';
        email5.references=null;
        email5.subject = 'Create Case';
        email5.htmlBody='<p>email body</p>';
        email5.fromName = 'Test Name';
        email5.fromAddress = 'testEmail@test.com';
        email5.plainTextBody = 'email body';
        customEmailToCaseHandlerObj.ruleEngine(email5,'testToAddress@test.com');
        
        //test standard action with references
        Messaging.InboundEmail email6 = new Messaging.InboundEmail() ;
        email6.ccAddresses=new String[]{'testToyAddress@test.com'};
        email6.toAddresses=new String[]{'testToAddress@test.com'};
        email6.messageid='<Test4>';
        email6.references=new String[]{'Test1','Test4'};
        email6.subject = 'Create Case';
        email6.htmlBody='<p>email body</p>';
        email6.fromName = 'Test Name';
        email6.fromAddress = 'testEmail@test.com';
        email6.plainTextBody = 'email body';
         CustomEmailToCaseHandler customEmailToCaseHandlerObj5=new CustomEmailToCaseHandler();
        customEmailToCaseHandlerObj5.ruleEngine(email6,'testToAddress@test.com');
        
        //insert email action records action block
        email_action__c emailActionRec3=new email_action__c();
        emailActionRec3.Name='Test Email Action';
        emailActionRec3.Exchange_Mailbox__c='testToAddress2@test.com';
        emailActionRec3.Auto_Response_Email_Template_Name__c='TestAutoResPonse';
        emailActionRec3.Case_Record_Type__c='Cross Border CoE Record Type';
        emailActionRec3.Case_Priority__c='High';
        emailActionRec3.Assigned_to_Queue__c='testAssignedQueue';
        emailActionRec3.Action__c='block';
        emailActionRec3.Sequence__c=0;
        insert emailActionRec3;
        
        //insert email matching for thie block action
       	Email_Matching_Rule__c emailMatchingRec=new Email_Matching_Rule__c();
        emailMatchingRec.Name='Test Email Matching Rule';
        emailMatchingRec.Field__c='subject';
        emailMatchingRec.operator__c='pattern Match';
        emailMatchingRec.Value__c='TestBlock';
        emailMatchingRec.Email_Action__c=emailActionRec3.id;
        insert emailMatchingRec;
        
        Email_Matching_Rule__c emailMatchingRec2=new Email_Matching_Rule__c();
        emailMatchingRec2.Name='Test Email Matching Rule';
        emailMatchingRec2.Field__c='To Address';
        emailMatchingRec2.operator__c='pattern Match';
        emailMatchingRec2.Value__c='testToAddress2@test.com';
        emailMatchingRec2.Email_Action__c=emailActionRec3.id;
        insert emailMatchingRec2;
        
        Email_Matching_Rule__c emailMatchingRec3=new Email_Matching_Rule__c();
        emailMatchingRec3.Name='Test Email Matching Rule';
        emailMatchingRec3.Field__c='From Address';
        emailMatchingRec3.operator__c='pattern Match';
        emailMatchingRec3.Value__c='testEmail@test.com';
        emailMatchingRec3.Email_Action__c=emailActionRec3.id;
        insert emailMatchingRec3;
        
        Email_Matching_Rule__c emailMatchingRec4=new Email_Matching_Rule__c();
        emailMatchingRec4.Name='Test Email Matching Rule';
        emailMatchingRec4.Field__c='CC Address';
        emailMatchingRec4.operator__c='pattern Match';
        emailMatchingRec4.Value__c='testToyAddress@test.com';
        emailMatchingRec4.Email_Action__c=emailActionRec3.id;
        insert emailMatchingRec4;
        
        Email_Matching_Rule__c emailMatchingRec5=new Email_Matching_Rule__c();
        emailMatchingRec5.Name='Test Email Matching Rule';
        emailMatchingRec5.Field__c='Body';
        emailMatchingRec5.operator__c='pattern Match';
        emailMatchingRec5.Value__c='TestbodyBlock';
        emailMatchingRec5.Email_Action__c=emailActionRec3.id;
        insert emailMatchingRec5;
        
        
        //test block action
        Messaging.InboundEmail email2 = new Messaging.InboundEmail() ;
        email2.ccAddresses=new String[]{'testToyAddress@test.com'};
        email2.toAddresses=new String[]{'testToAddress2@test.com'};
        email2.messageid='<Test4>';
        email2.references=new String[]{'Test1'};
        email2.subject = 'TestbodyBlock';
        email2.htmlBody='<p>email body</p>';
        email2.fromName = 'Test Name';
        email2.fromAddress = 'testEmail@test.com';
        email2.plainTextBody = 'TestbodyBlock';
        CustomEmailToCaseHandler customEmailToCaseHandlerObj2=new CustomEmailToCaseHandler();
        boolean res=customEmailToCaseHandlerObj2.ruleEngine(email2,'testToAddress2@test.com');
        
        
        
    }
}