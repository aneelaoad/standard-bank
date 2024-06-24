/**
* @description  : Test Class for CMN_KnowledgeArticleListing_CTRL
* User Story : SFP-4963
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date July 2021
*/
@IsTest
public class CMN_KnowledgeArticleListing_TEST {
    
    @IsTest
    static void getArticles() {
        
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_KnowledgeArticleVersions selectorMock = (SEL_KnowledgeArticleVersions) mocks.mock(SEL_KnowledgeArticleVersions.class);

        Knowledge__kav article = (Knowledge__kav) new BLD_Knowledge()
            .setOSBData()
            .useFAQ()
            .mock();
        
        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Knowledge__kav.SObjectType);
        mocks.when(selectorMock.selectArticleByPublishStatusAndRecordType((Set<String>) fflib_Match.anyObject(), (Set<Id>) fflib_Match.anyObject(), (Integer) fflib_Match.anyInteger()))
            .thenReturn(new List<Knowledge__kav> {article});
        mocks.stopStubbing();
        
        ORG_Application.selector.setMock(selectorMock);
        
        Test.startTest();
        List<Knowledge__kav> successStoryArticles = CMN_KnowledgeArticleListing_CTRL.getArticles('Success Stories',3);
        List<Knowledge__kav> faqArticles = CMN_KnowledgeArticleListing_CTRL.getArticles('FAQ',3);
        List<Knowledge__kav> allArticles = CMN_KnowledgeArticleListing_CTRL.getArticles('All Articles',3);
        List<Knowledge__kav> featuredArticle = CMN_KnowledgeArticleListing_CTRL.getFeaturedArticle(1);
        Test.stopTest();
        
        System.assert(successStoryArticles.size() > 0);
        System.assert(faqArticles.size() > 0);
        System.assert(allArticles.size() > 0);

    }

}