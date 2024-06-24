/*************************************************************************\
    @ Author        :     Vaishali Singh
    @ Date          :     19 January 2015
    @description   :     EN-0482: Opportunity Transfer Action on SF1
****************************************************************************/
@SuppressWarnings('PMD.ClassNamingConventions')
@IsTest(SeeAllData=false)
private class ownerTransferCntrlSF1_Test {
    
    // Get Account Record type Map
    public static Map < String, Schema.RecordTypeInfo > mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    // Get the record type id of from the Map based on the Name
    public static Id prospectRecTypeId = mapAccountRecordTypes.get('Child').getRecordTypeId();
    
    //Static data Member
    public static User testUser;
    public static String strUser;

    @IsTest
    static void testController() {

        Test.startTest();
        ApexPages.StandardController controller;
        ownerTransferCntrlSF1 oppTransferSF1;
         //Setup Test Data
        testUser = (User) new BLD_USER().useCib().getRecord();
        testUser.User_Division__c = 'Global Markets'; 
        testUser.Business_Unit__c = 'CRM IT'; 
        testUser.User_CIB_Global_Area__c = 'CIBSA';
        testUser.Force_Owner_to_Add_Opportunity_Product__c = true;
        insert testUser;

        // Create a Test Account
        System.runAs(testUser) {

            Account oTestClient = new Account();
            oTestClient.RecordTypeId = prospectRecTypeId;
            oTestClient.Name = 'Test Client 1'  ;
            oTestClient.BillingStreet = 'Test street 1' ;
            oTestClient.Client_Sector__c = 'Unknown Sector';
            oTestClient.Client_Sub_Sector__c = 'Unknown Sub-Sector';
            oTestClient.Client_Segment__c = 'AB';
            oTestClient.Country_Risk__c = 'India';
            oTestClient.Correspondence_Addr_Line1__c = 'Test Street Line 1' ;
            oTestClient.Correspondence_City__c = 'City';
            oTestClient.Correspondence_Postal_Code__c = '123456';
            oTestClient.Correspondence_Country__c = 'India';
            oTestClient.BillingCountry = 'South Africa';
            oTestClient.BillingCity = 'Durban';
            oTestClient.Client_Co_ordinator__c = UserInfo.getUserID();
            insert oTestClient;
            
            Opportunity opp = new Opportunity();
            opp.AccountId= oTestClient.Id;
            opp.Name= 'Opportunity_'+ oTestClient.Name;
            opp.CloseDate=System.today();
            opp.StageName='2 - Develop';
            opp.Short_Summary__c = 'test opportunity';
            opp.CurrencyIsoCode = 'ZAR';
            insert opp;

            try {
                Test.setCurrentPage(Page.TransferOppOwner);
                ApexPages.currentPage().getParameters().put('Id', opp.Id);
                controller = new ApexPages.StandardController(opp);
                oppTransferSF1 = new ownerTransferCntrlSF1(controller);
                ownerTransferCntrlSF1.oppWrapper objOpp = new ownerTransferCntrlSF1.oppWrapper();
                objOpp.oppId= opp.id;
                strUser = 'va';
                ownerTransferCntrlSF1.save(objOpp);
                ownerTransferCntrlSF1.getUserList(strUser);
            }
            catch (Exception ex) {
                System.assert(false, ex.getMessage());
            }

        }
        Test.StopTest();  
    }
}