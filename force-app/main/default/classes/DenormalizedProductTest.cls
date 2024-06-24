/**
 * 
 * @description DenormalizedProductTest
 * @author Ankit Kumar
 * @since 
 */
@IsTest
public with sharing class DenormalizedProductTest {
    
    @IsTest
    static void testDenormalizedProduct(){
        Test.startTest();
        DenormalizedProduct denormalizedProductRec = new DenormalizedProduct();
        DenormalizedProduct denormalizedProductCopy = DenormalizedProduct.parse(System.JSON.serialize(denormalizedProductRec));

        Test.stopTest();
        Assert.areNotEqual(null, denormalizedProductRec, 'denormalized product should not be null');
        Assert.areNotEqual(null, denormalizedProductCopy, 'denormalized product copy should not be null');
    }
}