/**
 * 
 * @description DenormalizedPromotionTest
 * @author Ankit Kumar
 * @since 
 */
@IsTest
public with sharing class DenormalizedPromotionTest {
    
    @IsTest
    static void testDenormalizedPromotion(){
        Test.startTest();
        DenormalizedPromotion denormalizedPromotionRec = new DenormalizedPromotion();
        DenormalizedPromotion denormalizedPromotionCopy = DenormalizedPromotion.parse(System.JSON.serialize(denormalizedPromotionRec));

        Test.stopTest();
        Assert.areNotEqual(null, denormalizedPromotionRec, 'denormalized promotion should not be null');
        Assert.areNotEqual(null, denormalizedPromotionCopy, 'denormalized promotion copy should not be null');
    }
}