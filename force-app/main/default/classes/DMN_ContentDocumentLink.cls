public with sharing class DMN_ContentDocumentLink {
    public static void updateBAssessmentHasDocumentField(List<ContentDocumentLink> contentDocLinks) {
        Set<Id> bAssessmentId = new Set<Id>();

        for(ContentDocumentLink file : contentDocLinks) {
            if(file.LinkedEntityId.getSObjectType() == Business_Assessment__c.SObjectType) {
                bAssessmentId.add(file.LinkedEntityId);
            }
        }

        if(bAssessmentId.isEmpty()) {
            return;
        }

        List<Business_Assessment__c> bAssessments = new List<Business_Assessment__c>();
        for(Id baId : bAssessmentId) {
            Business_Assessment__c ba = new Business_Assessment__c(Id = baId, HasDocument__c = true);
            bAssessments.add(ba);
        }

        if(!bAssessments.isEmpty()) {
            update bAssessments;
        }

    }
}