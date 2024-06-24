/**
 * @description Controller class that handles the interested journey for API Products
 *
 * @author Matthew Hunter (matthew.hutner@standardbank.co.za)
 * @date August 2022
 *
 */
public without sharing class OSB_OD_InterestedJourney_CTRL {
    /**
     * @description Method that sends the relevant parties emails in order to generate a lead
     *
     * @param productName Contact object that contains FirstName, LastName, Email and Phone
     * @param product name
     */
    @AuraEnabled
    public static void generateInterestedEmails(string productName) {
        Contact contact = SEL_Contacts.newInstance().selectByUserId(new Set<Id>{ UserInfo.getUserId() })[0];
        OSB_OD_sendEmails.sendInterestedEmails(new List<Contact>{ contact }, productName);
    }
}