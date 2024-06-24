/**
 * Created for SFP-5036 - Controller class for cbPreChatCmp component. 
 * @author Sharath Chintalapatii (sharath.chintalapati@standardbank.co.za)
 * @date October 2021
 */
public with sharing class CB_GM_PreChatCmpCnt {
    /**
     * Method returns the details of user authenticated on the OneHub
     *
     * @return userId, associated contact's firstname, lastname and email serialized as JSON
     */
    @auraenabled
    public static Map<String, String> getCurrentUser() {
        String emailAddress;
        string secureToken;
        Contact con;
        Map<String, String> output = new Map<String, String>();
        SEL_Users selUsers = new SEL_Users();
        List<User> users = selUsers.selectWithContactFieldsById(new Set<Id>{UserInfo.getUserId()});
        User usr = users.get(0);
        
        if(usr.contactId != null){
            secureToken = OSB_SRV_BotPaymentTrackingHandler.generateBotUserToken(String.valueOf(usr.Id) + String.valueOf(usr.contactId));
        }else{
        	secureToken = OSB_SRV_BotPaymentTrackingHandler.generateBotUserToken(String.valueOf(usr.Id) + String.valueOf(usr.Contact_Sync_ID__c));    
        }

        if (usr.Contact_Sync_ID__c  != null || usr.ContactId != null) {
            output.put('userId', usr.Id);
            if(usr.ContactId != null){
            	output.put('contactId', usr.ContactId );    
                con = [SELECT firstname, lastname FROM contact WHERE Id=:usr.ContactId];
            }else{
                output.put('contactId', usr.Contact_Sync_ID__c );
                con = [SELECT firstname, lastname FROM contact WHERE Id=:usr.Contact_Sync_ID__c];
            }
            
            output.put('firstName', con.firstName);
            output.put('lastName', con.LastName);
            output.put('email', usr.Email);
            output.put('token', secureToken);
        } else {
            output.put('userId', '');
            output.put('contactId', '');
            output.put('firstName', '');
            output.put('lastName', '');
            output.put('email', '');
            output.put('token', '');
        }
        system.debug('the output is --> '+output);
        return output;
    }
}