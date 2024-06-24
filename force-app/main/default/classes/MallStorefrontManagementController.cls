/**
 * 
 * @description MallStorefrontManagementController
 * @author Ankit Kumar
 * @since 
*/
public with sharing class MallStorefrontManagementController {
    public static final String DRAFT_STATUS = 'Draft';
    public static final String DEFAULT_CONTENT_LANGUAGE_ISO = 'en';
    /**
     * 
     * @description : getProviderInfo 
     *  @param accountId String
     *  @return : ProviderInfo
     */
    @AuraEnabled
    public static ProviderInfo getProviderInfo(String accountId){
        try {
            List<Provider__c> clonedProvider = new List<Provider__c>();
            Provider__c publishedProvider = new Provider__c();
            List<Provider__c> providers = new List<Provider__c>();
            String whereClause = '( Parent_Provider__r.Related_Client__c IN (\'' + String.join(new List<String>{accountId}, '\',\'') + '\') AND Status__c != \'Published\' )';
            whereClause += ' OR ( Related_Client__c IN (\'' + String.join(new List<String>{accountId}, '\',\'') + '\') AND Parent_Provider__c = NULL )';
            providers = SEL_Providers.newInstance().selectByCustomFilterCondition(whereClause);
            for(Provider__c provider: providers) {
                if(provider.Related_Client__c == accountId && String.IsBlank(provider.Parent_Provider__c)) {
                    publishedProvider = provider;
                } else if(String.IsNotBlank(provider.Parent_Provider__c) && provider.Parent_Provider__r.Related_Client__c == accountId ) {
                    clonedProvider.add(provider);
                }
            }
            

            ProviderInfo providerInfo = new ProviderInfo();
            providerInfo.publishedProvider = publishedProvider;
            if(clonedProvider.size() > 0) {
                providerInfo.clonedProvider = clonedProvider[0];  
            }

            List<Content_Unit_Translation__c> images = new  List<Content_Unit_Translation__c>();
            if(clonedProvider.size() > 0) {
                String providerId = clonedProvider[0].Id;
                whereClause = ' Provider__c IN (\'' + String.join(new List<String>{providerId}, '\',\'') + '\')';
                whereClause += ' AND Content_Unit__c = NULL ';
                images =  SEL_ContentUnitTranslations.newInstance().selectByCustomFilterCondition(whereClause);
            }
            if(images != NULL && images.size() > 0) {
                providerInfo.cut = images[0];   
            }
            return providerInfo;                   
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallStorefrontManagementController.getProviderInfo', e);
        }
    }

    /**
     * 
     * @description : providerUpdateRequest 
     *  @param publishedProviderId String
     *  @param clonedProviderId String
     *  @return : ProviderInfo
     */
    @AuraEnabled
    public static ProviderInfo providerUpdateRequest(String publishedProviderId, String clonedProviderId){
        try {
            Provider__c currentProvider = new Provider__c();
            List<Provider__c> providers = SEL_Providers.newInstance().selectByIds(new Set<Id>{(Id)publishedProviderId});
            if(providers.size() > 0 ) {
                currentProvider = providers[0];
            }
            if(String.isBlank(clonedProviderId)) {
                //Create a clone Provider
                Provider__c clonedProvider  = currentProvider.clone(false, true, false, false);
                clonedProvider.Name = currentProvider.Name + ' Clone ' + System.now().format('dd/MM/YYYY');
                clonedProvider.Parent_Provider__c = currentProvider.Id;
                clonedProvider.Status__c = DRAFT_STATUS;
                clonedProvider.Publishing_Unit__c = NULL;
                clonedProvider.OwnerId = UserInfo.getUserId();
                clonedProvider.Default_Translation__c = NULL;
                clonedProvider.Icon__c = NULL;
                insert clonedProvider;

                String languageTagId;
                List<Tag__c> languages = SEL_Tags.newInstance().selectTagsByNames(new Set<String>{DEFAULT_CONTENT_LANGUAGE_ISO});
                if(languages.size() > 0) {
                    languageTagId = languages[0].Id;
                }

                //Create a blank CUT for image and description
                Content_Unit_Translation__c cut = new Content_Unit_Translation__c(Image_Url__c = '', Provider__c = clonedProvider.Id, Language__c = languageTagId);
                insert cut;

                Provider__c clonedProviderTemp = new Provider__c(Id = clonedProvider.Id, Default_Translation__c = cut.Id);
                update clonedProviderTemp;

                ProviderInfo providerInfo = new ProviderInfo();
                providerInfo.publishedProvider = currentProvider;
                providerInfo.clonedProvider = clonedProvider;
                providerInfo.cut = cut;
                return providerInfo;
            } else {
                ProviderInfo providerInfo = getProviderInfo(publishedProviderId);
                providerInfo.publishedProvider = currentProvider;
                return providerInfo;  
            }
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallStorefrontManagementController.providerUpdateRequest', e);
        }
    }

    /**
     * 
     * @description : updateImageRequest 
     *  @param accountId String
     *  @param clonedProviderId String     
     *  @param contentVersionId String     
     *  @param cutId String
     *  @return : ProviderInfo
     */
    @AuraEnabled
    public static ProviderInfo updateImageRequest(String accountId, String clonedProviderId, String contentVersionId, String cutId){
        try {
            Content_Unit_Translation__c image = new Content_Unit_Translation__c();
            image.Id = cutId;
            image.Image_Url__c = new MallStorefrontManagementController().makeImageUrlPublic(new List<String>{contentVersionId}).get(contentVersionId);
            update image;
            
            ProviderInfo providerInfo = getProviderInfo(accountId);
            providerInfo.cut = image;
            return providerInfo;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallStorefrontManagementController.updateImageRequest', e);
        }
    }

    /**
     * 
     * @description : deleteImageRequest 
     *  @param accountId String     
     *  @param clonedProviderId String     
     *  @param documentId String
     *  @param cutId String
     *  @return : ProviderInfo
     */
    @AuraEnabled
    public static ProviderInfo deleteImageRequest(String accountId, String clonedProviderId, String documentId, String cutId){
        try {
            Content_Unit_Translation__c image = new Content_Unit_Translation__c();
            image.Id = cutId;
            image.Image_Url__c = NULL;
            update image;
            
            List<ContentDocument> imageDocuments = SEL_ContentDocument.newInstance().selectById(new Set<Id>{(Id)documentId});
            delete imageDocuments;

            ProviderInfo providerInfo = getProviderInfo(accountId);
            providerInfo.cut = image;
            return providerInfo;

        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallStorefrontManagementController.deleteImageRequest', e);
        }
    }

    /**
    * 
    * @description : ApexType to maintain the Provider and it's current clone to capture new publishing info
    */
    public class ProviderInfo {
        @AuraEnabled
        public Provider__c publishedProvider;
        @AuraEnabled
        public Provider__c clonedProvider;
        @AuraEnabled
        public Content_Unit_Translation__c cut;
         @AuraEnabled
        public Content_Unit_Translation__c icon;
    }

    /**
     * 
     * @description : makeImageUrlPublic 
     *  @param contentVersionIds List<String>     
     *  @return : Map<Id, String>
     */
    public Map<Id, String> makeImageUrlPublic(List<String> contentVersionIds) {
        List<ContentVersion> contentVersions = new List<ContentVersion>();
        List<ContentDistribution> contentDistributions = new List<ContentDistribution>();
        Map<Id, String> contentVersionIdToContentUrl = new Map<Id, String>();
        Set<Id> contentVersionIdsSet = new Set<Id>();
        contentVersionIdsSet.addAll((List<Id>)contentVersionIds);
        contentVersions = SEL_ContentVersion.newInstance().selectById(contentVersionIdsSet);
        for(ContentVersion contentVersion : contentVersions) {
            ContentDistribution contentDistribution = new ContentDistribution();
            contentDistribution.Name = contentVersion.Title;
            contentDistribution.ContentVersionId = contentVersion.Id;
            contentDistribution.PreferencesAllowViewInBrowser= true;
            contentDistribution.PreferencesLinkLatestVersion=true;
            contentDistribution.PreferencesNotifyOnVisit=false;
            contentDistribution.PreferencesPasswordRequired=false;
            contentDistribution.PreferencesAllowOriginalDownload= true;
            contentDistributions.add(contentDistribution);        
        }
        insert contentDistributions;
        List<String> contentDistributionIds = new List<String>();
        for(ContentDistribution contentDistribution : contentDistributions) {
            contentDistributionIds.add(contentDistribution.Id);
        }
        Set<Id> contentDistributionIdsSet = new Set<Id>();
        contentDistributionIdsSet.addAll((List<Id>)contentDistributionIds);
        contentDistributions = SEL_ContentDistribution.newInstance().selectById(contentDistributionIdsSet);
        for(ContentDistribution contentDistribution: contentDistributions) {
            String publicUrl = contentDistribution.ContentDownloadurl;
            contentVersionIdToContentUrl.put(contentDistribution.ContentVersionId, publicUrl);
        }
        return contentVersionIdToContentUrl;
    }

    /**
     * 
     * @description : updateSObjects 
     *  @param sObjects List<sObject>
     *  @return `List<sObject>`
     */
    @AuraEnabled
    public static List<sObject> updateSObjects(List<sObject> sObjects){
        try {
            update sObjects;
            return sObjects;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallStorefrontManagementController.updateSObjects', e);
        }
    }

     /**
     * 
     * @description : cancelProviderUpdates 
     *  @param publishedProviderId String
     *  @return ProviderInfo
     */
    @AuraEnabled
    public static ProviderInfo cancelProviderUpdates(String publishedProviderId) {
        ProviderInfo providerInfo = getProviderInfo(publishedProviderId);
        Provider__c clonedProvider = providerInfo.clonedProvider;
        if(clonedProvider != NULL && clonedProvider.Id != NULL) {
            clonedProvider.Approval_Comment__c = '';
            update clonedProvider;
        }
        if(providerInfo.cut != NULL && providerInfo.cut.Id != NULL) {
            Content_Unit_Translation__c cut = providerInfo.cut;
            cut.Image_Url__c = '';
            cut.Text__c = '';
            cut.RichText__c = '';
            update cut;
        }
        return getProviderInfo(publishedProviderId);
    }

    /**
     * 
     * @description : submitProviderForApproval 
     *  @param clonedProviderId String
     *  @param comment String     
     *  @return `Boolean`
     */
    @AuraEnabled
    public static Boolean submitProviderForApproval(String clonedProviderId, String comment){
        try { 
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments(comment);
            req.setObjectId(clonedProviderId);
            req.setSubmitterId(UserInfo.getUserId());             
            req.setProcessDefinitionNameOrId('BCB_Platform_Content_Update_Request');
            req.setSkipEntryCriteria(false); 
            if(!Test.isRunningTest()) {
                Approval.ProcessResult result = Approval.process(req);
                return result.isSuccess(); 
            } else {
                return true;
            }       
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallStorefrontManagementController.submitProviderForApproval', e);
        }
    }

    /**
     * 
     * @description : publishProvider 
     *  @param storeStateString String
     *  @return `Boolean`
     */
    @AuraEnabled
    public static Boolean publishProvider(String storeStateString){
        try {
            ProviderInfo providerInfo = (ProviderInfo)JSON.deserialize(storeStateString, ProviderInfo.class);   
            Provider__c publishedProvider = providerInfo.publishedProvider;
            Provider__c clonedProvider = providerInfo.clonedProvider;
            Content_Unit_Translation__c cut = providerInfo.cut;

            //Update Provider record
            Provider__c providerToUpdate = new Provider__c();
            providerToUpdate.Id = publishedProvider.Id;
            providerToUpdate.Approval_Comment__c = clonedProvider.Approval_Comment__c;
            update providerToUpdate;

            Provider__c cloneProvider = new Provider__c();
            cloneProvider.Id = clonedProvider.Id;
            cloneProvider.Status__c = 'Published';
            
            //Updating clone Provider in different transaction to avoid Record locks
            updateProviders(System.JSON.serialize(new List<Provider__c>{cloneProvider}));

            //Find the CUT record associated with the Provider for translations
            List<Content_Unit_Translation__c> cuts = new List<Content_Unit_Translation__c>();
            String whereClause = ' Provider__c IN (\'' + String.join(new List<String>{providerToUpdate.Id}, '\',\'') + '\')';
            whereClause += ' AND Language__c IN (\'' + String.join(new List<String>{cut.Language__c}, '\',\'') + '\')';
            whereClause += ' AND Content_Unit__c = NULL ';

            cuts = SEL_ContentUnitTranslations.newInstance().selectByCustomFilterCondition(whereClause);
            Content_Unit_Translation__c cutToUpdate = new Content_Unit_Translation__c();
            if(cuts.size() > 0) {
                cutToUpdate = cuts[0];
            } 
            cutToUpdate.Image_Url__c = cut.Image_Url__c;
            cutToUpdate.Text__c = cut.Text__c;
            cutToUpdate.RichText__c = cut.RichText__c;
            cutToUpdate.Language__c = cut.Language__c;
            cutToUpdate.Provider__c = providerToUpdate.Id;
            upsert cutToUpdate;

            Publishing_Unit__c pu = new Publishing_Unit__c();
            pu.Id = publishedProvider.Publishing_Unit__c;
            pu.IsPublished__c = true;
            update pu;
            return true;
        } catch (Exception e) {
            throw MallExceptionUtil.throwAuraException('MallStorefrontManagementController.publishProvider', e);
        }
    }

    /**
     * 
     * @description : updateProviders 
     *  @param providerListJSON String
     */
    @future
    public static void updateProviders(String providerListJSON) {
        try{
            List<Provider__c> providersToUpdate= (List<Provider__c>) System.JSON.deserialize(providerListJSON, List<Provider__c>.class);
            update providersToUpdate;
        }catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('MallStorefrontManagementController.updateProviders', e);
        }
    }
}