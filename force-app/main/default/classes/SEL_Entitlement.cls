/**
* Selector class for Entitlement SObject
*
* @author Syed Ovais Ali (syed.ali@standardbank.co.za)
* @date Sep 2021
*/

public inherited sharing class SEL_Entitlement extends fflib_SObjectSelector {

    /**
     * Creates a new instance of the selector via the application class. This is here to allow unit tests to override
	 * and inject a mock instead of this class or to switch out this class for a new version.
     * @return SEL_Entitlement class instance
     */ 
	public static SEL_Entitlement newInstance() {
        return (SEL_Entitlement) ORG_Application.selector.newInstance(Entitlement.SObjectType);
    }
    

     /**
     * Returns the SObject fields on this sObject
     * @return Entitlement fields list
     */
	public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
                Entitlement.Id,
                Entitlement.Name 
        };
    }
    
    
    /**
     * Returns the SObject type for the selector. This is used to retrieve the sObject name when building the SOQL
     * queries.
     * @return Entitlement object type
     */
    public Schema.SObjectType getSObjectType() {
        return Entitlement.SObjectType;
    }
    
    /**
    * Select Entitlement filtered by Name
    * @param entitlementName
    *
    * @return list of Entitlement
    */
    public List<Entitlement> selectByName(String entitlementName) {
        return (List<Entitlement>) Database.query(
                newQueryFactory(false, false, false)
                .setCondition('name =: entitlementName')
                .toSOQL()
        );
    }
    
    /**
    * Select Entitlement filtered by Name
    * @param entitlementName
    *
    * @return list of Entitlement
    */
    public List<Entitlement> selectByNameWithoutSharing(String entitlementName) {
        return new WithoutSharing().selectByName(this, entitlementName);
    }
    
     /**
    * Sub class to query data without sharing
    * 
    * @author Syed Ovais Ali (syed.ali@standardbank.co.za)
 	* @date Sep 2021
    */
    private without sharing class WithoutSharing { 
     	/**
        * select Entitlement by Name
        * @param classInstance
        * @param entitlementName
        * @return List<Entitlement> - with query results
        */
        public List<Entitlement> selectByName(SEL_Entitlement classInstance, String entitlementName) {
            return classInstance.selectByName(entitlementName);
        }
    }
    

}