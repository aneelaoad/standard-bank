/**
 * @description Contact Selector Layer class.
 *
 * @author Caro Reinecke (caro@khonology.com)
 *
 * @date 2018-09-07
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public inherited sharing class SEL_Contacts extends fflib_SObjectSelector
{
    /**
     * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     *
	 * @return SEL_Contacts
	 * returns instance of SEL_Contacts
     */
    public static SEL_Contacts newInstance() {
        return (SEL_Contacts) ORG_Application.selector.newInstance(
            Contact.SObjectType
        );
    }

    /**
    * @description return list of standard selector fields
    *
    * @return standard list of selector fields
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                Contact.AccountId,
                Contact.Company_Industry__c,
                Contact.Contact_Category__c,
                Contact.Contact_Role_s_at_Client__c,
                Contact.Email,
                Contact.FirstName,
                Contact.Group_Parent_CIF_Number__c,
                Contact.Id,
                Contact.Identity_Number__c,
                Contact.Initials__c,
                Contact.LastName,
                Contact.MailingCity,
				Contact.MailingAddress,
                Contact.MailingCountry,
                Contact.MailingPostalCode,
                Contact.MailingState,
                Contact.MailingStreet,
                Contact.Name,
                Contact.Onboarding_Tour_Date__c,
                Contact.OSB_Community_Access_Manager__c,
                Contact.OSB_Community_Access_Role__c,
                Contact.OSB_Community_Access_Status__c,
                Contact.OSB_Company_name__c,
                Contact.OSB_Date_Invite_Resent__c,
                Contact.OSB_Date_Invite_Sent__c,
                Contact.OSB_Expire_Sign_Up_Link__c,
                Contact.OSB_Operating_Country__c,
                Contact.OSB_Persona__c,    
                Contact.OSB_Passport_Number__c,
                Contact.OSB_Team_Profile_Onboarding_Tour_Date__c,
                Contact.OSB_User_Access_Approved__c,
                Contact.OSB_User_Access_Declined__c,
                Contact.OSB_User_Access_Deactivated__c,
                Contact.OSB_User_Sign_Up_Complete__c,
                Contact.OSB_Contact_Re_invited__c,
				Contact.OSB_HideMFA__c,
                Contact.OwnerId,
                Contact.Phone,
                Contact.Phone_Country__c,
                Contact.Ping_Id__c,
                Contact.RecordTypeId,
                Contact.Title,
				Contact.MobilePhone,
				Contact.BPID__c,
                Contact.User_Division_Sync__c,
                Contact.IndividualId,
            	Contact.HasOptedOutOfEmail,
                Contact.User_Business_Unit_Sync__c,
                Contact.ExternalIdentifier__c,
                Contact.ExternalCIFId__c,
                Contact.ExternalCIFUUID__c,
                Contact.Manage_Site_Features__c,
                Contact.CIF_Number__c,
                Contact.Register_Mall_Tenant__c,
                Contact.BCB_Platform_Tenant_Role__c,
                Contact.Related_Provider__c
            };
    }

    /**
    * @description Return sObject type of current selector
    *
    * @return Contact Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType() {
		return Contact.SObjectType;
    }

    /**
    * @description Returns list of contacts by id
    *
    * @param idSet Set<Id> set of contact ids
	*
    * @return list of selected contacts
    */
    public List<Contact> selectById(Set<Id> idSet) {
        return (List<Contact>) Database.query(
            newQueryFactory().setCondition('Id IN: idSet').toSOQL()
        );
    }
    
    /**
    * @description Returns list of contacts by id
    *
    * @param idSet Set<Id> set of contact ids
	*
    * @return list of selected contacts
    */
    public List<Contact> selectByPingUUID(Set<String> idSet) {
        return (List<Contact>) Database.query(
            newQueryFactory().setCondition('Ping_Id__c IN: idSet').toSOQL()
        );
    }

    /**
    * @description Get records by ClientId
	*
    * @param  clientId Set of IDs
	*
    * @return List<Contact>
    */
    public List<Contact> selectByClientId(Set<Id> clientId) {
        return (List<Contact>) Database.query(
                newQueryFactory()
                        .setCondition('AccountId IN: clientId')
                .setOrdering(
                    'CreatedDate',
                    fflib_QueryFactory.SortOrder.ASCENDING
                )
                        .toSOQL()
        );
    }
    /**
     * @description Select without conditions
     *
     * @param countLimit Integer - number of contacts to retrieve
     *
     * @return List<Contact>
     */
    public List<Contact> selectWithoutCondition(Integer countLimit) {
        return (List<Contact>) Database.query(
            newQueryFactory().setLimit(countLimit).toSOQL()
        );
    }

    /**
    * @description Get records by OnboardAppId
	*
    * @param  onboardId Set of IDs
	*
    * @return List<Contact>
    */
    public List<Contact> selectByOnboardAppId(Set<Id> onboardId) {
        String statusPending = DMN_ApplicationDocuments.STATUS_PENDING;
        return Database.query(
                newQueryFactory()
						.setCondition('Id IN (SELECT Authorised_Person__c FROM Application_Document__c WHERE Onboarding_Application__c IN:onboardId AND Document_Status__c=:statusPending)')
                        .setOrdering('CreatedDate',fflib_QueryFactory.SortOrder.ASCENDING)
                        .toSOQL());
    }
    /**
    * @description Returns record with cropped fields for registartion page
    *
    * @param idSet Set<Id> set of ids
	*
    * @return list of selected contacts
    */
    public List<Contact> selectByIdForRegistration(Set<Id> idSet) {
        List<Schema.SObjectField> regFields = new List<Schema.SObjectField>{
            Contact.Email,
            Contact.FirstName,
            Contact.LastName,
            Contact.Name,
            Contact.Phone,
            Contact.Phone_Country__c,
            Contact.OSB_Community_Access_Manager__c,
            Contact.Identity_Number__c,
            Contact.OSB_Expire_Sign_Up_Link__c,
            Contact.OSB_Passport_Number__c,
            Contact.OSB_Community_Access_Role__c,
            Contact.OSB_Company_name__c,
            Contact.Company_Industry__c,
            Contact.Title,
            Contact.OSB_Operating_Country__c,
            Contact.Manage_Site_Features__c
        };

        return (List<Contact>) Database.query(
                newQueryFactory(false)
                .selectFields(regFields)
                .setCondition('Id IN: idSet')
                .toSOQL()
        );
    }

    /**
    * @description Selects authorised person contact by related account id
    *
    * @param idSet Set<Id> set of related account ids
	*
    * @return list of selected contacts
    */
    public List<Contact> selectAuthorisedPersonByAccountId(Set<Id> idSet) {
        return (List<Contact>) Database.query(
            newQueryFactory()
                .setCondition(
                    'Contact_Role_s_at_Client__c includes (\'Authorised Person\') and AccountId in :idSet'
                )
                .toSOQL()
        );
    }

    /**
    * @description returns KYC contact list, by id of related account
    *
    * @param idSet Set<Id> set of ids
	*
    * @return list of selected contacts
    */
    public List<Contact> selectKYCContactByAccountId(Set<Id> idSet) {
        return (List<Contact>) Database.query(
            newQueryFactory()
                .setCondition(
                    'Contact_Role_s_at_Client__c includes (\'KYC Contact\',\'GROUP KYC Contact\') and AccountId in :idSet'
                )
                .toSOQL()
        );
    }

    /**
    * @description returns list of contacts by id of related User
    *
    * @param ids Set<Id> set of ids
	*
    * @return list of selected contacts
    */
    public List<Contact> selectByUserId(Set<Id> ids) {
        return Database.query(
                newQueryFactory(false, false, true)
                .setCondition(
                    'Id IN (SELECT ContactId FROM User WHERE Id IN :ids)'
                )
            			.selectField('OSB_Community_Access_Manager__r.name')
            			.selectField('Account.Name')
                .selectField('Manage_Site_Features__c')
                        .toSOQL()
        );
    }

    /**
    * @description Returns lists of contact by email, idNumber and passport number
    *
    * @param emails Set<String> set of emails
    * @param idNumbers Set<String> set of custom identity numbers
    * @param passportNumbers Set<String> set of passport numbers
	*
    * @return list of selected contacts
    */
    public List<Contact> selectByEmailIdentityPassport(
        Set<String> emails,
        Set<String> idNumbers,
        Set<String> passportNumbers
    ) {
        return Database.query(
                newQueryFactory(false, false, true)
                .setCondition(
                    'Email IN :emails AND (Identity_Number__c IN :idNumbers OR OSB_Passport_Number__c IN :passportNumbers)'
                )
                .toSOQL()
        );
    }

    /**
    * @description Returns lsit of contacts by custom identity number
    *
    * @param identityNumbers Set<String> set of custom identity numbers
	*
    * @return list of selected contacts
    */
    public List<Contact> selectByIdentityNumber(Set<String> identityNumbers) {
        return Database.query(
                newQueryFactory(false, false, true)
                        .setCondition('Identity_Number__c IN: IdentityNumbers')
                        .toSOQL()
        );
    }

	/**
	 * @description Returns a list of contacts selected by external Identifier field
	 *
	 * @param externalIds Set<String> set of custom external Ids
	 *
	 * @Modification Description : SFP-28318
	 *
	 * @return list of selected contacts
	 */
	public List<Contact> selectByExternalIdentifiers(Set<String> externalIds)
	{
		return Database.query(
				newQueryFactory(false, false, true)
						.setCondition('ExternalIdentifier__c IN: externalIds')
						.toSOQL()
		);
	}
    /**
    * @description Returns lsit of contacts by email address alone
    * created on 23rd March 2023
    * @param emailAddresses Set<String> set of email addresses
    * @return list of selected contacts
    */
    public List<Contact> selectByEmail(Set<String> emailAddresses) {
        return (List<Contact>) Database.query(
                newQueryFactory()
            			.selectField('Id')
             			.selectField('AccountId')
             			.selectField('Email')
             			.selectField('Name')
			 			.setCondition('Email in :emailAddresses')
        	 			.setLimit(1)
             			.toSOQL()
        );
    }
    
    /**
    * @description Returns list of contacts by it's OneHub managers id
    *
    * @param idSet Set<ID> set of OneHub managers ids
	 *
    * @return list of selected contacts
    */
    public List<Contact> selectByOneHubManager(Set<Id> idSet) {
        return (List<Contact>) Database.query(
                newQueryFactory()
            			.setCondition('OSB_Community_Access_Manager__c in :idSet')
                .toSOQL()
        );
    }

    /**
    * @description Returns list of contacts by first name, last name and email
    *
    * @param firstNames Set<String> set of first names
    * @param lastNames Set<String> set of last names
    * @param emails Set<String> set of emails
	*
    * @return list of selected contacts
    */
    public List<Contact> selectByFirstNameLastNameEmail(
        Set<String> firstNames,
        Set<String> lastNames,
        Set<String> emails
    ) {
        return (List<Contact>) Database.query(
                newQueryFactory()
                .setCondition(
                    '(FirstName IN: firstNames AND LastName IN: lastNames AND Email IN: emails)'
                )
                .toSOQL()
        );
    }

    /**
    * @description Returns list of contacts by first email and access status
    *
    * @param emails Set<String> set of emails
    * @param status Set<String> set of status
    * @return list of selected contacts
    */
    public List<Contact> selectByEmailAccessStatus(
        Set<String> emails,
        Set<String> status
    ) {
        return (List<Contact>) Database.query(
                newQueryFactory()
                .setCondition(
                    '(Email IN: emails AND OSB_Community_Access_Status__c IN: status )'
                )
                .toSOQL()
        );
    }

    /**
    * @description Returns contacts with PingId not equal to null by name and email
    *
    * @param names Set<String> set of names
    * @param emails Set<String> set of emails
	*
    * @return list of selected contacs
    */
    public List<Contact> selectByNameEmailPingId(
        Set<String> names,
        Set<String> emails
    ) {
        return (List<Contact>) Database.query(
                newQueryFactory()
                .setCondition(
                    'Name IN: names AND Email IN: emails AND Ping_Id__c !=null '
                )
                .toSOQL()
        );
    }

    /**
    * @description Returns contacts with PingId or email
    *
    * @param pingIds set of names
    * @param emails set of emails
	 *
    * @return list of selected contacs
    */
    public List<Contact> selectByEmailOrPingId(
        Set<String> pingIds,
        Set<String> emails
    ) {
        return (List<Contact>) Database.query(
                newQueryFactory()
                        .selectField('EAP_Community_Access_Status__c')
                        .setCondition('Email IN: emails OR Ping_Id__c IN: pingIds ')
                .toSOQL()
        );
    }

    /**
    * @description Select contacts with Company_Industry not equal to null by related user id
    *
    * @param ids Set<Id> set of related user's ids
	 *
    * @return list of contacts
    */
    public List<Contact> selectByIndustryUserId(Set<Id> ids) {
        return Database.query(
            newQueryFactory(false, false, true)
                .setCondition(
                    'Id IN (SELECT ContactId FROM User WHERE Id IN :ids) AND Company_Industry__c !=null'
                )
                    .toSOQL()
                    );
    }

    /**
    * @description Select contact with Business_Interests__c and Interests__c by related user id
    *
    * @param ids related user's id
	*
    * @return Contact
    */
	public Contact selectByIdWithInterests(Id ids)
	{
        return Database.query(
            newQueryFactory(false, false, true)
                    .selectField('Business_Interests__c')
                    .selectField('Interests__c')
                    .setCondition('Id =: ids')
                    .toSOQL()
                    );
    }

    /**
     * @description Calls method selectById in without sharing context,
     * 'WoSharing' stands for 'Without Sharing'
     *
     * @param ids set of contact ids
     *
     * @return list of contacts
     */
    public List<Contact> selectByIdWoSharing(Set<Id> ids) {
        return new WithoutSharing().selectById(this, ids);
    }

    /**
	 * @description Calls method selectById in without sharing context,
	 * 'WoSharing' stands for 'Without Sharing'
	 *
	 * @param externalIds set of contact externalIds
	 *
	 * @return list of contacts
	 */
	public List<Contact> selectByExternalIdentifiersWoSharing(Set<String> externalIds)
	{
		return new WithoutSharing().selectByExternalIdentifiers(this, externalIds);
	}

	/**
     * @description Calls method selectContactByIdentityNumber in without sharing context,
     * 'WoSharing' stands for 'Without Sharing'
     *
     * @param identityNumbers set of identity numbers
     *
     * @return list of contacts
     */
    public List<Contact> selectByIdentityNumberWoSharing(
        Set<String> identityNumbers
    ) {
        return new WithoutSharing()
            .selectByIdentityNumber(this, identityNumbers);
    }

    /**
     * @description Calls method selectContactByUserId in without sharing context,
     * 'WoSharing' stands for 'Without Sharing'
     *
     * @param ids set of user ids to filter out contact
     *
     * @return list of contacts
     */
    public List<Contact> selectByUserIdWoSharing(Set<Id> ids) {
        return new WithoutSharing().selectContactByUserId(this, ids);
    }

    /**
     * @description Calls method selectContactwithIndustryByUserId in without sharing context,
     * 'WoSharing' stands for 'Without Sharing'
     *
     * @param ids set of user ids to filter out contact
     *
     * @return list of contacts
     */
    public List<Contact> selectByIndustryUserIdWoSharing(Set<Id> ids) {
        return new WithoutSharing().selectByIndustryUserId(this, ids);
    }

    /**
     * @description Calls method selectContactByNameEmailPingId in without sharing context
	 *
     * @param names set of contact's names
     * @param emails set of contact's emails
     *
     * @return list of contacts
     */
    public List<Contact> selectByNameEmailPingIdWoSharing(
        Set<String> names,
        Set<String> emails
    ) {
        return new WithoutSharing()
            .selectContactByNameEmailPingId(this, names, emails);
    }        

   
    /**
    * @description check if exists a SF's user with the validation code sended it
    *
    * @param code code sended by the user
    * @return Contact
    */
    public Contact[] selectByValidationCode(String code) {
        return Database.query(
            newQueryFactory(false, false, true)
                    .selectField('Id')
                    .selectField('Name')
                    .selectField('Email')
                    .selectField('EAP_FederationID__c')
                    .selectField('EAP_Validationcode__c')
                    .selectField('AccountId')
                    .selectField('account.owner.UserRoleId')
                    .selectField('account.owner.Id')
                    .setCondition('EAP_Validationcode__c =: code')
                    .toSOQL()
                    );
        
    }

	/**
    * @description check if exists a SF's user with the validation code sended it
    *
    * @param id id sended by the user
    * @return Contact
    */
    public Contact[] selectByIdWithOutForce(String id) {
        return Database.query(
            newQueryFactory(false, false, true)
                    .selectField('Id')
                    .selectField('Name')
                    .selectField('Email')
                    .selectField('EAP_FederationID__c')
                    .selectField('EAP_Validationcode__c')
                    .selectField('AccountId')
                    .selectField('account.owner.UserRoleId')
                    .selectField('account.owner.Id')
                    .setCondition('Id =: id')
                    .toSOQL()
                    );
        
       
    }
    /**
     * @description Is used for omitting sharing setting, when needed
     */
    private without sharing class WithoutSharing {
        /**
        * @description Returns list of contacts by id without sharing
        *
        * @param selContact SEL_Contacts Contact selector instance
        * @param ids Set<Id> set of ids
		*
        * @return list of selected contacts
        */
        public List<Contact> selectById(SEL_Contacts selContact, Set<Id> ids) {
            return selContact.selectById(ids);
        }

        /**
        * @description Returns list of contacts by external identifiers without sharing
        *
        * @param selContact SEL_Contacts Contact selector instance
        * @param externalIds Set<String> set of external Ids
		*
        * @return list of selected contacts
        */
		public List<Contact> selectByExternalIdentifiers(SEL_Contacts selContact, Set<String> externalIds)
		{
			return selContact.selectByExternalIdentifiers(externalIds);
		}
        /**
        * @description Returns list of contacts by custom identity number without sharing
        *
        * @param selContact SEL_Contacts Contact selector instance
        * @param identityNumbers Set<String> set of custom identity numbers
		*
        * @return list of selected contacts
        */
        public List<Contact> selectByIdentityNumber(
            SEL_Contacts selContact,
            Set<String> identityNumbers
        ) {
            return selContact.selectByIdentityNumber(identityNumbers);
        }

        /**
        * @description Returns list of contacts by related User's Id without sharing
        *
        * @param selContact SEL_Contacts Contact selector instance
        * @param ids Set<Id> set of related user's ids
		*
        * @return list of selected contacts
        */
        public List<Contact> selectContactByUserId(
            SEL_Contacts selContact,
            Set<Id> ids
        ) {
            return selContact.selectByUserId(ids);
        }

        /**
        * @description Returns list of contacts by id without sharing, with Company_Industry filed not equal to null
        *
        * @param selContact SEL_Contacts Contact selector instance
        * @param ids Set<Id> set of related user's ids
		*
        * @return list of selected contacts
        */
        public List<Contact> selectByIndustryUserId(
            SEL_Contacts selContact,
            Set<Id> ids
        ) {
            return selContact.selectByIndustryUserId(ids);
        }

        /**
        * @description Returns list of contacts by email and name without sharing, with Ping_Id field not equal to null
        *
        * @param selContact SEL_Contacts Contact selector instance
        * @param names Set<String> set of names
        * @param emails Set<String> set of emails
		*
        * @return list of selected contacts
        */
        public List<Contact> selectContactByNameEmailPingId(
            SEL_Contacts selContact,
            Set<String> names,
            Set<String> emails
        ) {
            return selContact.selectByNameEmailPingId(names, emails);
        }
    }
    /**
    * @description Select contact for Contact flow for handling consents 
    *
    * @param ids ids
	*
    * @return Contact
    */
    public Contact[] selectByIdforConsentFlow(Id[] ids)
    {
        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('IndividualId')
            .selectField('HasOptedOutOfEmail')
            .selectField('Id')
            .selectField('AccountId')
            .selectField('Account.Primary_Relationship_Holder__c')
            .selectField('FirstName')
            .selectField('LastName')
            .selectField('Name')            
            .setCondition('Id =: ids')
            .toSOQL()
        );
    }


       /**
    * @description returns KYC contact list, by id of related account
    *
    * @param clientAccount
    * @param pricing
	* @param groupPricing
    * @return List<Contact> list of selected contacts
    */
    public List<Contact> selectContactByContactRole(Id clientAccount) {
        return (List<Contact>) Database.query(
            newQueryFactory()
                .selectField('Id')
                .selectField('AccountId')
                .selectField('Account.Name')
                .selectField('Title')
                .selectField('Email')
                .selectField('Contact_Category__c')
                .selectField('Contact_Role_s_at_Client__c')
                .selectField('Name')
                .setCondition(
                    'Contact_Role_s_at_Client__c includes (\'Pricing Contact\',\'Group Pricing Contact\') and  AccountId =:clientAccount and Inactive__c = false'
                )
                .toSOQL()
        );
    }

    /**
    * @description returns KYC contact list, by id of related account
    *
    * @param clientAccount
	* @param pricing
    * @param groupPricing
	* @param checkedMail
    * @return Contact list of selected contacts
    */
    public Contact selectContactByEmail(Id clientAccount,String checkedMail) {
        return (Contact) Database.query(
            newQueryFactory()
                .selectField('Id')
                .selectField('AccountId')
                .selectField('Account.Name')
                .selectField('Title')
                .selectField('Email')
                .selectField('Contact_Category__c')
                .selectField('Contact_Role_s_at_Client__c')
                .selectField('Name')
                .setCondition(
                    'Contact_Role_s_at_Client__c includes (\'Pricing Contact\',\'Group Pricing Contact\') and  AccountId =:clientAccount and Email =:checkedMail'
                )
                .toSOQL()
        );
    }
}