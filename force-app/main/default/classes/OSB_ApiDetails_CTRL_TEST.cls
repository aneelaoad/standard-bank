/**
 * Test class for OSB_ApiDetails_CTRL class
 *
 * @author Wojciech Kowalczyk (wkowalczyk@deloittece.com)
 * @date May 2020
 */
@IsTest(IsParallel=true)
private class OSB_ApiDetails_CTRL_TEST {

    @IsTest
    static void shouldGetApiDetails() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        Map<String, Object> apiDetails = new Map<String, Object>();
        OSB_SRV_ApiConnect serviceMock = (OSB_SRV_ApiConnect) mocks.mock(OSB_SRV_ApiConnect.class);
        ORG_Application.service.setMock(OSB_SRV_ApiConnect.IService.class, serviceMock);
        Test.startTest();
        apiDetails = OSB_ApiDetails_CTRL.getApiDetails('');
        Test.stopTest();
        ((OSB_SRV_ApiConnect) mocks.verify(serviceMock, 1))
                .getAPIDetails('');
        System.assertEquals(null, apiDetails);
    }

    @IsTest
    static void shouldGetKnowledgeDetails() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        SEL_KnowledgeArticleVersions selectorMock = (SEL_KnowledgeArticleVersions) mocks.mock(SEL_KnowledgeArticleVersions.class);

        Knowledge__kav article = (Knowledge__kav) new BLD_Knowledge()
            .setOSBData()
            .isComingSoon(false)
            .useApiProduct()
            .mock();

        mocks.startStubbing();
        mocks.when(selectorMock.sObjectType()).thenReturn(Knowledge__kav.SObjectType);
        mocks.when(selectorMock.selectByPublishStatusIdAndRecordTypeIdWoSharing((Set<String>) fflib_Match.anyObject(), (Set<Id>) fflib_Match.anyObject(), (Set<Id>) fflib_Match.anyObject()))
            .thenReturn(new List<Knowledge__kav> {article});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(selectorMock);

        Test.startTest();
        List<Knowledge__kav> actualKnowledgeList = OSB_ApiDetails_CTRL.getKnowledgeDetails(article.Id);
        Test.stopTest();
        System.assertEquals(UTL_RecordType.getRecordTypeId(DMN_Knowledge.OBJ_NAME, DMN_Knowledge.RT_API), actualKnowledgeList[0].RecordTypeId);
    }
    
    @IsTest
    static void shouldGetSubApis() {
        fflib_ApexMocks mocks = new fflib_ApexMocks();
		SEL_ChildProducts selectorMockChild = (SEL_ChildProducts) mocks.mock(SEL_ChildProducts.class);
        
        Child_products__c childProduct = (Child_products__c) new BLD_Child_Products()
            .setOSBData()
            .commitWork()
            .getRecord(); 

        mocks.startStubbing();
        mocks.when(selectorMockChild.sObjectType()).thenReturn(Child_products__c.SObjectType);
        mocks.when(selectorMockChild.selectByParentProductWoSharing(new Set<Id> {childProduct.Knowledge_Parent__c})).thenReturn(new List<Child_products__c> {childProduct});
        mocks.stopStubbing();

        ORG_Application.selector.setMock(selectorMockChild);

        Test.startTest();
        List<Child_products__c> actualChildProduct = OSB_ApiDetails_CTRL.getSubApis(childProduct.Knowledge_Parent__c);
        Test.stopTest();
        System.assertEquals(actualChildProduct[0].Knowledge_Parent__c, childProduct.Knowledge_Parent__c);
    }
}