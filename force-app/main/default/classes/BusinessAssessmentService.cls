/**
* Business Assessment service
*
* @author Wayne Solomon
* @date Jun 2020
*/
public inherited sharing class BusinessAssessmentService {

    /**
     * getBusinessAssessmentsWithAssessmentOpps
     * @param recIds set of ids
     * @return Map<Id, Business_Assessment__c>
     */
    public static Map<Id, Business_Assessment__c> getBusinessAssessmentsWithAssessmentOpps(Set<Id> recIds) {
        if (!recIds.isEmpty()){
            return new Map<Id, Business_Assessment__c>(new SEL_BusinessAssessments().selectByIdsWithAssessmentOppChildren(recIds));
        }
        return new Map<Id, Business_Assessment__c>();
    }

    /**
     * Update business assessments SGPRT-1201
     * @param businessAssessments business assessment records
     * @return list of Database.SaveResult
     */
    public static List<Database.SaveResult> updateBusinessAssessments(List<Business_Assessment__c> businessAssessments) {
        return Database.update(new List<Business_Assessment__c>(businessAssessments), false);
    }
}