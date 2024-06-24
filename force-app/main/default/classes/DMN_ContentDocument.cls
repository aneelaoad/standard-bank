public with sharing class DMN_ContentDocument {
    public static void updateBAssessmentHasDocumentField(Set<Id> contentDocs) {

        List<ContentDocumentLink> files = DMN_ContentDocument.getContentDocumentLinks(contentDocs);

        Set<Id> bAssessmentId = new Set<Id>();

        for(ContentDocumentLink file : files) {
            if(file.LinkedEntityId.getSObjectType() == Business_Assessment__c.SObjectType) {
                bAssessmentId.add(file.LinkedEntityId);
            }
        }

        if(bAssessmentId.isEmpty()) {
            return;
        }

        List<Business_Assessment__c> bAssessments = new List<Business_Assessment__c>();
        bAssessments = DMN_ContentDocument.getBAssessmentWithoutFiles(bAssessmentId, contentDocs );
        if(!bAssessments.isEmpty()) {
            update bAssessments;
        }

    }

    public static List<ContentDocumentLink> getContentDocumentLinks(Set<Id> contentDocIds) {
        List<ContentDocumentLink> contentDocumentLinks = [
                SELECT ContentDocumentId, LinkedEntityId
                FROM ContentDocumentLink
                WHERE ContentDocumentId IN :contentDocIds
        ];

        return contentDocumentLinks;
    }

    public static List<Business_Assessment__c> getBAssessmentWithoutFiles(Set<Id> bAssessmentIds, Set<Id> contentDocIds) {
        List<ContentDocumentLink> files = [
                SELECT LinkedEntityId
                FROM ContentDocumentLink
                WHERE LinkedEntityId IN :bAssessmentIds
                    AND ContentDocumentId NOT IN :contentDocIds
        ];

        List<Business_Assessment__c> bAssessments = new List<Business_Assessment__c>();

        for(Id bId : bAssessmentIds) {
            Boolean hasFile = false;
            for(ContentDocumentLink file: files) {
                if(file.LinkedEntityId == bId) {
                    hasFile = true;
                    continue;
                }
            }
            if(!hasFile) {
                bAssessments.add(new Business_Assessment__c(Id = bId, HasDocument__c = false));
            }
        }

        return bAssessments;

    }


}