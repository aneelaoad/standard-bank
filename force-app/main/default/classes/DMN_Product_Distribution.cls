/**
 * Domain class for Product Distribution object.
 * <br/>SGPRT-624
 *
 * @author Joanna Milosz (jmilosz@deloittece.com)
 * @date March 2021
 */
public with sharing class DMN_Product_Distribution {
    public static final String BANK_ROLE_TRANSFERRED = 'Transferred';

    /**
    * Method to populate Bank Role field on Product Distribution upon creation.
    * SGPRT-624
    * @param productDistributions list of new Product Distribution records.
    */
    public static void populateBankRole(List<Product_Distribution__c> productDistributions) {
        Set<Id> parentIds = new Set<Id>();
        for (Product_Distribution__c pd : productDistributions){
            parentIds.add(pd.Product__c);
        }

        SEL_Products selProds = SEL_Products.newInstance();
        List<SB_Product__c> parentProductsList = selProds.selectById(parentIds);
        Map<Id, SB_Product__c> parentProducts = new Map<Id, SB_Product__c>(parentProductsList);

        for (Product_Distribution__c pd : productDistributions){
                pd.Bank_Role__c = parentProducts.get(pd.Product__c).Bank_Role__c;
        }
    }
}