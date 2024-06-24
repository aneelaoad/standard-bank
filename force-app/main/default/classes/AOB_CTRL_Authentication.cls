/**
 * @description Class is used to update the verification status of the Related Party.
 *
 * @see AOB_CTRL_Authentication_Test
 *
 * @author Nakedi Mashapa
 *
 * @date 08/03/2023
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   05-19-2023   Tukelo Moseamo   SFP - 25088
 */
public with sharing class AOB_CTRL_Authentication
{
	@TestVisible
	private static final String AUTHENTICATED = 'Authenticated';
	private static final String COMPANY_DIRECTOR_ROLE = 'Company Director';
	private static final String DIRECTOR_ROLE = 'Director';
	private static final String MEMBER_ROLE = 'MEMBER';

	/**
	 * @description this is a method to update where a related party passed of failed authenitication
	 *
	 * @param reference the reference number from the source system
	 * @param status the value of pass or failure of authentication
	 * @param xdsFailureReason the reason for authentication failure
	 * @param applicationId is the application record
	 * @param contactId is the relate party that is being authenticated
	 *
	 * @return Contact a list of the update related contact(s)
	 */
	@AuraEnabled
	public static List<Contact> updateAuthentication(String reference, String status, String xdsFailureReason, String applicationId, String contactId)
	{

		//Insert verification data from frontend
		Verification__c verification = new Verification__c();
		verification.Authentication_Reference__c = reference;
		verification.Authentication_Status__c = status;
		verification.Application__c = applicationId;
		verification.Contact__c = contactId;
		if(status.equalsIgnoreCase(AUTHENTICATED))
		{
			verification.Authenticated__c = AOB_Constants.YES;
		}
		else
		{
			verification.XDS_Failure_Reason__c = xdsFailureReason;
			verification.Authenticated__c = AOB_Constants.NO;
		}

		CMN_DAL_SObjectDomain.insertDBObject(verification);
		return AOB_CTRL_Authentication.getAllContactsByApplicationId(applicationId);
	}
	/**
	 * @description this is a method to retrieve the related party that are linked with Client and has Director role
	 *
	 * @param applicationId is the application record
	 *
	 * @return Contact a list of the update related contact(s)
	 */
	@AuraEnabled(Cacheable=true)
	public static List<Contact> getAllContactsByApplicationId(Id applicationId)
	{
		// return contacts that have not been authenticated
		return getAuthenticatedOrSignedContacts(applicationId, true, false);
	}
	/**
	 * @description this is a method to retrieve the realted party that are linked with Client
	 *
	 * @param applicationId is the application record
	 *
	 * @return Contact a list of the update related contact(s)
	 */
	@AuraEnabled(Cacheable=true)
	public static List<Contact> getAllContactsToSign(Id applicationId)
	{
		// return contacts that have not signed
		return getAuthenticatedOrSignedContacts(applicationId, false, true);
	}
	/**
	 * @description this is a method to retrieve the Client that is linked with Client
	 *
	 * @param applicationId is the application record
	 *
	 * @return Contact
	 */
	@AuraEnabled(Cacheable=true)
	public static Contact getApplicant(Id applicationId)
	{
		List<AOB_Application__c> apps = SEL_AOBApplication.newInstance().selectAppsById(applicationId);
		Map<String, Object> jsonData = (Map<String, Object>)System.JSON.deserializeUntyped(apps[0].AOB_inflightData__c);
		AOB_DTO_StaffAssistedOnboarding.DTO_PreApplication preApplication = (AOB_DTO_StaffAssistedOnboarding.DTO_PreApplication)
				JSON.deserialize(JSON.serialize(jsonData.get(AOB_Constants.PRE_APPLICATION)),
						AOB_DTO_StaffAssistedOnboarding.DTO_PreApplication.class);
		List<Contact> applicantList = new SEL_Contacts().selectByIdentityNumber(new Set<String> {preApplication.IdNum});

		if(!applicantList.isEmpty())
		{
			return applicantList[0];
		}

		return null;
	}

	/**
	 * @description updates signed contracts
	 *
	 * @param applicationId application record Id
	 * @param contactId contact record Id
	 *
	 * @return List<Contact>
	 */
	@AuraEnabled
	public static List<Contact> updateSignedContract(String applicationId, String contactId)
	{
		List<Verification__c> verifications = new SEL_Verification().selectByApplication(new Set<Id> {applicationId});
		if(!verifications.isEmpty())
		{
			for(Verification__c verification : verifications)
			{
				if(verification.Contact__c == contactId)
				{
					verification.AOB_Signed__c = AOB_Constants.YES;
				}
			}
		}
		CMN_DAL_SObjectDomain.updateDBObjects(verifications);
		return getAuthenticatedOrSignedContacts(applicationId, false, true);
	}

	/**
	 * @description Retrieves contacts that have not been authenticated or have not signed an application
	 *
	 * @param applicationId application record Id
	 * @param fetchUnauthenticatedOnly true or false
	 * @param fetchUnsignedOnly true or false
	 *
	 * @return List<Contact>
	 */
	private static List<Contact> getAuthenticatedOrSignedContacts(Id applicationId, Boolean fetchUnauthenticatedOnly, Boolean fetchUnsignedOnly)
	{
		List<AccountContactRelation> relatedParties = new List<AccountContactRelation>();
		// Collect client ids from applications
		List<AOB_Application__c> applications = SEL_AOBApplication.newInstance().selectAppsById(applicationId);
		Set<Id> clientIds = CMN_UTIL_System.extractListIds(applications, AOB_Application__c.AOB_Client__c.getDescribe().name);
		Map<String, Verification__c> verificationMap = new Map<String, Verification__c>();
		List<Verification__c> verifications = new SEL_Verification().selectByApplication(new Set<Id> {applicationId});

		for(Verification__c verification : verifications)
		{
			verificationMap.put(verification.Contact__c, verification);
		}

		String signedOrAuthenticated = CMN_UTIL_String.EMPTY;
		// Query related parties
		if(!clientIds.isEmpty())
		{
			relatedParties = new SEL_AccountContactRelation().selectByClientId(clientIds);
		}
		// Collect contact ids for directors who are not authenticated
		Set<Id> contactIds = new Set<Id>();
		for(AccountContactRelation relatedParty : relatedParties)
		{
			if(fetchUnauthenticatedOnly)
			{
				signedOrAuthenticated = (String)verificationMap?.get(relatedParty.ContactId)?.Authenticated__c;
			}
			if(fetchUnsignedOnly)
			{
				signedOrAuthenticated = verificationMap?.get(relatedParty.ContactId)?.AOB_Signed__c;
			}
			if((relatedParty.Roles?.containsIgnoreCase(DIRECTOR_ROLE) || relatedParty.Roles?.containsIgnoreCase(COMPANY_DIRECTOR_ROLE)
					|| relatedParty.Roles?.containsIgnoreCase(MEMBER_ROLE)) && signedOrAuthenticated != AOB_Constants.YES)
			{
				contactIds.add(relatedParty.ContactId);
			}
		}
		// return contacts for the collected contact ids
		return SEL_Contacts.newInstance().selectById(contactIds);
	}
	@AuraEnabled(Cacheable=true)
	public static List<DTO_Contact> getShareholderStatus(Id applicationId)
	{
		Contact shareholderContact = AOB_CTRL_Authentication.getApplicant(applicationId);
		List<Contact> allContacts = AOB_CTRL_Authentication.getAllContactsToSign(applicationId);
		String mainShareholderId = shareholderContact.Id;

		List<DTO_Contact> updatedContacts = new List<DTO_Contact>();

		for(Contact cont : allContacts)
		{
			DTO_Contact updatedContact = new DTO_Contact();

			updatedContact.Id = cont.Id;
			updatedContact.Name = cont.Name;
			updatedContact.Phone = cont.Phone;
			updatedContact.Email = cont.Email;
			updatedContact.IdNumber = cont.Identity_Number__c;

			if(cont.Id == mainShareholderId)
			{
				updatedContact.Shareholder = AOB_Constants.YES;
			}
			else
			{
				updatedContact.Shareholder = AOB_Constants.NO;
			}

			updatedContacts.add(updatedContact);
		}

		return updatedContacts;
	}

	/**
	 * @description Contact DTO
	 */
	public class DTO_Contact
	{
		@AuraEnabled
		public String Id { get; set; }
		@AuraEnabled
		public String Name { get; set; }
		@AuraEnabled
		public String Phone { get; set; }
		@AuraEnabled
		public String Email { get; set; }
		@AuraEnabled
		public String IdNumber { get; set; }
		@AuraEnabled
		public String Shareholder { get; set; }
	}
}