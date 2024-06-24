/**
  @description It will create/update the Internal API Marketplace member Member 
  @className ACM_InternalRegistrationHandler  
  @Author - Purna Unnagiri
  @email 	purna.unnagiri@standardbank.co.za
  @company  Standardbank    
  @date  July 14, 2022
**/

public with sharing class ACM_InternalRegistrationHandler implements Auth.RegistrationHandler{
    
    static final string DEFAULT_INTERNAL_MARKETPLACE_ACCOUNT_NAME = Label.ACM_InternalMarketplaceAccount;
    static final string COMMUNITY_PROFILE_NAME = Label.ACM_InternalMarketplaceProfile;
	static final string COMMUNITY_PERMISSION_SET_LABEL = Label.ACM_InternalMarketplacePermissionSet;
	static final string BANK_CONTACT_RECORDTYPE = Label.ACM_BankContactRecordType;
	static final string USERNAME_EXTENSION = Label.ACM_InternalUserNameExtension;
	
    
    /**
	 * @description - Check whether we want to allow creation of a user or not
     * @param data  - Azure AD Auth Provider provided context for this User
	 * @return boolean - True or false based on Auth UserData
    **/	
	public boolean canCreateUser(Auth.UserData data) {		
		Boolean isUserDataValid = (data != null && data.email != null && data.lastName != null && data.firstName != null);        
		if(isUserDataValid){
			return true;
		}
		else{
			return false;
		}
    }
	
	/**
	 * @description It will assign permissionSet to users
	 * @param usersIds  - Set of the user ids
	 * @param permissionSetLabel  - Label of the permissionSet
	**/ 
	static void assignPermissionSetToUsers(Set<Id> usersIds, string permissionSetLabel) {
		If(usersIds.size()>0){
			List<User> usersList = [Select Id, Name, isActive FROM User WHERE Id IN :usersIds and isActive = true];
								
			if(usersList.size()>0){
				
				List<PermissionSet> permSet = [SELECT Id, Label, Name FROM PermissionSet where Label =:permissionSetLabel];
				
				if(permSet.size()>0){								
				
					List<PermissionSetAssignment> permissionSetAssign = [SELECT Id, PermissionSetId, PermissionSet.Name, 
												AssigneeId, Assignee.Name FROM PermissionSetAssignment 
												WHERE PermissionSet.Label =:permissionSetLabel AND AssigneeId IN :usersIds];
												
					if(permissionSetAssign.size() == 0){
						
						List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
						
						for (User u : usersList){
							
							PermissionSetAssignment psa = new PermissionSetAssignment();
							psa.PermissionSetId = permSet[0].Id;
							psa.AssigneeId = u.Id;		
							permissionSetList.add(psa);
							
						}
						if(permissionSetList.size()>0){
							insert permissionSetList;
						}
					}
				}
			}
		}
	}	
    	
    /**
     * @description - Create and initialize the User but don't save it yet
     * @param data - the provided User context from FaceBook
     * @param contactId - the contactId we are going to assign to this user
     * @return User that has been initialized but not Saved
    **/
    private User prepareUserData(Auth.UserData data, Id contactId){		
        String username;
		String alias;
		
		// Get the Profile Id
		Profile p = [SELECT Id FROM profile WHERE name=:COMMUNITY_PROFILE_NAME];		
		
		User u = new User();      
	
        alias = data.firstName + data.lastName;
		
        //Alias must be 8 characters or less
        if(alias.length() > 8){
            alias = alias.substring(0, 8);
		}
        u.username = data.email + '.' + USERNAME_EXTENSION;
        u.email = data.email;
        u.lastName = data.lastName;
        u.firstName = data.firstName;
        u.alias = alias;
        u.languagelocalekey = UserInfo.getLanguage();
        u.localesidkey = UserInfo.getLocale();
        u.emailEncodingKey = 'ISO-8859-1';
        u.timeZoneSidKey = 'Europe/London';
		u.profileId = p.Id;
		u.contactId = contactId;
		return u;		
    }
	
    /**
	 * @description  Create a contact
     * @param data - Azure AD provided context for this User
	 * @param data - Azure AD provided context for this Use
	 * @return Id - Contact id or null
    **/ 
    private List<Id> createContactUnderInternalMarketplaceAccount(Auth.UserData data) {
		List<Id> contactIds = New List<Id>();
		Account a;
		List<Account> accounts = [SELECT Id FROM account WHERE name=:DEFAULT_INTERNAL_MARKETPLACE_ACCOUNT_NAME];
		if(accounts.isEmpty()){
		   a = new Account(name = DEFAULT_INTERNAL_MARKETPLACE_ACCOUNT_NAME);
		   insert(a);
		}else{
		   a = accounts[0];
		}
	   
	    Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(BANK_CONTACT_RECORDTYPE).getRecordTypeId();											
		List<Contact> contactList = [Select id from contact where accountId !=null and email =:data.email];  
		If(contactList.size() == 0){ 
			Contact c = new Contact();
			c.accountId = a.Id;
			c.firstName = data.firstName;
			c.lastName  = data.lastName;
			c.email = data.email;
			c.recordTypeId = recordTypeId;
			insert c;
			contactIds.add(c.Id);
		}else{
			Set<Id> contactsIds = new Set<Id>(); 
			for(Contact con: contactList){
				contactsIds.add(con.Id);
			}
			contactIds.addAll(contactsIds);
		}
		return contactIds;
    }	
    
	/**
	 * @description Create the User - A required method to implement the Handler Interface
	 * @param portalId  - Id of the Community
	 * @param data - Auth Provider user data describing the User to create
	 * @return User that has been initialized
	**/ 
    public User createUser(Id portalId, Auth.UserData data){
		
        if(canCreateUser(data) && data.attributeMap.containsKey('sfdc_networkid')) {
			
			String userName = data.email + '.' + USERNAME_EXTENSION;
			
			List<User> userList = [Select id,username,email,isActive from user where username =:userName and isActive =true];  
			if(userList.size() == 0){
				// To keep things modular, we're creating the contact in a separate method
				List<Id> contactIds = createContactUnderInternalMarketplaceAccount(data);
				if(contactIds.size()>0){
					List<User> exisingUser = [Select Id, Name, isActive FROM User WHERE contactId IN :contactIds and isActive =true ];
					if(exisingUser.size() > 0){
						updateUser(exisingUser[0].Id, null, data);
						return exisingUser[0];
					}else{
						// Keeping it modular, we initialize the user in another method		   
						User u = prepareUserData(data, contactIds[0]);
						return u;					
					}					
				}else{
					//Returning null or throwing an exception fails the SSO flow
					return null;
				}
			}else{
				updateUser(userList[0].ID, null, data);
				return userList[0];
			}
		}else{
			//Returning null or throwing an exception fails the SSO flow
			return null;
		}		
    }
    
	/**
	 * @description Update the user record and assign permission set to user
	 * @param userId  - Id of the user
	 * @param portalId  - Id of the Community
	 * @param data - Auth Provider user data describing the User to create
	**/ 
    public void updateUser(Id userId, Id portalId, Auth.UserData data){
        if(userId !=null){
            Set<Id> userIds = new Set<Id>();
            userIds.add(userId);
            if(userIds.size()>0){
                assignPermissionSetToUsers(userIds, COMMUNITY_PERMISSION_SET_LABEL);
            }
        }
    }
}