/**
 * Selector layer class for Case SObject
 *
 * @author Kyle Cockcroft (kcockcroft@deloitte.co.za)
 * @date 2019-04-24
 * @description Selector Class for Case Object
 * 
 *****************************************************************************************
 *   @ Last Modified By  :   Maham Hassan
 *   @ Last Modified On  :   05/04/2022
 *   @ Last Modified Reason  : Get list of Cases based on Ids and Account Id.
 *
 *****************************************************************************************
 */
public with sharing class SEL_Cases extends fflib_SObjectSelector {
    
    /**
     * 
     * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 *              and inject a mock instead of this class or to switch out this class for a new version.
	 * 
     * @return returns instance of SEL_Cases
     */
    public static SEL_Cases newInstance() {
        return (SEL_Cases) ORG_Application.selector.newInstance(Case.SObjectType);
    }
    
    /**
    * 
    * @description Return sObject type of current selector
    *
    * @return Case Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType(){
        return Case.sObjectType;
    }
    
    /**
    *
    * @description return list of standard selector fields
    *
    * @return standard list of selector fields
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField> {
            Case.Id,
            Case.Status,
            Case.isClosed,
            Case.Notification__c,
            Case.RecordTypeId,
            Case.CaseNumber,
            Case.Next_Steps__c,
            Case.Type,
            Case.CreatedDate,
            Case.Resolution_Comment__c,
            Case.Resolved_By__c,
            Case.AccountId,
            Case.OwnerId,
            Case.Subject, 
            Case.Description,
            Case.Origin, 
            Case.CCC_Angola_Category__c,
            Case.CCC_Angola_Sub_Category__c,
            Case.ParentId,
            Case.CCC_Angola_Team__c,
            Case.Priority,
            Case.Email_Address__c,
            Case.SuppliedCompany,
            Case.SuppliedEmail,
            Case.SuppliedName,
            Case.SuppliedPhone
        };
    }
    
    /**
    * 
    * @description Returns list of cases by ID
    *
    * @param idSet Set<ID> of the cases
    * 
    * @return list of selected cases
    */
    public List<Case> selectById(Set<ID> idSet) {

        return (List<Case>) selectSObjectsById(idSet);
    } 
    
    /**
    * 
    * @description Returns list of cases by notification
    *
    * @param isClosed Boolean of the case closed
    * @param notification String notification
    * @param recordTypeId ID of the recordtype to check
    * 
    * @return list of selected cases
    */
    public List<Case> selectByNotification(Boolean isClosed, String notification, Id recordTypeId){
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('isClosed = :isClosed AND Notification__c = :notification AND RecordTypeId = :RecordTypeId');
        return (List<Case>) Database.query( query.toSOQL() );
    }  
    
    /**
    * 
    * @description Returns list of cases by caseId
    *
    * @param caseId ID of the case
    * 
    * @return list of selected cases
    */
    public List<Case> selectByCaseId(Id caseId){
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id = :caseId');
        return (List<Case>) Database.query( query.toSOQL() );
    }  
    
    /**
    * 
    * @description Returns list of cases by case parent ID
    *
    * @param caseParentId ID of the parent case
    * 
    * @return list of selected cases
    */
    public List<Case> selectByParentCaseId(Id caseParentId){
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id = :caseParentId');
        return (List<Case>) Database.query( query.toSOQL() );
    } 
    
    /**
    * 
    * @description Returns list of cases by Id
    *
    * @param newChild String of the child ID
    * 
    * @return list of selected cases
    */
    
    public case mergeCase(String newChild){
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id = :newChild');
        return (Case) Database.query( query.toSOQL() );
    } 
    
    /**
    * 
    * @description Returns list of cases by supplied email
    *
    * @param newChildList List<sobject> set of children object
    * 
    * @return list of selected cases
    */
    public List<Case> mergeMultipleCase(List<sobject> newChildList){
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Id in :newChildList');
        return (List<Case>) Database.query( query.toSOQL() );
    }
    
    /**
    * 
    * @description Returns list of cases by supplied email
    *
    * @param emailsSet Set<String> set of emails
    * @param subjectSet Set<String> set of subjects
    * @return list of selected cases
    */
    public List<Case> selectBySuppliedEmailAndSubject(Set<String>emailsSet,Set<String>subjectSet){
        return (List<Case>) Database.query(
                newQueryFactory().
                        setCondition('SuppliedEmail in :emailsSet AND Subject =: SubjectSet').
                        toSOQL());
    }
    
    /**
    * 
    * @description Returns list of cases by Subject
    * SFP-4835 - OneHub - MySupport Tab related component
    *
    * @param subjectSet Set<String> set of subjects
    * @return list of selected cases
    */
    public List<Case> selectBySubject(Set<String>subjectSet){
        return (List<Case>) Database.query(
                newQueryFactory().
                        setCondition('Subject =: subjectSet').
                        toSOQL());
    }

    /**
    * 
    * @description Returns list of cases by a filter condition
    * SFP-7989 - merging duplicate cases
    *
    * @param accId accountId passed from the parent case
    * @param parSub subject passed from the parent case
    * @param parCaseId parent case Id passed from the parent class
    * @return list of selected cases
    */
    
    public List<Case> selectCasesByCondition(string accId, String parSub, String parCaseId){
        string sub = '%'+parSub+'%';
        
        fflib_QueryFactory articleQueryFactory = newQueryFactory(false, false, true);
        String query = 'AccountId =:accId AND (Subject Like : sub) AND isClosed = False AND Id !=: parCaseID AND parentId = Null' ;
        articleQueryFactory
            .selectField('Id')
            .selectField('CaseNumber')
            .selectField('Subject')
            .selectField('Status')
            .selectField('Account.Name')
            .selectField('Contact.Name')
            .selectField('Origin')
            .selectField('Owner.Name')
            .selectField('CreatedDate')
            .selectField('Custody_Sub_Category__c')
            .selectField('Custody_Category__c')
            .setCondition(query)
            .addOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING)
        	.setLimit(10);
        
        return Database.query(articleQueryFactory.toSOQL());
    }
    
    
    /**
    * 
    * @description Returns list of cases by a  condition
    * SFP-5036 - Creation of Case from Live Agent/Chat
    *
    * @param caseId ID of the Case
    * 
    * @return list of selected cases
    */
    public List<Case> selectTheCaseById(ID caseId) {
		List<Case> caseList = new List<Case>();
        fflib_QueryFactory articleQueryFactory = newQueryFactory(false, false, true);
        String query = 'Id =:caseId';
        articleQueryFactory
            .selectField('Id')
            .selectField('caseNumber')
            .selectField('Live_Chat_Transcript__c')            
            .setCondition(query);
        return Database.query(articleQueryFactory.toSOQL());
    } 
    
    /**
    * 
    * @description Returns list of cases by a  condition
    * SFP-5036 - Creation of Case from Live Agent/Chat
    *
    * @param caseSubject subject of the Case
    * 
    * @return list of selected cases
    */
    public List<Case> selectCasesBySubject(set<String> caseSubject) {
		List<Case> caseList = new List<Case>();
        fflib_QueryFactory articleQueryFactory = newQueryFactory(false, false, true);
        String query = 'subject =:caseSubject';
        articleQueryFactory
            .selectField('Id')
            .selectField('caseNumber')
            .selectField('Subject')            
            .setCondition(query);
        return Database.query(articleQueryFactory.toSOQL());
    } 

    /**
    * 
    * @description Returns list of cases by a  condition
    *
    * @param caseIds List of the Case Ids
    * 
    * @return list of selected cases
    */
    public List<Case> selectCasesByids(set<Id> caseIds) {

        return Database.query(newQueryFactory(false, false, true)
                            .selectField('Account.Name')
                            .selectField('Contact.Email')
                            .selectField('Account.ParentId')
                            .selectField('Owner.Name')
                            .selectField('Contact.OtherPhone')
                            .selectField('Contact.MobilePhone')
                            .selectField('Contact.Name')
                            .setCondition('Id in : caseIds')
                            .toSOQL()
                            );
    } 


    /**
    * 
    * @description Returns list of cases by a  condition
    *
    * @param accountIds Set of the Account Id
    * 
    * @return list of selected cases
    */
    public List<Case> selectCasesByAccountIds(Set<Id> accountIds) {

        return Database.query(newQueryFactory(false, false, true)
                            .selectField('Account.Name')
                            .selectField('Contact.Email')
                            .selectField('Account.ParentId')
                            .selectField('Contact.OtherPhone')
                            .selectField('Owner.Name')
                            .selectField('Contact.MobilePhone')
                            .selectField('Contact.Name')
                            .setCondition('AccountId In: accountIds')
                            .toSOQL()
                            );
    } 
}