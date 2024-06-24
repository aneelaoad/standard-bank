/**
 * Test class for SEL_Option_List_Item
 *
 * @author Joanna Milosz (jmilosz@deloittece.com)
 * @date April 2021
 */
@IsTest(IsParallel=true)
private class SEL_Option_List_Item_Test {
    @IsTest
    static void shouldSelectWithoutCondition() {
        List<Option_List_Item__c> result = SEL_Option_List_Item.newInstance().selectWithoutCondition();
        System.assertNotEquals(null, result);
    }

    @IsTest
    static void selectByName() {
        List<Option_List_Item__c> result= SEL_Option_List_Item.newInstance().selectByName(new Set<String>());
        System.assertNotEquals(null, result);
    }
}