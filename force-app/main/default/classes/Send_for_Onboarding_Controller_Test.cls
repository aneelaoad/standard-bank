/*************************************************************************
    @ Author        : Prabhanshu Agrawal
    @ Date          : June 2015
    @ Description   : Test Class for Send_for_Onboarding_Controller
    @ Enhancement   : EN-0704
    
    -----------------------------------------------------------------------------
    @ Last Modified By      :   Abhishek Vaideeswaran
    @ Last Modified On      :   July 2015
    @ Last Modified Reason  :   Included KYC_Locations__c custom setting inorder to avoid hard coding of KYC location value.
    
    @ Last Modified By      :   Abhishek Vaideeswaran
    @ Last Modified On      :   July 2015
    @ Last Modified Reason  :   EN - 787 - Removed Primary_Relationship__c references from the test methods as the field is deleted.
    
    @ Last Modified By      :   Abhishek Vaideeswaran
    @ Last Modified On      :   August 2015
    @ Last Modified Reason  :   EN - 0792 - To test the change of routing criteria and the condition to set shouldrenderCIBROA/shouldrenderCIBSA as per the new criteria.

*************************************************************************/
@isTest

private class Send_for_Onboarding_Controller_Test{


    static testMethod void Test_Confirm_one_selected_CIB(){
        KYC_Locations__c klrec1 = new KYC_Locations__c(Name = 'SBSA', Value__c = 'SBSA - Standard Bank of South Africa Ltd');
        KYC_Locations__c klrec2 = new KYC_Locations__c(Name = 'SBAO', Value__c = 'SBAO - Standard Bank de Angola SA');
        KYC_Locations__c klrec3 = new KYC_Locations__c(Name = 'Cote dIvoire', Value__c = 'SBCI - Standard Bank Cote D\'Ivoire SA');
        List<KYC_Locations__c> kycLocations = new List<KYC_Locations__c> {
            klrec1,
            klrec2,
            klrec3
        };
        List<SubClassification_Mapping__c> clientSubClassificationMappings = TEST_DataFactory.getSubClassificationMappings();
        TEST_DataFactory.insertSettings(new List<Object> {
            new SB_Parameters__c(Name = 'GT_REQ_CODE_SBSA', Value__c = 'SA'),
            TEST_DataFactory.getCcSettings(),
            TEST_DataFactory.getCstTeamRankings(),
            TEST_DataFactory.getCSTManyPerRegionTeamRoles(),
            clientSubClassificationMappings,
            kycLocations
        });

        List<Account> olstTestAccount = new List<Account> {(Account) new BLD_Account().getRecord()};
        olstTestAccount[0].Status__c = 'New';
        olstTestAccount[0].KYC_Location__c = klrec1.Value__c;
        olstTestAccount[0].Relationship_Roles__c = 'Client';

        List<SubClassification_Mapping__c> sccMappingsForAssesment = new List<SubClassification_Mapping__c>();
        if(!clientSubClassificationMappings.isEmpty()){
            olstTestAccount[0].Client_Type_OnBoard__c = clientSubClassificationMappings[0].CLient_Type__c;
            olstTestAccount[0].Business_Classification__c = clientSubClassificationMappings[0].Business_Classification__c;
            //olstTestAccount[0].SCC_Type__c = clientSubClassificationMappings[0].SubClassification__c;
            sccMappingsForAssesment = [SELECT Id FROM SubClassification_Mapping__c WHERE Client_Type__c=:olstTestAccount[0].Client_Type_OnBoard__c and Business_Classification__c=:olstTestAccount[0].Business_Classification__c];
        }

        insert olstTestAccount[0];

        //create new user
        User testUser = (User) new BLD_USER().useSysAdmin().getRecord();
        testUser.FirstName = 'Firstname';
        testUser.LastName = 'LastName';
        testUser.Email = 'Test.admin@standardbank.co.za';
        system.runAs(new User(Id = UserInfo.getUserId())){
            insert testUser;

            testUser = [ SELECT  Name, Email
            From User
            WHERE Id =: testUser.Id  ];

            olstTestAccount[0].Client_Co_ordinator__r = testUser;
            olstTestAccount[0].OwnerId = testUser.Id;
            update olstTestAccount[0];


        }

        List<SFDC2GT_Xml_Stucture__c> xmlStructure = new List<SFDC2GT_Xml_Stucture__c>();

        xmlStructure.add(new SFDC2GT_Xml_Stucture__c(Name = 'Request',Object_Name__c = '', Field_Name__c = 'Account', Node_Item_Name__c = '', Node_Name__c = 'Request', Default_Value__c='', Order__c = 1, Message_Code__c = 'SA'));
        xmlStructure.add(new SFDC2GT_Xml_Stucture__c(Name = 'Account',Object_Name__c = 'Account', Field_Name__c = '', Node_Item_Name__c = '', Node_Name__c = 'Operation', Default_Value__c='New Customer', Order__c = 5, Message_Code__c = 'SA'));
        xmlStructure.add(new SFDC2GT_Xml_Stucture__c(Name = 'Account.Id',Object_Name__c = 'Account', Field_Name__c = 'Id', Node_Item_Name__c = '', Node_Name__c = 'Salesforce_ID', Default_Value__c='', Order__c = 10, Message_Code__c = 'SA'));
        xmlStructure.add(new SFDC2GT_Xml_Stucture__c(Name = 'Account.Contacts',Object_Name__c = 'Account', Field_Name__c = 'Contacts', Node_Item_Name__c = 'Cust_Contact', Node_Name__c = 'Cust_Contacts', Default_Value__c='', Order__c = 350, Message_Code__c = 'SA'));
        xmlStructure.add(new SFDC2GT_Xml_Stucture__c(Name = 'Contacts.Phone',Object_Name__c = 'Contacts', Field_Name__c = 'Phone', Node_Item_Name__c = '', Node_Name__c = 'Phone_Nume', Default_Value__c='', Order__c = 60, Message_Code__c = 'SA'));
        xmlStructure.add(new SFDC2GT_Xml_Stucture__c(Name = 'Contacts.Account.Id',Object_Name__c = 'Contacts', Field_Name__c = 'Account.Id', Node_Item_Name__c = '', Node_Name__c = 'AccountId', Default_Value__c='', Order__c = 70, Message_Code__c = 'SA'));
        xmlStructure.add(new SFDC2GT_Xml_Stucture__c(Name = 'Account.Custom_Client_Teams__r',Object_Name__c = 'Account', Field_Name__c = 'Custom_Client_Teams__r', Node_Item_Name__c = 'Internal_Contact', Node_Name__c = 'Internal_Contacts', Default_Value__c='', Order__c = 340, Message_Code__c = 'SA'));
        xmlStructure.add(new SFDC2GT_Xml_Stucture__c(Name = 'Team_Member__r.FirstName',Object_Name__c = 'Custom_Client_Teams__r', Field_Name__c = 'Team_Member__r.FirstName', Node_Item_Name__c = '', Node_Name__c = 'First_Name', Default_Value__c='', Order__c = 10, Message_Code__c = 'SA'));

        insert xmlStructure;

        Test.startTest();
        System.runAs(testUser){
            ApexPages.StandardController controller = new ApexPages.StandardController(olstTestAccount[0]);
            Send_for_Onboarding_Controller soc = new Send_for_Onboarding_Controller(controller);
            List<SelectOption> sccTypeOptions = soc.getSCCTypeItems();
            soc.acct.SCC_Type__c = clientSubClassificationMappings[0].SubClassification__c;
            soc.confirm();

            System.assertEquals(soc.shouldrenderCIBSA, True);
            System.assertEquals(soc.KYCLocation , klrec1.Value__c);
            System.assertEquals(sccTypeOptions.size(), sccMappingsForAssesment.size()+1);

            soc.onboardingService = new OnboardingService(olstTestAccount[0].Id, 'SA');
            Messaging.EmailFileAttachment xmlAttachment = soc.getOnboardingXmlAttachment();
            soc.sendEmail();
            system.assertNotEquals(null, xmlAttachment);
            system.assertEquals(1, Limits.getEmailInvocations());
        }
        Test.stopTest();

    }

    static testMethod void Test_Confirm_one_selected_PBB(){
        KYC_Locations__c klrec1 = new KYC_Locations__c(Name = 'SBSA', Value__c = 'SBSA - Standard Bank of South Africa Ltd');
        KYC_Locations__c klrec2 = new KYC_Locations__c(Name = 'SBAO', Value__c = 'SBAO - Standard Bank de Angola SA');
        KYC_Locations__c klrec3 = new KYC_Locations__c(Name = 'Cote dIvoire', Value__c = 'SBCI - Standard Bank Cote D\'Ivoire SA');
        List<KYC_Locations__c> kycLocations = new List<KYC_Locations__c> {
            klrec1,
            klrec2,
            klrec3
        };
        TEST_DataFactory.insertSettings(new List<Object> {
            new SB_Parameters__c(Name = 'GT_REQ_CODE_SBSA', Value__c = 'SA'),
            TEST_DataFactory.getCcSettings(),
            TEST_DataFactory.getCstTeamRankings(),
            TEST_DataFactory.getCSTManyPerRegionTeamRoles(),
            kycLocations
        });

        List<Account> olstTestAccount = new List<Account> {(Account) new BLD_Account().getRecord()};
        olstTestAccount[0].Status__c = 'New';
        olstTestAccount[0].KYC_Location__c = klrec2.Value__c;
        olstTestAccount[0].Relationship_Roles__c = 'Client';
        insert olstTestAccount[0];

        //create new user
        User testUser = (User) new BLD_USER().useSysAdmin().getRecord();
        testUser.FirstName = 'Firstname';
        testUser.LastName = 'LastName';
        testUser.Email = 'Test.admin@standardbank.co.za';
        system.runAs(new User(Id = UserInfo.getUserId())){
            insert testUser;
        }


        Test.startTest();
        System.runAs(testUser){
            ApexPages.StandardController controller = new ApexPages.StandardController(olstTestAccount[0]);
            Send_for_Onboarding_Controller soc = new Send_for_Onboarding_Controller(controller);
            soc.confirm();
            System.assertEquals(soc.shouldrenderCIBROA, True);
            System.assertEquals(soc.KYCLocation , klrec2.Value__c);
        }
        Test.stopTest();
    }

    static testMethod void Test_Confirm_none_selected(){
        KYC_Locations__c klrec1 = new KYC_Locations__c(Name = 'SBSA', Value__c = 'SBSA - Standard Bank of South Africa Ltd');
        KYC_Locations__c klrec2 = new KYC_Locations__c(Name = 'SBAO', Value__c = 'SBAO - Standard Bank de Angola SA');
        KYC_Locations__c klrec3 = new KYC_Locations__c(Name = 'Cote dIvoire', Value__c = 'SBCI - Standard Bank Cote D\'Ivoire SA');
        List<KYC_Locations__c> kycLocations = new List<KYC_Locations__c> {
            klrec1,
            klrec2,
            klrec3
        };
        TEST_DataFactory.insertSettings(new List<Object> {
            new SB_Parameters__c(Name = 'GT_REQ_CODE_SBSA', Value__c = 'SA'),
            TEST_DataFactory.getCcSettings(),
            TEST_DataFactory.getCstTeamRankings(),
            TEST_DataFactory.getCSTManyPerRegionTeamRoles(),
            kycLocations
        });

        List<Account> olstTestAccount = new List<Account> {(Account) new BLD_Account().getRecord()};
        olstTestAccount[0].Status__c = 'New';
        olstTestAccount[0].KYC_Location__c = klrec1.Value__c;
        olstTestAccount[0].Relationship_Roles__c = 'Agent;Broker';
        insert olstTestAccount[0];

        //create new user
        User testUser = (User) new BLD_USER().useSysAdmin().getRecord();
        system.runAs(new User(Id = UserInfo.getUserId())){
            insert testUser;
        }


        Test.startTest();
        System.runAs(testUser){
            ApexPages.StandardController controller = new ApexPages.StandardController(olstTestAccount[0]);
            Send_for_Onboarding_Controller soc = new Send_for_Onboarding_Controller(controller);
            soc.confirm();
            System.assertEquals(soc.shouldrenderCIBROA, True);
            System.assertEquals(soc.KYCLocation , klrec1.Value__c);
        }
        Test.stopTest();
    }

    static testMethod void Test_Confirm_more_than_one_selected(){
        KYC_Locations__c klrec1 = new KYC_Locations__c(Name = 'SBSA', Value__c = 'SBSA - Standard Bank of South Africa Ltd');
        KYC_Locations__c klrec2 = new KYC_Locations__c(Name = 'SBAO', Value__c = 'SBAO - Standard Bank de Angola SA');
        KYC_Locations__c klrec3 = new KYC_Locations__c(Name = 'Cote dIvoire', Value__c = 'SBCI - Standard Bank Cote D\'Ivoire SA');
        List<KYC_Locations__c> kycLocations = new List<KYC_Locations__c> {
            klrec1,
            klrec2,
            klrec3
        };
        TEST_DataFactory.insertSettings(new List<Object> {
            new SB_Parameters__c(Name = 'GT_REQ_CODE_SBSA', Value__c = 'SA'),
            TEST_DataFactory.getCcSettings(),
            TEST_DataFactory.getCstTeamRankings(),
            TEST_DataFactory.getCSTManyPerRegionTeamRoles(),
            kycLocations
        });

        List<Account> olstTestAccount = new List<Account> {(Account) new BLD_Account().getRecord()};
        olstTestAccount[0].Status__c = 'New';
        olstTestAccount[0].KYC_Location__c = klrec2.Value__c;
        olstTestAccount[0].Relationship_Roles__c = 'Client';
        insert olstTestAccount[0];

        //create new user
        User testUser = (User) new BLD_USER().useSysAdmin().getRecord();
        system.runAs(new User(Id = UserInfo.getUserId())){
            insert testUser;
        }


        Test.startTest();
        System.runAs(testUser){
            ApexPages.StandardController controller = new ApexPages.StandardController(olstTestAccount[0]);
            Send_for_Onboarding_Controller soc = new Send_for_Onboarding_Controller(controller);
            soc.confirm();
            System.assertEquals(soc.shouldrenderCIBROA, True);
            System.assertEquals(soc.KYCLocation , klrec2.Value__c);
        }
        Test.stopTest();
    }

    static testmethod void Test_Confim_Phone_Country_NotFilled(){
        KYC_Locations__c klrec1 = new KYC_Locations__c(Name = 'SBSA', Value__c = 'SBSA - Standard Bank of South Africa Ltd');
        KYC_Locations__c klrec2 = new KYC_Locations__c(Name = 'SBAO', Value__c = 'SBAO - Standard Bank de Angola SA');
        KYC_Locations__c klrec3 = new KYC_Locations__c(Name = 'Cote dIvoire', Value__c = 'SBCI - Standard Bank Cote D\'Ivoire SA');
        List<KYC_Locations__c> kycLocations = new List<KYC_Locations__c> {
            klrec1,
            klrec2,
            klrec3
        };
        List<SubClassification_Mapping__c> clientSubClassificationMappings = TEST_DataFactory.getSubClassificationMappings();
        TEST_DataFactory.insertSettings(new List<Object> {
            new SB_Parameters__c(Name = 'GT_REQ_CODE_SBSA', Value__c = 'SA'),
            TEST_DataFactory.getCcSettings(),
            TEST_DataFactory.getCstTeamRankings(),
            TEST_DataFactory.getCSTManyPerRegionTeamRoles(),
            clientSubClassificationMappings,
            kycLocations
        });

        List<Account> olstTestAccount = new List<Account> {(Account) new BLD_Account().getRecord()};
        olstTestAccount[0].Status__c = 'New';
        olstTestAccount[0].KYC_Location__c = klrec1.Value__c;
        olstTestAccount[0].Relationship_Roles__c = 'Client';


        List<SubClassification_Mapping__c> sccMappingsForAssesment = new List<SubClassification_Mapping__c>();
        if(!clientSubClassificationMappings.isEmpty()){
            olstTestAccount[0].Client_Type_OnBoard__c = clientSubClassificationMappings[0].CLient_Type__c;
            olstTestAccount[0].Business_Classification__c = clientSubClassificationMappings[0].Business_Classification__c;
            sccMappingsForAssesment = [SELECT Id FROM SubClassification_Mapping__c WHERE Client_Type__c=:olstTestAccount[0].Client_Type_OnBoard__c and Business_Classification__c=:olstTestAccount[0].Business_Classification__c];
        }

        insert olstTestAccount[0];


        List<RecordTypeInfo> recordTypes = Contact.SObjectType.getDescribe().getRecordTypeInfos();
        List<contact_Record_Type__c> clientContactRT = new List<contact_Record_Type__c>();
        for(RecordTypeInfo rti : recordTypes){
            clientContactRT.add(new contact_Record_Type__c(Name = rti.getName(), contactRecordTypeID__c = rti.getRecordTypeId()));
        }

        INSERT clientContactRT;

        List<Contact> contacts = new List<Contact> {(Contact) new BLD_Contact().useClientContact().getRecord()};
        for(Contact c: contacts) {
            c.AccountId = olstTestAccount[0].Id;
            c.Phone_Country__c = null;
        }

        insert contacts;

        //create new user
        User testUser = (User) new BLD_USER().useSysAdmin().getRecord();
        testUser.FirstName = 'Firstname';
        testUser.LastName = 'LastName';
        testUser.Email = 'Test.admin@standardbank.co.za';
        system.runAs(new User(Id = UserInfo.getUserId())){
            insert testUser;
        }


        Test.startTest();
        System.runAs(testUser){
            ApexPages.StandardController controller = new ApexPages.StandardController(olstTestAccount[0]);
            Send_for_Onboarding_Controller soc = new Send_for_Onboarding_Controller(controller);
            List<SelectOption> sccTypeOptions = soc.getSCCTypeItems();
            soc.confirm();
            PageReference returnedPageRef = soc.onAfterConfirm();

            System.assertEquals(null, returnedPageRef);
            System.assertEquals(soc.shouldrenderCIBSA, True);
            System.assertEquals(soc.KYCLocation , klrec1.Value__c);
            System.assertEquals(sccTypeOptions.size(), sccMappingsForAssesment.size()+1);
        }
        Test.stopTest();

    }

    static testmethod void Test_Confim_Phone_Country_FilledInPage(){
        KYC_Locations__c klrec1 = new KYC_Locations__c(Name = 'SBSA', Value__c = 'SBSA - Standard Bank of South Africa Ltd');
        KYC_Locations__c klrec2 = new KYC_Locations__c(Name = 'SBAO', Value__c = 'SBAO - Standard Bank de Angola SA');
        KYC_Locations__c klrec3 = new KYC_Locations__c(Name = 'Cote dIvoire', Value__c = 'SBCI - Standard Bank Cote D\'Ivoire SA');
        List<KYC_Locations__c> kycLocations = new List<KYC_Locations__c> {
            klrec1,
            klrec2,
            klrec3
        };
        TEST_DataFactory.insertSettings(new List<Object> {
            new SB_Parameters__c(Name = 'GT_REQ_CODE_SBSA', Value__c = 'SA'),
            TEST_DataFactory.getCcSettings(),
            TEST_DataFactory.getCstTeamRankings(),
            TEST_DataFactory.getCSTManyPerRegionTeamRoles(),
            TEST_DataFactory.getSubClassificationMappings(),
            kycLocations
        });

        List<Account> olstTestAccount = new List<Account> {(Account) new BLD_Account().getRecord()};
        olstTestAccount[0].Status__c = 'New';
        olstTestAccount[0].KYC_Location__c = klrec3.Value__c;
        olstTestAccount[0].Relationship_Roles__c = 'Client';
        insert olstTestAccount[0];

        //create new user
        User testUser = (User) new BLD_USER().useSysAdmin().getRecord();
        testUser.FirstName = 'Firstname';
        testUser.LastName = 'LastName';
        testUser.Email = 'Test.admin@standardbank.co.za';
        system.runAs(new User(Id = UserInfo.getUserId())){
            insert testUser;
        }

        testUser = [ SELECT  Name, Email
        From User
        WHERE Id =: testUser.Id  ];

        olstTestAccount[0].Client_Co_ordinator__r = testUser;
        olstTestAccount[0].Client_Co_ordinator__c = testUser.Id;
        olstTestAccount[0].OwnerId = testUser.Id;
        update olstTestAccount[0];

        List<RecordTypeInfo> recordTypes = Contact.SObjectType.getDescribe().getRecordTypeInfos();
        List<contact_Record_Type__c> clientContactRT = new List<contact_Record_Type__c>();
        for(RecordTypeInfo rti : recordTypes){
            clientContactRT.add(new contact_Record_Type__c(Name = rti.getName(), contactRecordTypeID__c = rti.getRecordTypeId()));
        }

        INSERT clientContactRT;

        List<Contact> contacts = new List<Contact> {(Contact) new BLD_Contact().useClientContact().getRecord()};
        for(Contact c: contacts) {
            c.AccountId = olstTestAccount[0].Id;
            c.Phone_Country__c = null;
        }

        insert contacts;

        Integer updated = 0;
        Test.startTest();
        System.runAs(testUser){
            ApexPages.StandardController controller = new ApexPages.StandardController(olstTestAccount[0]);
            Send_for_Onboarding_Controller soc = new Send_for_Onboarding_Controller(controller);
            soc.shouldrenderCIBSA = true;
            List<SelectOption> sccTypeOptions = soc.getSCCTypeItems();

            for (Contact c :soc.ClientContactList ){
                c.Phone_Country__c = 'USA';
                updated++;
            }

            soc.confirm();
            PageReference returnedPageRef = soc.onAfterConfirm();

            System.assert(!ApexPages.hasMessages(), ApexPages.getMessages());
            System.assertEquals(new PageReference('/' + olstTestAccount[0].Id).getUrl(), returnedPageRef.getUrl());
            System.assertEquals(soc.KYCLocation , klrec3.Value__c);
        }
        Test.stopTest();
        System.assertEquals(updated, [SELECT count() FROM Contact WHERE Phone_Country__c ='USA'], 'Client Contacts wasn\'t updated after confirm' );
    }

}