/**
 * Controller class for OSB_TeamProfile component
 *
 * @author Wayde Fagan (wayde.fagan@tetrad.co.za)
 * @description This is a controller class to team profile component
 * @date April 2020
 *
 * @LastModified August 2023
 * @author litha Nosekeleza (litha.Nosekeleza@standardbank.co.za)
 * @UserStory SFP-28081
 * @LastModifiedReason added a new  method to approveNewUserAccess
 * 
 **/
public without sharing class OSB_TeamProfile_Ctrl {
	private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('OSB_TeamProfile_Ctrl');
    private static final String CHECK_FOR_EMAIL = 'standardbank';
    private static final String DEFAULT_COUNTRY = 'South Africa';
    private static final String DEFAULT_CONTACT_CATEGORY = 'Developer';
    private static final String DEFAULT_PHONE_NUM = '0000000000';
    private static final String ACCOUNT_NAME = DMN_Account.STANDARD_BANK_EMPLOYEES;
    private static final String BANK_CONTACT_RECORD_NAME = 'Bank Contact Record Type';
    private static final String CLIENT_CONTACT_RECORD_NAME = 'Client Contact Record Type';
    @TestVisible
    private static final String TEAM_INVITES_KEY = 'teamInvitesSent';

    /**
     * @description Get contact for the team profile
     *
     * @return Map<String, Object> of contacts
     **/
    @AuraEnabled
    public static Map<String, Object> getTeamContacts(){
        List<User> contactIdOfUser = SEL_Users.newInstance().selectById(New Set<Id>{UserInfo.getUserId()});
       	List<Contact> teamInvitesSent = SEL_Contacts.newInstance().selectByOneHubManager(New Set<Id>{contactIdOfUser[0].ContactId});
        List<Contact> primaryContact = SEL_Contacts.newInstance().selectById(New Set<Id>{contactIdOfUser[0].ContactId});
        Map<String, Object> type2Contacts = new Map<String, Object>{
                TEAM_INVITES_KEY => teamInvitesSent
        };
        if (!primaryContact.isEmpty()) {
            type2Contacts.put('primaryContact', primaryContact[0]);
        }
        LOGGER.debug('OSB_TeamProfile_Ctrl, getTeamContacts: ' + type2Contacts); 
        return type2Contacts;
    }

    /**
     * @description Creates a new light contact for the new invites from the AP/DP/NP flow
     *
     * @param inviteList JSON object of the new contact list
     *
     * @return Boolean if created successfully
     **/
    @AuraEnabled(cacheable=false)
    public static Boolean createLightContact(List<Contact> inviteList){
        Boolean updateSuccessful = false; 
        try{
            List <Contact> contactsFoundList = new List <Contact> ();
            Set<String> firstNameSet = new Set<String>();
            Set<String> lastNameSet = new Set<String>();
            Set<String> emailSet = new Set<String>();
            Map<String,Contact> email2Contact = new Map<String,Contact>();
            Map<String,Contact> approvedOnehubContactsMap = new Map<String,Contact>();
            Contact oneHubManagerContact = new Contact(); 
            List <Contact> contactUser = SEL_Contacts.newInstance().selectByUserId(new Set<Id>{UserInfo.getUserId()});
            
            if(!contactUser.isEmpty()){
                oneHubManagerContact = contactUser[0];
            }
            for(Contact cont : inviteList){
                firstNameSet.add(cont.FirstName);  
                lastNameSet.add(cont.LastName);  
                emailSet.add(cont.Email);
            }  
            contactsFoundList = SEL_Contacts.newInstance().selectByFirstNameLastNameEmail(firstNameSet,lastNameSet,emailSet);
            if(!contactsFoundList.isEmpty()){
                for(Contact contactFound: contactsFoundList){
                    for(Contact inviteContact : inviteList){
                        if(inviteContact.LastName.equalsIgnoreCase(contactFound.LastName) && inviteContact.Email.equalsIgnoreCase(contactFound.Email)){
                            contactFound.OSB_Community_Access_Role__c = inviteContact.OSB_Community_Access_Role__c;    
                            contactFound.OSB_Date_Invite_Sent__c = System.now();
                            contactFound.OSB_Community_Access_Manager__c = oneHubManagerContact.Id;
                            if(String.isBlank(contactFound.OSB_Community_Access_Status__c) || contactFound.OSB_Community_Access_Status__c == DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_INVITE_SENT){
                                contactFound.OSB_Community_Access_Status__c = DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_INVITE_SENT;
                                email2Contact.put(contactFound.Email.toLowerCase(), contactFound);
                            }else{
                                if((contactFound.OSB_Community_Access_Status__c == DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_INACTIVE || 
                                    contactFound.OSB_Community_Access_Status__c == DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_DECLINED) &&
                                   !String.isBlank(contactFound.Ping_Id__c)){
                                       contactFound.OSB_Community_Access_Status__c = DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_PENDING_APPROVAL;
                                       contactFound.OSB_Contact_Re_invited__c = true;
                                       email2Contact.put(contactFound.Email.toLowerCase(),contactFound);
                                   }else{
                                    if (contactFound.OSB_Community_Access_Status__c == DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED &&
                                        !String.isBlank(contactFound.Ping_Id__c)) {  
                                            approvedOnehubContactsMap.put(contactFound.Email.toLowerCase(),contactFound);                
                                    }
                                   }
                            } 
                        }
                    }
                }
            }else{
                for(Contact inviteContact : inviteList){
                    email2Contact.put(inviteContact.Email.toLowerCase(),setUpLightContact(inviteContact, oneHubManagerContact)); 
                }
            }

            if(!approvedOnehubContactsMap.isEmpty()){
                for(Contact inviteContact : inviteList){
                    if((!email2Contact.containsKey(inviteContact.Email.toLowerCase())) && (!approvedOnehubContactsMap.containsKey(inviteContact.Email.toLowerCase()))){
                        email2Contact.put(inviteContact.Email.toLowerCase(),setUpLightContact(inviteContact, oneHubManagerContact));
                        continue;
                    }
                }
            }else{
                for(Contact inviteContact : inviteList){
                    if(!email2Contact.containsKey(inviteContact.Email.toLowerCase())){
                        email2Contact.put(inviteContact.Email.toLowerCase(),setUpLightContact(inviteContact, oneHubManagerContact));
                        continue;
                    }
                }
            }

           updateSuccessful = saveAndSendEmails(email2Contact);
        }catch(Exception e){
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_TeamProfile_Ctrl.class.getName());
            return false;
        } 
        LOGGER.debug('OSB_TeamProfile_Ctrl,createLightContact: ' + updateSuccessful); 
        return updateSuccessful;
    }  
    
    /**
     * @description This method commits the work and sends the relevant emails out
     * 
     * @param email2Contact Map of String email to contact
     * 
     * @return updateSuccessfull Boolean
     */
    private static Boolean saveAndSendEmails(Map<String,Contact> email2Contact){
        Boolean updateSuccessful = false;
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        List<Contact> contactsToBeEmailed = new List <Contact>();
        List<Contact> contactsToReinvite = new List<Contact>();
        List<Contact> contactsToCreated = new List<Contact>();
        try{
            for (String contactEmail : email2Contact.keySet()){
                if(email2Contact.get(contactEmail).Id == null){
                    contactsToCreated.add(email2Contact.get(contactEmail));
                }else if(email2Contact.get(contactEmail).OSB_Contact_Re_invited__c == true && email2Contact.get(contactEmail).Id != null){
                    contactsToReinvite.add(email2Contact.get(contactEmail));     
                }else{
                    contactsToBeEmailed.add(email2Contact.get(contactEmail));
                }
            }
            if(!contactsToCreated.isEmpty()){
                uow.registerNew(contactsToCreated); 
                uow.commitWork();
                uow = ORG_Application.unitOfWork.newInstance();
                OSB_SRV_EmailSender.newInstance().sendDPNpInviteEmail(contactsToCreated, uow);
            }
            if(!contactsToBeEmailed.isEmpty()){
                uow.registerDirty(contactsToBeEmailed);
                uow.commitWork();
                uow = ORG_Application.unitOfWork.newInstance();
                OSB_SRV_EmailSender.newInstance().sendDPNpInviteEmail(contactsToBeEmailed, uow);
            }
            if(!contactsToReinvite.isEmpty()){
                uow.registerDirty(contactsToReinvite);
                uow.commitWork();
                uow = ORG_Application.unitOfWork.newInstance();
                OSB_SRV_EmailSender.newInstance().sendReinviteEmail(contactsToReinvite, uow);
            }
            uow.commitWork();
            updateSuccessful = true;
        }catch(Exception e){
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_TeamProfile_Ctrl.class.getName());
            return false;
        }
         LOGGER.debug('OSB_TeamProfile_Ctrl.saveAndSendEmails: ' + updateSuccessful); 
        return updateSuccessful;
    }

    /**
     * @description This sets the fields of a light contact Record for contacts not found in Salesforce
     * 
     * @param inviteContact Contact record which will be used for update
     * @param oneHubManagerContact Contact of the onehub manager
     * 
     * @return Contact
     */
    private static Contact setUpLightContact(Contact inviteContact, Contact oneHubManagerContact){
        SEL_Accounts selectAccount = new SEL_Accounts();
        List<Account> standardBankAccountList = selectAccount.selectByRegisteredName(new Set<String>{ACCOUNT_NAME});

        inviteContact.OSB_Date_Invite_Sent__c = System.now();
        inviteContact.OSB_Community_Access_Manager__c = oneHubManagerContact.Id;
        inviteContact.Contact_Category__c = DEFAULT_CONTACT_CATEGORY;
        inviteContact.OSB_Community_Access_Status__c = DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_INVITE_SENT;
        inviteContact.Phone = DEFAULT_PHONE_NUM;
        inviteContact.OSB_IsCommunityUser__c = true;
        inviteContact.Phone_Country__c = DEFAULT_COUNTRY;
        String emailCheck = inviteContact.Email.toLowerCase();                    
        if(!emailCheck.contains(CHECK_FOR_EMAIL)){
            inviteContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(CLIENT_CONTACT_RECORD_NAME).getRecordTypeId();
            inviteContact.AccountId = oneHubManagerContact.AccountId;
        }else{
            inviteContact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(BANK_CONTACT_RECORD_NAME).getRecordTypeId();                       
            inviteContact.AccountId = standardBankAccountList[0].Id;
        }
        LOGGER.debug('OSB_TeamProfile_Ctrl. setUpLightContact: ' + inviteContact);
        return inviteContact;
    }

    /**
     * @description Updates contact record to declined once AP/DP declines access
     *
     * @param contactId Id of Contact whose access is declined
     *
     * @return boolean
     **/
    @AuraEnabled(cacheable=false)
    public static boolean declineNewUserAccess(Id contactId){
        boolean updateSuccess = false;
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        try{
            Contact contact = new Contact(Id = contactId);
            contact.OSB_Community_Access_Status__c = DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_DECLINED;
            contact.OSB_User_Access_Declined__c = System.now();
            uow.registerDirty(contact);

            OSB_SRV_EmailSender.newInstance().sendDpNpAccessDeclinedEmail(SEL_Contacts.newInstance().selectByIdWoSharing(new Set<Id>{contactId}), uow);
            uow.commitWork();
            
            updateSuccess = true;
             LOGGER.debug('OSB_TeamProfile_Ctrl. declineNewUserAccess: ' + updateSuccess);
            return updateSuccess;
        }
        catch(Exception e){
            LOGGER.fatal('OSB_TeamProfile_Ctrl.declineNewUserAccess: ' , e);
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_TeamProfile_Ctrl.class.getName());
            return false;
        }
    }

   

    /**
     * @description Resends the invite link by setting the OSB_Date_Invite_Resent__c to now
     *
     * @param contactId Id of Contact who the invite link should be sent to
     *
     * @return boolean
     **/
    @AuraEnabled(cacheable=false)
    public static boolean resendUserInviteLink(Id contactId){
        boolean updateSuccess = false;
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        try{
            Contact contact = new Contact(Id = contactId);
            contact.OSB_Date_Invite_Resent__c = System.now();
            uow.registerDirty(contact);

            OSB_SRV_EmailSender.newInstance().sendDPNpInviteEmail(SEL_Contacts.newInstance().selectByIdWoSharing(new Set<Id>{contactId}), uow);
            uow.commitWork();

            updateSuccess = true;
            LOGGER.debug('OSB_TeamProfile_Ctrl, resendUserInviteLink ' + updateSuccess);
            return updateSuccess;
        }
        catch(Exception e){
            LOGGER.fatal('OSB_TeamProfile_Ctrl.resendUserInviteLink: ' , e);
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_TeamProfile_Ctrl.class.getName());
            return false;
        }
    }

    /**
     * @description Updates contact record to inactive and changes user record to inactive once AP/DP removes access
     *
     * @param contactId Id of Contact whose access is to be removed
     *
     * @return boolean
     **/
    @AuraEnabled(cacheable=false)
    public static boolean deactivateUserOneHubAccessApex(Id contactId){ 
        boolean updateSuccess = false;
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        Contact contact = new Contact(Id = contactId);
        try{
            if(contact != null){
                List <User> userList = SEL_Users.newInstance().selectByContactId(new Set <Id>{contact.Id});
                if(!userList.isEmpty()){
                    updateUser(userList[0].Id,false);
                    updateEntitlementExceptions(userList[0].Id);
                }
            }
            contact.OSB_Community_Access_Status__c = DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_INACTIVE;
            contact.OSB_User_Access_Deactivated__c = system.now();
            uow.registerDirty(contact);

            OSB_SRV_EmailSender.newInstance().sendDpNpAccessRemovedEmail(SEL_Contacts.newInstance().selectByIdWoSharing(new Set<Id>{contactId}), uow);
            uow.commitWork();
            updateSuccess = true;
        }
        catch(Exception e){
            LOGGER.fatal('OSB_TeamProfile_Ctrl.deactivateUserOneHubAccessApex: ' , e);
            OSB_SRV_ActionFailureHandler.newInstance().handleError(e, OSB_TeamProfile_Ctrl.class.getName());
            return false;
        }
        LOGGER.debug('OSB_TeamProfile_Ctrl, deactivateUserOneHubAccessApex ' + updateSuccess);
        return updateSuccess;
    }
    
    @future 
    private static void updateEntitlementExceptions(Id userId){
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        Contact con = SEL_Contacts.newInstance().selectByUserId(New Set<Id>{userId})[0]; 
        List<Knowledge_Entitlement_Exception__c> currentExceptions = SEL_KnowledgeExceptions.newInstance().selectByContactIdWoSharing(new Set<Id>{con.Id});
        if(!currentExceptions.isEmpty()){
            uow.registerDeleted(currentExceptions);
            uow.commitWork();
        }
    }
    
    @future
    private static void updateUser(Id userId,Boolean status){
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        User user = new user(Id = userId);
        user.isActive = status;
        uow.registerDirty(user);
        uow.commitWork();
    }

    /**
     * @description Updates Contact.OSB_Team_Profile_Onboarding_Tour_Date__c with current date time
     * @param contactId id of contact to be updated
     */
    @AuraEnabled(Cacheable=false)
    public static void setOnboardingDate(Id contactId) {
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        uow.registerDirty(new Contact(
                Id = contactId,
                OSB_Team_Profile_Onboarding_Tour_Date__c = Datetime.now()
        ));
        uow.commitWork();
    }

    /**
     * @description Updates contact record to approved once invitee completes form
     *
     * @param contactId Id of Contact whose access is approved
     *  
     *@OPTL-1828
     **/
   
    @InvocableMethod(label='Auto Approve User and Send Email'  description='Approve User and Send Email' category='Contact')
    public static void approveNewUserAccess(List<Id> contactId){
       
        fflib_ISObjectUnitOfWork uow = ORG_Application.unitOfWork.newInstance();
        try{
            Contact contact = new Contact(Id = contactId[0]);
                contact.OSB_Community_Access_Status__c = DMN_Contact.OSB_COMMUNITY_ACCESS_STATUS_APPROVED;
                contact.OSB_User_Access_Approved__c = System.now();
                uow.registerDirty(contact);
                OSB_SRV_EmailSender.newInstance().sendDpNpAccessApprovedEmail(SEL_Contacts.newInstance().selectByIdWoSharing(new Set<Id>{contactId[0]}), uow);
                uow.commitWork();
        }
        catch(Exception e){
             LOGGER.fatal('OSB_TeamProfile_Ctrl.approveNewUserAccess error: ' , e);
        }
    }   
}