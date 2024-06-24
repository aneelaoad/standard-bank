/**
* @description  : Partnership Opportunities Controller
* User Story : SFP-4879
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date July 2021
*/
public without sharing class PP_Partnership_Opportunities_CTRL {

    /**
    * @description | Used to get Featured Partnership Opportunity
    * 
    * @return PP_PartnershipOpportunity__c
    **/
    @AuraEnabled(cacheable=true)
    public static PP_PartnershipOpportunity__c getSingleFeaturedOpportunity(){        
        return SEL_PartnershipOpportunities.newInstance().
            getSingleFeaturedPartnershipOpportunity();
    }
    
    /**
    * @description | Used to get All Published Partnerships
    * 
    * @return List<PP_PartnershipOpportunity__c>
    **/
    @AuraEnabled(cacheable=true)
    public static List<PP_PartnershipOpportunity__c> getAllPublishPartnerships(){        
        return SEL_PartnershipOpportunities.newInstance().
            getPublishedPartnershipOpportunity();
    }

    /**
    * @description | Used to get Related Files
    * 
    * @param recordId
    * @return Map<ID, String>
    **/
    @AuraEnabled(cacheable=true)
    public static Map<ID, String> getRelatedFiles(String recordId) {
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
        
        List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title 
                                     FROM ContentVersion WHERE ContentDocumentId IN : fileIDs];
        Map<ID, String> mapIdTitle = new Map<ID, String>();
        for (ContentVersion docLink : docs) {
            mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
        }
        
        return mapIdTitle;
    }
    
}