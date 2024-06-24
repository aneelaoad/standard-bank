/**
 * 
 * @author JP Basson (jabasson@deloitte.co.za)
 * @date March 2021
 * @description Selector class for Tasks
 *****************************************************************************************
 *   @ Last Modified By  :   Maham Hassan
 *   @ Last Modified On  :   05/04/2022
 *   @ Last Modified Reason  : Get list of Tasks based on Ids and Account Id.
 *
 *  @ Last Modified By  :   Maksim Dzianisik
 *  @ Last Modified On  :   March 2023
 *  @ Last Modified Reason  :   SFP-22261 Get list of Tasks based on WhatId with custom filter and limit
 *
 *****************************************************************************************
 */
public inherited sharing class SEL_Tasks extends fflib_SObjectSelector {

    /**
     * @description newInstance Method
     * @return SEL_Tasks- new instance for selector test methods
     */
    public static SEL_Tasks newInstance() {
		return(SEL_Tasks) ORG_Application.selector.newInstance(Task.SObjectType);
	}
    
    /**
     * @description getSObjectType
     * @return chema.SObjectType - Task sObjectType
     */
    public Schema.SObjectType getSObjectType(){
        return Task.sObjectType;
    }
    
    /**
     * @description getSObjectFieldList
     * @return List<Schema.SObjectField>  - specified fields in selector queries
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Task.Id,
            Task.WhatId,
            Task.Status,
            Task.Subject,            
            Task.Item_to_action__c,
            Task.IsRecurrence, 
            Task.Short_Description__c,
            Task.Description,
            Task.ActivityDate,
            Task.IsClosed,
            Task.Priority,
            Task.Type,
            Task.FinServ__Objectives__c,
            Task.FinServ__Expectations__c,
            task.RecurrenceActivityId
        };
    }

    /**
     * @description select tasks by  accountId
     * @param accountIds Set<Id> - Set of account id's to filter through
     * @return List<Task> - with query results
     */
    public List<Task> selectByAccountIds(Set<Id> accountIds) {
        
        return (List<Task>) Database.query(
                newQueryFactory().
                    selectField('Owner.Name').
                    selectField('Account.Name').
                    selectField('What.Name').
            		setCondition(' WhatId In : accountIds').
                    toSOQL());
    }  
    
     /**
     * @description select tasks by  accountId
     * @param ids Set<Id> - Set of id's to filter through
     * @return List<Task> - with query results
     */
    public List<Task> selectByIds(Set<Id> ids) {
        
        return (List<Task>) Database.query(
                newQueryFactory().
                    selectField('Owner.Name').
                    selectField('Account.Name').
                    selectField('What.Name').
            		setCondition(' Id in : ids').
                    toSOQL());
    } 

    /**
     * @description select tasks by subject and accountId
     * @param subject string - Task subject 
     * @param accountId Set<Id> - Set of account id's to filter through
     * @return List<Task> - with query results
     */
    public List<Task> selectBySubjectAndAccountId(String subject, Set<Id> accountId) {
        
        return (List<Task>) Database.query(
                newQueryFactory().
            			setCondition('Subject LIKE :subject AND WhatId in : accountId').
                        toSOQL());
    }  
    
     /**
     * @description select tasks by WhatId and RecordTypeId
     * @param whatIds
     * @param recordTypeId
     * @return List<Task> - with query results
     */
    public List<Task> selectByWhatIdsAndRecordTypeId(Set<Id> whatIds, String recordTypeId) {

        String condition = 'WhatId IN :whatIds AND RecordTypeId = :recordTypeId';

        return Database.query(
            newQueryFactory(false, false, true)
            .selectField('Subject')
            .selectField('PP_Phase__c')
            .selectField('PP_Step__c')
            .selectField('CompletedDateTime')
            .selectField('IsClosed')
            .selectField('WhatId')
            .selectField('Description')
            .selectField('RecordType.DeveloperName')
            .setCondition(condition)
            .toSOQL()
        );
    }
    
    /**
    * @description select tasks by WhatId and RecordTypeId
    * @param whatIds
    * @param recordTypeId
    * @return List<Task> - with query results
    */
    public List<Task> selectByWhatIdsAndRecordTypeIdWithoutSharing(Set<Id> whatIds, String recordTypeId) {
        return new WithoutSharing().selectByWhatIdsAndRecordTypeId(this, whatIds, recordTypeId);
    }

    /**
     * @description select tasks by WhatId with custom filter and limit
     * @param whatIds - Set<Id>
     * @param customFilter - String with custom "where" clause, will be added as "AND" after whatId
     * @param limitCount - Integer, number of records that have to be returned
     *
     * @return List<Task> - with query results
     */
    public List<Task> selectByWhatIdWithCustomFilterAndLimit(Set<Id> whatIds, String customFilter, Integer limitCount) {
        String condition = 'WhatId IN :whatIds';
        if (String.isNotBlank(customFilter)) {
            condition += ' AND ' + customFilter;
        }
        return (List<Task>) Database.query(
                newQueryFactory()
                .selectField('Owner.Name')
                .selectField('ActivityDate')
                .selectField('Who.Name')
                .selectField('Short_Description__c')
                .selectField('Subject')
                .selectField('Type')
                .setCondition(condition)
                .setLimit(limitCount)
                .toSOQL()
        );
    }
    
    /**
    * @description Sub class to query data without sharing
    * 
    * @author Peter (Peter.Guest@standardbank.co.za)
 	* @date Aug 2021
    */
    private without sharing class WithoutSharing { 
     	/**
        * @description select tasks by WhatId and RecordTypeId
        * @param classInstance
        * @param whatIds
        * @param recordTypeId
        * @return List<Task> - with query results
        */
        public List<Task> selectByWhatIdsAndRecordTypeId(SEL_Tasks classInstance, Set<Id> whatIds, String recordTypeId) {
            return classInstance.selectByWhatIdsAndRecordTypeId(whatIds, recordTypeId);
        }
    }
}