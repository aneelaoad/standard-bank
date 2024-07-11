/**
 * @description OSB_OtpManagement_CTRL class for osbOtpModal Lightning Component
 * @author Eldrin Shikwambana (eldrin.shikwambana@standardbank.co.za)
 * @date May 2024
 * UserStory SFP-38763
 **/
public with sharing class OSB_OtpManagement_CTRL {
    public static final String developerName = 'OneHub';

    /**
     * @description  Retrieving the Onehub Custom metadata record from the OTP Request Setting.
     * @return String
     **/
    @AuraEnabled
    public static OTP_Request_Setting__mdt getCustomMetadataRecord() {
        OTP_Request_Setting__mdt metadataRecord = OTP_Request_Setting__mdt.getInstance(
            developerName
        );
        return metadataRecord;
    }

    /**
     * @description Requests for an OTP code for the respective user
     *  SFP-38763
     * @param otpReason String
     * @return SRV_OTP.Response wrapper class
     **/
    @AuraEnabled
    public static SRV_OTP.Response initialiseOTP(String otpReason) {
        Id userId = UserInfo.getUserID();
        SRV_OTP service = (SRV_OTP) SRV_OTP.newInstance();
        Contact userContact = SEL_Contacts.newInstance().selectByUserId(new Set<Id>{ userId })[0];
        List<OTPRequest__c> existingRequests = SEL_OTPRequest.newInstance().selectByRelatedRecordId(userContact.Id);
        service.initialise(developerName, userContact.Id);
        if (!existingRequests.isEmpty()) {
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                new List<SObjectType>{ OTPRequest__c.SObjectType }
            );
            OTPRequest__c existingRequest = existingRequests[0];
            existingRequest.CodeExpiresAt__c = System.now().addHours(-1);
            uow.registerDirty(existingRequest);
            uow.commitWork();
        }
        return service.requestCode();
    }

    /**
     * @description Validates an OTP code provided by the user .
     * SFP-38763
     * @param  String inputCode
     * @return SRV_OTP.Response wrapper class
     **/
    @AuraEnabled
    public static SRV_OTP.Response validateOTPCode(String inputCode) {
        Id userId = UserInfo.getUserID();
        Contact userContact = SEL_Contacts.newInstance().selectByUserId(new Set<Id>{ userId })[0];
        SRV_OTP service = (SRV_OTP) SRV_OTP.newInstance();
        service.initialise(developerName, userContact.Id);
        return service.validateCode(inputCode);
    }

    /**
     * @description Creates a case and assign it to the OneHub queue.
     * SFP-38763
     * @return created Case record
     **/
    @AuraEnabled
    public static Case createCase() {
        Case caseRecord = new Case();
        Id userId = UserInfo.getUserID();
        Contact userContact = SEL_Contacts.newInstance().selectByUserId(new Set<Id>{ userId })[0];
        caseRecord.Subject = 'Suspicious activity detected';
        caseRecord.Description =
            'We have detected some unusual activity for ' +
            userContact.FirstName +
            ' ' +
            userContact.LastName +
            ' six or more OTP attempts. Please get in touch with them so we can help ensure the security of their OneHub account.';
        caseRecord.OwnerId = UTL_Queue.getQueueId(DMN_Queue.ONEHUB_QUEUE);
        return DMN_Case.createCaseWithUserContactId(caseRecord);
    }

    /**
     * @description A method to invoke OTP emails to a flow.
     * SFP-38763
     * @param  otpId String
     * @param  otpReason String
     **/
    @AuraEnabled
    public static void sendOutMailOTP(String otpReason) {
        Contact userContact = SEL_Contacts.newInstance().selectByUserId(new Set<Id>{ UserInfo.getUserID() })[0];
        OTPRequest__c otpRequest = SEL_OTPRequest.newInstance().selectByRelatedRecordId(userContact.Id)[0];
        Map<String, Object> inputs = new Map<String, Object>();
        inputs.put('otpAction', otpReason);
        inputs.put('recordID', otpRequest.Id);

        if (!Test.isRunningTest()) {
            Flow.Interview.OSB_OTP_Email_Alerts myFlow = new Flow.Interview.OSB_OTP_Email_Alerts(inputs);
            myFlow.start();
        }
    }
}