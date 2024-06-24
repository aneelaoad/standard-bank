/**
*
* @author Khushmeet Kaur (khushmeet.kaur@absyz.com)
* @date 2023-03-25
* @description Contract Selector Layer class.
* 
*/
public with sharing class SEL_Contracts extends fflib_SObjectSelector{
    /**
    * @description getSObjectFieldList
    * @return List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        
        return new List<Schema.SObjectField> {
            Contract.ActivatedById,
                Contract.ActivatedDate,
                Contract.Active__c,
                Contract.Agency__c,
                Contract.Agreement_ID__c,
                Contract.AgreementType__c,
                Contract.Agreement_Version__c,
                Contract.AssetClass__c,
                Contract.BillingAddress,
                Contract.AccountId,
                Contract.EndDate,
                Contract.Name,
                Contract.ContractNumber,
                Contract.OwnerId,
                Contract.RecordTypeId,
                Contract.StartDate,
                Contract.ContractTerm,
                Contract.CreatedById,
                Contract.CustomerSignedId,
                Contract.CustomerSignedDate,
                Contract.Data_Quality_Description__c,
                Contract.Data_Quality_Score__c,
                Contract.Description,
                Contract.HighLevelAssetClass__c,
                Contract.Jurisdictions__c,
                Contract.Products__c,
                Contract.ShippingAddress,
                Contract.Status
                };
                    }
    /**
    * @description selectById
    * @return Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType() {
        return Contract.sObjectType;
    }
    
    /**
     * @description Select Master Agreement with Account Id.
     * @param idmasterAgreeementRecordId The ID of the master agreement record.
     * @param idAccount The ID of the account.
     * @return List of Contract objects.
     */
    public List<Contract> selectMasterAgremeentWithAccountId(Id idmasterAgreeementRecordId,String idAccount) {
        
        return (List<Contract>) Database.query(
            newQueryFactory().
            setCondition('RecordTypeId =:idmasterAgreeementRecordId AND AccountId =:idAccount AND Active__c =True').
            toSOQL());
    }
    
    /**
    * @description selectMasterAgremeentWithOtherAgreementType
    * @param strAssetManagerId Asset Manager Id
    * @return List<ManagedFundRecord>
    */
    public List<Contract> selectMasterAgremeentWithOtherAgreementType(String strAssetManagerId) {
        
        return (List<Contract>) Database.query(
            newQueryFactory().
            setCondition('Active__c =True AND AccountId =:strAssetManagerId AND AgreementType__c != \'Other\'').
            toSOQL());
    }
   /**
    * @description selectContractByRecordId
    * @return List<Contract>
    * @param listContract Contract Id
    */
    public List<Contract> selectContractRecordByRecordId(List<String>listContract) {
        
        return (List<Contract>) Database.query(
            newQueryFactory().
            setCondition('Id =:listContract').
            toSOQL());
    }
    
   /**
    * @description selectContractByRecordId
    * @param strContractId Contract Id
    * @return List<Contract>
    */
    public Contract selectRecordById(String strContractId) {
        
        return (Contract ) Database.query(
            newQueryFactory().
            setCondition('Id =:strContractId').
            toSOQL());
    }
    
   /**
    * @description selectMasterAgremeentWithAccountId.
    * @param idmasterAgreeementRecordId 
    * @param idAccount Account Id.
    * @return List<Contract>
    */
    public List<Contract> selectActiveMasterAgremeentWithoutOther(Id idmasterAgreeementRecordId,String idAccount) {
        
        return (List<Contract>) Database.query(
            newQueryFactory().
            setCondition('RecordTypeId =:idmasterAgreeementRecordId AND AccountId =:idAccount AND Active__c =True AND AgreementType__c != \'Other\'').
            toSOQL());
    }
}