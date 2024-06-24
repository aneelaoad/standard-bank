/**
 * 
 * @description DenormalizedShopTest
 * @author Ankit Kumar
 * @since 
 */
@isTest
public with sharing class DenormalizedShopTest {
    
    @IsTest
    static void testDenormalizedShop(){
        Test.startTest();
        DenormalizedShop denormalizedShopRec = new DenormalizedShop();
        DenormalizedShop denormalizedShopCopy = DenormalizedShop.parse(System.JSON.serialize(denormalizedShopRec));

        Test.stopTest();
        Assert.areNotEqual(null, denormalizedShopRec, 'denormalized shop should not be null');
        Assert.areNotEqual(null, denormalizedShopCopy, 'denormalized shop copy should not be null');
    }
}