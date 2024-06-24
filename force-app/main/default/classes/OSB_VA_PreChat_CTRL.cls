/**
 *
 * Controller class for OSB_VA_PreChat component
 *
 * @author Konrad Bruszewski (konrad.bruszewski@standardbank.co.za)
 * @date January 2021
 */
public with sharing class OSB_VA_PreChat_CTRL {


    /**
     * Method returns the details of user authenticated on the OneHub
     *
     * @return userId, associated contact's firstanme, lastname and email serialized as JSON
     */
    @auraenabled
    public static Map<String, String> getCurrentUser() {
        SEL_Users selUsers = new SEL_Users();
        List<User> users = selUsers.selectWithContactFieldsById(new Set<Id>{
                UserInfo.getUserId()
        });
        User u = users.get(0);
        Map<String, String> output = new Map<String, String>();
        String emailAddress;
        if (u.ContactId != null) {
            emailAddress = u.Contact.Email;
        }
        String secureToken = OSB_SRV_BotPaymentTrackingHandler.generateBotUserToken(String.valueOf(u.Id) + String.valueOf(u.ContactId));
        if (u.ContactId != null) {
            output.put('userId', u.Id);
            output.put('contactId', u.ContactId);
            output.put('firstName', u.Contact.FirstName);
            output.put('lastName', u.Contact.LastName);
            output.put('email', emailAddress);
            output.put('token', secureToken);
        } else {
            output.put('userId', '');
            output.put('contactId', '');
            output.put('firstName', '');
            output.put('lastName', '');
            output.put('email', '');
            output.put('token', '');
        }
        return output;
    }
}