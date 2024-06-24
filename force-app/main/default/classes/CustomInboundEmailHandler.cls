/*************************************************************************\
@ Author        :     Raja Kumar
@ Date          :     23rd Sept 2022
@ Test File     :     CustomInboundEmailHandlerTest
@ Description   :     SFP-12913 : Create New Case using custom email handler
creating this custom inbound email handler to replicate standard Email-to-case functionality and 
to add features not catered by standard email-to-case such as creating a new when when a mail is 
received for a closed case and creating case with spam status for recall emails.
****************************************************************************/


public with sharing  class CustomInboundEmailHandler implements Messaging.InboundEmailHandler {
    private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('CustomInboundEmailHandler');
    public Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        //assign variable in handler class
        CustomEmailToCaseHandler customEmailToCaseHandlerObj=new CustomEmailToCaseHandler();
        boolean caseCreated=false;
        
        //handle toAddress of InboundEnvelope
        if(envelope.toAddress != null){
            caseCreated=customEmailToCaseHandlerObj.ruleEngine(email,envelope.toAddress);
            
        }
        result.success=true;
        LOGGER.debug('result of inbound email handler : '+ result);
        return result;
    }
}