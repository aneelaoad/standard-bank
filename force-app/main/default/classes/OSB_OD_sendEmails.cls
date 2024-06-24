/**
 * @description Class used to send emails to generate leads for API Products.
 *
 * @author Matthew Hunter (matthew.hunter@standardbank.co.za)
 * @date August 2022
 *
 */
public without sharing class OSB_OD_sendEmails {
    /**
     * @description Sends out emails to the relevant parties involved with generating a lead for an API Product
     *
     * @param contacts List of contact objects containing FirstName, LastName, Email, Phone
     * @param productName product name
     */
    public static void sendInterestedEmails(List<Contact> contacts, string productName) {
        sendContactInterestedEmail(contacts, productName);
    }

    /**
     * @description Sends out a confirmation email to the client confirming that we have recieved their lead
     *
     * @param contacts List of contact objects contact object containing FirstName, LastName, Email, Phone
     * @param productName product name
     */
    @TestVisible
    private static void sendContactInterestedEmail(List<Contact> contacts, string productName) {
        sendSupportInterestedEmail(contacts, productName);
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        List<Messaging.SingleEmailMessage> emails = OSB_SRV_EmailBuilder.newInstance()
            .createOneDeveloperInterestedEmail(contacts, productName);
        for (Messaging.SingleEmailMessage email : emails) {
            uow.registerEmail(email);
        }
        uow.commitWork();
    }

    /**
     * @description Sends out an email to the OneHub support team with the relevant client information in order to generte a lead
     *
     * @param contacts List of contact objects containing FirstName, LastName, Email, Phone
     * @param productName product name
     */
    @TestVisible
    private static void sendSupportInterestedEmail(List<Contact> contacts, string productName) {
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        List<Messaging.SingleEmailMessage> emails = OSB_SRV_EmailBuilder.newInstance()
            .createOneDeveloperSupportEmail(contacts, productName);
        for (Messaging.SingleEmailMessage email : emails) {
            uow.registerEmail(email);
        }
        uow.commitWork();
    }
}