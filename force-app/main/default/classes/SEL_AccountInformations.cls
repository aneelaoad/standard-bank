/**
 * Created by zwalczewska on 08.05.2020.
 */
public with sharing class SEL_AccountInformations extends fflib_SObjectSelector {

    public Schema.SObjectType getSObjectType(){
        return Account_Information__c.SObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField>{
                Account_Information__c.Id,
                Account_Information__c.Account_Status__c,
                Account_Information__c.Name,
                Account_Information__c.Account_Name__c,
                Account_Information__c.Client__c,
                Account_Information__c.Actual_Balance__c,
                Account_Information__c.Current_Balance__c,
                Account_Information__c.CreatedById,
                Account_Information__c.CurrencyIsoCode,
                Account_Information__c.Current_Monthly_Payment__c,
                Account_Information__c.Current_Limit__c,
                Account_Information__c.ERL__c,
                Account_Information__c.Expected_Monthly_Turnover__c,
                Account_Information__c.Facility_Limit__c,
                Account_Information__c.Headroom__c,
                Account_Information__c.Month_Since_Account_Open__c,
                Account_Information__c.Net_Interest_Income__c,
                Account_Information__c.Non_Interest_Revenue__c,
                Account_Information__c.Operating_Income__c,
                Account_Information__c.OwnerId,
                Account_Information__c.PMT_Extract_Date__c,
                Account_Information__c.Proact_External_Id__c,
                Account_Information__c.Product_Category__c,
                Account_Information__c.Product_Name__c,
                Account_Information__c.Product_Sub_Category__c,
                Account_Information__c.Rate_Primary__c,
                Account_Information__c.YTD_Credit_Balance__c,
                Account_Information__c.YTD_Debit_Balance__c
        };
    }

    /**
	 * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
	 */
    public static SEL_AccountInformations newInstance() {
        return(SEL_AccountInformations) ORG_Application.selector.newInstance(Account_Information__c.SObjectType);
    }


    public List<Account_Information__c> selectById(Set<Id> recordIds){
        return (List<Account_Information__c>) selectSObjectsById(recordIds);
    }

    public List<Account_Information__c> selectWithParentAccountById(Set<Id> recordIds) {
        return (List<Account_Information__c>) Database.query(
                newQueryFactory().
                        setCondition('Id in :recordIds').
                        selectField('Client__r.GUID__c').
                        toSOQL());
    }

    public List<Account_Information__c> selectByParentAccountId(Set<Id> clientIds) {
        return (List<Account_Information__c>) Database.query(
                newQueryFactory().
                        setCondition('Client__c in :clientIds').
                        selectField('Client__r.Name').
                        toSOQL());
    }

    public List<Account_Information__c> selectByIdWithPMTExtractDateOrdering(Set<Id> clientIds) {
        return (List<Account_Information__c>) Database.query(
                newQueryFactory().
                        setCondition('Client__c in :clientIds').
                        selectField('Headroom__c').
                        selectField('Expected_Monthly_Turnover__c').
                        selectField('ERL__c').
                        addOrdering('PMT_Extract_Date__c', fflib_QueryFactory.SortOrder.DESCENDING).
                        toSOQL());
    }

    public Database.QueryLocator queryLocatorAllAccountInformations(){
        return Database.getQueryLocator(
                newQueryFactory().toSOQL()
        );
    }

    public List<Account_Information__c> selectWithParentAccount(){
        return Database.query(
                newQueryFactory()
                        .selectField('Client__r.Name')
                        .toSOQL()
        );
    }
}