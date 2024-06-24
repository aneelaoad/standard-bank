/**
* @description Used to create Data, mostly for unit tests
* 
* <p></p>  
*  
* @author Salesforce
* 
* @date Oct 17th 2021
* Modifications Log
* Ver   Date         Author           Modification
* 1.0   05-19-2023   Tukelo Moseamo   SFP - 25088
*/
@isTest

@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class AOB_DAL_TestFactory {
    /**
* @description This method is use to create a community user
* @return User A user that Is/not inserted
*/
    public static User createCommunityUser( )
	{
		UserRole userrole =
		[
				SELECT Id,
						DeveloperName
				FROM UserRole
				WHERE DeveloperName = 'Business_Banking_SA'
				LIMIT 1
		];
    	User adminUser = (User)new BLD_USER()
		.userName(AOB_Constants.PBB_USER_NAME+'.aobTest')
		.role(userrole.Id)
		.useSysAdmin()
		.syncContact()
		.getRecord();
		User user;
		System.runAs(adminUser)
		{
			String externalUserProfile = 'AOB_Authenticated Customer Community Plus Login';
			//get Profile
			Profile profile =
			[
					SELECT Id
					FROM Profile
					WHERE Name = :externalUserProfile
			];
			//Insert User
			String uniqueName = getUniqueName();

			String accountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
			Account account = new Account(Name = 'TestACC', RecordTypeId = accountRT);
			insert account;

			Contact contact = new Contact(LastName = 'test',
					Email = uniqueName + '@test.org',
					FirstName = 'testFirstName',
					AccountId = account.Id
			);
			insert contact;
			user = new User(LastName = 'test',
					Email = uniqueName + '@test.org',
					Username = uniqueName + '@test.org',
					ProfileId = profile.Id,
					EmailEncodingKey = 'ISO-8859-1',
					Alias = uniqueName.substring(18, 23),
					TimeZoneSidKey = 'America/Los_Angeles',
					LocaleSidKey = 'en_US',
					LanguageLocaleKey = 'en_US',
					UserPermissionsKnowledgeUser = true,
					ContactId = contact.Id,
					User_Division__c = 'Digital',
					Business_Unit__c = 'Bank Sector',
					User_CIB_Global_Area__c = 'CIBSA',
					Country = 'ZA',
					City = 'city',
					State = 'state',
					PostalCode = 'state',
					FederationIdentifier = 'FederationIdentifier' + uniqueName
			);

			insert user;
		}

		return user;
	}
    
    
    /**
    * @description creates ping user
    * @return User 
    **/
    public static User createCommunityUserPing()
	{
		UserRole userrole =
		[
				SELECT Id,
						DeveloperName
				FROM UserRole
				WHERE DeveloperName = 'Business_Banking_SA'
				LIMIT 1
		];
		User adminUser =
		[
				SELECT Id,
						UserRoleId
				FROM User
				WHERE Id = :UserInfo.getUserId()
				LIMIT 1
		];

		if(String.isBlank(adminUser.UserRoleId))
		{
			adminUser.UserRoleId = userrole.Id;
			update adminUser;
		}

		User user;
		System.runAs(adminUser)
		{
			String externalUserProfile = 'AOB_Authenticated Customer Community Plus Login';
			Profile profile =
			[
					SELECT Id
					FROM Profile
					WHERE Name = :externalUserProfile
			];
			String uniqueName = getUniqueName();

			String accountRT = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Personal_Business_Banking_Client').getRecordTypeId();
			String contactRT = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('SA_Client_Contact_Record_Type').getRecordTypeId();
			Account account = new Account(Name = AOB_Constants.AOB_DUMMY_NAME, RecordTypeId = accountRT);
			insert account;

			Contact contact = new Contact(LastName = 'test',
					Email = uniqueName + '@test.org',
					FirstName = AOB_Constants.AOB_DUMMY_NAME,
					AccountId = account.Id,
					RecordTypeId = contactRT
			);
			insert contact;
			user = new User(LastName = 'test',
					Email = uniqueName + '@test.org',
					Username = uniqueName + '@test.org',
					ProfileId = profile.Id,
					EmailEncodingKey = 'ISO-8859-1',
					Alias = uniqueName.substring(18, 23),
					TimeZoneSidKey = 'America/Los_Angeles',
					LocaleSidKey = 'en_US',
					LanguageLocaleKey = 'en_US',
					UserPermissionsKnowledgeUser = true,
					ContactId = contact.Id,
					User_Division__c = 'Digital',
					Business_Unit__c = 'Bank Sector',
					User_CIB_Global_Area__c = 'CIBSA',
					Country = 'ZA',
					City = 'city',
					State = 'state',
					PostalCode = 'state',
					FederationIdentifier = 'FederationIdentifier' + uniqueName
			);

			insert user;
		}

		List<PermissionSet> permissionSetList =
		[
				SELECT Id
				FROM PermissionSet
				WHERE Name = 'AOB_AuthenticatedCommunityCustomers'
		];
		PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = permissionSetList[0].Id);
		insert psa;
		return user;
	}
    /**
*@description Get the unique name to be user for Email, Username of the created user
* @return A unique Name
*/
    public static string getUniqueName(){
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        
        return uniqueName;
    }
    
/**
* @description This method is used to create a new application (without params)
* @return AOB_Application__c
*/
    public static AOB_Application__c createApplication() {
        User communityUser = [
            SELECT id, contactId
            FROM User
            WHERE id = :UserInfo.getUserId()
        ];
        Account acc = [
            SELECT id
            FROM account
            WHERE
            id IN (
                SELECT accountId
                FROM contact
                WHERE id = :communityUser.contactId
            )
        ];
        AOB_Application__c newApplication = new AOB_Application__c();
        newApplication.AOB_Client__c  = acc.id;
        newApplication.AOB_ExpiryDate__c = system.today().addDays(7);
        newApplication.AOB_inflightData__c=null;
        newApplication.AOB_Status__c = 'In Progress';
        newApplication.Name ='MyMobiz';
        insert newApplication;
        return newApplication;
    }
    
    /**
* @description This method is used to create a new application (without params)
* @return AOB_Application__c
* @param userId
*/
    public static AOB_Application__c createApplication(User userId) {
        User communityUser = [
            SELECT id, contactId
            FROM User
            WHERE id = :userId.Id
        ];
        Account acc = [
            SELECT id
            FROM account
            WHERE
            id IN (
                SELECT accountId
                FROM contact
                WHERE id = :communityUser.contactId
            )
        ];
        AOB_Application__c newApplication = new AOB_Application__c();
        newApplication.AOB_Client__c  = acc.id;
        newApplication.AOB_inflightData__c=null;
        newApplication.AOB_ExpiryDate__c = system.today().addDays(7);
        newApplication.AOB_Status__c = 'New';
        insert newApplication;
        return newApplication;
    }

    /**
    * @description create line item
    * @param userId  
    * @return AOB_Application__c 
    **/
    public static AOB_Application__c createApplicationWithLineItems(User userId) {
        User communityUser = [
            SELECT id, contactId
            FROM User
            WHERE id = :userId.Id
        ];
        Account acc = [
            SELECT id
            FROM account
            WHERE
            id IN (
                SELECT accountId
                FROM contact
                WHERE id = :communityUser.contactId
            )
        ];
        AOB_Application__c newApplication = new AOB_Application__c();
        newApplication.AOB_Client__c  = acc.id;
        newApplication.AOB_inflightData__c=null;
        newApplication.AOB_ExpiryDate__c = system.today().addDays(7);
        newApplication.AOB_Status__c = 'New';
        insert newApplication;
        Product2 prod=new Product2();
        prod.Name='MyMobiz';
        prod.ProductCode='4648';
        insert prod;
        // Insert Application Line Item
        AOB_ApplicationLineItem__c appLineItem = new AOB_ApplicationLineItem__c();
        appLineItem.AOB_Application__c =newApplication.Id;
        appLineItem.AOB_Product__c =prod.Id;
        appLineItem.AOB_Main__c = TRUE;
        appLineItem.Name = prod.Name;
        insert appLineItem;
        return newApplication;
    }     
    
    /**
    * @description This method is used to create a new product
    * @param name
    * @param productCode
    * @return Product2
    */
    public static Product2 createProduct(String name, String productCode) {
        Product2 newProduct = new Product2(Name = name);
        newProduct.ProductCode = productCode;
        newProduct.ExternalId = productCode;
        insert newProduct;
        return newProduct;
    }
    
    /**
   * @description This method is used to create a new AOB_RequiredDocument__c record
   * @param productId
   * @param description
   * @param helpText
   * @param order
   * @return AOB_RequiredDocument__c
   */
  public static AOB_ProductAOContent__c createAOContent( Id productId, String description, String helpText, Integer order) {
    AOB_ProductAOContent__c requiredDocument = new AOB_ProductAOContent__c(
      AOB_Product__c = productId,
      AOB_Description__c = description,
      AOB_HelpText__c = helpText,
      AOB_Sequence__c = order
    );
    insert requiredDocument;
    return requiredDocument;
  }
    /**
    * @description This method is use to get the user with profile
    * @param profileName 
    * @param doInsert
    * @return User A user that Is/not inserted
    */
    public static User createUser (String profileName, Boolean doInsert) {
        User result = new User(
            ProfileId = [
                SELECT  Id
                FROM    Profile
                WHERE   Name = :profileName
                LIMIT 1
            ].Id,
            LastName = 'LastName',
            FirstName='FirstName',
            Email = 'aob@sb.com',
            Username = 'aob@sb.com' + System.currentTimeMillis(),
            CommunityNickname = 'aob' + System.currentTimeMillis(),
            CompanyName = 'aob',
            Title = 'Volunteer',
            Alias = 'aob',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            isActive = true,
            User_Division__c ='Digital',
            Business_Unit__c  ='Bank Sector',
            User_CIB_Global_Area__c   ='CIBSA',
            Country  ='ZA',
            city  ='city',
            state='state',
            postalCode='state'
        );
        
        if (doInsert) {
            insert result; 
        }
        return result;
    }
    
    /**
    * @description This method is used to create a new product
    * @param name
    * @return Product2
    */
    public static Product2 createProduct(String name){
        Product2 newProduct = new Product2(Name = name);
        insert newProduct;
        return newProduct;
    }
    /**
    * @description This method is used to create a new AOB_RequiredDocument__c record
    * @param productId
    * @param description
    * @param helpText
    * @param order
    * @return AOB_RequiredDocument__c
    */
    public static AOB_ProductAOContent__c createAOProductContent(Id productId, String description, String helpText, Integer order){
        AOB_ProductAOContent__c aoContent = new AOB_ProductAOContent__c( AOB_Product__c = productId,
                                                                        AOB_Description__c = description,
                                                                        AOB_HelpText__c = helpText,
                                                                        AOB_sequence__c = order
                                                                       );
        insert aoContent;
        return aoContent;
    }
    
    /**
    * @description This method is used to create a new application line item
    * @param productId
    * @param applicationId
    * @return AOB_ApplicationLineItem__c
    */
    public static AOB_ApplicationLineItem__c createApplicationLineItem(Id productId, Id applicationId){
        AOB_ApplicationLineItem__c newApplicationLineItem = new AOB_ApplicationLineItem__c(AOB_Main__c=true,AOB_Product__c = productId, AOB_Application__c = applicationId);
        insert newApplicationLineItem;
        return newApplicationLineItem;
    }

    /**
    * @description This method is used to create a new secondary (not Main) application line item
    * @param productId
    * @param applicationId
    * @return AOB_ApplicationLineItem__c
    */
    public static AOB_ApplicationLineItem__c createApplicationLineItemSecondary(Id productId, Id applicationId){
        AOB_ApplicationLineItem__c newApplicationLineItem = new AOB_ApplicationLineItem__c(AOB_Main__c=false,AOB_Product__c = productId, AOB_Application__c = applicationId);
        insert newApplicationLineItem;
        return newApplicationLineItem;
    }
    
    /**
    * @description     genericObjectCreation: Created a record of the provided Object with the provided field values  
    * @param objectName
    * @param values
    * @return   True if the Record is created and Error otherwise
    */
    public static sObject genericObjectCreation(string objectName, Map<string,object> values){
        Map<String, Schema.SObjectType> mObjects = Schema.getGlobalDescribe();
        sObject n = mObjects.get(objectName).newSObject();
        for(string fieldName:values.keyset()){
            n.put(fieldName,values.get(fieldName));
        }
        return n;
    }
    
    /**
    * @description creates screen
    * @return list<AOB_FlowScreen__c> 
    **/
    public static list<AOB_FlowScreen__c> createScreen(){
        list<AOB_FlowScreen__c> listScreen = new list<AOB_FlowScreen__c>();
        
        AOB_FlowScreen__c screen = new AOB_FlowScreen__c(name = 'Company details', 
                                                         aob_title__c='Company details', 
                                                         aob_subTitle__c='Enter the following information', 
                                                         AOB_ExternalId__c='1234');
        listScreen.add(screen);
        insert listScreen;
        return listScreen;    
    }  
    
    /**
    * @description creates section
    * @param screenId 
    * @return list<AOB_ScreenSection__c> 
    **/
    public static list<AOB_ScreenSection__c> createSection(id screenId){
        list<AOB_ScreenSection__c> listSection = new list<AOB_ScreenSection__c>();
        
        AOB_ScreenSection__c section = new AOB_ScreenSection__c(AOB_Screen__c=screenId, 
                                                                name='Company contact details', 
                                                                AOB_ExternalId__c='Q1', 	
                                                                AOB_Title__c=' ');
        
        listSection.add(section);
        insert listSection;
        return listSection;    
    }  
    
    /**
    * @description creates field
    * @param sectionId 
    * @return list<AOB_field__c> 
    **/
    public static list<AOB_field__c> createFields(id sectionId){
        list<AOB_field__c> listField = new list<AOB_field__c>{
            							new AOB_field__c(AOB_Section__c=sectionId, 
                                              name='Cellphone Number', 
                                              AOB_ExternalId__c='123', 
                                              AOB_Type__c='Text', 
                                              AOB_sequence__c=1, 
                                              AOB_label__c='Cellphone Number?'),
                                        new AOB_Field__c(AOB_Section__c=sectionId, 
                                              name='cellphone', 
                                              AOB_ExternalId__c='124', 
                                              AOB_Type__c='Radio', 
                                              AOB_sequence__c=2, 
                                              AOB_label__c='Do you have a cellphone?', 	
                                              //AOB_Parent__c=listField[0].id,
                                              AOB_ShowAtScreenLoad__c=true,
                                              AOB_MRITable__c='YESNORADIONotif'),    
            							new AOB_field__c(AOB_Section__c=sectionId, 
                                              name='Email', 
                                              AOB_ExternalId__c='125', 
                                              AOB_Type__c='Email', 
                                              AOB_sequence__c=3, 
                                              AOB_label__c='Email Address'),
            							new AOB_field__c(AOB_Section__c=sectionId, 
                                              name='Check Box', 
                                              AOB_ExternalId__c='126', 
                                              AOB_Type__c='Checkbox', 
                                              AOB_sequence__c=4, 
                                              AOB_label__c='CheckBox'),
            							new AOB_field__c(AOB_Section__c=sectionId, 
                                              name='Currency', 
                                              AOB_ExternalId__c='127', 
                                              AOB_Type__c='Currency', 
                                              AOB_sequence__c=5, 
                                              AOB_label__c='Currency'),
            							new AOB_field__c(AOB_Section__c=sectionId, 
                                              name='Help Text', 
                                              AOB_ExternalId__c='128', 
                                              AOB_Type__c='helpText', 
                                              AOB_sequence__c=6, 
                                              AOB_label__c='Help Text'),
            							new AOB_field__c(AOB_Section__c=sectionId, 
                                              name='Output', 
                                              AOB_ExternalId__c='129', 
                                              AOB_Type__c='Output', 
                                              AOB_sequence__c=7, 
                                              AOB_label__c='Output'),
                                        new AOB_field__c(AOB_Section__c=sectionId, 
                                              name='ComboBox', 
                                              AOB_ExternalId__c='130', 
                                              AOB_Type__c='Combobox', 
                                              AOB_sequence__c=8, 
                                              AOB_label__c='Combobox'),
                                        new AOB_field__c(AOB_Section__c=sectionId, 
                                              name='Tax', 
                                              AOB_ExternalId__c='131', 
                                              AOB_Type__c='Tax', 
                                              AOB_sequence__c=9, 
                                              AOB_label__c='Tax'),
                                        new AOB_field__c(AOB_Section__c=sectionId, 
                                              name='MultiSelectSearch', 
                                              AOB_ExternalId__c='132', 
                                              AOB_Type__c='MultiSelectSearch', 
                                              AOB_sequence__c=10, 
                                              AOB_label__c='MultiSelectSearch'),
                                        new AOB_field__c(AOB_Section__c=sectionId, 
                                              name='Private address', 
                                              AOB_ExternalId__c='133', 
                                              AOB_Type__c='Private address', 
                                              AOB_sequence__c=11, 
                                              AOB_label__c='Private address'),
                                        new AOB_field__c(AOB_Section__c=sectionId, 
                                              name='fuzzy dropdown', 
                                              AOB_ExternalId__c='134', 
                                              AOB_Type__c='fuzzy dropdown', 
                                              AOB_sequence__c=12, 
                                                         AOB_label__c='fuzzy dropdown')};
                			
        insert listField;
        
        AOB_Field__c parent = [select id from AOB_Field__c where AOB_ExternalId__c = '123' limit 1 ];
        AOB_Field__c child = [select id from AOB_Field__c where AOB_ExternalId__c = '124' limit 1 ];
        child.AOB_Parent__c = parent.id;
        update child;
        
        return listField;    
    } 
    
    /**
    * @description creates reference data 
    * @return list<AOB_referencedData__c> 
    **/
    public static list<AOB_referencedData__c> createRefData(){
        list<AOB_referencedData__c> listRefData = new list<AOB_referencedData__c>();
        
        AOB_referencedData__c refData = new AOB_referencedData__c(name='Yes', 
                                                                  AOB_Default__c=true, 
                                                                  AOB_SAPField__c='YESNORADIONotif', 
                                                                  AOB_isActive__c=true, 
                                                                  AOB_Code__c='true', 
                                                                  AOB_Language__c = 'en_US');

        AOB_referencedData__c refData2 = new AOB_referencedData__c(name='No', 
                                                                  AOB_Default__c=true, 
                                                                  AOB_SAPField__c='YESNORADIONotif', 
                                                                  AOB_isActive__c=true, 
                                                                  AOB_Code__c='false', 
                                                                  AOB_Language__c = 'en_US');                                                          
        
        listRefData.add(refData);
        listRefData.add(refData2);
        insert listRefData;
        return listRefData;    
    }  

    /**
    * @description creates application with lead
    * @return string 
    **/
    public static string createLeadWithApplication(){
        Lead leadRec = new Lead(Company = 'Prox',
                      LastName = 'Lead Last Name',
                      Customer_ID__c = '9501126721146');
        insert leadRec;
        // Insert Application
        AOB_Application__c application = new AOB_Application__c();
        application.Name = 'MyMoBiz';
        application.AOB_Status__c = 'In Progress';
        application.AOB_Retry_Count__c=1;
        application.AOB_inflightData__c = '{"PreApplication": { "Name": "SampleName", "Surname": "Ram", "IdNum": "9801120672097", "PhoneNumber": "0612345678", "EmailAddress": "force@ggmail.com","soleOwner": "true","businessType": "SOLE PROPRIETOR", "soleShareholder": "true","businessName": "Business Name","businessTurnover": "200000","businessProvince": "ZAF.EC", "consent": true },"preApplicationResponse":{"businessBPGUID":"d671c60e-fe03-1ed7-a9eb-4cf2ef6d1dec","businessBPID":"0531113757","businessRegisteredName":"MONSTER DOORS","digitalOfferId":"0045379680","inflightCustomerDataId":"0045379680","initiatorBPGUID":"45551ed4-38a9-0164-0000-00000ab6f567","initiatorBPID":"0530845443","initiatorDigitalID":null,"processId":"0045379680"},"Summary":{"itemId":"100","documentCode":"Test Code","documentName":"Contract","documentId":"idd_D0273485-0000-C316-A1CC-C389514C5256"},"Available Bundles":{"ZPOB":false,"ZPSS":false,"4488":false} ,"Company Financial Details":{"ENTITY CLASSIFICATION":"NFI","MoreLessClassif":"true","FOREIGN TAX RESIDENCY":"true","taxCountries":true,"taxInputs":{"firstCountry":"DZ2","firstTaxNumber":"12345678900","secondCountry":"AL1","secondReason":"02"},"undefined":"","BUSINESS FUNDING":"{\"0016\":\"100\",\"0026\":\"100\",\"0027\":\"100\",\"0024\":\"100\",\"0021\":\"100\"}"},"Employment Details":{"taxInputs":{"firstCountry":"AL","firstReason":"1","secondCountry":"AX","secondReason":"3"},"jobTitle":"14","INDUSTRY":"1","Employed":"true","TaxResident":"true","taxCountries":true,"undefined":"1234567890"},"Personal Details":{"Nationality":"AL","citizenship":"AF","PublicOfficial":"false","Related":"true","RelationType":"5","RelationName":"Sample"},"PreApplication":{"consent":true,"businessProvince":"ZAF.EC","businessTurnover":"800000","businessName":"Random Company Name","soleShareholder":"true","businessType":"SOLE PROPRIETOR","soleOwner":"true","EmailAddress":"force@gmail.com","PhoneNumber":"765878260","IdNum":"5601120672097","Surname":"Ram","Name":"SampleName"},"Residential Address":{"Street":"dsfjks","UnitNumber":"hj","Complexe":"jh","suburb":"42ND HILL","city":"ABERDEEN","province":"ZAF.EC","PostalCode":"4567"},"Company Details":{"TELEPHONE  NUMBER (OPTIONAL)":"0612345678","EMAIL ADDRESS":"sample@gmail.com","CELLPHONE":"0612345678","PREFERRED BRANCH":"2750","COUNTRY OF REGISTRATION":"AX","INDUSTRY CLASSIFICATION":"27","NATURE OF THE BUSINESS":"18"},"Company Trading Address":{"PostalCode":"4567","PROVINCE":"ZAF.EC","city":"ABERDEEN","SUBURB":"486 SCHEME","Complex":"df","UnitNumber":"hj","StreetName":"sjhdj","AddressType":"Same"},"Marketing Consent":{"marketPermission":"true","researchContact":"true","otherCompaniesCom":"true"},"Card Selection":{},"Notifications":{"NotifiedMean":"EMAIL","depositInfo":"true"},"ProcessData":[{"parentTaskID":"","processTaskDetail":{"callBackURL":"","correlationID":"b60da24a-9861-c0c8-5b49-19fbc058d3f3","ownerBPID":null,"wfrFailureReason":null,"wfrRetryAllowed":null,"wfrStatus":null},"status":"Closed","taskID":"7704451","taskName":"Capture Application Data"},{"parentTaskID":"","processTaskDetail":{"callBackURL":"","correlationID":"b60da24a-9861-c0c8-5b49-19fbc058d3f3","ownerBPID":null,"wfrFailureReason":null,"wfrRetryAllowed":null,"wfrStatus":null},"status":"Closed","taskID":"7704452","taskName":"Step: Await IDV Callback"}]}';
        application.Lead__c = leadRec.Id;
        insert application;
        // Insert Product
        Product2 prod=new Product2();
        prod.Name='MyMobiz';
        prod.ProductCode='4648';
        insert prod;
        // Insert Application Line Item
        AOB_ApplicationLineItem__c appLineItem = new AOB_ApplicationLineItem__c();
        appLineItem.AOB_Application__c =application.Id;
        appLineItem.AOB_Product__c =prod.Id;
        appLineItem.AOB_Main__c = TRUE;
        appLineItem.Name = prod.Name;
        insert appLineItem;
        return leadRec.Customer_ID__c;

    }

     /**
     * @description creates mymobiz product 
     **/
     public static void createmymobizProduct(){
       
        Product2 prod=new Product2();
        prod.Name='MyMobiz';
        prod.ProductCode='4648';
        insert prod;
    } 

    /**
    * @description creates app with inflightdata
    * @return string 
    **/
    public static string createAppWithInflightKey(){
        AOB_Application__c application = new AOB_Application__c();
        Map<String, String> preAppData = new Map<String, String>();
        String appData2=' {'+
            '      "businessBPGUID":"d671c60e-fe03-1ed7-a9eb-4cf2ef6d1dec",'+
            '      "businessBPID":"0531113757",'+
            '      "businessRegisteredName":"MONSTER DOORS",'+
            '      "digitalOfferId":"0045379680",'+
            '      "inflightCustomerDataId":"0045379680",'+
            '     "initiatorBPGUID":"45551ed4-38a9-0164-0000-00000ab6f567",'+
            '     "initiatorBPID":"0530845443",'+
            '      "initiatorDigitalID":null,'+
            '       "processId":"0045379680",'+
            '}';
        preAppData.put('preApplicationResponse', appData2);
        application.Name = 'MyMoBiz';
        application.AOB_Status__c = 'In Progress';
        application.AOB_inflightData__c = SYSTEM.JSON.serialize(preAppData);
        insert application;
        return application.Id;
    }
    
    /**
    * @description creates app with contract inflight data node
    * @return String 
    **/
    public static String createAppWithContractInflightKey() {
        AOB_Application__c application = new AOB_Application__c();
        Map<String, Object> preAppData = new Map<String, Object>();
        
        Object preApplicationResponse = '{"cipcRegisteredDetails":{"businessDetails":{"businessBPID":'+
            '"0535760494","businessBPGUID":"bdade73d-72f7-1eed-bbfd-0581e3175032","applicationResponseDetails":{"processID":"",'+
            '"processExpiryDate":"2023-05-18","maintenanceOfferID":"0600049650","digitalOfferID":"0045407500"}}}},"ContractDocument"'+
            ':[{"documentId":"c686b66c665f4c0d81243db55e493b04","documentName":"Mandate","documentCode":"MANDT","itemId":"0"}]}';
        
        preAppData.put('preApplicationResponse', preApplicationResponse);
        application.Name = 'MyMoBiz';
        application.AOB_Status__c = 'In Progress';
        application.AOB_inflightData__c = SYSTEM.JSON.serialize(preAppData);
        insert application;
        return application.Id;
    }

    /**
    * @description creates contact and account
    * @return Map<String, String> 
    **/
    public static Map<String,String> createAccountWithContact(){
        Map<String,String> accConIds = new Map<String, String>();
        Account newAccount = new Account(); 
        newAccount.Name = 'Test';
        newAccount.ExternalIdentifier__c = '123';
        Insert newAccount;

        Contact con = new Contact();
        con.LastName = 'TestName';
        con.ExternalIdentifier__c = '12345';
        con.accountId = newAccount.Id;
        Insert con;
        accConIds.put('accountId',newAccount.Id);
        accConIds.put('contactId',con.Id);
        return accConIds;
    }  
    
	/**
	* @description app with new address
	* @return String 
	**/
	public static String createApplicationWithNewAddress()
	{
		Lead lobj = new Lead();
		lobj.FirstName = 'FirstName';
		lobj.LastName = 'LastName';
		lobj.Customer_ID__c = '9801120672097';
		lobj.Company = 'TestCompany';
		insert lobj;
		AOB_Application__c application = new AOB_Application__c();
		String json = '{"Card Selection":{"chequeCardSelected":true,"debitCardSelected":true},"ContractDoucument":[{"documentId":"00EB1186-0000-C117-99FA-762353A112EE", "documentName":"Card application","documentCode":"CARAP","itemId":"400"}],"PreApplication": { "Name": "SampleName", "Surname": "Ram", "IdNum": "9801120672097","businessRegistrationNumber":"2020/679442/07","pricingOption":"ZMMB", "PhoneNumber": "0612345678", "EmailAddress": "force@ggmail.com","soleOwner": "true","businessType": "SOLE PROPRIETOR", "soleShareholder": "true","businessName": "Business Name","businessTurnover": "200000","businessProvince": "ZAF.EC", "consent": true },"preApplicationResponse":{"businessBPGUID":"d671c60e-fe03-1ed7-a9eb-4cf2ef6d1dec","businessBPID":"0531113757","businessRegisteredName":"MONSTER DOORS","digitalOfferId":"0045379680","inflightCustomerDataId":"0045379680","initiatorBPGUID":"45551ed4-38a9-0164-0000-00000ab6f567","initiatorBPID":"0530845443","initiatorDigitalID":null,"processId":"0045379680"},"Summary":{"itemId":"100","documentCode":"Test Code","documentName":"Contract","documentId":"idd_D0273485-0000-C316-A1CC-C389514C5256"},"Available Bundles":{"ZPOB":false,"ZPSS":false,"4488":false},"Company Financial Details":{"taxInputs":{"firstTaxNumber":"1234567890","firstCountry":"AX"},"taxCountries":true,"undefined":"","FOREIGN TAX RESIDENCY":"false","ENTITY CLASSIFICATION":"NFI","MoreLessClassif":"true"},"Employment Details":{"taxInputs":{"firstCountry":"AL","firstReason":"1","secondCountry":"AX","secondReason":"3"},"jobTitle":"14","INDUSTRY":"1","Employed":"true","TaxResident":"true","taxCountries":true,"undefined":"1234567890"},"Personal Details":{"Nationality":"AL","citizenship":"AF","PublicOfficial":"false","Related":"true","RelationType":"5","RelationName":"Sample"},"PreApplication":{"consent":true,"businessProvince":"ZAF.EC","businessTurnover":"800000","businessName":"Random Company Name","soleShareholder":"true","businessType":"SOLE PROPRIETOR","soleOwner":"true","EmailAddress":"force@gmail.com","PhoneNumber":"765878260","IdNum":"5601120672097","Surname":"Ram","Name":"SampleName"},"Residential Address":{"Street":"dsfjks","UnitNumber":"hj","Complexe":"jh","suburb":"42ND HILL","city":"ABERDEEN","province":"ZAF.EC","PostalCode":"4567"},"Company Details":{"TELEPHONE  NUMBER (OPTIONAL)":"0612345678","EMAIL ADDRESS":"sample@gmail.com","CELLPHONE":"0612345678","PREFERRED BRANCH":"2750","COUNTRY OF REGISTRATION":"AX","INDUSTRY CLASSIFICATION":"27","NATURE OF THE BUSINESS":"18"},"Company Trading Address":{"PostalCode":"4567","PROVINCE":"ZAF.EC","city":"ABERDEEN","SUBURB":"486 SCHEME","Complex":"df","UnitNumber":"hj","StreetName":"sjhdj","AddressType":"Same"},"Marketing Consent":{"marketPermission":"true","researchContact":"true","otherCompaniesCom":"true"},"Card Selection":{"chequeCardSelected":true,"debitCardSelected":true},"Notifications":{"NotifiedMean":"SMS","depositInfo":"true"},"ProcessData":[{"parentTaskID":"","processTaskDetail":{"callBackURL":"","correlationID":"b60da24a-9861-c0c8-5b49-19fbc058d3f3","ownerBPID":null,"wfrFailureReason":null,"wfrRetryAllowed":null,"wfrStatus":null},"status":"Closed","taskID":"7704451","taskName":"Capture Application Data"},{"parentTaskID":"","processTaskDetail":{"callBackURL":"","correlationID":"b60da24a-9861-c0c8-5b49-19fbc058d3f3","ownerBPID":null,"wfrFailureReason":null,"wfrRetryAllowed":null,"wfrStatus":null},"status":"Closed","taskID":"7704452","taskName":"Step: Await IDV Callback"}]}';
		application.Name = 'MyMoBiz';
		application.AOB_Status__c = 'In Progress';
		application.AOB_TECH_OTPAttempts__c = 1;
		application.AOB_CurrentScreen__c = 'Summary';
		application.AOB_Retry_Count__c = 1;
		application.AOB_inflightData__c = json;
		application.Lead_Created__c = true;
		application.Lead__c = lobj.Id;

		application.AOB_TECH_WFRErrorCode__c = 'error';
		application.AOB_SalesObjectId__c = '45375115';
		application.AOB_Registration_Number__c = '2020/679442/07';
		insert application;

		List<Product2> productlist = new List<Product2>();

		Product2 mymobizProduct = new Product2();
		mymobizProduct.Name = 'MyMoBiz';
		mymobizProduct.ProductCode = '4648';
		productlist.add(mymobizProduct);

		Product2 chequeCard = new Product2();
		chequeCard.Name = 'Business Cheque Card';
		chequeCard.ProductCode = 'ZBCH';
		productlist.add(chequeCard);

		Product2 snapScap = new Product2();
		snapScap.Name = 'SnapScan';
		snapScap.ProductCode = 'ZPSS';
		productlist.add(snapScap);

		Product2 pocketBiz = new Product2();
		pocketBiz.Name = 'PocketBiz';
		pocketBiz.ProductCode = 'ZPOB';
		productlist.add(pocketBiz);

		insert productlist;

		List<AOB_ApplicationLineItem__c> lineItemlist = new List<AOB_ApplicationLineItem__c>();
		AOB_ApplicationLineItem__c lineItem1 = new AOB_ApplicationLineItem__c();
		lineItem1.Name = 'MymoBiz';
		String detailsData = '{"tnxDetails":{"priceOption":"ZMMB","myUpdates":{"recipientName":"KARABO MODISE","msgType":"E","email":"karabo.modise@standardbank.co.za","cellphone":null}}}';
		lineItem1.Details__c = detailsData;
		lineItem1.AOB_Status__c='Accepted';
		lineItem1.SalesObjectItemId__c = '100';
		lineItem1.AOB_ExpiryDate__c = Date.today().addDays(10);
		lineItem1.AOB_Application__c = application.Id;
		lineItem1.AOB_Pricing_Option__c = 'ZMMB';
		lineItem1.AOB_Product__c = mymobizProduct.Id;
		lineItemlist.add(lineItem1);

		AOB_ApplicationLineItem__c lineItemCheq = new AOB_ApplicationLineItem__c();
		lineItemCheq.Name = 'Cheque Card';
		String data2 = '{"addressValue":{"PROVINCE":"ZAF.LP","SUBURB":"Sea Point","UnitNumber":"999000","PostalCode":"7890","city":"LINDLEY","Complex":"parnandhi petals","StreetName":"sainagar"},"Deliver Address":"New","Delivery method":"Private Address"}';
		lineItemCheq.Details__c = data2;
		lineItemCheq.AOB_Status__c='Accepted';
		lineItemCheq.SalesObjectItemId__c = '400';
		lineItemCheq.AOB_Application__c = application.Id;
		lineItemCheq.AOB_Product__c = chequeCard.Id;
		lineItemlist.add(lineItemCheq);

		AOB_ApplicationLineItem__c lineItemPocket = new AOB_ApplicationLineItem__c();
		lineItemPocket.Name = 'PocketBiz';
		String data3 = '{"merchantDeviceDetails":{"prodDetails":{"serviceDescription":"TRADING IN ENTERTAINMENT COMMODITIES","registrationEmailAddr":"karabo.modise@standardbank.co.za","numberOfDevices":1,"merchantCategoryCode":"7996","consents":null,"businessTelephoneNbr":"0784585896","businessMobileNbr":"0839876543","businessEmailAddr":"tktrading@webmail.com","acceptRCSNum":null,"acceptDinersNum":null,"acceptAmExpressNum":null},"pricingOption":"ZPBP"}}';
		lineItemPocket.Details__c = data3;
		lineItemPocket.AOB_Status__c='Accepted';
		lineItemPocket.SalesObjectItemId__c = '600';
		lineItemPocket.AOB_Application__c = application.Id;
		lineItemPocket.AOB_Product__c = pocketBiz.Id;
		lineItemlist.add(lineItemPocket);

		AOB_ApplicationLineItem__c lineItemSnapScan = new AOB_ApplicationLineItem__c();
		lineItemSnapScan.Name = 'SnapScan';
		String data4 = '{"snapScanDetails":{"snapscanDetails":{"storeType":"O","merchantCategoryDesc":"ANTIQUE REPRODUCTION STORES","merchantCategoryCode":"5937","businessServiceDesc":"ANTIQUES","businessName":"MAFIA INC","businessEmail":"mafia@testemail.com","authPersonName":"GAMBINO LUCCHESE","authPersonIdNum":"6711205246099","authPersonEmail":"gambino@standardbank.co.za","authPersonCell":"0834167890","authPartner":null,"accountNbr":"0000010006844276"},"pricingOption":"ZPSP"}}';
		lineItemSnapScan.Details__c = data4;
		lineItemSnapScan.AOB_Status__c='Accepted';
		lineItemSnapScan.SalesObjectItemId__c = '700';
		lineItemSnapScan.AOB_Application__c = application.Id;
		lineItemSnapScan.AOB_Product__c = snapScap.Id;
		lineItemlist.add(lineItemSnapScan);
		insert lineItemlist;

		Verification__c vc = new Verification__c();
		vc.Name = 'test IDV';
		vc.AOB_WFR_Status__c = 'Started';
		vc.Correlation_ID__c = 'b985bf32-5990-40a6-86ba-cf9d1fc3f476';
		vc.AOB_Callback_Requested__c = true;
		vc.Application__c = application.Id;
		insert vc;
		return application.Id;

	}
    

    /**
    * @description test data for authentication
    * @param clientId 
    * @return AOB_Application__c 
    **/
    public static AOB_Application__c createAOBApplication(Id clientId) {
        AOB_Application__c app = new AOB_Application__c();
        app.Name = 'Test Application';
        app.AOB_Client__c = clientId;
        insert app;
        return app;
    }

       /**
	 * @description This method create a Account,Contact and update AccountContactRelation with authentication status
	 *
	 * @return Account
	 */
    public static Account createClient() {
        Account client = new Account();
        client.Name = 'Test Client';
        insert client;
        
        Contact contact = new Contact();
        contact.FirstName = 'John';
        contact.LastName = 'Doe';
        contact.Email = 'johndoe@test.com';
        contact.accountId = client.Id;
        insert contact;
        
        AccountContactRelation acr = [select id,ContactId, AccountId FROM AccountContactRelation WHERE AccountId = :client.Id];
        acr.roles = 'Company Director';
        update acr;
        
        return client;
    }
         
    /**
    * @description This method create Verication data for the application
    * @param app 
    * @param reference 
    * @param status 
    * @param clientid 
    * @return Verification__c 
    **/
    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static Verification__c createVerification(AOB_Application__c app, String reference, String status, Id clientid) {
        Verification__c verification = new Verification__c();
        verification.Authentication_Reference__c = reference;
        verification.Authentication_Status__c = status;
        verification.Application__c = app.Id;
        verification.Client__c = clientid;
        insert verification;
        return verification;
    }

    /**
    * @description creates app
    * @return String 
    **/
    public static String createApplicationRecord()
	{
		Lead lobj = new Lead();
		lobj.FirstName = 'FirstName';
        lobj.LastName = 'LastName';
		lobj.Customer_ID__c = '9801120672097';
		lobj.Company = 'TestCompany';
		insert lobj;
		AOB_Application__c application = new AOB_Application__c();
		String json = '{"Card Selection":{"chequeCardSelected":true,"debitCardSelected":true},"ContractDoucument":[{"documentId":"00EB1186-0000-C117-99FA-762353A112EE", "documentName":"Card application","documentCode":"CARAP","itemId":"400"}],"PreApplication": { "Name": "SampleName", "Surname": "Ram", "IdNum": "9801120672097","businessRegistrationNumber":"2020/679442/07","pricingOption":"ZMMB", "PhoneNumber": "0612345678", "EmailAddress": "force@ggmail.com","soleOwner": "true","businessType": "SOLE PROPRIETOR", "soleShareholder": "true","businessName": "Business Name","businessTurnover": "200000","businessProvince": "ZAF.EC", "consent": true },"preApplicationResponse":{"businessBPGUID":"d671c60e-fe03-1ed7-a9eb-4cf2ef6d1dec","businessBPID":"0531113757","businessRegisteredName":"MONSTER DOORS","digitalOfferId":"0045379680","inflightCustomerDataId":"0045379680","initiatorBPGUID":"45551ed4-38a9-0164-0000-00000ab6f567","initiatorBPID":"0530845443","initiatorDigitalID":null,"processId":"0045379680"},"Summary":{"itemId":"100","documentCode":"Test Code","documentName":"Contract","documentId":"idd_D0273485-0000-C316-A1CC-C389514C5256"},"Available Bundles":{"ZPOB":false,"ZPSS":false,"4488":false},"Company Financial Details":{"taxInputs":{"firstTaxNumber":"1234567890","firstCountry":"AX"},"taxCountries":true,"undefined":"","FOREIGN TAX RESIDENCY":"false","ENTITY CLASSIFICATION":"NFI","MoreLessClassif":"true"},"Employment Details":{"taxInputs":{"firstCountry":"AL","firstReason":"1","secondCountry":"AX","secondReason":"3"},"jobTitle":"14","INDUSTRY":"1","Employed":"true","TaxResident":"true","taxCountries":true,"undefined":"1234567890"},"Personal Details":{"Nationality":"AL","citizenship":"AF","PublicOfficial":"false","Related":"true","RelationType":"5","RelationName":"Sample"},"PreApplication":{"consent":true,"businessProvince":"ZAF.EC","businessTurnover":"800000","businessName":"Random Company Name","soleShareholder":"true","businessType":"SOLE PROPRIETOR","soleOwner":"true","EmailAddress":"force@gmail.com","PhoneNumber":"765878260","IdNum":"5601120672097","Surname":"Ram","Name":"SampleName"},"Residential Address":{"Street":"dsfjks","UnitNumber":"hj","Complexe":"jh","suburb":"42ND HILL","city":"ABERDEEN","province":"ZAF.EC","PostalCode":"4567"},"Company Details":{"TELEPHONE  NUMBER (OPTIONAL)":"0612345678","EMAIL ADDRESS":"sample@gmail.com","CELLPHONE":"0612345678","PREFERRED BRANCH":"2750","COUNTRY OF REGISTRATION":"AX","INDUSTRY CLASSIFICATION":"27","NATURE OF THE BUSINESS":"18"},"Company Trading Address":{"PostalCode":"4567","PROVINCE":"ZAF.EC","city":"ABERDEEN","SUBURB":"486 SCHEME","Complex":"df","UnitNumber":"hj","StreetName":"sjhdj","AddressType":"Same"},"Marketing Consent":{"marketPermission":"true","researchContact":"true","otherCompaniesCom":"true"},"Card Selection":{"chequeCardSelected":true,"debitCardSelected":true},"Notifications":{"NotifiedMean":"EMAIL","depositInfo":"true"},"ProcessData":[{"parentTaskID":"","processTaskDetail":{"callBackURL":"","correlationID":"b60da24a-9861-c0c8-5b49-19fbc058d3f3","ownerBPID":null,"wfrFailureReason":null,"wfrRetryAllowed":null,"wfrStatus":null},"status":"Closed","taskID":"7704451","taskName":"Capture Application Data"},{"parentTaskID":"","processTaskDetail":{"callBackURL":"","correlationID":"b60da24a-9861-c0c8-5b49-19fbc058d3f3","ownerBPID":null,"wfrFailureReason":null,"wfrRetryAllowed":null,"wfrStatus":null},"status":"Closed","taskID":"7704452","taskName":"Step: Await IDV Callback"}]}';
		application.Name = 'MyMoBiz';
		application.AOB_Status__c = 'In Progress';
		application.AOB_TECH_OTPAttempts__c = 1;
		application.AOB_CurrentScreen__c = 'Summary';
		application.AOB_Retry_Count__c = 2;
		application.AOB_inflightData__c = json;
		application.Lead_Created__c = true;
		application.Lead__c = lobj.Id;
		
		application.AOB_TECH_WFRErrorCode__c = 'error';
		application.AOB_SalesObjectId__c = '45375115';
		application.AOB_Registration_Number__c = '2020/679442/07';
		insert application;

		List<Product2> productlist = new List<Product2>();

		Product2 mymobizProduct = new Product2();
		mymobizProduct.Name = 'MyMoBiz';
		mymobizProduct.ProductCode = '4648';
		productlist.add(mymobizProduct);

		Product2 chequeCard = new Product2();
		chequeCard.Name = 'Business Cheque Card';
		chequeCard.ProductCode = 'ZBCH';
		productlist.add(chequeCard);

		Product2 snapScap = new Product2();
		snapScap.Name = 'SnapScan';
		snapScap.ProductCode = 'ZPSS';
		productlist.add(snapScap);

		Product2 pocketBiz = new Product2();
		pocketBiz.Name = 'PocketBiz';
		pocketBiz.ProductCode = 'ZPOB';
		productlist.add(pocketBiz);
        
        Product2 marketLink = new Product2();
		marketLink.Name = 'MarketLink';
		marketLink.ProductCode = '4488';
		productlist.add(marketLink);

		insert productlist;

		List<AOB_ApplicationLineItem__c> lineItemlist = new List<AOB_ApplicationLineItem__c>();
		AOB_ApplicationLineItem__c lineItem1 = new AOB_ApplicationLineItem__c();
		lineItem1.Name = 'MymoBiz';
		String detailsData = '{"tnxDetails":{"priceOption":"ZMMB","myUpdates":{"recipientName":"KARABO MODISE","msgType":"E","email":"karabo.modise@standardbank.co.za","cellphone":null}}}';
		lineItem1.Details__c = detailsData;
		lineItem1.AOB_Status__c='Accepted';
		lineItem1.SalesObjectItemId__c = '100';
		lineItem1.AOB_ExpiryDate__c = Date.today().addDays(10);
		lineItem1.AOB_Application__c = application.Id;
		lineItem1.AOB_Pricing_Option__c = 'ZMMB';
		lineItem1.AOB_Product__c = mymobizProduct.Id;
		lineItemlist.add(lineItem1);

		AOB_ApplicationLineItem__c lineItemCheq = new AOB_ApplicationLineItem__c();
		lineItemCheq.Name = 'Cheque Card';
		String data2 = '{"addressValue":{"PROVINCE":"ZAF.LP","SUBURB":"Sea Point","UnitNumber":"999000","PostalCode":"7890","city":"LINDLEY","Complex":"parnandhi petals","StreetName":"sainagar"},"Deliver Address":"Company","Delivery method":"Private Address"}';
		lineItemCheq.Details__c = data2;
		lineItemCheq.AOB_Status__c='Accepted';
		lineItemCheq.SalesObjectItemId__c = '400';
		lineItemCheq.AOB_Application__c = application.Id;
		lineItemCheq.AOB_Product__c = chequeCard.Id;
		lineItemlist.add(lineItemCheq);

		AOB_ApplicationLineItem__c lineItemPocket = new AOB_ApplicationLineItem__c();
		lineItemPocket.Name = 'PocketBiz';
		String data3 = '{"merchantDeviceDetails":{"prodDetails":{"serviceDescription":"TRADING IN ENTERTAINMENT COMMODITIES","registrationEmailAddr":"karabo.modise@standardbank.co.za","numberOfDevices":1,"merchantCategoryCode":"7996","consents":null,"businessTelephoneNbr":"0784585896","businessMobileNbr":"0839876543","businessEmailAddr":"tktrading@webmail.com","acceptRCSNum":null,"acceptDinersNum":null,"acceptAmExpressNum":null},"pricingOption":"ZPBP"}}';
		lineItemPocket.Details__c = data3;
		lineItemPocket.AOB_Status__c='Accepted';
		lineItemPocket.SalesObjectItemId__c = '600';
		lineItemPocket.AOB_Application__c = application.Id;
		lineItemPocket.AOB_Product__c = pocketBiz.Id;
		lineItemlist.add(lineItemPocket);

		AOB_ApplicationLineItem__c lineItemSnapScan = new AOB_ApplicationLineItem__c();
		lineItemSnapScan.Name = 'SnapScan';
		String data4 = '{"snapScanDetails":{"snapscanDetails":{"storeType":"O","merchantCategoryDesc":"ANTIQUE REPRODUCTION STORES","merchantCategoryCode":"5937","businessServiceDesc":"ANTIQUES","businessName":"MAFIA INC","businessEmail":"mafia@testemail.com","authPersonName":"GAMBINO LUCCHESE","authPersonIdNum":"6711205246099","authPersonEmail":"gambino@standardbank.co.za","authPersonCell":"0834167890","authPartner":null,"accountNbr":"0000010006844276"},"pricingOption":"ZPSP"}}';
		lineItemSnapScan.Details__c = data4;
		lineItemSnapScan.AOB_Status__c='Accepted';
		lineItemSnapScan.SalesObjectItemId__c = '700';
		lineItemSnapScan.AOB_Application__c = application.Id;
		lineItemSnapScan.AOB_Product__c = snapScap.Id;
		lineItemlist.add(lineItemSnapScan);
		insert lineItemlist;

		Verification__c vc = new Verification__c();
		vc.Name = 'test IDV';
		vc.AOB_WFR_Status__c = 'Started';
		vc.Correlation_ID__c = 'b985bf32-5990-40a6-86ba-cf9d1fc3f476';
		vc.AOB_Callback_Requested__c = true;
		vc.Application__c = application.Id;
		insert vc;
		return application.Id;

	}
   
   /**
   * @description creates app
   * @param jsonData 
   * @return string 
   **/
   public static string createApplicationRecord(String jsonData){
        Lead lobj=new Lead();
        lobj.FirstName = 'FirstName';
        lobj.LastName = 'LastName';
        lobj.Customer_ID__c = '9801120672097';
        lobj.Company = 'TestCompany';
        insert lobj;
        AOB_Application__c application = new AOB_Application__c();
        application.Name = 'MyMoBiz';
        application.AOB_Status__c = 'In Progress';
        application.AOB_TECH_OTPAttempts__c=1;
        application.AOB_currentScreen__c='Summary';
        application.AOB_Retry_Count__c=1;
        application.AOB_inflightData__c =jsonData;
        application.Lead_Created__c=true;
        application.Lead__c=lobj.Id;

        application.AOB_TECH_WFRErrorCode__c='error';
        application.AOB_SalesObjectId__c='45375115';
        application.AOB_Registration_Number__c='2020/679442/07';
        insert application;
        
        List<Product2> productlist=new List<Product2>();
        
        Product2 mymobizProduct= new Product2();
        mymobizProduct.Name='MyMoBiz';
        mymobizProduct.ProductCode='4648';
        productlist.add(mymobizProduct);
        
        Product2 chequeCard= new Product2();
        chequeCard.Name='Business Cheque Card';
        chequeCard.ProductCode='ZBCH';
        productlist.add(chequeCard);
        
        Product2 snapScap= new Product2();
        snapScap.Name='SnapScan';
        snapScap.ProductCode='ZPSS';
        productlist.add(snapScap);
        
        
        Product2 pocketBiz= new Product2();
        pocketBiz.Name='PocketBiz';
        pocketBiz.ProductCode='ZPOB';
        productlist.add(pocketBiz);
        
        insert productlist;
        
        List<AOB_ApplicationLineItem__c> lineItemlist=new List<AOB_ApplicationLineItem__c>();
        AOB_ApplicationLineItem__c lineItem1=new AOB_ApplicationLineItem__c();
        lineItem1.Name='MymoBiz';
        String detailsData='{"tnxDetails":{"priceOption":"ZMMB","myUpdates":{"recipientName":"KARABO MODISE","msgType":"E","email":"karabo.modise@standardbank.co.za","cellphone":null}}}';
        lineItem1.Details__c=detailsData;
        lineItem1.SalesObjectItemId__c='100';
        lineItem1.AOB_ExpiryDate__c=Date.today().addDays(10);
        lineItem1.AOB_Application__c=application.id;
        lineItem1.AOB_Pricing_Option__c='ZMMB';
        lineItem1.AOB_Product__c=mymobizProduct.id;
        lineItemlist.add(lineItem1);
        
        AOB_ApplicationLineItem__c lineItemCheq=new AOB_ApplicationLineItem__c();
        lineItemCheq.Name='Cheque Card';
		String data2='{"addressValue":{"PROVINCE":"ZAF.EC","SUBURB":"TANTJI","UnitNumber":"102","PostalCode":"3033","city":"SOUTHBROOM","Complex":"Eye of Africa estate","StreetName":"sairam enclave"},"Deliver Address":"Company","Delivery method":"Private Address"}';
        lineItemCheq.Details__c=data2;
        lineItemCheq.SalesObjectItemId__c='400';
        lineItemCheq.AOB_Application__c=application.id;
        lineItemCheq.AOB_Product__c=chequeCard.id;
        lineItemlist.add(lineItemCheq);
        
        AOB_ApplicationLineItem__c lineItemPocket=new AOB_ApplicationLineItem__c();
        lineItemPocket.Name='PocketBiz';
        String data3='{"merchantDeviceDetails":null,"numberOfDevices":"01","dinersCheck":true,"dinersNumber":"test","americanCheckbox":true,"americanNumber":"test","rcsCheckbox":true,"rcsNumber":"test","goodsdescribe":"test","merchantCategory":"3064","pricePerDevice":"69.00"}';
        lineItemPocket.Details__c=data3;
        lineItemPocket.SalesObjectItemId__c='600';
        lineItemPocket.AOB_Application__c=application.id;
        lineItemPocket.AOB_Product__c=pocketBiz.id;
        lineItemlist.add(lineItemPocket);
        
        AOB_ApplicationLineItem__c lineItemSnapScan=new AOB_ApplicationLineItem__c();
        lineItemSnapScan.Name='SnapScan';
        String data4='{"COMPANY TRADING NAME":"My Business","EMAIL ADDRESS":"john@gmail.com","DESCRIBE YOUR GOODS/SERVICES":"Coffee Shop","MERCHANT CATEGORY":"3076","receiveOnline":false,"receiveInStore":true}';
        lineItemSnapScan.Details__c=data4;
        lineItemSnapScan.SalesObjectItemId__c='700';
        lineItemSnapScan.AOB_Application__c=application.id;
        lineItemSnapScan.AOB_Product__c=snapScap.id;
        lineItemlist.add(lineItemSnapScan);
        Insert lineItemlist;
        
        Verification__c vc = new Verification__c();
        vc.Name='test IDV';
        vc.AOB_WFR_Status__c='Started';
        vc.Correlation_ID__c='b985bf32-5990-40a6-86ba-cf9d1fc3f476';
        vc.AOB_Callback_Requested__c=true;
        vc.Application__c=application.Id;
        vc.AOB_WFR_ErrorCode__c='test';
       vc.AOB_WFR_Message__c='test';
        Insert vc;
        return application.Id;
        
    }
    
    /**
	 * @description This method generates Inflight data for use in the application creation
	 *
	 * @return Pre Application JSON String
	 */
	public static AOB_DTO_StaffAssistedOnboarding.DTO_PreApplication generateApplicationInflightData()
	{
		AOB_DTO_StaffAssistedOnboarding.DTO_PreApplication preApplication = new AOB_DTO_StaffAssistedOnboarding.DTO_PreApplication();
		preApplication.appName = CMN_DAL_SObjectDomain.generateRandomName();
		preApplication.businessName = CMN_DAL_SObjectDomain.generateRandomName();
		preApplication.businessProvince = CMN_DAL_SObjectDomain.generateRandomName();
		preApplication.businessTurnover = CMN_DAL_SObjectDomain.generateRandomNumber();
		preApplication.businessType = CMN_DAL_SObjectDomain.generateRandomName();
		preApplication.consent = CMN_DAL_SObjectDomain.generateRandomBoolean();
		preApplication.EmailAddress = CMN_DAL_SObjectDomain.generateRandomEmail();
		preApplication.IdNum = CMN_DAL_SObjectDomain.generateRandomNumber(13);
		preApplication.Name = CMN_DAL_SObjectDomain.generateRandomName();
		preApplication.PhoneNumber = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
		preApplication.pricingOption = CMN_DAL_SObjectDomain.generateRandomName();
		preApplication.productNumber = CMN_DAL_SObjectDomain.generateRandomNumber(4);
		preApplication.soleOwner = String.valueOf(CMN_DAL_SObjectDomain.generateRandomBoolean());
		preApplication.Surname = CMN_DAL_SObjectDomain.generateRandomName();
		return preApplication;
	}

	/**
	 * @description This method generates Inflight data for use in the application creation
	 *
	 * @return Pre Application JSON String
	 */
    @SuppressWarnings('PMD.NcssMethodCount')
	public static AOB_API_InternalPreApplication.DTO_PreApplicationResponse generatePreApplicationResponse()
	{
		AOB_DTO_StaffAOResponse.DTO_TaxDetail taxDetail = new AOB_DTO_StaffAOResponse.DTO_TaxDetail();
		taxDetail.taxNumber = String.valueOf(CMN_DAL_SObjectDomain.generateRandomNumber(10));
		taxDetail.provisionalTaxPayerInd = CMN_DAL_SObjectDomain.generateRandomName();
		taxDetail.taxType = CMN_DAL_SObjectDomain.generateRandomName();

		AOB_DTO_StaffAOResponse.DTO_Relationship relationship = new AOB_DTO_StaffAOResponse.DTO_Relationship();
		relationship.relationshipTypeCode = CMN_DAL_SObjectDomain.generateRandomName();

		AOB_DTO_StaffAOResponse.DTO_PublicOfficialRelatedDetail publicOfficialRelatedDetail =
				new AOB_DTO_StaffAOResponse.DTO_PublicOfficialRelatedDetail();
		publicOfficialRelatedDetail.typeOfRelationship = CMN_DAL_SObjectDomain.generateRandomName();
		publicOfficialRelatedDetail.surname = CMN_DAL_SObjectDomain.generateRandomName();
		publicOfficialRelatedDetail.name = CMN_DAL_SObjectDomain.generateRandomName();
		publicOfficialRelatedDetail.relatedToPublicOfficial = CMN_DAL_SObjectDomain.generateRandomBoolean();

		AOB_DTO_StaffAOResponse.DTO_PipDetail pipDetail = new AOB_DTO_StaffAOResponse.DTO_PipDetail();
		pipDetail.publicOfficialRelatedDetails = publicOfficialRelatedDetail;
		pipDetail.publicOfficial = CMN_DAL_SObjectDomain.generateRandomBoolean();

		AOB_DTO_StaffAOResponse.DTO_DirectorAddress directorAddress = new AOB_DTO_StaffAOResponse.DTO_DirectorAddress();
		directorAddress.postalCode = String.valueOf(CMN_DAL_SObjectDomain.generateRandomInteger(4));
		directorAddress.province = CMN_DAL_SObjectDomain.generateRandomName();
		directorAddress.country = CMN_DAL_SObjectDomain.generateRandomName();
		directorAddress.cityDistrict = CMN_DAL_SObjectDomain.generateRandomName();
		directorAddress.countyDistrict = CMN_DAL_SObjectDomain.generateRandomName();
		directorAddress.addressLine1 = CMN_DAL_SObjectDomain.generateRandomName();
		directorAddress.addressLine2 = CMN_DAL_SObjectDomain.generateRandomName();
		directorAddress.addressLine3 = CMN_DAL_SObjectDomain.generateRandomName();
		directorAddress.addressLine4 = CMN_DAL_SObjectDomain.generateRandomName();

		AOB_DTO_StaffAOResponse.DTO_EmployDetail employeeDetail = new AOB_DTO_StaffAOResponse.DTO_EmployDetail();
		employeeDetail.jobTitle = CMN_DAL_SObjectDomain.generateRandomName();
		employeeDetail.occupationStatus = CMN_DAL_SObjectDomain.generateRandomName();
		employeeDetail.industry = CMN_DAL_SObjectDomain.generateRandomName();

		AOB_DTO_StaffAOResponse.DTO_DirectorDetail directorDetail = new AOB_DTO_StaffAOResponse.DTO_DirectorDetail();
		directorDetail.isInitiator = CMN_DAL_SObjectDomain.generateRandomBoolean();
		directorDetail.mainApplicant = CMN_DAL_SObjectDomain.generateRandomBoolean();
		directorDetail.authorizedToApply = CMN_DAL_SObjectDomain.generateRandomBoolean();
		directorDetail.loggedInUser = CMN_DAL_SObjectDomain.generateRandomBoolean();
		directorDetail.lastName = CMN_DAL_SObjectDomain.generateRandomName();
		directorDetail.grossMonthlyIncome = CMN_DAL_SObjectDomain.generateRandomNumber(5);
		directorDetail.cellphoneNumber = CMN_DAL_SObjectDomain.generateRandomPhoneNumber();
		directorDetail.totalMonthlyExpenses = CMN_DAL_SObjectDomain.generateRandomNumber(6);
		directorDetail.identificationType = CMN_DAL_SObjectDomain.generateRandomName();
		directorDetail.emailAddress = CMN_DAL_SObjectDomain.generateRandomEmail();
		directorDetail.assets = CMN_DAL_SObjectDomain.generateRandomName();
		directorDetail.liabilities = CMN_DAL_SObjectDomain.generateRandomName();
		directorDetail.digitalId = CMN_DAL_SObjectDomain.generateRandomNumber(6);
		directorDetail.bpId = CMN_DAL_SObjectDomain.generateRandomName();
		directorDetail.citizenship = CMN_DAL_SObjectDomain.generateRandomName();
		directorDetail.identificationCountryCode = CMN_DAL_SObjectDomain.generateRandomName();
		directorDetail.bpGuid = CMN_DAL_SObjectDomain.generateRandomName();
		directorDetail.firstName = CMN_DAL_SObjectDomain.generateRandomName();
		directorDetail.preferredCommunicationMethod = CMN_DAL_SObjectDomain.generateRandomName();
		directorDetail.nationality = CMN_DAL_SObjectDomain.generateRandomName();
		directorDetail.identificationNumber = CMN_DAL_SObjectDomain.generateRandomNumber(13);
		directorDetail.status = CMN_DAL_SObjectDomain.generateRandomName();
		directorDetail.taxDetails = taxDetail;
		directorDetail.relationships = relationship;
		directorDetail.pipDetails = pipDetail;
		directorDetail.directorAddress = directorAddress;
		directorDetail.employDetails = employeeDetail;

		AOB_DTO_StaffAOResponse.DTO_KycAddress kycAddress = new AOB_DTO_StaffAOResponse.DTO_KycAddress();
		kycAddress.postalCode = String.valueOf(CMN_DAL_SObjectDomain.generateRandomInteger(4));
		kycAddress.province = CMN_DAL_SObjectDomain.generateRandomName();
		kycAddress.country = CMN_DAL_SObjectDomain.generateRandomName();
		kycAddress.city = CMN_DAL_SObjectDomain.generateRandomName();
		kycAddress.district = CMN_DAL_SObjectDomain.generateRandomName();
		kycAddress.line1 = CMN_DAL_SObjectDomain.generateRandomName();
		kycAddress.line2 = CMN_DAL_SObjectDomain.generateRandomName();
		kycAddress.line3 = CMN_DAL_SObjectDomain.generateRandomName();
		kycAddress.line4 = CMN_DAL_SObjectDomain.generateRandomName();

		AOB_DTO_StaffAOResponse.DTO_BusinessDetail businessDetail = new AOB_DTO_StaffAOResponse.DTO_BusinessDetail();
		businessDetail.businessTurnover = String.valueOf(CMN_DAL_SObjectDomain.generateRandomInteger(7));
		businessDetail.entityClassification = CMN_DAL_SObjectDomain.generateRandomName();
		businessDetail.businessType = CMN_DAL_SObjectDomain.generateRandomName();
		businessDetail.businessStatus = CMN_DAL_SObjectDomain.generateRandomName();
		businessDetail.businessBPGUID = CMN_DAL_SObjectDomain.generateRandomName();
		businessDetail.businessName = CMN_DAL_SObjectDomain.generateRandomName();
		businessDetail.businessBPID = CMN_DAL_SObjectDomain.generateRandomName();
		businessDetail.businessProvince = CMN_DAL_SObjectDomain.generateRandomName();
		businessDetail.businessRegistrationNumber = generateBusinessRegNumber();
		businessDetail.businessCity = CMN_DAL_SObjectDomain.generateRandomName();

		AOB_API_InternalPreApplication.DTO_CipcRegisteredDetail cipcRegisteredDetail = new AOB_API_InternalPreApplication.DTO_CipcRegisteredDetail();
		cipcRegisteredDetail.directorDetails = new List<AOB_DTO_StaffAOResponse.DTO_DirectorDetail> {directorDetail};
		cipcRegisteredDetail.businessDetails = businessDetail;

		AOB_API_InternalPreApplication.DTO_ApplicationResponseDetail applicationResponseDetail =
				new AOB_API_InternalPreApplication.DTO_ApplicationResponseDetail();
		applicationResponseDetail.processExpiryDate = String.valueOf(CMN_DAL_SObjectDomain.generateRandomDate());
		applicationResponseDetail.digitalOfferID = CMN_DAL_SObjectDomain.generateRandomNumber();
		applicationResponseDetail.processID = CMN_DAL_SObjectDomain.generateRandomNumber();
		applicationResponseDetail.maintenanceOfferID = CMN_DAL_SObjectDomain.generateRandomNumber();

		AOB_DTO_StaffAOResponse.DTO_ResponseStatus responseStatus = new AOB_DTO_StaffAOResponse.DTO_ResponseStatus();
		responseStatus.statusCode = String.valueOf(CMN_DAL_SObjectDomain.generateRandomNumber(3));
		responseStatus.serverStatusCode = String.valueOf(CMN_DAL_SObjectDomain.generateRandomNumber(3));
		responseStatus.severity = CMN_DAL_SObjectDomain.generateRandomName();
		responseStatus.statusDescription = CMN_DAL_SObjectDomain.generateRandomName();

		AOB_DTO_StaffAOResponse.DTO_OrchestrationHeaderResponse headerResponse =
				new AOB_DTO_StaffAOResponse.DTO_OrchestrationHeaderResponse();
		headerResponse.instanceId = CMN_DAL_SObjectDomain.generateRandomName();
		headerResponse.respondToAddress = CMN_DAL_SObjectDomain.generateRandomName();
		headerResponse.requestTimeStamp = CMN_DAL_SObjectDomain.generateRandomName();
		headerResponse.responseTimeStamp = CMN_DAL_SObjectDomain.generateRandomName();
		headerResponse.correlationId = CMN_DAL_SObjectDomain.generateRandomName();
		headerResponse.channelId = CMN_DAL_SObjectDomain.generateRandomName();
		headerResponse.responseStatus = responseStatus;

		AOB_API_InternalPreApplication.DTO_PreApplicationResponse dtoPreApplicationResponse =
				new AOB_API_InternalPreApplication.DTO_PreApplicationResponse();
		dtoPreApplicationResponse.cipcRegisteredDetails = cipcRegisteredDetail;
		dtoPreApplicationResponse.orchestrationHeaderResponse = headerResponse;
		dtoPreApplicationResponse.applicationResponseDetails = applicationResponseDetail;

		AOB_API_InternalPreApplication.DTO_Response response = new AOB_API_InternalPreApplication.DTO_Response();
		response.preApplicationResponse = dtoPreApplicationResponse;
		return dtoPreApplicationResponse;
	}

	/**
	 * @description This method generates a random business registration number
	 * @return String
	 */
	public static String generateBusinessRegNumber()
	{
		return String.valueOf(System.now().year())
				+ '/' + CMN_DAL_SObjectDomain.generateRandomNumber(6)
				+ '/' + CMN_DAL_SObjectDomain.generateRandomNumber(2);

	}

	/**
	 * @description This method creates an application record with inflight data
	 * @return application record
	 */
	public static AOB_Application__c createApplicationWithInflightData(){
		AOB_DTO_StaffAssistedOnboarding.DTO_InflightData newInflightData = new AOB_DTO_StaffAssistedOnboarding.DTO_InflightData();
		newInflightData.PreApplication =  AOB_DAL_TestFactory.generateApplicationInflightData();

		AOB_Application__c application = new AOB_Application__c();
		application.AOB_ExpiryDate__c = System.today().addDays(7);
		application.AOB_inflightData__c = JSON.serialize(newInflightData);
		application.AOB_Status__c = AOB_Constants.IN_PROGRESS;
		application.Name = CMN_DAL_SObjectDomain.generateRandomName();
		insert application;
		return application;
	}
}