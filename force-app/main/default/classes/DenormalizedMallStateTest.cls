/**
 * 
 * @description DenormalizedMallStateTest
 * @author Ankit Kumar
 * @since 
 */
@istest
public with sharing class DenormalizedMallStateTest {
    
    @IsTest
    static void testDenormalizedMallState(){
        Test.startTest();        
        DenormalizedMallState mallState = new DenormalizedMallState();
        mallState.products = new List<DenormalizedProduct>();
        Test.stopTest();
        Assert.areNotEqual(mallState, null, 'denormalized mall state should not be null');
    }
}