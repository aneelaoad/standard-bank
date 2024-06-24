/**
*  apex class handling user provisioning with ping
*
* <p>SFP-8698</p>
*
* @author Salesforce
*
* @date Oct 2021 
*/
global with sharing class AOB_PingRegistrationHandler implements Auth.RegistrationHandler {
    private static final String EXTERNAL_USER_PROFILE = AOB_Utils.getOnboardingSettings('SB-COZA').AOB_Profile__c;
    private static final String SERVICE_NAME = AOB_PingRegistrationHandler.class.getName();
    
    /**
    * Create the User - A required method to implement the Handler Interface
    * @param portalId  - Id of the Community
    * @param data - Auth Provider user data describing the User to create
    * @return User that has been initialized
    */
    global User createUser(Id portalId, Auth.UserData data) {
         System.debug('Auth UserData '+data);
        Profile p = [SELECT Id 
                     FROM profile 
                     WHERE Name = :EXTERNAL_USER_PROFILE];
        System.debug('EXTERNAL_USER_PROFILE '+EXTERNAL_USER_PROFILE);
        System.debug('Profile '+p);
        Id contactId;
        String federationId;
        List<User> users = new List<User>();
        //check if the unique identifier is already assigne to a user
        if (data.attributeMap.containsKey(AOB_Constants.ID_STRING)) {
            federationId = data.attributeMap.get(AOB_Constants.ID_STRING);
            users = [ SELECT Id, federationIdentifier, isActive, ContactId
                      FROM User
                       WHERE federationIdentifier = :federationId AND isActive = TRUE ];
        }

        //if new User
        if (users.isEmpty()) {
            system.debug('*** users.isEmpty');
            system.debug('data.attributeMap '+data.attributeMap);
            User user = new User();
            Account newAccount = AOB_SRV_UserManagement.createAccount( data.attributeMap );
            if (newAccount != null) {
                Contact cont = new Contact();
                List<AccountContactRelation> acrList = [SELECT AccountId, ContactId FROM AccountContactRelation WHERE AccountId =:newAccount.id];
                if(acrList.isEmpty()){
                    Contact newCont = AOB_SRV_UserManagement.createContact(data.attributeMap,newAccount.Id);
                    //TO ADD: Create account contact relationship
                    AOB_SRV_UserManagement.createAccountContactRelation(newAccount.Id,newCont.Id);
                    user = AOB_SRV_UserManagement.createUser(data.attributeMap, user, newCont.id);
                    user.contactId = newCont.id;  
                }else{ 
                    user = AOB_SRV_UserManagement.createUser(data.attributeMap, user, acrList[0].ContactId);
                    user.contactId = acrList[0].ContactId;
                }  
                AOB_SRV_UserManagement.createAccountContactRelation(newAccount.id,user.contactId);
            }
            return user;
        }else{
            return users[0]; 
        }
    } 
    /* 
    * Update the user
    * @param portalId  - Id of the Community
    * @param data - Auth Provider user data describing the User to create
    */
    global void updateUser(Id userId, Id portalId, Auth.UserData data) {
        System.debug('Auth UserData '+data);
    }
    
}