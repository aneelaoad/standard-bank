/**
 * Conversation Selector Layer class.
 *
 * @author Mikołaj Rzepiński (mrzepinski@deloittece.com)
 * @date September 2020
 */
public with sharing class SEL_Conversations extends fflib_SObjectSelector {

    /**
     * @description  This method for getting SObject Field List
     * @return schema list of fields
    **/
    public List<Schema.SObjectField> getSObjectFieldList() {

        return new List<Schema.SObjectField> {
                Conversation__c.PBB_Attrition_Risk__c,
                Conversation__c.PBB_BusinessRiskIndex__c,
                Conversation__c.Category__c,
                Conversation__c.Client__c,
                Conversation__c.Close_Date__c,
                Conversation__c.isClosed__c,
                Conversation__c.Closed_By__c,
                Conversation__c.Comments__c,
                Conversation__c.CreatedById,
                Conversation__c.CurrencyIsoCode,
                Conversation__c.Description__c,
                Conversation__c.Expected_OI__c,
                Conversation__c.ExternalId__c,
                Conversation__c.ExternalIdLeadKey__c,
                Conversation__c.PBB_File_Id__c,
                Conversation__c.Future_Contact_Date__c,
                Conversation__c.PBB_HighValueCD__c,
                Conversation__c.Is_User_A_Manager__c,
                Conversation__c.IsActive__c,
                Conversation__c.LastModifiedById,
                Conversation__c.Name,
                Conversation__c.OwnerId,
                Conversation__c.Reason__c,
                Conversation__c.Response__c,
                Conversation__c.Status__c,
                Conversation__c.Subcategory__c,
                Conversation__c.Type__c,
                Conversation__c.BPID__c,
                Conversation__c.Registration_Number__c
        };
    }

    /**
    * @description  This method is to SObjectType
    * @return   Conversation object
    **/
    public Schema.SObjectType getSObjectType() {
        return Conversation__c.sObjectType;
    }

    /**
    * @description  This method is to newInstance
    * @return   Conversation object
    **/
    public static SEL_Conversations newInstance() {
        return(SEL_Conversations) ORG_Application.selector.newInstance(Conversation__c.SObjectType);
    }

    /**
    * @description  This method is to extra fields
    * @param	idSet set of Id's
    * @return   Results of a query
    **/
    public List<Conversation__c> selectByIdWithExtraFields(Set<ID> idSet) {

        fflib_QueryFactory conQueryFactory = newQueryFactory();
        conQueryFactory.selectField('Client__c.Name')
                .selectField('Client__c.Name')
                .selectField('CreatedById.Name')
                .selectField('OwnerId.Name')
                .selectField('LastModifiedById.Name')
                .selectField('LastModifiedDate')
                .selectField('CreatedDate')
                .setCondition('Id in :idSet');

        return (List<Conversation__c>) Database.query(
                conQueryFactory.toSOQL());
    }

    /**
    * @description  This method is to get fields using external id
    * @param	recordExternalIds set of Strings
    * @return   Results of a query
    **/
    public List<Conversation__c> selectByExternalId(Set<String> recordExternalIds) {
        return (List<Conversation__c>) Database.query(
                newQueryFactory().
                        selectField('Subcategory__c')
                        .setCondition('ExternalId__c IN :recordExternalIds').
                        toSOQL());
    }

    /**
    * @description  This method is to get Lead keys using external id
    * @param	recordExternalIdLeadKeys set of Strings
    * @return   Results of a query
    **/
    public List<Conversation__c> selectByExternalIdLeadKey(Set<String> recordExternalIdLeadKeys) {
        return (List<Conversation__c>) Database.query(
                newQueryFactory().
                        selectField('Subcategory__c')
                        .setCondition('ExternalIdLeadKey__c IN :recordExternalIdLeadKeys').
                        toSOQL());
    }

    /**
    * @description  This method is to get Conversation context
    * @param	recordIds set of Ids
    * @return   Results of a query
    **/
    public List<Conversation__c> selectContextConversations(Set<Id> recordIds) {
        return (List<Conversation__c>) Database.query(
                newQueryFactory().
                        setCondition('Id IN :recordIds').
                        toSOQL());
    }

    /**
    * @description  This method is to get conversation by external Id
    * @param	recordIds set of Strings
    * @return   Results of a query
    **/
    public List<Conversation__c> selectExternalIdForConversations(Set<Id> recordIds) {
        return (List<Conversation__c>) Database.query(
                newQueryFactory().
                        setCondition('Id IN :recordIds').
                        toSOQL());
    }

    /**
    * @description  This method Deactivate by Owner
    * @param	userId user Id
    * @param	conversationIds set of Strings
    * @return   Results of a query
    **/
    public List<Conversation__c> selectByOwnerToDeactivate(Id userId, Set<Id> conversationIds) {
        return (List<Conversation__c>) Database.query(
                newQueryFactory().
                        setCondition('OwnerId = :userId AND Id NOT IN :conversationIds AND IsActive__c = TRUE AND isClosed__c = FALSE').
                        toSOQL());
    }

    /**
    * @description  This method Deactivate by Account Selected
    * @param	accountId Account Id
    * @param	conversationIds set of Strings
    * @return   Results of a query
    **/
    public List<Conversation__c> selectByAccountToDeactivate(Id accountId, Set<Id> conversationIds) {
        return (List<Conversation__c>) Database.query(
                newQueryFactory().
                        setCondition('Client__c = :accountId AND Id NOT IN :conversationIds AND IsActive__c = TRUE AND isClosed__c = FALSE').
                        toSOQL());
    }

    /**
    * @description  This method Deactivate by Account Selected
    * @param	userIds Account Id
    * @param	conversationIds set of Strings
    * @return   Results of a query
    **/
    public List<Conversation__c> selectByOwnersToDeactivate(Set<Id> userIds, Set<Id> conversationIds) {
        return (List<Conversation__c>) Database.query(
                newQueryFactory().
                        setCondition('OwnerId IN :userIds AND Id NOT IN :conversationIds AND IsActive__c = TRUE AND isClosed__c = FALSE').
                        toSOQL());
    }

    /**
    * @description  This method Deactivate by Account Selected
    * @param	accountIds Account Id
    * @param	conversationIds set of Ids
    * @return   Results of a query
    **/
    public List<Conversation__c> selectByAccountsToDeactivate(Set<Id> accountIds, Set<Id> conversationIds) {
        return (List<Conversation__c>) Database.query(
                newQueryFactory().
                        setCondition('Client__c IN :accountIds AND Id NOT IN :conversationIds AND IsActive__c = TRUE AND isClosed__c = FALSE').
                        toSOQL());
    }

    /**
    * @description  Method querying the Account Object
    * @param	accountIds set of Ids
    * @return   Results of a query
    **/
    public List<Conversation__c> selectByAccounts(Set<Id> accountIds) {
        return (List<Conversation__c>) Database.query(
                newQueryFactory().
                        setCondition('Client__c IN :accountIds AND IsActive__c = TRUE AND isClosed__c = FALSE').
                        toSOQL());
    }
}