/**
 * 
 * @description Denormalized Class for Event
 * @author Maham Hasan
 * @since 
 */
@isTest
public class DenormalizedEventTest {

     @IsTest
    static void denormalizedContentTest(){
        
       
        Test.startTest();
        DenormalizedEvent denormalizedEvent = new DenormalizedEvent();
        Test.stopTest();

        Assert.areNotEqual(null, denormalizedEvent, 'Expected Outcome');
        
    }
}