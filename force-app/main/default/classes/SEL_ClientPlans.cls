/**
 * Created by: Dyllan Higgins
 * Date created: 30 March 2021
 * Description: Select Client Plan ID using fflib_SObjectSelector 
 */

public inherited sharing class SEL_ClientPlans extends fflib_SObjectSelector {

        /**
	 * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     * 
     * @return returns instance of SEL_ClientPlans
	 */
    public static SEL_ClientPlans newInstance() {
        return(SEL_ClientPlans) ORG_Application.selector.newInstance(Client_Plan__c.SObjectType);
    }

    /**
    * Return sObject type of current selector
    *
    * @return Contact Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType(){
        return Client_Plan__c.sObjectType;
  }

    /**
    * return list of standard selector fields
    *
    * @return standard list of selector fields
    */
    public List<Schema.SObjectField> getSObjectFieldList(){
        return new List<Schema.SObjectField>{
            Client_Plan__c.Id
    };
  }

/**
 * This is used to retrieve <Client_Plan__c> records . No condtions
 * 
 * @return list of Client_Plan__c records
 */
public List<Client_Plan__c> selectNoCondition(){
    return (List<Client_Plan__c>) Database.query(
        newQueryFactory()
        .toSOQL());
}


}