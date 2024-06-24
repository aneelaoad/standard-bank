/**
 * Test class for SEL_ChildProducts
 *
 * @author Wayde Fagan (Wayde.fagan@tetrad.co.za)
 * @date March 2021
*/
@IsTest
private class SEL_ChildProducts_Test {
    
	@IsTest
    static void shouldSelectByParentProduct() {
        SEL_ChildProducts.newInstance().selectByParentProduct(new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Knowledge_Parent__c IN :masterKnowledge'));
    }
    
    @IsTest
    static void shouldSelectByParentProductWoSharing() {
        SEL_ChildProducts.newInstance().selectByParentProductWoSharing(new Set<Id>());
        fflib_QueryFactory result = fflib_QueryFactory.lastQueryFactory;
        System.assert(result.getCondition().containsIgnoreCase('Knowledge_Parent__c IN :masterKnowledge'));
    }
}