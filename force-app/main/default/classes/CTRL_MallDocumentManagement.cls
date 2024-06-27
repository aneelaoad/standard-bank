/**
 * 
 * @description CTRL_MallDocumentManagement
 * @author Ankit Kumar
 * @since 
 */
public with sharing class CTRL_MallDocumentManagement {
    private final static String ACCOUNT_CONFIRMATION_LETTER = 'Account Confirmation Letter';
    private final static String FICA_DOCUMENTS = 'FICA documents';
    private final static String PREVIOUS_STATEMENTS = 'Previous statements';
    private final static String STAMPED_STATEMENTS = 'Stamped statements';
    private final static String CHANNEL_ID = 'BLUESHOP';
    private final static Integer CODE_LENGTH = 30;
    private final static String EMPTY = '';
    private static CMN_WebserviceSetting__mdt settings;

    /**
     * 
     * @description getCustomerAccountList
     * @return  `MallCustomerAccountListResponse`
     */
    @AuraEnabled
    public static MallCustomerAccountListResponse getCustomerAccountList() {
        try {
            MallCustomerAccountListResponse accountListResponse;
            String pingBPGUID = getCustomerPBGUID();
            if(String.isBlank(pingBPGUID)) {
                throw MallExceptionUtil.throwAuraException('CTRL_MallDocumentManagement.getCustomerAccountList', new AuraHandledException('Customer BPGUID should not be empty'));
            }
            if(String.isNotBlank(pingBPGUID)) {
                accountListResponse = API_MallCustomerAccountList.getCustomerAccountList(pingBPGUID);
            }
            return accountListResponse;
        } catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('CTRL_MallDocumentManagement.getCustomerAccountList', e);
        }
    }

    /**
     * 
     * @description getCustomerDocumentsByAccountNumbers
     * @param accountNumbers `List<String>`
     * @return  `MallDocumentResponse`
     */
    @AuraEnabled
    public static MallDocumentResponse getCustomerDocumentsByAccountNumbers(List<String> accountNumbers) {
        try {
            String pingBPGUID = getCustomerPBGUID();
            MallDocumentResponse documentResponse;

            if(String.isBlank(pingBPGUID)){
                throw MallExceptionUtil.throwAuraException('CTRL_MallDocumentManagement.getCustomerDocumentsByAccountNumbers', new AuraHandledException('Customer BPGUID should not be empty'));
            }
  
            if(String.isNotBlank(pingBPGUID)) {
                API_MallCustomerDocumentManagement.CustomerDocumentRequest customerDocumentRequest = new API_MallCustomerDocumentManagement.CustomerDocumentRequest();
                customerDocumentRequest.externalArrangementIds = accountNumbers;
                customerDocumentRequest.channelId = CHANNEL_ID;
                customerDocumentRequest.userId = pingBPGUID;
                customerDocumentRequest.category = new List<String>{FICA_DOCUMENTS, ACCOUNT_CONFIRMATION_LETTER};
                documentResponse = new API_MallCustomerDocumentManagement().getCustomerDocuments(customerDocumentRequest);            
            }

            return documentResponse;
        }  catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('CTRL_MallDocumentManagement.getCustomerDocumentsByAccountNumbers', e);
        }
    }

    /**
     * 
     * @description getCustomerStampedStatementsByAccountNumbers
     * @param accountNumbers `List<String>`
     * @return  `MallDocumentResponse`
     */
    @AuraEnabled
    public static MallDocumentResponse getCustomerStampedStatementsByAccountNumbers(List<String> accountNumbers) {
        try {
            String pingBPGUID = getCustomerPBGUID();
            MallDocumentResponse documentResponse;

            if(String.isBlank(pingBPGUID)){
                throw MallExceptionUtil.throwAuraException('CTRL_MallDocumentManagement.getCustomerStampedStatementsByAccountNumbers', new AuraHandledException('Customer BPGUID should not be empty'));
            }

            if(String.isNotBlank(pingBPGUID)) {                
                API_MallCustomerDocumentManagement.CustomerDocumentRequest customerDocumentRequest = new API_MallCustomerDocumentManagement.CustomerDocumentRequest();
                customerDocumentRequest.externalArrangementIds = accountNumbers;
                customerDocumentRequest.channelId = CHANNEL_ID;
                customerDocumentRequest.userId = pingBPGUID;
                customerDocumentRequest.category = new List<String>{STAMPED_STATEMENTS};
                documentResponse = new API_MallCustomerDocumentManagement().getCustomerDocuments(customerDocumentRequest);
            }
            return documentResponse;
        }  catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('CTRL_MallDocumentManagement.getCustomerStampedStatementsByAccountNumbers', e);
        }
    }

    /**
     * 
     * @description getCustomerPreviousStatementsByAccountNumbers
     * @param accountNumbers List<String>
     * @param startDate String
     * @param endDate String
     * @return  `MallDocumentResponse`
     */
    @AuraEnabled
    public static MallDocumentResponse getCustomerPreviousStatementsByAccountNumbers(List<String> accountNumbers, String startDate, String endDate) {
        try {
            String pingBPGUID = getCustomerPBGUID();
            MallDocumentResponse documentResponse;

            if(String.isBlank(pingBPGUID)){
                throw MallExceptionUtil.throwAuraException('CTRL_MallDocumentManagement.getCustomerPreviousStatementsByAccountNumbers', new AuraHandledException('Customer BPGUID should not be empty'));
            }

            if(String.isNotBlank(pingBPGUID)) {
                API_MallCustomerDocumentManagement.CustomerDocumentRequest customerDocumentRequest = new API_MallCustomerDocumentManagement.CustomerDocumentRequest();
                customerDocumentRequest.externalArrangementIds = accountNumbers;
                customerDocumentRequest.channelId = CHANNEL_ID;
                customerDocumentRequest.userId = pingBPGUID;
                customerDocumentRequest.dateFrom = startDate;
                customerDocumentRequest.dateTo = endDate;
                customerDocumentRequest.category = new List<String>{PREVIOUS_STATEMENTS};
                documentResponse = new API_MallCustomerDocumentManagement().getCustomerDocuments(customerDocumentRequest);
            }
            return documentResponse;
        }catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('CTRL_MallDocumentManagement.getCustomerPreviousStatementsByAccountNumbers', e);
        }
    }

    /**
     * 
     * @description getCustomerDocumentByUUID
     * @param documentUUID String
     * @return String
     */
    @AuraEnabled
    public static MallDocumentLinkResponse getCustomerDocumentByUUID(String documentUUID) {
        try {
            String pingBPGUID = getCustomerPBGUID();
            MallDocumentLinkResponse documentUrls;

            if(String.isBlank(pingBPGUID)){
                throw MallExceptionUtil.throwAuraException('CTRL_MallDocumentManagement.getCustomerDocumentByUUID', new AuraHandledException('Customer BPGUID should not be empty'));
            }

            if(String.isNotBlank(pingBPGUID)) {
                API_MallCustomerDocumentManagement.DocumentDownloadResponse documentDownloadResponse= new API_MallCustomerDocumentManagement().getCustomerDocumentByUUID(pingBPGUID, documentUUID);
                documentUrls = new CTRL_MallDocumentManagement().createDocumentForDownload(documentDownloadResponse);
            }
            return documentUrls;
        } catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('CTRL_MallDocumentManagement.getCustomerDocumentByUUID', e);
        }
    } 

    /**
     * 
     * @description deleteDocumentDownloaded
     * @param contentVersionId String
     * @return String
     */
    @AuraEnabled
    public static String deleteDocumentDownloaded(String contentVersionId) {
        try {
            List<ContentDistribution> contentRecords = SEL_ContentDistribution.newInstance().selectByContentVersionId(new Set<Id>{(Id)contentVersionId});
            if(contentRecords.size() > 0) {
                delete contentRecords;
                return 'success';
            }
            return 'error';
        } catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('CTRL_MallDocumentManagement.deleteDocumentDownloaded', e);
        }
    }

    
    /**
     * 
     * @description createDocumentForDownload
     * @param documentDownloadResponse API_MallCustomerDocumentManagement.DocumentDownloadResponse
     * @return String
     */
    public MallDocumentLinkResponse createDocumentForDownload(API_MallCustomerDocumentManagement.DocumentDownloadResponse documentDownloadResponse) { 
        try {
            MallDocumentLinkResponse documentLinks;
            ContentVersion contentVersion = new ContentVersion();
            contentVersion.Title = documentDownloadResponse.fileName;
            contentVersion.PathOnClient = documentDownloadResponse.fileName;
            contentVersion.VersionData = EncodingUtil.base64Decode(documentDownloadResponse.content);
            insert contentVersion;
            Map<Id,MallDocumentLinkResponse> contentIdVsLink = new CTRL_MallDocumentManagement().makeImageUrlPublic(new List<String>{contentVersion.Id});
            if(contentIdVsLink != NULL) {
                documentLinks = contentIdVsLink.get(contentVersion.Id);
            }
            return documentLinks; 
        } catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('CTRL_MallDocumentManagement.createDocumentForDownload', e);
        }   
    }

    /**
     * 
     * @description : makeImageUrlPublic 
     *  @param contentVersionIds List<String>     
     *  @return : Map<Id, String>
     */
    public Map<Id, MallDocumentLinkResponse> makeImageUrlPublic(List<String> contentVersionIds) {
        try {
            List<ContentVersion> contentVersions = new List<ContentVersion>();
            List<ContentDistribution> contentDistributions = new List<ContentDistribution>();
            Map<Id, MallDocumentLinkResponse> contentVersionIdToContentUrl = new Map<Id, MallDocumentLinkResponse>();
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
                MallDocumentLinkResponse mallDocResponse = new MallDocumentLinkResponse();
                mallDocResponse.downloadUrl = contentDistribution.ContentDownloadurl;
                mallDocResponse.publicViewUrl = contentDistribution.DistributionPublicUrl;
                contentVersionIdToContentUrl.put(contentDistribution.ContentVersionId, mallDocResponse);
            }
            return contentVersionIdToContentUrl;
        } catch(Exception e) {
            throw MallExceptionUtil.throwAuraException('CTRL_MallDocumentManagement.makeImageUrlPublic', e);
        }
    }

    /**
     * 
     * @description getCustomerPBGUID
     * @return String
     */
    public static String getCustomerPBGUID() {
        String currentUserId = UserInfo.getUserId();
        User currentUser = new User();
        String pingBPGUID;

        List<User> users = SEL_Users.newInstance().selectById(new Set<Id>{(Id)currentUserId});

        if(users.size() > 0) {
            currentUser = users[0];
            pingBPGUID = currentUser.Ping_BPGUID__c;
        }
        return pingBPGUID;
    }

   

    public class MallDocumentLinkResponse {

        @AuraEnabled
        public string downloadUrl;
        @AuraEnabled
        public string publicViewUrl;
        
    }
}