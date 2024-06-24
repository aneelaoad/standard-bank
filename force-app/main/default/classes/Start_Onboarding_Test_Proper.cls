/* @Class Name   : SA_batchJob_ISICMapping_Test_Proper
 * @Description  : Test class for Start_Onboarding.cls
 * @Created By   : Jana Cechova
 * @Created On   : 22 Mar 2016 
 * @Modification Log:  
 * --------------------------------------------------------------------------------------------------
 * @Developer                Date                   Description
 * --------------------------------------------------------------------------------------------------
    @ Last Modified By  : Jana Cechova
    @ Last Modified On  : Jul 22, 2016
    @ Modification Description : US-1479: RTB - Update Existing CommB Onboarding Validations to Validate only Onboarding RecordTypes => user_division__c = 'Commercial Banking 
 * ---------------------------------------------------------------------------------------------------
 * --------------------------------------------------------------------------------------------------
    @ Last Modified By  : Upender Nath Sharma
    @ Last Modified On  : Jan 13, 2017
    @ Modification Description : Test Class Failure , Insert Custom Setting record('Cote dIvoire') 
 * ---------------------------------------------------------------------------------------------------
 
*/

@isTest(SeeAllData = false) 
private class Start_Onboarding_Test_Proper {
    
    public static Map < String, Schema.RecordTypeInfo > mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Id potentialcifRecTypeId = mapAccountRecordTypes.get('Potential (CIF)').getRecordTypeId();
    public static Id potentialgtRecTypeId = mapAccountRecordTypes.get('Potential (Goldtier)').getRecordTypeId();
    public static Id childClientRTId = mapAccountRecordTypes.get('Child').getRecordTypeId();

    private static final String USERNAME = 'dwaeq23123e321312@example.com';
    private static User sysAdmin {
        get {
            if (sysAdmin == null) {
                sysAdmin = [SELECT Id FROM User WHERE Username = :USERNAME];
            }
            return sysAdmin;
        }
        set;
    }

    @testSetup
    private static void defaultData(){
        TEST_DataFactory.generateConfiguration();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            new BLD_USER(USERNAME).useSysAdmin().commitWork();
        }
    } 

    @IsTest
    static void testforCIBSA(){

        Account accRec = (Account) new BLD_Account().usePotential()
            .proposedClientCoordinator(sysAdmin)
            .getRecord();

        System.runAs(sysAdmin) {
            ApexPages.StandardController controller = new ApexPages.StandardController(accRec);
            Start_Onboarding ctrl = new Start_Onboarding(controller);
            
            accRec.KYC_Location__c = 'SBSA - Standard Bank of South Africa Ltd';
            accRec.Relationship_Roles__c = 'Client';
            insert accRec;
            
            ctrl.selectconfirm();

            Account acc = [Select RecordtypeID from Account where ID = : accRec.ID];
            System.assertequals(acc.RecordtypeID, potentialgtRecTypeId );
        }
    }
    
    @IsTest
    static void shouldSetPotentialCIFRecordType(){

         Account accRec = (Account) new BLD_Account().usePotential()
             .proposedClientCoordinator(sysAdmin)
             .getRecord();

         System.runAs(sysAdmin){
            ApexPages.StandardController controller = new ApexPages.StandardController(accRec);
            Start_Onboarding ctrl = new Start_Onboarding(controller);
            
            
            //Update - To test Update Location functionality
            accRec.KYC_Location__c = 'SBAO - Standard Bank de Angola SA';
            accRec.Relationship_Roles__c = 'Client';
            insert accRec;
            
            ctrl.selectconfirm();
            
            // Asserts after update Account
            Account acc1 = [SELECT RecordtypeId FROM Account WHERE Id = : accRec.Id];
            System.assertequals(acc1.RecordtypeID, potentialcifRecTypeId,'RecordType on Account was not changed correctly.');
        }
     }

    @IsTest
    static void testforexception(){

        Account accRec = (Account) new BLD_Account().usePotential()
            .proposedClientCoordinator(sysAdmin)
            .commitWork()
            .getRecord();
        
        system.Test.startTest();
        
        System.runAs(sysAdmin){
            try {
                ApexPages.StandardController controller = new ApexPages.StandardController(accRec);
                Start_Onboarding ctrl = new Start_Onboarding(controller);
                accRec.KYC_Location__c = 'SBAO - Standard Bank de Angola SA';
                update accRec;
                ctrl.selectconfirm();
            }
            catch (Exception ex) {
                System.assert(false, ex.getMessage());
            }
        }
        system.Test.stopTest();
    }
    
    static testMethod void testCifDateAllocationOnClientUpdate() {

        // Create Account
        Account a1 = new Account();
        a1.RecordTypeId = childClientRTId;
        a1.Name = 'Test Client';
        a1.BillingStreet = 'Test street';
        a1.Client_Sector__c = 'Unknown Sector';
        a1.Client_Sub_Sector__c = 'Unknown Sub-Sector';
        a1.Client_Segment__c = 'AB';
        a1.Country_Risk__c = 'India';
        a1.Correspondence_Addr_Line1__c = 'Test Street Line 1';
        a1.Correspondence_City__c = 'City';
        a1.Correspondence_Postal_Code__c = '123456';
        a1.Correspondence_Country__c = 'India';
        a1.BillingCountry = 'South Africa';
        a1.BillingCity = 'Durban';
        a1.Client_Co_ordinator__c = sysAdmin.Id;
        a1.CRT_Client_Types__c = 'Non CRT Account'; //must be set
        a1.CIF_Number_Allocated_date__c = null;
        a1.CIF__c = null;
        a1.CIF_Client_Type__c = DMN_Account.CIF_C_TYPE;
        insert a1;
        system.Test.startTest();

        //Update Account - this should fire the WR
        a1.CIF__c = 'Test ' + 234;
        update a1;

        system.Test.stopTest();
        // Assert after update
        Account aAfterUpd = [SELECT id, CIF__c, CIF_Number_Allocated_date__c FROM Account WHERE id =: a1.id];
        system.assertEquals(system.today(), aAfterUpd.CIF_Number_Allocated_date__c, 'CIF_Number_Allocated_date__c should\'ve been updated via a WR to today');
        //Update - reset the date and confirm it won't be set back to today when a subsequent CIF-number update happens
        aAfterUpd.CIF_Number_Allocated_date__c = system.today().addDays(-1);
        aAfterUpd.CIF__c = 'Test ' + 567;
        update aAfterUpd;
        
        
        // Assert after update
        Account aAfterUpd2 = [SELECT id, CIF__c, CIF_Number_Allocated_date__c FROM Account WHERE id = :a1.id];
        system.assertNotEquals(system.today(), aAfterUpd2.CIF_Number_Allocated_date__c, 'CIF_Number_Allocated_date__c should\'ve not been updated via a WR more than once');
    }
    
    static testMethod void testCifDateAllocationOnClientInsert() {

        // Create Account
        Account a1 = new Account();
        a1.RecordTypeId = childClientRTId;
        a1.Name = 'Test Client';
        a1.BillingStreet = 'Test street';
        a1.Client_Sector__c = 'Unknown Sector';
        a1.Client_Sub_Sector__c = 'Unknown Sub-Sector';
        a1.Client_Segment__c = 'AB';
        a1.Country_Risk__c = 'India';
        a1.Correspondence_Addr_Line1__c = 'Test Street Line 1';
        a1.Correspondence_City__c = 'City';
        a1.Correspondence_Postal_Code__c = '123456';
        a1.Correspondence_Country__c = 'India';
        a1.BillingCountry = 'South Africa';
        a1.BillingCity = 'Durban';
        a1.Client_Co_ordinator__c = sysAdmin.Id;
        a1.CRT_Client_Types__c = 'Non CRT Account'; //must be set
        a1.CIF__c = 'Test ' + 234; //CIF number in the record from the beginning
        a1.CIF_Number_Allocated_date__c = null;
        a1.CIF_Client_Type__c = DMN_Account.CIF_C_TYPE;
        insert a1;

        // Assert after insert
        Account aAfterIns = [SELECT id, CIF__c, CIF_Number_Allocated_date__c FROM Account WHERE id = :a1.id];
        system.assertEquals(system.today(), aAfterIns.CIF_Number_Allocated_date__c, 'CIF_Number_Allocated_date__c should\'ve been updated via a WR to today');
        
        system.Test.startTest();
        
        //Update - reset the date and confirm it won't be set back to today when a subsequent CIF-number update happens
        aAfterIns.CIF_Number_Allocated_date__c = system.today().addDays(-1);
        aAfterIns.CIF__c = 'Test ' + 567;
        update aAfterIns;
        
        system.Test.stopTest();
        
        // Assert after update
        Account aAfterIns2 = [SELECT id, CIF__c, CIF_Number_Allocated_date__c FROM Account WHERE id = :a1.id];
        system.assertNotEquals(system.today(), aAfterIns2.CIF_Number_Allocated_date__c, 'CIF_Number_Allocated_date__c should\'ve not been updated via a WR more than once');
    }
    static testMethod void testCifDateAllocationOnClientInsertWithCommBPRH() {
        // Create user
        User testUser = (User) new BLD_USER().useCommB().getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert testUser;
        }

        system.Test.startTest();
        
        System.runAs(testUser){
            list<Account> olstTestAccount = new List<Account> {(Account) new BLD_Account().usePotential().getRecord()};
           
            ApexPages.StandardController controller = new ApexPages.StandardController(olstTestAccount[0]);
            Start_Onboarding ctrl = new Start_Onboarding(controller);
            
            olstTestAccount[0].primary_relationship_holder__c = 'Commercial Banking';
            olstTestAccount[0].Client_Co_ordinator__c = testUser.id;
            olstTestAccount[0].KYC_Location__c = 'SBAO - Standard Bank de Angola SA';
            olstTestAccount[0].Relationship_Roles__c = 'Agent;Client';
            olstTestAccount[0].KYC_Location__c = DMN_Account.DEFAULT_COMMB_KYC_LOCATION;
            insert olstTestAccount[0];
  
            ctrl.selectconfirm();
            
            // Asserts after update Account
            Account acc1 = [Select RecordtypeID, Onboarded_in_SFDC__c from Account where ID = : olstTestAccount[0].ID];
            System.assertequals(acc1.RecordtypeID, potentialcifRecTypeId, 'RecordType on Account was not changed correctly.');
            System.assertequals(true,acc1.Onboarded_in_SFDC__c, 'Field Onboared in SFDC was not changed correctly.');
        }
        system.Test.stopTest();
    }

    @IsTest
    static void testCodeCoverageIsTestRunning() {
        list<Account> olstTestAccount = new List<Account> {
            (Account) new BLD_Account().usePotential().proposedClientCoordinator(sysAdmin).getRecord()};
        insert olstTestAccount[0];

        olstTestAccount[0].Description = 'TEST_Cover_DML_Exception_2016-03-22'; 
        update olstTestAccount[0];
        
        system.Test.startTest();
        
        System.runAs(sysAdmin){
            try {
                ApexPages.StandardController controller = new ApexPages.StandardController(olstTestAccount[0]);
                Start_Onboarding ctrl = new Start_Onboarding(controller);
                olstTestAccount[0].KYC_Location__c = 'SBAO - Standard Bank de Angola SA';
                olstTestAccount[0].Relationship_Roles__c = 'Agent;Client';
                update olstTestAccount[0];
                ctrl.selectconfirm();
            }
            catch(Exception ex) {
                System.assert(false, ex.getMessage());
            }
        }
        system.Test.stopTest();
    }
}