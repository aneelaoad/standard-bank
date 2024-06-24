/**
 * @description A class controller for the NBAC_AncillaryOpportunities lwc component.
 * @author Nikita Haruk
 * @date 22/09/2023
 *
 *  @ Last Modified By  :   Augustine Chirombo
 *  @ Last Modified On  :   15/04/2024
 *  @ Last Modified Reason : SFP-36900 - Added logic to fetch products without sharing enforced.
 */
public with sharing class NBAC_AncillaryOpportunities_CTRL {
    
    private final static Set<String> ANCILLARY_OPP_STAGES = new Set<String> {
        DMN_Opportunity.ST_LEAD,
        DMN_Opportunity.ST_DEVELOP,
        DMN_Opportunity.ST_CLOSED_WON
    };

    /**
     * @description Select ancillary opportunities by nbac Id 
     * @param nbacId The Business Assessment Id
     * @return List<SB_Product__c> -  List of products linked to ancillary opportunities
     */
    @AuraEnabled(cacheable=true)
    public static List<SB_Product__c> getAncillaryOpportunities(Id nbacId) {
        Set<Id> parentIds = new Set<Id>();
        for (Assessment_Opportunity__c aOpp : new SEL_AssessmentOpportunities().selectByBusinessAssessmentId(new Set<Id> { nbacId }, true)) {
            parentIds.add(aOpp.Opportunity__c);
        }
        return new SEL_Products().selectByOppParentIdsAndStagesWithoutSharing(parentIds, ANCILLARY_OPP_STAGES);
    }
}