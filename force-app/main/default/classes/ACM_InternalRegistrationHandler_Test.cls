/**
  @description It will test the ACM_InternalRegistrationHandler class 
  @className ACM_InternalRegistrationHandler_Test  
  @Author - Purna Unnagiri
  @email 	purna.unnagiri@standardbank.co.za
  @company  Standardbank    
  @date  July 14, 2022
**/ 
@isTest
public class ACM_InternalRegistrationHandler_Test {
    
    /**
     * @description Positive test for canCreateUser where all the required information is provided
    **/
	@isTest
    public static void testCanCreateUser() {
        ACM_InternalRegistrationHandler handler = new ACM_InternalRegistrationHandler();
        Auth.UserData data = createUser('purna.unnagiri@example.com','Unnagiri','Purna');
        
        System.Assert(handler.canCreateUser(data),'Handler should be able to create this user');
    }
    
    /**
     * @description Negative test for canCreateUser because insufficient detail is available
    **/
	@isTest     
    public static void testCanCreateUserNegative() {
        ACM_InternalRegistrationHandler handler = new ACM_InternalRegistrationHandler();
        Auth.UserData data = createUser(null,'Unnagiri','Purna');
        
        System.Assert(!handler.canCreateUser(data),'Handler should not be able to create user with missing email');
    }
    
    /**
     * @description Simple direct test of the UpdateUser method.  Create the user first 
     * and then attempt to update some properties.
    **/
	@isTest
    public static void testUpdateUser() {
        ACM_InternalRegistrationHandler handler = new ACM_InternalRegistrationHandler();
        
        Auth.UserData data = createUser('tjones@example.com','Thomas','Jones-Drew');
		
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		User theUser = new User(Email=data.email, LastName=data.lastName, firstName=data.firstName,
						 Alias = 'newUser', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',
						LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='Europe/London', 
						UserName='newuser'+Datetime.now().getTime()+ '@testorg.com', 
						city='Johannesburg', State='Gauteng', Country='South Africa', User_CIB_Global_Area__c='CIBSA',
                        User_Division__c='Business Enablers', Business_Unit__c='CRM');
		insert theUser;		
        Test.startTest();        
			validate(theUser,data);
			handler.updateUser(theUser.id, null, data);
			System.Assert(theUser.Id !=null, 'User id must be set for user update');	
		Test.stopTest();
    }
	
    /**
     * @description Trying to create user but username already exists.
    **/
	@isTest
    public static void testCreateInternalUserButUserNameAlreadyExists() {
        ACM_InternalRegistrationHandler handler = new ACM_InternalRegistrationHandler();
        
        Auth.UserData data = createUser('tjones@example.com','Thomas','Jones-Drew');
		
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		User theUser = new User(Email=data.email, LastName=data.lastName, firstName=data.firstName,
						Alias = 'newUser', EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',
						LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='Europe/London', 
						UserName=data.email+'.'+Label.ACM_InternalUserNameExtension, 
						city='Johannesburg', State='Gauteng', Country='South Africa', User_CIB_Global_Area__c='CIBSA',
                        User_Division__c='Business Enablers', Business_Unit__c='CRM');
		insert theUser;		
        Test.startTest();
			String theCommunityId = '00000001';
			data.attributeMap.put('sfdc_networkid',theCommunityId);
			
			User newUser = handler.createUser(null, data);			 
		Test.stopTest();
		System.Assert(newUser !=null,'User must not be null because user already there');
    }	
    
    /**
     * @description Simple scenario to create a Internal Community user
    **/
	@isTest
    public static void testCreateInternalCommunityUser() {
        ACM_InternalRegistrationHandler handler = new ACM_InternalRegistrationHandler();
        
        Auth.UserData data = createUser('tjones@example.com','Thomas','Jones-Drew');
		
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		Account acc = new Account(Name=Label.ACM_InternalMarketplaceAccount);
		insert acc;		
		
		string bankContactRecordType = Label.ACM_BankContactRecordType;
		Id recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get(bankContactRecordType).getRecordTypeId();
		Contact con = new Contact();
		con.accountId = acc.Id;
		con.recordtypeId = recordTypeId;
		con.firstName = data.firstName;
		con.lastName = data.lastName;
		con.email = data.email;		
		insert con;
        
        Test.startTest();
        String theCommunityId = '00000001';
        data.attributeMap.put('sfdc_networkid',theCommunityId);
        
        User theUser = handler.createUser(null, data);
        
        Test.stopTest();
        
        validate(theUser,data);
        
        // Additional validations for Community User
        System.Assert(theUser.ContactId !=null, 'Contact must be set for user');        
    }	
	
    /**
     * @description Simple scenario to create a Internal Community user without account
    **/
	@isTest
    public static void testCreateInternalCommunityUserWithoutAccount() {
        ACM_InternalRegistrationHandler handler = new ACM_InternalRegistrationHandler();        
        Auth.UserData data = createUser('tjones@example.com','Thomas','Jones-Drew');
        
        Test.startTest();
        String theCommunityId = '00000001';
        data.attributeMap.put('sfdc_networkid',theCommunityId);
        
        User theUser = handler.createUser(null, data);
        
        Test.stopTest();
        
        validate(theUser,data);
        
        // Additional validations for Community User
        System.Assert(theUser.ContactId !=null, 'Contact must be set for user');        
    }
    
    /**
     * @description Scenario where we don't have enough detail to create a User end-to-end
    **/
	@isTest
    public static void testCreateInternalCommunityUserNegative() {
        ACM_InternalRegistrationHandler handler = new ACM_InternalRegistrationHandler();
        
        Auth.UserData data = createUser(null,'Thomas','Jones-Drew');
                
        Test.startTest();
        
        User theUser = handler.createUser(null, data);
        
        Test.stopTest();
        
        System.Assert(theUser==null,'User should be null for negative case');
        
    }	
    
    /**
     * @description Helper method to Validate the the User we've created
     * 
     * @param theUser - the User that we created
     * @param data - the original AuthData supplied by Azure AD
    **/ 
    private static void validate(User theUser, Auth.UserData data) {
        System.Assert(theUser !=null,'User must not be null');
        System.AssertEquals(theUser.email, data.email, 'Email address must be the same');
        System.AssertEquals(theUser.FirstName, data.FirstName, 'First name must match');
        System.AssertEquals(theUser.LastName, data.LastName, 'Last name must match');
    }
    
    /**
     * @description Helper method to instantiate the handler UserData
     * 
     * @param email
     * @param lastName
     * @param firstName
     * @return Auth.UserData that looks like what we expect from Azure AD
     **/ 
    private static Auth.UserData createUser(String email,String lastName, String firstName) {
         Map<String, String> attributeMap = new Map<String,String>();
         String identifier = lastName+System.currentTimeMillis();
         String locale = 'en_US';
         return new Auth.UserData( identifier,
               firstName,
               lastName,
              '', // fullname
               email,
               '', // link
               '', // userName
               locale,
               '', // provider
               '', // siteLoginUrl
               attributeMap);
    }
}