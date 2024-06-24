/**
 * 
 * @description MallServiceFrontQuicklinksCtrl
 * @author Ankit Kumar
 * @since 
 */
public with sharing class MallServiceFrontQuicklinksCtrl {
    public static final String DEFAULT_CONTENT_LANGUAGE_ISO = 'en';
    public static List<Link__c> newLinks = new List<Link__c> ();

    /**
     * 
     * @description : getApprovalHistoryByLinkIds 
     * @param linkIds List<String>
     * @return List<ProcessInstanceStep>
     */
    @AuraEnabled
    public static List<ProcessInstanceStep> getApprovalHistoryByLinkIds(List<String> linkIds) {
        try {
            Set<Id> linkIdsSet = new Set<Id>();
            linkIdsSet.addAll((List<Id>)linkIds);
            List<Offering__c> offerings = SEL_Offerings.newInstance().selectByParentOffering(linkIdsSet);
            List<String> childServiceIds = new List<String> ();
            for (Offering__c offering: offerings) {
                childServiceIds.add(offering.Id);
            }
            linkIds.addAll(childServiceIds);
    
            linkIdsSet = new Set<Id>();
            linkIdsSet.addAll((List<Id>)linkIds);
            List<ProcessInstanceStep> processInstanceSteps = SEL_ProcessInstanceSteps.newInstance().selectByTargetObjectId(linkIdsSet);
            return processInstanceSteps;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallServiceFrontQuicklinksCtrl.getApprovalHistoryByLinkIds', e);
        }
    }

    /**
     * 
     * @description : getQuickLinks 
     * @param serviceId Id
     * @return : List<QuickLinkInfo>
     */
    @AuraEnabled
    public static List<QuickLinkInfo> getQuickLinks(Id serviceId) {
        try {
            List<QuickLinkInfo> infos = new List<QuickLinkInfo> ();
            String whereClause = ' Link__r.Offering__c IN (\'' + String.join(new List<String>{serviceId}, '\',\'') + '\')';
            whereClause += ' AND Link__r.Status__c != NULL And Title__c != NULL And Link__r.Desktop_Url__c != NULL';
    
            for (Content_Unit_Translation__c translation: SEL_ContentUnitTranslations.newInstance().selectByCustomFilterCondition(whereClause)) {
                QuickLinkInfo info = new QuickLinkInfo();
                info.name = translation.Title__c;
                info.id = translation.Link__c;
                info.serviceId = translation.Link__r.Offering__c;
                info.desktopUrl = translation.Link__r.Desktop_Url__c;
                info.comments = translation.Link__r.Comment__c;
                info.status = translation.Link__r.Status__c;
                info.online = translation.Link__r.Status__c == 'Published' ? true : false;
                infos.add(info);
            }
            return infos;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallServiceFrontQuicklinksCtrl.getQuickLinks', e);
        }
    }


    /**
     * 
     * @description : saveQuicklinks 
     *  @param quickLinkInfosString String
     */
    @AuraEnabled
    public static void saveQuicklinks(String quickLinkInfosString) {
        try {
            List<QuickLinkInfo> quickLinkInfos = (List<QuickLinkInfo> ) JSON.deserialize(quickLinkInfosString, List<QuickLinkInfo> .class);
            List<Link__c> links = new List<Link__c> ();
            List<Id> linkIds = new List<Id> ();
            Map<Id, QuickLinkInfo> linkIdVsInfo = new Map<Id, QuickLinkInfo> ();
            for (QuickLinkInfo info: quickLinkInfos) {
                Link__c link = new Link__c(
                    name = info.name, 
                    Desktop_url__c = info.desktopUrl,          
                    Guest_url__c = info.desktopUrl, 
                    Mobile_url__c = info.desktopUrl,
                    Id = (!String.isBlank(info.id)) ? info.id : NULL,
                    Offering__c = info.serviceId,
                    Status__c = 'Draft'
                );
                links.add(link);
                if (!String.isBlank(info.id)) {
                    linkIds.add(info.id);
                    linkIdVsInfo.put(info.id, info);
                }
            }
            upsert links;
            newLinks = links;
    
            List<Content_Unit_Translation__c> translations = new List<Content_Unit_Translation__c> ();
            String whereClause = ' Link__c IN (\'' + String.join(linkIds, '\',\'') + '\')';
            translations = SEL_ContentUnitTranslations.newInstance().selectByCustomFilterCondition(whereClause);
            for (Content_Unit_Translation__c translation: translations) {
                if (linkIdVsInfo.containsKey(translation.Link__c) && (translation.Title__c != linkIdVsInfo.get(translation.Link__c).name)) {
                    translation.Title__c = linkIdVsInfo.get(translation.Link__c).name;
                    translations.add(translation);
                }
            }
    
            for (Link__c link: Links) {
                if (!linkIds.contains(link.Id)) {
                    String languageTagId;
                    List<Tag__c> languages = SEL_Tags.newInstance().selectTagsByNames(new Set<String>{DEFAULT_CONTENT_LANGUAGE_ISO});
                    if (languages.size()> 0) {
                        languageTagId = languages[0].Id;
                    }
                    Content_Unit_Translation__c translation = new Content_Unit_Translation__c(Title__c = link.name, Language__c = languageTagId, Link__c = link.Id);
                    translations.add(translation);
                }
            }
            if(translations != NULL && translations.size() > 0) {
                upsert translations;
            }
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallServiceFrontQuicklinksCtrl.saveQuicklinks', e);
        }
    }

    
    /**
     * 
     * @description : submitQuickLinksForApproval 
     *  @param quickLinkInfoStrings List<String>
     *  @param saveQuickLinks Boolean
     */
    @AuraEnabled
    public static void submitQuickLinksForApproval(List<String> quickLinkInfoStrings, Boolean saveQuickLinks) {
        try {
            List<QuickLinkInfo> quickLinkInfos = new List<QuickLinkInfo>();
            for (String stringInfo: quickLinkInfoStrings) {
                quickLinkInfos.add((QuickLinkInfo) JSON.deserialize(stringInfo, QuickLinkInfo.class));
            }
    
            List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest> ();
            if (saveQuickLinks) {
                saveQuicklinks(JSON.serialize(quickLinkInfos));
            } else {
                for (QuickLinkInfo info: quickLinkInfos) {
                    Link__c link = new Link__c(Id = info.id, Comment__c = info.comments);
                    newLinks.add(link);
                }
            }
            List<Link__c> updateLinkStatus = new List<Link__c> ();
            for (Link__c link: newLinks) {
                link.Status__c = 'Draft';
                updateLinkStatus.add(link);
            }
    
            update updateLinkStatus;
    
            for (Link__c link: newLinks) {
                Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                req.setComments(link.Comment__c);
                req.setObjectId(link.id);
                req.setSubmitterId(UserInfo.getUserId());
                String approvalProcessName = 'Quick_Link_Content_Publishing_Request';
                req.setProcessDefinitionNameOrId(approvalProcessName);
                req.setSkipEntryCriteria(false);
                requests.add(req);
            }
            if(!Test.isRunningTest()) {
                Approval.process(requests);
            }
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallServiceFrontQuicklinksCtrl.submitQuickLinksForApproval', e);
        }
    }

    /**
     * 
     * @description : recallQuickLinks 
     *  @param linkIds List<Id>
     */
    @AuraEnabled
    public static void recallQuickLinks(List<Id> linkIds) {
        try {
            List<Approval.ProcessWorkItemRequest> requests = new List<Approval.ProcessWorkItemRequest> ();
            for (ProcessInstanceWorkitem wi: [SELECT Id FROM ProcessInstanceWorkItem
                    WHERE ProcessInstance.TargetObjectId in: linkIds
                    AND ProcessInstance.Status = 'Submitted'
                ]) {
                Approval.ProcessWorkItemRequest pwiRequest = new Approval.ProcessWorkItemRequest();
                pwiRequest.setAction('Removed');
                pwiRequest.setWorkItemId(wi.Id);
                requests.add(pwiRequest);
            }
            if (!requests.isEmpty()) {
                List<Link__c> linksToUpdate = new List<Link__c> ();
                for (Approval.ProcessResult result: Approval.process(requests)) {
                    if (result.isSuccess()) {
                        linksToUpdate.add(new Link__c(Id = result.getEntityId(), Status__c = 'Draft'));
                    }
                }
                update linksToUpdate;
            }
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallServiceFrontQuicklinksCtrl.recallQuickLinks', e);
        }
    }

    /**
     * 
     * @description : publishQuickLinks 
     *  @param linkIds List<Id>
     */
    @AuraEnabled
    public static void publishQuickLinks(List<Id> linkIds) {
        try {
            List<Link__c> linksToUpdate = new List<Link__c> ();
        
            for (Id linkId: linkIds) {
                Link__c link = new Link__c(Id = linkId, Status__c = 'Published');
    
                linksToUpdate.add(link);
            }
            update linksToUpdate;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallServiceFrontQuicklinksCtrl.publishQuickLinks', e);
        }
    }

    /**
     * 
     * @description QuickLinkInfo
     */
    public class QuickLinkInfo {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String desktopUrl;
        @AuraEnabled
        public Id serviceId;
        @AuraEnabled
        public Id id;
        @AuraEnabled
        public String comments;
        @AuraEnabled
        public String icon;
        @AuraEnabled
        public Boolean online;
        @AuraEnabled
        public String status;
    }

}