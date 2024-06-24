/*************************************************************************\
@ Author        :     Raja Kumar
@ Date          :     23rd Sept 2022
@ Description   :     SFP-12913 : Create New Case using custom email handler

This test class covers following classes for custom inbound email handler.
*CustomInboundEmailHandler
****************************************************************************/
@isTest(SeeAllData=false)
public class CustomInboundEmailHandlerTest {
    
    //test for existing contact
    @isTest static void testInboundEmail(){
      fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        
        User testUser1 = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        uow.commitWork();
        
        System.runAs(testUser1) {
                        //email to test references
            Messaging.InboundEmail email4 = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env4 = new Messaging.InboundEnvelope();
            env4.toAddress='testToAddressNot@test.com';
            email4.ccAddresses=new String[]{'testToyAddress@test.com'};
            email4.toAddresses=new String[]{'testToAddressNot@test.com'};
            email4.messageid='<Test4>';
            email4.references=new String[]{'<Test1>'};
            email4.subject = 'Create Case';
            email4.htmlBody='<p>email body</p>';
            email4.fromName = 'Test Name';
            email4.fromAddress = 'testEmail@test.com';
            email4.plainTextBody = 'email body';
            Messaging.InboundEmail.BinaryAttachment attachment4 = new Messaging.InboundEmail.BinaryAttachment();
            attachment4.body = blob.valueOf('my attachment text');
            attachment4.fileName = 'textfileone.txt';
            attachment4.mimeTypeSubType = 'text/plain';
            email4.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment4 };
            CustomInboundEmailHandler  testInboundEmail4=new CustomInboundEmailHandler ();
            Messaging.InboundEmailResult result=testInboundEmail4.handleInboundEmail(email4, env4);
			system.assert(result.success,true);            
        }
    }
}