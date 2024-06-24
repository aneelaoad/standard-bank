/**
* @description  : Test Class for Partner Portal Partnership Oportunity Controller
* User Story : SFP-4879
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date July 2021
*/
@IsTest(IsParallel=true)
private class PP_Partnership_Opportunities_CTRL_TEST {
    
    @IsTest
    static void getOpportunitiesTest(){
        fflib_ApexMocks mocks = new fflib_ApexMocks();
        
        SEL_PartnershipOpportunities partnershipOpptyMock = (SEL_PartnershipOpportunities) mocks.mock(SEL_PartnershipOpportunities.class);
        
        PP_PartnershipOpportunity__c partnershipOppty = (PP_PartnershipOpportunity__c) new BLD_PartnershipOpportunities()
            .setPartnershipOpptyData()
            .mock();
        
        
        mocks.startStubbing();
        mocks.when(partnershipOpptyMock.sObjectType()).thenReturn(PP_PartnershipOpportunity__c.SObjectType);
        mocks.when(partnershipOpptyMock.getSingleFeaturedPartnershipOpportunity())
            .thenReturn(partnershipOppty);
        mocks.when(partnershipOpptyMock.getPublishedPartnershipOpportunity())
            .thenReturn(new List<PP_PartnershipOpportunity__c> {partnershipOppty});
        mocks.stopStubbing();
        
        ORG_Application.selector.setMock(partnershipOpptyMock);
        
        Test.startTest();
        PP_PartnershipOpportunity__c result = PP_Partnership_Opportunities_CTRL.getSingleFeaturedOpportunity();
        List<PP_PartnershipOpportunity__c> result2 = PP_Partnership_Opportunities_CTRL.getAllPublishPartnerships();
        PP_Partnership_Opportunities_CTRL.getRelatedFiles(result.Id);
        System.AssertEquals(result.name,'Predictive Analytics for Credit Scoring'); 
        System.AssertEquals(result2[0].name,'Predictive Analytics for Credit Scoring'); 
        Test.stopTest();
        
        
    } 
    
}