/**
 * 
 * @description DenormalizedLinkTest
 * @author Ankit Kumar
 * @since 
 */
@isTest
public with sharing class DenormalizedLinkTest {
    
    @IsTest
    static void testDenormalizedLInks(){
        Test.startTest();
        DenormalizedLink denormalizedLink = new DenormalizedLink();
        Test.stopTest();
        Assert.areNotEqual(null, denormalizedLink, 'denormalized link should not be null');
        
    }
}