@isTest
public class CI_GemLeadControllerTest {

    private static final String USERNAME = 'testExecUsedwadwar@standardbank.test.com';
    private static User insightsUser {
        get {
            if (insightsUser == null) {
                insightsUser = [SELECT Id FROM User WHERE Username = :USERNAME];
            }
            return insightsUser;
        }
        set;
    }

    @TestSetup
    private static void setupTestData(){

        insightsUser = (User) new BLD_USER(USERNAME).useInsightsExec().commitWork().getRecord();

        Id recordTypeId = [SELECT Id FROM RecordType WHERE Name = 'News Lead'].Id;

        System.runAs(insightsUser) {
            List<CI_Gem__c> gems = new List<CI_Gem__c>();
            CI_Gem__c gem1 = new CI_Gem__c(RecordTypeId = recordTypeId, User__c = insightsUser.Id, Data__c = '{"articleId":"test","articleTitle":"test"}');
            CI_Gem__c gem2 = new CI_Gem__c(RecordTypeId = recordTypeId, User__c = insightsUser.Id, Data__c = '{"articleId":"test","articleTitle":"test"}');
            CI_Gem__c gem3 = new CI_Gem__c(RecordTypeId = recordTypeId, User__c = insightsUser.Id, Data__c = '{"articleId":"test","articleTitle":"test"}');
            gems.add(gem1);
            gems.add(gem2);
            gems.add(gem3);
            insert gems;

            fflib_SObjectUnitOfWork uow = ABS_ObjectBuilderBase.getNewUnitOfWork();
            for (Integer i = 0; i < 3; i++) {
                new BLD_News(uow)
                    .an('testId' + i)
                    .title('title' + i)
                    .pred(true);
            }
            uow.commitWork();
        }
    }

    @isTest private static void getLeadGemsTest(){

        String returnValue = '[{"An":"TestArticleID1","Title":"TestTitle1","Pred":1, "Publication_Date":"2019:05:05T12:00:00:00"},{"An":"TestArticleID2","Title":"TestTitle2","Pred":0, "Publication_Date":"2019:05:05T12:00:00:00"}]';
        Test.setMock(HttpCalloutMock.class, new CI_SingleRequestMock(200, 'Complete', returnValue, null));
        CI_NewsCallout.setPendingCache();

        System.runAs(insightsUser){
            Test.startTest();
            List<CI_Gem__c> gemsWithoutClient = CI_GemLeadController.getLeadGems(null);
//            List<CI_Gem__c> gemsWithClient = CI_GemLeadController.getLeadGems('testId');
            Test.stopTest();
            System.assertEquals(3, gemsWithoutClient.size());
//            System.assertEquals(0, gemsWithClient.size());
        }

    }

    @isTest private static void checkAndInsertLeadGemsTest(){

        List<ArticleNews__c> news = [SELECT Id, Pred__c, Title__c, An__c FROM ArticleNews__c];

        System.runAs(insightsUser){
            List<CI_Gem__c> gems = CI_GemLeadController.checkAndInsertLeadGems(news, null);
            System.assertEquals(3, gems.size());
        }
    }
}