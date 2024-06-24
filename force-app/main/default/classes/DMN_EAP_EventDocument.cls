/**
 * @description       : 
 * @author            : TCK
 * @group             : 
 * @last modified on  : 06-22-2022
 * @last modified by  : TCK
 * Modifications Log 
 * Ver   Date         Author   Modification
 * 1.0   07-01-2021   TCK   Initial Version
**/
public with sharing class DMN_EAP_EventDocument {

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param id2NewRecords 
    * @param id2OldRecords 
    **/
    public static void createFileAccessApp(Map<Id, EAP_Document__c> id2NewRecords,Map<Id, EAP_Document__c> id2OldRecords){
        Set<Id> docsId = new Set<Id>();
        for(EAP_Document__c doc:id2NewRecords.values()){
            if(doc.EAP_PublishMobileApp__c == true && id2OldRecords.geT(doc.Id).EAP_PublishMobileApp__c != doc.EAP_PublishMobileApp__c){
                docsId.add(doc.Id);
            }
        }
        if(docsId.size() > 0){
            generatePublicLink(docsId);
        }
    }
    
    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param docsId 
    **/
    private static void generatePublicLink(Set<Id> docsId){
        
        // List<ContentDocumentLink> mainPhotoList = [SELECT ContentDocumentId,ContentDocument.LatestPublishedVersionId,LinkedEntityId,Visibility  
        //                             FROM ContentDocumentLink 
        //                             WHERE LinkedEntityId in :docsId];
        List<ContentDocumentLink> mainPhotoList = SEL_ContentDocumentLink.newInstance().selectByLinkedEntityId(docsId);
        List<String> cdlIdsList = new List<String>();
        List<ContentDocumentLink> cdlVisibilityUpdateList = new List<ContentDocumentLink>();
        for(ContentDocumentLink cdl: mainPhotoList){
            cdlIdsList.add(cdl.ContentDocumentId);
            if(cdl.Visibility != 'AllUsers'){
                cdlVisibilityUpdateList.add(cdl);
            }
        }
        if(!cdlVisibilityUpdateList.isEmpty()){
            updateImgVisibility(cdlVisibilityUpdateList);
        }
        
        // List<ContentVersion> cvList = [SELECT Id,ContentDocumentId,ContentDocument.LatestPublishedVersionId,FileType,ContentBodyId FROM ContentVersion WHERE ContentDocumentId in :cdlIdsList];
        Set<Id> cvIds = new Set<Id>();
        for (String id : cdlIdsList ) {
            cvIds.add(id);
        }
        List<ContentVersion> cvList = SEL_ContentVersion.newInstance().selectByContentDocumentId(cvIds);
        createContentDritributionLink(cvList);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param contentVersionList 
    **/
    private static void createContentDritributionLink(List<ContentVersion> contentVersionList){

        // List<ContentDistribution> contentDistributionList = [SELECT Id,ContentVersionId,DistributionPublicUrl FROM ContentDistribution WHERE ContentVersionId IN :contentVersionList];
        Set<Id> cdIds = new Set<Id>();
        for (ContentVersion cv : contentVersionList ) {
            cdIds.add(cv.Id);
        }
        List<ContentDistribution> contentDistributionList = SEL_ContentDistribution.newInstance().selectByContentVersionId(cdIds);
        Set<Id> cdWithLink = new Set<Id>();
        for(ContentDistribution cd:contentDistributionList){
            cdWithLink.add(cd.ContentVersionId);
        }

        List<ContentVersion> cvCreateDistributionList = new List<ContentVersion>();
        for(ContentVersion cv:contentVersionList){
            if(!cdWithLink.contains(cv.Id)){
                cvCreateDistributionList.add(cv);
            }
        }
        
        if(cvCreateDistributionList.size() > 0){
            generatePublicUrlImage(cvCreateDistributionList);
        }
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param cdlVisibilityUpdate 
    **/
    private static void updateImgVisibility(List<ContentDocumentLink> cdlVisibilityUpdate){
        for(ContentDocumentLink cdl:cdlVisibilityUpdate){
            cdl.Visibility = 'AllUsers';
        }
        Database.update(cdlVisibilityUpdate);
    }

    /**
    * @description 
    * @author TCK | 06-14-2022 
    * @param contentVersionsId 
    **/
    private static void generatePublicUrlImage(List<ContentVersion> contentVersionsId){

        List<ContentDistribution> cdList = new List<ContentDistribution>();
        for(ContentVersion cv:contentVersionsId){
            ContentDistribution cd = new ContentDistribution();
            cd.Name = 'CDL_'+cv.Id;
            cd.ContentVersionId = cv.Id;
            cd.PreferencesAllowViewInBrowser= true;
            cd.PreferencesLinkLatestVersion=true;
            cd.PreferencesNotifyOnVisit=false;
            cd.PreferencesPasswordRequired=false;
            cd.PreferencesAllowOriginalDownload= true;
            cdList.add(cd);
        }

        Database.insert(cdList);
    }

}