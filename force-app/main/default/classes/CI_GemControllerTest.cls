@isTest
public class CI_GemControllerTest {
    private static User user;
    
    private static User getTestUser() {
        
        System.runAs(new User(ID = UserInfo.getUserID())){
               user = (User) new BLD_USER().useSysAdmin().getRecord();
               insert user;
           }
        return user;
    }

    private static void addUserToClientTeam(User user, Account client) {

        Account acc = [
                SELECT Parentid, Name
                FROM Account
                WHERE Id = :client.Id
        ];

        Custom_Client_Team__c cct = new Custom_Client_Team__c();
        cct.account__c = acc.Id;
        cct.client_Access__c = 'Read/Write';
        cct.client_Role__c = 'Analyst';
        cct.team_Member__c = user.Id;
        insert cct;
    }

    private static Account createTestClient(String clientName) {
        // RecordType clientTopParentRecType = [SELECT Id FROM RecordType WHERE Name = 'Ultimate Group Parent' AND SobjectType = 'Account' LIMIT 1];
        Id clientTopParentRecTypeId = UTL_RecordType.getRecordTypeId(DMN_Account.OBJ_NAME, DMN_Account.RT_ULTIMATE_PARENT);
        Account client = new Account(Name = clientName, RecordTypeId = clientTopParentRecTypeId, CIF__c = clientName + 'CIF', CIF_Client_Type__c = 'R');
        insert client;

        return client;
    }

    @isTest(SeeAllData=false)
    static void getGemsActionTest() {
        ////TEST DATA
        //Create client
        Account testClient = createTestClient('GemTestClient1');

        //Get test user
        User testUser = getTestUser();

        //Add test user to test client's CST
        addUserToClientTeam(testUser, testClient);

        //Lead gems
        Id newsLeadRecordTypeId = Schema.SObjectType.CI_Gem__c.getRecordTypeInfosByName().get('News Lead').getRecordTypeId();

        List<CI_Gem__c> gemsToInsert = new List<CI_Gem__c>();

        //Portfolio lead gems (not related to a client)
        CI_Gem__c gem1 = new CI_Gem__c();
        gem1.User__c = testUser.Id;
        gem1.Data__c = '{"articleId":"TestArticleID1","articleTitle":"TestTitle1"}';
        gem1.RecordTypeId = newsLeadRecordTypeId;


        CI_Gem__c gem2 = new CI_Gem__c();
        gem2.User__c = testUser.Id;
        gem2.Data__c = '{"articleId":"TestArticleID2","articleTitle":"TestTitle2"}';
        gem2.Deleted__c = true;
        gem2.RecordTypeId = newsLeadRecordTypeId;

        //Client lead gems
        CI_Gem__c gem3 = new CI_Gem__c();
        gem3.User__c = testUser.Id;
        gem3.Data__c = '{"articleId":"TestArticleID3","articleTitle":"TestTitle3"}';
        gem3.Client__c = testClient.Id;
        gem3.RecordTypeId = newsLeadRecordTypeId;

        CI_Gem__c gem4 = new CI_Gem__c();
        gem4.User__c = testUser.Id;
        gem4.Data__c = '{"articleId":"TestArticleID4","articleTitle":"TestTitle4"}';
        gem4.Client__c = testClient.Id;
        gem4.RecordTypeId = newsLeadRecordTypeId;

        gemsToInsert.add(gem1);
        gemsToInsert.add(gem2);
        gemsToInsert.add(gem3);
        gemsToInsert.add(gem4);

        insert gemsToInsert;

        ////TEST
        system.runAs(testUser) {
            //Make sure LastViewedDate is set
            Account viewAccount = [SELECT Id From Account Where Id = :testClient.Id FOR VIEW];

            String returnValue = '[{"An":"TestArticleID5","Title":"TestTitle5","Pred":1,"Medium_Prob_Clients":"GemTestClient1", "Publication_Date":"2019:05:05T12:00:00:00"},{"An":"TestArticleID6","Title":"TestTitle6","Pred":0,"Medium_Prob_Clients":"GemTestClient1", "Publication_Date":"2019:05:05T12:00:00:00"}]';
            Test.setMock(HttpCalloutMock.class, new CI_SingleRequestMock(200, 'Complete', returnValue, null));

            Test.startTest();

            //No client test
            List<CI_Gem__c> respGemList = (List<CI_Gem__c>) CI_GemController.getGemsAction(null).Data;

            System.assertEquals(3, respGemList.size());

            /* String articleId0 = (String)((Map<String, Object>)JSON.deserializeUntyped(respGemList[0].Data__c)).get('articleId');
            String articleTitle0 = (String)((Map<String, Object>)JSON.deserializeUntyped(respGemList[0].Data__c)).get('articleTitle');
            String articleId1 = (String)((Map<String, Object>)JSON.deserializeUntyped(respGemList[1].Data__c)).get('articleId');
            String articleTitle1 = (String)((Map<String, Object>)JSON.deserializeUntyped(respGemList[1].Data__c)).get('articleTitle');
            
            System.assertEquals('TestArticleID5', articleId0);
            System.assertEquals('TestTitle5', articleTitle0);
            System.assertEquals('TestArticleID3', articleId1);
            System.assertEquals('TestTitle3', articleTitle1); */

            Test.stopTest();
        }
    }

    @isTest(SeeAllData=false)
    static void getClientGemsActionTest() {
        ////TEST DATA
        //Create client
        Account testClient = createTestClient('GemTestClient1');

        //Get test user
        User testUser = getTestUser();

        //Add test user to test client's CST
        addUserToClientTeam(testUser, testClient);

        //Lead gems
        Id newsLeadRecordTypeId = Schema.SObjectType.CI_Gem__c.getRecordTypeInfosByName().get('News Lead').getRecordTypeId();

        List<CI_Gem__c> gems = new List<CI_Gem__c>();

        //Client lead gems
        CI_Gem__c gem1 = new CI_Gem__c();
        gem1.User__c = testUser.Id;
        gem1.Data__c = '{"articleId":"TestArticleID3","articleTitle":"TestTitle3"}';
        gem1.Client__c = testClient.Id;
        gem1.RecordTypeId = newsLeadRecordTypeId;

        CI_Gem__c gem2 = new CI_Gem__c();
        gem2.User__c = testUser.Id;
        gem2.Data__c = '{"articleId":"TestArticleID4","articleTitle":"TestTitle4"}';
        gem2.Deleted__c = true;
        gem2.Client__c = testClient.Id;
        gem2.RecordTypeId = newsLeadRecordTypeId;

        gems.add(gem1);
        gems.add(gem2);
        insert gems;

        ////TEST
        system.runAs(testUser) {
            String returnValue = '[{"An":"TestArticleID5","Title":"TestTitle5","Pred":1,"Medium_Prob_Clients":"GemTestClient1", "Publication_Date":"2019:05:05T12:00:00:00"},{"An":"TestArticleID6","Title":"TestTitle6","Pred":0,"Medium_Prob_Clients":"GemTestClient1", "Publication_Date":"2019:05:05T12:00:00:00"}]';
            Test.setMock(HttpCalloutMock.class, new CI_SingleRequestMock(200, 'Complete', returnValue, null));

            Test.startTest();
            List<CI_Gem__c> respGemList = (List<CI_Gem__c>) CI_GemController.getGemsAction(testClient.Id).Data;

            System.assertEquals(1, respGemList.size());

            Test.stopTest();
        }
    }

    @isTest(SeeAllData=false)
    static void checkAndInsertLeadGemsTest() {
        ////TEST DATA
        //Create client
        Account testClient = createTestClient('GemTestClient1');

        //Get test user
        User testUser = getTestUser();

        //Add test user to test client's CST
        addUserToClientTeam(testUser, testClient);

        //Lead gems
        Id newsLeadRecordTypeId = Schema.SObjectType.CI_Gem__c.getRecordTypeInfosByName().get('News Lead').getRecordTypeId();
        List<CI_Gem__c> gemsToInsert = new List<CI_Gem__c>();

        //Portfolio lead gems (not related to a client)
        CI_Gem__c gem1 = new CI_Gem__c();
        gem1.User__c = testUser.Id;
        gem1.Data__c = '{"articleId":"TestArticleID1","articleTitle":"TestTitle1"}';
        gem1.RecordTypeId = newsLeadRecordTypeId;

        CI_Gem__c gem2 = new CI_Gem__c();
        gem2.User__c = testUser.Id;
        gem2.Data__c = '{"articleId":"TestArticleID2","articleTitle":"TestTitle2"}';
        gem2.Deleted__c = true;
        gem2.RecordTypeId = newsLeadRecordTypeId;

        //Client lead gems
        CI_Gem__c gem3 = new CI_Gem__c();
        gem3.User__c = testUser.Id;
        gem3.Data__c = '{"articleId":"TestArticleID3","articleTitle":"TestTitle3"}';
        gem3.Client__c = testClient.Id;
        gem3.Deleted__c = true;
        gem3.RecordTypeId = newsLeadRecordTypeId;

        CI_Gem__c gem4 = new CI_Gem__c();
        gem4.User__c = testUser.Id;
        gem4.Data__c = '{"articleId":"TestArticleID4","articleTitle":"TestTitle4"}';
        gem4.Deleted__c = true;
        gem4.Client__c = testClient.Id;
        gem4.RecordTypeId = newsLeadRecordTypeId;

        gemsToInsert.add(gem1);
        gemsToInsert.add(gem2);
        gemsToInsert.add(gem3);
        gemsToInsert.add(gem4);

        insert(gemsToInsert);
        //Articles
        List<ArticleNews__c> articleList = new List<ArticleNews__c>();

        //New article lead
        ArticleNews__c article = new ArticleNews__c();
        article.An__c = 'TestArticleID5';
        article.Title__c = 'TestTitle5';
        article.Pred__c = true;
        articleList.add(article);

        //New Non-lead article lead
        article = new ArticleNews__c();
        article.An__c = 'TestArticleID6';
        article.Title__c = 'TestTitle6';
        articleList.add(article);

        //Existing article lead
        article = new ArticleNews__c();
        article.An__c = 'TestArticleID4';
        article.Title__c = 'TestTitle4';
        article.Pred__c = true;
        articleList.add(article);
        
        ////TEST
        system.runAs(testUser){
            CI_GemLeadController.checkAndInsertLeadGems(articleList, null);

            List<CI_Gem__c> gems = [SELECT Id FROM CI_Gem__c WHERE User__c =: UserInfo.getUserId()];

            //4 existing + 1 new
            System.assertEquals(5, gems.size());
        }
    }

    @isTest(SeeAllData=false)
    static void getLeadGemsTest() {
        ////TEST DATA
        //Create client
        Account testClient = createTestClient('GemTestClient1');

        //Get test user
        User testUser = getTestUser();

        //Add test user to test client's CST
        addUserToClientTeam(testUser, testClient);

        //Lead gems
        Id newsLeadRecordTypeId = Schema.SObjectType.CI_Gem__c.getRecordTypeInfosByName().get('News Lead').getRecordTypeId();

        List<CI_Gem__c> gemsToInsert = new List<CI_Gem__c>();
        //Portfolio lead gems (not related to a client)
        CI_Gem__c gem1 = new CI_Gem__c();
        gem1.User__c = testUser.Id;
        gem1.Data__c = '{"articleId":"TestArticleID1","articleTitle":"TestTitle1"}';
        gem1.RecordTypeId = newsLeadRecordTypeId;

        CI_Gem__c gem2 = new CI_Gem__c();
        gem2.User__c = testUser.Id;
        gem2.Data__c = '{"articleId":"TestArticleID2","articleTitle":"TestTitle2"}';
        gem2.Deleted__c = true;
        gem2.RecordTypeId = newsLeadRecordTypeId;

        //Client lead gems
        CI_Gem__c gem3 = new CI_Gem__c();
        gem3.User__c = testUser.Id;
        gem3.Data__c = '{"articleId":"TestArticleID3","articleTitle":"TestTitle3"}';
        gem3.Client__c = testClient.Id;
        gem3.RecordTypeId = newsLeadRecordTypeId;

        CI_Gem__c gem4 = new CI_Gem__c();
        gem4.User__c = testUser.Id;
        gem4.Data__c = '{"articleId":"TestArticleID4","articleTitle":"TestTitle4"}';
        gem4.Deleted__c = true;
        gem4.Client__c = testClient.Id;
        gem4.RecordTypeId = newsLeadRecordTypeId;

        gemsToInsert.add(gem1);
        gemsToInsert.add(gem2);
        gemsToInsert.add(gem3);
        gemsToInsert.add(gem4);

        insert(gemsToInsert);
        ////TEST
        system.runAs(testUser) {
            //Make sure LastViewedDate is set
            Account viewAccount = [SELECT Id From Account Where Id = :testClient.Id FOR VIEW];

            String returnValue = '[{"An":"TestArticleID5","Title":"TestTitle5","Pred":1,"Medium_Prob_Clients":"GemTestClient1", "Publication_Date":"2019:05:05T12:00:00:00"},{"An":"TestArticleID6","Title":"TestTitle6","Pred":0,"Medium_Prob_Clients":"GemTestClient1", "Publication_Date":"2019:05:05T12:00:00:00"}]';
            Test.setMock(HttpCalloutMock.class, new CI_SingleRequestMock(200, 'Complete', returnValue, null));

            Test.startTest();
            List<CI_Gem__c> gemList = CI_GemLeadController.getLeadGems(null);

            //1 new gem + 4 existing (incl deleted ones)
            System.assertEquals(4, gemList.size());

            Test.stopTest();
        }
    }

    @isTest(SeeAllData=false)
    static void dismissGemAction() {
        ////TEST DATA
        //Create client
        Account testClient = createTestClient('GemTestClient1');

        //Get test user
        User testUser = getTestUser();

        //Lead gem
        Id newsLeadRecordTypeId = Schema.SObjectType.CI_Gem__c.getRecordTypeInfosByName().get('News Lead').getRecordTypeId();
        CI_Gem__c gem = new CI_Gem__c();
        gem.User__c = testUser.Id;
        gem.Data__c = '{"articleId":"TestArticleID1","articleTitle":"TestTitle1"}';
        gem.Dismissed__c = false;
        gem.RecordTypeId = newsLeadRecordTypeId;
        insert gem;
        
        ////TEST
        system.runAs(testUser){ 
            CI_Gem__c leadGem = [SELECT Id FROM CI_Gem__c WHERE Dismissed__c = false AND User__c =: testUser.Id LIMIT 1];
            CI_GemController.dismissGemAction(leadGem.Id);
            CI_Gem__c dismissedGem = [SELECT Id, Dismissed__c FROM CI_Gem__c WHERE Id =: leadGem.Id LIMIT 1];

            System.assert(dismissedGem.Dismissed__c);
        }
    }

    @isTest static void deleteGemAction() {
        ////TEST DATA
        //Create client
        Account testClient = createTestClient('GemTestClient1');

        //Get test user
        User testUser = getTestUser();

        //Lead gem
        Id newsLeadRecordTypeId = Schema.SObjectType.CI_Gem__c.getRecordTypeInfosByName().get('News Lead').getRecordTypeId();
        CI_Gem__c gem = new CI_Gem__c();
        gem.User__c = testUser.Id;
        gem.Data__c = '{"articleId":"TestArticleID1","articleTitle":"TestTitle1"}';
        gem.RecordTypeId = newsLeadRecordTypeId;
        insert gem;
        
        ////TEST
        system.runAs(testUser){ 
            CI_Gem__c leadGem = [SELECT Id FROM CI_Gem__c WHERE Deleted__c = false AND User__c =: testUser.Id LIMIT 1];
            CI_GemController.deleteGemAction(leadGem.Id);
            CI_Gem__c deletedGem = [SELECT Id, Deleted__c FROM CI_Gem__c WHERE Id =: leadGem.Id LIMIT 1];

            System.assert(deletedGem.Deleted__c);
        }
    }

    @isTest static void removeDeletedGems() {
        List<CI_Gem__c> gemList = new List<CI_Gem__c>();
        
        CI_Gem__c gem = new CI_Gem__c();
        gemList.add(gem);

        gem = new CI_Gem__c();
        gem.Deleted__c = true;
        gemList.add(gem);

        CI_GemController.removeDeletedGems(gemList);

        System.assertEquals(1, gemList.size());
    } 
}