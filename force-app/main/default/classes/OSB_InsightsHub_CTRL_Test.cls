/**
 * Test class for OSB_InsightsHub_CTRL class
 * 
 * @author Wayde Fagan (wayde.fagan@tetrad.co.za)
 * @date April 2020
 * 
 */
@isTest
public class OSB_InsightsHub_CTRL_Test {
    
	@IsTest
    static void shouldGetKnowledgeDetails() {
        List<OSB_URLs__c> osbUrls = TEST_DataFactory.getOsbUrls();
        insert osbUrls;
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_KnowledgeArticleVersions selectorMock = (SEL_KnowledgeArticleVersions) mocks.mock(SEL_KnowledgeArticleVersions.class);

        Knowledge__kav article = (Knowledge__kav) new BLD_Knowledge()
            .setOSBData()
            .useInsightArticle()
            .mock();

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Knowledge__kav.SObjectType);
        mocks.when(selectorMock.selectByPublishStatusAndRecordTypeIdWoSharing((Set<String>) fflib_Match.anyObject(), (Set<Id>) fflib_Match.anyObject(), (Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<Knowledge__kav> {article});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(selectorMock);

        Test.startTest();
        Map<String,Object> actualKnowledgeList = OSB_InsightsHub_CTRL.getInsights();
        Test.stopTest();
        System.assertNotEquals(Null, actualKnowledgeList.get('KnowledgeList'));
    }
}