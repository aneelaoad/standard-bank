/**
 * Created by Chibuye Kunda on 2018/10/27.
 */

@IsTest
private class ProceedButtonControllerTest {

    /** this is the user name of commB user
     */
    private static final String m_commb_username = 'commb@commb.com';

    /** this is the user name of commB cc user
     */
    private static final String m_commb_cc_username = 'cc_commb@commb.com';

    /** this is the name of client
     */
    private static final String m_commb_client_name = 'commb test client';

    /** this is the last name of the contact oject
     */
    private static final String m_last_name = 'Test Last Name';

    /** this will hold CommB user object
     */
    private static User m_commb_user{

        //define get
        get{

            //check if variable is null
            if( m_commb_user == null )
                //get the user record
                m_commb_user = [ SELECT Id
                                 FROM User
                                 WHERE Username =: m_commb_username ];

            return m_commb_user;        //return commB user variable

        }//end of get

        //define set
        set{}

    }//end of property definition

    /** this will hold commB cc user object
     */
    private static User m_cc_commb_user{

        //define get
        get{

            //check if variable is null
            if( m_cc_commb_user == null )
                //get the user record
                m_cc_commb_user = [ SELECT Id
                                    FROM User
                                    WHERE Username =: m_commb_cc_username ];

            return m_cc_commb_user;

        }

        //define set
        set{}

    }//end of property definition


    /** this will hold our test account
     */
    private static Account m_commb_client{

        //define get
        get{

            //check if variable is null
            if( m_commb_client == null )
                //get the account record
                m_commb_client = [ SELECT Id, Client_Co_ordinator__c
                                   FROM Account
                                   WHERE Name =: m_commb_client_name ];

            return m_commb_client;      //return the client

        }//end of get

        //define set
        set{}

    }//end of property definition

    /** this will hold our test contact
     */
    private static Contact m_commb_contact{

        //define get
        get{

            //check if variable is null
            if( m_commb_contact == null )
                //get the accoun
                m_commb_contact = [ SELECT Id
                                    FROM Contact
                                    WHERE LastName =: m_last_name ];

            return m_commb_contact;         //return the client contact

        }//end of get

        //define set
        set{}

    }//end of property define





    /** this function will setup our test data
     */
    @TestSetup
    private static void setup(){

        TEST_DataFactory.insertSettings(new List<Object> {
                TEST_DataFactory.getCstTeamRankings()
        });
        new BLD_USER( m_commb_username ).useCommB().commitWork();       //create a user
        new BLD_USER( m_commb_cc_username ).useCommB().commitWork();    //create cc user

        //run as commB user
        System.runAs( m_commb_user ){
            createAccount();                      //create commB data
            createContact();                    //create a contact
        }//end of run as block

        createClientCoordinatorSettings();

    }//end of function definition





    /** this function will test our sumbit for onbaording function
     */
    @IsTest
    private static void testSubmitForOnboarding(){

        String mockBody = '<?xml version="1.0" encoding="UTF-8"?>'	+
                + 	'<Response>'	+
                +		'<Operation>New Customer</Operation>'	+
                +		'<Success>true</Success>'	+
                +	'</Response>';

        SingleRequestMock singleMock = new SingleRequestMock(200, 'OK',mockBody, null);
        Test.setMock(HttpCalloutMock.class, singleMock);

        List< SubClassification_Mapping__c > subclassification_list = TEST_DataFactory.getSubClassificationMappings();     //get sub classification
//
        KYC_Locations__c kyc_sa = new KYC_Locations__c( Name = 'SBSA', Value__c = 'SBSA - Standard Bank of South Africa Ltd'   );
        KYC_Locations__c kyc_angola = new KYC_Locations__c( Name = 'SBAO', Value__c = 'SBAO - Standard Bank de Angola SA' );
        KYC_Locations__c kyc_ivory_coast = new KYC_Locations__c( Name = 'Cote dIvoire', Value__c = 'SBCI - Standard Bank Cote D\'Ivoire SA' );

        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getSbParameters(),
            TEST_DataFactory.getCcSettings(),
            TEST_DataFactory.getCSTManyPerRegionTeamRoles(),
            subclassification_list,
            kyc_sa,
            kyc_angola,
            kyc_ivory_coast
        });

        User test_user = (User) new BLD_USER('test.admin@standardbank.co.za').useSysAdmin().getRecord();
        test_user.FirstName = 'firstName';
        test_user.LastName = 'lastName';
        test_user.Email = 'test.admin@standardbank.co.za';
        test_user.Contact_Sync_ID__c = m_commb_contact.Id;


        System.runAs( new User( Id = UserInfo.getUserId() ) ){
            insert test_user;
        }

        List< Account > account_list = new List<Account> {
            (Account) new BLD_Account().getRecord()
        };
        account_list[0].Status__c = 'New';
        account_list[0].KYC_Location__c = kyc_sa.Value__c;
        account_list[0].Relationship_Roles__c = 'Client';
        account_list[0].Primary_Relationship_Holder__c = DMN_Account.PRIMARY_REL_HOLDER_CIB;
        account_list[0].Client_Co_ordinator__c = test_user.Id;

        insert account_list[0];

        List< SubClassification_Mapping__c > scc_mappings_list = new List< SubClassification_Mapping__c >();

        //check if we have subclassification
        if( !subclassification_list.isEmpty() ){

            account_list[0].Client_Type_OnBoard__c = subclassification_list[0].Client_Type__c;
            account_list[0].Business_Classification__c = subclassification_list[0].Business_Classification__c;
            scc_mappings_list = [ SELECT Id
                                  FROM SubClassification_Mapping__c
                                  WHERE ( Client_Type__c =: account_list[0].Client_Type_OnBoard__c ) AND Business_Classification__c =: account_list[0].Business_Classification__c  ];

        }//end of if-block




        List<SFDC2GT_Xml_Stucture__c> xml_structure = new List<SFDC2GT_Xml_Stucture__c>();

        xml_structure.add(new SFDC2GT_Xml_Stucture__c(Name = 'Request',Object_Name__c = '', Field_Name__c = 'Account', Node_Item_Name__c = '', Node_Name__c = 'Request', Default_Value__c='', Order__c = 1, Message_Code__c = 'SA'));
        xml_structure.add(new SFDC2GT_Xml_Stucture__c(Name = 'Account',Object_Name__c = 'Account', Field_Name__c = '', Node_Item_Name__c = '', Node_Name__c = 'Operation', Default_Value__c='New Customer', Order__c = 5, Message_Code__c = 'SA'));
        xml_structure.add(new SFDC2GT_Xml_Stucture__c(Name = 'Account.Id',Object_Name__c = 'Account', Field_Name__c = 'Id', Node_Item_Name__c = '', Node_Name__c = 'Salesforce_ID', Default_Value__c='', Order__c = 10, Message_Code__c = 'SA'));
        xml_structure.add(new SFDC2GT_Xml_Stucture__c(Name = 'Account.Contacts',Object_Name__c = 'Account', Field_Name__c = 'Contacts', Node_Item_Name__c = 'Cust_Contact', Node_Name__c = 'Cust_Contacts', Default_Value__c='', Order__c = 350, Message_Code__c = 'SA'));
        xml_structure.add(new SFDC2GT_Xml_Stucture__c(Name = 'Contacts.Phone',Object_Name__c = 'Contacts', Field_Name__c = 'Phone', Node_Item_Name__c = '', Node_Name__c = 'Phone_Nume', Default_Value__c='', Order__c = 60, Message_Code__c = 'SA'));
        xml_structure.add(new SFDC2GT_Xml_Stucture__c(Name = 'Contacts.Account.Id',Object_Name__c = 'Contacts', Field_Name__c = 'Account.Id', Node_Item_Name__c = '', Node_Name__c = 'AccountId', Default_Value__c='', Order__c = 70, Message_Code__c = 'SA'));
        xml_structure.add(new SFDC2GT_Xml_Stucture__c(Name = 'Account.Custom_Client_Teams__r',Object_Name__c = 'Account', Field_Name__c = 'Custom_Client_Teams__r', Node_Item_Name__c = 'Internal_Contact', Node_Name__c = 'Internal_Contacts', Default_Value__c='', Order__c = 340, Message_Code__c = 'SA'));
        xml_structure.add(new SFDC2GT_Xml_Stucture__c(Name = 'Team_Member__r.FirstName',Object_Name__c = 'Custom_Client_Teams__r', Field_Name__c = 'Team_Member__r.FirstName', Node_Item_Name__c = '', Node_Name__c = 'First_Name', Default_Value__c='', Order__c = 10, Message_Code__c = 'SA'));

        insert xml_structure;

        Account new_account = account_list[0];
        ProceedButtonController.ServerResponse response;

        Test.startTest();
        System.runAs( test_user ) {

            response = ProceedButtonController.submitForOnboarding(new_account);
        }

        Test.stopTest();

        System.assertEquals( response.is_error, false );    //no error expected

    }//end of function definition




    /** this function will test if record should be sent for approval
     */
    @IsTest
    private static void testSendForApproval(){

        ProceedButtonController.ServerResponse response;                //this will hold server response

        //run as commB user
        System.runAs( m_commb_user ){

            response = ProceedButtonController.shouldBeApproved( m_cc_commb_user.Id );

        }//end of run as

        System.assertEquals( response.is_error, false );    //no error expected

    }//end of function definition





    /** this function will test if record is goldtier record
     */
    @IsTest
    private static void testIsGoldtierRecord(){

        ProceedButtonController.ServerResponse response;                //will hold server response
        SEL_Accounts selector = new SEL_Accounts();
        List< Account > test_accounts = selector.selectByRegistrationNumber( new Set<String>{ '12345' } );

        System.runAs( m_commb_user ){

            response = ProceedButtonController.isGoldtierRecord( test_accounts[0] );

        }//end of run as definition

        System.assertEquals( response.is_error, false );            //no error expect

    }//end of function definition





    /** this function will test if user is CIB
     */
    @IsTest
    private static void testIsUserCIB(){

        ProceedButtonController.ServerResponse response;

        //run as commB user
        System.runAs( m_commb_user ){

            response = ProceedButtonController.isUserCIB();            //check if we have CIB user

            System.assert( !response.is_error );                //check we dont have a error
            System.assert( response.result_message == 'false' );        //check that result message is false

        }//end of run as block

        System.assertEquals( response.is_error, false );            //no error expected

    }//end of function definition




    @IsTest
    private static void testChangeRecordType(){

        ProceedButtonController.ServerResponse response;                //this is our response object
        SEL_Accounts selector = new SEL_Accounts();
        List< Account > test_accounts = selector.selectByRegistrationNumber( new Set< String >{ '12345' } );

        //run in user context
        System.runAs( m_commb_user ){

            response = ProceedButtonController.changeRecordType( test_accounts[0].Id, 'Potential_Goldtier' );

        }//end of run as block

        System.assertEquals( response.is_error, false );                //no error expected

    }




    /** this function will test create client team
     */
    @IsTest
    private static void testCreateClientTeam(){

        ProceedButtonController.ServerResponse response;

        Account test_account = [ SELECT Id, RecordTypeId, Client_Co_ordinator__c, Client_Coordinator_Division__c
                                 FROM Account
                                 WHERE Registration_Number__c = '12345' ];

        //run in user context
        System.runAs( m_commb_user ){

             response = ProceedButtonController.createClientTeam( test_account );

        }//end of run as block

        System.assertEquals( response.is_error, false );                //no error expected

    }//end of function definition






    /** this function will create a commb client data
     */
    private static void createAccount(){

        fflib_SObjectUnitOfWork unit_of_work = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Account commb_client = new BLD_Account( unit_of_work );                             //this is Account object

        commb_client.setField( Account.Name, m_commb_client_name )
                .setField( Account.Client_Type_OnBoard__c, 'Trust' )
                .setField( Account.Business_Classification__c, 'Foundation' )
                .setField( Account.Registered_Suburb__c, 'test suburb' )
                .setField( Account.BillingStreet, 'test street' )
                .setField( Account.KYC_Location__c, 'SBSA - Standard Bank of South Africa Ltd' )
                .setField( Account.Relationship_Roles__c, 'Client' )
                .setField( Account.Client_Relationship_Hierarchy__c, 'Group Parent' )
                .setField( Account.Client_Sector__c, 'Consumer' )

                .setField( Account.Client_Sub_Sector__c, 'Retail' )
                .setField( Account.Registration_Number__c, '12345' )
                .setField( Account.Client_Co_ordinator__c, m_commb_user.Id )
                .setField( Account.High_Risk_Business__c, 'No' )
                .setField( Account.Source_of_Funds__c, 'Gift' )
                .setField( Account.Expected_Income__c, '1234' )
                .setField( Account.Relevant_Regulator_or_Approved_Regulated__c, 'test approver' )
                .setField( Account.OwnerId, m_commb_user.Id )
                .setField( Account.Primary_Relationship_Holder__c, 'Commercial Banking' );

        unit_of_work.commitWork();          //commit work

    }//end of function definition






    /** this function will create a contact
     */
    private static void createContact(){

        fflib_SObjectUnitOfWork unit_of_work = ABS_ObjectBuilderBase.getNewUnitOfWork();
        BLD_Contact commb_contact = new BLD_Contact( unit_of_work );                  //create the commB contact

        commb_contact.setField( Contact.LastName, m_last_name );             //set the contact last name

        unit_of_work.commitWork();          //commit work

    }//end of function definition





    /** this function will create ClientCoordinatorSettings object
     */
    private static void createClientCoordinatorSettings(){

        ClientCoordinatorSettings__c[] access_map = new ClientCoordinatorSettings__c[]{
            new ClientCoordinatorSettings__c( Name='CC_OpportunityAccessLevel', AccessLevel__c='Read/Write' ),
            new ClientCoordinatorSettings__c( Name='CC_ContactAccessLevel', AccessLevel__c='Read/Write' ),
            new ClientCoordinatorSettings__c( Name='CC_ClientAccessLevel', AccessLevel__c='Full Access' ),
            new ClientCoordinatorSettings__c( Name='CC_CaseAccessLevel', AccessLevel__c='Read Only' ),
            new ClientCoordinatorSettings__c( Name='CC_Client_Coverage_OppAccessLevel', AccessLevel__c='Read Only' )
        };

        SObject[] custom_settings = new SObject[]{};                 //create an array of sobjects
        custom_settings.addAll( ( SObject[] ) access_map );

        insert custom_settings;

    }//end of function definition


}//end of class definition