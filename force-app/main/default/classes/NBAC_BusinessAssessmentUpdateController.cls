/**
 * Created by pmalicki on 17.08.2018.
 */

public with sharing class NBAC_BusinessAssessmentUpdateController {

    @AuraEnabled
    public static Boolean updateBusinessAssessment(Id bAssessmentId) {

        List<Business_Assessment__c> bAssessments = [SELECT Id, Account__c FROM Business_Assessment__c WHERE Id = :bAssessmentId];

        bAssessments = DMN_BusinessAssessment.updateRevenueAndCrocData(bAssessments);

        if(bAssessments != null && bAssessments.size() != 0) {
            update bAssessments;
            return true;
        }
        return false;
    }

}