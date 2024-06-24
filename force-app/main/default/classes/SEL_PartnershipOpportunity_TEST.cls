/**
* @description  : Test Class for Partnership Opportunity Selector Class
* User Story : SFP-11650
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date 04 2022
*/
@IsTest(IsParallel=true)
public class SEL_PartnershipOpportunity_TEST {

    @IsTest
    static void getPartnershipOpportunity() {
        PP_PartnershipOpportunity__c  partnerOppty = BLD_PartnershipOpportunities.getPartnershipOppty();
        insert partnerOppty;
        SEL_PartnershipOpportunities.newInstance().getSingleFeaturedPartnershipOpportunity();
        SEL_PartnershipOpportunities.newInstance().getPublishedPartnershipOpportunity();
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('PP_PublishEndDate__c  >= Today'));
    }
}