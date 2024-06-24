/**
* @description Uploading Documents from Managed Fund Page
* @Author Khushmeet Kaur
* @Company Absyz
* @Test Class OMF_UploadDocumentsController_Test
*/
/**
* @Last Modified By : Aman Kumar 
* @Last Modified On : 06-05-2024
* @Modification description: SFP-Number - SFP-38048
*/
//supressed because of naming convention used in aura , the following code fails if we name it as per convention here 
@SuppressWarnings('PMD.FormalParameterNamingConventions,PMD.ExcessiveParameterList,PMD.CognitiveComplexity')

public without sharing class OMF_UploadDocumentsController {
     private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('OMF_UploadDocumentsController');
    @AuraEnabled
    /**
     * @description Get the KYC Required Documents Record with KYC Status details and the uploaded file Id and Name.
     * @param list_managedFundId
     * @param blnRequiredDocuments Boolean if Required Document.
     * @param blnSingleManagedFundRecord Boolean if managed fund is single record is being called
     * @return listGetKYCDocumentsWrapper
     */
    public static list<GetKYCDocumentsWrapper> getKYCDocuments(List<String>list_managedFundId,Boolean blnRequiredDocuments,Boolean blnSingleManagedFundRecord){
        
        Map<String, String> mapManagedFundIdByParentId = new Map<String, String>();
        
        for (OMF_ManagedFund__c objManagedFund : new SEL_OMF_ManagedFunds().selectManagedFundRecordByRecordIdList(list_managedFundId)){
            mapManagedFundIdByParentId.put(objManagedFund.Id, objManagedFund.BulkOnboarding__c);
        }
        
        List<GetKYCDocumentsWrapper>listGetKYCDocumentsWrapper = new list<GetKYCDocumentsWrapper>();
        Map<String, Map<String, List<String>>> mapRequiredDocNameById = new Map<String, Map<String, List<String>>>();
        Map<String, Map<String, List<String>>> mapMasterAgreementByKYCRecordIdByParentId = new Map<String, Map<String, List<String>>>();
        List<Id> listKycStatusRecordId = new List<Id>();
        
        List<KYC_Required_Documents__c> kycRequiredDocumentsList = new SEL_KYCRequiredDocuments().selectByKYCReviewId(list_managedFundId);
        
        for (KYC_Required_Documents__c objKYCRequiredDocuments : kycRequiredDocumentsList) {
            listKycStatusRecordId.add(objKYCRequiredDocuments.Id);
        }
        mapRequiredDocNameById = populateMapRequiredDocName(kycRequiredDocumentsList,blnRequiredDocuments,blnSingleManagedFundRecord,mapManagedFundIdByParentId);
        
        //Create map master agreement by kyc record by parent id
        mapMasterAgreementByKYCRecordIdByParentId = createMapMasterAgreementByKYCRecordIdByParentId(new SEL_KYCRequiredDocuments().selectByKYCReviewId(list_managedFundId));
        
        List<GetMasterAgreementDetailsWrapper> listGetMasterAgreementDetailsWrapper = new List<GetMasterAgreementDetailsWrapper>();
        Map<String, ContentDocumentLink> mapContentDocumentLinkByParentId = new Map<String, ContentDocumentLink>();
        
        for(ContentDocumentLink objDocLink : new SEL_ContentDocumentLink().selectByListLinkEntityId(listKycStatusRecordId)){
            mapContentDocumentLinkByParentId.put(objDocLink.LinkedEntityId, objDocLink);
        }
        
        
        for (String strDocumentName : mapRequiredDocNameById.keySet()) {
            listGetMasterAgreementDetailsWrapper =  populateListGetMasterAgreementDetails(mapMasterAgreementByKYCRecordIdByParentId,strDocumentName,mapContentDocumentLinkByParentId);
           
            GetKYCDocumentsWrapper objGetKYCDocumentsWrapper = new GetKYCDocumentsWrapper();
            objGetKYCDocumentsWrapper.strDocumentName = strDocumentName;
            
            if(strDocumentName.equals('Fund Fact Sheet')){
                objGetKYCDocumentsWrapper.strHelpText = 'Also known as the Minimum Disclosure Document';
            }
            if (strDocumentName.equals('Resolution to Amend the Master Agreement Exhibit')) {
                objGetKYCDocumentsWrapper.strDocumentHeader = 'Resolutions to Amend the Master Agreement Exhibits';
                objGetKYCDocumentsWrapper.list_masterAgreementDetails = listGetMasterAgreementDetailsWrapper;
                objGetKYCDocumentsWrapper.strHelpText = 'Also known as the Amendment Agreement for the Addition and/or Amendment of Counterparties';
            }
            
            for (String objRecordId : mapRequiredDocNameById.get(strDocumentName).keySet()) {
                objGetKYCDocumentsWrapper.strRecordId = objRecordId;
                objGetKYCDocumentsWrapper.blnRequired = blnRequiredDocuments;
                objGetKYCDocumentsWrapper.list_kycStatusId = mapRequiredDocNameById.get(strDocumentName).get(objRecordId);
                objGetKYCDocumentsWrapper = populatelistGetKYCDocumentsWrapper(mapContentDocumentLinkByParentId,objGetKYCDocumentsWrapper,objRecordId,strDocumentName);
            }
            listGetKYCDocumentsWrapper.add(objGetKYCDocumentsWrapper);
        }
        return listGetKYCDocumentsWrapper;
    }
    /**
     * @description This will store kyc status record ID in case of optional docs or managed fund bulk record id in case of required doc.
     */
    public class GetKYCDocumentsWrapper{
        
        @AuraEnabled public String strRecordId; 
        
        @AuraEnabled public String strDocumentName;
        
        @AuraEnabled public String strDocumentHeader;
        
        @AuraEnabled public Boolean blnRequired = false;
        
        @AuraEnabled public List<String>list_kycStatusId;
        
        @AuraEnabled public String strFileName;
        
        @AuraEnabled public String strFileId;
        
        @AuraEnabled public String strHelpText;
        
        @AuraEnabled public List<GetMasterAgreementDetailsWrapper> list_masterAgreementDetails;
    }
    /**
    * @description This will store Wrapper class to store master agreement details
    */
    public class GetMasterAgreementDetailsWrapper{
        
        @AuraEnabled public String strMasterAgreementName;
        
        @AuraEnabled public List<String> list_kycStatusId;
        
        @AuraEnabled public String strFileName;
        
        @AuraEnabled public String strFileId;
    }
    
    private static List<GetMasterAgreementDetailsWrapper> populateListGetMasterAgreementDetails(Map<String, Map<String, List<String>>>mapMasterAgreementByKYCRecordIdByParentId,String strDocumentName,Map<String, ContentDocumentLink> mapContentDocumentLinkByParentId){
        List<GetMasterAgreementDetailsWrapper> listGetMasterAgreementDetailsWrapper = new List<GetMasterAgreementDetailsWrapper>();
        if (mapMasterAgreementByKYCRecordIdByParentId.containsKey(strDocumentName)) {
            for (String masterAgreementName : mapMasterAgreementByKYCRecordIdByParentId.get(strDocumentName).keySet()) {
                GetMasterAgreementDetailsWrapper objgetMasterAgreementDetailsWrapper = new GetMasterAgreementDetailsWrapper();
                objgetMasterAgreementDetailsWrapper.strMasterAgreementName = masterAgreementName;
                objgetMasterAgreementDetailsWrapper.list_kycStatusId = mapMasterAgreementByKYCRecordIdByParentId.get(strDocumentName).get(masterAgreementName);
                
                for (String strRecordId : objgetMasterAgreementDetailsWrapper.list_kycStatusId) {
                    if (mapContentDocumentLinkByParentId.containsKey(strRecordId)) {
                        objgetMasterAgreementDetailsWrapper.strFileName = mapContentDocumentLinkByParentId.get(strRecordId).ContentDocument.Title + '.' + mapContentDocumentLinkByParentId.get(strRecordId).ContentDocument.FileExtension;
                        objgetMasterAgreementDetailsWrapper.strFileId = mapContentDocumentLinkByParentId.get(strRecordId).ContentDocumentId;
                    }
                }
                listGetMasterAgreementDetailsWrapper.add(objgetMasterAgreementDetailsWrapper);
            }
        }
        return listGetMasterAgreementDetailsWrapper;
    }
    
    private static GetKYCDocumentsWrapper populatelistGetKYCDocumentsWrapper(Map<String, ContentDocumentLink>mapContentDocumentLinkByParentId, GetKYCDocumentsWrapper objGetKYCDocumentsWrapper,String objRecordId,String strDocumentName){
        if(mapContentDocumentLinkByParentId.containsKey(objRecordId)){
            objGetKYCDocumentsWrapper.strFileName = mapContentDocumentLinkByParentId.get(objRecordId).ContentDocument.Title + '.' + mapContentDocumentLinkByParentId.get(objRecordId).ContentDocument.FileExtension;
            objGetKYCDocumentsWrapper.strFileId = mapContentDocumentLinkByParentId.get(objRecordId).ContentDocumentId;
        }
        if(strDocumentName == 'Shared Client Certificate'){
            objGetKYCDocumentsWrapper.strDocumentHeader = 'Shared Documents';
            for(String strRecordId : objGetKYCDocumentsWrapper.list_kycStatusId){
                if(mapContentDocumentLinkByParentId.containsKey(strRecordId)){
                    objGetKYCDocumentsWrapper.strFileName = mapContentDocumentLinkByParentId.get(strRecordId).ContentDocument.Title + '.' + mapContentDocumentLinkByParentId.get(strRecordId).ContentDocument.FileExtension;
                    objGetKYCDocumentsWrapper.strFileId = mapContentDocumentLinkByParentId.get(strRecordId).ContentDocumentId;
                }
            }
        }
        return objGetKYCDocumentsWrapper;
    }
    
    private static Map<String, Map<String, List<String>>> populateMapRequiredDocName(List<KYC_Required_Documents__c>listKYCRequiredDocument,Boolean blnRequiredDocuments,Boolean blnSingleManagedFundRecord, Map<String, String> mapManagedFundIdByParentId){
        Map<String, Map<String, List<String>>> mapRequiredDocNameById = new Map<String, Map<String, List<String>>>();

        for (KYC_Required_Documents__c objKYCRequiredDocuments : listKYCRequiredDocument) {
            
            String strParentId = mapManagedFundIdByParentId.get(objKYCRequiredDocuments.KYC_Review_Status__r.ManagedFundID__c);
            
            if(blnSingleManagedFundRecord == true){
                if(!mapRequiredDocNameById.containsKey(objKYCRequiredDocuments.Document_Required__c)){
                    mapRequiredDocNameById.put(objKYCRequiredDocuments.Document_Required__c, new Map<String, List<String>>());
                }
                mapRequiredDocNameById.get(objKYCRequiredDocuments.Document_Required__c).put(objKYCRequiredDocuments.Id, new List<String>());
            }
            else{
                if (blnRequiredDocuments == null || blnRequiredDocuments == true && (objKYCRequiredDocuments.Document_Required__c == 'Resolution to Amend the Master Agreement Exhibit' || objKYCRequiredDocuments.Document_Required__c == 'Shared Client Certificate')) {
                    if (!mapRequiredDocNameById.containsKey(objKYCRequiredDocuments.Document_Required__c)) {
                        mapRequiredDocNameById.put(objKYCRequiredDocuments.Document_Required__c, new Map<String, List<String>>());
                    }
                    if (!mapRequiredDocNameById.get(objKYCRequiredDocuments.Document_Required__c).containsKey(strParentId)) {
                        mapRequiredDocNameById.get(objKYCRequiredDocuments.Document_Required__c).put(strParentId, new List<String>());
                    }
                    mapRequiredDocNameById.get(objKYCRequiredDocuments.Document_Required__c).get(strParentId).add(objKYCRequiredDocuments.Id);
                    
                }
                if (blnRequiredDocuments == null || blnRequiredDocuments == false && (objKYCRequiredDocuments.Document_Required__c != 'Resolution to Amend the Master Agreement Exhibit' && objKYCRequiredDocuments.Document_Required__c != 'Shared Client Certificate')) {
                    if(!mapRequiredDocNameById.containsKey(objKYCRequiredDocuments.Document_Required__c)){
                        mapRequiredDocNameById.put(objKYCRequiredDocuments.Document_Required__c, new Map<String, List<String>>());
                    }
                    mapRequiredDocNameById.get(objKYCRequiredDocuments.Document_Required__c).put(objKYCRequiredDocuments.Id, new List<String>());
                }
            }  
        }
        return mapRequiredDocNameById;
    }
    
    private static Map<String, Map<String, List<String>>>  createMapMasterAgreementByKYCRecordIdByParentId(List<KYC_Required_Documents__c>listKYCDocument){
        
        Map<String, Map<String, List<String>>> mapMasterAgreementByKYCRecordIdByParentId = new Map<String, Map<String, List<String>>>();
        
        for (KYC_Required_Documents__c objKYCRequiredDocuments :listKYCDocument){
            if (objKYCRequiredDocuments.Master_Agreement_Name__c != null && objKYCRequiredDocuments.Master_Agreement_Name__c != '') {
                if (!mapMasterAgreementByKYCRecordIdByParentId.containsKey(objKYCRequiredDocuments.Document_Required__c)) {
                    mapMasterAgreementByKYCRecordIdByParentId.put(objKYCRequiredDocuments.Document_Required__c, new Map<String, List<String>>());
                } 
                if (!mapMasterAgreementByKYCRecordIdByParentId.get(objKYCRequiredDocuments.Document_Required__c).containsKey(objKYCRequiredDocuments.Master_Agreement_Name__c)) {
                    mapMasterAgreementByKYCRecordIdByParentId.get(objKYCRequiredDocuments.Document_Required__c).put(objKYCRequiredDocuments.Master_Agreement_Name__c,new List<String>());
                }
                mapMasterAgreementByKYCRecordIdByParentId.get(objKYCRequiredDocuments.Document_Required__c).get(objKYCRequiredDocuments.Master_Agreement_Name__c).add(objKYCRequiredDocuments.Id);
            }
        }
        return mapMasterAgreementByKYCRecordIdByParentId;
    }
    /**
     * @description Create KYC Required Documents.
     * @param strManagedFundId 
     * @return isSuccess
     */
    public static Boolean createKYCRequiredDocument(String strManagedFundId){
        Boolean isSuccess = false;
        List<KYC_Required_Documents__c> listKycRequiredDocumentInsert = new List<KYC_Required_Documents__c>();
        Set<String> masterAgreementNames = new Set<String>();
        Set<String> kycRequiredDocuments = new Set<String>();
        Map<String, KYC_Status__c> mapKycStatus = new Map<String, KYC_Status__c>();
        Map<String, Set<String>> mapMasterAgreementNames = new Map<String, Set<String>>();
        
        // Query the KYC_Required_Documents__c records related to the given ManagedFundId
        for(KYC_Required_Documents__c objKYCRequiredDocument : new SEL_KYCRequiredDocuments().selectKYCDocumentsWithManagedFund(strManagedFundId)){
            masterAgreementNames.add(objKYCRequiredDocument.Master_Agreement_Name__c);
        }
        
        // Query the OMF_ManagedFundRules__c records to get a list of KYC documents required
        Id kycDocumentRecordType = Schema.SObjectType.OMF_ManagedFundRules__c.getRecordTypeInfosByName().get('KYC Documents').getRecordTypeId();
        OMF_ManagedFundRules__c[] listManagedFundRules = new SEL_OMF_ManagedFundRules().selectedManagedFundRulesWithRecordTypeId(kycDocumentRecordType);
        
        for(OMF_ManagedFundRules__c objManagedFundRules : listManagedFundRules){
            kycRequiredDocuments.addAll(objManagedFundRules.DocumentRequired__c.split(';'));
            kycRequiredDocuments.addAll(objManagedFundRules.AdditionalDocuments__c.split(';'));
        }
        
        // Query the KYC_Status__c record related to the given ManagedFundId
        for(KYC_Status__c objKYCStatus : new SEL_KYCStatuses().selectKYCStatusByManagedFund(strManagedFundId)){
            mapKycStatus.put(objKYCStatus.ManagedFundID__c, objKYCStatus);
        }
        
        // Query the OMF_FundToAgreement__c records related to the given ManagedFundId
        for(OMF_FundToAgreement__c objFundToAgreement : new SEL_OMFFundToAgreement().selectFundToAgreementByManagedFundID(strManagedFundId)){
            if (!mapMasterAgreementNames.containsKey(objFundToAgreement.ManagedFundID__c)) {
                mapMasterAgreementNames.put(objFundToAgreement.ManagedFundId__c, new set<String>{ objFundToAgreement.MasterAgreementId__r.Name });
            } else {
                mapMasterAgreementNames.get(objFundToAgreement.ManagedFundID__c).add(objFundToAgreement.MasterAgreementId__r.Name);
            }
        }
        
        if (mapKycStatus.containsKey(strManagedFundId)) {
            for (String strKYCRequiredDocument : kycRequiredDocuments) {
                if (strKYCRequiredDocument != 'Resolution to Amend the Master Agreement Exhibit') {
                      KYC_Required_Documents__c objKYCRequiredDocuments = createKYCRequiredDocument(strKYCRequiredDocument, mapKycStatus.get(strManagedFundId).Id);
                    listKycRequiredDocumentInsert.add(objKYCRequiredDocuments);
                }
            }
        }
        if (masterAgreementNames.isEmpty() && mapMasterAgreementNames.containsKey(strManagedFundId)) {
            for (String strMasterAgreementDetails : mapMasterAgreementNames.get(strManagedFundId)) {
                KYC_Required_Documents__c objKYCRequiredDocuments = createKYCRequiredDocument(
                    'Resolution to Amend the Master Agreement Exhibit', mapKycStatus.get(strManagedFundId).Id
                );
                objKYCRequiredDocuments.Master_Agreement_Name__c = strMasterAgreementDetails;
                listKycRequiredDocumentInsert.add(objKYCRequiredDocuments);
            }
        }
        
        if (!masterAgreementNames.isEmpty() && mapMasterAgreementNames.containsKey(strManagedFundId)) {
            for (String masterAgreement : mapMasterAgreementNames.get(strManagedFundId)) {
                if (!masterAgreementNames.contains(masterAgreement)) {
                    KYC_Required_Documents__c objKYCRequiredDocuments = createKYCRequiredDocument(
                        'Resolution to Amend the Master Agreement Exhibit', mapKycStatus.get(strManagedFundId).Id
                    );
                    objKYCRequiredDocuments.Master_Agreement_Name__c = masterAgreement;
                    listKycRequiredDocumentInsert.add(objKYCRequiredDocuments);
                }
            }
        }
        if(!listKycRequiredDocumentInsert.isEmpty()){
            try{
                insert listKycRequiredDocumentInsert;
                isSuccess = true;
            }
            catch(DmlException e) {
                 LOGGER.ERROR('The following exception has occurred: ',e);
            }
        } 
        return isSuccess;
    }
    
    private static KYC_Required_Documents__c createKYCRequiredDocument(String documentType, Id kycReviewStatusId) {
        KYC_Required_Documents__c objKYCRequiredDocuments = new KYC_Required_Documents__c(
            Status__c = 'Outstanding',
            Document_Required__c = documentType,
            KYC_Review_Status__c = kycReviewStatusId
        );
        return objKYCRequiredDocuments;
    }
    
    /**
     * @description Create content document link for the inserted kyc required document related to the multiple kyc record.
     * @param list_KYCStatusRecordId List of kyc requied document records.
     * @param strContentDocumentId String inserted content document ID
     * @return isSuccess true if the required documents inserted successfully.
     */
    @AuraEnabled
    public static Boolean createContentDocumentLink(List<String> list_KYCStatusRecordId, String strContentDocumentId){
        Boolean isSuccess = true;
        
        // Get the ContentDocumentLink record
        ContentDocumentLink objContentDocumentLinkRecord = new SEL_ContentDocumentLink().selectRecordByContentDocumentId(strContentDocumentId)[0];
        
        List<ContentDocumentLink> listContentDocumentLink = new List<ContentDocumentLink>();
        List<KYC_Required_Documents__c> listKYCRequiredDocument = new SEL_KYCRequiredDocuments().selectKYCRequiredDocumentId(list_KYCStatusRecordId);
        List<KYC_Required_Documents__c>listKYCRequiredDocuemntUpdate = new list<KYC_Required_Documents__c>();
        
        Set<Id> managedFundIdSet = new Set<Id>();
        // Create ContentDocumentLinks and update KYC Required Documents
        for (KYC_Required_Documents__c objKYCDoc : listKYCRequiredDocument) {
            objKYCDoc.Status__c = 'Received';
            objKYCDoc.Date_Received__c = Date.today();
            listKYCRequiredDocuemntUpdate.add(objKYCDoc);
            
            ContentDocumentLink objContentDocumentLink = new ContentDocumentLink();
            objContentDocumentLink.LinkedEntityId = objKYCDoc.Id;
            objContentDocumentLink.ContentDocumentId = objContentDocumentLinkRecord.ContentDocumentId;
            objContentDocumentLink.shareType = 'V';
            
            listContentDocumentLink.add(objContentDocumentLink);
            
            managedFundIdSet.add(objKYCDoc.KYC_Review_Status__r.ManagedFundID__c);
        }
        
        List<OMF_ManagedFund__c> listManagedFundRecord = new SEL_OMF_ManagedFunds().selectBySetOfId(managedFundIdSet);
        for(OMF_ManagedFund__c objManagedFund : listManagedFundRecord){
            objManagedFund.Onboarding_Status__c = 'Document Upload';
        }
        
        try{
            insert listContentDocumentLink;
            update listKYCRequiredDocuemntUpdate;
            update listManagedFundRecord;
        }
        catch(Exception ex){
            isSuccess = false;
            LOGGER.ERROR('An exception occured',ex);
        }
        return isSuccess;
    }
    
    
    /**
     * @description Initiate the kyc process i.e sending the records details for KYC.
     * @param list_ManagedFundId List of managed fund Id
     * @return isSuccess true if the kyc has been initiated.
     */
    @AuraEnabled
    public static Boolean inititateKYC(List<Id> list_ManagedFundId) {
        Boolean isSuccess = false;
        List<OMF_ManagedFund__c> listManagedFunds = new SEL_OMF_ManagedFunds().selectManagedFundRecordByRecordIdList(list_ManagedFundId);
        if (listManagedFunds.isEmpty()) {
            return isSuccess; // No records to process, return false.
        }
        List<OMF_ManagedFund__c> listManagedFundToUpdate = new List<OMF_ManagedFund__c>();
        
        for (OMF_ManagedFund__c objManagedFund : listManagedFunds) {
            listManagedFundToUpdate.add(objManagedFund);
            doInitiateKyc(objManagedFund.Fund__c,objManagedFund.Id);
        }
        
        OMF_ManagedFund__c objManagedFundUpdate = new OMF_ManagedFund__c(
            Id = listManagedFundToUpdate[0].BulkOnboarding__c,
            Onboarding_Status__c = 'Submitted'
        );
        
        listManagedFundToUpdate.add(objManagedFundUpdate);
        
        try{
            isSuccess = true;
            update listManagedFundToUpdate;
        }
        catch(Exception ex){
            isSuccess = false;
             LOGGER.ERROR('An exception has occured while updating record',ex);
        }
        
        return isSuccess;
    }
    /**
    * @description delete the content document link related to the record id
    * @param recordId
    */
    @AuraEnabled
    public static void deleteContentDocumentLink(String recordId){
        //Get content documenaddKYCDocumentt link
        ContentDocumentLink [] listContentDocumentLink = new SEL_ContentDocumentLink().selectByStringLinkEntityId(recordId);
        if(listContentDocumentLink.size()>0){
            try{
                Delete listContentDocumentLink;
            }
            catch(Exception ex){
                 LOGGER.ERROR('An error occured while deleting content document link',ex);
            }
        }
    }
    
    /**
    * @description call the webservice to send kyc related data
    * @param fundRecordId
    * @param managedfundRecordId
    */
    @future(callout=true)
    public static void doInitiateKyc(String fundRecordId,String managedfundRecordId){
        if(String.isNotBlank(fundRecordId) && String.isNotBlank(managedfundRecordId)){
            OMF_API_OnboardMyFundServiceJSON service = new OMF_API_OnboardMyFundServiceJSON(fundRecordId,managedfundRecordId,'SA');
            service.sendRequest();
        }    
    } 
    /**
    * @description call the webservice to send kyc related data
    * @param strDocumentId
    */
    @AuraEnabled
    public static void deleteDocument(String strDocumentId){
        ContentDocument objContentDocument = [SELECT Id FROM ContentDocument WHERE Id =: strDocumentId];
        delete objContentDocument;
    }
     /**
    * @description To check the size of the document
    * @param contentDocumentId
    */
    @AuraEnabled
    public static boolean getDocumentSizeError(String contentDocumentId) {
        boolean documentSizeError = false;
        OMFSetting__mdt fileSize = OMFSetting__mdt.getInstance('OMF_FileSizeLimit');
        ContentVersion uploadedDocument = new ContentVersion();
        try{
           uploadedDocument = [SELECT Id, ContentSize FROM ContentVersion WHERE ContentDocumentId = :contentDocumentId LIMIT 1];
        }catch(Exception ex){
            LOGGER.ERROR('An exception occured',ex);
        }
        if (uploadedDocument != null && uploadedDocument.ContentSize > fileSize.FileSizeLimit__c) {
            documentSizeError = true;
            deleteDocument(contentDocumentId);
        }

        return documentSizeError;
    }
}