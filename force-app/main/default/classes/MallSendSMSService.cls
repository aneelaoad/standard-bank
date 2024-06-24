/**
 * @description MallSendSMSService
 * @author Maham Hassan
 * @since
 */
public with sharing class MallSendSMSService {
    /**
    * @description sendSMSNotification : method to send SMS
    * @param request
    * @return Boolean
    */
    public static Boolean sendSMSNotification(MallCentralMessagingWebService.CMSSMSRequest request) {
        try {
            Mall_SMS_Notification_Configuration__mdt smsSetting = Mall_SMS_Notification_Configuration__mdt.getInstance('Mall_Login_Alert_SMS_Configuration');
            if(smsSetting.IsTesting__c) {
                request.senderAddress = smsSetting.Test_SMS_Sender_Number__c;
                request.reciepientAddress = smsSetting.Test_SMS_Receiver_Number__c;
            } 
            return (String.isNotBlank(request.content) ? MallCentralMessagingWebService.sendSMSToCustomer(request) : false);
                        
       } catch (Exception e) { 
            throw MallExceptionUtil.throwAuraException('MallSendSMSService.sendSMSNotification', e); 
        }
    }
}