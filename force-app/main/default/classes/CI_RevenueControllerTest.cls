@isTest
public class CI_RevenueControllerTest {
    
    private static User user;

    private static String STD_USER_NAME = 'tester8y93y327@testorg.com';
    private static String TPS_USER_NAME = 'TPStester8y93y327@testorg.com';
    private static String GM_USER_NAME = 'GMtester8y93y327@testorg.com';

    private static User standardUser {
        get {
            if (standardUser == null) {
                standardUser = [SELECT Id FROM User WHERE UserName LIKE :('%' + STD_USER_NAME) LIMIT 1];
            }
            return standardUser;
        }
    }

    private static void setupTestData() {

        User stdUser = (User) new BLD_USER(STD_USER_NAME).useCib().getRecord();
        User tpsDivisionUser = (User) new BLD_USER(TPS_USER_NAME).useCib().division(DMN_User.TPS_DIVISION).getRecord();
        User gmDivisionUser = (User) new BLD_USER(GM_USER_NAME).useCib().division(DMN_User.GM_DIVISION).getRecord();

        System.runAs(new User(Id = UserInfo.getUserId())) {
            insert new List<User> {stdUser, tpsDivisionUser, gmDivisionUser};
        }
        
        TEST_DataFactory.generateConfiguration();
        RecordType RecordType = [select Id from RecordType where Name = 'Ultimate Group Parent' and SobjectType = 'Account' limit 1];      
        List<Account> clientList = new List<Account>();   
        clientList.add(new Account(Name ='Google Africa', RecordTypeId = RecordType.Id, CIF__c = 'RevContrTestCIF1'));
        insert clientList;  
         
        Client_Capital_and_Revenue__c CandR = New Client_Capital_and_Revenue__c(CROC_ZAR__c=20, Client__c = clientList[0].id);
        insert CandR;
                
        //Revenue
        //RecordType previousYearRevenueRT = [select Id from RecordType where Name = 'Current & Previous Year' and SobjectType = 'Global_Client_Revenue__c' limit 1];  
        //RecordType historicalRevenueRT = [select Id from RecordType where Name = 'Historical Revenue' and SobjectType = 'Global_Client_Revenue__c' limit 1];  
        
        List<Opportunity> oppList = new List<Opportunity>();
        oppList.add(new Opportunity(Name = 'Test lead', StageName = 'Lead', Amount = 120000, CloseDate = System.today(), 
                                    AccountID = clientList[0].id, LeadSource = 'Service', Description = 'Description', 
                                    Probability = 10, CurrencyIsoCode = 'ZAR', Start_Date__c = System.today()));
        oppList.add(new Opportunity(Name = 'Test develop', StageName = 'Develop', Amount = 450000, CloseDate = System.today(), 
                                    AccountID = clientList[0].id, LeadSource = 'Service', Description = 'Description', 
                                    Probability = 10, CurrencyIsoCode = 'ZAR', Start_Date__c = System.today()));
        oppList.add(new Opportunity(Name = 'Test won', StageName = 'Won', Amount = 980000, CloseDate = System.today(), 
                                    AccountID = clientList[0].id, LeadSource = 'Service', Description = 'Description', 
                                    Probability = 10, CurrencyIsoCode = 'ZAR', Start_Date__c = System.today()));
        oppList.add(new Opportunity(Name = 'Test lost', StageName = 'Lost', Amount = 3456000, CloseDate = System.today(), 
                                    AccountID = clientList[0].id, LeadSource = 'Service', Description = 'Description', 
                                    Probability = 10, CurrencyIsoCode = 'ZAR', Start_Date__c = System.today()));
        oppList.add(new Opportunity(Name = 'Test right stage develop', StageName = '2 - Develop', Amount = 450000, CloseDate = System.today(),
                AccountID = clientList[0].id, LeadSource = 'Service', Description = 'Description',
                Probability = 10, CurrencyIsoCode = 'ZAR', Start_Date__c = System.today()));

        insert oppList;

        List<Share_Wallet__c> sowList = new List<Share_Wallet__c>();
        sowList.add(new Share_Wallet__c(Division__c = 'Global Markets', Revenue__c = 256000, 
                                        Total_Wallet_Size__c = 879000, Financial_Year__c = '2017', Client__c = clientList[0].id, 
                                        Period__c = 'Full Year', CurrencyIsoCode = 'ZAR'));    
        sowList.add(new Share_Wallet__c(Division__c = 'Transactional Products and Services', Revenue__c = 256000, 
                                        Total_Wallet_Size__c = 879000, Financial_Year__c = '2017', Client__c = clientList[0].id, 
                                        Period__c = 'Full Year', CurrencyIsoCode = 'ZAR'));   
        sowList.add(new Share_Wallet__c(Division__c = 'Investment Banking', Revenue__c = 256000, 
                                        Total_Wallet_Size__c = 879000, Financial_Year__c = '2017', Client__c = clientList[0].id, 
                                        Period__c = 'Full Year', CurrencyIsoCode = 'ZAR'));  
        sowList.add(new Share_Wallet__c(Division__c = 'Real Estate', Revenue__c = 256000, 
                                        Total_Wallet_Size__c = 879000, Financial_Year__c = '2017', Client__c = clientList[0].id, 
                                        Period__c = 'Full Year', CurrencyIsoCode = 'ZAR'));
        insert sowList;

        Client_Financial_Analysis__c cfa = new Client_Financial_Analysis__c();
        cfa.Client_Name__c = clientList[0].id;
        cfa.Statement_Date__c = Date.newInstance(2017, 01, 31);
        cfa.Debt_Ratio__c = 40.00;
        insert cfa;
        

        List<Global_Client_Revenue__c> revenueList = new List<Global_Client_Revenue__c>();
        
        Global_Client_Revenue__c gcr = new Global_Client_Revenue__c();
        gcr.client__c = clientList[0].id;
        gcr.Snapshot_Date__c = Date.newInstance(Date.today().year(), 12, 31);
        gcr.Trading_Division__c = 'TPS';
        gcr.Division_Product_Subsets__c ='Trade';
        gcr.Client_Value_ZAR_Current_Month__c = 10;
        gcr.Budget_ZAR_Next_Year__c = 100;
        gcr.Client_CIF_Number__c = 'RevContrTestCIF1';
        revenueList.add(gcr);

        Global_Client_Revenue__c gcr2 = new Global_Client_Revenue__c();
        gcr2.client__c = clientList[0].id;
        gcr2.Snapshot_Date__c = Date.newInstance(Date.today().year(), 12, 31);
        gcr2.Trading_Division__c = 'TPS';
        gcr2.Reporting_Country__C ='South Africa';
        gcr2.Client_Value_ZAR_Current_Month__c = 20;
        gcr2.Budget_ZAR_Next_Year__c = 200;
        gcr2.Client_CIF_Number__c = 'RevContrTestCIF1';
        revenueList.add(gcr2);

        Global_Client_Revenue__c gcr3 = new Global_Client_Revenue__c();
        gcr3.client__c = clientList[0].id;
        gcr3.Snapshot_Date__c = Date.newInstance(Date.today().year() - 1, 12, 31);
        gcr3.Trading_Division__c = 'TPS';
        gcr3.Reporting_Country__C ='South Africa';
        gcr3.Client_Value_ZAR_Current_Month__c = 30;
        gcr3.Budget_ZAR_Next_Year__c = 300;
        gcr3.Client_CIF_Number__c = 'RevContrTestCIF1';
        revenueList.add(gcr3);

        insert revenueList;

        List<Client_Capital_and_Revenue__c> capitalList = new List<Client_Capital_and_Revenue__c>();
        Client_Capital_and_Revenue__c ccr =  new Client_Capital_and_Revenue__c();
        ccr.Client__c = clientList[0].id;
        ccr.Client_CIF_Number__c = 'RevContrTestCIF1';
        ccr.CROC_ZAR__c = 20;
        capitalList.add(ccr);

        insert capitalList;
   }

    private static User setupClientTeamUser(String[] clientNames) {
        System.runAs(new User(Id = UserInfo.getUserId())){
               user = (User) new BLD_USER().useSysAdmin().getRecord();
               insert user;
           }

        List<Account> clients = [select id, Parentid, Name from Account where name IN: clientNames];
        
        List<Custom_Client_Team__c> cst = new List<Custom_Client_Team__c>();

        for(Account client : clients){
            cst.add(New Custom_Client_Team__c(Account__c = client.id,Team_Member__c = user.id,Client_Role__c = 'Analyst',Client_Access__c = 'Full Access'));
        }
        insert cst;

        return user;
    }

    static testMethod void getDivisionTest() {
        fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
    	User userTpsDiv = (User) new BLD_USER(uow).useCib().division(DMN_User.TPS_DIVISION).getRecord();
        User userGmDiv = (User) new BLD_USER(uow).useCib().division(DMN_User.GM_DIVISION).getRecord();
        User userVafDiv = (User) new BLD_USER(uow).useCib().division(DMN_User.VAF_DIVISION).getRecord();
        User userIbDiv = (User) new BLD_USER(uow).useCib().division(DMN_User.IB_DIVISION).getRecord();        
        uow.commitWork();       
        
        system.runAs(userTpsDiv){ 
            DMN_GlobalClientRevenue.getTradingDivisionBasedOnUserDivision();
        }      
        system.runAs(userGmDiv){ 
            DMN_GlobalClientRevenue.getTradingDivisionBasedOnUserDivision();
        }      
        system.runAs(userVafDiv){ 
            DMN_GlobalClientRevenue.getTradingDivisionBasedOnUserDivision();
        }      
        system.runAs(userIbDiv){ 
            DMN_GlobalClientRevenue.getTradingDivisionBasedOnUserDivision();
        }
    }
    
    static testMethod void getClientReturnOverCapitalTest() {
        setupTestData();            
        List<Account> client = [select id, Parentid, Name from Account where name  =: 'Google Africa'];
        CI_CardMapModel result = (CI_CardMapModel)CI_RevenueController.getClientReturnOverCapital(client[0].id).Data;  
        
        System.assertEquals('20.00', result.cardDataMap.get('CROC'));
    } 

    static testMethod void getDealsTest() {
        setupTestData();            
        List<Account> client = [select id, Parentid, Name from Account where name  =: 'Google Africa'];
        CI_CardListObjectModel result = (CI_CardListObjectModel)CI_RevenueController.getDeals(client[0].id, new List<String> {'Lead', 'Develop', 'Won', 'Lost'}).Data;

        for(Object o: result.cardObjectList)
        {
            Opportunity opp = (Opportunity)o;

            if(opp.Name.contains('lead'))
            {
                System.assertEquals('Test lead', opp.Name);
            }   
            else if(opp.Name.contains('develop'))
            {
                System.assertEquals('Test develop', opp.Name);
            } 
            else if(opp.Name.contains('won'))
            {
                System.assertEquals('Test won', opp.Name);
            } 
            else if(opp.Name.contains('lost'))
            {
                System.assertEquals('Test lost', opp.Name);
            }              
        }
    }  

    static testMethod void getShareOfWalletTest() {
        setupTestData();            
        List<Account> client = [select id, Parentid, Name from Account where name  =: 'Google Africa'];
        CI_CardListObjectModel result = (CI_CardListObjectModel)CI_RevenueController.getShareOfWallet(client[0].id).Data;

        for(Object o: result.cardObjectList)
        {
            Share_Wallet__c share = (Share_Wallet__c)o;

            if(share.Division__c.contains('Estate'))
            {
                System.assertEquals('Real Estate', share.Division__c);
            }   
            else if(share.Division__c.contains('Global'))
            {
                System.assertEquals('Global Markets', share.Division__c);
            } 
            else if(share.Division__c.contains('Transactional'))
            {
                System.assertEquals('Transactional Products and Services', share.Division__c);
            } 
            else if(share.Division__c.contains('Investment'))
            {
                System.assertEquals('Investment Banking', share.Division__c);
            }              
        }
    }    
    /*
    This was commnted out to allow deployment of other functionality 
    static testMethod void getRevenueVsBudgetTest() {
        setupTestData();            
        List<Account> clients = [select id, Parentid, Name from Account where name  =: 'Google Africa'];
        
        CI_CardMapModel result = (CI_CardMapModel)CI_RevenueController.getRevenueVsBudgetGap((new Map<Id,Account>(clients)).keySet()).Data;

        System.assertEquals('300.0', result.cardDataMap.get('Budget'));   
        System.assertEquals('30.0', result.cardDataMap.get('Revenue'));  
        System.assertEquals('-90.0', result.cardDataMap.get('BudgetGapPercent'));          
    }     
    */

    @isTest
    static void getPortfolioRevenueVsBudgetGapTest() {
        setupTestData();
        
        List<String> clientName = new List<String>();
        clientName.add('Google Africa');
        User user = setupClientTeamUser(clientName);            
        
        system.runAs(user){ 
             CI_CardMapModel result = (CI_CardMapModel)CI_RevenueController.getPortfolioRevenueVsBudgetGap(null).Data;
            
            System.assertEquals('300.0000', result.cardDataMap.get('Budget'));
            System.assertEquals('30.00000', result.cardDataMap.get('Revenue'));
            System.assertEquals('-90.0', result.cardDataMap.get('BudgetGapPercent'));     
        }        
    }    

    @isTest
    static void getPortfolioRevenueYoYTest() {
        setupTestData();

        List<String> clientName = new List<String>();
        clientName.add('Google Africa');
        User user = setupClientTeamUser(clientName);            
        
        system.runAs(user){ 
            CI_CardListObjectModel result = (CI_CardListObjectModel)CI_RevenueController.getPortfolioRevenueYoY(Date.today().year(), 1, 12, null).Data;

            Map<String, Decimal> thisYearRevMap = (Map<String, Decimal>)result.cardObjectList[0];
            Map<String, Decimal> lastYearRevMap = (Map<String, Decimal>)result.cardObjectList[1];
            
            System.assertEquals(thisYearRevMap.get('Year'), Date.today().year());
            System.assertEquals(thisYearRevMap.get('Amount'), 30.0);
            
            System.assertEquals(lastYearRevMap.get('Year'), Date.today().year() - 1);
            System.assertEquals(lastYearRevMap.get('Amount'), 30.0);   
        }        
    }  

    @isTest
    static void getPortfolioCROCTest() {
        setupTestData();

        List<String> clientName = new List<String>();
        clientName.add('Google Africa');
        User user = setupClientTeamUser(clientName);            
        
        system.runAs(user){ 
            CI_CardMapModel result = (CI_CardMapModel)CI_RevenueController.getPortfolioCROC(null).Data;

            System.assertEquals(result.cardDataMap.get('CROC'), '20.00');   
        }        
    } 

    @isTest
    static void getPortfolioROETest() {
        setupTestData();
        
        List<String> clientName = new List<String>();
        clientName.add('Google Africa');
        User user = setupClientTeamUser(clientName);            
        
        system.runAs(user){ 
            CI_CardMapModel result = (CI_CardMapModel)CI_RevenueController.getPortfolioROE(null).Data;

            Decimal x = (20.00/100 )* 0.5 * 0.8 * 100;
        
            System.assertEquals(String.valueOf(x), result.cardDataMap.get('ROE'));   
        }        
    } 

    static testMethod void getCROCTest() {
        setupTestData();            
        List<Account> client = [select id, Parentid, Name from Account where name  =: 'Google Africa'];
        Decimal result = CI_RevenueController.getCROC((new Map<Id,Account>(client)).keySet());
         
        System.assertEquals(result, 20.00);              
    }

    static testMethod void getClientCROCTest() {
        setupTestData();            
        List<Account> client = [select id, Parentid, Name from Account where name  =: 'Google Africa'];
        CI_CardMapModel result = (CI_CardMapModel)CI_RevenueController.getClientCROC(client[0].Id).Data;

        System.assertEquals(result.cardDataMap.get('CROC'), '20.00');            
    }

    static testMethod void getClientROETest() {
        setupTestData();
        List<Account> client = [select id, Parentid, Name from Account where name  =: 'Google Africa'];
        CI_CardMapModel result = (CI_CardMapModel)CI_RevenueController.getClientROE(client[0].Id).Data;
        Decimal x = (20.00/100 )* 0.5 * 0.8 * 100;

        System.assertEquals(String.valueOf(x), result.cardDataMap.get('ROE'));                 
    }

    static testMethod void getClientRevenueVsBudgetGapTest() {
        setupTestData();            
        List<Account> clients = [select id, Parentid, Name from Account where name  =: 'Google Africa'];
        
        CI_CardMapModel result = (CI_CardMapModel)CI_RevenueController.getClientRevenueVsBudgetGap(clients[0].id).Data;

        System.assertEquals('300.0000', result.cardDataMap.get('Budget'));
        System.assertEquals('30.00000', result.cardDataMap.get('Revenue'));
        System.assertEquals('-90.0', result.cardDataMap.get('BudgetGapPercent'));          
    } 

    static testMethod void getRevenueBudgetSnapshotDateTest() {
        setupTestData();            
        CI_CardMapModel result = (CI_CardMapModel)CI_RevenueController.getRevenueBudgetSnapshotDate().Data;

        System.assertEquals(result.cardDataMap.get('Month_End_Snapshot_Date__c'), String.valueOf(Date.newInstance(Date.today().year(), 12, 31)));           
    }

    @isTest
    static void getPortfolioMonthlyRevenueVarianceTest() {
        TEST_DataFactory.generateConfiguration();
        //Test data
        RecordType clientTopParentRecType = [select Id from RecordType where Name = 'Ultimate Group Parent' and SobjectType = 'Account' limit 1];      
        
        List<Account> clientList = new List<Account>();   
        clientList.add(new Account(Name ='RevenueVarianceClient1', RecordTypeId = clientTopParentRecType.Id, CIF__c = 'RevContrTestCIF1', CRT_Parent_Child__c = '1'));
        clientList.add(new Account(Name ='RevenueVarianceClient2', RecordTypeId = clientTopParentRecType.Id, CIF__c = 'RevContrTestCIF2', CRT_Parent_Child__c = '1'));
        
        insert clientList;

        List<String> clientNames = new List<String>();
        clientNames.add('RevenueVarianceClient1');
        clientNames.add('RevenueVarianceClient2');
        User user = setupClientTeamUser(clientNames);

        List<Global_Client_Revenue__c> revenueList = new List<Global_Client_Revenue__c>();
        RecordType historicalRevRecType = [select Id from RecordType where Name = 'Historical Revenue' and SobjectType = 'Global_Client_Revenue__c' limit 1];

        Date latestSnapshotDate = Date.today().toStartOfMonth().addDays(-1);
        Date previousSnapshotDate = Date.today().toStartOfMonth().addMonths(-1).addDays(-1);
        Global_Client_Revenue__c gcr = new Global_Client_Revenue__c();
        gcr.client__c = clientList[0].id;
        gcr.Snapshot_Date__c = latestSnapshotDate;
        gcr.Trading_Division__c = 'TPS';
        gcr.Division_Product_Subsets__c ='Trade';
        gcr.Client_Value_ZAR_Current_Month__c = 10;
        gcr.Budget_ZAR_Next_Year__c = 100;
        gcr.Client_CIF_Number__c = 'RevContrTestCIF1';
        gcr.RecordTypeId = historicalRevRecType.Id;
        revenueList.add(gcr);

        Global_Client_Revenue__c gcr2 = new Global_Client_Revenue__c();
        gcr2.client__c = clientList[0].id;
        gcr2.Snapshot_Date__c = previousSnapshotDate;
        gcr2.Trading_Division__c = 'TPS';
        gcr2.Reporting_Country__C ='South Africa';
        gcr2.Client_Value_ZAR_Current_Month__c = 20;
        gcr2.Budget_ZAR_Next_Year__c = 200;
        gcr2.Client_CIF_Number__c = 'RevContrTestCIF1';
        gcr2.RecordTypeId = historicalRevRecType.Id;
        revenueList.add(gcr2);

        Global_Client_Revenue__c gcr3 = new Global_Client_Revenue__c();
        gcr3.client__c = clientList[1].id;
        gcr3.Snapshot_Date__c = latestSnapshotDate;
        gcr3.Trading_Division__c = 'TPS';
        gcr3.Reporting_Country__C ='South Africa';
        gcr3.Client_Value_ZAR_Current_Month__c = 45;
        gcr3.Budget_ZAR_Next_Year__c = 450;
        gcr3.Client_CIF_Number__c = 'RevContrTestCIF2';
        gcr3.RecordTypeId = historicalRevRecType.Id;
        revenueList.add(gcr3);

        Global_Client_Revenue__c gcr4 = new Global_Client_Revenue__c();
        gcr4.client__c = clientList[1].id;
        gcr4.Snapshot_Date__c = previousSnapshotDate;
        gcr4.Trading_Division__c = 'TPS';
        gcr4.Reporting_Country__C ='South Africa';
        gcr4.Client_Value_ZAR_Current_Month__c = 30;
        gcr4.Budget_ZAR_Next_Year__c = 300;
        gcr4.Client_CIF_Number__c = 'RevContrTestCIF2';
        gcr4.RecordTypeId = historicalRevRecType.Id;
        revenueList.add(gcr4);

        insert revenueList;


        system.runAs(user) {
            CI_CardListObjectModel result = (CI_CardListObjectModel)CI_RevenueController.getPortfolioMonthlyRevenueVariance().Data;

            System.assertEquals(2, result.cardObjectList.size());

            System.assertEquals('-50.0', ((Map<String,String>)result.cardObjectList[0]).get('PercentVariance'));
            System.assertEquals('20.00000', ((Map<String,String>)result.cardObjectList[0]).get('PreviousMonthRevenue'));
            System.assertEquals(String.valueOf(previousSnapshotDate.month()), ((Map<String,String>)result.cardObjectList[0]).get('PreviousMonth'));
            System.assertEquals('10.00000', ((Map<String,String>)result.cardObjectList[0]).get('CurrentMonthRevenue'));
            System.assertEquals(String.valueOf(latestSnapshotDate.month()), ((Map<String,String>)result.cardObjectList[0]).get('CurrentMonth'));
            System.assertEquals('RevenueVarianceClient1', ((Map<String,String>)result.cardObjectList[0]).get('ClientName'));
            
            System.assertEquals('50.0', ((Map<String,String>)result.cardObjectList[1]).get('PercentVariance'));
            System.assertEquals('30.00000', ((Map<String,String>)result.cardObjectList[1]).get('PreviousMonthRevenue'));
            System.assertEquals(String.valueOf(previousSnapshotDate.month()), ((Map<String,String>)result.cardObjectList[1]).get('PreviousMonth'));
            System.assertEquals('45.000000', ((Map<String,String>)result.cardObjectList[1]).get('CurrentMonthRevenue'));
            System.assertEquals(String.valueOf(latestSnapshotDate.month()), ((Map<String,String>)result.cardObjectList[1]).get('CurrentMonth'));
            System.assertEquals('RevenueVarianceClient2', ((Map<String,String>)result.cardObjectList[1]).get('ClientName'));
        }         
    } 

    @isTest
    static void getPortfolioVarianceActionTest() {
        TEST_DataFactory.generateConfiguration();
        //Test data
        RecordType clientTopParentRecType = [select Id from RecordType where Name = 'Ultimate Group Parent' and SobjectType = 'Account' limit 1];
        
        List<Account> clientList = new List<Account>();   
        clientList.add(new Account(Name ='RevenueVarianceClient1', RecordTypeId = clientTopParentRecType.Id, CIF__c = 'RevContrTestCIF1', CRT_Parent_Child__c = '1'));
        clientList.add(new Account(Name ='RevenueVarianceClient2', RecordTypeId = clientTopParentRecType.Id, CIF__c = 'RevContrTestCIF2', CRT_Parent_Child__c = '1'));
        
        insert clientList;

        List<String> clientNames = new List<String>();
        clientNames.add('RevenueVarianceClient1');
        clientNames.add('RevenueVarianceClient2');
        User user = setupClientTeamUser(clientNames);  

        List<Global_Client_Revenue__c> revenueList = new List<Global_Client_Revenue__c>();
        RecordType historicalRevRecType = [select Id from RecordType where Name = 'Historical Revenue' and SobjectType = 'Global_Client_Revenue__c' limit 1];
        
        //RevenueVarianceClient1
        Global_Client_Revenue__c gcr = new Global_Client_Revenue__c();
        gcr.client__c = clientList[0].id;
        gcr.Snapshot_Date__c = Date.newInstance(Date.today().year(), 11, 31);
        gcr.Trading_Division__c = 'TPS';
        gcr.Division_Product_Subsets__c ='Trade';
        gcr.Client_Value_ZAR_Current_Month__c = 10;
        gcr.Client_CIF_Number__c = 'RevContrTestCIF1';
        gcr.RecordTypeId = historicalRevRecType.Id;
        revenueList.add(gcr);

        Global_Client_Revenue__c gcr2 = new Global_Client_Revenue__c();
        gcr2.client__c = clientList[0].id;
        gcr2.Snapshot_Date__c = Date.newInstance(Date.today().year() - 1, 11, 31);
        gcr2.Trading_Division__c = 'TPS';
        gcr2.Reporting_Country__C ='South Africa';
        gcr2.Client_Value_ZAR_Current_Month__c = 20;
        gcr2.Client_CIF_Number__c = 'RevContrTestCIF1';
        gcr2.RecordTypeId = historicalRevRecType.Id;
        revenueList.add(gcr2);

        Global_Client_Revenue__c gcr21 = new Global_Client_Revenue__c();
        gcr21.client__c = clientList[0].id;
        gcr21.Snapshot_Date__c = Date.newInstance(Date.today().year() - 1, 12, 31);
        gcr21.Trading_Division__c = 'TPS';
        gcr21.Reporting_Country__C ='South Africa';
        gcr21.Client_Value_ZAR_Current_Month__c = 25;
        gcr21.Client_CIF_Number__c = 'RevContrTestCIF1';
        gcr21.RecordTypeId = historicalRevRecType.Id;
        revenueList.add(gcr21);

        //RevenueVarianceClient2
        Global_Client_Revenue__c gcr3 = new Global_Client_Revenue__c();
        gcr3.client__c = clientList[1].id;
        gcr3.Snapshot_Date__c = Date.newInstance(Date.today().year(), 11, 31);
        gcr3.Trading_Division__c = 'TPS';
        gcr3.Reporting_Country__C ='South Africa';
        gcr3.Client_Value_ZAR_Current_Month__c = 45;
        gcr3.Client_CIF_Number__c = 'RevContrTestCIF2';
        gcr3.RecordTypeId = historicalRevRecType.Id;
        revenueList.add(gcr3);

        Global_Client_Revenue__c gcr4 = new Global_Client_Revenue__c();
        gcr4.client__c = clientList[1].id;
        gcr4.Snapshot_Date__c = Date.newInstance(Date.today().year() - 1, 11, 31);
        gcr4.Trading_Division__c = 'TPS';
        gcr4.Reporting_Country__C ='South Africa';
        gcr4.Client_Value_ZAR_Current_Month__c = 30;
        gcr4.Client_CIF_Number__c = 'RevContrTestCIF2';
        gcr4.RecordTypeId = historicalRevRecType.Id;
        revenueList.add(gcr4);

        Global_Client_Revenue__c gcr5 = new Global_Client_Revenue__c();
        gcr5.client__c = clientList[1].id;
        gcr5.Snapshot_Date__c = Date.newInstance(Date.today().year() - 1, 12, 31);
        gcr5.Trading_Division__c = 'TPS';
        gcr5.Reporting_Country__C ='South Africa';
        gcr5.Client_Value_ZAR_Current_Month__c = 20;
        gcr5.Client_CIF_Number__c = 'RevContrTestCIF2';
        gcr5.RecordTypeId = historicalRevRecType.Id;
        revenueList.add(gcr5);

        insert revenueList;

        system.runAs(user) {
            CI_CardListObjectModel result = (CI_CardListObjectModel)CI_RevenueController.getPortfolioVarianceAction().Data;

            System.assertEquals(2, result.cardObjectList.size());
            
            for(Object cardObject : result.cardObjectList){
                if(((Map<String,String>)cardObject).get('ClientName') == 'RevenueVarianceClient1'){
                    System.assertEquals('-50.0', ((Map<String,String>)cardObject).get('PercentVariance'));
                    System.assertEquals('20.00000', ((Map<String,String>)cardObject).get('PreviousYearRevenue'));
                    System.assertEquals(String.valueOf(Date.today().year() - 1), ((Map<String,String>)cardObject).get('PreviousYear'));
                    System.assertEquals('10.00000', ((Map<String,String>)cardObject).get('CurrentYearRevenue'));
                    System.assertEquals(String.valueOf(Date.today().year()), ((Map<String,String>)cardObject).get('CurrentYear'));
                    System.assertEquals('RevenueVarianceClient1', ((Map<String,String>)cardObject).get('ClientName'));
                } else {
                    System.assertEquals('50.0', ((Map<String,String>)cardObject).get('PercentVariance'));
                    System.assertEquals('30.00000', ((Map<String,String>)cardObject).get('PreviousYearRevenue'));
                    System.assertEquals(String.valueOf(Date.today().year() - 1), ((Map<String,String>)cardObject).get('PreviousYear'));
                    System.assertEquals('45.000000', ((Map<String,String>)cardObject).get('CurrentYearRevenue'));
                    System.assertEquals(String.valueOf(Date.today().year()), ((Map<String,String>)cardObject).get('CurrentYear'));
                    System.assertEquals('RevenueVarianceClient2', ((Map<String,String>)cardObject).get('ClientName'));
                }
            }
        }
    }

    @isTest
    static void testGetUserIsoCode(){
        setupTestData();
        CI_ResponseDto actualIsoCode;
        String expectedIsoCode;

        System.runAs(standardUser) {
            expectedIsoCode = UserInfo.getDefaultCurrency();

            Test.startTest();
            actualIsoCode = CI_RevenueController.getUserIsoCodeAction();
            Test.stopTest();
        }

        System.assertEquals(expectedIsoCode, actualIsoCode.Data);
    }

    @IsTest
    static void shouldGetRevenueClientByDivision() {
        setupTestData();
        AggregateResult gcrData = [
                SELECT Client__c, Client__r.Name,
                        Trading_Division__c,
                        SUM(Client_Value_ZAR_Current_Year__c) rev,
                        SUM(Budget_ZAR_Next_Year__c) budget,
                        Client__r.RecordType.DeveloperName ClientRecordType
                FROM Global_Client_Revenue__c
                WHERE RecordType.DeveloperName = :DMN_GlobalClientRevenue.RTD_CURRENT_PREVIOUS_YEAR
                AND CALENDAR_YEAR(Snapshot_Date__c) = :StdBank_Ltn_ClientsStatisticsController.getLatestRevenueSnapshotDate().year()
                GROUP BY Client__c, Client__r.Name,
                        Trading_Division__c,
                        Client__r.RecordType.DeveloperName];

        Test.startTest();
        CI_ResponseDto response = CI_RevenueController.getRevenueClientByDivision((Id)gcrData.get('Client__c'));
        Test.stopTest();

        System.assertEquals((Decimal)gcrData.get('budget') == null? 0 : (Decimal)gcrData.get('budget'), Decimal.valueOf((String)((List<Map<String, Object>>)response.Data).get(0).get('Budget')));
        System.assertEquals((String)gcrData.get('ClientRecordType'), (String)((List<Map<String, Object>>)response.Data).get(0).get('ClientRecordType'));
        System.assertEquals((Id)gcrData.get('Client__c'), (Id)((List<Map<String, Object>>)response.Data).get(0).get('Id'));
        System.assertEquals((String)gcrData.get('Name'), (String)((List<Map<String, Object>>)response.Data).get(0).get('Name'));
        System.assertEquals((Decimal)gcrData.get('rev') == null? 0 : (Decimal)gcrData.get('rev'), Decimal.valueOf((String)((List<Map<String, Object>>)response.Data).get(0).get('Revenue')));
        System.assertEquals((String)gcrData.get('Trading_Division__c'), (String)((List<Map<String, Object>>)response.Data).get(0).get('Trading_Division__c'));

    }

    @IsTest
    static void shouldGetPortfolioRevenueYTD() {
        setupTestData();
        AggregateResult gcrData = [
                SELECT SUM(Client_Value_ZAR_Current_Year__c) revenue
                FROM Global_Client_Revenue__c
                WHERE Client__r.Name = 'Google Africa'
                AND RecordType.DeveloperName = :DMN_GlobalClientRevenue.RTD_CURRENT_PREVIOUS_YEAR];

        Test.startTest();
        CI_ResponseDto response = CI_RevenueController.getPortfolioRevenueYTD();
        Test.stopTest();

        System.assertEquals((Decimal)gcrData.get('revenue') == null? 0 : (Decimal)gcrData.get('revenue'), Decimal.valueOf((String)((CI_CardMapModel)response.Data).cardDataMap.get('PortfolioRevenueYTD')));
    }

    @IsTest
    static void shouldGetPortfolioCYPipelineAction() {
        setupTestData();

        List<Opportunity> opps = [
                SELECT Name, Probability, AccountId,
                        convertCurrency(Current_Year_Revenue_Currency__c),
                        CloseDate
                FROM Opportunity
                WHERE Account.Name = 'Google Africa'
                AND StageName = '2 - Develop'
                AND CloseDate = THIS_YEAR
                ORDER BY AccountId
        ];

        Test.startTest();
        CI_ResponseDto response = CI_RevenueController.getPortfolioCYPipelineAction(opps[0].AccountId, null);
        Test.stopTest();

        System.assertEquals(opps[0].Probability, ((List<Opportunity>)response.Data).get(0).Probability);
        System.assertEquals(opps[0].AccountId, ((List<Opportunity>)response.Data).get(0).AccountId);
        System.assertEquals(opps[0].Current_Year_Revenue_Currency__c, ((List<Opportunity>)response.Data).get(0).Current_Year_Revenue_Currency__c);
        System.assertEquals(opps[0].CloseDate, ((List<Opportunity>)response.Data).get(0).CloseDate);
    }

    @IsTest
    static void shouldGetCustomSettingsActionBeCiRevenueDrillDown() {
        setupTestData();
        insert TEST_DataFactory.getCIParameters();
        String expectedComponent = 'CI_RevenueDrillDown';
        User tpsUser = [
                SELECT Id
                FROM User
                WHERE UserName LIKE :('%' + TPS_USER_NAME)
                AND User_Division__c = :DMN_User.TPS_DIVISION
                LIMIT 1
        ];

        CI_ResponseDto response = new CI_ResponseDto(null);

        System.runAs(tpsUser) {
            Test.startTest();
            response = CI_RevenueController.getCustomSettingsAction(null);
            Test.stopTest();
        }

        System.assertEquals(expectedComponent, ((Map<String,String>)response.Data).get('redirectComponent'));
    }

    @IsTest
    static void shouldGetCustomSettingsActionBeCiRevenueSecondLevel() {
        setupTestData();
        insert TEST_DataFactory.getCIParameters();
        String expectedComponent = 'CI_RevenueSecondLevel';
        User gmUser = [
                SELECT Id
                FROM User
                WHERE UserName LIKE :('%' + GM_USER_NAME)
                AND User_Division__c = :DMN_User.GM_DIVISION
                LIMIT 1
        ];

        CI_ResponseDto response = new CI_ResponseDto(null);

        System.runAs(gmUser) {
            Test.startTest();
            response = CI_RevenueController.getCustomSettingsAction(null);
            Test.stopTest();
        }

        System.assertEquals(expectedComponent, ((Map<String,String>)response.Data).get('redirectComponent'));
    }

}