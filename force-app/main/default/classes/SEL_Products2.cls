/**
 * Selector layer class for Product2 SObject
 *
 * @author Nikita Haruk
 * @date 2022-08-30
 *
 * @last modified by  : Maksim Dzianisik
 * @last modified on  : Apr 2024
 * @description       : SFP-37196 added additional fields to the selected list
 */
public inherited sharing class SEL_Products2 extends fflib_SObjectSelector {

    /**
     * @description This is used to retrieve the sObject name when building the SOQL
     * queries.
     *
     * @return the SObject type for the selector.
    */
    public Schema.SObjectType getSObjectType(){
        return Product2.SObjectType;
    }

    /**
     * @description Creates a new instance of the selector via the application class. This is here to allow unit tests to override
     * and inject a mock instead of this class or to switch out this class for a new version.
     *
     * @return instance of the class
    */
    public static SEL_Products2 newInstance() {
        return (SEL_Products2) ORG_Application.selector.newInstance(Product2.SObjectType);
    }

    /**
     * @description This is used to retrieve a specific set of SObject fields
     *
     * @return List of SObjectField
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Product2.Id,
            Product2.Name,
            Product2.Grand_Parent_Product__c,
            Product2.Parent_Product__c,
            Product2.Product_Division__c,
            Product2.ProductCode,
            Product2.Risk_Weighted_Value__c,
            Product2.Non_Advisory_IB_Fees_Product__c,
            Product2.IsActive
        };
    }        
    /**
     * @description Returns CIB related AND User_Division related Products from Product2 object used on search operation on custom lwc component    
     *
     * @param userDivs - User-division field  
     * @return List of Product2 records
    */
    public List<Product2> selectCIBRelatedProducts2(String[] userDivs) {      
        return (List<Product2>) Database.query(
            newQueryFactory()
                .setCondition('Grand_Parent_Product__c != null AND Product_Division__c != null AND Product_Division__c IN :userDivs AND isActive = TRUE')            	
                .setOrdering('Grand_Parent_Product__c' , fflib_QueryFactory.SortOrder.ASCENDING, true)
                .toSOQL()
        );
    }

    /**
    * @description 
    * @author 
    * @param nameSet
    * @return List<Product2> 
    * Modification Log:
    * Tukelo - condition change from Product2 to Name
    **/
    public List<Product2> selectByProductName(Set<String> nameSet) {

        return (List<Product2>) Database.query(
                newQueryFactory().
                        setCondition('Name in :nameSet').
                        toSOQL());
    }
    
     /**
     * @description Returns Products by provided Id   
     *
     * @param prodIds - product2 Ids  
     * @return List of Product2 records
    */
    public List<Product2> selectByIds(Set<Id> prodIds) {
        return (List<Product2>) Database.query(
                newQueryFactory()
                        .setCondition('Id IN :prodIds')
                        .toSOQL()
        );
    }
    /**
     * @description Returns Products by their product Codes
     *
     * @param prodCodes - product Codes
     * @return List of Product2 records
    */
    public List<Product2> selectByProductCodes(Set<String> prodCodes) {
        return (List<Product2>) Database.query(
                newQueryFactory()
                        .setCondition('ProductCode IN :prodCodes')
                        .toSOQL()
        );
    }


     /**
     * @description Returns Products by their product Codes
     *
     * @param prodCodes - product Codes
     * @return List of Product2 records
    */
    public List<Product2> selectByProductCodeslist(String prodCodes) {
        return (List<Product2>) Database.query(
                newQueryFactory()
                        .setCondition('ProductCode = :prodCodes')
                        .toSOQL()
        );
    }


    
}