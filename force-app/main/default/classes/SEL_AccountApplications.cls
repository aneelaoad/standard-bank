/**
 * Account Application Selector Layer class.
 *
 * @author Caro Reinecke (caro@khonology.com)
 * @date 2018-01-08
 */
public class SEL_AccountApplications extends fflib_SObjectSelector {

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                Account_Application__c.OnboardingApplicationID__c,
                Account_Application__c.Id,
                Account_Application__c.Client__c,
                Account_Application__c.Account_Details_Confirmed__c,
                Account_Application__c.Application_Status__c,
                Account_Application__c.Bank_Account_Name__c,
                Account_Application__c.Bank_Account_Number__c,
                Account_Application__c.Bank_Account_Type__c,
                Account_Application__c.Bank_Account_Active__c,
                Account_Application__c.Statement_Delivery_Frequency__c,
                Account_Application__c.Statement_Delivery_Destination__c,
                Account_Application__c.Statement_Delivery_Method__c,
                Account_Application__c.Requested_By__c,
                Account_Application__c.Requester_Number__c
        };
    }

    public Schema.SObjectType getSObjectType() {

        return Account_Application__c.sObjectType;
    }

    public List<Account_Application__c> selectById(Set<ID> idSet) {

        return (List<Account_Application__c>) selectSObjectsById(idSet);
    }

    public List<Account_Application__c> selectByApplicationId(Set<Decimal> IdSet) {

        return (List<Account_Application__c>) Database.query(
                newQueryFactory().
                        setCondition('OnboardingApplicationID__c in :IdSet').
                        toSOQL());
    }
}