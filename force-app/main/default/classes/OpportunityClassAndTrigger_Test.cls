/*************************************************************************\
@ Author        :     Shaveen Bageloo
@ Date          :     13 Apr 2011
@ Test File     :     N/A
@description   :     Test Class for Opportunity Inserts / Updates.
@ Last Modified By  :   Caro Reinecke
@ Last Modified On  :   10 Jun 2011
@ Last Modified Reason  :   Renamed according to Standards
Regression - Globalise User Profiles: Moved validation rules and workflow code to trigger
Tests modified to cater for CRT Feed functionality as defined in OpportunityTriggerUtility.

@ Last Modified By  : Jorel Naidoo
@ Last Modified On  : August 2012
@ Modification Description : CR #7027 - Update Test Class Effected by the validation rules: 
Populate_One_Total_Value & Populate_One_Current_Year_Value on SB_Product__c Object.
Updated to use the TestFactoryUtils class
API Version moved from 21 to 25 

@ Last Modified By  : Nitish Kumar
@ Last Modified On  : Feb 2013
@ Modification Description : EN 31 - Used TestDataUtilityClass 
Added Best Practices
API Version moved from 25 to 27
@                          
@ Last Modified By  :   Navin Rai
@ Last Modified On  :   14/06/2013
@ Last Modified Reason  : EN-101.Reverted to standard OpportunityTeamMember.Hence,removed 
@                         Custom_sales_Team functinality.
@                         Changed the version to 28. 

@Last Modified By   : Abhishek V
@Last Modified on   : 18/11/2015
@Last Modified Reason: Due to a validation inclusion for EN - 0916, it is not possible to add products for a closed opportunity.                             

@Last Modified By   : Jana Cechova 
@Last Modified on   : 2 May, 2016
@Last Modified Reason: Updated test classes based on best practice.      

@ Last Modified By  : Abhishek V
@ Last Modified On  : July 5, 2016
@ Modification Description : Combined individual update statement to update of list in method testOpportunityTriggerUtility2 to avoid SOQL 101.    

@ Last Modified By  : Abhishek V
@ Last Modified On  : November 15, 2016
@ Modification Description : Migrated Test.starttest() in testOpportunityTriggerUtility2 method to avoid SOQL error.            
****************************************************************************/
@isTest(SeeAllData=false)
private class OpportunityClassAndTrigger_Test{
    
    public static Map < String, Schema.RecordTypeInfo > mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Id prospectRecTypeId = mapAccountRecordTypes.get('Child').getRecordTypeId();
    public static List < Account > olstAccount;
    public static List <Opportunity> olstOpportunity ;
    public static User user01;
    public static User user02;
    public static User user03;
    public static List<SB_Product__c> olstOppProduct ;
    public static List<Custom_Client_Team__c> olstCustomClientTeam ;
    public static List<ClientTeamOpportunity_Products__c> olstClientTeamOpportunityProducts ;
    private static final Integer NUM_OF_RECS = 2;
    
    static void createTestData() {        
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
        user01 = (User) new BLD_USER(uow).useSysAdmin()
            .division(DMN_User.GM_DIVISION)
            .businessUnit(DMN_User.BU_BUY_SIDE)
            .cibGlobalArea(DMN_User.CIB_GA_CIBSA)
            .getRecord();
        
        user02 = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        user03 = (User) new BLD_USER(uow).useSysAdmin().getRecord();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            uow.commitWork();
        }
        
        TEST_DataFactory.insertSettings(new List<Object> {
            TEST_DataFactory.getCcSettings(),
                TEST_DataFactory.getErrorMessages(),
                TEST_DataFactory.getEnvironmentVariable(),
                TEST_DataFactory.getUserProfileIds(),
                TEST_DataFactory.getCstTeamRankings()
                });
        
        olstAccount = new List<Account>();
        for (Integer i = 0; i < NUM_OF_RECS; i++) {
            olstAccount.add(
                (Account) new BLD_Account().useChild()
                .name('test Acc ' + i)
                .clientRelationshipHierarchy(null)
                .getRecord()
            );
        }
        insert olstAccount;
        
        olstOpportunity = new List<Opportunity>();
        for (Integer i = 0; i < NUM_OF_RECS; i++) {
            olstOpportunity.add(
                (Opportunity) new BLD_Opportunity()
                .name('test Opp ' + i)
                .linkAccountId(olstAccount[i].Id)
                .getRecord()
            );
        }
        
    }
    
    static testMethod void testOpportunityTriggerUtilityOther () {
        createTestData();
        Account onlyClient = new Account(Name = 'Testing Account');
        insert onlyClient;
        
        // Create common test Opportunities
        List<Opportunity> allOpportunities = new List<Opportunity>();
        
        
        Map<Id,Opportunity> allOpportunitiesMp = new Map<Id,Opportunity>();
        Map<Id,Opportunity> allOpportunitiesMpOld = new Map<Id,Opportunity>();
        
        
        Opportunity x7Opp = new Opportunity(ownerid=user01.Id, StageName = '1 - Lead', AccountId = onlyClient.Id, Name = 'Opportunity For Testing 7 Days Email Alerts', CloseDate = System.today().addDays(7));
        Opportunity x14Opp = new Opportunity(ownerid=user01.Id,StageName = '1 - Lead', AccountId = onlyClient.Id, Name = 'Opportunity For Testing 14 Days Email Alerts', CloseDate = System.today().addDays(14));
        Opportunity x90Opp = new Opportunity(ownerid=user01.Id,StageName = '1 - Lead', AccountId = onlyClient.Id, Name = 'Opportunity For Testing 90 Days Email Alerts', CloseDate = System.today().addDays(-90));
        allOpportunities.add(x7Opp);
        allOpportunities.add(x14Opp);
        allOpportunities.add(x90Opp);
        insert allOpportunities;
        
        for(Opportunity op: allOpportunities){
            allOpportunitiesMp.put(op.Id,op);
            opportunity temp = op.clone(false, false, false, false);   
            temp.ownerId=user03.Id;
            allOpportunitiesMpOld.put(op.Id,temp );
        }
        
        system.Test.startTest();
        OpportunityTriggerUtility.SendEmailforOwnerChanged (allOpportunitiesMp, allOpportunitiesMp);
        
        
        OpportunityTriggerUtility.retrieveRecordTypeId('Opportunity Path');
        
        OpportunityTriggerUtility.SendEmailforOwnerChanged(allOpportunitiesMp, allOpportunitiesMpOld);//owner change
            system.Test.stopTest();
    }
    static testMethod void testOpportunityTriggerUtility1And2 () {
        
        List<Account> acctoupdatelst = new List<Account>();
        List<Opportunity> opptoupdatelst = new List<Opportunity>();
        createTestData();
        try{
            System.runAs(user01) {                
                //insert olstOpportunity;
                
                olstAccount[0].OwnerId = user01.id;
                olstAccount[0].CIF_Customer_Reporting_Country__c = 'SOUTH AFRICA';
                acctoupdatelst.add(olstAccount[0]);
                
                olstAccount[1].OwnerId = user01.id; 
                olstAccount[1].CIF_Customer_Reporting_Country__c = 'ZAMBIA';
                acctoupdatelst.add(olstAccount[1]);
                update acctoupdatelst;
                
                olstOpportunity = new List<Opportunity>();
                for (Integer i = 0; i < NUM_OF_RECS; i++) {
                    olstOpportunity.add(
                        (Opportunity) new BLD_Opportunity()
                        .name('test Opp ' + i)
                        .linkAccountId(olstAccount[i].Id)
                        .getRecord()
                    );
                }
                insert olstOpportunity;
                
                
                olstOpportunity[0].AccountId = olstAccount[1].id;
                opptoupdatelst.add(olstOpportunity[0]);
                
                olstOpportunity[1].StageName='4 - Closed Lost';
                olstOpportunity[1].Reason_Won_Lost_Comments__c='Test reason for Won';
                olstOpportunity[1].ReasonForWinLossPickList__c='Legal';
                olstOpportunity[1].Reason_Won_Lost_Detail__c='Legal Terms Unfavourable';
                olstOpportunity[1].recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Opportunity Path').getRecordTypeId();
                opptoupdatelst.add(olstOpportunity[1]);
                update opptoupdatelst;
                
                
                olstOppProduct = new List<SB_Product__c>();
                for (Integer i = 0; i < NUM_OF_RECS; i++) {
                    olstOppProduct.add(
                        (SB_Product__c) new BLD_Product()
                        .linkToOpp(olstOpportunity[i].Id)
                        .getRecord()
                    );
                }
                insert olstOppProduct[0] ;

                olstCustomClientTeam = new List<Custom_Client_Team__c>();
                for (Integer i = 0; i < NUM_OF_RECS; i++) {
                    olstCustomClientTeam.add(
                        (Custom_Client_Team__c) new BLD_ClientTeam()
                        .account(olstAccount[i].Id)
                        .role(DMN_ClientTeam.ROLE_CREDIT_RISK)
                        .user(user02.Id)
                        .getRecord()
                    );
                }
                insert olstCustomClientTeam ;
                
                olstClientTeamOpportunityProducts = new List<ClientTeamOpportunity_Products__c>();
                for (Integer i = 0; i < NUM_OF_RECS; i++) {
                    olstClientTeamOpportunityProducts.add(
                        new ClientTeamOpportunity_Products__c(
                            Custom_Client_Team__c = olstCustomClientTeam[i].Id
                        )
                    );
                }
                insert olstClientTeamOpportunityProducts ;
                system.Test.startTest();
                
                olstOppProduct = new List<SB_Product__c> {
                    (SB_Product__c) new BLD_Product()
                        .linkToOpp(olstOpportunity[0].Id)
                        .getRecord()
                        };
                            // modifed for EN - 916
                            insert olstOppProduct[0] ;
                
                olstCustomClientTeam = new List<Custom_Client_Team__c>();
                for (Integer i = 0; i < NUM_OF_RECS; i++) {
                    olstCustomClientTeam.add(
                        (Custom_Client_Team__c) new BLD_ClientTeam()
                        .account(olstAccount[i].Id)
                        .role(DMN_ClientTeam.ROLE_CREDIT_RISK)
                        .user(user03.Id)
                        .getRecord()
                    );
                }
                insert olstCustomClientTeam ;
                
                olstClientTeamOpportunityProducts = new List<ClientTeamOpportunity_Products__c>();
                for (Integer i = 0; i < NUM_OF_RECS; i++) {
                    olstClientTeamOpportunityProducts.add(
                        new ClientTeamOpportunity_Products__c(
                            Custom_Client_Team__c = olstCustomClientTeam[i].Id,
                            Opportunity__c = olstOpportunity[i].Id
                        )
                    );
                }
                insert olstClientTeamOpportunityProducts ;
                
                // modifed for EN - 916
                olstOppProduct[0].Client__c =  olstAccount[0].id ;
                update olstOppProduct[0];
                
                olstOppProduct[0].SA_Current_known_conflict_of_interest__c='none'; 
                update olstOppProduct[0] ;
                
                olstOpportunity[0].AccountId = olstAccount[0].id;
                update olstOpportunity[0];
                
                delete olstOppProduct[0];
                delete olstClientTeamOpportunityProducts[1];
                system.Test.stopTest();
                
                olstOpportunity[1].IsPrivate = true;
                update olstOpportunity;
                
                delete olstOpportunity;
            }   
        }catch (Exception ex) {
            system.debug('error:'+ex.getStackTraceString());
            System.assert(false);
        }
    }     
}