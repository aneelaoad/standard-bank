/*********************************************************************
@ Author                    : Nitish Kumar
@ Created Date           : August,2013
@description               : Test Class for SyncCCBatchClass batch class

@ Last Modified By  :   Vishnu Vundavalli        
@ Last Modified On  :   10th March 2015
@ Last Modified Reason  : EN-650, Rename Relationship Manager Role to Manager Client Coverage 
                          And Portfolio/Sector Head Role to Sector/Client Coverage Head

@ Last Modified By  :   Petr Svestka
@ Last Modified On  :   29th June 2016
@ Last Modified Reason  : US-1415, unscheduling jobs already executed
 *********************************************************************/
@Istest
public class SyncCCBatchClass_Test {
    
    static testMethod void testSyncCCBatch() {
         
        //insert custom settings
        Environment_Variable__c oEnvironmentVariable = getEnvVariable();
        TEST_DataFactory.insertSettings(new List<Object> {
            oEnvironmentVariable,
            TEST_DataFactory.getCstTeamRankings(),
            TEST_DataFactory.getCSTManyPerRegionTeamRoles()
        });

        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        
        User admUser = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        User testUser1 = (User) new BLD_USER(uow).useSysAdmin().division(DMN_User.GM_DIVISION).getRecord();
        User testUser2 = (User) new BLD_USER(uow).useCib().getRecord();
        User testUser3 = (User) new BLD_USER(uow).useCib().getRecord();
        User testUser4 = (User) new BLD_USER(uow).useCib().getRecord();
        User testUser5 = (User) new BLD_USER(uow).useSysAdmin().division(DMN_User.GM_DIVISION).getRecord();
        User testUser6 = (User) new BLD_USER(uow).useCib().getRecord();
        User testUser7 = (User) new BLD_USER(uow).useCib().getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow.commitWork();
        }
        
        system.runAs(new User(Id = UserInfo.getUserId())){
            insert TEST_DataFactory.getCcSettings();
        }
        
        insert TEST_DataFactory.getUserProfileIds();

        BLD_Account accBld1 = new BLD_Account(uow).useChild()
            .addOpportunity(
                new BLD_Opportunity(uow)
            )
            .addClientTeam(
                new BLD_ClientTeam(uow)
                    .user(testUser1.Id)
                    .coordinator(true)
                    .role(DMN_ClientTeam.ROLE_GM_EXECUTION_MANAGER)
            )
            .addClientTeam(
                new BLD_ClientTeam(uow)
                    .user(testUser2.Id)
                    .ccbm(true)
                    .role(DMN_ClientTeam.ROLE_CREDIT_RISK)
            )
            .addClientTeam(
                new BLD_ClientTeam(uow)
                    .user(testUser3.Id)
                    .role(DMN_ClientTeam.ROLE_EXEC_SPONSOR)
            )
            .addClientTeam(
                new BLD_ClientTeam(uow)
                    .user(testUser4.Id)
                    .role(DMN_ClientTeam.ROLE_ANALYST)
            );

        BLD_Account accBld2 = new BLD_Account(uow).useChild()
            .addOpportunity(
                new BLD_Opportunity(uow)
            )
            .addClientTeam(
                new BLD_ClientTeam(uow)
                    .user(testUser5.Id)
                    .coordinator(true)
                    .role(DMN_ClientTeam.ROLE_GM_EXECUTION_MANAGER)
            )
            .addClientTeam(
                new BLD_ClientTeam(uow)
                    .user(testUser6.Id)
                    .ccbm(true)
                    .role(DMN_ClientTeam.ROLE_CREDIT_RISK)
            )
            .addClientTeam(
                new BLD_ClientTeam(uow)
                    .user(testUser7.Id)
                    .role(DMN_ClientTeam.ROLE_EXEC_SPONSOR)
            )
            .addClientTeam(
                new BLD_ClientTeam(uow)
                    .user(testUser4.Id)
                    .role(DMN_ClientTeam.ROLE_ANALYST)
            );

        new BLD_Account(uow).useChild()
            .proposedClientCoordinator(new User(Id = oEnvironmentVariable.Salesforce_Administration_Id__c));
        
        uow.commitWork();

        System.RunAs(admUser){
        Test.startTest();
        
        merge ((Account) accBld1.getRecord()) ((Account) accBld2.getRecord());
        
        SyncCCBatchClass b = new SyncCCBatchClass();
        b.strQuery='Select Id from Account where id = \''+accBld1.getRecordId()+'\' limit 10';

        for (CronTrigger ct: [SELECT id FROM CronTrigger WHERE nextFireTime = null]) {
            System.abortJob(ct.id);
        }
        
        try{
          String sch = '0 0 23 * * ?';
        system.schedule('Test Batch Class', sch, b);
        
        }
        catch(Exception ex){
            System.assert(false, ex.getMessage());
        }
        
        Test.stopTest();
        
     }
    }

    /**
     * Temporary method for before SyncCCBatchClass_Test is rewritten
     *
     * @return Environment Variable record
     */
    @SuppressWarnings('PMD.AvoidHardcodingId')
    private static Environment_Variable__c getEnvVariable() {

        Environment_Variable__c settings = new Environment_Variable__c();

        settings.SetupOwnerId = UserInfo.getProfileId();
        settings.Admin_Profile_IDs__c = '00e20000000ibPfAAI;00e20000000nNXZAA2;00e20000000nZXIAA2';
        settings.Bank_Contact_Account_Id__c = '0012000000WvK7s';
        settings.Bank_Contact_Record_Id__c = '012200000005FgnAAE';
        settings.BatchErrorEmails__c = 'CIBSACRMITProductionSuppo@standardbank.co.za';
        settings.BRDLiteTemplateID__c = '069200000002zr5';
        settings.BRDTemplateID__c = '069200000002zr0';
        settings.ChangeRequestChecklistID__c = '069200000002zrF';
        settings.ConfirmationEmailHandlerAddress__c = 'acctconfirm@1hunxa46atciwcg46tn5swewd.in.salesforce.com';
        settings.CRM_Production_Support__c = 'cibsacrmitproductionsuppo@standardbank.co.za';
        settings.Draw_Down_Grand_Parent_Products__c = 'Loans';
        settings.Draw_Down_Product_Record_Types__c = 'Lending / Deposits / Commitments';
        settings.FDTemplateID__c = '069200000002zrK';
        settings.GainMarginChangeEMailAddress__c = 'support@forex.com';
        settings.Gain_Partner_Services_email_address__c = 'partnerservices@gaincapital.com';
        settings.Ignore_Validation_Rule__c = false;
        settings.MarketingWebServerURL__c = 'http://corporateandinvestment.standardbank.co.za';
        settings.MoreDocsEmailTemplateId__c = '00X200000013lIW';
        settings.onErrorAddress__c = 'standardfxtrader@standardbank.co.za';
        settings.serverURL__c = '';
        settings.TDLiteTemplateID__c = '069200000002zrj';
        settings.TDTemplateID__c = '069200000002zrP';
        settings.urlTrainingSnippets__c = 'http://bluematter.scmb.co.za';
        settings.Salesforce_Administration_Id__c = '00520000000lPx5';

        return settings;
    }
}