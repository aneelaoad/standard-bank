/**
* @Name of the Class : OMF_BulkOnboardMyFund
* @Description : As operational manager  
                 I want the ability to Read,Create,Edit the data.
                 So that I can be able to Onboard asset manager's fund .
* @Author : Khushmeet Kaur (Khushmeet.kaur@standardbank.co.za)
* @Created Date : 2023-03-25
*/
/***************************************************************************************
@Last Modified By : 2024-05-10
@Last Modified On : Khushmeet Kaur (Khushmeet.kaur@standardbank.co.za)
@Modification description: SFP-35400 Added a method to insert kyc records when user edit the master contracts.
***************************************************************************************/

@SuppressWarnings('PMD.FieldNamingConventions,PMD.ClassNamingConventions,PMD.NcssMethodCount,PMD.ExcessivePublicCount')
public without sharing class OMF_BulkOnboardMyFund {
     private static final sbgplatform.rflib_Logger LOGGER = sbgplatform.rflib_LoggerUtil.getFactory().createLogger('OMF_BulkOnboardMyFund');
     private static final String omfManagedFundObject = 'OMF_ManagedFund__c';
     private static final String SingleOnboardingRecordType = 'Single Onboarding';
     private static final String accountObject = 'Account';
     private static final String fundRecordType = 'Fund';
     private static final String fundDetailsStage = 'Fund Details';
     private static final String contractObject = 'Contract';
     private static final String masterAgreementRecordType = 'Master Agreement';
     private static final String kYCReviewStatus = 'Awaiting Compliance/Legal Guidance';
     private static final String gTRisk = 'High';
     private static final String legalOnboardingStatus = 'Legal+Credit';
     private static final String otherAgreementType = 'Other';
     private static final String documentUploadStage = 'Document Upload';
    @AuraEnabled
    /**
    * @description Get the Fund Record and Master Agreement(Contract) related to the searched Registration Number.
    * @param strfundRegistrationNumber The registration number to search for.
    * @param strRecordId The ID of the record
    * @return Wrapper containing Fund List and Master Agreement List.
    */
    public static GetFundMasterAgreementWrapper getFundMasterAgreementDetails(String strfundRegistrationNumber, String strRecordId) {
        GetFundMasterAgreementWrapper objgetFundMasterAgreementWrapper = new GetFundMasterAgreementWrapper();
        Id masterAgreementRecordTypeId = OMF_BulkOnboardMyFund.getRecordTypeId(contractObject,masterAgreementRecordType);
        try{
            List<Account> listFundRecord = new SEL_Accounts().selectedAccountWithRegistrationNumberOfFundRecordType(strfundRegistrationNumber);
            OMF_ManagedFund__c objManagedFund = new SEL_OMF_ManagedFunds().selectedByRecordId(strRecordId)[0];
            List<Contract> listContractRecord = new SEL_Contracts().selectActiveMasterAgremeentWithoutOther(masterAgreementRecordTypeId,objManagedFund.AssetManager__c);
            Account[] listAssetManager = new SEL_Accounts().selectAccountDetail(objManagedFund.AssetManager__c);
            
            if (!listFundRecord.isEmpty()) {
                objgetFundMasterAgreementWrapper.objFundDetail = listFundRecord[0];
            } else {
                objgetFundMasterAgreementWrapper.objFundDetail = null;
            }
            
            objgetFundMasterAgreementWrapper.listContractDetails = listContractRecord;
            if(!listAssetManager.isEmpty()){
                objgetFundMasterAgreementWrapper.objAssetManagerDetail = listAssetManager[0];
            }
        }
        catch(Exception ex){
           LOGGER.ERROR('Error: ',ex);
        }
        return objgetFundMasterAgreementWrapper;
    }
    
    /**
     * @description GetFundMasterAgreementWrapper Wrapper class to store fund details and contract details
     */
    public class GetFundMasterAgreementWrapper{ 
        /**
         * @description objFundDetail this will store the account (Fund details)
         */
        @AuraEnabled public Account objFundDetail{get;set;} 
        /**
         * @description listContractDetails this will store the list of contract details
         */
        @AuraEnabled public List<Contract>listContractDetails{get;set;}
        /**
         * @description objAssetManagerDetail this will store the list of contract details
         */
        @AuraEnabled public Account objAssetManagerDetail{get;set;}
    }
    /**
    * @description updateFundRecords to update the fund records
    * @param strRecordDetails Wrapper class strRecordDetails
    * @return Boolean containing Fund List and Master Agreement List.
    */
    @AuraEnabled
     public static Boolean updateFundRecords(String strRecordDetails){
        
        
        RecordDetails objrecordDetails = (RecordDetails) System.JSON.deserialize(strRecordDetails, RecordDetails.class);
        
        Account objFund = objrecordDetails.objFundDetails;
        
         
        Database.update(objFund);
         
        String strManagedFundId = objRecordDetails.strManagedFundId;
        Database.update(new OMF_ManagedFund__c(Id = objRecordDetails.strManagedFundId, ShortName__c = objRecordDetails.strShortName));
         
         return true;
        
    }

    
    @AuraEnabled
    /**
     * @description createRecords Create all of the records including managed fund, fund, KYC status, and fund-to-agreement.
     * @param strRecordDetails The ID of the parent record.
     * @return OMF_ManagedFund__c List of Managed Fund Records.
     */
    public static List<OMF_ManagedFund__c> createRecords(String strRecordDetails){
        
        RecordDetails objrecordDetails = (RecordDetails) System.JSON.deserialize(strRecordDetails, RecordDetails.class);
        
        Account objFund = objrecordDetails.objFundDetails;
        objFund.RecordTypeId = OMF_BulkOnboardMyFund.getRecordTypeId(accountObject,fundRecordType);
        
         
        String strFundId = String.isNotBlank(objFund.Id) && !objRecordDetails.blnEditModal ? objFund.Id : Database.upsert(objFund).getId();
 
        OMF_ManagedFund__c objManagedFund = new SEL_OMF_ManagedFunds().selectByManagedFundRecordWithId(objrecordDetails.strManagedFundParentRecordId)[0];
        
        String assetManagerId;
        String strManagedFundId;
        if (objRecordDetails.blnEditModal == true) {
            strManagedFundId = objRecordDetails.strManagedFundId;
            Database.update(new OMF_ManagedFund__c(Id = objRecordDetails.strManagedFundId, ShortName__c = objRecordDetails.strShortName));
        } else {
            strManagedFundId = Database.insert(new OMF_ManagedFund__c(
                AssetManager__c = objManagedFund.AssetManager__c,
                Fund__c = strFundId,
                RecordTypeId = OMF_BulkOnboardMyFund.getRecordTypeId(omfManagedFundObject,SingleOnboardingRecordType),
                ShortName__c = objRecordDetails.strShortName,
                Onboarding_Status__c = fundDetailsStage,
                BulkOnboarding__c = objManagedFund.Id
            )).getId();
            
            KYC_Status__c objKYCStatus = new KYC_Status__c();
            objKYCStatus.Client__c = strFundId;
            objKYCStatus.KYC_Review_Status__c = kYCReviewStatus;
            objKYCStatus.GT_Risk__c = gTRisk;
            objKYCStatus.ManagedFundID__c = strManagedFundId;
            objKYCStatus.ManagedFundKYCRecord__c = true;
            Database.insert(objKYCStatus);
        }  
        assetManagerId = objManagedFund.AssetManager__c;
        
        createMasterAgreementRecords(strManagedFundId,assetManagerId,objrecordDetails);
        
        list<OMF_ManagedFund__c> listCreatedManagedFundRecord  =new SEL_OMF_ManagedFunds().selectByManagedFundRecordWithId(strManagedFundId);
        return listCreatedManagedFundRecord;
    }
    
    private static void createMasterAgreementRecords(String strManagedFundId,String assetManagerId,RecordDetails objrecordDetails){
        
        //Get the existing fund to agreement records.
        List<OMF_FundToAgreement__c> listFundToAgreementRecord = new SEL_OMFFundToAgreement().selectFundToAgreementByOtherMasterAgreement(strManagedFundId);
        List<Contract> contractsToUpdate = new List<Contract>();
        list<OMF_FundToAgreement__c>listMasterAgreementDelete = new list<OMF_FundToAgreement__c>();
        List<String> existingMasterAgreementIds = new List<String>();
        Map<String, OMF_FundToAgreement__c> existingMasterAgreementsByFundToAgreement = new Map<String, OMF_FundToAgreement__c>();
        Boolean blnMasterRecordExist = false;
            
        for (OMF_FundToAgreement__c fundToAgreement : listFundToAgreementRecord) {
             if (fundToAgreement.MasterAgreementID__r.AgreementType__c == 'Other') {
                 if (fundToAgreement.MasterAgreementID__r.Products__c != objrecordDetails.strOtherProducts) {
                        Contract contractToUpdate = new Contract();
                        contractToUpdate.Id = fundToAgreement.MasterAgreementID__c;
                        contractToUpdate.Products__c = objrecordDetails.strOtherProducts;
                        contractsToUpdate.add(contractToUpdate);
                    }
                 else if(fundToAgreement.MasterAgreementID__r.Products__c == objrecordDetails.strOtherProducts){
                     blnMasterRecordExist = true;
                 }
           }
           if(fundToAgreement.MasterAgreementID__r.AgreementType__c == 'Other' && String.isBlank(objrecordDetails.strOtherProducts)){
                 listMasterAgreementDelete.add(fundToAgreement);
           }
           else {
                 if(fundToAgreement.MasterAgreementID__r.AgreementType__c != 'Other' ){
                        existingMasterAgreementIds.add(fundToAgreement.MasterAgreementID__c);
                        existingMasterAgreementsByFundToAgreement.put(fundToAgreement.MasterAgreementID__c, fundToAgreement);
                   }
             }
        }
        
        List<Id> masterAgreementIdsToInsert = new List<Id>();
        if (objrecordDetails.list_MasterAgreement != null) {
            for (String masterAgreementId : objrecordDetails.list_MasterAgreement) {
                if (!existingMasterAgreementIds.contains(masterAgreementId)) {
                    masterAgreementIdsToInsert.add(masterAgreementId);
                }
            }
        }
        
        
        list<String>listMasterAgreementNameDelete = new list<String>();
        //Get the master agreement which needs to be deleted
        for (String strExisitingMasterAgreementId : existingMasterAgreementIds) {
            if (!objrecordDetails.list_MasterAgreement.contains(strExisitingMasterAgreementId)) {
                listMasterAgreementDelete.add(existingMasterAgreementsByFundToAgreement.get(strExisitingMasterAgreementId));
                listMasterAgreementNameDelete.add(existingMasterAgreementsByFundToAgreement.get(strExisitingMasterAgreementId).MasterAgreementID__r.Name);
            }
        }
        List<Id>listMasterAgreementId = new List<Id>();
        
        
        if (contractsToUpdate.size() == 0 && String.isNotBlank(objrecordDetails.strOtherProducts) && blnMasterRecordExist == false){
            Contract otherProductContract = new Contract();
            otherProductContract.AccountId = assetManagerId;
            otherProductContract.AgreementType__c = otherAgreementType;
            otherProductContract.StartDate = System.today();
            otherProductContract.Products__c = objrecordDetails.strOtherProducts;
            otherProductContract.Status = 'Draft';
            otherProductContract.Active__c = true;
            otherProductContract.RecordTypeId = OMF_BulkOnboardMyFund.getRecordTypeId(contractObject,masterAgreementRecordType);
            
            try{
                Database.SaveResult objInsertResult = Database.insert(otherProductContract);
                String strOtherProductContractId = objInsertResult.getId();
                listMasterAgreementId.add(strOtherProductContractId);
            }
            catch(Exception ex){
                LOGGER.ERROR('An exception an occured: ',ex);
            }
        }
        
        
        if (objrecordDetails.list_MasterAgreement != null && objrecordDetails.list_MasterAgreement.size() > 0 && masterAgreementIdsToInsert.size() <0 ) {
            listMasterAgreementId.addAll(objrecordDetails.list_MasterAgreement);
        }
        
        else if(listMasterAgreementId.size() == 0){
            listMasterAgreementId = masterAgreementIdsToInsert;
        }
        
        if(contractsToUpdate.size()>0){
            try{
                update contractsToUpdate;
            }
            catch(Exception ex){
                LOGGER.ERROR('An exception an occured: ',ex);
            }
        }
        
        try{
            KYC_Required_Documents__c[] listKycDocumentDelete = new SEL_KYCRequiredDocuments().selectByKYCRequiredDocumentsByMasterAgreementName(strManagedFundId,listMasterAgreementNameDelete);
            Database.delete(listKycDocumentDelete, false);
        }
        catch(Exception ex){
           LOGGER.ERROR('An exception an occured: ',ex);
        }
        
        List<OMF_FundToAgreement__c> listFundToAgreement = new List<OMF_FundToAgreement__c>();
        for (String strMasterAgreementId : listMasterAgreementId) {
            OMF_FundToAgreement__c objFundToAgreement = new OMF_FundToAgreement__c();
            objFundToAgreement.ManagedFundID__c = strManagedFundId;
            objFundToAgreement.MasterAgreementID__c = strMasterAgreementId;
            listFundToAgreement.add(objFundToAgreement);
        }
        
        Database.insert(listFundToAgreement);
        
        
        if (listMasterAgreementDelete.size() > 0) {
            try{
                delete listMasterAgreementDelete;
            }
            catch(Exception ex){
               LOGGER.ERROR('An exception an occured: ',ex);
            }
        }
        
        if(objrecordDetails.blnEditModal == false){
            OMF_UploadDocumentsController.createKYCRequiredDocument(strManagedFundId);
        }
        else{
            createEditKYCRequiredDocument(strManagedFundId);
        }
        
        OMF_BulkOnboardMyFund.createContentDocumentLinkNewManagedFundRecord(objrecordDetails.strManagedFundParentRecordId,strManagedFundId);
    }
    
    /**
    * @description  Wrapper class to store fund details,short name,master agreement,other product and  more details
    */
    public class RecordDetails {
        @AuraEnabled public Account objFundDetails;
        @AuraEnabled public String strShortName;
        @AuraEnabled public List<String> list_MasterAgreement;
        @AuraEnabled public String strOtherProducts;
        @AuraEnabled public String strManagedFundParentRecordId;
        @AuraEnabled public Boolean blnEditModal;
        @AuraEnabled public String strManagedFundId;
    }
    /*Create kyc required document record when the master agreement is de-selected and selected again.
     */
    private static void createEditKYCRequiredDocument(String strManagedFundId){
        
        Set<String> masterAgreementNames = new Set<String>();
        Map<String, Set<String>> mapMasterAgreementNames = new Map<String, Set<String>>();
        Map<String, KYC_Status__c> mapKycStatus = new Map<String, KYC_Status__c>();
    List < KYC_Required_Documents__c > listKycRequiredDocuments = new SEL_KYCRequiredDocuments().selectKYCDocumentsWithManagedFund(strManagedFundId);
   
        
    try {
        for (KYC_Required_Documents__c objKYCRequiredDocument : listKycRequiredDocuments) {
            masterAgreementNames.add(objKYCRequiredDocument.Master_Agreement_Name__c);
        }

        for (KYC_Status__c objKYCStatus: new SEL_KYCStatuses().selectKYCStatusByManagedFund(strManagedFundId)) {
            mapKycStatus.put(objKYCStatus.ManagedFundID__c, objKYCStatus);
        }
       	//List MasterAgreement to be inserted.
       	List<String>masterAgreementInsert = new list<String>();
        for (OMF_FundToAgreement__c objFundToAgreement: new SEL_OMFFundToAgreement().selectFundToAgreementByManagedFundID(strManagedFundId)) {
            if(!masterAgreementNames.contains(objFundToAgreement.MasterAgreementId__r.Name)){
                mapMasterAgreementNames.put(objFundToAgreement.ManagedFundId__c, new set<String>{ objFundToAgreement.MasterAgreementId__r.Name });
            }
        }
        
        List<KYC_Required_Documents__c> listKycRequiredDocumentInsert = new List<KYC_Required_Documents__c>();
        if (mapMasterAgreementNames.containsKey(strManagedFundId)) {
            
            for (String strMasterAgreementDetails : mapMasterAgreementNames.get(strManagedFundId)) {
                KYC_Required_Documents__c objKYCRequiredDocuments = createKYCRequiredDocument(
                    'Resolution to Amend the Master Agreement Exhibit', mapKycStatus.get(strManagedFundId).Id
                );
                
                objKYCRequiredDocuments.Master_Agreement_Name__c = strMasterAgreementDetails;
                listKycRequiredDocumentInsert.add(objKYCRequiredDocuments);
            }
        }
        insert listKycRequiredDocumentInsert;
    } catch (Exception ex) {
        LOGGER.ERROR('An exception an occured: ', ex);
    }

    }
    
    private static KYC_Required_Documents__c createKYCRequiredDocument(String documentType, Id kycReviewStatusId) {
        KYC_Required_Documents__c objKYCRequiredDocuments = new KYC_Required_Documents__c(
            Status__c = 'Outstanding',
            Document_Required__c = documentType,
            KYC_Review_Status__c = kycReviewStatusId
        );
        return objKYCRequiredDocuments;
    }
    
    @AuraEnabled
   /**
     * @description Create content document link for the managed fund
     *              record which is added, if the existing parent record id has some content document id.
     * @param strParentRecordId The ID of the parent record.
     * @param strManagedFundId The ID of the managed fund.
     */

    public static void createContentDocumentLinkNewManagedFundRecord(String strParentRecordId,String strManagedFundId){
        List<ContentDocumentLink> listContentDocumentLink = new SEL_ContentDocumentLink().selectByStringLinkEntityId(strParentRecordId);
        if (listContentDocumentLink.isEmpty()) {
            return;
        }
        try{
            Set<Id>setKycRequiredDocumentId = new set<Id>();
            map<String,String>mapKyuRequiredDocumentIdByDocumentName = new map<String,String>();
            //Get list of required document
            Id managedFundRuleRecordId = Schema.SObjectType.OMF_ManagedFundRules__c.getRecordTypeInfosByName().get('KYC Documents').getRecordTypeId();
            
            OMF_ManagedFundRules__c[] listManagedFundRules = new SEL_OMF_ManagedFundRules().selectedManagedFundRulesWithRecordTypeId(managedFundRuleRecordId);
            
            List<String> listKycRequiredDocument = new list<String>();
             for(OMF_ManagedFundRules__c objManagedFundRules : listManagedFundRules){
                listKycRequiredDocument.addAll(objManagedFundRules.DocumentRequired__c.split(';'));
                listKycRequiredDocument.addAll(objManagedFundRules.AdditionalDocuments__c.split(';'));
        	}
            //Get all the kyc status records with parent id
            for(KYC_Required_Documents__c objKYCRequiredDocument : new SEL_KYCRequiredDocuments().selectByKYCRequiredDocumentAndManagedFundId(listKycRequiredDocument,strParentRecordId,strManagedFundId)){
                setKycRequiredDocumentId.add(objKYCRequiredDocument.Id);
                String documentName = String.isNotBlank(objKYCRequiredDocument.Master_Agreement_Name__c) ? objKYCRequiredDocument.Master_Agreement_Name__c : objKYCRequiredDocument.Document_Required__c;
                mapKyuRequiredDocumentIdByDocumentName.put(objKYCRequiredDocument.Id,documentName);
            } 
            map<String,String>mapKycRequiredDocumentNameByContentDocumentId = new map<String,String>();
            List<ContentDocumentLink> listContentDocumentLinkInsert = new List<ContentDocumentLink>();
            List<SObject> updateList = new List<SObject>();

            //Get content document link
            for(ContentDocumentLink objContentDocumentLink :new SEL_ContentDocumentLink().selectByLinkedEntityId(setKycRequiredDocumentId)){
                mapKycRequiredDocumentNameByContentDocumentId.put(mapKyuRequiredDocumentIdByDocumentName.get(objContentDocumentLink.LinkedEntityId),objContentDocumentLink.ContentDocumentId);
            }
            
            for (KYC_Required_Documents__c objKYCRequiredDocument :new SEL_KYCRequiredDocuments().selectByKYCRequiredDocumentWithManagedFundId(listKycRequiredDocument,strManagedFundId)){    
                String documentName = String.isNotBlank(objKYCRequiredDocument.Master_Agreement_Name__c) ? objKYCRequiredDocument.Master_Agreement_Name__c : objKYCRequiredDocument.Document_Required__c;
                if (mapKycRequiredDocumentNameByContentDocumentId.containsKey(documentName)) {
                    ContentDocumentLink objContentDocumentLink = new ContentDocumentLink();
                    objContentDocumentLink.LinkedEntityId = objKYCRequiredDocument.Id;
                    objContentDocumentLink.ContentDocumentId = mapKycRequiredDocumentNameByContentDocumentId.get(documentName);
                    objContentDocumentLink.shareType = 'V';
                    
                    listContentDocumentLinkInsert.add(objContentDocumentLink);
                    
                    objKYCRequiredDocument.Status__c = 'Received';
                    objKYCRequiredDocument.Date_Received__c = Date.today();
                    updateList.add(objKYCRequiredDocument);
                }
            }
            
            Database.update(new OMF_ManagedFund__c(Id = strManagedFundId, Onboarding_Status__c = documentUploadStage));
            insert listContentDocumentLinkInsert;
            update updateList;

        } catch (Exception ex) {
            LOGGER.ERROR('An exception an occured: ',ex);
        }
    }
    @AuraEnabled
   /**
     * @description Delete Managed Fund record and its related records.
     * @param strRecordId The ID of the Managed Fund Record.
     * @return Boolean indicating if all the records are deleted successfully.
     */
    public static list<OMF_ManagedFund__c> getExisitingManagedFundRecord(String strRecordId){
        List<OMF_ManagedFund__c> listManagedFundRecord = new SEL_OMF_ManagedFunds().selectManagedFundRecordByStatusNotCancelled(strRecordId);
        return listManagedFundRecord;
    }
    @AuraEnabled
    /**
      * @description  deleteManagedFundRecord Delete Managed Fund record and related records also.
      * @param strRecordId managed fund record id.
      * @return  strRecordId Boolean if all the records are deleted.
      */
    public static Boolean deleteManagedFundRecord(String strRecordId){
        Boolean blnIsSuccess = false;
        List<OMF_ManagedFund__c> listManagedFund = new SEL_OMF_ManagedFunds().selectByManagedFundWithKYCRecord(strRecordId);
        if (listManagedFund.isEmpty()) {
            return true;
        }
        try{
            OMF_ManagedFund__c managedFund = listManagedFund[0];
            if (!managedFund.KYC_Status__r.isEmpty()) {
                List<KYC_Status__c> listKYCStatus = listManagedFund[0].KYC_Status__r;
                Set<Id> setManagedFundParentId = new Set<Id>{managedFund.BulkOnboarding__c};
                List<Id> listContentDocumentDelete = new List<Id>();
                List<OMF_ManagedFund__c>listExistingManagedFund = new SEL_OMF_ManagedFunds().selectByParentRecordId(setManagedFundParentId,strRecordId);
                if(listExistingManagedFund.isEmpty()){
                    for (ContentDocumentlink objContentDocumentLink : new SEL_ContentDocumentLink().selectByLinkedEntityIdAllFields(setManagedFundParentId)) {
                        listContentDocumentDelete.add(objContentDocumentLink.ContentDocumentId);
                    }
                }
                delete managedFund;
                Database.delete(managedFund.Fund__c);//delete the fund record related to managed fund record
                Database.delete(listContentDocumentDelete, true);
                //delete as user objKYCStatus;
                set<Id> setKYCStatus = new set<Id>();
                for(KYC_Status__c objKYCStatus : listKYCStatus){
                    setKYCStatus.add(objKYCStatus.Id);
                }
                
                deleteKYCRecord(setKYCStatus);
            }
            blnIsSuccess = true; 
            
        }catch (Exception ex){
            LOGGER.ERROR('An exception an occured: ',ex);
            blnIsSuccess = false;
        }
        return blnIsSuccess;
    }
    
    @future
    private static void deleteKYCRecord(set<Id>listKYCId){
        list<KYC_Status__c>listKYCStatus = new SEL_KYCStatuses().selectById(listKYCId);
        delete listKYCStatus;
    }
    
    @AuraEnabled
    /**
      * @description getExistingRecordDetails Get the existing record details managed fund,
      * @param strRecordId Managed Fund Record Id.
      * @return Wrapper class of getExisitingRecordDetailWrapper.
      */
    public static getExisitingRecordDetailWrapper getExistingRecordDetails(String strRecordId){
        
        getExisitingRecordDetailWrapper objgetExisitingRecordDetailWrapper = new getExisitingRecordDetailWrapper();
        Map<Id, OMF_ManagedFund__c> mapManagedFunds = new SEL_OMF_ManagedFunds().selectByManagedFundRecord(strRecordId);
        String strFundId = mapManagedFunds.get(strRecordId).Fund__c;
        String strAssetManagerId = mapManagedFunds.get(strRecordId).AssetManager__c;
        String strShortName = mapManagedFunds.get(strRecordId).ShortName__c;
        
        List<OMF_FundToAgreement__c> lstFundToAgreements = new SEL_OMFFundToAgreement().selectFundToAgreementByOtherMasterAgreement(strRecordId);
        List<String> listSelectedMasterAgreementId = new List<String>();
        List<String> listOtherProductList = new List<String>();
        
        for (OMF_FundToAgreement__c objFundToAgreement : lstFundToAgreements) {
            if (objFundToAgreement.MasterAgreementID__r.AgreementType__c == 'Other') {
                listOtherProductList.addAll(objFundToAgreement.MasterAgreementID__r.Products__c.split(';'));
            } else {
                listSelectedMasterAgreementId.add(objFundToAgreement.MasterAgreementID__c);
            }   
        }
        
        Id fundRecordTypeId = OMF_BulkOnboardMyFund.getRecordTypeId(accountObject,fundRecordType);
        List<Account> lstFundRecords = new SEL_Accounts().selectedFundRecordDetail(strFundId,fundRecordTypeId);
        Account objFundDetail = lstFundRecords.isEmpty() ? new Account() : lstFundRecords[0];
        List<Contract>listContractRecord = new SEL_Contracts().selectMasterAgremeentWithOtherAgreementType(strAssetManagerId);
        objgetExisitingRecordDetailWrapper.objFundDetails = objFundDetail;
        objgetExisitingRecordDetailWrapper.list_selectedMasterAgreementId = listSelectedMasterAgreementId;
        objgetExisitingRecordDetailWrapper.list_masterAgreement = listContractRecord;
        objgetExisitingRecordDetailWrapper.list_OtherProducts = listOtherProductList;
        objgetExisitingRecordDetailWrapper.strShortName = strShortName;
        
        
        return objgetExisitingRecordDetailWrapper;
    } 
    
    /**
    * @description wrapper method
    */
    public class getExisitingRecordDetailWrapper {
        @AuraEnabled public Account objFundDetails; 
        @AuraEnabled public List<String> list_selectedMasterAgreementId;
        @AuraEnabled public List<Contract>list_masterAgreement;
        @AuraEnabled public List<String> list_OtherProducts;
        @AuraEnabled public String strShortName;
    }
     
    /**
     * @description Get the updateOnboardingStageLegal
     * @param recordId The record id for the current record.
     * @return Booleam
     */
	@AuraEnabled
    public static Boolean updateOnboardingStageLegal(String recordId) {
        Boolean isSuccess = false;
        OMF_ManagedFund__c[] listManagedFund = new SEL_OMF_ManagedFunds().selectedByRecordId(recordId);
        if(!listManagedFund.isEmpty()){
            OMF_ManagedFund__c objManagedFund = new OMF_ManagedFund__c();
            objManagedFund.Id = listManagedFund[0].Id;
            objManagedFund.Onboarding_Status__c = legalOnboardingStatus;
             update objManagedFund;
            isSuccess = true;
        }
        return isSuccess;
    }
    
    /**
     * @description Get the record type id
     * @param objAPIName The name of the object
     * @param recTypeDevName The name of the Record Type
     * @return Record Id of the specified Record Type for the given object
     */

    public static Id getRecordTypeId(String objAPIName, String recTypeDevName) {
        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objAPIName).getDescribe();
        // Get the map of record type information for the object
        Map<String, Schema.RecordTypeInfo> recordTypeMap = objectDescribe.getRecordTypeInfosByName();
        // Get the ID of the specified record type
        Id recordTypeId = recordTypeMap.get(recTypeDevName).getRecordTypeId();
        return recordTypeId;
    }
    
}